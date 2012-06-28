// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2003(c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation    TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                        408-826-6000 (other locations)
// Hillsboro, OR 97124                  web  : http://www.latticesemi.com/
// U.S.A                                email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// File         : rxcver.v
// Title        : UART Component -- rxcver
// Code type    : Register Transfer Level
// Dependencies : 
// Description  : Verilog file for the UART Receiver Module
//    <Global reset and clock>
//      reset      : Master reset
//	clk        : Master clock
//
//    <Register>
//      rbr        : Receiver Buffer Register
//
//    <Rising edge of rbr, lsr read strobes>
//      rbr_rd     : one CPU clk width pulse indicating rising edge of rbr Read
//      lsr_rd     : one CPU clk width pulse indicating rising edge of lsr Read
//
//    <Receiver input>
//      sin         : Receiver serial input
//
//    <Receiver control>
//      databits     : "00"=5-bit, "01"=6-bit, "10"=7-bit, "11"=8-bit
//      parity_en    : '0'=Parity Bit Enable, '1'=Parity Bit Disable
//      parity_even  : '0'=Even Parity Selected, '1'=Odd Parity Selected
//      parity_stick : '0'=Stick Parity Disable, '1'=Stick Parity Enable
//
//    <Receiver/Transmitter status>
//      rx_rdy       : rbr data is ready to be read
//      overrun_err  : Overrun error
//      parity_err   : Parity error
//      frame_err    : Frame error
//      break_int    : BREAK interrupt
//
// =============================================================================
//                        REVISION HISTORY
// Version      : 1.0
// Changes Made : Initial Creation
// Version      : 7.0SP2, 3.0
// Changes Made : Add one more register to sin to avoid meta-stability
// Version      : 3.1
// Changes Made : Baudrate Generation is modified.
//                RX and TX path of the UART is updated to faster clock
//                16 word deep FIFO is implemented when FIFO option is
//                selected
// =============================================================================

