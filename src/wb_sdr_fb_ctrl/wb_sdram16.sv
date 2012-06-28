//----------------------------------------------------------------------------
// Wishbone SDRAM controller with secondary host port for frame buffer access
//----------------------------------------------------------------------------
`default_nettype none 
module wb_sdram16  #(
	parameter                  adr_width = 22    
       ) (
	input logic                     clk,
        input logic                     clk_locked,
	input logic                     reset,
	// Wishbone interface
	input logic                     wb_stb_i,
	input logic                     wb_cyc_i,
	output logic               wb_ack_o,
	input  logic                    wb_we_i,
	input  logic             [31:0] wb_adr_i,
	input  logic              [3:0] wb_sel_i,
	input  logic             [31:0] wb_dat_i,
	output logic        [31:0] wb_dat_o,
	// SDRAM connection
        inout   wire [15:0]  dram_dq,   //      Sdram Data bus 16 Bits
        output  logic [11:0]  dram_addr, //      Sdram Address bus 12 Bits
        output  logic dram_ldqm,         //      Sdram Low-byte Data Mask 
        output  logic dram_udqm,         //      Sdram High-byte Data Mask
        output  logic dram_we_n,         //      Sdram Write Enable
        output  logic dram_cas_n,        //      Sdram Column Address Strobe
        output  logic dram_ras_n,        //      Sdram Row Address Strobe
        output  logic dram_cs_n,         //      Sdram Chip Select
        output  logic dram_ba_0,         //      Sdram Bank Address 0
        output  logic dram_ba_1,         //      Sdram Bank Address 0
        output  logic dram_clk,          //      Sdram Clock
        output  logic dram_cke,          //      Sdram Clock Enable
        // SDRAM secondary  ACCESS
        input logic sdr_rd            ,      // initiate read operation
        input logic sdr_wr            ,      // initiate write operation
        output logic sdr_earlyOpBegun ,      // read/write op has begun (async)
        output logic sdr_opBegun      ,      // read/write op has begun (clocked)
        output logic sdr_rdPending    ,      // true if read operation(s) are still in the pipeline
        output logic sdr_done         ,      // read or write operation is done
        output logic sdr_rdDone       ,      // read operation is done and data is available
        input logic [21:0] sdr_hAddr  ,  // address from host to SDRAM
        input logic [15:0] sdr_hDIn ,     // data from host to SDRAM
        output logic [15:0] sdr_hDOut ,   // data from SDRAM to host
        output logic [3:0] sdr_status   // diagnostic status of the SDRAM controller FSM     
);

//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------

assign dram_clk = clk ;
// Wishbone handling
logic wbi_rdDone ; // sdram controller read acknoledge
logic wbi_earlyOpBegun ; //  sdram_controller ack
logic wbi_opBegun ; //  sdram_controller ack
logic wbi_wr ; // sdram controller write signal
logic wb_ack_o_wr ;
logic wbi_rdPending ;
logic [15:0]wbi_hDOut ;
logic [21:0] wbi_hAddr0 ;
logic [22+16-1:0] wb_write_fifo_data_out ;
assign wb_ack_o = wb_ack_o_wr | wbi_rdDone ;
wire wbi_rd = wb_stb_i & wb_cyc_i & ~wb_we_i & ~wbi_rdPending & ~wbi_rdDone   ;
assign wb_dat_o = {wbi_hDOut , wbi_hDOut} ; 
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i & ~wb_ack_o;
assign wbi_hAddr0 = wbi_wr ? wb_write_fifo_data_out[21+16:0+16] : wb_adr_i[22:1] ;      

//----------------------------------------------------------------------------
// Synchronous FIFO for Write access buffering
//----------------------------------------------------------------------------
logic wb_write_fifo_empty ;
logic wb_write_fifo_almost_empty ;
logic wb_write_fifo_full ;
logic wb_write_fifo_almost_full ;
wire wb_write_fifo_rd_en = wbi_earlyOpBegun & ~wb_write_fifo_empty & wbi_wr   ;
wire wb_write_fifo_wr_en = wb_wr & ~wb_write_fifo_full ;
sync_fifo
       #(.DATA_WIDTH(22+16), // Store Addresses + Data
	 .RAM_DEPTH(16),
	 .ALMOST_EMPTY_VAL(1),
	 .ALMOST_FULL_VAL(15))
         wb_write_fifo
	 (
         .clk(clk)      , // Clock input
         .rst(reset)    , // Active high reset
         .data_in({wb_adr_i[22:1],wb_dat_i[15:0]}), // Store Address + data, only 16 data addresses are used.
         .rd_en(wb_write_fifo_rd_en)    , // Read enable
         .wr_en(wb_write_fifo_wr_en)    , // Write Enable
         .data_out(wb_write_fifo_data_out) ,// Data Output
         .empty(wb_write_fifo_empty)    , // FIFO empty
	 .almost_empty(wb_write_fifo_almost_empty), // FIFO almost empty
         .full(wb_write_fifo_full),       // FIFO full
	 .almost_full(wb_write_fifo_almost_full) // FIFO almost full
);    
 


//----------------------------------------------------------------------------
// State Machine for WishBone 
//----------------------------------------------------------------------------
enum logic [2:0] {s_idle, s_write  }  state;

always @(posedge clk)
begin
  if (reset)
  begin
    state    <= s_idle;
    wb_ack_o_wr <= 0;
   end 
   else 
   begin
     case (state)
	s_idle: begin
          wb_ack_o_wr <= 0;
          if (wb_write_fifo_wr_en)  begin
  	     wb_ack_o_wr   <=  1;
             state      <=  s_write;
          end
        end
	s_write: begin
          wb_ack_o_wr <= 0;
          state <= s_idle ;
        end
     endcase
   end
end
                
// SDRAM CTRL SIGNAL GENERATION
always @(posedge clk or posedge reset)
if (reset) begin
  wbi_wr <= 1'b0 ;
end
else
begin
 wbi_wr <= ~wb_write_fifo_empty ;
end

// Real SDRAM CTRL INSTANTIATION
logic ctrl_rst ;
logic ctrl_rd ;
logic ctrl_wr ;
logic ctrl_earlyOpBegun ;
logic ctrl_opBegun ;
logic ctrl_rdPending ;
logic ctrl_done ;
logic ctrl_rdDone ;
logic [21:0]ctrl_hAddr ;
logic [15:0]ctrl_hDIn ;
logic [15:0]ctrl_hDOut ;
logic [3:0]ctrl_status ;

logic wbi_done ;
logic [3:0]wbi_status ;

// Dual PORT splitter instance
XessDualport u_dualport(
    .clk(clk) ,
     // Host Side port 0 (WishBone)
     .rst0(reset),    
     .rd0(wbi_rd),           
     .wr0(wbi_wr),           
     .earlyOpBegun0(wbi_earlyOpBegun), 
     .opBegun0(wbi_opBegun),      
     .rdPending0(wbi_rdPending),    
     .done0(wbi_done),         
     .rdDone0(wbi_rdDone),       
     .hAddr0(wbi_hAddr0),       
     .hDIn0(wb_write_fifo_data_out[15:0]),        
     .hDOut0(wbi_hDOut),       
     .status0(wbi_status),       
     // Host Side port 1 (External Access)
     .rst1(reset),    
     .rd1(sdr_rd),           
     .wr1(sdr_wr),           
     .earlyOpBegun1(sdr_earlyOpBegun), 
     .opBegun1(sdr_opBegun),      
     .rdPending1(sdr_rdPending),    
     .done1(sdr_done),         
     .rdDone1(sdr_rdDone),       
     .hAddr1(sdr_hAddr),       
     .hDIn1(sdr_hDIn),        
     .hDOut1(sdr_hDOut),       
     .status1(sdr_status),       
     // Controler Side
     .rst(ctrl_rst),
     .rd(ctrl_rd) ,
     .wr(ctrl_wr) ,
     .earlyOpBegun(ctrl_earlyOpBegun),
     .opBegun(ctrl_opBegun),
     .rdPending(ctrl_rdPending) ,
     .done(ctrl_done),
     .rdDone(ctrl_rdDone),
     .hAddr(ctrl_hAddr),
     .hDIn(ctrl_hDIn),
     .hDOut(ctrl_hDOut),
     .status(ctrl_status)
    );

XessSdramCntl u_sdramcntl(
    .clk(clk) ,
    .lock(clk_locked) ,
    // SDRAM interface
    .cke(dram_cke) ,
    .cs_n(dram_cs_n),
    .ras_n(dram_ras_n),
    .cas_n(dram_cas_n),
    .we_n(dram_we_n),
    .ba({dram_ba_1,dram_ba_0}),
    .sAddr(dram_addr),
    .sDQ(dram_dq),
    .dqmh(dram_udqm),
    .dqml(dram_ldqm),
    // host port connections
    .rst(ctrl_rst),
    .rd(ctrl_rd) ,
    .wr(ctrl_wr) ,
    .earlyOpBegun(ctrl_earlyOpBegun),
    .opBegun(ctrl_opBegun),
    .rdPending(ctrl_rdPending) ,
    .done(ctrl_done),
    .rdDone(ctrl_rdDone),
    .hAddr(ctrl_hAddr),
    .hDIn(ctrl_hDIn),
    .hDOut(ctrl_hDOut),
    .status(ctrl_status)
    );

     
    



endmodule
