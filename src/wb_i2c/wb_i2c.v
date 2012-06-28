module wb_i2c (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,

	inout              trans_comp,
	output             wb_irq
);

wire [7:0]i2c_blc_add_i;
wire [7:0]i2c_blc_data_i;
wire [7:0]i2c_blc_data_o;

wire i2c_blc_scl_oe;
wire i2c_blc_scl_in = 0;
wire i2c_blc_scl_o;
wire i2c_blc_sda_oe;
wire i2c_blc_sda_in = 0;
wire i2c_blc_sda_o;

   block i2c_blc(
			.wb_clk_i  (  clk      ),
			.wb_rst_i  (  reset    ),

			.irq       (   wb_irq       ),
			.wb_add_i  ( i2c_blc_add_i  ),
			.wb_data_i ( i2c_blc_data_i ),
			.wb_data_o ( i2c_blc_data_o ),
			.wb_we_i   (   wb_we_i      ),
			.wb_stb_i  (   wb_stb_i     ),
			.wb_cyc_i  (   wb_cyc_i     ),
			.wb_ack_o  (   wb_ack_o     ),
			.scl_oe    ( i2c_blc_scl_oe ),
			.scl_in    ( i2c_blc_scl_in ),
			.scl_o     ( i2c_blc_scl_o  ),
			.sda_oe    ( i2c_blc_sda_oe ),
			.sda_in    ( i2c_blc_sda_in ),
			.sda_o     ( i2c_blc_sda_o  ),
			.trans_comp(   trans_comp   )
		);

assign i2c_blc_data_i = wb_dat_i[7:0];

assign i2c_blc_add_i = wb_adr_i[7:0];

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:0] <= 32'b0;
	end else begin
		wb_dat_o[31:8] <= 24'b0;

		wb_dat_o[7:0]  <= wb_dat_o;
	end
end

endmodule