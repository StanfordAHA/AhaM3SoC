//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : AXI4 to CGRA Simple Interface
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
// Updates  :
//          - 08/09/2022    : Replaced IntMemAxi with AXItoSRAM
//------------------------------------------------------------------------------

module AhaAxiToSif (
    // Clock and Reset
    input   wire            ACLK,
    input   wire            ARESETn,

    // AXI4 Interface
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
    input   wire            RREADY,

    // SIF Write Interface
    output  wire [31:0]     SIF_WR_ADDR,
    output  wire            SIF_WR_EN,
    output  wire [7:0]      SIF_WR_STRB,
    output  wire [63:0]     SIF_WR_DATA,

    // SIF Read Interface
    output  wire [31:0]     SIF_RD_ADDR,
    output  wire            SIF_RD_EN,
    input   wire [63:0]     SIF_RD_DATA,
    input   wire            SIF_RD_VALID
);


    //
    // Internal Signals
    //

    wire    [31:0]          SIF_WR_ADDR_w;
    wire                    SIF_WR_EN_w;
    wire    [7:0]           SIF_WR_STRB_w;
    wire    [63:0]          SIF_WR_DATA_w;

    reg     [31:0]          SIF_WR_ADDR_r;
    reg                     SIF_WR_EN_r;
    reg     [7:0]           SIF_WR_STRB_r;
    reg     [63:0]          SIF_WR_DATA_r;

    wire    [31:0]          SIF_RD_ADDR_w;
    wire                    SIF_RD_EN_w;

    reg     [31:0]          SIF_RD_ADDR_r;
    reg                     SIF_RD_EN_r;


    //
    // Write Channel
    //

    AhaAxiToSifWrite u_axi_to_sif_write (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),

        .AWID               (AWID),
        .AWADDR             (AWADDR),
        .AWLEN              (AWLEN),
        .AWSIZE             (AWSIZE),
        .AWBURST            (AWBURST),
        .AWLOCK             (AWLOCK),
        .AWCACHE            (AWCACHE),
        .AWPROT             (AWPROT),
        .AWVALID            (AWVALID),
        .AWREADY            (AWREADY),

        .WDATA              (WDATA),
        .WSTRB              (WSTRB),
        .WLAST              (WLAST),
        .WVALID             (WVALID),
        .WREADY             (WREADY),

        .BID                (BID),
        .BRESP              (BRESP),
        .BVALID             (BVALID),
        .BREADY             (BREADY),

        .SIF_ADDR           (SIF_WR_ADDR_w),
        .SIF_STRB           (SIF_WR_STRB_w),
        .SIF_WE             (SIF_WR_EN_w),
        .SIF_DATA           (SIF_WR_DATA_w)
    );

    //
    // Read Channel
    //

    AhaAxiToSifRead u_axi_to_sif_read (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),

        .ARID               (ARID),
        .ARADDR             (ARADDR),
        .ARLEN              (ARLEN),
        .ARSIZE             (ARSIZE),
        .ARBURST            (ARBURST),
        .ARLOCK             (ARLOCK),
        .ARCACHE            (ARCACHE),
        .ARPROT             (ARPROT),
        .ARVALID            (ARVALID),
        .ARREADY            (ARREADY),

        .RID                (RID),
        .RDATA              (RDATA),
        .RRESP              (RRESP),
        .RLAST              (RLAST),
        .RVALID             (RVALID),
        .RREADY             (RREADY),

        .SIF_ADDR           (SIF_RD_ADDR_w),
        .SIF_RE             (SIF_RD_EN_w),
        .SIF_DATA           (SIF_RD_DATA),
        .SIF_VALID          (SIF_RD_VALID)
    );

    //
    // Output Registers
    //

    always @(posedge ACLK or negedge ARESETn)
        if (!ARESETn)
        begin
            SIF_WR_ADDR_r   <= 32'h0;
            SIF_WR_EN_r     <= 1'b0;
            SIF_WR_STRB_r   <= 8'h0;
            SIF_WR_DATA_r   <= 64'h0;
            SIF_RD_ADDR_r   <= 32'h0;
            SIF_RD_EN_r     <= 1'b0;
        end
        else
        begin
            SIF_WR_ADDR_r   <= SIF_WR_ADDR_w;
            SIF_WR_EN_r     <= SIF_WR_EN_w;
            SIF_WR_STRB_r   <= SIF_WR_STRB_w;
            SIF_WR_DATA_r   <= SIF_WR_DATA_w;
            SIF_RD_ADDR_r   <= SIF_RD_ADDR_w;
            SIF_RD_EN_r     <= SIF_RD_EN_w;
        end

    //
    // Output Assignments
    //

    assign SIF_WR_ADDR      = SIF_WR_ADDR_r;
    assign SIF_WR_EN        = SIF_WR_EN_r;
    assign SIF_WR_STRB      = SIF_WR_STRB_r;
    assign SIF_WR_DATA      = SIF_WR_DATA_r;
    assign SIF_RD_ADDR      = SIF_RD_ADDR_r;
    assign SIF_RD_EN        = SIF_RD_EN_r;

endmodule
