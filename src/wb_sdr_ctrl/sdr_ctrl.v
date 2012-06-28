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
// File             : sdr_ctrl.v
// Title            : SDRAM Control logic 
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

module sdr_ctrl(
  //global
  sys_CLK,
  sys_RESET,
  //fifo interface
  wb2sdr_re,
  wb2sdr_q,
  wb2sdr_empty,
  wb2sdr_almost_empty,
  sdr2wb_full,
  sdr2wb_almost_full,
  //System interface
  sys_DLY_100US,
  iState,
  cState,
  clkCNT,
  S_STB_I,
  read_tmn,
  rd_cmd,
  rd_cmd_cnt,
  cross_page,
  write_done
);
`include "sdr_par.v"
//---------------------------------------------------------------------
// inputs
//
input        sys_CLK;
input        sys_RESET;
input [68:0] wb2sdr_q;
output       wb2sdr_re;
input        wb2sdr_empty;
input        wb2sdr_almost_empty;
input        sdr2wb_full;
input        sdr2wb_almost_full;
input        sys_DLY_100US;
input        S_STB_I;

//---------------------------------------------------------------------
// outputs
//
output [3:0] iState;
output [3:0] cState;
output [3:0] clkCNT;
output       read_tmn;
output       rd_cmd;
output [`SDR_COL_WIDTH+`SDR_BNK_WDTH:0] rd_cmd_cnt;
input       cross_page;
output       write_done;

//---------------------------------------------------------------------
// registers
//
wire         wb2sdr_re;
reg          sys_INIT_DONE;  // indicates sdr initialization is done

reg [3:0]    iState;        // INIT_FSM state variables
reg [3:0]    cState;        // CMD_FSM state variables

reg [3:0]    clkCNT;
reg          syncResetClkCNT; // reset clkCNT to 0
reg          sys_REF_REQ;
reg [11:0]   ar_cnt;
wire         rd_cmd;
reg          read_tmn;
reg [`SDR_COL_WIDTH+`SDR_BNK_WDTH:0] rd_cmd_cnt;
reg          write_done;
reg          wb2sdr_empty_dly;

//---------------------------------------------------------------------
// local definitions
//
`define endOf_tRP          clkCNT == `SDR_TRP-1
`define endOf_tRFC         clkCNT == `SDR_TRFC-1
`define endOf_tMRD         clkCNT == `SDR_TMRD-1
`define endOf_tRCD         clkCNT == `SDR_TRCD-1
`define endOf_Cas_Latency  clkCNT == NUM_CLK_CL-1
`define endOf_Read_Burst   clkCNT == NUM_CLK_READ - 1
`define endOf_Write_Burst  clkCNT == NUM_CLK_WRITE-2
`define endOf_tDAL         clkCNT == NUM_CLK_WAIT

always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET) begin
      write_done <= 1'b0;
      wb2sdr_empty_dly <= 1'b1;
   end else begin
      wb2sdr_empty_dly <= wb2sdr_empty;
      if (wb2sdr_empty & ~wb2sdr_empty_dly)
         write_done <= 1'b1;
      else if (!wb2sdr_empty)
         write_done <= 1'b0;
   end
//---------------------------------------------------------------------
// auto refresh require
//
always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET) begin
      sys_REF_REQ <= 1'b0;
      ar_cnt      <= `SDR_TREFI;
   end else begin
     if(ar_cnt == 12'd0)
        ar_cnt <= `SDR_TREFI;
     else
        ar_cnt <= ar_cnt - 1;

     if (cState == c_AR)
        sys_REF_REQ <= 1'b0;
     else if(ar_cnt == 'b0)
        sys_REF_REQ <= 1'b1;
   end
//---------------------------------------------------------------------
// INIT_FSM state machine
//
always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET) begin
     iState <= #tDLY i_NOP;
  end else
    case (iState)
      i_NOP:   // wait for 100 us delay by checking sys_DLY_100US
               if (sys_DLY_100US) iState <= #tDLY i_PRE;
      i_PRE:   // precharge all
               iState <= #tDLY (`SDR_TRP == 0) ? i_AR1 : i_tRP;
      i_tRP:   // wait until tRP satisfied
               if (`endOf_tRP) iState <= #tDLY i_AR1;
      i_AR1:   // auto referesh
               iState <= #tDLY (`SDR_TRFC == 0) ? i_AR2 : i_tRFC1;
      i_tRFC1: // wait until tRFC satisfied
               if (`endOf_tRFC) iState <= #tDLY i_AR2;
      i_AR2:   // auto referesh
               iState <= #tDLY (`SDR_TRFC == 0) ? i_MRS : i_tRFC2;
      i_tRFC2: // wait until tRFC satisfied
               if (`endOf_tRFC) iState <= #tDLY i_MRS;
      i_MRS:   // load mode register
               iState <= #tDLY (`SDR_TMRD == 0) ? i_ready : i_tMRD;
      i_tMRD:  // wait until tMRD satisfied
               if (`endOf_tMRD) iState <= #tDLY i_ready;
      i_ready: // stay at this state for normal operation
               iState <= #tDLY i_ready;
      default:
               iState <= #tDLY i_NOP;
    endcase

//
// sys_INIT_DONE generation
//
always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET) begin
     sys_INIT_DONE <= #tDLY 0;
  end else
    case (iState)
      i_ready: sys_INIT_DONE <= #tDLY 1;
      default: sys_INIT_DONE <= #tDLY 0;
    endcase

//---------------------------------------------------------------------
// CMD_FSM state machine
//
always @(posedge sys_CLK or posedge sys_RESET)
   if (sys_RESET) begin
      rd_cmd_cnt <= #tDLY 0;
      read_tmn   <= #tDLY 1'b0;
   end else begin
      if ((`endOf_Read_Burst) && (cState == c_rdata))
         rd_cmd_cnt <= #tDLY 0;
      else if (cState == c_READA || cState == c_cl || cState == c_rdata)
         rd_cmd_cnt <= #tDLY rd_cmd_cnt+1;
      else
         rd_cmd_cnt <= #tDLY 0;

      if (cState == c_idle)
         read_tmn <= 1'b0;
      else if (~S_STB_I)
         read_tmn <= 1'b1;
   end


