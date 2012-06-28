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
// File         : intface.v
// Title        : UART Component -- intface
// Code type    : Register Transfer Level
// Dependencies : 
// Description  :
//    <Global reset and clock>
//      reset        : Master reset
//      clk          : Master Clock
//
//    <Wishbone interface>
//      adr_i     : Address bus
//      dat_i     : Data bus input
//      dat_o     : Data but output
//      stb_i     : strobe output, used to indicate a valid data transfer cycle
//      cyc_i     : cycle signal, indicate whether a valid bus cycle is in process 
//      we_i      : write enable output, used to indicate whether the current cycle is a READ or Write
//      sel_i     : output array select signal, used to indicate where valid data is expected
//      ack_o     : acknowledge, indicate the nomal termination of a bus cycle
//      intr      : Interrupt
//      cti_i     : cycle type identifier, 
//      bte_i     : burst type extension
//          
//    <Registers>
//      rbr         : Receiver Buffer Register
//      thr         : Transmitter Holding Register
//      msr         : Modem Status Register
//      mcr         : Modem Control Register
//
//    <Rising edge of registers read/write strobes>
//      rbr_rd    : one CPU clk width pulse indicating RBR read strobe
//      thr_wr    : one CPU clk width pulse indicating THR write strobe
//      lsr_rd    : one CPU clk width pulse indicating LSR read strobe
//      msr_rd    : one CPU clk width pulse indicating MSR read strobe
//
//    <Receiver/Transmitter control>
//      databits    : "00"=5-bit, "01"=6-bit, "10"=7-bit, "11"=8-bit
//      stopbits    : "00"=1-bit, "01"=1.5-bit(5-bit data),
//                    "10"=2-bit(6,7,8-bit data)
//      parity_en     : '0'=Parity Bit Enable, '1'=Parity Bit Disable
//      parity_even   : '0'=Even Parity Selected, '1'=Odd Parity Selected
//      parity_stick  : '0'=Stick Parity Disable, '1'=Stick Parity Enable
//      tx_break      : '0'=Disable BREAK assertion, '1'=Assert BREAK
//
//    <Receiver/Transmitter status>
//      rx_rdy       : rbr data is ready to be read
//      overrun_err  : Overrun error
//      parity_err   : Parity error
//      frame_err    : Frame error
//      break_int    : BREAK interrupt
//      thre         : thr is empty
//      temt         : Both thr and TSR are empty
//
// --------------------------------------------------------------------
//
//
//
//----------------------------------------------------------------------------
//   GENERAL REGISTER:                                                      --
//------------------------                                                  --
//   =================================================================      --
//  |  ADDRESS A[2:0]   |            REGISTER             | IMPLEMENT |     --
//   =================================================================      --
//  | $000 (READ)       | RBR (RECEIVER BUFFER REGISTER)  |  Y        |     --
//   -----------------------------------------------------------------      --
//  | $000 (WRITE)      | THR (TRANSMIT HOLD REGISTER)    |  Y        |     --
//   =================================================================      --
//  | $001 (WRITE)      | IER (INTERRUPT ENABLE REGISTER) |  Y        |     --
//   =================================================================      --
//  | $010 (READ)       | IIR (INTERRUPT ID REGISTER)     |  Y        |     --
//   =================================================================      --
//  | $011 (WRITE)      | LCR (LINE CONTROL REGISTER)     |  Y        |     --
//   =================================================================      --
//  | $100 (WRITE)      | MCR (MODEM CONTROL REGISTER)    |  Y        |     --
//   =================================================================      --
//  | $101 (READ)       | LSR (LINE STATUS REGISTER)      |  Y        |     --
//   =================================================================      --
//  | $110 (READ)       | MSR (MODEM STATUS REGISTER)     |  Y        |     --
//   =================================================================      --
//  | $111 (READ/WRITE) | SCR (SCRATCHPAD REGISTER)       |  N        |     --
//   =================================================================      --
//                                                                          --
//  NOTE:  By using Lattice ISP solution, the Baud Rate can be
//         re-configured even when the device is soldered on the board.     --
//         Therefore the Baud Rate register set is omitted.                 --
//                                                                          --
//         Because each Lattice ispLSI device has a embedded UES register,  --
//         the Scratchpad register can be omitted too.                      --
//                                                                          --
//----------------------------------------------------------------------------
//  REGISTER BIT FIELDS:                                                    --
//--------------------------                                                --
//                                                                          --
//    ============================                                          --
//   | LSR (LINE STATUS REGISTER) |                                         --
//    ==============================================================        --
//   |  0    | TEMT | THRE  |  BI   |  FE   |  PE   |  OE   | RxRDY |       --
//    ==============================================================        --
//                                                                          --
//    RxRDY : RECEIVE DATA READY                                            --
//    OE    : OVERRUN ERROR                                                 --
//    PE    : PARITY ERROR                                                  --
//    FE    : FRAMING ERROR                                                 --
//    BI    : BREAK INTERRUPT                                               --
//    THRE  : TRASMITTER HOLDING REGISTER EMPTY                             --
//    TEMT  : TRASMITTER EMPTY                                              --
//                                                                          --
//                                                                          --
//    RxRDY: The data received flag is set to 1 at the successful           --
//           completion of a byte receive cycle.  It is automatically       --
//           cleared to 0 when the Rx Data Register is read.  If a new byte --
//           is received before an Rx Data Register read, the over run flag --
//           will be set to 1. If (SR) status option is set the UART will   --
//           ignore all further incoming bytes until the Rx Data Register   --
//           has been read.                                                 --
//                                                                          --
//    OE:    It indicates that the data in RBR was not read by the CPU      --
//           before the next character arrived, thereby destroying the the  --
//           previous character. The OE indicator is set to 1 upon          --
//           detection of an overrun condition and reset whenever the CPU   --
//           reads the contents of LSR                                      --
//                                                                          --
//    PE:    The parity error flag is set to 1 if an invalid parity bit is  --
//           encountered. It is automatically cleared to 0 when the CPU     --
//           reads the contents of Line Status Register.                    --
//                                                                          --
//    FE:    The framing error flag is set to 1 if an invalid stop bit is   --
//           encountered. It is automatically cleared to 0 when the CPU     --
//           reads the contents of Line Status Register.                    --
//                                                                          --
//    BI:    The start bit error flag is set to 1 if an invalid start bit   --
//           is encountered. It is automatically cleared to 0 when the CPU  --
//           reads the contents of Line Status Register.                    --
//                                                                          --
//    THRE:  The Transmit Holding Register Empty flag indicate that the     --
//           UART is ready to accept a new character for transmission. In   --
//           addition this bit cause the UART issue an interrupt to the CPU --
//           when the THRE interrupt enable is set to high                  --
//                                                                          --
//    TEMT:  The Transmitter Empty indicator is set to '1' whenever         --
//           whenever the Transmitter Holding Register and the Transmitter  --
//           Shifting Register are both empty. It is reset to '0' whenever  --
//           either the Transmitter Holding register or Transmitter Shift   --
//           Register contains a character                                  --
//                                                                          --
//    ================================                                      --
//   | LCR (LINE CONTROL REGISTER)    |                                     --
//    ===============================================================       --
//   |  DLAB |  SB   |  SP   | EPS   |  PEN  |  STB  | WLS1  | WLS0  |      --
//    ===============================================================       --
//                                                                          --
//    WLS1-WLS0:  WORD LENGTH SELECT  00 = 5 DATA BITS                      --
//                                    01 = 6 DATA BITS                      --
//                                    10 = 7 DATA BITS                      --
//                                    11 = 8 DATA BITS                      --
//                                                                          --
//    STB:  NUMBER OF STOP BITS  0 = 1 STOP BIT (DEFAULT)                   --
//                               1 = 1.5 STOP BITS (DATA LENGTH 5 BITS)     --
//                               1 = 2 STOP BITS   (DATA LENGTH 6,7,8 BITS) --
//                                                                          --
//    PEN:  PARITY ENABLE                                                   --
//    EPS:  EVEN PARITY SELECT                                              --
//    SP:   SET PARITY                                                      --
//                                  SP EPS PEN      PARITY SELECTION        --
//                                  X   X   0       NO PARITY               --
//                                  0   0   1       ODD PARITY              --
//                                  0   1   1       EVEN PARITY             --
//                                  1   0   1       FORCE PARITY "1"        --
//                                  1   1   1       FORCE PARITY "0"        --
//                                                                          --
//    SB:   SET BREAK When enable the Break control bit causes a break      --
//          condition to be transmitted (the TX output is forced to a logic --
//          0 state). This condition exits until disabled by resetting this --
//          bit to a logic 0.                                               --
//                                                                          --
//    DLAB: DIVISOR LATCH ACCESS BIT:   0 = Divisor latch disable (default) --
//                                      1 = Divisor latch enabled           --
//          Note: Because we use ISP solution to reconfigure Baud Rate,     --
//                this bit is omitted as well as the Baud Rate Register.    --
//                                                                          --
//    =============================                                         --
//   | IIR (INTERRUPT ID REGISTER) |                                        --
//    ===================================================================   --
//   |   0   |   0   |   0   |   0   | INT 2 | INT 1 | INT 0 | INT STAT  |  --
//    ===================================================================   --
//                                                                          --
//   PRIOTITY LEVEL  BIT-3  BIT-2  BIT-1  BIT-0  SOURCE OF INTERRUPT        --
//   NONE              0      0      0      1    NONE                       --
//   HIGHEST           0      1      1      0    LSR (OE/PE/FE/BI)          --
//   2nd               0      1      0      0    RxRDY (Receiver Data Ready)--
//   3rd               0      0      1      0    THRE (THR Empty)           --
//   4th               0      0      0      0    MSR (Modem Status Register)--
//                                                                          --
//      In the 16450 Mode Bit-3 is 0.                                       --
//                                                                          --
//    =================================                                     --
//   | IER (INTERRUPT ENABLE REGISTER) |                                    --
//    ===============================================================       --
//   |   0   |   0   |   0   |   0   |  MSI  |  RLSI |  THRI | RHRI  |      --
//    ===============================================================       --
//                                                                          --
//   RBRI:    Receiver Buffer Register Interrupt (1 = Enable, 0 = Disble)   --
//   THRI:    Transmitter Hold Register Interrupt (1 = Enalbe, 0 = Disble)  --
//   RLSI:    Receiver Line Status Interrupt (1 = Enalble, 0 = Disble)      --
//   MSI:     Modem Status Interrupt (1 = Enable, 0 = Disble)               --
//                                                                          --
//    =============================                                         --
//   | MSR (MODEM STATUS REGISTER) |                                        --
//    ===============================================================       --
//   |  DCD  |  RI   |  DSR  |  CTS  |  DDCD |  TERI |  DDSR |  DCTS |      --
//    ===============================================================       --
//                                                                          --
//   DCD:       Data Carrier Detect                                         --
//   RI:        Ring Indicator                                              --
//   DSR:       Data Set Ready                                              --
//   CTS:       Clear To Send                                               --
//   DDCD:      Delta Data Carrier Detect                                   --
//   TERI:      Trailing Edge Ring Indicator                                --
//   DDSR:      Delta Data Set Ready                                        --
//   DCTS:      Delta Clear to Send                                         --
//   Bit0-3 are set to '1' whenever a control input from the MODEM changes  --
//   state, and an Modem Stauts. Interrupt is generated. They are reset to  --
//   '0' whenever the CPU reads the Modem Status Register.                  --
//                                                                          --
//    ==============================                                        --
//   | MCR (MODEM CONTROL REGISTER) |                                       --
//    ===============================================================       --
//   |   0   |   0   |   0   | LOOP* | OUT2* | OUT1* |  RTS  |  DTR  |      --
//    ===============================================================       --
//                                                                          --
//   DTR:       Data Terminal Ready                                         --
//   RTS:       Request To Send                                             --
//   OUT1:      Auxiliary User-defined Output 1 (Not Implemented)           --
//   OUT2:      Auxiliary User-defined Output 2 (Not Implemented)           --
//   LOOP:      Local Loopback for diagnostic testing of the UART           --
//              (Not Implemented)                                           --
//                                                                          --
//   Note:      OUT1, OUT2 and LOOP are not implemented                     --
//                                                                          --
// =============================================================================
//                        REVISION HISTORY
// Version      : 1.0
// Changes Made : Initial Creation
// Version      : 7.0SP2
// Changes Made : No Change
// Version      : 7.1, 3.0
// Changes Made : msr_rd changed to be combinatorial logic
//                lsr_rd changed to be combinatorial logic
//                When IER is masked, should diasble the current INT
// Version      : 3.1
// Changes Made : Baudrate Generation is modified.
//                RX and TX path of the UART is updated to faster clock
//                16 word deep FIFO is implemented when FIFO option is
//                selected              
// =============================================================================

