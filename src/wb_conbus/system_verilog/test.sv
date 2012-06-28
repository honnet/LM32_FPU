interface test_int; //Interface definition

	logic a,b,c,d;

endinterface: test_int

module test(test_int t ,input bit clk);
	always @(posedge clk) t.a <= t.d & t.c;
	always @(posedge clk) t.b <= t.d | t.c;
endmodule


module top;
	logic clk = 0;

	test_int t(); // Instantiate the interface

	test my_test(.*);

	initial
	begin

		t.c = 0;
		t.d = 0;

		clk = 1;
		#1

		$display("a = ", t.a, " = ", t.c," and ", t.d);
		$display("b = ", t.b, " = ", t.c," or ", t.d);

		clk = 0;
		#1

		t.c = 1;
		t.d = 0;

		clk = 1;
		#1

		$display("a = ", t.a, " = ", t.c," and ", t.d);
		$display("b = ", t.b, " = ", t.c," or ", t.d);

		clk = 0;
		#1

		t.c = 0;
		t.d = 1;

		clk = 1;
		#1

		$display("a = ", t.a, " = ", t.c," and ", t.d);
		$display("b = ", t.b, " = ", t.c," or ", t.d);

		clk = 0;
		#1

		t.c = 1;
		t.d = 1;

		clk = 1;
		#1

		$display("a = ", t.a, " = ", t.c," and ", t.d);
		$display("b = ", t.b, " = ", t.c," or ", t.d);

	end
endmodule
