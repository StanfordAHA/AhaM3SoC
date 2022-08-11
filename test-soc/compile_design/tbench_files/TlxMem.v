module TlxMem (
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
  output  wire [2:0]      tlx_rev_flow_tdata
);

  // AXI Master
  wire [3:0]      awid;
  wire [31:0]     awaddr;
  wire [7:0]      awlen;
  wire [2:0]      awsize;
  wire [1:0]      awburst;
  wire            awlock;
  wire [3:0]      awcache;
  wire [2:0]      awprot;
  wire            awvalid;
  wire            awready;

  wire [63:0]     wdata;
  wire [7:0]      wstrb;
  wire            wlast;
  wire            wvalid;
  wire            wready;

  wire [3:0]      bid;
  wire [1:0]      bresp;
  wire            bvalid;
  wire            bready;

  wire [3:0]      arid;
  wire [31:0]     araddr;
  wire [7:0]      arlen;
  wire [2:0]      arsize;
  wire [1:0]      arburst;
  wire            arlock;
  wire [3:0]      arcache;
  wire [2:0]      arprot;
  wire            arvalid;
  wire            arready;

  wire [3:0]      rid;
  wire [63:0]     rdata;
  wire [1:0]      rresp;
  wire            rlast;
  wire            rvalid;
  wire            rready;

  // tlx master domain
  tlx_master_dom tlx_master(
    // Forward Link
    .tlx_fwd_clk                    (tlx_fwd_clk),
    .tlx_fwd_reset_n                (tlx_fwd_reset_n),

    .tlx_fwd_payload_tvalid         (tlx_fwd_payload_tvalid),
    .tlx_fwd_payload_tready         (tlx_fwd_payload_tready),
    .tlx_fwd_payload_tdata          (tlx_fwd_payload_tdata),

    .tlx_fwd_flow_tvalid            (tlx_fwd_flow_tvalid),
    .tlx_fwd_flow_tready            (tlx_fwd_flow_tready),
    .tlx_fwd_flow_tdata             (tlx_fwd_flow_tdata),

    // Reverse Link
    .tlx_rev_clk                    (tlx_rev_clk),
    .tlx_rev_reset_n                (tlx_rev_reset_n),

    .tlx_rev_payload_tvalid         (tlx_rev_payload_tvalid),
    .tlx_rev_payload_tready         (tlx_rev_payload_tready),
    .tlx_rev_payload_tdata          (tlx_rev_payload_tdata),

    .tlx_rev_flow_tvalid            (tlx_rev_flow_tvalid),
    .tlx_rev_flow_tready            (tlx_rev_flow_tready),
    .tlx_rev_flow_tdata             (tlx_rev_flow_tdata),

    // AXI Master
    .awid               (awid),
    .awaddr             (awaddr),
    .awlen              (awlen),
    .awsize             (awsize),
    .awburst            (awburst),
    .awlock             (awlock),
    .awcache            (awcache),
    .awprot             (awprot),
    .awvalid            (awvalid),
    .awready            (awready),

    .wdata              (wdata),
    .wstrb              (wstrb),
    .wlast              (wlast),
    .wvalid             (wvalid),
    .wready             (wready),

    .bid                (bid),
    .bresp              (bresp),
    .bvalid             (bvalid),
    .bready             (bready),

    .arid               (arid),
    .araddr             (araddr),
    .arlen              (arlen),
    .arsize             (arsize),
    .arburst            (arburst),
    .arlock             (arlock),
    .arcache            (arcache),
    .arprot             (arprot),
    .arvalid            (arvalid),
    .arready            (arready),

    .rid                (rid),
    .rdata              (rdata),
    .rresp              (rresp),
    .rlast              (rlast),
    .rvalid             (rvalid),
    .rready             (rready)
  );

  // memory
  AxiSram #(
    .DATA_WIDTH(64),
    .ID_WIDTH(4),
    .NUM_RD_WS(0),
    .IS_ROM(1'b0),
    .MEM_ADDR_WIDTH(27),
    .MEM_INIT_FILE_0("image.hex"),
    .MEM_INIT_FILE_1("image.hex")
  ) mem (
    .ACLK                (tlx_rev_clk),
    .ARESETn             (tlx_rev_reset_n),

    .AWID                (awid),
    .AWADDR              (awaddr),
    .AWLEN               (awlen),
    .AWSIZE              (awsize),
    .AWBURST             (awburst),
    .AWVALID             (awvalid),
    .AWREADY             (awready),
    .WSTRB               (wstrb),
    .WLAST               (wlast),
    .WDATA               (wdata),
    .WVALID              (wvalid),
    .WREADY              (wready),
    .BID                 (bid),
    .BRESP               (bresp),
    .BVALID              (bvalid),
    .BREADY              (bready),
    .ARID                (arid),
    .ARADDR              (araddr),
    .ARLEN               (arlen),
    .ARSIZE              (arsize),
    .ARBURST             (arburst),
    .ARVALID             (arvalid),
    .ARREADY             (arready),
    .RID                 (rid),
    .RRESP               (rresp),
    .RDATA               (rdata),
    .RLAST               (rlast),
    .RVALID              (rvalid),
    .RREADY              (rready),

    .SCANENABLE          (1'b0),
    .SCANINACLK          (1'b0),
    .SCANOUTACLK         ()
  );
endmodule