`ifndef INTFACE_FILE
`define INTFACE_FILE
`include "system_conf.v"
`include "txcver_fifo.v"
`timescale 1ns/10ps
module intface #(parameter CLK_IN_MHZ = 25,
                 parameter BAUD_RATE = 115200,
                 parameter ADDRWIDTH = 5,
                 parameter DATAWIDTH = 8,
                 parameter FIFO = 0) 
       (
        // Global reset and clock
        reset,
        clk,
        // wishbone interface
        adr_i,
        dat_i,
        dat_o,
        stb_i,
        cyc_i,
        we_i,
        sel_i,
        cti_i,
        bte_i,
        ack_o,
        intr,
        // Registers
        rbr,
        rbr_fifo,		
        thr,
        // Rising edge of registers read/write strobes
        rbr_rd,
        thr_wr,
        lsr_rd,
        `ifdef MODEM
        msr_rd,
        msr,
        mcr,
        `endif
        // Receiver/Transmitter control
        databits,
        stopbits,
        parity_en,
        parity_even,
        parity_stick,
        tx_break,
        // Receiver/Transmitter status
        rx_rdy,
        overrun_err,
        parity_err,
        frame_err,
        break_int,
        thre,
        temt,
	fifo_empty,
	fifo_empty_thr,
	thr_rd,
	fifo_almost_full,
	divisor
       ); 
    
    input   reset ;
    input   clk;   
    output  fifo_empty_thr; 
    input   fifo_empty; 
    input   fifo_almost_full;
    input   thr_rd;
    input [31:0] adr_i;
    input [31:0] dat_i;
    input        we_i ; 
    input        stb_i;
    input        cyc_i;
    input [3:0]  sel_i;
    input [2:0]  cti_i;
    input [1:0]  bte_i;

    input [7:0]          rbr_fifo;
    input [DATAWIDTH-1:0] rbr; 
    input                 rx_rdy      ;
    input                 overrun_err ;
    input                 parity_err  ;
    input                 frame_err   ;
    input                 break_int   ;
    input                 thre        ;
    input                 temt        ;
    
    output                  lsr_rd   ;
    output [31:0] dat_o ;
    output                  intr ;
    output                  ack_o;
    output [DATAWIDTH-1:0]  thr  ;  
    output                  rbr_rd;
    output                  thr_wr;  
    
    output [1:0]            databits;
    output [1:0]            stopbits;
    output                  parity_en   ;
    output                  parity_even ;
    output                  parity_stick;
    output                  tx_break    ;
    `ifdef MODEM
    output                  msr_rd   ;
    input  [DATAWIDTH-1:0]  msr   ;
    output [1:0]            mcr  ;  
    `endif
    output [15:0]           divisor;
    
   reg    ack_o;
    
   reg  [DATAWIDTH-1:0] data_8bit ;
   wire [31:0]    dat_o ;
  
   wire [DATAWIDTH-1:0]    thr_fifo;
   reg [DATAWIDTH-1:0]     thr_nonfifo; 	   

 generate
   if (FIFO == 1)
     assign thr  = thr_fifo;
   else
     assign thr  = thr_nonfifo;
 endgenerate


   reg [6:0] lsr;
   reg  [6:0] lcr;

   wire [3:0] 		    iir     ;
  `ifdef MODEM
   reg  [3:0] 		    ier     ;
   `else 
   reg  [2:0] 		    ier     ;
   `endif 
   
   wire 		    rx_rdy_int   ;
   wire 		    thre_int    ;
   wire 		    dataerr_int ;
   wire 		    data_err     ;
   
   wire thr_wr_strobe;
   wire rbr_rd_strobe;
   wire iir_rd_strobe;
   reg iir_rd_strobe_delay;
   wire lsr_rd_strobe;
   wire div_wr_strobe;
   wire lsr_rd;
   reg lsr2_r, lsr3_r, lsr4_r;

   reg  thr_wr;
   wire rbr_rd_fifo;	   	   
   reg  rbr_rd_nonfifo;

 generate
   if (FIFO == 1)
     assign rbr_rd  = rbr_rd_fifo;
   else
     assign rbr_rd  = rbr_rd_nonfifo;
 endgenerate

   `ifdef MODEM 
   wire  modem_stat   ;
   wire  modem_int   ;
   wire  msr_rd_strobe;
   wire  msr_rd   ; 
   reg  [1:0]  mcr     ;  
   reg         msr_rd_strobe_detect;
   `endif

