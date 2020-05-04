//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Synchronous Pulse Generator
//-----------------------------------------------------------------------------
// Input D is in the destination clock domain
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//-----------------------------------------------------------------------------
module AhaSyncPulseGen (
  input   wire    CLK,
  input   wire    RESETn,
  input   wire    D,
  output  wire    RISE_PULSE,
  output  wire    FALL_PULSE
);

  reg d_r;

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) d_r <= 1'b0;
    else d_r <= D;
  end

  assign RISE_PULSE = D & ~d_r;
  assign FALL_PULSE = ~D & d_r;

endmodule
