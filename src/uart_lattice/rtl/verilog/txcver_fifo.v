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
// ============================================================================
`ifndef TXFIFO_FILE
`define TXFIFO_FILE
`include "system_conf.v"
`timescale 1ns / 10ps
module txcver_fifo (Data, Clock, WrEn, RdEn, Reset, Q, Empty, Full,
                    AlmostEmpty, AlmostFull);

   input [7:0] Data;
   input Clock;
   input WrEn;
   input RdEn;
   input Reset;
   output [7:0] Q;
   output Empty;
   output Full;
   output AlmostEmpty;
   output AlmostFull; 
   parameter 		    lat_family   = `LATTICE_FAMILY;
   generate
     if (lat_family == "SC" || lat_family == "SCM") begin
          pmi_fifo_dc #(.pmi_data_width_w(8),
		       .pmi_data_width_r(8),
		       .pmi_data_depth_w(16),
		       .pmi_data_depth_r(16),
		       .pmi_full_flag(16),
		       .pmi_empty_flag(0),
		       .pmi_almost_full_flag(8),
		       .pmi_almost_empty_flag(4),
		       .pmi_regmode("noreg"),
		       .pmi_family(`LATTICE_FAMILY),
		       .module_type("pmi_fifo_dc"),
                       .pmi_implementation("LUT"))
	   tx_fifo_inst_dc (
                        .Data(Data),
                        .WrClock(Clock),
			.RdClock(Clock),
			.WrEn	(WrEn),
			.RdEn	(RdEn),
			.Reset	(Reset),
			.RPReset(Reset),
			.Q	(Q),
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
                        .pmi_almost_full_flag(8),
                        .pmi_almost_empty_flag(4),
                        .pmi_regmode("noreg"),
                        .pmi_family(`LATTICE_FAMILY),
                        .module_type("pmi_fifo"),
                        .pmi_implementation("LUT"))
           tx_fifo_inst        
                     (.Data(Data),
                      .Clock(Clock),
                      .WrEn(WrEn),
                      .RdEn(RdEn),
                      .Reset(Reset),
                      .Q(Q),
                      .Empty(Empty),
                      .Full(Full),
                      .AlmostEmpty(AlmostEmpty),
                      .AlmostFull(AlmostFull));
     end  
  endgenerate
endmodule

`endif
