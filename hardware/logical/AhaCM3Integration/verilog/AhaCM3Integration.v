//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: CORTEX-M3 Processor Integration for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 11, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 29, 2022  :
//      - Added IRQ synchronization for XGCD interrupts
//      - Added XGCD interrupts
//------------------------------------------------------------------------------

module AhaCM3Integration (
  // Resets
  input   wire            CPU_PORESETn,       // CPU Power on reset synchronized to CPU_CLK
  input   wire            CPU_SYSRESETn,      // CPU soft reset synchronized to CPU_CLK
  input   wire            DAP_RESETn,         // Debug system reset synchronized to DAP_CLK
  input   wire            JTAG_TRSTn,         // JTAG Reset synchronized to JTAG Test Clock
  input   wire            JTAG_PORESETn,      // JTAG Power on reset synchronized to JTAG_TCK
  input   wire            TPIU_RESETn,        // TPIU Reset

  // Clocks
  input   wire            SYS_CLK,            // CPU-domain free running clock
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
  output  wire            INT_REQ,            // An interrupt has been request
  output  wire            DBGPWRUPREQ,        // Debug Power Up Request
  output  wire            DBGRSTREQ,          // Debug Reset Request
  output  wire            DBGSYSPWRUPREQ,     // Debug Request to Power Up CPU
  output  wire            SLEEP,              // Indicates CPU is in sleep mode (dbg activity might still be on)
  output  wire            SLEEPDEEP,          // Indicates CPU is in deep sleep mode (dbg activity might still be on)
  output  wire            LOCKUP,             // Indicates CPU is locked up
  output  wire            SYSRESETREQ,        // Request CPU Reset
  output  wire            SLEEPHOLDACKn,      // Response to sleep extension request

  // Merged I/D-Code Bus
  input   wire            CODE_HREADY,        // CODE bus ready
  input   wire [31:0]     CODE_HRDATA,        // CODE bus read data
  input   wire  [1:0]     CODE_HRESP,         // CODE bus response
  output  wire [31:0]     CODE_HADDR,         // CODE bus address
  output  wire  [1:0]     CODE_HTRANS,        // CODE bus transfer type
  output  wire [ 2:0]     CODE_HSIZE,         // CODE bus transfer size
  output  wire            CODE_HWRITE,        // CODE bus write not read
  output  wire  [2:0]     CODE_HBURST,        // CODE bus burst length
  output  wire [31:0]     CODE_HWDATA,        // CODE bus write data

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
  input   wire            XGCD0_INT,
  input   wire            XGCD1_INT,

  // SysTick
  input   wire            SYS_TICK_NOT_10MS_MULT, // Does the sys-tick calibration value
                                              // provide exact multiple of 10ms from CPU_CLK?
  input   wire [23:0]     SYS_TICK_CALIB      // SysTick calibration value
);

  // ---------- Local Params --------------------------------------------------
  localparam  NUM_IRQ     = 13;
  localparam  TRACE_LVL   = 1;
  localparam  DEBUG_LVL   = 3;
  localparam  WIC_LINES   = NUM_IRQ + 3;

  // ---------- CortexM3 Wires ------------------------------------------------
  // ICode Bus
  wire          icode_hready;
  wire [31:0]   icode_hrdata;
  wire  [1:0]   icode_hresp;
  wire [31:0]   icode_haddr;
  wire  [1:0]   icode_htrans;
  wire  [2:0]   icode_hsize;
  wire  [2:0]   icode_hburst;

  // DCode Bus
  wire          dcode_hready;
  wire [31:0]   dcode_hrdata;
  wire  [1:0]   dcode_hresp;
  wire [31:0]   dcode_haddr;
  wire  [1:0]   dcode_htrans;
  wire  [2:0]   dcode_hsize;
  wire  [2:0]   dcode_hburst;
  wire [31:0]   dcode_hwdata;
  wire          dcode_hwrite;

  // DAP Bus
  wire          cpu_dap_psel;
  wire          cpu_dap_penable;
  wire          cpu_dap_pwrite;
  wire          cpu_dap_pabort;
  wire [31:0]   cpu_dap_paddr;
  wire [31:0]   cpu_dap_pwdata;
  wire          cpu_dap_pready;
  wire          cpu_dap_pslverr;
  wire [31:0]   cpu_dap_prdata;

  // ---------- DAP Wires -----------------------------------------------------
  wire [31:0]   dap_prdata;
  wire          dap_pready;
  wire          dap_pslverr;
  wire [31:0]   dap_paddr;
  wire          dap_pwrite;
  wire          dap_penable;
  wire          dap_pabort;
  wire          dap_psel;
  wire [31:0]   dap_pwdata;

  // ---------- External PPB Wires --------------------------------------------
  wire [31:0]   ppb_prdata;
  wire          ppb_pready;
  wire          ppb_pslverr;
  wire          ppb_psel;
  wire [19:2]   ppb_paddr;
  wire          ppb_penable;
  wire          ppb_pwrite;
  wire [31:0]   ppb_pwdata;

  // ---------- ROM Table ------------------------------------------------------
  wire          rom_tbl_psel;
  wire [31:0]   rom_tbl_prdata;

  // ---------- TPIU -----------------------------------------------------------
  wire          trace_enabled;
  wire          cpu_halted;
  wire [47:0]   cpu_tsvalueb;

  wire          cpu_atvalid;
  wire [6:0]    cpu_atiditm;
  wire [7:0]    cpu_atdata;
  wire          cpu_atready;

  wire          cpu_dwt_sync;

  wire          tpiu_actv;
  wire          tpiu_baud;
  wire          tpiu_psel;
  wire [31:0]   tpiu_prdata;

  // ---------- Interrupts -----------------------------------------------------
  wire          cpu_int_nmi; // Not synched to CPU_CLK
  wire [239:0]  cpu_int_isr; // Not synched to CPU_CLK

  // ---------- WIC ------------------------------------------------------------
  wire                  wic_load;
  wire                  wic_clear;
  wire [WIC_LINES-1:0]  wic_int;
  wire [WIC_LINES-1:0]  wic_mask;
  wire [WIC_LINES-1:0]  wic_pend;
  wire                  wic_ds_ack_n;
  wire                  wic_ds_req_n;
  wire [239:0]          wic_mask_isr;
  wire                  wic_mask_mon;
  wire                  wic_mask_nmi;
  wire                  wic_mask_rx_ev;

  // ===== CortexM3 Instantiation -- ARM IP
  CORTEXM3 #(
      .MPU_PRESENT        (1),
      .NUM_IRQ            (NUM_IRQ),
      .LVL_WIDTH          (3),
      .TRACE_LVL          (TRACE_LVL),
      .DEBUG_LVL          (DEBUG_LVL),
      .CLKGATE_PRESENT    (1),
      .RESET_ALL_REGS     (0),
      .OBSERVATION        (0),
      .WIC_PRESENT        (1),
      .WIC_LINES          (WIC_LINES), // NUM_IRQ + 3
      .BB_PRESENT         (1),
      .CONST_AHB_CTRL     (1)
    ) u_cortexm3 (
      // Clocks and Resets
      .PORESETn           (CPU_PORESETn),
      .SYSRESETn          (CPU_SYSRESETn),
      .FCLK               (CPU_CLK),
      .HCLK               (CPU_CLK),
      .DAPCLK             (DAP_CLK),

      .DAPRESETn          (DAP_RESETn),

      // ICode Bus
      .HREADYI            (icode_hready),
      .HRDATAI            (icode_hrdata),
      .HRESPI             (icode_hresp),
      .HADDRI             (icode_haddr),
      .HTRANSI            (icode_htrans),
      .HSIZEI             (icode_hsize),
      .HBURSTI            (icode_hburst),
      .HPROTI             (/*unused*/),
      .MEMATTRI           (/*unused*/),
      .BRCHSTAT           (/*unused*/),
      .IFLUSH             (1'b0),

      // DCode Bus
      .HREADYD            (dcode_hready),
      .HRDATAD            (dcode_hrdata),
      .HRESPD             (dcode_hresp),
      .EXRESPD            (1'b0),
      .HADDRD             (dcode_haddr),
      .HTRANSD            (dcode_htrans),
      .HMASTERD           (/*unused*/),
      .HSIZED             (dcode_hsize),
      .HBURSTD            (dcode_hburst),
      .HPROTD             (/*unused*/),
      .MEMATTRD           (/*unused*/),
      .EXREQD             (/*unused*/),
      .HWRITED            (dcode_hwrite),
      .HWDATAD            (dcode_hwdata),

      // System Bus
      .HREADYS            (SYS_HREADY),
      .HRDATAS            (SYS_HRDATA),
      .HRESPS             (SYS_HRESP),
      .EXRESPS            (1'b0),
      .HADDRS             (SYS_HADDR),
      .HTRANSS            (SYS_HTRANS),
      .HMASTERS           (/*unused*/),
      .HWRITES            (SYS_HWRITE),
      .HSIZES             (SYS_HSIZE),
      .HMASTLOCKS         (/*unused*/),
      .HWDATAS            (SYS_HWDATA),
      .HBURSTS            (SYS_HBURST),
      .HPROTS             (SYS_HPROT),
      .MEMATTRS           (/*unused*/),
      .EXREQS             (/*unused*/),

      // DAP
      .DAPCLKEN           (DBGPWRUPACK),
      .DAPEN              (DBGPWRUPACK),
      .DAPSEL             (cpu_dap_psel),
      .DAPENABLE          (cpu_dap_penable),
      .DAPWRITE           (cpu_dap_pwrite),
      .DAPABORT           (cpu_dap_pabort),
      .DAPADDR            (cpu_dap_paddr),
      .DAPWDATA           (cpu_dap_pwdata),
      .FIXMASTERTYPE      (1'b0),
      .DAPREADY           (cpu_dap_pready),
      .DAPSLVERR          (cpu_dap_pslverr),
      .DAPRDATA           (cpu_dap_prdata),

      // External PPB
      .PRDATA             (ppb_prdata),
      .PREADY             (ppb_pready),
      .PSLVERR            (ppb_pslverr),
      .PSEL               (ppb_psel),
      .PADDR31            (/*unused*/),
      .PADDR              (ppb_paddr),
      .PENABLE            (ppb_penable),
      .PWRITE             (ppb_pwrite),
      .PWDATA             (ppb_pwdata),

      // TPIU Interface
      .TPIUACTV           (tpiu_actv),
      .TPIUBAUD           (tpiu_baud),

      // Interrupts
      .INTISR             (cpu_int_isr),
      .INTNMI             (cpu_int_nmi),

      // WIC Interface
      .WICDSREQn          (wic_ds_req_n),
      .WICDSACKn          (wic_ds_ack_n),
      .WICLOAD            (wic_load),
      .WICCLEAR           (wic_clear),
      .WICMASKISR         (wic_mask_isr),
      .WICMASKMON         (wic_mask_mon),
      .WICMASKNMI         (wic_mask_nmi),
      .WICMASKRXEV        (wic_mask_rx_ev),

      // ATB Interface
      .ATREADY            (cpu_atready),
      .ATVALID            (cpu_atvalid),
      .AFREADY            (/*unused*/),
      .ATDATA             (cpu_atdata),

      // Events
      .RXEV               (1'b0), // No events in single-core config
      .TXEV               (/*unused*/),

      // Reset and Power Control
      .SYSRESETREQ        (SYSRESETREQ),
      .SLEEPHOLDREQn      (SLEEPHOLDREQn),
      .SLEEPHOLDACKn      (SLEEPHOLDACKn),
      .SLEEPING           (SLEEP),
      .SLEEPDEEP          (SLEEPDEEP),
      .LOCKUP             (LOCKUP),

      // Auxiliary Fault Status
      .AUXFAULT           ({32{1'b0}}),

      // Scan Test Interface
      .SE                 (1'b0), // no scans implemented
      .RSTBYPASS          (1'b0), // no scans implemented
      .CGBYPASS           (1'b0), // no scans implemented

      // SysTick
      .STCLK              (1'b1),
      .STCALIB            ({1'b1, SYS_TICK_NOT_10MS_MULT, SYS_TICK_CALIB}),

      // Configuration
      .BIGEND             (1'b0),
      .DNOTITRANS         (1'b1),
      .STKALIGNINIT       (1'b1),

      // Miscellaneous
      .PPBLOCK            ({6{1'b0}}),
      .VECTADDR           ({10{1'b0}}),
      .VECTADDREN         (1'b0),

      // Global Timestamp Interface
      .TSVALUEB           (cpu_tsvalueb),
      .TSCLKCHANGE        (CPU_CLK_CHANGED),

      // Logic Disable
      .MPUDISABLE         (1'b0),
      .DBGEN              (1'b1),

      // ETM Interface
      .ETMPWRUP           (1'b0),
      .ETMFIFOFULL        (1'b0),
      .ETMTRIGGER         (/*unused*/),
      .ETMTRIGINOTD       (/*unused*/),
      .ETMIVALID          (/*unused*/),
      .ETMISTALL          (/*unused*/),
      .ETMDVALID          (/*unused*/),
      .ETMFOLD            (/*unused*/),
      .ETMCANCEL          (/*unused*/),
      .ETMIA              (/*unused*/),
      .ETMICCFAIL         (/*unused*/),
      .ETMIBRANCH         (/*unused*/),
      .ETMIINDBR          (/*unused*/),
      .ETMISB             (/*unused*/),
      .ETMINTSTAT         (/*unused*/),
      .ETMINTNUM          (/*unused*/),
      .ETMFLUSH           (/*unused*/),
      .ETMFINDBR          (/*unused*/),
      .DSYNC              (cpu_dwt_sync),

      // Debug
      .EDBGRQ             (1'b0),
      .DBGRESTART         (1'b0),
      .DBGRESTARTED       (/*unused*/),

      // HTM Interface
      .HTMDHADDR          (/*unused*/),
      .HTMDHTRANS         (/*unused*/),
      .HTMDHSIZE          (/*unused*/),
      .HTMDHBURST         (/*unused*/),
      .HTMDHPROT          (/*unused*/),
      .HTMDHWDATA         (/*unused*/),
      .HTMDHWRITE         (/*unused*/),
      .HTMDHRDATA         (/*unused*/),
      .HTMDHREADY         (/*unused*/),
      .HTMDHRESP          (/*unused*/),

      // ITM Interface
      .ATIDITM            (cpu_atiditm),

      // Core Status
      .HALTED             (cpu_halted),
      .CURRPRI            (/*unused*/),
      .TRCENA             (trace_enabled),

      // Extended visibility signals
      .INTERNALSTATE      (/*unused*/)
    );

  // ===== ICode and DCode Mux
  cm3_code_mux u_cm3_code_mux (
    .HCLK               (CPU_CLK),
    .HRESETn            (CPU_SYSRESETn),

    .HADDRI             (icode_haddr),
    .HTRANSI            (icode_htrans),
    .HSIZEI             (icode_hsize),
    .HBURSTI            (icode_hburst),
    .HPROTI             ({4{1'b0}}),
    .HRDATAI            (icode_hrdata),
    .HREADYI            (icode_hready),
    .HRESPI             (icode_hresp),

    .HADDRD             (dcode_haddr),
    .HTRANSD            (dcode_htrans),
    .HSIZED             (dcode_hsize),
    .HBURSTD            (dcode_hburst),
    .HPROTD             ({4{1'b0}}),
    .HWDATAD            (dcode_hwdata),
    .HWRITED            (dcode_hwrite),
    .EXREQD             (1'b0),
    .HRDATAD            (dcode_hrdata),
    .HREADYD            (dcode_hready),
    .HRESPD             (dcode_hresp),
    .EXRESPD            (/*unused*/),

    .HRDATAC            (CODE_HRDATA),
    .HREADYC            (CODE_HREADY),
    .HRESPC             (CODE_HRESP),
    .EXRESPC            (1'b0),
    .HADDRC             (CODE_HADDR),
    .HWDATAC            (CODE_HWDATA),
    .HTRANSC            (CODE_HTRANS),
    .HWRITEC            (CODE_HWRITE),
    .HSIZEC             (CODE_HSIZE),
    .HBURSTC            (CODE_HBURST),
    .HPROTC             (/*unused*/),
    .EXREQC             (/*unused*/)
  );

  // ===== DAP Integration
  DAPSWJDP #(
      .DP_PRESENT(1),
      .JTAG_PRESENT(1),
      .RESET_ALL_REGS(0)
    ) u_dapswjdp (
      .nTRST            (JTAG_TRSTn),
      .nPOTRST          (JTAG_PORESETn),
      .SWCLKTCK         (JTAG_TCK),
      .SWDITMS          (JTAG_TMS),
      .TDI              (JTAG_TDI),
      .DAPRESETn        (DAP_RESETn),
      .DAPCLK           (DAP_CLK),
      .DAPCLKEN         (DBGPWRUPACK),
      .DAPRDATA         (dap_prdata),
      .DAPREADY         (dap_pready),
      .DAPSLVERR        (dap_pslverr),
      .nCDBGPWRDN       (1'b1),
      .CDBGPWRUPACK     (DBGPWRUPACK),
      .CSYSPWRUPACK     (DBGSYSPWRUPACK),
      .CDBGRSTACK       (DBGRSTACK),

      .SWDO             (/*unused*/), // JTAG only
      .SWDOEN           (/*unused*/),
      .TDO              (JTAG_TDO),
      .nTDOEN           (/*unused*/),
      .DAPADDR          (dap_paddr),
      .DAPWRITE         (dap_pwrite),
      .DAPENABLE        (dap_penable),
      .DAPABORT         (dap_pabort),
      .DAPSEL           (dap_psel),
      .DAPWDATA         (dap_pwdata),
      .CDBGPWRUPREQ     (DBGPWRUPREQ),
      .CSYSPWRUPREQ     (DBGSYSPWRUPREQ),
      .CDBGRSTREQ       (DBGRSTREQ),
      .JTAGNSW          (/*unused*/),
      .JTAGTOP          (/*unused*/)
    );

    // Connect CPU Dap bus (AHB AP) to DAP
    assign cpu_dap_penable  = dap_penable;
    assign cpu_dap_pwrite   = dap_pwrite;
    assign cpu_dap_paddr    = {{24{1'b0}}, dap_paddr[7:0]};
    assign cpu_dap_pabort   = dap_pabort;
    assign cpu_dap_pwdata   = dap_pwdata;
    assign cpu_dap_psel     = (dap_paddr[31:24] == 8'h00) && dap_psel;

    // Add default slave to DAP
    reg         int_dap_pready;
    reg         int_dap_pslverr;
    reg [31:0]  int_dap_prdata;
    always @(*) begin
      if(cpu_dap_psel) begin
        int_dap_pready  = cpu_dap_pready;
        int_dap_pslverr = cpu_dap_pslverr;
        int_dap_prdata  = cpu_dap_prdata;
      end else begin
        int_dap_pready  = 1'b1;
        int_dap_pslverr = 1'b0;
        int_dap_prdata  = {32{1'b0}};
      end
    end

    assign dap_pready   = int_dap_pready;
    assign dap_pslverr  = int_dap_pslverr;
    assign dap_prdata   = int_dap_prdata;

    // ===== External Private Peripheral Bus Integration
    // TPIU: @ 0xE0040000
    assign tpiu_psel = (ppb_paddr[19:12]==8'h40) & ppb_psel;
    // ROM Table: @ 0xE00FF000
    assign rom_tbl_psel = (ppb_paddr[19:12]==8'hFF) & ppb_psel;

    // PPB slave select
    reg [31:0] int_ppb_prdata;
    always @(*) begin
      casex ({rom_tbl_psel, tpiu_psel})
        2'b1x: int_ppb_prdata = rom_tbl_prdata;
        2'b01: int_ppb_prdata = tpiu_prdata;
        default: int_ppb_prdata = {32{1'b0}};
      endcase
    end

    assign ppb_prdata   = int_ppb_prdata;
    assign ppb_pslverr  = 1'b0;
    assign ppb_pready   = 1'b1;

    // ===== ROM Table Integration
    AhaRomTable u_rom_table (
       // Inputs
       .PCLK           (CPU_CLK),
       .PRESETn        (CPU_PORESETn),
       .PSEL           (rom_tbl_psel),
       .PENABLE        (ppb_penable),
       .PADDR          (ppb_paddr[11:2]),
       .PWRITE         (ppb_pwrite),
       // Outputs
       .PRDATA         (rom_tbl_prdata)
      );

    // ===== TPIU Integration
    cm3_tpiu #(
        .TRACE_LVL(TRACE_LVL),
        .CP_PRESENT(0)
      ) u_cm3_tpiu (
        .CLK                  (CPU_CLK),
        .CLKEN                (trace_enabled),
        .TRACECLKIN           (TPIU_TRACECLKIN),
        .RESETn               (CPU_PORESETn),
        .TRESETn              (TPIU_RESETn),

        .PWRITE               (ppb_pwrite),
        .PENABLE              (ppb_penable),
        .PSEL                 (tpiu_psel),
        .PADDR                (ppb_paddr[11:2]),
        .PWDATA               (ppb_pwdata[12:0]),
        .PRDATA               (tpiu_prdata),

        .ATVALID1S            (1'b0),
        .ATID1S               ({7{1'b0}}),
        .ATDATA1S             ({8{1'b0}}),
        .ATREADY1S            (/*unused*/),

        .ATVALID2S            (cpu_atvalid),
        .ATID2S               (cpu_atiditm),
        .ATDATA2S             (cpu_atdata),
        .ATREADY2S            (cpu_atready),

        .SYNCREQ              (cpu_dwt_sync),
        .MAXPORTSIZE          (2'b11),  // full size
        .TRIGGER              (1'b0), // no ETM

        .TRACECLK             (TPIU_TRACE_CLK),
        .TRACEDATA            (TPIU_TRACE_DATA),
        .TRACESWO             (TPIU_TRACE_SWO),
        .SWOACTIVE            (/*unused*/),
        .TPIUACTV             (tpiu_actv),
        .TPIUBAUD             (tpiu_baud)
      );

  // Trace Timestamp Generator
  AhaCounter #(.WIDTH(48)) u_counter(
    .CLK      (CPU_CLK),
    .RESETn   (CPU_SYSRESETn),
    .EN       (trace_enabled & ~cpu_halted),
    .Q        (cpu_tsvalueb)
  );

  // ===== Interrupts
  // Most interrupt sources are in synchronous clock domains:
  //    CGRA, TLX, and SYSTEM clocks are synchronous since they
  //    are derived from the same master clock.
  // XGCD clock is completely async to SYSTEM clock.

  wire   sync_XGCD0_INT;
  wire   sync_XGCD1_INT;

  AhaDataSync u_aha_data_sync_XGCD0_INT (
    .CLK        (SYS_CLK),
    .RESETn     (CPU_PORESETn),
    .D          (XGCD0_INT),
    .Q          (sync_XGCD0_INT)
  );

  AhaDataSync u_aha_data_sync_XGCD1_INT (
    .CLK        (SYS_CLK),
    .RESETn     (CPU_PORESETn),
    .D          (XGCD1_INT),
    .Q          (sync_XGCD1_INT)
  );

  assign cpu_int_isr[0]        = wic_pend[3]   | TIMER0_INT;
  assign cpu_int_isr[1]        = wic_pend[4]   | TIMER1_INT;
  assign cpu_int_isr[2]        = wic_pend[5]   | UART0_TX_RX_INT;
  assign cpu_int_isr[3]        = wic_pend[6]   | UART1_TX_RX_INT;
  assign cpu_int_isr[4]        = wic_pend[7]   | UART0_TX_RX_O_INT | UART1_TX_RX_O_INT;
  assign cpu_int_isr[5]        = wic_pend[8]   | DMA0_INT[0];
  assign cpu_int_isr[6]        = wic_pend[9]   | DMA0_INT[1];
  assign cpu_int_isr[7]        = wic_pend[10]  | DMA1_INT[0];
  assign cpu_int_isr[8]        = wic_pend[11]  | DMA1_INT[1];
  assign cpu_int_isr[9]        = wic_pend[12]  | CGRA_INT;
  assign cpu_int_isr[10]       = wic_pend[13]  | TLX_INT;
  assign cpu_int_isr[11]       = wic_pend[14]  | sync_XGCD0_INT;
  assign cpu_int_isr[12]       = wic_pend[15]  | sync_XGCD1_INT;
  assign cpu_int_isr[239:13]   = {(240-13){1'b0}};

  assign cpu_int_nmi           = WDOG_INT;

  // ===== WIC Integration
  cm3_wic #(.WIC_PRESENT(1), .WIC_LINES(WIC_LINES)) u_cm3_wic (
    .FCLK         (SYS_CLK),
    .RESETn       (CPU_SYSRESETn),

    .WICLOAD      (wic_load),
    .WICCLEAR     (wic_clear),
    .WICINT       (wic_int),
    .WICMASK      (wic_mask),
    .WICENREQ     (PMU_WIC_EN_REQ),
    .WICDSACKn    (wic_ds_ack_n),
    .WICSENSE     (/*unused*/),
    .WICPEND      (wic_pend),
    .WICDSREQn    (wic_ds_req_n),
    .WICENACK     (PMU_WIC_EN_ACK),
    .WAKEUP       (PMU_WAKEUP)
  );

  assign wic_int = {cpu_int_isr[(NUM_IRQ-1):0], 1'b0, cpu_int_nmi, 1'b0};
  assign wic_mask = { wic_mask_isr[(NUM_IRQ-1):0], wic_mask_mon,
                      wic_mask_nmi, wic_mask_rx_ev
                    };
  // used when SLEEP (not SLEEPDEEP) to wake up the processor
  assign INT_REQ = (| wic_int);

endmodule // AhaCM3Integration
