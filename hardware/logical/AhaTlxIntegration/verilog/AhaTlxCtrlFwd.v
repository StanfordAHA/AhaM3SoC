//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TLX Training Controller for Forward Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxCtrlFwd (
  // Clock and Reset
  input   wire            CLK,    // Slave Interface Block Clock
  input   wire            RESETn, // SIB Reset

  // TLX Data
  input   wire            LANE0_DIN,
  output  wire            LANE0_DOUT,
  input   wire            LANE1_DIN,
  output  wire            LANE1_DOUT,
  input   wire            LANE2_DIN,
  output  wire            LANE2_DOUT,
  input   wire            LANE3_DIN,
  input   wire            LANE4_DIN,

  // Enable Signals
  input   wire            LANE0_EN,
  input   wire            LANE1_EN,
  input   wire            LANE2_EN,
  input   wire            LANE3_EN,
  input   wire            LANE4_EN,

  // Interrupt Enable Signals
  input   wire            LANE0_IE,
  input   wire            LANE1_IE,
  input   wire            LANE2_IE,
  input   wire            LANE3_IE,
  input   wire            LANE4_IE,

  // Start Pulse Signals
  input   wire            LANE0_START,
  input   wire            LANE1_START,
  input   wire            LANE2_START,
  input   wire            LANE3_START,
  input   wire            LANE4_START,

  // Clear Pulse Signals
  input   wire            LANE0_CLEAR,
  input   wire            LANE1_CLEAR,
  input   wire            LANE2_CLEAR,
  input   wire            LANE3_CLEAR,
  input   wire            LANE4_CLEAR,

  // Sequence Signals
  input   wire [31:0]     LANE0_SEQUENCE,
  input   wire [31:0]     LANE1_SEQUENCE,
  input   wire [31:0]     LANE2_SEQUENCE,
  input   wire [31:0]     LANE3_SEQUENCE,
  input   wire [31:0]     LANE4_SEQUENCE,

  // Length Signals
  input   wire [31:0]     LANE0_LENGTH,
  input   wire [31:0]     LANE1_LENGTH,
  input   wire [31:0]     LANE2_LENGTH,
  input   wire [31:0]     LANE3_LENGTH,
  input   wire [31:0]     LANE4_LENGTH,

  // Match Count Signals
  output  wire [31:0]     LANE0_MATCH_COUNT,
  output  wire [31:0]     LANE1_MATCH_COUNT,
  output  wire [31:0]     LANE2_MATCH_COUNT,
  output  wire [31:0]     LANE3_MATCH_COUNT,
  output  wire [31:0]     LANE4_MATCH_COUNT,


  // Interrupt Status Signals
  output  wire            LANE0_INT_STATUS,
  output  wire            LANE1_INT_STATUS,
  output  wire            LANE2_INT_STATUS,
  output  wire            LANE3_INT_STATUS,
  output  wire            LANE4_INT_STATUS,

  // Training Status Signals
  output  wire            LANE0_STATUS,
  output  wire            LANE1_STATUS,
  output  wire            LANE2_STATUS,
  output  wire            LANE3_STATUS,
  output  wire            LANE4_STATUS
);

  // Lane0 - FWD Output
  AhaTlxOutputLane u_fwd_lane0 (
    .CLK          (CLK),
    .RESETn       (RESETn),
    .D_IN         (LANE0_DIN),
    .START        (LANE0_START & LANE0_EN),
    .CLEAR        (LANE0_CLEAR),
    .SEQUENCE     (LANE0_SEQUENCE),
    .LENGTH       (LANE0_LENGTH),
    .AUTO_STOP    (LANE0_IE & LANE0_EN),
    .MODE         (LANE0_EN),

    .DONE         (LANE0_INT_STATUS),
    .ACTIVE       (LANE0_STATUS),
    .D_OUT        (LANE0_DOUT)
  );

  assign LANE0_MATCH_COUNT = 32'h0;

  // Lane1 - FWD Output
  AhaTlxOutputLane u_fwd_lane1 (
    .CLK          (CLK),
    .RESETn       (RESETn),
    .D_IN         (LANE1_DIN),
    .START        (LANE1_START & LANE1_EN),
    .CLEAR        (LANE1_CLEAR),
    .SEQUENCE     (LANE1_SEQUENCE),
    .LENGTH       (LANE1_LENGTH),
    .AUTO_STOP    (LANE1_IE & LANE1_EN),
    .MODE         (LANE1_EN),

    .DONE         (LANE1_INT_STATUS),
    .ACTIVE       (LANE1_STATUS),
    .D_OUT        (LANE1_DOUT)
  );

  assign LANE1_MATCH_COUNT = 32'h0;

  // Lane2 - FWD Output
  AhaTlxOutputLane u_fwd_lane2 (
    .CLK          (CLK),
    .RESETn       (RESETn),
    .D_IN         (LANE2_DIN),
    .START        (LANE2_START & LANE2_EN),
    .CLEAR        (LANE2_CLEAR),
    .SEQUENCE     (LANE2_SEQUENCE),
    .LENGTH       (LANE2_LENGTH),
    .AUTO_STOP    (LANE2_IE & LANE2_EN),
    .MODE         (LANE2_EN),

    .DONE         (LANE2_INT_STATUS),
    .ACTIVE       (LANE2_STATUS),
    .D_OUT        (LANE2_DOUT)
  );

  assign LANE2_MATCH_COUNT = 32'h0;

  // Lane3
  AhaTlxInputLane u_fwd_lane3 (
    .CLK          (CLK),
    .RESETn       (RESETn),
    .D_IN         (LANE3_DIN),
    .START        (LANE3_START & LANE3_EN),
    .CLEAR        (LANE3_CLEAR),
    .SEQUENCE     (LANE3_SEQUENCE),
    .LENGTH       (LANE3_LENGTH),
    .AUTO_STOP    (LANE3_IE & LANE3_EN),

    .DONE         (LANE3_INT_STATUS),
    .ACTIVE       (LANE3_STATUS),
    .MATCH_COUNT  (LANE3_MATCH_COUNT)
  );

  // Lane4
  AhaTlxInputLane u_fwd_lane4 (
    .CLK          (CLK),
    .RESETn       (RESETn),
    .D_IN         (LANE4_DIN),
    .START        (LANE4_START & LANE4_EN),
    .CLEAR        (LANE4_CLEAR),
    .SEQUENCE     (LANE4_SEQUENCE),
    .LENGTH       (LANE4_LENGTH),
    .AUTO_STOP    (LANE4_IE & LANE4_EN),

    .DONE         (LANE4_INT_STATUS),
    .ACTIVE       (LANE4_STATUS),
    .MATCH_COUNT  (LANE4_MATCH_COUNT)
  );

endmodule
