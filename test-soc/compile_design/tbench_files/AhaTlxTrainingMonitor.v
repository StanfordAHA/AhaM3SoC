//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Single Lane Input/Output Monitor for TLX Traning
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxTrainingMonitor (
    input   wire            FWD_CLK,
    input   wire            FWD_RESETn,

    input   wire            REV_CLK,
    input   wire            REV_RESETn,

    input   wire            OE,         // Output Enable (on Reverse Channel)

    input   wire            FWD_DATA_IN,
    input   wire            REV_DATA_IN,
    output  wire            REV_DATA_OUT
);

  localparam [31:0] MAGIC_SEQUENCE = 32'h5A6B7C8D;

  wire [31:0] match_count;
  reg  [31:0] rev_sequence;
  reg         start_fwd;
  reg         start_rev;

  // start fwd:
  initial begin
    start_fwd = 1'b0;
    @(posedge FWD_RESETn);
    repeat(10) @(posedge FWD_CLK);
    #1 start_fwd = 1'b1;
    @(posedge FWD_CLK)
    #1 start_fwd = 1'b0;
  end

  // start start_rev:
  initial begin
    start_rev = 1'b0;
    @(posedge REV_RESETn);
    repeat(10) @(posedge REV_CLK);
    #1 start_rev = 1'b1;
    @(posedge REV_CLK)
    #1 start_rev = 1'b0;
  end

  always @(posedge REV_CLK or negedge REV_RESETn)
    if(~REV_RESETn) rev_sequence <= 32'h0;
    else if(match_count > 0) rev_sequence <= MAGIC_SEQUENCE;

  AhaTlxInputLane u_mon_input_lane (
    .CLK                    (FWD_CLK),
    .RESETn                 (FWD_RESETn),
    .D_IN                   (FWD_DATA_IN),
    .START                  (start_fwd),
    .CLEAR                  (1'b0),
    .SEQUENCE               (MAGIC_SEQUENCE),
    .LENGTH                 (32'h100),
    .AUTO_STOP              (1'b0),
    .DONE                   (),
    .ACTIVE                 (),
    .MATCH_COUNT            (match_count)
  );

  AhaTlxOutputLane u_drv_output_lane (
    .CLK                    (REV_CLK),
    .RESETn                 (REV_RESETn),
    .D_IN                   (REV_DATA_IN),
    .START                  (start_rev),
    .CLEAR                  (1'b0),
    .SEQUENCE               (rev_sequence),
    .LENGTH                 (32'h100),
    .AUTO_STOP              (1'b0),
    .MODE                   (OE),
    .DONE                   (),
    .ACTIVE                 (),
    .D_OUT                  (REV_DATA_OUT)
  );
endmodule
