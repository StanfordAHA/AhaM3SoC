//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : AXI4 to CGRA Simple Interface (Write Channel)
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
// Updates  :
//          - 08/09/2022    : Replaced IntMemAxi with AXItoSRAM
//------------------------------------------------------------------------------

module AhaAxiToSifWrite (
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

    output  wire [31:0]     SIF_ADDR,
    output  wire [7:0]      SIF_STRB,
    output  wire            SIF_WE,
    output  wire [63:0]     SIF_DATA
);

    //
    // Internal Signals
    //

    wire                    sram_ce_n;
    wire                    sram_we_n;
    wire [7:0]              sram_wbe_n;
    wire [31:0]             sram_addr;
    wire [63:0]             sram_wdata;


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
        .S_AXI_ARID         (4'h0),
        .S_AXI_ARADDR       (32'h0),
        .S_AXI_ARLEN        (8'h0),
        .S_AXI_ARSIZE       (3'h0),
        .S_AXI_ARBURST      (2'h0),
        .S_AXI_ARLOCK       (1'b0),
        .S_AXI_ARCACHE      (4'h0),
        .S_AXI_ARPROT       (3'h0),
        .S_AXI_ARVALID      (1'b0),
        .S_AXI_ARREADY      (),
        .S_AXI_RID          (),
        .S_AXI_RDATA        (),
        .S_AXI_RRESP        (),
        .S_AXI_RLAST        (),
        .S_AXI_RVALID       (),
        .S_AXI_RREADY       (1'b1),

        .SRAM_CEn           (sram_ce_n),
        .SRAM_ADDR          (sram_addr),
        .SRAM_WDATA         (sram_wdata),
        .SRAM_WEn           (sram_we_n),
        .SRAM_WBEn          (sram_wbe_n),
        .SRAM_RDATA         (64'h0)
    );

    //
    // Output Assignments
    //

    assign SIF_ADDR         = sram_addr;
    assign SIF_STRB         = ~sram_wbe_n;
    assign SIF_WE           = ~(sram_ce_n | sram_we_n);
    assign SIF_DATA         = sram_wdata;

endmodule
