//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to AXI-Lite Converter
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
module AhaAxiToAxiLite #(parameter ID_WIDTH = 4) (
  // Clock and Reset
  input   wire                    ACLK,
  input   wire                    ARESETn,

  // AXI4 Slave Interface
  input   wire [ID_WIDTH-1:0]     AXI_AWID,
  input   wire [31:0]             AXI_AWADDR,
  input   wire [7:0]              AXI_AWLEN,
  input   wire [2:0]              AXI_AWSIZE,
  input   wire [1:0]              AXI_AWBURST,
  input   wire                    AXI_AWLOCK,
  input   wire [3:0]              AXI_AWCACHE,
  input   wire [2:0]              AXI_AWPROT,
  input   wire                    AXI_AWVALID,
  output  wire                    AXI_AWREADY,
  input   wire [31:0]             AXI_WDATA,
  input   wire [3:0]              AXI_WSTRB,
  input   wire                    AXI_WLAST,
  input   wire                    AXI_WVALID,
  output  wire                    AXI_WREADY,
  output  wire [ID_WIDTH-1:0]     AXI_BID,
  output  wire [1:0]              AXI_BRESP,
  output  wire                    AXI_BVALID,
  input   wire                    AXI_BREADY,
  input   wire [ID_WIDTH-1:0]     AXI_ARID,
  input   wire [31:0]             AXI_ARADDR,
  input   wire [7:0]              AXI_ARLEN,
  input   wire [2:0]              AXI_ARSIZE,
  input   wire [1:0]              AXI_ARBURST,
  input   wire                    AXI_ARLOCK,
  input   wire [3:0]              AXI_ARCACHE,
  input   wire [2:0]              AXI_ARPROT,
  input   wire                    AXI_ARVALID,
  output  wire                    AXI_ARREADY,
  output  wire [ID_WIDTH-1:0]     AXI_RID,
  output  wire [31:0]             AXI_RDATA,
  output  wire [1:0]              AXI_RRESP,
  output  wire                    AXI_RLAST,
  output  wire                    AXI_RVALID,
  input   wire                    AXI_RREADY,

  // AXI-Lite Master Interface
  output  wire  [31:0]            LITE_AWADDR,
  output  wire                    LITE_AWVALID,
  input   wire                    LITE_AWREADY,

  output  wire  [31:0]            LITE_WDATA,
  output  wire  [4:0]             LITE_WSTRB,
  output  wire                    LITE_WVALID,
  input   wire                    LITE_WREADY,

  output  wire  [1:0]             LITE_BRESP,
  output  wire                    LITE_BVALID,
  input   wire                    LITE_BREADY,

  output  wire  [31:0]            LITE_ARADDR,
  output  wire                    LITE_ARVALID,
  input   wire                    LITE_ARREADY,

  input   wire  [31:0]            LITE_RDATA,
  input   wire  [1:0]             LITE_RRESP,
  input   wire                    LITE_RVALID,
  output  wire                    LITE_RREADY
);

  wire unused = (| AXI_AWLEN)   |
                (| AXI_AWSIZE)  |
                (| AXI_AWBURST) |
                (| AXI_AWLOCK)  |
                (| AXI_AWCACHE) |
                (| AXI_AWPROT)  |
                (| AXI_WLAST)   |
                (| AXI_ARLEN)   |
                (| AXI_ARSIZE)  |
                (| AXI_ARBURST) |
                (| AXI_ARLOCK)  |
                (| AXI_ARCACHE) |
                (| AXI_ARPROT);

  // Regs for ID Reflection
  reg [ID_WIDTH-1:0]    bid;
  reg [ID_WIDTH-1:0]    rid;

  // AW Channel
  assign LITE_AWADDR    = AXI_AWADDR;
  assign LITE_AWVALID   = AXI_AWVALID;
  assign AXI_AWREADY    = LITE_AWREADY;

  // W Channel
  assign LITE_WDATA     = AXI_WDATA;
  assign LITE_WVALID    = AXI_WVALID;
  assign LITE_WSTRB     = AXI_WSTRB;
  assign AXI_WREADY     = LITE_WREADY;

  // B Channel
  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) bid <= {ID_WIDTH{1'b0}};
    else if(AXI_AWVALID & AXI_AWREADY) bid <= AXI_AWID;
  end

  assign AXI_BID        = bid;
  assign AXI_BVALID     = LITE_BVALID;
  assign AXI_BRESP      = LITE_BRESP;
  assign LITE_BREADY    = AXI_BREADY;

  // AR Channel
  assign LITE_ARADDR    = AXI_ARADDR;
  assign LITE_ARVALID   =  AXI_ARVALID;
  assign AXI_ARREADY    = LITE_ARREADY;

  // R Channel
  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) rid <= {ID_WIDTH{1'b0}};
    else if(AXI_ARVALID & AXI_ARREADY) rid <= AXI_ARID;
  end

  assign AXI_RID        = rid;
  assign AXI_RDATA      = LITE_RDATA;
  assign AXI_RRESP      = LITE_RRESP;
  assign AXI_RVALID     = LITE_RVALID;
  assign AXI_RLAST      = 1'b1;
  assign LITE_RREADY    = AXI_RREADY;
endmodule
