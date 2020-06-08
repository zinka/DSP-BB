WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../../hdl/primitives/signed_adder.v

TOPLEVEL := signed_adder # hdl module name

MODULE   := signed_adder_tb # testbench name

VERILATOR_TRACE := 0
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
