// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2006 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================/
//                         FILE DETAILS
// Project          : LatticeMico32
// File             : lm32_include_all.v
// Title            : CPU include files
// Version          : 6.1.17
//                  : Initial Release
// Version          : 7.0SP2, 3.0
//                  : No Change
// Version          : 3.1
//                  : No Change
// =============================================================================

`ifndef LM32_ALL_FILES
`define LM32_ALL_FILES
`ifndef SIMULATION
`include "pmi_def.v"
`endif
`include "system_conf.v"
// JTAG Debug related files
`ifdef CFG_JTAG_ENABLED
  `include "../components/lm32_top/rtl/verilog/er1.v"
  `include "../components/lm32_top/rtl/verilog/typeb.v"
  `include "../components/lm32_top/rtl/verilog/typea.v"
  `include "../components/lm32_top/rtl/verilog/jtag_cores.v"
  `include "../components/lm32_top/rtl/verilog/jtag_lm32.v"
  `include "../components/lm32_top/rtl/verilog/lm32_jtag.v"
`endif
// CPU Core related files
`include "../components/lm32_top/rtl/verilog/lm32_addsub.v"
`include "../components/lm32_top/rtl/verilog/lm32_adder.v"
`include "../components/lm32_top/rtl/verilog/lm32_cpu.v"
`include "../components/lm32_top/rtl/verilog/lm32_dcache.v"
`include "../components/lm32_top/rtl/verilog/lm32_debug.v"
`include "../components/lm32_top/rtl/verilog/lm32_decoder.v"
`include "../components/lm32_top/rtl/verilog/lm32_icache.v"
`include "../components/lm32_top/rtl/verilog/lm32_instruction_unit.v"
`include "../components/lm32_top/rtl/verilog/lm32_interrupt.v"
`include "../components/lm32_top/rtl/verilog/lm32_load_store_unit.v"
`include "../components/lm32_top/rtl/verilog/lm32_logic_op.v"
`ifdef LM32_MC_ARITHMETIC_ENABLED
`include "../components/lm32_top/rtl/verilog/lm32_mc_arithmetic.v"
`endif
`ifdef CFG_PL_MULTIPLY_ENABLED
  `include "../components/lm32_top/rtl/verilog/lm32_multiplier.v"
`endif
`ifdef CFG_PL_BARREL_SHIFT_ENABLED
  `include "../components/lm32_top/rtl/verilog/lm32_shifter.v"
`endif
`include "../components/lm32_top/rtl/verilog/lm32_top.v"
`ifdef DEBUG_ROM
  `include "../components/lm32_top/rtl/verilog/lm32_monitor.v"
  `include "../components/lm32_top/rtl/verilog/lm32_monitor_ram.v"
`endif
`ifdef CFG_TRACE_ENABLED
  `define USE_LM32_RAM
`endif
`ifdef CFG_ICACHE_ENABLED
  `define USE_LM32_RAM
`endif
`ifdef CFG_DCACHE_ENABLED
  `define USE_LM32_RAM
`endif
`ifdef CFG_EBR_POSEDGE_REGISTER_FILE
  `define USE_LM32_RAM
`endif
`ifdef USE_LM32_RAM
  `include "../components/lm32_top/rtl/verilog/lm32_ram.v"
`endif  
  `include "../components/lm32_top/rtl/verilog/lm32_trace.v"
`endif // LM32_ALL_FILES
