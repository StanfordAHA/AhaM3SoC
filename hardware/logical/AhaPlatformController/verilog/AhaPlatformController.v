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
  input   wire            DP_JTAG_TRSTn,      // Debug Port JTAG Reset
  input   wire            CGRA_JTAG_TRSTn,    // CGRA JTAG Reset

  // JTAG Clocks
  input   wire            DP_JTAG_TCK,        // Debug Port JTAG Clock
  input   wire            CGRA_JTAG_TCK,      // CGRA JTAG Clock

  // TLX Reverse Clock
  input   wire            TLX_REV_CLK,        // TLX Reverse Channel Clock

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
  output  wire            DP_JTAG_RESETn,
  output  wire            DP_JTAG_PORESETn,
  output  wire            CGRA_JTAG_RESETn,
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

  // NIC Clock Qualifiers for Peripheral Clocks
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
  input   wire            INT_REQ,
  input   wire            DBGPWRUPREQ,
  input   wire            DBGRSTREQ,
  input   wire            DBGSYSPWRUPREQ,
  input   wire            SLEEP,
  input   wire            SLEEPDEEP,
  input   wire            LOCKUP,
  input   wire            SYSRESETREQ,
  input   wire            SLEEPHOLDACKn,
  input   wire            WDOG_RESET_REQ,

  // Pad Strength Control
  output  wire [2:0]      OUT_PAD_DS_GRP0,
  output  wire [2:0]      OUT_PAD_DS_GRP1,
  output  wire [2:0]      OUT_PAD_DS_GRP2,
  output  wire [2:0]      OUT_PAD_DS_GRP3,
  output  wire [2:0]      OUT_PAD_DS_GRP4,
  output  wire [2:0]      OUT_PAD_DS_GRP5,
  output  wire [2:0]      OUT_PAD_DS_GRP6,
  output  wire [2:0]      OUT_PAD_DS_GRP7,

  // Platform Control Regspace
  input   wire            PCTRL_HSEL,
  input   wire [31:0]     PCTRL_HADDR,
  input   wire  [1:0]     PCTRL_HTRANS,
  input   wire            PCTRL_HWRITE,
  input   wire  [2:0]     PCTRL_HSIZE,
  input   wire  [2:0]     PCTRL_HBURST,
  input   wire  [3:0]     PCTRL_HPROT,
  input   wire  [3:0]     PCTRL_HMASTER,
  input   wire [31:0]     PCTRL_HWDATA,
  input   wire            PCTRL_HMASTLOCK,
  input   wire            PCTRL_HREADYMUX,

  output  wire [31:0]     PCTRL_HRDATA,
  output  wire            PCTRL_HREADYOUT,
  output  wire [1:0]      PCTRL_HRESP
);

//-----------------------------------------------------------------------------
// Clock Control Wires
//-----------------------------------------------------------------------------
// System Clock
wire  [2:0]     sys_clk_select_w;
wire            sys_fclk_w;

// CPU Clock (Synchronous to System Clock)
wire            cpu_clk_gate_w;
wire            cpu_gclk_w;

// DAP Clock (Synchronous to System Clock)
wire            dap_clk_gate_w;
wire            dap_gclk_w;

// DMA0 Clock (Synchronous to System Clock)
wire            dma0_clk_gate_w;
wire            dma0_gclk_w;

// DMA0 Peripheral Clock (Derived from System Clock)
wire [2:0]      dma0_pclk_select_w;
wire            dma0_free_pclk_w;
wire            dma0_gpclk_en_w;

// DMA1 Clock (Synchronous to System Clock)
wire            dma1_clk_gate_w;
wire            dma1_gclk_w;

// DMA1 Peripheral Clock (Derived from System Clock)
wire [2:0]      dma1_pclk_select_w;
wire            dma1_free_pclk_w;
wire            dma1_gpclk_en_w;

// SRAM Clock (Synchronous to System Clock)
wire            sram_clk_gate_w;
wire            sram_gclk_w;

