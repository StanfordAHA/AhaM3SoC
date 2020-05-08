//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: TLX Control Engine for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 7, 2020
//------------------------------------------------------------------------------
module AhaTlxCtrlRegspace (
  // Clocks and Resets
  input   wire                CLK,
  input   wire                RESETn,

  // Control RegSpace
  input   wire [31:0]         TLX_HADDR,
  input   wire [2:0]          TLX_HBURST,
  input   wire [3:0]          TLX_HPROT,
  input   wire [2:0]          TLX_HSIZE,
  input   wire [1:0]          TLX_HTRANS,
  input   wire [31:0]         TLX_HWDATA,
  input   wire                TLX_HWRITE,
  output  wire [31:0]         TLX_HRDATA,
  output  wire                TLX_HREADYOUT,
  output  wire                TLX_HRESP,
  input   wire                TLX_HSELx,
  input   wire                TLX_HREADY,

  // Training Signals
  input   wire                H2L_LANE_INT_STATUS_REG_LANE0_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE1_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE2_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE3_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE4_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE5_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE6_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE7_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE8_w,
  input   wire                H2L_LANE_INT_STATUS_REG_LANE9_w,
  input   wire                H2L_LANE_STATUS_REG_LANE0_w,
  input   wire                H2L_LANE_STATUS_REG_LANE1_w,
  input   wire                H2L_LANE_STATUS_REG_LANE2_w,
  input   wire                H2L_LANE_STATUS_REG_LANE3_w,
  input   wire                H2L_LANE_STATUS_REG_LANE4_w,
  input   wire                H2L_LANE_STATUS_REG_LANE5_w,
  input   wire                H2L_LANE_STATUS_REG_LANE6_w,
  input   wire                H2L_LANE_STATUS_REG_LANE7_w,
  input   wire                H2L_LANE_STATUS_REG_LANE8_w,
  input   wire                H2L_LANE_STATUS_REG_LANE9_w,
  input   wire [31:0]         H2L_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w,
  input   wire [31:0]         H2L_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w,

  output                      L2H_LANE_ENABLE_REG_LANE0_r,
  output                      L2H_LANE_ENABLE_REG_LANE1_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE2_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE3_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE4_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE5_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE6_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE7_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE8_r,
  output  wire                L2H_LANE_ENABLE_REG_LANE9_r,
  output  wire                L2H_LANE_IE_REG_LANE0_r,
  output  wire                L2H_LANE_IE_REG_LANE1_r,
  output  wire                L2H_LANE_IE_REG_LANE2_r,
  output  wire                L2H_LANE_IE_REG_LANE3_r,
  output  wire                L2H_LANE_IE_REG_LANE4_r,
  output  wire                L2H_LANE_IE_REG_LANE5_r,
  output  wire                L2H_LANE_IE_REG_LANE6_r,
  output  wire                L2H_LANE_IE_REG_LANE7_r,
  output  wire                L2H_LANE_IE_REG_LANE8_r,
  output  wire                L2H_LANE_IE_REG_LANE9_r,
  output  wire                L2H_LANE_START_REG_LANE0_r,
  output  wire                L2H_LANE_START_REG_LANE1_r,
  output  wire                L2H_LANE_START_REG_LANE2_r,
  output  wire                L2H_LANE_START_REG_LANE3_r,
  output  wire                L2H_LANE_START_REG_LANE4_r,
  output  wire                L2H_LANE_START_REG_LANE5_r,
  output  wire                L2H_LANE_START_REG_LANE6_r,
  output  wire                L2H_LANE_START_REG_LANE7_r,
  output  wire                L2H_LANE_START_REG_LANE8_r,
  output  wire                L2H_LANE_START_REG_LANE9_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE0_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE1_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE2_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE3_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE4_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE5_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE6_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE7_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE8_r,
  output  wire                L2H_LANE_CLEAR_REG_LANE9_r,
  output  wire [31:0]         L2H_LANE0_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE1_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE2_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE3_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE4_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE5_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE6_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE7_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE8_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE9_SEQUENCE_REG_SEQUENCE_r,
  output  wire [31:0]         L2H_LANE0_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE1_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE2_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE3_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE4_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE5_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE6_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE7_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE8_LENGTH_REG_LENGTH_r,
  output  wire [31:0]         L2H_LANE9_LENGTH_REG_LENGTH_r
);

