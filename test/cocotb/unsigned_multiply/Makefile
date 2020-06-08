WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../../hdl/primitives/unsigned_multiply.v

TOPLEVEL := unsigned_multiply # hdl module name

MODULE   := unsigned_multiply_tb # testbench name

VERILATOR_TRACE := 0
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