// Interconnect (NIC) Clock (Synchronous to System Clock)
wire            nic_clk_gate_w;
wire            nic_gclk_w;

// TLX FWD Clock
wire            tlx_clk_gate_w;
wire [2:0]      tlx_clk_select_w;
wire            tlx_fclk_w;
wire            tlx_gclk_w;

// CGRA Clock
wire            cgra_clk_gate_w;
wire [2:0]      cgra_clk_select_w;
wire            cgra_fclk_w;
wire            cgra_gclk_w;

// TIMER0 Peripheral Clock (Derived from System Clock)
wire            timer0_clk_gate_w;
wire [2:0]      timer0_clk_select_w;
wire            timer0_fclk_w;
wire            timer0_gclk_w;
wire            timer0_gclk_en_w;

// TIMER1 Peripheral Clock (Derived from System Clock)
wire            timer1_clk_gate_w;
wire [2:0]      timer1_clk_select_w;
wire            timer1_fclk_w;
wire            timer1_gclk_w;
wire            timer1_gclk_en_w;

// UART0 Peripheral Clock (Derived from System Clock)
wire            uart0_clk_gate_w;
wire [2:0]      uart0_clk_select_w;
wire            uart0_fclk_w;
wire            uart0_gclk_w;
wire            uart0_gclk_en_w;

// UART1 Peripheral Clock (Derived from System Clock)
wire            uart1_clk_gate_w;
wire [2:0]      uart1_clk_select_w;
wire            uart1_fclk_w;
wire            uart1_gclk_w;
wire            uart1_gclk_en_w;

// Watchdog Peripheral Clock (Derived from System Clock)
wire            wdog_clk_gate_w;
wire [2:0]      wdog_clk_select_w;
wire            wdog_fclk_w;
wire            wdog_gclk_w;
wire            wdog_gclk_en_w;

//-----------------------------------------------------------------------------
// Reset Control Wires
//-----------------------------------------------------------------------------
// System Reset Request (this includes LOCKUP if enabled)
wire            sysresetreq_w;

// CPU
wire            cpu_poresetn_w;
wire            cpu_resetn_w;

// DMA0 (SYS_FCLK Domain)
wire            dma0_sys_reset_en_w;
wire            dma0_reset_req_w;
wire            dma0_reset_ack_w;
wire            dma0_poresetn_w;
wire            dma0_resetn_w;

// DMA1 (SYS_FCLK Domain)
wire            dma1_sys_reset_en_w;
wire            dma1_reset_req_w;
wire            dma1_reset_ack_w;
wire            dma1_poresetn_w;
wire            dma1_resetn_w;

// SRAM (SYS_FCLK Domain)
wire            sram_sys_reset_en_w;
wire            sram_poresetn_w;
wire            sram_resetn_w;

// TLX
wire            tlx_reset_req_w;
wire            tlx_reset_ack_w;
wire            tlx_rev_reset_req_w;
wire            tlx_rev_reset_ack_w;
wire            tlx_sys_reset_en_w;
wire            tlx_poresetn_w;
wire            tlx_resetn_w;
wire            tlx_rev_resetn_w;

// CGRA
wire            cgra_reset_req_w;
wire            cgra_reset_ack_w;
wire            cgra_sys_reset_en_w;
wire            cgra_poresetn_w;
wire            cgra_resetn_w;

// NIC
wire            nic_sys_reset_en_w;
wire            nic_reset_req_w;
wire            nic_reset_ack_w;
wire            nic_poresetn_w;
wire            nic_resetn_w;

// DAP
wire            dap_reset_req_w;
wire            dap_reset_ack_w;
wire            dap_poresetn_w;
wire            dap_resetn_w;

// Timer0
wire            timer0_reset_req_w;
wire            timer0_reset_ack_w;
wire            timer0_sys_reset_en_w;
wire            timer0_poresetn_w;
wire            timer0_resetn_w;

