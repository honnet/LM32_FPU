/*Projet COMELEC Clanzig Kellya et TOVO Flavia

Module de simulation du système. Donne l'horloge et le reset puis laisse évoluer le système pendant un certain temps. Il instancie de plus le module sortie qui permet d'écrire dans la console les informations provenant de la sortie uart_txd.

*/


`timescale 1us / 100ns

module test_bench_DE2(); 

reg clock_50;
reg reset;
reg zero = 0;


//UART
reg uart_rxd;
wire uart_txd;


//SRAM
wire [15:0] sram_dq;
wire [17:0] sram_addr;
wire sram_ub_n;
wire sram_lb_n;
wire sram_we_n;
wire sram_oe_n;
wire sram_ce_n;

wire out;
wire [15:0] dram_dq; //      Sdram Data bus 16 Bits
wire [11:0] dram_addr;   //      Sdram Address bus 12 Bits
wire dram_ldqm;   //      Sdram Low-byte Data Mask 
wire dram_udqm;   //      Sdram High-byte Data Mask
wire dram_we_n;   //      Sdram Write Enable
wire dram_cas_n;   //      Sdram Column Address Strobe
wire dram_ras_n;   //      Sdram Row Address Strobe
wire dram_cs_n;   //      Sdram Chip Select
wire dram_ba_0;   //      Sdram Bank Address 0
wire dram_ba_1;   //      Sdram Bank Address 0
wire dram_clk;   //      Sdram Clock
wire dram_cke;   //      Sdram Clock Enable


task sync_attente;
  input int n;
  begin
    int i;
    for(i=0;i<n;i++) 
       @(negedge clock_50) ;
  end
endtask

//On instancie le module a tester.
sortie SORTIE(.clk(clock_50),.reset(reset),.uart_txd(uart_txd));

// On instancie la SRAM externe
IS61LV25616 SRAM(.A(sram_addr), .IO(sram_dq), .CE_(sram_oe_n), .OE_(sram_ce_n), .WE_(sram_we_n), .LB_(sram_lb_n), .UB_(sram_ub_n));

// On instancie la SDRAM externe
km416s4030 SDRAM(
        .BA0(dram_ba_0), 
        .BA1(dram_ba_1),    
        .DQML(dram_ldqm),    
        .DQMU(dram_udqm),    
        .DQ0(dram_dq[0]),     
        .DQ1(dram_dq[1]),     
        .DQ2(dram_dq[2]),    
        .DQ3(dram_dq[3]),     
        .DQ4(dram_dq[4]),     
        .DQ5(dram_dq[5]),    
        .DQ6(dram_dq[6]),     
        .DQ7(dram_dq[7]),     
        .DQ8(dram_dq[8]),     
        .DQ9(dram_dq[9]),     
        .DQ10(dram_dq[10]),    
        .DQ11(dram_dq[11]),    
        .DQ12(dram_dq[12]),    
        .DQ13(dram_dq[13]),    
        .DQ14(dram_dq[14]),    
        .DQ15(dram_dq[15]),    
        .CLK(dram_clk),     
        .CKE(dram_cke),     
        .A0(dram_addr[0]),      
        .A1(dram_addr[1]),      
        .A2(dram_addr[2]),       
        .A3(dram_addr[3]),       
        .A4(dram_addr[4]),       
        .A5(dram_addr[5]),       
        .A6(dram_addr[6]),       
        .A7(dram_addr[7]),       
        .A8(dram_addr[8]),       
        .A9(dram_addr[9]),       
        .A10(dram_addr[10]),      
        .A11(dram_addr[11]),      
        .WENeg(dram_we_n),  
        .RASNeg(dram_ras_n),  
        .CSNeg(dram_cs_n),   
        .CASNeg(dram_cas_n)  
        ) ;

// Le FPGA LUI MEME
DE2_TOP DE2(.CLOCK_27(zero),
            .CLOCK_50(clock_50),
            .EXT_CLOCK(zero),
            .KEY({zero,zero,zero,~reset}),
            .UART_TXD(uart_txd),
            .UART_RXD(uart_rxd), 
            .SRAM_DQ(sram_dq), 
            .SRAM_ADDR(sram_addr),
            .SRAM_UB_N(sram_ub_n), 
            .SRAM_LB_N(sram_lb_n), 
            .SRAM_WE_N(sram_we_n), 
            .SRAM_CE_N(sram_oe_n), 
            .SRAM_OE_N(sram_ce_n),
            .DRAM_DQ(dram_dq),				//	SDRAM Data bus 16 Bits
            .DRAM_ADDR(dram_addr),				//	SDRAM Address bus 12 Bits
            .DRAM_LDQM(dram_ldqm),				//	SDRAM Low-byte Data Mask 
            .DRAM_UDQM(dram_udqm),				//	SDRAM High-byte Data Mask
            .DRAM_WE_N(dram_we_n),				//	SDRAM Write Enable
            .DRAM_CAS_N(dram_cas_n),				//	SDRAM Column Address Strobe
            .DRAM_RAS_N(dram_ras_n),				//	SDRAM Row Address Strobe
            .DRAM_CS_N(dram_cs_n),				//	SDRAM Chip Select
            .DRAM_BA_0(dram_ba_0),				//	SDRAM Bank Address 0
            .DRAM_BA_1(dram_ba_1),				//	SDRAM Bank Address 0
            .DRAM_CLK(dram_clk),				//	SDRAM Clock
            .DRAM_CKE(dram_cke)				//	SDRAM Clock Enable

);

initial begin
   $timeformat(-9, 1,  " ns", 6);
   clock_50 = 0;
   reset = 1;      // deassert reset  t=0	
   #100ns reset = 0;   // assert reset    t=3
   sync_attente(434*800) ;
   $stop;      // to kill the simulation
end

// This block generates a clock pulse
always
  #10ns clock_50 = ~ clock_50;

endmodule