//------------------------------------------------------------------------------
// Simple Register Access Interface Wires
//------------------------------------------------------------------------------
  wire  [11:0]                regif_addr;
  wire                        regif_read_en;
  wire                        regif_write_en;
  wire  [3:0]                 regif_byte_strobe;
  wire  [31:0]                regif_wdata;
  wire  [31:0]                regif_rdata;
  wire                        regif_ack;
  wire                        regif_nack;

//------------------------------------------------------------------------------
// Convert AHB to Simple Reg Access Interface
//------------------------------------------------------------------------------
  wire [1:0] tlx_hresp_w;

  AhaAHBToParallel #(.ADDR_WIDTH(12)) u_tlx_ctrl_ahb_to_parallel_if (
    // AHB Interface
    .HCLK                     (CLK),
    .HRESETn                  (RESETn),

    .HSEL                     (TLX_HSELx),
    .HADDR                    (TLX_HADDR),
    .HTRANS                   (TLX_HTRANS),
    .HWRITE                   (TLX_HWRITE),
    .HSIZE                    (TLX_HSIZE),
    .HBURST                   (TLX_HBURST),
    .HPROT                    (TLX_HPROT),
    .HMASTER                  (4'h0),
    .HWDATA                   (TLX_HWDATA),
    .HMASTLOCK                (1'b0),
    .HREADYMUX                (TLX_HREADY),

    .HRDATA                   (TLX_HRDATA),
    .HREADYOUT                (TLX_HREADYOUT),
    .HRESP                    (tlx_hresp_w),

    // Parallel Interface
    .PAR_ADDR                 (regif_addr),
    .PAR_RD_EN                (regif_read_en),
    .PAR_WR_EN                (regif_write_en),
    .PAR_WR_STRB              (regif_byte_strobe),
    .PAR_WR_DATA              (regif_wdata),
    .PAR_RD_DATA              (regif_rdata),
    .PAR_ACK                  (regif_ack),
    .PAR_NACK                 (regif_nack)
  );

  assign TLX_HRESP      = tlx_hresp_w[0];

//------------------------------------------------------------------------------
// Register Space Integration
//------------------------------------------------------------------------------
  AhaTlxCtrlAddrMap_pio u_tlx_ctrl_addr_map (
    .clk                                            (CLK),
    .reset                                          (~RESETn),

    .h2l_LANE_INT_STATUS_REG_LANE0_w                (H2L_LANE_INT_STATUS_REG_LANE0_w),
    .h2l_LANE_INT_STATUS_REG_LANE1_w                (H2L_LANE_INT_STATUS_REG_LANE1_w),
    .h2l_LANE_INT_STATUS_REG_LANE2_w                (H2L_LANE_INT_STATUS_REG_LANE2_w),
    .h2l_LANE_INT_STATUS_REG_LANE3_w                (H2L_LANE_INT_STATUS_REG_LANE3_w),
    .h2l_LANE_INT_STATUS_REG_LANE4_w                (H2L_LANE_INT_STATUS_REG_LANE4_w),
    .h2l_LANE_INT_STATUS_REG_LANE5_w                (H2L_LANE_INT_STATUS_REG_LANE5_w),
    .h2l_LANE_INT_STATUS_REG_LANE6_w                (H2L_LANE_INT_STATUS_REG_LANE6_w),
    .h2l_LANE_INT_STATUS_REG_LANE7_w                (H2L_LANE_INT_STATUS_REG_LANE7_w),
    .h2l_LANE_INT_STATUS_REG_LANE8_w                (H2L_LANE_INT_STATUS_REG_LANE8_w),
    .h2l_LANE_INT_STATUS_REG_LANE9_w                (H2L_LANE_INT_STATUS_REG_LANE9_w),
    .h2l_LANE_STATUS_REG_LANE0_w                    (H2L_LANE_STATUS_REG_LANE0_w),
    .h2l_LANE_STATUS_REG_LANE1_w                    (H2L_LANE_STATUS_REG_LANE1_w),
    .h2l_LANE_STATUS_REG_LANE2_w                    (H2L_LANE_STATUS_REG_LANE2_w),
    .h2l_LANE_STATUS_REG_LANE3_w                    (H2L_LANE_STATUS_REG_LANE3_w),
    .h2l_LANE_STATUS_REG_LANE4_w                    (H2L_LANE_STATUS_REG_LANE4_w),
    .h2l_LANE_STATUS_REG_LANE5_w                    (H2L_LANE_STATUS_REG_LANE5_w),
    .h2l_LANE_STATUS_REG_LANE6_w                    (H2L_LANE_STATUS_REG_LANE6_w),
    .h2l_LANE_STATUS_REG_LANE7_w                    (H2L_LANE_STATUS_REG_LANE7_w),
    .h2l_LANE_STATUS_REG_LANE8_w                    (H2L_LANE_STATUS_REG_LANE8_w),
    .h2l_LANE_STATUS_REG_LANE9_w                    (H2L_LANE_STATUS_REG_LANE9_w),
    .h2l_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE0_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE1_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE2_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE3_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE4_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE5_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE6_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE7_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE8_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2l_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w        (H2L_LANE9_MATCH_COUNT_REG_MATCH_COUNT_w),
    .h2d_pio_dec_address                            (regif_addr[7:2]),
    .h2d_pio_dec_write_data                         (regif_wdata),
    .h2d_pio_dec_write_enable                       (regif_byte_strobe),
    .h2d_pio_dec_write                              (regif_write_en),
    .h2d_pio_dec_read                               (regif_read_en),

    .l2h_LANE_ENABLE_REG_LANE0_r                    (L2H_LANE_ENABLE_REG_LANE0_r),
    .l2h_LANE_ENABLE_REG_LANE1_r                    (L2H_LANE_ENABLE_REG_LANE1_r),
    .l2h_LANE_ENABLE_REG_LANE2_r                    (L2H_LANE_ENABLE_REG_LANE2_r),
    .l2h_LANE_ENABLE_REG_LANE3_r                    (L2H_LANE_ENABLE_REG_LANE3_r),
    .l2h_LANE_ENABLE_REG_LANE4_r                    (L2H_LANE_ENABLE_REG_LANE4_r),
    .l2h_LANE_ENABLE_REG_LANE5_r                    (L2H_LANE_ENABLE_REG_LANE5_r),
    .l2h_LANE_ENABLE_REG_LANE6_r                    (L2H_LANE_ENABLE_REG_LANE6_r),
    .l2h_LANE_ENABLE_REG_LANE7_r                    (L2H_LANE_ENABLE_REG_LANE7_r),
    .l2h_LANE_ENABLE_REG_LANE8_r                    (L2H_LANE_ENABLE_REG_LANE8_r),
    .l2h_LANE_ENABLE_REG_LANE9_r                    (L2H_LANE_ENABLE_REG_LANE9_r),
    .l2h_LANE_IE_REG_LANE0_r                        (L2H_LANE_IE_REG_LANE0_r),
    .l2h_LANE_IE_REG_LANE1_r                        (L2H_LANE_IE_REG_LANE1_r),
    .l2h_LANE_IE_REG_LANE2_r                        (L2H_LANE_IE_REG_LANE2_r),
    .l2h_LANE_IE_REG_LANE3_r                        (L2H_LANE_IE_REG_LANE3_r),
    .l2h_LANE_IE_REG_LANE4_r                        (L2H_LANE_IE_REG_LANE4_r),
    .l2h_LANE_IE_REG_LANE5_r                        (L2H_LANE_IE_REG_LANE5_r),
    .l2h_LANE_IE_REG_LANE6_r                        (L2H_LANE_IE_REG_LANE6_r),
    .l2h_LANE_IE_REG_LANE7_r                        (L2H_LANE_IE_REG_LANE7_r),
    .l2h_LANE_IE_REG_LANE8_r                        (L2H_LANE_IE_REG_LANE8_r),
    .l2h_LANE_IE_REG_LANE9_r                        (L2H_LANE_IE_REG_LANE9_r),
    .l2h_LANE_START_REG_LANE0_r                     (L2H_LANE_START_REG_LANE0_r),
    .l2h_LANE_START_REG_LANE1_r                     (L2H_LANE_START_REG_LANE1_r),
    .l2h_LANE_START_REG_LANE2_r                     (L2H_LANE_START_REG_LANE2_r),
    .l2h_LANE_START_REG_LANE3_r                     (L2H_LANE_START_REG_LANE3_r),
    .l2h_LANE_START_REG_LANE4_r                     (L2H_LANE_START_REG_LANE4_r),
    .l2h_LANE_START_REG_LANE5_r                     (L2H_LANE_START_REG_LANE5_r),
    .l2h_LANE_START_REG_LANE6_r                     (L2H_LANE_START_REG_LANE6_r),
    .l2h_LANE_START_REG_LANE7_r                     (L2H_LANE_START_REG_LANE7_r),
    .l2h_LANE_START_REG_LANE8_r                     (L2H_LANE_START_REG_LANE8_r),
    .l2h_LANE_START_REG_LANE9_r                     (L2H_LANE_START_REG_LANE9_r),
    .l2h_LANE_CLEAR_REG_LANE0_r                     (L2H_LANE_CLEAR_REG_LANE0_r),
    .l2h_LANE_CLEAR_REG_LANE1_r                     (L2H_LANE_CLEAR_REG_LANE1_r),
    .l2h_LANE_CLEAR_REG_LANE2_r                     (L2H_LANE_CLEAR_REG_LANE2_r),
    .l2h_LANE_CLEAR_REG_LANE3_r                     (L2H_LANE_CLEAR_REG_LANE3_r),
    .l2h_LANE_CLEAR_REG_LANE4_r                     (L2H_LANE_CLEAR_REG_LANE4_r),
    .l2h_LANE_CLEAR_REG_LANE5_r                     (L2H_LANE_CLEAR_REG_LANE5_r),
    .l2h_LANE_CLEAR_REG_LANE6_r                     (L2H_LANE_CLEAR_REG_LANE6_r),
    .l2h_LANE_CLEAR_REG_LANE7_r                     (L2H_LANE_CLEAR_REG_LANE7_r),
    .l2h_LANE_CLEAR_REG_LANE8_r                     (L2H_LANE_CLEAR_REG_LANE8_r),
    .l2h_LANE_CLEAR_REG_LANE9_r                     (L2H_LANE_CLEAR_REG_LANE9_r),
    .l2h_LANE0_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE0_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE1_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE1_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE2_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE2_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE3_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE3_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE4_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE4_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE5_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE5_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE6_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE6_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE7_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE7_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE8_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE8_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE9_SEQUENCE_REG_SEQUENCE_r              (L2H_LANE9_SEQUENCE_REG_SEQUENCE_r),
    .l2h_LANE0_LENGTH_REG_LENGTH_r                  (L2H_LANE0_LENGTH_REG_LENGTH_r),
    .l2h_LANE1_LENGTH_REG_LENGTH_r                  (L2H_LANE1_LENGTH_REG_LENGTH_r),
    .l2h_LANE2_LENGTH_REG_LENGTH_r                  (L2H_LANE2_LENGTH_REG_LENGTH_r),
    .l2h_LANE3_LENGTH_REG_LENGTH_r                  (L2H_LANE3_LENGTH_REG_LENGTH_r),
    .l2h_LANE4_LENGTH_REG_LENGTH_r                  (L2H_LANE4_LENGTH_REG_LENGTH_r),
    .l2h_LANE5_LENGTH_REG_LENGTH_r                  (L2H_LANE5_LENGTH_REG_LENGTH_r),
    .l2h_LANE6_LENGTH_REG_LENGTH_r                  (L2H_LANE6_LENGTH_REG_LENGTH_r),
    .l2h_LANE7_LENGTH_REG_LENGTH_r                  (L2H_LANE7_LENGTH_REG_LENGTH_r),
    .l2h_LANE8_LENGTH_REG_LENGTH_r                  (L2H_LANE8_LENGTH_REG_LENGTH_r),
    .l2h_LANE9_LENGTH_REG_LENGTH_r                  (L2H_LANE9_LENGTH_REG_LENGTH_r),
    .d2h_dec_pio_read_data                          (regif_rdata),
    .d2h_dec_pio_ack                                (regif_ack),
    .d2h_dec_pio_nack                               (regif_nack)
  );

endmodule
