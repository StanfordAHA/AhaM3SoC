//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Output Capsule for TLX Training
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 6, 2020
//------------------------------------------------------------------------------
module AhaTlxOutputCapsule (
    input   wire            CLK,            // Clock
    input   wire            RESETn,         // Reset

    input   wire            D_IN,           // TLX Data

    input   wire            START,          // Start Pulse
    input   wire            CLEAR,          // Clear Pulse (Clears DONE)

    input   wire [31:0]     SEQUENCE,       // Sequence to send out
    input   wire [31:0]     LENGTH,         // Trip count of sequences to send out
    input   wire            AUTO_STOP,      // Stop after LENGTH or run until CLEAR
    input   wire            MODE,           // select TLX data or training data output

    output  wire            DONE,           // Completed training sequence
    output  wire            ACTIVE,         // Status indicating training active
    output  wire            D_OUT           // PHY lane output
);

    wire        start_pulse;
    wire        clear_pulse;

    reg         tr_out;
    reg [4:0]   idx;
    reg [31:0]  count;
    reg         done_r;
    wire        done_w;
    wire        tr_tick   = idx == 5'b11111;

    parameter   [1:0] // synopsys enum code
                      IDLE      = 2'b00,
                      TRAINING  = 2'b01,
                      FINISH    = 2'b10;

    // synopsys state_vector state
    reg [1:0]   // synopsys enum code
                state, next;

    // State Update
    always @(posedge CLK or negedge RESETn) begin
      if(~RESETn)   state   <= IDLE;
      else          state   <= next;
    end

    // Next State Logic
    always @(*) begin
      case (state)
        IDLE:       casez ({clear_pulse, start_pulse})
                      2'b1?   : next  = IDLE;
                      2'b01   : next  = TRAINING;
                      default : next  = IDLE;
                    endcase
        TRAINING:   casez ({clear_pulse, done_w & AUTO_STOP})
                      2'b1?   : next  = IDLE;
                      2'b01   : next  = FINISH;
                      2'b00   : next  = TRAINING;
                      default : next  = IDLE;
                    endcase
        FINISH:     next = IDLE;
      endcase
    end

    // Index Generator
    always @(posedge CLK or negedge RESETn) begin
      if(~RESETn)   idx <= 5'h0;
      else if(state == TRAINING) idx <= idx + 1'b1;
      else idx <= 5'h0;
    end

    // Training output
    always @(posedge CLK or negedge RESETn) begin
      if(~RESETn)   tr_out <= 1'b0;
      else if(clear_pulse == 1'b1) tr_out <= 1'b0;
      else if((state == TRAINING) && !done_w) tr_out <= SEQUENCE[idx];
      else tr_out <= 1'b0;
    end

    // Sequence Count
    always @(posedge CLK or negedge RESETn) begin
      if(~RESETn) count <= {32{1'b0}};
      else if(clear_pulse == 1'b1) count <= {32{1'b0}};
      else if((state == TRAINING) & tr_tick) count <= count + 1'b1;      
    end

    // Done Signals
    assign done_w = (state == TRAINING) && (count == LENGTH) && (AUTO_STOP == 1'b1);
    always @(posedge CLK or negedge RESETn) begin
      if(~RESETn) done_r <= 1'b0;
      else if((done_w == 1'b1) && (AUTO_STOP == 1'b1)) done_r <= 1'b1;
      else if(clear_pulse == 1'b1) done_r <= 1'b0;
    end


    AhaSyncPulseGen u_start_pulse_gen (
      .CLK          (CLK),
      .RESETn       (RESETn),
      .D            (START),
      .RISE_PULSE   (start_pulse),
      .FALL_PULSE   ()
    );

    AhaSyncPulseGen u_clear_pulse_gen (
      .CLK          (CLK),
      .RESETn       (RESETn),
      .D            (CLEAR),
      .RISE_PULSE   (clear_pulse),
      .FALL_PULSE   ()
    );

    assign  D_OUT = MODE ? tr_out : D_IN;
    assign  DONE  = done_r;
    assign ACTIVE = AUTO_STOP ? (state == TRAINING) && (count != LENGTH) : (state == TRAINING);
endmodule
