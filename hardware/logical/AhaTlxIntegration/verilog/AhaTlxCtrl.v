//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TLX Training Controller
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxCtrl (
  // Clock and Reset
  input   wire            TLX_SIB_CLK,    // Slave Interface Block Clock
  input   wire            TLX_SIB_RESETn, // SIB Reset
  input   wire            TLX_REV_CLK,    // REV Channel Clock
  input   wire            TLX_REV_RESETn, // TLX Reset sync'ed to TLX_REV_CLK

  // RegSpace
  input   wire [31:0]     TLX_HADDR,
  input   wire [2:0]      TLX_HBURST,
  input   wire [3:0]      TLX_HPROT,
  input   wire [2:0]      TLX_HSIZE,
  input   wire [1:0]      TLX_HTRANS,
  input   wire [31:0]     TLX_HWDATA,
  input   wire            TLX_HWRITE,
  output  wire [31:0]     TLX_HRDATA,
  output  wire            TLX_HREADYOUT,
  output  wire            TLX_HRESP,
  input   wire            TLX_HSELx,
  input   wire            TLX_HREADY,

  // FWD Channel
  input   wire            FWD_LANE0_IN,
  output  wire            FWD_LANE0_OUT,
  input   wire            FWD_LANE1_IN,
  output  wire            FWD_LANE1_OUT,
  input   wire            FWD_LANE2_IN,
  output  wire            FWD_LANE2_OUT,
  input   wire            FWD_LANE3_IN,
  input   wire            FWD_LANE4_IN,

  // REV Channel
  input   wire            REV_LANE0_IN,
  input   wire            REV_LANE1_IN,
  input   wire            REV_LANE2_IN,
  input   wire            REV_LANE3_IN,
  output  wire            REV_LANE3_OUT,
  input   wire            REV_LANE4_IN,
  output  wire            REV_LANE4_OUT,

  // Interrupts
  output  wire            TLX_INT
);

