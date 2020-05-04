//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Wrapper for ICG Std Cell
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockGate (
    input   wire  TE,
    input   wire  E,
    input   wire  CP,
    output  wire  Q
);
  // Instantiate ICG cell here
  CKLNQD10BWP16P90 u_icg (
    .TE   (TE),
    .E    (E),
    .CP   (CP),
    .Q    (Q)
  );
endmodule
