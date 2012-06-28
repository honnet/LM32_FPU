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
// File             : sdr_sig.v
// Title            : SDRAM control signal generation logic 
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

module sdr_sig(
  sys_CLK,
  sys_RESET,
  wb2sdr_q,
  iState,
  cState,
  rd_cmd,
  cross_page,
  sdr_CKE,    // sdr clock enable
  sdr_CSn,    // sdr chip select
  sdr_RASn,   // sdr row address
  sdr_CASn,   // sdr column select
  sdr_WEn,    // sdr write enable
  sdr_BA,     // sdr bank address
  sdr_A       // sdr address
);

`include "sdr_par.v"

`ifdef SDR_DATA_SIZE_32
  parameter LOW_0_CA = 0;
`else
  `ifdef SDR_DATA_SIZE_16
  parameter LOW_0_CA = 1;
  `else
    `ifdef SDR_DATA_SIZE_8
     parameter LOW_0_CA = 2;
    `else
     parameter LOW_0_CA = 3;
    `endif
  `endif
`endif

parameter CA_LSB = 2;
parameter CA_MSB = `SDR_COL_WIDTH+CA_LSB-1-LOW_0_CA;
parameter BA_LSB = CA_MSB+1;
parameter BA_MSB = `SDR_BNK_WDTH+BA_LSB-1;
parameter RA_LSB = BA_MSB+1;
parameter RA_MSB = `SDR_ROW_WIDTH+RA_LSB-1;

parameter HIGH_0_PRC = `SDR_ADR_WIDTH-11;
parameter HIGH_0_CA  = 10-`SDR_COL_WIDTH;

`ifdef SDR_DATA_SIZE_32
`define col_addr {{HIGH_0_PRC{1'b0}},1'b1,{HIGH_0_CA{1'b0}},sys_A[CA_MSB:CA_LSB]}
`else
`define col_addr {{HIGH_0_PRC{1'b0}},1'b1,{HIGH_0_CA{1'b0}},sys_A[CA_MSB:CA_LSB],{LOW_0_CA{1'b0}}}
`endif

//---------------------------------------------------------------------
// inputs
//
input                     sys_CLK;
input                     sys_RESET;
input [68:0]              wb2sdr_q;
input [3:0]               iState;
input [3:0]               cState;
input                     rd_cmd;
output                    cross_page;

//---------------------------------------------------------------------
// outputs
//
output                      sdr_CKE;
output                      sdr_CSn;
output                      sdr_RASn;
output                      sdr_CASn;
output                      sdr_WEn;
output [`SDR_BNK_WDTH-1:0]  sdr_BA;
output [`SDR_ADR_WIDTH-1:0] sdr_A;

reg                       sdr_CKE;
reg                       sdr_CSn;
reg                       sdr_RASn;
reg                       sdr_CASn;
reg                       sdr_WEn;
reg [`SDR_BNK_WDTH-1:0]   sdr_BA;
reg [`SDR_ADR_WIDTH-1:0]  sdr_A;

reg  [31:0]      sys_A;
wire [31:0]      next_adr;
reg [`SDR_ADR_WIDTH+`SDR_BNK_WDTH-1:0] row_addr;
wire            cross_page;
reg             cross_page_dly;

//assign sys_A = wb2sdr_q[31:0];
assign #tDLY next_adr = sys_A+4;

always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET) begin
      sys_A <= #tDLY 0;
      row_addr <= #tDLY 0;
      cross_page_dly <= #tDLY 1'b0;
   end else begin
      cross_page_dly <= #tDLY cross_page;
      if (cState == c_ReWait) begin
         sys_A    <= #tDLY wb2sdr_q[31:0];
         row_addr <= #tDLY wb2sdr_q[RA_MSB:BA_LSB];
      end else if ((cState == c_READA && rd_cmd == 1'b1) || cState == c_WRITEA) begin
         sys_A    <= #tDLY sys_A + 4;
         row_addr <= #tDLY next_adr[RA_MSB:BA_LSB];
      end
   end
assign cross_page = (cState == c_READA || cState == c_WRITEA) ? ((next_adr[RA_MSB:BA_LSB] == row_addr) ? 1'b0 : 1'b1) :
                    cState == c_ACTIVE ? 1'b0 : cross_page_dly;

//---------------------------------------------------------------------
// SDR SDRAM Control Singals
//
always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET) begin
    `sdr_COMMAND <= #tDLY INHIBIT;
    sdr_CKE <= #tDLY 0;
    sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
    sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
  end else
    case (iState)
      i_tRP,
      i_tRFC1,
      i_tRFC2,
      i_tMRD,
      i_NOP: begin
               `sdr_COMMAND <= #tDLY NOP;
               sdr_CKE <= #tDLY 1;
               sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
               sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
             end
      i_PRE: begin
               `sdr_COMMAND <= #tDLY PRECHARGE;
               sdr_CKE <= #tDLY 1;
               sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
               sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
             end
      i_AR1,
      i_AR2: begin
               `sdr_COMMAND <= #tDLY AUTO_REFRESH;
               sdr_CKE <= #tDLY 1;
               sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
               sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
             end
      i_MRS: begin
               `sdr_COMMAND <= #tDLY LOAD_MODE_REGISTER;
               sdr_CKE <= #tDLY 1;
               sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b0}};
               sdr_A   <= #tDLY {
                            2'b00,
                            `MR_Write_Burst_Mode,
                            `MR_Operation_Mode,
                            `MR_CAS_Latency,
                            `MR_Burst_Type,
                            `MR_Burst_Length
                          };
             end
      i_ready:
             case (cState)
               c_idle,
               c_tRCD,
               c_tRFC,
               c_cl,
               c_rdata,
               c_wdata:  begin
                           `sdr_COMMAND <= #tDLY NOP;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
                           sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
                         end
               c_ACTIVE: begin
                           `sdr_COMMAND <= #tDLY ACTIVE;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY sys_A[RA_MSB:RA_LSB];//row
                         end
               c_READA:  begin
                           `sdr_COMMAND <= #tDLY rd_cmd ? READ : NOP;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY `col_addr;
                           end
               c_WRITEA: begin
                           `sdr_COMMAND <= #tDLY WRITE;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY sys_A[BA_MSB:BA_LSB];//bank
                           sdr_A   <= #tDLY `col_addr;
                         end
               c_AR:     begin
                           `sdr_COMMAND <= #tDLY AUTO_REFRESH;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
                           sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
                         end
               c_bterm:  begin
                           `sdr_COMMAND <= #tDLY BURST_TERMINATE;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
                           sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
                         end
               default:  begin
                           `sdr_COMMAND <= #tDLY NOP;
                           sdr_CKE <= #tDLY 1;
                           sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
                           sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
                         end
             endcase
      default:
             begin
               `sdr_COMMAND <= #tDLY NOP;
               sdr_CKE <= #tDLY 1;
               sdr_BA  <= #tDLY {`SDR_BNK_WDTH{1'b1}};
               sdr_A   <= #tDLY {`SDR_ADR_WIDTH{1'b1}};
             end
    endcase

endmodule

