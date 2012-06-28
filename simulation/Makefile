TOP_MODULE = test_bench_DE2

.PHONY: all clean simu_top compile_all.done

all: work compile_all.done simu_top

work:
	vlib work

compile_all:
	vsim -c -do simu.tcl

compile_all.done:compile_all
	touch $@

simu_top:
	vsim -L altera_mf_ver $(TOP_MODULE)

clean:
	rm -rf work
	rm -f transcript  vsim.wlf 
	rm -f compile_all.done
	rm -f soft.vm
