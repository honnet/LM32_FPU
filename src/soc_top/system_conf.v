`ifndef SYSTEM_CONF
 `define SYSTEM_CONF
 
 // define lattice family
 `define LATTICE_FAMILY "EC"
 
 //`define CFG_TARGET_ASIC
 `timescale 1ns / 100 ps
 `define CLK_FREQUENCY 100_000_000

 `define CFG_EBA_RESET 32'h0
 `define MULT_ENABLE
 `define CFG_PL_MULTIPLY_ENABLED
 `define SHIFT_ENABLE
 `define CFG_PL_BARREL_SHIFT_ENABLED
 `define CFG_MC_DIVIDE_ENABLED
 `define CFG_SIGN_EXTEND_ENABLED
 `define CFG_CYCLE_COUNTER_ENABLED
 `define CFG_USER_ENABLED
 
 `define CFG_ICACHE_ENABLED
 `define CFG_ICACHE_BASE_ADDRESS 32'h0
 `define CFG_ICACHE_LIMIT 32'hffffff
 `define CFG_ICACHE_SETS 512
 `define CFG_ICACHE_ASSOCIATIVITY 1
 `define CFG_ICACHE_BYTES_PER_LINE 16
 `define CFG_ICACHE_AUTO

 `define CFG_DCACHE_ENABLED
 `define CFG_DCACHE_BASE_ADDRESS 32'h0
 `define CFG_DCACHE_LIMIT 32'hffffff
 `define CFG_DCACHE_SETS 512
 `define CFG_DCACHE_ASSOCIATIVITY 1
 `define CFG_DCACHE_BYTES_PER_LINE 16
 `define CFG_DCACHE_AUTO

 `define B_RAM_ADD_W 12

 `define ADDRESS_LOCK

 `define uartADDRWIDTH 5
 `define uartDATAWIDTH 8
 `define uartBAUD_RATE 115_200
 `define IB_SIZE 32'h4
 `define OB_SIZE 32'h4
 `define BLOCK_WRITE
 `define BLOCK_READ
 `define DATA_BITS 8
 `define STOP_BITS 1
 `define INTERRUPT_DRIVEN
 `define CharIODevice

 `define timerPERIOD_NUM 32'h14
 `define timerPERIOD_WIDTH 32'h20
 `define timerWRITEABLE_PERIOD
 `define timerREADABLE_SNAPSHOT
 `define timerSTART_STOP_CONTROL

 `define sramREAD_LATENCY 1
 `define sramWRITE_LATENCY 0
 `define sramLATENCY 0
 `define sramSRAM_ADDR_WIDTH 18
 `define sramSRAM_DATA_WIDTH 16
 `define sramSRAM_BE_WIDTH 2

`endif // SYSTEM_CONF
