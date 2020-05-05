//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Control Engine for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 3, 2020
//------------------------------------------------------------------------------
module AhaPlatformCtrlEngine (
  // Clocks and Resets
  input   wire                CLK,
  input   wire                RESETn,

  // Pad Strength Control
  output  wire  [2:0]         PAD_DS_GRP0,
  output  wire  [2:0]         PAD_DS_GRP1,
  output  wire  [2:0]         PAD_DS_GRP2,
  output  wire  [2:0]         PAD_DS_GRP3,
  output  wire  [2:0]         PAD_DS_GRP4,
  output  wire  [2:0]         PAD_DS_GRP5,
  output  wire  [2:0]         PAD_DS_GRP6,
  output  wire  [2:0]         PAD_DS_GRP7,

  // Clock Select Signals
  output  wire  [2:0]         SYS_CLK_SELECT,
  output  wire  [2:0]         DMA0_PCLK_SELECT,
  output  wire  [2:0]         DMA1_PCLK_SELECT,
  output  wire  [2:0]         TLX_CLK_SELECT,
  output  wire  [2:0]         CGRA_CLK_SELECT,
  output  wire  [2:0]         TIMER0_CLK_SELECT,
  output  wire  [2:0]         TIMER1_CLK_SELECT,
  output  wire  [2:0]         UART0_CLK_SELECT,
  output  wire  [2:0]         UART1_CLK_SELECT,
  output  wire  [2:0]         WDOG_CLK_SELECT,

  // Clock Gate Enable Signals
  output  wire                CPU_CLK_GATE_EN,
  output  wire                DAP_CLK_GATE_EN,
  output  wire                DMA0_CLK_GATE_EN,
  output  wire                DMA1_CLK_GATE_EN,
  output  wire                SRAM_CLK_GATE_EN,
  output  wire                NIC_CLK_GATE_EN,
  output  wire                TLX_CLK_GATE_EN,
  output  wire                CGRA_CLK_GATE_EN,
  output  wire                TIMER0_CLK_GATE_EN,
  output  wire                TIMER1_CLK_GATE_EN,
  output  wire                UART0_CLK_GATE_EN,
  output  wire                UART1_CLK_GATE_EN,
  output  wire                WDOG_CLK_GATE_EN,

  // System Reset Propagation Control
  output  wire                DMA0_SYS_RESET_EN,
  output  wire                DMA1_SYS_RESET_EN,
  output  wire                SRAM_SYS_RESET_EN,
  output  wire                TLX_SYS_RESET_EN,
  output  wire                CGRA_SYS_RESET_EN,
  output  wire                NIC_SYS_RESET_EN,
  output  wire                TIMER0_SYS_RESET_EN,
  output  wire                TIMER1_SYS_RESET_EN,
  output  wire                UART0_SYS_RESET_EN,
  output  wire                UART1_SYS_RESET_EN,
  output  wire                WDOG_SYS_RESET_EN,

  // Peripheral Reset Requests
  output  wire                DMA0_RESET_REQ,
  output  wire                DMA1_RESET_REQ,
  output  wire                TLX_RESET_REQ,
  output  wire                TLX_REV_RESET_REQ,
  output  wire                CGRA_RESET_REQ,
  output  wire                NIC_RESET_REQ,
  output  wire                TIMER0_RESET_REQ,
  output  wire                TIMER1_RESET_REQ,
  output  wire                UART0_RESET_REQ,
  output  wire                UART1_RESET_REQ,
  output  wire                WDOG_RESET_REQ,

  // Peripheral Reset Request Acknowledgements
  input   wire                DMA0_RESET_ACK,
  input   wire                DMA1_RESET_ACK,
  input   wire                TLX_RESET_ACK,
  input   wire                TLX_REV_RESET_ACK,
  input   wire                CGRA_RESET_ACK,
  input   wire                NIC_RESET_ACK,
  input   wire                TIMER0_RESET_ACK,
  input   wire                TIMER1_RESET_ACK,
  input   wire                UART0_RESET_ACK,
  input   wire                UART1_RESET_ACK,
  input   wire                WDOG_RESET_ACK,

  // SysTick
  output  wire                CPU_CLK_CHANGED,
  output  wire                SYS_TICK_NOT_10MS_MULT,
  output  wire [23:0]         SYS_TICK_CALIB,

  // Debug and Power Management
  output  wire                DBGPWRUPACK,
  output  wire                DBGSYSPWRUPACK,
  output  wire                SLEEPHOLDREQn,
  output  wire                PMU_WIC_EN_REQ,
  output  wire                SYSRESETREQ_COMBINED,

  input   wire                PMU_WIC_EN_ACK,
  input   wire                PMU_WAKEUP,
  input   wire                DBGPWRUPREQ,
  input   wire                DBGSYSPWRUPREQ,
  input   wire                SLEEP,
  input   wire                SLEEPDEEP,
  input   wire                LOCKUP,
  input   wire                SYSRESETREQ,
  input   wire                SLEEPHOLDACKn,
  input   wire                WDOG_TIMEOUT_RESET_REQ,

  // Control Regspace
  input   wire                PCTRL_HSEL,
  input   wire [31:0]         PCTRL_HADDR,
  input   wire  [1:0]         PCTRL_HTRANS,
  input   wire                PCTRL_HWRITE,
  input   wire  [2:0]         PCTRL_HSIZE,
  input   wire  [2:0]         PCTRL_HBURST,
  input   wire  [3:0]         PCTRL_HPROT,
  input   wire  [3:0]         PCTRL_HMASTER,
  input   wire [31:0]         PCTRL_HWDATA,
  input   wire                PCTRL_HMASTLOCK,
  input   wire                PCTRL_HREADYMUX,

  output  wire [31:0]         PCTRL_HRDATA,
  output  wire                PCTRL_HREADYOUT,
  output  wire [1:0]          PCTRL_HRESP
);

