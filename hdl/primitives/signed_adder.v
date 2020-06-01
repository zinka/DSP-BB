/*
******************************************************************************
* @file    : signed_adder.v
* @project : DSP Building Blocks
* @brief   : A simple adder for signed integers
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

`timescale 1ns/1ns
`default_nettype none

module signed_adder #(
           parameter AWIDTH=16,
           parameter BWIDTH=16
       )
       (
           input  wire  i_clk,
           input  wire  signed  [AWIDTH-1:0] i_a,
           input  wire  signed  [BWIDTH-1:0] i_b,
           output reg   [OUTWID-1:0]   o_sum
       );

/*
***************************************************************************
* main code
***************************************************************************
*/

// deciding output width
localparam	OUTWID = (AWIDTH > BWIDTH) ? (AWIDTH + 1) : (BWIDTH+1);

/* verilator lint_off WIDTH */
always @(posedge i_clk) begin
    o_sum <= i_a + i_b;
end
/* verilator lint_on WIDTH */

/*
***************************************************************************
* Requirements
***************************************************************************
*/

// 1) cover 10-15 = -5
// 2) if a<0 && b>0, sum<b
// 3) if a>0 && b>0, sum>a && sum>b
// 4) if a<0 && b<0, sum<a && sum<b

/*
***************************************************************************
* formal verification code 
* (only formal verification here other tests in COCOTB module)
***************************************************************************
*/

`ifdef  FORMAL

// selecting from a set of tests
localparam [2:0]	FORMAL_TEST = 3'b001;

generate

    if (FORMAL_TEST == 3'b000) // simple alternative to testbench
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == -4'd15));
            cover(o_sum == -4'd5);
        end
    end

    else if (FORMAL_TEST == 3'b001) // asserting "if a<0 && b>0, sum<b"
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1) && (i_b[BWIDTH-1]==0));
            // TODO
        end
    end

    else if (FORMAL_TEST == 3'b002) // asserting "if a>0 && b>0, sum>a && sum>b"
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==0) && (i_b[BWIDTH-1]==0));
            // TODO
        end
    end

    else if (FORMAL_TEST == 3'b003) // asserting "if a<0 && b<0, sum<a && sum<b"
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1) && (i_b[BWIDTH-1]==1));
            // TODO
        end
    end

endgenerate

`endif  // FORMAL    

endmodule
