// --------------------------------------------------------------------
// Copyright (c) 2005 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2 TOP LEVEL
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Chen       :| 05/08/19  :|      Initial Revision
//   V1.1 :| Johnny Chen       :| 05/11/16  :|      Added FLASH Address FL_ADDR[21:20]
//   V1.2 :| Johnny Chen       :| 05/11/16  :|		Fixed ISP1362 INT/DREQ Pin Direction.   
//   V1.3 :| Johnny Chen       :| 05/11/16  :|		Added the Dedicated TV Decoder Line-Locked-Clock Input
//													for DE2 v2.X PCB.
// --------------------------------------------------------------------

/*
Instancie la PLL pour avoir l'horloge adaptee a notre systeme et le systeme en lui meme. Ce module permet de garder le systeme completement independant du materiel.
*/

module DE2_TOP
	(
		////////////////////////	Clock Input	 	////////////////////////
input			CLOCK_27,				//	27 MHz
input			CLOCK_50,				//	50 MHz
input			EXT_CLOCK,				//	External Clock
////////////////////////	Push Button		////////////////////////
input	[3:0]	KEY,					//	Pushbutton[3:0]
////////////////////////	DPDT Switch		////////////////////////
input	[17:0]	SW,						//	Toggle Switch[17:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0,					//	Seven Segment Digit 0
output	[6:0]	HEX1,					//	Seven Segment Digit 1
output	[6:0]	HEX2,					//	Seven Segment Digit 2
output	[6:0]	HEX3,					//	Seven Segment Digit 3
output	[6:0]	HEX4,					//	Seven Segment Digit 4
output	[6:0]	HEX5,					//	Seven Segment Digit 5
output	[6:0]	HEX6,					//	Seven Segment Digit 6
output	[6:0]	HEX7,					//	Seven Segment Digit 7
////////////////////////////	LED		////////////////////////////
output	[8:0]	LEDG,					//	LED Green[8:0]
output	[17:0]	LEDR,					//	LED Red[17:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD,				//	UART Transmitter
input			UART_RXD,				//	UART Receiver
////////////////////////////	IRDA	////////////////////////////
output			IRDA_TXD,				//	IRDA Transmitter
input			IRDA_RXD,				//	IRDA Receiver
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ,				//	SDRAM Data bus 16 Bits
output	[11:0]	DRAM_ADDR,				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM,				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM,				//	SDRAM High-byte Data Mask
output			DRAM_WE_N,				//	SDRAM Write Enable
output			DRAM_CAS_N,				//	SDRAM Column Address Strobe
output			DRAM_RAS_N,				//	SDRAM Row Address Strobe
output			DRAM_CS_N,				//	SDRAM Chip Select
output			DRAM_BA_0,				//	SDRAM Bank Address 0
output			DRAM_BA_1,				//	SDRAM Bank Address 0
output			DRAM_CLK,				//	SDRAM Clock
output			DRAM_CKE,				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout	[7:0]	FL_DQ,					//	FLASH Data bus 8 Bits
output	[21:0]	FL_ADDR,				//	FLASH Address bus 22 Bits
output			FL_WE_N,				//	FLASH Write Enable
output			FL_RST_N,				//	FLASH Reset
output			FL_OE_N,				//	FLASH Output Enable
output			FL_CE_N,				//	FLASH Chip Enable
////////////////////////	SRAM Interface	////////////////////////
inout	[15:0]	SRAM_DQ,				//	SRAM Data bus 16 Bits
output	[17:0]	SRAM_ADDR,				//	SRAM Address bus 18 Bits
output			SRAM_UB_N,				//	SRAM High-byte Data Mask 
output			SRAM_LB_N,				//	SRAM Low-byte Data Mask 
output			SRAM_WE_N,				//	SRAM Write Enable
output			SRAM_CE_N,				//	SRAM Chip Enable
output			SRAM_OE_N,				//	SRAM Output Enable
////////////////////	ISP1362 Interface	////////////////////////
inout	[15:0]	OTG_DATA,				//	ISP1362 Data bus 16 Bits
output	[1:0]	OTG_ADDR,				//	ISP1362 Address 2 Bits
output			OTG_CS_N,				//	ISP1362 Chip Select
output			OTG_RD_N,				//	ISP1362 Write
output			OTG_WR_N,				//	ISP1362 Read
output			OTG_RST_N,				//	ISP1362 Reset
output			OTG_FSPEED,				//	USB Full Speed,	0 = Enable, Z = Disable
output			OTG_LSPEED,				//	USB Low Speed, 	0 = Enable, Z = Disable
input			OTG_INT0,				//	ISP1362 Interrupt 0
input			OTG_INT1,				//	ISP1362 Interrupt 1
input			OTG_DREQ0,				//	ISP1362 DMA Request 0
input			OTG_DREQ1,				//	ISP1362 DMA Request 1
output			OTG_DACK0_N,			//	ISP1362 DMA Acknowledge 0
output			OTG_DACK1_N,			//	ISP1362 DMA Acknowledge 1
////////////////////	LCD Module 16X2	////////////////////////////
inout	[7:0]	LCD_DATA,				//	LCD Data bus 8 bits
output			LCD_ON,					//	LCD Power ON/OFF
output			LCD_BLON,				//	LCD Back Light ON/OFF
output			LCD_RW,					//	LCD Read/Write Select, 0 = Write, 1 = Read
output			LCD_EN,					//	LCD Enable
output			LCD_RS,					//	LCD Command/Data Select, 0 = Command, 1 = Data
////////////////////	SD Card Interface	////////////////////////
inout			SD_DAT,					//	SD Card Data
inout			SD_DAT3,				//	SD Card Data 3
inout			SD_CMD,					//	SD Card Command Signal
output			SD_CLK,					//	SD Card Clock
////////////////////////	I2C		////////////////////////////////
inout			I2C_SDAT,				//	I2C Data
output			I2C_SCLK,				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
input		 	PS2_DAT,				//	PS2 Data
input			PS2_CLK,				//	PS2 Clock
////////////////////	USB JTAG link	////////////////////////////
input  			TDI,					// CPLD -> FPGA (data in)
input  			TCK,					// CPLD -> FPGA (clk)
input  			TCS,					// CPLD -> FPGA (CS)
output 			TDO,					// FPGA -> CPLD (data out)
////////////////////////	VGA			////////////////////////////
output			VGA_CLK,   				//	VGA Clock
output			VGA_HS,					//	VGA H_SYNC
output			VGA_VS,					//	VGA V_SYNC
output			VGA_BLANK,				//	VGA BLANK
output			VGA_SYNC,				//	VGA SYNC
output	[9:0]	VGA_R,   				//	VGA Red[9:0]
output	[9:0]	VGA_G,	 				//	VGA Green[9:0]
output	[9:0]	VGA_B,   				//	VGA Blue[9:0]
////////////////	Ethernet Interface	////////////////////////////
inout	[15:0]	ENET_DATA,				//	DM9000A DATA bus 16Bits
output			ENET_CMD,				//	DM9000A Command/Data Select, 0 = Command, 1 = Data
output			ENET_CS_N,				//	DM9000A Chip Select
output			ENET_WR_N,				//	DM9000A Write
output			ENET_RD_N,				//	DM9000A Read
output			ENET_RST_N,				//	DM9000A Reset
input			ENET_INT,				//	DM9000A Interrupt
output			ENET_CLK,				//	DM9000A Clock 25 MHz
////////////////////	Audio CODEC		////////////////////////////
inout			AUD_ADCLRCK,			//	Audio CODEC ADC LR Clock
input			AUD_ADCDAT,				//	Audio CODEC ADC Data
inout			AUD_DACLRCK,			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT,				//	Audio CODEC DAC Data
inout			AUD_BCLK,				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK,				//	Audio CODEC Chip Clock
////////////////////	TV Devoder		////////////////////////////
input	[7:0]	TD_DATA,    			//	TV Decoder Data bus 8 bits
input			TD_HS,					//	TV Decoder H_SYNC
input			TD_VS,					//	TV Decoder V_SYNC
output			TD_RESET,				//	TV Decoder Reset
input			TD_CLK,					//	TV Decoder Clock
////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0,					//	GPIO Connection 0
inout	[35:0]	GPIO_1				//	GPIO Connection 1
);

