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
module AhaClockSwitch (
  // Inputs
  input   wire        CLK_IN,
  input   wire        CLK_EN_IN,

  input   wire        ALT_CLK_EN1,
  input   wire        ALT_CLK_EN2,
  input   wire        ALT_CLK_EN3,
  input   wire        ALT_CLK_EN4,
  input   wire        ALT_CLK_EN5,
  input   wire [2:0]  SELECT,
  input   wire [2:0]  SELECT_VAL,
  input   wire        RESETn,

  // Outputs
  output  wire        CLK_OUT,
  output  wire        CLK_EN_OUT,
  output  wire        EN
);

  reg   clk_en_r;
  wire  reset_n_w;
  wire  select_clk;

  // synchronize reset de-assertion
  AhaResetSync u_rst_sync (
    .CLK    (~CLK_IN),
    .Dn     (RESETn),
    .Qn     (reset_n_w)
  );

  always @(negedge CLK_IN or negedge reset_n_w) begin
    if(~reset_n_w) clk_en_r  <= 1'b0;
    else clk_en_r <=  select_clk &
                      (~ALT_CLK_EN1) &
                      (~ALT_CLK_EN2) &
                      (~ALT_CLK_EN3) &
                      (~ALT_CLK_EN4) &
                      (~ALT_CLK_EN5);
  end

  assign select_clk = SELECT == SELECT_VAL;

  assign CLK_OUT      = CLK_IN & clk_en_r;
  assign CLK_EN_OUT   = CLK_EN_IN & clk_en_r;  
  assign EN = clk_en_r;

endmodule
