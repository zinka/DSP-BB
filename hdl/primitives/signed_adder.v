/*
******************************************************************************
* @file    : signed_adder.v
* @project : DSP Building Blocks
* @brief   : A simple adder for signed integers
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : just ensure 
             -2^(AWIDTH-1) <= i_a <= 2^(AWIDTH-1) -1, and
             -2^(BWIDTH-1) <= i_b <= 2^(BWIDTH-1) -1.
             Bit growth is taken care.
******************************************************************************
* This code is licensed under the MIT License.
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
           output reg   signed  [OUTWID-1:0] o_sum
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
localparam [2:0] FORMAL_TEST = 3'b001;

generate

    // simple alternative to testbench
    if (FORMAL_TEST == 3'b000)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == -4'd15));
            cover(o_sum == -4'd5);
        end
    end

    // asserting "if a<0 && b>=0, sum<b"
    else if (FORMAL_TEST == 3'b001)
    begin
        reg signed [AWIDTH-1:0] f_difference = 0; // sum-b, i.e., a, should be negative
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1)&&(i_b[BWIDTH-1]==0)); // a<0 and b>=0
            f_difference <= o_sum-$past(i_b);
            if(f_sum_valid) assert(f_difference[AWIDTH-1]==1'b1); // assert only after a valid sum is available
        end
    end

    // asserting "if a>=0 && b>=0, sum>=a && sum>=b"
    else if (FORMAL_TEST == 3'b010)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==0) && (i_b[BWIDTH-1]==0));
            if(f_sum_valid) assert(o_sum >= $past(i_a)); // assert only after a valid sum is available
            if(f_sum_valid) assert(o_sum >= $past(i_b)); // assert only after a valid sum is available
        end
    end

    // asserting "if a<0 && b<0, sum<a && sum<b"
    else if (FORMAL_TEST == 3'b011)
    begin
        reg signed [AWIDTH-1:0] f_difference_sb = 0; // sum-b, i.e., a, should be negative
        reg signed [BWIDTH-1:0] f_difference_sa = 0; // sum-a, i.e., b, should be negative
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1) && (i_b[BWIDTH-1]==1));
            f_difference_sb <= o_sum-$past(i_b);
            if(f_sum_valid) assert(f_difference_sb[AWIDTH-1]==1'b1); // assert only after a valid sum is available
            f_difference_sa <= o_sum-$past(i_a);
            if(f_sum_valid) assert(f_difference_sa[BWIDTH-1]==1'b1); // assert only after a valid sum is available
        end
    end

endgenerate

`endif  // FORMAL    

endmodule
