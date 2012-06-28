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
// File             : wb_sdr_ctrl.v
// Title            : SDRAM controller's top file
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

module wb_sdr_ctrl(
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
                  //Sdram interface
                  sdr_DQ,        // sdr data
                  sdr_A,         // sdr address
                  sdr_BA,        // sdr bank address
                  sdr_CKE,       // sdr clock enable
                  sdr_CSn,       // sdr chip select
                  sdr_RASn,      // sdr row address
                  sdr_CASn,      // sdr column select
                  sdr_WEn,       // sdr write enable
                  sdr_DQM,       // sdr write data mask
                  sdr_clk,
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


output  [`SDR_ADR_WIDTH-1:0] sdr_A;
output  [`SDR_BNK_WDTH-1:0]  sdr_BA;
output                       sdr_CKE;
output                       sdr_CSn;
output                       sdr_RASn;
output                       sdr_CASn;
output                       sdr_WEn;
output  [`SDR_USER_DM-1:0]   sdr_DQM;
inout   [`SDR_DATA_WIDTH-1:0]sdr_DQ;

output            sdr_clk;
input             RST_I;


wire      [68:0]  wb2sdr_data;
wire              wb2sdr_we;
wire              wb2sdr_re;
wire      [68:0]  wb2sdr_q;
wire              wb2sdr_empty;
wire              wb2sdr_almost_empty;
wire              wb2sdr_full;
wire              wb2sdr_almost_full;

wire      [31:0]  sdr2wb_data;
wire              sdr2wb_we;
wire              sdr2wb_re;
wire      [31:0]  sdr2wb_q;
wire              sdr2wb_empty;
wire              sdr2wb_full;
reg               sys_DLY_100US;
reg   [15:0]      sys_dly_cnt;
wire              read_tmn;
wire              write_done;

assign sdr_clk = CLK_I;

always @(posedge sdr_clk or posedge RST_I)
if(RST_I) begin
   sys_DLY_100US <= 1'b0;
   sys_dly_cnt   <= `T100US; end
else begin
   if (sys_dly_cnt == 10'h0) begin
      sys_DLY_100US <= 1'b1;
      sys_dly_cnt <= sys_dly_cnt; end
   else begin
      sys_DLY_100US <= 1'b0;
      sys_dly_cnt <= sys_dly_cnt - 1;end
end

parameter READ_FIFO_DEPTH = 16;
parameter WRITE_FIFO_DEPTH = 16;
parameter READ_FIFO_ALMOST_FULL = READ_FIFO_DEPTH-NUM_CLK_CL/NUM_CLK_READ;
parameter WRITE_FIFO_ALMOST_EMPTY = 1;

pmi_fifo_dc #(
           69,                    //parameter pmi_data_width_w = 69,
           69,                    //parameter pmi_data_width_r = 69,
           WRITE_FIFO_DEPTH,         //parameter pmi_data_depth_w = 256,
           WRITE_FIFO_DEPTH,         //parameter pmi_data_depth_r = 256,
           WRITE_FIFO_DEPTH,         //parameter pmi_full_flag = 256,
           0,                     //parameter pmi_empty_flag = 0,
           WRITE_FIFO_DEPTH-1,       //parameter pmi_almost_full_flag = 252,
           WRITE_FIFO_ALMOST_EMPTY,  //parameter pmi_almost_empty_flag = 4,
           "noreg",               //parameter pmi_regmode = "noreg",
           "async",               //parameter pmi_resetmode = "async",
           `LATTICE_FAMILY,       //parameter pmi_family = "XP" ,
           "pmi_fifo_dc",         //parameter module_type = "pmi_fifo_dc",
           "LUT"                  //parameter pmi_implementation = "EBR"
           ) fifo_wb2sdr
   (.Data        (wb2sdr_data ),
    .WrClock     (CLK_I       ),
    .RdClock     (sdr_clk     ),
    .WrEn        (wb2sdr_we   ),
    .RdEn        (wb2sdr_re   ),
    .Reset       (RST_I       ),
    .RPReset     (RST_I       ),
    .Q           (wb2sdr_q    ),
    .Empty       (wb2sdr_empty),
    .Full        (wb2sdr_full ),
    .AlmostEmpty (wb2sdr_almost_empty),
    .AlmostFull  (wb2sdr_almost_full));


