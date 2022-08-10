//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : AXI Wrapper for 32KB RAM (64-bit wide)
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
//------------------------------------------------------------------------------

module AhaAxiRam32K #(
    parameter IMAGE_FILE    = "None"
)(
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

    //
    // Internal Signals
    //

    wire                    sram_ce_n;
    wire [31:0]             sram_addr;
    wire [63:0]             sram_wdata;
    wire                    sram_we_n;
    wire [7:0]              sram_wbe_n;
    wire [63:0]             sram_rdata;

    //
    // AXI to SRAM Converter
    //

    AXItoSRAM u_axi_to_sram (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),

        .S_AXI_AWID         (AWID),
        .S_AXI_AWADDR       (AWADDR),
        .S_AXI_AWLEN        (AWLEN),
        .S_AXI_AWSIZE       (AWSIZE),
        .S_AXI_AWBURST      (AWBURST),
        .S_AXI_AWLOCK       (AWLOCK),
        .S_AXI_AWCACHE      (AWCACHE),
        .S_AXI_AWPROT       (AWPROT),
        .S_AXI_AWVALID      (AWVALID),
        .S_AXI_AWREADY      (AWREADY),
        .S_AXI_WDATA        (WDATA),
        .S_AXI_WSTRB        (WSTRB),
        .S_AXI_WLAST        (WLAST),
        .S_AXI_WVALID       (WVALID),
        .S_AXI_WREADY       (WREADY),
        .S_AXI_BID          (BID),
        .S_AXI_BRESP        (BRESP),
        .S_AXI_BVALID       (BVALID),
        .S_AXI_BREADY       (BREADY),
        .S_AXI_ARID         (ARID),
        .S_AXI_ARADDR       (ARADDR),
        .S_AXI_ARLEN        (ARLEN),
        .S_AXI_ARSIZE       (ARSIZE),
        .S_AXI_ARBURST      (ARBURST),
        .S_AXI_ARLOCK       (ARLOCK),
        .S_AXI_ARCACHE      (ARCACHE),
        .S_AXI_ARPROT       (ARPROT),
        .S_AXI_ARVALID      (ARVALID),
        .S_AXI_ARREADY      (ARREADY),
        .S_AXI_RID          (RID),
        .S_AXI_RDATA        (RDATA),
        .S_AXI_RRESP        (RRESP),
        .S_AXI_RLAST        (RLAST),
        .S_AXI_RVALID       (RVALID),
        .S_AXI_RREADY       (RREADY),

        .SRAM_CEn           (sram_ce_n),
        .SRAM_ADDR          (sram_addr),
        .SRAM_WDATA         (sram_wdata),
        .SRAM_WEn           (sram_we_n),
        .SRAM_WBEn          (sram_wbe_n),
        .SRAM_RDATA         (sram_rdata)
    );

    //
    // SRAM Wrapper Instantiation
    //

    AhaSram4Kx64 #(.IMAGE_FILE(IMAGE_FILE)) u_aha_sram_4kx64 (
        .CLK                (ACLK),
        .RESETn             (ARESETn),
        .CEn                (sram_ce_n),
        .WEn                (sram_wbe_n),
        .A                  (sram_addr[14:3]),
        .D                  (sram_wdata),
        .Q                  (sram_rdata)
    );

endmodule
