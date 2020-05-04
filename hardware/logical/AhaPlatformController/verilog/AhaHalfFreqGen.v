//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Clock Divider by 2
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaHalfFreqGen (
  input   wire          CLK_IN,
  input   wire          RESETn,
  output  wire          Q
);
  reg clk_div_dff;

  always @(posedge CLK_IN or negedge RESETn) begin
    if(~RESETn) clk_div_dff <= 1'b0;
    else clk_div_dff <= ~clk_div_dff;
  end

  assign Q = clk_div_dff;

endmodule
