/*
******************************************************************************
* @file    : sin_table.v
* @project : DSP Building Blocks
* @brief   : A very simple sine wave generator using LUT
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
* @notes   : based on https://zipcpu.com/dsp/2017/07/11/simplest-sinewave-generator.html
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

`timescale 1ns/1ns
`default_nettype none

module sin_table #(
           parameter PW = 17, // Number of bits in the input phase
           parameter OW = 13  // Number of output bits
       ) (
           input  wire            i_clk  ,
           input  wire            i_reset,
           input  wire            i_ce   ,
           input  wire            i_aux  ,
           input  wire [(PW-1):0] i_phase,
           output reg  [(OW-1):0] o_val  ,
           output reg             o_aux
       );

/*
***************************************************************************
* main code
***************************************************************************
*/

reg [(OW-1):0] tbl[0:((1<<PW)-1)]; // infer BRAM, 2^PW elements of OW width

initial	$readmemh("sintable.hex", tbl); // init BRAM

initial o_val = 1;
always @(posedge i_clk)
    if (i_reset)
        o_val <= 0;
    else if (i_ce)
        o_val <= tbl[i_phase];

initial o_aux = 0;
always @(posedge i_clk)
    if (i_reset)
        o_aux <= 0;
    else if (i_ce)
        o_aux <= i_aux;

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

reg f_past_valid = 1'b0;
always @(posedge i_clk)
begin
	f_past_valid <= 1'b1;
end

// selecting from a set of tests
localparam [2:0] FORMAL_TEST = 3'b001;

generate

	// simple alternative to testbench
	if (FORMAL_TEST == 3'b000)
	begin
		always @(posedge i_clk)
		begin
		end
	end

	// asserting ""
	else if (FORMAL_TEST == 3'b001)
	begin
		always @(posedge i_clk)
		begin
		end
	end

	// asserting ""
	else if (FORMAL_TEST == 3'b010)
	begin
		always @(posedge i_clk)
		begin
		end
	end

	// asserting ""
	else if (FORMAL_TEST == 3'b011)
	begin
		always @(posedge i_clk)
		begin
		end
	end

endgenerate

`endif  // FORMAL  

endmodule

    /* verilator lint_on UNUSED */
