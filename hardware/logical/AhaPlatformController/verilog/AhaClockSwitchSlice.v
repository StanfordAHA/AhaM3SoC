//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Glitch-free Clock Switch Slice
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 22, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - September 27, 2022
//      - Moved synchronizer stage to positive edge of clock
//------------------------------------------------------------------------------

module AhaClockSwitchSlice (
  // Inputs
  input   wire        CLK,
  input   wire        SELECT_REQ,

  // Others
  input   wire        OTHERS_SELECT,

  // Outputs
  output  wire        CLK_OUT,
  output  wire        SELECT_ACK
);

  //
  // Internal Signals
  //

  reg               r_EN_STAGE0_SYNC;
  reg               r_EN_STAGE1;
  reg               r_EN;

  //
  // Clock Selection Synchronization Stages
  //

  always @(posedge CLK) begin
      r_EN_STAGE0_SYNC  <= SELECT_REQ & ~OTHERS_SELECT;
      r_EN_STAGE1       <= r_EN_STAGE0_SYNC;
  end

  //
  // Update of Clock Gating Signal
  //

  always @(negedge CLK)
      r_EN    <= r_EN_STAGE1;

  //
  // Output Assignments
  //

  assign CLK_OUT          = CLK & r_EN;
  assign SELECT_ACK       = r_EN;

endmodule
