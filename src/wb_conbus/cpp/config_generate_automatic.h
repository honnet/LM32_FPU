//
// config_generate_automatic.h
//
//
// File used to generate automatiquement the bus connection file
//
// This file contains the constants necessaries to make the code clean;
// all that could be need to generate de file must be defined here.
//
// If the structure dont change, it is possible to change the intend of the
// final file without change the .cpp file.
//
// Any needed parameter must be added after manually.
//
//
// Work for COMELEC380 - Kellya CLANZIG and Flavia CORREIA TOVO
// June 2009
//
/////////////////////////////////////////////////////////////////////////////////////////////
//
// DEFINITIONS:
//          All ?? will be filled by the answers of the user to the program questions
//          All XX will be altomatically by the program using the information given by the user
//            it will be repeated N times
//          All ZZ will be filled by the value of the parametre, default or not
//          All KK variate from 0 to the number of slaves
//          HH -> number of gnt bits
//          MODULE_NAME will be changed by the module name
//


#ifndef CONFIG_GENERATE_AUTOMATIC
#define CONFIG_GENERATE_AUTOMATIC

#define INTRODUCTION " ----------------------------------------------------------------------------------- \n"\
		     " ----                                                                           ---- \n"\
		     " ---- Program to automatically generate the file of the WISHBONE Connection Bus ---- \n"\
		     " ----                                                                           ---- \n"\
		     " ----                   Work for COMELEC380 - TELECOM ParisTech                 ---- \n"\
		     " ----                  By Kellya CLANZIG and Flavia CORREIA TOVO                ---- \n"\
		     " ----                                Spring 2009                                ---- \n"\
		     " ----                                                                           ---- \n"\
		     " -----------------------------------------------------------------------------------"

#define INT_FILE_1 "/////////////////////////////////////////////////////////////////////\n"\
		     "////                                                             //// \n"\
		     "////              WISHBONE Connection Bus Top Level              //// \n"\
		     "////                                                             //// \n"\
		     "////                                                             //// \n"\
		     "////  Automatic generated.                                       //// \n"\
		     "////                        COMELEC380                           //// \n"\
		     "////                                                             //// \n"\
		     "////          Kellya CLANZIG and Flavia CORREIA TOVO             //// \n"\
		     "////                                                             //// \n"\
		     "///////////////////////////////////////////////////////////////////// \n"

#define INT_FILE_2 "/////////////////////////////////////////////////////////////////////\n"\
		     "////                                                             //// \n"\
		     "////                 General Round Robin Arbiter                 //// \n"\
		     "////                                                             //// \n"\
		     "////                                                             //// \n"\
		     "////  Automatic generated.                                       //// \n"\
		     "////                        COMELEC380                           //// \n"\
		     "////                                                             //// \n"\
		     "////          Kellya CLANZIG and Flavia CORREIA TOVO             //// \n"\
		     "////                                                             //// \n"\
		     "///////////////////////////////////////////////////////////////////// \n"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                        WISHBONE Connection Bus Top Level                                                        ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////
// MODULE CONSTANTS //
//////////////////////
#define MODULE1 "module MODULE_NAME #(\n"

#define PARAM_S_ADR_W "	parameter		sXX_addr_w = ZZ,"

#define PARAM_S_ADR_W_COMEN "			// slave XX address decode width"

#define PARAM_S_ADR_W_31BIT_N " -- bit 31 is always ignored!\n"
#define PARAM_S_ADR_W_31BIT_Y " -- bit 31 used!\n"

#define PARAM_S_ADR "	parameter		sXX_addr = ZZ'hzz"

#define PARAM_S_ADR_COMEN "		// slave XX address\n"

#define AFTER_PARAM ") ( \n"\
			"  clk_i, rst_i,"

#define BEGIN_IOS " );\n\n"\
		"  input	clk_i, rst_i;"

