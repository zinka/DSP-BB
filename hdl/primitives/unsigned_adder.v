/*
******************************************************************************
* @file    : unsigned_adder.v
* @project : DSP Building Blocks
* @brief   : A simple adder for unsigned integers
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : just ensure 
             0 <= i_a <= 2^AWIDTH -1, and
             0 <= i_b <= 2^BWIDTH -1.
             Bit growth taken care.
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

`timescale 1ns/1ns
`default_nettype none

module unsigned_adder #(
           parameter AWIDTH=16,
           parameter BWIDTH=16
       )
       (
           input  wire  i_clk,
           input  wire  [AWIDTH-1:0] i_a,
           input  wire  [BWIDTH-1:0] i_b,
           output reg   [OUTWID-1:0] o_sum
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

// 1) cover 10+5 = 15
// 2) assert the maximum sum value

/*
***************************************************************************
* formal verification code 
* (only formal verification here ... other tests in COCOTB module)
***************************************************************************
*/

`ifdef  FORMAL

reg f_past_valid;
reg f_sum_valid;
initial f_past_valid = 1'b0;
initial f_sum_valid = 1'b0;
always @(posedge i_clk)
begin
    f_past_valid <= 1'b1;
    if(f_past_valid == 1'b1) f_sum_valid <= 1'b1;
end

// selecting from a set of tests
localparam [2:0] FORMAL_TEST = 3'd1;

generate

    // cover 10+5 = 15
    if (FORMAL_TEST == 3'b000)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == 5));
            cover(o_sum == 15);
        end
    end

    // assert the maximum sum value
    else if (FORMAL_TEST == 3'b001)
    begin
        always @(posedge i_clk)
        begin
            assume(i_a == {AWIDTH{1'b1}});
            assume(i_b == {BWIDTH{1'b1}});
            if(f_sum_valid) assert(o_sum[0] == 0);
            if(f_sum_valid) assert(o_sum[OUTWID-1:1] == {(OUTWID-1){1'b1}});
        end
    end

endgenerate

`endif  // FORMAL      

endmodule
