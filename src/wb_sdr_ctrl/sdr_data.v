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
// File             : sdr_data.v
// Title            : SDRAM data logic 
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

/*
This is the data module for a synchronous DRAM controller.
*/

module sdr_data(
  sys_CLK,
  sys_RESET,
  wb2sdr_q,    // data bus
  sdr2wb_we,
  sdr2wb_data,
  sdr2wb_full,
  cState,
  clkCNT,
  rd_cmd_cnt,
  sdr_DQM,
  sdr_DQ       // sdr data
);

`include "sdr_par.v"

//---------------------------------------------------------------------
// inputs
//
input         sys_CLK;
input         sys_RESET;
input  [68:0] wb2sdr_q;
output        sdr2wb_we;
output [31:0] sdr2wb_data;
input         sdr2wb_full;
input  [3:0]  cState;
input  [3:0]  clkCNT;
input [`SDR_COL_WIDTH+`SDR_BNK_WDTH:0] rd_cmd_cnt;

output [`SDR_USER_DM-1:0] sdr_DQM;
inout  [`SDR_DATA_WIDTH-1:0]  sdr_DQ;

//wires & regs
wire         sdr_dat_valid;
wire [`SDR_COL_WIDTH+`SDR_BNK_WDTH:0] rd_dat_cnt;
wire [`SDR_DATA_WIDTH-1:0]  sdr_DQ_in;
reg  [`SDR_USER_DM-1:0] sdr_DQM;
reg [31:0] regSdrDQ;
reg        enableSysD;
wire [31:0] regSysD;
reg [`SDR_DATA_WIDTH-1:0]  regSysDX;
reg        enableSdrDQ;
wire [3:0]  regSEL;

`ifdef SDR_DATA_SIZE_4
wire [3:0]   cnt0_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt1_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt2_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt3_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt4_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt5_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt6_sdrdq /* synthesys syn_keep=1 */;
wire [3:0]   cnt7_sdrdq /* synthesys syn_keep=1 */;
`else
  `ifdef SDR_DATA_SIZE_8
wire [7:0]   cnt0_sdrdq /* synthesys syn_keep=1 */;
wire [7:0]   cnt1_sdrdq /* synthesys syn_keep=1 */;
wire [7:0]   cnt2_sdrdq /* synthesys syn_keep=1 */;
wire [7:0]   cnt3_sdrdq /* synthesys syn_keep=1 */;
  `else
    `ifdef SDR_DATA_SIZE_16
wire [15:0]  cnt0_sdrdq /* synthesys syn_keep=1 */;
wire [15:0]  cnt1_sdrdq /* synthesys syn_keep=1 */;
    `else
wire [31:0]  cnt0_sdrdq /* synthesys syn_keep=1 */;
    `endif
  `endif
`endif


assign rd_dat_cnt = rd_cmd_cnt - NUM_CLK_CL-1;

`ifdef SDR_DATA_SIZE_4
assign cnt0_sdrdq = (rd_dat_cnt[2:0] == 0) ? sdr_DQ_in : regSdrDQ[3:0];
assign cnt1_sdrdq = (rd_dat_cnt[2:0] == 1) ? sdr_DQ_in : regSdrDQ[7:4];
assign cnt2_sdrdq = (rd_dat_cnt[2:0] == 2) ? sdr_DQ_in : regSdrDQ[11:8];
assign cnt3_sdrdq = (rd_dat_cnt[2:0] == 3) ? sdr_DQ_in : regSdrDQ[15:12];
assign cnt4_sdrdq = (rd_dat_cnt[2:0] == 4) ? sdr_DQ_in : regSdrDQ[19:16];
assign cnt5_sdrdq = (rd_dat_cnt[2:0] == 5) ? sdr_DQ_in : regSdrDQ[23:20];
assign cnt6_sdrdq = (rd_dat_cnt[2:0] == 6) ? sdr_DQ_in : regSdrDQ[27:24];
assign cnt7_sdrdq = (rd_dat_cnt[2:0] == 7) ? sdr_DQ_in : regSdrDQ[31:28];
assign sdr_dat_valid = (rd_dat_cnt[2:0] == 7) ? 1'b1 : 1'b0;
`else
  `ifdef SDR_DATA_SIZE_8
