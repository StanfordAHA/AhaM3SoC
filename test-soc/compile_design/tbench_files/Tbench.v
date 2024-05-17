//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose  : SoC TestBench
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Aug 10, 2022
//------------------------------------------------------------------------------

`ifdef IMPL_RTL
  `define SOC_TOP     u_soc
`elsif IMPL_GATELEVEL
    `define SOC_TOP     u_soc.core
`endif

// =============================================================================
// Debug and Trace Wires
// -----------------------------------------------------------------------------

module Tbench;

    wire                    nTRST;      // Test Reset
    wire                    TMS;        // Test Mode Select / SWDIN
    wire                    TCK;        // Test Clock / SWCLK
    wire                    TDI;        // Test Data In
    wire                    TDO;        // Test Data Out

    wire                    TPIU_SWO;
    wire                    TPIU_CLK;

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
    wire [(`TLX_FWD_DATA_LO_WIDTH-1):0]     TLX_FWD_PAYLOAD_TDATA_LO;
    wire [(39-`TLX_FWD_DATA_LO_WIDTH):0]    TLX_FWD_PAYLOAD_TDATA_HI;
    wire [39:0]                             TLX_FWD_PAYLOAD_TDATA;

    wire                                    TLX_FWD_FLOW_TVALID;
    wire [1:0]                              TLX_FWD_FLOW_TDATA;

    assign TLX_FWD_PAYLOAD_TDATA = {TLX_FWD_PAYLOAD_TDATA_HI, TLX_FWD_PAYLOAD_TDATA_LO};

    //
    // TLX REV Wires
    //
    wire                                    TLX_REV_PAYLOAD_TVALID;
    wire [(`TLX_REV_DATA_LO_WIDTH-1):0]     TLX_REV_PAYLOAD_TDATA_LO;
    wire [(79-`TLX_REV_DATA_LO_WIDTH):0]    TLX_REV_PAYLOAD_TDATA_HI;
    wire [79:0]                             TLX_REV_PAYLOAD_TDATA;

    wire                                    TLX_REV_FLOW_TVALID;
    wire [2:0]                              TLX_REV_FLOW_TDATA;

    wire                                    TLX_REV_LANE_0;
    wire [79:0]                             TLX_REV_PAYLOAD_TDATA_w;

    assign TLX_REV_PAYLOAD_TDATA_w  = {TLX_REV_PAYLOAD_TDATA[79:1], TLX_REV_LANE_0};
    assign TLX_REV_PAYLOAD_TDATA_LO = TLX_REV_PAYLOAD_TDATA_w[(`TLX_REV_DATA_LO_WIDTH-1):0];
    assign TLX_REV_PAYLOAD_TDATA_HI = TLX_REV_PAYLOAD_TDATA_w[79:`TLX_REV_DATA_LO_WIDTH];


// =============================================================================
// Clock and Reset
// -----------------------------------------------------------------------------

    localparam  MAIN_PERIOD  = 10;

    reg                     MASTER_CLK;
    reg                     PO_RESET_N;
    reg                     SYS_RESET_N;

    initial
    begin
        MASTER_CLK          = 1'b0;
    end

    always #(MAIN_PERIOD/2) MASTER_CLK = ~MASTER_CLK;

    initial
    begin
        PO_RESET_N          = 1'b0;
        SYS_RESET_N         = 1'b0;

        repeat(100) @(posedge MASTER_CLK);
        @(negedge MASTER_CLK) PO_RESET_N = 1'b1;

	$display("release PORESET");

        repeat(100) @(posedge MASTER_CLK);
        @(negedge MASTER_CLK) SYS_RESET_N = 1'b1;

	$display("release SYSRESET");
    end

// ============================================================================
// SAIF Dumping
// ============================================================================
`ifdef GEN_PWR_SAIF
    wire flag_start;
    wire flag_end;
    assign flag_start = | Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.strm_g2f_start_pulse[13:0];
    assign flag_end = Tbench.u_soc.core.u_aha_garnet.u_garnet.interrupt;

    // setup the power SAIF
    initial begin
        // $display("[PWR SAIF] Setting up the power SAIF region");
        // $set_toggle_region(Tbench);
        $fsdbDumpfile("run.fsdb");
        $fsdbDumpvars(0, Tbench, "+mda");
    end

    // start recording SAIF
    initial begin
        wait(flag_start == 1'b1);
        // $display("[PWR SAIF] Start recording SAIF into run.saif (T=%t)", $time);
        // $toggle_start();
        $display("[PWR FSDB] Start kernel: @T=%t", $time);
    end

    // stop recording SAIF
    initial begin
        wait(flag_end == 1'b1);
        wait(flag_end == 1'b0);
        // $toggle_stop();
        // $toggle_report("run.saif", 1e-12, "Tbench");
        // $display("[PWR SAIF] Done recording SAIF into run.saif (T=%t)", $time);
        // $toggle_reset();
        $display("[PWR FSDB] End kernel: @T=%t", $time);
    end
`endif

// =============================================================================
// SoC Instantiation
// =============================================================================

`ifdef IMPL_RTL
    AhaGarnetSoC u_soc (
        // Resets
        .PORESETn                           (PO_RESET_N),
        .SYSRESETn                          (SYS_RESET_N),

        // Clocks
        .MASTER_CLK                         (MASTER_CLK),
        .ALT_MASTER_CLK                     (1'b0),
        .TPIU_TRACECLKIN                    (MASTER_CLK),

        // SoC JTAG Interface
        .DP_JTAG_TRSTn                      (nTRST),
        .DP_JTAG_TDI                        (TDI),
        .DP_JTAG_TDO                        (TDO),
        .DP_JTAG_TCK                        (TCK),
        .DP_JTAG_TMS                        (TMS),

        // CGRA JTAG Interface
        .CGRA_JTAG_TRSTn                    (1'b1),
        .CGRA_JTAG_TDI                      (1'b0),
        .CGRA_JTAG_TDO                      (/* unused */),
        .CGRA_JTAG_TCK                      (1'b0),
        .CGRA_JTAG_TMS                      (1'b0),

        // Trace
        .TPIU_TRACE_SWO                     (TPIU_SWO),

        // UART
        .UART0_RXD                          (UART0_RXD),
        .UART0_TXD                          (UART0_TXD),
        .UART1_RXD                          (UART1_RXD),
        .UART1_TXD                          (UART1_TXD),

        // TLX FWD Channel
        //.TLX_FWD_CLK                        (TLX_FWD_CLK),
        //.TLX_FWD_PAYLOAD_TVALID             (TLX_FWD_PAYLOAD_TVALID),
        //.TLX_FWD_PAYLOAD_TDATA_LO           (TLX_FWD_PAYLOAD_TDATA_LO),
        //.TLX_FWD_PAYLOAD_TDATA_HI           (TLX_FWD_PAYLOAD_TDATA_HI),
        //.TLX_FWD_FLOW_TVALID                (TLX_FWD_FLOW_TVALID),
        //.TLX_FWD_FLOW_TDATA                 (TLX_FWD_FLOW_TDATA),
        .TLX_FWD_CLK                        (),
        .TLX_FWD_PAYLOAD_TVALID             (),
        .TLX_FWD_PAYLOAD_TDATA_LO           (),
        .TLX_FWD_PAYLOAD_TDATA_HI           (),
        .TLX_FWD_FLOW_TVALID                (),
        .TLX_FWD_FLOW_TDATA                 (),

        //TLX REV Channel
        //.TLX_REV_CLK                        (MASTER_CLK),
        //.TLX_REV_PAYLOAD_TVALID             (TLX_REV_PAYLOAD_TVALID),
        //.TLX_REV_PAYLOAD_TDATA_LO           (TLX_REV_PAYLOAD_TDATA_LO),
        //.TLX_REV_PAYLOAD_TDATA_HI           (TLX_REV_PAYLOAD_TDATA_HI),
        //.TLX_REV_FLOW_TVALID                (TLX_REV_FLOW_TVALID),
        //.TLX_REV_FLOW_TDATA                 (TLX_REV_FLOW_TDATA),
        .TLX_REV_CLK                        (1'd0),
        .TLX_REV_PAYLOAD_TVALID             (1'd0),
        .TLX_REV_PAYLOAD_TDATA_LO           (45'd0),
        .TLX_REV_PAYLOAD_TDATA_HI           (35'd0),
        .TLX_REV_FLOW_TVALID                (1'd0),
        .TLX_REV_FLOW_TDATA                 (3'd0),

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
`elsif IMPL_GATELEVEL

    supply1 VDD;
    supply1 VDDPST;
    supply0 VSS;

    GarnetSOC_pad_frame u_soc (
        .pad_PORESETn                       (PO_RESET_N),
        .pad_SYSRESETn                      (SYS_RESET_N),
        .pad_DP_JTAG_TRSTn                  (nTRST),
        .pad_CGRA_JTAG_TRSTn                (1'b1),

        .pad_MASTER_CLK                     (MASTER_CLK),
        .pad_TPIU_TRACECLKIN                (MASTER_CLK),

        .pad_DP_JTAG_TCK                    (TCK),
        .pad_DP_JTAG_TDI                    (TDI),
        .pad_DP_JTAG_TMS                    (TMS),
        .pad_DP_JTAG_TDO                    (TDO),

        .pad_CGRA_JTAG_TCK                  (1'b0),
        .pad_CGRA_JTAG_TDI                  (1'b0),
        .pad_CGRA_JTAG_TMS                  (1'b0),
        .pad_CGRA_JTAG_TDO                  (/* unused */),

        .pad_TPIU_TRACE_SWO                 (TPIU_SWO),

        .pad_UART0_RXD                      (UART0_RXD),
        .pad_UART0_TXD                      (UART0_TXD),
        .pad_UART1_RXD                      (UART1_RXD),
        .pad_UART1_TXD                      (UART1_TXD),

        // TLX FWD Channel
        // .pad_TLX_FWD_CLK                        (TLX_FWD_CLK),
        // .pad_TLX_FWD_PAYLOAD_TVALID             (TLX_FWD_PAYLOAD_TVALID),
        // .pad_TLX_FWD_PAYLOAD_TDATA_LO           (TLX_FWD_PAYLOAD_TDATA_LO),
        // .pad_TLX_FWD_PAYLOAD_TDATA_HI           (TLX_FWD_PAYLOAD_TDATA_HI),
        // .pad_TLX_FWD_FLOW_TVALID                (TLX_FWD_FLOW_TVALID),
        // .pad_TLX_FWD_FLOW_TDATA                 (TLX_FWD_FLOW_TDATA),
        .pad_TLX_FWD_CLK                        (),
        .pad_TLX_FWD_PAYLOAD_TVALID             (),
        .pad_TLX_FWD_PAYLOAD_TDATA_LO           (),
        .pad_TLX_FWD_PAYLOAD_TDATA_HI           (),
        .pad_TLX_FWD_FLOW_TVALID                (),
        .pad_TLX_FWD_FLOW_TDATA                 (),

        //TLX REV Channel
        // .pad_TLX_REV_CLK                        (MASTER_CLK),
        // .pad_TLX_REV_PAYLOAD_TVALID             (TLX_REV_PAYLOAD_TVALID),
        // .pad_TLX_REV_PAYLOAD_TDATA_LO           (TLX_REV_PAYLOAD_TDATA_LO),
        // .pad_TLX_REV_PAYLOAD_TDATA_HI           (TLX_REV_PAYLOAD_TDATA_HI),
        // .pad_TLX_REV_FLOW_TVALID                (TLX_REV_FLOW_TVALID),
        // .pad_TLX_REV_FLOW_TDATA                 (TLX_REV_FLOW_TDATA),
        .pad_TLX_REV_CLK                        (1'd0),
        .pad_TLX_REV_PAYLOAD_TVALID             (1'd0),
        .pad_TLX_REV_PAYLOAD_TDATA_LO           (45'd0),
        .pad_TLX_REV_PAYLOAD_TDATA_HI           (35'd0),
        .pad_TLX_REV_FLOW_TVALID                (1'd0),
        .pad_TLX_REV_FLOW_TDATA                 (3'd0),

        // LoopBack
        .pad_LOOP_BACK_SELECT               (4'h0),
        .pad_LOOP_BACK                      (/* unused */),

        // Powers
        .VSS (VSS),
        .VDD (VDD),
        .VDDPST (VDDPST)
    );
`endif

`ifdef SDF_ANNOTATION
    initial begin
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X00_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0A_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0C_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0D_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0E_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X01_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1A_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X02_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X04_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X05_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X06_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X08_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X09_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X10_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X11_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X12_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X14_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X15_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X16_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X18_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X19_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0B_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X0F_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X1B_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X03_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X07_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X13_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0A,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0B,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0C,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0D,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0E,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y0F,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y01,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y02,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y03,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y04,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y05,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y06,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y07,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y08,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y09,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf", Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0.Tile_X17_Y10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/17-tile_array/outputs/tile_array.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.Interconnect_inst0,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_0,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_1,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_2,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_3,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_4,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_5,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_6,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_7,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_8,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_9,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_10,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_11,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_12,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer.glb_tile_gen_13,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/15-glb_top/outputs/glb_top.sdf",Tbench.u_soc.core.u_aha_garnet.u_garnet.global_buffer_W_inst0.global_buffer,,,"MAXIMUM");
        $sdf_annotate("/sim/pohan/garnet_build/1203/31-cadence-innovus-signoff/outputs/design.sdf",Tbench.u_soc,,"sdf_annotation.log","MAXIMUM");
    end
`endif


// =============================================================================
// TLX Master Domain Instantiation
// -----------------------------------------------------------------------------

    TlxMem u_tlx_mem (
        // FWD Link
        .tlx_fwd_clk                            (TLX_FWD_CLK),
        .tlx_fwd_reset_n                        (PO_RESET_N),

        .tlx_fwd_payload_tvalid                 (TLX_FWD_PAYLOAD_TVALID),
        .tlx_fwd_payload_tdata                  (TLX_FWD_PAYLOAD_TDATA),

        .tlx_fwd_flow_tvalid                    (TLX_FWD_FLOW_TVALID),
        .tlx_fwd_flow_tdata                     (TLX_FWD_FLOW_TDATA),

        // REV Link
        .tlx_rev_clk                            (MASTER_CLK),
        .tlx_rev_reset_n                        (PO_RESET_N),

        .tlx_rev_payload_tvalid                 (TLX_REV_PAYLOAD_TVALID),
        .tlx_rev_payload_tdata                  (TLX_REV_PAYLOAD_TDATA),

        .tlx_rev_flow_tvalid                    (TLX_REV_FLOW_TVALID),
        .tlx_rev_flow_tdata                     (TLX_REV_FLOW_TDATA)
    );

// =============================================================================
// Performance Monitor Instantiation
// -----------------------------------------------------------------------------

`ifndef NO_CGRA
    /*
    PerfMonitor u_perf_monitor (
        .CPU_CLK                    (`SOC_TOP.u_aha_soc_partial.u_cpu_integration.CPU_CLK),
        .PROC_WR_EN                 (`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_wr_en),
        .PROC_RD_EN                 (`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_rd_en),
        .IF_CFG_WR_EN               (`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.if_cfg_wr_en),
        .CGRA_CFG_G2F_CFG_WR_EN     (|`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.cgra_cfg_g2f_cfg_wr_en),
        .STREAM_DATA_VALID_G2F      (|`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_g2f),
        .STREAM_DATA_VALID_F2G      (|`SOC_TOP.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_f2g)
    );
    */
`endif

// =============================================================================
// Pull Up/Pull Down
// -----------------------------------------------------------------------------

    pullup(TDI);
    pullup(TMS);
    pullup(TCK);
    pullup(nTRST);
    pullup(TDO);

    pullup(TPIU_SWO);

    pullup(UART0_RXD);
    pullup(UART0_TXD);
    pullup(UART1_RXD);
    pullup(UART1_TXD);


// =============================================================================
// UART Capture (on UART0)
// -----------------------------------------------------------------------------

    SWOCapture u_swo_capture (
        .CLK                        (`SOC_TOP.uart0_clk),
        .RESETn                     (PO_RESET_N),
        .SWO                        (UART0_TXD)
    );

// =============================================================================
// TLX Training Capture
// -----------------------------------------------------------------------------

    AhaTlxTrainingMonitor u_tlx_capture (
        .FWD_CLK                    (TLX_FWD_CLK),
        .FWD_RESETn                 (PO_RESET_N),
        .REV_CLK                    (MASTER_CLK),
        .REV_RESETn                 (PO_RESET_N),
        // .OE                         (`SOC_TOP.u_aha_tlx.u_aha_tlx_ctrl.l2h_LANE_ENABLE_REG_LANE0_r),
        .OE                         (0),
        .FWD_DATA_IN                (TLX_FWD_PAYLOAD_TDATA[0]),
        .REV_DATA_IN                (TLX_REV_PAYLOAD_TDATA[0]),
        .REV_DATA_OUT               (TLX_REV_LANE_0)
    );

// =============================================================================
// CXDT Instantiation
// -----------------------------------------------------------------------------

`ifdef JTAG
    CXDT #(.IMAGENAME ("./CXDT.bin"))
    u_cxdt(.CLK       (MASTER_CLK),
           .PORESETn  (PO_RESET_N),
           .TDO       (TDO),
           .TDI       (TDI),
           .nTRST     (nTRST),
           .SWCLKTCK  (TCK),
           .SWDIOTMS  (TMS)
    );
`endif

// =============================================================================
// Max Cycle Monitor
// -----------------------------------------------------------------------------

int max_cycle;
initial begin
    if ($value$plusargs("MAX_CYCLE=%0d", max_cycle))
    begin
        repeat (max_cycle) @(posedge MASTER_CLK);
        $display("\n%0t\tERROR: The %0d cycles marker has passed!", $time, max_cycle);
        $finish(2);
    end
end

// =============================================================================
// VCD Dump
// -----------------------------------------------------------------------------
// dumping trn file can speed up
    initial
    begin
        if ($test$plusargs("VCD_ON"))
        begin
            `ifdef SIM_XCELIUM
                // $recordfile("dump.trn");
                // $recordvars(Tbench);
            `else
                // $fsdbDumpfile("dump.fsdb");
                // $fsdbDumpvars(0, Tbench, "+mda");
                // $fsdbDumpvars(0, Tbench);
            `endif
        end
    end

endmodule
