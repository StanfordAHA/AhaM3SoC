//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Glitch-free Clock Switch
//------------------------------------------------------------------------------
//
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 22, 2022  : removed clock enables
//------------------------------------------------------------------------------

module AhaClockSwitch (
  // Inputs
  input   wire        CLK,

  input   wire        ALT_CLK_EN1,
  input   wire        ALT_CLK_EN2,
  input   wire        ALT_CLK_EN3,
  input   wire        ALT_CLK_EN4,
  input   wire        ALT_CLK_EN5,
  input   wire [2:0]  SELECT_REQ,
  input   wire [2:0]  SELECT_VAL,

  // Outputs
  output  wire        CLK_OUT,
  output  wire        SELECT_ACK
);

  // Internal
  reg     clk_sel;
  reg     clk_en;

  // Select Condition
  wire    clk_sel_cond = SELECT_REQ == SELECT_VAL;
  wire    others_sel =  ALT_CLK_EN1 | ALT_CLK_EN2 | ALT_CLK_EN3 |
                        ALT_CLK_EN4 | ALT_CLK_EN5;

  always @ (negedge CLK) begin
    clk_sel   <= clk_sel_cond;
    clk_en    <= clk_sel_cond & ~others_sel;
  end

  assign CLK_OUT      = CLK & clk_en;
  assign SELECT_ACK   = clk_sel;

endmodule
