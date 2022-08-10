//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : ICG Cell
//------------------------------------------------------------------------------
// Process  : Global Foundries
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------

module AhaClockGate (
    input   wire            TE,
    input   wire            E,
    input   wire            CP,
    output  wire            Q
);
    // Instantiate ICG cell here
    SC7P5T_CKGPRELATNX10_SSC14R u_icg (
        .TE                     (TE),
        .E                      (E),
        .CLK                    (CP),
        .Z                      (Q)
    );
endmodule
