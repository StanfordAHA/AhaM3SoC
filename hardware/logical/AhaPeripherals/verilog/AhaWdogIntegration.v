//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: CMSDK Watchdog Timer Integration for AHA SOC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 16, 2020
//------------------------------------------------------------------------------
module AhaWdogIntegration (
  // Bus Interface
  input   wire            HCLK,         // Interconnect Clock
  input   wire            HRESETn,      // Interconnect Reset (synched to HCLK)

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
  input   wire            PCLK,         // Watchdog timer clock
  input   wire            PCLKEN,       // Watchdog timer clock qualifier for HCLK
  input   wire            PRESETn,      // Watchdog reset (synched to PCLK)

  // Interrupts
  output  wire            WDOG_INT,      // Watchdog interrupt
  output  wire            WDOG_RESET     // Watchdog timeout reset
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

  // CMSDK Wdog Timer
  cmsdk_apb_watchdog u_cmsdk_apb_watchdog (
    .PCLK            (PCLK),                  // APB clock
    .PRESETn         (PRESETn),               // APB reset

    .PENABLE         (int_penable),           // APB enable
    .PSEL            (int_psel),              // APB periph select
    .PADDR           (int_paddr[11:2]),       // APB address bus [11:2]
    .PWRITE          (int_pwrite),            // APB write
    .PWDATA          (int_pwdata),            // APB write data [31:0]

    .WDOGCLK         (PCLK),                  // Watchdog clock
    .WDOGCLKEN       (1'b1),                  // Watchdog clock enable
    .WDOGRESn        (PRESETn),               // Watchdog clock reset

    .ECOREVNUM       (4'h0),                  // ECO revision number

    .PRDATA          (int_prdata),            // APB read data [31:0]

    .WDOGINT         (WDOG_INT),              // Watchdog interrupt
    .WDOGRES         (WDOG_RESET)             // Watchdog timeout reset
  );

  assign int_pready   = 1'b1;
  assign int_pslverr  = 1'b0;

endmodule
