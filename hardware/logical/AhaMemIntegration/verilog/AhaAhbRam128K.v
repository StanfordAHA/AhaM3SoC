//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : AHB Wrapper for 128KB RAM (32-bit wide)
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
//------------------------------------------------------------------------------

module AhaAhbRam128K #(
    parameter IMAGE_FILE    = "None"
)(
    input   wire            HCLK,
    input   wire            HRESETn,

    input   wire            HSEL,
    input   wire            HREADY,
    input   wire [1:0]      HTRANS,
    input   wire [2:0]      HSIZE,
    input   wire            HWRITE,
    input   wire [31:0]     HADDR,
    input   wire [31:0]     HWDATA,

    output  wire            HREADYOUT,
    output  wire [1:0]      HRESP,
    output  wire [31:0]     HRDATA
);


    //
    // Internal Signals
    //

    wire [14:0]             sram_addr;
    wire [31:0]             sram_rdata;
    wire [31:0]             sram_wdata;
    wire [3:0]              sram_we;
    wire                    sram_ce;

    //
    // AHB to SRAM Converter
    //

    cmsdk_ahb_to_sram #(.AW(17)) u_ahb_to_sram (
        .HCLK               (HCLK),
        .HRESETn            (HRESETn),

        .HSEL               (HSEL),
        .HREADY             (HREADY),
        .HTRANS             (HTRANS),
        .HSIZE              (HSIZE),
        .HWRITE             (HWRITE),
        .HADDR              (HADDR[16:0]),
        .HWDATA             (HWDATA),

        .HREADYOUT          (HREADYOUT),
        .HRESP              (HRESP[0]),
        .HRDATA             (HRDATA),

        .SRAMRDATA          (sram_rdata),
        .SRAMADDR           (sram_addr),
        .SRAMWEN            (sram_we),
        .SRAMWDATA          (sram_wdata),
        .SRAMCS             (sram_ce)
    );

    //
    // SRAM Wrapper Instantiation
    //

    AhaSram32Kx32 #(.IMAGE_FILE(IMAGE_FILE)) u_aha_sram_32kx32 (
        .CLK                (HCLK),
        .RESETn             (HRESETn),
        .CEn                (~sram_ce),
        .WEn                (~sram_we),
        .A                  (sram_addr),
        .D                  (sram_wdata),
        .Q                  (sram_rdata)
    );

    //
    // Output Assignments
    //

    assign HRESP[1]         = 1'b0;

endmodule
