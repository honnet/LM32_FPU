package conbus_pack;

	parameter m_number = 8; //number of masters
	parameter s_number = 8; //number of slaves

	parameter dw = 32;    // Data bus Width
	parameter aw = 32;    // Address bus Width
	parameter sw = 4;     // Number of Select Lines
	parameter mbusw = 72; // address width + byte select width + dat width + cyc + we + stb +cab , input from master interface
	parameter sbusw = 3;  // ack + err + rty, input from slave interface

	parameter gnt_bits = $ceil(m_number**0.5); //gnt number of bits, number of necessary bits to represent all masters

	parameter aw_bits = $ceil(aw**0.5); //gnt number of bits, number of necessary bits to represent all masters

endpackage
