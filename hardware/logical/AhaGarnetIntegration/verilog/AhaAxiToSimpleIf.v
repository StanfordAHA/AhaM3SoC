//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
module AhaAxiToSimpleIf #(
  parameter CGRA_RD_WS  = 0,
  parameter ID_WIDTH    = 4)
(
  // Clock and Reset
  input   wire            ACLK,
  input   wire            ARESETn,

  // AXI4 Slave Interface
  input   wire [3 :0]     AWID,
  input   wire [31:0]     AWADDR,
  input   wire [7 :0]     AWLEN,
  input   wire [2 :0]     AWSIZE,
  input   wire [1 :0]     AWBURST,
  input   wire            AWLOCK,
  input   wire [3 :0]     AWCACHE,
  input   wire [2 :0]     AWPROT,
  input   wire            AWVALID,
  output  wire            AWREADY,
  input   wire [63:0]     WDATA,
  input   wire [7 :0]     WSTRB,
  input   wire            WLAST,
  input   wire            WVALID,
  output  wire            WREADY,
  output  wire [3 :0]     BID,
  output  wire [1 :0]     BRESP,
  output  wire            BVALID,
  input   wire            BREADY,
  input   wire [3 :0]     ARID,
  input   wire [31:0]     ARADDR,
  input   wire [7 :0]     ARLEN,
  input   wire [2 :0]     ARSIZE,
  input   wire [1 :0]     ARBURST,
  input   wire            ARLOCK,
  input   wire [3 :0]     ARCACHE,
  input   wire [2 :0]     ARPROT,
  input   wire            ARVALID,
  output  wire            ARREADY,
  output  wire [3 :0]     RID,
  output  wire [63:0]     RDATA,
  output  wire [1 :0]     RRESP,
  output  wire            RLAST,
  output  wire            RVALID,
  input   wire            RREADY,

  // Simple Interface
  output  wire [31:0]     SIF_WR_ADDR,
  output  wire [7:0]      SIF_WR_EN,
  output  wire [63:0]     SIF_WR_DATA,

  // SRAM Read Channel
  output  wire [31:0]     SIF_RD_ADDR,
  output  wire            SIF_RD_EN,
  input   wire [63:0]     SIF_RD_DATA
);

  // Simple IF Wires
  wire        wr_mem_ce_n;
  wire [7:0]  wr_mem_we_n;
  wire [31:0] wr_mem_addr;

  wire        rd_mem_ce_n;
  wire [31:0] rd_mem_addr;

  // Write Channel
  IntMemAxi #(
    .DATA_WIDTH   (64),
    .ID_WIDTH     (ID_WIDTH),
    .NUM_RD_WS    (0),
    .IS_ROM       (1'b0)
  ) u_wr_channel (
    .ACLK         (ACLK),
    .ARESETn      (ARESETn),

    .AWID         (AWID),
    .AWADDR       (AWADDR),
    .AWLEN        (AWLEN[3:0]),
    .AWSIZE       (AWSIZE),
    .AWBURST      (AWBURST),
    .AWVALID      (AWVALID),
    .AWREADY      (AWREADY),

    .WSTRB        (WSTRB),
    .WLAST        (WLAST),
    .WVALID       (WVALID),
    .WREADY       (WREADY),

    .BID          (BID),
    .BRESP        (BRESP),
    .BVALID       (BVALID),
    .BREADY       (BREADY),

    .ARID         ({ID_WIDTH{1'b0}}),
    .ARADDR       (32'd0),
    .ARLEN        (4'd0),
    .ARSIZE       (3'd0),
    .ARBURST      (2'd0),
    .ARVALID      (1'b0),
    .ARREADY      (),

    .RID          (),
    .RRESP        (),
    .RLAST        (),
    .RVALID       (),
    .RREADY       (1'b0),

    .MEMCEn       (wr_mem_ce_n),
    .MEMWEn       (wr_mem_we_n),
    .MEMADDR      (wr_mem_addr),

    .SCANENABLE   (1'b0),
    .SCANINACLK   (1'b0),
    .SCANOUTACLK  ()
  );

  assign SIF_WR_ADDR    = wr_mem_addr;
  assign SIF_WR_EN      = {8{~wr_mem_ce_n}} & ~wr_mem_we_n;
  assign SIF_WR_DATA    = WDATA;

  // Read Channel
  IntMemAxi #(
    .DATA_WIDTH   (64),
    .ID_WIDTH     (ID_WIDTH),
    .NUM_RD_WS    (CGRA_RD_WS),
    .IS_ROM       (1'b0)
  ) u_rd_channel (
    .ACLK         (ACLK),
    .ARESETn      (ARESETn),

    .AWID         ({ID_WIDTH{1'b0}}),
    .AWADDR       (32'd0),
    .AWLEN        (4'd0),
    .AWSIZE       (3'd0),
    .AWBURST      (2'd0),
    .AWVALID      (1'b0),
    .AWREADY      (/*unused*/),

    .WSTRB        (8'd0),
    .WLAST        (1'b0),
    .WVALID       (1'b0),
    .WREADY       (/*unused*/),

    .BID          (/*unused*/),
    .BRESP        (/*unused*/),
    .BVALID       (/*unused*/),
    .BREADY       (1'b0),

    .ARID         (ARID),
    .ARADDR       (ARADDR),
    .ARLEN        (ARLEN[3:0]),
    .ARSIZE       (ARSIZE),
    .ARBURST      (ARBURST),
    .ARVALID      (ARVALID),
    .ARREADY      (ARREADY),

    .RID          (RID),
    .RRESP        (RRESP),
    .RLAST        (RLAST),
    .RVALID       (RVALID),
    .RREADY       (RREADY),

    .MEMCEn       (rd_mem_ce_n),
    .MEMWEn       (/*unused*/),
    .MEMADDR      (rd_mem_addr),

    .SCANENABLE   (1'b0),
    .SCANINACLK   (1'b0),
    .SCANOUTACLK  (/*unused*/)
  );

  assign SIF_RD_ADDR    = rd_mem_addr;
  assign SIF_RD_EN      = ~rd_mem_ce_n;
  assign RDATA          = SIF_RD_DATA;

endmodule
