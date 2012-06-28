// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A.
//
//                     TEL: 1-800-Lattice  (USA and Canada)
//                          1-408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// =============================================================================
//                        REVISION HISTORY
// Version      : 7.2
// Changes Made : Initial Creation
//                Baudrate Generation is modified.
//                RX and TX path of the UART is updated to faster clock
//                16 word deep FIFO is implemented when FIFO option is
//                selected
// =============================================================================

`ifndef RXFIFO_FILE
`define RXFIFO_FILE
`include "system_conf.v"
`timescale 1ns / 10ps
module rxcver_fifo (Data, Clock, WrEn, RdEn, Reset, Q, Q_error, Empty, Full,
                    AlmostEmpty, AlmostFull);

   input [10:0] Data;
   input Clock;
   input WrEn;
   input RdEn;
   input Reset;
   output [7:0] Q;
   output [2:0] Q_error;
   output Empty;
   output Full;
   output AlmostEmpty;
   output AlmostFull;
   wire[7:0] Q_node; 
   parameter 		    lat_family   = `LATTICE_FAMILY;
   generate
     if (lat_family == "SC" || lat_family == "SCM") begin
          pmi_fifo_dc #(.pmi_data_width_w(8),
		       .pmi_data_width_r(8),
		       .pmi_data_depth_w(16),
		       .pmi_data_depth_r(16),
		       .pmi_full_flag(16),
		       .pmi_empty_flag(0),
		       .pmi_almost_full_flag(1),
		       .pmi_almost_empty_flag(0),
		       .pmi_regmode("noreg"),
		       .pmi_family(`LATTICE_FAMILY),
		       .module_type("pmi_fifo_dc"),
                       .pmi_implementation("LUT"))
	   rx_fifo_inst_dc (
                        .Data(Data[10:3]),
                        .WrClock(Clock),
			.RdClock(Clock),
			.WrEn	(WrEn),
			.RdEn	(RdEn),
			.Reset	(Reset),
			.RPReset(Reset),
			.Q	(Q_node),
			.Empty	(Empty),
			.Full	(Full),
			.AlmostEmpty (AlmostEmpty),
			.AlmostFull (AlmostFull));
     end else begin

           pmi_fifo #(
                      .pmi_data_width(8),
                      .pmi_data_depth(16),
                      .pmi_full_flag(16),
                      .pmi_empty_flag(0),
                      .pmi_almost_full_flag(1),
                      .pmi_almost_empty_flag(0),
                      .pmi_regmode("noreg"),
                      .pmi_family(`LATTICE_FAMILY),
                      .module_type("pmi_fifo"),
                      .pmi_implementation("LUT"))
           rx_fifo_inst        
                     (.Data(Data[10:3]),
                      .Clock(Clock),
                      .WrEn(WrEn),
                      .RdEn(RdEn),
                      .Reset(Reset),
                      .Q(Q_node),
                      .Empty(Empty),
                      .Full(Full),
                      .AlmostEmpty(AlmostEmpty),
                      .AlmostFull(AlmostFull));   
     end  
   endgenerate 
   reg [2:0] fifo [15:0];
   

   reg [4:0] wr_pointer1 = 0;
   reg [4:0] rd_pointer1 = 0;
   reg [4:0] rd_pointer_prev = 0;
   reg valid_RdEn;
   

   always @(posedge Clock or posedge Reset)
     begin
        if (Reset)
	   begin
	        wr_pointer1 <=  0;
                rd_pointer1 <=  0; 
                valid_RdEn <=  0;
                rd_pointer_prev <= 0;		
 		fifo[0] <=  0;
		fifo[1] <=  0;
		fifo[2] <=  0;
		fifo[3] <=  0;
		fifo[4] <=  0;
		fifo[5] <=  0;
		fifo[6] <=  0;
		fifo[7] <=  0;
		fifo[8] <=  0;
		fifo[9] <=  0;
		fifo[10] <=  0;
		fifo[11] <=  0;
		fifo[12] <=  0;
		fifo[13] <=  0;
		fifo[14] <=  0;
		fifo[15] <=  0;	
           end	
        else
           begin
	     if (WrEn == 1 && RdEn !=1 && Full !=1) begin
	       fifo[wr_pointer1%16] <=  Data[2:0];
	       wr_pointer1          <=  wr_pointer1 + 1; end

	     else if (WrEn != 1 && RdEn ==1 && Empty !=1) begin
               valid_RdEn          <=  1'b1;
	       rd_pointer_prev     <=  rd_pointer1;
	       rd_pointer1          <=  rd_pointer1 +1; end 

	     else if (WrEn == 1 && RdEn ==1) begin
	       rd_pointer_prev     <=  rd_pointer1;
               valid_RdEn          <=  1'b1;	     
	       fifo[wr_pointer1%16] <=  Data[2:0];
	       rd_pointer1          <=  rd_pointer1 + 1;
	       wr_pointer1          <=  wr_pointer1 + 1; 
              end  
//	     else
//	       valid_RdEn          <= 1'b0;	     

             if (valid_RdEn)  begin   
	       fifo[rd_pointer_prev%16] <= 0;
	       valid_RdEn          <= 1'b0;
	     end    
	   end
     end


  // Data is only valid for single clock cycle after read to the FIFO occurs  
//    assign   Q = {Q_node, fifo[rd_pointer_prev%16]};
   assign Q = Q_node;
   assign Q_error = fifo[rd_pointer_prev%16]; 

endmodule
   
`endif
