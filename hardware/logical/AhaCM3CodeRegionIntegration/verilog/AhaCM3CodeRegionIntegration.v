//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: CORTEX-M3 Processor Integration with Code Region SRAM
//
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 11, 2020
//------------------------------------------------------------------------------
module AhaCM3CodeRegionIntegration (
  // Resets
  input   wire            CPU_PORESETn,       // CPU Power on reset synchronized to CPU_CLK
  input   wire            CPU_SYSRESETn,      // CPU soft reset synchronized to CPU_CLK
  input   wire            DAP_RESETn,         // Debug system reset synchronized to DAP_CLK
  input   wire            JTAG_TRSTn,         // JTAG Reset synchronized to JTAG Test Clock
  input   wire            JTAG_PORESETn,      // JTAG Power on reset synchronized to JTAG_TCK
  input   wire            TPIU_RESETn,        // TPIU Reset (synchronized to TPIU_TRACECLKIN)

  // Clocks
  input   wire            SYS_CLK ,           // CPU-domain free running clock
  input   wire            CPU_CLK,            // CPU-domain gated clock
  input   wire            DAP_CLK,            // DAP Clock
  input   wire            JTAG_TCK,           // JTAG test clock
  input   wire            TPIU_TRACECLKIN,    // TPIU interface clock

  // Clock-related Signals
  input   wire            CPU_CLK_CHANGED,    // Indicates whether CPU clok frequency has changed

  // JTAG/DAP Interface
  input   wire            JTAG_TDI,           // JTAG Data In Port
  input   wire            JTAG_TMS,           // JTAG TMS Port
  output  wire            JTAG_TDO,           // JTAG TDO Port

  // TPIU
  output  wire  [3:0]     TPIU_TRACE_DATA,    // Trace Data
  output  wire            TPIU_TRACE_SWO,     // Trace Single Wire Output
  output  wire            TPIU_TRACE_CLK,     // Trace Output Clock

  // Reset and Power Control
  input   wire            DBGPWRUPACK,        // Acknowledgement for Debug PowerUp Request
  input   wire            DBGRSTACK,          // Acknowledgement for Debug Reset Request
  input   wire            DBGSYSPWRUPACK,     // Acknowledgement for CPU PowerUp Request
  input   wire            SLEEPHOLDREQn,      // Request to extend Sleep
  input   wire            PMU_WIC_EN_REQ,     // PMU Request to Enable WIC
  output  wire            PMU_WIC_EN_ACK,     // WIC Response to PMU Enable Request
  output  wire            PMU_WAKEUP,         // WIC Requests PMU to Wake Up Processor
  output  wire            INT_REQ,            // An interrupt has been requested
  output  wire            DBGPWRUPREQ,        // Debug Power Up Request
  output  wire            DBGRSTREQ,          // Debug Reset Request
  output  wire            DBGSYSPWRUPREQ,     // Debug Request to Power Up CPU
  output  wire            SLEEP,              // Indicates CPU is in sleep mode (dbg activity might still be on)
  output  wire            SLEEPDEEP,          // Indicates CPU is in deep sleep mode (dbg activity might still be on)
  output  wire            LOCKUP,             // Indicates CPU is locked up
  output  wire            SYSRESETREQ,        // Request CPU Reset
  output  wire            SLEEPHOLDACKn,      // Response to sleep extension request

  // System Bus
  input   wire            SYS_HREADY,         // System bus ready
  input   wire [31:0]     SYS_HRDATA,         // System bus read data
  input   wire  [1:0]     SYS_HRESP,          // System bus response
  output  wire [31:0]     SYS_HADDR,          // System bus address
  output  wire  [1:0]     SYS_HTRANS,         // System bus transfer type
  output  wire [ 2:0]     SYS_HSIZE,          // System bus transfer size
  output  wire            SYS_HWRITE,         // System bus write not read
  output  wire  [2:0]     SYS_HBURST,         // System bus burst length
  output  wire  [3:0]     SYS_HPROT,          // System bus HPROT
  output  wire [31:0]     SYS_HWDATA,         // System bus write data

  // Interrupts
  input   wire            TIMER0_INT,         // Timer0 Interrupt
  input   wire            TIMER1_INT,         // Timer1 Interrupt
  input   wire            UART0_TX_RX_INT,    // UART0 Tx and Rx interrupts
  input   wire            UART1_TX_RX_INT,    // UART1 Tx and Rx Interrupts
  input   wire            UART0_TX_RX_O_INT,  // UART0 overflow interrupts
  input   wire            UART1_TX_RX_O_INT,  // UART1 overflow interrupts
  input   wire  [1:0]     DMA0_INT,
  input   wire  [1:0]     DMA1_INT,
  input   wire            CGRA_INT,
  input   wire            WDOG_INT,           // Watchdog interrupt used as NMI
  input   wire            TLX_INT,

  // SysTick
  input   wire            SYS_TICK_NOT_10MS_MULT, // Does the sys-tick calibration value
                                              // provide exact multiple of 10ms from CPU_CLK?
  input   wire [23:0]     SYS_TICK_CALIB      // SysTick calibration value
);

  // I-Code/D-Code wires
  wire            int_code_hready;
  wire [31:0]     int_code_hrdata;
  wire  [1:0]     int_code_hresp;
  wire [31:0]     int_code_haddr;
  wire  [1:0]     int_code_htrans;
  wire [ 2:0]     int_code_hsize;
  wire            int_code_hwrite;
  wire  [2:0]     int_code_hburst;
  wire [31:0]     int_code_hwdata;

  // ==== Instantiate AhaCM3Integration Level
  AhaCM3Integration u_aha_cm3_integration (
    // Resets
    .CPU_PORESETn         (CPU_PORESETn),
    .CPU_SYSRESETn        (CPU_SYSRESETn),
    .DAP_RESETn           (DAP_RESETn),
    .JTAG_TRSTn           (JTAG_TRSTn),
    .JTAG_PORESETn        (JTAG_PORESETn),
    .TPIU_RESETn          (TPIU_RESETn),

    // Clocks
    .SYS_CLK              (SYS_CLK),
    .CPU_CLK              (CPU_CLK),
    .DAP_CLK              (DAP_CLK),
    .JTAG_TCK             (JTAG_TCK),
    .TPIU_TRACECLKIN      (TPIU_TRACECLKIN),

    // Clock-related
    .CPU_CLK_CHANGED      (CPU_CLK_CHANGED),

    // JTAG
    .JTAG_TDI             (JTAG_TDI),
    .JTAG_TMS             (JTAG_TMS),
    .JTAG_TDO             (JTAG_TDO),

    // Trace
    .TPIU_TRACE_DATA      (TPIU_TRACE_DATA),
    .TPIU_TRACE_SWO       (TPIU_TRACE_SWO),
    .TPIU_TRACE_CLK       (TPIU_TRACE_CLK),

    // Reset and PMU
    .DBGPWRUPACK          (DBGPWRUPACK),
    .DBGRSTACK            (DBGRSTACK),
    .DBGSYSPWRUPACK       (DBGSYSPWRUPACK),
    .SLEEPHOLDREQn        (SLEEPHOLDREQn),
    .PMU_WIC_EN_REQ       (PMU_WIC_EN_REQ),
    .PMU_WIC_EN_ACK       (PMU_WIC_EN_ACK),
    .PMU_WAKEUP           (PMU_WAKEUP),
    .INT_REQ              (INT_REQ),
    .DBGPWRUPREQ          (DBGPWRUPREQ),
    .DBGRSTREQ            (DBGRSTREQ),
    .DBGSYSPWRUPREQ       (DBGSYSPWRUPREQ),
    .SLEEP                (SLEEP),
    .SLEEPDEEP            (SLEEPDEEP),
    .LOCKUP               (LOCKUP),
    .SYSRESETREQ          (SYSRESETREQ),
    .SLEEPHOLDACKn        (SLEEPHOLDACKn),

    // Merged CM3 I/D Code
    .CODE_HREADY          (int_code_hready),
    .CODE_HRDATA          (int_code_hrdata),
    .CODE_HRESP           (int_code_hresp),
    .CODE_HADDR           (int_code_haddr),
    .CODE_HTRANS          (int_code_htrans),
    .CODE_HSIZE           (int_code_hsize),
    .CODE_HWRITE          (int_code_hwrite),
    .CODE_HBURST          (int_code_hburst),
    .CODE_HWDATA          (int_code_hwdata),

    // CM3 Sys Bus
    .SYS_HREADY           (SYS_HREADY),
    .SYS_HRDATA           (SYS_HRDATA),
    .SYS_HRESP            (SYS_HRESP),
    .SYS_HADDR            (SYS_HADDR),
    .SYS_HTRANS           (SYS_HTRANS),
    .SYS_HSIZE            (SYS_HSIZE),
    .SYS_HWRITE           (SYS_HWRITE),
    .SYS_HBURST           (SYS_HBURST),
    .SYS_HPROT            (SYS_HPROT),
    .SYS_HWDATA           (SYS_HWDATA),

    // Interrupts
    .TIMER0_INT           (TIMER0_INT),
    .TIMER1_INT           (TIMER1_INT),
    .UART0_TX_RX_INT      (UART0_TX_RX_INT),
    .UART1_TX_RX_INT      (UART1_TX_RX_INT),
    .UART0_TX_RX_O_INT    (UART0_TX_RX_O_INT),
    .UART1_TX_RX_O_INT    (UART1_TX_RX_O_INT),
    .DMA0_INT             (DMA0_INT),
    .DMA1_INT             (DMA1_INT),
    .CGRA_INT             (CGRA_INT),
    .WDOG_INT             (WDOG_INT),
    .TLX_INT              (TLX_INT),

    // SysTick
    .SYS_TICK_CALIB       (SYS_TICK_CALIB),
    .SYS_TICK_NOT_10MS_MULT   (SYS_TICK_NOT_10MS_MULT)
  );

  // ===== Code Region SRAM Instantiation
  AhaAhbCodeRegion u_code_region (
    .HCLK                 (CPU_CLK),
    .HRESETn              (CPU_SYSRESETn),
    .HSEL                 (1'b1),
    .HREADY               (1'b1),
    .HTRANS               (int_code_htrans),
    .HSIZE                (int_code_hsize),
    .HWRITE               (int_code_hwrite),
    .HADDR                (int_code_haddr),
    .HWDATA               (int_code_hwdata),
    .HREADYOUT            (int_code_hready),
    .HRESP                (int_code_hresp),
    .HRDATA               (int_code_hrdata)
  );

endmodule
