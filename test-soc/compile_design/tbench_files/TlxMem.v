//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Model for FPGA TLX Domain
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 25, 2022  : Move from IntMemAXI to AXItoSRAM Interface
//------------------------------------------------------------------------------

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
  wire [3:0]                awid;
  wire [31:0]               awaddr;
  wire [7:0]                awlen;
  wire [2:0]                awsize;
  wire [1:0]                awburst;
  wire                      awlock;
  wire [3:0]                awcache;
  wire [2:0]                awprot;
  wire                      awvalid;
  wire                      awready;

  wire [63:0]               wdata;
  wire [7:0]                wstrb;
  wire                      wlast;
  wire                      wvalid;
  wire                      wready;

  wire [3:0]                bid;
  wire [1:0]                bresp;
  wire                      bvalid;
  wire                      bready;

  wire [3:0]                arid;
  wire [31:0]               araddr;
  wire [7:0]                arlen;
  wire [2:0]                arsize;
  wire [1:0]                arburst;
  wire                      arlock;
  wire [3:0]                arcache;
  wire [2:0]                arprot;
  wire                      arvalid;
  wire                      arready;

  wire [3:0]                rid;
  wire [63:0]               rdata;
  wire [1:0]                rresp;
  wire                      rlast;
  wire                      rvalid;
  wire                      rready;

  wire                      sram_ce_n;
  wire [31:0]               sram_addr;
  wire [63:0]               sram_wdata;
  wire                      sram_we_n;
  wire [7:0]                sram_wbe_n;
  wire [63:0]               sram_rdata;
  wire [7:0]                w_SRAM_WBE_n;

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
    .awid                           (awid),
    .awaddr                         (awaddr),
    .awlen                          (awlen),
    .awsize                         (awsize),
    .awburst                        (awburst),
    .awlock                         (awlock),
    .awcache                        (awcache),
    .awprot                         (awprot),
    .awvalid                        (awvalid),
    .awready                        (awready),

    .wdata                          (wdata),
    .wstrb                          (wstrb),
    .wlast                          (wlast),
    .wvalid                         (wvalid),
    .wready                         (wready),

    .bid                            (bid),
    .bresp                          (bresp),
    .bvalid                         (bvalid),
    .bready                         (bready),

    .arid                           (arid),
    .araddr                         (araddr),
    .arlen                          (arlen),
    .arsize                         (arsize),
    .arburst                        (arburst),
    .arlock                         (arlock),
    .arcache                        (arcache),
    .arprot                         (arprot),
    .arvalid                        (arvalid),
    .arready                        (arready),

    .rid                            (rid),
    .rdata                          (rdata),
    .rresp                          (rresp),
    .rlast                          (rlast),
    .rvalid                         (rvalid),
    .rready                         (rready)
  );

  //
  //    AXI to SRAM Converter
  //

  AXItoSRAM u_axi_to_sram (
      .ACLK                         (tlx_rev_clk),
      .ARESETn                      (tlx_rev_reset_n),

      .S_AXI_AWID                   (awid),
      .S_AXI_AWADDR                 (awaddr),
      .S_AXI_AWLEN                  (awlen),
      .S_AXI_AWSIZE                 (awsize),
      .S_AXI_AWBURST                (awburst),
      .S_AXI_AWLOCK                 (awlock),
      .S_AXI_AWCACHE                (awcache),
      .S_AXI_AWPROT                 (awprot),
      .S_AXI_AWVALID                (awvalid),
      .S_AXI_AWREADY                (awready),
      .S_AXI_WDATA                  (wdata),
      .S_AXI_WSTRB                  (wstrb),
      .S_AXI_WLAST                  (wlast),
      .S_AXI_WVALID                 (wvalid),
      .S_AXI_WREADY                 (wready),
      .S_AXI_BID                    (bid),
      .S_AXI_BRESP                  (bresp),
      .S_AXI_BVALID                 (bvalid),
      .S_AXI_BREADY                 (bready),
      .S_AXI_ARID                   (arid),
      .S_AXI_ARADDR                 (araddr),
      .S_AXI_ARLEN                  (arlen),
      .S_AXI_ARSIZE                 (arsize),
      .S_AXI_ARBURST                (arburst),
      .S_AXI_ARLOCK                 (arlock),
      .S_AXI_ARCACHE                (arcache),
      .S_AXI_ARPROT                 (arprot),
      .S_AXI_ARVALID                (arvalid),
      .S_AXI_ARREADY                (arready),
      .S_AXI_RID                    (rid),
      .S_AXI_RDATA                  (rdata),
      .S_AXI_RRESP                  (rresp),
      .S_AXI_RLAST                  (rlast),
      .S_AXI_RVALID                 (rvalid),
      .S_AXI_RREADY                 (rready),

      .SRAM_CEn                     (sram_ce_n),
      .SRAM_ADDR                    (sram_addr),
      .SRAM_WDATA                   (sram_wdata),
      .SRAM_WEn                     (sram_we_n),
      .SRAM_WBEn                    (sram_wbe_n),
      .SRAM_RDATA                   (sram_rdata)
  );

    //
    // TLX SRAM Wrapper Instantiation
    //

    assign w_SRAM_WBE_n               = {8{sram_we_n}} | sram_wbe_n;

    AhaSramSimGen #(
        .ADDR_WIDTH                 (27),
        .DATA_WIDTH                 (64),
        .IMAGE_FILE                 ("TLXIMAGE.hex")
    ) u_aha_sram_mem (
        .CLK                        (tlx_rev_clk),
        .RESETn                     (tlx_rev_reset_n),
        .CS                         (~sram_ce_n),
        .WE                         (~w_SRAM_WBE_n),
        .ADDR                       (sram_addr[29:3]),
        .WDATA                      (sram_wdata),
        .RDATA                      (sram_rdata)
    );



  /*
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
  */

endmodule
