interface test_int; //Interface definition

	logic a,b;

	modport master (output a, b);

	modport slave  (input  a, b);

endinterface: test_int

module test_1 (test_int.slave ts[2:0], test_int.master tm ,input bit clk);
	initial
	begin
		tm.b = 0;
		tm.a = 1;
	end

	always @(posedge clk) tm.b <= (ts[0].a | ts[1].a | ts[2].a) & (ts[0].b | ts[1].b | ts[2].b) ;
	always @(posedge clk) tm.a <= ts[2].a;
endmodule

module test_2 (test_int.slave ts, test_int.master tm[2:0], input bit clk);
	always @(posedge clk) tm[0].b <= ts.a & ts.b;
	always @(posedge clk) tm[1].b <= ts.a;
	always @(posedge clk) tm[0].a <= ts.b;
	always @(posedge clk) tm[1].a <= ts.a | ts.b;
endmodule

module top;
	logic clk = 0;

	test_int ts1[2:0](); // Instantiate the interface
	test_int tm1(); // Instantiate the interface

	test_1 my_test_1(ts1,tm1,clk);
	test_2 my_test_2(tm1,ts1,clk);

	initial
	begin
		clk = 1;
		#1
		clk = 0;
		#1
		clk = 1;

		$display("a = ", ts1[0].a, " b = ", ts1[0].b);
		$display("a = ", ts1[1].a, " b = ", ts1[1].b);

		clk = 0;

	end
endmodule