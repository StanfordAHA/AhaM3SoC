//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: 4K-by-64-bit SRAM Wrapper for AHA SoC
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 17, 2020
//------------------------------------------------------------------------------
module AhaSram32K (
  input   wire          CLK,
  input   wire          CEn,
  input   wire [7:0]    WEn,
  input   wire [11:0]   A,
  input   wire [63:0]   D,
  output  wire [63:0]   Q
);

  // Power-Related
  localparam  RTSEL = 2'b01;
  localparam  WTSEL = 2'b00;

  // Select Wires
  wire        ce_n_0 = CEn | A[11];
  wire        ce_n_1 = CEn | ~A[11];
  wire [63:0] q0;
  wire [63:0] q1;

  // Bit-Enable Wires
  wire [7:0]  bwe_n_0 = {8{WEn[0]}};
  wire [7:0]  bwe_n_1 = {8{WEn[1]}};
  wire [7:0]  bwe_n_2 = {8{WEn[2]}};
  wire [7:0]  bwe_n_3 = {8{WEn[3]}};
  wire [7:0]  bwe_n_4 = {8{WEn[4]}};
  wire [7:0]  bwe_n_5 = {8{WEn[5]}};
  wire [7:0]  bwe_n_6 = {8{WEn[6]}};
  wire [7:0]  bwe_n_7 = {8{WEn[7]}};

  wire [63:0] bwe_n = { bwe_n_7, bwe_n_6, bwe_n_5, bwe_n_4, bwe_n_3, bwe_n_2,
                        bwe_n_1, bwe_n_0 };

  wire we_n = (& WEn);

  TS1N16FFCLLSBLVTC2048X64M8SW u_sram_2048x64_0 (
    .CLK    (CLK),
    .CEB    (ce_n_0),
    .WEB    (we_n),
    .BWEB   (bwe_n),
    .A      (A[10:0]),
    .D      (D),
    .Q      (q0),
    .RTSEL  (RTSEL),
    .WTSEL  (WTSEL)
  );

  TS1N16FFCLLSBLVTC2048X64M8SW u_sram_2048x64_1 (
    .CLK    (CLK),
    .CEB    (ce_n_1),
    .WEB    (we_n),
    .BWEB   (bwe_n),
    .A      (A[10:0]),
    .D      (D),
    .Q      (q1),
    .RTSEL  (RTSEL),
    .WTSEL  (WTSEL)
  );

  // Read Selection
  assign Q = A[11] ? q1 : q0;
endmodule
