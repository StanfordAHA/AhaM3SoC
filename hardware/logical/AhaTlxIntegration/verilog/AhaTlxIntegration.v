//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TLX Integration
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaTlxIntegration (
  // Clock and Reset
  input   wire            TLX_SIB_CLK,    // Slave Interface Block Clock
  input   wire            TLX_SIB_RESETn, // SIB Reset
  input   wire            TLX_REV_CLK,    // REV Channel Clock
  input   wire            TLX_REV_RESETn, // TLX Reset sync'ed to TLX_REV_CLK

  output  wire            TLX_INT,        // TLX Interrupt

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

  // Slave Interface Block Signals
  input   wire [3:0]      TLX_AWID,
  input   wire [31:0]     TLX_AWADDR,
  input   wire [7:0]      TLX_AWLEN,
  input   wire [2:0]      TLX_AWSIZE,
  input   wire [1:0]      TLX_AWBURST,
  input   wire            TLX_AWLOCK,
  input   wire [3:0]      TLX_AWCACHE,
  input   wire [2:0]      TLX_AWPROT,
  input   wire            TLX_AWVALID,
  output  wire            TLX_AWREADY,
  input   wire [63:0]     TLX_WDATA,
  input   wire [7:0]      TLX_WSTRB,
  input   wire            TLX_WLAST,
  input   wire            TLX_WVALID,
  output  wire            TLX_WREADY,
  output  wire [3:0]      TLX_BID,
  output  wire [1:0]      TLX_BRESP,
  output  wire            TLX_BVALID,
  input   wire            TLX_BREADY,
  input   wire [3:0]      TLX_ARID,
  input   wire [31:0]     TLX_ARADDR,
  input   wire [7:0]      TLX_ARLEN,
  input   wire [2:0]      TLX_ARSIZE,
  input   wire [1:0]      TLX_ARBURST,
  input   wire            TLX_ARLOCK,
  input   wire [3:0]      TLX_ARCACHE,
  input   wire [2:0]      TLX_ARPROT,
  input   wire            TLX_ARVALID,
  output  wire            TLX_ARREADY,
  output  wire [3:0]      TLX_RID,
  output  wire [63:0]     TLX_RDATA,
  output  wire [1:0]      TLX_RRESP,
  output  wire            TLX_RLAST,
  output  wire            TLX_RVALID,
  input   wire            TLX_RREADY,

  // Forward Channel
  output  wire            TLX_FWD_PAYLOAD_TVALID,
  input   wire            TLX_FWD_PAYLOAD_TREADY,
  output  wire [39:0]     TLX_FWD_PAYLOAD_TDATA,

  output  wire            TLX_FWD_FLOW_TVALID,
  input   wire            TLX_FWD_FLOW_TREADY,
  output  wire [1:0]      TLX_FWD_FLOW_TDATA,

  // Reverse Channel
  input   wire            TLX_REV_PAYLOAD_TVALID,
  output  wire            TLX_REV_PAYLOAD_TREADY,
  input   wire [79:0]     TLX_REV_PAYLOAD_TDATA,

  input   wire            TLX_REV_FLOW_TVALID,
  output  wire            TLX_REV_FLOW_TREADY,
  input   wire [2:0]      TLX_REV_FLOW_TDATA
);

