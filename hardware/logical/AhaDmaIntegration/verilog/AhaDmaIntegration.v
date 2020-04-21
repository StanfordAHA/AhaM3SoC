//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: DMA Integration for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
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

  wire [1:0]  int_awlock;
  wire [1:0]  int_arlock;

  pl330_dma_AhaIntegration u_pl330_dma (
    // Global Signals
    .aclk                   (ACLK),
    .aresetn                (ARESETn),

    //----------------------------------------
    // Boot Interface
    //----------------------------------------
    .boot_from_pc           (1'b0),
    .boot_addr              ({32{1'b0}}),
    .boot_manager_ns        (1'b0),
    .boot_irq_ns            (2'b11),
    .boot_periph_ns         (1'b1),

    //----------------------------------------
    // Periph Request Interfaces
    //----------------------------------------
    // Peripheral Interface [0]
    .drvalid_0              (1'b0),
    .drtype_0               (2'b00),
    .drready_0              (/*unused*/),
    .drlast_0               (1'b0),
    .davalid_0              (/*unused*/),
    .datype_0               (/*unused*/),
    .daready_0              (1'b1),

    //----------------------------------------
    // Interrupt Outputs
    //----------------------------------------
    .irq                    (IRQ),
    .irq_abort              (IRQ_ABORT),

    //----------------------------------------
    // AXI Interface
    //----------------------------------------
    // Write Address Channel
    .awid                   (AWID),
    .awaddr                 (AWADDR),
    .awlen                  (AWLEN[3:0]),
    .awsize                 (AWSIZE),
    .awburst                (AWBURST),
    .awlock                 (int_awlock),
    .awcache                (AWCACHE),
    .awprot                 (AWPROT),
    .awvalid                (AWVALID),
    .awready                (AWREADY),

    // Write Data Channel
    .wid                    (/*unused*/),
    .wdata                  (WDATA),
    .wstrb                  (WSTRB),
    .wlast                  (WLAST),
    .wvalid                 (WVALID),
    .wready                 (WREADY),

    // Write Response Channel
    .bid                    (BID),
    .bresp                  (BRESP),
    .bvalid                 (BVALID),
    .bready                 (BREADY),

    // Read Address Channel
    .arid                   (ARID),
    .araddr                 (ARADDR),
    .arlen                  (ARLEN[3:0]),
    .arsize                 (ARSIZE),
    .arburst                (ARBURST),
    .arlock                 (int_arlock),
    .arcache                (ARCACHE),
    .arprot                 (ARPROT),
    .arvalid                (ARVALID),
    .arready                (ARREADY),

    // Read Data Channel
    .rid                    (RID),
    .rdata                  (RDATA),
    .rresp                  (RRESP),
    .rlast                  (RLAST),
    .rvalid                 (RVALID),
    .rready                 (RREADY),

    //----------------------------------------
    // Non-Secure APB Interface
    //----------------------------------------
    .prdata                 (/*unused*/),
    .pclken                 (PCLKEN),
    .paddr                  ({32{1'b0}}),
    .psel                   (1'b0),
    .penable                (1'b0),
    .pwrite                 (1'b0),
    .pwdata                 ({32{1'b0}}),
    .pready                 (/*unused*/),

    //----------------------------------------
    // Secure APB Interface
    //----------------------------------------
    .sprdata                (PRDATA),
    .spaddr                 ({{20{1'b0}}, PADDR}),
    .spsel                  (PSEL),
    .spenable               (PENABLE),
    .spwrite                (PWRITE),
    .spwdata                (PWDATA),
    .spready                (PREADY)
  );

  assign PREADY     = 1'b1;
  assign PSLVERR    = 1'b0;
  assign AWLEN[7:4] = 4'h0;
  assign ARLEN[7:4] = 4'h0;

  assign AWLOCK = int_awlock[0];
  assign ARLOCK = int_arlock[0];
endmodule