//------------------------------------------------------------------------------
// Regspace
//------------------------------------------------------------------------------
  wire                    h2l_LANE_INT_STATUS_REG_LANE0_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE1_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE2_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE3_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE4_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE5_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE6_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE7_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE8_w;
  wire                    h2l_LANE_INT_STATUS_REG_LANE9_w;
  wire                    h2l_LANE_STATUS_REG_LANE0_w;
  wire                    h2l_LANE_STATUS_REG_LANE1_w;
  wire                    h2l_LANE_STATUS_REG_LANE2_w;
  wire                    h2l_LANE_STATUS_REG_LANE3_w;
  wire                    h2l_LANE_STATUS_REG_LANE4_w;
  wire                    h2l_LANE_STATUS_REG_LANE5_w;
  wire                    h2l_LANE_STATUS_REG_LANE6_w;
  wire                    h2l_LANE_STATUS_REG_LANE7_w;
  wire                    h2l_LANE_STATUS_REG_LANE8_w;
  wire                    h2l_LANE_STATUS_REG_LANE9_w;
  wire [31:0]             h2l_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w;
  wire [31:0]             h2l_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w;

  wire                    l2h_LANE_ENABLE_REG_LANE0_r;
  wire                    l2h_LANE_ENABLE_REG_LANE1_r;
  wire                    l2h_LANE_ENABLE_REG_LANE2_r;
  wire                    l2h_LANE_ENABLE_REG_LANE3_r;
  wire                    l2h_LANE_ENABLE_REG_LANE4_r;
  wire                    l2h_LANE_ENABLE_REG_LANE5_r;
  wire                    l2h_LANE_ENABLE_REG_LANE6_r;
  wire                    l2h_LANE_ENABLE_REG_LANE7_r;
  wire                    l2h_LANE_ENABLE_REG_LANE8_r;
  wire                    l2h_LANE_ENABLE_REG_LANE9_r;
  wire                    l2h_LANE_IE_REG_LANE0_r;
  wire                    l2h_LANE_IE_REG_LANE1_r;
  wire                    l2h_LANE_IE_REG_LANE2_r;
  wire                    l2h_LANE_IE_REG_LANE3_r;
  wire                    l2h_LANE_IE_REG_LANE4_r;
  wire                    l2h_LANE_IE_REG_LANE5_r;
  wire                    l2h_LANE_IE_REG_LANE6_r;
  wire                    l2h_LANE_IE_REG_LANE7_r;
  wire                    l2h_LANE_IE_REG_LANE8_r;
  wire                    l2h_LANE_IE_REG_LANE9_r;
  wire                    l2h_LANE_START_REG_LANE0_r;
  wire                    l2h_LANE_START_REG_LANE1_r;
  wire                    l2h_LANE_START_REG_LANE2_r;
  wire                    l2h_LANE_START_REG_LANE3_r;
  wire                    l2h_LANE_START_REG_LANE4_r;
  wire                    l2h_LANE_START_REG_LANE5_r;
  wire                    l2h_LANE_START_REG_LANE6_r;
  wire                    l2h_LANE_START_REG_LANE7_r;
  wire                    l2h_LANE_START_REG_LANE8_r;
  wire                    l2h_LANE_START_REG_LANE9_r;
  wire                    l2h_LANE_CLEAR_REG_LANE0_r;
  wire                    l2h_LANE_CLEAR_REG_LANE1_r;
  wire                    l2h_LANE_CLEAR_REG_LANE2_r;
  wire                    l2h_LANE_CLEAR_REG_LANE3_r;
  wire                    l2h_LANE_CLEAR_REG_LANE4_r;
  wire                    l2h_LANE_CLEAR_REG_LANE5_r;
  wire                    l2h_LANE_CLEAR_REG_LANE6_r;
  wire                    l2h_LANE_CLEAR_REG_LANE7_r;
  wire                    l2h_LANE_CLEAR_REG_LANE8_r;
  wire                    l2h_LANE_CLEAR_REG_LANE9_r;
  wire [31:0]             l2h_LANE0_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE1_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE2_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE3_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE4_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE5_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE6_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE7_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE8_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE9_SEQUENCE_REG_SEQUENCE_r;
  wire [31:0]             l2h_LANE0_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE1_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE2_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE3_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE4_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE5_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE6_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE7_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE8_LENGTH_REG_LENGTH_r;
  wire [31:0]             l2h_LANE9_LENGTH_REG_LENGTH_r;

  AhaTlxCtrlRegspace u_aha_tlx_ctrl_regspace (
    // Clock and Reset
    .CLK                                          (TLX_SIB_CLK),
    .RESETn                                       (TLX_SIB_RESETn),

    // AHB Interface
    .TLX_HADDR                                    (TLX_HADDR),
    .TLX_HBURST                                   (TLX_HBURST),
    .TLX_HPROT                                    (TLX_HPROT),
    .TLX_HSIZE                                    (TLX_HSIZE),
    .TLX_HTRANS                                   (TLX_HTRANS),
    .TLX_HWDATA                                   (TLX_HWDATA),
    .TLX_HWRITE                                   (TLX_HWRITE),
    .TLX_HRDATA                                   (TLX_HRDATA),
    .TLX_HREADYOUT                                (TLX_HREADYOUT),
    .TLX_HRESP                                    (TLX_HRESP),
    .TLX_HSELx                                    (TLX_HSELx),
    .TLX_HREADY                                   (TLX_HREADY),

    // Training Signals
    .H2L_LANE_INT_STATUS_REG_LANE0_w              (h2l_LANE_INT_STATUS_REG_LANE0_w),
    .H2L_LANE_INT_STATUS_REG_LANE1_w              (h2l_LANE_INT_STATUS_REG_LANE1_w),
    .H2L_LANE_INT_STATUS_REG_LANE2_w              (h2l_LANE_INT_STATUS_REG_LANE2_w),
    .H2L_LANE_INT_STATUS_REG_LANE3_w              (h2l_LANE_INT_STATUS_REG_LANE3_w),
    .H2L_LANE_INT_STATUS_REG_LANE4_w              (h2l_LANE_INT_STATUS_REG_LANE4_w),
    .H2L_LANE_INT_STATUS_REG_LANE5_w              (h2l_LANE_INT_STATUS_REG_LANE5_w),
    .H2L_LANE_INT_STATUS_REG_LANE6_w              (h2l_LANE_INT_STATUS_REG_LANE6_w),
    .H2L_LANE_INT_STATUS_REG_LANE7_w              (h2l_LANE_INT_STATUS_REG_LANE7_w),
    .H2L_LANE_INT_STATUS_REG_LANE8_w              (h2l_LANE_INT_STATUS_REG_LANE8_w),
    .H2L_LANE_INT_STATUS_REG_LANE9_w              (h2l_LANE_INT_STATUS_REG_LANE9_w),
    .H2L_LANE_STATUS_REG_LANE0_w                  (h2l_LANE_STATUS_REG_LANE0_w),
    .H2L_LANE_STATUS_REG_LANE1_w                  (h2l_LANE_STATUS_REG_LANE1_w),
    .H2L_LANE_STATUS_REG_LANE2_w                  (h2l_LANE_STATUS_REG_LANE2_w),
    .H2L_LANE_STATUS_REG_LANE3_w                  (h2l_LANE_STATUS_REG_LANE3_w),
    .H2L_LANE_STATUS_REG_LANE4_w                  (h2l_LANE_STATUS_REG_LANE4_w),
    .H2L_LANE_STATUS_REG_LANE5_w                  (h2l_LANE_STATUS_REG_LANE5_w),
    .H2L_LANE_STATUS_REG_LANE6_w                  (h2l_LANE_STATUS_REG_LANE6_w),
    .H2L_LANE_STATUS_REG_LANE7_w                  (h2l_LANE_STATUS_REG_LANE7_w),
    .H2L_LANE_STATUS_REG_LANE8_w                  (h2l_LANE_STATUS_REG_LANE8_w),
    .H2L_LANE_STATUS_REG_LANE9_w                  (h2l_LANE_STATUS_REG_LANE9_w),
    .H2L_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w),
    .H2L_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w      (h2l_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w),

    .L2H_LANE_ENABLE_REG_LANE0_r                  (l2h_LANE_ENABLE_REG_LANE0_r),
    .L2H_LANE_ENABLE_REG_LANE1_r                  (l2h_LANE_ENABLE_REG_LANE1_r),
    .L2H_LANE_ENABLE_REG_LANE2_r                  (l2h_LANE_ENABLE_REG_LANE2_r),
    .L2H_LANE_ENABLE_REG_LANE3_r                  (l2h_LANE_ENABLE_REG_LANE3_r),
    .L2H_LANE_ENABLE_REG_LANE4_r                  (l2h_LANE_ENABLE_REG_LANE4_r),
    .L2H_LANE_ENABLE_REG_LANE5_r                  (l2h_LANE_ENABLE_REG_LANE5_r),
    .L2H_LANE_ENABLE_REG_LANE6_r                  (l2h_LANE_ENABLE_REG_LANE6_r),
    .L2H_LANE_ENABLE_REG_LANE7_r                  (l2h_LANE_ENABLE_REG_LANE7_r),
    .L2H_LANE_ENABLE_REG_LANE8_r                  (l2h_LANE_ENABLE_REG_LANE8_r),
    .L2H_LANE_ENABLE_REG_LANE9_r                  (l2h_LANE_ENABLE_REG_LANE9_r),
    .L2H_LANE_IE_REG_LANE0_r                      (l2h_LANE_IE_REG_LANE0_r),
    .L2H_LANE_IE_REG_LANE1_r                      (l2h_LANE_IE_REG_LANE1_r),
    .L2H_LANE_IE_REG_LANE2_r                      (l2h_LANE_IE_REG_LANE2_r),
    .L2H_LANE_IE_REG_LANE3_r                      (l2h_LANE_IE_REG_LANE3_r),
    .L2H_LANE_IE_REG_LANE4_r                      (l2h_LANE_IE_REG_LANE4_r),
    .L2H_LANE_IE_REG_LANE5_r                      (l2h_LANE_IE_REG_LANE5_r),
    .L2H_LANE_IE_REG_LANE6_r                      (l2h_LANE_IE_REG_LANE6_r),
    .L2H_LANE_IE_REG_LANE7_r                      (l2h_LANE_IE_REG_LANE7_r),
    .L2H_LANE_IE_REG_LANE8_r                      (l2h_LANE_IE_REG_LANE8_r),
    .L2H_LANE_IE_REG_LANE9_r                      (l2h_LANE_IE_REG_LANE9_r),
    .L2H_LANE_START_REG_LANE0_r                   (l2h_LANE_START_REG_LANE0_r),
    .L2H_LANE_START_REG_LANE1_r                   (l2h_LANE_START_REG_LANE1_r),
    .L2H_LANE_START_REG_LANE2_r                   (l2h_LANE_START_REG_LANE2_r),
    .L2H_LANE_START_REG_LANE3_r                   (l2h_LANE_START_REG_LANE3_r),
    .L2H_LANE_START_REG_LANE4_r                   (l2h_LANE_START_REG_LANE4_r),
    .L2H_LANE_START_REG_LANE5_r                   (l2h_LANE_START_REG_LANE5_r),
    .L2H_LANE_START_REG_LANE6_r                   (l2h_LANE_START_REG_LANE6_r),
    .L2H_LANE_START_REG_LANE7_r                   (l2h_LANE_START_REG_LANE7_r),
    .L2H_LANE_START_REG_LANE8_r                   (l2h_LANE_START_REG_LANE8_r),
    .L2H_LANE_START_REG_LANE9_r                   (l2h_LANE_START_REG_LANE9_r),
    .L2H_LANE_CLEAR_REG_LANE0_r                   (l2h_LANE_CLEAR_REG_LANE0_r),
    .L2H_LANE_CLEAR_REG_LANE1_r                   (l2h_LANE_CLEAR_REG_LANE1_r),
    .L2H_LANE_CLEAR_REG_LANE2_r                   (l2h_LANE_CLEAR_REG_LANE2_r),
    .L2H_LANE_CLEAR_REG_LANE3_r                   (l2h_LANE_CLEAR_REG_LANE3_r),
    .L2H_LANE_CLEAR_REG_LANE4_r                   (l2h_LANE_CLEAR_REG_LANE4_r),
    .L2H_LANE_CLEAR_REG_LANE5_r                   (l2h_LANE_CLEAR_REG_LANE5_r),
    .L2H_LANE_CLEAR_REG_LANE6_r                   (l2h_LANE_CLEAR_REG_LANE6_r),
    .L2H_LANE_CLEAR_REG_LANE7_r                   (l2h_LANE_CLEAR_REG_LANE7_r),
    .L2H_LANE_CLEAR_REG_LANE8_r                   (l2h_LANE_CLEAR_REG_LANE8_r),
    .L2H_LANE_CLEAR_REG_LANE9_r                   (l2h_LANE_CLEAR_REG_LANE9_r),
    .L2H_LANE0_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE0_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE1_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE1_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE2_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE2_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE3_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE3_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE4_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE4_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE5_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE5_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE6_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE6_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE7_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE7_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE8_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE8_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE9_SEQUENCE_REG_SEQUENCE_r            (l2h_LANE9_SEQUENCE_REG_SEQUENCE_r),
    .L2H_LANE0_LENGTH_REG_LENGTH_r                (l2h_LANE0_LENGTH_REG_LENGTH_r),
    .L2H_LANE1_LENGTH_REG_LENGTH_r                (l2h_LANE1_LENGTH_REG_LENGTH_r),
    .L2H_LANE2_LENGTH_REG_LENGTH_r                (l2h_LANE2_LENGTH_REG_LENGTH_r),
    .L2H_LANE3_LENGTH_REG_LENGTH_r                (l2h_LANE3_LENGTH_REG_LENGTH_r),
    .L2H_LANE4_LENGTH_REG_LENGTH_r                (l2h_LANE4_LENGTH_REG_LENGTH_r),
    .L2H_LANE5_LENGTH_REG_LENGTH_r                (l2h_LANE5_LENGTH_REG_LENGTH_r),
    .L2H_LANE6_LENGTH_REG_LENGTH_r                (l2h_LANE6_LENGTH_REG_LENGTH_r),
    .L2H_LANE7_LENGTH_REG_LENGTH_r                (l2h_LANE7_LENGTH_REG_LENGTH_r),
    .L2H_LANE8_LENGTH_REG_LENGTH_r                (l2h_LANE8_LENGTH_REG_LENGTH_r),
    .L2H_LANE9_LENGTH_REG_LENGTH_r                (l2h_LANE9_LENGTH_REG_LENGTH_r)
  );

