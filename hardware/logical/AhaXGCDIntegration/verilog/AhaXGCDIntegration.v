//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : XGCD Integration
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 14, 2022
//------------------------------------------------------------------------------

module AhaXGCDIntegration (
    // Clocks and Reset
    input       wire            XGCD_EXT_CLK,           // from BUMP
    input       wire            XGCD_SOC_CLK,           // from SoC Master Clock
    input       wire [1:0]      XGCD_CLK_SELECT,        // from BUMP
    input       wire            PORESETn,

    output      wire            XGCD_DIV8_CLK,          // to BUMP and SoC

    // Register Space Interface
    input       wire [31:0]     XGCD_HADDR,
    input       wire [2:0]      XGCD_HBURST,
    input       wire [3:0]      XGCD_HPROT,
    input       wire [2:0]      XGCD_HSIZE,
    input       wire [1:0]      XGCD_HTRANS,
    input       wire [31:0]     XGCD_HWDATA,
    input       wire            XGCD_HWRITE,
    output      wire [31:0]     XGCD_HRDATA,
    output      wire            XGCD_HREADYOUT,
    output      wire            XGCD_HRESP,
    input       wire            XGCD_HSELx,
    input       wire            XGCD_HREADY,

    // XGCD0 Data Interface
    input       wire [3:0]      XGCD0_AWID,
    input       wire [31:0]     XGCD0_AWADDR,
    input       wire [7:0]      XGCD0_AWLEN,
    input       wire [2:0]      XGCD0_AWSIZE,
    input       wire [1:0]      XGCD0_AWBURST,
    input       wire            XGCD0_AWLOCK,
    input       wire [3:0]      XGCD0_AWCACHE,
    input       wire [2:0]      XGCD0_AWPROT,
    input       wire            XGCD0_AWVALID,
    output      wire            XGCD0_AWREADY,
    input       wire [63:0]     XGCD0_WDATA,
    input       wire [7:0]      XGCD0_WSTRB,
    input       wire            XGCD0_WLAST,
    input       wire            XGCD0_WVALID,
    output      wire            XGCD0_WREADY,
    output      wire [3:0]      XGCD0_BID,
    output      wire [1:0]      XGCD0_BRESP,
    output      wire            XGCD0_BVALID,
    input       wire            XGCD0_BREADY,
    input       wire [3:0]      XGCD0_ARID,
    input       wire [31:0]     XGCD0_ARADDR,
    input       wire [7:0]      XGCD0_ARLEN,
    input       wire [2:0]      XGCD0_ARSIZE,
    input       wire [1:0]      XGCD0_ARBURST,
    input       wire            XGCD0_ARLOCK,
    input       wire [3:0]      XGCD0_ARCACHE,
    input       wire [2:0]      XGCD0_ARPROT,
    input       wire            XGCD0_ARVALID,
    output      wire            XGCD0_ARREADY,
    output      wire [3:0]      XGCD0_RID,
    output      wire [63:0]     XGCD0_RDATA,
    output      wire [1:0]      XGCD0_RRESP,
    output      wire            XGCD0_RLAST,
    output      wire            XGCD0_RVALID,
    input       wire            XGCD0_RREADY,

    // XGCD1 Data Interface
    input       wire [3:0]      XGCD1_AWID,
    input       wire [31:0]     XGCD1_AWADDR,
    input       wire [7:0]      XGCD1_AWLEN,
    input       wire [2:0]      XGCD1_AWSIZE,
    input       wire [1:0]      XGCD1_AWBURST,
    input       wire            XGCD1_AWLOCK,
    input       wire [3:0]      XGCD1_AWCACHE,
    input       wire [2:0]      XGCD1_AWPROT,
    input       wire            XGCD1_AWVALID,
    output      wire            XGCD1_AWREADY,
    input       wire [63:0]     XGCD1_WDATA,
    input       wire [7:0]      XGCD1_WSTRB,
    input       wire            XGCD1_WLAST,
    input       wire            XGCD1_WVALID,
    output      wire            XGCD1_WREADY,
    output      wire [3:0]      XGCD1_BID,
    output      wire [1:0]      XGCD1_BRESP,
    output      wire            XGCD1_BVALID,
    input       wire            XGCD1_BREADY,
    input       wire [3:0]      XGCD1_ARID,
    input       wire [31:0]     XGCD1_ARADDR,
    input       wire [7:0]      XGCD1_ARLEN,
    input       wire [2:0]      XGCD1_ARSIZE,
    input       wire [1:0]      XGCD1_ARBURST,
    input       wire            XGCD1_ARLOCK,
    input       wire [3:0]      XGCD1_ARCACHE,
    input       wire [2:0]      XGCD1_ARPROT,
    input       wire            XGCD1_ARVALID,
    output      wire            XGCD1_ARREADY,
    output      wire [3:0]      XGCD1_RID,
    output      wire [63:0]     XGCD1_RDATA,
    output      wire [1:0]      XGCD1_RRESP,
    output      wire            XGCD1_RLAST,
    output      wire            XGCD1_RVALID,
    input       wire            XGCD1_RREADY,

    // XGCD Interrupts
    output      wire            XGCD0_INT,
    output      wire            XGCD1_INT,

    // Output Bump Signals
    output      wire            XGCD0_START,        // BUMP
    output      wire            XGCD1_START,        // BUMP
    output      wire            XGCD0_DONE,         // BUMP
    output      wire            XGCD1_DONE          // BUMP
);

    //
    // Wrapper Reset Synchronization
    //

    wire        sync_RESETn;

    AhaResetSync u_aha_reset_sync (
        .CLK                    (XGCD_DIV8_CLK),
        .Dn                     (PORESETn),
        .Qn                     (sync_RESETn)
    );

    //
    // AHB to APB
    //

    wire    [31:0]              w_PADDR;
    wire                        w_PENABLE;
    wire                        w_PWRITE;
    wire    [31:0]              w_PWDATA;
    wire                        w_PSEL;
    reg     [31:0]              r_PRDATA;
    reg                         r_PREADY;
    reg                         r_PSLVERR;

    wire                        w_PSEL_RO;
    wire                        w_PSEL_XGCD0;
    wire                        w_PSEL_XGCD1;

    wire    [31:0]              w_PRDATA_RO;
    wire    [31:0]              w_PRDATA_XGCD0;
    wire    [31:0]              w_PRDATA_XGCD1;

    wire                        w_PREADY_R0;
    wire                        w_PREADY_XGCD0;
    wire                        w_PREADY_XGCD1;

    wire                        w_PSLVERR_RO;
    wire                        w_PSLVERR_XGCD0;
    wire                        w_PSLVERR_XGCD1;

    always @(*)
    begin
        case (w_PADDR[31:12])
            20'h40014  : begin
                r_PRDATA    = w_PRDATA_RO;
                r_PREADY    = w_PREADY_R0;
                r_PSLVERR   = w_PSLVERR_RO;
            end
            20'h40016   : begin
                r_PRDATA    = w_PRDATA_XGCD0;
                r_PREADY    = w_PREADY_XGCD0;
                r_PSLVERR   = w_PSLVERR_XGCD0;
            end
            20'h40018  : begin
                r_PRDATA    = w_PRDATA_XGCD1;
                r_PREADY    = w_PREADY_XGCD1;
                r_PSLVERR   = w_PSLVERR_XGCD1;
            end
            default : begin
                r_PRDATA    = {32{1'b0}};
                r_PREADY    = 1'b1;
                r_PSLVERR   = 1'b0;
            end
        endcase
    end

    assign w_PSEL_RO    = w_PSEL && (w_PADDR[31:12] == 20'h40014);
    assign w_PSEL_XGCD0 = w_PSEL && (w_PADDR[31:12] == 20'h40016);
    assign w_PSEL_XGCD1 = w_PSEL && (w_PADDR[31:12] == 20'h40018);

    cmsdk_ahb_to_apb #(
        .ADDRWIDTH              (32),
        .REGISTER_RDATA         (1),
        .REGISTER_WDATA         (0)
    ) u_cmsdk_ahb_apb_bridge (
        .HCLK                   (XGCD_DIV8_CLK),
        .HRESETn                (sync_RESETn),
        .PCLKEN                 (1'b1),

        .HSEL                   (XGCD_HSELx),
        .HADDR                  (XGCD_HADDR),
        .HTRANS                 (XGCD_HTRANS),
        .HSIZE                  (XGCD_HSIZE),
        .HPROT                  (XGCD_HPROT),
        .HWRITE                 (XGCD_HWRITE),
        .HREADY                 (XGCD_HREADY),
        .HWDATA                 (XGCD_HWDATA),

        .HREADYOUT              (XGCD_HREADYOUT),
        .HRDATA                 (XGCD_HRDATA),
        .HRESP                  (XGCD_HRESP),

        .PADDR                  (w_PADDR),
        .PENABLE                (w_PENABLE),
        .PWRITE                 (w_PWRITE),
        .PSTRB                  (/*unused*/),
        .PPROT                  (/*unused*/),
        .PWDATA                 (w_PWDATA),
        .PSEL                   (w_PSEL),

        .APBACTIVE              (/*unused*/),

        .PRDATA                 (r_PRDATA),
        .PREADY                 (r_PREADY),
        .PSLVERR                (r_PSLVERR)
    );

    //
    // XGCD Wrapper
    //

    XGCDWrapperTop u_xgcd_wrapper_top (
        .clk_in_extern          (XGCD_EXT_CLK),
        .clk_in_system          (XGCD_SOC_CLK),
        .reset_n                (PORESETn),
        .clk_select             (XGCD_CLK_SELECT),
        .clk_div_8              (XGCD_DIV8_CLK),

        .start_out_255          (XGCD0_START),
        .start_out_1279         (XGCD1_START),
        .done_out_255           (XGCD0_DONE),
        .done_out_1279          (XGCD1_DONE),

        .IRQ_255                (XGCD0_INT),
        .IRQ_1279               (XGCD1_INT),

        .S_APB_PADDR_RO         (w_PADDR),
        .S_APB_PSEL_RO          (w_PSEL_RO),
        .S_APB_PENABLE_RO       (w_PENABLE),
        .S_APB_PWRITE_RO        (w_PWRITE),
        .S_APB_PWDATA_RO        (w_PWDATA),
        .S_APB_PRDATA_RO        (w_PRDATA_RO),
        .S_APB_PREADY_RO        (w_PREADY_R0),
        .S_APB_PSLVERR_RO       (w_PSLVERR_RO),

        .S_APB_PADDR_255        (w_PADDR),
        .S_APB_PSEL_255         (w_PSEL_XGCD0),
        .S_APB_PENABLE_255      (w_PENABLE),
        .S_APB_PWRITE_255       (w_PWRITE),
        .S_APB_PWDATA_255       (w_PWDATA),
        .S_APB_PRDATA_255       (w_PRDATA_XGCD0),
        .S_APB_PREADY_255       (w_PREADY_XGCD0),
        .S_APB_PSLVERR_255      (w_PSLVERR_XGCD0),

        .S_APB_PADDR_1279       (w_PADDR),
        .S_APB_PSEL_1279        (w_PSEL_XGCD1),
        .S_APB_PENABLE_1279     (w_PENABLE),
        .S_APB_PWRITE_1279      (w_PWRITE),
        .S_APB_PWDATA_1279      (w_PWDATA),
        .S_APB_PRDATA_1279      (w_PRDATA_XGCD1),
        .S_APB_PREADY_1279      (w_PREADY_XGCD1),
        .S_APB_PSLVERR_1279     (w_PSLVERR_XGCD1),

        .S_AXI_AWID_255         (XGCD0_AWID),
        .S_AXI_AWADDR_255       (XGCD0_AWADDR),
        .S_AXI_AWLEN_255        (XGCD0_AWLEN),
        .S_AXI_AWSIZE_255       (XGCD0_AWSIZE),
        .S_AXI_AWBURST_255      (XGCD0_AWBURST),
        .S_AXI_AWLOCK_255       (XGCD0_AWLOCK),
        .S_AXI_AWCACHE_255      (XGCD0_AWCACHE),
        .S_AXI_AWPROT_255       (XGCD0_AWPROT),
        .S_AXI_AWVALID_255      (XGCD0_AWVALID),
        .S_AXI_AWREADY_255      (XGCD0_AWREADY),
        .S_AXI_WDATA_255        (XGCD0_WDATA),
        .S_AXI_WSTRB_255        (XGCD0_WSTRB),
        .S_AXI_WLAST_255        (XGCD0_WLAST),
        .S_AXI_WVALID_255       (XGCD0_WVALID),
        .S_AXI_WREADY_255       (XGCD0_WREADY),
        .S_AXI_BID_255          (XGCD0_BID),
        .S_AXI_BRESP_255        (XGCD0_BRESP),
        .S_AXI_BVALID_255       (XGCD0_BVALID),
        .S_AXI_BREADY_255       (XGCD0_BREADY),
        .S_AXI_ARID_255         (XGCD0_ARID),
        .S_AXI_ARADDR_255       (XGCD0_ARADDR),
        .S_AXI_ARLEN_255        (XGCD0_ARLEN),
        .S_AXI_ARSIZE_255       (XGCD0_ARSIZE),
        .S_AXI_ARBURST_255      (XGCD0_ARBURST),
        .S_AXI_ARLOCK_255       (XGCD0_ARLOCK),
        .S_AXI_ARCACHE_255      (XGCD0_ARCACHE),
        .S_AXI_ARPROT_255       (XGCD0_ARPROT),
        .S_AXI_ARVALID_255      (XGCD0_ARVALID),
        .S_AXI_ARREADY_255      (XGCD0_ARREADY),
        .S_AXI_RID_255          (XGCD0_RID),
        .S_AXI_RDATA_255        (XGCD0_RDATA),
        .S_AXI_RRESP_255        (XGCD0_RRESP),
        .S_AXI_RLAST_255        (XGCD0_RLAST),
        .S_AXI_RVALID_255       (XGCD0_RVALID),
        .S_AXI_RREADY_255       (XGCD0_RREADY),

        .S_AXI_AWID_1279        (XGCD1_AWID),
        .S_AXI_AWADDR_1279      (XGCD1_AWADDR),
        .S_AXI_AWLEN_1279       (XGCD1_AWLEN),
        .S_AXI_AWSIZE_1279      (XGCD1_AWSIZE),
        .S_AXI_AWBURST_1279     (XGCD1_AWBURST),
        .S_AXI_AWLOCK_1279      (XGCD1_AWLOCK),
        .S_AXI_AWCACHE_1279     (XGCD1_AWCACHE),
        .S_AXI_AWPROT_1279      (XGCD1_AWPROT),
        .S_AXI_AWVALID_1279     (XGCD1_AWVALID),
        .S_AXI_AWREADY_1279     (XGCD1_AWREADY),
        .S_AXI_WDATA_1279       (XGCD1_WDATA),
        .S_AXI_WSTRB_1279       (XGCD1_WSTRB),
        .S_AXI_WLAST_1279       (XGCD1_WLAST),
        .S_AXI_WVALID_1279      (XGCD1_WVALID),
        .S_AXI_WREADY_1279      (XGCD1_WREADY),
        .S_AXI_BID_1279         (XGCD1_BID),
        .S_AXI_BRESP_1279       (XGCD1_BRESP),
        .S_AXI_BVALID_1279      (XGCD1_BVALID),
        .S_AXI_BREADY_1279      (XGCD1_BREADY),
        .S_AXI_ARID_1279        (XGCD1_ARID),
        .S_AXI_ARADDR_1279      (XGCD1_ARADDR),
        .S_AXI_ARLEN_1279       (XGCD1_ARLEN),
        .S_AXI_ARSIZE_1279      (XGCD1_ARSIZE),
        .S_AXI_ARBURST_1279     (XGCD1_ARBURST),
        .S_AXI_ARLOCK_1279      (XGCD1_ARLOCK),
        .S_AXI_ARCACHE_1279     (XGCD1_ARCACHE),
        .S_AXI_ARPROT_1279      (XGCD1_ARPROT),
        .S_AXI_ARVALID_1279     (XGCD1_ARVALID),
        .S_AXI_ARREADY_1279     (XGCD1_ARREADY),
        .S_AXI_RID_1279         (XGCD1_RID),
        .S_AXI_RDATA_1279       (XGCD1_RDATA),
        .S_AXI_RRESP_1279       (XGCD1_RRESP),
        .S_AXI_RLAST_1279       (XGCD1_RLAST),
        .S_AXI_RVALID_1279      (XGCD1_RVALID),
        .S_AXI_RREADY_1279      (XGCD1_RREADY)
    );

endmodule