// Timer1
wire            timer1_reset_req_w;
wire            timer1_reset_ack_w;
wire            timer1_sys_reset_en_w;
wire            timer1_poresetn_w;
wire            timer1_resetn_w;

// UART0
wire            uart0_reset_req_w;
wire            uart0_reset_ack_w;
wire            uart0_sys_reset_en_w;
wire            uart0_poresetn_w;
wire            uart0_resetn_w;

// UART1
wire            uart1_reset_req_w;
wire            uart1_reset_ack_w;
wire            uart1_sys_reset_en_w;
wire            uart1_poresetn_w;
wire            uart1_resetn_w;

// WDOG
wire            wdog_reset_req_w;
wire            wdog_reset_ack_w;
wire            wdog_sys_reset_en_w;
wire            wdog_poresetn_w;
wire            wdog_resetn_w;

// Platform Controller
wire            platform_cntrl_poresetn_w;

// JTAG DP
wire            dp_jtag_poresetn_w;
wire            dp_jtag_resetn_w;

// CGRA JTAG
wire            cgra_jtag_resetn_w;

//-----------------------------------------------------------------------------
// Clock Controller Integration
//-----------------------------------------------------------------------------
AhaClockController u_clock_controller (
  // Master Interface
  .MASTER_CLK                       (MASTER_CLK),
  .PORESETn                         (PORESETn),

  // System Clock
  .SYS_CLK_SELECT                   (sys_clk_select_w),
  .SYS_FCLK                         (sys_fclk_w),

  // CPU Clock (Synchronous to System Clock)
  .CPU_CLK_GATE                     (cpu_clk_gate_w),
  .CPU_GCLK                         (cpu_gclk_w),

  // DAP Clock (Synchronous to System Clock)
  .DAP_CLK_GATE                     (dap_clk_gate_w),
  .DAP_GCLK                         (dap_gclk_w),

  // DMA0 Clock (Synchronous to System Clock)
  .DMA0_CLK_GATE                    (dma0_clk_gate_w),
  .DMA0_GCLK                        (dma0_gclk_w),

  // DMA0 Peripheral Clock (Derived from System Clock)
  .DMA0_PCLK_SELECT                 (dma0_pclk_select_w),
  .DMA0_FREE_PCLK                   (dma0_free_pclk_w),
  .DMA0_GPCLK_EN                    (dma0_gpclk_en_w),

  // DMA1 Clock (Synchronous to System Clock)
  .DMA1_CLK_GATE                    (dma1_clk_gate_w),
  .DMA1_GCLK                        (dma1_gclk_w),

  // DMA1 Peripheral Clock (Derived from System Clock)
  .DMA1_PCLK_SELECT                 (dma1_pclk_select_w),
  .DMA1_FREE_PCLK                   (dma1_free_pclk_w),
  .DMA1_GPCLK_EN                    (dma1_gpclk_en_w),

  // SRAM Clock (Synchronous to System Clock)
  .SRAM_CLK_GATE                    (sram_clk_gate_w),
  .SRAM_GCLK                        (sram_gclk_w),

  // Interconnect (NIC) Clock (Synchronous to System Clock)
  .NIC_CLK_GATE                     (nic_clk_gate_w),
  .NIC_GCLK                         (nic_gclk_w),

  // TLX FWD Clock
  .TLX_CLK_GATE                     (tlx_clk_gate_w),
  .TLX_CLK_SELECT                   (tlx_clk_select_w),
  .TLX_FCLK                         (tlx_fclk_w),
  .TLX_GCLK                         (tlx_gclk_w),

  // CGRA Clock
  .CGRA_CLK_GATE                    (cgra_clk_gate_w),
  .CGRA_CLK_SELECT                  (cgra_clk_select_w),
  .CGRA_FCLK                        (cgra_fclk_w),
  .CGRA_GCLK                        (cgra_gclk_w),

  // TIMER0 Peripheral Clock (Derived from System Clock)
  .TIMER0_CLK_GATE                  (timer0_clk_gate_w),
  .TIMER0_CLK_SELECT                (timer0_clk_select_w),
  .TIMER0_FCLK                      (timer0_fclk_w),
  .TIMER0_GCLK                      (timer0_gclk_w),
  .TIMER0_GCLK_EN                   (timer0_gclk_en_w),

  // TIMER1 Peripheral Clock (Derived from System Clock)
  .TIMER1_CLK_GATE                  (timer1_clk_gate_w),
  .TIMER1_CLK_SELECT                (timer1_clk_select_w),
  .TIMER1_FCLK                      (timer1_fclk_w),
  .TIMER1_GCLK                      (timer1_gclk_w),
  .TIMER1_GCLK_EN                   (timer1_gclk_en_w),

  // UART0 Peripheral Clock (Derived from System Clock)
  .UART0_CLK_GATE                   (uart0_clk_gate_w),
  .UART0_CLK_SELECT                 (uart0_clk_select_w),
  .UART0_FCLK                       (uart0_fclk_w),
  .UART0_GCLK                       (uart0_gclk_w),
  .UART0_GCLK_EN                    (uart0_gclk_en_w),

  // UART1 Peripheral Clock (Derived from System Clock)
  .UART1_CLK_GATE                   (uart1_clk_gate_w),
  .UART1_CLK_SELECT                 (uart1_clk_select_w),
  .UART1_FCLK                       (uart1_fclk_w),
  .UART1_GCLK                       (uart1_gclk_w),
  .UART1_GCLK_EN                    (uart1_gclk_en_w),

  // Watchdog Peripheral Clock (Derived from System Clock)
  .WDOG_CLK_GATE                    (wdog_clk_gate_w),
  .WDOG_CLK_SELECT                  (wdog_clk_select_w),
  .WDOG_FCLK                        (wdog_fclk_w),
  .WDOG_GCLK                        (wdog_gclk_w),
  .WDOG_GCLK_EN                     (wdog_gclk_en_w)
);