#define LOCAL_WIRES " // Local wires\n"\
			"wire	[`mselectw -1:0]	i_gnt_arb;\n"\
			"wire	[HH-1:0]			gnt;\n"\
			"reg	[`sselectw -1:0]	i_ssel_dec;\n"\
			"reg	[`mbusw -1:0]		i_bus_m;	// internal share bus, master data and control to slave\n"\
			"wire	[`dw -1:0]		i_dat_s;	// internal share bus , slave data to master\n"\
			"wire	[`sbusw -1:0]		i_bus_s;	// internal share bus , slave control to master\n"

#define END_MODULE1 "endmodule"


//////////////////////
// MASTER CONSTANTS //
//////////////////////
#define MASTER_INTERFACE "  // Master XX Interface \n"\
			"  mXX_dat_i, mXX_dat_o, mXX_adr_i, mXX_sel_i, mXX_we_i, mXX_cyc_i,\n"\
			"  mXX_stb_i, mXX_ack_o, mXX_err_o, mXX_rty_o, mXX_cab_i"

#define MASTER_INT_INOUTS "  // Master XX Interface \n"\
			"  input  [`dw-1:0]	mXX_dat_i; \n"\
			"  output [`dw-1:0]	mXX_dat_o; \n"\
			"  input  [`aw-1:0]	mXX_adr_i; \n"\
			"  input  [`sw-1:0]	mXX_sel_i; \n"\
			"  input			mXX_we_i;  \n"\
			"  input			mXX_cyc_i; \n"\
			"  input			mXX_stb_i; \n"\
			"  input			mXX_cab_i; \n"\
			"  output		mXX_ack_o; \n"\
			"  output		mXX_err_o; \n"\
			"  output		mXX_rty_o;"

#define MASTER_OUT_INT "  // masterXX output interface\n"\
			"  assign	mXX_dat_o = i_dat_s;\n"\
			"  assign  {mXX_ack_o, mXX_err_o, mXX_rty_o} = i_bus_s & {3{i_gnt_arb[XX]}};\n"

#define I_BUS_S_PART1 "  assign  i_bus_s = {sXX_ack_i "
#define I_BUS_S_PART2 "| sXX_ack_i"
#define I_BUS_S_PART3 " ,\n 			sXX_err_i "
#define I_BUS_S_PART4 "| sXX_err_i"
#define I_BUS_S_PART5 " ,\n 			sXX_rty_i "
#define I_BUS_S_PART6 "| sXX_rty_i"
#define I_BUS_S_PART7 " };\n"

#define MASTER_IN_INT "		mXX_adr_i, mXX_sel_i, mXX_dat_i, mXX_we_i, mXX_cab_i, mXX_cyc_i,mXX_stb_i"

#define MASTER_IN_INT2 "			HH'hXX:	i_bus_m = {mXX_adr_i, mXX_sel_i, mXX_dat_i, mXX_we_i,"\
			" mXX_cab_i, mXX_cyc_i,mXX_stb_i};\n"

#define MASTER_IN_INT_DEFAULT " 			default:i_bus_m =  ZZ'b0;//{m0_adr_i, m0_sel_i, "\
			"m0_dat_i, m0_we_i, m0_cab_i, m0_cyc_i,m0_stb_i};\n"\
			"endcase\n"


/////////////////////
// SLAVE CONSTANTS //
/////////////////////
#define SLAVE_INTERFACE "  // Slave XX Interface \n"\
			"  sXX_dat_i, sXX_dat_o, sXX_adr_o, sXX_sel_o, sXX_we_o, sXX_cyc_o, \n"\
			"  sXX_stb_o, sXX_ack_i, sXX_err_i, sXX_rty_i, sXX_cab_o"

#define SLAVE_INT_INOUTS "  // Slave XX Interface \n"\
			"  input  [`dw-1:0]	sXX_dat_i; \n"\
			"  output [`dw-1:0]	sXX_dat_o; \n"\
			"  output [`aw-1:0]	sXX_adr_o; \n"\
			"  output [`sw-1:0]	sXX_sel_o; \n"\
			"  output		sXX_we_o;  \n"\
			"  output		sXX_cyc_o; \n"\
			"  output		sXX_stb_o; \n"\
			"  output		sXX_cab_o; \n"\
			"  input			sXX_ack_i; \n"\
			"  input			sXX_err_i; \n"\
			"  input			sXX_rty_i;"

