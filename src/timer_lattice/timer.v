// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2006 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                         FILE DETAILS
// Project          : LM32 Timer
// File             : timer.v
// Title            : Timer component core file
// Dependencies     : None
// Version          : 7.0
//                  : Initial Release
// Version          : 7.0SP2, 3.0
//                  : No Change
// =============================================================================
`ifndef TIMER_FILE
`define TIMER_FILE
module timer #(
   parameter PERIOD_NUM   = 20,//decimal
   parameter PERIOD_WIDTH = 16,//decimal
   parameter WRITEABLE_PERIOD  = 1,
   parameter READABLE_SNAPSHOT = 1,
   parameter START_STOP_CONTROL = 1,
   parameter TIMEOUT_PULSE = 1,
   parameter WATCHDOG = 0)
             (
             //slave port
             S_ADR_I,    //32bits
             S_DAT_I,    //32bits
             S_WE_I,
             S_STB_I,
             S_CYC_I,
             S_CTI_I,
             S_BTE_I,
             S_LOCK_I,
             S_SEL_I,
             S_DAT_O,    //32bits
             S_ACK_O,
             S_RTY_O,
             S_ERR_O,
             S_INT_O,
             RSTREQ_O,   //resetrequest, only used when WatchDog enabled
             TOPULSE_O,  //timeoutpulse, only used when TimeOutPulse enabled
             //system clock and reset
             CLK_I,
             RST_I
             );

   input  [31:0]  S_ADR_I;
   input  [31:0]  S_DAT_I;
   input          S_WE_I;
   input          S_STB_I;
   input          S_CYC_I;
   input  [2:0]   S_CTI_I;
   input          S_LOCK_I;
   input  [3:0]   S_SEL_I;
   input  [1:0]   S_BTE_I;
   output [31:0]  S_DAT_O;
   output         S_ACK_O;
   output         S_INT_O;
   output         S_RTY_O;
   output         S_ERR_O;
   output         RSTREQ_O;
   output         TOPULSE_O;

   input          CLK_I;
   input          RST_I;

   parameter  UDLY     = 1;
   parameter  ST_IDLE  = 2'b00;
   parameter  ST_CNT   = 2'b01;
   parameter  ST_STOP  = 2'b10;

   reg  dw00_cs;
   reg  dw04_cs;
   reg  dw08_cs;
   reg  dw0c_cs;
   reg  reg_wr;
   reg  reg_rd;
   reg  [31:0] latch_s_data;
   reg  [1:0]  reg_04_data;
   reg         reg_run;
   reg         reg_stop;
   reg         reg_start;
   reg [1:0]   status;
   reg  [PERIOD_WIDTH-1:0] internal_counter;
   reg  [PERIOD_WIDTH-1:0] reg_08_data;
   reg  s_ack_dly;
   reg  s_ack_2dly;
   reg  s_ack_pre;
   reg  RSTREQ_O;
   reg  TOPULSE_O;
   reg  reg_to;

   wire        reg_cont;
   wire        reg_ito;
   wire [1:0]  read_00_data;
   wire [1:0]  read_04_data;
   wire [PERIOD_WIDTH-1:0] read_08_data;
   wire [PERIOD_WIDTH-1:0] read_0c_data;
   wire [PERIOD_WIDTH-1:0] reg_period;
   wire        S_ACK_O;
   wire [31:0] S_DAT_O;
   wire        S_INT_O;

   assign     S_RTY_O = 1'b0;
   assign     S_ERR_O = 1'b0;

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       latch_s_data     <= #UDLY 32'h0;
     else
       latch_s_data     <= #UDLY S_DAT_I;

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       begin
          dw00_cs   <= #UDLY 1'b0;
          dw04_cs   <= #UDLY 1'b0;
          dw08_cs   <= #UDLY 1'b0;
          dw0c_cs   <= #UDLY 1'b0;
       end
     else
       begin
          dw00_cs   <= #UDLY (!(|S_ADR_I[5:2]));
          dw04_cs   <= #UDLY (S_ADR_I[5:2] == 4'h1);
          dw08_cs   <= #UDLY (S_ADR_I[5:2] == 4'h2);
          dw0c_cs   <= #UDLY (S_ADR_I[5:2] == 4'h3);
       end

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       begin
          reg_wr    <= #UDLY 1'b0;
          reg_rd    <= #UDLY 1'b0;
       end
     else
       begin
          reg_wr    <= #UDLY S_WE_I && S_STB_I && S_CYC_I;
          reg_rd    <= #UDLY !S_WE_I && S_STB_I && S_CYC_I;
       end

   generate
   if (START_STOP_CONTROL == 1)

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       begin
          status                   <= #UDLY ST_IDLE;
          internal_counter         <= #UDLY 'h0;
       end
     else
       case(status)
         ST_IDLE:
           begin
             if(reg_wr && dw08_cs)
               begin
               internal_counter <= #UDLY (WRITEABLE_PERIOD == 1) ? latch_s_data : reg_period;
               end
             else if(reg_start && !reg_stop)
               begin
               status           <= #UDLY ST_CNT;
               if(|reg_period)
                 internal_counter <= #UDLY reg_period - 1;
               end
           end
         ST_CNT:
           begin
              if(reg_stop && (|internal_counter))
                status           <= #UDLY ST_STOP;
              else if(reg_wr && dw08_cs)
                begin
                internal_counter <= #UDLY (WRITEABLE_PERIOD == 1) ? latch_s_data : reg_period;
                if(!(|internal_counter) && !reg_cont)
                   status        <= #UDLY ST_IDLE;
                end
              else if(!(|internal_counter))
                begin
                if(!reg_cont)
                  begin
                  status         <= #UDLY ST_IDLE;
                  end
                internal_counter <= #UDLY reg_period;
                end
              else
                internal_counter <= #UDLY internal_counter - 1;
           end
         ST_STOP:
           begin
              if(reg_start && !reg_stop)
                status           <= #UDLY ST_CNT;
              else if(reg_wr && dw08_cs)
                begin
                internal_counter <= #UDLY (WRITEABLE_PERIOD == 1) ? latch_s_data : reg_period;
                end
           end
        default:
           begin
              status               <= #UDLY ST_IDLE;
              internal_counter     <= #UDLY 'h0;
           end
       endcase
   endgenerate


   generate
   if (START_STOP_CONTROL == 0)
   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       internal_counter         <= #UDLY 'h0;
     else if ((reg_wr && dw08_cs) && (WATCHDOG == 1) || !(|internal_counter))
       internal_counter         <= #UDLY reg_period;
     else
       internal_counter         <= #UDLY internal_counter - 1;
   endgenerate

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       reg_to        <= #UDLY 1'b0;
     else if(reg_wr && dw00_cs && (!latch_s_data[0]))
       reg_to        <= #UDLY 1'b0;
     else if(!(|internal_counter) && reg_ito && ((START_STOP_CONTROL == 0) || reg_run))
       reg_to        <= #UDLY 1'b1;

   generate
   if (START_STOP_CONTROL == 1)
   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       reg_run       <= #UDLY 1'b0;
     else if(reg_stop)
       reg_run       <= #UDLY 1'b0;
     else if(reg_start)
       reg_run       <= #UDLY 1'b1;
     else
       reg_run       <= #UDLY (status !== ST_IDLE);
   endgenerate

   assign read_00_data   = (START_STOP_CONTROL == 1) ? {reg_run,reg_to} : {1'b1,reg_to};

   //reg_04:control
   assign      {reg_cont,reg_ito} = reg_04_data;

   generate
   if (START_STOP_CONTROL == 1)
   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       reg_stop      <= #UDLY 1'b0;
     else if(reg_wr && dw04_cs)
       begin
          if(latch_s_data[3] && !latch_s_data[2] && !reg_stop)
            reg_stop  <= #UDLY 1'b1;
          else if(!latch_s_data[3] && latch_s_data[2] && reg_stop)
            reg_stop  <= #UDLY 1'b0;
       end

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       reg_start     <= #UDLY 1'b0;
     else if(reg_wr && dw04_cs && !reg_run)
       reg_start     <= #UDLY latch_s_data[2];
     else
       reg_start     <= #UDLY 1'b0;
   endgenerate

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       reg_04_data   <= #UDLY 2'h0;
     else if(reg_wr && dw04_cs)
       reg_04_data   <= #UDLY latch_s_data[1:0];

   assign  read_04_data   = reg_04_data;

  generate
  if (WRITEABLE_PERIOD == 1) begin
    assign reg_period     = reg_08_data;
    assign read_08_data   = reg_08_data;
    always @(posedge CLK_I or posedge RST_I) begin
     if (RST_I)
       reg_08_data   <= #UDLY PERIOD_NUM;
     else if ((reg_wr && dw08_cs) && (START_STOP_CONTROL == 1))
       reg_08_data   <= #UDLY latch_s_data;
	 end
   end
  else
     assign reg_period   = PERIOD_NUM;
  endgenerate

  generate
  if (READABLE_SNAPSHOT == 1)
    assign  read_0c_data   = internal_counter;
  endgenerate

   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       begin
          s_ack_pre     <= #UDLY 1'b0;
          s_ack_dly     <= #UDLY 1'b0;
          s_ack_2dly    <= #UDLY 1'b0;
       end
     else
       begin
          s_ack_pre     <= #UDLY S_STB_I && S_CYC_I;
          s_ack_dly     <= #UDLY s_ack_pre;
          s_ack_2dly    <= #UDLY s_ack_dly;
       end

   assign S_ACK_O = s_ack_dly & !s_ack_2dly;
   assign S_DAT_O  = (dw00_cs & !S_WE_I & S_STB_I)                     ? read_00_data :
                     (dw04_cs & !S_WE_I & S_STB_I)                     ? read_04_data :
                     (dw08_cs & !S_WE_I & S_STB_I & WRITEABLE_PERIOD)  ? read_08_data :
                     (dw0c_cs & !S_WE_I & S_STB_I & READABLE_SNAPSHOT) ? read_0c_data :
                                                                         32'h0;
   assign S_INT_O  = reg_to;

  generate
  if (WATCHDOG == 1)
   always @(posedge CLK_I or posedge RST_I) begin
     if(RST_I)
       RSTREQ_O      <= #UDLY 1'b0;
     else if(!(|internal_counter) && !RSTREQ_O && ((START_STOP_CONTROL == 0) || reg_run))
       RSTREQ_O      <= #UDLY 1'b1;
     else
       RSTREQ_O      <= #UDLY 1'b0;
	 end
  endgenerate


  generate
  if (TIMEOUT_PULSE == 1)
   //TOPULSE_O
   always @(posedge CLK_I or posedge RST_I)
     if(RST_I)
       TOPULSE_O     <= #UDLY 1'b0;
     else if(!(|internal_counter) && !TOPULSE_O && ((START_STOP_CONTROL == 0) || reg_run))
       TOPULSE_O     <= #UDLY 1'b1;
     else
       TOPULSE_O     <= #UDLY 1'b0;
  endgenerate

endmodule
`endif
