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

  output  wire            TLX_FWD_CLK,    // TLX Forward Channel Clock

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

  // SIB and Reverse DL Integration
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
    .tdata_m1_m_tlx_fwd_ib_axi_stream         (TLX_FWD_PAYLOAD_TDATA),

    .tvalid_m1_m_tlx_fwd_ib_flow              (TLX_FWD_FLOW_TVALID),
    .tready_m1_m_tlx_fwd_ib_flow              (TLX_FWD_FLOW_TREADY),
    .tdata_m1_m_tlx_fwd_ib_flow               (TLX_FWD_FLOW_TDATA),

    // REV Channel
    .dl_rev_M1_m_tlxclk                       (TLX_REV_CLK),
    .dl_rev_M1_m_tlxresetn                    (TLX_REV_RESETn),

    .tvalid_m1_m_tlx_pl_rev_to_dl_rev_data    (TLX_REV_PAYLOAD_TVALID),
    .tready_m1_m_tlx_pl_rev_to_dl_rev_data    (TLX_REV_PAYLOAD_TREADY),
    .tdata_m1_m_tlx_pl_rev_to_dl_rev_data     (TLX_REV_PAYLOAD_TDATA),

    .tvalid_m1_m_tlx_pl_rev_to_dl_rev_flow    (TLX_REV_FLOW_TVALID),
    .tready_m1_m_tlx_pl_rev_to_dl_rev_flow    (TLX_REV_FLOW_TREADY),
    .tdata_m1_m_tlx_pl_rev_to_dl_rev_flow     (TLX_REV_FLOW_TDATA)
  );

  assign TLX_FWD_CLK = TLX_SIB_CLK;
endmodule
