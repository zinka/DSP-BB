# Author: Srinivasa Rao Zinka (srinivas . zinka [at] gmail . com)
# Copyright (c) 2016 Srinivasa Rao Zinka
# License: New BSD License.
"""
Module for testing int_clk_div.v

**Progress:**
Just some bassic tests got added.
"""

import random

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
from cocotb.triggers import RisingEdge, Timer


def input_gen():
    """
    Generator for input data applied by BitDriver.
    Continually yield a tuple with the number of cycles to be ON
    followed by the number of cycles to be OFF.

    Think of it like a *signal generator*!
    """
    while True:
        yield random.randint(1, 5), random.randint(1, 5)


class BitMonitor(Monitor):
    """
    Monitor a single-bit input or output of the DUT (on raising edge).

    Think of it like an *oscilloscope*!    

    :param str name: name of the monitor
    :param str signal: signal to be monitored
    :param str clk: reference clock
    :param callback: callback to be called with each recovered transaction as the argument
    :param event: event that will be called when a transaction is received
    """
    def __init__(self, name, signal, clk, callback=None, event=None):
        self.name = name
        self.signal = signal
        self.clk = clk
        Monitor.__init__(self, callback, event)

    @coroutine
    def _monitor_recv(self):
        """
        capture some behavior of the pins, form a transaction, and pass this 
        transaction to the internal ``_recv`` method
        """
        clkedge = RisingEdge(self.clk)  # this gets executed only once

        while True:
            yield clkedge  # fire on raising edge (until then wait!) ... and then exit temporarily

            # welcome back after 0 sec delay!
            # change the monitored value just after the raising (active) edge
            vec = self.signal.value  # next execution resumes from this point
            self._recv(vec)  # pass on the received transaction


class CNT_TB(object):
    """
    Test fixture

    Think of it like the *overall setup* containing DUT, signal generator and oscilloscope!.

    :param dut: Veriog module under test
    :param init_val: ``BinaryValue`` which must be captured by the output monitor with the first rising clock edge
    """
    def __init__(self, dut, init_val):

        self.stopped = False  # just a flag ... this is like a pause button

        # bring in the DUT
        self.dut = dut

        # start input stimulus (bring in the signal generator)
        self.input_drv = BitDriver(signal=dut.i_ce,
                                   clk=dut.i_clk,
                                   generator=input_gen())

        # start monitoring the output (bring in the oscilloscope and switch it ON)
        self.output_mon = BitMonitor(name="output",
                                     signal=dut.o_clk,
                                     clk=dut.i_clk)

        # check against expected values (note down the readings and compare with the expected)
        self.expected_output = [init_val]
        self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.output_mon, self.expected_output)

        # prepare the next expected value using a GOLDEN reference (dynamically update the reference values)
        self.input_mon = BitMonitor(name="input",
                                    signal=dut.o_clk,
                                    clk=dut.i_clk,
                                    callback=self.reference)

    def start(self):
        """
        Start the stimulus

        Think of it like switching ON the signal generator!
        """
        self.input_drv.start()

    def stop(self):
        """
        Stop the stimulus and update the `stopped` status.

        Think of it like switching OFF the signal generator! ... 
        remember if you start again, test starts from the previous state
        """
        self.input_drv.stop()
        self.stopped = True

    def reference(self, transaction):
        """
        Golden reference model.

        Think of it like a reference (expected) signal generator!

        :param transaction: transaction received
        """
        if not self.stopped:
            self.expected_output.append(transaction)


@cocotb.test(skip=False)
def class_test(dut):
    """
    Setup the (generic) test fixure and start "class_test"

    :param dut: Veriog module under test
    """

    # clock and clock edge (time is not part of test fixure)
    cocotb.fork(Clock(dut.i_clk, 10, 'ns').start(start_high=False))
    clkedge = RisingEdge(dut.i_clk)

    # instantiate the test fixure
    tb = CNT_TB(dut, init_val=BinaryValue(0))

    # start the stimulus and wait for 100 clock cycles
    tb.start()
    for _ in range(100):
        yield clkedge

    # stop the stimulus ... one more clock cycle is needed to capture
    # the resulting output of the DUT
    tb.stop()
    yield clkedge

    # print result of the scoreboard (submit the readings)
    raise tb.scoreboard.result


@cocotb.test(skip=False)
def wavedrom_test(dut):
    """
    A simple test to provide a Wavedrom file

    :param dut: Veriog module under test
    """
    with cocotb.wavedrom.trace(dut.i_rstn,
                               dut.i_ce,
                               dut.counter,
                               dut.state,
                               clk=dut.i_clk) as waves:

        # start the clock
        cocotb.fork(Clock(dut.i_clk, 10, units='ns').start())

        # provide the seqence manually
        dut.i_ce <= 1
        dut.i_rstn <= 1
        yield Timer(10, units='ns')
        dut.i_rstn <= 0
        yield Timer(10, units='ns')
        dut.i_rstn <= 1
        yield Timer(180, units='ns')

        # prepare json script and print it out
        dut._log.info(
            waves.dumpj(header={
                'text': 'WaveDrom example',
                'tick': 0
            }))

        # write the json script to a file
        waves.write('wavedrom.json', header={'tick': 0}, config={'hscale': 3})


# Register the test.
factory = TestFactory(class_test)
factory.generate_tests()