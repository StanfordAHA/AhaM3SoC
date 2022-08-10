module PerfMonitor (
    input   wire    CPU_CLK,
    input   wire    PROC_WR_EN,
    input   wire    PROC_RD_EN,
    input   wire    IF_CFG_WR_EN,
    input   wire    CGRA_CFG_G2F_CFG_WR_EN,
    input   wire    STREAM_DATA_VALID_G2F,
    input   wire    STREAM_DATA_VALID_F2G
);

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
      wait(PROC_WR_EN);
      t0 = cycles;
      fork
        // Thread-1
        begin
          while(1) begin
            wait(PROC_WR_EN);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(IF_CFG_WR_EN);
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
            wait(IF_CFG_WR_EN);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(CGRA_CFG_G2F_CFG_WR_EN);
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
            wait(CGRA_CFG_G2F_CFG_WR_EN);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(PROC_WR_EN);
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
            wait(PROC_WR_EN);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(IF_CFG_WR_EN);
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
            wait(IF_CFG_WR_EN);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(STREAM_DATA_VALID_G2F);
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
            wait(STREAM_DATA_VALID_F2G);
            t1 = cycles;
            @(negedge CPU_CLK);
          end
        end
        // Thread-2
        begin
          wait(PROC_RD_EN);
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

endmodule
