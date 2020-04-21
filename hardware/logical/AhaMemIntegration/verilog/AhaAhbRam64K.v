//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHB wrapper for 64K SRAM with 32-bit width
//
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 11, 2020
//------------------------------------------------------------------------------
module AhaAhbRam64K (
  // Inputs
  input   wire          HCLK,
  input   wire          HRESETn,

  input   wire          HSEL,
  input   wire          HREADY,
  input   wire  [1:0]   HTRANS,
  input   wire  [2:0]   HSIZE,
  input   wire          HWRITE,
  input   wire [31:0]   HADDR,
  input   wire [31:0]   HWDATA,

  output  wire          HREADYOUT,
  output  wire  [1:0]   HRESP,
  output  wire  [31:0]  HRDATA
);

  wire  [13:0]  sram_addr;
  wire  [31:0]  sram_rdata;
  wire  [31:0]  sram_wdata;
  wire   [3:0]  sram_we;
  wire          sram_cs;

  wire int_hresp;

  cmsdk_ahb_to_sram #(.AW(16)) u_ahb_to_sram (
    .HCLK               (HCLK),
    .HRESETn            (HRESETn),

    .HSEL               (HSEL),
    .HREADY             (HREADY),
    .HTRANS             (HTRANS),
    .HSIZE              (HSIZE),
    .HWRITE             (HWRITE),
    .HADDR              (HADDR[15:0]),
    .HWDATA             (HWDATA),

    .HREADYOUT          (HREADYOUT),
    .HRESP              (int_hresp),
    .HRDATA             (HRDATA),

    .SRAMRDATA          (sram_rdata),
    .SRAMADDR           (sram_addr),
    .SRAMWEN            (sram_we),
    .SRAMWDATA          (sram_wdata),
    .SRAMCS             (sram_cs)
  );

  assign HRESP = {1'b0, int_hresp};

  // ===== Memory Array
  wire [63:0]   line_d;

  wire [63:0]   bank0_q;
  wire [63:0]   bank0_bwe_n;
  wire          bank0_ce_n;
  wire          bank0_we_n;

  TS1N16FFCLLSBLVTC2048X64M8SW bank0(
    .CLK    (HCLK),
    .CEB    (bank0_ce_n),
    .WEB    (bank0_we_n),
    .A      (sram_addr[11:1]),
    .BWEB   (bank0_bwe_n),
    .D      (line_d),
    .RTSEL  (2'b01),
    .WTSEL  (2'b00),
    .Q      (bank0_q)
  );

  wire [63:0]   bank1_q;
  wire [63:0]   bank1_bwe_n;
  wire          bank1_ce_n;
  wire          bank1_we_n;

  TS1N16FFCLLSBLVTC2048X64M8SW bank1(
    .CLK    (HCLK),
    .CEB    (bank1_ce_n),
    .WEB    (bank1_we_n),
    .A      (sram_addr[11:1]),
    .BWEB   (bank1_bwe_n),
    .D      (line_d),
    .RTSEL  (2'b01),
    .WTSEL  (2'b00),
    .Q      (bank1_q)
  );

  wire [63:0]   bank2_q;
  wire [63:0]   bank2_bwe_n;
  wire          bank2_ce_n;
  wire          bank2_we_n;

  TS1N16FFCLLSBLVTC2048X64M8SW bank2(
    .CLK    (HCLK),
    .CEB    (bank2_ce_n),
    .WEB    (bank2_we_n),
    .A      (sram_addr[11:1]),
    .BWEB   (bank2_bwe_n),
    .D      (line_d),
    .RTSEL  (2'b01),
    .WTSEL  (2'b00),
    .Q      (bank2_q)
  );

  wire [63:0]   bank3_q;
  wire [63:0]   bank3_bwe_n;
  wire          bank3_ce_n;
  wire          bank3_we_n;

  TS1N16FFCLLSBLVTC2048X64M8SW bank3(
    .CLK    (HCLK),
    .CEB    (bank3_ce_n),
    .WEB    (bank3_we_n),
    .A      (sram_addr[11:1]),
    .BWEB   (bank3_bwe_n),
    .D      (line_d),
    .RTSEL  (2'b01),
    .WTSEL  (2'b00),
    .Q      (bank3_q)
  );

  // Chip enables
  assign bank0_ce_n   = ~(sram_cs && (sram_addr[13:12] == 2'b00));
  assign bank1_ce_n   = ~(sram_cs && (sram_addr[13:12] == 2'b01));
  assign bank2_ce_n   = ~(sram_cs && (sram_addr[13:12] == 2'b10));
  assign bank3_ce_n   = ~(sram_cs && (sram_addr[13:12] == 2'b11));

  // Write enables
  assign bank0_we_n   = ~((| sram_we) && (sram_addr[13:12] == 2'b00));
  assign bank1_we_n   = ~((| sram_we) && (sram_addr[13:12] == 2'b01));
  assign bank2_we_n   = ~((| sram_we) && (sram_addr[13:12] == 2'b10));
  assign bank3_we_n   = ~((| sram_we) && (sram_addr[13:12] == 2'b11));

  // Bit Write Enables
  wire  [7:0] lane0_we_n = ~{8{sram_we[0]}};
  wire  [7:0] lane1_we_n = ~{8{sram_we[1]}};
  wire  [7:0] lane2_we_n = ~{8{sram_we[2]}};
  wire  [7:0] lane3_we_n = ~{8{sram_we[3]}};
  wire  [31:0] half_line_we_n = {lane3_we_n, lane2_we_n, lane1_we_n, lane0_we_n};

  wire  [63:0] line_bwe_n = sram_addr[0] ? {half_line_we_n, {32{1'b1}}} :
    {{32{1'b1}}, half_line_we_n} ;

  assign bank0_bwe_n = {64{bank0_we_n}} | line_bwe_n;
  assign bank1_bwe_n = {64{bank1_we_n}} | line_bwe_n;
  assign bank2_bwe_n = {64{bank2_we_n}} | line_bwe_n;
  assign bank3_bwe_n = {64{bank3_we_n}} | line_bwe_n;

  // Write Data
  assign line_d = sram_addr[0] ? {sram_wdata, {32{1'b0}}} :
    {{32{1'b0}}, sram_wdata};

  // Read Data
  reg [1:0]   bank_r;
  reg         rd_en_r;
  reg         word_sel_r;
  always @(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      bank_r      <= 2'b00;
      rd_en_r     <= 1'b0;
      word_sel_r  <= 1'b0;
    end else begin
      bank_r      <= sram_addr[13:12];
      rd_en_r     <= sram_cs & ~(| sram_we[3:0]);
      word_sel_r  <= sram_addr[0];
    end
  end

  reg [63:0]  line_r;
  always @(*) begin
    case (bank_r)
      2'b00: line_r = bank0_q;
      2'b01: line_r = bank1_q;
      2'b10: line_r = bank2_q;
      2'b11: line_r = bank3_q;
      default: line_r = {64{1'b0}};
    endcase
  end

  wire [31:0] temp_read = word_sel_r ? line_r[63:32] : line_r[31:0];
  assign sram_rdata = {32{rd_en_r}} & temp_read;

endmodule