assign cnt0_sdrdq = (rd_dat_cnt[1:0] == 0) ? sdr_DQ_in : regSdrDQ[7:0];
assign cnt1_sdrdq = (rd_dat_cnt[1:0] == 1) ? sdr_DQ_in : regSdrDQ[15:8];
assign cnt2_sdrdq = (rd_dat_cnt[1:0] == 2) ? sdr_DQ_in : regSdrDQ[23:16];
assign cnt3_sdrdq = (rd_dat_cnt[1:0] == 3) ? sdr_DQ_in : regSdrDQ[31:24];
assign sdr_dat_valid = (rd_dat_cnt[1:0] == 3) ? 1'b1 : 1'b0;
  `else
    `ifdef SDR_DATA_SIZE_16
assign cnt0_sdrdq = (rd_dat_cnt[0] == 0) ? sdr_DQ_in : regSdrDQ[15:0];
assign cnt1_sdrdq = (rd_dat_cnt[0] == 1) ? sdr_DQ_in : regSdrDQ[31:16];
assign sdr_dat_valid = (rd_dat_cnt[0] == 1) ? 1'b1 : 1'b0;
    `else
assign cnt0_sdrdq = sdr_DQ_in;
assign sdr_dat_valid = 1'b1;
    `endif
  `endif
`endif

//---------------------------------------------------------------------
//  Read Cycle Data Path
assign #tDLY sdr2wb_we = enableSysD;
assign #tDLY sdr2wb_data = regSdrDQ;