//-----------------------------------------------------------------------------
// Reset Controller Integration
//-----------------------------------------------------------------------------
  AhaResetController u_reset_controller (
    // System Clock
    .SYS_FCLK                       (sys_fclk_w),

    // Power-On Reset
    .PORESETn                       (PORESETn),

    // System Reset Request (this includes LOCKUP if enabled)
    .SYSRESETREQ                    (sysresetreq_w),

    // CPU
    .CPU_PORESETn                   (cpu_poresetn_w),
    .CPU_RESETn                     (cpu_resetn_w),

    // DMA0 (SYS_FCLK Domain)
    .DMA0_SYS_RESET_EN              (dma0_sys_reset_en_w),
    .DMA0_RESET_REQ                 (dma0_reset_req_w),
    .DMA0_RESET_ACK                 (dma0_reset_ack_w),
    .DMA0_PORESETn                  (dma0_poresetn_w),
    .DMA0_RESETn                    (dma0_resetn_w),

    // DMA1 (SYS_FCLK Domain)
    .DMA1_SYS_RESET_EN              (dma1_sys_reset_en_w),
    .DMA1_RESET_REQ                 (dma1_reset_req_w),
    .DMA1_RESET_ACK                 (dma1_reset_ack_w),
    .DMA1_PORESETn                  (dma1_poresetn_w),
    .DMA1_RESETn                    (dma1_resetn_w),

    // SRAM (SYS_FCLK Domain)
    .SRAM_SYS_RESET_EN              (sram_sys_reset_en_w),
    .SRAM_PORESETn                  (sram_poresetn_w),
    .SRAM_RESETn                    (sram_resetn_w),

    // TLX
    .TLX_FCLK                       (tlx_fclk_w),
    .TLX_REV_CLK                    (TLX_REV_CLK),
    .TLX_RESET_REQ                  (tlx_reset_req_w),
    .TLX_RESET_ACK                  (tlx_reset_ack_w),
    .TLX_REV_RESET_REQ              (tlx_rev_reset_req_w),
    .TLX_REV_RESET_ACK              (tlx_rev_reset_ack_w),
    .TLX_SYS_RESET_EN               (tlx_sys_reset_en_w),
    .TLX_PORESETn                   (tlx_poresetn_w),
    .TLX_RESETn                     (tlx_resetn_w),
    .TLX_REV_RESETn                 (tlx_rev_resetn_w),

    // CGRA
    .CGRA_FCLK                      (cgra_fclk_w),
    .CGRA_RESET_REQ                 (cgra_reset_req_w),
    .CGRA_RESET_ACK                 (cgra_reset_ack_w),
    .CGRA_SYS_RESET_EN              (cgra_sys_reset_en_w),
    .CGRA_PORESETn                  (cgra_poresetn_w),
    .CGRA_RESETn                    (cgra_resetn_w),

    // NIC
    .NIC_SYS_RESET_EN               (nic_sys_reset_en_w),
    .NIC_RESET_REQ                  (nic_reset_req_w),
    .NIC_RESET_ACK                  (nic_reset_ack_w),
    .NIC_PORESETn                   (nic_poresetn_w),
    .NIC_RESETn                     (nic_resetn_w),

    // DAP
    .DAP_RESET_REQ                  (dap_reset_req_w),
    .DAP_RESET_ACK                  (dap_reset_ack_w),
    .DAP_PORESETn                   (dap_poresetn_w),
    .DAP_RESETn                     (dap_resetn_w),

    // Timer0
    .TIMER0_FCLK                    (timer0_fclk_w),
    .TIMER0_RESET_REQ               (timer0_reset_req_w),
    .TIMER0_RESET_ACK               (timer0_reset_ack_w),
    .TIMER0_SYS_RESET_EN            (timer0_sys_reset_en_w),
    .TIMER0_PORESETn                (timer0_poresetn_w),
    .TIMER0_RESETn                  (timer0_resetn_w),

    // Timer1
    .TIMER1_FCLK                    (timer1_fclk_w),
    .TIMER1_RESET_REQ               (timer1_reset_req_w),
    .TIMER1_RESET_ACK               (timer1_reset_ack_w),
    .TIMER1_SYS_RESET_EN            (timer1_sys_reset_en_w),
    .TIMER1_PORESETn                (timer1_poresetn_w),
    .TIMER1_RESETn                  (timer1_resetn_w),

    // UART0
    .UART0_FCLK                     (uart0_fclk_w),
    .UART0_RESET_REQ                (uart0_reset_req_w),
    .UART0_RESET_ACK                (uart0_reset_ack_w),
    .UART0_SYS_RESET_EN             (uart0_sys_reset_en_w),
    .UART0_PORESETn                 (uart0_poresetn_w),
    .UART0_RESETn                   (uart0_resetn_w),

    // UART1
    .UART1_FCLK                     (uart1_fclk_w),
    .UART1_RESET_REQ                (uart1_reset_req_w),
    .UART1_RESET_ACK                (uart1_reset_ack_w),
    .UART1_SYS_RESET_EN             (uart1_sys_reset_en_w),
    .UART1_PORESETn                 (uart1_poresetn_w),
    .UART1_RESETn                   (uart1_resetn_w),

    // WDOG
    .WDOG_FCLK                      (wdog_fclk_w),
    .WDOG_RESET_REQ                 (wdog_reset_req_w),
    .WDOG_RESET_ACK                 (wdog_reset_ack_w),
    .WDOG_SYS_RESET_EN              (wdog_sys_reset_en_w),
    .WDOG_PORESETn                  (wdog_poresetn_w),
    .WDOG_RESETn                    (wdog_resetn_w),

    // Platform Controller
    .PLATFORM_CNTRL_PORESETn        (platform_cntrl_poresetn_w),

    // JTAG DP
    .DP_JTAG_TCK                    (DP_JTAG_TCK),
    .DP_JTAG_TRSTn                  (DP_JTAG_TRSTn),
    .DP_JTAG_PORESETn               (dp_jtag_poresetn_w),
    .DP_JTAG_RESETn                 (dp_jtag_resetn_w),

    // CGRA JTAG
    .CGRA_JTAG_TCK                  (CGRA_JTAG_TCK),
    .CGRA_JTAG_TRSTn                (CGRA_JTAG_TRSTn),
    .CGRA_JTAG_RESETn               (cgra_jtag_resetn_w)
  );

  assign dap_reset_req_w  = DBGRSTREQ;


