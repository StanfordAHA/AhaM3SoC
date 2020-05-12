//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Clock Controller (Mock)
//-----------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//-----------------------------------------------------------------------------
module AhaClockController (
  // Master Interface
  input   wire            MASTER_CLK,
  input   wire            PORESETn,

  // System Clock
  input   wire [2:0]      SYS_CLK_SELECT,
  output  wire            SYS_FCLK,

  // CPU Clock (Synchronous to System Clock)
  input   wire            CPU_CLK_GATE,
  output  wire            CPU_GCLK,

  // DAP Clock (Synchronous to System Clock)
  input   wire            DAP_CLK_GATE,
  output  wire            DAP_GCLK,

  // DMA0 Clock (Synchronous to System Clock)
  input   wire            DMA0_CLK_GATE,
  output  wire            DMA0_GCLK,

  // DMA0 Peripheral Clock (Derived from System Clock)
  input   wire [2:0]      DMA0_PCLK_SELECT,
  output  wire            DMA0_FREE_PCLK,
  output  wire            DMA0_GPCLK_EN,

  // DMA1 Clock (Synchronous to System Clock)
  input   wire            DMA1_CLK_GATE,
  output  wire            DMA1_GCLK,

  // DMA1 Peripheral Clock (Derived from System Clock)
  input   wire [2:0]      DMA1_PCLK_SELECT,
  output  wire            DMA1_FREE_PCLK,
  output  wire            DMA1_GPCLK_EN,

  // SRAM Clock (Synchronous to System Clock)
  input   wire            SRAM_CLK_GATE,
  output  wire            SRAM_GCLK,

  // Interconnect (NIC) Clock (Synchronous to System Clock)
  input   wire            NIC_CLK_GATE,
  output  wire            NIC_GCLK,

  // TLX FWD Clock
  input   wire            TLX_CLK_GATE,
  input   wire [2:0]      TLX_CLK_SELECT,
  output  wire            TLX_FCLK,
  output  wire            TLX_GCLK,

  // CGRA Clock
  input   wire            CGRA_CLK_GATE,
  input   wire [2:0]      CGRA_CLK_SELECT,
  output  wire            CGRA_FCLK,
  output  wire            CGRA_GCLK,

  // TIMER0 Peripheral Clock (Derived from System Clock)
  input   wire            TIMER0_CLK_GATE,
  input   wire [2:0]      TIMER0_CLK_SELECT,
  output  wire            TIMER0_FCLK,
  output  wire            TIMER0_GCLK,
  output  wire            TIMER0_GCLK_EN,

  // TIMER1 Peripheral Clock (Derived from System Clock)
  input   wire            TIMER1_CLK_GATE,
  input   wire [2:0]      TIMER1_CLK_SELECT,
  output  wire            TIMER1_FCLK,
  output  wire            TIMER1_GCLK,
  output  wire            TIMER1_GCLK_EN,

  // UART0 Peripheral Clock (Derived from System Clock)
  input   wire            UART0_CLK_GATE,
  input   wire [2:0]      UART0_CLK_SELECT,
  output  wire            UART0_FCLK,
  output  wire            UART0_GCLK,
  output  wire            UART0_GCLK_EN,

  // UART1 Peripheral Clock (Derived from System Clock)
  input   wire            UART1_CLK_GATE,
  input   wire [2:0]      UART1_CLK_SELECT,
  output  wire            UART1_FCLK,
  output  wire            UART1_GCLK,
  output  wire            UART1_GCLK_EN,

  // Watchdog Peripheral Clock (Derived from System Clock)
  input   wire            WDOG_CLK_GATE,
  input   wire [2:0]      WDOG_CLK_SELECT,
  output  wire            WDOG_FCLK,
  output  wire            WDOG_GCLK,
  output  wire            WDOG_GCLK_EN
);

  // Unused Wires
  wire  unused =  (| SYS_CLK_SELECT)    |
                  (| CPU_CLK_GATE)      |
                  (| DAP_CLK_GATE)      |
                  (| DMA0_CLK_GATE)     |
                  (| DMA1_CLK_GATE)     |
                  (| DMA0_PCLK_SELECT)  |
                  (| DMA1_PCLK_SELECT)  |
                  (| SRAM_CLK_GATE)     |
                  (| NIC_CLK_GATE)      |
                  (| TLX_CLK_GATE)      |
                  (| TLX_CLK_SELECT)    |
                  (| CGRA_CLK_GATE)     |
                  (| CGRA_CLK_SELECT)   |
                  (| TIMER0_CLK_GATE)   |
                  (| TIMER0_CLK_SELECT) |
                  (| TIMER1_CLK_GATE)   |
                  (| TIMER1_CLK_SELECT) |
                  (| UART0_CLK_GATE)    |
                  (| UART0_CLK_SELECT)  |
                  (| UART1_CLK_GATE)    |
                  (| UART1_CLK_SELECT)  |
                  (| WDOG_CLK_GATE)     |
                  (| WDOG_CLK_SELECT)   ;