// FIFO signals for FIFO mode
   wire         fifo_full_thr;
   wire         fifo_empty_thr;
   wire         fifo_almost_full_thr;
   wire         fifo_almost_empty_thr;
   wire [8:0]   fifo_din_thr;
   reg          fifo_wr_thr;
   reg          fifo_wr_q_thr;
   wire         fifo_wr_pulse_thr;

   // UART baud 16x clock generator
   reg [15:0]   divisor;
   always @(posedge clk or posedge reset) begin
      if (reset)
        divisor <= ((CLK_IN_MHZ*1000*1000)/(BAUD_RATE));
      else if (div_wr_strobe)
        divisor <= dat_i[15:0];
   end

   // UART Registers Address Map
   parameter A_RBR = 5'b00000;
   parameter A_THR = 5'b00000;
   parameter A_IER = 5'b00100;
   parameter A_IIR = 5'b01000;
   parameter A_LCR = 5'b01100;
   parameter A_LSR = 5'b10100;
   parameter A_DIV = 5'b11100;   
`ifdef MODEM
   parameter A_MSR = 5'b11000;
   parameter A_MCR = 5'b10000;
`endif

  always @(posedge clk or posedge reset)  begin 
    if (reset)
      thr_wr <= 1'b0;
    else 
      thr_wr <= thr_wr_strobe;
   end 

  assign lsr_rd = lsr_rd_strobe;

  assign rbr_rd_fifo = rbr_rd_strobe;

  always @(posedge clk or posedge reset)  begin 
   if (reset)
     rbr_rd_nonfifo <= 1'b0;
    else 
     rbr_rd_nonfifo <= rbr_rd_strobe;
   end 

   `ifdef MODEM

   assign  msr_rd = msr_rd_strobe;

   `endif
  
   ////////////////////////////////////////////////////////////////////////////////
   // Registers Read/Write Control Signals
   ////////////////////////////////////////////////////////////////////////////////
 generate
   if (FIFO == 1)
     assign thr_wr_strobe = (adr_i[ADDRWIDTH-1:0] == A_THR) &&  cyc_i && stb_i &&  we_i && ~fifo_full_thr && ~ack_o;
   else
     assign thr_wr_strobe = (adr_i[ADDRWIDTH-1:0] == A_THR) &&  cyc_i && stb_i &&  we_i;
 endgenerate

 generate
   if (FIFO == 1)
     assign rbr_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_RBR) &&  cyc_i && stb_i && ~we_i && ~fifo_empty && ~ack_o;
   else
     assign rbr_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_RBR) &&  cyc_i && stb_i && ~we_i;
 endgenerate

 generate
   if (FIFO == 1)
     assign iir_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_IIR) &&  cyc_i && stb_i && ~we_i && ~ack_o;  
   else 	   
     assign iir_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_IIR) &&  cyc_i && stb_i && ~we_i;
 endgenerate 

 generate
   if (FIFO == 1)
     assign lsr_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_LSR) &&  cyc_i && stb_i && ~we_i && ~ack_o; 
   else    	
     assign lsr_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_LSR) &&  cyc_i && stb_i && ~we_i;  
 endgenerate 
 
 `ifdef MODEM 
   assign msr_rd_strobe = (adr_i[ADDRWIDTH-1:0] == A_MSR) &&  cyc_i && stb_i && ~we_i;
 `endif
 
   assign div_wr_strobe = (adr_i[ADDRWIDTH-1:0] == A_DIV) &&  cyc_i && stb_i &&  we_i;  
   
  ////////////////////////////////////////////////////////////////////////////////
  // Registers Read/Write Operation
  ////////////////////////////////////////////////////////////////////////////////
 generate
  if (FIFO == 1) begin
   always @(cyc_i or stb_i or we_i or adr_i or rbr_fifo or iir 
	   `ifdef MODEM
           or msr
	   `endif 
	   or lsr)
   begin
     case (adr_i[ADDRWIDTH-1:0])
       A_RBR: data_8bit <= rbr_fifo;
       A_IIR: data_8bit <= {4'b0000, iir};
       A_LSR: data_8bit <= {1'b0,lsr};
       `ifdef MODEM
       A_MSR: data_8bit <= msr;
       `endif
       default: data_8bit <= 8'b11111111;
   endcase	   
   end
  end
  else begin	  
  // Register Read
 always @(posedge clk or posedge reset)  begin 
   if (reset)
     data_8bit <= 8'b11111111;
    else if (cyc_i && stb_i && ~we_i)
     case (adr_i[ADDRWIDTH-1:0])
       A_RBR: data_8bit <= rbr;
       A_IIR: data_8bit <= {4'b0000, iir};
       A_LSR: data_8bit <= {1'b0,lsr};
       `ifdef MODEM
       A_MSR: data_8bit <= msr;
       `endif
       default: data_8bit <= 8'b11111111;
   endcase
 end
 end
 endgenerate 
  assign dat_o = {24'h000000,data_8bit};   


generate
if (FIFO == 0)
begin
    always @(posedge clk or posedge reset)  begin
        if (reset) begin
            thr_nonfifo <= 0;
             `ifdef MODEM
           ier <= 4'b0000;
           mcr <= 2'b00;
            `else
           ier <= 3'b000;
            `endif
            lcr <= 7'h00; end 
       else if (cyc_i && stb_i && we_i)
          case (adr_i[ADDRWIDTH-1:0])  
             	A_THR: thr_nonfifo <= dat_i[7:0];
                `ifdef MODEM
               A_IER: ier <= dat_i[3:0];
               A_MCR: mcr <= dat_i[1:0];
                `else 
               A_IER: ier <= dat_i[2:0];
                `endif
               A_LCR: lcr <= dat_i[6:0];
           default: ;
          endcase
      end
end
else 
begin
    always @(posedge clk or posedge reset)  begin
        if (reset) begin
             `ifdef MODEM
           ier <= 4'b0000;
           mcr <= 2'b00;
            `else
           ier <= 3'b000;
            `endif
            lcr <= 7'h00; end 
       else if (cyc_i && stb_i && we_i)
          case (adr_i[ADDRWIDTH-1:0])  
                `ifdef MODEM
               A_IER: ier <= dat_i[3:0];
               A_MCR: mcr <= dat_i[1:0];
                `else 
               A_IER: ier <= dat_i[2:0];
                `endif
               A_LCR: lcr <= dat_i[6:0];
           default: ;
          endcase
end

end

endgenerate

 generate
 if (FIFO == 1) begin
   assign fifo_wr_pulse_thr = thr_wr_strobe;
   assign fifo_din_thr      = dat_i[7:0];
   txcver_fifo TX_FIFO(
	              .Data        (fifo_din_thr),
		      .Clock       (clk),
		      .WrEn        (fifo_wr_pulse_thr),
		      .RdEn        (thr_rd),
		      .Reset       (reset),
		      .Q           (thr_fifo),
		      .Empty       (fifo_empty_thr),
		      .Full        (fifo_full_thr),
		      .AlmostEmpty (fifo_almost_empty_thr),
		      .AlmostFull  (fifo_almost_full_thr)   
	              );
 end
endgenerate

   ////////////////////////////////////////////////////////////////////////////////
   //  Line Control Register
   ////////////////////////////////////////////////////////////////////////////////
   
   // databits : "00"=5-bit, "01"=6-bit, "10"=7-bit, "11"=8-bit
   assign databits = lcr[1:0];
   
   // stopbits : "00"=1-bit, "01"=1.5-bit(5-bit data), "10"=2-bit(6,7,8-bit data)
   assign stopbits = (lcr[2] == 1'b0) ? 2'b00 : (lcr[2:0] == 3'b100) ? 2'b01 : 2'b10;
   
   // parity_en : '0'=Parity Bit Enable, '1'=Parity Bit Disable
   assign parity_en = lcr[3];
   
   // parity_even : '0'=Even Parity Selected, '1'=Odd Parity Selected
   assign parity_even = lcr[4];
   
   // parity_stick : '0'=Stick Parity Disable, '1'=Stick Parity Enable
   assign parity_stick = lcr[5];
   
   // tx_break : '0'=Disable BREAK assertion, '1'=Assert BREAK
   assign tx_break = lcr[6];
   
   ////////////////////////////////////////////////////////////////////////////////
   //  Line Status Register
   ////////////////////////////////////////////////////////////////////////////////
 generate
 if (FIFO == 1) begin
  
   always @(posedge clk or posedge reset)
     if (reset)
       lsr2_r <= 1'b0;
     else if (parity_err)
       lsr2_r  <= 1'b1;
     else if (lsr_rd_strobe)
       lsr2_r  <= 1'b0;

   always @(posedge clk or posedge reset)
     if (reset)
       lsr3_r <= 1'b0;
     else if (frame_err)
       lsr3_r  <= 1'b1;
     else if (lsr_rd_strobe)
       lsr3_r  <= 1'b0;

   always @(posedge clk or posedge reset)
     if (reset)
       lsr4_r <= 1'b0;
     else if (break_int)
       lsr4_r  <= 1'b1;
     else if (lsr_rd_strobe)
       lsr4_r  <= 1'b0;

   always @(posedge clk)
      lsr <= {temt , thre , lsr4_r , lsr3_r , lsr2_r , overrun_err , rx_rdy};
 end
 
 else
 
   always @(temt or thre or break_int or frame_err or parity_err or overrun_err or rx_rdy)
      lsr =  {temt , thre , break_int , frame_err , parity_err , overrun_err , rx_rdy};
       
endgenerate

   ////////////////////////////////////////////////////////////////////////////////
   // Interrupt Arbitrator
   ////////////////////////////////////////////////////////////////////////////////
   
   // Int is the common interrupt line for all internal UART events
`ifdef MODEM
   assign intr = rx_rdy_int | thre_int | dataerr_int | modem_int;
`else
   assign intr = rx_rdy_int | thre_int | dataerr_int;
`endif
   
   // Receiving Data Error Flags including Overrun, Parity, Framing and Break
 generate
   if (FIFO == 1)
     assign data_err = overrun_err | lsr2_r | lsr3_r | lsr4_r;
   else	   
     assign data_err = overrun_err | parity_err | frame_err | break_int;
 endgenerate

   // Whenever bit0, 1, 2,or 3 is set to '1', A_WB Modem Status Interrupt is generated
`ifdef MODEM
   assign modem_stat = msr[0] | msr[1] | msr[2] | msr[3];
`endif

generate
 if (FIFO == 1)
  always @(posedge clk or posedge reset)
     if (reset)
       iir_rd_strobe_delay <= 1'b0;
     else
       iir_rd_strobe_delay <= iir_rd_strobe;
endgenerate

   // State Machine Definition
   parameter  idle = 3'b000;
   parameter  int0 = 3'b001;
   parameter  int1 = 3'b010;
   parameter  int2 = 3'b011;
   parameter  int3 = 3'b100;
   reg [2:0]  cs_state;


generate 
if (FIFO == 1) begin
   always @(posedge clk or posedge reset) begin
        if (reset)
          cs_state <= idle;
        else
          case (cs_state)
            idle: begin
               if (ier[2] == 1'b1 && data_err == 1'b1 )
                 cs_state <= int0;
               else if (ier[0] == 1'b1 && (fifo_almost_full || !fifo_empty) )	       
                 cs_state <= int1;
               else if (ier[1] == 1'b1 && thre == 1'b1)
                 cs_state <= int2;
            `ifdef MODEM
               else if (ier[3] == 1'b1 && modem_stat == 1'b1)
                 cs_state <= int3;
            `endif
            end
            int0: begin
	       if ((lsr_rd_strobe == 1'b1) || (ier[2] == 1'b0)) begin    
		 if (ier[0] == 1'b1 && fifo_almost_full) 
		   cs_state <= int1;
                else	      
	           cs_state <= idle; end
            end
            int1: begin
               if (data_err == 1'b1 && ier[2] == 1'b1)
		  cs_state <= int0;     
	       else if (!fifo_almost_full || (ier[0] == 1'b0))	     	       
	          cs_state <= idle;
            end
            int2: begin
               if (iir_rd_strobe_delay || (thre == 1'b0) || (ier[1] == 1'b0))  	       
                 cs_state <= idle;
            end
           `ifdef MODEM
            int3: begin
               if ((msr_rd_strobe)|| (ier[3] == 1'b0))
                 cs_state <= idle;
            end
           `endif
            default: cs_state <= idle;
          endcase
       end end
       
else  begin
   
   always @(posedge clk or posedge reset) begin
        if (reset)
          cs_state <= idle;
        else
          case (cs_state)
            idle: begin
               if (ier[2] == 1'b1 && data_err == 1'b1)
                 cs_state <= int0;
               else if (ier[0] == 1'b1 && rx_rdy == 1'b1)       	       
                 cs_state <= int1;
               else if (ier[1] == 1'b1 && thre == 1'b1)
                 cs_state <= int2;
            `ifdef MODEM
               else if (ier[3] == 1'b1 && modem_stat == 1'b1)
                 cs_state <= int3;
            `endif
            end
            int0: begin
	       if ((lsr_rd_strobe == 1'b1) || (ier[2] == 1'b0)) begin	      
		 if (ier[0] == 1'b1 && rx_rdy) 
		   cs_state <= int1;
                else	      
	           cs_state <= idle; end
            end
            int1: begin
               if (data_err == 1'b1 && ier[2] == 1'b1)
		  cs_state <= int0;     
	       else if ((rx_rdy == 1'b0) || (ier[0] == 1'b0)) 	       
	           cs_state <= idle;
            end
            int2: begin 	       
	       if (iir_rd_strobe || (thre == 1'b0) || (ier[1] == 1'b0))	       
                 cs_state <= idle;
            end
           `ifdef MODEM
            int3: begin
               if ((msr_rd_strobe)|| (ier[3] == 1'b0))
                 cs_state <= idle;
            end
           `endif
            default: cs_state <= idle;
          endcase
     end
end
endgenerate

 // ACK signal generate
  always @(posedge clk or posedge reset) begin
    if (reset)
      ack_o <= 1'b0;
    else if (ack_o)
      ack_o <= 1'b0;
    else if (cyc_i & stb_i) 
      ack_o <= 1'b1;
 end
   
   // Set Receiver Line Status Interrupt
   assign dataerr_int = (cs_state == int0) ? 1'b1 : 1'b0;
   
   // Set Received Data Available Interrupt
   assign rx_rdy_int  = (cs_state == int1) ? 1'b1 : 1'b0;
   
   // Set thr Empty Interrupt
   assign thre_int    = (cs_state == int2) ? 1'b1 : 1'b0;
   
   // Set MODEM Status Interrupt
   `ifdef MODEM
   assign modem_int   = (cs_state == int3) ? 1'b1 : 1'b0;
   `endif
   
   // Update IIR
   assign iir = (cs_state == int0) ? 4'b0110 :
                (cs_state == int1) ? 4'b0100 :
                (cs_state == int2) ? 4'b0010 :
                 `ifdef MODEM
                (cs_state == int3) ? 4'b0000 :
                 `endif
                4'b0001 ;  // No Interrupt Pending

endmodule
`endif // INTFACE_FILE
