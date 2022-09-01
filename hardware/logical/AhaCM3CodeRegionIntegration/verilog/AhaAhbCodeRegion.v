//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : AHB code Region for AhaCM3Integration
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 11, 2020
//------------------------------------------------------------------------------

module AhaAhbCodeRegion (
    // Inputs
    input   wire            HCLK,
    input   wire            HRESETn,

    input   wire            HSEL,
    input   wire            HREADY,
    input   wire  [1:0]     HTRANS,
    input   wire  [2:0]     HSIZE,
    input   wire            HWRITE,
    input   wire [31:0]     HADDR,
    input   wire [31:0]     HWDATA,

    // Outputs
    output wire             HREADYOUT,
    output wire   [1:0]     HRESP,
    output wire  [31:0]     HRDATA
);

    //
    // Internal Signals
    //

    wire                    sram_hreadyout;
    wire [1:0]              sram_hresp;
    wire [31:0]             sram_hrdata;

    wire                    sram_hsel;
    reg   [31:0]            int_addr;
    wire                    default_sel;

    assign default_sel      = (| int_addr[31:17]);
    assign sram_hsel        = ~(| HADDR[31:17]) & HSEL;

    //
    // SRAM Wrapper Instantiation
    //

    AhaAhbRam128K #(.IMAGE_FILE("ROM.hex"))  u_aha_ahb_ram_128k (
        .HCLK               (HCLK),
        .HRESETn            (HRESETn),

        .HSEL               (sram_hsel),
        .HREADY             (HREADY),
        .HTRANS             (HTRANS),
        .HSIZE              (HSIZE),
        .HWRITE             (HWRITE),
        .HADDR              (HADDR),
        .HWDATA             (HWDATA),

        .HREADYOUT          (sram_hreadyout),
        .HRESP              (sram_hresp),
        .HRDATA             (sram_hrdata)
    );


    //
    // Target Selector
    //

    always @(posedge HCLK or negedge HRESETn) begin
        if(~HRESETn) int_addr <= {32{1'b0}};
        else if(HTRANS[1] & sram_hreadyout) int_addr <= HADDR;
    end

    assign HREADYOUT        = default_sel ? 1'b1        : sram_hreadyout;
    assign HRESP            = default_sel ? 2'b01       : sram_hresp;
    assign HRDATA           = default_sel ? {32{1'b0}}  : sram_hrdata;

endmodule