`ifndef RXCVER_FILE
`define RXCVER_FILE
`include "system_conf.v"
`include "rxcver_fifo.v"
`timescale 1ns/10ps
module rxcver #(parameter DATAWIDTH=8,
                parameter FIFO=0)
     (
     // Global reset and clock
     reset,
     clk,
     // Register
     rbr,
     rbr_fifo,	     
     // Rising edge of rbr, lsr read strobes
     rbr_rd,
     lsr_rd,
     // Receiver input
     sin,
     // Receiver control
     databits,
     parity_en,
     parity_even,
     parity_stick,
     // Receiver status
     rx_rdy,
     overrun_err,
     parity_err,
     frame_err,
     break_int,
     fifo_empty,
     fifo_almost_full,
     divisor  
     );
   
   input         reset   ;
   input         clk     ;
   input         rbr_rd ;
   input         lsr_rd ;
   input         sin    ;
   input [1:0]   databits ;
   input         parity_en;
   input         parity_even;
   input         parity_stick;

   output [7:0]           rbr_fifo;
   output [DATAWIDTH-1:0]  rbr ;  
   output 		   rx_rdy      ;
   output 		   overrun_err ;
   output 		   parity_err  ;
   output 		   frame_err   ;
   output 		   break_int   ;
   output                  fifo_empty  ;
   output                  fifo_almost_full;
   input[15:0]             divisor;
   
   reg [3:0] 	           databit_recved_num;
   reg [DATAWIDTH-1:0]     rsr;
   reg 			   rx_parity_err  ;
   reg 			   rx_frame_err ;
   reg 			   rx_idle;
   reg 			   rbr_datardy;
   reg [3:0] 	           count;
   reg 			   hunt;
   reg 			   hunt_one;
   reg 			   sin_d0;
   reg 			   sin_d1;
   reg 			   rx_frame_err_d1;
   reg 			   rx_idle_d1;
   reg 			   overrun_err_int;
   reg 			   parity_err_int;
   reg 			   frame_err_int;
   reg 			   break_int_int;
   reg 			   sampled_once;
   reg 			   rxclk_en;    

   wire [7:0]             rbr_fifo;
   wire [2:0]             rbr_fifo_error;

   reg [DATAWIDTH-1:0]     rbr; 

   
   // State Machine Definition
   parameter 	idle   = 3'b000;
   parameter 	shift  = 3'b001;
   parameter 	parity = 3'b010;
   parameter 	stop   = 3'b011;
   parameter    idle1  = 3'b100;
   reg [2:0]    cs_state;

   parameter    lat_family = `LATTICE_FAMILY;
   // FIFO signals for FIFO mode
   wire         fifo_full;
   wire         fifo_empty;
   wire         fifo_almost_full;
   wire         fifo_almost_empty;
   reg[10:0]    fifo_din;
   reg          fifo_wr;
   reg          fifo_wr_q;
   wire         fifo_wr_pulse;

   reg [15:0]   counter;
   wire [15:0]  divisor_2;
   assign divisor_2 = divisor/2;
   reg          sin_d0_delay; 

   
   ////////////////////////////////////////////////////////////////////////////////
   // Generate hunt
   ////////////////////////////////////////////////////////////////////////////////
   
   // hunt : will be TRUE when start bit is found
     always @(posedge clk or posedge reset) begin
     if (reset)
       hunt <= 1'b0;
     else if ((cs_state == idle) && (sin_d0 == 1'b0) && (sin_d1 == 1'b1))
       // Set Hunt when SIN falling edge is found at the idle state
       hunt <= 1'b1;
     else if (sampled_once && ~sin_d0)
        // Start bit is successfully sampled twice after framing error
        // set Hunt_r "true" for resynchronizing of next frame
       hunt <= 1'b1;
     else if (~rx_idle || sin_d0)
       hunt <= 1'b0;
     end
   
   
   // hunt_one :
   //   hunt_one, used for BI flag generation, indicates that there is at
   //   least a '1' in the (data + parity + stop) bits of the frame.
   //   Break Interrupt flag(BI) is set to '1' whenever the received input
   //   is held at the '0' state for all bits in the frame (Start bit +
   //   Data bits + Parity bit + Stop bit).  So, as long as hunt_one is still
   //   low after all bits are received, BI will be set to '1'.
     always @(posedge clk or posedge reset) begin
        if (reset)
          hunt_one <= 1'b0;
        else if (hunt)
          hunt_one <= 1'b0;
        else if ((rx_idle == 1'b0) && (counter == divisor_2) && (sin_d0 == 1'b1))
          hunt_one <= 1'b1;
     end
   
   // rbr_datardy :
   // This will be set to indicate that the data in rbr is ready for read and
   // will be cleared after rbr is read.
   //
   generate 
   begin
      if (FIFO == 1) begin
       always @(posedge clk or posedge reset) begin
        if (reset) 
          rbr_datardy <= 1'b0;
        else begin
	   if (fifo_empty)	   
            // clear RbrDataRDY when RBR is read by CPU in 450 or FIFO is
	    // empty in 550 mode
            rbr_datardy <= 1'b0; 
	   else if (!fifo_empty)	   
            // set RbrDataRDY at RxIdle_r rising edge
            rbr_datardy <= 1'b1;
        end    
       end
      end
      else begin
       always @(posedge clk or posedge reset) begin
        if (reset) 
          rbr_datardy <= 1'b0;
        else begin
           if (rbr_rd)   	   
            // clear RbrDataRDY when RBR is read by CPU in 450 or FIFO is
	    // empty in 550 mode
            rbr_datardy <= 1'b0;
           else if ((rx_idle == 1'b1) && (rx_idle_d1 == 1'b0))	   
            // set RbrDataRDY at RxIdle_r rising edge
            rbr_datardy <= 1'b1;
        end    
       end
      end
   end
