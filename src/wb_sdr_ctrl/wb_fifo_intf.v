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
// ============================================================================/
//                         FILE DETAILS
// Project          : SDRAM Controller
// File             : wb_fifo_intf.v
// Title            : Logic to control the read/wrtie to the interface FIFO 
//                    from Wishbone
// Dependencies     : sdr_par.v
// Version          : 1.1
// Revision         : 1.0: 2006/1/1
//                         Initial Release
//                    7.0SP2, 3.0: 2007/11/5
//                         Add burst read support
//                    3.1: 2008/2/27
//                         Add burst write support
// =============================================================================
`timescale 1ns / 10ps

module wb_fifo_intf(
                  //Wishbone interface
                  S_ADR_I,
                  S_SEL_I,
                  S_DAT_I,
                  S_DAT_O,
                  S_WE_I,
                  S_ACK_O,
                  S_ERR_O,
                  S_RTY_O,
                  S_CTI_I,
                  S_BTE_I,
                  S_LOCK_I,
                  S_CYC_I,
                  S_STB_I,
                  CLK_I,
                  //FIFOs interface at the side of Wishbone side
                  //Wishbone => Sdram FIFO
                  wb2sdr_we,
                  wb2sdr_data,
                  wb2sdr_almost_full,
                  wb2sdr_empty,
                  write_done,
                  //Sdram => Wishbone FIFO
                  sdr2wb_re,
                  sdr2wb_q,
                  sdr2wb_empty,
                  //Global
                  RST_I
                  );
`include "sdr_par.v"


//Wishbone interface
input     [31:0]  S_ADR_I;
input     [31:0]  S_DAT_I;
output    [31:0]  S_DAT_O;
input     [3:0]   S_SEL_I;
input             S_WE_I;
output            S_ACK_O;
output            S_ERR_O;
output            S_RTY_O;
input     [2:0]   S_CTI_I;
input     [1:0]   S_BTE_I;
input             S_LOCK_I;
input             S_CYC_I;
input             S_STB_I;
input             CLK_I;

output            wb2sdr_we;
output    [68:0]  wb2sdr_data;
input             wb2sdr_almost_full;
input             wb2sdr_empty;
input             write_done;

output            sdr2wb_re;
input     [31:0]  sdr2wb_q;
input             sdr2wb_empty;

input             RST_I;

assign    S_ERR_O = 1'b0;
assign    S_RTY_O = 1'b0;


reg               S_ACK_O;
wire      [31:0]  S_DAT_O;


reg       [1:0]   wb_status;
parameter WB_IDLE   = 2'b00;
parameter WB_WRITE  = 2'b01;
parameter WB_WRWAIT = 2'b10;
parameter WB_READ   = 2'b11;


wire              wb2sdr_we;
wire      [68:0]  wb2sdr_data;
wire              sdr2wb_re;
wire              wb_start;


// wb interface operation

assign #tDLY S_DAT_O   = sdr2wb_q;
assign #tDLY sdr2wb_re = ~sdr2wb_empty;

assign #tDLY wb_start  = S_CYC_I && S_STB_I && sdr2wb_empty;
assign #tDLY wb2sdr_we = S_WE_I == 1'b1       ? S_ACK_O  :
                         wb_status == WB_IDLE ? wb_start : 1'b0;
assign #tDLY wb2sdr_data = {S_WE_I,S_SEL_I,S_DAT_I,S_ADR_I};

always @(posedge RST_I or posedge CLK_I)
if(RST_I) begin
   wb_status   <= WB_IDLE;
   S_ACK_O     <= 1'b0;
end else
   case(wb_status)
   WB_IDLE:   if (wb_start) begin
                 S_ACK_O     <= #tDLY S_WE_I ? 1'b1 : 1'b0;
                 wb_status   <= #tDLY S_WE_I ? WB_WRITE : WB_READ;
              end else begin
                 S_ACK_O     <= #tDLY 1'b0;
                 wb_status   <= #tDLY WB_IDLE;
              end
   WB_WRITE:  if (!S_STB_I) begin
                 S_ACK_O    <= #tDLY 1'b0;
                 wb_status  <= #tDLY WB_WRWAIT;
              end else if(!wb2sdr_almost_full) begin
                 S_ACK_O     <= #tDLY 1'b1;
              end else begin
                 S_ACK_O    <= #tDLY 1'b0;
              end
   WB_WRWAIT: if (write_done)
                 wb_status  <= #tDLY WB_IDLE;
   WB_READ:   if (!S_STB_I) begin
                 S_ACK_O    <= #tDLY 1'b0;
                 wb_status  <= #tDLY WB_IDLE;
              end else begin
                 S_ACK_O    <= #tDLY sdr2wb_re;
              end
   default: wb_status <= #tDLY WB_IDLE;
   endcase


endmodule

