//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC Garnet CGRA Integration
//------------------------------------------------------------------------------
// Note: The following macros are used
//       - NO_CGRA : define this for CGRA exclusion
//       - CGRA_RD_WS: number of wait states for read transactions
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaGarnetIntegration (
  // Clock and Reset
  input   wire            CGRA_CLK,           // CGRA Clock
  input   wire            CGRA_RESETn,        // CGRA PowerOn Reset

  // Interrupt Interface
  output  wire            CGRA_INT,           // CGRA Interrupt Signal

  // Data Interface
  input   wire [3 :0]     CGRA_DATA_AWID,
  input   wire [31:0]     CGRA_DATA_AWADDR,
  input   wire [7 :0]     CGRA_DATA_AWLEN,
  input   wire [2 :0]     CGRA_DATA_AWSIZE,
  input   wire [1 :0]     CGRA_DATA_AWBURST,
  input   wire            CGRA_DATA_AWLOCK,
  input   wire [3 :0]     CGRA_DATA_AWCACHE,
  input   wire [2 :0]     CGRA_DATA_AWPROT,
  input   wire            CGRA_DATA_AWVALID,
  output  wire            CGRA_DATA_AWREADY,
  input   wire [63:0]     CGRA_DATA_WDATA,
  input   wire [7 :0]     CGRA_DATA_WSTRB,
  input   wire            CGRA_DATA_WLAST,
  input   wire            CGRA_DATA_WVALID,
  output  wire            CGRA_DATA_WREADY,
  output  wire [3 :0]     CGRA_DATA_BID,
  output  wire [1 :0]     CGRA_DATA_BRESP,
  output  wire            CGRA_DATA_BVALID,
  input   wire            CGRA_DATA_BREADY,
  input   wire [3 :0]     CGRA_DATA_ARID,
  input   wire [31:0]     CGRA_DATA_ARADDR,
  input   wire [7 :0]     CGRA_DATA_ARLEN,
  input   wire [2 :0]     CGRA_DATA_ARSIZE,
  input   wire [1 :0]     CGRA_DATA_ARBURST,
  input   wire            CGRA_DATA_ARLOCK,
  input   wire [3 :0]     CGRA_DATA_ARCACHE,
  input   wire [2 :0]     CGRA_DATA_ARPROT,
  input   wire            CGRA_DATA_ARVALID,
  output  wire            CGRA_DATA_ARREADY,
  output  wire [3 :0]     CGRA_DATA_RID,
  output  wire [63:0]     CGRA_DATA_RDATA,
  output  wire [1 :0]     CGRA_DATA_RRESP,
  output  wire            CGRA_DATA_RLAST,
  output  wire            CGRA_DATA_RVALID,
  input   wire            CGRA_DATA_RREADY,

  // Register Interface
  input   wire [3:0]      CGRA_REG_AWID,
  input   wire [31:0]     CGRA_REG_AWADDR,
  input   wire [7:0]      CGRA_REG_AWLEN,
  input   wire [2:0]      CGRA_REG_AWSIZE,
  input   wire [1:0]      CGRA_REG_AWBURST,
  input   wire            CGRA_REG_AWLOCK,
  input   wire [3:0]      CGRA_REG_AWCACHE,
  input   wire [2:0]      CGRA_REG_AWPROT,
  input   wire            CGRA_REG_AWVALID,
  output  wire            CGRA_REG_AWREADY,
  input   wire [31:0]     CGRA_REG_WDATA,
  input   wire [3:0]      CGRA_REG_WSTRB,
  input   wire            CGRA_REG_WLAST,
  input   wire            CGRA_REG_WVALID,
  output  wire            CGRA_REG_WREADY,
  output  wire [3:0]      CGRA_REG_BID,
  output  wire [1:0]      CGRA_REG_BRESP,
  output  wire            CGRA_REG_BVALID,
  input   wire            CGRA_REG_BREADY,
  input   wire [3:0]      CGRA_REG_ARID,
  input   wire [31:0]     CGRA_REG_ARADDR,
  input   wire [7:0]      CGRA_REG_ARLEN,
  input   wire [2:0]      CGRA_REG_ARSIZE,
  input   wire [1:0]      CGRA_REG_ARBURST,
  input   wire            CGRA_REG_ARLOCK,
  input   wire [3:0]      CGRA_REG_ARCACHE,
  input   wire [2:0]      CGRA_REG_ARPROT,
  input   wire            CGRA_REG_ARVALID,
  output  wire            CGRA_REG_ARREADY,
  output  wire [3:0]      CGRA_REG_RID,
  output  wire [31:0]     CGRA_REG_RDATA,
  output  wire [1:0]      CGRA_REG_RRESP,
  output  wire            CGRA_REG_RLAST,
  output  wire            CGRA_REG_RVALID,
  input   wire            CGRA_REG_RREADY
);

  `ifndef NO_CGRA
    // AXI-to-AXI-Lite
    wire [31:0]           slave_araddr;
    wire                  slave_arready;
    wire                  slave_arvalid;

    wire [31:0]           slave_awaddr;
    wire                  slave_awready;
    wire                  slave_awvalid;

    wire                  slave_bready;
    wire [1:0]            slave_bresp;
    wire                  slave_bvalid;

    wire [31:0]           slave_rdata;
    wire                  slave_rready;
    wire [1:0]            slave_rresp;
    wire                  slave_rvalid;

    wire [31:0]           slave_wdata;
    wire                  slave_wready;
    wire                  slave_wvalid;

    AhaAxiToAxiLite #(.ID_WIDTH(4)) u_axi_to_lite (
      .ACLK                           (CGRA_CLK),
      .ARESETn                        (CGRA_RESETn),

      .AXI_AWID                       (CGRA_REG_AWID),
      .AXI_AWADDR                     (CGRA_REG_AWADDR),
      .AXI_AWLEN                      (CGRA_REG_AWLEN),
      .AXI_AWSIZE                     (CGRA_REG_AWSIZE),
      .AXI_AWBURST                    (CGRA_REG_AWBURST),
      .AXI_AWLOCK                     (CGRA_REG_AWLOCK),
      .AXI_AWCACHE                    (CGRA_REG_AWCACHE),
      .AXI_AWPROT                     (CGRA_REG_AWPROT),
      .AXI_AWVALID                    (CGRA_REG_AWVALID),
      .AXI_AWREADY                    (CGRA_REG_AWREADY),
      .AXI_WDATA                      (CGRA_REG_WDATA),
      .AXI_WSTRB                      (CGRA_REG_WSTRB),
      .AXI_WLAST                      (CGRA_REG_WLAST),
      .AXI_WVALID                     (CGRA_REG_WVALID),
      .AXI_WREADY                     (CGRA_REG_WREADY),
      .AXI_BID                        (CGRA_REG_BID),
      .AXI_BRESP                      (CGRA_REG_BRESP),
      .AXI_BVALID                     (CGRA_REG_BVALID),
      .AXI_BREADY                     (CGRA_REG_BREADY),
      .AXI_ARID                       (CGRA_REG_ARID),
      .AXI_ARADDR                     (CGRA_REG_ARADDR),
      .AXI_ARLEN                      (CGRA_REG_ARLEN),
      .AXI_ARSIZE                     (CGRA_REG_ARSIZE),
      .AXI_ARBURST                    (CGRA_REG_ARBURST),
      .AXI_ARLOCK                     (CGRA_REG_ARLOCK),
      .AXI_ARCACHE                    (CGRA_REG_ARCACHE),
      .AXI_ARPROT                     (CGRA_REG_ARPROT),
      .AXI_ARVALID                    (CGRA_REG_ARVALID),
      .AXI_ARREADY                    (CGRA_REG_ARREADY),
      .AXI_RID                        (CGRA_REG_RID),
      .AXI_RDATA                      (CGRA_REG_RDATA),
      .AXI_RRESP                      (CGRA_REG_RRESP),
      .AXI_RLAST                      (CGRA_REG_RLAST),
      .AXI_RVALID                     (CGRA_REG_RVALID),
      .AXI_RREADY                     (CGRA_REG_RREADY),

      .LITE_AWADDR                    (slave_awaddr),
      .LITE_AWVALID                   (slave_awvalid),
      .LITE_AWREADY                   (slave_awready),
      .LITE_WDATA                     (slave_wdata),
      .LITE_WSTRB                     (/*unused*/),
      .LITE_WVALID                    (slave_wvalid),
      .LITE_WREADY                    (slave_wready),
      .LITE_BRESP                     (slave_bresp),
      .LITE_BVALID                    (slave_bvalid),
      .LITE_BREADY                    (slave_bready),
      .LITE_ARADDR                    (slave_araddr),
      .LITE_ARVALID                   (slave_arvalid),
      .LITE_ARREADY                   (slave_arready),
      .LITE_RDATA                     (slave_rdata),
      .LITE_RRESP                     (slave_rresp),
      .LITE_RVALID                    (slave_rvalid),
      .LITE_RREADY                    (slave_rready)
    );

    // AXI to Simple CGRA Data Interface
    wire [31:0]           sif_wr_addr;
    wire [7:0]            sif_wr_en;
    wire [63:0]           sif_wr_data;

    wire [31:0]           sif_rd_addr;
    wire                  sif_rd_en;
    wire [63:0]           sif_rd_dat;

    AhaAxiToSimpleIf #(.ID_WIDTH(4), .CGRA_RD_WS(`CGRA_RD_WS)) u_axi_to_sif (
      .ACLK                           (CGRA_CLK),
      .ARESETn                        (CGRA_RESETn),

      .AWID                           (CGRA_DATA_AWID),
      .AWADDR                         (CGRA_DATA_AWADDR),
      .AWLEN                          (CGRA_DATA_AWLEN),
      .AWSIZE                         (CGRA_DATA_AWSIZE),
      .AWBURST                        (CGRA_DATA_AWBURST),
      .AWLOCK                         (CGRA_DATA_AWLOCK),
      .AWCACHE                        (CGRA_DATA_AWCACHE),
      .AWPROT                         (CGRA_DATA_AWPROT),
      .AWVALID                        (CGRA_DATA_AWVALID),
      .AWREADY                        (CGRA_DATA_AWREADY),
      .WDATA                          (CGRA_DATA_WDATA),
      .WSTRB                          (CGRA_DATA_WSTRB),
      .WLAST                          (CGRA_DATA_WLAST),
      .WVALID                         (CGRA_DATA_WVALID),
      .WREADY                         (CGRA_DATA_WREADY),
      .BID                            (CGRA_DATA_BID),
      .BRESP                          (CGRA_DATA_BRESP),
      .BVALID                         (CGRA_DATA_BVALID),
      .BREADY                         (CGRA_DATA_BREADY),
      .ARID                           (CGRA_DATA_ARID),
      .ARADDR                         (CGRA_DATA_ARADDR),
      .ARLEN                          (CGRA_DATA_ARLEN),
      .ARSIZE                         (CGRA_DATA_ARSIZE),
      .ARBURST                        (CGRA_DATA_ARBURST),
      .ARLOCK                         (CGRA_DATA_ARLOCK),
      .ARCACHE                        (CGRA_DATA_ARCACHE),
      .ARPROT                         (CGRA_DATA_ARPROT),
      .ARVALID                        (CGRA_DATA_ARVALID),
      .ARREADY                        (CGRA_DATA_ARREADY),
      .RID                            (CGRA_DATA_RID),
      .RDATA                          (CGRA_DATA_RDATA),
      .RRESP                          (CGRA_DATA_RRESP),
      .RLAST                          (CGRA_DATA_RLAST),
      .RVALID                         (CGRA_DATA_RVALID),
      .RREADY                         (CGRA_DATA_RREADY),

      .SIF_WR_ADDR                    (sif_wr_addr),
      .SIF_WR_EN                      (sif_wr_en),
      .SIF_WR_DATA                    (sif_wr_data),
      .SIF_RD_ADDR                    (sif_rd_addr),
      .SIF_RD_EN                      (sif_rd_en),
      .SIF_RD_DATA                    (sif_rd_data)
    );

    // CGRA Instantiation
    Garnet u_garnet (
      .axi4_slave_araddr              (slave_araddr[12:0]),
      .axi4_slave_arready             (slave_arready),
      .axi4_slave_arvalid             (slave_arvalid),
      .axi4_slave_awaddr              (slave_awaddr[12:0]),
      .axi4_slave_awready             (slave_awready),
      .axi4_slave_awvalid             (slave_awvalid),
      .axi4_slave_bready              (slave_bready),
      .axi4_slave_bresp               (slave_bresp),
      .axi4_slave_bvalid              (slave_bvalid),
      .axi4_slave_rdata               (slave_rdata),
      .axi4_slave_rready              (slave_rready),
      .axi4_slave_rresp               (slave_rresp),
      .axi4_slave_rvalid              (slave_rvalid),
      .axi4_slave_wdata               (slave_wdata),
      .axi4_slave_wready              (slave_wready),
      .axi4_slave_wvalid              (slave_wvalid),

      .cgra_running_clk_out           (/*unused*/),
      .clk_in                         (CGRA_CLK),
      .reset_in                       (~CGRA_RESETn),

      .interrupt                      (CGRA_INT),

      .jtag_tck                       (1'b0),
      .jtag_tdi                       (1'b0),
      .jtag_tdo                       (/*unused*/),
      .jtag_tms                       (1'b0),
      .jtag_trst_n                    (1'b1),

      .proc_packet_rd_addr            (sif_rd_addr[18:0]),
      .proc_packet_rd_data            (sif_rd_data),
      .proc_packet_rd_data_valid      (/*unused*/),
      .proc_packet_rd_en              (sif_rd_en),

      .proc_packet_wr_addr            (sif_wr_addr[18:0]),
      .proc_packet_wr_data            (sif_wr_data),
      .proc_packet_wr_en              ((| sif_wr_en)),
      .proc_packet_wr_strb            (sif_wr_en)
    );
  `else
  wire unused = (| CGRA_DATA_AWID)    |
                (| CGRA_DATA_AWADDR)  |
                (| CGRA_DATA_AWLEN)   |
                (| CGRA_DATA_AWSIZE)  |
                (| CGRA_DATA_AWBURST) |
                (| CGRA_DATA_AWLOCK)  |
                (| CGRA_DATA_AWCACHE) |
                (| CGRA_DATA_AWPROT)  |
                (| CGRA_DATA_AWVALID) |
                (| CGRA_DATA_WDATA)   |
                (| CGRA_DATA_WSTRB)   |
                (| CGRA_DATA_WLAST)   |
                (| CGRA_DATA_WVALID)  |
                (| CGRA_DATA_BREADY)  |
                (| CGRA_DATA_ARID)    |
                (| CGRA_DATA_ARADDR)  |
                (| CGRA_DATA_ARLEN)   |
                (| CGRA_DATA_ARSIZE)  |
                (| CGRA_DATA_ARBURST) |
                (| CGRA_DATA_ARLOCK)  |
                (| CGRA_DATA_ARCACHE) |
                (| CGRA_DATA_ARPROT)  |
                (| CGRA_DATA_ARVALID) |
                (| CGRA_DATA_RREADY)  |
                (| CGRA_REG_AWID)     |
                (| CGRA_REG_AWADDR)   |
                (| CGRA_REG_AWLEN)    |
                (| CGRA_REG_AWSIZE)   |
                (| CGRA_REG_AWBURST)  |
                (| CGRA_REG_AWLOCK)   |
                (| CGRA_REG_AWCACHE)  |
                (| CGRA_REG_AWPROT)   |
                (| CGRA_REG_AWVALID)  |
                (| CGRA_REG_WDATA)    |
                (| CGRA_REG_WSTRB)    |
                (| CGRA_REG_WLAST)    |
                (| CGRA_REG_WVALID)   |
                (| CGRA_REG_BREADY)   |
                (| CGRA_REG_ARID)     |
                (| CGRA_REG_ARADDR)   |
                (| CGRA_REG_ARLEN)    |
                (| CGRA_REG_ARSIZE)   |
                (| CGRA_REG_ARBURST)  |
                (| CGRA_REG_ARLOCK)   |
                (| CGRA_REG_ARCACHE)  |
                (| CGRA_REG_ARPROT)   |
                (| CGRA_REG_ARVALID)  |
                (| CGRA_REG_RREADY)   |
                (| CGRA_CLK)          |
                (| CGRA_RESETn);

  assign CGRA_INT           = 1'b0;

  assign CGRA_DATA_AWREADY  = 1'b1;
  assign CGRA_DATA_WREADY   = 1'b1;
  assign CGRA_DATA_BID      = 4'h0;
  assign CGRA_DATA_BRESP    = 2'b00;
  assign CGRA_DATA_BVALID   = 1'b1;
  assign CGRA_DATA_ARREADY  = 1'b1;
  assign CGRA_DATA_RID      = 4'h0;
  assign CGRA_DATA_RDATA    = {64{1'b0}};
  assign CGRA_DATA_RRESP    = 2'b00;
  assign CGRA_DATA_RLAST    = 1'b1;
  assign CGRA_DATA_RVALID   = 1'b1;

  assign CGRA_REG_AWREADY   = 1'b1;
  assign CGRA_REG_WREADY    = 1'b1;
  assign CGRA_REG_BID       = 4'h0;
  assign CGRA_REG_BRESP     = 2'b00;
  assign CGRA_REG_BVALID    = 1'b0;
  assign CGRA_REG_ARREADY   = 1'b1;
  assign CGRA_REG_RID       = 4'h0;
  assign CGRA_REG_RDATA     = {32{1'b0}};
  assign CGRA_REG_RRESP     = 2'b00;
  assign CGRA_REG_RLAST     = 1'b1;
  assign CGRA_REG_RVALID    = 1'b0;
`endif

endmodule
