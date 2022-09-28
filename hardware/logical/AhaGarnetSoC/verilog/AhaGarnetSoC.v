//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TopLevel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 25, 2022
//      - Added CPU-only external reset (SYSRESETn)
//
//  - Aug 30, 2022
//      - Integrated XGCD
//------------------------------------------------------------------------------

module AhaGarnetSoC (
  // Resets
  input   wire            PORESETn,           // Global Power-on Reset
  input   wire            SYSRESETn,          // CPU-only Reset
  input   wire            DP_JTAG_TRSTn,      // Coresight JTAG Reset
  input   wire            CGRA_JTAG_TRSTn,    // CGRA JTAG Reset

  // Input Clocks
  input   wire            MASTER_CLK,         // Main Clock
  input   wire            ALT_MASTER_CLK,     // Alternate master clock
  input   wire            DP_JTAG_TCK,        // Coresight JTAG Clock
  input   wire            CGRA_JTAG_TCK,      // CGRA JTAG Clock
  input   wire            TPIU_TRACECLKIN,    // TPIU Interface Clock
  input   wire            XGCD_EXT_CLK,       // XGCD External Clock

  // SOC JTAG Interface
  input   wire            DP_JTAG_TDI,        // Coresight JTAG Data In Port
  input   wire            DP_JTAG_TMS,        // Coresight JTAG TMS Port
  output  wire            DP_JTAG_TDO,        // Coresight JTAG TDO Port

  // CGRA JTAG Interface
  input   wire            CGRA_JTAG_TDI,       // CGRA JTAG Data In Port
  input   wire            CGRA_JTAG_TMS,       // CGRA JTAG TMS Port
  output  wire            CGRA_JTAG_TDO,       // CGRA JTAG TDO Port

  // Trace
  output  wire            TPIU_TRACE_SWO,     // Trace Single Wire Output

  // UART
  input   wire            UART0_RXD,          // UART0 Rx Data
  output  wire            UART0_TXD,          // UART0 Tx Data
  input   wire            UART1_RXD,          // UART1 Rx Data
  output  wire            UART1_TXD,          // UART1 Tx Data

  // TLX FWD Channel
  output  wire            TLX_FWD_CLK,
  output  wire                                  TLX_FWD_PAYLOAD_TVALID,
  output  wire [(`TLX_FWD_DATA_LO_WIDTH-1):0]   TLX_FWD_PAYLOAD_TDATA_LO,
  output  wire [(39-`TLX_FWD_DATA_LO_WIDTH):0]  TLX_FWD_PAYLOAD_TDATA_HI,

  output  wire            TLX_FWD_FLOW_TVALID,
  output  wire [1:0]      TLX_FWD_FLOW_TDATA,

  // TLX REV Channel
  input   wire            TLX_REV_CLK,
  input   wire                                  TLX_REV_PAYLOAD_TVALID,
  input   wire [(`TLX_REV_DATA_LO_WIDTH-1):0]   TLX_REV_PAYLOAD_TDATA_LO,
  input   wire [(79-`TLX_REV_DATA_LO_WIDTH):0]  TLX_REV_PAYLOAD_TDATA_HI,

  input   wire            TLX_REV_FLOW_TVALID,
  input   wire [2:0]      TLX_REV_FLOW_TDATA,

  // Pad Strength Control
  output  wire [2:0]      OUT_PAD_DS_GRP0,
  output  wire [2:0]      OUT_PAD_DS_GRP1,
  output  wire [2:0]      OUT_PAD_DS_GRP2,
  output  wire [2:0]      OUT_PAD_DS_GRP3,
  output  wire [2:0]      OUT_PAD_DS_GRP4,
  output  wire [2:0]      OUT_PAD_DS_GRP5,
  output  wire [2:0]      OUT_PAD_DS_GRP6,
  output  wire [2:0]      OUT_PAD_DS_GRP7,

  // LoopBack Signal
  input   wire [3:0]      LOOP_BACK_SELECT,
  output  wire            LOOP_BACK,

  // XGCD
  input   wire [1:0]      XGCD_CLK_SELECT,
  output  wire            XGCD_DIV8_CLK,
  output  wire            XGCD0_START,
  output  wire            XGCD1_START,
  output  wire            XGCD0_DONE,
  output  wire            XGCD1_DONE
);

  // Synchronized Reset Wires
  wire            cpu_poreset_n;
  wire            cpu_sysreset_n;
  wire            dap_reset_n;
  wire            dp_jtag_trst_n;
  wire            dp_jtag_poreset_n;
  wire            cgra_jtag_trst_n;
  wire            cgra_jtag_poreset_n;
  wire            sram_reset_n;
  wire            tlx_reset_n;
  wire            tlx_rev_reset_n;
  wire            cgra_reset_n;
  wire            dma0_reset_n;
  wire            dma1_reset_n;
  wire            periph_reset_n;
  wire            timer0_reset_n;
  wire            timer1_reset_n;
  wire            uart0_reset_n;
  wire            uart1_reset_n;
  wire            wdog_reset_n;
  wire            nic_reset_n;
  wire            tpiu_reset_n;
  wire            xgcd_reset_n;

  // Generated Clocks Wires
  wire            sys_clk;
  wire            cpu_clk;
  wire            dap_clk;
  wire            sram_clk;
  wire            tlx_clk;
  wire            cgra_clk;
  wire            dma0_clk;
  wire            dma1_clk;
  wire            timer0_clk;
  wire            timer1_clk;
  wire            uart0_clk;
  wire            uart1_clk;
  wire            wdog_clk;
  wire            nic_clk;

  // Clock Qualifier Wires
  wire            timer0_clk_en;
  wire            timer1_clk_en;
  wire            uart0_clk_en;
  wire            uart1_clk_en;
  wire            wdog_clk_en;
  wire            dma0_clk_en;
  wire            dma1_clk_en;

  // SysTick Wires
  wire            cpu_clk_changed;
  wire            sys_tick_not_10ms_mult;
  wire [23:0]     sys_tick_calib;

  // Reset and Power Control Wires
  wire            dbgpwrupack;
  wire            dbgrstack;
  wire            dbgsyspwrupack;
  wire            sleepholdreq_n;
  wire            pmu_wic_en_req;
  wire            pmu_wic_en_ack;
  wire            pmu_wakeup;
  wire            int_req;
  wire            dbgpwrupreq;
  wire            dbgrstreq;
  wire            dbgsyspwrupreq;
  wire            sleep;
  wire            sleepdeep;
  wire            lockup;
  wire            sysresetreq;
  wire            sleepholdack_n;
  wire            wdog_reset_req;

  // CGRA Wires
  wire            cgra_int;

  wire [3 :0]     cgra_data_awid;
  wire [31:0]     cgra_data_awaddr;
  wire [7 :0]     cgra_data_awlen;
  wire [2 :0]     cgra_data_awsize;
  wire [1 :0]     cgra_data_awburst;
  wire            cgra_data_awlock;
  wire [3 :0]     cgra_data_awcache;
  wire [2 :0]     cgra_data_awprot;
  wire            cgra_data_awvalid;
  wire            cgra_data_awready;
  wire [63:0]     cgra_data_wdata;
  wire [7 :0]     cgra_data_wstrb;
  wire            cgra_data_wlast;
  wire            cgra_data_wvalid;
  wire            cgra_data_wready;
  wire [3 :0]     cgra_data_bid;
  wire [1 :0]     cgra_data_bresp;
  wire            cgra_data_bvalid;
  wire            cgra_data_bready;
  wire [3 :0]     cgra_data_arid;
  wire [31:0]     cgra_data_araddr;
  wire [7 :0]     cgra_data_arlen;
  wire [2 :0]     cgra_data_arsize;
  wire [1 :0]     cgra_data_arburst;
  wire            cgra_data_arlock;
  wire [3 :0]     cgra_data_arcache;
  wire [2 :0]     cgra_data_arprot;
  wire            cgra_data_arvalid;
  wire            cgra_data_arready;
  wire [3 :0]     cgra_data_rid;
  wire [63:0]     cgra_data_rdata;
  wire [1 :0]     cgra_data_rresp;
  wire            cgra_data_rlast;
  wire            cgra_data_rvalid;
  wire            cgra_data_rready;

  wire [3:0]      cgra_reg_awid;
  wire [31:0]     cgra_reg_awaddr;
  wire [7:0]      cgra_reg_awlen;
  wire [2:0]      cgra_reg_awsize;
  wire [1:0]      cgra_reg_awburst;
  wire            cgra_reg_awlock;
  wire [3:0]      cgra_reg_awcache;
  wire [2:0]      cgra_reg_awprot;
  wire            cgra_reg_awvalid;
  wire            cgra_reg_awready;
  wire [31:0]     cgra_reg_wdata;
  wire [3:0]      cgra_reg_wstrb;
  wire            cgra_reg_wlast;
  wire            cgra_reg_wvalid;
  wire            cgra_reg_wready;
  wire [3:0]      cgra_reg_bid;
  wire [1:0]      cgra_reg_bresp;
  wire            cgra_reg_bvalid;
  wire            cgra_reg_bready;
  wire [3:0]      cgra_reg_arid;
  wire [31:0]     cgra_reg_araddr;
  wire [7:0]      cgra_reg_arlen;
  wire [2:0]      cgra_reg_arsize;
  wire [1:0]      cgra_reg_arburst;
  wire            cgra_reg_arlock;
  wire [3:0]      cgra_reg_arcache;
  wire [2:0]      cgra_reg_arprot;
  wire            cgra_reg_arvalid;
  wire            cgra_reg_arready;
  wire [3:0]      cgra_reg_rid;
  wire [31:0]     cgra_reg_rdata;
  wire [1:0]      cgra_reg_rresp;
  wire            cgra_reg_rlast;
  wire            cgra_reg_rvalid;
  wire            cgra_reg_rready;

  // TLX Wires
  wire            tlx_int;
  wire [3:0]      tlx_awid;
  wire [31:0]     tlx_awaddr;
  wire [7:0]      tlx_awlen;
  wire [2:0]      tlx_awsize;
  wire [1:0]      tlx_awburst;
  wire            tlx_awlock;
  wire [3:0]      tlx_awcache;
  wire [2:0]      tlx_awprot;
  wire            tlx_awvalid;
  wire            tlx_awready;
  wire [63:0]     tlx_wdata;
  wire [7:0]      tlx_wstrb;
  wire            tlx_wlast;
  wire            tlx_wvalid;
  wire            tlx_wready;
  wire [3:0]      tlx_bid;
  wire [1:0]      tlx_bresp;
  wire            tlx_bvalid;
  wire            tlx_bready;
  wire [3:0]      tlx_arid;
  wire [31:0]     tlx_araddr;
  wire [7:0]      tlx_arlen;
  wire [2:0]      tlx_arsize;
  wire [1:0]      tlx_arburst;
  wire            tlx_arlock;
  wire [3:0]      tlx_arcache;
  wire [2:0]      tlx_arprot;
  wire            tlx_arvalid;
  wire            tlx_arready;
  wire [3:0]      tlx_rid;
  wire [63:0]     tlx_rdata;
  wire [1:0]      tlx_rresp;
  wire            tlx_rlast;
  wire            tlx_rvalid;
  wire            tlx_rready;

  wire [31:0]     tlx_haddr;
  wire [2:0]      tlx_hburst;
  wire [3:0]      tlx_hprot;
  wire [2:0]      tlx_hsize;
  wire [1:0]      tlx_htrans;
  wire [31:0]     tlx_hwdata;
  wire            tlx_hwrite;
  wire [31:0]     tlx_hrdata;
  wire            tlx_hreadyout;
  wire            tlx_hresp;
  wire            tlx_hselx;
  wire            tlx_hready;

  // Platform Control Wires
  wire            pctrl_hsel;
  wire [31:0]     pctrl_haddr;
  wire  [1:0]     pctrl_htrans;
  wire            pctrl_hwrite;
  wire  [2:0]     pctrl_hsize;
  wire  [2:0]     pctrl_hburst;
  wire  [3:0]     pctrl_hprot;
  wire  [3:0]     pctrl_hmaster;
  wire [31:0]     pctrl_hwdata;
  wire            pctrl_hmastlock;
  wire            pctrl_hreadymux;
  wire [31:0]     pctrl_hrdata;
  wire            pctrl_hreadyout;
  wire [1:0]      pctrl_hresp;

  // XGCD wires

  wire [3:0]      xgcd0_awid;
  wire [31:0]     xgcd0_awaddr;
  wire [7:0]      xgcd0_awlen;
  wire [2:0]      xgcd0_awsize;
  wire [1:0]      xgcd0_awburst;
  wire            xgcd0_awlock;
  wire [3:0]      xgcd0_awcache;
  wire [2:0]      xgcd0_awprot;
  wire            xgcd0_awvalid;
  wire            xgcd0_awready;
  wire [63:0]     xgcd0_wdata;
  wire [7:0]      xgcd0_wstrb;
  wire            xgcd0_wlast;
  wire            xgcd0_wvalid;
  wire            xgcd0_wready;
  wire [3:0]      xgcd0_bid;
  wire [1:0]      xgcd0_bresp;
  wire            xgcd0_bvalid;
  wire            xgcd0_bready;
  wire [3:0]      xgcd0_arid;
  wire [31:0]     xgcd0_araddr;
  wire [7:0]      xgcd0_arlen;
  wire [2:0]      xgcd0_arsize;
  wire [1:0]      xgcd0_arburst;
  wire            xgcd0_arlock;
  wire [3:0]      xgcd0_arcache;
  wire [2:0]      xgcd0_arprot;
  wire            xgcd0_arvalid;
  wire            xgcd0_arready;
  wire [3:0]      xgcd0_rid;
  wire [63:0]     xgcd0_rdata;
  wire [1:0]      xgcd0_rresp;
  wire            xgcd0_rlast;
  wire            xgcd0_rvalid;
  wire            xgcd0_rready;

  wire [3:0]      xgcd1_awid;
  wire [31:0]     xgcd1_awaddr;
  wire [7:0]      xgcd1_awlen;
  wire [2:0]      xgcd1_awsize;
  wire [1:0]      xgcd1_awburst;
  wire            xgcd1_awlock;
  wire [3:0]      xgcd1_awcache;
  wire [2:0]      xgcd1_awprot;
  wire            xgcd1_awvalid;
  wire            xgcd1_awready;
  wire [63:0]     xgcd1_wdata;
  wire [7:0]      xgcd1_wstrb;
  wire            xgcd1_wlast;
  wire            xgcd1_wvalid;
  wire            xgcd1_wready;
  wire [3:0]      xgcd1_bid;
  wire [1:0]      xgcd1_bresp;
  wire            xgcd1_bvalid;
  wire            xgcd1_bready;
  wire [3:0]      xgcd1_arid;
  wire [31:0]     xgcd1_araddr;
  wire [7:0]      xgcd1_arlen;
  wire [2:0]      xgcd1_arsize;
  wire [1:0]      xgcd1_arburst;
  wire            xgcd1_arlock;
  wire [3:0]      xgcd1_arcache;
  wire [2:0]      xgcd1_arprot;
  wire            xgcd1_arvalid;
  wire            xgcd1_arready;
  wire [3:0]      xgcd1_rid;
  wire [63:0]     xgcd1_rdata;
  wire [1:0]      xgcd1_rresp;
  wire            xgcd1_rlast;
  wire            xgcd1_rvalid;
  wire            xgcd1_rready;

  wire [31:0]     xgcd_haddr;
  wire [2:0]      xgcd_hburst;
  wire [3:0]      xgcd_hprot;
  wire [2:0]      xgcd_hsize;
  wire [1:0]      xgcd_htrans;
  wire [31:0]     xgcd_hwdata;
  wire            xgcd_hwrite;
  wire [31:0]     xgcd_hrdata;
  wire            xgcd_hreadyout;
  wire            xgcd_hresp;
  wire            xgcd_hselx;
  wire            xgcd_hready;

  wire            xgcd0_int;
  wire            xgcd1_int;


  //------------------------------------------------------------------------------
  // Instantiate Partial SoC Integration
  //------------------------------------------------------------------------------
  AhaSoCPartialIntegration u_aha_soc_partial (
    // Resets
    .CPU_PORESETn                 (cpu_poreset_n),
    .CPU_SYSRESETn                (cpu_sysreset_n),
    .DAP_RESETn                   (dap_reset_n),
    .JTAG_TRSTn                   (dp_jtag_trst_n),
    .JTAG_PORESETn                (dp_jtag_poreset_n),
    .SRAM_RESETn                  (sram_reset_n),
    .TLX_RESETn                   (tlx_reset_n),
    .CGRA_RESETn                  (cgra_reset_n),
    .DMA0_RESETn                  (dma0_reset_n),
    .DMA1_RESETn                  (dma1_reset_n),
    .PERIPH_RESETn                (periph_reset_n),
    .TIMER0_RESETn                (timer0_reset_n),
    .TIMER1_RESETn                (timer1_reset_n),
    .UART0_RESETn                 (uart0_reset_n),
    .UART1_RESETn                 (uart1_reset_n),
    .WDOG_RESETn                  (wdog_reset_n),
    .NIC_RESETn                   (nic_reset_n),
    .TPIU_RESETn                  (tpiu_reset_n),
    .XGCD_RESETn                  (xgcd_reset_n),

    // Clocks
    .SYS_CLK                      (sys_clk),
    .CPU_CLK                      (cpu_clk),
    .DAP_CLK                      (dap_clk),
    .JTAG_TCK                     (DP_JTAG_TCK),
    .SRAM_CLK                     (sram_clk),
    .TLX_CLK                      (tlx_clk),
    .CGRA_CLK                     (cgra_clk),
    .DMA0_CLK                     (dma0_clk),
    .DMA1_CLK                     (dma1_clk),
    .TIMER0_CLK                   (timer0_clk),
    .TIMER1_CLK                   (timer1_clk),
    .UART0_CLK                    (uart0_clk),
    .UART1_CLK                    (uart1_clk),
    .WDOG_CLK                     (wdog_clk),
    .NIC_CLK                      (nic_clk),
    .TPIU_TRACECLKIN              (TPIU_TRACECLKIN),
    .XGCD_BUS_CLK                 (XGCD_DIV8_CLK),

    // Clock Qualifier Signals
    .TIMER0_CLKEN                 (timer0_clk_en),
    .TIMER1_CLKEN                 (timer1_clk_en),
    .UART0_CLKEN                  (uart0_clk_en),
    .UART1_CLKEN                  (uart1_clk_en),
    .WDOG_CLKEN                   (wdog_clk_en),
    .DMA0_CLKEN                   (dma0_clk_en),
    .DMA1_CLKEN                   (dma1_clk_en),

    // JTAG/DAP Interface
    .JTAG_TDI                     (DP_JTAG_TDI),
    .JTAG_TMS                     (DP_JTAG_TMS),
    .JTAG_TDO                     (DP_JTAG_TDO),

    // Trace Interface
    .TPIU_TRACE_DATA              (/* unused */),
    .TPIU_TRACE_SWO               (TPIU_TRACE_SWO),
    .TPIU_TRACE_CLK               (/* unused */),

    // UART Interface
    .UART0_RXD                    (UART0_RXD),
    .UART0_TXD                    (UART0_TXD),
    .UART1_RXD                    (UART1_RXD),
    .UART1_TXD                    (UART1_TXD),

    // Reset and Power Control
    .DBGPWRUPACK                  (dbgpwrupack),
    .DBGRSTACK                    (dbgrstack),
    .DBGSYSPWRUPACK               (dbgsyspwrupack),
    .SLEEPHOLDREQn                (sleepholdreq_n),
    .PMU_WIC_EN_REQ               (pmu_wic_en_req),
    .PMU_WIC_EN_ACK               (pmu_wic_en_ack),
    .PMU_WAKEUP                   (pmu_wakeup),
    .INT_REQ                      (int_req),
    .DBGPWRUPREQ                  (dbgpwrupreq),
    .DBGRSTREQ                    (dbgrstreq),
    .DBGSYSPWRUPREQ               (dbgsyspwrupreq),
    .SLEEP                        (sleep),
    .SLEEPDEEP                    (sleepdeep),
    .LOCKUP                       (lockup),
    .SYSRESETREQ                  (sysresetreq),
    .SLEEPHOLDACKn                (sleepholdack_n),
    .WDOG_RESET_REQ               (wdog_reset_req),

    // SysTick
    .CPU_CLK_CHANGED              (cpu_clk_changed),
    .SYS_TICK_NOT_10MS_MULT       (sys_tick_not_10ms_mult),
    .SYS_TICK_CALIB               (sys_tick_calib),

    // CGRA
    .CGRA_INT                     (cgra_int),

    .CGRA_DATA_AWID               (cgra_data_awid),
    .CGRA_DATA_AWADDR             (cgra_data_awaddr),
    .CGRA_DATA_AWLEN              (cgra_data_awlen),
    .CGRA_DATA_AWSIZE             (cgra_data_awsize),
    .CGRA_DATA_AWBURST            (cgra_data_awburst),
    .CGRA_DATA_AWLOCK             (cgra_data_awlock),
    .CGRA_DATA_AWCACHE            (cgra_data_awcache),
    .CGRA_DATA_AWPROT             (cgra_data_awprot),
    .CGRA_DATA_AWVALID            (cgra_data_awvalid),
    .CGRA_DATA_AWREADY            (cgra_data_awready),
    .CGRA_DATA_WDATA              (cgra_data_wdata),
    .CGRA_DATA_WSTRB              (cgra_data_wstrb),
    .CGRA_DATA_WLAST              (cgra_data_wlast),
    .CGRA_DATA_WVALID             (cgra_data_wvalid),
    .CGRA_DATA_WREADY             (cgra_data_wready),
    .CGRA_DATA_BID                (cgra_data_bid),
    .CGRA_DATA_BRESP              (cgra_data_bresp),
    .CGRA_DATA_BVALID             (cgra_data_bvalid),
    .CGRA_DATA_BREADY             (cgra_data_bready),
    .CGRA_DATA_ARID               (cgra_data_arid),
    .CGRA_DATA_ARADDR             (cgra_data_araddr),
    .CGRA_DATA_ARLEN              (cgra_data_arlen),
    .CGRA_DATA_ARSIZE             (cgra_data_arsize),
    .CGRA_DATA_ARBURST            (cgra_data_arburst),
    .CGRA_DATA_ARLOCK             (cgra_data_arlock),
    .CGRA_DATA_ARCACHE            (cgra_data_arcache),
    .CGRA_DATA_ARPROT             (cgra_data_arprot),
    .CGRA_DATA_ARVALID            (cgra_data_arvalid),
    .CGRA_DATA_ARREADY            (cgra_data_arready),
    .CGRA_DATA_RID                (cgra_data_rid),
    .CGRA_DATA_RDATA              (cgra_data_rdata),
    .CGRA_DATA_RRESP              (cgra_data_rresp),
    .CGRA_DATA_RLAST              (cgra_data_rlast),
    .CGRA_DATA_RVALID             (cgra_data_rvalid),
    .CGRA_DATA_RREADY             (cgra_data_rready),

    .CGRA_REG_AWID                (cgra_reg_awid),
    .CGRA_REG_AWADDR              (cgra_reg_awaddr),
    .CGRA_REG_AWLEN               (cgra_reg_awlen),
    .CGRA_REG_AWSIZE              (cgra_reg_awsize),
    .CGRA_REG_AWBURST             (cgra_reg_awburst),
    .CGRA_REG_AWLOCK              (cgra_reg_awlock),
    .CGRA_REG_AWCACHE             (cgra_reg_awcache),
    .CGRA_REG_AWPROT              (cgra_reg_awprot),
    .CGRA_REG_AWVALID             (cgra_reg_awvalid),
    .CGRA_REG_AWREADY             (cgra_reg_awready),
    .CGRA_REG_WDATA               (cgra_reg_wdata),
    .CGRA_REG_WSTRB               (cgra_reg_wstrb),
    .CGRA_REG_WLAST               (cgra_reg_wlast),
    .CGRA_REG_WVALID              (cgra_reg_wvalid),
    .CGRA_REG_WREADY              (cgra_reg_wready),
    .CGRA_REG_BID                 (cgra_reg_bid),
    .CGRA_REG_BRESP               (cgra_reg_bresp),
    .CGRA_REG_BVALID              (cgra_reg_bvalid),
    .CGRA_REG_BREADY              (cgra_reg_bready),
    .CGRA_REG_ARID                (cgra_reg_arid),
    .CGRA_REG_ARADDR              (cgra_reg_araddr),
    .CGRA_REG_ARLEN               (cgra_reg_arlen),
    .CGRA_REG_ARSIZE              (cgra_reg_arsize),
    .CGRA_REG_ARBURST             (cgra_reg_arburst),
    .CGRA_REG_ARLOCK              (cgra_reg_arlock),
    .CGRA_REG_ARCACHE             (cgra_reg_arcache),
    .CGRA_REG_ARPROT              (cgra_reg_arprot),
    .CGRA_REG_ARVALID             (cgra_reg_arvalid),
    .CGRA_REG_ARREADY             (cgra_reg_arready),
    .CGRA_REG_RID                 (cgra_reg_rid),
    .CGRA_REG_RDATA               (cgra_reg_rdata),
    .CGRA_REG_RRESP               (cgra_reg_rresp),
    .CGRA_REG_RLAST               (cgra_reg_rlast),
    .CGRA_REG_RVALID              (cgra_reg_rvalid),
    .CGRA_REG_RREADY              (cgra_reg_rready),

    // TLX
    .TLX_INT                      (tlx_int),

    .TLX_AWID                     (tlx_awid),
    .TLX_AWADDR                   (tlx_awaddr),
    .TLX_AWLEN                    (tlx_awlen),
    .TLX_AWSIZE                   (tlx_awsize),
    .TLX_AWBURST                  (tlx_awburst),
    .TLX_AWLOCK                   (tlx_awlock),
    .TLX_AWCACHE                  (tlx_awcache),
    .TLX_AWPROT                   (tlx_awprot),
    .TLX_AWVALID                  (tlx_awvalid),
    .TLX_AWREADY                  (tlx_awready),
    .TLX_WDATA                    (tlx_wdata),
    .TLX_WSTRB                    (tlx_wstrb),
    .TLX_WLAST                    (tlx_wlast),
    .TLX_WVALID                   (tlx_wvalid),
    .TLX_WREADY                   (tlx_wready),
    .TLX_BID                      (tlx_bid),
    .TLX_BRESP                    (tlx_bresp),
    .TLX_BVALID                   (tlx_bvalid),
    .TLX_BREADY                   (tlx_bready),
    .TLX_ARID                     (tlx_arid),
    .TLX_ARADDR                   (tlx_araddr),
    .TLX_ARLEN                    (tlx_arlen),
    .TLX_ARSIZE                   (tlx_arsize),
    .TLX_ARBURST                  (tlx_arburst),
    .TLX_ARLOCK                   (tlx_arlock),
    .TLX_ARCACHE                  (tlx_arcache),
    .TLX_ARPROT                   (tlx_arprot),
    .TLX_ARVALID                  (tlx_arvalid),
    .TLX_ARREADY                  (tlx_arready),
    .TLX_RID                      (tlx_rid),
    .TLX_RDATA                    (tlx_rdata),
    .TLX_RRESP                    (tlx_rresp),
    .TLX_RLAST                    (tlx_rlast),
    .TLX_RVALID                   (tlx_rvalid),
    .TLX_RREADY                   (tlx_rready),

    .TLX_HADDR                    (tlx_haddr),
    .TLX_HBURST                   (tlx_hburst),
    .TLX_HPROT                    (tlx_hprot),
    .TLX_HSIZE                    (tlx_hsize),
    .TLX_HTRANS                   (tlx_htrans),
    .TLX_HWDATA                   (tlx_hwdata),
    .TLX_HWRITE                   (tlx_hwrite),
    .TLX_HRDATA                   (tlx_hrdata),
    .TLX_HREADYOUT                (tlx_hreadyout),
    .TLX_HRESP                    (tlx_hresp),
    .TLX_HSELx                    (tlx_hselx),
    .TLX_HREADY                   (tlx_hready),

    // XGCD
    .XGCD0_AWID                   (xgcd0_awid),
    .XGCD0_AWADDR                 (xgcd0_awaddr),
    .XGCD0_AWLEN                  (xgcd0_awlen),
    .XGCD0_AWSIZE                 (xgcd0_awsize),
    .XGCD0_AWBURST                (xgcd0_awburst),
    .XGCD0_AWLOCK                 (xgcd0_awlock),
    .XGCD0_AWCACHE                (xgcd0_awcache),
    .XGCD0_AWPROT                 (xgcd0_awprot),
    .XGCD0_AWVALID                (xgcd0_awvalid),
    .XGCD0_AWREADY                (xgcd0_awready),
    .XGCD0_WDATA                  (xgcd0_wdata),
    .XGCD0_WSTRB                  (xgcd0_wstrb),
    .XGCD0_WLAST                  (xgcd0_wlast),
    .XGCD0_WVALID                 (xgcd0_wvalid),
    .XGCD0_WREADY                 (xgcd0_wready),
    .XGCD0_BID                    (xgcd0_bid),
    .XGCD0_BRESP                  (xgcd0_bresp),
    .XGCD0_BVALID                 (xgcd0_bvalid),
    .XGCD0_BREADY                 (xgcd0_bready),
    .XGCD0_ARID                   (xgcd0_arid),
    .XGCD0_ARADDR                 (xgcd0_araddr),
    .XGCD0_ARLEN                  (xgcd0_arlen),
    .XGCD0_ARSIZE                 (xgcd0_arsize),
    .XGCD0_ARBURST                (xgcd0_arburst),
    .XGCD0_ARLOCK                 (xgcd0_arlock),
    .XGCD0_ARCACHE                (xgcd0_arcache),
    .XGCD0_ARPROT                 (xgcd0_arprot),
    .XGCD0_ARVALID                (xgcd0_arvalid),
    .XGCD0_ARREADY                (xgcd0_arready),
    .XGCD0_RID                    (xgcd0_rid),
    .XGCD0_RDATA                  (xgcd0_rdata),
    .XGCD0_RRESP                  (xgcd0_rresp),
    .XGCD0_RLAST                  (xgcd0_rlast),
    .XGCD0_RVALID                 (xgcd0_rvalid),
    .XGCD0_RREADY                 (xgcd0_rready),

    .XGCD1_AWID                   (xgcd1_awid),
    .XGCD1_AWADDR                 (xgcd1_awaddr),
    .XGCD1_AWLEN                  (xgcd1_awlen),
    .XGCD1_AWSIZE                 (xgcd1_awsize),
    .XGCD1_AWBURST                (xgcd1_awburst),
    .XGCD1_AWLOCK                 (xgcd1_awlock),
    .XGCD1_AWCACHE                (xgcd1_awcache),
    .XGCD1_AWPROT                 (xgcd1_awprot),
    .XGCD1_AWVALID                (xgcd1_awvalid),
    .XGCD1_AWREADY                (xgcd1_awready),
    .XGCD1_WDATA                  (xgcd1_wdata),
    .XGCD1_WSTRB                  (xgcd1_wstrb),
    .XGCD1_WLAST                  (xgcd1_wlast),
    .XGCD1_WVALID                 (xgcd1_wvalid),
    .XGCD1_WREADY                 (xgcd1_wready),
    .XGCD1_BID                    (xgcd1_bid),
    .XGCD1_BRESP                  (xgcd1_bresp),
    .XGCD1_BVALID                 (xgcd1_bvalid),
    .XGCD1_BREADY                 (xgcd1_bready),
    .XGCD1_ARID                   (xgcd1_arid),
    .XGCD1_ARADDR                 (xgcd1_araddr),
    .XGCD1_ARLEN                  (xgcd1_arlen),
    .XGCD1_ARSIZE                 (xgcd1_arsize),
    .XGCD1_ARBURST                (xgcd1_arburst),
    .XGCD1_ARLOCK                 (xgcd1_arlock),
    .XGCD1_ARCACHE                (xgcd1_arcache),
    .XGCD1_ARPROT                 (xgcd1_arprot),
    .XGCD1_ARVALID                (xgcd1_arvalid),
    .XGCD1_ARREADY                (xgcd1_arready),
    .XGCD1_RID                    (xgcd1_rid),
    .XGCD1_RDATA                  (xgcd1_rdata),
    .XGCD1_RRESP                  (xgcd1_rresp),
    .XGCD1_RLAST                  (xgcd1_rlast),
    .XGCD1_RVALID                 (xgcd1_rvalid),
    .XGCD1_RREADY                 (xgcd1_rready),

    .XGCD_HADDR                   (xgcd_haddr),
    .XGCD_HBURST                  (xgcd_hburst),
    .XGCD_HPROT                   (xgcd_hprot),
    .XGCD_HSIZE                   (xgcd_hsize),
    .XGCD_HTRANS                  (xgcd_htrans),
    .XGCD_HWDATA                  (xgcd_hwdata),
    .XGCD_HWRITE                  (xgcd_hwrite),
    .XGCD_HRDATA                  (xgcd_hrdata),
    .XGCD_HREADYOUT               (xgcd_hreadyout),
    .XGCD_HRESP                   (xgcd_hresp),
    .XGCD_HSELx                   (xgcd_hselx),
    .XGCD_HREADY                  (xgcd_hready),

    .XGCD0_INT                    (xgcd0_int),
    .XGCD1_INT                    (xgcd1_int),

    // Platform Controller
    .PCTRL_HSEL                   (pctrl_hsel),
    .PCTRL_HADDR                  (pctrl_haddr),
    .PCTRL_HTRANS                 (pctrl_htrans),
    .PCTRL_HWRITE                 (pctrl_hwrite),
    .PCTRL_HSIZE                  (pctrl_hsize),
    .PCTRL_HBURST                 (pctrl_hburst),
    .PCTRL_HPROT                  (pctrl_hprot),
    .PCTRL_HMASTER                (pctrl_hmaster),
    .PCTRL_HWDATA                 (pctrl_hwdata),
    .PCTRL_HMASTLOCK              (pctrl_hmastlock),
    .PCTRL_HREADYMUX              (pctrl_hreadymux),

    .PCTRL_HRDATA                 (pctrl_hrdata),
    .PCTRL_HREADYOUT              (pctrl_hreadyout),
    .PCTRL_HRESP                  (pctrl_hresp)
  );

  //------------------------------------------------------------------------------
  // Instantiate Garnet CGRA
  //------------------------------------------------------------------------------
  AhaGarnetIntegration u_aha_garnet (
    .CLK                          (cgra_clk),
    .RESETn                       (cgra_reset_n),

    .INTERRUPT                    (cgra_int),

    .JTAG_TCK                     (CGRA_JTAG_TCK),
    .JTAG_TDI                     (CGRA_JTAG_TDI),
    .JTAG_TDO                     (CGRA_JTAG_TDO),
    .JTAG_TMS                     (CGRA_JTAG_TMS),
    .JTAG_TRSTn                   (cgra_jtag_trst_n),

    .CGRA_DATA_AWID               (cgra_data_awid),
    .CGRA_DATA_AWADDR             (cgra_data_awaddr),
    .CGRA_DATA_AWLEN              (cgra_data_awlen),
    .CGRA_DATA_AWSIZE             (cgra_data_awsize),
    .CGRA_DATA_AWBURST            (cgra_data_awburst),
    .CGRA_DATA_AWLOCK             (cgra_data_awlock),
    .CGRA_DATA_AWCACHE            (cgra_data_awcache),
    .CGRA_DATA_AWPROT             (cgra_data_awprot),
    .CGRA_DATA_AWVALID            (cgra_data_awvalid),
    .CGRA_DATA_AWREADY            (cgra_data_awready),
    .CGRA_DATA_WDATA              (cgra_data_wdata),
    .CGRA_DATA_WSTRB              (cgra_data_wstrb),
    .CGRA_DATA_WLAST              (cgra_data_wlast),
    .CGRA_DATA_WVALID             (cgra_data_wvalid),
    .CGRA_DATA_WREADY             (cgra_data_wready),
    .CGRA_DATA_BID                (cgra_data_bid),
    .CGRA_DATA_BRESP              (cgra_data_bresp),
    .CGRA_DATA_BVALID             (cgra_data_bvalid),
    .CGRA_DATA_BREADY             (cgra_data_bready),
    .CGRA_DATA_ARID               (cgra_data_arid),
    .CGRA_DATA_ARADDR             (cgra_data_araddr),
    .CGRA_DATA_ARLEN              (cgra_data_arlen),
    .CGRA_DATA_ARSIZE             (cgra_data_arsize),
    .CGRA_DATA_ARBURST            (cgra_data_arburst),
    .CGRA_DATA_ARLOCK             (cgra_data_arlock),
    .CGRA_DATA_ARCACHE            (cgra_data_arcache),
    .CGRA_DATA_ARPROT             (cgra_data_arprot),
    .CGRA_DATA_ARVALID            (cgra_data_arvalid),
    .CGRA_DATA_ARREADY            (cgra_data_arready),
    .CGRA_DATA_RID                (cgra_data_rid),
    .CGRA_DATA_RDATA              (cgra_data_rdata),
    .CGRA_DATA_RRESP              (cgra_data_rresp),
    .CGRA_DATA_RLAST              (cgra_data_rlast),
    .CGRA_DATA_RVALID             (cgra_data_rvalid),
    .CGRA_DATA_RREADY             (cgra_data_rready),

    .CGRA_REG_AWID                (cgra_reg_awid),
    .CGRA_REG_AWADDR              (cgra_reg_awaddr),
    .CGRA_REG_AWLEN               (cgra_reg_awlen),
    .CGRA_REG_AWSIZE              (cgra_reg_awsize),
    .CGRA_REG_AWBURST             (cgra_reg_awburst),
    .CGRA_REG_AWLOCK              (cgra_reg_awlock),
    .CGRA_REG_AWCACHE             (cgra_reg_awcache),
    .CGRA_REG_AWPROT              (cgra_reg_awprot),
    .CGRA_REG_AWVALID             (cgra_reg_awvalid),
    .CGRA_REG_AWREADY             (cgra_reg_awready),
    .CGRA_REG_WDATA               (cgra_reg_wdata),
    .CGRA_REG_WSTRB               (cgra_reg_wstrb),
    .CGRA_REG_WLAST               (cgra_reg_wlast),
    .CGRA_REG_WVALID              (cgra_reg_wvalid),
    .CGRA_REG_WREADY              (cgra_reg_wready),
    .CGRA_REG_BID                 (cgra_reg_bid),
    .CGRA_REG_BRESP               (cgra_reg_bresp),
    .CGRA_REG_BVALID              (cgra_reg_bvalid),
    .CGRA_REG_BREADY              (cgra_reg_bready),
    .CGRA_REG_ARID                (cgra_reg_arid),
    .CGRA_REG_ARADDR              (cgra_reg_araddr),
    .CGRA_REG_ARLEN               (cgra_reg_arlen),
    .CGRA_REG_ARSIZE              (cgra_reg_arsize),
    .CGRA_REG_ARBURST             (cgra_reg_arburst),
    .CGRA_REG_ARLOCK              (cgra_reg_arlock),
    .CGRA_REG_ARCACHE             (cgra_reg_arcache),
    .CGRA_REG_ARPROT              (cgra_reg_arprot),
    .CGRA_REG_ARVALID             (cgra_reg_arvalid),
    .CGRA_REG_ARREADY             (cgra_reg_arready),
    .CGRA_REG_RID                 (cgra_reg_rid),
    .CGRA_REG_RDATA               (cgra_reg_rdata),
    .CGRA_REG_RRESP               (cgra_reg_rresp),
    .CGRA_REG_RLAST               (cgra_reg_rlast),
    .CGRA_REG_RVALID              (cgra_reg_rvalid),
    .CGRA_REG_RREADY              (cgra_reg_rready)
  );

  //------------------------------------------------------------------------------
  // Instantiate TLX
  //------------------------------------------------------------------------------
  wire [39:0]   tlx_fwd_payload_tdata;
  wire [79:0]   tlx_rev_payload_tdata;

  AhaTlxIntegration u_aha_tlx (
    // Clocks and Resets
    .TLX_SIB_CLK                  (tlx_clk),
    .TLX_SIB_RESETn               (tlx_reset_n),
    .TLX_REV_CLK                  (TLX_REV_CLK),
    .TLX_REV_RESETn               (tlx_rev_reset_n),

    // Interrupts
    .TLX_INT                      (tlx_int),

    // RegSpace
    .TLX_HADDR                    (tlx_haddr),
    .TLX_HBURST                   (tlx_hburst),
    .TLX_HPROT                    (tlx_hprot),
    .TLX_HSIZE                    (tlx_hsize),
    .TLX_HTRANS                   (tlx_htrans),
    .TLX_HWDATA                   (tlx_hwdata),
    .TLX_HWRITE                   (tlx_hwrite),
    .TLX_HRDATA                   (tlx_hrdata),
    .TLX_HREADYOUT                (tlx_hreadyout),
    .TLX_HRESP                    (tlx_hresp),
    .TLX_HSELx                    (tlx_hselx),
    .TLX_HREADY                   (tlx_hready),

    // Slave Interface Block Signals
    .TLX_AWID                     (tlx_awid),
    .TLX_AWADDR                   (tlx_awaddr),
    .TLX_AWLEN                    (tlx_awlen),
    .TLX_AWSIZE                   (tlx_awsize),
    .TLX_AWBURST                  (tlx_awburst),
    .TLX_AWLOCK                   (tlx_awlock),
    .TLX_AWCACHE                  (tlx_awcache),
    .TLX_AWPROT                   (tlx_awprot),
    .TLX_AWVALID                  (tlx_awvalid),
    .TLX_AWREADY                  (tlx_awready),
    .TLX_WDATA                    (tlx_wdata),
    .TLX_WSTRB                    (tlx_wstrb),
    .TLX_WLAST                    (tlx_wlast),
    .TLX_WVALID                   (tlx_wvalid),
    .TLX_WREADY                   (tlx_wready),
    .TLX_BID                      (tlx_bid),
    .TLX_BRESP                    (tlx_bresp),
    .TLX_BVALID                   (tlx_bvalid),
    .TLX_BREADY                   (tlx_bready),
    .TLX_ARID                     (tlx_arid),
    .TLX_ARADDR                   (tlx_araddr),
    .TLX_ARLEN                    (tlx_arlen),
    .TLX_ARSIZE                   (tlx_arsize),
    .TLX_ARBURST                  (tlx_arburst),
    .TLX_ARLOCK                   (tlx_arlock),
    .TLX_ARCACHE                  (tlx_arcache),
    .TLX_ARPROT                   (tlx_arprot),
    .TLX_ARVALID                  (tlx_arvalid),
    .TLX_ARREADY                  (tlx_arready),
    .TLX_RID                      (tlx_rid),
    .TLX_RDATA                    (tlx_rdata),
    .TLX_RRESP                    (tlx_rresp),
    .TLX_RLAST                    (tlx_rlast),
    .TLX_RVALID                   (tlx_rvalid),
    .TLX_RREADY                   (tlx_rready),

    // Forward Channel
    .TLX_FWD_PAYLOAD_TVALID       (TLX_FWD_PAYLOAD_TVALID),
    .TLX_FWD_PAYLOAD_TREADY       (1'b1),
    .TLX_FWD_PAYLOAD_TDATA        (tlx_fwd_payload_tdata),

    .TLX_FWD_FLOW_TVALID          (TLX_FWD_FLOW_TVALID),
    .TLX_FWD_FLOW_TREADY          (1'b1),
    .TLX_FWD_FLOW_TDATA           (TLX_FWD_FLOW_TDATA),

    // Reverse Channel
    .TLX_REV_PAYLOAD_TVALID       (TLX_REV_PAYLOAD_TVALID),
    .TLX_REV_PAYLOAD_TREADY       (/* unused */),
    .TLX_REV_PAYLOAD_TDATA        (tlx_rev_payload_tdata),

    .TLX_REV_FLOW_TVALID          (TLX_REV_FLOW_TVALID),
    .TLX_REV_FLOW_TREADY          (/* unused */),
    .TLX_REV_FLOW_TDATA           (TLX_REV_FLOW_TDATA)
  );

  assign TLX_FWD_CLK  = tlx_clk;

  assign TLX_FWD_PAYLOAD_TDATA_LO = tlx_fwd_payload_tdata[`TLX_FWD_DATA_LO_WIDTH-1:0];
  assign TLX_FWD_PAYLOAD_TDATA_HI = tlx_fwd_payload_tdata[39:`TLX_FWD_DATA_LO_WIDTH];

  assign tlx_rev_payload_tdata    = {TLX_REV_PAYLOAD_TDATA_HI, TLX_REV_PAYLOAD_TDATA_LO};

  //------------------------------------------------------------------------------
  // Instantiate XGCD
  //------------------------------------------------------------------------------
  AhaXGCDIntegration u_aha_xgcd_integration (
    .XGCD_EXT_CLK                   (XGCD_EXT_CLK),
    .XGCD_SOC_CLK                   (sys_clk),                 
    .XGCD_CLK_SELECT                (XGCD_CLK_SELECT),
    .PORESETn                       (PORESETn),
    .XGCD_DIV8_CLK                  (XGCD_DIV8_CLK),

    .XGCD_HADDR                     (xgcd_haddr),
    .XGCD_HBURST                    (xgcd_hburst),
    .XGCD_HPROT                     (xgcd_hprot),
    .XGCD_HSIZE                     (xgcd_hsize),
    .XGCD_HTRANS                    (xgcd_htrans),
    .XGCD_HWDATA                    (xgcd_hwdata),
    .XGCD_HWRITE                    (xgcd_hwrite),
    .XGCD_HRDATA                    (xgcd_hrdata),
    .XGCD_HREADYOUT                 (xgcd_hreadyout),
    .XGCD_HRESP                     (xgcd_hresp),
    .XGCD_HSELx                     (xgcd_hselx),
    .XGCD_HREADY                    (xgcd_hready),

    .XGCD0_AWID                     (xgcd0_awid),
    .XGCD0_AWADDR                   (xgcd0_awaddr),
    .XGCD0_AWLEN                    (xgcd0_awlen),
    .XGCD0_AWSIZE                   (xgcd0_awsize),
    .XGCD0_AWBURST                  (xgcd0_awburst),
    .XGCD0_AWLOCK                   (xgcd0_awlock),
    .XGCD0_AWCACHE                  (xgcd0_awcache),
    .XGCD0_AWPROT                   (xgcd0_awprot),
    .XGCD0_AWVALID                  (xgcd0_awvalid),
    .XGCD0_AWREADY                  (xgcd0_awready),
    .XGCD0_WDATA                    (xgcd0_wdata),
    .XGCD0_WSTRB                    (xgcd0_wstrb),
    .XGCD0_WLAST                    (xgcd0_wlast),
    .XGCD0_WVALID                   (xgcd0_wvalid),
    .XGCD0_WREADY                   (xgcd0_wready),
    .XGCD0_BID                      (xgcd0_bid),
    .XGCD0_BRESP                    (xgcd0_bresp),
    .XGCD0_BVALID                   (xgcd0_bvalid),
    .XGCD0_BREADY                   (xgcd0_bready),
    .XGCD0_ARID                     (xgcd0_arid),
    .XGCD0_ARADDR                   (xgcd0_araddr),
    .XGCD0_ARLEN                    (xgcd0_arlen),
    .XGCD0_ARSIZE                   (xgcd0_arsize),
    .XGCD0_ARBURST                  (xgcd0_arburst),
    .XGCD0_ARLOCK                   (xgcd0_arlock),
    .XGCD0_ARCACHE                  (xgcd0_arcache),
    .XGCD0_ARPROT                   (xgcd0_arprot),
    .XGCD0_ARVALID                  (xgcd0_arvalid),
    .XGCD0_ARREADY                  (xgcd0_arready),
    .XGCD0_RID                      (xgcd0_rid),
    .XGCD0_RDATA                    (xgcd0_rdata),
    .XGCD0_RRESP                    (xgcd0_rresp),
    .XGCD0_RLAST                    (xgcd0_rlast),
    .XGCD0_RVALID                   (xgcd0_rvalid),
    .XGCD0_RREADY                   (xgcd0_rready),

    .XGCD1_AWID                     (xgcd1_awid),
    .XGCD1_AWADDR                   (xgcd1_awaddr),
    .XGCD1_AWLEN                    (xgcd1_awlen),
    .XGCD1_AWSIZE                   (xgcd1_awsize),
    .XGCD1_AWBURST                  (xgcd1_awburst),
    .XGCD1_AWLOCK                   (xgcd1_awlock),
    .XGCD1_AWCACHE                  (xgcd1_awcache),
    .XGCD1_AWPROT                   (xgcd1_awprot),
    .XGCD1_AWVALID                  (xgcd1_awvalid),
    .XGCD1_AWREADY                  (xgcd1_awready),
    .XGCD1_WDATA                    (xgcd1_wdata),
    .XGCD1_WSTRB                    (xgcd1_wstrb),
    .XGCD1_WLAST                    (xgcd1_wlast),
    .XGCD1_WVALID                   (xgcd1_wvalid),
    .XGCD1_WREADY                   (xgcd1_wready),
    .XGCD1_BID                      (xgcd1_bid),
    .XGCD1_BRESP                    (xgcd1_bresp),
    .XGCD1_BVALID                   (xgcd1_bvalid),
    .XGCD1_BREADY                   (xgcd1_bready),
    .XGCD1_ARID                     (xgcd1_arid),
    .XGCD1_ARADDR                   (xgcd1_araddr),
    .XGCD1_ARLEN                    (xgcd1_arlen),
    .XGCD1_ARSIZE                   (xgcd1_arsize),
    .XGCD1_ARBURST                  (xgcd1_arburst),
    .XGCD1_ARLOCK                   (xgcd1_arlock),
    .XGCD1_ARCACHE                  (xgcd1_arcache),
    .XGCD1_ARPROT                   (xgcd1_arprot),
    .XGCD1_ARVALID                  (xgcd1_arvalid),
    .XGCD1_ARREADY                  (xgcd1_arready),
    .XGCD1_RID                      (xgcd1_rid),
    .XGCD1_RDATA                    (xgcd1_rdata),
    .XGCD1_RRESP                    (xgcd1_rresp),
    .XGCD1_RLAST                    (xgcd1_rlast),
    .XGCD1_RVALID                   (xgcd1_rvalid),
    .XGCD1_RREADY                   (xgcd1_rready),

    .XGCD0_INT                      (xgcd0_int),
    .XGCD1_INT                      (xgcd1_int),

    .XGCD0_START                    (XGCD0_START),
    .XGCD1_START                    (XGCD1_START),
    .XGCD0_DONE                     (XGCD0_DONE),
    .XGCD1_DONE                     (XGCD1_DONE)
  );

  //------------------------------------------------------------------------------
  // Instantiate Platform Controller
  //------------------------------------------------------------------------------
  AhaPlatformController u_aha_platform_ctrl (
    // Master Clocks and Resets
    .MASTER_CLK                   (MASTER_CLK),
    .ALT_MASTER_CLK               (ALT_MASTER_CLK),
    .PORESETn                     (PORESETn),
    .SYSRESETn                    (SYSRESETn),
    .DP_JTAG_TRSTn                (DP_JTAG_TRSTn),
    .CGRA_JTAG_TRSTn              (CGRA_JTAG_TRSTn),

    // JTAG Clocks
    .DP_JTAG_TCK                  (DP_JTAG_TCK),
    .CGRA_JTAG_TCK                (CGRA_JTAG_TCK),

    // TLX Reverse Channel Clock
    .TLX_REV_CLK                  (TLX_REV_CLK),

    // TPIU Input Clock
    .TPIU_TRACECLKIN              (TPIU_TRACECLKIN),

    // XGCD Bus Clock
    .XGCD_BUS_CLK                 (XGCD_DIV8_CLK),

    // Generated Clocks
    .SYS_CLK                      (sys_clk),
    .CPU_CLK                      (cpu_clk),
    .DAP_CLK                      (dap_clk),
    .SRAM_CLK                     (sram_clk),
    .TLX_CLK                      (tlx_clk),
    .CGRA_CLK                     (cgra_clk),
    .DMA0_CLK                     (dma0_clk),
    .DMA1_CLK                     (dma1_clk),
    .TIMER0_CLK                   (timer0_clk),
    .TIMER1_CLK                   (timer1_clk),
    .UART0_CLK                    (uart0_clk),
    .UART1_CLK                    (uart1_clk),
    .WDOG_CLK                     (wdog_clk),
    .NIC_CLK                      (nic_clk),

    // Synchronized Resets
    .CPU_PORESETn                 (cpu_poreset_n),
    .CPU_SYSRESETn                (cpu_sysreset_n),
    .DAP_RESETn                   (dap_reset_n),
    .DP_JTAG_RESETn               (dp_jtag_trst_n),
    .DP_JTAG_PORESETn             (dp_jtag_poreset_n),
    .CGRA_JTAG_RESETn             (cgra_jtag_trst_n),
    .SRAM_RESETn                  (sram_reset_n),
    .TLX_RESETn                   (tlx_reset_n),
    .TLX_REV_RESETn               (tlx_rev_reset_n),
    .CGRA_RESETn                  (cgra_reset_n),
    .DMA0_RESETn                  (dma0_reset_n),
    .DMA1_RESETn                  (dma1_reset_n),
    .PERIPH_RESETn                (periph_reset_n),
    .TIMER0_RESETn                (timer0_reset_n),
    .TIMER1_RESETn                (timer1_reset_n),
    .UART0_RESETn                 (uart0_reset_n),
    .UART1_RESETn                 (uart1_reset_n),
    .WDOG_RESETn                  (wdog_reset_n),
    .NIC_RESETn                   (nic_reset_n),
    .TPIU_RESETn                  (tpiu_reset_n),
    .XGCD_RESETn                  (xgcd_reset_n),

    // Peripheral Clock Qualifiers
    .TIMER0_CLKEN                 (timer0_clk_en),
    .TIMER1_CLKEN                 (timer1_clk_en),
    .UART0_CLKEN                  (uart0_clk_en),
    .UART1_CLKEN                  (uart1_clk_en),
    .WDOG_CLKEN                   (wdog_clk_en),
    .DMA0_CLKEN                   (dma0_clk_en),
    .DMA1_CLKEN                   (dma1_clk_en),

    // SysTick
    .CPU_CLK_CHANGED              (cpu_clk_changed),
    .SYS_TICK_NOT_10MS_MULT       (sys_tick_not_10ms_mult),
    .SYS_TICK_CALIB               (sys_tick_calib),

    // Control
    .DBGPWRUPACK                  (dbgpwrupack),
    .DBGRSTACK                    (dbgrstack),
    .DBGSYSPWRUPACK               (dbgsyspwrupack),
    .SLEEPHOLDREQn                (sleepholdreq_n),
    .PMU_WIC_EN_REQ               (pmu_wic_en_req),
    .PMU_WIC_EN_ACK               (pmu_wic_en_ack),
    .PMU_WAKEUP                   (pmu_wakeup),
    .INT_REQ                      (int_req),
    .DBGPWRUPREQ                  (dbgpwrupreq),
    .DBGRSTREQ                    (dbgrstreq),
    .DBGSYSPWRUPREQ               (dbgsyspwrupreq),
    .SLEEP                        (sleep),
    .SLEEPDEEP                    (sleepdeep),
    .LOCKUP                       (lockup),
    .SYSRESETREQ                  (sysresetreq),
    .SLEEPHOLDACKn                (sleepholdack_n),
    .WDOG_RESET_REQ               (wdog_reset_req),

    // Pad Strength Control
    .OUT_PAD_DS_GRP0              (OUT_PAD_DS_GRP0),
    .OUT_PAD_DS_GRP1              (OUT_PAD_DS_GRP1),
    .OUT_PAD_DS_GRP2              (OUT_PAD_DS_GRP2),
    .OUT_PAD_DS_GRP3              (OUT_PAD_DS_GRP3),
    .OUT_PAD_DS_GRP4              (OUT_PAD_DS_GRP4),
    .OUT_PAD_DS_GRP5              (OUT_PAD_DS_GRP5),
    .OUT_PAD_DS_GRP6              (OUT_PAD_DS_GRP6),
    .OUT_PAD_DS_GRP7              (OUT_PAD_DS_GRP7),

    // Platform Control Regspace
    .PCTRL_HSEL                   (pctrl_hsel),
    .PCTRL_HADDR                  (pctrl_haddr),
    .PCTRL_HTRANS                 (pctrl_htrans),
    .PCTRL_HWRITE                 (pctrl_hwrite),
    .PCTRL_HSIZE                  (pctrl_hsize),
    .PCTRL_HBURST                 (pctrl_hburst),
    .PCTRL_HPROT                  (pctrl_hprot),
    .PCTRL_HMASTER                (pctrl_hmaster),
    .PCTRL_HWDATA                 (pctrl_hwdata),
    .PCTRL_HMASTLOCK              (pctrl_hmastlock),
    .PCTRL_HREADYMUX              (pctrl_hreadymux),
    .PCTRL_HRDATA                 (pctrl_hrdata),
    .PCTRL_HREADYOUT              (pctrl_hreadyout),
    .PCTRL_HRESP                  (pctrl_hresp)
  );

  //------------------------------------------------------------------------------
  // Instantiate LoopBack Gen
  //------------------------------------------------------------------------------
  AhaLoopBackGen u_loop_back_gen (
    .SELECT                       (LOOP_BACK_SELECT),

    // Clocks
    .SYS_CLK                      (sys_clk),
    .CPU_CLK                      (cpu_clk),
    .DAP_CLK                      (dap_clk),
    .DP_JTAG_CLK                  (DP_JTAG_TCK),
    .UART0_CLK                    (uart0_clk),
    .SRAM_CLK                     (sram_clk),
    .NIC_CLK                      (nic_clk),

    // Debug Signals
    .DBG_PWR_UP_REQ               (dbgpwrupreq),
    .DBG_PWR_UP_ACK               (dbgpwrupack),

    .DBG_SYS_PWR_UP_REQ           (dbgsyspwrupreq),
    .DBG_SYS_PWR_UP_ACK           (dbgsyspwrupack),

    // Output
    .LOOP_BACK                    (LOOP_BACK)
  );

endmodule
