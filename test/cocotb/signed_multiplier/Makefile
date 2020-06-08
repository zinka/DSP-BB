WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../../hdl/primitives/signed_multiply.v

TOPLEVEL := signed_multiply # hdl module name

MODULE   := signed_multiply_tb # testbench name

VERILATOR_TRACE := 0
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
