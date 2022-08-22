//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Clock Divider
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 22, 2022  :
//          - moved reset synchronizer externally
//          - removed clock enable generation
//------------------------------------------------------------------------------

module AhaClockDivider (
  // Inputs
  input   wire          CLK_IN,
  input   wire          RESETn,

  // Outputs
  output  wire          CLK_by_1,
  output  wire          CLK_by_2,
  output  wire          CLK_by_4,
  output  wire          CLK_by_8,
  output  wire          CLK_by_16,
  output  wire          CLK_by_32
);
  // Generated Clocks
  wire                  clk_by_1_w;
  wire                  clk_by_2_w;
  wire                  clk_by_4_w;
  wire                  clk_by_8_w;
  wire                  clk_by_16_w;
  wire                  clk_by_32_w;

  // Generated Clocks
  AhaFreqDivider u_aha_freq_divider (
    .CLK                (CLK_IN),
    .RESETn             (RESETn),

    .By1CLK             (clk_by_1_w),
    .By2CLK             (clk_by_2_w),
    .By4CLK             (clk_by_4_w),
    .By8CLK             (clk_by_8_w),
    .By16CLK            (clk_by_16_w),
    .By32CLK            (clk_by_32_w)
  );

  assign CLK_by_1       = clk_by_1_w;
  assign CLK_by_2       = clk_by_2_w;
  assign CLK_by_4       = clk_by_4_w;
  assign CLK_by_8       = clk_by_8_w;
  assign CLK_by_16      = clk_by_16_w;
  assign CLK_by_32      = clk_by_32_w;
endmodule
