#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Unsigned Multiply Gr
# GNU Radio version: 3.8.1.0

from gnuradio import blocks
import pmt
from gnuradio import gr
from gnuradio.filter import firdes
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
import relative_path  # embedded python module


class unsigned_multiply_gr(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Unsigned Multiply Gr")

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 32000

        ##################################################
        # Blocks
        ##################################################
        self.file_source_0_0 = blocks.file_source(gr.sizeof_float*1, 'data_b.bin', False, 0, 0)
        self.file_source_0_0.set_begin_tag(pmt.PMT_NIL)
        self.file_source_0 = blocks.file_source(gr.sizeof_float*1, 'data_a.bin', False, 0, 0)
        self.file_source_0.set_begin_tag(pmt.PMT_NIL)
        self.blocks_throttle_0_0 = blocks.throttle(gr.sizeof_float*1, samp_rate,True)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_float*1, samp_rate,True)
        self.blocks_multiply_xx_0 = blocks.multiply_vff(1)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_float*1, 'data_prod.bin', False)
        self.blocks_file_sink_0.set_unbuffered(True)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_multiply_xx_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_throttle_0_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.file_source_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.file_source_0_0, 0), (self.blocks_throttle_0_0, 0))


    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.blocks_throttle_0.set_sample_rate(self.samp_rate)
        self.blocks_throttle_0_0.set_sample_rate(self.samp_rate)





def main(top_block_cls=unsigned_multiply_gr, options=None):
    tb = top_block_cls()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()

    try:
        input('Press Enter to quit: ')
    except EOFError:
        pass
    tb.stop()
    tb.wait()


if __name__ == '__main__':
    main()
