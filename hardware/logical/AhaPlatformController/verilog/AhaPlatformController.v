//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Controller for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaPlatformController (
  // Master Clock and Reset
  input   wire            MASTER_CLK,         // Master Clock
  input   wire            PORESETn,           // Global PowerOn Reset
  input   wire            JTAG_RESETn,        // JTAG Reset

  // JTAG Clock
  input   wire            JTAG_TCK,           // JTAG Clock

  // TLX Reverse Clock
  input   wire            TLX_REV_CLK,

  // Generated Clocks
  output  wire            CPU_FCLK,
  output  wire            CPU_GCLK,
  output  wire            DAP_CLK,
  output  wire            SRAM_CLK,
  output  wire            TLX_CLK,
  output  wire            CGRA_CLK,
  output  wire            DMA0_CLK,
  output  wire            DMA1_CLK,
  output  wire            PERIPH_CLK,
  output  wire            TIMER0_CLK,
  output  wire            TIMER1_CLK,
  output  wire            UART0_CLK,
  output  wire            UART1_CLK,
  output  wire            WDOG_CLK,
  output  wire            NIC_CLK,

  // Synchronized resets
  output  wire            CPU_PORESETn,
  output  wire            CPU_SYSRESETn,
  output  wire            DAP_RESETn,
  output  wire            JTAG_TRSTn,
  output  wire            JTAG_PORESETn,
  output  wire            SRAM_RESETn,
  output  wire            TLX_RESETn,
  output  wire            CGRA_RESETn,
  output  wire            DMA0_RESETn,
  output  wire            DMA1_RESETn,
  output  wire            PERIPH_RESETn,
  output  wire            TIMER0_RESETn,
  output  wire            TIMER1_RESETn,
  output  wire            UART0_RESETn,
  output  wire            UART1_RESETn,
  output  wire            WDOG_RESETn,
  output  wire            NIC_RESETn,
  output  wire            TLX_REV_RESETn,

  // Peripheral Clock Qualifiers
  output  wire            TIMER0_CLKEN,
  output  wire            TIMER1_CLKEN,
  output  wire            UART0_CLKEN,
  output  wire            UART1_CLKEN,
  output  wire            WDOG_CLKEN,
  output  wire            DMA0_CLKEN,
  output  wire            DMA1_CLKEN,

  // SysTick
  output  wire            CPU_CLK_CHANGED,
  output  wire            SYS_TICK_NOT_10MS_MULT,
  output  wire [23:0]     SYS_TICK_CALIB,

  // Control
  output  wire            DBGPWRUPACK,
  output  wire            DBGRSTACK,
  output  wire            DBGSYSPWRUPACK,
  output  wire            SLEEPHOLDREQn,
  output  wire            PMU_WIC_EN_REQ,
  input   wire            PMU_WIC_EN_ACK,
  input   wire            PMU_WAKEUP,
  input   wire            DBGPWRUPREQ,
  input   wire            DBGRSTREQ,
  input   wire            DBGSYSPWRUPREQ,
  input   wire            SLEEP,
  input   wire            SLEEPDEEP,
  input   wire            LOCKUP,
  input   wire            SYSRESETREQ,
  input   wire            SLEEPHOLDACKn,
  input   wire            WDOG_RESET_REQ,

  // LoopBack
  output  wire            LOOP_BACK
);

  wire unused = PMU_WIC_EN_ACK | PMU_WAKEUP | SLEEP | SLEEPDEEP | LOCKUP |
    SLEEPHOLDACKn | WDOG_RESET_REQ;

  // ===== PORESETn
  // CPU PORESETn
  reg cpu_poreset_n_q;
  reg cpu_poreset_n_qq;
  always @(posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      cpu_poreset_n_q   <= 1'b0;
      cpu_poreset_n_qq  <= 1'b0;
    end else begin
      cpu_poreset_n_q   <= 1'b1;
      cpu_poreset_n_qq  <= cpu_poreset_n_q;
    end
  end
  assign CPU_PORESETn  = cpu_poreset_n_qq;

  // JTAG PORESETn
  reg jtag_poreset_n_q;
  reg jtag_poreset_n_qq;
  always @(posedge JTAG_TCK or negedge PORESETn) begin
    if(~PORESETn) begin
      jtag_poreset_n_q   <= 1'b0;
      jtag_poreset_n_qq  <= 1'b0;
    end else begin
      jtag_poreset_n_q   <= 1'b1;
      jtag_poreset_n_qq  <= jtag_poreset_n_q;
    end
  end
  assign JTAG_PORESETn  = jtag_poreset_n_qq;

  // ===== JTAG RESETn
  reg jtag_trst_n_q;
  reg jtag_trst_n_qq;
  always @(posedge JTAG_TCK or negedge JTAG_RESETn) begin
    if(~JTAG_RESETn) begin
      jtag_trst_n_q   <= 1'b0;
      jtag_trst_n_qq  <= 1'b0;
    end else begin
      jtag_trst_n_q   <= 1'b1;
      jtag_trst_n_qq  <= jtag_trst_n_q;
    end
  end
  assign JTAG_TRSTn  = jtag_trst_n_qq;

  // ===== CPU System Reset
  reg   int_cpu_sysresetn_q;
  reg   int_cpu_sysresetn_qq;
  wire  cpu_reset_n;
  always @ (posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      int_cpu_sysresetn_q     <= 1'b0;
      int_cpu_sysresetn_qq    <= 1'b0;
    end else begin
      int_cpu_sysresetn_q     <= ~SYSRESETREQ;
      int_cpu_sysresetn_qq    <= int_cpu_sysresetn_q;
    end
  end
  assign cpu_reset_n = int_cpu_sysresetn_q & int_cpu_sysresetn_qq;
  assign CPU_SYSRESETn = cpu_reset_n;

  // ===== Debug Reset
  reg int_dbg_resetn_q;
  reg int_dbg_resetn_qq;
  always @ (posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      int_dbg_resetn_q     <= 1'b0;
      int_dbg_resetn_qq    <= 1'b0;
    end else begin
      int_dbg_resetn_q     <= ~DBGRSTREQ;
      int_dbg_resetn_qq    <= int_dbg_resetn_q;
    end
  end
  assign DAP_RESETn = int_dbg_resetn_q & int_dbg_resetn_qq;

  // ===== TLX Reverse Channel Reset
  reg tlx_rev_reset_n_q;
  reg tlx_rev_reset_n_qq;
  always @(posedge TLX_REV_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      tlx_rev_reset_n_q   <= 1'b0;
      tlx_rev_reset_n_qq  <= 1'b0;
    end else begin
      tlx_rev_reset_n_q   <= 1'b1;
      tlx_rev_reset_n_qq  <= tlx_rev_reset_n_q;
    end
  end
  assign TLX_REV_RESETn  = tlx_rev_reset_n_qq;

  // Synchronized Reset Assignments
  assign SRAM_RESETn          = cpu_reset_n;
  assign TLX_RESETn           = cpu_reset_n;
  assign CGRA_RESETn          = cpu_reset_n;
  assign DMA0_RESETn          = cpu_reset_n;
  assign DMA1_RESETn          = cpu_reset_n;
  assign PERIPH_RESETn        = cpu_reset_n;
  assign TIMER0_RESETn        = cpu_reset_n;
  assign TIMER1_RESETn        = cpu_reset_n;
  assign UART0_RESETn         = cpu_reset_n;
  assign UART1_RESETn         = cpu_reset_n;
  assign WDOG_RESETn          = cpu_reset_n;
  assign NIC_RESETn           = cpu_reset_n;

  // Generated Clock Assignments
  assign CPU_FCLK             = MASTER_CLK;
  assign CPU_GCLK             = MASTER_CLK;
  assign DAP_CLK              = MASTER_CLK;
  assign SRAM_CLK             = MASTER_CLK;
  assign TLX_CLK              = MASTER_CLK;
  assign CGRA_CLK             = MASTER_CLK;
  assign DMA0_CLK             = MASTER_CLK;
  assign DMA1_CLK             = MASTER_CLK;
  assign PERIPH_CLK           = MASTER_CLK;
  assign TIMER0_CLK           = MASTER_CLK;
  assign TIMER1_CLK           = MASTER_CLK;
  assign UART0_CLK            = MASTER_CLK;
  assign UART1_CLK            = MASTER_CLK;
  assign WDOG_CLK             = MASTER_CLK;
  assign NIC_CLK              = MASTER_CLK;

  // Peripheral Clock Qualifiers
  assign TIMER0_CLKEN         = 1'b1;
  assign TIMER1_CLKEN         = 1'b1;
  assign UART0_CLKEN          = 1'b1;
  assign UART1_CLKEN          = 1'b1;
  assign WDOG_CLKEN           = 1'b1;
  assign DMA0_CLKEN           = 1'b1;
  assign DMA1_CLKEN           = 1'b1;

  // SysTick
  assign CPU_CLK_CHANGED        = 1'b0;
  assign SYS_TICK_NOT_10MS_MULT = 1'b0;
  assign SYS_TICK_CALIB         = 24'h98967F;

  // Control
  assign DBGPWRUPACK            = DBGPWRUPREQ;
  assign DBGRSTACK              = DBGRSTREQ;
  assign DBGSYSPWRUPACK         = DBGSYSPWRUPREQ;
  assign SLEEPHOLDREQn          = 1'b1;
  assign PMU_WIC_EN_REQ         = 1'b0;

  // LoopBack
  assign LOOP_BACK              = MASTER_CLK;

endmodule
