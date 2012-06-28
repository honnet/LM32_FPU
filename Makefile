export TOPDIR = $(shell pwd)
.PHONY: all clean software simu syn

all: syn

software:
	make all -C soft

simu_comp: software
	make compile_all -C simulation

simu: software
	make all -C simulation

syn: software
	make all -C target/syn

program: 
	make program -C target/syn

clean:
	make clean -C soft
	make clean -C simulation
	make clean -C target/syn
