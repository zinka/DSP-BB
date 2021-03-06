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
from adder_model import adder_model
from signed_adder_gr import main


def bin2sign(bin_value):
    """
    A simple functional to convert 2's compliment binary value to signed integer

    :param bin_value: 2's compliment binary value
    """
    vec = BinaryValue()
    vec.signed_integer = bin_value.value
    return vec.signed_integer


@cocotb.test(timeout_time=50, timeout_unit="ns", skip=False)
def basic_simulation(dut):
    """
    A simple functional test to provide a Wavedrom file

    :param dut: Veriog module under test
    """
    with cocotb.wavedrom.trace(dut.i_a, dut.i_b, dut.o_sum, clk=dut.i_clk) as waves:

        # start the clock
        cocotb.fork(Clock(dut.i_clk, 10, units="ns").start())
        clkedge = RisingEdge(dut.i_clk)

        # provide an input sequence manually
        # cycle-I
        dut.i_a <= 1
        dut.i_b <= 2
        yield clkedge
        yield ReadWrite()
        print(dut.o_sum.value)
        # cycle-II
        dut.i_a <= 2
        dut.i_b <= 3
        yield clkedge
        yield ReadWrite()
        print(dut.o_sum.value)
        # cycle-II
        dut.i_a <= 10
        dut.i_b <= -15
        yield clkedge
        yield ReadWrite()
        print(dut.o_sum.value)

        # # prepare json script and print it out
        # waves.dumpj(header={'text': 'WaveDrom example', 'tick': 0})

        # # write the json script to a file
        # waves.write('wavedrom.json', header={'tick': 0}, config={'hscale': 3})


@cocotb.test(timeout_time=200, timeout_unit="ns", skip=False)
def basic_test(dut):
    """
    Randmized test for o_sum = i_a + i_b (signed addition/subtraction)
    """

    # start the clock
    cocotb.fork(Clock(dut.i_clk, 10, units="ns").start())
    clkedge = RisingEdge(dut.i_clk)

    yield clkedge  # synchronize ourselves with the clock

    # start the simulation
    for _ in range(10):

        # randomize the input data
        A = random.randint(-10, 15)
        B = random.randint(-10, 15)
        dut.i_a <= A
        dut.i_b <= B

        # wait for posedge and let the output be resolved
        yield clkedge
        yield ReadWrite()  # there seems some "updating" issue with cocotb here! ... without this statement, this test won't pass

        # format A if it is a negative number
        if A < 0:
            i_A = bin2sign(dut.i_a)
        else:
            i_A = int(dut.i_a)

        # format B if it is a negative number
        if B < 0:
            i_B = bin2sign(dut.i_b)
        else:
            i_B = int(dut.i_b)

        # format the output if it is a negative number
        if adder_model(A, B) < 0:
            o_SUM = bin2sign(dut.o_sum)
        else:
            o_SUM = int(dut.o_sum)

        # compare with the reference model
        if o_SUM != adder_model(A, B):
            raise TestFailure(
                "Randomised test failed with: %s + %s = %s" % (i_A, i_B, o_SUM)
            )
        else:
            dut._log.info(
                "Randomised test passed with: %s + %s = %s" % (i_A, i_B, o_SUM)
            )


@cocotb.test(timeout_time=200, timeout_unit="ns", skip=False)
def gr_test(dut):
    """
    Randmized test for o_sum = i_a + i_b (signed addition/subtraction) using GNU Radio
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

        # randomize the input data
        A = random.randint(-10, 15)
        B = random.randint(-10, 15)
        dut.i_a <= A
        dut.i_b <= B

        # wait for posedge and let the output be resolved
        yield clkedge
        yield ReadWrite()  # there seems some "updating" issue with cocotb here! ... without this statement, this test won't pass

        # format A if it is a negative number
        if A < 0:
            i_A = bin2sign(dut.i_a)
        else:
            i_A = int(dut.i_a)

        # format B if it is a negative number
        if B < 0:
            i_B = bin2sign(dut.i_b)
        else:
            i_B = int(dut.i_b)

        # format the output if it is a negative number
        if adder_model(A, B) < 0:
            o_SUM = bin2sign(dut.o_sum)
        else:
            o_SUM = int(dut.o_sum)

        a_lst.append(i_A)
        b_lst.append(i_B)
        sum_lst.append(o_SUM)

    # pass the data to Gnu Radio and get the return data
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
