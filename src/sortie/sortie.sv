 
//-----------------------------------------------------
// Design Name : sortie 
// File Name   : sortie.v
//-----------------------------------------------------

module sortie #(
	parameter          freq_hz = 50_000_000,
	parameter          baud    = 115200
) (
	input              reset,
	input              clk,
	// UART line
	input              uart_txd
);

parameter divisor = freq_hz/baud/16;

//-----------------------------------------------------------------
// enable16 generator
//-----------------------------------------------------------------
reg [15:0] enable16_counter;

wire    enable16;
assign  enable16 = (enable16_counter == 0);

always @(posedge clk)
begin
	if (reset) begin
		enable16_counter <= divisor-1;
	end else begin
		enable16_counter <= enable16_counter - 1;
		if (enable16_counter == 0) begin
			enable16_counter <= divisor-1;
		end
	end
end

//-----------------------------------------------------------------
// UART TX Logic
//-----------------------------------------------------------------
reg [3:0] tx_bitcount;
reg [3:0] tx_count16;
reg [7:0] txd_reg;

reg read;
reg read_in;
reg res;
reg debut;

initial begin
read = 0;
read_in = 0;
res = 0;
debut = 0;
tx_bitcount = 0;
tx_count16 = 1;
txd_reg = 0;
end

always @(posedge clk)
begin
	if (reset) begin
		if(res==0)begin
			//$display("Reset actif\n");
			res=1;
		end
		read = 0;
		read_in = 0;
	end
 	else begin
		if((~read_in)&&(uart_txd==1)) begin
			if(debut == 0) begin
				//$display("Debut du travail\n");
				debut = 1;
			end
			read = 1;
			res = 0;
		end

		if(read&&(~read_in)&&(uart_txd==0))begin
			read_in = 1;
			//$display("On va remplir le registre\n");
		end
		if(read_in) begin
			if (enable16) begin
				tx_count16  <= tx_count16 + 1;
				if (tx_count16 == 0) begin
					if(tx_bitcount < 9) begin
							txd_reg  <= { 1'b0, txd_reg[7:1] };
							txd_reg[7] <= uart_txd;
							tx_bitcount <= tx_bitcount + 1;
					end
					else begin
					tx_bitcount = 0;
					read = 0;
					read_in = 0;
					res = 0;
					debut = 0;
					$write("%c", txd_reg);
					end
				end
			end
		end
	end
end


endmodule

