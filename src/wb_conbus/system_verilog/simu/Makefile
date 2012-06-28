
.PHONY: all clean

all: clean modelSim

modelSim:
	vlib work
	vsim

clean:
	rm -rf work
	rm -f transcript vsim.wlf *~
	rm -f ../*~