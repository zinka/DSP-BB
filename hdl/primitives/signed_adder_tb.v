/*
******************************************************************************
* @file    : signed_adder_tb.v
* @project : DSP Building Blocks
* @brief   : Verilog testbench for signed_adder.v
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
******************************************************************************
* This program is hereby granted to the public domain.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
* FITNESS FOR A PARTICULAR PURPOSE.
******************************************************************************
*/

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

/*
***************************************************************************
* testbench
***************************************************************************
*/

module signed_adder_tb; 

localparam period = 10; // clock period

/*
***************************************************************************
* dump vcd file, monitor values, and define finish time
***************************************************************************
*/

initial 
begin
$dumpfile("dump.vcd");
// $dumpvars(0, value, clk, reset);
$dumpvars;
// $monitor("t =%d: o_cnt =%d\n", $time, o_cnt);
$display("=============================================\n");
#(20*period) $finish; // run for 20 clock cycles
end

/*
***************************************************************************
* clock
***************************************************************************
*/

reg i_clk = 0;
always #(period/2) i_clk = !i_clk;

/*
***************************************************************************
* module instantiation
***************************************************************************
*/

// local parameters
localparam AWIDTH = 4, BWIDTH = 3;
localparam	OUTWID = (AWIDTH > BWIDTH) ? (AWIDTH + 1) : (BWIDTH+1);

// module inputs
reg signed [AWIDTH-1:0] i_a = -8;
reg signed [BWIDTH-1:0] i_b = -4;

// module outputs
wire signed [OUTWID-1:0] o_sum;

// module instantiation
signed_adder u_signed_adder (
  .i_a (i_a),
	.i_b (i_b),
	.o_sum (o_sum)
);

/*
***************************************************************************
* module stimuli (random)
***************************************************************************
*/

integer seed = 10;

initial
repeat(40) @(posedge i_clk)
begin 
  i_a = $random % 20;
  i_b = $random % 4; 
end

/*
***************************************************************************
* display in terminal
***************************************************************************
*/

initial $monitor("a:%0d, b:%0d, sum:%0d\n", i_a, i_b, o_sum);
    
endmodule