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
  input   wire            TLX_CLK,            // TLX Clock
  input   wire            TLX_RESETn,         // CGRA PowerOn Reset

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
  input   wire            TLX_RREADY
);

  wire unused = (| TLX_CLK)             |
                (| TLX_RESETn)          |
                (| TLX_AWID)            |
                (| TLX_AWADDR)          |
                (| TLX_AWLEN)           |
                (| TLX_AWSIZE)          |
                (| TLX_AWBURST)         |
                (| TLX_AWLOCK)          |
                (| TLX_AWCACHE)         |
                (| TLX_AWPROT)          |
                (| TLX_AWVALID)         |
                (| TLX_WDATA)           |
                (| TLX_WSTRB)           |
                (| TLX_WLAST)           |
                (| TLX_WVALID)          |
                (| TLX_BREADY)          |
                (| TLX_ARID)            |
                (| TLX_ARADDR)          |
                (| TLX_ARLEN)           |
                (| TLX_ARSIZE)          |
                (| TLX_ARBURST)         |
                (| TLX_ARLOCK)          |
                (| TLX_ARCACHE)         |
                (| TLX_ARPROT)          |
                (| TLX_ARVALID)         |
                (| TLX_RREADY);

  assign TLX_AWREADY      = 1'b1;
  assign TLX_WREADY       = 1'b1;
  assign TLX_BID          = 4'h0;
  assign TLX_BRESP        = 2'b00;
  assign TLX_BVALID       = 1'b1;
  assign TLX_ARREADY      = 1'b1;
  assign TLX_RID          = 4'h0;
  assign TLX_RDATA        = {64{1'b0}};
  assign TLX_RRESP        = 2'b00;
  assign TLX_RLAST        = 1'b1;
  assign TLX_RVALID       = 1'b1;

endmodule
