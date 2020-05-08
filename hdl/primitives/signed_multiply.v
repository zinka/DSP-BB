/*
******************************************************************************
* @file    : signed_multiply.v
* @project : DSP Building Blocks
* @brief   : A simple multiplier for signed integers
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : just ensure -2^(AWIDTH-1) <= i_a <= 2^(AWIDTH-1) -1, etc. 
             Bit growth is taken care.
******************************************************************************
* This program is hereby granted to the public domain.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
* FITNESS FOR A PARTICULAR PURPOSE.
******************************************************************************
*/

`default_nettype none

module signed_multiply #(
    parameter AWIDTH=16,
    parameter BWIDTH=16
)
(
    input  wire  signed  [AWIDTH-1:0] i_a,
	input  wire  signed  [BWIDTH-1:0] i_b,
	output wire  signed  [OUTWID:0]   o_prod // do I need signed?
);

    // deciding output width
    localparam	OUTWID = (AWIDTH + BWIDTH);

	assign o_prod = i_a * i_b;

endmodule