//------------------------------------------------------------------------------
// Data Wires Muxed with Training
//------------------------------------------------------------------------------
  // FWD
  //
  // 5 Lanes spread as follows:
  // - Lane0 (Output)   : TLX_FWD_PAYLOAD_TDATA[0]  -> Bottom Side of Chip (before RDL)
  // - Lane1 (Output)   : TLX_FWD_PAYLOAD_TDATA[16] -> Left Side of Chip (before RDL)
  // - Lane2 (Output)   : TLX_FWD_PAYLOAD_TDATA[39] -> Left Side of Chip (before RDL)
  // - Lane3 (Input)    : TLX_FWD_PAYLOAD_TREADY    -> Left Side of Chip (before RDL)
  // - Lane4 (Input)    : TLX_FWD_FLOW_TREADY       -> Left Side of Chip (before RDL)
  wire [39:0]   tlx_fwd_payload_tdata_w;
  wire [39:0]   tlx_fwd_payload_tdata_muxed;
  wire          tlx_fwd_data_lane_0;
  wire          tlx_fwd_data_lane_1;
  wire          tlx_fwd_data_lane_2;

  assign tlx_fwd_payload_tdata_muxed = {
    tlx_fwd_data_lane_2,
    tlx_fwd_payload_tdata_w[38:17],
    tlx_fwd_data_lane_1,
    tlx_fwd_payload_tdata_w[15:1],
    tlx_fwd_data_lane_0
  };

  assign TLX_FWD_PAYLOAD_TDATA = tlx_fwd_payload_tdata_muxed;

  // REV
  // 5 Lanes spread as follows:
  // - Lane0 (Input)   : TLX_REV_PAYLOAD_TDATA[0]   -> Right Side of Chip (before RDL)
  // - Lane1 (Input)   : TLX_REV_PAYLOAD_TDATA[24]  -> Right Side of Chip (before RDL)
  // - Lane2 (Input)   : TLX_REV_PAYLOAD_TDATA[64]  -> Bottom Side of Chip (before RDL)
  // - Lane3 (Output)  : TLX_REV_PAYLOAD_TREADY     -> Right Side of Chip (before RDL)
  // - Lane4 (Output)  : TLX_REV_FLOW_TREADY        -> Right Side of Chip (before RDL)
  wire          tlx_rev_flow_tready_w;
  wire          tlx_rev_payload_tready_w;
  wire          tlx_rev_data_lane3;
  wire          tlx_rev_data_lane4;

  assign TLX_REV_PAYLOAD_TREADY = tlx_rev_data_lane3;
  assign TLX_REV_FLOW_TREADY    = tlx_rev_data_lane4;

//------------------------------------------------------------------------------
// TLX Training Controller Integration
//------------------------------------------------------------------------------
  AhaTlxCtrl u_aha_tlx_ctrl (
    // Clock and Reset
    .TLX_SIB_CLK                              (TLX_SIB_CLK),
    .TLX_SIB_RESETn                           (TLX_SIB_RESETn),
    .TLX_REV_CLK                              (TLX_REV_CLK),
    .TLX_REV_RESETn                           (TLX_REV_RESETn),

    // RegSpace
    .TLX_HADDR                                (TLX_HADDR),
    .TLX_HBURST                               (TLX_HBURST),
    .TLX_HPROT                                (TLX_HPROT),
    .TLX_HSIZE                                (TLX_HSIZE),
    .TLX_HTRANS                               (TLX_HTRANS),
    .TLX_HWDATA                               (TLX_HWDATA),
    .TLX_HWRITE                               (TLX_HWRITE),
    .TLX_HRDATA                               (TLX_HRDATA),
    .TLX_HREADYOUT                            (TLX_HREADYOUT),
    .TLX_HRESP                                (TLX_HRESP),
    .TLX_HSELx                                (TLX_HSELx),
    .TLX_HREADY                               (TLX_HREADY),

    // FWD Channel
    .FWD_LANE0_IN                             (tlx_fwd_payload_tdata_w[0]),
    .FWD_LANE0_OUT                            (tlx_fwd_data_lane_0),
    .FWD_LANE1_IN                             (tlx_fwd_payload_tdata_w[16]),
    .FWD_LANE1_OUT                            (tlx_fwd_data_lane_1),
    .FWD_LANE2_IN                             (tlx_fwd_payload_tdata_w[39]),
    .FWD_LANE2_OUT                            (tlx_fwd_data_lane_2),
    .FWD_LANE3_IN                             (TLX_FWD_PAYLOAD_TREADY),
    .FWD_LANE4_IN                             (TLX_FWD_FLOW_TREADY),

    // REV Channel
    .REV_LANE0_IN                             (TLX_REV_PAYLOAD_TDATA[0]),
    .REV_LANE1_IN                             (TLX_REV_PAYLOAD_TDATA[24]),
    .REV_LANE2_IN                             (TLX_REV_PAYLOAD_TDATA[64]),
    .REV_LANE3_IN                             (tlx_rev_payload_tready_w),
    .REV_LANE3_OUT                            (tlx_rev_data_lane3),
    .REV_LANE4_IN                             (tlx_rev_flow_tready_w),
    .REV_LANE4_OUT                            (tlx_rev_data_lane4),

    // Interrupts
    .TLX_INT                                  (TLX_INT)
  );

