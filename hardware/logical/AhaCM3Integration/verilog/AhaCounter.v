//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Simple Counter with Enable
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 12, 2020
//------------------------------------------------------------------------------
module AhaCounter #(parameter WIDTH = 8) (
  input   wire              CLK,
  input   wire              RESETn,
  input   wire              EN,
  output  wire [WIDTH-1:0]  Q
);

  reg [WIDTH-1:0] count_val;

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) count_val <= {WIDTH{1'b0}};
    else if(EN) count_val <= count_val + {{(WIDTH-1){1'b0}}, 1'b1};
  end

  assign Q = count_val;
endmodule
