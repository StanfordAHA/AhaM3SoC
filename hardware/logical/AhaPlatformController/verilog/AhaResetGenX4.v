//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Reset Generator With 4 Req Lanes
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 3, 2020
//------------------------------------------------------------------------------
//
// NUM_CYCLES = Actual # of reset cycles  - 1
//
//------------------------------------------------------------------------------
module AhaResetGenX4 #(
  parameter NUM_CYCLES  = 1
)(
  input   wire      CLK,
  input   wire      PORESETn,

  // Reset Request Lane 0
  input   wire      REQ_0,
  output  wire      ACK_0,

  // Reset Request Lane 1
  input   wire      REQ_1,
  output  wire      ACK_1,

  // Reset Request Lane 2
  input   wire      REQ_2,
  output  wire      ACK_2,

  // Reset Request Lane 3
  input   wire      REQ_3,
  output  wire      ACK_3,

  output  wire      Qn
);

  wire q0_n;
  wire q1_n;
  wire q2_n;
  wire q3_n;

  AhaResetGen #(.NUM_CYCLES(NUM_CYCLES)) u_rst_gen_0 (
    .CLK        (CLK),
    .PORESETn   (PORESETn),
    .REQ        (REQ_0),
    .ACK        (ACK_0),
    .Qn         (q0_n)
  );

  AhaResetGen #(.NUM_CYCLES(NUM_CYCLES)) u_rst_gen_1 (
    .CLK        (CLK),
    .PORESETn   (PORESETn),
    .REQ        (REQ_1),
    .ACK        (ACK_1),
    .Qn         (q1_n)
  );

  AhaResetGen #(.NUM_CYCLES(NUM_CYCLES)) u_rst_gen_2 (
    .CLK        (CLK),
    .PORESETn   (PORESETn),
    .REQ        (REQ_2),
    .ACK        (ACK_2),
    .Qn         (q2_n)
  );

  AhaResetGen #(.NUM_CYCLES(NUM_CYCLES)) u_rst_gen_3 (
    .CLK        (CLK),
    .PORESETn   (PORESETn),
    .REQ        (REQ_3),
    .ACK        (ACK_3),
    .Qn         (q3_n)
  );

  assign Qn   = q0_n & q1_n & q2_n & q3_n;

endmodule