//------------------------------------------------------------------------------
// TLX Slave Domain Integration
//------------------------------------------------------------------------------
  nic400_slave_pwr_M1_m_tlx_tlx_AhaIntegration     u_slave_pwr_M1_m_tlx (
    // Interface between SIB and System Interconnect
    .awid_m1_m_s                              (TLX_AWID),
    .awaddr_m1_m_s                            (TLX_AWADDR),
    .awlen_m1_m_s                             (TLX_AWLEN),
    .awsize_m1_m_s                            (TLX_AWSIZE),
    .awburst_m1_m_s                           (TLX_AWBURST),
    .awlock_m1_m_s                            (TLX_AWLOCK),
    .awcache_m1_m_s                           (TLX_AWCACHE),
    .awprot_m1_m_s                            (TLX_AWPROT),
    .awvalid_m1_m_s                           (TLX_AWVALID),
    .awready_m1_m_s                           (TLX_AWREADY),
    .wdata_m1_m_s                             (TLX_WDATA),
    .wstrb_m1_m_s                             (TLX_WSTRB),
    .wlast_m1_m_s                             (TLX_WLAST),
    .wvalid_m1_m_s                            (TLX_WVALID),
    .wready_m1_m_s                            (TLX_WREADY),
    .bid_m1_m_s                               (TLX_BID),
    .bresp_m1_m_s                             (TLX_BRESP),
    .bvalid_m1_m_s                            (TLX_BVALID),
    .bready_m1_m_s                            (TLX_BREADY),
    .arid_m1_m_s                              (TLX_ARID),
    .araddr_m1_m_s                            (TLX_ARADDR),
    .arlen_m1_m_s                             (TLX_ARLEN),
    .arsize_m1_m_s                            (TLX_ARSIZE),
    .arburst_m1_m_s                           (TLX_ARBURST),
    .arlock_m1_m_s                            (TLX_ARLOCK),
    .arcache_m1_m_s                           (TLX_ARCACHE),
    .arprot_m1_m_s                            (TLX_ARPROT),
    .arvalid_m1_m_s                           (TLX_ARVALID),
    .arready_m1_m_s                           (TLX_ARREADY),
    .rid_m1_m_s                               (TLX_RID),
    .rdata_m1_m_s                             (TLX_RDATA),
    .rresp_m1_m_s                             (TLX_RRESP),
    .rlast_m1_m_s                             (TLX_RLAST),
    .rvalid_m1_m_s                            (TLX_RVALID),
    .rready_m1_m_s                            (TLX_RREADY),

    // FWD Channel
    .clk_sclk                                 (TLX_SIB_CLK),
    .clk_sresetn                              (TLX_SIB_RESETn),

    .tvalid_m1_m_tlx_fwd_ib_axi_stream        (TLX_FWD_PAYLOAD_TVALID),
    .tready_m1_m_tlx_fwd_ib_axi_stream        (TLX_FWD_PAYLOAD_TREADY),
    .tdata_m1_m_tlx_fwd_ib_axi_stream         (tlx_fwd_payload_tdata_w),

    .tvalid_m1_m_tlx_fwd_ib_flow              (TLX_FWD_FLOW_TVALID),
    .tready_m1_m_tlx_fwd_ib_flow              (TLX_FWD_FLOW_TREADY),
    .tdata_m1_m_tlx_fwd_ib_flow               (TLX_FWD_FLOW_TDATA),

    // REV Channel
    .dl_rev_M1_m_tlxclk                       (TLX_REV_CLK),
    .dl_rev_M1_m_tlxresetn                    (TLX_REV_RESETn),

    .tvalid_m1_m_tlx_pl_rev_to_dl_rev_data    (TLX_REV_PAYLOAD_TVALID),
    .tready_m1_m_tlx_pl_rev_to_dl_rev_data    (tlx_rev_payload_tready_w),
    .tdata_m1_m_tlx_pl_rev_to_dl_rev_data     (TLX_REV_PAYLOAD_TDATA),

    .tvalid_m1_m_tlx_pl_rev_to_dl_rev_flow    (TLX_REV_FLOW_TVALID),
    .tready_m1_m_tlx_pl_rev_to_dl_rev_flow    (tlx_rev_flow_tready_w),
    .tdata_m1_m_tlx_pl_rev_to_dl_rev_flow     (TLX_REV_FLOW_TDATA)
  );

endmodule
