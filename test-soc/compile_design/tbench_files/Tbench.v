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
  // TLX FWD Wires
  wire                                  tlx_fwd_payload_tvalid;
  wire                                  tlx_fwd_payload_tready;
  wire [(`TLX_FWD_DATA_LO_WIDTH-1):0]   tlx_fwd_payload_tdata_lo;
  wire [(39-`TLX_FWD_DATA_LO_WIDTH):0]  tlx_fwd_payload_tdata_hi;
  wire [39:0]                           tlx_fwd_payload_tdata;

  wire                                  tlx_fwd_flow_tvalid;
  wire                                  tlx_fwd_flow_tready;
  wire [1:0]                            tlx_fwd_flow_tdata;

  assign tlx_fwd_payload_tdata = {tlx_fwd_payload_tdata_hi, tlx_fwd_payload_tdata_lo};

  // TLX REV Wires
  wire                                  tlx_rev_payload_tvalid;
  wire                                  tlx_rev_payload_tready;
  wire [(`TLX_REV_DATA_LO_WIDTH-1):0]   tlx_rev_payload_tdata_lo;
  wire [(79-`TLX_REV_DATA_LO_WIDTH):0]  tlx_rev_payload_tdata_hi;
  wire [79:0]                           tlx_rev_payload_tdata;

  wire                                  tlx_rev_flow_tvalid;
  wire                                  tlx_rev_flow_tready;
  wire [2:0]                            tlx_rev_flow_tdata;

  assign tlx_rev_payload_tdata_lo = tlx_rev_payload_tdata[(`TLX_REV_DATA_LO_WIDTH-1):0];
  assign tlx_rev_payload_tdata_hi = tlx_rev_payload_tdata[79:`TLX_REV_DATA_LO_WIDTH];

  AhaGarnetSoC SOC (
    .PORESETn                       (po_reset_n),
    .JTAG_RESETn                    (nTRST),

    .MASTER_CLK                     (master_clk),
    .JTAG_TCK                       (TCK),

    .JTAG_TDI                       (TDI),
    .JTAG_TMS                       (TMS),
    .JTAG_TDO                       (TDO),

    .TPIU_TRACE_DATA                (),
    .TPIU_TRACE_SWO                 (),
    .TPIU_TRACE_CLK                 (),

    .UART0_RXD                      (uart0_rxd),
    .UART0_TXD                      (uart0_txd),
    .UART1_RXD                      (uart1_rxd),
    .UART1_TXD                      (uart1_txd),

    // TLX FWD
    .TLX_FWD_PAYLOAD_TVALID         (tlx_fwd_payload_tvalid),
    .TLX_FWD_PAYLOAD_TREADY         (tlx_fwd_payload_tready),
    .TLX_FWD_PAYLOAD_TDATA_LO       (tlx_fwd_payload_tdata_lo),
    .TLX_FWD_PAYLOAD_TDATA_HI       (tlx_fwd_payload_tdata_hi),

    .TLX_FWD_FLOW_TVALID            (tlx_fwd_flow_tvalid),
    .TLX_FWD_FLOW_TREADY            (tlx_fwd_flow_tready),
    .TLX_FWD_FLOW_TDATA             (tlx_fwd_flow_tdata),

    // TLX REV
    .TLX_REV_CLK                    (master_clk),

    .TLX_REV_PAYLOAD_TVALID         (tlx_rev_payload_tvalid),
    .TLX_REV_PAYLOAD_TREADY         (tlx_rev_payload_tready),
    .TLX_REV_PAYLOAD_TDATA_LO       (tlx_rev_payload_tdata_lo),
    .TLX_REV_PAYLOAD_TDATA_HI       (tlx_rev_payload_tdata_hi),

    .TLX_REV_FLOW_TVALID            (tlx_rev_flow_tvalid),
    .TLX_REV_FLOW_TREADY            (tlx_rev_flow_tready),
    .TLX_REV_FLOW_TDATA             (tlx_rev_flow_tdata),

    // LoopBack
    .LOOP_BACK                      ()
  );

  // TLX Master Domain
  tlx_mem u_tlx_m_dom (
    // FWD Link
    .tlx_fwd_clk                    (master_clk),
    .tlx_fwd_reset_n                (po_reset_n),

    .tlx_fwd_payload_tvalid         (tlx_fwd_payload_tvalid),
    .tlx_fwd_payload_tready         (tlx_fwd_payload_tready),
    .tlx_fwd_payload_tdata          (tlx_fwd_payload_tdata),

    .tlx_fwd_flow_tvalid            (tlx_fwd_flow_tvalid),
    .tlx_fwd_flow_tready            (tlx_fwd_flow_tready),
    .tlx_fwd_flow_tdata             (tlx_fwd_flow_tdata),

    // REV Link
    .tlx_rev_clk                    (master_clk),
    .tlx_rev_reset_n                (po_reset_n),

    .tlx_rev_payload_tvalid         (tlx_rev_payload_tvalid),
    .tlx_rev_payload_tready         (tlx_rev_payload_tready),
    .tlx_rev_payload_tdata          (tlx_rev_payload_tdata),

    .tlx_rev_flow_tvalid            (tlx_rev_flow_tvalid),
    .tlx_rev_flow_tready            (tlx_rev_flow_tready),
    .tlx_rev_flow_tdata             (tlx_rev_flow_tdata)
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
