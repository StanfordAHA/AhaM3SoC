module Tbench;
  // ----------------------------------------------------------------------------
  // Debug and Trace
  // ----------------------------------------------------------------------------
  wire          nTRST;                     // Test reset
  wire          TMS;                       // Test Mode Select/SWDIN
  wire          TCK;                       // Test clock / SWCLK
  wire          TDI;                       // Test Data In
  wire          TDO;                       // Test Data Out

  // ----------------------------------------------------------------------------
  // UART
  // ----------------------------------------------------------------------------
  wire          uart0_txd;
  wire          uart0_rxd;
  wire          uart1_txd;
  wire          uart1_rxd;

  //-----------------------------------------
  // Clocks and reset
  //-----------------------------------------
  localparam MAIN_PERIOD    = 100;

  reg           master_clk;
  reg           po_reset_n;

  initial
  begin
    master_clk    = 1'b1;
  end

  always #(MAIN_PERIOD/2)  master_clk = ~master_clk;

  initial
    begin
      po_reset_n   = 1'b0;
      #10000
      po_reset_n   = 1'b1;
    end

  //-----------------------------------------
  // AHASOC Integration
  //-----------------------------------------

  AhaGarnetSoC SOC (
    .PORESETn         (po_reset_n),
    .JTAG_RESETn      (nTRST),

    .MASTER_CLK       (master_clk),
    .JTAG_TCK         (TCK),

    .JTAG_TDI         (TDI),
    .JTAG_TMS         (TMS),
    .JTAG_TDO         (TDO),

    .TPIU_TRACE_DATA  (),
    .TPIU_TRACE_SWO   (),
    .TPIU_TRACE_CLK   (),

    .UART0_RXD        (uart0_rxd),
    .UART0_TXD        (uart0_txd),
    .UART1_RXD        (uart1_rxd),
    .UART1_TXD        (uart1_txd)
  );

  //-----------------------------------------
  // Pullup and pulldown
  //-----------------------------------------
  pullup(TDI);
  pullup(TMS);
  pullup(TCK);
  pullup(nTRST);
  pullup(TDO);

  pullup(uart0_rxd);
  pullup(uart1_rxd);

  //-----------------------------------------
  // UART Loop Back
  //-----------------------------------------
  assign uart0_rxd  = uart0_txd;
  assign uart1_rxd  = uart1_txd;

  //-------------------------------------------
  // CXDT instantiation
  //-------------------------------------------
  CXDT #(.IMAGENAME ("./CXDT.bin"))
  u_cxdt(.CLK       (master_clk),
         .PORESETn  (po_reset_n),
         .TDO       (TDO),
         .TDI       (TDI),
         .nTRST     (nTRST),
         .SWCLKTCK  (TCK),
         .SWDIOTMS  (TMS)
  );

  //-----------------------------------------
  // UART0 Capture
  //-----------------------------------------
  cmsdk_uart_capture_ard u_cmsdk_uart_capture_ard (
    .RESETn              (po_reset_n),    // Power on reset
    .CLK                 (master_clk),      // Clock
    .RXD                 (uart0_txd),     // Received data
    .SIMULATIONEND       (),
    .DEBUG_TESTER_ENABLE (),
    .AUXCTRL             (),
    .SPI0                (),
    .SPI1                (),
    .I2C0                (),
    .I2C1                (),
    .UART0               (),
    .UART1               ()
  );

  assign uart0_rxd = uart0_txd;

  //-----------------------------------------
  // VCD Dump
  //-----------------------------------------
  `ifdef VCD_ON
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, Tbench);
      $dumpon;
    end
  `endif

endmodule