pmi_fifo_dc #(
           32,                    //parameter pmi_data_width_w = 32,
           32,                    //parameter pmi_data_width_r = 32,
           READ_FIFO_DEPTH,       //parameter pmi_data_depth_w = 256,
           READ_FIFO_DEPTH,       //parameter pmi_data_depth_r = 256,
           READ_FIFO_DEPTH,       //parameter pmi_full_flag = 256,
           0,                     //parameter pmi_empty_flag = 0,
           READ_FIFO_ALMOST_FULL, //parameter pmi_almost_full_flag = 252,
           1,                     //parameter pmi_almost_empty_flag = 4,
           "noreg",               //parameter pmi_regmode = "noreg"
           "async",               //parameter pmi_resetmode = "async",
           `LATTICE_FAMILY,       //parameter pmi_family = "XP" ,
           "pmi_fifo_dc",         //parameter module_type = "pmi_fifo_dc",
           "LUT"                  //parameter pmi_implementation = "EBR"
           ) fifo_sdr2wb
   (.Data        (sdr2wb_data ),
    .WrClock     (sdr_clk     ),
    .RdClock     (CLK_I       ),
    .WrEn        (sdr2wb_we   ),
    .RdEn        (sdr2wb_re   ),
    .Reset       (read_tmn    ),
    .RPReset     (RST_I       ),
    .Q           (sdr2wb_q    ),
    .Empty       (sdr2wb_empty),
    .Full        (sdr2wb_full ),
    .AlmostEmpty (            ),
    .AlmostFull  (sdr2wb_almost_full));


wb_fifo_intf wb_fifo_intf_uut(
    .S_ADR_I     (S_ADR_I     ),
    .S_SEL_I     (S_SEL_I     ),
    .S_DAT_I     (S_DAT_I     ),
    .S_DAT_O     (S_DAT_O     ),
    .S_WE_I      (S_WE_I      ),
    .S_ACK_O     (S_ACK_O     ),
    .S_ERR_O     (S_ERR_O     ),
    .S_RTY_O     (S_RTY_O     ),
    .S_CTI_I     (S_CTI_I     ),
    .S_BTE_I     (S_BTE_I     ),
    .S_LOCK_I    (S_LOCK_I    ),
    .S_CYC_I     (S_CYC_I     ),
    .S_STB_I     (S_STB_I     ),
    .CLK_I       (CLK_I       ),

    .wb2sdr_we   (wb2sdr_we   ),
    .wb2sdr_data (wb2sdr_data ),
    .wb2sdr_almost_full (wb2sdr_almost_full ),
    .wb2sdr_empty(wb2sdr_empty),
    .write_done  (write_done  ),

    .sdr2wb_re   (sdr2wb_re   ),
    .sdr2wb_q    (sdr2wb_q    ),
    .sdr2wb_empty(sdr2wb_empty),

    .RST_I       (RST_I       )
    );

sdr_fifo_intf sdr_fifo_intf_uut(
    .sdr_DQ      (sdr_DQ       ),
    .sdr_A       (sdr_A        ),
    .sdr_BA      (sdr_BA       ),
    .sdr_CKE     (sdr_CKE      ),
    .sdr_CSn     (sdr_CSn      ),
    .sdr_RASn    (sdr_RASn     ),
    .sdr_CASn    (sdr_CASn     ),
    .sdr_WEn     (sdr_WEn      ),
    .sdr_DQM     (sdr_DQM      ),
    .S_STB_I     (S_STB_I      ),
    .read_tmn    (read_tmn     ),
    .write_done  (write_done   ),

    .sdr2wb_we   (sdr2wb_we   ),
    .sdr2wb_data (sdr2wb_data ),
    .sdr2wb_full (sdr2wb_full ),
    .sdr2wb_almost_full(sdr2wb_almost_full),

    .wb2sdr_re   (wb2sdr_re   ),
    .wb2sdr_q    (wb2sdr_q    ),
    .wb2sdr_empty(wb2sdr_empty),
    .wb2sdr_almost_empty(wb2sdr_almost_empty),
    .sys_DLY_100US(sys_DLY_100US),
    .sdr_clk     (sdr_clk     ),
    .RST_I       (RST_I       )
    );



endmodule


