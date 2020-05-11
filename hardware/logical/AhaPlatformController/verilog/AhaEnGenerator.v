//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Generator of Clock Enable Signals
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaEnGenerator (
  // Source Clock and Reset
  input   wire          CLK,
  input   wire          RESETn,

  // Clock Enable Signals
  output  wire          By2CLKEN,
  output  wire          By4CLKEN,
  output  wire          By8CLKEN,
  output  wire          By16CLKEN,
  output  wire          By32CLKEN
);

  reg [4:0] counter_r;

  reg       by2clk_en_r;
  reg       by4clk_en_r;
  reg       by8clk_en_r;
  reg       by16clk_en_r;
  reg       by32clk_en_r;

  // Counter
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) counter_r   <= 5'h0;
    else counter_r  <= counter_r + 1'b1;
  end

  // Enable Signals
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) begin
      by2clk_en_r   <= 1'b0;
      by4clk_en_r   <= 1'b0;
      by8clk_en_r   <= 1'b0;
      by16clk_en_r  <= 1'b0;
      by32clk_en_r  <= 1'b0;
    end else begin
      by2clk_en_r   <= counter_r[0]     == 1'b1;
      by4clk_en_r   <= counter_r[1:0]   == 2'b11;
      by8clk_en_r   <= counter_r[2:0]   == 3'b111;
      by16clk_en_r  <= counter_r[3:0]   == 4'hF;
      by32clk_en_r  <= counter_r[4:0]   == 5'h1F;
    end
  end

  // Output Clock Assignments
  assign By2CLKEN   = by2clk_en_r;
  assign By4CLKEN   = by4clk_en_r;
  assign By8CLKEN   = by8clk_en_r;
  assign By16CLKEN  = by16clk_en_r;
  assign By32CLKEN  = by32clk_en_r;

endmodule
