//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TLX Training Controller for Reverse Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxCtrlRev (
  // Clock and Reset
  input   wire            SYS_CLK,    // Slave Interface Block Clock
  input   wire            SYS_RESETn, // SIB Reset
  input   wire            REV_CLK,    // Rev Channel Clock
  input   wire            REV_RESETn, // Rev Channel Reset

  // TLX Data
  input   wire            LANE0_DIN,
  input   wire            LANE1_DIN,
  input   wire            LANE2_DIN,
  input   wire            LANE3_DIN,
  output  wire            LANE3_DOUT,
  input   wire            LANE4_DIN,
  output  wire            LANE4_DOUT,

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

  // Lane0 Sync Wires
  wire            lane0_start_sync;
  wire            lane0_clear_sync;

  wire            lane0_en_sync;
  wire            lane0_ie_sync;
  wire [31:0]     lane0_sequence_sync;
  wire [31:0]     lane0_length_sync;

  wire            lane0_int_status_w;
  wire            lane0_status_w;
  wire [31:0]     lane0_match_count_w;

  // Lane1 Sync Wires
  wire            lane1_start_sync;
  wire            lane1_clear_sync;

  wire            lane1_en_sync;
  wire            lane1_ie_sync;
  wire [31:0]     lane1_sequence_sync;
  wire [31:0]     lane1_length_sync;

  wire            lane1_int_status_w;
  wire            lane1_status_w;
  wire [31:0]     lane1_match_count_w;

  // Lane2 Sync Wires
  wire            lane2_start_sync;
  wire            lane2_clear_sync;

  wire            lane2_en_sync;
  wire            lane2_ie_sync;
  wire [31:0]     lane2_sequence_sync;
  wire [31:0]     lane2_length_sync;

  wire            lane2_int_status_w;
  wire            lane2_status_w;
  wire [31:0]     lane2_match_count_w;

  // Lane3 Sync Wires
  wire            lane3_start_sync;
  wire            lane3_clear_sync;

  wire            lane3_en_sync;
  wire            lane3_ie_sync;
  wire [31:0]     lane3_sequence_sync;
  wire [31:0]     lane3_length_sync;

  wire            lane3_int_status_w;
  wire            lane3_status_w;

  // Lane4 Sync Wires
  wire            lane4_start_sync;
  wire            lane4_clear_sync;

  wire            lane4_en_sync;
  wire            lane4_ie_sync;
  wire [31:0]     lane4_sequence_sync;
  wire [31:0]     lane4_length_sync;

  wire            lane4_int_status_w;
  wire            lane4_status_w;

  // Lane0
  AhaTlxInputLane u_rev_lane0 (
    .CLK          (REV_CLK),
    .RESETn       (REV_RESETn),
    .D_IN         (LANE0_DIN),
    .START        (lane0_start_sync & lane0_en_sync),
    .CLEAR        (lane0_clear_sync),
    .SEQUENCE     (lane0_sequence_sync),
    .LENGTH       (lane0_length_sync),
    .AUTO_STOP    (lane0_ie_sync & lane0_en_sync),

    .DONE         (lane0_int_status_w),
    .ACTIVE       (lane0_status_w),
    .MATCH_COUNT  (lane0_match_count_w)
  );

  // Lane1
  AhaTlxInputLane u_rev_lane1 (
    .CLK          (REV_CLK),
    .RESETn       (REV_RESETn),
    .D_IN         (LANE1_DIN),
    .START        (lane1_start_sync & lane1_en_sync),
    .CLEAR        (lane1_clear_sync),
    .SEQUENCE     (lane1_sequence_sync),
    .LENGTH       (lane1_length_sync),
    .AUTO_STOP    (lane1_ie_sync & lane1_en_sync),

    .DONE         (lane1_int_status_w),
    .ACTIVE       (lane1_status_w),
    .MATCH_COUNT  (lane1_match_count_w)
  );

  // Lane2
  AhaTlxInputLane u_rev_lane2 (
    .CLK          (REV_CLK),
    .RESETn       (REV_RESETn),
    .D_IN         (LANE2_DIN),
    .START        (lane2_start_sync & lane2_en_sync),
    .CLEAR        (lane2_clear_sync),
    .SEQUENCE     (lane2_sequence_sync),
    .LENGTH       (lane2_length_sync),
    .AUTO_STOP    (lane2_ie_sync & lane2_en_sync),

    .DONE         (lane2_int_status_w),
    .ACTIVE       (lane2_status_w),
    .MATCH_COUNT  (lane2_match_count_w)
  );

  // Lane3
  AhaTlxOutputLane u_rev_lane3 (
    .CLK          (REV_CLK),
    .RESETn       (REV_RESETn),
    .D_IN         (LANE3_DIN),
    .START        (lane3_start_sync & lane3_en_sync),
    .CLEAR        (lane3_clear_sync),
    .SEQUENCE     (lane3_sequence_sync),
    .LENGTH       (lane3_length_sync),
    .AUTO_STOP    (lane3_ie_sync & lane3_en_sync),
    .MODE         (lane3_en_sync),

    .DONE         (lane3_int_status_w),
    .ACTIVE       (lane3_status_w),
    .D_OUT        (LANE3_DOUT)
  );
  assign LANE3_MATCH_COUNT  = 32'h0;

  // Lane4
  AhaTlxOutputLane u_rev_lane4 (
    .CLK          (REV_CLK),
    .RESETn       (REV_RESETn),
    .D_IN         (LANE4_DIN),
    .START        (lane4_start_sync & lane4_en_sync),
    .CLEAR        (lane4_clear_sync),
    .SEQUENCE     (lane4_sequence_sync),
    .LENGTH       (lane4_length_sync),
    .AUTO_STOP    (lane4_ie_sync & lane4_en_sync),
    .MODE         (lane4_en_sync),

    .DONE         (lane4_int_status_w),
    .ACTIVE       (lane4_status_w),
    .D_OUT        (LANE4_DOUT)
  );
  assign LANE4_MATCH_COUNT  = 32'h0;

  // Synchronize Enable Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane0_en_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_EN),
    .Q                      (lane0_en_sync)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane1_en_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_EN),
    .Q                      (lane1_en_sync)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane2_en_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_EN),
    .Q                      (lane2_en_sync)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane3_en_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_EN),
    .Q                      (lane3_en_sync)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane4_en_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_EN),
    .Q                      (lane4_en_sync)
  );

  // Synchronize IE Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane0_ie_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_IE),
    .Q                      (lane0_ie_sync)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane1_ie_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_IE),
    .Q                      (lane1_ie_sync)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane2_ie_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_IE),
    .Q                      (lane2_ie_sync)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane3_ie_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_IE),
    .Q                      (lane3_ie_sync)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane4_ie_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_IE),
    .Q                      (lane4_ie_sync)
  );

  // Synchronize START Signals
  // Lane0
  AhaTlxPulseSync u_tlx_ctrl_rev_lane0_start_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_START),
    .Q                      (lane0_start_sync)
  );

  // Lane1
  AhaTlxPulseSync u_tlx_ctrl_rev_lane1_start_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_START),
    .Q                      (lane1_start_sync)
  );

  // Lane2
  AhaTlxPulseSync u_tlx_ctrl_rev_lane2_start_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_START),
    .Q                      (lane2_start_sync)
  );

  // Lane3
  AhaTlxPulseSync u_tlx_ctrl_rev_lane3_start_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_START),
    .Q                      (lane3_start_sync)
  );

  // Lane4
  AhaTlxPulseSync u_tlx_ctrl_rev_lane4_start_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_START),
    .Q                      (lane4_start_sync)
  );

  // Synchronize CLEAR Signals
  // Lane0
  AhaTlxPulseSync u_tlx_ctrl_rev_lane0_clear_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_CLEAR),
    .Q                      (lane0_clear_sync)
  );

  // Lane1
  AhaTlxPulseSync u_tlx_ctrl_rev_lane1_clear_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_CLEAR),
    .Q                      (lane1_clear_sync)
  );

  // Lane2
  AhaTlxPulseSync u_tlx_ctrl_rev_lane2_clear_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_CLEAR),
    .Q                      (lane2_clear_sync)
  );

  // Lane3
  AhaTlxPulseSync u_tlx_ctrl_rev_lane3_clear_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_CLEAR),
    .Q                      (lane3_clear_sync)
  );

  // Lane4
  AhaTlxPulseSync u_tlx_ctrl_rev_lane4_clear_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_CLEAR),
    .Q                      (lane4_clear_sync)
  );

  // Synchronize SEQUENCE Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane0_seq_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_SEQUENCE),
    .Q                      (lane0_sequence_sync)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane1_seq_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_SEQUENCE),
    .Q                      (lane1_sequence_sync)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane2_seq_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_SEQUENCE),
    .Q                      (lane2_sequence_sync)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane3_seq_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_SEQUENCE),
    .Q                      (lane3_sequence_sync)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane4_seq_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_SEQUENCE),
    .Q                      (lane4_sequence_sync)
  );

  // Synchronize LENGTH Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane0_length_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE0_LENGTH),
    .Q                      (lane0_length_sync)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane1_length_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE1_LENGTH),
    .Q                      (lane1_length_sync)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane2_length_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE2_LENGTH),
    .Q                      (lane2_length_sync)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane3_length_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE3_LENGTH),
    .Q                      (lane3_length_sync)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane4_length_sync (
    .SRC_CLK                (SYS_CLK),
    .SRC_RESETn             (SYS_RESETn),
    .DEST_CLK               (REV_CLK),
    .DEST_RESETn            (REV_RESETn),
    .D                      (LANE4_LENGTH),
    .Q                      (lane4_length_sync)
  );

  // Synchronize MATCH_COUNT Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane0_match_count_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane0_match_count_w),
    .Q                      (LANE0_MATCH_COUNT)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane1_match_count_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane1_match_count_w),
    .Q                      (LANE1_MATCH_COUNT)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(32)
    )
  u_tlx_ctrl_rev_lane2_match_count_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane2_match_count_w),
    .Q                      (LANE2_MATCH_COUNT)
  );

  // Synchronize INT_STATUS Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane0_int_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane0_int_status_w),
    .Q                      (LANE0_INT_STATUS)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane1_int_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane1_int_status_w),
    .Q                      (LANE1_INT_STATUS)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane2_int_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane2_int_status_w),
    .Q                      (LANE2_INT_STATUS)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane3_int_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane3_int_status_w),
    .Q                      (LANE3_INT_STATUS)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane4_int_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane4_int_status_w),
    .Q                      (LANE4_INT_STATUS)
  );

  // Synchronize STATUS Signals
  // Lane0
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane0_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane0_status_w),
    .Q                      (LANE0_STATUS)
  );

  // Lane1
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane1_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane1_status_w),
    .Q                      (LANE1_STATUS)
  );

  // Lane2
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane2_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane2_status_w),
    .Q                      (LANE2_STATUS)
  );

  // Lane3
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane3_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane3_status_w),
    .Q                      (LANE3_STATUS)
  );

  // Lane4
  AhaTlxDataSync #(
    .WIDTH(1)
    )
  u_tlx_ctrl_rev_lane4_stat_sync (
    .SRC_CLK                (REV_CLK),
    .SRC_RESETn             (REV_RESETn),
    .DEST_CLK               (SYS_CLK),
    .DEST_RESETn            (SYS_RESETn),
    .D                      (lane4_status_w),
    .Q                      (LANE4_STATUS)
  );

endmodule
