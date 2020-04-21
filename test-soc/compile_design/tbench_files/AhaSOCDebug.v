//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: CORTEX-M3 Processor Integration Debug Wrapper
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 12, 2020
//------------------------------------------------------------------------------
module AhaSOCDebug (
  // Resets
  input   wire            PORESETn,           // Global Power-on-reset
  input   wire            JTAG_TRSTn,         // JTAG Reset

  // Clocks
  input   wire            MASTER_CLK,           // main clock (fast clock)
  input   wire            JTAG_TCK,           // JTAG clock

  // JTAG Interface
  input   wire            JTAG_TDI,           // JTAG Data In Port
  input   wire            JTAG_TMS,           // JTAG TMS Port
  output  wire            JTAG_TDO           // JTAG TDO Port
);

  wire  cpu_poreset_n;
  wire  cpu_sysreset_n;
  wire  dbg_reset_n;
  wire  jtag_trst_n;
  wire  jtag_poreset_n;

  wire  dbg_pwrup_req;
  wire  dbg_rst_req;
  wire  dbg_syspwrup_req;
  wire  sysreset_req;

  // ===== AHA CortextM3
  AhaCM3CodeRegionIntegration u_aha_codereg_integration (
    // Resets
    .CPU_PORESETn         (cpu_poreset_n),
    .CPU_SYSRESETn        (cpu_sysreset_n),
    .DAP_RESETn           (dbg_reset_n),
    .JTAG_TRSTn           (jtag_trst_n),
    .JTAG_PORESETn        (jtag_poreset_n),

    // Clocks
    .CPU_FCLK             (MASTER_CLK),
    .CPU_GCLK             (MASTER_CLK),
    .DAP_CLK              (MASTER_CLK),
    .JTAG_TCK             (JTAG_TCK),

    // Clock-related
    .CPU_CLK_CHANGED      (1'b0),

    // JTAG
    .JTAG_TDI             (JTAG_TDI),
    .JTAG_TMS             (JTAG_TMS),
    .JTAG_TDO             (JTAG_TDO),

    // Trace
    .TPIU_TRACE_DATA      (/*unused*/),
    .TPIU_TRACE_SWO       (/*unused*/),
    .TPIU_TRACE_CLK       (/*unused*/),

    // Reset and PMU
    .DBGPWRUPACK          (dbg_pwrup_req),
    .DBGRSTACK            (dbg_rst_req),
    .DBGSYSPWRUPACK       (dbg_syspwrup_req),
    .SLEEPHOLDREQn        (1'b1),
    .PMU_WIC_EN_REQ       (1'b1),
    .PMU_WIC_EN_ACK       (/*unused*/),
    .PMU_WAKEUP           (/*unused*/),
    .DBGPWRUPREQ          (dbg_pwrup_req),
    .DBGRSTREQ            (dbg_rst_req),
    .DBGSYSPWRUPREQ       (dbg_syspwrup_req),
    .SLEEP                (/*unused*/),
    .SLEEPDEEP            (/*unused*/),
    .LOCKUP               (/*unused*/),
    .SYSRESETREQ          (sysreset_req),
    .SLEEPHOLDACKn        (/*unused*/),

    // CM3 Sys Bus
    .SYS_HREADY           (1'b1),
    .SYS_HRDATA           ({32{1'b0}}),
    .SYS_HRESP            (2'b00),
    .SYS_HADDR            (/*unused*/),
    .SYS_HTRANS           (/*unused*/),
    .SYS_HSIZE            (/*unused*/),
    .SYS_HWRITE           (/*unused*/),
    .SYS_HBURST           (/*unused*/),
    .SYS_HPROT            (/*unused*/),
    .SYS_HWDATA           (/*unused*/),

    // Interrupts
    .TIMER0_INT           (1'b0),
    .TIMER1_INT           (1'b0),
    .UART0_TX_RX_INT      (1'b0),
    .UART1_TX_RX_INT      (1'b0),
    .UART0_TX_RX_O_INT    (1'b0),
    .UART1_TX_RX_O_INT    (1'b0),
    .DMA0_INT             (2'b00),
    .DMA1_INT             (2'b00),
    .CGRA_INT             (1'b0),
    .WDOG_INT             (1'b0),

    // SysTick
    .SYS_TICK_CALIB       (24'h0F423F),
    .SYS_TICK_NOT_10MS_MULT   (1'b0)
  );

  // ===== PORESETn
  // CPU PORESETn
  reg cpu_poreset_n_q;
  reg cpu_poreset_n_qq;
  always @(posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      cpu_poreset_n_q   <= 1'b0;
      cpu_poreset_n_qq  <= 1'b0;
    end else begin
      cpu_poreset_n_q   <= 1'b1;
      cpu_poreset_n_qq  <= cpu_poreset_n_q;
    end
  end
  assign cpu_poreset_n  = cpu_poreset_n_qq;

  // JTAG PORESETn
  reg jtag_poreset_n_q;
  reg jtag_poreset_n_qq;
  always @(posedge JTAG_TCK or negedge PORESETn) begin
    if(~PORESETn) begin
      jtag_poreset_n_q   <= 1'b0;
      jtag_poreset_n_qq  <= 1'b0;
    end else begin
      jtag_poreset_n_q   <= 1'b1;
      jtag_poreset_n_qq  <= jtag_poreset_n_q;
    end
  end
  assign jtag_poreset_n  = jtag_poreset_n_qq;

  // JTAG RESETn
  reg jtag_trst_n_q;
  reg jtag_trst_n_qq;
  always @(posedge JTAG_TCK or negedge JTAG_TRSTn) begin
    if(~JTAG_TRSTn) begin
      jtag_trst_n_q   <= 1'b0;
      jtag_trst_n_qq  <= 1'b0;
    end else begin
      jtag_trst_n_q   <= 1'b1;
      jtag_trst_n_qq  <= jtag_trst_n_q;
    end
  end
  assign jtag_trst_n  = jtag_trst_n_qq;

  // CPU System Reset
  reg int_cpu_sysresetn_q;
  reg int_cpu_sysresetn_qq;
  always @ (posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      int_cpu_sysresetn_q     <= 1'b0;
      int_cpu_sysresetn_qq    <= 1'b0;
    end else begin
      int_cpu_sysresetn_q     <= ~sysreset_req;
      int_cpu_sysresetn_qq    <= int_cpu_sysresetn_q;
    end
  end
  assign cpu_sysreset_n = int_cpu_sysresetn_q & int_cpu_sysresetn_qq;

  // Debug Reset
  reg int_dbg_resetn_q;
  reg int_dbg_resetn_qq;
  always @ (posedge MASTER_CLK or negedge PORESETn) begin
    if(~PORESETn) begin
      int_dbg_resetn_q     <= 1'b0;
      int_dbg_resetn_qq    <= 1'b0;
    end else begin
      int_dbg_resetn_q     <= ~dbg_rst_req;
      int_dbg_resetn_qq    <= int_dbg_resetn_q;
    end
  end
  assign dbg_reset_n = int_dbg_resetn_q & int_dbg_resetn_qq;

endmodule
