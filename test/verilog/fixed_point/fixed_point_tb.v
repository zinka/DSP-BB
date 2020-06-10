/*
******************************************************************************
* @file    : fixed_point_tb.v
* @project : DSP Building Blocks
* @brief   : A simple Verilog testbench to understand fixed point arithmetic
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

`timescale 1ns/1ns
`default_nettype none

module fixed_point_tb;

reg signed [7:0] a;
reg signed [7:0] b;
reg signed [7:0] c;
reg signed [15:0] ab;  // large enough for product
localparam sf = 2.0**-4.0;  // Q4.4 scaling factor, 2^-4

initial
begin
    $display("=========================================\n");

    // addition
    a = 8'b0011_1010;  // 3.6250
    b = 8'b0100_0001;  // 4.0625
    c = a + b;         // 0111.1011 = 7.6875
    $display("%f + %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // addition overflow
    a = 8'b0110_1010;  // 6.6250
    b = 8'b0100_0001;  // 4.0625
    c = a + b;
    $display("%f + %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // subtraction
    a = 8'b0011_1010;  // 3.6250
    b = 8'b1110_1000;  // -1.5000
    c = a + b;         // 0010.0010 = 2.1250
    $display("%f + %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // multiplication
    a = 8'b0011_0100;  // 3.2500
    b = 8'b0010_0001;  // 2.0625
    ab = a * b;        // 00000110.10110100 = 6.703125
    c = ab[11:4];      // take middle 8 bits: 0110.1011 = 6.6875
    $display("%f x %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // division
    a = 8'b0111_1000;  // 7.5000
    b = 8'b0000_1000;  // 0.5000
    ab = a * b;        // 00000011.11000000 = 3.7500
    c = ab[11:4];      // take middle 8 bits: 0011.1100 = 3.7500
    $display("%f x %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // multiplication overflow
    a = 8'b0110_1000;  // 6.5000
    b = 8'b0100_0000;  // 4.0000
    ab = a * b;
    c = ab[11:4];      // take middle 8 bits
    $display("%f x %f = %f", $itor(a)*sf, $itor(b)*sf, $itor(c)*sf);

    // scaling
    a = 8'b0000_1100;  // 0.7500  (0.75 = 3/256 x 2^6)
    b = 8'b0111_0000;  // 7.0000
    ab = a * b;        // 00000101.01000000
    c = ab[11:4];      // take middle 8 bits: 0101.1010
    $display("%f", $itor(c)*2.0**-10.0);  // divide result by 2^10

end

reg signed [32:0] a1;
reg signed [32:0] b1;
reg signed [32:0] c1;
reg signed [32:0] ab1;  // large enough for product
localparam sf1 = 2.0**-16.0;  // Q4.4 scaling factor is 2^-4

initial
begin
    $display("\n=========================================\n");
    // converting to and from integers
    a1 = 32'b 10_1010; // decimal 42
    a1 = a1 << 16; // convert to Q16.16 notation by left shifting
    b1 = 32'b 10__1110_0000_0000_0000; // +2.875 in Q16.16 format
    c1 = a1 + b1;
    c1 = c1 >> 16; // don't need to mltiply with sf1
    $display("%f + %f = %f", $itor(a1)*sf1, $itor(b1)*sf1, $itor(c1));
end

endmodule
