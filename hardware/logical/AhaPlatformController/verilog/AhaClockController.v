//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Clock Controller
//-----------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//-----------------------------------------------------------------------------
//
// In terms of Frequency, there are () clock domains:
// - System Clock Domain: shared by CPU, DMAs, SRAMs, and NIC
// - CGRA Clock Domain
// - FWD TLX Clock Domain
// - Timer0 Clock Domain
// - Timer1 Clock Domain
// - UART0 Clock Domain
// - UART1 Clock Domain
// - Watchdog Clock Domain
//
// * DMA peripheral interface can be run at a lower freq using PCLKEN signals
// * System Clock is derived from Master Clock
// * Peripheral Clocks are derived from System Clock
// * Output free-running clocks can be used for external reset synchronization
// ----------------------------------------------------------------------------
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

  // Generated Clocks From Master Clock
  wire    gen_clk_by_1;
  wire    gen_clk_by_2;
  wire    gen_clk_by_4;
  wire    gen_clk_by_8;
  wire    gen_clk_by_16;
  wire    gen_clk_by_32;

  AhaClockDivider u_clk_div (
    .CLK_IN           (MASTER_CLK),
    .RESETn           (PORESETn),

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

  // Generate System Clock From Master Clock
  wire    sys_fclk_w;

  AhaClockSelector u_clk_selector_sys_clk (
    .CLK_by_1         (gen_clk_by_1),
    .CLK_by_1_EN      (1'b0),
    .CLK_by_2         (gen_clk_by_2),
    .CLK_by_2_EN      (1'b0),
    .CLK_by_4         (gen_clk_by_4),
    .CLK_by_4_EN      (1'b0),
    .CLK_by_8         (gen_clk_by_8),
    .CLK_by_8_EN      (1'b0),
    .CLK_by_16        (gen_clk_by_16),
    .CLK_by_16_EN     (1'b0),
    .CLK_by_32        (gen_clk_by_32),
    .CLK_by_32_EN     (1'b0),

    .RESETn           (PORESETn),
    .SELECT           (SYS_CLK_SELECT),

    .CLK_OUT          (sys_fclk_w),
    .CLK_EN_OUT       ()
  );

  assign SYS_FCLK = sys_fclk_w;

  // Generate CPU Gated Clock from System Clock
  AhaClockGate u_cpu_gclk (
    .TE     (1'b0),
    .E      (~CPU_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (CPU_GCLK)
  );

  // Generate DAP Gated Clock from System Clock
  AhaClockGate u_dap_gclk (
    .TE     (1'b0),
    .E      (~DAP_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (DAP_GCLK)
  );

  // Generate DMA0 Gated Clock from System Clock
  AhaClockGate u_dma0_gclk (
    .TE     (1'b0),
    .E      (~DMA0_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (DMA0_GCLK)
  );

  // Generate DMA1 Gated Clock from System Clock
  AhaClockGate u_dma1_gclk (
    .TE     (1'b0),
    .E      (~DMA1_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (DMA1_GCLK)
  );

  // Generate SRAM Gated Clock from System Clock
  AhaClockGate u_sram_gclk (
    .TE     (1'b0),
    .E      (~SRAM_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (SRAM_GCLK)
  );

  // Generate NIC Gated Clock from System Clock
  AhaClockGate u_nic_gclk (
    .TE     (1'b0),
    .E      (~NIC_CLK_GATE),
    .CP     (sys_fclk_w),
    .Q      (NIC_GCLK)
  );

  // Generate TLX Free-Running Clock from Master Clock
  wire    tlx_fclk_w;

  AhaClockSelector u_clk_selector_tlx_clk (
    .CLK_by_1         (gen_clk_by_1),
    .CLK_by_1_EN      (1'b0),
    .CLK_by_2         (gen_clk_by_2),
    .CLK_by_2_EN      (1'b0),
    .CLK_by_4         (gen_clk_by_4),
    .CLK_by_4_EN      (1'b0),
    .CLK_by_8         (gen_clk_by_8),
    .CLK_by_8_EN      (1'b0),
    .CLK_by_16        (gen_clk_by_16),
    .CLK_by_16_EN     (1'b0),
    .CLK_by_32        (gen_clk_by_32),
    .CLK_by_32_EN     (1'b0),

    .RESETn           (PORESETn),
    .SELECT           (TLX_CLK_SELECT),

    .CLK_OUT          (tlx_fclk_w),
    .CLK_EN_OUT       ()
  );

  assign TLX_FCLK = tlx_fclk_w;

  // Generate TLX Gated Clock from TLX Free-Running Clock
  AhaClockGate u_tlx_gclk (
    .TE     (1'b0),
    .E      (~TLX_CLK_GATE),
    .CP     (tlx_fclk_w),
    .Q      (TLX_GCLK)
  );

  // Generate CGRA Free-Running Clock from Master Clock
  wire    cgra_fclk_w;

  AhaClockSelector u_clk_selector_cgra_clk (
    .CLK_by_1         (gen_clk_by_1),
    .CLK_by_1_EN      (1'b0),
    .CLK_by_2         (gen_clk_by_2),
    .CLK_by_2_EN      (1'b0),
    .CLK_by_4         (gen_clk_by_4),
    .CLK_by_4_EN      (1'b0),
    .CLK_by_8         (gen_clk_by_8),
    .CLK_by_8_EN      (1'b0),
    .CLK_by_16        (gen_clk_by_16),
    .CLK_by_16_EN     (1'b0),
    .CLK_by_32        (gen_clk_by_32),
    .CLK_by_32_EN     (1'b0),

    .RESETn           (PORESETn),
    .SELECT           (CGRA_CLK_SELECT),

    .CLK_OUT          (cgra_fclk_w),
    .CLK_EN_OUT       ()
  );

  assign CGRA_FCLK = cgra_fclk_w;

  // Generate CGRA Gated Clock from CGRA Free-Running Clock
  AhaClockGate u_cgra_gclk (
    .TE     (1'b0),
    .E      (~CGRA_CLK_GATE),
    .CP     (cgra_fclk_w),
    .Q      (CGRA_GCLK)
  );

  // Generated Clocks for System Clock
  wire    sys_gen_clk_by_1;
  wire    sys_gen_clk_by_2;
  wire    sys_gen_clk_by_4;
  wire    sys_gen_clk_by_8;
  wire    sys_gen_clk_by_16;
  wire    sys_gen_clk_by_32;

  wire    sys_gen_clk_en_by_1;
  wire    sys_gen_clk_en_by_2;
  wire    sys_gen_clk_en_by_4;
  wire    sys_gen_clk_en_by_8;
  wire    sys_gen_clk_en_by_16;
  wire    sys_gen_clk_en_by_32;

  AhaClockDivider u_clk_div_from_sysclk (
    .CLK_IN           (sys_fclk_w),
    .RESETn           (PORESETn),

    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32)
  );

  // Generate Timer0 Free-Running Clock from System Clock
  wire    timer0_fclk_w;
  wire    timer0_free_en_w;

  AhaClockSelector u_clk_selector_timer0_clk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (TIMER0_CLK_SELECT),

    .CLK_OUT          (timer0_fclk_w),
    .CLK_EN_OUT       (timer0_free_en_w)
  );

  assign TIMER0_FCLK = timer0_fclk_w;

  // Generate Timer0 Gated Clock from Timer0 Free-Running Clock
  AhaClockGate u_timer0_gclk (
    .TE     (1'b0),
    .E      (~TIMER0_CLK_GATE),
    .CP     (timer0_fclk_w),
    .Q      (TIMER0_GCLK)
  );

  AhaClockGate u_timer0_gated_en (
    .TE     (1'b0),
    .E      (~TIMER0_CLK_GATE),
    .CP     (timer0_free_en_w),
    .Q      (TIMER0_GCLK_EN)
  );

  // Generate Timer1 Free-Running Clock from System Clock
  wire    timer1_fclk_w;
  wire    timer1_free_en_w;

  AhaClockSelector u_clk_selector_timer1_clk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (TIMER1_CLK_SELECT),

    .CLK_OUT          (timer1_fclk_w),
    .CLK_EN_OUT       (timer1_free_en_w)
  );

  assign TIMER1_FCLK = timer1_fclk_w;

  // Generate Timer1 Gated Clock from Timer1 Free-Running Clock
  AhaClockGate u_timer1_gclk (
    .TE     (1'b0),
    .E      (~TIMER1_CLK_GATE),
    .CP     (timer1_fclk_w),
    .Q      (TIMER1_GCLK)
  );

  AhaClockGate u_timer1_gated_en (
    .TE     (1'b0),
    .E      (~TIMER1_CLK_GATE),
    .CP     (timer1_free_en_w),
    .Q      (TIMER1_GCLK_EN)
  );

  // Generate UART0 Free-Running Clock from System Clock
  wire    uart0_fclk_w;
  wire    uart0_free_en_w;

  AhaClockSelector u_clk_selector_uart0_clk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (UART0_CLK_SELECT),

    .CLK_OUT          (uart0_fclk_w),
    .CLK_EN_OUT       (uart0_free_en_w)
  );

  assign UART0_FCLK = uart0_fclk_w;

  // Generate UART0 Gated Clock from UART0 Free-Running Clock
  AhaClockGate u_uart0_gclk (
    .TE     (1'b0),
    .E      (~UART0_CLK_GATE),
    .CP     (uart0_fclk_w),
    .Q      (UART0_GCLK)
  );

  AhaClockGate u_uart0_gated_en (
    .TE     (1'b0),
    .E      (~UART0_CLK_GATE),
    .CP     (uart0_free_en_w),
    .Q      (UART0_GCLK_EN)
  );

  // Generate UART1 Free-Running Clock from System Clock
  wire    uart1_fclk_w;
  wire    uart1_free_en_w;

  AhaClockSelector u_clk_selector_uart1_clk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (UART1_CLK_SELECT),

    .CLK_OUT          (uart1_fclk_w),
    .CLK_EN_OUT       (uart1_free_en_w)
  );

  assign UART1_FCLK = uart1_fclk_w;

  // Generate UART1 Gated Clock from UART1 Free-Running Clock
  AhaClockGate u_uart1_gclk (
    .TE     (1'b0),
    .E      (~UART1_CLK_GATE),
    .CP     (uart1_fclk_w),
    .Q      (UART1_GCLK)
  );

  AhaClockGate u_uart1_gated_en (
    .TE     (1'b0),
    .E      (~UART1_CLK_GATE),
    .CP     (uart1_free_en_w),
    .Q      (UART1_GCLK_EN)
  );

  // Generate WDOG Free-Running Clock from System Clock
  wire    wdog_fclk_w;
  wire    wdog_free_en_w;

  AhaClockSelector u_clk_selector_wdog_clk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (WDOG_CLK_SELECT),

    .CLK_OUT          (wdog_fclk_w),
    .CLK_EN_OUT       (wdog_free_en_w)
  );

  assign WDOG_FCLK = wdog_fclk_w;

  // Generate WDOG Gated Clock from WDOG Free-Running Clock
  AhaClockGate u_wdog_gclk (
    .TE     (1'b0),
    .E      (~WDOG_CLK_GATE),
    .CP     (wdog_fclk_w),
    .Q      (WDOG_GCLK)
  );

  AhaClockGate u_wdog_gated_en (
    .TE     (1'b0),
    .E      (~WDOG_CLK_GATE),
    .CP     (wdog_free_en_w),
    .Q      (WDOG_GCLK_EN)
  );

  // Generate DMA0 Free-Running PCLK from System Clock
  wire    dma0_free_pclk_w;
  wire    dma0_free_pen_w;

  AhaClockSelector u_clk_selector_dma0_pclk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (DMA0_PCLK_SELECT),

    .CLK_OUT          (dma0_free_pclk_w),
    .CLK_EN_OUT       (dma0_free_pen_w)
  );

  assign DMA0_FREE_PCLK = dma0_free_pclk_w;

  // Generate DMA0 PCKLEN using DMA0_CLK_GATE and DMA0 Free-Running PCLK
  AhaClockGate u_dma0_gated_pen (
    .TE     (1'b0),
    .E      (~DMA0_CLK_GATE),
    .CP     (dma0_free_pen_w),
    .Q      (DMA0_GPCLK_EN)
  );

  // Generate DMA1 Free-Running PCLK from System Clock
  wire    dma1_free_pclk_w;
  wire    dma1_free_pen_w;

  AhaClockSelector u_clk_selector_dma1_pclk (
    .CLK_by_1         (sys_gen_clk_by_1),
    .CLK_by_1_EN      (sys_gen_clk_en_by_1),
    .CLK_by_2         (sys_gen_clk_by_2),
    .CLK_by_2_EN      (sys_gen_clk_en_by_2),
    .CLK_by_4         (sys_gen_clk_by_4),
    .CLK_by_4_EN      (sys_gen_clk_en_by_4),
    .CLK_by_8         (sys_gen_clk_by_8),
    .CLK_by_8_EN      (sys_gen_clk_en_by_8),
    .CLK_by_16        (sys_gen_clk_by_16),
    .CLK_by_16_EN     (sys_gen_clk_en_by_16),
    .CLK_by_32        (sys_gen_clk_by_32),
    .CLK_by_32_EN     (sys_gen_clk_en_by_32),

    .RESETn           (PORESETn),
    .SELECT           (DMA1_PCLK_SELECT),

    .CLK_OUT          (dma1_free_pclk_w),
    .CLK_EN_OUT       (dma1_free_pen_w)
  );

  assign DMA1_FREE_PCLK = dma1_free_pclk_w;

  // Generate DMA1 PCKLEN using DMA1_CLK_GATE and DMA1 Free-Running PCLK
  AhaClockGate u_dma1_gated_pen (
    .TE     (1'b0),
    .E      (~DMA1_CLK_GATE),
    .CP     (dma1_free_pen_w),
    .Q      (DMA1_GPCLK_EN)
  );
endmodule