//------------------------------------------------------------------------------
// Register Wires
//------------------------------------------------------------------------------
  wire          l2h_SYS_CLK_SELECT_REG_SELECT_swmod_o;

  wire          l2h_CLK_GATE_EN_REG_CPU_r;
  wire          l2h_CLK_GATE_EN_REG_DAP_r;
  wire          l2h_CLK_GATE_EN_REG_DMA0_r;
  wire          l2h_CLK_GATE_EN_REG_DMA1_r;
  wire          l2h_CLK_GATE_EN_REG_SRAMx_r;
  wire          l2h_CLK_GATE_EN_REG_TLX_FWD_r;
  wire          l2h_CLK_GATE_EN_REG_GGRA_r;
  wire          l2h_CLK_GATE_EN_REG_NIC_r;
  wire          l2h_CLK_GATE_EN_REG_TIMER0_r;
  wire          l2h_CLK_GATE_EN_REG_TIMER1_r;
  wire          l2h_CLK_GATE_EN_REG_UART0_r;
  wire          l2h_CLK_GATE_EN_REG_UART1_r;
  wire          l2h_CLK_GATE_EN_REG_WDOG_r;

  wire          l2h_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r;
  wire          l2h_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r;

//------------------------------------------------------------------------------
// Register Space
//------------------------------------------------------------------------------
  AhaPlatformCtrlRegspace u_platform_ctrl_reg_space (
    // AHB Interface
    .HCLK                                           (CLK),
    .HRESETn                                        (RESETn),

    .HSEL                                           (PCTRL_HSEL),
    .HADDR                                          (PCTRL_HADDR),
    .HTRANS                                         (PCTRL_HTRANS),
    .HWRITE                                         (PCTRL_HWRITE),
    .HSIZE                                          (PCTRL_HSIZE),
    .HBURST                                         (PCTRL_HBURST),
    .HPROT                                          (PCTRL_HPROT),
    .HMASTER                                        (PCTRL_HMASTER),
    .HWDATA                                         (PCTRL_HWDATA),
    .HMASTLOCK                                      (PCTRL_HMASTLOCK),
    .HREADYMUX                                      (PCTRL_HREADYMUX),

    .HRDATA                                         (PCTRL_HRDATA),
    .HREADYOUT                                      (PCTRL_HREADYOUT),
    .HRESP                                          (PCTRL_HRESP),

    // Register Signals
    .H2L_RESET_ACK_REG_DMA0_w                       (DMA0_RESET_ACK),
    .H2L_RESET_ACK_REG_DMA1_w                       (DMA1_RESET_ACK),
    .H2L_RESET_ACK_REG_TLX_FWD_w                    (TLX_RESET_ACK),
    .H2L_RESET_ACK_REG_TLX_REV_w                    (TLX_REV_RESET_ACK),
    .H2L_RESET_ACK_REG_GGRA_w                       (CGRA_RESET_ACK),
    .H2L_RESET_ACK_REG_NIC_w                        (NIC_RESET_ACK),
    .H2L_RESET_ACK_REG_TIMER0_w                     (TIMER0_RESET_ACK),
    .H2L_RESET_ACK_REG_TIMER1_w                     (TIMER1_RESET_ACK),
    .H2L_RESET_ACK_REG_UART0_w                      (UART0_RESET_ACK),
    .H2L_RESET_ACK_REG_UART1_w                      (UART1_RESET_ACK),
    .H2L_RESET_ACK_REG_WDOG_w                       (WDOG_RESET_ACK),

    .L2H_PAD_STRENGTH_CTRL_REG_GRP0_r               (PAD_DS_GRP0),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP1_r               (PAD_DS_GRP1),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP2_r               (PAD_DS_GRP2),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP3_r               (PAD_DS_GRP3),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP4_r               (PAD_DS_GRP4),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP5_r               (PAD_DS_GRP5),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP6_r               (PAD_DS_GRP6),
    .L2H_PAD_STRENGTH_CTRL_REG_GRP7_r               (PAD_DS_GRP7),
    .L2H_SYS_CLK_SELECT_REG_SELECT_SWMOD_o          (l2h_SYS_CLK_SELECT_REG_SELECT_swmod_o),
    .L2H_SYS_CLK_SELECT_REG_SELECT_r                (SYS_CLK_SELECT),
    .L2H_DMA0_PCLK_SELECT_REG_SELECT_r              (DMA0_PCLK_SELECT),
    .L2H_DMA1_PCLK_SELECT_REG_SELECT_r              (DMA1_PCLK_SELECT),
    .L2H_TLX_FWD_CLK_SELECT_REG_SELECT_r            (TLX_CLK_SELECT),
    .L2H_CGRA_CLK_SELECT_REG_SELECT_r               (CGRA_CLK_SELECT),
    .L2H_TIMER0_CLK_SELECT_REG_SELECT_r             (TIMER0_CLK_SELECT),
    .L2H_TIMER1_CLK_SELECT_REG_SELECT_r             (TIMER1_CLK_SELECT),
    .L2H_UART0_CLK_SELECT_REG_SELECT_r              (UART0_CLK_SELECT),
    .L2H_UART1_CLK_SELECT_REG_SELECT_r              (UART1_CLK_SELECT),
    .L2H_WDOG_CLK_SELECT_REG_SELECT_r               (WDOG_CLK_SELECT),
    .L2H_CLK_GATE_EN_REG_CPU_r                      (l2h_CLK_GATE_EN_REG_CPU_r),
    .L2H_CLK_GATE_EN_REG_DAP_r                      (l2h_CLK_GATE_EN_REG_DAP_r),
    .L2H_CLK_GATE_EN_REG_DMA0_r                     (l2h_CLK_GATE_EN_REG_DMA0_r),
    .L2H_CLK_GATE_EN_REG_DMA1_r                     (l2h_CLK_GATE_EN_REG_DMA1_r),
    .L2H_CLK_GATE_EN_REG_SRAMX_r                    (l2h_CLK_GATE_EN_REG_SRAMx_r),
    .L2H_CLK_GATE_EN_REG_TLX_FWD_r                  (l2h_CLK_GATE_EN_REG_TLX_FWD_r),
    .L2H_CLK_GATE_EN_REG_GGRA_r                     (l2h_CLK_GATE_EN_REG_GGRA_r),
    .L2H_CLK_GATE_EN_REG_NIC_r                      (l2h_CLK_GATE_EN_REG_NIC_r),
    .L2H_CLK_GATE_EN_REG_TIMER0_r                   (l2h_CLK_GATE_EN_REG_TIMER0_r),
    .L2H_CLK_GATE_EN_REG_TIMER1_r                   (l2h_CLK_GATE_EN_REG_TIMER1_r),
    .L2H_CLK_GATE_EN_REG_UART0_r                    (l2h_CLK_GATE_EN_REG_UART0_r),
    .L2H_CLK_GATE_EN_REG_UART1_r                    (l2h_CLK_GATE_EN_REG_UART1_r),
    .L2H_CLK_GATE_EN_REG_WDOG_r                     (l2h_CLK_GATE_EN_REG_WDOG_r),
    .L2H_SYS_RESET_PROP_REG_DMA0_r                  (DMA0_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_DMA1_r                  (DMA1_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_SRAMX_r                 (SRAM_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_TLX_FWD_r               (TLX_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_GGRA_r                  (CGRA_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_NIC_r                   (NIC_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_TIMER0_r                (TIMER0_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_TIMER1_r                (TIMER1_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_UART0_r                 (UART0_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_UART1_r                 (UART1_SYS_RESET_EN),
    .L2H_SYS_RESET_PROP_REG_WDOG_r                  (WDOG_SYS_RESET_EN),
    .L2H_RESET_REQ_REG_DMA0_r                       (DMA0_RESET_REQ),
    .L2H_RESET_REQ_REG_DMA1_r                       (DMA1_RESET_REQ),
    .L2H_RESET_REQ_REG_TLX_FWD_r                    (TLX_RESET_REQ),
    .L2H_RESET_REQ_REG_TLX_REV_r                    (TLX_REV_RESET_REQ),
    .L2H_RESET_REQ_REG_GGRA_r                       (CGRA_RESET_REQ),
    .L2H_RESET_REQ_REG_NIC_r                        (NIC_RESET_REQ),
    .L2H_RESET_REQ_REG_TIMER0_r                     (TIMER0_RESET_REQ),
    .L2H_RESET_REQ_REG_TIMER1_r                     (TIMER1_RESET_REQ),
    .L2H_RESET_REQ_REG_UART0_r                      (UART0_RESET_REQ),
    .L2H_RESET_REQ_REG_UART1_r                      (UART1_RESET_REQ),
    .L2H_RESET_REQ_REG_WDOG_r                       (WDOG_RESET_REQ),
    .L2H_SYS_TICK_CONFIG_REG_CALIB_r                (SYS_TICK_CALIB),
    .L2H_SYS_TICK_CONFIG_REG_NOT_10_MS_r            (SYS_TICK_NOT_10MS_MULT),
    .L2H_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r       (l2h_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r),
    .L2H_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r (l2h_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r)
  );

//------------------------------------------------------------------------------
// System Reset Req Generation
//------------------------------------------------------------------------------
AhaSysResetReqGen u_sys_reset_req_combined (
  .CLK                            (CLK),
  .RESETn                         (RESETn),

  .SYSRESETREQ                    (SYSRESETREQ),
  .LOCKUP                         (LOCKUP),
  .LOCKUP_RESET_EN                (l2h_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r),
  .WDOG_TIMEOUT_RESET             (WDOG_TIMEOUT_RESET_REQ),
  .WDOG_TIMEOUT_RESET_EN          (l2h_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r),

  .SYSRESETREQ_COMBINED           (SYSRESETREQ_COMBINED)
);

//------------------------------------------------------------------------------
// SysTick Clock Change Monitor
//------------------------------------------------------------------------------
  AhaSyncPulseGen u_sys_tick_clock_change_mon (
    .CLK                          (CLK),
    .RESETn                       (RESETn),
    .D                            (l2h_SYS_CLK_SELECT_REG_SELECT_swmod_o),
    .RISE_PULSE                   (CPU_CLK_CHANGED),
    .FALL_PULSE                   ()
  );

//------------------------------------------------------------------------------
// Power Management
//------------------------------------------------------------------------------
  AhaPowerMgmtUnit u_pwr_mgmt (
    .CLK                          (CLK),
    .RESETn                       (RESETn),

    // Input Control
    .DBGPWRUPREQ                  (DBGPWRUPREQ),
    .DBGSYSPWRUPREQ               (DBGSYSPWRUPREQ),
    .PMU_WIC_EN_ACK               (PMU_WIC_EN_ACK),
    .PMU_WAKEUP                   (PMU_WAKEUP),
    .SLEEP                        (SLEEP),
    .SLEEPDEEP                    (SLEEPDEEP),
    .SLEEPHOLDACKn                (SLEEPHOLDACKn),

    .CPU_CLK_GATE_EN_in           (l2h_CLK_GATE_EN_REG_CPU_r),
    .DAP_CLK_GATE_EN_in           (l2h_CLK_GATE_EN_REG_DAP_r),
    .DMA0_CLK_GATE_EN_in          (l2h_CLK_GATE_EN_REG_DMA0_r),
    .DMA1_CLK_GATE_EN_in          (l2h_CLK_GATE_EN_REG_DMA1_r),
    .SRAM_CLK_GATE_EN_in          (l2h_CLK_GATE_EN_REG_SRAMx_r),
    .TLX_CLK_GATE_EN_in           (l2h_CLK_GATE_EN_REG_TLX_FWD_r),
    .CGRA_CLK_GATE_EN_in          (l2h_CLK_GATE_EN_REG_GGRA_r),
    .NIC_CLK_GATE_EN_in           (l2h_CLK_GATE_EN_REG_NIC_r),
    .TIMER0_CLK_GATE_EN_in        (l2h_CLK_GATE_EN_REG_TIMER0_r),
    .TIMER1_CLK_GATE_EN_in        (l2h_CLK_GATE_EN_REG_TIMER1_r),
    .UART0_CLK_GATE_EN_in         (l2h_CLK_GATE_EN_REG_UART0_r),
    .UART1_CLK_GATE_EN_in         (l2h_CLK_GATE_EN_REG_UART1_r),
    .WDOG_CLK_GATE_EN_in          (l2h_CLK_GATE_EN_REG_WDOG_r),

    // Output Control
    .DBGPWRUPACK                  (DBGPWRUPACK),
    .DBGSYSPWRUPACK               (DBGSYSPWRUPACK),
    .SLEEPHOLDREQn                (SLEEPHOLDREQn),
    .PMU_WIC_EN_REQ               (PMU_WIC_EN_REQ),

    .CPU_CLK_GATE_EN_out          (CPU_CLK_GATE_EN),
    .DAP_CLK_GATE_EN_out          (DAP_CLK_GATE_EN),
    .DMA0_CLK_GATE_EN_out         (DMA0_CLK_GATE_EN),
    .DMA1_CLK_GATE_EN_out         (DMA1_CLK_GATE_EN),
    .SRAM_CLK_GATE_EN_out         (SRAM_CLK_GATE_EN),
    .TLX_CLK_GATE_EN_out          (TLX_CLK_GATE_EN),
    .CGRA_CLK_GATE_EN_out         (CGRA_CLK_GATE_EN),
    .NIC_CLK_GATE_EN_out          (NIC_CLK_GATE_EN),
    .TIMER0_CLK_GATE_EN_out       (TIMER0_CLK_GATE_EN),
    .TIMER1_CLK_GATE_EN_out       (TIMER1_CLK_GATE_EN),
    .UART0_CLK_GATE_EN_out        (UART0_CLK_GATE_EN),
    .UART1_CLK_GATE_EN_out        (UART1_CLK_GATE_EN),
    .WDOG_CLK_GATE_EN_out         (WDOG_CLK_GATE_EN)
  );

endmodule
