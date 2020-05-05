//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: LoopBack Control
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 5, 2020
//------------------------------------------------------------------------------
module AhaLoopBackGen (
  input   wire  [3:0]     SELECT,

  // Clocks
  input   wire            SYS_CLK,
  input   wire            CPU_CLK,
  input   wire            DAP_CLK,
  input   wire            DP_JTAG_CLK,
  input   wire            UART0_CLK,
  input   wire            SRAM_CLK,
  input   wire            NIC_CLK,

  // Debug Signals
  input   wire            DBG_PWR_UP_REQ,
  input   wire            DBG_PWR_UP_ACK,

  input   wire            DBG_SYS_PWR_UP_REQ,
  input   wire            DBG_SYS_PWR_UP_ACK,

  // Output
  output  wire            LOOP_BACK
);

  reg chosen;

  always @(*) begin
    chosen = SYS_CLK;
    case (SELECT)
      4'd0:  chosen = SYS_CLK;
      4'd1:  chosen = CPU_CLK;
      4'd2:  chosen = DAP_CLK;
      4'd3:  chosen = DP_JTAG_CLK;
      4'd4:  chosen = UART0_CLK;
      4'd5:  chosen = SRAM_CLK;
      4'd6:  chosen = NIC_CLK;
      4'd7:  chosen = DBG_PWR_UP_REQ;
      4'd8:  chosen = DBG_PWR_UP_ACK;
      4'd9:  chosen = DBG_SYS_PWR_UP_REQ;
      4'd10: chosen = DBG_SYS_PWR_UP_ACK;
    endcase
  end

  assign LOOP_BACK = chosen;

endmodule
