import conbus_pack::*;


module wb_conbus_arb (
	input	clk, rst,
	input  [m_number-1:0] req,
	output [gnt_bits-1:0] gnt
);

genvar i;

// Parameters
wire [gnt_bits-1:0] grant [m_number-1:0];
for (i = 0; i < m_number; i = i + 1)
	begin
		assign grant[i] = i;
	end

// Local Registers and Wires
reg [gnt_bits-1:0] state, next_state;

//  Misc Logic
assign gnt = state;

always @(posedge clk or posedge rst)
	if(rst)   state <= grant[0];
	else      state <= next_state;

integer j,k;
always @(state or req)
	begin
		next_state = state;
		for (j = 0; j < m_number; j = j + 1)
		begin
			for (k = 0; k < m_number; k = k + 1)
			begin
				next_state = (state == grant[j]) ?
						( !req[j] ?
							(req[k] ? grant[k] : next_state)
							: next_state )
						: next_state;
			end
		end
	end

endmodule
