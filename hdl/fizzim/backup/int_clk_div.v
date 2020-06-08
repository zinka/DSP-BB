/*
 ******************************************************************************
 * @file    : int_clk_div.v
 * @project : DSP Building Blocks
 * @brief   : A simple clock divider (integer divide approach)
 * @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
 ******************************************************************************
* This code is licensed under the MIT License.
 ******************************************************************************
 */

`timescale 1ns/1ns
`default_nettype none

module int_clk_div #(parameter COUNTER_WID = 5'd19,
                     parameter HALF_CLOCK_STRECH = 19'd4)
       (output reg o_clk,                    // stretched output clock
        input wire i_ce,                     // component enable
        input wire i_clk,                    // clock
        input wire i_rstn);                  // active low reset

/*
 ***************************************************************************
 * state machine
 ***************************************************************************
 */

// state indices
localparam
    RESET = 2'b00,
    IDLE = 2'b01,
    START = 2'b10;

// state registers
reg [1:0] state;
reg [1:0] nextstate;

// local registers
reg [(COUNTER_WID-1):0] counter; // counter for stretching
reg o_clk_stb;                   // strobe for o_clk

// initial values
initial counter[(COUNTER_WID-1):0] = 0;
initial o_clk                      = 1'b0;
initial o_clk_stb                  = 1'b0;
initial state                      = RESET;

// comb always block
// verilator lint_off CASEINCOMPLETE
always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
        RESET: if (i_ce)   nextstate = START;
        IDLE : if (i_ce)   nextstate = START;
        START: if (!i_ce)  nextstate = IDLE;
    endcase
end
// verilator lint_on CASEINCOMPLETE

// state sequential always block
always @(posedge i_clk) begin
    if (!i_rstn)
        state <= RESET;
    else
        state <= nextstate;
end

// datapath sequential always block
// verilator lint_off CASEINCOMPLETE
always @(posedge i_clk) begin
    if (!i_rstn) begin
        counter[(COUNTER_WID-1):0] <= 0;
        o_clk                      <= 1'b0;
        o_clk_stb                  <= 1'b0;
    end
    else begin
        counter[(COUNTER_WID-1):0] <= o_clk_stb? 0 : (counter + 1'b1); // default
        o_clk                      <= o_clk_stb? (!o_clk) : o_clk;     // default
        o_clk_stb <= (counter == (HALF_CLOCK_STRECH-2));               // default
        case (nextstate)
            RESET: begin
                counter[(COUNTER_WID-1):0] <= 0;
                o_clk                      <= 1'b0;
                o_clk_stb                  <= 1'b0;
            end
            IDLE : begin
                counter[(COUNTER_WID-1):0] <= counter;
                o_clk                      <= o_clk;
                o_clk_stb                  <= o_clk_stb;
            end
        endcase
    end
end
// verilator lint_on CASEINCOMPLETE

// This code allows you to see state names in simulation
// verilator lint_off UNUSED
`ifndef SYNTHESIS
        reg [39:0] statename;
always @* begin
    case (state)
        RESET:   statename = "RESET";
        IDLE :   statename = "IDLE";
        START:   statename = "START";
        default: statename = "XXXXX";
    endcase
end
`endif
// verilator lint_on UNUSED

// fizzim code generation ends

/*
 ***************************************************************************
 * user code
 ***************************************************************************
 */

`ifdef  FORMAL

`ifdef  INT_CLK_DIV
`define ASSUME  assume
`else
`define ASSUME  assume
`endif

//________________________________________________________
// cover statements

reg [3:0] f_clk_cnt = 0;
always @(posedge i_clk)
begin
    `ASSUME(i_ce && i_rstn);
    if (counter == (HALF_CLOCK_STRECH-1)) f_clk_cnt <= f_clk_cnt +1;
    if (f_clk_cnt == 5)
        // simple alternative to testbench
        cover((counter == (HALF_CLOCK_STRECH-1)) && o_clk);
end

//________________________________________________________
// assumptions about inputs

reg f_past_valid;
initial f_past_valid = 1'b0;
always @(posedge i_clk) f_past_valid <= 1'b1;

always @(posedge i_clk)
    if (f_past_valid)
    begin
    end

//________________________________________________________
// asserting reset condition/state

always @(posedge i_clk)
    if ((!f_past_valid)||($past(!i_rstn)))
    begin
        assert(o_clk == 0);
        assert(counter == 0);
        assert(state == RESET);
    end

//________________________________________________________
// assertions about outputs

always @(posedge i_clk)
begin

    //________________________________________________________
    // irrespective of STATE

    // always in a known state
    assert(state<3);

    // o_clk doesn't changes if i_ce == 0 (except when we reset)
    if (f_past_valid && $past(!i_ce) && $past(i_rstn)) assert($stable(o_clk));

    // counter doesn't changes if i_ce == 0 (except when we reset)
    if (f_past_valid && $past(!i_ce) && $past(i_rstn)) assert($stable(counter));

    //________________________________________________________
    // STATE wise

    case(state)
        RESET   : begin
            assert(counter == 0 && o_clk == 0); // asserting reset values
        end
        IDLE    : begin
            assert($stable(o_clk) && $stable(counter)); // no changes
        end
        START   : begin
            assert(!($stable(counter))); // counter always changes
            if (counter == 0) assert(!($stable(o_clk))); // o_clk changes when counter = 0
            else assert(($stable(o_clk))); // otherwise o_clk is stable
        end
        default : assert(0); // you are not supposed to come here!
    endcase

end

//________________________________________________________
// selecting from a set of tests

localparam [2:0]	FORMAL_TEST = 3'b001;

generate

    if (FORMAL_TEST == 3'b000)
    begin
        always @(*)
            `ASSUME(i_ce);
    end

    else if (FORMAL_TEST == 3'b001)
    begin
    end

endgenerate

`endif  // FORMAL

endmodule
