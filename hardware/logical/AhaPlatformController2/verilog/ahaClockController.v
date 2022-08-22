//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose: Platform Clock Controller
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
// -----------------------------------------------------------------------------
// Updates  :
//  - Aug 22, 2022  :
//      - simplified peripheral clocking architecture
//      - added clock gate on TLX REV clock
//------------------------------------------------------------------------------
//
// In terms of frequency, there are 5 clock domains:
//  - System clock domain (CPU, DMAs, SRAMs, NIC400, and DAP)
//  - CGRA clock domain
//  - TLX FWD clock domain
//  - TLX REV clock domain
//  - Peripheral clock domain
//
// Note:
//  - Output free-running clocks can be used for external reset synchronization
//------------------------------------------------------------------------------

module AhaClockController (
    // Master Interface
    input   wire            MASTER_CLK,
    input   wire            PORESETn,

    // System Clock
    input   wire [2:0]      SYS_CLK_SELECT,
    output  wire            SYS_FCLK,

    // CPU Clock (Synchronous to SYS_FCLK)
    input   wire            CPU_CLK_GATE,
    output  wire            CPU_GCLK,

    // DAP Clock (Synchronous to SYS_FCLK)
    input   wire            DAP_CLK_GATE,
    output  wire            DAP_GCLK,

    // DMA0 Clock (Synchronous to SYS_FCLK)
    input   wire            DMA0_CLK_GATE,
    output  wire            DMA0_GCLK,

    // DMA1 Clock (Synchronous to SYS_FCLK)
    input   wire            DMA1_CLK_GATE,
    output  wire            DMA1_GCLK,

    // SRAM Clock (Synchronous to SYS_FCLK)
    input   wire            SRAM_CLK_GATE,
    output  wire            SRAM_GCLK,

    // NIC Clock (Synchronous to SYS_FCLK)
    input   wire            NIC_CLK_GATE,
    output  wire            NIC_GCLK,

    // TLX FWD Clock
    input   wire [2:0]      TLX_FWD_CLK_SELECT,
    input   wire            TLX_FWD_CLK_GATE,
    output  wire            TLX_FWD_FCLK,
    output  wire            TLX_FWD_GCLK,

    // TLX REV Clock
    input   wire            TLX_REV_FCLK,
    input   wire            TLX_REV_CLK_GATE,
    output  wire            TLX_REV_GCLK,


    // CGRA Clock
    input   wire [2:0]      CGRA_CLK_SELECT,
    input   wire            CGRA_CLK_GATE,
    output  wire            CGRA_FCLK,
    output  wire            CGRA_GCLK,

    // Peripheral Clock
    input   wire [2:0]      PERIPH_CLK_SELECT,
    input   wire            TIMER0_CLK_GATE,
    input   wire            TIMER1_CLK_GATE,
    input   wire            UART0_CLK_GATE,
    input   wire            UART1_CLK_GATE,
    input   wire            WDOG_CLK_GATE,
    output  wire            PERIPH_FCLK,
    output  wire            TIMER0_GCLK,
    output  wire            TIMER1_GCLK,
    output  wire            UART0_GCLK,
    output  wire            UART1_GCLK,
    output  wire            WDOG_GCLK
);

    //
    // Internal Signals
    //

    wire                    by_1_CLK;
    wire                    by_2_CLK;
    wire                    by_4_CLK;
    wire                    by_8_CLK;
    wire                    by_16_CLK;
    wire                    by_32_CLK;

    wire                    sync_PORESETn;

    wire                    w_sys_fclk;
    wire                    w_tlx_fwd_fclk;
    wire                    w_cgra_fclk;
    wire                    w_periph_fclk;

    wire [3:0]              w_periph_clk_select;
    wire [3:0]              w_sys_clk_select;
    wire [3:0]              w_periph_sys_select_add;
    wire [2:0]              w_periph_sys_clk_select;
    //
    // PORESETn SynchronizerPERIPH_CLK_FCLK
    //

    AhaResetSync u_aha_reset_sync_poresetn (
        .CLK                (MASTER_CLK),
        .Dn                 (PORESETn),
        .Qn                 (sync_PORESETn)
    );

    //
    // Master Clock Divider
    //

    AhaClockDivider u_aha_clk_divider_master (
        .CLK_IN             (MASTER_CLK),
        .RESETn             (sync_PORESETn),

        .By_1               (by_1_CLK),
        .By_2               (by_2_CLK),
        .By_4               (by_4_CLK),
        .By_8               (by_8_CLK),
        .By_16              (by_16_CLK),
        .By_32              (by_32_CLK)
    );

    //
    // System Clock Selector
    //

    AhaClockSelector u_aha_clk_selector_sys (
        .CLK_by_1           (by_1_CLK),
        .CLK_by_2           (by_2_CLK),
        .CLK_by_4           (by_4_CLK),
        .CLK_by_8           (by_8_CLK),
        .CLK_by_16          (by_16_CLK),
        .CLK_by_32          (by_32_CLK),

        .SELECT             (SYS_CLK_SELECT),

        .CLK_OUT            (w_sys_fclk)
    );

    //
    // System Clock
    //

    AhaClockGate u_aha_clk_gate_sys (
        .TE                 (1'b0),
        .E                  (1'b1),
        .CP                 (w_sys_fclk),
        .Q                  (SYS_FCLK)
    );

    //
    // CPU Clock
    //

    AhaClockGate u_aha_clk_gate_cpu (
        .TE                 (1'b0),
        .E                  (~CPU_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (CPU_GCLK)
    );

    //
    // DAP Clock
    //

    AhaClockGate u_aha_clk_gate_dap (
        .TE                 (1'b0),
        .E                  (~DAP_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (DAP_GCLK)
    );

    //
    // DMA0 Clock
    //

    AhaClockGate u_aha_clk_gate_dma0 (
        .TE                 (1'b0),
        .E                  (~DMA0_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (DMA0_GCLK)
    );

    //
    // DMA1 Clock
    //

    AhaClockGate u_aha_clk_gate_dma1 (
        .TE                 (1'b0),
        .E                  (~DMA1_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (DMA1_GCLK)
    );

    //
    // SRAM Clock
    //

    AhaClockGate u_aha_clk_gate_sram (
        .TE                 (1'b0),
        .E                  (~SRAM_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (SRAM_GCLK)
    );

    //
    // NIC Clock
    //

    AhaClockGate u_aha_clk_gate_nic (
        .TE                 (1'b0),
        .E                  (~NIC_CLK_GATE),
        .CP                 (w_sys_fclk),
        .Q                  (NIC_GCLK)
    );

    //
    // TLX FWD Clock Selector
    //

    AhaClockSelector u_aha_clk_selector_tlx_fwd (
        .CLK_by_1           (by_1_CLK),
        .CLK_by_2           (by_2_CLK),
        .CLK_by_4           (by_4_CLK),
        .CLK_by_8           (by_8_CLK),
        .CLK_by_16          (by_16_CLK),
        .CLK_by_32          (by_32_CLK),

        .SELECT             (TLX_FWD_CLK_SELECT),

        .CLK_OUT            (w_tlx_fwd_fclk)
    );

    //
    // TLX FWD Clock
    //

    AhaClockGate u_aha_clk_gate_tlx_fwd_fclk (
        .TE                 (1'b0),
        .E                  (1'b1),
        .CP                 (w_tlx_fwd_fclk),
        .Q                  (TLX_FCLK)
    );

    AhaClockGate u_aha_clk_gate_tlx_fwd_gclk (
        .TE                 (1'b0),
        .E                  (~TLX_FWD_CLK_GATE),
        .CP                 (w_tlx_fwd_fclk),
        .Q                  (TLX_GCLK)
    );

    //
    // TLX REV Gated Clock
    //

    AhaClockGate u_aha_clk_gate_tlx_rev_gclk (
        .TE                 (1'b0),
        .E                  (~TLX_REV_CLK_GATE),
        .CP                 (TLX_REV_FCLK),
        .Q                  (TLX_REV_GCLK)
    );

    //
    // CGRA Clock Selector
    //

    AhaClockSelector u_aha_clk_selector_cgra (
        .CLK_by_1           (by_1_CLK),
        .CLK_by_2           (by_2_CLK),
        .CLK_by_4           (by_4_CLK),
        .CLK_by_8           (by_8_CLK),
        .CLK_by_16          (by_16_CLK),
        .CLK_by_32          (by_32_CLK),

        .SELECT             (CGRA_CLK_SELECT),

        .CLK_OUT            (w_cgra_fclk)
    );

    //
    // CGRA Clock
    //

    AhaClockGate u_aha_clk_gate_cgra_fclk (
        .TE                 (1'b0),
        .E                  (1'b1),
        .CP                 (w_cgra_fclk),
        .Q                  (CGRA_FCLK)
    );

    AhaClockGate u_aha_clk_gate_cgra_gclk (
        .TE                 (1'b0),
        .E                  (~CGRA_CLK_GATE),
        .CP                 (w_cgra_fclk),
        .Q                  (CGRA_GCLK)
    );

    //
    // Peripheral Clock Selector
    //

    assign w_periph_clk_select      = {1'b0, PERIPH_CLK_SELECT};
    assign w_sys_clk_select         = {1'b0, SYS_CLK_SELECT};
    assign w_periph_sys_select_add  = w_periph_clk_select + w_sys_clk_select;
    assign w_periph_sys_clk_select  = (w_periph_sys_select_add > 4'b0101) ?
                                      3'b101 : w_periph_sys_select_add[2:0];

    AhaClockSelector u_aha_clk_selector_periph (
        .CLK_by_1           (by_1_CLK),
        .CLK_by_2           (by_2_CLK),
        .CLK_by_4           (by_4_CLK),
        .CLK_by_8           (by_8_CLK),
        .CLK_by_16          (by_16_CLK),
        .CLK_by_32          (by_32_CLK),

        .SELECT             (w_periph_sys_clk_select),

        .CLK_OUT            (w_periph_fclk)
    );

    //
    // Peripheral Clock
    //

    AhaClockGate u_aha_clk_gate_periph (
        .TE                 (1'b0),
        .E                  (1'b1),
        .CP                 (w_periph_fclk),
        .Q                  (PERIPH_FCLK)
    );

    //
    // TIMER0 Gated Clock
    //

    AhaClockGate u_aha_clk_gate_timer0 (
        .TE                 (1'b0),
        .E                  (~TIMER0_CLK_GATE),
        .CP                 (w_periph_fclk),
        .Q                  (TIMER0_GCLK)
    );

    //
    // TIMER1 Gated Clock
    //

    AhaClockGate u_aha_clk_gate_timer1 (
        .TE                 (1'b0),
        .E                  (~TIMER1_CLK_GATE),
        .CP                 (w_periph_fclk),
        .Q                  (TIMER1_GCLK)
    );

    //
    // UART0 Gated Clock
    //

    AhaClockGate u_aha_clk_gate_uart0 (
        .TE                 (1'b0),
        .E                  (~UART0_CLK_GATE),
        .CP                 (w_periph_fclk),
        .Q                  (UART0_GCLK)
    );

    //
    // UART1 Gated Clock
    //

    AhaClockGate u_aha_clk_gate_uart1 (
        .TE                 (1'b0),
        .E                  (~UART1_CLK_GATE),
        .CP                 (w_periph_fclk),
        .Q                  (UART1_GCLK)
    );

    //
    // WDOG Gated Clock
    //

    AhaClockGate u_aha_clk_gate_wdog (
        .TE                 (1'b0),
        .E                  (~WDOG_CLK_GATE),
        .CP                 (w_periph_fclk),
        .Q                  (WDOG_GCLK)
    );

endmodule /* AhaClockController */
