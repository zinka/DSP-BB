TOPLEVEL := int_clk_div # hdl module name
MODULE   := int_clk_div_tb # testbench name

VERILATOR_TRACE := 1
SIM := verilator

WPWD=$(shell pwd)
VERILOG_SOURCES = $(WPWD)/../../hdl/int_clk_div.v

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