//-----------------------------------------------------------------------------
// Control Register Space Integration
//-----------------------------------------------------------------------------
  AhaPlatformCtrlEngine u_ctrl_engine (
    // Clocks and Resets
    .CLK                            (sys_fclk_w),
    .RESETn                         (platform_cntrl_poresetn_w),

    // Pad Strength Control
    .PAD_DS_GRP0                    (OUT_PAD_DS_GRP0),
    .PAD_DS_GRP1                    (OUT_PAD_DS_GRP1),
    .PAD_DS_GRP2                    (OUT_PAD_DS_GRP2),
    .PAD_DS_GRP3                    (OUT_PAD_DS_GRP3),
    .PAD_DS_GRP4                    (OUT_PAD_DS_GRP4),
    .PAD_DS_GRP5                    (OUT_PAD_DS_GRP5),
    .PAD_DS_GRP6                    (OUT_PAD_DS_GRP6),
    .PAD_DS_GRP7                    (OUT_PAD_DS_GRP7),

    // Clock Select Signals
    .SYS_CLK_SELECT                 (sys_clk_select_w),
    .DMA0_PCLK_SELECT               (dma0_pclk_select_w),
    .DMA1_PCLK_SELECT               (dma1_pclk_select_w),
    .TLX_CLK_SELECT                 (tlx_clk_select_w),
    .CGRA_CLK_SELECT                (cgra_clk_select_w),
    .TIMER0_CLK_SELECT              (timer0_clk_select_w),
    .TIMER1_CLK_SELECT              (timer1_clk_select_w),
    .UART0_CLK_SELECT               (uart0_clk_select_w),
    .UART1_CLK_SELECT               (uart1_clk_select_w),
    .WDOG_CLK_SELECT                (wdog_clk_select_w),

    // Clock Gate Enable Signals
    .CPU_CLK_GATE_EN                (cpu_clk_gate_w),
    .DAP_CLK_GATE_EN                (dap_clk_gate_w),
    .DMA0_CLK_GATE_EN               (dma0_clk_gate_w),
    .DMA1_CLK_GATE_EN               (dma1_clk_gate_w),
    .SRAM_CLK_GATE_EN               (sram_clk_gate_w),
    .NIC_CLK_GATE_EN                (nic_clk_gate_w),
    .TLX_CLK_GATE_EN                (tlx_clk_gate_w),
    .CGRA_CLK_GATE_EN               (cgra_clk_gate_w),
    .TIMER0_CLK_GATE_EN             (timer0_clk_gate_w),
    .TIMER1_CLK_GATE_EN             (timer1_clk_gate_w),
    .UART0_CLK_GATE_EN              (uart0_clk_gate_w),
    .UART1_CLK_GATE_EN              (uart1_clk_gate_w),
    .WDOG_CLK_GATE_EN               (wdog_clk_gate_w),

    // Control for System Reset Propagation
    .DMA0_SYS_RESET_EN              (dma0_sys_reset_en_w),
    .DMA1_SYS_RESET_EN              (dma1_sys_reset_en_w),
    .SRAM_SYS_RESET_EN              (sram_sys_reset_en_w),
    .TLX_SYS_RESET_EN               (tlx_sys_reset_en_w),
    .CGRA_SYS_RESET_EN              (cgra_sys_reset_en_w),
    .NIC_SYS_RESET_EN               (nic_sys_reset_en_w),
    .TIMER0_SYS_RESET_EN            (timer0_sys_reset_en_w),
    .TIMER1_SYS_RESET_EN            (timer1_sys_reset_en_w),
    .UART0_SYS_RESET_EN             (uart0_sys_reset_en_w),
    .UART1_SYS_RESET_EN             (uart1_sys_reset_en_w),
    .WDOG_SYS_RESET_EN              (wdog_sys_reset_en_w),

    // Peripheral Reset Requests
    .DMA0_RESET_REQ                 (dma0_reset_req_w),
    .DMA1_RESET_REQ                 (dma1_reset_req_w),
    .TLX_RESET_REQ                  (tlx_reset_req_w),
    .TLX_REV_RESET_REQ              (tlx_rev_reset_req_w),
    .CGRA_RESET_REQ                 (cgra_reset_req_w),
    .NIC_RESET_REQ                  (nic_reset_req_w),
    .TIMER0_RESET_REQ               (timer0_reset_req_w),
    .TIMER1_RESET_REQ               (timer1_reset_req_w),
    .UART0_RESET_REQ                (uart0_reset_req_w),
    .UART1_RESET_REQ                (uart1_reset_req_w),
    .WDOG_RESET_REQ                 (wdog_reset_req_w),

    // Peripheral Reset Request Acknowledgements
    .DMA0_RESET_ACK                 (dma0_reset_ack_w),
    .DMA1_RESET_ACK                 (dma1_reset_ack_w),
    .TLX_RESET_ACK                  (tlx_reset_ack_w),
    .TLX_REV_RESET_ACK              (tlx_rev_reset_ack_w),
    .CGRA_RESET_ACK                 (cgra_reset_ack_w),
    .NIC_RESET_ACK                  (nic_reset_ack_w),
    .TIMER0_RESET_ACK               (timer0_reset_ack_w),
    .TIMER1_RESET_ACK               (timer1_reset_ack_w),
    .UART0_RESET_ACK                (uart0_reset_ack_w),
    .UART1_RESET_ACK                (uart1_reset_ack_w),
    .WDOG_RESET_ACK                 (wdog_reset_ack_w),

    // SysTick
    .CPU_CLK_CHANGED                (CPU_CLK_CHANGED),
    .SYS_TICK_NOT_10MS_MULT         (SYS_TICK_NOT_10MS_MULT),
    .SYS_TICK_CALIB                 (SYS_TICK_CALIB),

    // Debug and Power
    .DBGPWRUPACK                    (DBGPWRUPACK),
    .DBGSYSPWRUPACK                 (DBGSYSPWRUPACK),
    .SLEEPHOLDREQn                  (SLEEPHOLDREQn),
    .PMU_WIC_EN_REQ                 (PMU_WIC_EN_REQ),
    .SYSRESETREQ_COMBINED           (sysresetreq_w),

    .PMU_WIC_EN_ACK                 (PMU_WIC_EN_ACK),
    .PMU_WAKEUP                     (PMU_WAKEUP),
    .INT_REQ                        (INT_REQ),
    .DBGPWRUPREQ                    (DBGPWRUPREQ),
    .DBGSYSPWRUPREQ                 (DBGSYSPWRUPREQ),
    .SLEEP                          (SLEEP),
    .SLEEPDEEP                      (SLEEPDEEP),
    .LOCKUP                         (LOCKUP),
    .SYSRESETREQ                    (SYSRESETREQ),
    .SLEEPHOLDACKn                  (SLEEPHOLDACKn),
    .WDOG_TIMEOUT_RESET_REQ         (WDOG_RESET_REQ),

    // Control Regspace
    .PCTRL_HSEL                     (PCTRL_HSEL),
    .PCTRL_HADDR                    (PCTRL_HADDR),
    .PCTRL_HTRANS                   (PCTRL_HTRANS),
    .PCTRL_HWRITE                   (PCTRL_HWRITE),
    .PCTRL_HSIZE                    (PCTRL_HSIZE),
    .PCTRL_HBURST                   (PCTRL_HBURST),
    .PCTRL_HPROT                    (PCTRL_HPROT),
    .PCTRL_HMASTER                  (PCTRL_HMASTER),
    .PCTRL_HWDATA                   (PCTRL_HWDATA),
    .PCTRL_HMASTLOCK                (PCTRL_HMASTLOCK),
    .PCTRL_HREADYMUX                (PCTRL_HREADYMUX),
    .PCTRL_HRDATA                   (PCTRL_HRDATA),
    .PCTRL_HREADYOUT                (PCTRL_HREADYOUT),
    .PCTRL_HRESP                    (PCTRL_HRESP)
  );

