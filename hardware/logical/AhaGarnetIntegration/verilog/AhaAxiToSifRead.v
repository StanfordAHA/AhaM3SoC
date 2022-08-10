//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : AXI4 to CGRA Simple Interface (Read Channel)
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
// Updates  :
//          - 08/10/2022    : Fixed ID_WIDTH to 4 bits
//------------------------------------------------------------------------------

module AhaAxiToSifRead (
    input   wire            ACLK,
    input   wire            ARESETn,

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

    output  wire [31:0]     SIF_ADDR,
    output  wire            SIF_RE,
    input   wire [63:0]     SIF_DATA,
    input   wire            SIF_VALID
);

    //
    // Internal Signals
    //

    wire                    ARREADY_w;
    wire                    RVALID_w;
    wire                    RLAST_w;
    wire    [63:0]          RDATA_w;
    reg     [3:0]           RID_r;

    //
    // ID Reflection
    //

    always @(posedge ACLK or negedge ARESETn)
        if (!ARESETn)
            RID_r   <= 4'h0;
        else if (ARVALID & ARREADY_w)
            RID_r   <= ARID;

    //
    // Address Generator
    //

    AhaAxiToSifReadAddrGen u_addr_gen (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),

        .ARADDR             (ARADDR),
        .ARBURST            (ARBURST),
        .ARSIZE             (ARSIZE),
        .ARLEN              (ARLEN),
        .ARVALID            (ARVALID),
        .ARREADY            (ARREADY_w),
        .RVALID             (RVALID_w),
        .RREADY             (RREADY),
        .RLAST              (RLAST_w),

        .SIF_RD_ADDR        (SIF_ADDR),
        .SIF_RD_EN          (SIF_RE)
    );

    //
    // Data
    //

    AhaAxiToSifReadData u_data (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),

        .ARLEN              (ARLEN),
        .ARVALID            (ARVALID),
        .ARREADY            (ARREADY_w),
        .RREADY             (RREADY),
        .RVALID             (RVALID_w),
        .RLAST              (RLAST_w),
        .RDATA              (RDATA_w),

        .SIF_RD_DATA        (SIF_DATA),
        .SIF_RD_VALID       (SIF_VALID)
    );

    //
    // Output Assignments
    //

    assign ARREADY          = ARREADY_w;
    assign RVALID           = RVALID_w;
    assign RLAST            = RLAST_w;
    assign RID              = RID_r;
    assign RRESP            = 2'b00;

endmodule
