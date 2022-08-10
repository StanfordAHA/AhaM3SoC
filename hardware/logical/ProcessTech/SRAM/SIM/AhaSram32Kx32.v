//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : Simulation View of 32K-by-32-bit SRAM (128KB)
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
//------------------------------------------------------------------------------

module AhaSram32Kx32 #( parameter IMAGE_FILE = "None" )
(
    input   wire            CLK,
    input   wire            RESETn,
    input   wire            CEn,
    input   wire [3:0]      WEn,
    input   wire [14:0]     A,
    input   wire [31:0]     D,
    output  wire [31:0]     Q
);

    //
    // Instantiate SIM SRAM Generator
    //

    AhaSramSimGen sram_sim_gen_inst #(
        .ADDR_WIDTH         (15),
        .DATA_WIDTH         (32),
        .IMAGE_FILE         (IMAGE_FILE)
    ) (
        .CLK                (CLK),
        .RESETn             (RESETn),
        .CS                 (~CEn),
        .WE                 (~WEn),
        .ADDR               (A),
        .WDATA              (D),
        .RDATA              (Q)
    );

endmodule
