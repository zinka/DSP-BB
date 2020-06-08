# Author: Srinivasa Rao Zinka (srinivas . zinka [at] gmail . com)
# Copyright (c) 2020 Srinivasa Rao Zinka
# License: MIT License
"""
Module for testing signed_adder.v

**Progress:**
Just some bassic tests got added.
"""

import sys
sys.path.insert(1, "/usr/lib/python3/dist-packages")  # for gnuradio

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
from unsigned_adder_gr import main


@cocotb.test(timeout_time=200, timeout_unit="ns", skip=False)
def gr_test(dut):
    """
    Randmized test for o_sum = i_a + i_b (unsigned addition/subtraction) using GNU Radio
    """

    # start the clock
    cocotb.fork(Clock(dut.i_clk, 10, units="ns").start())
    clkedge = RisingEdge(dut.i_clk)

    yield clkedge  # synchronize ourselves with the clock

    a_lst = []
    b_lst = []
    sum_lst = []
    # start the simulation
    for _ in range(10):

        # randomize the input data (+ve)
        A = random.randint(0, 100)
        B = random.randint(0, 100)
        dut.i_a <= A
        dut.i_b <= B

        # wait for posedge and let the output be resolved
        yield clkedge
        yield ReadWrite()  # there seems some "updating" issue with cocotb here! ... without this statement, this test won't pass

        # binary to integer
        i_A = int(dut.i_a)
        i_B = int(dut.i_b)
        o_SUM = int(dut.o_sum)

        # collect test i/p and o/p data
        a_lst.append(i_A)
        b_lst.append(i_B)
        sum_lst.append(o_SUM)

    # pass the data to GNU Radio and get the return data
    np.array(a_lst, dtype=np.float32).tofile("data_a.bin")
    np.array(b_lst, dtype=np.float32).tofile("data_b.bin")
    main()
    sum_lst_gr = np.fromfile("data_sum.bin", dtype=np.float32)

    # compare the returned data with verilator output
    if np.array_equal(sum_lst_gr, np.array(sum_lst)):
        dut._log.info("gr_test passed")
    else:
        raise TestFailure("gr_test failed")

    # print for convinience
    print(np.fromfile("data_a.bin", dtype=np.float32))
    print(np.fromfile("data_b.bin", dtype=np.float32))
    print(np.fromfile("data_sum.bin", dtype=np.float32))


if __name__ == "__main__":

    # # write to binary file
    # a = np.array([5,6,7,8], dtype=np.float32)
    # a.tofile("a.bin")
    # b = np.array([5,6,7,8], dtype=np.float32)
    # b.tofile("b.bin")

    # # from test.cocotb.model.top_block import main
    # main()

    # # read from binary file
    print(np.fromfile("a.bin", dtype=np.float32))
    print(np.fromfile("b.bin", dtype=np.float32))
    print(np.fromfile("sum.bin", dtype=np.float32))
