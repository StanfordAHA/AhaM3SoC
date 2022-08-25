//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Reset Controller
//-----------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 3, 2020
//-----------------------------------------------------------------------------
module AhaResetController (
  // System Clock
  input   wire        SYS_FCLK,

  // Power-On Reset
  input   wire        PORESETn,

  // System Reset Request (this includes LOCKUP if enabled)
  input   wire        SYSRESETREQ,

  // CPU
  input   wire        CPU_SYSRESETn,
  output  wire        CPU_PORESETn,
  output  wire        CPU_RESETn,

  // DMA0 (SYS_FCLK Domain)
  input   wire        DMA0_SYS_RESET_EN,    // enable for SYSRESETREQ to reset DMA0
  input   wire        DMA0_RESET_REQ,
  output  wire        DMA0_RESET_ACK,
  output  wire        DMA0_PORESETn,
  output  wire        DMA0_RESETn,

  // DMA1 (SYS_FCLK Domain)
  input   wire        DMA1_SYS_RESET_EN,    // enable for SYSRESETREQ to reset DMA1
  input   wire        DMA1_RESET_REQ,
  output  wire        DMA1_RESET_ACK,
  output  wire        DMA1_PORESETn,
  output  wire        DMA1_RESETn,

  // SRAM (SYS_FCLK Domain)
  input   wire        SRAM_SYS_RESET_EN,    // enable for SYSRESETREQ to reset SRAM logic
  output  wire        SRAM_PORESETn,
  output  wire        SRAM_RESETn,

  // TLX
  input   wire        TLX_FCLK,
  input   wire        TLX_REV_CLK,
  input   wire        TLX_RESET_REQ,
  output  wire        TLX_RESET_ACK,
  input   wire        TLX_REV_RESET_REQ,
  output  wire        TLX_REV_RESET_ACK,
  input   wire        TLX_SYS_RESET_EN,    // enable for SYSRESETREQ to reset TLX
  output  wire        TLX_PORESETn,
  output  wire        TLX_RESETn,
  output  wire        TLX_REV_RESETn,

  // TPIU
  input   wire        TPIU_TRACECLKIN,
  output  wire        TPIU_RESETn,

  // CGRA
  input   wire        CGRA_FCLK,
  input   wire        CGRA_RESET_REQ,
  output  wire        CGRA_RESET_ACK,
  input   wire        CGRA_SYS_RESET_EN,    // enable for SYSRESETREQ to reset CGRA
  output  wire        CGRA_PORESETn,
  output  wire        CGRA_RESETn,

  // NIC
  input   wire        NIC_SYS_RESET_EN,    // enable for SYSRESETREQ to reset NIC
  input   wire        NIC_RESET_REQ,
  output  wire        NIC_RESET_ACK,
  output  wire        NIC_PORESETn,
  output  wire        NIC_RESETn,

  // DAP
  input   wire        DAP_RESET_REQ,
  output  wire        DAP_RESET_ACK,
  output  wire        DAP_PORESETn,
  output  wire        DAP_RESETn,

  // Timer0
  input   wire        TIMER0_FCLK,
  input   wire        TIMER0_RESET_REQ,
  output  wire        TIMER0_RESET_ACK,
  input   wire        TIMER0_SYS_RESET_EN,    // enable for SYSRESETREQ to reset Timer0
  output  wire        TIMER0_PORESETn,
  output  wire        TIMER0_RESETn,

  // Timer1
  input   wire        TIMER1_FCLK,
  input   wire        TIMER1_RESET_REQ,
  output  wire        TIMER1_RESET_ACK,
  input   wire        TIMER1_SYS_RESET_EN,    // enable for SYSRESETREQ to reset Timer1
  output  wire        TIMER1_PORESETn,
  output  wire        TIMER1_RESETn,

  // UART0
  input   wire        UART0_FCLK,
  input   wire        UART0_RESET_REQ,
  output  wire        UART0_RESET_ACK,
  input   wire        UART0_SYS_RESET_EN,    // enable for SYSRESETREQ to reset UART0
  output  wire        UART0_PORESETn,
  output  wire        UART0_RESETn,

  // UART1
  input   wire        UART1_FCLK,
  input   wire        UART1_RESET_REQ,
  output  wire        UART1_RESET_ACK,
  input   wire        UART1_SYS_RESET_EN,    // enable for SYSRESETREQ to reset UART1
  output  wire        UART1_PORESETn,
  output  wire        UART1_RESETn,

  // WDOG
  input   wire        WDOG_FCLK,
  input   wire        WDOG_RESET_REQ,
  output  wire        WDOG_RESET_ACK,
  input   wire        WDOG_SYS_RESET_EN,    // enable for SYSRESETREQ to reset WDOG
  output  wire        WDOG_PORESETn,
  output  wire        WDOG_RESETn,

  // Platform Controller
  output  wire        PLATFORM_CNTRL_PORESETn,

  // JTAG DP
  input   wire        DP_JTAG_TCK,
  input   wire        DP_JTAG_TRSTn,
  output  wire        DP_JTAG_PORESETn,
  output  wire        DP_JTAG_RESETn,

  // CGRA JTAG
  input   wire        CGRA_JTAG_TCK,
  input   wire        CGRA_JTAG_TRSTn,
  output  wire        CGRA_JTAG_RESETn
);

  // Power-On Reset Wires
  wire        sys_clk_poreset_n;
  wire        tlx_clk_poreset_n;
  wire        cgra_clk_poreset_n;
  wire        dp_jtag_clk_poreset_n;
  wire        cgra_jtag_poreset_n;
  wire        timer0_clk_poreset_n;
  wire        timer1_clk_poreset_n;
  wire        uart0_clk_poreset_n;
  wire        uart1_clk_poreset_n;
  wire        wdog_clk_poreset_n;
  wire        tpiu_clk_poreset_n;

  // --------------------------------------------------------------------------
  // Power-On Resets
  // --------------------------------------------------------------------------
  // Power-On Reset -- System Clock Domain
  AhaResetSync u_sys_clk_poresetn_sync (
    .CLK      (SYS_FCLK),
    .Dn       (PORESETn),
    .Qn       (sys_clk_poreset_n)
  );

  // Power-On Reset -- TLX Clock Domain
  AhaResetSync u_tlx_clk_poresetn_sync (
    .CLK      (TLX_FCLK),
    .Dn       (PORESETn),
    .Qn       (tlx_clk_poreset_n)
  );

  // Power-On Reset -- TPIU Clock Domain
  AhaResetSync u_tpiu_clk_poresetn_sync (
    .CLK      (TPIU_TRACECLKIN),
    .Dn       (PORESETn),
    .Qn       (tpiu_clk_poreset_n)
  );

  assign TPIU_RESETn = tpiu_clk_poreset_n;

  // Power-On Reset -- CGRA Clock Domain
  AhaResetSync u_cgra_clk_poresetn_sync (
    .CLK      (CGRA_FCLK),
    .Dn       (PORESETn),
    .Qn       (cgra_clk_poreset_n)
  );

  // Power-On Reset -- CoreSight DP Clock Domain
  AhaResetSync u_dp_jtag_clk_poresetn_sync (
    .CLK      (DP_JTAG_TCK),
    .Dn       (PORESETn),
    .Qn       (dp_jtag_clk_poreset_n)
  );

  // Power-On Reset -- CGRA JTAG Clock Domain
  AhaResetSync u_cgra_jtag_clk_poresetn_sync (
    .CLK      (CGRA_JTAG_TCK),
    .Dn       (PORESETn),
    .Qn       (cgra_jtag_poreset_n)
  );

  // Power-On Reset -- Timer0 Clock Domain
  AhaResetSync u_timer0_clk_poresetn_sync (
    .CLK      (TIMER0_FCLK),
    .Dn       (PORESETn),
    .Qn       (timer0_clk_poreset_n)
  );

  // Power-On Reset -- Timer1 Clock Domain
  AhaResetSync u_timer1_clk_poresetn_sync (
    .CLK      (TIMER1_FCLK),
    .Dn       (PORESETn),
    .Qn       (timer1_clk_poreset_n)
  );

  // Power-On Reset -- UART0 Clock Domain
  AhaResetSync u_uart0_clk_poresetn_sync (
    .CLK      (UART0_FCLK),
    .Dn       (PORESETn),
    .Qn       (uart0_clk_poreset_n)
  );

  // Power-On Reset -- UART1 Clock Domain
  AhaResetSync u_uart1_clk_poresetn_sync (
    .CLK      (UART1_FCLK),
    .Dn       (PORESETn),
    .Qn       (uart1_clk_poreset_n)
  );

  // Power-On Reset -- Watchdog Clock Domain
  AhaResetSync u_wdog_clk_poresetn_sync (
    .CLK      (WDOG_FCLK),
    .Dn       (PORESETn),
    .Qn       (wdog_clk_poreset_n)
  );

  // --------------------------------------------------------------------------
  // Reset Controllers
  // --------------------------------------------------------------------------
  // CPU
  AhaResetGen #(.NUM_CYCLES(8)) u_cpu_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn & CPU_SYSRESETn),
    .REQ          (SYSRESETREQ),
    .ACK          (),
    .Qn           (CPU_RESETn)
  );
  assign CPU_PORESETn = sys_clk_poreset_n;

  // DMA0
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_dma0_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & DMA0_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (DMA0_RESET_REQ),
    .ACK_1        (DMA0_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (DMA0_RESETn)
  );
  assign DMA0_PORESETn = sys_clk_poreset_n;

  // DMA1
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_dma1_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & DMA1_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (DMA1_RESET_REQ),
    .ACK_1        (DMA1_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (DMA1_RESETn)
  );
  assign DMA1_PORESETn = sys_clk_poreset_n;

  // SRAM
  AhaResetGen #(.NUM_CYCLES(8)) u_sram_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn),
    .REQ          (SYSRESETREQ & SRAM_SYS_RESET_EN),
    .ACK          (),
    .Qn           (SRAM_RESETn)
  );
  assign SRAM_PORESETn = sys_clk_poreset_n;

  // TLX
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_tlx_reset_ctrl (
    .CLK          (TLX_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & TLX_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (TLX_RESET_REQ),
    .ACK_1        (TLX_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (TLX_RESETn)
  );
  assign TLX_PORESETn = tlx_clk_poreset_n;

  // TLX Reverse Channel
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_tlx_rev_reset_ctrl (
    .CLK          (TLX_REV_CLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & TLX_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (TLX_REV_RESET_REQ),
    .ACK_1        (TLX_REV_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (TLX_REV_RESETn)
  );

  // CGRA
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_cgra_reset_ctrl (
    .CLK          (CGRA_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & CGRA_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (CGRA_RESET_REQ),
    .ACK_1        (CGRA_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (CGRA_RESETn)
  );
  assign CGRA_PORESETn = cgra_clk_poreset_n;

  // NIC
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_nic_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & NIC_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (NIC_RESET_REQ),
    .ACK_1        (NIC_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (NIC_RESETn)
  );
  assign NIC_PORESETn = sys_clk_poreset_n;

  // DAP
  AhaResetGen #(.NUM_CYCLES(8)) u_dap_reset_ctrl (
    .CLK          (SYS_FCLK),
    .PORESETn     (PORESETn),
    .REQ          (DAP_RESET_REQ),
    .ACK          (DAP_RESET_ACK),
    .Qn           (DAP_RESETn)
  );
  assign DAP_PORESETn = sys_clk_poreset_n;

  // TIMER0
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_timer0_reset_ctrl (
    .CLK          (TIMER0_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & TIMER0_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (TIMER0_RESET_REQ),
    .ACK_1        (TIMER0_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (TIMER0_RESETn)
  );
  assign TIMER0_PORESETn = timer0_clk_poreset_n;

  // TIMER1
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_timer1_reset_ctrl (
    .CLK          (TIMER1_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & TIMER1_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (TIMER1_RESET_REQ),
    .ACK_1        (TIMER1_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (TIMER1_RESETn)
  );
  assign TIMER1_PORESETn = timer1_clk_poreset_n;

  // UART0
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_uart0_reset_ctrl (
    .CLK          (UART0_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & UART0_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (UART0_RESET_REQ),
    .ACK_1        (UART0_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (UART0_RESETn)
  );
  assign UART0_PORESETn = uart0_clk_poreset_n;

  // UART1
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_uart1_reset_ctrl (
    .CLK          (UART1_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & UART1_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (UART1_RESET_REQ),
    .ACK_1        (UART1_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (UART1_RESETn)
  );
  assign UART1_PORESETn = uart1_clk_poreset_n;

  // WDOG
  AhaResetGenX4 #(.NUM_CYCLES(8)) u_wdog_reset_ctrl (
    .CLK          (WDOG_FCLK),
    .PORESETn     (PORESETn),
    .REQ_0        (SYSRESETREQ & WDOG_SYS_RESET_EN),
    .ACK_0        (),
    .REQ_1        (WDOG_RESET_REQ),
    .ACK_1        (WDOG_RESET_ACK),
    .REQ_2        (1'b0),
    .ACK_2        (),
    .REQ_3        (1'b0),
    .ACK_3        (),
    .Qn           (WDOG_RESETn)
  );
  assign WDOG_PORESETn = wdog_clk_poreset_n;

  // Platform Controller
  assign PLATFORM_CNTRL_PORESETn = sys_clk_poreset_n;

  // JTAG DP
  AhaResetSync u_dp_jtag_reset_sync (
    .CLK      (DP_JTAG_TCK),
    .Dn       (DP_JTAG_TRSTn),
    .Qn       (DP_JTAG_RESETn)
  );
  assign DP_JTAG_PORESETn = dp_jtag_clk_poreset_n;

  // CGRA JTAG
  AhaResetSync u_cgra_jtag_reset_sync (
    .CLK      (CGRA_JTAG_TCK),
    .Dn       (CGRA_JTAG_TRSTn),
    .Qn       (CGRA_JTAG_RESETn)
  );

endmodule
