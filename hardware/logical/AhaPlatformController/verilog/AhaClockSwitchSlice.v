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
  reg     clk_sel_q;
  reg     clk_sel_qq;
  reg     clk_en_q;
  reg     clk_en_qq;

  always @ (negedge CLK) begin
    clk_sel_q     <= SELECT_REQ;
    clk_en_q      <= SELECT_REQ & ~OTHERS_SELECT;

    clk_sel_qq    <= clk_sel_q;
    clk_en_qq     <= clk_en_q;
  end

  assign CLK_OUT  = CLK & clk_en_qq;
  assign SELECT_ACK = clk_sel_qq;

endmodule
