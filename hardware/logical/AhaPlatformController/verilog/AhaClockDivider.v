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
    .CLK        (CLK_IN),
    .Dn         (RESETn),
    .Qn         (reset_sync_n)
  );

  // Generated Clocks
  AhaFreqDivider u_aha_freq_divider (
    .CLK        (CLK_IN),
    .RESETn     (RESETn),

    .By2CLK     (clk_by_2_w),
    .By4CLK     (clk_by_4_w),
    .By8CLK     (clk_by_8_w),
    .By16CLK    (clk_by_16_w),
    .By32CLK    (clk_by_32_w)
  );

  // Enable Signals
  AhaEnGenerator u_aha_en_generator (
    .CLK        (CLK_IN),
    .RESETn     (RESETn),

    .By2CLKEN   (clk_by_2_en_w),
    .By4CLKEN   (clk_by_4_en_w),
    .By8CLKEN   (clk_by_8_en_w),
    .By16CLKEN  (clk_by_16_en_w),
    .By32CLKEN  (clk_by_32_en_w)
  );

  assign CLK_by_1       = CLK_IN;
  assign CLK_by_1_EN    = 1'b1;
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
