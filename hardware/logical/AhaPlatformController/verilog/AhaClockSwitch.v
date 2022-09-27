//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : Glitch-free Clock Switch
//------------------------------------------------------------------------------
// Author   : Gedeon Nyengele
// Date     : April 17, 2020
//------------------------------------------------------------------------------
// Updates:
//  - September 27, 2022
//      - Added 2-FF synchronizer at the input stage (allows to write timing
//          exception constraints)
//------------------------------------------------------------------------------

module AhaClockSwitch (
    // Clock Signals
    input   wire        CLK,
    input   wire        CLK_EN,

    // State of Other Clock Signals
    input   wire        ALT_CLK_EN1,
    input   wire        ALT_CLK_EN2,
    input   wire        ALT_CLK_EN3,
    input   wire        ALT_CLK_EN4,
    input   wire        ALT_CLK_EN5,

    // Selector Lines
    input   wire [2:0]  SELECT_REQ,
    input   wire [2:0]  SELECT_VAL,

    // Output Clock Signals
    output  wire        CLK_OUT,
    output  wire        CLK_EN_OUT,
    output  wire        SELECT_ACK
);

    //
    // Internal Signals
    //

    wire                w_SEL;
    wire                w_OTHERS_SEL;

    reg                 r_EN_STAGE0_SYNC;
    reg                 r_EN_STATEG1;
    reg                 r_EN;
    wire                w_CLK_OUT;

    //
    // Clock Selection Conditions
    //

    assign w_SEL        = {1{SELECT_REQ == SELECT_VAL}};
    assign w_OTHERS_SEL = ALT_CLK_EN1 | ALT_CLK_EN2 | ALT_CLK_EN3 | ALT_CLK_EN4 | ALT_CLK_EN5;

    //
    // Clock Selection Input Stages (Synchronization)
    //

    always @(posedge CLK) begin
        r_EN_STAGE0_SYNC    <= w_SEL & ~w_OTHERS_SEL;
        r_EN_STATEG1        <= r_EN_STAGE0_SYNC;
    end

    //
    // Clock Selection Output Stage (Clock Gating)
    //

    always @(negedge CLK)
        r_EN    <= r_EN_STATEG1;

    AhaClockGate u_clock_gate_CLK (
        .TE     (1'b0),
        .E      (r_EN),
        .CP     (CLK),
        .Q      (w_CLK_OUT)
    );

    //
    // Output Assignments
    //

    assign CLK_OUT          = w_CLK_OUT;
    assign CLK_EN_OUT       = CLK_EN & r_EN;
    assign SELECT_ACK       = r_EN;
endmodule
