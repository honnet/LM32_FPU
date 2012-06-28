import conbus_pack::*;

// module wb_conbus_top (
// 	input	clk, rst,
// 	conbus_interface.master m[m_number-1:0],
// 	conbus_interface.slave  s[s_number-1:0]
// );

module top;
	logic clk = 0;
	logic rst = 0;

	conbus_interface m[m_number-1:0](); // Instantiate the interface
	conbus_interface s[s_number-1:0](); // Instantiate the interface

	wb_conbus_top my_wb_conbus(.clk(clk),.rst(rst),.m(m),.s(s));

	initial
	begin
		clk = 1;
		#1
		clk = 0;
		#1
		clk = 1;
		#1
		clk = 0;
	end
endmodule