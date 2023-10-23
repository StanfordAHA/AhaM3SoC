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
// Updates  :
//  - Aug 25, 2022  :
//      - Added external TPIU clock
//      - Added TPIU_TRACECLKIN-synchronized reset
//
//  - Aug 29, 2022  :
//      - Integrated XGCD
//------------------------------------------------------------------------------

module AhaSoCPartialIntegration (
    // Resets
    input       wire            CPU_PORESETn,       // CPU Power on reset synchronized to CPU_CLK
    input       wire            CPU_SYSRESETn,      // CPU soft reset synchronized to CPU_CLK
    input       wire            DAP_RESETn,         // Debug system reset synchronized to DAP_CLK
    input       wire            JTAG_TRSTn,         // JTAG Reset synchronized to JTAG Test Clock
    input       wire            JTAG_PORESETn,      // JTAG Power on reset synchronized to JTAG_TCK
    input       wire            SRAM_RESETn,        // SRAM0 Reset
    input       wire            TLX_RESETn,         // TLX Reset (Slave IF Block)
    input       wire            CGRA_RESETn,        // CGRA Reset
    input       wire            DMA0_RESETn,        // DMA0 Reset
    input       wire            DMA1_RESETn,        // DMA1 Reset
    input       wire            PERIPH_RESETn,      // Peripheral Bus Reset
    input       wire            TIMER0_RESETn,      // Timer0 Reset
    input       wire            TIMER1_RESETn,      // Timer1 Reset
    input       wire            UART0_RESETn,       // UART0 Reset
    input       wire            UART1_RESETn,       // UART1 Reset
    input       wire            WDOG_RESETn,        // Watchdog Reset
    input       wire            NIC_RESETn,         // Interconnect Reset
    input       wire            TPIU_RESETn,        // TPIU Reset
    // input       wire            XGCD_RESETn,        // XGCD Bus Interface Reset

    // Clocks
    input       wire            SYS_CLK,            // system free running clock
    input       wire            CPU_CLK,            // CPU-domain gated clock
    input       wire            DAP_CLK,            // DAP clock
    input       wire            JTAG_TCK,           // JTAG test clock
    input       wire            SRAM_CLK,           // SRAM Clock
    input       wire            TLX_CLK,            // TLX Clock (Slave IF Block)
    input       wire            CGRA_CLK,           // CGRA Clock
    input       wire            DMA0_CLK,           // DMA0 Clock
    input       wire            DMA1_CLK,           // DMA1 Clock
    input       wire            TIMER0_CLK,         // Timer0 Clock
    input       wire            TIMER1_CLK,         // Timer1 Clock
    input       wire            UART0_CLK,          // UART0 Clock
    input       wire            UART1_CLK,          // UART1 Clock
    input       wire            WDOG_CLK,           // Watchdog Clock
    input       wire            NIC_CLK,            // Interconnect Clock
    input       wire            TPIU_TRACECLKIN,    // TPIU Interface Clock
    // input       wire            XGCD_BUS_CLK,       // XGCD Bus Interface Clock

    // Clock-related Signals
    input       wire            CPU_CLK_CHANGED,    // Indicates whether CPU clok frequency has changed
    input       wire            TIMER0_CLKEN,       // Qualifier for PERIPH Clock
    input       wire            TIMER1_CLKEN,       // Qualifier for PERIPH Clock
    input       wire            UART0_CLKEN,        // Qualifier for PERIPH Clock
    input       wire            UART1_CLKEN,        // Qualifier for PERIPH Clock
    input       wire            WDOG_CLKEN,         // Qualifier for PERIPH Clock
    input       wire            DMA0_CLKEN,         // Qualifier for DMA0 and PERIPH Clocks
    input       wire            DMA1_CLKEN,         // Qualifier for DMA1 and PERIPH Clocks

    // JTAG/DAP Interface
    input       wire            JTAG_TDI,           // JTAG Data In Port
    input       wire            JTAG_TMS,           // JTAG TMS Port
    output      wire            JTAG_TDO,           // JTAG TDO Port

    // TPIU
    output      wire  [3:0]     TPIU_TRACE_DATA,    // Trace Data
    output      wire            TPIU_TRACE_SWO,     // Trace Single Wire Output
    output      wire            TPIU_TRACE_CLK,     // Trace Output Clock

    // UART
    input       wire            UART0_RXD,          // UART0 Rx Data
    output      wire            UART0_TXD,          // UART0 Tx Data
    input       wire            UART1_RXD,          // UART1 Rx Data
    output      wire            UART1_TXD,          // UART1 Tx Data

    // Reset and Power Control
    input       wire            DBGPWRUPACK,        // Acknowledgement for Debug PowerUp Request
    input       wire            DBGRSTACK,          // Acknowledgement for Debug Reset Request
    input       wire            DBGSYSPWRUPACK,     // Acknowledgement for CPU PowerUp Request
    input       wire            SLEEPHOLDREQn,      // Request to extend Sleep
    input       wire            PMU_WIC_EN_REQ,     // PMU Request to Enable WIC
    output      wire            PMU_WIC_EN_ACK,     // WIC Response to PMU Enable Request
    output      wire            PMU_WAKEUP,         // WIC Requests PMU to Wake Up Processor
    output      wire            INT_REQ,            // An interrupt request is pending
    output      wire            DBGPWRUPREQ,        // Debug Power Up Request
    output      wire            DBGRSTREQ,          // Debug Reset Request
    output      wire            DBGSYSPWRUPREQ,     // Debug Request to Power Up CPU
    output      wire            SLEEP,              // Indicates CPU is in sleep mode (dbg activity might still be on)
    output      wire            SLEEPDEEP,          // Indicates CPU is in deep sleep mode (dbg activity might still be on)
    output      wire            LOCKUP,             // Indicates CPU is locked up
    output      wire            SYSRESETREQ,        // Request CPU Reset
    output      wire            SLEEPHOLDACKn,      // Response to sleep extension request
    output      wire            WDOG_RESET_REQ,     // Wdog reset

    // SysTick
    input       wire            SYS_TICK_NOT_10MS_MULT, // Does the sys-tick calibration value
                                                        // provide exact multiple of 10ms from CPU_CLK?
    input       wire [23:0]     SYS_TICK_CALIB,         // SysTick calibration value

    // CGRA
    input       wire            CGRA_INT,               // CGRA Interrupt

    output      wire [3 :0]     CGRA_DATA_AWID,
    output      wire [31:0]     CGRA_DATA_AWADDR,
    output      wire [7 :0]     CGRA_DATA_AWLEN,
    output      wire [2 :0]     CGRA_DATA_AWSIZE,
    output      wire [1 :0]     CGRA_DATA_AWBURST,
    output      wire            CGRA_DATA_AWLOCK,
    output      wire [3 :0]     CGRA_DATA_AWCACHE,
    output      wire [2 :0]     CGRA_DATA_AWPROT,
    output      wire            CGRA_DATA_AWVALID,
    input       wire            CGRA_DATA_AWREADY,
    output      wire [63:0]     CGRA_DATA_WDATA,
    output      wire [7 :0]     CGRA_DATA_WSTRB,
    output      wire            CGRA_DATA_WLAST,
    output      wire            CGRA_DATA_WVALID,
    input       wire            CGRA_DATA_WREADY,
    input       wire [3 :0]     CGRA_DATA_BID,
    input       wire [1 :0]     CGRA_DATA_BRESP,
    input       wire            CGRA_DATA_BVALID,
    output      wire            CGRA_DATA_BREADY,
    output      wire [3 :0]     CGRA_DATA_ARID,
    output      wire [31:0]     CGRA_DATA_ARADDR,
    output      wire [7 :0]     CGRA_DATA_ARLEN,
    output      wire [2 :0]     CGRA_DATA_ARSIZE,
    output      wire [1 :0]     CGRA_DATA_ARBURST,
    output      wire            CGRA_DATA_ARLOCK,
    output      wire [3 :0]     CGRA_DATA_ARCACHE,
    output      wire [2 :0]     CGRA_DATA_ARPROT,
    output      wire            CGRA_DATA_ARVALID,
    input       wire            CGRA_DATA_ARREADY,
    input       wire [3 :0]     CGRA_DATA_RID,
    input       wire [63:0]     CGRA_DATA_RDATA,
    input       wire [1 :0]     CGRA_DATA_RRESP,
    input       wire            CGRA_DATA_RLAST,
    input       wire            CGRA_DATA_RVALID,
    output      wire            CGRA_DATA_RREADY,

    output      wire [3:0]      CGRA_REG_AWID,
    output      wire [31:0]     CGRA_REG_AWADDR,
    output      wire [7:0]      CGRA_REG_AWLEN,
    output      wire [2:0]      CGRA_REG_AWSIZE,
    output      wire [1:0]      CGRA_REG_AWBURST,
    output      wire            CGRA_REG_AWLOCK,
    output      wire [3:0]      CGRA_REG_AWCACHE,
    output      wire [2:0]      CGRA_REG_AWPROT,
    output      wire            CGRA_REG_AWVALID,
    input       wire            CGRA_REG_AWREADY,
    output      wire [31:0]     CGRA_REG_WDATA,
    output      wire [3:0]      CGRA_REG_WSTRB,
    output      wire            CGRA_REG_WLAST,
    output      wire            CGRA_REG_WVALID,
    input       wire            CGRA_REG_WREADY,
    input       wire [3:0]      CGRA_REG_BID,
    input       wire [1:0]      CGRA_REG_BRESP,
    input       wire            CGRA_REG_BVALID,
    output      wire            CGRA_REG_BREADY,
    output      wire [3:0]      CGRA_REG_ARID,
    output      wire [31:0]     CGRA_REG_ARADDR,
    output      wire [7:0]      CGRA_REG_ARLEN,
    output      wire [2:0]      CGRA_REG_ARSIZE,
    output      wire [1:0]      CGRA_REG_ARBURST,
    output      wire            CGRA_REG_ARLOCK,
    output      wire [3:0]      CGRA_REG_ARCACHE,
    output      wire [2:0]      CGRA_REG_ARPROT,
    output      wire            CGRA_REG_ARVALID,
    input       wire            CGRA_REG_ARREADY,
    input       wire [3:0]      CGRA_REG_RID,
    input       wire [31:0]     CGRA_REG_RDATA,
    input       wire [1:0]      CGRA_REG_RRESP,
    input       wire            CGRA_REG_RLAST,
    input       wire            CGRA_REG_RVALID,
    output      wire            CGRA_REG_RREADY,

  // TLX
    input       wire            TLX_INT,

    output      wire [3:0]      TLX_AWID,
    output      wire [31:0]     TLX_AWADDR,
    output      wire [7:0]      TLX_AWLEN,
    output      wire [2:0]      TLX_AWSIZE,
    output      wire [1:0]      TLX_AWBURST,
    output      wire            TLX_AWLOCK,
    output      wire [3:0]      TLX_AWCACHE,
    output      wire [2:0]      TLX_AWPROT,
    output      wire            TLX_AWVALID,
    input       wire            TLX_AWREADY,
    output      wire [63:0]     TLX_WDATA,
    output      wire [7:0]      TLX_WSTRB,
    output      wire            TLX_WLAST,
    output      wire            TLX_WVALID,
    input       wire            TLX_WREADY,
    input       wire [3:0]      TLX_BID,
    input       wire [1:0]      TLX_BRESP,
    input       wire            TLX_BVALID,
    output      wire            TLX_BREADY,
    output      wire [3:0]      TLX_ARID,
    output      wire [31:0]     TLX_ARADDR,
    output      wire [7:0]      TLX_ARLEN,
    output      wire [2:0]      TLX_ARSIZE,
    output      wire [1:0]      TLX_ARBURST,
    output      wire            TLX_ARLOCK,
    output      wire [3:0]      TLX_ARCACHE,
    output      wire [2:0]      TLX_ARPROT,
    output      wire            TLX_ARVALID,
    input       wire            TLX_ARREADY,
    input       wire [3:0]      TLX_RID,
    input       wire [63:0]     TLX_RDATA,
    input       wire [1:0]      TLX_RRESP,
    input       wire            TLX_RLAST,
    input       wire            TLX_RVALID,
    output      wire            TLX_RREADY,

    output      wire [31:0]     TLX_HADDR,
    output      wire [2:0]      TLX_HBURST,
    output      wire [3:0]      TLX_HPROT,
    output      wire [2:0]      TLX_HSIZE,
    output      wire [1:0]      TLX_HTRANS,
    output      wire [31:0]     TLX_HWDATA,
    output      wire            TLX_HWRITE,
    input       wire [31:0]     TLX_HRDATA,
    input       wire            TLX_HREADYOUT,
    input       wire            TLX_HRESP,
    output      wire            TLX_HSELx,
    output      wire            TLX_HREADY,

    // XGCD

    // output      wire [3:0]      XGCD0_AWID,
    // output      wire [31:0]     XGCD0_AWADDR,
    // output      wire [7:0]      XGCD0_AWLEN,
    // output      wire [2:0]      XGCD0_AWSIZE,
    // output      wire [1:0]      XGCD0_AWBURST,
    // output      wire            XGCD0_AWLOCK,
    // output      wire [3:0]      XGCD0_AWCACHE,
    // output      wire [2:0]      XGCD0_AWPROT,
    // output      wire            XGCD0_AWVALID,
    // input       wire            XGCD0_AWREADY,
    // output      wire [63:0]     XGCD0_WDATA,
    // output      wire [7:0]      XGCD0_WSTRB,
    // output      wire            XGCD0_WLAST,
    // output      wire            XGCD0_WVALID,
    // input       wire            XGCD0_WREADY,
    // input       wire [3:0]      XGCD0_BID,
    // input       wire [1:0]      XGCD0_BRESP,
    // input       wire            XGCD0_BVALID,
    // output      wire            XGCD0_BREADY,
    // output      wire [3:0]      XGCD0_ARID,
    // output      wire [31:0]     XGCD0_ARADDR,
    // output      wire [7:0]      XGCD0_ARLEN,
    // output      wire [2:0]      XGCD0_ARSIZE,
    // output      wire [1:0]      XGCD0_ARBURST,
    // output      wire            XGCD0_ARLOCK,
    // output      wire [3:0]      XGCD0_ARCACHE,
    // output      wire [2:0]      XGCD0_ARPROT,
    // output      wire            XGCD0_ARVALID,
    // input       wire            XGCD0_ARREADY,
    // input       wire [3:0]      XGCD0_RID,
    // input       wire [63:0]     XGCD0_RDATA,
    // input       wire [1:0]      XGCD0_RRESP,
    // input       wire            XGCD0_RLAST,
    // input       wire            XGCD0_RVALID,
    // output      wire            XGCD0_RREADY,

    // output      wire [3:0]      XGCD1_AWID,
    // output      wire [31:0]     XGCD1_AWADDR,
    // output      wire [7:0]      XGCD1_AWLEN,
    // output      wire [2:0]      XGCD1_AWSIZE,
    // output      wire [1:0]      XGCD1_AWBURST,
    // output      wire            XGCD1_AWLOCK,
    // output      wire [3:0]      XGCD1_AWCACHE,
    // output      wire [2:0]      XGCD1_AWPROT,
    // output      wire            XGCD1_AWVALID,
    // input       wire            XGCD1_AWREADY,
    // output      wire [63:0]     XGCD1_WDATA,
    // output      wire [7:0]      XGCD1_WSTRB,
    // output      wire            XGCD1_WLAST,
    // output      wire            XGCD1_WVALID,
    // input       wire            XGCD1_WREADY,
    // input       wire [3:0]      XGCD1_BID,
    // input       wire [1:0]      XGCD1_BRESP,
    // input       wire            XGCD1_BVALID,
    // output      wire            XGCD1_BREADY,
    // output      wire [3:0]      XGCD1_ARID,
    // output      wire [31:0]     XGCD1_ARADDR,
    // output      wire [7:0]      XGCD1_ARLEN,
    // output      wire [2:0]      XGCD1_ARSIZE,
    // output      wire [1:0]      XGCD1_ARBURST,
    // output      wire            XGCD1_ARLOCK,
    // output      wire [3:0]      XGCD1_ARCACHE,
    // output      wire [2:0]      XGCD1_ARPROT,
    // output      wire            XGCD1_ARVALID,
    // input       wire            XGCD1_ARREADY,
    // input       wire [3:0]      XGCD1_RID,
    // input       wire [63:0]     XGCD1_RDATA,
    // input       wire [1:0]      XGCD1_RRESP,
    // input       wire            XGCD1_RLAST,
    // input       wire            XGCD1_RVALID,
    // output      wire            XGCD1_RREADY,

    // output      wire [31:0]     XGCD_HADDR,
    // output      wire [2:0]      XGCD_HBURST,
    // output      wire [3:0]      XGCD_HPROT,
    // output      wire [2:0]      XGCD_HSIZE,
    // output      wire [1:0]      XGCD_HTRANS,
    // output      wire [31:0]     XGCD_HWDATA,
    // output      wire            XGCD_HWRITE,
    // input       wire [31:0]     XGCD_HRDATA,
    // input       wire            XGCD_HREADYOUT,
    // input       wire            XGCD_HRESP,
    // output      wire            XGCD_HSELx,
    // output      wire            XGCD_HREADY,

    // input       wire            XGCD0_INT,
    // input       wire            XGCD1_INT,

    // Platform Controller
    output      wire            PCTRL_HSEL,
    output      wire [31:0]     PCTRL_HADDR,
    output      wire  [1:0]     PCTRL_HTRANS,
    output      wire            PCTRL_HWRITE,
    output      wire  [2:0]     PCTRL_HSIZE,
    output      wire  [2:0]     PCTRL_HBURST,
    output      wire  [3:0]     PCTRL_HPROT,
    output      wire  [3:0]     PCTRL_HMASTER,
    output      wire [31:0]     PCTRL_HWDATA,
    output      wire            PCTRL_HMASTLOCK,
    output      wire            PCTRL_HREADYMUX,

    input       wire [31:0]     PCTRL_HRDATA,
    input       wire            PCTRL_HREADYOUT,
    input       wire [1:0]      PCTRL_HRESP
);

    // CPU Integration Wires
    wire [31:0]                 cpu_haddr;
    wire [2 :0]                 cpu_hburst;
    wire [3 :0]                 cpu_hprot;
    wire [2 :0]                 cpu_hsize;
    wire [1 :0]                 cpu_htrans;
    wire [31:0]                 cpu_hwdata;
    wire                        cpu_hwrite;
    wire [31:0]                 cpu_hrdata;
    wire [1 :0]                 cpu_hresp;
    wire                        cpu_hready;

    // DMA0 Wires
    wire [1 :0]                 dma0_awid;
    wire [31:0]                 dma0_awaddr;
    wire [7 :0]                 dma0_awlen;
    wire [2 :0]                 dma0_awsize;
    wire [1 :0]                 dma0_awburst;
    wire                        dma0_awlock;
    wire [3 :0]                 dma0_awcache;
    wire [2 :0]                 dma0_awprot;
    wire                        dma0_awvalid;
    wire                        dma0_awready;
    wire [63:0]                 dma0_wdata;
    wire [7 :0]                 dma0_wstrb;
    wire                        dma0_wlast;
    wire                        dma0_wvalid;
    wire                        dma0_wready;
    wire [1 :0]                 dma0_bid;
    wire [1 :0]                 dma0_bresp;
    wire                        dma0_bvalid;
    wire                        dma0_bready;
    wire [1 :0]                 dma0_arid;
    wire [31:0]                 dma0_araddr;
    wire [7 :0]                 dma0_arlen;
    wire [2 :0]                 dma0_arsize;
    wire [1 :0]                 dma0_arburst;
    wire                        dma0_arlock;
    wire [3 :0]                 dma0_arcache;
    wire [2 :0]                 dma0_arprot;
    wire                        dma0_arvalid;
    wire                        dma0_arready;
    wire [1 :0]                 dma0_rid;
    wire [63:0]                 dma0_rdata;
    wire [1 :0]                 dma0_rresp;
    wire                        dma0_rlast;
    wire                        dma0_rvalid;
    wire                        dma0_rready;

    wire [11:0]                 dma0_paddr;
    wire                        dma0_penable;
    wire                        dma0_pwrite;
    wire                        dma0_psel;
    wire [31:0]                 dma0_pwdata;
    wire [31:0]                 dma0_prdata;
    wire                        dma0_pready;
    wire                        dma0_pslverr;

    // DMA1 Wires
    wire [1 :0]                 dma1_awid;
    wire [31:0]                 dma1_awaddr;
    wire [7 :0]                 dma1_awlen;
    wire [2 :0]                 dma1_awsize;
    wire [1 :0]                 dma1_awburst;
    wire                        dma1_awlock;
    wire [3 :0]                 dma1_awcache;
    wire [2 :0]                 dma1_awprot;
    wire                        dma1_awvalid;
    wire                        dma1_awready;
    wire [63:0]                 dma1_wdata;
    wire [7 :0]                 dma1_wstrb;
    wire                        dma1_wlast;
    wire                        dma1_wvalid;
    wire                        dma1_wready;
    wire [1 :0]                 dma1_bid;
    wire [1 :0]                 dma1_bresp;
    wire                        dma1_bvalid;
    wire                        dma1_bready;
    wire [1 :0]                 dma1_arid;
    wire [31:0]                 dma1_araddr;
    wire [7 :0]                 dma1_arlen;
    wire [2 :0]                 dma1_arsize;
    wire [1 :0]                 dma1_arburst;
    wire                        dma1_arlock;
    wire [3 :0]                 dma1_arcache;
    wire [2 :0]                 dma1_arprot;
    wire                        dma1_arvalid;
    wire                        dma1_arready;
    wire [1 :0]                 dma1_rid;
    wire [63:0]                 dma1_rdata;
    wire [1 :0]                 dma1_rresp;
    wire                        dma1_rlast;
    wire                        dma1_rvalid;
    wire                        dma1_rready;

    wire [11:0]                 dma1_paddr;
    wire                        dma1_penable;
    wire                        dma1_pwrite;
    wire                        dma1_psel;
    wire [31:0]                 dma1_pwdata;
    wire [31:0]                 dma1_prdata;
    wire                        dma1_pready;
    wire                        dma1_pslverr;

    // SRAM0 Wires
    wire [3 :0]                 sram0_awid;
    wire [31:0]                 sram0_awaddr;
    wire [7 :0]                 sram0_awlen;
    wire [2 :0]                 sram0_awsize;
    wire [1 :0]                 sram0_awburst;
    wire                        sram0_awlock;
    wire [3 :0]                 sram0_awcache;
    wire [2 :0]                 sram0_awprot;
    wire                        sram0_awvalid;
    wire                        sram0_awready;
    wire [63:0]                 sram0_wdata;
    wire [7 :0]                 sram0_wstrb;
    wire                        sram0_wlast;
    wire                        sram0_wvalid;
    wire                        sram0_wready;
    wire [3 :0]                 sram0_bid;
    wire [1 :0]                 sram0_bresp;
    wire                        sram0_bvalid;
    wire                        sram0_bready;
    wire [3 :0]                 sram0_arid;
    wire [31:0]                 sram0_araddr;
    wire [7 :0]                 sram0_arlen;
    wire [2 :0]                 sram0_arsize;
    wire [1 :0]                 sram0_arburst;
    wire                        sram0_arlock;
    wire [3 :0]                 sram0_arcache;
    wire [2 :0]                 sram0_arprot;
    wire                        sram0_arvalid;
    wire                        sram0_arready;
    wire [3 :0]                 sram0_rid;
    wire [63:0]                 sram0_rdata;
    wire [1 :0]                 sram0_rresp;
    wire                        sram0_rlast;
    wire                        sram0_rvalid;
    wire                        sram0_rready;

    // SRAM1 Wires
    wire [3 :0]                 sram1_awid;
    wire [31:0]                 sram1_awaddr;
    wire [7 :0]                 sram1_awlen;
    wire [2 :0]                 sram1_awsize;
    wire [1 :0]                 sram1_awburst;
    wire                        sram1_awlock;
    wire [3 :0]                 sram1_awcache;
    wire [2 :0]                 sram1_awprot;
    wire                        sram1_awvalid;
    wire                        sram1_awready;
    wire [63:0]                 sram1_wdata;
    wire [7 :0]                 sram1_wstrb;
    wire                        sram1_wlast;
    wire                        sram1_wvalid;
    wire                        sram1_wready;
    wire [3 :0]                 sram1_bid;
    wire [1 :0]                 sram1_bresp;
    wire                        sram1_bvalid;
    wire                        sram1_bready;
    wire [3 :0]                 sram1_arid;
    wire [31:0]                 sram1_araddr;
    wire [7 :0]                 sram1_arlen;
    wire [2 :0]                 sram1_arsize;
    wire [1 :0]                 sram1_arburst;
    wire                        sram1_arlock;
    wire [3 :0]                 sram1_arcache;
    wire [2 :0]                 sram1_arprot;
    wire                        sram1_arvalid;
    wire                        sram1_arready;
    wire [3 :0]                 sram1_rid;
    wire [63:0]                 sram1_rdata;
    wire [1 :0]                 sram1_rresp;
    wire                        sram1_rlast;
    wire                        sram1_rvalid;
    wire                        sram1_rready;

    // SRAM2 Wires
    wire [3 :0]                 sram2_awid;
    wire [31:0]                 sram2_awaddr;
    wire [7 :0]                 sram2_awlen;
    wire [2 :0]                 sram2_awsize;
    wire [1 :0]                 sram2_awburst;
    wire                        sram2_awlock;
    wire [3 :0]                 sram2_awcache;
    wire [2 :0]                 sram2_awprot;
    wire                        sram2_awvalid;
    wire                        sram2_awready;
    wire [63:0]                 sram2_wdata;
    wire [7 :0]                 sram2_wstrb;
    wire                        sram2_wlast;
    wire                        sram2_wvalid;
    wire                        sram2_wready;
    wire [3 :0]                 sram2_bid;
    wire [1 :0]                 sram2_bresp;
    wire                        sram2_bvalid;
    wire                        sram2_bready;
    wire [3 :0]                 sram2_arid;
    wire [31:0]                 sram2_araddr;
    wire [7 :0]                 sram2_arlen;
    wire [2 :0]                 sram2_arsize;
    wire [1 :0]                 sram2_arburst;
    wire                        sram2_arlock;
    wire [3 :0]                 sram2_arcache;
    wire [2 :0]                 sram2_arprot;
    wire                        sram2_arvalid;
    wire                        sram2_arready;
    wire [3 :0]                 sram2_rid;
    wire [63:0]                 sram2_rdata;
    wire [1 :0]                 sram2_rresp;
    wire                        sram2_rlast;
    wire                        sram2_rvalid;
    wire                        sram2_rready;

    // SRAM3 Wires
    wire [3 :0]                 sram3_awid;
    wire [31:0]                 sram3_awaddr;
    wire [7 :0]                 sram3_awlen;
    wire [2 :0]                 sram3_awsize;
    wire [1 :0]                 sram3_awburst;
    wire                        sram3_awlock;
    wire [3 :0]                 sram3_awcache;
    wire [2 :0]                 sram3_awprot;
    wire                        sram3_awvalid;
    wire                        sram3_awready;
    wire [63:0]                 sram3_wdata;
    wire [7 :0]                 sram3_wstrb;
    wire                        sram3_wlast;
    wire                        sram3_wvalid;
    wire                        sram3_wready;
    wire [3 :0]                 sram3_bid;
    wire [1 :0]                 sram3_bresp;
    wire                        sram3_bvalid;
    wire                        sram3_bready;
    wire [3 :0]                 sram3_arid;
    wire [31:0]                 sram3_araddr;
    wire [7 :0]                 sram3_arlen;
    wire [2 :0]                 sram3_arsize;
    wire [1 :0]                 sram3_arburst;
    wire                        sram3_arlock;
    wire [3 :0]                 sram3_arcache;
    wire [2 :0]                 sram3_arprot;
    wire                        sram3_arvalid;
    wire                        sram3_arready;
    wire [3 :0]                 sram3_rid;
    wire [63:0]                 sram3_rdata;
    wire [1 :0]                 sram3_rresp;
    wire                        sram3_rlast;
    wire                        sram3_rvalid;
    wire                        sram3_rready;

    // Peripheral Subsystem Wires
    wire [31:0]                 periph_haddr;
    wire [2 :0]                 periph_hburst;
    wire [3 :0]                 periph_hprot;
    wire [2 :0]                 periph_hsize;
    wire [1 :0]                 periph_htrans;
    wire [31:0]                 periph_hwdata;
    wire                        periph_hwrite;
    wire [31:0]                 periph_hrdata;
    wire                        periph_hreadyout;
    wire  [1:0]                 periph_hresp;
    wire                        periph_hsel;
    wire                        periph_hready;

    wire                        timer0_int;
    wire                        timer1_int;

    wire                        uart0_txint;
    wire                        uart0_rxint;
    wire                        uart0_txovrint;
    wire                        uart0_rxovrint;
    wire                        uart0_uartint;

    wire                        uart1_txint;
    wire                        uart1_rxint;
    wire                        uart1_txovrint;
    wire                        uart1_rxovrint;
    wire                        uart1_uartint;

    wire [1:0]                  dma0_int;
    wire [1:0]                  dma1_int;
    wire                        wdog_int;

    // Instantiate System Interconnect
    nic400_OnyxIntegration u_nic_interconnect (

    // Instance: u_cd_CGRA, Port: M_AXI_CGRA_DATA

    .AWID_M_AXI_CGRA_DATA       (CGRA_DATA_AWID),
    .AWADDR_M_AXI_CGRA_DATA     (CGRA_DATA_AWADDR),
    .AWLEN_M_AXI_CGRA_DATA      (CGRA_DATA_AWLEN),
    .AWSIZE_M_AXI_CGRA_DATA     (CGRA_DATA_AWSIZE),
    .AWBURST_M_AXI_CGRA_DATA    (CGRA_DATA_AWBURST),
    .AWLOCK_M_AXI_CGRA_DATA     (CGRA_DATA_AWLOCK),
    .AWCACHE_M_AXI_CGRA_DATA    (CGRA_DATA_AWCACHE),
    .AWPROT_M_AXI_CGRA_DATA     (CGRA_DATA_AWPROT),
    .AWVALID_M_AXI_CGRA_DATA    (CGRA_DATA_AWVALID),
    .AWREADY_M_AXI_CGRA_DATA    (CGRA_DATA_AWREADY),
    .WDATA_M_AXI_CGRA_DATA      (CGRA_DATA_WDATA),
    .WSTRB_M_AXI_CGRA_DATA      (CGRA_DATA_WSTRB),
    .WLAST_M_AXI_CGRA_DATA      (CGRA_DATA_WLAST),
    .WVALID_M_AXI_CGRA_DATA     (CGRA_DATA_WVALID),
    .WREADY_M_AXI_CGRA_DATA     (CGRA_DATA_WREADY),
    .BID_M_AXI_CGRA_DATA        (CGRA_DATA_BID),
    .BRESP_M_AXI_CGRA_DATA      (CGRA_DATA_BRESP),
    .BVALID_M_AXI_CGRA_DATA     (CGRA_DATA_BVALID),
    .BREADY_M_AXI_CGRA_DATA     (CGRA_DATA_BREADY),
    .ARID_M_AXI_CGRA_DATA       (CGRA_DATA_ARID),
    .ARADDR_M_AXI_CGRA_DATA     (CGRA_DATA_ARADDR),
    .ARLEN_M_AXI_CGRA_DATA      (CGRA_DATA_ARLEN),
    .ARSIZE_M_AXI_CGRA_DATA     (CGRA_DATA_ARSIZE),
    .ARBURST_M_AXI_CGRA_DATA    (CGRA_DATA_ARBURST),
    .ARLOCK_M_AXI_CGRA_DATA     (CGRA_DATA_ARLOCK),
    .ARCACHE_M_AXI_CGRA_DATA    (CGRA_DATA_ARCACHE),
    .ARPROT_M_AXI_CGRA_DATA     (CGRA_DATA_ARPROT),
    .ARVALID_M_AXI_CGRA_DATA    (CGRA_DATA_ARVALID),
    .ARREADY_M_AXI_CGRA_DATA    (CGRA_DATA_ARREADY),
    .RID_M_AXI_CGRA_DATA        (CGRA_DATA_RID),
    .RDATA_M_AXI_CGRA_DATA      (CGRA_DATA_RDATA),
    .RRESP_M_AXI_CGRA_DATA      (CGRA_DATA_RRESP),
    .RLAST_M_AXI_CGRA_DATA      (CGRA_DATA_RLAST),
    .RVALID_M_AXI_CGRA_DATA     (CGRA_DATA_RVALID),
    .RREADY_M_AXI_CGRA_DATA     (CGRA_DATA_RREADY),

    // Instance: u_cd_CGRA, Port: M_AXI_CGRA_REG

    .AWID_M_AXI_CGRA_REG        (CGRA_REG_AWID),
    .AWADDR_M_AXI_CGRA_REG      (CGRA_REG_AWADDR),
    .AWLEN_M_AXI_CGRA_REG       (CGRA_REG_AWLEN),
    .AWSIZE_M_AXI_CGRA_REG      (CGRA_REG_AWSIZE),
    .AWBURST_M_AXI_CGRA_REG     (CGRA_REG_AWBURST),
    .AWLOCK_M_AXI_CGRA_REG      (CGRA_REG_AWLOCK),
    .AWCACHE_M_AXI_CGRA_REG     (CGRA_REG_AWCACHE),
    .AWPROT_M_AXI_CGRA_REG      (CGRA_REG_AWPROT),
    .AWVALID_M_AXI_CGRA_REG     (CGRA_REG_AWVALID),
    .AWREADY_M_AXI_CGRA_REG     (CGRA_REG_AWREADY),
    .WDATA_M_AXI_CGRA_REG       (CGRA_REG_WDATA),
    .WSTRB_M_AXI_CGRA_REG       (CGRA_REG_WSTRB),
    .WLAST_M_AXI_CGRA_REG       (CGRA_REG_WLAST),
    .WVALID_M_AXI_CGRA_REG      (CGRA_REG_WVALID),
    .WREADY_M_AXI_CGRA_REG      (CGRA_REG_WREADY),
    .BID_M_AXI_CGRA_REG         (CGRA_REG_BID),
    .BRESP_M_AXI_CGRA_REG       (CGRA_REG_BRESP),
    .BVALID_M_AXI_CGRA_REG      (CGRA_REG_BVALID),
    .BREADY_M_AXI_CGRA_REG      (CGRA_REG_BREADY),
    .ARID_M_AXI_CGRA_REG        (CGRA_REG_ARID),
    .ARADDR_M_AXI_CGRA_REG      (CGRA_REG_ARADDR),
    .ARLEN_M_AXI_CGRA_REG       (CGRA_REG_ARLEN),
    .ARSIZE_M_AXI_CGRA_REG      (CGRA_REG_ARSIZE),
    .ARBURST_M_AXI_CGRA_REG     (CGRA_REG_ARBURST),
    .ARLOCK_M_AXI_CGRA_REG      (CGRA_REG_ARLOCK),
    .ARCACHE_M_AXI_CGRA_REG     (CGRA_REG_ARCACHE),
    .ARPROT_M_AXI_CGRA_REG      (CGRA_REG_ARPROT),
    .ARVALID_M_AXI_CGRA_REG     (CGRA_REG_ARVALID),
    .ARREADY_M_AXI_CGRA_REG     (CGRA_REG_ARREADY),
    .RID_M_AXI_CGRA_REG         (CGRA_REG_RID),
    .RDATA_M_AXI_CGRA_REG       (CGRA_REG_RDATA),
    .RRESP_M_AXI_CGRA_REG       (CGRA_REG_RRESP),
    .RLAST_M_AXI_CGRA_REG       (CGRA_REG_RLAST),
    .RVALID_M_AXI_CGRA_REG      (CGRA_REG_RVALID),
    .RREADY_M_AXI_CGRA_REG      (CGRA_REG_RREADY),

    // Instance: u_cd_SYSTEM, Port: M_AHB_PERIPH

    .HADDR_M_AHB_PERIPH         (periph_haddr),
    .HBURST_M_AHB_PERIPH        (periph_hburst),
    .HPROT_M_AHB_PERIPH         (periph_hprot),
    .HSIZE_M_AHB_PERIPH         (periph_hsize),
    .HTRANS_M_AHB_PERIPH        (periph_htrans),
    .HWDATA_M_AHB_PERIPH        (periph_hwdata),
    .HWRITE_M_AHB_PERIPH        (periph_hwrite),
    .HRDATA_M_AHB_PERIPH        (periph_hrdata),
    .HREADYOUT_M_AHB_PERIPH     (periph_hreadyout),
    .HRESP_M_AHB_PERIPH         (periph_hresp[0]),
    .HSELx_M_AHB_PERIPH         (periph_hsel),
    .HREADY_M_AHB_PERIPH        (periph_hready),

    // Instance: u_cd_SYSTEM, Port: BID_M_AXI_SRAM0

    .AWID_M_AXI_SRAM0           (sram0_awid),
    .AWADDR_M_AXI_SRAM0         (sram0_awaddr),
    .AWLEN_M_AXI_SRAM0          (sram0_awlen),
    .AWSIZE_M_AXI_SRAM0         (sram0_awsize),
    .AWBURST_M_AXI_SRAM0        (sram0_awburst),
    .AWLOCK_M_AXI_SRAM0         (sram0_awlock),
    .AWCACHE_M_AXI_SRAM0        (sram0_awcache),
    .AWPROT_M_AXI_SRAM0         (sram0_awprot),
    .AWVALID_M_AXI_SRAM0        (sram0_awvalid),
    .AWREADY_M_AXI_SRAM0        (sram0_awready),
    .WDATA_M_AXI_SRAM0          (sram0_wdata),
    .WSTRB_M_AXI_SRAM0          (sram0_wstrb),
    .WLAST_M_AXI_SRAM0          (sram0_wlast),
    .WVALID_M_AXI_SRAM0         (sram0_wvalid),
    .WREADY_M_AXI_SRAM0         (sram0_wready),
    .BID_M_AXI_SRAM0            (sram0_bid),
    .BRESP_M_AXI_SRAM0          (sram0_bresp),
    .BVALID_M_AXI_SRAM0         (sram0_bvalid),
    .BREADY_M_AXI_SRAM0         (sram0_bready),
    .ARID_M_AXI_SRAM0           (sram0_arid),
    .ARADDR_M_AXI_SRAM0         (sram0_araddr),
    .ARLEN_M_AXI_SRAM0          (sram0_arlen),
    .ARSIZE_M_AXI_SRAM0         (sram0_arsize),
    .ARBURST_M_AXI_SRAM0        (sram0_arburst),
    .ARLOCK_M_AXI_SRAM0         (sram0_arlock),
    .ARCACHE_M_AXI_SRAM0        (sram0_arcache),
    .ARPROT_M_AXI_SRAM0         (sram0_arprot),
    .ARVALID_M_AXI_SRAM0        (sram0_arvalid),
    .ARREADY_M_AXI_SRAM0        (sram0_arready),
    .RID_M_AXI_SRAM0            (sram0_rid),
    .RDATA_M_AXI_SRAM0          (sram0_rdata),
    .RRESP_M_AXI_SRAM0          (sram0_rresp),
    .RLAST_M_AXI_SRAM0          (sram0_rlast),
    .RVALID_M_AXI_SRAM0         (sram0_rvalid),
    .RREADY_M_AXI_SRAM0         (sram0_rready),

    // Instance: u_cd_SYSTEM, Port: M_AXI_SRAM1

    .AWID_M_AXI_SRAM1           (sram1_awid),
    .AWADDR_M_AXI_SRAM1         (sram1_awaddr),
    .AWLEN_M_AXI_SRAM1          (sram1_awlen),
    .AWSIZE_M_AXI_SRAM1         (sram1_awsize),
    .AWBURST_M_AXI_SRAM1        (sram1_awburst),
    .AWLOCK_M_AXI_SRAM1         (sram1_awlock),
    .AWCACHE_M_AXI_SRAM1        (sram1_awcache),
    .AWPROT_M_AXI_SRAM1         (sram1_awprot),
    .AWVALID_M_AXI_SRAM1        (sram1_awvalid),
    .AWREADY_M_AXI_SRAM1        (sram1_awready),
    .WDATA_M_AXI_SRAM1          (sram1_wdata),
    .WSTRB_M_AXI_SRAM1          (sram1_wstrb),
    .WLAST_M_AXI_SRAM1          (sram1_wlast),
    .WVALID_M_AXI_SRAM1         (sram1_wvalid),
    .WREADY_M_AXI_SRAM1         (sram1_wready),
    .BID_M_AXI_SRAM1            (sram1_bid),
    .BRESP_M_AXI_SRAM1          (sram1_bresp),
    .BVALID_M_AXI_SRAM1         (sram1_bvalid),
    .BREADY_M_AXI_SRAM1         (sram1_bready),
    .ARID_M_AXI_SRAM1           (sram1_arid),
    .ARADDR_M_AXI_SRAM1         (sram1_araddr),
    .ARLEN_M_AXI_SRAM1          (sram1_arlen),
    .ARSIZE_M_AXI_SRAM1         (sram1_arsize),
    .ARBURST_M_AXI_SRAM1        (sram1_arburst),
    .ARLOCK_M_AXI_SRAM1         (sram1_arlock),
    .ARCACHE_M_AXI_SRAM1        (sram1_arcache),
    .ARPROT_M_AXI_SRAM1         (sram1_arprot),
    .ARVALID_M_AXI_SRAM1        (sram1_arvalid),
    .ARREADY_M_AXI_SRAM1        (sram1_arready),
    .RID_M_AXI_SRAM1            (sram1_rid),
    .RDATA_M_AXI_SRAM1          (sram1_rdata),
    .RRESP_M_AXI_SRAM1          (sram1_rresp),
    .RLAST_M_AXI_SRAM1          (sram1_rlast),
    .RVALID_M_AXI_SRAM1         (sram1_rvalid),
    .RREADY_M_AXI_SRAM1         (sram1_rready),

    // Instance: u_cd_SYSTEM, Port: M_AXI_SRAM2

    .AWID_M_AXI_SRAM2           (sram2_awid),
    .AWADDR_M_AXI_SRAM2         (sram2_awaddr),
    .AWLEN_M_AXI_SRAM2          (sram2_awlen),
    .AWSIZE_M_AXI_SRAM2         (sram2_awsize),
    .AWBURST_M_AXI_SRAM2        (sram2_awburst),
    .AWLOCK_M_AXI_SRAM2         (sram2_awlock),
    .AWCACHE_M_AXI_SRAM2        (sram2_awcache),
    .AWPROT_M_AXI_SRAM2         (sram2_awprot),
    .AWVALID_M_AXI_SRAM2        (sram2_awvalid),
    .AWREADY_M_AXI_SRAM2        (sram2_awready),
    .WDATA_M_AXI_SRAM2          (sram2_wdata),
    .WSTRB_M_AXI_SRAM2          (sram2_wstrb),
    .WLAST_M_AXI_SRAM2          (sram2_wlast),
    .WVALID_M_AXI_SRAM2         (sram2_wvalid),
    .WREADY_M_AXI_SRAM2         (sram2_wready),
    .BID_M_AXI_SRAM2            (sram2_bid),
    .BRESP_M_AXI_SRAM2          (sram2_bresp),
    .BVALID_M_AXI_SRAM2         (sram2_bvalid),
    .BREADY_M_AXI_SRAM2         (sram2_bready),
    .ARID_M_AXI_SRAM2           (sram2_arid),
    .ARADDR_M_AXI_SRAM2         (sram2_araddr),
    .ARLEN_M_AXI_SRAM2          (sram2_arlen),
    .ARSIZE_M_AXI_SRAM2         (sram2_arsize),
    .ARBURST_M_AXI_SRAM2        (sram2_arburst),
    .ARLOCK_M_AXI_SRAM2         (sram2_arlock),
    .ARCACHE_M_AXI_SRAM2        (sram2_arcache),
    .ARPROT_M_AXI_SRAM2         (sram2_arprot),
    .ARVALID_M_AXI_SRAM2        (sram2_arvalid),
    .ARREADY_M_AXI_SRAM2        (sram2_arready),
    .RID_M_AXI_SRAM2            (sram2_rid),
    .RDATA_M_AXI_SRAM2          (sram2_rdata),
    .RRESP_M_AXI_SRAM2          (sram2_rresp),
    .RLAST_M_AXI_SRAM2          (sram2_rlast),
    .RVALID_M_AXI_SRAM2         (sram2_rvalid),
    .RREADY_M_AXI_SRAM2         (sram2_rready),

    // Instance: u_cd_SYSTEM, Port: M_AXI_SRAM3

    .AWID_M_AXI_SRAM3           (sram3_awid),
    .AWADDR_M_AXI_SRAM3         (sram3_awaddr),
    .AWLEN_M_AXI_SRAM3          (sram3_awlen),
    .AWSIZE_M_AXI_SRAM3         (sram3_awsize),
    .AWBURST_M_AXI_SRAM3        (sram3_awburst),
    .AWLOCK_M_AXI_SRAM3         (sram3_awlock),
    .AWCACHE_M_AXI_SRAM3        (sram3_awcache),
    .AWPROT_M_AXI_SRAM3         (sram3_awprot),
    .AWVALID_M_AXI_SRAM3        (sram3_awvalid),
    .AWREADY_M_AXI_SRAM3        (sram3_awready),
    .WDATA_M_AXI_SRAM3          (sram3_wdata),
    .WSTRB_M_AXI_SRAM3          (sram3_wstrb),
    .WLAST_M_AXI_SRAM3          (sram3_wlast),
    .WVALID_M_AXI_SRAM3         (sram3_wvalid),
    .WREADY_M_AXI_SRAM3         (sram3_wready),
    .BID_M_AXI_SRAM3            (sram3_bid),
    .BRESP_M_AXI_SRAM3          (sram3_bresp),
    .BVALID_M_AXI_SRAM3         (sram3_bvalid),
    .BREADY_M_AXI_SRAM3         (sram3_bready),
    .ARID_M_AXI_SRAM3           (sram3_arid),
    .ARADDR_M_AXI_SRAM3         (sram3_araddr),
    .ARLEN_M_AXI_SRAM3          (sram3_arlen),
    .ARSIZE_M_AXI_SRAM3         (sram3_arsize),
    .ARBURST_M_AXI_SRAM3        (sram3_arburst),
    .ARLOCK_M_AXI_SRAM3         (sram3_arlock),
    .ARCACHE_M_AXI_SRAM3        (sram3_arcache),
    .ARPROT_M_AXI_SRAM3         (sram3_arprot),
    .ARVALID_M_AXI_SRAM3        (sram3_arvalid),
    .ARREADY_M_AXI_SRAM3        (sram3_arready),
    .RID_M_AXI_SRAM3            (sram3_rid),
    .RDATA_M_AXI_SRAM3          (sram3_rdata),
    .RRESP_M_AXI_SRAM3          (sram3_rresp),
    .RLAST_M_AXI_SRAM3          (sram3_rlast),
    .RVALID_M_AXI_SRAM3         (sram3_rvalid),
    .RREADY_M_AXI_SRAM3         (sram3_rready),

    // Instance: u_cd_SYSTEM, Port: S_AHB_CPU

    .HADDR_S_AHB_CPU            (cpu_haddr),
    .HBURST_S_AHB_CPU           (cpu_hburst),
    .HPROT_S_AHB_CPU            (cpu_hprot),
    .HSIZE_S_AHB_CPU            (cpu_hsize),
    .HTRANS_S_AHB_CPU           (cpu_htrans),
    .HWDATA_S_AHB_CPU           (cpu_hwdata),
    .HWRITE_S_AHB_CPU           (cpu_hwrite),
    .HRDATA_S_AHB_CPU           (cpu_hrdata),
    .HRESP_S_AHB_CPU            (cpu_hresp[0]),
    .HREADY_S_AHB_CPU           (cpu_hready),

    // Instance: u_cd_SYSTEM, Port: S_AXI_DMA0

    .AWID_S_AXI_DMA0            (dma0_awid),
    .AWADDR_S_AXI_DMA0          (dma0_awaddr),
    .AWLEN_S_AXI_DMA0           (dma0_awlen),
    .AWSIZE_S_AXI_DMA0          (dma0_awsize),
    .AWBURST_S_AXI_DMA0         (dma0_awburst),
    .AWLOCK_S_AXI_DMA0          (dma0_awlock),
    .AWCACHE_S_AXI_DMA0         (dma0_awcache),
    .AWPROT_S_AXI_DMA0          (dma0_awprot),
    .AWVALID_S_AXI_DMA0         (dma0_awvalid),
    .AWREADY_S_AXI_DMA0         (dma0_awready),
    .WDATA_S_AXI_DMA0           (dma0_wdata),
    .WSTRB_S_AXI_DMA0           (dma0_wstrb),
    .WLAST_S_AXI_DMA0           (dma0_wlast),
    .WVALID_S_AXI_DMA0          (dma0_wvalid),
    .WREADY_S_AXI_DMA0          (dma0_wready),
    .BID_S_AXI_DMA0             (dma0_bid),
    .BRESP_S_AXI_DMA0           (dma0_bresp),
    .BVALID_S_AXI_DMA0          (dma0_bvalid),
    .BREADY_S_AXI_DMA0          (dma0_bready),
    .ARID_S_AXI_DMA0            (dma0_arid),
    .ARADDR_S_AXI_DMA0          (dma0_araddr),
    .ARLEN_S_AXI_DMA0           (dma0_arlen),
    .ARSIZE_S_AXI_DMA0          (dma0_arsize),
    .ARBURST_S_AXI_DMA0         (dma0_arburst),
    .ARLOCK_S_AXI_DMA0          (dma0_arlock),
    .ARCACHE_S_AXI_DMA0         (dma0_arcache),
    .ARPROT_S_AXI_DMA0          (dma0_arprot),
    .ARVALID_S_AXI_DMA0         (dma0_arvalid),
    .ARREADY_S_AXI_DMA0         (dma0_arready),
    .RID_S_AXI_DMA0             (dma0_rid),
    .RDATA_S_AXI_DMA0           (dma0_rdata),
    .RRESP_S_AXI_DMA0           (dma0_rresp),
    .RLAST_S_AXI_DMA0           (dma0_rlast),
    .RVALID_S_AXI_DMA0          (dma0_rvalid),
    .RREADY_S_AXI_DMA0          (dma0_rready),

    // Instance: u_cd_SYSTEM, Port: S_AXI_DMA1

    .AWID_S_AXI_DMA1            (dma1_awid),
    .AWADDR_S_AXI_DMA1          (dma1_awaddr),
    .AWLEN_S_AXI_DMA1           (dma1_awlen),
    .AWSIZE_S_AXI_DMA1          (dma1_awsize),
    .AWBURST_S_AXI_DMA1         (dma1_awburst),
    .AWLOCK_S_AXI_DMA1          (dma1_awlock),
    .AWCACHE_S_AXI_DMA1         (dma1_awcache),
    .AWPROT_S_AXI_DMA1          (dma1_awprot),
    .AWVALID_S_AXI_DMA1         (dma1_awvalid),
    .AWREADY_S_AXI_DMA1         (dma1_awready),
    .WDATA_S_AXI_DMA1           (dma1_wdata),
    .WSTRB_S_AXI_DMA1           (dma1_wstrb),
    .WLAST_S_AXI_DMA1           (dma1_wlast),
    .WVALID_S_AXI_DMA1          (dma1_wvalid),
    .WREADY_S_AXI_DMA1          (dma1_wready),
    .BID_S_AXI_DMA1             (dma1_bid),
    .BRESP_S_AXI_DMA1           (dma1_bresp),
    .BVALID_S_AXI_DMA1          (dma1_bvalid),
    .BREADY_S_AXI_DMA1          (dma1_bready),
    .ARID_S_AXI_DMA1            (dma1_arid),
    .ARADDR_S_AXI_DMA1          (dma1_araddr),
    .ARLEN_S_AXI_DMA1           (dma1_arlen),
    .ARSIZE_S_AXI_DMA1          (dma1_arsize),
    .ARBURST_S_AXI_DMA1         (dma1_arburst),
    .ARLOCK_S_AXI_DMA1          (dma1_arlock),
    .ARCACHE_S_AXI_DMA1         (dma1_arcache),
    .ARPROT_S_AXI_DMA1          (dma1_arprot),
    .ARVALID_S_AXI_DMA1         (dma1_arvalid),
    .ARREADY_S_AXI_DMA1         (dma1_arready),
    .RID_S_AXI_DMA1             (dma1_rid),
    .RDATA_S_AXI_DMA1           (dma1_rdata),
    .RRESP_S_AXI_DMA1           (dma1_rresp),
    .RLAST_S_AXI_DMA1           (dma1_rlast),
    .RVALID_S_AXI_DMA1          (dma1_rvalid),
    .RREADY_S_AXI_DMA1          (dma1_rready),

    // Instance: u_cd_TLX, Port: M_AHB_TLX_REG

    .HADDR_M_AHB_TLX_REG        (TLX_HADDR),
    .HBURST_M_AHB_TLX_REG       (TLX_HBURST),
    .HPROT_M_AHB_TLX_REG        (TLX_HPROT),
    .HSIZE_M_AHB_TLX_REG        (TLX_HSIZE),
    .HTRANS_M_AHB_TLX_REG       (TLX_HTRANS),
    .HWDATA_M_AHB_TLX_REG       (TLX_HWDATA),
    .HWRITE_M_AHB_TLX_REG       (TLX_HWRITE),
    .HRDATA_M_AHB_TLX_REG       (TLX_HRDATA),
    .HREADYOUT_M_AHB_TLX_REG    (TLX_HREADYOUT),
    .HRESP_M_AHB_TLX_REG        (TLX_HRESP),
    .HSELx_M_AHB_TLX_REG        (TLX_HSELx),
    .HREADY_M_AHB_TLX_REG       (TLX_HREADY),

    // Instance: u_cd_TLX, Port: M_AXI_TLX_DATA

    .AWID_M_AXI_TLX_DATA        (TLX_AWID),
    .AWADDR_M_AXI_TLX_DATA      (TLX_AWADDR),
    .AWLEN_M_AXI_TLX_DATA       (TLX_AWLEN),
    .AWSIZE_M_AXI_TLX_DATA      (TLX_AWSIZE),
    .AWBURST_M_AXI_TLX_DATA     (TLX_AWBURST),
    .AWLOCK_M_AXI_TLX_DATA      (TLX_AWLOCK),
    .AWCACHE_M_AXI_TLX_DATA     (TLX_AWCACHE),
    .AWPROT_M_AXI_TLX_DATA      (TLX_AWPROT),
    .AWVALID_M_AXI_TLX_DATA     (TLX_AWVALID),
    .AWREADY_M_AXI_TLX_DATA     (TLX_AWREADY),
    .WDATA_M_AXI_TLX_DATA       (TLX_WDATA),
    .WSTRB_M_AXI_TLX_DATA       (TLX_WSTRB),
    .WLAST_M_AXI_TLX_DATA       (TLX_WLAST),
    .WVALID_M_AXI_TLX_DATA      (TLX_WVALID),
    .WREADY_M_AXI_TLX_DATA      (TLX_WREADY),
    .BID_M_AXI_TLX_DATA         (TLX_BID),
    .BRESP_M_AXI_TLX_DATA       (TLX_BRESP),
    .BVALID_M_AXI_TLX_DATA      (TLX_BVALID),
    .BREADY_M_AXI_TLX_DATA      (TLX_BREADY),
    .ARID_M_AXI_TLX_DATA        (TLX_ARID),
    .ARADDR_M_AXI_TLX_DATA      (TLX_ARADDR),
    .ARLEN_M_AXI_TLX_DATA       (TLX_ARLEN),
    .ARSIZE_M_AXI_TLX_DATA      (TLX_ARSIZE),
    .ARBURST_M_AXI_TLX_DATA     (TLX_ARBURST),
    .ARLOCK_M_AXI_TLX_DATA      (TLX_ARLOCK),
    .ARCACHE_M_AXI_TLX_DATA     (TLX_ARCACHE),
    .ARPROT_M_AXI_TLX_DATA      (TLX_ARPROT),
    .ARVALID_M_AXI_TLX_DATA     (TLX_ARVALID),
    .ARREADY_M_AXI_TLX_DATA     (TLX_ARREADY),
    .RID_M_AXI_TLX_DATA         (TLX_RID),
    .RDATA_M_AXI_TLX_DATA       (TLX_RDATA),
    .RRESP_M_AXI_TLX_DATA       (TLX_RRESP),
    .RLAST_M_AXI_TLX_DATA       (TLX_RLAST),
    .RVALID_M_AXI_TLX_DATA      (TLX_RVALID),
    .RREADY_M_AXI_TLX_DATA      (TLX_RREADY),

    // Instance: u_cd_XGCD, Port: M_AHB_XGCD

    // .HADDR_M_AHB_XGCD           (XGCD_HADDR),
    // .HBURST_M_AHB_XGCD          (XGCD_HBURST),
    // .HPROT_M_AHB_XGCD           (XGCD_HPROT),
    // .HSIZE_M_AHB_XGCD           (XGCD_HSIZE),
    // .HTRANS_M_AHB_XGCD          (XGCD_HTRANS),
    // .HWDATA_M_AHB_XGCD          (XGCD_HWDATA),
    // .HWRITE_M_AHB_XGCD          (XGCD_HWRITE),
    // .HRDATA_M_AHB_XGCD          (XGCD_HRDATA),
    // .HREADYOUT_M_AHB_XGCD       (XGCD_HREADYOUT),
    // .HRESP_M_AHB_XGCD           (XGCD_HRESP),
    // .HSELx_M_AHB_XGCD           (XGCD_HSELx),
    // .HREADY_M_AHB_XGCD          (XGCD_HREADY),

    // Instance: u_cd_XGCD, Port: M_AXI_XGCD0

    // .AWID_M_AXI_XGCD0           (XGCD0_AWID),
    // .AWADDR_M_AXI_XGCD0         (XGCD0_AWADDR),
    // .AWLEN_M_AXI_XGCD0          (XGCD0_AWLEN),
    // .AWSIZE_M_AXI_XGCD0         (XGCD0_AWSIZE),
    // .AWBURST_M_AXI_XGCD0        (XGCD0_AWBURST),
    // .AWLOCK_M_AXI_XGCD0         (XGCD0_AWLOCK),
    // .AWCACHE_M_AXI_XGCD0        (XGCD0_AWCACHE),
    // .AWPROT_M_AXI_XGCD0         (XGCD0_AWPROT),
    // .AWVALID_M_AXI_XGCD0        (XGCD0_AWVALID),
    // .AWREADY_M_AXI_XGCD0        (XGCD0_AWREADY),
    // .WDATA_M_AXI_XGCD0          (XGCD0_WDATA),
    // .WSTRB_M_AXI_XGCD0          (XGCD0_WSTRB),
    // .WLAST_M_AXI_XGCD0          (XGCD0_WLAST),
    // .WVALID_M_AXI_XGCD0         (XGCD0_WVALID),
    // .WREADY_M_AXI_XGCD0         (XGCD0_WREADY),
    // .BID_M_AXI_XGCD0            (XGCD0_BID),
    // .BRESP_M_AXI_XGCD0          (XGCD0_BRESP),
    // .BVALID_M_AXI_XGCD0         (XGCD0_BVALID),
    // .BREADY_M_AXI_XGCD0         (XGCD0_BREADY),
    // .ARID_M_AXI_XGCD0           (XGCD0_ARID),
    // .ARADDR_M_AXI_XGCD0         (XGCD0_ARADDR),
    // .ARLEN_M_AXI_XGCD0          (XGCD0_ARLEN),
    // .ARSIZE_M_AXI_XGCD0         (XGCD0_ARSIZE),
    // .ARBURST_M_AXI_XGCD0        (XGCD0_ARBURST),
    // .ARLOCK_M_AXI_XGCD0         (XGCD0_ARLOCK),
    // .ARCACHE_M_AXI_XGCD0        (XGCD0_ARCACHE),
    // .ARPROT_M_AXI_XGCD0         (XGCD0_ARPROT),
    // .ARVALID_M_AXI_XGCD0        (XGCD0_ARVALID),
    // .ARREADY_M_AXI_XGCD0        (XGCD0_ARREADY),
    // .RID_M_AXI_XGCD0            (XGCD0_RID),
    // .RDATA_M_AXI_XGCD0          (XGCD0_RDATA),
    // .RRESP_M_AXI_XGCD0          (XGCD0_RRESP),
    // .RLAST_M_AXI_XGCD0          (XGCD0_RLAST),
    // .RVALID_M_AXI_XGCD0         (XGCD0_RVALID),
    // .RREADY_M_AXI_XGCD0         (XGCD0_RREADY),

    // Instance: u_cd_XGCD, Port: M_AXI_XGCD1

    // .AWID_M_AXI_XGCD1           (XGCD1_AWID),
    // .AWADDR_M_AXI_XGCD1         (XGCD1_AWADDR),
    // .AWLEN_M_AXI_XGCD1          (XGCD1_AWLEN),
    // .AWSIZE_M_AXI_XGCD1         (XGCD1_AWSIZE),
    // .AWBURST_M_AXI_XGCD1        (XGCD1_AWBURST),
    // .AWLOCK_M_AXI_XGCD1         (XGCD1_AWLOCK),
    // .AWCACHE_M_AXI_XGCD1        (XGCD1_AWCACHE),
    // .AWPROT_M_AXI_XGCD1         (XGCD1_AWPROT),
    // .AWVALID_M_AXI_XGCD1        (XGCD1_AWVALID),
    // .AWREADY_M_AXI_XGCD1        (XGCD1_AWREADY),
    // .WDATA_M_AXI_XGCD1          (XGCD1_WDATA),
    // .WSTRB_M_AXI_XGCD1          (XGCD1_WSTRB),
    // .WLAST_M_AXI_XGCD1          (XGCD1_WLAST),
    // .WVALID_M_AXI_XGCD1         (XGCD1_WVALID),
    // .WREADY_M_AXI_XGCD1         (XGCD1_WREADY),
    // .BID_M_AXI_XGCD1            (XGCD1_BID),
    // .BRESP_M_AXI_XGCD1          (XGCD1_BRESP),
    // .BVALID_M_AXI_XGCD1         (XGCD1_BVALID),
    // .BREADY_M_AXI_XGCD1         (XGCD1_BREADY),
    // .ARID_M_AXI_XGCD1           (XGCD1_ARID),
    // .ARADDR_M_AXI_XGCD1         (XGCD1_ARADDR),
    // .ARLEN_M_AXI_XGCD1          (XGCD1_ARLEN),
    // .ARSIZE_M_AXI_XGCD1         (XGCD1_ARSIZE),
    // .ARBURST_M_AXI_XGCD1        (XGCD1_ARBURST),
    // .ARLOCK_M_AXI_XGCD1         (XGCD1_ARLOCK),
    // .ARCACHE_M_AXI_XGCD1        (XGCD1_ARCACHE),
    // .ARPROT_M_AXI_XGCD1         (XGCD1_ARPROT),
    // .ARVALID_M_AXI_XGCD1        (XGCD1_ARVALID),
    // .ARREADY_M_AXI_XGCD1        (XGCD1_ARREADY),
    // .RID_M_AXI_XGCD1            (XGCD1_RID),
    // .RDATA_M_AXI_XGCD1          (XGCD1_RDATA),
    // .RRESP_M_AXI_XGCD1          (XGCD1_RRESP),
    // .RLAST_M_AXI_XGCD1          (XGCD1_RLAST),
    // .RVALID_M_AXI_XGCD1         (XGCD1_RVALID),
    // .RREADY_M_AXI_XGCD1         (XGCD1_RREADY),


    //  Non-bus signals

    .CGRAclk                    (CGRA_CLK),
    .CGRAresetn                 (CGRA_RESETn),
    .SYSTEMclk                  (NIC_CLK),
    .SYSTEMresetn               (NIC_RESETn),
    .TLXclk                     (TLX_CLK),
    .TLXresetn                  (TLX_RESETn)
    // .XGCDclk                    (XGCD_BUS_CLK),
    // .XGCDresetn                 (XGCD_RESETn)
    );

    // Instantiate CPU Integration
    AhaCM3CodeRegionIntegration u_cpu_integration (
        // Resets
        .CPU_PORESETn               (CPU_PORESETn),
        .CPU_SYSRESETn              (CPU_SYSRESETn),
        .DAP_RESETn                 (DAP_RESETn),
        .JTAG_TRSTn                 (JTAG_TRSTn),
        .JTAG_PORESETn              (JTAG_PORESETn),
        .TPIU_RESETn                (TPIU_RESETn),

        // Clocks
        .SYS_CLK                    (SYS_CLK),
        .CPU_CLK                    (CPU_CLK),
        .DAP_CLK                    (DAP_CLK),
        .JTAG_TCK                   (JTAG_TCK),
        .TPIU_TRACECLKIN            (TPIU_TRACECLKIN),

        // Clock-Related Signals
        .CPU_CLK_CHANGED            (CPU_CLK_CHANGED),

        // JTAG/DAP Interface
        .JTAG_TDI                   (JTAG_TDI),
        .JTAG_TMS                   (JTAG_TMS),
        .JTAG_TDO                   (JTAG_TDO),

        // TPIU
        .TPIU_TRACE_DATA            (TPIU_TRACE_DATA),
        .TPIU_TRACE_SWO             (TPIU_TRACE_SWO),
        .TPIU_TRACE_CLK             (TPIU_TRACE_CLK),

        // Reset and PWR Control
        .DBGPWRUPACK                (DBGPWRUPACK),
        .DBGRSTACK                  (DBGRSTACK),
        .DBGSYSPWRUPACK             (DBGSYSPWRUPACK),
        .SLEEPHOLDREQn              (SLEEPHOLDREQn),
        .PMU_WIC_EN_REQ             (PMU_WIC_EN_REQ),
        .PMU_WIC_EN_ACK             (PMU_WIC_EN_ACK),
        .PMU_WAKEUP                 (PMU_WAKEUP),
        .INT_REQ                    (INT_REQ),
        .DBGPWRUPREQ                (DBGPWRUPREQ),
        .DBGRSTREQ                  (DBGRSTREQ),
        .DBGSYSPWRUPREQ             (DBGSYSPWRUPREQ),
        .SLEEP                      (SLEEP),
        .SLEEPDEEP                  (SLEEPDEEP),
        .LOCKUP                     (LOCKUP),
        .SYSRESETREQ                (SYSRESETREQ),
        .SLEEPHOLDACKn              (SLEEPHOLDACKn),

        // System Bus
        .SYS_HREADY                 (cpu_hready),
        .SYS_HRDATA                 (cpu_hrdata),
        .SYS_HRESP                  (cpu_hresp),
        .SYS_HADDR                  (cpu_haddr),
        .SYS_HTRANS                 (cpu_htrans),
        .SYS_HSIZE                  (cpu_hsize),
        .SYS_HWRITE                 (cpu_hwrite),
        .SYS_HBURST                 (cpu_hburst),
        .SYS_HPROT                  (cpu_hprot),
        .SYS_HWDATA                 (cpu_hwdata),

        // Interrupts
        .TIMER0_INT                 (timer0_int),
        .TIMER1_INT                 (timer1_int),
        .UART0_TX_RX_INT            (uart0_rxint | uart0_txint),
        .UART1_TX_RX_INT            (uart1_rxint | uart1_txint),
        .UART0_TX_RX_O_INT          (uart0_rxovrint | uart0_txovrint),
        .UART1_TX_RX_O_INT          (uart1_rxovrint | uart1_txovrint),
        .DMA0_INT                   (dma0_int),
        .DMA1_INT                   (dma1_int),
        .CGRA_INT                   (CGRA_INT),
        .WDOG_INT                   (wdog_int),
        .TLX_INT                    (TLX_INT),
        // .XGCD0_INT                  (XGCD0_INT),
        // .XGCD1_INT                  (XGCD1_INT),

        // SysTick
        .SYS_TICK_NOT_10MS_MULT     (SYS_TICK_NOT_10MS_MULT),
        .SYS_TICK_CALIB             (SYS_TICK_CALIB)
    );

    assign cpu_hresp[1]             = 1'b0;

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
