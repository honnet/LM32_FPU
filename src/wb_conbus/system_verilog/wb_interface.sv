import conbus_pack::*;

interface conbus_interface; //Interface definition

	logic unsigned [dw-1:0] dat_i;
	logic unsigned [dw-1:0] dat_o;
	logic unsigned [aw-1:0] adr;
	logic unsigned [sw-1:0] sel;
	logic we;
	logic cyc;
	logic stb;
	logic cab;
	logic ack;
	logic err;
	logic rty;

	logic unsigned [aw_bits-1:0] adr_w;
	logic unsigned [aw-1:0] addr;

	modport master (input  dat_i,
			output dat_o,
			input  adr,
			       sel,
			       we,
			       cyc,
			       stb,
			       cab,
			output ack,
			       err,
			       rty);

	modport slave  (input  dat_i,
			output dat_o,
			       adr,
			       sel,
			output we,
			       cyc,
			       stb,
			       cab,
			input  ack,
			       err,
			       rty);

endinterface: conbus_interface
