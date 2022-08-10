//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : SoC TestBench
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Aug 10, 2022
//------------------------------------------------------------------------------

// =============================================================================
// Debug and Trace Wires
// -----------------------------------------------------------------------------

module Tbench;

    wire                    nTRST;      // Test Reset
    wire                    TMS;        // Test Mode Select / SWDIN
    wire                    TCK;        // Test Clock / SWCLK
    wire                    TDI;        // Test Data In
    wire                    TDO;        // Test Data Out

// =============================================================================
// UART Wires
// -----------------------------------------------------------------------------

    wire                    UART0_RXD;
    wire                    UART0_TXD;
    wire                    UART1_RXD;
    wire                    UART1_TXD;

    // LoopBack
    assign UART0_RXD        = UART0_TXD;
    assign UART1_RXD        = UART1_TXD;

// =============================================================================
// TLX Wires
// -----------------------------------------------------------------------------

    //
    // TLX FWD Wires
    //

    wire                                    TLX_FWD_CLK;
    wire                                    TLX_FWD_PAYLOAD_TVALID;
    wire                                    TLX_FWD_PAYLOAD_TREADY;
    wire [(`TLX_FWD_DATA_LO_WIDTH-1):0]     TLX_FWD_PAYLOAD_TDATA_LO;
    wire [(39-`TLX_FWD_DATA_LO_WIDTH):0]    TLX_FWD_PAYLOAD_TDATA_HI;
    wire [39:0]                             TLX_FWD_PAYLOAD_TDATA;

    wire                                    TLX_FWD_FLOW_TVALID;
    wire                                    TLX_FWD_FLOW_TREADY;
    wire [1:0]                              TLX_FWD_FLOW_TDATA;

    assign TLX_FWD_PAYLOAD_TDATA = {TLX_FWD_PAYLOAD_TDATA_HI, TLX_FWD_PAYLOAD_TDATA_LO};

    //
    // TLX REV Wires
    //
    wire                                    TLX_REV_PAYLOAD_TVALID;
    wire                                    TLX_REV_PAYLOAD_TREADY;
    wire [(`TLX_REV_DATA_LO_WIDTH-1):0]     TLX_REV_PAYLOAD_TDATA_LO;
    wire [(79-`TLX_REV_DATA_LO_WIDTH):0]    TLX_REV_PAYLOAD_TDATA_HI;
    wire [79:0]                             TLX_REV_PAYLOAD_TDATA;

    wire                                    TLX_REV_FLOW_TVALID;
    wire                                    TLX_REV_FLOW_TREADY;
    wire [2:0]                              TLX_REV_FLOW_TDATA;

    wire                                    TLX_REV_LANE_0;
    wire [79:0]                             TLX_REV_PAYLOAD_TDATA_w;

    assign TLX_REV_PAYLOAD_TDATA_w  = {TLX_REV_PAYLOAD_TDATA[79:1], TLX_REV_LANE_0};
    assign TLX_REV_PAYLOAD_TDATA_LO = TLX_REV_PAYLOAD_TDATA_w[(`TLX_REV_DATA_LO_WIDTH-1):0];
    assign TLX_REV_PAYLOAD_TDATA_HI = TLX_REV_PAYLOAD_TDATA_w[79:`TLX_REV_DATA_LO_WIDTH];


// =============================================================================
// Clock and Reset
// -----------------------------------------------------------------------------

    localparam  SYS_CLK_PERIOD  = 10;

    reg                     MASTER_CLK;
    reg                     PO_RESET_N;

    initial
    begin
        MASTER_CLK          = 1'b0;
    end

    always #(MAIN_PERIOD/2) MASTER_CLK = ~MASTER_CLK;

    initial
    begin
        PO_RESET_N          = 1'b0;
        repeat(100) @(posedge MASTER_CLK);
        @(negedge MASTER_CLK) PO_RESET_N = 1'b1;
    end

// =============================================================================
// SoC Instantiation
// -----------------------------------------------------------------------------

    `ifdef SOC_SIMULATION

        AhaGarnetSoC u_soc (
            // Resets
            .PORESETn                           (PO_RESET_N),
            .DP_JTAG_TRSTn                      (nTRST),
            .CGRA_JTAG_TRSTn                    (1'b1),

            // Clocks
            .MASTER_CLK                         (MASTER_CLK),
            .ALT_MASTER_CLK                     (1'b0),
            .DP_JTAG_TCK                        (TCK),
            .CGRA_JTAG_TCK                      (1'b0),

            // SoC JTAG Interface
            .DP_JTAG_TDI                        (TDI),
            .DP_JTAG_TMS                        (TMS),
            .DP_JTAG_TDO                        (TDO),

            // CGRA JTAG Interface
            .CGRA_JTAG_TDI                      (1'b0),
            .CGRA_JTAG_TMS                      (1'b0),
            .CGRA_JTAG_TDO                      (/* unused */),

            // Trace
            .TPIU_TRACE_DATA                    (/* unused */),
            .TPIU_TRACE_SWO                     (/* unused */),
            .TPIU_TRACE_CLK                     (/* unused */),

            // UART
            .UART0_RXD                          (UART0_RXD),
            .UART0_TXD                          (UART0_TXD),
            .UART1_RXD                          (UART1_RXD),
            .UART1_TXD                          (UART1_TXD),

            // TLX FWD Channel
            .TLX_FWD_CLK                        (TLX_FWD_CLK),

            .TLX_FWD_PAYLOAD_TVALID             (TLX_FWD_PAYLOAD_TVALID),
            .TLX_FWD_PAYLOAD_TREADY             (TLX_FWD_PAYLOAD_TREADY),
            .TLX_FWD_PAYLOAD_TDATA_LO           (TLX_FWD_PAYLOAD_TDATA_LO),
            .TLX_FWD_PAYLOAD_TDATA_HI           (TLX_FWD_PAYLOAD_TDATA_HI),

            .TLX_FWD_FLOW_TVALID                (TLX_FWD_FLOW_TVALID),
            .TLX_FWD_FLOW_TREADY                (TLX_FWD_FLOW_TREADY),
            .TLX_FWD_FLOW_TDATA                 (TLX_FWD_FLOW_TDATA),

            //TLX REV Channel
            .TLX_REV_CLK                        (TLX_REV_CLK),

            .TLX_REV_PAYLOAD_TVALID             (TLX_REV_PAYLOAD_TVALID),
            .TLX_REV_PAYLOAD_TREADY             (TLX_REV_PAYLOAD_TREADY),
            .TLX_REV_PAYLOAD_TDATA_LO           (TLX_REV_PAYLOAD_TDATA_LO),
            .TLX_REV_PAYLOAD_TDATA_HI           (TLX_REV_PAYLOAD_TDATA_HI),

            .TLX_REV_FLOW_TVALID                (TLX_REV_FLOW_TVALID),
            .TLX_REV_FLOW_TREADY                (TLX_REV_FLOW_TREADY),
            .TLX_REV_FLOW_TDATA                 (TLX_REV_FLOW_TDATA),

            .OUT_PAD_DS_GRP0                    (/* unused */),
            .OUT_PAD_DS_GRP1                    (/* unused */),
            .OUT_PAD_DS_GRP2                    (/* unused */),
            .OUT_PAD_DS_GRP3                    (/* unused */),
            .OUT_PAD_DS_GRP4                    (/* unused */),
            .OUT_PAD_DS_GRP5                    (/* unused */),
            .OUT_PAD_DS_GRP6                    (/* unused */),
            .OUT_PAD_DS_GRP7                    (/* unused */),

            .LOOP_BACK_SELECT                   (4'h0),
            .LOOP_BACK                          (/* unused */)
        );

// =============================================================================
// TLX Master Domain Instantiation
// -----------------------------------------------------------------------------

    TlxMem u_tlx_mem (
        // FWD Link
        .tlx_fwd_clk                            (TLX_FWD_CLK),
        .tlx_fwd_reset_n                        (PO_RESET_N),

        .tlx_fwd_payload_tvalid                 (TLX_FWD_PAYLOAD_TVALID),
        .tlx_fwd_payload_tready                 (TLX_FWD_PAYLOAD_TREADY),
        .tlx_fwd_payload_tdata                  (TLX_FWD_PAYLOAD_TDATA),

        .tlx_fwd_flow_tvalid                    (TLX_FWD_FLOW_TVALID),
        .tlx_fwd_flow_tready                    (TLX_FWD_FLOW_TREADY),
        .tlx_fwd_flow_tdata                     (TLX_FWD_FLOW_TDATA),

        // REV Link
        .tlx_rev_clk                            (MASTER_CLK),
        .tlx_rev_reset_n                        (PO_RESET_N),

        .tlx_rev_payload_tvalid                 (TLX_REV_PAYLOAD_TVALID),
        .tlx_rev_payload_tready                 (TLX_REV_PAYLOAD_TREADY),
        .tlx_rev_payload_tdata                  (TLX_REV_PAYLOAD_TDATA),

        .tlx_rev_flow_tvalid                    (TLX_REV_FLOW_TVALID),
        .tlx_rev_flow_tready                    (TLX_REV_FLOW_TREADY),
        .tlx_rev_flow_tdata                     (TLX_REV_FLOW_TDATA)
    );

// =============================================================================
// Performance Monitor Instantiation
// -----------------------------------------------------------------------------

    `ifndef SOC_ONLY
        PerfMonitor u_perf_monitor (
            .CPU_CLK                    (u_soc.u_aha_soc_partial.u_cpu_integration.CPU_CLK),
            .PROC_WR_EN                 (u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_wr_en),
            .PROC_RD_EN                 (u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_rd_en),
            .IF_CFG_WR_EN               (u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.if_cfg_wr_en),
            .CGRA_CFG_G2F_CFG_WR_EN     (|u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.cgra_cfg_g2f_cfg_wr_en),
            .STREAM_DATA_VALID_G2F      (|u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_g2f),
            .STREAM_DATA_VALID_F2G      (|u_soc.u_aha_soc_partial.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_f2g)
        );
    `else
        PerfMonitor u_perf_monitor (
            .CPU_CLK                    (1'b0),
            .PROC_WR_EN                 (1'b0),
            .PROC_RD_EN                 (1'b0),
            .IF_CFG_WR_EN               (1'b0),
            .CGRA_CFG_G2F_CFG_WR_EN     (1'b0),
            .STREAM_DATA_VALID_G2F      (1'b0),
            .STREAM_DATA_VALID_F2G      (1'b0)
        );
    `endif

// =============================================================================
// Pull Up/Pull Down
// -----------------------------------------------------------------------------

    pullup(TDI);
    pullup(TMS);
    pullup(TCK);
    pullup(nTRST);
    pullup(TDO);

    pullup(UART0_RXD);
    pullup(UART0_TXD);
    pullup(UART1_RXD);
    pullup(UART1_TXD);

// =============================================================================
// UART Capture (on UART0)
// -----------------------------------------------------------------------------

    cmsdk_uart_capture_ard u_cmsdk_uart_capture_ard (
        .RESETn                     (PO_RESET_N),                   // Power on reset
        .CLK                        (Tbench.u_soc.core.uart0_clk),  // Clock
        .RXD                        (UART0_TXD),                    // Received data
        .SIMULATIONEND              (),
        .DEBUG_TESTER_ENABLE        (),
        .AUXCTRL                    (),
        .SPI0                       (),
        .SPI1                       (),
        .I2C0                       (),
        .I2C1                       (),
        .UART0                      (),
        .UART1                      ()
    );

// =============================================================================
// TLX Training Capture
// -----------------------------------------------------------------------------

    AhaTlxTrainingMonitor u_tlx_capture (
        .FWD_CLK                    (TLX_FWD_CLK),
        .FWD_RESETn                 (PO_RESET_N),
        .REV_CLK                    (MASTER_CLK),
        .REV_RESETn                 (PO_RESET_N),
        .OE                         (Tbench.u_soc.core.u_aha_tlx.u_aha_tlx_ctrl.l2h_LANE_ENABLE_REG_LANE0_r),
        .FWD_DATA_IN                (TLX_FWD_PAYLOAD_TDATA[0]),
        .REV_DATA_IN                (TLX_REV_PAYLOAD_TDATA[0]),
        .REV_DATA_OUT               (TLX_REV_LANE_0)
    );

// =============================================================================
// VCD Dump
// -----------------------------------------------------------------------------
// dumping trn file can speed up
    initial
    begin
        if ($test$plusargs("VCD_ON"))
        begin
            $recordfile("dump.trn");
            $recordvars(Tbench);
        end
    end

endmodule

`endif