#define SLAVE_OUT_INT "  // slaveXX output interface\n"\
			"  assign {sXX_adr_o, sXX_sel_o, sXX_dat_o, sXX_we_o, sXX_cab_o,sXX_cyc_o} = i_bus_m[`mbusw -1:1];\n"\
			"  assign sXX_stb_o = i_bus_m[1] & i_bus_m[0] & i_ssel_dec[XX];\n"

#define SLAVE_IN_INT "assign	i_dat_s = "

#define SLAVE_IN_INT_2 "\n				i_ssel_dec[XX] ? sXX_dat_i :"

#define SLAVE_IN_INT_VALUE "{`dw{1'b0}};\n"


///////////////////////
// ARBITOR CONSTANTS //
///////////////////////
#define ARBITOR_M_ASSIGN "assign i_gnt_arb[XX] = (gnt == HH'dXX);\n"

#define ARBITOR_MODULE1 "wb_conbus_arb	wb_conbus_arb(\n"\
			"	.clk(clk_i),\n"\
			"	.rst(rst_i),\n"\
			"	.req({\n"

#define ARBITOR_MODULE1_2 "		mXX_cyc_i"

#define ARBITOR_MODULE1_END "}),\n"\
			"	.gnt(gnt)\n"\
			");\n"


//////////////////////
// DECODE CONSTANTS //
//////////////////////
#define DECODE_WIRE "//  Address decode logic\n"\
			"wire [ZZ:0]	"

#define DECODE_M_SEL "mXX_ssel_dec"

#define DECODE_M_ADR "		HH'hXX: i_ssel_dec = mXX_ssel_dec;\n"

#define DECODE_M_ADR_DEFAULT "		default: i_ssel_dec = ZZ'b0;\n"\
				"endcase\n"

// XX Slaves, xx Masters, ZZ Address, KK -1 ou 0 si bit 31 valid or not
#define DECODE_M_ADR_RUN_FASTER "assign mxx_ssel_dec[XX] = (mxx_adr_i[`aw -1 KK : `aw KK - sZZ_addr_w ] == sXX_addr);\n"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                        General Round Robin Arbiter                                                              ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define MODULE2 "module MODULE_NAME(clk, rst, req, gnt);\n\n"\
		"input		clk;\n"\
		"input		rst;\n"\
		"input	[ZZ-1:0]	req;		// Req input\n"\
		"output	[HH-1:0]	gnt; 		// Grant output\n"

#define PARAMETRES "// Parameters\n"\
		"parameter	[HH-1:0]\n"
#define PARAM_2 "                grantXX = HH'hXX"

#define REGS "// Local Registers and Wires\n"\
		"reg [HH-1:0]	state, next_state;\n"

#define MISC_LOGIC "//  Misc Logic\n"\
		"assign	gnt = state;\n\n"\
		"always@(posedge clk or posedge rst)\n"\
		"	if(rst)		state <= grant0;\n"\
		"	else		state <= next_state;\n"

#define NEXT_ST_LOG "// Next State Logic\n"\
		"//   - implements round robin arbitration algorithm\n"\
		"//   - switches grant if current req is dropped or next is asserted\n"\
		"//   - parks at last grant\n"\
		"always@(state or req )\n"\
		"   begin\n"\
		"	next_state = state;	// Default Keep State\n"\
		"	case(state)\n"

#define NEXT_ST_LOG_2 "	   grantxx:\n"\
		"		// if this req is dropped or next is asserted, check for other req's\n"\
		"		if(!req[xx] )\n"\
		"		   begin\n"

#define NEXT_ST_LOG_3 "			if(req[XX])	next_state = grantXX;\n"

#define END "	endcase\n"\
		"   end\n\n"\
		"endmodule\n"


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                          ERROR CONSTANTS                                                                        ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define ERROR_ZERO "                      It can't be zero! \n"

#define ERROR_OPENING_FILE 32


#endif
