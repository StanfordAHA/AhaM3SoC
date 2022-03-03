//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI Wrapper for 32K/64-bit SRAM
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaAxiRam32K (
  input   wire            ACLK,
  input   wire            ARESETn,

  input   wire [3:0]      AWID,
  input   wire [31:0]     AWADDR,
  input   wire [7:0]      AWLEN,
  input   wire [2:0]      AWSIZE,
  input   wire [1:0]      AWBURST,
  input   wire            AWLOCK,
  input   wire [3:0]      AWCACHE,
  input   wire [2:0]      AWPROT,
  input   wire            AWVALID,
  output  wire            AWREADY,
  input   wire [63:0]     WDATA,
  input   wire [7:0]      WSTRB,
  input   wire            WLAST,
  input   wire            WVALID,
  output  wire            WREADY,
  output  wire [3:0]      BID,
  output  wire [1:0]      BRESP,
  output  wire            BVALID,
  input   wire            BREADY,
  input   wire [3:0]      ARID,
  input   wire [31:0]     ARADDR,
  input   wire [7:0]      ARLEN,
  input   wire [2:0]      ARSIZE,
  input   wire [1:0]      ARBURST,
  input   wire            ARLOCK,
  input   wire [3:0]      ARCACHE,
  input   wire [2:0]      ARPROT,
  input   wire            ARVALID,
  output  wire            ARREADY,
  output  wire [3:0]      RID,
  output  wire [63:0]     RDATA,
  output  wire [1:0]      RRESP,
  output  wire            RLAST,
  output  wire            RVALID,
  input   wire            RREADY
);

  // Avoid lint messages
  wire unused = AWLOCK | (& AWCACHE) | (& AWPROT) | ARLOCK |
                (& ARCACHE) | (& ARPROT);

  // SRAM Interface Wires
  wire          mem_ce_n;
  wire  [7:0]   mem_we_n;
  wire  [31:0]  mem_addr;

  // AXI to SRAM Interface Converter
  IntMemAxi #(
    .DATA_WIDTH           (64),
    .NUM_RD_WS            (0),
    .IS_ROM               (1'b0),
    .ID_WIDTH             (4)
  ) u_int_mem_axi (
    // INPUTS
    // global signals
    .ACLK                 (ACLK),
    .ARESETn              (ARESETn),

    // Write Address Channel
    .AWVALID              (AWVALID),
    .AWID                 (AWID),
    .AWADDR               (AWADDR),
    .AWLEN                (AWLEN),
    .AWSIZE               (AWSIZE),
    .AWBURST              (AWBURST),

    // Write Channel
    .WVALID               (WVALID),
    .WLAST                (WLAST),
    .WSTRB                (WSTRB),

    // Write Response Channel
    .BREADY               (BREADY),

    // Read Address Channel
    .ARVALID              (ARVALID),
    .ARID                 (ARID),
    .ARADDR               (ARADDR),
    .ARLEN                (ARLEN),
    .ARSIZE               (ARSIZE),
    .ARBURST              (ARBURST),

    // Read Channel
    .RREADY               (RREADY),

    // dummy scan pins
    .SCANENABLE           (1'b0),
    .SCANINACLK           (1'b0),


    // OUTPUTS
    // Write Address Channel
    .AWREADY              (AWREADY),
    // Write Channel
    .WREADY               (WREADY),

    // Write Response Channel
    .BVALID               (BVALID),
    .BRESP                (BRESP),
    .BID                  (BID),

    // Read Address Channel
    .ARREADY              (ARREADY),

    // Read Channel
    .RVALID               (RVALID),
    .RID                  (RID),
    .RLAST                (RLAST),
    .RRESP                (RRESP),

    // Memory signals
    .MEMCEn               (mem_ce_n),
    .MEMWEn               (mem_we_n),
    .MEMADDR              (mem_addr),

    // dummy scan pins
    .SCANOUTACLK          (/*unused*/)
  );

  // 32K SRAM Integration
  AhaSram32K u_sram_32K (
    .CLK                  (ACLK),
    .CEn                  (mem_ce_n),
    .WEn                  (mem_we_n),
    .A                    (mem_addr[14:3]),
    .D                    (WDATA),
    .Q                    (RDATA)
  );
endmodule
