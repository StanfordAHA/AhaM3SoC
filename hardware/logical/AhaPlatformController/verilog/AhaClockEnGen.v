//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Clock Enable Generator
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockEnGen (
  input   wire          CLK_IN,
  input   wire          RESETn,
  input   wire [2:0]    DIV_FACTOR,
  output  wire          Q
);

  reg [4:0] counter;
  reg clk_en_r;
  reg clk_en_rr;

  reg [4:0] factor;

  always @(*) begin
    case (DIV_FACTOR)
      3'b000: factor = 5'h0;
      3'b001: factor = 5'h1;
      3'b010: factor = 5'h3;
      3'b011: factor = 5'h7;
      3'b100: factor = 5'hF;
      3'b101: factor = 5'h1F;
      default: factor = 5'h1F;
    endcase
  end

  always @(posedge CLK_IN or negedge RESETn) begin
    if(~RESETn) begin
      counter   <= 5'h0;
      clk_en_r  <= 1'b0;
    end
    else if(counter == factor) begin
      counter   <= 5'h0;
      clk_en_r  <= 1'b1;
    end
    else begin
      counter   <= counter + 1'b1;
      clk_en_r  <= 1'b0;
    end
  end

  always @(posedge CLK_IN or negedge RESETn) begin
    if(~RESETn) clk_en_rr   <= 1'b0;
    else clk_en_rr  <= clk_en_r;
  end

  assign Q = clk_en_rr;

endmodule
