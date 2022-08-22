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
    input   wire            CLK_IN_EXTERN,          // BUMP
    input   wire            CLK_IN_SYSTEM,
    input   wire [1:0]      CLK_SELECT,             // BUMP
    input   wire            RESETn,

    output  wire            CLK_DIV_8,              // BUMP

    // Ring Oscillator Control Interface
    input   wire [31:0]     RO_PADDR,
    input   wire            RO_PSEL,
    input   wire            RO_PENABLE,
    input   wire            RO_PWRITE,
    input   wire [31:0]     RO_PWDATA,
    output  wire [31:0]     RO_PRDATA,
    output  wire            RO_PREADY,
    output  wire            RO_PSLVERR,

    // XGCD0 Control Interface (255)
    input   wire [31:0]     XGCD0_PADDR,
    input   wire            XGCD0_PSEL,
    input   wire            XGCD0_PENABLE,
    input   wire            XGCD0_PWRITE,
    input   wire [31:0]     XGCD0_PWDATA,
    output  wire [31:0]     XGCD0_PRDATA,
    output  wire            XGCD0_PREADY,
    output  wire            XGCD0_PSLVERR,

    // XGCD0 Data Interface
    input   wire [3:0]      XGCD0_AWID,
    input   wire [31:0]     XGCD0_AWADDR,
    input   wire [7:0]      XGCD0_AWLEN,
    input   wire [2:0]      XGCD0_AWSIZE,
    input   wire [1:0]      XGCD0_AWBURST,
    input   wire            XGCD0_AWLOCK,
    input   wire [3:0]      XGCD0_AWCACHE,
    input   wire [2:0]      XGCD0_AWPROT,
    input   wire            XGCD0_AWVALID,
    output  wire            XGCD0_AWREADY,

    input   wire [63:0]     XGCD0_WDATA,
    input   wire [7:0]      XGCD0_WSTRB,
    input   wire            XGCD0_WLAST,
    input   wire            XGCD0_WVALID,
    output  wire            XGCD0_WREADY,

    output  wire [3:0]      XGCD0_BID,
    output  wire [1:0]      XGCD0_BRESP,
    output  wire            XGCD0_BVALID,
    input   wire            XGCD0_BREADY,

    input   wire [3:0]      XGCD0_ARID,
    input   wire [31:0]     XGCD0_ARADDR,
    input   wire [7:0]      XGCD0_ARLEN,
    input   wire [2:0]      XGCD0_ARSIZE,
    input   wire [1:0]      XGCD0_ARBURST,
    input   wire            XGCD0_ARLOCK,
    input   wire [3:0]      XGCD0_ARCACHE,
    input   wire [2:0]      XGCD0_ARPROT,
    input   wire            XGCD0_ARVALID,
    output  wire            XGCD0_ARREADY,

    output  wire [3:0]      XGCD0_RID,
    output  wire [63:0]     XGCD0_RDATA,
    output  wire [1:0]      XGCD0_RRESP,
    output  wire            XGCD0_RLAST,
    output  wire            XGCD0_RVALID,
    input   wire            XGCD0_RREADY,

    // XGCD0 Interrupt
    output  wire            XGCD0_IRQ,

    // XGCD1 Control Interface (1279)
    input   wire [31:0]     XGCD1_PADDR,
    input   wire            XGCD1_PSEL,
    input   wire            XGCD1_PENABLE,
    input   wire            XGCD1_PWRITE,
    input   wire [31:0]     XGCD1_PWDATA,
    output  wire [31:0]     XGCD1_PRDATA,
    output  wire            XGCD1_PREADY,
    output  wire            XGCD1_PSLVERR,

    // XGCD1 Data Interface
    input   wire [3:0]      XGCD1_AWID,
    input   wire [31:0]     XGCD1_AWADDR,
    input   wire [7:0]      XGCD1_AWLEN,
    input   wire [2:0]      XGCD1_AWSIZE,
    input   wire [1:0]      XGCD1_AWBURST,
    input   wire            XGCD1_AWLOCK,
    input   wire [3:0]      XGCD1_AWCACHE,
    input   wire [2:0]      XGCD1_AWPROT,
    input   wire            XGCD1_AWVALID,
    output  wire            XGCD1_AWREADY,

    input   wire [63:0]     XGCD1_WDATA,
    input   wire [7:0]      XGCD1_WSTRB,
    input   wire            XGCD1_WLAST,
    input   wire            XGCD1_WVALID,
    output  wire            XGCD1_WREADY,

    output  wire [3:0]      XGCD1_BID,
    output  wire [1:0]      XGCD1_BRESP,
    output  wire            XGCD1_BVALID,
    input   wire            XGCD1_BREADY,

    input   wire [3:0]      XGCD1_ARID,
    input   wire [31:0]     XGCD1_ARADDR,
    input   wire [7:0]      XGCD1_ARLEN,
    input   wire [2:0]      XGCD1_ARSIZE,
    input   wire [1:0]      XGCD1_ARBURST,
    input   wire            XGCD1_ARLOCK,
    input   wire [3:0]      XGCD1_ARCACHE,
    input   wire [2:0]      XGCD1_ARPROT,
    input   wire            XGCD1_ARVALID,
    output  wire            XGCD1_ARREADY,

    output  wire [3:0]      XGCD1_RID,
    output  wire [63:0]     XGCD1_RDATA,
    output  wire [1:0]      XGCD1_RRESP,
    output  wire            XGCD1_RLAST,
    output  wire            XGCD1_RVALID,
    input   wire            XGCD1_RREADY,

    // XGCD0 Interrupt
    output  wire            XGCD1_IRQ,

    // Output Bump Signals
    output  wire            XGCD0_START,            // BUMP
    output  wire            XGCD1_START,            // BUMP
    output  wire            XGCD0_DONE,             // BUMP
    output  wire            XGCD1_DONE              // BUMP
);

endmodule
