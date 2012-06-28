// TPT/YM 2009 SINGLE CLOCK SYNCHRONOUS FIFO
// DATA_WIDTH : witdh of datas
// RAM_DEPTH  : number of datas
// ALMOST_EMPTY_VAL : number of remaining values in the fifo for an active ALMOST_EMPTY flag
// ALMOST_FULL_VAL  : number of sotred values in the fifo for an active ALMOST_FULL flag


module sync_fifo
       #(parameter DATA_WIDTH = 8,
	 parameter RAM_DEPTH = 8,
	 parameter ALMOST_EMPTY_VAL = 1,
	 parameter ALMOST_FULL_VAL = RAM_DEPTH-1)
	 (
         input logic clk      , // Clock input
         input logic rst      , // Active high reset
         input logic [DATA_WIDTH-1:0] data_in , // Data input
         input logic rd_en    , // Read enable
         input logic wr_en    , // Write Enable
         output logic [DATA_WIDTH-1:0] data_out ,// Data Output
         output logic empty    , // FIFO empty
	 output logic almost_empty, // FIFO almost empty
         output logic full,       // FIFO full
	 output logic almost_full // FIFO almost full
);    
 
function integer clogb2;
input [31:0]  value;
begin
  int i ;
  if ((value == 0) || (value == 1)) clogb2 = 0 ;
  else
    begin
    value = value-1 ;
    for (i = 0; i < 32; i++)
      if (value[i]) clogb2 = i+1 ;
  end
end
endfunction

localparam  ADDR_WIDTH = clogb2(RAM_DEPTH) ;

//-----------Internal variables-------------------
logic [ADDR_WIDTH-1:0] wr_pointer;
logic [ADDR_WIDTH-1:0] rd_pointer;
logic [ADDR_WIDTH :0] status_cnt;

logic write, read ;



// Internal memory
logic [DATA_WIDTH-1 :0] mem [RAM_DEPTH-1:0] ;
always @ (posedge clk )
begin
  if(write)
    mem[wr_pointer] <= data_in ;
  data_out <= mem[rd_pointer] ;
end

//-----------Variable assignments---------------
assign full = (status_cnt == RAM_DEPTH);
assign almost_full = (status_cnt == ALMOST_FULL_VAL) ;
assign empty = (status_cnt == 0);
assign almost_empty = (status_cnt == ALMOST_EMPTY_VAL) ;
assign write = wr_en && (~full || rd_en) ;
assign read  = rd_en && (~empty || wr_en) ;

//-----------Code Start---------------------------
always @ (posedge clk )
begin : WRITE_POINTER
  if (rst) 
    wr_pointer <= 0;
  else if (write) 
    wr_pointer <= wr_pointer + 1;
end

always @ (posedge clk )
begin : READ_POINTER_DATA
  if (rst) 
    rd_pointer <= 0;
  else if (read) 
    rd_pointer <= rd_pointer + 1;
end


always @ (posedge clk )
begin : STATUS_COUNTER
  if (rst) 
    status_cnt <= 0;
   // Read but no write.
  else if (( rd_en) && !( wr_en) && (status_cnt != 0)) 
    status_cnt <= status_cnt - 1;
  // Write but no read.
  else if (( wr_en) && !( rd_en) && (status_cnt != RAM_DEPTH))
    status_cnt <= status_cnt + 1;
end 
   
endmodule
