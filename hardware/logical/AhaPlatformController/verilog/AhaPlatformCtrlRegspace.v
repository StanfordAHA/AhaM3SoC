//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Platform Controller Register Space
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 4, 2020
//------------------------------------------------------------------------------
module AhaPlatformCtrlRegspace (
  // AHB Interface
  input   wire                HCLK,
  input   wire                HRESETn,

  input   wire                HSEL,
  input   wire [31:0]         HADDR,
  input   wire  [1:0]         HTRANS,
  input   wire                HWRITE,
  input   wire  [2:0]         HSIZE,
  input   wire  [2:0]         HBURST,
  input   wire  [3:0]         HPROT,
  input   wire  [3:0]         HMASTER,
  input   wire [31:0]         HWDATA,
  input   wire                HMASTLOCK,
  input   wire                HREADYMUX,

  output  wire [31:0]         HRDATA,
  output  wire                HREADYOUT,
  output  wire [1:0]          HRESP,

  // Register Signals
  input   wire                H2L_RESET_ACK_REG_DMA0_w,
  input   wire                H2L_RESET_ACK_REG_DMA1_w,
  input   wire                H2L_RESET_ACK_REG_TLX_FWD_w,
  input   wire                H2L_RESET_ACK_REG_TLX_REV_w,
  input   wire                H2L_RESET_ACK_REG_GGRA_w,
  input   wire                H2L_RESET_ACK_REG_NIC_w,
  input   wire                H2L_RESET_ACK_REG_TIMER0_w,
  input   wire                H2L_RESET_ACK_REG_TIMER1_w,
  input   wire                H2L_RESET_ACK_REG_UART0_w,
  input   wire                H2L_RESET_ACK_REG_UART1_w,
  input   wire                H2L_RESET_ACK_REG_WDOG_w,

  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP0_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP1_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP2_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP3_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP4_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP5_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP6_r,
  output  wire [2:0]          L2H_PAD_STRENGTH_CTRL_REG_GRP7_r,
  output  wire                L2H_SYS_CLK_SELECT_REG_SELECT_SWMOD_o,
  output  wire [2:0]          L2H_SYS_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_DMA0_PCLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_DMA1_PCLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_TLX_FWD_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_CGRA_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_TIMER0_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_TIMER1_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_UART0_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_UART1_CLK_SELECT_REG_SELECT_r,
  output  wire [2:0]          L2H_WDOG_CLK_SELECT_REG_SELECT_r,
  output  wire                L2H_CLK_GATE_EN_REG_CPU_r,
  output  wire                L2H_CLK_GATE_EN_REG_DAP_r,
  output  wire                L2H_CLK_GATE_EN_REG_DMA0_r,
  output  wire                L2H_CLK_GATE_EN_REG_DMA1_r,
  output  wire                L2H_CLK_GATE_EN_REG_SRAMX_r,
  output  wire                L2H_CLK_GATE_EN_REG_TLX_FWD_r,
  output  wire                L2H_CLK_GATE_EN_REG_GGRA_r,
  output  wire                L2H_CLK_GATE_EN_REG_NIC_r,
  output  wire                L2H_CLK_GATE_EN_REG_TIMER0_r,
  output  wire                L2H_CLK_GATE_EN_REG_TIMER1_r,
  output  wire                L2H_CLK_GATE_EN_REG_UART0_r,
  output  wire                L2H_CLK_GATE_EN_REG_UART1_r,
  output  wire                L2H_CLK_GATE_EN_REG_WDOG_r,
  output  wire                L2H_SYS_RESET_PROP_REG_DMA0_r,
  output  wire                L2H_SYS_RESET_PROP_REG_DMA1_r,
  output  wire                L2H_SYS_RESET_PROP_REG_SRAMX_r,
  output  wire                L2H_SYS_RESET_PROP_REG_TLX_FWD_r,
  output  wire                L2H_SYS_RESET_PROP_REG_GGRA_r,
  output  wire                L2H_SYS_RESET_PROP_REG_NIC_r,
  output  wire                L2H_SYS_RESET_PROP_REG_TIMER0_r,
  output  wire                L2H_SYS_RESET_PROP_REG_TIMER1_r,
  output  wire                L2H_SYS_RESET_PROP_REG_UART0_r,
  output  wire                L2H_SYS_RESET_PROP_REG_UART1_r,
  output  wire                L2H_SYS_RESET_PROP_REG_WDOG_r,
  output  wire                L2H_RESET_REQ_REG_DMA0_r,
  output  wire                L2H_RESET_REQ_REG_DMA1_r,
  output  wire                L2H_RESET_REQ_REG_TLX_FWD_r,
  output  wire                L2H_RESET_REQ_REG_TLX_REV_r,
  output  wire                L2H_RESET_REQ_REG_GGRA_r,
  output  wire                L2H_RESET_REQ_REG_NIC_r,
  output  wire                L2H_RESET_REQ_REG_TIMER0_r,
  output  wire                L2H_RESET_REQ_REG_TIMER1_r,
  output  wire                L2H_RESET_REQ_REG_UART0_r,
  output  wire                L2H_RESET_REQ_REG_UART1_r,
  output  wire                L2H_RESET_REQ_REG_WDOG_r,
  output  wire [23:0]         L2H_SYS_TICK_CONFIG_REG_CALIB_r,
  output  wire                L2H_SYS_TICK_CONFIG_REG_NOT_10_MS_r,
  output  wire                L2H_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r,
  output  wire                L2H_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r,
  output  wire                L2H_MASTER_CLK_SELECT_SELECT_r
);

    //
    // Internal Signals
    //

    wire    [11:0]              w_PADDR;
    wire                        w_PENABLE;
    wire                        w_PWRITE;
    wire    [31:0]              w_PWDATA;
    wire                        w_PSEL;
    wire                        w_PREADY;
    wire                        w_PSLVERR;
    wire    [31:0]              w_PRDATA;

    reg [31:0]                  apb_rdata;
    reg [31:0]                  apb_rdata_reg;
    wire                        apb_setup_phase;
    wire                        apb_rd_en;
    wire                        apb_wr_en;
    wire [4:0]                  apb_addr_oft;

    reg     [31:0]              PAD_STRENGTH_CTRL_REG;
    reg     [31:0]              SYS_CLK_SELECT_REG;
    reg                         SYS_CLK_SELECT_SWMOD;
    reg     [31:0]              DMA0_PCLK_SELECT_REG;
    reg     [31:0]              DMA1_PCLK_SELECT_REG;
    reg     [31:0]              TLX_FWD_CLK_SELECT_REG;
    reg     [31:0]              CGRA_CLK_SELECT_REG;
    reg     [31:0]              TIMER0_CLK_SELECT_REG;
    reg     [31:0]              TIMER1_CLK_SELECT_REG;
    reg     [31:0]              UART0_CLK_SELECT_REG;
    reg     [31:0]              UART1_CLK_SELECT_REG;
    reg     [31:0]              WDOG_CLK_SELECT_REG;
    reg     [31:0]              CLK_GATE_EN_REG;
    reg     [31:0]              SYS_RESET_PROP_REG;
    reg     [31:0]              RESET_REQ_REG;
    reg     [31:0]              SYS_TICK_CONFIG_REG;
    reg     [31:0]              SYS_RESET_AGGR_REG;
    reg     [31:0]              MASTER_CLK_SELECT_REG;

    wire    [31:0]              w_RESET_ACK_REG;

    //
    // AHB to APB
    //

    cmsdk_ahb_to_apb #(
        .ADDRWIDTH              (12),
        .REGISTER_RDATA         (1),
        .REGISTER_WDATA         (1)
    ) u_cmsdk_ahb_apb_bridge (
        .HCLK                   (HCLK),
        .HRESETn                (HRESETn),
        .PCLKEN                 (1'b1),

        .HSEL                   (HSEL),
        .HADDR                  (HADDR[11:0]),
        .HTRANS                 (HTRANS),
        .HSIZE                  (HSIZE),
        .HPROT                  (HPROT),
        .HWRITE                 (HWRITE),
        .HREADY                 (HREADYMUX),
        .HWDATA                 (HWDATA),

        .HREADYOUT              (HREADYOUT),
        .HRDATA                 (HRDATA),
        .HRESP                  (HRESP[0]),

        .PADDR                  (w_PADDR),
        .PENABLE                (w_PENABLE),
        .PWRITE                 (w_PWRITE),
        .PSTRB                  (/*unused*/),
        .PPROT                  (/*unused*/),
        .PWDATA                 (w_PWDATA),
        .PSEL                   (w_PSEL),

        .APBACTIVE              (/*unused*/),

        .PRDATA                 (w_PRDATA),
        .PREADY                 (w_PREADY),
        .PSLVERR                (w_PSLVERR)
    );

    assign HRESP[1] = 1'b0;

    //
    // APB Control Signals
    //

    assign apb_addr_oft         = w_PADDR[6:2];
    assign apb_setup_phase      = w_PSEL & ~w_PENABLE;
    assign apb_rd_en            = apb_setup_phase & ~w_PWRITE;
    assign apb_wr_en            = apb_setup_phase & w_PWRITE;

    //
    // PAD_STRENGTH_CTRL_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            PAD_STRENGTH_CTRL_REG   <= {32{1'b0}};
        else if (apb_wr_en && (apb_addr_oft == 5'd1))
            PAD_STRENGTH_CTRL_REG   <= w_PWDATA;

    //
    // SYS_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) begin
            SYS_CLK_SELECT_REG      <= 32'h00000001;
            SYS_CLK_SELECT_SWMOD    <= 1'b0;
        end
        else begin
            if (apb_wr_en && (apb_addr_oft == 5'd2)) begin
                SYS_CLK_SELECT_REG      <= w_PWDATA;
                SYS_CLK_SELECT_SWMOD    <= 1'b1;
            end
            else
                SYS_CLK_SELECT_SWMOD    <= 1'b0;
        end

    //
    // DMA0_PCLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            DMA0_PCLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd5))
            DMA0_PCLK_SELECT_REG   <= w_PWDATA;


    //
    // DMA1_PCLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            DMA1_PCLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd6))
            DMA1_PCLK_SELECT_REG   <= w_PWDATA;

    //
    // TLX_FWD_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            TLX_FWD_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd8))
            TLX_FWD_CLK_SELECT_REG   <= w_PWDATA;

    //
    // CGRA_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            CGRA_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd10))
            CGRA_CLK_SELECT_REG   <= w_PWDATA;

    //
    // TIMER0_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            TIMER0_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd12))
            TIMER0_CLK_SELECT_REG   <= w_PWDATA;

    //
    // TIMER1_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            TIMER1_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd13))
            TIMER1_CLK_SELECT_REG   <= w_PWDATA;

    //
    // UART0_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            UART0_CLK_SELECT_REG   <= 32'h00000001;
        else if (apb_wr_en && (apb_addr_oft == 5'd14))
            UART0_CLK_SELECT_REG   <= w_PWDATA;

    //
    // UART1_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            UART1_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd15))
            UART1_CLK_SELECT_REG   <= w_PWDATA;

    //
    // WDOG_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            WDOG_CLK_SELECT_REG   <= 32'h00000005;
        else if (apb_wr_en && (apb_addr_oft == 5'd16))
            WDOG_CLK_SELECT_REG   <= w_PWDATA;

    //
    // CLK_GATE_EN_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            CLK_GATE_EN_REG   <= 32'h00007D5C;
        else if (apb_wr_en && (apb_addr_oft == 5'd17))
            CLK_GATE_EN_REG   <= w_PWDATA;

    //
    // SYS_RESET_PROP_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            SYS_RESET_PROP_REG   <= 32'h00007F78;
        else if (apb_wr_en && (apb_addr_oft == 5'd18))
            SYS_RESET_PROP_REG   <= w_PWDATA;

    //
    // RESET_REQ_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            RESET_REQ_REG   <= 32'h00007DD8;
        else if (apb_wr_en && (apb_addr_oft == 5'd19))
            RESET_REQ_REG   <= w_PWDATA;

    //
    // SYS_TICK_CONFIG_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            SYS_TICK_CONFIG_REG   <= 32'h80000000;
        else if (apb_wr_en && (apb_addr_oft == 5'd21))
            SYS_TICK_CONFIG_REG   <= w_PWDATA;

    //
    // SYS_RESET_AGGR_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            SYS_RESET_AGGR_REG   <= {32{1'b0}};
        else if (apb_wr_en && (apb_addr_oft == 5'd22))
            SYS_RESET_AGGR_REG   <= w_PWDATA;

    //
    // MASTER_CLK_SELECT_REG
    //

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            MASTER_CLK_SELECT_REG   <= {32{1'b0}};
        else if (apb_wr_en && (apb_addr_oft == 5'd23))
            MASTER_CLK_SELECT_REG   <= w_PWDATA;

    //
    // Read Data
    //

    always @(*)
        case (apb_addr_oft)
            5'd0    : apb_rdata_reg = 32'h5A5A5A5A;
            5'd1    : apb_rdata_reg = PAD_STRENGTH_CTRL_REG;
            5'd2    : apb_rdata_reg = SYS_CLK_SELECT_REG;
            5'd5    : apb_rdata_reg = DMA0_PCLK_SELECT_REG;
            5'd6    : apb_rdata_reg = DMA1_PCLK_SELECT_REG;
            5'd8    : apb_rdata_reg = TLX_FWD_CLK_SELECT_REG;
            5'd10   : apb_rdata_reg = CGRA_CLK_SELECT_REG;
            5'd12   : apb_rdata_reg = TIMER0_CLK_SELECT_REG;
            5'd13   : apb_rdata_reg = TIMER1_CLK_SELECT_REG;
            5'd14   : apb_rdata_reg = UART0_CLK_SELECT_REG;
            5'd15   : apb_rdata_reg = UART1_CLK_SELECT_REG;
            5'd16   : apb_rdata_reg = WDOG_CLK_SELECT_REG;
            5'd17   : apb_rdata_reg = CLK_GATE_EN_REG;
            5'd18   : apb_rdata_reg = SYS_RESET_PROP_REG;
            5'd19   : apb_rdata_reg = RESET_REQ_REG;
            5'd20   : apb_rdata_reg = w_RESET_ACK_REG;
            5'd21   : apb_rdata_reg = SYS_TICK_CONFIG_REG;
            5'd22   : apb_rdata_reg = SYS_RESET_AGGR_REG;
            5'd23   : apb_rdata_reg = MASTER_CLK_SELECT_REG;
            default : apb_rdata_reg = {32{1'b0}};
        endcase

    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)
            apb_rdata   <= {32{1'b0}};
        else if (apb_rd_en)
            apb_rdata   <= apb_rdata_reg;

    //
    // APB Outputs
    //

    assign w_PRDATA             = apb_rdata;
    assign w_PREADY             = 1'b1;
    assign w_PSLVERR            = 1'b0;

    //
    // Control Signals
    //

    assign w_RESET_ACK_REG  = { 17'd0,
                                H2L_RESET_ACK_REG_WDOG_w,
                                H2L_RESET_ACK_REG_UART1_w,
                                H2L_RESET_ACK_REG_UART0_w,
                                H2L_RESET_ACK_REG_TIMER1_w,
                                H2L_RESET_ACK_REG_TIMER0_w,
                                H2L_RESET_ACK_REG_NIC_w,
                                H2L_RESET_ACK_REG_GGRA_w,
                                H2L_RESET_ACK_REG_TLX_REV_w,
                                H2L_RESET_ACK_REG_TLX_FWD_w,
                                1'b0,
                                H2L_RESET_ACK_REG_DMA1_w,
                                H2L_RESET_ACK_REG_DMA0_w,
                                3'b000};


    // PAD_STRENGTH_CTRL_REG

    assign L2H_PAD_STRENGTH_CTRL_REG_GRP0_r = PAD_STRENGTH_CTRL_REG[2:0];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP1_r = PAD_STRENGTH_CTRL_REG[5:3];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP2_r = PAD_STRENGTH_CTRL_REG[8:6];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP3_r = PAD_STRENGTH_CTRL_REG[11:9];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP4_r = PAD_STRENGTH_CTRL_REG[14:12];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP5_r = PAD_STRENGTH_CTRL_REG[17:15];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP6_r = PAD_STRENGTH_CTRL_REG[20:18];
    assign L2H_PAD_STRENGTH_CTRL_REG_GRP7_r = PAD_STRENGTH_CTRL_REG[23:21];

    // SYS_CLK_SELECT_REG

    assign L2H_SYS_CLK_SELECT_REG_SELECT_SWMOD_o    = SYS_CLK_SELECT_SWMOD;
    assign L2H_SYS_CLK_SELECT_REG_SELECT_r          = SYS_CLK_SELECT_REG[2:0];

    // DMA0_PCLK_SELECT_REG

    assign L2H_DMA0_PCLK_SELECT_REG_SELECT_r    = DMA0_PCLK_SELECT_REG[2:0];

    // DMA1_PCLK_SELECT_REG

    assign L2H_DMA1_PCLK_SELECT_REG_SELECT_r    = DMA1_PCLK_SELECT_REG[2:0];

    // TLX_FWD_CLK_SELECT_REG

    assign L2H_TLX_FWD_CLK_SELECT_REG_SELECT_r  = TLX_FWD_CLK_SELECT_REG[2:0];

    // CGRA_CLK_SELECT_REG

    assign L2H_CGRA_CLK_SELECT_REG_SELECT_r     = CGRA_CLK_SELECT_REG[2:0];

    // TIMER0_CLK_SELECT_REG

    assign L2H_TIMER0_CLK_SELECT_REG_SELECT_r   = TIMER0_CLK_SELECT_REG[2:0];

    // TIMER1_CLK_SELECT_REG

    assign L2H_TIMER1_CLK_SELECT_REG_SELECT_r   = TIMER1_CLK_SELECT_REG[2:0];

    // UART0_CLK_SELECT_REG

    assign L2H_UART0_CLK_SELECT_REG_SELECT_r    = UART0_CLK_SELECT_REG[2:0];

    // UART1_CLK_SELECT_REG

    assign L2H_UART1_CLK_SELECT_REG_SELECT_r    = UART1_CLK_SELECT_REG[2:0];

    // WDOG_CLK_SELECT_REG

    assign L2H_WDOG_CLK_SELECT_REG_SELECT_r    = WDOG_CLK_SELECT_REG[2:0];

    // CLK_GATE_EN_REG

    assign L2H_CLK_GATE_EN_REG_CPU_r            = CLK_GATE_EN_REG[1];
    assign L2H_CLK_GATE_EN_REG_DAP_r            = CLK_GATE_EN_REG[2];
    assign L2H_CLK_GATE_EN_REG_DMA0_r           = CLK_GATE_EN_REG[3];
    assign L2H_CLK_GATE_EN_REG_DMA1_r           = CLK_GATE_EN_REG[4];
    assign L2H_CLK_GATE_EN_REG_SRAMX_r          = CLK_GATE_EN_REG[5];
    assign L2H_CLK_GATE_EN_REG_TLX_FWD_r        = CLK_GATE_EN_REG[6];
    assign L2H_CLK_GATE_EN_REG_GGRA_r           = CLK_GATE_EN_REG[8];
    assign L2H_CLK_GATE_EN_REG_NIC_r            = CLK_GATE_EN_REG[9];
    assign L2H_CLK_GATE_EN_REG_TIMER0_r         = CLK_GATE_EN_REG[10];
    assign L2H_CLK_GATE_EN_REG_TIMER1_r         = CLK_GATE_EN_REG[11];
    assign L2H_CLK_GATE_EN_REG_UART0_r          = CLK_GATE_EN_REG[12];
    assign L2H_CLK_GATE_EN_REG_UART1_r          = CLK_GATE_EN_REG[13];
    assign L2H_CLK_GATE_EN_REG_WDOG_r           = CLK_GATE_EN_REG[14];

    // SYS_RESET_PROP_REG

    assign L2H_SYS_RESET_PROP_REG_DMA0_r        = SYS_RESET_PROP_REG[3];
    assign L2H_SYS_RESET_PROP_REG_DMA1_r        = SYS_RESET_PROP_REG[4];
    assign L2H_SYS_RESET_PROP_REG_SRAMX_r       = SYS_RESET_PROP_REG[5];
    assign L2H_SYS_RESET_PROP_REG_TLX_FWD_r     = SYS_RESET_PROP_REG[6];
    assign L2H_SYS_RESET_PROP_REG_GGRA_r        = SYS_RESET_PROP_REG[8];
    assign L2H_SYS_RESET_PROP_REG_NIC_r         = SYS_RESET_PROP_REG[9];
    assign L2H_SYS_RESET_PROP_REG_TIMER0_r      = SYS_RESET_PROP_REG[10];
    assign L2H_SYS_RESET_PROP_REG_TIMER1_r      = SYS_RESET_PROP_REG[11];
    assign L2H_SYS_RESET_PROP_REG_UART0_r       = SYS_RESET_PROP_REG[12];
    assign L2H_SYS_RESET_PROP_REG_UART1_r       = SYS_RESET_PROP_REG[13];
    assign L2H_SYS_RESET_PROP_REG_WDOG_r        = SYS_RESET_PROP_REG[14];

    // RESET_REQ_REG

    assign L2H_RESET_REQ_REG_DMA0_r             = RESET_REQ_REG[3];
    assign L2H_RESET_REQ_REG_DMA1_r             = RESET_REQ_REG[4];
    assign L2H_RESET_REQ_REG_TLX_FWD_r          = RESET_REQ_REG[6];
    assign L2H_RESET_REQ_REG_TLX_REV_r          = RESET_REQ_REG[7];
    assign L2H_RESET_REQ_REG_GGRA_r             = RESET_REQ_REG[8];
    assign L2H_RESET_REQ_REG_NIC_r              = RESET_REQ_REG[9];
    assign L2H_RESET_REQ_REG_TIMER0_r           = RESET_REQ_REG[10];
    assign L2H_RESET_REQ_REG_TIMER1_r           = RESET_REQ_REG[11];
    assign L2H_RESET_REQ_REG_UART0_r            = RESET_REQ_REG[12];
    assign L2H_RESET_REQ_REG_UART1_r            = RESET_REQ_REG[13];
    assign L2H_RESET_REQ_REG_WDOG_r             = RESET_REQ_REG[14];

    // SYS_TICK_CONFIG_REG

    assign L2H_SYS_TICK_CONFIG_REG_CALIB_r      = SYS_TICK_CONFIG_REG[23:0];
    assign L2H_SYS_TICK_CONFIG_REG_NOT_10_MS_r  = SYS_TICK_CONFIG_REG[31];

    // SYS_RESET_AGGR_REG

    assign L2H_SYS_RESET_AGGR_REG_LOCKUP_RESET_EN_r       = SYS_RESET_AGGR_REG[0];
    assign L2H_SYS_RESET_AGGR_REG_WDOG_TIMEOUT_RESET_EN_r = SYS_RESET_AGGR_REG[1];

    // MASTER_CLK_SELECT_REG

    assign L2H_MASTER_CLK_SELECT_SELECT_r       = MASTER_CLK_SELECT_REG[0];

endmodule
