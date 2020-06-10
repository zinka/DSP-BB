# Author: Srinivasa Rao Zinka (srinivas . zinka [at] gmail . com)
# Copyright (c) 2020 Srinivasa Rao Zinka
# License: MIT License
"""
Module for testing signed_adder.v

**Progress:**
Just some bassic tests got added.
"""

import sys
sys.path.insert(1,'/usr/lib/python3/dist-packages') # add gnuradio path

import cocotb
import cocotb.wavedrom
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.decorators import coroutine
from cocotb.drivers import BitDriver
from cocotb.monitors import Monitor
from cocotb.regression import TestFactory
from cocotb.result import TestFailure
from cocotb.scoreboard import Scoreboard
from cocotb.triggers import RisingEdge, Timer, ReadWrite, ReadOnly

import random
import numpy as np
from signed_multiply_gr import main

def bin2sign(bin_value):
    """
    A simple functional to convert 2's compliment binary value to signed integer

    :param bin_value: 2's compliment binary value
    """    
    vec = BinaryValue()
    vec.signed_integer = bin_value.value
    return vec.signed_integer

@cocotb.test(timeout_time=200, timeout_unit='ns', skip=False)
def multiply_gr_test(dut):
    """
    Randmized test for o_prod = i_a * i_b (signed multiplication) using GNU Radio
    """

    # start the clock
    cocotb.fork(Clock(dut.i_clk, 10, units='ns').start())
    clkedge = RisingEdge(dut.i_clk)
    yield clkedge  # synchronize ourselves with the clock

    # start the simulation
    a_lst = []
    b_lst = []
    prod_lst = []
    for _ in range(10):

        # randomize the input data
        A = random.randint(-10, 15)
        B = random.randint(-10, 15)
        dut.i_a <= A
        dut.i_b <= B

        # wait for posedge and let the output be resolved
        yield clkedge
        yield ReadWrite() # there seems some "updating" issue with cocotb here! ... without this statement, this test won't pass

        # format A if it is a negative number
        if (A < 0):
            i_A = bin2sign(dut.i_a)
        else:
            i_A = int(dut.i_a)

        # format B if it is a negative number
        if (B < 0):
            i_B = bin2sign(dut.i_b)
        else:
            i_B = int(dut.i_b)

        # format the output if it is a negative number
        if (A*B < 0):
            o_PROD = bin2sign(dut.o_prod)
        else:
            o_PROD = int(dut.o_prod)   

        a_lst.append(i_A)
        b_lst.append(i_B)
        prod_lst.append(o_PROD)
    
    # pass the data to Gnu Radio and get the return data
    np.array(a_lst, dtype=np.float32).tofile("data_a.bin")
    np.array(b_lst, dtype=np.float32).tofile("data_b.bin")
    main() # call the main Gnu Radio flowgraph
    prod_lst_gr = np.fromfile("data_prod.bin", dtype=np.float32)

    # compare the returned data with verilator output
    if np.array_equal(prod_lst_gr, np.array(prod_lst)):
        dut._log.info("gr_test passed")
    else:
        raise TestFailure("gr_test failed")

    # print for convinience
    print(np.fromfile("data_a.bin", dtype=np.float32))
    print(np.fromfile("data_b.bin", dtype=np.float32))
    print(np.fromfile("data_prod.bin", dtype=np.float32))    


if __name__ == "__main__":

    # # write to binary file
    # a = np.array([5,6,7,8], dtype=np.float32)
    # a.tofile("a.bin")
    # b = np.array([5,6,7,8], dtype=np.float32)
    # b.tofile("b.bin")

    # # read from binary file
    print(np.fromfile("data_a.bin", dtype=np.float32))
    print(np.fromfile("data_b.bin", dtype=np.float32))
    print(np.fromfile("data_prod.bin", dtype=np.float32))