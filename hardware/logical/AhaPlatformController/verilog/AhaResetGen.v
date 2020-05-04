//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Reset Generator
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 3, 2020
//------------------------------------------------------------------------------
//
// NUM_CYCLES = Actual # of reset cycles  - 1
//
//------------------------------------------------------------------------------
module AhaResetGen #(
  parameter NUM_CYCLES  = 1
)(
  input   wire      CLK,
  input   wire      PORESETn,

  input   wire      REQ,
  output  wire      ACK,

  output  wire      Qn
);

  // Resets
  wire  poresetn_sync;

  // Wire for Synchronized Request
  wire  req_sync;

  // Wire for Reset Request Pulse
  wire  req_pulse;

  reg [NUM_CYCLES:0]  rst_cycles;
  reg                 ack_r;
  reg                 req_sync_r;

  // Power-On Reset Synchronization
  AhaResetSync u_poreset_sync (
    .CLK      (CLK),
    .Dn       (PORESETn),
    .Qn       (poresetn_sync)
  );

  // Synchronized Reset Request
  AhaDataSync u_req_sync (
    .CLK          (CLK),
    .RESETn       (poresetn_sync),
    .D            (REQ),
    .Q            (req_sync)
  );

  // Reset Request Pulse
  AhaSyncPulseGen u_req_pulse (
    .CLK          (CLK),
    .RESETn       (poresetn_sync),
    .D            (req_sync),
    .RISE_PULSE   (req_pulse),
    .FALL_PULSE   ()
  );

  // Reset Generation Logic
  integer i;
  always @(posedge CLK or negedge poresetn_sync) begin
    if(~poresetn_sync) rst_cycles <= {(NUM_CYCLES+1){1'b0}};
    else if(req_pulse) rst_cycles <= {(NUM_CYCLES+1){1'b0}};
    else begin
      rst_cycles[0] <= 1'b1;
      for(i = 1; i <= NUM_CYCLES; i = i + 1)
        rst_cycles[i] <= rst_cycles[i-1];
    end
  end

  // ACK Generation Logic
  always @(posedge CLK or negedge poresetn_sync) begin
    if(~poresetn_sync) begin
      req_sync_r <= 1'b0;
      ack_r <= 1'b0;
    end
    else begin
      req_sync_r <= req_sync;
      ack_r <= req_sync_r & rst_cycles[NUM_CYCLES];
    end
  end

  // Output Assignments
  assign ACK          = ack_r;
  assign Qn           = rst_cycles[NUM_CYCLES];
endmodule
