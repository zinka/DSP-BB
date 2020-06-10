/*
******************************************************************************
* @file    : sin_table_tb.v
* @project : DSP Building Blocks
* @brief   : Verilog testbench for sin_table_tb.v
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

`include "dsp/wave_generators/sin_table.v"
`timescale 1ns/1ns
`default_nettype none

/*
***************************************************************************
* testbench
***************************************************************************
*/

module sin_table_tb;

localparam period = 10; // clock period

/*
***************************************************************************
* dump vcd file, monitor values, and define finish time
***************************************************************************
*/

initial
begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // $dumpvars(0, value, clk, reset);
    $display("=============================================\n");
    #(200000*period) $finish; // run for 20 clock cycles
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
localparam PW = 17, OW = 13;

// module inputs
// reg i_clk;
reg i_reset=0;
reg i_ce = 1;
reg i_aux = 1;
reg [(PW-1):0] i_phase = 0;

// module outputs
wire signed o_aux;
wire signed [(OW-1):0] o_val;

// module instantiation
sin_table u_sin_table (
              .i_clk  (i_clk  ),
              .i_reset(i_reset),
              .i_ce   (i_ce   ),
              .i_aux  (i_aux  ),
              .i_phase(i_phase),
              .o_val  (o_val  ),
              .o_aux  (o_aux)
          );

/*
***************************************************************************
* module stimuli
***************************************************************************
*/

initial
    repeat(1000000) @(negedge i_clk)
    begin
        i_phase = i_phase+1;
    end    

/*
***************************************************************************
* display in terminal
***************************************************************************
*/

initial $monitor("phase:%0h, o_val:%0h\n", i_phase, o_val);

endmodule
