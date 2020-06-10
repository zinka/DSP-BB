/*
******************************************************************************
* @file    : qadd.v
* @project : DSP Building Blocks
* @brief   : module to add two numbers given in fixed point format
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : what about overflow?
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

`timescale 1ns/1ns
`default_nettype none

module qadd #(
           parameter Q = 15, // number of fractional bits
           parameter N = 32  // total number of bits
       )
       (
           input  wire i_clk,
           input  wire [N-1:0] a,  // addend 1
           input  wire [N-1:0] b,  // addend 2
           output reg  [N-1:0] c   // sum
       );

/*
***************************************************************************
* main code
***************************************************************************
*/	

always @(posedge i_clk)
begin

    // both negative or both positive
    if(a[N-1] == b[N-1])
    begin
        c[N-2:0] <= a[N-2:0] + b[N-2:0];
        c[N-1] <= a[N-1];
    end

    // a +ve and b -ve
    else if(a[N-1] == 0 && b[N-1] == 1)
    begin
        if( a[N-2:0] > b[N-2:0] )
        begin
            c[N-2:0] <= a[N-2:0] - b[N-2:0];
            c[N-1] <= 0;
        end
        else
        begin
            c[N-2:0] <= b[N-2:0] - a[N-2:0];
            if (c[N-2:0] == 0) c[N-1] <= 0;
            else c[N-1] <= 1;
        end
    end

    // a -ve or b +ve
    else
    begin
        if( a[N-2:0] > b[N-2:0] )
        begin
            c[N-2:0] <= a[N-2:0] - b[N-2:0];
            if (c[N-2:0] == 0)
                c[N-1] <= 0;
            else
                c[N-1] <= 1;
        end
        else
        begin
            c[N-2:0] <= b[N-2:0] - a[N-2:0];
            c[N-1] <= 0;
        end
    end

end

/*
***************************************************************************
* Requirements
***************************************************************************
*/

// 0) cover 10.23-15.67 = -5.44

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

    // cover 10.23-15.67 = -5.44
    if (FORMAL_TEST == 3'b000)
    begin
        always @(posedge i_clk)
        begin
            assume((i_a == 10) && (i_b == 5));
            cover(o_sum == 15);
        end
    end

endgenerate

`endif  // FORMAL  	

endmodule
