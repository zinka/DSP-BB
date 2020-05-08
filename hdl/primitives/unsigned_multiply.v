/*
******************************************************************************
* @file    : unsigned_multiply.v
* @project : DSP Building Blocks
* @brief   : A simple multiplier for unsigned integers
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : just ensure 0 <= i_a <= 2^AWIDTH -1, etc. 
             Bit growth is taken care.
******************************************************************************
* This program is hereby granted to the public domain.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
* FITNESS FOR A PARTICULAR PURPOSE.
******************************************************************************
*/

`default_nettype none

module unsigned_multiply #(
    parameter AWIDTH=16,
    parameter BWIDTH=16
)
(
    input  wire  [AWIDTH-1:0] i_a,
	input  wire  [BWIDTH-1:0] i_b,
	output wire  [OUTWID:0]   o_prod
);

    // deciding output width
    localparam	OUTWID = (AWIDTH + BWIDTH);

	assign o_prod = i_a * i_b;

endmodule