`ifdef SDR_DATA_SIZE_32
assign rd_cmd = 1'b1;
`endif
`ifdef SDR_DATA_SIZE_16
assign rd_cmd = (rd_cmd_cnt[0] == 1'b0) ? 1'b1 : 1'b0;
`endif
`ifdef SDR_DATA_SIZE_8
assign rd_cmd = (rd_cmd_cnt[1:0] == 2'b00) ? 1'b1 : 1'b0;
`endif
`ifdef SDR_DATA_SIZE_4
assign rd_cmd = (rd_cmd_cnt[2:0] == 3'b000) ? 1'b1 : 1'b0;
`endif

always @(posedge sys_CLK or posedge sys_RESET)
  if (sys_RESET) begin
     cState <= #tDLY c_idle;
  end else
    case (cState)
      c_idle:   // wait until refresh request or addr strobe asserted
                if (sys_REF_REQ && sys_INIT_DONE) cState <= #tDLY c_AR;
      //          else if (!wb2sdr_empty && sys_INIT_DONE) cState <= #tDLY c_ReWait0;
                else if (!wb2sdr_empty && sys_INIT_DONE) cState <= #tDLY c_ReWait;
      //c_ReWait0: cState <= c_ReWait;
      c_ReWait: if (!sdr2wb_full) cState <= c_ACTIVE;
      c_ACTIVE: // assert row/bank addr
                if (`SDR_TRCD == 1)
                   cState <= #tDLY (wb2sdr_q[68]) ? c_WRITEA : c_READA;
                else cState <= #tDLY c_tRCD;
      c_tRCD:   // wait until tRCD satisfied
                if (`endOf_tRCD)
                   cState <= #tDLY (wb2sdr_q[68]) ? c_WRITEA : c_READA;
      c_READA:  // assert col/bank addr for read with auto-precharge
                if (read_tmn)
                   cState <= #tDLY c_idle;
                else if (rd_cmd & (sdr2wb_almost_full | cross_page))
                   cState <= #tDLY c_cl;
      c_cl:     // CASn latency
                if (read_tmn)
                   cState <= #tDLY c_idle;
                else if (`endOf_Cas_Latency) cState <= #tDLY c_rdata;
      c_rdata:  // read cycle data phase
                if (read_tmn)
                   cState <= #tDLY c_idle;
                else if (`endOf_Read_Burst) cState <= #tDLY sdr2wb_full ? c_ReWait : c_ACTIVE;
                //if (`endOf_Read_Burst) cState <= #tDLY c_bterm;
      c_bterm:  // burst terminate
                cState <= #tDLY c_idle;
      c_WRITEA: // assert col/bank addr for write with auto-precharge
                if (NUM_CLK_WRITE > 1)
                   cState <= #tDLY c_wdata;
                else if (wb2sdr_almost_empty || cross_page) begin
                   if (`SDR_TDAL < 4)
                      cState <= #tDLY c_idle;
                   else
                      cState <= #tDLY c_tDAL;
                end
      c_wdata:  // write cycle data phase
                if (`endOf_Write_Burst) begin
                   if (wb2sdr_almost_empty | cross_page) begin
                      if (`SDR_TDAL < 4)
                         cState <= #tDLY c_idle;
                      else
                         cState <= #tDLY c_tDAL;
                   end else
                      cState <= #tDLY c_WRITEA;
                end
      c_tDAL:   // wait until (tWR + tRP) satisfied before issuing next
                // SDRAM ACTIVE command
                if (`endOf_tDAL) cState <= #tDLY c_idle;
      c_AR:     // auto-refresh
                cState <= #tDLY (`SDR_TRFC == 1) ? c_idle : c_tRFC;
      c_tRFC:   // wait until tRFC satisfied
                if (`endOf_tRFC) cState <= #tDLY c_idle;
      default:
                cState <= #tDLY c_idle;
    endcase

//wb2sdr_re generation
assign wb2sdr_re = (cState == c_idle) && !sys_REF_REQ && !wb2sdr_empty && sys_INIT_DONE ||
                   (cState == c_WRITEA) && (NUM_CLK_WRITE == 1) && !wb2sdr_almost_empty && !cross_page ||
                   (cState == c_wdata) && (NUM_CLK_WRITE > 1) && `endOf_Write_Burst && !wb2sdr_almost_empty && !cross_page;
//---------------------------------------------------------------------
// Clock Counter
//
always @(posedge sys_CLK)
  if (syncResetClkCNT) clkCNT <= #tDLY 0;
  else clkCNT <= #tDLY clkCNT + 1;

//
// syncResetClkCNT generation
//
always @(iState or cState or clkCNT)
  case (iState)
    i_PRE:
         syncResetClkCNT <= #tDLY (`SDR_TRP == 1) ? 1 : 0;
    i_AR1,
    i_AR2:
         syncResetClkCNT <= #tDLY (`SDR_TRFC == 1) ? 1 : 0;
    i_NOP:
         syncResetClkCNT <= #tDLY 1;
    i_tRP:
         syncResetClkCNT <= #tDLY (`endOf_tRP) ? 1 : 0;
    i_tMRD:
         syncResetClkCNT <= #tDLY (`endOf_tMRD) ? 1 : 0;
    i_tRFC1,
    i_tRFC2:
         syncResetClkCNT <= #tDLY (`endOf_tRFC) ? 1 : 0;
    i_ready:
         case (cState)
           c_ACTIVE:
                syncResetClkCNT <= #tDLY (`SDR_TRCD == 1) ? 1 : 0;
           c_idle:
                syncResetClkCNT <= #tDLY 1;
           c_tRCD:
                syncResetClkCNT <= #tDLY (`endOf_tRCD) ? 1 : 0;
           c_tRFC:
                syncResetClkCNT <= #tDLY (`endOf_tRFC) ? 1 : 0;
           c_cl:
                syncResetClkCNT <= #tDLY (`endOf_Cas_Latency) ? 1 : 0;
           c_rdata:
                syncResetClkCNT <= #tDLY (clkCNT == NUM_CLK_READ-1) ? 1 : 0;
           c_wdata:
                syncResetClkCNT <= #tDLY (`endOf_Write_Burst) ? 1 : 0;
           c_tDAL:
                syncResetClkCNT <= #tDLY (`endOf_tDAL) ? 1 : 0; 
           default:
                syncResetClkCNT <= #tDLY 1;
         endcase
    default:
         syncResetClkCNT <= #tDLY 0;
  endcase

endmodule






