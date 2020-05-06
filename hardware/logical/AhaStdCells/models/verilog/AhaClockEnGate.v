//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Model for ICG Std Cell for a Clock Enable Signal
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaClockEnGate (
    input   wire  TE,
    input   wire  E,
    input   wire  CP,       // clock associated with the clock enable signal
    input   wire  CE,       // clock enable signal
    output  wire  Q
);
    // Internal Wires and Regs
    wire  en;
    reg   en_r;

    assign en = TE | E;

    // Logic
    always @(CP or en) begin
      if(CP == 1'b0) en_r <= en;
    end

    // Output
    assign Q = CE & en_r;
endmodule
