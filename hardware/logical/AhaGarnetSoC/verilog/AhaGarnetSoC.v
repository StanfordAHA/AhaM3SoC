//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA SoC TopLevel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaGarnetSoC (
  // Resets
  input   wire            PORESETn,           // Global Power-on Reset
  input   wire            SOC_JTAG_TRSTn,     // SOC JTAG Reset
  input   wire            CGRA_JTAG_TRSTn,    // SOC JTAG Reset

  // Clocks
  input   wire            MASTER_CLK,         // Main Clock
  input   wire            SOC_JTAG_TCK,       // SOC JTAG Clock
  input   wire            CGRA_JTAG_TCK,      // CGRA JTAG Clock

  // SOC JTAG Interface
  input   wire            SOC_JTAG_TDI,       // JTAG Data In Port
  input   wire            SOC_JTAG_TMS,       // JTAG TMS Port
  output  wire            SOC_JTAG_TDO,       // JTAG TDO Port

  // CGRA JTAG Interface
  input   wire            CGRA_JTAG_TDI,       // JTAG Data In Port
  input   wire            CGRA_JTAG_TMS,       // JTAG TMS Port
  output  wire            CGRA_JTAG_TDO,       // JTAG TDO Port

  // Trace
  output  wire  [3:0]     TPIU_TRACE_DATA,    // Trace Data
  output  wire            TPIU_TRACE_SWO,     // Trace Single Wire Output
  output  wire            TPIU_TRACE_CLK,     // Trace Output Clock

  // UART
  input   wire            UART0_RXD,          // UART0 Rx Data
  output  wire            UART0_TXD,          // UART0 Tx Data
  input   wire            UART1_RXD,          // UART1 Rx Data
  output  wire            UART1_TXD,          // UART1 Tx Data

  // TLX FWD Channel
  output  wire            TLX_FWD_CLK,
  output  wire                                  TLX_FWD_PAYLOAD_TVALID,
  input   wire                                  TLX_FWD_PAYLOAD_TREADY,
  output  wire [(`TLX_FWD_DATA_LO_WIDTH-1):0]   TLX_FWD_PAYLOAD_TDATA_LO,
  output  wire [(39-`TLX_FWD_DATA_LO_WIDTH):0]  TLX_FWD_PAYLOAD_TDATA_HI,

  output  wire            TLX_FWD_FLOW_TVALID,
  input   wire            TLX_FWD_FLOW_TREADY,
  output  wire [1:0]      TLX_FWD_FLOW_TDATA,

  // TLX REV Channel
  input   wire            TLX_REV_CLK,
  input   wire                                  TLX_REV_PAYLOAD_TVALID,
  output  wire                                  TLX_REV_PAYLOAD_TREADY,
  input   wire [(`TLX_REV_DATA_LO_WIDTH-1):0]   TLX_REV_PAYLOAD_TDATA_LO,
  input   wire [(79-`TLX_REV_DATA_LO_WIDTH):0]  TLX_REV_PAYLOAD_TDATA_HI,

  input   wire            TLX_REV_FLOW_TVALID,
  output  wire            TLX_REV_FLOW_TREADY,
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
  output  wire            LOOP_BACK
);

  // Synchronized Reset Wires
  wire            cpu_poreset_n;
  wire            cpu_sysreset_n;
  wire            dap_reset_n;
  wire            soc_jtag_trst_n;
  wire            soc_jtag_poreset_n;
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

  // Generated Clocks Wires
  wire            cpu_fclk;
  wire            cpu_gclk;
  wire            dap_clk;
  wire            sram_clk;
  wire            tlx_clk;
  wire            cgra_clk;
  wire            dma0_clk;
  wire            dma1_clk;
  wire            periph_clk;
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

  // ==== Instantiate Partial SoC Integration
  AhaSoCPartialIntegration u_partial_soc (
    // Resets
    .CPU_PORESETn                 (cpu_poreset_n),
    .CPU_SYSRESETn                (cpu_sysreset_n),
    .DAP_RESETn                   (dap_reset_n),
    .JTAG_TRSTn                   (soc_jtag_trst_n),
    .JTAG_PORESETn                (soc_jtag_poreset_n),
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

    // Clocks
    .CPU_FCLK                     (cpu_fclk),
    .CPU_GCLK                     (cpu_gclk),
    .DAP_CLK                      (dap_clk),
    .JTAG_TCK                     (SOC_JTAG_TCK),
    .SRAM_CLK                     (sram_clk),
    .TLX_CLK                      (tlx_clk),
    .CGRA_CLK                     (cgra_clk),
    .DMA0_CLK                     (dma0_clk),
    .DMA1_CLK                     (dma1_clk),
    .PERIPH_CLK                   (periph_clk),
    .TIMER0_CLK                   (timer0_clk),
    .TIMER1_CLK                   (timer1_clk),
    .UART0_CLK                    (uart0_clk),
    .UART1_CLK                    (uart1_clk),
    .WDOG_CLK                     (wdog_clk),
    .NIC_CLK                      (nic_clk),

    // Clock Qualifier Signals
    .TIMER0_CLKEN                 (timer0_clk_en),
    .TIMER1_CLKEN                 (timer1_clk_en),
    .UART0_CLKEN                  (uart0_clk_en),
    .UART1_CLKEN                  (uart1_clk_en),
    .WDOG_CLKEN                   (wdog_clk_en),
    .DMA0_CLKEN                   (dma0_clk_en),
    .DMA1_CLKEN                   (dma1_clk_en),

    // JTAG/DAP Interface
    .JTAG_TDI                     (SOC_JTAG_TDI),
    .JTAG_TMS                     (SOC_JTAG_TMS),
    .JTAG_TDO                     (SOC_JTAG_TDO),

    // Trace Interface
    .TPIU_TRACE_DATA              (TPIU_TRACE_DATA),
    .TPIU_TRACE_SWO               (TPIU_TRACE_SWO),
    .TPIU_TRACE_CLK               (TPIU_TRACE_CLK),

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
    .TLX_RREADY                   (tlx_rready)
  );

  // ==== Instantiate Garnet CGRA
  AhaGarnetIntegration u_garnet (
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

  // ==== Instantiate TLX
  wire [39:0]   tlx_fwd_payload_tdata;
  wire [79:0]   tlx_rev_payload_tdata;

  AhaTlxIntegration u_tlx (
    // Clocks and Resets
    .TLX_SIB_CLK                  (tlx_clk),
    .TLX_SIB_RESETn               (tlx_reset_n),
    .TLX_FWD_CLK                  (TLX_FWD_CLK),
    .TLX_REV_CLK                  (TLX_REV_CLK),
    .TLX_REV_RESETn               (tlx_rev_reset_n),

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
    .TLX_FWD_PAYLOAD_TREADY       (TLX_FWD_PAYLOAD_TREADY),
    .TLX_FWD_PAYLOAD_TDATA        (tlx_fwd_payload_tdata),

    .TLX_FWD_FLOW_TVALID          (TLX_FWD_FLOW_TVALID),
    .TLX_FWD_FLOW_TREADY          (TLX_FWD_FLOW_TREADY),
    .TLX_FWD_FLOW_TDATA           (TLX_FWD_FLOW_TDATA),

    // Reverse Channel
    .TLX_REV_PAYLOAD_TVALID       (TLX_REV_PAYLOAD_TVALID),
    .TLX_REV_PAYLOAD_TREADY       (TLX_REV_PAYLOAD_TREADY),
    .TLX_REV_PAYLOAD_TDATA        (tlx_rev_payload_tdata),

    .TLX_REV_FLOW_TVALID          (TLX_REV_FLOW_TVALID),
    .TLX_REV_FLOW_TREADY          (TLX_REV_FLOW_TREADY),
    .TLX_REV_FLOW_TDATA           (TLX_REV_FLOW_TDATA)
  );

  assign TLX_FWD_PAYLOAD_TDATA_LO = tlx_fwd_payload_tdata[`TLX_FWD_DATA_LO_WIDTH-1:0];
  assign TLX_FWD_PAYLOAD_TDATA_HI = tlx_fwd_payload_tdata[39:`TLX_FWD_DATA_LO_WIDTH];

  assign tlx_rev_payload_tdata    = {TLX_REV_PAYLOAD_TDATA_HI, TLX_REV_PAYLOAD_TDATA_LO};

  // ==== Instantiate Platform Controller
  AhaPlatformController u_platform_ctrl (
    // Master Clock and Power-On Reset
    .MASTER_CLK                   (MASTER_CLK),
    .PORESETn                     (PORESETn),
    .DP_JTAG_TRSTn                (SOC_JTAG_TRSTn),
    .CGRA_JTAG_TRSTn              (CGRA_JTAG_TRSTn),

    // JTAG Clocks
    .DP_JTAG_TCK                  (SOC_JTAG_TCK),
    .CGRA_JTAG_TCK                (CGRA_JTAG_TCK),

    // TLX Reverse Channel Clock
    .TLX_REV_CLK                  (TLX_REV_CLK),

    // Generated Clocks
    .CPU_FCLK                     (cpu_fclk),
    .CPU_GCLK                     (cpu_gclk),
    .DAP_CLK                      (dap_clk),
    .SRAM_CLK                     (sram_clk),
    .TLX_CLK                      (tlx_clk),
    .CGRA_CLK                     (cgra_clk),
    .DMA0_CLK                     (dma0_clk),
    .DMA1_CLK                     (dma1_clk),
    .PERIPH_CLK                   (periph_clk),
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
    .DP_JTAG_RESETn               (soc_jtag_trst_n),
    .DP_JTAG_PORESETn             (soc_jtag_poreset_n),
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

    // LoopBack
    .LOOP_BACK                    (LOOP_BACK)
  );

endmodule
