//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Glitch-free Clock Switch Slice
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 22, 2020
//------------------------------------------------------------------------------
module AhaClockSwitchSlice (
  // Inputs
  input   wire        CLK,
  input   wire        SELECT_REQ,

  // Others
  input   wire        OTHERS_SELECT,

  // Outputs
  output  wire        CLK_OUT,
  output  wire        SELECT_ACK
);

  // Internal
  reg     clk_sel;
  reg     clk_en;

  always @ (negedge CLK) begin
    clk_sel   <= SELECT_REQ;
    clk_en    <= SELECT_REQ & ~OTHERS_SELECT;
  end

  assign CLK_OUT  = CLK & clk_en;
  assign SELECT_ACK = clk_sel;

endmodule
