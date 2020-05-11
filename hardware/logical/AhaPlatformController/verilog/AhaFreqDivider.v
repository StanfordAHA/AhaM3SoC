//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Frequency Divider Module
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 8, 2020
//------------------------------------------------------------------------------
module AhaFreqDivider (
  // Source Clock and Reset
  input   wire        CLK,
  input   wire        RESETn,

  // Divided Clocks
  output  wire        By2CLK,
  output  wire        By4CLK,
  output  wire        By8CLK,
  output  wire        By16CLK,
  output  wire        By32CLK
);

  // Counter register
  reg [4:0]   counter;

  // Generated Clocks
  reg         by2clk_r;
  reg         by4clk_r;
  reg         by8clk_r;
  reg         by16clk_r;
  reg         by32clk_r;

  // Counter
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) counter <= 5'h0;
    else counter <= counter + 1'b1;
  end

  // Clock Generation
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) begin
      by2clk_r    <= 1'b0;
      by4clk_r    <= 1'b0;
      by8clk_r    <= 1'b0;
      by16clk_r   <= 1'b0;
      by32clk_r   <= 1'b0;
    end else begin
      by2clk_r    <= ~counter[0];
      by4clk_r    <= ~counter[1];
      by8clk_r    <= ~counter[2];
      by16clk_r   <= ~counter[3];
      by32clk_r   <= ~counter[4];
    end
  end

  // Output Clock Assignments
  assign By2CLK   = by2clk_r;
  assign By4CLK   = by4clk_r;
  assign By8CLK   = by8clk_r;
  assign By16CLK  = by16clk_r;
  assign By32CLK  = by32clk_r;

endmodule /* AhaClockDivider */