endgenerate
   
   // sampled_once :
   //   This will be set for one clk clock after a framing error occurs not
   //   because of BREAK and a low sin signal is sampled by the clk right
   //   after the sample time of the Stop bit which causes the framing error.
   always @ (posedge clk or posedge reset)  begin 
        if (reset)
          sampled_once <= 1'b0;
        else if (rx_frame_err && ~rx_frame_err_d1 && ~sin_d0 && hunt_one)
          // Start bit got sampled once
          sampled_once <= 1'b1;
        else
          sampled_once <= 1'b0;
     end
   
   
   // rx_idle Flag
     always @ (posedge clk or posedge reset)  begin
     if (reset)
          rx_idle <= 1'b1;                               
     else if (cs_state == idle)
          rx_idle <= 1'b1;
     else
          rx_idle <= 1'b0;		
     end
   
    ////////////////////////////////////////////////////////////////////////////////
   // Receiver Finite State Machine
   ////////////////////////////////////////////////////////////////////////////////
   //  rx_parity_err:
   //               rx_parity_err is a dynamic Parity Error indicator which is
   //               initialized to 0 for even parity and 1 for odd parity.
   //               For odd parity, if there are odd number of '1's in the
   //               (data + parity) bits, the XOR will bring rx_parity_err back to 0
   //               which means no parity error, otherwise rx_parity_err will be 1 to
   //               indicate a parity error.
   // parity_stick='1' means Stick Parity is enabled.  In this case,
   //               the accumulated dynamic rx_parity_err result will be ignored.  A new
   //               value will be assigned to rx_parity_err based on the even/odd parity
   //               mode setting and the sin sampled in parity bit.
   //                  parity_even='0'(odd parity):
   //                     sin needs to be '1', otherwise it's a stick parity error.
   //                  parity_even='1'(even parity):
   //                     sin needs to be '0', otherwise it's a stick parity error.
   
   always @ (posedge clk or posedge reset) begin 
        if (reset) begin
           rsr <= 0;
           databit_recved_num <= 4'h0;
           rx_parity_err <= 1'b1;
           rx_frame_err <= 1'b0;
           cs_state <= idle;
	   counter  <= 16'b0000_0000_0000_0000;
           end   
        else case (cs_state)
           idle: begin
		   if ((sin_d0 == 1'b0) && (sin_d0_delay == 1'b1)) begin
		      cs_state <= idle1;
	           end
		  counter <= divisor - 1'b1; 
	         end  
	   idle1: begin
		    if (counter == divisor_2) begin
		      if (sin_d0 == 1'b1)
		        cs_state <= idle;
		      else begin
                        rsr <= 0;
                        databit_recved_num <= 4'h0;
                        rx_parity_err <= ~ parity_even;
                        rx_frame_err <= 1'b0;
		      end
	            end
	           
	           if (counter == 16'b0000_0000_0000_0001) begin
		      cs_state <= shift;
		      counter  <= divisor;
	           end
                   else
	             counter <= counter - 1'b1; 		   
                  end	       
	                		      
           shift: begin
                    if (counter == divisor_2) begin
		      rsr <= {sin_d0, rsr[7:1]};
                      rx_parity_err <= rx_parity_err ^ sin_d0;
                      databit_recved_num <= databit_recved_num + 1; 
                    end

	            if (counter == 16'b0000_0000_0000_0001) begin
		      if ((databits==2'b00 && databit_recved_num == 4'h5) ||
                          (databits==2'b01 && databit_recved_num == 4'h6) ||
                          (databits==2'b10 && databit_recved_num == 4'h7) ||
                          (databits==2'b11 && databit_recved_num == 4'h8))  
                          if (parity_en == 1'b0)
                            cs_state <= stop;
                          else
                            cs_state <= parity;

		      counter  <= divisor;
	            end	
		    else 
                      counter <= counter - 1'b1;		    
                  end 

           parity: begin
                     if (counter == divisor_2) begin
                       if (parity_stick == 1'b0)
                         rx_parity_err <= rx_parity_err ^ sin_d0;
                       else
                         if (parity_even == 1'b0)
                           rx_parity_err <= ~sin_d0;
                         else
                           rx_parity_err <= sin_d0;
		     end

		     if (counter == 16'b0000_0000_0000_0001) begin
		       cs_state <= stop;
	               counter  <= divisor;	       
		     end
                     else 
                      counter <= counter - 1'b1;		     
	           end

           stop: begin  
	           if (counter == divisor_2) begin
		     // The Receiver checks the 1st Stopbit only regardless of the number
                     // of Stop bits selected.
                     // Stop bit needs to be '1', otherwise it's a Framing error
                     rx_frame_err <= ~sin_d0;
		     cs_state     <= idle;
	           end
                   counter <= counter - 1'b1;
	         end
          default: 
                cs_state <= idle;
          endcase
     end
   
      
   ////////////////////////////////////////////////////////////////////////////////
			// Receiver Buffer Register
   ////////////////////////////////////////////////////////////////////////////////
 generate
   if (FIFO == 1) begin
   always @(posedge clk or posedge reset) begin 
	if (reset) begin
          fifo_din <= 0;
	  fifo_wr  <= 0; end
	else if ((rx_idle == 1'b1) && (rx_idle_d1 == 1'b0)) begin
         if (break_int_int)
         begin 
           fifo_din <= {8'b0, 3'b100};
           fifo_wr  <= 1'b1;
        end
         else begin  
           case (databits)
             2'b00: fifo_din <= { 3'b000, rsr[7:3], 1'b0, parity_err_int, frame_err_int};
             2'b01: fifo_din <= { 2'b00 , rsr[7:2], 1'b0, parity_err_int, frame_err_int};
             2'b10: fifo_din <= { 1'b0  , rsr[7:1], 1'b0, parity_err_int, frame_err_int};
             default: fifo_din <= {rsr, 1'b0, parity_err_int, frame_err_int};
           endcase
	  fifo_wr   <= 1'b1; end
        end 
        else
	 fifo_wr    <= 1'b0;	
     end
   always @(posedge clk or posedge reset)
        if (reset)
          fifo_wr_q <= 0;
        else
	  fifo_wr_q <= fifo_wr;
   assign fifo_wr_pulse = fifo_wr & ~fifo_wr_q;  
   rxcver_fifo RX_FIFO(
	              .Data        (fifo_din),
		      .Clock       (clk),
		      .WrEn        (fifo_wr_pulse),
		      .RdEn        (rbr_rd),
		      .Reset       (reset),
		      .Q           (rbr_fifo),
		      .Q_error     (rbr_fifo_error),
		      .Empty       (fifo_empty),
		      .Full        (fifo_full),
		      .AlmostEmpty (fifo_almost_empty),
		      .AlmostFull  (fifo_almost_full));   
   end
   else begin
   always @(posedge clk or posedge reset) begin 
        if (reset)
          rbr <= 0;
        else if ((rx_idle == 1'b1) && (rx_idle_d1 == 1'b0))
          case (databits)
            2'b00: rbr <= { 3'b000, rsr[7:3]};
            2'b01: rbr <= { 2'b00 , rsr[7:2]};
            2'b10: rbr <= { 1'b0  , rsr[7:1]};
            default: rbr <= rsr;
          endcase
     end
   end     	
 endgenerate  
   ////////////////////////////////////////////////////////////////////////////////
   // Delayed Signals for edge detections
   ////////////////////////////////////////////////////////////////////////////////
   always @(posedge clk or posedge reset) begin 
        if (reset) begin
          sin_d0 <= 1'b0;
          sin_d0_delay <= 1'b0;
          end
        else begin
          // sin_d0 : Signal for rising edge detection of signal sin
          // must be registered before using with sin_d1, 
          // since sin is ASYNCHRONOUS!!! to the system clock
          sin_d0 <= sin;
          sin_d0_delay <= sin_d0;
          end
     end 

     always @(posedge clk or posedge reset) begin 
        if (reset) begin
          sin_d1 <= 1'b0;
          rx_frame_err_d1 <= 1'b1;
          end
        else begin
          //sin_d1 : Signal for falling edge detection of signal SIN
          sin_d1 <= sin_d0;
          // rx_frame_err_d1 :
          // a delayed version of rx_frame_err for detacting the rising edge
          // used to resynchronize the next frame after framing error
          rx_frame_err_d1 <= rx_frame_err;
        end
     end 
   
   always @(posedge clk or posedge reset) begin 
        if (reset) begin
          rx_idle_d1 <= 1'b1;
          end
        else begin
          // rx_idle_d1 : Signal for rising edge detection of signal rx_idle
          rx_idle_d1 <= rx_idle;
          end
     end 
        
   ////////////////////////////////////////////////////////////////////////////////
   // Generate Error Flags
   ////////////////////////////////////////////////////////////////////////////////
   
   // Receiver Error Flags in lsr
   //   overrun_err(OE), parity_err(PE), frame_err(FE), break_int(BI)
   //   will be set to reflect the sin line status only after the whole frame
   //   (Start bit + Data bits + Parity bit + Stop bit) is received.  A rising
   //   edge of rx_idle indicates the whole frame is received.
generate 
  if (FIFO == 1) begin
   always @(posedge clk or posedge reset) begin 
        if (reset) begin
          parity_err_int  <= 1'b0;
          frame_err_int   <= 1'b0;
          break_int_int   <= 1'b0;
          end               
         else begin  
          // Set parity_err flag if rx_parity_err is 1 when Parity enable
           parity_err_int  <= (rx_parity_err) & parity_en;
          // Set frame_err flag if rx_frame_err is 1(Stop bit is sampled low)
          frame_err_int   <= rx_frame_err;    
          // Set break_int flag if hunt_one is still low
              break_int_int   <= (~ hunt_one);
          end
     end
   always @(posedge clk or posedge reset) 
        if (reset) 
          overrun_err_int <= 1'b0;
        else if (fifo_full && fifo_wr)
          overrun_err_int <= 1'b1;
        else if (lsr_rd)
	  overrun_err_int <= 1'b0;

       assign   overrun_err = overrun_err_int;
       assign   parity_err  = rbr_fifo_error[1];
       assign   frame_err   = rbr_fifo_error[0];
       assign   break_int   = rbr_fifo_error[2];
   // Receiver ready for read when data is available in rbr
   assign  rx_rdy = rbr_datardy;	
  end
  else begin
   always @(posedge clk or posedge reset) begin 
        if (reset) begin
          overrun_err_int <= 1'b0;
          parity_err_int  <= 1'b0;
          frame_err_int   <= 1'b0;
          break_int_int   <= 1'b0;
          end               
        else if (rx_idle && !rx_idle_d1) begin  // update at rxidle rising
          // Set overrun_err flag if RBR data is still not read by CPU
          overrun_err_int <= rbr_datardy;   
          // Set parity_err flag if rx_parity_err is 1 when Parity enable
          parity_err_int  <= (parity_err_int | rx_parity_err) & parity_en; 
          // Set frame_err flag if rx_frame_err is 1(Stop bit is sampled low)
          frame_err_int   <= frame_err_int | rx_frame_err;    
          // Set break_int flag if hunt_one is still low
          break_int_int   <= break_int_int | (~ hunt_one);  
          end
        else if (lsr_rd) begin  // clear when LSR is read
          parity_err_int  <= 1'b0;
          frame_err_int   <= 1'b0;
          overrun_err_int <= 1'b0;
          break_int_int   <= 1'b0;
          end
     end

     assign     overrun_err = overrun_err_int;
     assign     parity_err  = parity_err_int;
     assign     frame_err   = frame_err_int;
     assign     break_int   = break_int_int;   
   // Receiver ready for read when data is available in rbr
   assign  rx_rdy = rbr_datardy;
  end
//`endif
endgenerate

endmodule
`endif // RXCVER_FILE
