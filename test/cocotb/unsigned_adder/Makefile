WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../../hdl/primitives/unsigned_adder.v

TOPLEVEL := unsigned_adder # hdl module name

MODULE   := unsigned_adder_tb # testbench name

VERILATOR_TRACE := 0
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