//  Intern values to link system and pll
wire CLOCK_IN;
wire LOCKED;

//	Turn on all display
assign	HEX0		=	7'hFF;
assign	HEX1		=	7'hFF;
assign	HEX2		=	7'hFF;
assign	HEX3		=	7'hFF;
assign	HEX4		=	7'hFF;
assign	HEX5		=	7'hFF;
assign	HEX6		=	7'hFF;
assign	HEX7		=	7'hFF;
assign	LEDG		=	9'h000;
assign	LEDR		=	18'h00000;
assign	LCD_ON		=	1'b1;
assign	LCD_BLON	=	1'b1;




//	All inout port turn to tri-state
assign	DRAM_DQ		=	16'hzzzz;
assign	FL_DQ		=	8'hzz;
assign	SRAM_DQ		=	16'hzzzz;
assign	OTG_DATA	=	16'hzzzz;
assign	LCD_DATA	=	8'hzz;
assign	SD_DAT		=	1'bz;
assign	I2C_SDAT	=	1'bz;
assign	ENET_DATA	=	16'hzzzz;
assign	AUD_ADCLRCK	=	1'bz;
assign	AUD_DACLRCK	=	1'bz;
assign	AUD_BCLK	=	1'bz;
assign	GPIO_0		=	36'hzzzzzzzzz;
assign	GPIO_1		=	36'hzzzzzzzzz;