//-----------------------------------------------------------------------------
// Reset Sync
//-----------------------------------------------------------------------------
wire      poresetn_master_clk;
wire      poresetn_sys_clk;

AhaResetSync u_sync_master_clk (
  .CLK    (MASTER_CLK),
  .Dn     (PORESETn),
  .Qn     (poresetn_master_clk)
);

AhaResetSync u_sync_sys_clk (
  .CLK    (SYS_FCLK),
  .Dn     (PORESETn),
  .Qn     (poresetn_sys_clk)
);

//-----------------------------------------------------------------------------
// Clock Sources
//-----------------------------------------------------------------------------

  // Generated Clocks From Master Clock
  wire    gen_clk_by_1;
  wire    gen_clk_by_2;
  wire    gen_clk_by_4;
  wire    gen_clk_by_8;
  wire    gen_clk_by_16;
  wire    gen_clk_by_32;

  AhaClockDivider u_clk_divider (
    .CLK_IN           (MASTER_CLK),
    .RESETn           (poresetn_master_clk),

    .CLK_by_1         (gen_clk_by_1),
    .CLK_by_1_EN      (),
    .CLK_by_2         (gen_clk_by_2),
    .CLK_by_2_EN      (),
    .CLK_by_4         (gen_clk_by_4),
    .CLK_by_4_EN      (),
    .CLK_by_8         (gen_clk_by_8),
    .CLK_by_8_EN      (),
    .CLK_by_16        (gen_clk_by_16),
    .CLK_by_16_EN     (),
    .CLK_by_32        (gen_clk_by_32),
    .CLK_by_32_EN     ()
  );

//-----------------------------------------------------------------------------
// Clock Enable Sources
//-----------------------------------------------------------------------------

  wire    sys_clk_en_by_2;
  wire    sys_clk_en_by_4;
  wire    sys_clk_en_by_8;
  wire    sys_clk_en_by_16;
  wire    sys_clk_en_by_32;

  AhaEnGenerator u_clk_en_generator (
    .CLK              (SYS_FCLK),
    .RESETn           (poresetn_sys_clk),

    .By2CLKEN         (sys_clk_en_by_2),
    .By4CLKEN         (sys_clk_en_by_4),
    .By8CLKEN         (sys_clk_en_by_8),
    .By16CLKEN        (sys_clk_en_by_16),
    .By32CLKEN        (sys_clk_en_by_32)
  );

//-----------------------------------------------------------------------------
// System Clocks
//-----------------------------------------------------------------------------

  // System Clock
  assign SYS_FCLK        = gen_clk_by_2;

  // CPU Gated Clock
  assign CPU_GCLK       = gen_clk_by_2;

  // DAP Gated Clock
  assign DAP_GCLK       = gen_clk_by_2;

  // DMA0 Gated Clock
  assign DMA0_GCLK      = gen_clk_by_2;

  // DMA1 Gated Clock
  assign DMA1_GCLK      = gen_clk_by_2;

  // DMA0 PCLK
  assign DMA0_FREE_PCLK = gen_clk_by_4;
  assign DMA0_GPCLK_EN  = sys_clk_en_by_2;

  // DMA1 PCLK
  assign DMA1_FREE_PCLK = gen_clk_by_4;
  assign DMA1_GPCLK_EN  = sys_clk_en_by_2;

  // SRAM Gated Clock
  assign SRAM_GCLK      = gen_clk_by_2;

  // NIC Gated Clock
  assign NIC_GCLK       = gen_clk_by_2;

  // TLX FWD Gated Clock
  assign TLX_FCLK       = gen_clk_by_2;
  assign TLX_GCLK       = gen_clk_by_2;

  // CGRA Gated Clock
  assign CGRA_FCLK      = gen_clk_by_1;
  assign CGRA_GCLK      = gen_clk_by_1;

  // Timer0 Clock
  assign TIMER0_FCLK    = gen_clk_by_4;
  assign TIMER0_GCLK    = gen_clk_by_4;
  assign TIMER0_GCLK_EN = sys_clk_en_by_2;

  // Timer1 Clock
  assign TIMER1_FCLK    = gen_clk_by_4;
  assign TIMER1_GCLK    = gen_clk_by_4;
  assign TIMER1_GCLK_EN = sys_clk_en_by_2;

  // Uart0 Clock
  assign UART0_FCLK     = gen_clk_by_4;
  assign UART0_GCLK     = gen_clk_by_4;
  assign UART0_GCLK_EN  = sys_clk_en_by_2;

  // Uart1 Clock
  assign UART1_FCLK     = gen_clk_by_4;
  assign UART1_GCLK     = gen_clk_by_4;
  assign UART1_GCLK_EN  = sys_clk_en_by_2;

  // WDOG Clock
  assign WDOG_FCLK      = gen_clk_by_4;
  assign WDOG_GCLK      = gen_clk_by_4;
  assign WDOG_GCLK_EN   = sys_clk_en_by_2;

endmodule
