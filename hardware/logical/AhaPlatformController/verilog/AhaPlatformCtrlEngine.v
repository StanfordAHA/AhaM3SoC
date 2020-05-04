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
  output  wire                SYSRESETREQ_LOCKUP,

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

  // unused inputs
  wire unused = CLK |
                RESETn |
                DMA0_RESET_ACK |
                DMA1_RESET_ACK |
                TLX_RESET_ACK |
                TLX_REV_RESET_ACK |
                CGRA_RESET_ACK |
                NIC_RESET_ACK |
                TIMER0_RESET_ACK |
                TIMER1_RESET_ACK |
                UART0_RESET_ACK |
                UART1_RESET_ACK |
                WDOG_RESET_ACK |
                PMU_WIC_EN_ACK |
                PMU_WAKEUP |
                SLEEP |
                SLEEPDEEP |
                LOCKUP |
                SLEEPHOLDACKn |
                WDOG_TIMEOUT_RESET_REQ |
                (| PCTRL_HSEL ) |
                (| PCTRL_HADDR ) |
                (| PCTRL_HTRANS ) |
                (| PCTRL_HWRITE ) |
                (| PCTRL_HSIZE ) |
                (| PCTRL_HBURST ) |
                (| PCTRL_HPROT ) |
                (| PCTRL_HMASTER ) |
                (| PCTRL_HWDATA ) |
                (| PCTRL_HMASTLOCK ) |
                (| PCTRL_HREADYMUX );

  // Assign Outputs
  // Pad Strength Control
  assign PAD_DS_GRP0          = 3'b000;
  assign PAD_DS_GRP1          = 3'b000;
  assign PAD_DS_GRP2          = 3'b000;
  assign PAD_DS_GRP3          = 3'b000;
  assign PAD_DS_GRP4          = 3'b000;
  assign PAD_DS_GRP5          = 3'b000;
  assign PAD_DS_GRP6          = 3'b000;
  assign PAD_DS_GRP7          = 3'b000;

  // Clock Select Signals
  assign SYS_CLK_SELECT       = 3'b000;
  assign DMA0_PCLK_SELECT     = 3'b000;
  assign DMA1_PCLK_SELECT     = 3'b000;
  assign TLX_CLK_SELECT       = 3'b000;
  assign CGRA_CLK_SELECT      = 3'b000;
  assign TIMER0_CLK_SELECT    = 3'b101;
  assign TIMER1_CLK_SELECT    = 3'b010;
  assign UART0_CLK_SELECT     = 3'b000;
  assign UART1_CLK_SELECT     = 3'b011;
  assign WDOG_CLK_SELECT      = 3'b000;

  // Clock Gate Enable Signals
  assign CPU_CLK_GATE_EN      = 1'b0;
  assign DAP_CLK_GATE_EN      = 1'b0;
  assign DMA0_CLK_GATE_EN     = 1'b0;
  assign DMA1_CLK_GATE_EN     = 1'b0;
  assign SRAM_CLK_GATE_EN     = 1'b0;
  assign NIC_CLK_GATE_EN      = 1'b0;
  assign TLX_CLK_GATE_EN      = 1'b0;
  assign CGRA_CLK_GATE_EN     = 1'b0;
  assign TIMER0_CLK_GATE_EN   = 1'b0;
  assign TIMER1_CLK_GATE_EN   = 1'b0;
  assign UART0_CLK_GATE_EN    = 1'b0;
  assign UART1_CLK_GATE_EN    = 1'b0;
  assign WDOG_CLK_GATE_EN     = 1'b0;

  // System Reset Propagation Control
  assign DMA0_SYS_RESET_EN    = 1'b1;
  assign DMA1_SYS_RESET_EN    = 1'b1;
  assign SRAM_SYS_RESET_EN    = 1'b1;
  assign TLX_SYS_RESET_EN     = 1'b1;
  assign CGRA_SYS_RESET_EN    = 1'b1;
  assign NIC_SYS_RESET_EN     = 1'b1;
  assign TIMER0_SYS_RESET_EN  = 1'b1;
  assign TIMER1_SYS_RESET_EN  = 1'b1;
  assign UART0_SYS_RESET_EN   = 1'b1;
  assign UART1_SYS_RESET_EN   = 1'b1;
  assign WDOG_SYS_RESET_EN    = 1'b1;

  // Peripheral Reset Requests
  assign DMA0_RESET_REQ       = 1'b0;
  assign DMA1_RESET_REQ       = 1'b0;
  assign TLX_RESET_REQ        = 1'b0;
  assign TLX_REV_RESET_REQ    = 1'b0;
  assign CGRA_RESET_REQ       = 1'b0;
  assign NIC_RESET_REQ        = 1'b0;
  assign TIMER0_RESET_REQ     = 1'b0;
  assign TIMER1_RESET_REQ     = 1'b0;
  assign UART0_RESET_REQ      = 1'b0;
  assign UART1_RESET_REQ      = 1'b0;
  assign WDOG_RESET_REQ       = 1'b0;

  // SysTick
  assign CPU_CLK_CHANGED          = 1'b0;
  assign SYS_TICK_NOT_10MS_MULT   = 1'b0;
  assign SYS_TICK_CALIB           = 24'h98967F;

  // Debug and Power Management
  assign DBGPWRUPACK          = DBGPWRUPREQ;
  assign DBGSYSPWRUPACK       = DBGSYSPWRUPREQ;
  assign SLEEPHOLDREQn        = 1'b1;
  assign PMU_WIC_EN_REQ       = 1'b0;
  assign SYSRESETREQ_LOCKUP   = SYSRESETREQ;

  // Control Regspace
  assign PCTRL_HRDATA         = 32'h0;
  assign PCTRL_HREADYOUT      = 1'b1;
  assign PCTRL_HRESP          = 2'b00;

endmodule
