//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Two-Flip Flop Reset Synchronizer
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaResetSync (
  // Inputs
  input   wire  CLK,
  input   wire  Dn,
  // Outputs
  output  wire  Qn
);

  reg sync_q;
  reg sync_qq;
  always @(posedge CLK or negedge Dn) begin
    if(~Dn) begin
      sync_q   <= 1'b0;
      sync_qq  <= 1'b0;
    end else begin
      sync_q   <= 1'b1;
      sync_qq  <= sync_q;
    end
  end
  assign Qn  = sync_qq;

endmodule
