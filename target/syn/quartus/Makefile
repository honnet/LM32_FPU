 
.PHONY: all clean program

all:
	mkdir -p db
	rm -rf db
	quartus_sh -t DE2_quartus.tcl

program:
	@quartus_pgm -c USB-Blaster  -m JTAG -oP\;DE2_TOP.sof
clean:
	rm -rf DE2_TOP*
	rm -rf db
	rm -rf incremental_db*
