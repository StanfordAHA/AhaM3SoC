//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Dummy XGCD Wrapper
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Aug 30, 2022
//------------------------------------------------------------------------------

module XGCDWrapperTop (
    input       wire            clk_in_extern,
    input       wire            clk_in_system,
    input       wire            reset_n,
    input       wire [1:0]      clk_select,
    output      wire            clk_div_8,

    output      wire            start_out_255,
    output      wire            start_out_1279,
    output      wire            done_out_255,
    output      wire            done_out_1279,

    output      wire            IRQ_255,
    output      wire            IRQ_1279,

    input       wire [31:0]     S_APB_PADDR_RO,
    input       wire            S_APB_PSEL_RO,
    input       wire            S_APB_PENABLE_RO,
    input       wire            S_APB_PWRITE_RO,
    input       wire [31:0]     S_APB_PWDATA_RO,
    output      wire [31:0]     S_APB_PRDATA_RO,
    output      wire            S_APB_PREADY_RO,
    output      wire            S_APB_PSLVERR_RO,

    input       wire [31:0]     S_APB_PADDR_255,
    input       wire            S_APB_PSEL_255,
    input       wire            S_APB_PENABLE_255,
    input       wire            S_APB_PWRITE_255,
    input       wire [31:0]     S_APB_PWDATA_255,
    output      wire [31:0]     S_APB_PRDATA_255,
    output      wire            S_APB_PREADY_255,
    output      wire            S_APB_PSLVERR_255,

    input       wire [31:0]     S_APB_PADDR_1279,
    input       wire            S_APB_PSEL_1279,
    input       wire            S_APB_PENABLE_1279,
    input       wire            S_APB_PWRITE_1279,
    input       wire [31:0]     S_APB_PWDATA_1279,
    output      wire [31:0]     S_APB_PRDATA_1279,
    output      wire            S_APB_PREADY_1279,
    output      wire            S_APB_PSLVERR_1279,

    input       wire [3:0]      S_AXI_AWID_255,
    input       wire [31:0]     S_AXI_AWADDR_255,
    input       wire [7:0]      S_AXI_AWLEN_255,
    input       wire [2:0]      S_AXI_AWSIZE_255,
    input       wire [1:0]      S_AXI_AWBURST_255,
    input       wire            S_AXI_AWLOCK_255,
    input       wire [3:0]      S_AXI_AWCACHE_255,
    input       wire [2:0]      S_AXI_AWPROT_255,
    input       wire            S_AXI_AWVALID_255,
    output      wire            S_AXI_AWREADY_255,
    input       wire [63:0]     S_AXI_WDATA_255,
    input       wire [7:0]      S_AXI_WSTRB_255,
    input       wire            S_AXI_WLAST_255,
    input       wire            S_AXI_WVALID_255,
    output      wire            S_AXI_WREADY_255,
    output      wire [3:0]      S_AXI_BID_255,
    output      wire [1:0]      S_AXI_BRESP_255,
    output      wire            S_AXI_BVALID_255,
    input       wire            S_AXI_BREADY_255,
    input       wire [3:0]      S_AXI_ARID_255,
    input       wire [31:0]     S_AXI_ARADDR_255,
    input       wire [7:0]      S_AXI_ARLEN_255,
    input       wire [2:0]      S_AXI_ARSIZE_255,
    input       wire [1:0]      S_AXI_ARBURST_255,
    input       wire            S_AXI_ARLOCK_255,
    input       wire [3:0]      S_AXI_ARCACHE_255,
    input       wire [2:0]      S_AXI_ARPROT_255,
    input       wire            S_AXI_ARVALID_255,
    output      wire            S_AXI_ARREADY_255,
    output      wire [3:0]      S_AXI_RID_255,
    output      wire [63:0]     S_AXI_RDATA_255,
    output      wire [1:0]      S_AXI_RRESP_255,
    output      wire            S_AXI_RLAST_255,
    output      wire            S_AXI_RVALID_255,
    input       wire            S_AXI_RREADY_255,

    input       wire [3:0]      S_AXI_AWID_1279,
    input       wire [31:0]     S_AXI_AWADDR_1279,
    input       wire [7:0]      S_AXI_AWLEN_1279,
    input       wire [2:0]      S_AXI_AWSIZE_1279,
    input       wire [1:0]      S_AXI_AWBURST_1279,
    input       wire            S_AXI_AWLOCK_1279,
    input       wire [3:0]      S_AXI_AWCACHE_1279,
    input       wire [2:0]      S_AXI_AWPROT_1279,
    input       wire            S_AXI_AWVALID_1279,
    output      wire            S_AXI_AWREADY_1279,
    input       wire [63:0]     S_AXI_WDATA_1279,
    input       wire [7:0]      S_AXI_WSTRB_1279,
    input       wire            S_AXI_WLAST_1279,
    input       wire            S_AXI_WVALID_1279,
    output      wire            S_AXI_WREADY_1279,
    output      wire [3:0]      S_AXI_BID_1279,
    output      wire [1:0]      S_AXI_BRESP_1279,
    output      wire            S_AXI_BVALID_1279,
    input       wire            S_AXI_BREADY_1279,
    input       wire [3:0]      S_AXI_ARID_1279,
    input       wire [31:0]     S_AXI_ARADDR_1279,
    input       wire [7:0]      S_AXI_ARLEN_1279,
    input       wire [2:0]      S_AXI_ARSIZE_1279,
    input       wire [1:0]      S_AXI_ARBURST_1279,
    input       wire            S_AXI_ARLOCK_1279,
    input       wire [3:0]      S_AXI_ARCACHE_1279,
    input       wire [2:0]      S_AXI_ARPROT_1279,
    input       wire            S_AXI_ARVALID_1279,
    output      wire            S_AXI_ARREADY_1279,
    output      wire [3:0]      S_AXI_RID_1279,
    output      wire [63:0]     S_AXI_RDATA_1279,
    output      wire [1:0]      S_AXI_RRESP_1279,
    output      wire            S_AXI_RLAST_1279,
    output      wire            S_AXI_RVALID_1279,
    input       wire            S_AXI_RREADY_1279
);

    // Prevent Linting Messages
    wire unused =   clk_in_extern           |
                    clk_in_system           |
                    reset_n                 |
                    (|clk_select)           |
                    (|S_APB_PADDR_RO)       |
                    S_APB_PSEL_RO           |
                    S_APB_PENABLE_RO        |
                    S_APB_PWRITE_RO         |
                    (|S_APB_PWDATA_RO)      |
                    (|S_APB_PADDR_255)      |
                    S_APB_PSEL_255          |
                    S_APB_PENABLE_255       |
                    S_APB_PWRITE_255        |
                    (|S_APB_PWDATA_255)     |
                    (|S_APB_PADDR_1279)     |
                    S_APB_PSEL_1279         |
                    S_APB_PENABLE_1279      |
                    S_APB_PWRITE_1279       |
                    (|S_APB_PWDATA_1279)    |
                    (|S_AXI_AWID_255)       |
                    (|S_AXI_AWADDR_255)     |
                    (|S_AXI_AWLEN_255)      |
                    (|S_AXI_AWSIZE_255)     |
                    (|S_AXI_AWBURST_255)    |
                    S_AXI_AWLOCK_255        |
                    (|S_AXI_AWCACHE_255)    |
                    (|S_AXI_AWPROT_255)     |
                    S_AXI_AWVALID_255       |
                    (|S_AXI_WDATA_255)      |
                    (|S_AXI_WSTRB_255)      |
                    S_AXI_WLAST_255         |
                    S_AXI_WVALID_255        |
                    S_AXI_BREADY_255        |
                    (|S_AXI_ARID_255)       |
                    (|S_AXI_ARADDR_255)     |
                    (|S_AXI_ARLEN_255)      |
                    (|S_AXI_ARSIZE_255)     |
                    (|S_AXI_ARBURST_255)    |
                    S_AXI_ARLOCK_255        |
                    (|S_AXI_ARCACHE_255)    |
                    (|S_AXI_ARPROT_255)     |
                    S_AXI_ARVALID_255       |
                    S_AXI_RREADY_255        |
                    (|S_AXI_AWID_1279)      |
                    (|S_AXI_AWADDR_1279)    |
                    (|S_AXI_AWLEN_1279)     |
                    (|S_AXI_AWSIZE_1279)    |
                    (|S_AXI_AWBURST_1279)   |
                    S_AXI_AWLOCK_1279       |
                    (|S_AXI_AWCACHE_1279)   |
                    (|S_AXI_AWPROT_1279)    |
                    S_AXI_AWVALID_1279      |
                    (|S_AXI_WDATA_1279)     |
                    (|S_AXI_WSTRB_1279)     |
                    S_AXI_WLAST_1279        |
                    S_AXI_WVALID_1279       |
                    S_AXI_BREADY_1279       |
                    (|S_AXI_ARID_1279)      |
                    (|S_AXI_ARADDR_1279)    |
                    (|S_AXI_ARLEN_1279)     |
                    (|S_AXI_ARSIZE_1279)    |
                    (|S_AXI_ARBURST_1279)   |
                    S_AXI_ARLOCK_1279       |
                    (|S_AXI_ARCACHE_1279)   |
                    (|S_AXI_ARPROT_1279)    |
                    S_AXI_ARVALID_1279      |
                    S_AXI_RREADY_1279       ;

    //
    // Output Assignments
    //

    assign clk_div_8            = 1'b0;

    assign start_out_255        = 1'b0;
    assign start_out_1279       = 1'b0;
    assign done_out_255         = 1'b0;
    assign done_out_1279        = 1'b0;

    assign IRQ_255              = 1'b0;
    assign IRQ_1279             = 1'b0;

    assign S_APB_PRDATA_RO      = {32{1'b0}};
    assign S_APB_PREADY_RO      = 1'b1;
    assign S_APB_PSLVERR_RO     = 1'b0;

    assign S_APB_PRDATA_255     = {32{1'b0}};
    assign S_APB_PREADY_255     = 1'b1;
    assign S_APB_PSLVERR_255    = 1'b0;

    assign S_APB_PRDATA_1279    = {32{1'b0}};
    assign S_APB_PREADY_1279    = 1'b1;
    assign S_APB_PSLVERR_1279   = 1'b0;

    assign S_AXI_AWREADY_255    = 1'b1;
    assign S_AXI_WREADY_255     = 1'b1;
    assign S_AXI_BID_255        = 4'h0;
    assign S_AXI_BRESP_255      = 2'b00;
    assign S_AXI_BVALID_255     = 1'b0;
    assign S_AXI_ARREADY_255    = 1'b1;
    assign S_AXI_RID_255        = 4'h0;
    assign S_AXI_RDATA_255      = {64{1'b0}};
    assign S_AXI_RRESP_255      = 2'b00;
    assign S_AXI_RLAST_255      = 1'b0;
    assign S_AXI_RVALID_255     = 1'b0;

    assign S_AXI_AWREADY_1279   = 1'b1;
    assign S_AXI_WREADY_1279    = 1'b1;
    assign S_AXI_BID_1279       = 4'h0;
    assign S_AXI_BRESP_1279     = 2'b00;
    assign S_AXI_BVALID_1279    = 1'b0;
    assign S_AXI_ARREADY_1279   = 1'b1;
    assign S_AXI_RID_1279       = 4'h0;
    assign S_AXI_RDATA_1279     = {64{1'b0}};
    assign S_AXI_RRESP_1279     = 2'b00;
    assign S_AXI_RLAST_1279     = 1'b0;
    assign S_AXI_RVALID_1279    = 1'b0;

endmodule
