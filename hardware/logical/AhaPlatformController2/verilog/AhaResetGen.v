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

  // Synchronized Resets
  wire  poresetn_sync;
  wire  req_sync;

  // Reset Cycles
  reg [NUM_CYCLES:0]  rst_cycles;
  reg [NUM_CYCLES:0]  ack_cycles;

  // Power-On Reset Synchronization
  AhaResetSync u_poreset_sync (
    .CLK          (CLK),
    .Dn           (PORESETn),
    .Qn           (poresetn_sync)
  );

  // Synchronized Reset Request
  AhaDataSync u_req_sync (
    .CLK          (CLK),
    .RESETn       (poresetn_sync),
    .D            (REQ),
    .Q            (req_sync)
  );

  // Reset Generation Logic
  integer i;
  always @(posedge CLK or negedge poresetn_sync) begin
    if(~poresetn_sync) rst_cycles <= {(NUM_CYCLES+1){1'b0}};
    else begin
      rst_cycles[0] <= ~req_sync;
      for(i = 1; i <= NUM_CYCLES; i = i + 1)
        rst_cycles[i] <= rst_cycles[i-1];
    end
  end

  // ACK generation
  always @(posedge CLK or negedge poresetn_sync) begin
    if(~poresetn_sync) ack_cycles <= {(NUM_CYCLES+1){1'b0}};
    else begin
      ack_cycles[0] <= req_sync;
      for(i = 1; i <= NUM_CYCLES; i = i + 1)
        ack_cycles[i] <= ack_cycles[i-1];
    end
  end

  // Output Assignments
  assign ACK          = ack_cycles[NUM_CYCLES];
  assign Qn           = (& rst_cycles);
endmodule
