//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose: Platform Reset Controller
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 3, 2020
//------------------------------------------------------------------------------
// Updates  :
//  - Aug 22, 2022  :
//------------------------------------------------------------------------------

module AhaResetController (
    // Power-On Reset
    input   wire            PORESETn,

    // System Free-Running Clock
    input   wire            SYS_FCLK,

    // System Reset Request
    // This can include LOCKUP if enabled
    input   wire            SYSRESETREQ,

    // PORESETn Synchronized to SYS_FCLK
    output  wire            SYS_PORESETn,

    // CPU Reset
    output  wire            CPU_RESETn,

    // DAP Reset
    input   wire            DAP_RESET_REQ,          // software reset request
    output  wire            DAP_RESET_ACK,          // software reset acknowledgement
    output  wire            DAP_RESETn,             // DAP reset

    // DMA0 Reset
    input   wire            DMA0_SYS_RESET_EN,      // enable SYSRESETREQ to reset DMA0
    input   wire            DMA0_RESET_REQ,         // software reset request
    output  wire            DMA0_RESET_ACK,         // software reset acknowledgement
    output  wire            DMA0_RESETn,            // DMA0 reset

    // DMA1 Reset
    input   wire            DMA1_SYS_RESET_EN,      // enable SYSRESETREQ to reset DMA1
    input   wire            DMA1_RESET_REQ,         // software reset request
    output  wire            DMA1_RESET_ACK,         // software reset acknowledgement
    output  wire            DMA1_RESETn,            // DMA1 reset

    // SRAM Reset
    input   wire            SRAM_SYS_RESET_EN,      // enable SYSRESETREQ to reset SRAMs
    input   wire            SRAM_RESET_REQ,         // software reset request
    output  wire            SRAM_RESET_ACK,         // software reset acknowledgement
    output  wire            SRAM_RESETn,

    // NIC Reset
    input   wire            NIC_SYS_RESET_EN,       // enable SYSRESETREQ to reset NIC
    input   wire            NIC_RESET_REQ,          // software reset request
    output  wire            NIC_RESET_ACK,          // software reset acknowledgement
    output  wire            NIC_RESETn,             // NIC reset

    // TLX FWD Reset
    input   wire            TLX_FWD_FCLK,           // TLX FWD free-running clock
    input   wire            TLX_FWD_SYS_RESET_EN,   // enable SYSRESETREQ to reset TLX FWD
    input   wire            TLX_FWD_RESET_REQ,      // software reset request
    output  wire            TLX_FWD_RESET_ACK,      // software reset acknowledgement
    output  wire            TLX_FWD_RESETn,         // TLX FWD reset

    // TLX REV Reset
    input   wire            TLX_REV_FCLK,           // TLX REV free-running clock
    input   wire            TLX_REV_SYS_RESET_EN,   // enable SYSRESETREQ to reset TLX REV
    input   wire            TLX_REV_RESET_REQ,      // software reset request
    output  wire            TLX_REV_RESET_ACK,      // software reset acknowledgement
    output  wire            TLX_REV_RESETn,         // TLX REV reset

    // CGRA Reset
    input   wire            CGRA_FCLK,              // CGRA free-running clock
    input   wire            CGRA_SYS_RESET_EN,      // enable SYSRESETREQ to reset CGRA
    input   wire            CGRA_RESET_REQ,         // software reset request
    output  wire            CGRA_RESET_ACK,         // software reset acknowledgement
    output  wire            CGRA_RESETn,            // CGRA reset

    // Peripheral Free-Running Clock
    input   wire            PERIPH_FCLK,

    // TIMER0 Reset
    input   wire            TIMER0_SYS_RESET_EN,    // enable SYSRESETREQ to reset TIMER0
    input   wire            TIMER0_RESET_REQ,       // software reset request
    output  wire            TIMER0_RESET_ACK,       // software reset acknowledgement
    output  wire            TIMER0_RESETn,          // TIMER0 Reset

    // TIMER1 Reset
    input   wire            TIMER1_SYS_RESET_EN,    // enable SYSRESETREQ to reset TIMER1
    input   wire            TIMER1_RESET_REQ,       // software reset request
    output  wire            TIMER1_RESET_ACK,       // software reset acknowledgement
    output  wire            TIMER1_RESETn,          // TIMER1 Reset

    // UART0 Reset
    input   wire            UART0_SYS_RESET_EN,     // enable SYSRESETREQ to reset UART0
    input   wire            UART0_RESET_REQ,        // software reset request
    output  wire            UART0_RESET_ACK,        // software reset acknowledgement
    output  wire            UART0_RESETn,           // UART0 Reset

    // UART1 Reset
    input   wire            UART1_SYS_RESET_EN,     // enable SYSRESETREQ to reset UART1
    input   wire            UART1_RESET_REQ,        // software reset request
    output  wire            UART1_RESET_ACK,        // software reset acknowledgement
    output  wire            UART1_RESETn,           // UART1 Reset

    // WDOG Reset
    input   wire            WDOG_SYS_RESET_EN,      // enable SYSRESETREQ to reset WDOG
    input   wire            WDOG_RESET_REQ,         // software reset request
    output  wire            WDOG_RESET_ACK,         // software reset acknowledgement
    output  wire            WDOG_RESETn,            // WDOG Reset

    // DP JTAG Reset
    input   wire            DP_JTAG_TCK,            // DP JTAG Clock
    input   wire            DP_JTAG_TRSTn,          // DP JTAG Test Reset
    output  wire            DP_JTAG_PORESETn,       // DP JTAG Synchronized PORESETn
    output  wire            DP_JTAG_RESETn,         // DP JTAG Synchronized Test Reset

    // CGRA JTAG Reset
    input   wire            CGRA_JTAG_TCK,          // CGRA JTAG Clock
    input   wire            CGRA_JTAG_TRSTn,        // CGRA JTAG Test Reset
    output  wire            CGRA_JTAG_PORESETn,     // CGRA JTAG Synchronized PORESETn
    output  wire            CGRA_JTAG_RESETn,       // CGRA JTAG Synchronized Test Reset

    // TPIU Reset
    input   wire            TPIU_TRACE_CLK,         // TPIU free-running clock
    output  wire            TPIU_RESETn             // TPIU Reset
);

    //
    // Internal Wires
    //

    wire                    w_sys_poresetn;
    wire                    w_dp_jtag_poresetn;
    wire                    w_cgra_jtag_poresetn;

    //
    // Power-On Resets
    //

    // System Clock Domain
    AhaResetSync a_aha_reset_sync_sys_poresetn (
        .CLK                (SYS_FCLK),
        .Dn                 (PORESETn),
        .Qn                 (w_sys_poresetn)
    );

    // DP JTAG Clock Domain
    AhaResetSync a_aha_reset_sync_dp_jtag_poresetn (
        .CLK                (DP_JTAG_TCK),
        .Dn                 (PORESETn),
        .Qn                 (w_dp_jtag_poresetn)
    );

    // CGRA JTAG Clock Domain
    AhaResetSync a_aha_reset_sync_cgra_jtag_poresetn (
        .CLK                (CGRA_JTAG_TCK),
        .Dn                 (PORESETn),
        .Qn                 (w_cgra_jtag_poresetn)
    );

    // TPIU Clock Domain
    AhaResetSync a_aha_reset_sync_tpiu_poresetn (
        .CLK                (TPIU_TRACE_CLK),
        .Dn                 (PORESETn),
        .Qn                 (TPIU_RESETn)
    );

    //
    // Reset Controllers
    //

    // CPU
    AhaResetGen #(.NUM_CYCLES(8)) u_aha_reset_gen_cpu (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ                (SYSRESETREQ),
        .ACK                (),
        .Qn                 (CPU_RESETn)
    );

    // DAP
    AhaResetGen #(.NUM_CYCLES(8)) u_aha_reset_gen_dap (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ                (DAP_RESET_REQ),
        .ACK                (DAP_RESET_ACK),
        .Qn                 (DAP_RESETn)
    );

    // DMA0
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_dma0 (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & DMA0_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (DMA0_RESET_REQ),
        .ACK_1              (DMA0_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (DMA0_RESETn)
    );

    // DMA1
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_dma1 (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & DMA1_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (DMA1_RESET_REQ),
        .ACK_1              (DMA1_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (DMA1_RESETn)
    );

    // SRAM
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_sram (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & SRAM_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (SRAM_RESET_REQ),
        .ACK_1              (SRAM_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (SRAM_RESETn)
    );

    // NIC
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_nic (
        .CLK                (SYS_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & NIC_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (NIC_RESET_REQ),
        .ACK_1              (NIC_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (NIC_RESETn)
    );

    // TLX FWD
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_tlx_fwd (
        .CLK                (TLX_FWD_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & TLX_FWD_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (TLX_FWD_RESET_REQ),
        .ACK_1              (TLX_FWD_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),DP_JTAG_PORESETn
        .Qn                 (TLX_FWD_RESETn)
    );

    // TLX REV
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_tlx_rev (
        .CLK                (TLX_REV_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & TLX_REV_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (TLX_REV_RESET_REQ),
        .ACK_1              (TLX_REV_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),DP_JTAG_PORESETn
        .Qn                 (TLX_REV_RESETn)
    );

    // CGRA
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_cgra (
        .CLK                (CGRA_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & CGRA_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (CGRA_RESET_REQ),
        .ACK_1              (CGRA_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (CGRA_RESETn)
    );

    // TIMER0
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_timer0 (
        .CLK                (PERIPH_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & TIMER0_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (TIMER0_RESET_REQ),
        .ACK_1              (TIMER0_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (TIMER0_RESETn)
    );

    // TIMER1
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_timer1 (
        .CLK                (PERIPH_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & TIMER1_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (TIMER1_RESET_REQ),
        .ACK_1              (TIMER1_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (TIMER1_RESETn)
    );

    // UART0
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_uart0 (
        .CLK                (PERIPH_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & UART0_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (UART0_RESET_REQ),
        .ACK_1              (UART0_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (UART0_RESETn)
    );

    // UART1
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_uart1 (
        .CLK                (PERIPH_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & UART1_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (UART1_RESET_REQ),
        .ACK_1              (UART1_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (UART1_RESETn)
    );

    // WDOG
    AhaResetGenX4 #(.NUM_CYCLES(8)) u_aha_reset_gen_x4_wdog (
        .CLK                (PERIPH_FCLK),
        .PORESETn           (PORESETn),
        .REQ_0              (SYSRESETREQ & WDOG_SYS_RESET_EN),
        .ACK_0              (),
        .REQ_1              (WDOG_RESET_REQ),
        .ACK_1              (WDOG_RESET_ACK),
        .REQ_2              (1'b0),
        .ACK_2              (),
        .REQ_3              (1'b0),
        .ACK_3              (),
        .Qn                 (WDOG_RESETn)
    );

    // DP JTAG
    AhaResetSync u_aha_reset_sync_dp_jtag (
        .CLK                (DP_JTAG_TCK),
        .Dn                 (DP_JTAG_TRSTn),
        .Qn                 (DP_JTAG_RESETn)
    );

    // CGRA JTAG
    AhaResetSync u_aha_reset_sync_cgra_jtag (
        .CLK                (CGRA_JTAG_TCK),
        .Dn                 (CGRA_JTAG_TRSTn),
        .Qn                 (CGRA_JTAG_RESETn)
    );

    //
    // Extra Output Assignments
    //

    assign SYS_PORESETn             = w_sys_poresetn;
    assign DP_JTAG_PORESETn         = w_dp_jtag_poresetn;
    assign CGRA_JTAG_PORESETn       = w_cgra_jtag_poresetn;

endmodule;
