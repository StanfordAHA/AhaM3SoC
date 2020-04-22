module tlx_master_dom (
  // Forward Link
  input   wire            tlx_fwd_clk,
  input   wire            tlx_fwd_reset_n,

  input   wire            tlx_fwd_payload_tvalid,
  output  wire            tlx_fwd_payload_tready,
  input   wire [39:0]     tlx_fwd_payload_tdata,

  input   wire            tlx_fwd_flow_tvalid,
  output  wire            tlx_fwd_flow_tready,
  input   wire [1:0]      tlx_fwd_flow_tdata,

  // Reverse Link
  input   wire            tlx_rev_clk,
  input   wire            tlx_rev_reset_n,

  output  wire            tlx_rev_payload_tvalid,
  input   wire            tlx_rev_payload_tready,
  output  wire [79:0]     tlx_rev_payload_tdata,

  output  wire            tlx_rev_flow_tvalid,
  input   wire            tlx_rev_flow_tready,
  output  wire [2:0]      tlx_rev_flow_tdata,

  // AXI Master
  output  wire [3:0]      awid,
  output  wire [31:0]     awaddr,
  output  wire [7:0]      awlen,
  output  wire [2:0]      awsize,
  output  wire [1:0]      awburst,
  output  wire            awlock,
  output  wire [3:0]      awcache,
  output  wire [2:0]      awprot,
  output  wire            awvalid,
  input   wire            awready,

  output  wire [63:0]     wdata,
  output  wire [7:0]      wstrb,
  output  wire            wlast,
  output  wire            wvalid,
  input   wire            wready,

  input   wire [3:0]      bid,
  input   wire [1:0]      bresp,
  input   wire            bvalid,
  output  wire            bready,

  output  wire [3:0]      arid,
  output  wire [31:0]     araddr,
  output  wire [7:0]      arlen,
  output  wire [2:0]      arsize,
  output  wire [1:0]      arburst,
  output  wire            arlock,
  output  wire [3:0]      arcache,
  output  wire [2:0]      arprot,
  output  wire            arvalid,
  input   wire            arready,

  input   wire [3:0]      rid,
  input   wire [63:0]     rdata,
  input   wire [1:0]      rresp,
  input   wire            rlast,
  input   wire            rvalid,
  output  wire            rready
);

  // TLX Master Domain
  nic400_master_pwr_M1_m_tlx_tlx_AhaIntegration     u_master_pwr_M1_m_tlx (
    // Master Interface Block Signals
    .awid_m1_m_m                              (awid),
    .awaddr_m1_m_m                            (awaddr),
    .awlen_m1_m_m                             (awlen),
    .awsize_m1_m_m                            (awsize),
    .awburst_m1_m_m                           (awburst),
    .awlock_m1_m_m                            (awlock),
    .awcache_m1_m_m                           (awcache),
    .awprot_m1_m_m                            (awprot),
    .awvalid_m1_m_m                           (awvalid),
    .awready_m1_m_m                           (awready),
    .wdata_m1_m_m                             (wdata),
    .wstrb_m1_m_m                             (wstrb),
    .wlast_m1_m_m                             (wlast),
    .wvalid_m1_m_m                            (wvalid),
    .wready_m1_m_m                            (wready),
    .bid_m1_m_m                               (bid),
    .bresp_m1_m_m                             (bresp),
    .bvalid_m1_m_m                            (bvalid),
    .bready_m1_m_m                            (bready),
    .arid_m1_m_m                              (arid),
    .araddr_m1_m_m                            (araddr),
    .arlen_m1_m_m                             (arlen),
    .arsize_m1_m_m                            (arsize),
    .arburst_m1_m_m                           (arburst),
    .arlock_m1_m_m                            (arlock),
    .arcache_m1_m_m                           (arcache),
    .arprot_m1_m_m                            (arprot),
    .arvalid_m1_m_m                           (arvalid),
    .arready_m1_m_m                           (arready),
    .rid_m1_m_m                               (rid),
    .rdata_m1_m_m                             (rdata),
    .rresp_m1_m_m                             (rresp),
    .rlast_m1_m_m                             (rlast),
    .rvalid_m1_m_m                            (rvalid),
    .rready_m1_m_m                            (rready),

    // FWD Channel Signals
    .dl_fwd_M1_m_tlxclk                       (tlx_fwd_clk),
    .dl_fwd_M1_m_tlxresetn                    (tlx_fwd_reset_n),

    .tvalid_m1_m_tlx_pl_fwd_to_dl_fwd_data    (tlx_fwd_payload_tvalid),
    .tready_m1_m_tlx_pl_fwd_to_dl_fwd_data    (tlx_fwd_payload_tready),
    .tdata_m1_m_tlx_pl_fwd_to_dl_fwd_data     (tlx_fwd_payload_tdata),

    .tvalid_m1_m_tlx_pl_fwd_to_dl_fwd_flow    (tlx_fwd_flow_tvalid),
    .tready_m1_m_tlx_pl_fwd_to_dl_fwd_flow    (tlx_fwd_flow_tready),
    .tdata_m1_m_tlx_pl_fwd_to_dl_fwd_flow     (tlx_fwd_flow_tdata),

    // REV Channel Signals
    .clk_mclk                                 (tlx_rev_clk),
    .clk_mresetn                              (tlx_rev_reset_n),

    .tvalid_m1_m_tlx_tlx_m_to_pl_rev_data     (tlx_rev_payload_tvalid),
    .tready_m1_m_tlx_tlx_m_to_pl_rev_data     (tlx_rev_payload_tready),
    .tdata_m1_m_tlx_tlx_m_to_pl_rev_data      (tlx_rev_payload_tdata),

    .tvalid_m1_m_tlx_tlx_m_to_pl_rev_flow     (tlx_rev_flow_tvalid),
    .tready_m1_m_tlx_tlx_m_to_pl_rev_flow     (tlx_rev_flow_tready),
    .tdata_m1_m_tlx_tlx_m_to_pl_rev_flow      (tlx_rev_flow_tdata)
  );


endmodule
