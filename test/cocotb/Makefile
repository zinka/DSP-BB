WPWD=$(shell pwd)

VERILOG_SOURCES = $(WPWD)/../../hdl/adder.v
VERILOG_SOURCES = $(WPWD)/../../hdl/int_clk_div.v
VERILOG_SOURCES = $(WPWD)/../../hdl/primitives/signed_adder.v

TOPLEVEL := adder # hdl module name
TOPLEVEL := int_clk_div # hdl module name
TOPLEVEL := signed_adder # hdl module name

MODULE   := test_adder # testbench name
MODULE   := int_clk_div_tb # testbench name
MODULE   := signed_adder_tb # testbench name

VERILATOR_TRACE := 0
SIM := verilator

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim
