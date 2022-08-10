//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : Cell for Gating a Clock Enable Signal
//------------------------------------------------------------------------------
// Process  : All
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------

module AhaClockEnGate (
    input   wire            PORESETn,
    input   wire            TE,
    input   wire            E,
    input   wire            CP,       // clock associated with the clock enable signal
    input   wire            CE,       // clock enable signal
    output  wire            Q
);
    // Internal Wires and Regs
    wire                    reset_n;
    wire                    en;
    reg                     en_r;

    assign en               = TE | E;

    AhaResetSync u_rst_sync (
      .CLK                  (CP),
      .Dn                   (PORESETn),
      .Qn                   (reset_n)
    );

    always @(posedge CP or negedge reset_n) begin
      if(~reset_n) en_r <= 1'b0;
      else en_r <= en;
    end

    // Output
    assign Q                = CE & en_r;
endmodule
