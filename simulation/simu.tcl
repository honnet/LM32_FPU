# set_input_dir "/cal/nfs3/promo10/clanzig/COMELEC380/LM32_SYNTH/src/soc"
set TOP_DIR  [ pwd ]/..

## compile verilog files

vcom +acc  $TOP_DIR/src/wb_sdr_fb_ctrl/common.vhd
vcom +acc  $TOP_DIR/src/wb_sdr_fb_ctrl/sdramcntl.vhd
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_sdr_fb_ctrl/sync_fifo.sv
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_sdr_fb_ctrl/wb_sdram16.sv
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_uart/uart.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_uart/wb_uart.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_sram/wb_sram16.sv

vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/counter.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/shift.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/ms_core.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/processor_interface.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/i2c_blk.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_i2c/wb_i2c.v

vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/wb_conbus $TOP_DIR/src/wb_conbus/wb_conbus_arb.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/wb_conbus $TOP_DIR/src/wb_conbus/wb_conbus_top.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_adder.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_addsub.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_cpu.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_dcache.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_decoder.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_icache.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_instruction_unit.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_interrupt.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_load_store_unit.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_logic_op.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_mc_arithmetic.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_monitor.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_multiplier.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_ram.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_shifter.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/src/lm32_top  $TOP_DIR/src/lm32_top/lm32_top.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_timer/wb_timer.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top $TOP_DIR/src/wb_bram/wb_bram.v
vlog +acc  +incdir+$TOP_DIR/src/soc_top +incdir+$TOP_DIR/soft $TOP_DIR/src/soc_top/system_top.v
vlog +acc  $TOP_DIR/src/sortie/sortie.sv
vlog +acc  $TOP_DIR/target/src/PLL/pll.v
vlog +acc  $TOP_DIR/target/src/frm_exercise.sv
vlog +acc $TOP_DIR/target/src/DE2_TOP.v
vcom +acc src_simu/conversions.vhd
vcom +acc src_simu/gen_utils.vhd
vcom +acc src_simu/km416s4030.vhd
vlog +acc src_simu/IS61LV25616.v
vlog +acc src_simu/test_bench_DE2.sv
vlog +acc $TOP_DIR/target/src/gen_vga_sync.sv
vlog +acc $TOP_DIR/target/src/palette.sv
vlog +acc $TOP_DIR/target/src/bateau.sv

exit -f
