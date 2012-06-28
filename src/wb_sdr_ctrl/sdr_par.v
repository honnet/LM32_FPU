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
// File             : sdr_par.v
// Title            : SDRAM parameter file 
// Dependencies     : None
// Version          : 1.1
// Revision         : 1.0: 2006/1/1
//                         Initial Release
//                    7.0SP2, 3.0: 2007/11/5
//                         Add burst read support
//                    3.1: 2008/2/27
//                         Add burst write support
// =============================================================================


`define LATTICE_FAMILY "ECP"
// User modifiable parameters
/****************************
* Bus width setting
****************************/
`define SDR_ROW_WIDTH 12
`define SDR_COL_WIDTH 8
`define SDR_BNK_WDTH  2
`define SDR_DATA_WIDTH 32
`define SDR_DATA_SIZE_32 TRUE

/****************************
* Mode register setting
****************************/
// SDRAM mode register definition

// Write Burst Mode, 0: Programmed_Length, 1: Single_Access
`define   MR_Write_Burst_Mode   1'b0

// Operation Mode: Standard
`define   MR_Operation_Mode     2'b00

// CAS Latency, 3'b010: Latency_2,  3'b011: Latency_3
`define   MR_CAS_Latency        3'b011

// Burst Type, 1'b0: Sequential, 1'b1: Interleaved: 1'b1
`define   MR_Burst_Type         1'b0

// Burst Length
// 3'b000  burst length=1 for DATA_WIDTH 32
// 3'b001  burst length=2 for DATA_WIDTH 16
// 3'b010  burst length=4 for DATA_WIDTH 8
// 3'b011  burst length=8 for DATA_WIDTH 4
// 3'b111  burst length=full page
`ifdef SDR_DATA_SIZE_32
  `define   MR_Burst_Length       3'b000
`endif
`ifdef SDR_DATA_SIZE_16
  `define   MR_Burst_Length       3'b001
`endif
`ifdef SDR_DATA_SIZE_8
  `define   MR_Burst_Length       3'b010
`endif
`ifdef SDR_DATA_SIZE_4
  `define   MR_Burst_Length       3'b011
`endif
/****************************
* SDRAM AC timing spec
****************************/
//---------------------------------------------------------------------
// Clock count definition for meeting SDRAM AC timing spec
//
`define SDR_TMRD   2
`define SDR_TRP    1
`define SDR_TRFC   5
`define SDR_TRCD   1
`define SDR_TDAL   5
`define SDR_TREFI  9'd390
`define T100US 12'd2500

// end of user modifiable parameters
//----------------------------------------------------------------------------



//----------------------------------------------------------------------------
`define SDR_ADR_WIDTH `SDR_ROW_WIDTH

`ifdef SDR_DATA_SIZE_4
`define SDR_USER_DM 1
`else
`define SDR_USER_DM `SDR_DATA_WIDTH/8
`endif

// tDAL needs to be satisfied before the next sdram ACTIVE command can
// be issued. State c_tDAL of CMD_FSM is created for this purpose.
// However, states c_idle, c_ACTIVE and c_tRCD need to be taken into
// account because ACTIVE command will not be issued until CMD_FSM
// switch from c_ACTIVE to c_tRCD. NUM_CLK_WAIT is the version after
// the adjustment.
parameter NUM_CLK_WAIT = (`SDR_TDAL < 4) ? 0 : `SDR_TDAL - 4;

parameter NUM_CLK_CL      = `MR_CAS_Latency;

`ifdef SDR_DATA_SIZE_32
parameter NUM_CLK_READ    = 1;
parameter NUM_CLK_WRITE   = 1;
`endif

`ifdef SDR_DATA_SIZE_16
parameter NUM_CLK_READ    = 2;
parameter NUM_CLK_WRITE   = 2;
`endif

`ifdef SDR_DATA_SIZE_8
parameter NUM_CLK_READ    = 4;
parameter NUM_CLK_WRITE   = 4;
`endif

`ifdef SDR_DATA_SIZE_4
parameter NUM_CLK_READ    = 8;
parameter NUM_CLK_WRITE   = 8;
`endif

//---------------------------------------------------------------------
// INIT_FSM state variable assignments (gray coded)
//

parameter i_NOP   = 4'b0000;
parameter i_PRE   = 4'b0001;
parameter i_tRP   = 4'b0010;
parameter i_AR1   = 4'b0011;
parameter i_tRFC1 = 4'b0100;
parameter i_AR2   = 4'b0101;
parameter i_tRFC2 = 4'b0110;
parameter i_MRS   = 4'b0111;
parameter i_tMRD  = 4'b1000;
parameter i_ready = 4'b1001;

//---------------------------------------------------------------------
// CMD_FSM state variable assignments (gray coded)
//

parameter c_idle   = 4'b0000;
parameter c_tRCD   = 4'b0001;
parameter c_cl     = 4'b0010;
parameter c_rdata  = 4'b0011;
parameter c_wdata  = 4'b0100;
parameter c_tRFC   = 4'b0101;
parameter c_tDAL   = 4'b0110;
parameter c_ACTIVE = 4'b1000;
parameter c_READA  = 4'b1111;
parameter c_WRITEA = 4'b1110;
parameter c_AR     = 4'b1011;
parameter c_ReWait = 4'b1100;
parameter c_ReWait0 = 4'b1101;
parameter c_bterm  = 4'b1010;
//---------------------------------------------------------------------
// SDRAM commands (sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn)
//

parameter INHIBIT            = 4'b1111;
parameter NOP                = 4'b0111;
parameter ACTIVE             = 4'b0011;
parameter READ               = 4'b0101;
parameter WRITE              = 4'b0100;
parameter BURST_TERMINATE    = 4'b0110;
parameter PRECHARGE          = 4'b0010;
parameter AUTO_REFRESH       = 4'b0001;
parameter LOAD_MODE_REGISTER = 4'b0000;


parameter tDLY = 2; // 2ns delay for simulation purpose
