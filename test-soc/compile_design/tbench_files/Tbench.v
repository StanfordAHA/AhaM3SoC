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
  localparam MAIN_PERIOD    = 10;

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
      #100
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

// This is used to compute the cycles spent on each Amber SoC processing stage
  wire CPU_CLK                = u_soc.core.u_aha_soc_partial.u_cpu_integration.CPU_CLK;
  wire proc_wr_en             = u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_wr_en;
  wire proc_rd_en             = u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.proc_rd_en;
  wire if_cfg_wr_en           = u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.if_cfg_wr_en;
  wire cgra_cfg_g2f_cfg_wr_en = |u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.cgra_cfg_g2f_cfg_wr_en;
  wire stream_data_valid_g2f  = |u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_g2f;
  wire stream_data_valid_f2g  = |u_soc.core.u_aha_garnet.u_garnet.GlobalBuffer_16_32_inst0$global_buffer_inst0.stream_data_valid_f2g;

  integer cycles;
  integer cycles_step1_bs2glb;
  integer cycles_step2_config_glb_1;
  integer cycles_step3_config_cgra;
  integer cycles_step4_img2glb;
  integer cycles_step5_config_glb_2;
  integer cycles_step6_exe_cgra;
  //integer cycles_step7_readback;
  integer bubble_12;
  integer bubble_23;
  integer bubble_34;
  integer bubble_45;
  integer bubble_56;
  integer bubble_67;
  integer t0, t1;

  always@(negedge CPU_CLK) begin
    cycles = cycles + 1;
  end

  initial begin
    cycles = 0;
    // ================== stage 1
    wait(proc_wr_en);
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(proc_wr_en);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(if_cfg_wr_en);
        cycles_step1_bs2glb = t1 - t0;
        bubble_12 = cycles - t1;
      end
    join_any

    // ================== stage 2
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(if_cfg_wr_en);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(cgra_cfg_g2f_cfg_wr_en);
        cycles_step2_config_glb_1 = t1 - t0;
        bubble_23 = cycles - t1;
      end
    join_any

    // ================== stage 3
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(cgra_cfg_g2f_cfg_wr_en);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(proc_wr_en);
        cycles_step3_config_cgra = t1 - t0;
        bubble_34 = cycles - t1;
      end
    join_any

    // ================== stage 4
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(proc_wr_en);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(if_cfg_wr_en);
        cycles_step4_img2glb = t1 - t0;
        bubble_45 = cycles - t1;
      end
    join_any

    // ================== stage 5
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(if_cfg_wr_en);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(stream_data_valid_g2f);
        cycles_step5_config_glb_2 = t1 - t0;
        bubble_56 = cycles - t1;
      end
    join_any

    // ================== stage 6
    t0 = cycles;
    fork
      // Thread-1
      begin
        while(1) begin
          wait(stream_data_valid_f2g);
          t1 = cycles;
          @(negedge CPU_CLK);
        end
      end
      // Thread-2
      begin
        wait(proc_rd_en);
        cycles_step6_exe_cgra = t1 - t0;
        bubble_67 = cycles - t1;
      end
    join_any

    $display("=================== Stage Cycles ========================");
    $display("Stage 1: %5d cycles (bs2glb)",       cycles_step1_bs2glb);
    $display("Stage 2: %5d cycles (config_glb_1)", cycles_step2_config_glb_1);
    $display("Stage 3: %5d cycles (config_cgra)",  cycles_step3_config_cgra);
    $display("Stage 4: %5d cycles (img2glb)",      cycles_step4_img2glb);
    $display("Stage 5: %5d cycles (config_glb_2)", cycles_step5_config_glb_2);
    $display("Stage 6: %5d cycles (exe_cgra)",     cycles_step6_exe_cgra);
    $display("====================== Bubbles ==========================");
    $display("Bubble 1-2: %5d cycles", bubble_12);
    $display("Bubble 2-3: %5d cycles", bubble_23);
    $display("Bubble 3-4: %5d cycles", bubble_34);
    $display("Bubble 4-5: %5d cycles", bubble_45);
    $display("Bubble 5-6: %5d cycles", bubble_56);
    $display("Bubble 6-7: %5d cycles", bubble_67);
    $display("=========================================================");
  end

