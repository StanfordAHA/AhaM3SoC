//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Two-Flip Flop Data Synchronizer
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaDataSync (
  // Inputs
  input   wire  CLK,
  input   wire  RESETn,
  input   wire  D,
  // Outputs
  output  wire  Q
);

  reg sync_q;
  reg sync_qq;
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) begin
      sync_q   <= 1'b0;
      sync_qq  <= 1'b0;
    end else begin
      sync_q   <= D;
      sync_qq  <= sync_q;
    end
  end
  assign Q = sync_qq;

endmodule
