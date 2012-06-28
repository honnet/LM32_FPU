import conbus_pack::*;


module wb_conbus_top (
	input	clk, rst,
	conbus_interface.master m[m_number-1:0],
	conbus_interface.slave  s[s_number-1:0]
);

 // Local wires
wire   [m_number-1:0]   i_gnt_arb;
wire   [gnt_bits-1:0]   gnt;
reg    [s_number-1:0]   i_ssel_dec;
reg    [mbusw-1:0]      i_bus_m;	// internal share bus, master data and control to slave
wire   [dw-1:0]         i_dat_s;	// internal share bus , slave data to master
wire   [sbusw-1:0]      i_bus_s;
wire   s_ack, s_err, s_rty;

genvar i_m;
genvar i_s;

for(i_m = 0; i_m< m_number; i_m = i_m + 1)
	begin
		assign   m[i_m].dat_o = i_dat_s;
		assign  {m[i_m].ack, m[i_m].err, m[i_m].rty} = i_bus_s & {3{i_gnt_arb[i_m]}};
	end


assign s_ack = s[0].ack;
assign s_err = s[0].err;
assign s_rty = s[0].rty;
for(i_m = 1; i_m< m_number; i_m = i_m + 1)
	begin
		assign   s_ack =  s_ack | s[i_m].ack;
		assign   s_err =  s_err | s[i_m].err;
		assign   s_rty =  s_rty | s[i_m].rty;
	end
assign  i_bus_s = {s_ack, s_err, s_rty};


for(i_s = 0; i_s< s_number; i_s = i_s + 1)
	begin
		assign  {s[i_s].adr, s[i_s].sel, s[i_s].dat_o, s[i_s].we, s[i_s].cab,s[i_s].cyc} = i_bus_m[mbusw -1:1];
		assign   s[i_s].stb = i_bus_m[1] & i_bus_m[0] & i_ssel_dec[i_s];
	end


genvar j;
assign i_bus_m =  72'b0;
for (j = 0; j < m_number; j = j + 1)
	begin
		assign i_bus_m = (gnt == j) ?
				{ m[j].adr, m[j].sel, m[j].dat_i, m[j].we, m[j].cab, m[j].cyc, m[j].stb}
				: i_bus_m;
	end


wire notdefined = 1;
for (i_s = 0; i_s< s_number; i_s = i_s + 1)
	begin
		assign i_dat_s = i_ssel_dec[i_s]? s[i_s].dat_i : i_dat_s;
		assign notdefined = i_ssel_dec[i_s] ? 0 : notdefined;
	end
assign	i_dat_s = notdefined ? {dw{1'b0}} : i_dat_s;


for (i_m = 0; i_m< m_number; i_m = i_m + 1)
	begin
		assign i_gnt_arb[i_m] = (gnt == i_m);
	end


//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//
wb_conbus_arb	wb_conbus_arb(
	.clk(clk_i),
	.rst(rst_i),
	.req({
		m.cyc_i}), // don't work !!!!!
	.gnt(gnt)
);


wire [s_number-1:0] m_ssel_dec [m_number-1:0];


genvar k;
assign i_ssel_dec = 0;
for (k = 0; k < m_number; k = k + 1)
	begin
		assign i_ssel_dec = (gnt == k) ? m_ssel_dec[k] : i_ssel_dec;
	end


for (i_m = 0; i_m< m_number; i_m = i_m + 1)
	begin
		for (i_s = 0; i_s< m_number; i_s = i_s + 1)
			begin
				assign m_ssel_dec[i_m][i_s] = (m[i_m].adr[aw -1 -1 : aw -1 - s[i_s].addr_w ] == s[i_s].addr);
			end
	end

endmodule