// Initialize the tlx_mem with bitstream/input/gold
  parameter TLX_BASE_BS    = 32'h4_000_000;
  parameter TLX_BASE_INPUT = 32'h5_000_000;
  parameter TLX_BASE_GOLD  = 32'h6_000_000;

  reg [31:0] bs_addr;
  reg [31:0] bs_data;
  reg [15:0] temp [0:1920*1080*3-1];
  integer fp, i, j;
  integer bytes_read, total_pixels;
  integer tlx_base;
  string file_path;
  initial begin
      // ===== Bitstream =====
      if ($test$plusargs("TLX_BITSTREAM")) begin
          $value$plusargs("TLX_BITSTREAM=%s", file_path);
          $display("Bitstream file: %s detected, start initializing TLX memory", file_path);
          fp = $fopen(file_path, "r");
          if (fp) begin
              i = 0;
              tlx_base = TLX_BASE_BS;
              while($fscanf(fp, "%h %h", bs_addr, bs_data) == 2) begin
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem0[tlx_base+i] = bs_data;
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem1[tlx_base+i] = bs_addr;
                  i = i + 1;
              end
              $display("Total %0d lines are initialized using %s", i, file_path);
          end
      end
      // ===== App Input =====
      if ($test$plusargs("TLX_APP_INPUT")) begin
          $value$plusargs("TLX_APP_INPUT=%s", file_path);
          $display("Application input file: %s detected, start initializing TLX memory", file_path);
          fp = $fopen(file_path, "rb");
          if (fp) begin
              bytes_read = $fread(temp, fp);
              total_pixels = bytes_read / 2; // one pixel = 16bits = 2 bytes
              i = 0;
              tlx_base = TLX_BASE_INPUT;
              while(i < total_pixels) begin
                  j = tlx_base + (i/4);
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem0[j] = {temp[i+1], temp[i]};
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem1[j] = {temp[i+3], temp[i+2]};
                  i = i + 4;
              end
              $display("Total %0d input pixels are initialized using %s", total_pixels, file_path);
          end
      end
      // ===== App Gold =====
      if ($test$plusargs("TLX_APP_GOLD")) begin
          $value$plusargs("TLX_APP_GOLD=%s", file_path);
          $display("Application gold file: %s detected, start initializing TLX memory", file_path);
          fp = $fopen(file_path, "rb");
          if (fp) begin
              bytes_read = $fread(temp, fp);
              total_pixels = bytes_read / 2;
              i = 0;
              tlx_base = TLX_BASE_GOLD;
              while(i < total_pixels) begin
                  j = tlx_base + (i/4);
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem0[j] = {temp[i+1], temp[i]};
                  u_tlx_m_dom.mem.sram_mem.uMemModelBhav.mem1[j] = {temp[i+3], temp[i+2]};
                  i = i + 4;
              end
              $display("Total %0d gold pixels are initialized using %s", total_pixels, file_path);
          end
      end
  end

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
  // max cycle set
  //-----------------------------------------
  int max_cycle;
  initial begin
    if ($value$plusargs("MAX_CYCLE=%0d", max_cycle)) begin
      repeat (max_cycle) @(posedge master_clk);
      $display("\n%0t\tERROR: The %0d cycles marker has passed!", $time, max_cycle);
      $finish(2);
    end
  end

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
  // dumping trn file can speed up
  initial begin
    if ($test$plusargs("VCD_ON")) begin
      $recordfile("dump.trn");
      // $recordvars(Tbench.u_soc.core.u_aha_garnet);
      $recordvars(Tbench);
    end
  end

endmodule
