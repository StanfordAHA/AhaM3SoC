//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Asynchronous Pulse Generator
//-----------------------------------------------------------------------------
// Input D is from a different clock domain
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//-----------------------------------------------------------------------------
module AhaAsyncPulseGen (
  input   wire    CLK,
  input   wire    RESETn,
  input   wire    D,
  output  wire    RISE_PULSE,
  output  wire    FALL_PULSE
);

  wire  d_sync;
  reg   d_r;

  AhaDataSync u_data_sync (
    .CLK      (CLK),
    .RESETn   (RESETn),
    .D        (D),
    .Q        (d_sync)
  );

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) d_r <= 1'b0;
    else d_r <= d_sync;
  end

  assign RISE_PULSE = d_sync & ~d_r;
  assign FALL_PULSE = ~d_sync & d_r;

endmodule