//PLL
wire VIDEO_CLK ;
wire LOCKED_65M ;
pll PLL1 (.inclk0(CLOCK_50), 
	.c0(CLOCK_IN), 
	.locked(LOCKED));


//Mise en place du reset pour le systeme prenant en compte locked et KEY[0]
wire reset = (~KEY[0])||(~LOCKED);

// Temporary unused secondary SDRAM port
//wire sdr_rd  ; 
//wire sdr_wr  ;
//wire sdr_earlyOpBegun;
//wire sdr_opBegun ;
//wire sdr_rdPending ;
//wire sdr_done ;
//wire sdr_rdDone ;
//wire [21:0] sdr_hAddr ;
//wire [15:0] sdr_hDIn ;
//wire [15:0] sdr_hDOut ;
//wire [3:0] sdr_status ;


// System
wire[31:0] copro_result  ;
wire copro_complete ;
wire copro_valid;
wire [31:0] copro_op0;
wire [31:0] copro_op1;
wire [10:0] copro_opcode;

system SYSTEM_top (.clk(CLOCK_IN),
                .clk_locked(LOCKED),
		.rst(reset),
		.uart_rxd(UART_RXD),
		.uart_txd(UART_TXD),
                .copro_result(copro_result),
                .copro_complete(copro_complete),
                .copro_valid(copro_valid),
                .copro_op0(copro_op0),
                .copro_op1(copro_op1),
                .copro_opcode(copro_opcode),
		.sram_adr(SRAM_ADDR),
		.sram_dat(SRAM_DQ),
		.sram_be_n({SRAM_UB_N,SRAM_LB_N}),
		.sram_ce_n(SRAM_CE_N),
		.sram_oe_n(SRAM_OE_N),
		.sram_we_n(SRAM_WE_N));

float_copro copro(
                 .clk(CLOCK_IN),
                 .copro_valid(copro_valid),
                 .copro_opcode(copro_opcode),
                 .copro_op0(copro_op0),
                 .copro_op1(copro_op1),
                 .copro_complete(copro_complete),
                 .copro_result(copro_result)) ;

		

endmodule



