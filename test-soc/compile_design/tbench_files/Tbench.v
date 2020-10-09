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
  wire                                  tlx_fwd_clk;
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

  wire tlx_rev_lane_0;
  wire [79:0] tlx_rev_payload_tdata_w;

  assign tlx_rev_payload_tdata_w  = {tlx_rev_payload_tdata[79:1], tlx_rev_lane_0};
  assign tlx_rev_payload_tdata_lo = tlx_rev_payload_tdata_w[(`TLX_REV_DATA_LO_WIDTH-1):0];
  assign tlx_rev_payload_tdata_hi = tlx_rev_payload_tdata_w[79:`TLX_REV_DATA_LO_WIDTH];

  GarnetSOC_pad_frame u_soc (
    .pad_jtag_intf_i_phy_tck        (1'b0),
    .pad_jtag_intf_i_phy_tdi        (1'b0),
    .pad_jtag_intf_i_phy_tdo        (),
    .pad_jtag_intf_i_phy_tms        (1'b0),
    .pad_jtag_intf_i_phy_trst_n     (1'b1),
    .pad_ext_rstb                   (1'b0),
    .pad_ext_dump_start             (1'b0),

    .pad_PORESETn                   (po_reset_n),
    .pad_DP_JTAG_TRSTn              (nTRST),
    .pad_CGRA_JTAG_TRSTn            (1'b1),

    .pad_MASTER_CLK                 (master_clk),
    .pad_DP_JTAG_TCK                (TCK),
    .pad_CGRA_JTAG_TCK              (1'b0),

    .pad_DP_JTAG_TDI                (TDI),
    .pad_DP_JTAG_TMS                (TMS),
    .pad_DP_JTAG_TDO                (TDO),

    .pad_CGRA_JTAG_TDI              (1'b0),
    .pad_CGRA_JTAG_TMS              (1'b0),
    .pad_CGRA_JTAG_TDO              (),

    .pad_TPIU_TRACE_DATA            (),
    .pad_TPIU_TRACE_SWO             (),
    .pad_TPIU_TRACE_CLK             (),

    .pad_UART0_RXD                  (uart0_rxd),
    .pad_UART0_TXD                  (uart0_txd),
    .pad_UART1_RXD                  (uart1_rxd),
    .pad_UART1_TXD                  (uart1_txd),

    // TLX FWD
    .pad_TLX_FWD_CLK                (tlx_fwd_clk),
    .pad_TLX_FWD_PAYLOAD_TVALID     (tlx_fwd_payload_tvalid),
    .pad_TLX_FWD_PAYLOAD_TREADY     (tlx_fwd_payload_tready),
    .pad_TLX_FWD_PAYLOAD_TDATA_LO   (tlx_fwd_payload_tdata_lo),
    .pad_TLX_FWD_PAYLOAD_TDATA_HI   (tlx_fwd_payload_tdata_hi),

    .pad_TLX_FWD_FLOW_TVALID        (tlx_fwd_flow_tvalid),
    .pad_TLX_FWD_FLOW_TREADY        (tlx_fwd_flow_tready),
    .pad_TLX_FWD_FLOW_TDATA         (tlx_fwd_flow_tdata),

    // TLX REV
    .pad_TLX_REV_CLK                (master_clk),

    .pad_TLX_REV_PAYLOAD_TVALID     (tlx_rev_payload_tvalid),
    .pad_TLX_REV_PAYLOAD_TREADY     (tlx_rev_payload_tready),
    .pad_TLX_REV_PAYLOAD_TDATA_LO   (tlx_rev_payload_tdata_lo),
    .pad_TLX_REV_PAYLOAD_TDATA_HI   (tlx_rev_payload_tdata_hi),

    .pad_TLX_REV_FLOW_TVALID        (tlx_rev_flow_tvalid),
    .pad_TLX_REV_FLOW_TREADY        (tlx_rev_flow_tready),
    .pad_TLX_REV_FLOW_TDATA         (tlx_rev_flow_tdata),

    // LoopBack
    .pad_LOOP_BACK_SELECT           (4'h0),
    .pad_LOOP_BACK                  ()
  );

  // TLX Master Domain
  tlx_mem u_tlx_m_dom (
    // FWD Link
    .tlx_fwd_clk                    (tlx_fwd_clk),
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
    .CLK                 (Tbench.u_soc.core.uart0_clk),      // Clock
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
  // TLX Traning Capture
  //-----------------------------------------

  AhaTlxTrainingMonitor u_tlx_capture (
    .FWD_CLK            (tlx_fwd_clk),
    .FWD_RESETn         (po_reset_n),
    .REV_CLK            (master_clk),
    .REV_RESETn         (po_reset_n),
    .OE                 (Tbench.u_soc.core.u_aha_tlx.u_aha_tlx_ctrl.l2h_LANE_ENABLE_REG_LANE0_r),
    .FWD_DATA_IN        (tlx_fwd_payload_tdata[0]),
    .REV_DATA_IN        (tlx_rev_payload_tdata[0]),
    .REV_DATA_OUT       (tlx_rev_lane_0)
  );

  //-----------------------------------------
  // VCD Dump
  //-----------------------------------------
  `ifdef VCD_ON
    initial begin
      // $dumpfile("dump.vcd");
      // $dumpvars(0, Tbench);
      // $dumpon;
      // dumping trn file can speed up
      $recordfile("dump.trn");
      $recordvars();
    end
  `endif

endmodule
