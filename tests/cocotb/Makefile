WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../hdl/adder.v
VERILOG_SOURCES = $(WPWD)/../../hdl/int_clk_div.v

TOPLEVEL := adder # hdl module name
TOPLEVEL := int_clk_div # hdl module name

MODULE   := test_adder # testbench name
MODULE   := int_clk_div_tb # testbench name

VERILATOR_TRACE := 1
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