//-----------------------------------------------------------------------------
// Output Assignments
//-----------------------------------------------------------------------------
  // Generated Clocks
  assign CPU_FCLK               = sys_fclk_w;
  assign CPU_GCLK               = cpu_gclk_w;
  assign DAP_CLK                = dap_gclk_w;
  assign SRAM_CLK               = sram_gclk_w;
  assign TLX_CLK                = tlx_gclk_w;
  assign CGRA_CLK               = cgra_gclk_w;
  assign DMA0_CLK               = dma0_gclk_w;
  assign DMA1_CLK               = dma1_gclk_w;
  assign PERIPH_CLK             = nic_gclk_w;
  assign TIMER0_CLK             = timer0_gclk_w;
  assign TIMER1_CLK             = timer1_gclk_w;
  assign UART0_CLK              = uart0_gclk_w;
  assign UART1_CLK              = uart1_gclk_w;
  assign WDOG_CLK               = wdog_gclk_w;
  assign NIC_CLK                = nic_gclk_w;

  // Synchronized resets
  assign CPU_PORESETn           = cpu_poresetn_w;
  assign CPU_SYSRESETn          = cpu_resetn_w;
  assign DAP_RESETn             = dap_resetn_w;
  assign DP_JTAG_RESETn         = dp_jtag_resetn_w;
  assign DP_JTAG_PORESETn       = dp_jtag_poresetn_w;
  assign CGRA_JTAG_RESETn       = cgra_jtag_resetn_w;
  assign SRAM_RESETn            = sram_resetn_w;
  assign TLX_RESETn             = tlx_resetn_w;
  assign CGRA_RESETn            = cgra_resetn_w;
  assign DMA0_RESETn            = dma0_resetn_w;
  assign DMA1_RESETn            = dma1_resetn_w;
  assign PERIPH_RESETn          = nic_resetn_w;
  assign TIMER0_RESETn          = timer0_resetn_w;
  assign TIMER1_RESETn          = timer1_resetn_w;
  assign UART0_RESETn           = uart0_resetn_w;
  assign UART1_RESETn           = uart1_resetn_w;
  assign WDOG_RESETn            = wdog_resetn_w;
  assign NIC_RESETn             = nic_resetn_w;
  assign TLX_REV_RESETn         = tlx_rev_resetn_w;

  // NIC Clock Qualifiers for Peripheral Clocks
  assign TIMER0_CLKEN           = timer0_gclk_en_w;
  assign TIMER1_CLKEN           = timer1_gclk_en_w;
  assign UART0_CLKEN            = uart0_gclk_en_w;
  assign UART1_CLKEN            = uart1_gclk_en_w;
  assign WDOG_CLKEN             = wdog_gclk_en_w;
  assign DMA0_CLKEN             = dma0_gpclk_en_w;
  assign DMA1_CLKEN             = dma1_gpclk_en_w;

  // Request ACKs
  assign DBGRSTACK              = dap_reset_ack_w;

endmodule
