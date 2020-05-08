//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Two-Flip Flop Data Synchronizer for TLX
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxDataSync #(
  parameter WIDTH = 1
  )(
  // Inputs
  input   wire              SRC_CLK,
  input   wire              SRC_RESETn,
  input   wire              DEST_CLK,
  input   wire              DEST_RESETn,

  input   wire  [WIDTH-1:0] D,

  // Outputs
  output  wire  [WIDTH-1:0] Q
);

  DW_data_sync #(
    .width          (WIDTH),
    .pend_mode      (1),
    .ack_delay      (1),
    .f_sync_type    (2),
    .r_sync_type    (2),
    .send_mode      (0)
    )
  u_aha_tlx_data_sync (
    .clk_s          (SRC_CLK),
    .rst_s_n        (SRC_RESETn),
    .init_s_n       (1'b1),
    .send_s         (1'b1),
    .data_s         (D),
    .empty_s        (),
    .full_s         (),
    .done_s         (),
    .clk_d          (DEST_CLK),
    .rst_d_n        (DEST_RESETn),
    .init_d_n       (1'b1),
    .data_avail_d   (),
    .data_d         (Q),
    .test           (1'b0)
  );

endmodule
