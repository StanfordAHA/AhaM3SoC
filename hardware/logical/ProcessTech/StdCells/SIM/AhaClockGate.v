//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : Simulation View of ICG Cell
//------------------------------------------------------------------------------
// Process  : None
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
    // Internal Wires and Regs
    wire                    en;
    reg                     en_r;

    assign en               = TE | E;

    // Logic
    always @(CP or en) begin
        if(CP == 1'b0) en_r <= en;
    end

    // Output
    assign Q                = CP & en_r;
endmodule
