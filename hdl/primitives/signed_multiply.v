/*
******************************************************************************
* @file    : signed_multiply.v
* @project : DSP Building Blocks
* @brief   : A simple multiplier for signed integers
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

module signed_multiply #(
           parameter AWIDTH=8,
           parameter BWIDTH=8
       )
       (
           input  wire  i_clk,
           input  wire  signed  [AWIDTH-1:0] i_a,
           input  wire  signed  [BWIDTH-1:0] i_b,
           output reg   signed  [OUTWID-1:0] o_prod
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

// 0) cover 10*-5 = -50
// 1) if a<0 && b>=0, prod<0 if b!=0
// 2) if a>=0 && b<0, prod<0 if a!=0
// 3) if a>=0 && b>=0, prod>0 if a!=0 and b!=0
// 4) if a<0 && b<0, prod>0

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

    // TEST-0: cover 10*-5 = -50
    if (FORMAL_TEST == 3'd0)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == -4'd5));
            cover(o_prod == -7'd50);            
        end
    end

    // TEST-1: if a<0 && b>=0, prod<0 if b!=0
    else if (FORMAL_TEST == 3'd1)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1)&&(i_b[BWIDTH-1]==0)); // a<0 and b>=0
            if(f_prod_valid && ($past(i_b)!=0)) assert(o_prod[OUTWID-1]==1'b1); // assert only after a valid product is available
        end
    end

    // TEST-2: if b<0 && a>=0, prod<0 if a!=0
    else if (FORMAL_TEST == 3'd2)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==0)&&(i_b[BWIDTH-1]==1)); // a>=0 and b<0
            if(f_prod_valid && ($past(i_a)!=0)) assert(o_prod[OUTWID-1]==1'b1); // assert only after a valid product is available
        end
    end

    // TEST-3: if a>=0 && b>=0, prod>0 if a!=0 and b!=0
    else if (FORMAL_TEST == 3'd3)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==0)&&(i_b[BWIDTH-1]==0)); // a>=0 && b>=0
            if(f_prod_valid) assert(o_prod[OUTWID-1]==1'b0); // don't need to check past a and b values
        end
    end

    // TEST-4: if a<0 && b<0, prod>0
    else if (FORMAL_TEST == 3'd4)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a[AWIDTH-1]==1)&&(i_b[BWIDTH-1]==1)); // a<0 && b<0
            if(f_prod_valid) assert(o_prod[OUTWID-1]==1'b0); // don't need to check past a and b values
        end
    end    

endgenerate

`endif  // FORMAL  

endmodule