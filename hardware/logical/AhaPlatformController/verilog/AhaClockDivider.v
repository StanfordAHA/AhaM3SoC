//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Clock Divider
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockDivider (
  // Inputs
  input   wire          CLK_IN,
  input   wire          RESETn,

  // Outputs
  output  wire          CLK_by_1,
  output  wire          CLK_by_1_EN,
  output  wire          CLK_by_2,
  output  wire          CLK_by_2_EN,
  output  wire          CLK_by_4,
  output  wire          CLK_by_4_EN,
  output  wire          CLK_by_8,
  output  wire          CLK_by_8_EN,
  output  wire          CLK_by_16,
  output  wire          CLK_by_16_EN,
  output  wire          CLK_by_32,
  output  wire          CLK_by_32_EN
);
  // Generated Clocks
  wire  clk_by_1_w;
  wire  clk_by_1_en_w;
  wire  clk_by_2_w;
  wire  clk_by_2_en_w;
  wire  clk_by_4_w;
  wire  clk_by_4_en_w;
  wire  clk_by_8_w;
  wire  clk_by_8_en_w;
  wire  clk_by_16_w;
  wire  clk_by_16_en_w;
  wire  clk_by_32_w;
  wire  clk_by_32_en_w;

  // Reset Synchonization
  wire  reset_sync_n;
  AhaResetSync u_rst_sync (
    .CLK    (CLK_IN),
    .Dn     (RESETn),
    .Qn     (reset_sync_n)
  );

  // By 1 clock
  assign clk_by_1_w     = CLK_IN;
  AhaClockEnGen clk_by_1_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b000),
    .Q          (clk_by_1_en_w)
  );

  // By 2 Clock
  AhaHalfFreqGen clk_by_2_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .Q          (clk_by_2_w)
  );
  AhaClockEnGen clk_by_2_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b001),
    .Q          (clk_by_2_en_w)
  );

  // By 4 Clock
  AhaHalfFreqGen clk_by_4_gen (
    .CLK_IN     (clk_by_2_w),
    .RESETn     (reset_sync_n),
    .Q          (clk_by_4_w)
  );
  AhaClockEnGen clk_by_4_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b010),
    .Q          (clk_by_4_en_w)
  );

  // By 8 Clock
  AhaHalfFreqGen clk_by_8_gen (
    .CLK_IN     (clk_by_4_w),
    .RESETn     (reset_sync_n),
    .Q          (clk_by_8_w)
  );
  AhaClockEnGen clk_by_8_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b011),
    .Q          (clk_by_8_en_w)
  );

  // By 16 Clock
  AhaHalfFreqGen clk_by_16_gen (
    .CLK_IN     (clk_by_8_w),
    .RESETn     (reset_sync_n),
    .Q          (clk_by_16_w)
  );
  AhaClockEnGen clk_by_16_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b100),
    .Q          (clk_by_16_en_w)
  );

  // By 32 Clock
  AhaHalfFreqGen clk_by_32_gen (
    .CLK_IN     (clk_by_16_w),
    .RESETn     (reset_sync_n),
    .Q          (clk_by_32_w)
  );
  AhaClockEnGen clk_by_32_en_gen (
    .CLK_IN     (CLK_IN),
    .RESETn     (reset_sync_n),
    .DIV_FACTOR (3'b101),
    .Q          (clk_by_32_en_w)
  );

  assign CLK_by_1       = clk_by_1_w;
  assign CLK_by_1_EN    = clk_by_1_en_w;
  assign CLK_by_2       = clk_by_2_w;
  assign CLK_by_2_EN    = clk_by_2_en_w;
  assign CLK_by_4       = clk_by_4_w;
  assign CLK_by_4_EN    = clk_by_4_en_w;
  assign CLK_by_8       = clk_by_8_w;
  assign CLK_by_8_EN    = clk_by_8_en_w;
  assign CLK_by_16      = clk_by_16_w;
  assign CLK_by_16_EN   = clk_by_16_en_w;
  assign CLK_by_32      = clk_by_32_w;
  assign CLK_by_32_EN   = clk_by_32_en_w;
endmodule
