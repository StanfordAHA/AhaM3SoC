//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
module AhaAxiToSif #(
  parameter ID_WIDTH    = 4
  ) (
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

  output  wire [31:0]     SIF_WR_ADDR,
  output  wire            SIF_WR_EN,
  output  wire [7:0]      SIF_WR_STRB,
  output  wire [63:0]     SIF_WR_DATA,

  output  wire [31:0]     SIF_RD_ADDR,
  input   wire [63:0]     SIF_RD_DATA,
  output  wire            SIF_RD_EN,
  input   wire            SIF_RD_VALID
);

  wire unused = (| AWLOCK )  |
                (| AWCACHE ) |
                (| AWPROT )  |
                (| ARLOCK )  |
                (| ARCACHE ) |
                (| ARPROT );


  AhaAxiToSifWrite #(.ID_WIDTH(ID_WIDTH)) u_axi_to_sif_write (
    .ACLK             (ACLK),
    .ARESETn          (ARESETn),

    .AWID             (AWID),
    .AWADDR           (AWADDR),
    .AWLEN            (AWLEN),
    .AWSIZE           (AWSIZE),
    .AWBURST          (AWBURST),
    .AWVALID          (AWVALID),
    .AWREADY          (AWREADY),

    .WSTRB            (WSTRB),
    .WLAST            (WLAST),
    .WDATA            (WDATA),
    .WVALID           (WVALID),
    .WREADY           (WREADY),

    .BID              (BID),
    .BRESP            (BRESP),
    .BVALID           (BVALID),
    .BREADY           (BREADY),

    .SIF_ADDR         (SIF_WR_ADDR),
    .SIF_WE           (SIF_WR_EN),
    .SIF_STRB         (SIF_WR_STRB),
    .SIF_DATA         (SIF_WR_DATA)
  );

  AhaAxiToSifRead #(.ID_WIDTH(ID_WIDTH)) u_axi_to_sif_read (
    .ACLK           (ACLK),
    .ARESETn        (ARESETn),

    .ARID           (ARID),
    .ARADDR         (ARADDR),
    .ARLEN          (ARLEN),
    .ARSIZE         (ARSIZE),
    .ARBURST        (ARBURST),
    .ARVALID        (ARVALID),
    .ARREADY        (ARREADY),

    .RID            (RID),
    .RRESP          (RRESP),
    .RLAST          (RLAST),
    .RVALID         (RVALID),
    .RREADY         (RREADY),
    .RDATA          (RDATA),

    .SIF_RD_ADDR    (SIF_RD_ADDR),
    .SIF_RD_EN      (SIF_RD_EN),
    .SIF_RD_DATA    (SIF_RD_DATA),
    .SIF_RD_VALID   (SIF_RD_VALID)
  );

endmodule
