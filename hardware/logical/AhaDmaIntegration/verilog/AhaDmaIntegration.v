//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: DMA Integration for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//
// ChangeList:
// - 02/16/2022 : changed DMA engine from ARM PL330 to AHA DMA v1.0
//------------------------------------------------------------------------------
module AhaDmaIntegration (
  // Data Interface
  input   wire              ACLK,
  input   wire              ARESETn,

  output  wire [1 :0]       AWID,
  output  wire [31:0]       AWADDR,
  output  wire [7 :0]       AWLEN,
  output  wire [2 :0]       AWSIZE,
  output  wire [1 :0]       AWBURST,
  output  wire              AWLOCK,
  output  wire [3 :0]       AWCACHE,
  output  wire [2 :0]       AWPROT,
  output  wire              AWVALID,
  input   wire              AWREADY,
  output  wire [63:0]       WDATA,
  output  wire [7 :0]       WSTRB,
  output  wire              WLAST,
  output  wire              WVALID,
  input   wire              WREADY,
  input   wire [1  :0]      BID,
  input   wire [1  :0]      BRESP,
  input   wire              BVALID,
  output  wire              BREADY,
  output  wire [1 :0]       ARID,
  output  wire [31:0]       ARADDR,
  output  wire [7 :0]       ARLEN,
  output  wire [2 :0]       ARSIZE,
  output  wire [1 :0]       ARBURST,
  output  wire              ARLOCK,
  output  wire [3 :0]       ARCACHE,
  output  wire [2 :0]       ARPROT,
  output  wire              ARVALID,
  input   wire              ARREADY,
  input   wire [1  :0]      RID,
  input   wire [63 :0]      RDATA,
  input   wire [1  :0]      RRESP,
  input   wire              RLAST,
  input   wire              RVALID,
  output  wire              RREADY,

  // Control Interface
  input   wire              PCLKEN,

  input   wire [11:0]       PADDR,
  input   wire              PENABLE,
  input   wire              PWRITE,
  input   wire              PSEL,
  input   wire [31:0]       PWDATA,
  output  wire [31:0]       PRDATA,
  output  wire              PREADY,
  output  wire              PSLVERR,

  // Interrupts
  output  wire [1:0]        IRQ,
  output  wire              IRQ_ABORT
);

    wire        unused      = PCLKEN;
    wire        dma_irq;
    wire [31:0] apb_paddr   = {{20{1'b0}}, PADDR};

    //
    // Instantiation of AHA DMA
    //
    DMA dma_inst (
        .ACLK               (ACLK),
        .ARESETn            (ARESETn),
        .Irq                (dma_irq),
        .M_AXI_AWID         (AWID),
        .M_AXI_AWADDR       (AWADDR),
        .M_AXI_AWLEN        (AWLEN),
        .M_AXI_AWSIZE       (AWSIZE),
        .M_AXI_AWBURST      (AWBURST),
        .M_AXI_AWLOCK       (AWLOCK),
        .M_AXI_AWCACHE      (AWCACHE),
        .M_AXI_AWPROT       (AWPROT),
        .M_AXI_AWVALID      (AWVALID),
        .M_AXI_AWREADY      (AWREADY),
        .M_AXI_WDATA        (WDATA),
        .M_AXI_WSTRB        (WSTRB),
        .M_AXI_WLAST        (WLAST),
        .M_AXI_WVALID       (WVALID),
        .M_AXI_WREADY       (WREADY),
        .M_AXI_BID          (BID),
        .M_AXI_BRESP        (BRESP),
        .M_AXI_BVALID       (BVALID),
        .M_AXI_BREADY       (BREADY),
        .M_AXI_ARID         (ARID),
        .M_AXI_ARADDR       (ARADDR),
        .M_AXI_ARLEN        (ARLEN),
        .M_AXI_ARSIZE       (ARSIZE),
        .M_AXI_ARBURST      (ARBURST),
        .M_AXI_ARLOCK       (ARLOCK),
        .M_AXI_ARCACHE      (ARCACHE),
        .M_AXI_ARPROT       (ARPROT),
        .M_AXI_ARVALID      (ARVALID),
        .M_AXI_ARREADY      (ARREADY),
        .M_AXI_RID          (RID),
        .M_AXI_RDATA        (RDATA),
        .M_AXI_RRESP        (RRESP),
        .M_AXI_RLAST        (RLAST),
        .M_AXI_RVALID       (RVALID),
        .M_AXI_RREADY       (RREADY),
        .RegIntf_PADDR      (apb_paddr),
        .RegIntf_PSEL       (PSEL),
        .RegIntf_PENABLE    (PENABLE),
        .RegIntf_PWRITE     (PWRITE),
        .RegIntf_PWDATA     (PWDATA),
        .RegIntf_PREADY     (PREADY),
        .RegIntf_PRDATA     (PRDATA),
        .RegIntf_PSLVERR    (PSLVERR)
    );

    //
    // IRQ Output Assignments
    //
    assign IRQ          = {1'b0, dma_irq};
    assign IRQ_ABORT    = 1'b0;
endmodule
