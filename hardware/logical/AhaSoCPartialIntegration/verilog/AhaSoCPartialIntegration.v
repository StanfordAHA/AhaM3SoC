//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Partial SoC Integration.
//          (Includes Processor, Peripherals, DMAs, SRAMS, System Interconnect)
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaSoCPartialIntegration (
  // Resets
  input   wire            CPU_PORESETn,       // CPU Power on reset synchronized to CPU_CLK
  input   wire            CPU_SYSRESETn,      // CPU soft reset synchronized to CPU_CLK
  input   wire            DAP_RESETn,         // Debug system reset synchronized to DAP_CLK
  input   wire            JTAG_TRSTn,         // JTAG Reset synchronized to JTAG Test Clock
  input   wire            JTAG_PORESETn,      // JTAG Power on reset synchronized to JTAG_TCK
  input   wire            SRAM_RESETn,        // SRAM0 Reset
  input   wire            TLX_RESETn,         // TLX Reset (Slave IF Block)
  input   wire            CGRA_RESETn,        // CGRA Reset
  input   wire            DMA0_RESETn,        // DMA0 Reset
  input   wire            DMA1_RESETn,        // DMA1 Reset
  input   wire            PERIPH_RESETn,      // Peripheral Bus Reset
  input   wire            TIMER0_RESETn,      // Timer0 Reset
  input   wire            TIMER1_RESETn,      // Timer1 Reset
  input   wire            UART0_RESETn,       // UART0 Reset
  input   wire            UART1_RESETn,       // UART1 Reset
  input   wire            WDOG_RESETn,        // Watchdog Reset
  input   wire            NIC_RESETn,         // Interconnect Reset

  // Clocks
  input   wire            SYS_CLK,            // system free running clock
  input   wire            CPU_CLK,            // CPU-domain gated clock
  input   wire            DAP_CLK,            // DAP clock
  input   wire            JTAG_TCK,           // JTAG test clock
  input   wire            SRAM_CLK,           // SRAM Clock
  input   wire            TLX_CLK,            // TLX Clock (Slave IF Block)
  input   wire            CGRA_CLK,           // CGRA Clock
  input   wire            DMA0_CLK,           // DMA0 Clock
  input   wire            DMA1_CLK,           // DMA1 Clock
  input   wire            TIMER0_CLK,         // Timer0 Clock
  input   wire            TIMER1_CLK,         // Timer1 Clock
  input   wire            UART0_CLK,          // UART0 Clock
  input   wire            UART1_CLK,          // UART1 Clock
  input   wire            WDOG_CLK,           // Watchdog Clock
  input   wire            NIC_CLK,            // Interconnect Clock

  // Clock-related Signals
  input   wire            CPU_CLK_CHANGED,    // Indicates whether CPU clok frequency has changed
  input   wire            TIMER0_CLKEN,       // Qualifier for PERIPH Clock
  input   wire            TIMER1_CLKEN,       // Qualifier for PERIPH Clock
  input   wire            UART0_CLKEN,        // Qualifier for PERIPH Clock
  input   wire            UART1_CLKEN,        // Qualifier for PERIPH Clock
  input   wire            WDOG_CLKEN,         // Qualifier for PERIPH Clock
  input   wire            DMA0_CLKEN,         // Qualifier for DMA0 and PERIPH Clocks
  input   wire            DMA1_CLKEN,         // Qualifier for DMA1 and PERIPH Clocks

  // JTAG/DAP Interface
  input   wire            JTAG_TDI,           // JTAG Data In Port
  input   wire            JTAG_TMS,           // JTAG TMS Port
  output  wire            JTAG_TDO,           // JTAG TDO Port

  // TPIU
  output  wire  [3:0]     TPIU_TRACE_DATA,    // Trace Data
  output  wire            TPIU_TRACE_SWO,     // Trace Single Wire Output
  output  wire            TPIU_TRACE_CLK,     // Trace Output Clock

  // UART
  input   wire            UART0_RXD,          // UART0 Rx Data
  output  wire            UART0_TXD,          // UART0 Tx Data
  input   wire            UART1_RXD,          // UART1 Rx Data
  output  wire            UART1_TXD,          // UART1 Tx Data

  // Reset and Power Control
  input   wire            DBGPWRUPACK,        // Acknowledgement for Debug PowerUp Request
  input   wire            DBGRSTACK,          // Acknowledgement for Debug Reset Request
  input   wire            DBGSYSPWRUPACK,     // Acknowledgement for CPU PowerUp Request
  input   wire            SLEEPHOLDREQn,      // Request to extend Sleep
  input   wire            PMU_WIC_EN_REQ,     // PMU Request to Enable WIC
  output  wire            PMU_WIC_EN_ACK,     // WIC Response to PMU Enable Request
  output  wire            PMU_WAKEUP,         // WIC Requests PMU to Wake Up Processor
  output  wire            INT_REQ,            // An interrupt request is pending
  output  wire            DBGPWRUPREQ,        // Debug Power Up Request
  output  wire            DBGRSTREQ,          // Debug Reset Request
  output  wire            DBGSYSPWRUPREQ,     // Debug Request to Power Up CPU
  output  wire            SLEEP,              // Indicates CPU is in sleep mode (dbg activity might still be on)
  output  wire            SLEEPDEEP,          // Indicates CPU is in deep sleep mode (dbg activity might still be on)
  output  wire            LOCKUP,             // Indicates CPU is locked up
  output  wire            SYSRESETREQ,        // Request CPU Reset
  output  wire            SLEEPHOLDACKn,      // Response to sleep extension request
  output  wire            WDOG_RESET_REQ,     // Wdog reset

  // SysTick
  input   wire            SYS_TICK_NOT_10MS_MULT, // Does the sys-tick calibration value
                                              // provide exact multiple of 10ms from CPU_CLK?
  input   wire [23:0]     SYS_TICK_CALIB,     // SysTick calibration value

  // CGRA
  input   wire            CGRA_INT,           // CGRA Interrupt

  output  wire [3 :0]     CGRA_DATA_AWID,
  output  wire [31:0]     CGRA_DATA_AWADDR,
  output  wire [7 :0]     CGRA_DATA_AWLEN,
  output  wire [2 :0]     CGRA_DATA_AWSIZE,
  output  wire [1 :0]     CGRA_DATA_AWBURST,
  output  wire            CGRA_DATA_AWLOCK,
  output  wire [3 :0]     CGRA_DATA_AWCACHE,
  output  wire [2 :0]     CGRA_DATA_AWPROT,
  output  wire            CGRA_DATA_AWVALID,
  input   wire            CGRA_DATA_AWREADY,
  output  wire [63:0]     CGRA_DATA_WDATA,
  output  wire [7 :0]     CGRA_DATA_WSTRB,
  output  wire            CGRA_DATA_WLAST,
  output  wire            CGRA_DATA_WVALID,
  input   wire            CGRA_DATA_WREADY,
  input   wire [3 :0]     CGRA_DATA_BID,
  input   wire [1 :0]     CGRA_DATA_BRESP,
  input   wire            CGRA_DATA_BVALID,
  output  wire            CGRA_DATA_BREADY,
  output  wire [3 :0]     CGRA_DATA_ARID,
  output  wire [31:0]     CGRA_DATA_ARADDR,
  output  wire [7 :0]     CGRA_DATA_ARLEN,
  output  wire [2 :0]     CGRA_DATA_ARSIZE,
  output  wire [1 :0]     CGRA_DATA_ARBURST,
  output  wire            CGRA_DATA_ARLOCK,
  output  wire [3 :0]     CGRA_DATA_ARCACHE,
  output  wire [2 :0]     CGRA_DATA_ARPROT,
  output  wire            CGRA_DATA_ARVALID,
  input   wire            CGRA_DATA_ARREADY,
  input   wire [3 :0]     CGRA_DATA_RID,
  input   wire [63:0]     CGRA_DATA_RDATA,
  input   wire [1 :0]     CGRA_DATA_RRESP,
  input   wire            CGRA_DATA_RLAST,
  input   wire            CGRA_DATA_RVALID,
  output  wire            CGRA_DATA_RREADY,

  output  wire [3:0]      CGRA_REG_AWID,
  output  wire [31:0]     CGRA_REG_AWADDR,
  output  wire [7:0]      CGRA_REG_AWLEN,
  output  wire [2:0]      CGRA_REG_AWSIZE,
  output  wire [1:0]      CGRA_REG_AWBURST,
  output  wire            CGRA_REG_AWLOCK,
  output  wire [3:0]      CGRA_REG_AWCACHE,
  output  wire [2:0]      CGRA_REG_AWPROT,
  output  wire            CGRA_REG_AWVALID,
  input   wire            CGRA_REG_AWREADY,
  output  wire [31:0]     CGRA_REG_WDATA,
  output  wire [3:0]      CGRA_REG_WSTRB,
  output  wire            CGRA_REG_WLAST,
  output  wire            CGRA_REG_WVALID,
  input   wire            CGRA_REG_WREADY,
  input   wire [3:0]      CGRA_REG_BID,
  input   wire [1:0]      CGRA_REG_BRESP,
  input   wire            CGRA_REG_BVALID,
  output  wire            CGRA_REG_BREADY,
  output  wire [3:0]      CGRA_REG_ARID,
  output  wire [31:0]     CGRA_REG_ARADDR,
  output  wire [7:0]      CGRA_REG_ARLEN,
  output  wire [2:0]      CGRA_REG_ARSIZE,
  output  wire [1:0]      CGRA_REG_ARBURST,
  output  wire            CGRA_REG_ARLOCK,
  output  wire [3:0]      CGRA_REG_ARCACHE,
  output  wire [2:0]      CGRA_REG_ARPROT,
  output  wire            CGRA_REG_ARVALID,
  input   wire            CGRA_REG_ARREADY,
  input   wire [3:0]      CGRA_REG_RID,
  input   wire [31:0]     CGRA_REG_RDATA,
  input   wire [1:0]      CGRA_REG_RRESP,
  input   wire            CGRA_REG_RLAST,
  input   wire            CGRA_REG_RVALID,
  output  wire            CGRA_REG_RREADY,

  // TLX
  input   wire            TLX_INT,

  output  wire [3:0]      TLX_AWID,
  output  wire [31:0]     TLX_AWADDR,
  output  wire [7:0]      TLX_AWLEN,
  output  wire [2:0]      TLX_AWSIZE,
  output  wire [1:0]      TLX_AWBURST,
  output  wire            TLX_AWLOCK,
  output  wire [3:0]      TLX_AWCACHE,
  output  wire [2:0]      TLX_AWPROT,
  output  wire            TLX_AWVALID,
  input   wire            TLX_AWREADY,
  output  wire [63:0]     TLX_WDATA,
  output  wire [7:0]      TLX_WSTRB,
  output  wire            TLX_WLAST,
  output  wire            TLX_WVALID,
  input   wire            TLX_WREADY,
  input   wire [3:0]      TLX_BID,
  input   wire [1:0]      TLX_BRESP,
  input   wire            TLX_BVALID,
  output  wire            TLX_BREADY,
  output  wire [3:0]      TLX_ARID,
  output  wire [31:0]     TLX_ARADDR,
  output  wire [7:0]      TLX_ARLEN,
  output  wire [2:0]      TLX_ARSIZE,
  output  wire [1:0]      TLX_ARBURST,
  output  wire            TLX_ARLOCK,
  output  wire [3:0]      TLX_ARCACHE,
  output  wire [2:0]      TLX_ARPROT,
  output  wire            TLX_ARVALID,
  input   wire            TLX_ARREADY,
  input   wire [3:0]      TLX_RID,
  input   wire [63:0]     TLX_RDATA,
  input   wire [1:0]      TLX_RRESP,
  input   wire            TLX_RLAST,
  input   wire            TLX_RVALID,
  output  wire            TLX_RREADY,

  output  wire [31:0]     TLX_HADDR,
  output  wire [2:0]      TLX_HBURST,
  output  wire [3:0]      TLX_HPROT,
  output  wire [2:0]      TLX_HSIZE,
  output  wire [1:0]      TLX_HTRANS,
  output  wire [31:0]     TLX_HWDATA,
  output  wire            TLX_HWRITE,
  input   wire [31:0]     TLX_HRDATA,
  input   wire            TLX_HREADYOUT,
  input   wire            TLX_HRESP,
  output  wire            TLX_HSELx,
  output  wire            TLX_HREADY,

  // Platform Controller
  output  wire            PCTRL_HSEL,
  output  wire [31:0]     PCTRL_HADDR,
  output  wire  [1:0]     PCTRL_HTRANS,
  output  wire            PCTRL_HWRITE,
  output  wire  [2:0]     PCTRL_HSIZE,
  output  wire  [2:0]     PCTRL_HBURST,
  output  wire  [3:0]     PCTRL_HPROT,
  output  wire  [3:0]     PCTRL_HMASTER,
  output  wire [31:0]     PCTRL_HWDATA,
  output  wire            PCTRL_HMASTLOCK,
  output  wire            PCTRL_HREADYMUX,

  input   wire [31:0]     PCTRL_HRDATA,
  input   wire            PCTRL_HREADYOUT,
  input   wire [1:0]      PCTRL_HRESP
);

  // CPU Integration Wires
  wire [31:0]     cpu_haddr;
  wire [2 :0]     cpu_hburst;
  wire [3 :0]     cpu_hprot;
  wire [2 :0]     cpu_hsize;
  wire [1 :0]     cpu_htrans;
  wire [31:0]     cpu_hwdata;
  wire            cpu_hwrite;
  wire [31:0]     cpu_hrdata;
  wire [1 :0]     cpu_hresp;
  wire            cpu_hready;

  // DMA0 Wires
  wire [1 :0]     dma0_awid;
  wire [31:0]     dma0_awaddr;
  wire [7 :0]     dma0_awlen;
  wire [2 :0]     dma0_awsize;
  wire [1 :0]     dma0_awburst;
  wire            dma0_awlock;
  wire [3 :0]     dma0_awcache;
  wire [2 :0]     dma0_awprot;
  wire            dma0_awvalid;
  wire            dma0_awready;
  wire [63:0]     dma0_wdata;
  wire [7 :0]     dma0_wstrb;
  wire            dma0_wlast;
  wire            dma0_wvalid;
  wire            dma0_wready;
  wire [1 :0]     dma0_bid;
  wire [1 :0]     dma0_bresp;
  wire            dma0_bvalid;
  wire            dma0_bready;
  wire [1 :0]     dma0_arid;
  wire [31:0]     dma0_araddr;
  wire [7 :0]     dma0_arlen;
  wire [2 :0]     dma0_arsize;
  wire [1 :0]     dma0_arburst;
  wire            dma0_arlock;
  wire [3 :0]     dma0_arcache;
  wire [2 :0]     dma0_arprot;
  wire            dma0_arvalid;
  wire            dma0_arready;
  wire [1 :0]     dma0_rid;
  wire [63:0]     dma0_rdata;
  wire [1 :0]     dma0_rresp;
  wire            dma0_rlast;
  wire            dma0_rvalid;
  wire            dma0_rready;

  wire [11:0]     dma0_paddr;
  wire            dma0_penable;
  wire            dma0_pwrite;
  wire            dma0_psel;
  wire [31:0]     dma0_pwdata;
  wire [31:0]     dma0_prdata;
  wire            dma0_pready;
  wire            dma0_pslverr;

  // DMA1 Wires
  wire [1 :0]     dma1_awid;
  wire [31:0]     dma1_awaddr;
  wire [7 :0]     dma1_awlen;
  wire [2 :0]     dma1_awsize;
  wire [1 :0]     dma1_awburst;
  wire            dma1_awlock;
  wire [3 :0]     dma1_awcache;
  wire [2 :0]     dma1_awprot;
  wire            dma1_awvalid;
  wire            dma1_awready;
  wire [63:0]     dma1_wdata;
  wire [7 :0]     dma1_wstrb;
  wire            dma1_wlast;
  wire            dma1_wvalid;
  wire            dma1_wready;
  wire [1 :0]     dma1_bid;
  wire [1 :0]     dma1_bresp;
  wire            dma1_bvalid;
  wire            dma1_bready;
  wire [1 :0]     dma1_arid;
  wire [31:0]     dma1_araddr;
  wire [7 :0]     dma1_arlen;
  wire [2 :0]     dma1_arsize;
  wire [1 :0]     dma1_arburst;
  wire            dma1_arlock;
  wire [3 :0]     dma1_arcache;
  wire [2 :0]     dma1_arprot;
  wire            dma1_arvalid;
  wire            dma1_arready;
  wire [1 :0]     dma1_rid;
  wire [63:0]     dma1_rdata;
  wire [1 :0]     dma1_rresp;
  wire            dma1_rlast;
  wire            dma1_rvalid;
  wire            dma1_rready;

  wire [11:0]     dma1_paddr;
  wire            dma1_penable;
  wire            dma1_pwrite;
  wire            dma1_psel;
  wire [31:0]     dma1_pwdata;
  wire [31:0]     dma1_prdata;
  wire            dma1_pready;
  wire            dma1_pslverr;

  // SRAM0 Wires
  wire [3 :0]     sram0_awid;
  wire [31:0]     sram0_awaddr;
  wire [7 :0]     sram0_awlen;
  wire [2 :0]     sram0_awsize;
  wire [1 :0]     sram0_awburst;
  wire            sram0_awlock;
  wire [3 :0]     sram0_awcache;
  wire [2 :0]     sram0_awprot;
  wire            sram0_awvalid;
  wire            sram0_awready;
  wire [63:0]     sram0_wdata;
  wire [7 :0]     sram0_wstrb;
  wire            sram0_wlast;
  wire            sram0_wvalid;
  wire            sram0_wready;
  wire [3 :0]     sram0_bid;
  wire [1 :0]     sram0_bresp;
  wire            sram0_bvalid;
  wire            sram0_bready;
  wire [3 :0]     sram0_arid;
  wire [31:0]     sram0_araddr;
  wire [7 :0]     sram0_arlen;
  wire [2 :0]     sram0_arsize;
  wire [1 :0]     sram0_arburst;
  wire            sram0_arlock;
  wire [3 :0]     sram0_arcache;
  wire [2 :0]     sram0_arprot;
  wire            sram0_arvalid;
  wire            sram0_arready;
  wire [3 :0]     sram0_rid;
  wire [63:0]     sram0_rdata;
  wire [1 :0]     sram0_rresp;
  wire            sram0_rlast;
  wire            sram0_rvalid;
  wire            sram0_rready;

  // SRAM1 Wires
  wire [3 :0]     sram1_awid;
  wire [31:0]     sram1_awaddr;
  wire [7 :0]     sram1_awlen;
  wire [2 :0]     sram1_awsize;
  wire [1 :0]     sram1_awburst;
  wire            sram1_awlock;
  wire [3 :0]     sram1_awcache;
  wire [2 :0]     sram1_awprot;
  wire            sram1_awvalid;
  wire            sram1_awready;
  wire [63:0]     sram1_wdata;
  wire [7 :0]     sram1_wstrb;
  wire            sram1_wlast;
  wire            sram1_wvalid;
  wire            sram1_wready;
  wire [3 :0]     sram1_bid;
  wire [1 :0]     sram1_bresp;
  wire            sram1_bvalid;
  wire            sram1_bready;
  wire [3 :0]     sram1_arid;
  wire [31:0]     sram1_araddr;
  wire [7 :0]     sram1_arlen;
  wire [2 :0]     sram1_arsize;
  wire [1 :0]     sram1_arburst;
  wire            sram1_arlock;
  wire [3 :0]     sram1_arcache;
  wire [2 :0]     sram1_arprot;
  wire            sram1_arvalid;
  wire            sram1_arready;
  wire [3 :0]     sram1_rid;
  wire [63:0]     sram1_rdata;
  wire [1 :0]     sram1_rresp;
  wire            sram1_rlast;
  wire            sram1_rvalid;
  wire            sram1_rready;

  // SRAM2 Wires
  wire [3 :0]     sram2_awid;
  wire [31:0]     sram2_awaddr;
  wire [7 :0]     sram2_awlen;
  wire [2 :0]     sram2_awsize;
  wire [1 :0]     sram2_awburst;
  wire            sram2_awlock;
  wire [3 :0]     sram2_awcache;
  wire [2 :0]     sram2_awprot;
  wire            sram2_awvalid;
  wire            sram2_awready;
  wire [63:0]     sram2_wdata;
  wire [7 :0]     sram2_wstrb;
  wire            sram2_wlast;
  wire            sram2_wvalid;
  wire            sram2_wready;
  wire [3 :0]     sram2_bid;
  wire [1 :0]     sram2_bresp;
  wire            sram2_bvalid;
  wire            sram2_bready;
  wire [3 :0]     sram2_arid;
  wire [31:0]     sram2_araddr;
  wire [7 :0]     sram2_arlen;
  wire [2 :0]     sram2_arsize;
  wire [1 :0]     sram2_arburst;
  wire            sram2_arlock;
  wire [3 :0]     sram2_arcache;
  wire [2 :0]     sram2_arprot;
  wire            sram2_arvalid;
  wire            sram2_arready;
  wire [3 :0]     sram2_rid;
  wire [63:0]     sram2_rdata;
  wire [1 :0]     sram2_rresp;
  wire            sram2_rlast;
  wire            sram2_rvalid;
  wire            sram2_rready;

  // SRAM3 Wires
  wire [3 :0]     sram3_awid;
  wire [31:0]     sram3_awaddr;
  wire [7 :0]     sram3_awlen;
  wire [2 :0]     sram3_awsize;
  wire [1 :0]     sram3_awburst;
  wire            sram3_awlock;
  wire [3 :0]     sram3_awcache;
  wire [2 :0]     sram3_awprot;
  wire            sram3_awvalid;
  wire            sram3_awready;
  wire [63:0]     sram3_wdata;
  wire [7 :0]     sram3_wstrb;
  wire            sram3_wlast;
  wire            sram3_wvalid;
  wire            sram3_wready;
  wire [3 :0]     sram3_bid;
  wire [1 :0]     sram3_bresp;
  wire            sram3_bvalid;
  wire            sram3_bready;
  wire [3 :0]     sram3_arid;
  wire [31:0]     sram3_araddr;
  wire [7 :0]     sram3_arlen;
  wire [2 :0]     sram3_arsize;
  wire [1 :0]     sram3_arburst;
  wire            sram3_arlock;
  wire [3 :0]     sram3_arcache;
  wire [2 :0]     sram3_arprot;
  wire            sram3_arvalid;
  wire            sram3_arready;
  wire [3 :0]     sram3_rid;
  wire [63:0]     sram3_rdata;
  wire [1 :0]     sram3_rresp;
  wire            sram3_rlast;
  wire            sram3_rvalid;
  wire            sram3_rready;

  // Peripheral Subsystem Wires
  wire [31:0]     periph_haddr;
  wire [2 :0]     periph_hburst;
  wire [3 :0]     periph_hprot;
  wire [2 :0]     periph_hsize;
  wire [1 :0]     periph_htrans;
  wire [31:0]     periph_hwdata;
  wire            periph_hwrite;
  wire [31:0]     periph_hrdata;
  wire            periph_hreadyout;
  wire  [1:0]     periph_hresp;
  wire            periph_hsel;
  wire            periph_hready;

  wire            timer0_int;
  wire            timer1_int;

  wire            uart0_txint;
  wire            uart0_rxint;
  wire            uart0_txovrint;
  wire            uart0_rxovrint;
  wire            uart0_uartint;

  wire            uart1_txint;
  wire            uart1_rxint;
  wire            uart1_txovrint;
  wire            uart1_rxovrint;
  wire            uart1_uartint;

  wire [1:0]      dma0_int;
  wire [1:0]      dma1_int;
  wire            wdog_int;

  // Instantiate System Interconnect
  nic400_AhaIntegration u_nic_interconnect (
    // CGRA Data
    .AWID_master_CGRA_DATA                  (CGRA_DATA_AWID),
    .AWADDR_master_CGRA_DATA                (CGRA_DATA_AWADDR),
    .AWLEN_master_CGRA_DATA                 (CGRA_DATA_AWLEN),
    .AWSIZE_master_CGRA_DATA                (CGRA_DATA_AWSIZE),
    .AWBURST_master_CGRA_DATA               (CGRA_DATA_AWBURST),
    .AWLOCK_master_CGRA_DATA                (CGRA_DATA_AWLOCK),
    .AWCACHE_master_CGRA_DATA               (CGRA_DATA_AWCACHE),
    .AWPROT_master_CGRA_DATA                (CGRA_DATA_AWPROT),
    .AWVALID_master_CGRA_DATA               (CGRA_DATA_AWVALID),
    .AWREADY_master_CGRA_DATA               (CGRA_DATA_AWREADY),
    .WDATA_master_CGRA_DATA                 (CGRA_DATA_WDATA),
    .WSTRB_master_CGRA_DATA                 (CGRA_DATA_WSTRB),
    .WLAST_master_CGRA_DATA                 (CGRA_DATA_WLAST),
    .WVALID_master_CGRA_DATA                (CGRA_DATA_WVALID),
    .WREADY_master_CGRA_DATA                (CGRA_DATA_WREADY),
    .BID_master_CGRA_DATA                   (CGRA_DATA_BID),
    .BRESP_master_CGRA_DATA                 (CGRA_DATA_BRESP),
    .BVALID_master_CGRA_DATA                (CGRA_DATA_BVALID),
    .BREADY_master_CGRA_DATA                (CGRA_DATA_BREADY),
    .ARID_master_CGRA_DATA                  (CGRA_DATA_ARID),
    .ARADDR_master_CGRA_DATA                (CGRA_DATA_ARADDR),
    .ARLEN_master_CGRA_DATA                 (CGRA_DATA_ARLEN),
    .ARSIZE_master_CGRA_DATA                (CGRA_DATA_ARSIZE),
    .ARBURST_master_CGRA_DATA               (CGRA_DATA_ARBURST),
    .ARLOCK_master_CGRA_DATA                (CGRA_DATA_ARLOCK),
    .ARCACHE_master_CGRA_DATA               (CGRA_DATA_ARCACHE),
    .ARPROT_master_CGRA_DATA                (CGRA_DATA_ARPROT),
    .ARVALID_master_CGRA_DATA               (CGRA_DATA_ARVALID),
    .ARREADY_master_CGRA_DATA               (CGRA_DATA_ARREADY),
    .RID_master_CGRA_DATA                   (CGRA_DATA_RID),
    .RDATA_master_CGRA_DATA                 (CGRA_DATA_RDATA),
    .RRESP_master_CGRA_DATA                 (CGRA_DATA_RRESP),
    .RLAST_master_CGRA_DATA                 (CGRA_DATA_RLAST),
    .RVALID_master_CGRA_DATA                (CGRA_DATA_RVALID),
    .RREADY_master_CGRA_DATA                (CGRA_DATA_RREADY),

    // CGRA REG
    .AWID_master_CGRA_REG                   (CGRA_REG_AWID),
    .AWADDR_master_CGRA_REG                 (CGRA_REG_AWADDR),
    .AWLEN_master_CGRA_REG                  (CGRA_REG_AWLEN),
    .AWSIZE_master_CGRA_REG                 (CGRA_REG_AWSIZE),
    .AWBURST_master_CGRA_REG                (CGRA_REG_AWBURST),
    .AWLOCK_master_CGRA_REG                 (CGRA_REG_AWLOCK),
    .AWCACHE_master_CGRA_REG                (CGRA_REG_AWCACHE),
    .AWPROT_master_CGRA_REG                 (CGRA_REG_AWPROT),
    .AWVALID_master_CGRA_REG                (CGRA_REG_AWVALID),
    .AWREADY_master_CGRA_REG                (CGRA_REG_AWREADY),
    .WDATA_master_CGRA_REG                  (CGRA_REG_WDATA),
    .WSTRB_master_CGRA_REG                  (CGRA_REG_WSTRB),
    .WLAST_master_CGRA_REG                  (CGRA_REG_WLAST),
    .WVALID_master_CGRA_REG                 (CGRA_REG_WVALID),
    .WREADY_master_CGRA_REG                 (CGRA_REG_WREADY),
    .BID_master_CGRA_REG                    (CGRA_REG_BID),
    .BRESP_master_CGRA_REG                  (CGRA_REG_BRESP),
    .BVALID_master_CGRA_REG                 (CGRA_REG_BVALID),
    .BREADY_master_CGRA_REG                 (CGRA_REG_BREADY),
    .ARID_master_CGRA_REG                   (CGRA_REG_ARID),
    .ARADDR_master_CGRA_REG                 (CGRA_REG_ARADDR),
    .ARLEN_master_CGRA_REG                  (CGRA_REG_ARLEN),
    .ARSIZE_master_CGRA_REG                 (CGRA_REG_ARSIZE),
    .ARBURST_master_CGRA_REG                (CGRA_REG_ARBURST),
    .ARLOCK_master_CGRA_REG                 (CGRA_REG_ARLOCK),
    .ARCACHE_master_CGRA_REG                (CGRA_REG_ARCACHE),
    .ARPROT_master_CGRA_REG                 (CGRA_REG_ARPROT),
    .ARVALID_master_CGRA_REG                (CGRA_REG_ARVALID),
    .ARREADY_master_CGRA_REG                (CGRA_REG_ARREADY),
    .RID_master_CGRA_REG                    (CGRA_REG_RID),
    .RDATA_master_CGRA_REG                  (CGRA_REG_RDATA),
    .RRESP_master_CGRA_REG                  (CGRA_REG_RRESP),
    .RLAST_master_CGRA_REG                  (CGRA_REG_RLAST),
    .RVALID_master_CGRA_REG                 (CGRA_REG_RVALID),
    .RREADY_master_CGRA_REG                 (CGRA_REG_RREADY),

    // Peripheral Subsystem
    .HADDR_master_PERIPH                    (periph_haddr),
    .HBURST_master_PERIPH                   (periph_hburst),
    .HPROT_master_PERIPH                    (periph_hprot),
    .HSIZE_master_PERIPH                    (periph_hsize),
    .HTRANS_master_PERIPH                   (periph_htrans),
    .HWDATA_master_PERIPH                   (periph_hwdata),
    .HWRITE_master_PERIPH                   (periph_hwrite),
    .HRDATA_master_PERIPH                   (periph_hrdata),
    .HREADYOUT_master_PERIPH                (periph_hreadyout),
    .HRESP_master_PERIPH                    (periph_hresp[0]),
    .HSELx_master_PERIPH                    (periph_hsel),
    .HREADY_master_PERIPH                   (periph_hready),

    // SRAM0
    .AWID_master_SRAM0                      (sram0_awid),
    .AWADDR_master_SRAM0                    (sram0_awaddr),
    .AWLEN_master_SRAM0                     (sram0_awlen),
    .AWSIZE_master_SRAM0                    (sram0_awsize),
    .AWBURST_master_SRAM0                   (sram0_awburst),
    .AWLOCK_master_SRAM0                    (sram0_awlock),
    .AWCACHE_master_SRAM0                   (sram0_awcache),
    .AWPROT_master_SRAM0                    (sram0_awprot),
    .AWVALID_master_SRAM0                   (sram0_awvalid),
    .AWREADY_master_SRAM0                   (sram0_awready),
    .WDATA_master_SRAM0                     (sram0_wdata),
    .WSTRB_master_SRAM0                     (sram0_wstrb),
    .WLAST_master_SRAM0                     (sram0_wlast),
    .WVALID_master_SRAM0                    (sram0_wvalid),
    .WREADY_master_SRAM0                    (sram0_wready),
    .BID_master_SRAM0                       (sram0_bid),
    .BRESP_master_SRAM0                     (sram0_bresp),
    .BVALID_master_SRAM0                    (sram0_bvalid),
    .BREADY_master_SRAM0                    (sram0_bready),
    .ARID_master_SRAM0                      (sram0_arid),
    .ARADDR_master_SRAM0                    (sram0_araddr),
    .ARLEN_master_SRAM0                     (sram0_arlen),
    .ARSIZE_master_SRAM0                    (sram0_arsize),
    .ARBURST_master_SRAM0                   (sram0_arburst),
    .ARLOCK_master_SRAM0                    (sram0_arlock),
    .ARCACHE_master_SRAM0                   (sram0_arcache),
    .ARPROT_master_SRAM0                    (sram0_arprot),
    .ARVALID_master_SRAM0                   (sram0_arvalid),
    .ARREADY_master_SRAM0                   (sram0_arready),
    .RID_master_SRAM0                       (sram0_rid),
    .RDATA_master_SRAM0                     (sram0_rdata),
    .RRESP_master_SRAM0                     (sram0_rresp),
    .RLAST_master_SRAM0                     (sram0_rlast),
    .RVALID_master_SRAM0                    (sram0_rvalid),
    .RREADY_master_SRAM0                    (sram0_rready),

    // SRAM1
    .AWID_master_SRAM1                      (sram1_awid),
    .AWADDR_master_SRAM1                    (sram1_awaddr),
    .AWLEN_master_SRAM1                     (sram1_awlen),
    .AWSIZE_master_SRAM1                    (sram1_awsize),
    .AWBURST_master_SRAM1                   (sram1_awburst),
    .AWLOCK_master_SRAM1                    (sram1_awlock),
    .AWCACHE_master_SRAM1                   (sram1_awcache),
    .AWPROT_master_SRAM1                    (sram1_awprot),
    .AWVALID_master_SRAM1                   (sram1_awvalid),
    .AWREADY_master_SRAM1                   (sram1_awready),
    .WDATA_master_SRAM1                     (sram1_wdata),
    .WSTRB_master_SRAM1                     (sram1_wstrb),
    .WLAST_master_SRAM1                     (sram1_wlast),
    .WVALID_master_SRAM1                    (sram1_wvalid),
    .WREADY_master_SRAM1                    (sram1_wready),
    .BID_master_SRAM1                       (sram1_bid),
    .BRESP_master_SRAM1                     (sram1_bresp),
    .BVALID_master_SRAM1                    (sram1_bvalid),
    .BREADY_master_SRAM1                    (sram1_bready),
    .ARID_master_SRAM1                      (sram1_arid),
    .ARADDR_master_SRAM1                    (sram1_araddr),
    .ARLEN_master_SRAM1                     (sram1_arlen),
    .ARSIZE_master_SRAM1                    (sram1_arsize),
    .ARBURST_master_SRAM1                   (sram1_arburst),
    .ARLOCK_master_SRAM1                    (sram1_arlock),
    .ARCACHE_master_SRAM1                   (sram1_arcache),
    .ARPROT_master_SRAM1                    (sram1_arprot),
    .ARVALID_master_SRAM1                   (sram1_arvalid),
    .ARREADY_master_SRAM1                   (sram1_arready),
    .RID_master_SRAM1                       (sram1_rid),
    .RDATA_master_SRAM1                     (sram1_rdata),
    .RRESP_master_SRAM1                     (sram1_rresp),
    .RLAST_master_SRAM1                     (sram1_rlast),
    .RVALID_master_SRAM1                    (sram1_rvalid),
    .RREADY_master_SRAM1                    (sram1_rready),

    // SRAM2
    .AWID_master_SRAM2                      (sram2_awid),
    .AWADDR_master_SRAM2                    (sram2_awaddr),
    .AWLEN_master_SRAM2                     (sram2_awlen),
    .AWSIZE_master_SRAM2                    (sram2_awsize),
    .AWBURST_master_SRAM2                   (sram2_awburst),
    .AWLOCK_master_SRAM2                    (sram2_awlock),
    .AWCACHE_master_SRAM2                   (sram2_awcache),
    .AWPROT_master_SRAM2                    (sram2_awprot),
    .AWVALID_master_SRAM2                   (sram2_awvalid),
    .AWREADY_master_SRAM2                   (sram2_awready),
    .WDATA_master_SRAM2                     (sram2_wdata),
    .WSTRB_master_SRAM2                     (sram2_wstrb),
    .WLAST_master_SRAM2                     (sram2_wlast),
    .WVALID_master_SRAM2                    (sram2_wvalid),
    .WREADY_master_SRAM2                    (sram2_wready),
    .BID_master_SRAM2                       (sram2_bid),
    .BRESP_master_SRAM2                     (sram2_bresp),
    .BVALID_master_SRAM2                    (sram2_bvalid),
    .BREADY_master_SRAM2                    (sram2_bready),
    .ARID_master_SRAM2                      (sram2_arid),
    .ARADDR_master_SRAM2                    (sram2_araddr),
    .ARLEN_master_SRAM2                     (sram2_arlen),
    .ARSIZE_master_SRAM2                    (sram2_arsize),
    .ARBURST_master_SRAM2                   (sram2_arburst),
    .ARLOCK_master_SRAM2                    (sram2_arlock),
    .ARCACHE_master_SRAM2                   (sram2_arcache),
    .ARPROT_master_SRAM2                    (sram2_arprot),
    .ARVALID_master_SRAM2                   (sram2_arvalid),
    .ARREADY_master_SRAM2                   (sram2_arready),
    .RID_master_SRAM2                       (sram2_rid),
    .RDATA_master_SRAM2                     (sram2_rdata),
    .RRESP_master_SRAM2                     (sram2_rresp),
    .RLAST_master_SRAM2                     (sram2_rlast),
    .RVALID_master_SRAM2                    (sram2_rvalid),
    .RREADY_master_SRAM2                    (sram2_rready),

    // SRAM3
    .AWID_master_SRAM3                      (sram3_awid),
    .AWADDR_master_SRAM3                    (sram3_awaddr),
    .AWLEN_master_SRAM3                     (sram3_awlen),
    .AWSIZE_master_SRAM3                    (sram3_awsize),
    .AWBURST_master_SRAM3                   (sram3_awburst),
    .AWLOCK_master_SRAM3                    (sram3_awlock),
    .AWCACHE_master_SRAM3                   (sram3_awcache),
    .AWPROT_master_SRAM3                    (sram3_awprot),
    .AWVALID_master_SRAM3                   (sram3_awvalid),
    .AWREADY_master_SRAM3                   (sram3_awready),
    .WDATA_master_SRAM3                     (sram3_wdata),
    .WSTRB_master_SRAM3                     (sram3_wstrb),
    .WLAST_master_SRAM3                     (sram3_wlast),
    .WVALID_master_SRAM3                    (sram3_wvalid),
    .WREADY_master_SRAM3                    (sram3_wready),
    .BID_master_SRAM3                       (sram3_bid),
    .BRESP_master_SRAM3                     (sram3_bresp),
    .BVALID_master_SRAM3                    (sram3_bvalid),
    .BREADY_master_SRAM3                    (sram3_bready),
    .ARID_master_SRAM3                      (sram3_arid),
    .ARADDR_master_SRAM3                    (sram3_araddr),
    .ARLEN_master_SRAM3                     (sram3_arlen),
    .ARSIZE_master_SRAM3                    (sram3_arsize),
    .ARBURST_master_SRAM3                   (sram3_arburst),
    .ARLOCK_master_SRAM3                    (sram3_arlock),
    .ARCACHE_master_SRAM3                   (sram3_arcache),
    .ARPROT_master_SRAM3                    (sram3_arprot),
    .ARVALID_master_SRAM3                   (sram3_arvalid),
    .ARREADY_master_SRAM3                   (sram3_arready),
    .RID_master_SRAM3                       (sram3_rid),
    .RDATA_master_SRAM3                     (sram3_rdata),
    .RRESP_master_SRAM3                     (sram3_rresp),
    .RLAST_master_SRAM3                     (sram3_rlast),
    .RVALID_master_SRAM3                    (sram3_rvalid),
    .RREADY_master_SRAM3                    (sram3_rready),

    // CPU
    .HADDR_slave_CPU                        (cpu_haddr),
    .HBURST_slave_CPU                       (cpu_hburst),
    .HPROT_slave_CPU                        (cpu_hprot),
    .HSIZE_slave_CPU                        (cpu_hsize),
    .HTRANS_slave_CPU                       (cpu_htrans),
    .HWDATA_slave_CPU                       (cpu_hwdata),
    .HWRITE_slave_CPU                       (cpu_hwrite),
    .HRDATA_slave_CPU                       (cpu_hrdata),
    .HRESP_slave_CPU                        (cpu_hresp[0]),
    .HREADY_slave_CPU                       (cpu_hready),

    // DMA0
    .AWID_slave_DMA0                        (dma0_awid),
    .AWADDR_slave_DMA0                      (dma0_awaddr),
    .AWLEN_slave_DMA0                       (dma0_awlen),
    .AWSIZE_slave_DMA0                      (dma0_awsize),
    .AWBURST_slave_DMA0                     (dma0_awburst),
    .AWLOCK_slave_DMA0                      (dma0_awlock),
    .AWCACHE_slave_DMA0                     (dma0_awcache),
    .AWPROT_slave_DMA0                      (dma0_awprot),
    .AWVALID_slave_DMA0                     (dma0_awvalid),
    .AWREADY_slave_DMA0                     (dma0_awready),
    .WDATA_slave_DMA0                       (dma0_wdata),
    .WSTRB_slave_DMA0                       (dma0_wstrb),
    .WLAST_slave_DMA0                       (dma0_wlast),
    .WVALID_slave_DMA0                      (dma0_wvalid),
    .WREADY_slave_DMA0                      (dma0_wready),
    .BID_slave_DMA0                         (dma0_bid),
    .BRESP_slave_DMA0                       (dma0_bresp),
    .BVALID_slave_DMA0                      (dma0_bvalid),
    .BREADY_slave_DMA0                      (dma0_bready),
    .ARID_slave_DMA0                        (dma0_arid),
    .ARADDR_slave_DMA0                      (dma0_araddr),
    .ARLEN_slave_DMA0                       (dma0_arlen),
    .ARSIZE_slave_DMA0                      (dma0_arsize),
    .ARBURST_slave_DMA0                     (dma0_arburst),
    .ARLOCK_slave_DMA0                      (dma0_arlock),
    .ARCACHE_slave_DMA0                     (dma0_arcache),
    .ARPROT_slave_DMA0                      (dma0_arprot),
    .ARVALID_slave_DMA0                     (dma0_arvalid),
    .ARREADY_slave_DMA0                     (dma0_arready),
    .RID_slave_DMA0                         (dma0_rid),
    .RDATA_slave_DMA0                       (dma0_rdata),
    .RRESP_slave_DMA0                       (dma0_rresp),
    .RLAST_slave_DMA0                       (dma0_rlast),
    .RVALID_slave_DMA0                      (dma0_rvalid),
    .RREADY_slave_DMA0                      (dma0_rready),

    // DMA1
    .AWID_slave_DMA1                        (dma1_awid),
    .AWADDR_slave_DMA1                      (dma1_awaddr),
    .AWLEN_slave_DMA1                       (dma1_awlen),
    .AWSIZE_slave_DMA1                      (dma1_awsize),
    .AWBURST_slave_DMA1                     (dma1_awburst),
    .AWLOCK_slave_DMA1                      (dma1_awlock),
    .AWCACHE_slave_DMA1                     (dma1_awcache),
    .AWPROT_slave_DMA1                      (dma1_awprot),
    .AWVALID_slave_DMA1                     (dma1_awvalid),
    .AWREADY_slave_DMA1                     (dma1_awready),
    .WDATA_slave_DMA1                       (dma1_wdata),
    .WSTRB_slave_DMA1                       (dma1_wstrb),
    .WLAST_slave_DMA1                       (dma1_wlast),
    .WVALID_slave_DMA1                      (dma1_wvalid),
    .WREADY_slave_DMA1                      (dma1_wready),
    .BID_slave_DMA1                         (dma1_bid),
    .BRESP_slave_DMA1                       (dma1_bresp),
    .BVALID_slave_DMA1                      (dma1_bvalid),
    .BREADY_slave_DMA1                      (dma1_bready),
    .ARID_slave_DMA1                        (dma1_arid),
    .ARADDR_slave_DMA1                      (dma1_araddr),
    .ARLEN_slave_DMA1                       (dma1_arlen),
    .ARSIZE_slave_DMA1                      (dma1_arsize),
    .ARBURST_slave_DMA1                     (dma1_arburst),
    .ARLOCK_slave_DMA1                      (dma1_arlock),
    .ARCACHE_slave_DMA1                     (dma1_arcache),
    .ARPROT_slave_DMA1                      (dma1_arprot),
    .ARVALID_slave_DMA1                     (dma1_arvalid),
    .ARREADY_slave_DMA1                     (dma1_arready),
    .RID_slave_DMA1                         (dma1_rid),
    .RDATA_slave_DMA1                       (dma1_rdata),
    .RRESP_slave_DMA1                       (dma1_rresp),
    .RLAST_slave_DMA1                       (dma1_rlast),
    .RVALID_slave_DMA1                      (dma1_rvalid),
    .RREADY_slave_DMA1                      (dma1_rready),

    // Instance: u_cd_tlx, Port: master_TLX

    .AWID_master_TLX                        (TLX_AWID),
    .AWADDR_master_TLX                      (TLX_AWADDR),
    .AWLEN_master_TLX                       (TLX_AWLEN),
    .AWSIZE_master_TLX                      (TLX_AWSIZE),
    .AWBURST_master_TLX                     (TLX_AWBURST),
    .AWLOCK_master_TLX                      (TLX_AWLOCK),
    .AWCACHE_master_TLX                     (TLX_AWCACHE),
    .AWPROT_master_TLX                      (TLX_AWPROT),
    .AWVALID_master_TLX                     (TLX_AWVALID),
    .AWREADY_master_TLX                     (TLX_AWREADY),
    .WDATA_master_TLX                       (TLX_WDATA),
    .WSTRB_master_TLX                       (TLX_WSTRB),
    .WLAST_master_TLX                       (TLX_WLAST),
    .WVALID_master_TLX                      (TLX_WVALID),
    .WREADY_master_TLX                      (TLX_WREADY),
    .BID_master_TLX                         (TLX_BID),
    .BRESP_master_TLX                       (TLX_BRESP),
    .BVALID_master_TLX                      (TLX_BVALID),
    .BREADY_master_TLX                      (TLX_BREADY),
    .ARID_master_TLX                        (TLX_ARID),
    .ARADDR_master_TLX                      (TLX_ARADDR),
    .ARLEN_master_TLX                       (TLX_ARLEN),
    .ARSIZE_master_TLX                      (TLX_ARSIZE),
    .ARBURST_master_TLX                     (TLX_ARBURST),
    .ARLOCK_master_TLX                      (TLX_ARLOCK),
    .ARCACHE_master_TLX                     (TLX_ARCACHE),
    .ARPROT_master_TLX                      (TLX_ARPROT),
    .ARVALID_master_TLX                     (TLX_ARVALID),
    .ARREADY_master_TLX                     (TLX_ARREADY),
    .RID_master_TLX                         (TLX_RID),
    .RDATA_master_TLX                       (TLX_RDATA),
    .RRESP_master_TLX                       (TLX_RRESP),
    .RLAST_master_TLX                       (TLX_RLAST),
    .RVALID_master_TLX                      (TLX_RVALID),
    .RREADY_master_TLX                      (TLX_RREADY),

    // Instance: u_cd_tlx, Port: master_TLX_REG
    .HADDR_master_TLX_REG                   (TLX_HADDR),
    .HBURST_master_TLX_REG                  (TLX_HBURST),
    .HPROT_master_TLX_REG                   (TLX_HPROT),
    .HSIZE_master_TLX_REG                   (TLX_HSIZE),
    .HTRANS_master_TLX_REG                  (TLX_HTRANS),
    .HWDATA_master_TLX_REG                  (TLX_HWDATA),
    .HWRITE_master_TLX_REG                  (TLX_HWRITE),
    .HRDATA_master_TLX_REG                  (TLX_HRDATA),
    .HREADYOUT_master_TLX_REG               (TLX_HREADYOUT),
    .HRESP_master_TLX_REG                   (TLX_HRESP),
    .HSELx_master_TLX_REG                   (TLX_HSELx),
    .HREADY_master_TLX_REG                  (TLX_HREADY),

    //  Non-bus signals

    .cgraclk                                (CGRA_CLK),
    .cgraresetn                             (CGRA_RESETn),
    .systemclk                              (NIC_CLK),
    .systemresetn                           (NIC_RESETn),
    .tlxclk                                 (TLX_CLK),
    .tlxresetn                              (TLX_RESETn)
  );

  // Instantiate CPU Integration
  AhaCM3CodeRegionIntegration u_cpu_integration (
    // Resets
    .CPU_PORESETn                           (CPU_PORESETn),
    .CPU_SYSRESETn                          (CPU_SYSRESETn),
    .DAP_RESETn                             (DAP_RESETn),
    .JTAG_TRSTn                             (JTAG_TRSTn),
    .JTAG_PORESETn                          (JTAG_PORESETn),

    // Clocks
    .SYS_CLK                                (SYS_CLK),
    .CPU_CLK                                (CPU_CLK),
    .DAP_CLK                                (DAP_CLK),
    .JTAG_TCK                               (JTAG_TCK),

    // Clock-Related Signals
    .CPU_CLK_CHANGED                        (CPU_CLK_CHANGED),

    // JTAG/DAP Interface
    .JTAG_TDI                               (JTAG_TDI),
    .JTAG_TMS                               (JTAG_TMS),
    .JTAG_TDO                               (JTAG_TDO),

    // TPIU
    .TPIU_TRACE_DATA                        (TPIU_TRACE_DATA),
    .TPIU_TRACE_SWO                         (TPIU_TRACE_SWO),
    .TPIU_TRACE_CLK                         (TPIU_TRACE_CLK),

    // Reset and PWR Control
    .DBGPWRUPACK                            (DBGPWRUPACK),
    .DBGRSTACK                              (DBGRSTACK),
    .DBGSYSPWRUPACK                         (DBGSYSPWRUPACK),
    .SLEEPHOLDREQn                          (SLEEPHOLDREQn),
    .PMU_WIC_EN_REQ                         (PMU_WIC_EN_REQ),
    .PMU_WIC_EN_ACK                         (PMU_WIC_EN_ACK),
    .PMU_WAKEUP                             (PMU_WAKEUP),
    .INT_REQ                                (INT_REQ),
    .DBGPWRUPREQ                            (DBGPWRUPREQ),
    .DBGRSTREQ                              (DBGRSTREQ),
    .DBGSYSPWRUPREQ                         (DBGSYSPWRUPREQ),
    .SLEEP                                  (SLEEP),
    .SLEEPDEEP                              (SLEEPDEEP),
    .LOCKUP                                 (LOCKUP),
    .SYSRESETREQ                            (SYSRESETREQ),
    .SLEEPHOLDACKn                          (SLEEPHOLDACKn),

    // System Bus
    .SYS_HREADY                             (cpu_hready),
    .SYS_HRDATA                             (cpu_hrdata),
    .SYS_HRESP                              (cpu_hresp),
    .SYS_HADDR                              (cpu_haddr),
    .SYS_HTRANS                             (cpu_htrans),
    .SYS_HSIZE                              (cpu_hsize),
    .SYS_HWRITE                             (cpu_hwrite),
    .SYS_HBURST                             (cpu_hburst),
    .SYS_HPROT                              (cpu_hprot),
    .SYS_HWDATA                             (cpu_hwdata),

    // Interrupts
    .TIMER0_INT                             (timer0_int),
    .TIMER1_INT                             (timer1_int),
    .UART0_TX_RX_INT                        (uart0_rxint | uart0_txint),
    .UART1_TX_RX_INT                        (uart1_rxint | uart1_txint),
    .UART0_TX_RX_O_INT                      (uart0_rxovrint | uart0_txovrint),
    .UART1_TX_RX_O_INT                      (uart1_rxovrint | uart1_txovrint),
    .DMA0_INT                               (dma0_int),
    .DMA1_INT                               (dma1_int),
    .CGRA_INT                               (CGRA_INT),
    .WDOG_INT                               (wdog_int),
    .TLX_INT                                (TLX_INT),

    // SysTick
    .SYS_TICK_NOT_10MS_MULT                 (SYS_TICK_NOT_10MS_MULT),
    .SYS_TICK_CALIB                         (SYS_TICK_CALIB)
  );

  assign cpu_hresp[1]     = 1'b0;

  // Instantiate DMA0
  AhaDmaIntegration u_dma_0 (
    // Data Interface
    .ACLK                                   (DMA0_CLK),
    .ARESETn                                (DMA0_RESETn),

    .AWID                                   (dma0_awid),
    .AWADDR                                 (dma0_awaddr),
    .AWLEN                                  (dma0_awlen),
    .AWSIZE                                 (dma0_awsize),
    .AWBURST                                (dma0_awburst),
    .AWLOCK                                 (dma0_awlock),
    .AWCACHE                                (dma0_awcache),
    .AWPROT                                 (dma0_awprot),
    .AWVALID                                (dma0_awvalid),
    .AWREADY                                (dma0_awready),
    .WDATA                                  (dma0_wdata),
    .WSTRB                                  (dma0_wstrb),
    .WLAST                                  (dma0_wlast),
    .WVALID                                 (dma0_wvalid),
    .WREADY                                 (dma0_wready),
    .BID                                    (dma0_bid),
    .BRESP                                  (dma0_bresp),
    .BVALID                                 (dma0_bvalid),
    .BREADY                                 (dma0_bready),
    .ARID                                   (dma0_arid),
    .ARADDR                                 (dma0_araddr),
    .ARLEN                                  (dma0_arlen),
    .ARSIZE                                 (dma0_arsize),
    .ARBURST                                (dma0_arburst),
    .ARLOCK                                 (dma0_arlock),
    .ARCACHE                                (dma0_arcache),
    .ARPROT                                 (dma0_arprot),
    .ARVALID                                (dma0_arvalid),
    .ARREADY                                (dma0_arready),
    .RID                                    (dma0_rid),
    .RDATA                                  (dma0_rdata),
    .RRESP                                  (dma0_rresp),
    .RLAST                                  (dma0_rlast),
    .RVALID                                 (dma0_rvalid),
    .RREADY                                 (dma0_rready),

    // Control Interface
    .PCLKEN                                 (DMA0_CLKEN),

    .PRDATA                                 (dma0_prdata),
    .PADDR                                  (dma0_paddr),
    .PSEL                                   (dma0_psel),
    .PENABLE                                (dma0_penable),
    .PWRITE                                 (dma0_pwrite),
    .PWDATA                                 (dma0_pwdata),
    .PREADY                                 (dma0_pready),
    .PSLVERR                                (dma0_pslverr),

    .IRQ                                    (dma0_int),
    .IRQ_ABORT                              (/*unused*/)
  );

  // Instantiate DMA1
  AhaDmaIntegration u_dma_1 (
    // Data Interface
    .ACLK                                   (DMA1_CLK),
    .ARESETn                                (DMA1_RESETn),

    .AWID                                   (dma1_awid),
    .AWADDR                                 (dma1_awaddr),
    .AWLEN                                  (dma1_awlen),
    .AWSIZE                                 (dma1_awsize),
    .AWBURST                                (dma1_awburst),
    .AWLOCK                                 (dma1_awlock),
    .AWCACHE                                (dma1_awcache),
    .AWPROT                                 (dma1_awprot),
    .AWVALID                                (dma1_awvalid),
    .AWREADY                                (dma1_awready),
    .WDATA                                  (dma1_wdata),
    .WSTRB                                  (dma1_wstrb),
    .WLAST                                  (dma1_wlast),
    .WVALID                                 (dma1_wvalid),
    .WREADY                                 (dma1_wready),
    .BID                                    (dma1_bid),
    .BRESP                                  (dma1_bresp),
    .BVALID                                 (dma1_bvalid),
    .BREADY                                 (dma1_bready),
    .ARID                                   (dma1_arid),
    .ARADDR                                 (dma1_araddr),
    .ARLEN                                  (dma1_arlen),
    .ARSIZE                                 (dma1_arsize),
    .ARBURST                                (dma1_arburst),
    .ARLOCK                                 (dma1_arlock),
    .ARCACHE                                (dma1_arcache),
    .ARPROT                                 (dma1_arprot),
    .ARVALID                                (dma1_arvalid),
    .ARREADY                                (dma1_arready),
    .RID                                    (dma1_rid),
    .RDATA                                  (dma1_rdata),
    .RRESP                                  (dma1_rresp),
    .RLAST                                  (dma1_rlast),
    .RVALID                                 (dma1_rvalid),
    .RREADY                                 (dma1_rready),

    // Control Interface
    .PCLKEN                                 (DMA1_CLKEN),

    .PRDATA                                 (dma1_prdata),
    .PADDR                                  (dma1_paddr),
    .PSEL                                   (dma1_psel),
    .PENABLE                                (dma1_penable),
    .PWRITE                                 (dma1_pwrite),
    .PWDATA                                 (dma1_pwdata),
    .PREADY                                 (dma1_pready),
    .PSLVERR                                (dma1_pslverr),

    .IRQ                                    (dma1_int),
    .IRQ_ABORT                              (/*unused*/)
  );

  // Instantiate SRAM0
  AhaAxiRam32K u_sram_0 (
    .ACLK                                   (SRAM_CLK),
    .ARESETn                                (SRAM_RESETn),

    .AWID                                   (sram0_awid),
    .AWADDR                                 (sram0_awaddr),
    .AWLEN                                  (sram0_awlen),
    .AWSIZE                                 (sram0_awsize),
    .AWBURST                                (sram0_awburst),
    .AWLOCK                                 (sram0_awlock),
    .AWCACHE                                (sram0_awcache),
    .AWPROT                                 (sram0_awprot),
    .AWVALID                                (sram0_awvalid),
    .AWREADY                                (sram0_awready),
    .WDATA                                  (sram0_wdata),
    .WSTRB                                  (sram0_wstrb),
    .WLAST                                  (sram0_wlast),
    .WVALID                                 (sram0_wvalid),
    .WREADY                                 (sram0_wready),
    .BID                                    (sram0_bid),
    .BRESP                                  (sram0_bresp),
    .BVALID                                 (sram0_bvalid),
    .BREADY                                 (sram0_bready),
    .ARID                                   (sram0_arid),
    .ARADDR                                 (sram0_araddr),
    .ARLEN                                  (sram0_arlen),
    .ARSIZE                                 (sram0_arsize),
    .ARBURST                                (sram0_arburst),
    .ARLOCK                                 (sram0_arlock),
    .ARCACHE                                (sram0_arcache),
    .ARPROT                                 (sram0_arprot),
    .ARVALID                                (sram0_arvalid),
    .ARREADY                                (sram0_arready),
    .RID                                    (sram0_rid),
    .RDATA                                  (sram0_rdata),
    .RRESP                                  (sram0_rresp),
    .RLAST                                  (sram0_rlast),
    .RVALID                                 (sram0_rvalid),
    .RREADY                                 (sram0_rready)
  );

  // Instantiate SRAM1
  AhaAxiRam32K u_sram_1 (
    .ACLK                                   (SRAM_CLK),
    .ARESETn                                (SRAM_RESETn),

    .AWID                                   (sram1_awid),
    .AWADDR                                 (sram1_awaddr),
    .AWLEN                                  (sram1_awlen),
    .AWSIZE                                 (sram1_awsize),
    .AWBURST                                (sram1_awburst),
    .AWLOCK                                 (sram1_awlock),
    .AWCACHE                                (sram1_awcache),
    .AWPROT                                 (sram1_awprot),
    .AWVALID                                (sram1_awvalid),
    .AWREADY                                (sram1_awready),
    .WDATA                                  (sram1_wdata),
    .WSTRB                                  (sram1_wstrb),
    .WLAST                                  (sram1_wlast),
    .WVALID                                 (sram1_wvalid),
    .WREADY                                 (sram1_wready),
    .BID                                    (sram1_bid),
    .BRESP                                  (sram1_bresp),
    .BVALID                                 (sram1_bvalid),
    .BREADY                                 (sram1_bready),
    .ARID                                   (sram1_arid),
    .ARADDR                                 (sram1_araddr),
    .ARLEN                                  (sram1_arlen),
    .ARSIZE                                 (sram1_arsize),
    .ARBURST                                (sram1_arburst),
    .ARLOCK                                 (sram1_arlock),
    .ARCACHE                                (sram1_arcache),
    .ARPROT                                 (sram1_arprot),
    .ARVALID                                (sram1_arvalid),
    .ARREADY                                (sram1_arready),
    .RID                                    (sram1_rid),
    .RDATA                                  (sram1_rdata),
    .RRESP                                  (sram1_rresp),
    .RLAST                                  (sram1_rlast),
    .RVALID                                 (sram1_rvalid),
    .RREADY                                 (sram1_rready)
  );

  // Instantiate SRAM2
  AhaAxiRam32K u_sram_2 (
    .ACLK                                   (SRAM_CLK),
    .ARESETn                                (SRAM_RESETn),

    .AWID                                   (sram2_awid),
    .AWADDR                                 (sram2_awaddr),
    .AWLEN                                  (sram2_awlen),
    .AWSIZE                                 (sram2_awsize),
    .AWBURST                                (sram2_awburst),
    .AWLOCK                                 (sram2_awlock),
    .AWCACHE                                (sram2_awcache),
    .AWPROT                                 (sram2_awprot),
    .AWVALID                                (sram2_awvalid),
    .AWREADY                                (sram2_awready),
    .WDATA                                  (sram2_wdata),
    .WSTRB                                  (sram2_wstrb),
    .WLAST                                  (sram2_wlast),
    .WVALID                                 (sram2_wvalid),
    .WREADY                                 (sram2_wready),
    .BID                                    (sram2_bid),
    .BRESP                                  (sram2_bresp),
    .BVALID                                 (sram2_bvalid),
    .BREADY                                 (sram2_bready),
    .ARID                                   (sram2_arid),
    .ARADDR                                 (sram2_araddr),
    .ARLEN                                  (sram2_arlen),
    .ARSIZE                                 (sram2_arsize),
    .ARBURST                                (sram2_arburst),
    .ARLOCK                                 (sram2_arlock),
    .ARCACHE                                (sram2_arcache),
    .ARPROT                                 (sram2_arprot),
    .ARVALID                                (sram2_arvalid),
    .ARREADY                                (sram2_arready),
    .RID                                    (sram2_rid),
    .RDATA                                  (sram2_rdata),
    .RRESP                                  (sram2_rresp),
    .RLAST                                  (sram2_rlast),
    .RVALID                                 (sram2_rvalid),
    .RREADY                                 (sram2_rready)
  );

  // Instantiate SRAM3
  AhaAxiRam32K u_sram_3 (
    .ACLK                                   (SRAM_CLK),
    .ARESETn                                (SRAM_RESETn),

    .AWID                                   (sram3_awid),
    .AWADDR                                 (sram3_awaddr),
    .AWLEN                                  (sram3_awlen),
    .AWSIZE                                 (sram3_awsize),
    .AWBURST                                (sram3_awburst),
    .AWLOCK                                 (sram3_awlock),
    .AWCACHE                                (sram3_awcache),
    .AWPROT                                 (sram3_awprot),
    .AWVALID                                (sram3_awvalid),
    .AWREADY                                (sram3_awready),
    .WDATA                                  (sram3_wdata),
    .WSTRB                                  (sram3_wstrb),
    .WLAST                                  (sram3_wlast),
    .WVALID                                 (sram3_wvalid),
    .WREADY                                 (sram3_wready),
    .BID                                    (sram3_bid),
    .BRESP                                  (sram3_bresp),
    .BVALID                                 (sram3_bvalid),
    .BREADY                                 (sram3_bready),
    .ARID                                   (sram3_arid),
    .ARADDR                                 (sram3_araddr),
    .ARLEN                                  (sram3_arlen),
    .ARSIZE                                 (sram3_arsize),
    .ARBURST                                (sram3_arburst),
    .ARLOCK                                 (sram3_arlock),
    .ARCACHE                                (sram3_arcache),
    .ARPROT                                 (sram3_arprot),
    .ARVALID                                (sram3_arvalid),
    .ARREADY                                (sram3_arready),
    .RID                                    (sram3_rid),
    .RDATA                                  (sram3_rdata),
    .RRESP                                  (sram3_rresp),
    .RLAST                                  (sram3_rlast),
    .RVALID                                 (sram3_rvalid),
    .RREADY                                 (sram3_rready)
  );

  // Instantiate Peripheral Subsystem
  AhaPeripherals u_aha_peripherals (
    // Bus Interface
    .HCLK                                   (NIC_CLK),
    .HRESETn                                (PERIPH_RESETn),

    .HSEL                                   (periph_hsel),
    .HADDR                                  ({{16{1'b0}}, periph_haddr[15:0]}),
    .HTRANS                                 (periph_htrans),
    .HWRITE                                 (periph_hwrite),
    .HSIZE                                  (periph_hsize),
    .HBURST                                 (periph_hburst),
    .HPROT                                  (periph_hprot),
    .HWDATA                                 (periph_hwdata),
    .HREADYMUX                              (periph_hready),

    .HRDATA                                 (periph_hrdata),
    .HREADYOUT                              (periph_hreadyout),
    .HRESP                                  (periph_hresp),

    // TIMER 0
    .TIMER0_PCLK                            (TIMER0_CLK),
    .TIMER0_PCLKEN                          (TIMER0_CLKEN),
    .TIMER0_PRESETn                         (TIMER0_RESETn),
    .TIMER0_INT                             (timer0_int),

    // TIMER 1
    .TIMER1_PCLK                            (TIMER1_CLK),
    .TIMER1_PCLKEN                          (TIMER1_CLKEN),
    .TIMER1_PRESETn                         (TIMER1_RESETn),
    .TIMER1_INT                             (timer1_int),

    // UART 0
    .UART0_PCLK                             (UART0_CLK),
    .UART0_PCLKEN                           (UART0_CLKEN),
    .UART0_PRESETn                          (UART0_RESETn),
    .UART0_RXD                              (UART0_RXD),
    .UART0_TXD                              (UART0_TXD),
    .UART0_TXINT                            (uart0_txint),
    .UART0_RXINT                            (uart0_rxint),
    .UART0_TXOVRINT                         (uart0_txovrint),
    .UART0_RXOVRINT                         (uart0_rxovrint),
    .UART0_UARTINT                          (uart0_uartint),

    // UART 1
    .UART1_PCLK                             (UART1_CLK),
    .UART1_PCLKEN                           (UART1_CLKEN),
    .UART1_PRESETn                          (UART1_RESETn),
    .UART1_RXD                              (UART1_RXD),
    .UART1_TXD                              (UART1_TXD),
    .UART1_TXINT                            (uart1_txint),
    .UART1_RXINT                            (uart1_rxint),
    .UART1_TXOVRINT                         (uart1_txovrint),
    .UART1_RXOVRINT                         (uart1_rxovrint),
    .UART1_UARTINT                          (uart1_uartint),

    // Watchdog
    .WDOG_PCLK                              (WDOG_CLK),
    .WDOG_PCLKEN                            (WDOG_CLKEN),
    .WDOG_PRESETn                           (WDOG_RESETn),
    .WDOG_INT                               (wdog_int),
    .WDOG_RESET                             (WDOG_RESET_REQ),

    // DMA 0
    .DMA0_PCLKEN                            (DMA0_CLKEN),

    .DMA0_PADDR                             (dma0_paddr),
    .DMA0_PENABLE                           (dma0_penable),
    .DMA0_PWRITE                            (dma0_pwrite),
    .DMA0_PSEL                              (dma0_psel),
    .DMA0_PWDATA                            (dma0_pwdata),

    .DMA0_PRDATA                            (dma0_prdata),
    .DMA0_PREADY                            (dma0_pready),
    .DMA0_PSLVERR                           (dma0_pslverr),

    // DMA 1
    .DMA1_PCLKEN                            (DMA1_CLKEN),

    .DMA1_PADDR                             (dma1_paddr),
    .DMA1_PENABLE                           (dma1_penable),
    .DMA1_PWRITE                            (dma1_pwrite),
    .DMA1_PSEL                              (dma1_psel),
    .DMA1_PWDATA                            (dma1_pwdata),

    .DMA1_PRDATA                            (dma1_prdata),
    .DMA1_PREADY                            (dma1_pready),
    .DMA1_PSLVERR                           (dma1_pslverr),

    // Platform Controller
    .PCTRL_HSEL                             (PCTRL_HSEL),
    .PCTRL_HADDR                            (PCTRL_HADDR),
    .PCTRL_HTRANS                           (PCTRL_HTRANS),
    .PCTRL_HWRITE                           (PCTRL_HWRITE),
    .PCTRL_HSIZE                            (PCTRL_HSIZE),
    .PCTRL_HBURST                           (PCTRL_HBURST),
    .PCTRL_HPROT                            (PCTRL_HPROT),
    .PCTRL_HMASTER                          (PCTRL_HMASTER),
    .PCTRL_HWDATA                           (PCTRL_HWDATA),
    .PCTRL_HMASTLOCK                        (PCTRL_HMASTLOCK),
    .PCTRL_HREADYMUX                        (PCTRL_HREADYMUX),
    .PCTRL_HRDATA                           (PCTRL_HRDATA),
    .PCTRL_HREADYOUT                        (PCTRL_HREADYOUT),
    .PCTRL_HRESP                            (PCTRL_HRESP)
  );

endmodule