always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET)
      regSdrDQ <= #tDLY 0;
   else
     `ifdef SDR_DATA_SIZE_4
       regSdrDQ <= #tDLY {cnt7_sdrdq,cnt6_sdrdq,cnt5_sdrdq,cnt4_sdrdq,cnt3_sdrdq,cnt2_sdrdq,cnt1_sdrdq,cnt0_sdrdq};
     `else
       `ifdef SDR_DATA_SIZE_8
         regSdrDQ <= #tDLY {cnt3_sdrdq,cnt2_sdrdq,cnt1_sdrdq,cnt0_sdrdq};
       `else
         `ifdef SDR_DATA_SIZE_16
           regSdrDQ <= #tDLY {cnt1_sdrdq,cnt0_sdrdq};
         `else
           regSdrDQ <= #tDLY cnt0_sdrdq;
         `endif
       `endif
     `endif

always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET)
          enableSysD <= #tDLY 0;
  else if ((rd_cmd_cnt > NUM_CLK_CL) && sdr_dat_valid && (cState == c_READA || cState == c_cl || cState == c_rdata))
          enableSysD <= #tDLY 1;
  else    enableSysD <= #tDLY 0;

//---------------------------------------------------------------------
//  Write Cycle Data Path
//
//assign #tDLY sdr_DQ = (enableSdrDQ) ? regSysDX : {`SDR_DATA_WIDTH{1'bz}};
   generate
   genvar  i;
     for (i = 0 ; i < `SDR_DATA_WIDTH; i = i + 1 ) 
     begin : u 
        BB sdram_data_inst(.I(regSysDX[i]), .T(~enableSdrDQ), .O(sdr_DQ_in[i]), .B(sdr_DQ[i]));
     end // block: u 
   endgenerate

`ifdef SDR_DATA_SIZE_4
  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            sdr_DQM <= #tDLY 0;
    else if (cState == c_WRITEA)
            sdr_DQM <= #tDLY regSEL[0];
    else if ((cState == c_wdata) && (clkCNT == 1))
            sdr_DQM <= #tDLY regSEL[1];
    else if ((cState == c_wdata) && (clkCNT == 3))
            sdr_DQM <= #tDLY regSEL[2];
    else if ((cState == c_wdata) && (clkCNT == 5))
            sdr_DQM <= #tDLY regSEL[3];
    else
            sdr_DQM <= #tDLY 0;

  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            regSysDX <= #tDLY 0;
    else if (cState == c_WRITEA)
            regSysDX <= #tDLY regSysD[3:0];
    else if ((cState == c_wdata) && (clkCNT == 0))
            regSysDX <= #tDLY regSysD[7:4];
    else if ((cState == c_wdata) && (clkCNT == 1))
            regSysDX <= #tDLY regSysD[11:8];
    else if ((cState == c_wdata) && (clkCNT == 2))
            regSysDX <= #tDLY regSysD[15:12];
    else if ((cState == c_wdata) && (clkCNT == 3))
            regSysDX <= #tDLY regSysD[19:16];
    else if ((cState == c_wdata) && (clkCNT == 4))
            regSysDX <= #tDLY regSysD[23:20];
    else if ((cState == c_wdata) && (clkCNT == 5))
            regSysDX <= #tDLY regSysD[27:24];
    else if ((cState == c_wdata) && (clkCNT == 6))
            regSysDX <= #tDLY regSysD[31:28];
    else
            regSysDX <= #tDLY 0;
`else
  `ifdef SDR_DATA_SIZE_8
  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            sdr_DQM <= #tDLY 0;
    else if (cState == c_WRITEA)
            sdr_DQM <= #tDLY regSEL[0];
    else if ((cState == c_wdata) && (clkCNT == 0))
            sdr_DQM <= #tDLY regSEL[1];
    else if ((cState == c_wdata) && (clkCNT == 1))
            sdr_DQM <= #tDLY regSEL[2];
    else if ((cState == c_wdata) && (clkCNT == 2))
            sdr_DQM <= #tDLY regSEL[3];
    else
            sdr_DQM <= #tDLY 0;

  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            regSysDX <= #tDLY 0;
    else if (cState == c_WRITEA)
            regSysDX <= #tDLY regSysD[7:0];
    else if ((cState == c_wdata) && (clkCNT == 0))
            regSysDX <= #tDLY regSysD[15:8];
    else if ((cState == c_wdata) && (clkCNT == 1))
            regSysDX <= #tDLY regSysD[23:16];
    else if ((cState == c_wdata) && (clkCNT == 2))
            regSysDX <= #tDLY regSysD[31:24];
    else
            regSysDX <= #tDLY 0;
  `else
    `ifdef SDR_DATA_SIZE_16
  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            sdr_DQM <= #tDLY 0;
    else if (cState == c_WRITEA)
            sdr_DQM <= #tDLY regSEL[1:0];
    else if ((cState == c_wdata) && (clkCNT == 0))
            sdr_DQM <= #tDLY regSEL[3:2];
    else
            sdr_DQM <= #tDLY 0;

  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            regSysDX <= #tDLY 0;
    else if (cState == c_WRITEA)
            regSysDX <= #tDLY regSysD[15:0];
    else if ((cState == c_wdata) && (clkCNT == 0))
            regSysDX <= #tDLY regSysD[31:16];
    else
            regSysDX <= #tDLY 0;

    `else
  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            sdr_DQM <= #tDLY 0;
    else if (cState == c_WRITEA)
            sdr_DQM <= #tDLY regSEL;
    else
            sdr_DQM <= #tDLY 0;

  always @(posedge sys_CLK or posedge sys_RESET)
    if (sys_RESET)
            regSysDX <= #tDLY 0;
    else if (cState == c_WRITEA)
            regSysDX <= #tDLY regSysD;
    else
            regSysDX <= #tDLY 0;
    `endif
  `endif
 `endif


always @(posedge sys_CLK or posedge sys_RESET)
  if(sys_RESET)
    enableSdrDQ <= #tDLY 0;
  else if (cState == c_WRITEA)
    enableSdrDQ <= #tDLY 1;
  else if ((cState != c_wdata) && (cState != c_WRITEA))
    enableSdrDQ <= #tDLY 0;

assign #tDLY regSysD = wb2sdr_q[63:32];
assign #tDLY regSEL = ~wb2sdr_q[67:64];

endmodule