//------------------------------------------------------------------------------
// FWD Training Module Integration
//------------------------------------------------------------------------------

  AhaTlxCtrlFwd u_tlx_ctrl_fwd (
    // Clock and Reset
    .CLK                                          (TLX_SIB_CLK),
    .RESETn                                       (TLX_SIB_RESETn),

    // TLX Data
    .LANE0_DIN                                    (FWD_LANE0_IN),
    .LANE0_DOUT                                   (FWD_LANE0_OUT),
    .LANE1_DIN                                    (FWD_LANE1_IN),
    .LANE1_DOUT                                   (FWD_LANE1_OUT),
    .LANE2_DIN                                    (FWD_LANE2_IN),
    .LANE2_DOUT                                   (FWD_LANE2_OUT),
    .LANE3_DIN                                    (FWD_LANE3_IN),
    .LANE4_DIN                                    (FWD_LANE4_IN),

    // Enable Signals
    .LANE0_EN                                     (l2h_LANE_ENABLE_REG_LANE0_r),
    .LANE1_EN                                     (l2h_LANE_ENABLE_REG_LANE1_r),
    .LANE2_EN                                     (l2h_LANE_ENABLE_REG_LANE2_r),
    .LANE3_EN                                     (l2h_LANE_ENABLE_REG_LANE3_r),
    .LANE4_EN                                     (l2h_LANE_ENABLE_REG_LANE4_r),

    // Interrupt Enable Signals
    .LANE0_IE                                     (l2h_LANE_IE_REG_LANE0_r),
    .LANE1_IE                                     (l2h_LANE_IE_REG_LANE1_r),
    .LANE2_IE                                     (l2h_LANE_IE_REG_LANE2_r),
    .LANE3_IE                                     (l2h_LANE_IE_REG_LANE3_r),
    .LANE4_IE                                     (l2h_LANE_IE_REG_LANE4_r),

    // Start Pulse Signals
    .LANE0_START                                  (l2h_LANE_START_REG_LANE0_r),
    .LANE1_START                                  (l2h_LANE_START_REG_LANE1_r),
    .LANE2_START                                  (l2h_LANE_START_REG_LANE2_r),
    .LANE3_START                                  (l2h_LANE_START_REG_LANE3_r),
    .LANE4_START                                  (l2h_LANE_START_REG_LANE4_r),

    // Clear Pulse Signals
    .LANE0_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE0_r),
    .LANE1_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE1_r),
    .LANE2_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE2_r),
    .LANE3_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE3_r),
    .LANE4_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE4_r),

    // Sequence Signals
    .LANE0_SEQUENCE                               (l2h_LANE0_SEQUENCE_REG_SEQUENCE_r),
    .LANE1_SEQUENCE                               (l2h_LANE1_SEQUENCE_REG_SEQUENCE_r),
    .LANE2_SEQUENCE                               (l2h_LANE2_SEQUENCE_REG_SEQUENCE_r),
    .LANE3_SEQUENCE                               (l2h_LANE3_SEQUENCE_REG_SEQUENCE_r),
    .LANE4_SEQUENCE                               (l2h_LANE4_SEQUENCE_REG_SEQUENCE_r),

    // Length Signals
    .LANE0_LENGTH                                 (l2h_LANE0_LENGTH_REG_LENGTH_r),
    .LANE1_LENGTH                                 (l2h_LANE1_LENGTH_REG_LENGTH_r),
    .LANE2_LENGTH                                 (l2h_LANE2_LENGTH_REG_LENGTH_r),
    .LANE3_LENGTH                                 (l2h_LANE3_LENGTH_REG_LENGTH_r),
    .LANE4_LENGTH                                 (l2h_LANE4_LENGTH_REG_LENGTH_r),

    // Match Count Signals
    .LANE0_MATCH_COUNT                            (h2l_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE1_MATCH_COUNT                            (h2l_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE2_MATCH_COUNT                            (h2l_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE3_MATCH_COUNT                            (h2l_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE4_MATCH_COUNT                            (h2l_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w),


    // Interrupt Status Signals
    .LANE0_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE0_w),
    .LANE1_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE1_w),
    .LANE2_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE2_w),
    .LANE3_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE3_w),
    .LANE4_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE4_w),

    // Training Status Signals
    .LANE0_STATUS                                 (h2l_LANE_STATUS_REG_LANE0_w),
    .LANE1_STATUS                                 (h2l_LANE_STATUS_REG_LANE1_w),
    .LANE2_STATUS                                 (h2l_LANE_STATUS_REG_LANE2_w),
    .LANE3_STATUS                                 (h2l_LANE_STATUS_REG_LANE3_w),
    .LANE4_STATUS                                 (h2l_LANE_STATUS_REG_LANE4_w)
  );

