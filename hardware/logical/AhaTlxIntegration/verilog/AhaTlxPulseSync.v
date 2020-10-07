//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Pulse Synchronizer Synchronizer for TLX
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxPulseSync (
  // Inputs
  input   wire  SRC_CLK,
  input   wire  SRC_RESETn,
  input   wire  DEST_CLK,
  input   wire  DEST_RESETn,

  input   wire  D,

  // Outputs
  output  wire  Q
);

  CW_pulse_sync #(
    .reg_event      (1),
    .f_sync_type    (2),
    .pulse_mode     (1)
    )
  u_aha_tlx_pulse_sync (
    .clk_s          (SRC_CLK),
    .rst_s_n        (SRC_RESETn),
    .init_s_n       (1'b1),
    .event_s        (D),
    .clk_d          (DEST_CLK),
    .rst_d_n        (DEST_RESETn),
    .init_d_n       (1'b1),
    .event_d        (Q),
    .test           (1'b0)
  );

endmodule
