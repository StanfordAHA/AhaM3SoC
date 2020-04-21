//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: CMSDK UART Integration for AHA SOC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 16, 2020
//------------------------------------------------------------------------------
module AhaUartIntegration (
  // Bus Interface
  input   wire            HCLK,
  input   wire            HRESETn,

  input   wire            HSEL,
  input   wire [31:0]     HADDR,
  input   wire  [1:0]     HTRANS,
  input   wire            HWRITE,
  input   wire  [2:0]     HSIZE,
  input   wire  [2:0]     HBURST,
  input   wire  [3:0]     HPROT,
  input   wire [31:0]     HWDATA,
  input   wire            HREADYMUX,

  output  wire [31:0]     HRDATA,
  output  wire            HREADYOUT,
  output  wire  [1:0]     HRESP,

  // Peripheral Interface
  input   wire            PCLK,
  input   wire            PCLKEN,
  input   wire            PRESETn,

  input   wire            RXD,
  output  wire            TXD,

  // Interrupts
  output  wire            TXINT,
  output  wire            RXINT,
  output  wire            TXOVRINT,
  output  wire            RXOVRINT,
  output  wire            UARTINT
);

  // Prevent lint messages for unused inputs
  wire unused = (| HBURST);

  wire [1:0]    int_hresp;

  wire [11:0]   int_paddr;
  wire          int_penable;
  wire          int_pwrite;
  wire [31:0]   int_pwdata;
  wire          int_psel;

  wire [31:0]   int_prdata;
  wire          int_pready;
  wire          int_pslverr;

  // AHB-APB Bridge
  cmsdk_ahb_to_apb #(
    .ADDRWIDTH            (12),
    .REGISTER_RDATA       (1),
    .REGISTER_WDATA       (0)
  ) u_cmsdk_ahb_apb_bridge (
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),
    .PCLKEN               (PCLKEN),

    .HSEL                 (HSEL),
    .HADDR                (HADDR[11:0]),
    .HTRANS               (HTRANS),
    .HSIZE                (HSIZE),
    .HPROT                (HPROT),
    .HWRITE               (HWRITE),
    .HREADY               (HREADYMUX),
    .HWDATA               (HWDATA),

    .HREADYOUT            (HREADYOUT),
    .HRDATA               (HRDATA),
    .HRESP                (int_hresp[0]),

    .PADDR                (int_paddr),
    .PENABLE              (int_penable),
    .PWRITE               (int_pwrite),
    .PSTRB                (/*unused*/),
    .PPROT                (/*unused*/),
    .PWDATA               (int_pwdata),
    .PSEL                 (int_psel),

    .APBACTIVE            (/*unused*/),

    .PRDATA               (int_prdata),
    .PREADY               (int_pready),
    .PSLVERR              (int_pslverr)
  );

  assign int_hresp[1]   = 1'b0;
  assign HRESP          = int_hresp;

  // CMSDK UART
  cmsdk_apb_uart u_cmsdk_apb_uart_0 (
    .PCLK            (PCLK),
    .PCLKG           (PCLK),
    .PRESETn         (PRESETn),

    .PSEL            (int_psel),
    .PADDR           (int_paddr[11:2]),
    .PENABLE         (int_penable),
    .PWRITE          (int_pwrite),
    .PWDATA          (int_pwdata),

    .ECOREVNUM       (4'h0),

    .PRDATA          (int_prdata),
    .PREADY          (int_pready),
    .PSLVERR         (int_pslverr),

    .RXD             (RXD),
    .TXD             (TXD),
    .TXEN            (/*unused*/),
    .BAUDTICK        (/*unused*/),

    .TXINT           (TXINT),
    .RXINT           (RXINT),
    .TXOVRINT        (TXOVRINT),
    .RXOVRINT        (RXOVRINT),
    .UARTINT         (UARTINT)
  );

endmodule
