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
  input   wire        PORESETn,

  input   wire        SELECT,

  // Outputs
  output  wire        CLK_OUT
);

  // Internal
  reg     master_clk0_enable;
  reg     master_clk1_enable;

  wire    master_clk0_reset_n;
  wire    master_clk1_reset_n;

  // Reset Synchronizers
  AhaResetSync master_clk0_poreset_sync (
    .CLK    (~MASTER_CLK0),
    .Dn     (PORESETn),
    .Qn     (master_clk0_reset_n)
  );

  AhaResetSync master_clk1_poreset_sync (
    .CLK    (~MASTER_CLK1),
    .Dn     (PORESETn),
    .Qn     (master_clk1_reset_n)
  );

  // CLK0 Enable
  always @(negedge MASTER_CLK0 or negedge master_clk0_reset_n) begin
    if(~master_clk0_reset_n)  master_clk0_enable <= 1'b0;
    else master_clk0_enable   <= ~SELECT & ~master_clk1_enable;
  end

  // CLK1 Enable
  always @(negedge MASTER_CLK1 or negedge master_clk1_reset_n) begin
    if(~master_clk1_reset_n)  master_clk1_enable <= 1'b0;
    else master_clk1_enable   <= SELECT & ~master_clk0_enable;
  end

  assign CLK_OUT  = (MASTER_CLK0 & master_clk0_enable) | (MASTER_CLK1 & master_clk1_enable);

endmodule
