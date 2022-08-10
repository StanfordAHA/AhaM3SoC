//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : Simulation View of 4K-by-64-bit SRAM (32KB)
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
//------------------------------------------------------------------------------

module AhaSram4Kx64 #( parameter IMAGE_FILE = "None" )
(
    input   wire            CLK,
    input   wire            RESETn,
    input   wire            CEn,
    input   wire [7:0]      WEn,
    input   wire [11:0]     A,
    input   wire [63:0]     D,
    output  wire [63:0]     Q
);

    //
    // Instantiate SIM SRAM Generator
    //

    AhaSramSimGen sram_sim_gen_inst #(
        .ADDR_WIDTH         (12),
        .DATA_WIDTH         (64),
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
