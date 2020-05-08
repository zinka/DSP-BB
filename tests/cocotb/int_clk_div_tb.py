import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
import cocotb.wavedrom
from cocotb.drivers import BitDriver
from cocotb.binary import BinaryValue
from cocotb.monitors import Monitor
from cocotb.decorators import coroutine
from cocotb.scoreboard import Scoreboard
from cocotb.regression import TestFactory

from cocotb.result import TestFailure
import random


def input_gen():
    while True:
        yield random.randint(1, 5), random.randint(1, 5)


class BitMonitor(Monitor):
    """Observe a single-bit input or output of the DUT."""
    def __init__(self, name, signal, clk, callback=None, event=None):
        self.name = name
        self.signal = signal
        self.clk = clk
        Monitor.__init__(self, callback, event)

    @coroutine
    def _monitor_recv(self):
        clkedge = RisingEdge(self.clk)

        while True:
            yield clkedge
            vec = self.signal.value
            self._recv(vec)


class CNT_TB(object):
    def __init__(self, dut, init_val):
        self.dut = dut
        self.stopped = False

        self.input_drv = BitDriver(signal=dut.i_ce,
                                   clk=dut.i_clk,
                                   generator=input_gen())
        self.output_mon = BitMonitor(name="output",
                                     signal=dut.o_clk,
                                     clk=dut.i_clk)

        self.expected_output = [init_val]
        self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.output_mon, self.expected_output)

        self.input_mon = BitMonitor(name="input",
                                    signal=dut.o_clk,
                                    clk=dut.i_clk,
                                    callback=self.model)

    def model(self, transaction):
        if not self.stopped:
            self.expected_output.append(transaction)

    def start(self):
        self.input_drv.start()

    def stop(self):
        self.input_drv.stop()
        self.stopped = True


@cocotb.test(skip=False)
def class_test(dut):
    # clock and clock edge
    cocotb.fork(Clock(dut.i_clk, 10, 'ns').start(start_high=False))
    clkedge = RisingEdge(dut.i_clk)

    # instantiate the module
    tb = CNT_TB(dut, init_val=BinaryValue(0))

    # Apply random input data by input_gen via BitDriver for 100 clock cycles.
    tb.start()
    # yield Timer(100, units='ns')
    for _ in range(100):
        yield clkedge

    # Stop generation of input data. One more clock cycle is needed to capture
    # the resulting output of the DUT.
    tb.stop()
    yield clkedge

    # Print result of scoreboard.
    raise tb.scoreboard.result


@cocotb.test(skip=True)
def wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace and save it to wavedrom.json
    """
    with cocotb.wavedrom.trace(dut.i_rstn,
                               dut.i_ce,
                               dut.counter,
                               dut.state,
                               clk=dut.i_clk) as waves:

        cocotb.fork(Clock(dut.i_clk, 10, units='ns').start())
        dut.i_ce <= 1
        dut.i_rstn <= 1
        yield Timer(10, units='ns')
        dut.i_rstn <= 0
        yield Timer(10, units='ns')
        dut.i_rstn <= 1
        yield Timer(180, units='ns')
        dut._log.info("counter value is: " + str(int(dut.counter.value)) +
                      "\n")

        dut._log.info(
            waves.dumpj(header={
                'text': 'WaveDrom example',
                'tick': 0
            }))
        waves.write('wavedrom.json', header={'tick': 0}, config={'hscale': 3})


# Register the test.
factory = TestFactory(class_test)
factory.generate_tests()        