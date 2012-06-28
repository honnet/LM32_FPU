// Squelette du coprocesseur flottant


module float_copro(
        input logic clk,
	input logic copro_valid,
	input logic [10:0] copro_opcode,
	input logic [31:0] copro_op0,
	input logic [31:0] copro_op1,
        output logic copro_complete, 
        output logic[31:0] copro_result) ;


endmodule

