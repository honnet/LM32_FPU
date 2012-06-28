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
// File             : sdr_fifo_intf.v
// Title            : SDRAM interface to the Wishbone bus 
// Dependencies     : sdr_par.v
// Version          : 1.1
// Revision         : 1.0: 2006/1/1
//                         Initial Release
//                    7.0SP2, 3.0: 2007/11/5
//                         Add burst read support
//                    3.1: 2008/2/27
//                         Add burst write support
// =============================================================================

`timescale 1ns / 100ps

`define sdr_COMMAND  {sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn}

module sdr_fifo_intf(
                  //Sdram interface
                  sdr_DQ,        // sdr data
                  sdr_A,         // sdr address
                  sdr_BA,        // sdr bank address
                  sdr_CKE,       // sdr clock enable
                  sdr_CSn,    // sdr chip select
                  sdr_RASn,      // sdr row address
                  sdr_CASn,      // sdr column select
                  sdr_WEn,       // sdr write enable
                  sdr_DQM,       // sdr write data mask
                  S_STB_I,
                  read_tmn,
                  write_done,
                  //FIFOs interface at the side of Sdram side
                  //Wishbone => Sdram FIFO
                  wb2sdr_re,
                  wb2sdr_q,
                  wb2sdr_empty,
                  wb2sdr_almost_empty,
                  //Sdram => Wishbone FIFO
                  sdr2wb_we,
                  sdr2wb_data,
                  sdr2wb_full,
                  sdr2wb_almost_full,
                  //System interface
                  sys_DLY_100US, // sdr power and clock stable for 100 us
                  //Global
                  sdr_clk,
                  RST_I
                  );

`include "sdr_par.v"
//Sdram interface
inout    [`SDR_DATA_WIDTH-1:0]    sdr_DQ;
output   [`SDR_ADR_WIDTH-1:0]     sdr_A;
output   [`SDR_BNK_WDTH-1:0]      sdr_BA;
output            sdr_CKE;

output            sdr_CSn;

output            sdr_RASn;
output            sdr_CASn;
output            sdr_WEn;
output    [`SDR_USER_DM-1:0] sdr_DQM;
input             S_STB_I;
output            read_tmn;
output            write_done;

output            wb2sdr_re;
input     [68:0]  wb2sdr_q;
input             wb2sdr_empty;
input             wb2sdr_almost_empty;

output            sdr2wb_we;
output    [31:0]  sdr2wb_data;
input             sdr2wb_full;
input             sdr2wb_almost_full;

input             sys_DLY_100US;

input             sdr_clk;
input             RST_I;

// intermodule wires

wire [3:0]                 iState;    // INIT_FSM state variables
wire [3:0]                 cState;    // CMD_FSM state variables
wire [3:0]                 clkCNT;
wire  rd_cmd;
wire cross_page;
wire [`SDR_COL_WIDTH+`SDR_BNK_WDTH:0] rd_cmd_cnt;
wire write_done;


sdr_ctrl U1 (
  .sys_CLK(sdr_clk),
  .sys_RESET(RST_I),
  .wb2sdr_re(wb2sdr_re),
  .wb2sdr_q(wb2sdr_q),
  .wb2sdr_empty(wb2sdr_empty),
  .wb2sdr_almost_empty(wb2sdr_almost_empty),
  .sdr2wb_full(sdr2wb_full),
  .sdr2wb_almost_full(sdr2wb_almost_full),
  .sys_DLY_100US(sys_DLY_100US),
  .iState(iState),
  .cState(cState),
  .clkCNT(clkCNT),
  .S_STB_I(S_STB_I),
  .read_tmn(read_tmn),
  .rd_cmd(rd_cmd),
  .rd_cmd_cnt(rd_cmd_cnt),
  .cross_page(cross_page),
  .write_done(write_done)
);

sdr_sig U2 (
  .sys_CLK(sdr_clk),
  .sys_RESET(RST_I),
  .wb2sdr_q(wb2sdr_q),
  .iState(iState),
  .cState(cState),
  .rd_cmd(rd_cmd),
  .cross_page(cross_page),
  .sdr_CKE(sdr_CKE),
  .sdr_CSn(sdr_CSn),
  .sdr_RASn(sdr_RASn),
  .sdr_CASn(sdr_CASn),
  .sdr_WEn(sdr_WEn),
  .sdr_BA(sdr_BA),
  .sdr_A(sdr_A)
);

sdr_data U3 (
  .sys_CLK(sdr_clk),
  .sys_RESET(RST_I),
  .wb2sdr_q(wb2sdr_q),
  .sdr2wb_we(sdr2wb_we),
  .sdr2wb_data(sdr2wb_data),
  .sdr2wb_full(sdr2wb_full),
  .cState(cState),
  .clkCNT(clkCNT),
  .rd_cmd_cnt(rd_cmd_cnt),
  .sdr_DQM(sdr_DQM),
  .sdr_DQ(sdr_DQ)
);


endmodule
