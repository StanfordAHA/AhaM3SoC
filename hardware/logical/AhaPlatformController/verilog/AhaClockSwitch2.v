//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Glitch-free Clock Switch
//------------------------------------------------------------------------------
//
// Based on "Glitch Free Clock Switching Techniques in Modern Microcontrollers"
//        by Borisav Jovanović, Milunka Damnjanović
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockSwitch2 (
  // Inputs
  input   wire        MASTER_CLK0,
  input   wire        MASTER_CLK1,

  input   wire        SELECT,

  // Outputs
  output  wire        CLK_OUT
);

  wire  m0_clk;
  wire  m1_clk;

  wire  m0_sel;
  wire  m1_sel;

  AhaClockSwitchSlice u_m0_clk_switch_slice (
    .CLK              (MASTER_CLK0),
    .SELECT_REQ       (~SELECT),
    .OTHERS_SELECT    (m1_sel),

    .CLK_OUT          (m0_clk),
    .SELECT_ACK       (m0_sel)
  );

  AhaClockSwitchSlice u_m1_clk_switch_slice (
    .CLK              (MASTER_CLK1),
    .SELECT_REQ       (SELECT),
    .OTHERS_SELECT    (m0_sel),

    .CLK_OUT          (m1_clk),
    .SELECT_ACK       (m1_sel)
  );

  assign CLK_OUT = m0_clk | m1_clk;

endmodule
