//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Glitch-Free Clock Selector
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockSelector (
  // Inputs
  input   wire          CLK_by_1,       // CLK/1
  input   wire          CLK_by_1_EN,    // Clock Enable Toggle Divider
  input   wire          CLK_by_2,       // CLK/2
  input   wire          CLK_by_2_EN,    // Clock Enable Toggle Divider
  input   wire          CLK_by_4,       // CLK/4
  input   wire          CLK_by_4_EN,    // Clock Enable Toggle Divider
  input   wire          CLK_by_8,       // CLK/8
  input   wire          CLK_by_8_EN,    // Clock Enable Toggle Divider
  input   wire          CLK_by_16,      // CLK/16
  input   wire          CLK_by_16_EN,   // Clock Enable Toggle Divider
  input   wire          CLK_by_32,      // CLK/32
  input   wire          CLK_by_32_EN,   // Clock Enable Toggle Divider

  input   wire          RESETn,         // Reset
  input   wire [2:0]    SELECT,         // Clock Selector

  // Outputs
  output  wire          CLK_OUT,        // Glick-Free Clock Output
  output  wire          CLK_EN_OUT      // Glitch-Free Clock Enable Output
);

  // Glitch Removal
  wire  clk_by_1_gfree_w;
  wire  clk_by_1_en_gfree_w;
  wire  clk_by_2_gfree_w;
  wire  clk_by_2_en_gfree_w;
  wire  clk_by_4_gfree_w;
  wire  clk_by_4_en_gfree_w;
  wire  clk_by_8_gfree_w;
  wire  clk_by_8_en_gfree_w;
  wire  clk_by_16_gfree_w;
  wire  clk_by_16_en_gfree_w;
  wire  clk_by_32_gfree_w;
  wire  clk_by_32_en_gfree_w;

  wire  by_1_en_w;
  wire  by_2_en_w;
  wire  by_4_en_w;
  wire  by_8_en_w;
  wire  by_16_en_w;
  wire  by_32_en_w;

  // By_1 Clock
  AhaClockSwitch u_clk_by_1 (
    .CLK_IN           (CLK_by_1),
    .CLK_EN_IN        (CLK_by_1_EN),

    .ALT_CLK_EN1      (by_2_en_w),
    .ALT_CLK_EN2      (by_4_en_w),
    .ALT_CLK_EN3      (by_8_en_w),
    .ALT_CLK_EN4      (by_16_en_w),
    .ALT_CLK_EN5      (by_32_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b000),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_1_gfree_w),
    .CLK_EN_OUT       (clk_by_1_en_gfree_w),
    .EN               (by_1_en_w)
  );

  // By_2 Clock
  AhaClockSwitch u_clk_by_2 (
    .CLK_IN           (CLK_by_2),
    .CLK_EN_IN        (CLK_by_2_EN),

    .ALT_CLK_EN1      (by_1_en_w),
    .ALT_CLK_EN2      (by_4_en_w),
    .ALT_CLK_EN3      (by_8_en_w),
    .ALT_CLK_EN4      (by_16_en_w),
    .ALT_CLK_EN5      (by_32_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b001),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_2_gfree_w),
    .CLK_EN_OUT       (clk_by_2_en_gfree_w),
    .EN               (by_2_en_w)
  );

  // By_4 Clock
  AhaClockSwitch u_clk_by_4 (
    .CLK_IN           (CLK_by_4),
    .CLK_EN_IN        (CLK_by_4_EN),

    .ALT_CLK_EN1      (by_1_en_w),
    .ALT_CLK_EN2      (by_2_en_w),
    .ALT_CLK_EN3      (by_8_en_w),
    .ALT_CLK_EN4      (by_16_en_w),
    .ALT_CLK_EN5      (by_32_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b010),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_4_gfree_w),
    .CLK_EN_OUT       (clk_by_4_en_gfree_w),
    .EN               (by_4_en_w)
  );

  // By_8 Clock
  AhaClockSwitch u_clk_by_8 (
    .CLK_IN           (CLK_by_8),
    .CLK_EN_IN        (CLK_by_8_EN),

    .ALT_CLK_EN1      (by_1_en_w),
    .ALT_CLK_EN2      (by_2_en_w),
    .ALT_CLK_EN3      (by_4_en_w),
    .ALT_CLK_EN4      (by_16_en_w),
    .ALT_CLK_EN5      (by_32_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b011),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_8_gfree_w),
    .CLK_EN_OUT       (clk_by_8_en_gfree_w),
    .EN               (by_8_en_w)
  );

  // By_16 Clock
  AhaClockSwitch u_clk_by_16 (
    .CLK_IN           (CLK_by_16),
    .CLK_EN_IN        (CLK_by_16_EN),

    .ALT_CLK_EN1      (by_1_en_w),
    .ALT_CLK_EN2      (by_2_en_w),
    .ALT_CLK_EN3      (by_4_en_w),
    .ALT_CLK_EN4      (by_8_en_w),
    .ALT_CLK_EN5      (by_32_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b100),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_16_gfree_w),
    .CLK_EN_OUT       (clk_by_16_en_gfree_w),
    .EN               (by_16_en_w)
  );

  // By_32 Clock
  AhaClockSwitch  u_clk_by_32 (
    .CLK_IN           (CLK_by_32),
    .CLK_EN_IN        (CLK_by_32_EN),

    .ALT_CLK_EN1      (by_1_en_w),
    .ALT_CLK_EN2      (by_2_en_w),
    .ALT_CLK_EN3      (by_4_en_w),
    .ALT_CLK_EN4      (by_8_en_w),
    .ALT_CLK_EN5      (by_16_en_w),
    .SELECT           (SELECT),
    .SELECT_VAL       (3'b101),
    .RESETn           (RESETn),

    .CLK_OUT          (clk_by_32_gfree_w),
    .CLK_EN_OUT       (clk_by_32_en_gfree_w),
    .EN               (by_32_en_w)
  );

  assign CLK_OUT =      clk_by_1_gfree_w |
                        clk_by_2_gfree_w |
                        clk_by_4_gfree_w |
                        clk_by_8_gfree_w |
                        clk_by_16_gfree_w |
                        clk_by_32_gfree_w;

  assign CLK_EN_OUT =   clk_by_1_en_gfree_w |
                        clk_by_2_en_gfree_w |
                        clk_by_4_en_gfree_w |
                        clk_by_8_en_gfree_w |
                        clk_by_16_en_gfree_w |
                        clk_by_32_en_gfree_w;
endmodule
