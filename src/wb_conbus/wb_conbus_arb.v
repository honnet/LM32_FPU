/////////////////////////////////////////////////////////////////////
////                                                             //// 
////                 General Round Robin Arbiter                 //// 
////                                                             //// 
////                                                             //// 
////  Automatic generated.                                       //// 
////                        COMELEC380                           //// 
////                                                             //// 
////          Kellya CLANZIG and Flavia CORREIA TOVO             //// 
////                                                             //// 
///////////////////////////////////////////////////////////////////// 

`include "wb_conbus_defines.v"

module wb_conbus_arb(clk, rst, req, gnt);

input		clk;
input		rst;
input	[8-1:0]	req;		// Req input
output	[3-1:0]	gnt; 		// Grant output

// Parameters
parameter	[3-1:0]
                grant0 = 3'h0,
                grant1 = 3'h1,
                grant2 = 3'h2,
                grant3 = 3'h3,
                grant4 = 3'h4,
                grant5 = 3'h5,
                grant6 = 3'h6,
                grant7 = 3'h7;

// Local Registers and Wires
reg [3-1:0]	state, next_state;

//  Misc Logic
assign	gnt = state;

always@(posedge clk or posedge rst)
	if(rst)		state <= grant0;
	else		state <= next_state;

// Next State Logic
//   - implements round robin arbitration algorithm
//   - switches grant if current req is dropped or next is asserted
//   - parks at last grant
always@(state or req )
   begin
	next_state = state;	// Default Keep State
	case(state)
	   grant0:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[0] )
		   begin
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
		   end
	   grant1:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[1] )
		   begin
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
		   end
	   grant2:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[2] )
		   begin
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
		   end
	   grant3:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[3] )
		   begin
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
		   end
	   grant4:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[4] )
		   begin
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
		   end
	   grant5:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[5] )
		   begin
			if(req[6])	next_state = grant6;
			else
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
		   end
	   grant6:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[6] )
		   begin
			if(req[7])	next_state = grant7;
			else
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
		   end
	   grant7:
		// if this req is dropped or next is asserted, check for other req's
		if(!req[7] )
		   begin
			if(req[0])	next_state = grant0;
			else
			if(req[1])	next_state = grant1;
			else
			if(req[2])	next_state = grant2;
			else
			if(req[3])	next_state = grant3;
			else
			if(req[4])	next_state = grant4;
			else
			if(req[5])	next_state = grant5;
			else
			if(req[6])	next_state = grant6;
		   end
	endcase
   end

endmodule
