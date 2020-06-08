/*
******************************************************************************
* @file    : unsigned_multiply.v
* @project : DSP Building Blocks
* @brief   : A simple multiplier for unsigned integers
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

module unsigned_multiply #(
           parameter AWIDTH=16,
           parameter BWIDTH=16
       )
       (
           input  wire  i_clk,
           input  wire  [AWIDTH-1:0] i_a,
           input  wire  [BWIDTH-1:0] i_b,
           output reg   [OUTWID-1:0] o_prod
       );

/*
***************************************************************************
* main code
***************************************************************************
*/

// deciding output width
localparam	OUTWID = (AWIDTH + BWIDTH);

always @(posedge i_clk) begin
    o_prod <= i_a * i_b;
end

/*
***************************************************************************
* Requirements
***************************************************************************
*/

// 0) cover 10*5 = 50

/*
***************************************************************************
* formal verification code 
* (only formal verification here ... other tests in COCOTB module)
***************************************************************************
*/

`ifdef  FORMAL

reg f_past_valid = 1'b0;
reg f_prod_valid = 1'b0;
always @(posedge i_clk)
begin
    f_past_valid <= 1'b1;
    if(f_past_valid == 1'b1) f_prod_valid <= 1'b1;
end

// selecting from a set of tests
localparam [2:0] FORMAL_TEST = 3'd0;

generate

    // TEST-0: cover 10*5 = 50
    if (FORMAL_TEST == 3'd0)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == 4'd5));
            cover(o_prod == 7'd50);            
        end
    end

endgenerate

`endif  // FORMAL

endmodule
