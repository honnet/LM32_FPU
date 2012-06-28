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
// File         : modem.v
// Title        : UART Component -- modem
// Code type    : Register Transfer Level
// Dependencies : 
// Description  :
//    <Global reset and clock>
//      reset     : Master reset
//      clk       : Master clock
//
//    <Registers>
//      msr        : Modem Status Register
//      mcr        : Modem Control Register
//
//    <Rising edge of registers read/write strobes>
//      msr_rd     : one CPU clk width pulse indicating MSR read strobe
//
//    <Modem interface>
//      dcd_n        : Data Carrier Detect
//      cts_n        : Clear To Send
//      dsr_n        : Data Set Ready
//      ri_n         : Ring Indicator
//      dtr_n        : Data Terminal Ready
//      rts_n        : Request To Send
//
// =============================================================================
//                        REVISION HISTORY
// Version      : 1.0
// Changes Made : Initial Creation
// Version      : 7.0SP2
// Changes Made : No Change
// Version      : 7.1, 3.0
// Changes Made : Use CPU clock for the MSR update
// Version      : 3.1
// Changes Made : Baudrate Generation is modified.
//                RX and TX path of the UART is updated to faster clock
//                16 word deep FIFO is implemented when FIFO option is
//                selected
// =============================================================================


`ifndef MODEM_FILE
`define MODEM_FILE
`timescale 1ns/10ps
`include "system_conf.v"
module modem #(parameter DATAWIDTH = 8)
            (
             // Global reset and clock
             reset      , // Master reset
             clk        , // System Clock
             // Registers
             msr        , // Modem Status Reg
             mcr        , // Modem Control Reg
             // Rising Edge of msr Read Strobe
             msr_rd     , // pulse indicating rising of MsrRDn_r
             // Modem interface
             dcd_n      , // Data Carrier Detect
             cts_n      , // Clear To Send
             dsr_n      , // Data Set Ready
             ri_n       , // Ring Indicator
             dtr_n      , // Data Terminal Ready
             rts_n        // Request To Send
           );
           
 
  input                  reset   ;
  input                  clk     ;
  input [1:0]            mcr     ;
             
  input                  msr_rd  ;
                         
  input                  dcd_n   ;
  input                  cts_n   ;
  input                  dsr_n   ;
  input                  ri_n    ;     
  output [DATAWIDTH-1:0] msr     ; 
             
  output                 dtr_n   ;
  output                 rts_n   ;

  reg    [DATAWIDTH-1:0] msr_reg ;
  reg                    ctsn_d1 ;
  reg                    dsrn_d1 ;
  reg                    dcdn_d1 ;
  reg                    rin_d1  ;
  
  assign dtr_n = ~mcr[0];
  assign rts_n = ~mcr[1];

////////////////////////////////////////////////////////////////////////////////
//      Modem Status Register Setup
////////////////////////////////////////////////////////////////////////////////

  assign msr = msr_reg;

  always @(posedge clk or posedge reset)  begin
    if (reset) begin
        msr_reg <= 0;
        ctsn_d1 <= 1'b1;
        dsrn_d1 <= 1'b1;
        dcdn_d1 <= 1'b1;
        rin_d1  <= 1'b1;
        end
    else  begin
        ctsn_d1 <= cts_n;
        dsrn_d1 <= dsr_n;
        dcdn_d1 <= dcd_n;
        rin_d1  <= ri_n ;
        if (msr_rd) 
          msr_reg <= 0;
        else begin
          msr_reg[0] <= msr_reg[0] | (ctsn_d1 ^ cts_n); // Indicate CTSn changes
          msr_reg[1] <= msr_reg[1] | (dsrn_d1 ^ dsr_n); // Indicate DSRn changes
          msr_reg[2] <= msr_reg[2] | (~rin_d1 & ri_n ); // Rising edge of RI    
          msr_reg[3] <= msr_reg[3] | (dcdn_d1 ^ dcd_n); // Indicate DCDn changes
          msr_reg[4] <= !cts_n;  // Compliment of CTSn
          msr_reg[5] <= !dsr_n;  // Compliment of DSRn
          msr_reg[6] <= !ri_n ;  // Compliment of RIn 
          msr_reg[7] <= !dcd_n;  // Compliment of DCDn
          end
        end
     end

endmodule
`endif // MODEM_FILE
