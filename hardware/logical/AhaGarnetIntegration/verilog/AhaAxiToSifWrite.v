//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface - Write Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
module AhaAxiToSifWrite #(
  parameter ID_WIDTH = 4
) (
  input   wire                  ACLK,
  input   wire                  ARESETn,

  input   wire [ID_WIDTH-1:0]   AWID,
  input   wire [31:0]           AWADDR,
  input   wire [7:0]            AWLEN,
  input   wire [2:0]            AWSIZE,
  input   wire [1:0]            AWBURST,
  input   wire                  AWVALID,
  output  wire                  AWREADY,

  input   wire [7:0]            WSTRB,
  input   wire                  WLAST,
  input   wire [63:0]           WDATA,
  input   wire                  WVALID,
  output  wire                  WREADY,

  output  wire [ID_WIDTH-1:0]   BID,
  output  wire [1:0]            BRESP,
  output  wire                  BVALID,
  input   wire                  BREADY,

  output  wire [31:0]           SIF_ADDR,
  output  wire [7:0]            SIF_STRB,
  output  wire                  SIF_WE,
  output  wire [63:0]           SIF_DATA
);

  wire        wr_mem_ce_n;
  wire [7:0]  wr_mem_we_n;
  wire [31:0] wr_mem_addr;
  wire [63:0] wr_mem_data;

  assign wr_mem_data = WDATA;

  IntMemAxi #(
    .DATA_WIDTH   (64),
    .ID_WIDTH     (ID_WIDTH),
    .NUM_RD_WS    (0),
    .IS_ROM       (1'b0)
  ) u_wr_channel (
    .ACLK                     (ACLK),
    .ARESETn                  (ARESETn),
    .AWID                     (AWID),
    .AWADDR                   (AWADDR),
    .AWLEN                    (AWLEN),
    .AWSIZE                   (AWSIZE),
    .AWBURST                  (AWBURST),
    .AWVALID                  (AWVALID),
    .AWREADY                  (AWREADY),
    .WSTRB                    (WSTRB),
    .WLAST                    (WLAST),
    .WVALID                   (WVALID),
    .WREADY                   (WREADY),
    .BID                      (BID),
    .BRESP                    (BRESP),
    .BVALID                   (BVALID),
    .BREADY                   (BREADY),
    .ARID                     (4'h0),
    .ARADDR                   (32'h0),
    .ARLEN                    (4'h0),
    .ARSIZE                   (3'h0),
    .ARBURST                  (2'h0),
    .ARVALID                  (1'b0),
    .ARREADY                  (),
    .RID                      (),
    .RRESP                    (),
    .RLAST                    (),
    .RVALID                   (),
    .RREADY                   (1'b1),

    .MEMCEn                   (wr_mem_ce_n),
    .MEMWEn                   (wr_mem_we_n),
    .MEMADDR                  (wr_mem_addr),

    .SCANENABLE               (1'b0),
    .SCANINACLK               (1'b0),
    .SCANOUTACLK              ()
  );

  assign SIF_ADDR   = wr_mem_addr;
  assign SIF_STRB   = ~wr_mem_we_n;
  assign SIF_WE     = ~wr_mem_ce_n;
  assign SIF_DATA   = wr_mem_data;

endmodule
