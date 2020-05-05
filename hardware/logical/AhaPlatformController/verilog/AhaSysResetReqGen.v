//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: System Reset Request Generator
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 4, 2020
//------------------------------------------------------------------------------
module AhaSysResetReqGen (
  // Clock and Reset
  input   wire          CLK,
  input   wire          RESETn,

  // Input Requests
  input   wire          SYSRESETREQ,
  input   wire          LOCKUP,
  input   wire          LOCKUP_RESET_EN,
  input   wire          WDOG_TIMEOUT_RESET,
  input   wire          WDOG_TIMEOUT_RESET_EN,

  // Combined System Reset Request
  output  wire          SYSRESETREQ_COMBINED
);

  reg rst_r;

  // Combine reset requests
  wire  rst_req = (SYSRESETREQ)   |
                  (LOCKUP & LOCKUP_RESET_EN) |
                  (WDOG_TIMEOUT_RESET & WDOG_TIMEOUT_RESET_EN);

  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) rst_r   <= 1'b0;
    else rst_r  <= rst_req;
  end

  assign SYSRESETREQ_COMBINED = rst_r;

endmodule