//------------------------------------------------------------------------------
// REV Training Module Integration
//------------------------------------------------------------------------------
  AhaTlxCtrlRev u_tlx_ctrl_rev (
    // Clock and Reset
    .SYS_CLK                                      (TLX_SIB_CLK),
    .SYS_RESETn                                   (TLX_SIB_RESETn),
    .REV_CLK                                      (TLX_REV_CLK),
    .REV_RESETn                                   (TLX_REV_RESETn),

    // TLX Data
    .LANE0_DIN                                    (REV_LANE0_IN),
    .LANE1_DIN                                    (REV_LANE1_IN),
    .LANE2_DIN                                    (REV_LANE2_IN),
    .LANE3_DIN                                    (REV_LANE3_IN),
    .LANE3_DOUT                                   (REV_LANE3_OUT),
    .LANE4_DIN                                    (REV_LANE4_IN),
    .LANE4_DOUT                                   (REV_LANE4_OUT),

    // Enable Signals
    .LANE0_EN                                     (l2h_LANE_ENABLE_REG_LANE5_r),
    .LANE1_EN                                     (l2h_LANE_ENABLE_REG_LANE6_r),
    .LANE2_EN                                     (l2h_LANE_ENABLE_REG_LANE7_r),
    .LANE3_EN                                     (l2h_LANE_ENABLE_REG_LANE8_r),
    .LANE4_EN                                     (l2h_LANE_ENABLE_REG_LANE9_r),

    // Interrupt Enable Signals
    .LANE0_IE                                     (l2h_LANE_IE_REG_LANE5_r),
    .LANE1_IE                                     (l2h_LANE_IE_REG_LANE6_r),
    .LANE2_IE                                     (l2h_LANE_IE_REG_LANE7_r),
    .LANE3_IE                                     (l2h_LANE_IE_REG_LANE8_r),
    .LANE4_IE                                     (l2h_LANE_IE_REG_LANE9_r),

    // Start Pulse Signals
    .LANE0_START                                  (l2h_LANE_START_REG_LANE5_r),
    .LANE1_START                                  (l2h_LANE_START_REG_LANE6_r),
    .LANE2_START                                  (l2h_LANE_START_REG_LANE7_r),
    .LANE3_START                                  (l2h_LANE_START_REG_LANE8_r),
    .LANE4_START                                  (l2h_LANE_START_REG_LANE9_r),

    // Clear Pulse Signals
    .LANE0_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE5_r),
    .LANE1_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE6_r),
    .LANE2_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE7_r),
    .LANE3_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE8_r),
    .LANE4_CLEAR                                  (l2h_LANE_CLEAR_REG_LANE9_r),

    // Sequence Signals
    .LANE0_SEQUENCE                               (l2h_LANE5_SEQUENCE_REG_SEQUENCE_r),
    .LANE1_SEQUENCE                               (l2h_LANE6_SEQUENCE_REG_SEQUENCE_r),
    .LANE2_SEQUENCE                               (l2h_LANE7_SEQUENCE_REG_SEQUENCE_r),
    .LANE3_SEQUENCE                               (l2h_LANE8_SEQUENCE_REG_SEQUENCE_r),
    .LANE4_SEQUENCE                               (l2h_LANE9_SEQUENCE_REG_SEQUENCE_r),

    // Length Signals
    .LANE0_LENGTH                                 (l2h_LANE5_LENGTH_REG_LENGTH_r),
    .LANE1_LENGTH                                 (l2h_LANE6_LENGTH_REG_LENGTH_r),
    .LANE2_LENGTH                                 (l2h_LANE7_LENGTH_REG_LENGTH_r),
    .LANE3_LENGTH                                 (l2h_LANE8_LENGTH_REG_LENGTH_r),
    .LANE4_LENGTH                                 (l2h_LANE9_LENGTH_REG_LENGTH_r),

    // Match Count Signals
    .LANE0_MATCH_COUNT                            (h2l_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE1_MATCH_COUNT                            (h2l_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE2_MATCH_COUNT                            (h2l_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE3_MATCH_COUNT                            (h2l_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w),
    .LANE4_MATCH_COUNT                            (h2l_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w),


    // Interrupt Status Signals
    .LANE0_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE5_w),
    .LANE1_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE6_w),
    .LANE2_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE7_w),
    .LANE3_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE8_w),
    .LANE4_INT_STATUS                             (h2l_LANE_INT_STATUS_REG_LANE9_w),

    // Training Status Signals
    .LANE0_STATUS                                 (h2l_LANE_STATUS_REG_LANE5_w),
    .LANE1_STATUS                                 (h2l_LANE_STATUS_REG_LANE6_w),
    .LANE2_STATUS                                 (h2l_LANE_STATUS_REG_LANE7_w),
    .LANE3_STATUS                                 (h2l_LANE_STATUS_REG_LANE8_w),
    .LANE4_STATUS                                 (h2l_LANE_STATUS_REG_LANE9_w)
  );

//------------------------------------------------------------------------------
// Combined Interrupt Output
//------------------------------------------------------------------------------
  assign TLX_INT =  h2l_LANE_INT_STATUS_REG_LANE0_w   |
                    h2l_LANE_INT_STATUS_REG_LANE1_w   |
                    h2l_LANE_INT_STATUS_REG_LANE2_w   |
                    h2l_LANE_INT_STATUS_REG_LANE3_w   |
                    h2l_LANE_INT_STATUS_REG_LANE4_w   |
                    h2l_LANE_INT_STATUS_REG_LANE5_w   |
                    h2l_LANE_INT_STATUS_REG_LANE6_w   |
                    h2l_LANE_INT_STATUS_REG_LANE7_w   |
                    h2l_LANE_INT_STATUS_REG_LANE8_w   |
                    h2l_LANE_INT_STATUS_REG_LANE9_w   ;
endmodule
