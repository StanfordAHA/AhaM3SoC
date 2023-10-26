//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : ASIC View of 32K-by-32-bit SRAM (128KB)
//------------------------------------------------------------------------------
// Process  : Intel
//------------------------------------------------------------------------------
//
// Author   : Kathleen Feng
// Date     : 18 October 2023
//------------------------------------------------------------------------------

module AhaSram32Kx32 #( parameter IMAGE_FILE = "None" )
(
    input   wire            CLK,
    input   wire            RESETn,
    input   wire            CEn,
    input   wire [3:0]      WEn,
    input   wire [14:0]     A,
    input   wire [31:0]     D,
    output  wire [31:0]     Q
);

    initial begin
    $deposit(Q, 0);
    end


    //
    // Internal Signals
    //

    wire [7:0]              lane0_wen;
    wire [7:0]              lane1_wen;
    wire [7:0]              lane2_wen;
    wire [7:0]              lane3_wen;
    wire [31:0]             bwen;
    wire [31:0]             bwe;
    wire                    wen_w;

    assign lane0_wen        = {8{WEn[0]}};
    assign lane1_wen        = {8{WEn[1]}};
    assign lane2_wen        = {8{WEn[2]}};
    assign lane3_wen        = {8{WEn[3]}};

    assign bwen             = { lane3_wen, lane2_wen, lane1_wen, lane0_wen };
    assign wen_w            = (& WEn);
    assign bwe              = ~bwen;

    //
    // Instantiate SRAM Macro
    //

    wire clkbyp = 1'b0;
    wire mcen = 1'b0;
    wire [2:0] mc = 3'b000;
    wire wpulseen = 1'b0;
    wire [1:0] wpulse = 2'b00;
    wire [1:0] wa = 2'b00;

    Intel32Kx32SRAM u_sram_32Kx32 (
        .clk(CLK),
        .rst(!RESETn),
        .ren(wen_w & ~CEn), // read when we don't write
        .wen(~wen_w & ~CEn),
        .adr(A),
        .mc(mc),
        .mcen(mcen),
        .clkbyp(clkbyp),
        .din(D),
        .wa(wa),
        .wpulse(wpulse),
        .wpulseen(wpulseen),
        .fwen(!RESETn),
        .q(Q)
    );

endmodule


module Intel32Kx32SRAM (
   input             clk,
   input             rst,
   input             ren,
   input             wen,
   input [14:0]      adr,
   input [2:0]       mc,
   input             mcen,
   input             clkbyp,
   input [31:0]      din,
   input [1:0]       wa,
   input [1:0]       wpulse,
   input             wpulseen,
   input             fwen,
   output reg [31:0] q
);

`define INTEL32KX32SRAM_BANKS 4

reg [`INTEL32KX32SRAM_BANKS - 1:0] ren_int;
reg [`INTEL32KX32SRAM_BANKS - 1:0] wen_int;
reg [31:0] q_int [0:(`INTEL32KX32SRAM_BANKS-1)];

generate
    for (genvar i = 0; i < `INTEL32KX32SRAM_BANKS; i++) begin
        ip224uhdlp1p11rf_8192x32m8b2c1s0_t0r0p0d0a1m1h u_mem (
            .clk(clk),
            .ren(ren_int[i]),
            .wen(wen_int[i]),
            .adr(adr[12:0]),
            .mc(mc),
            .mcen(mcen),
            .clkbyp(clkbyp),
            .din(din),
            .wa(wa),
            .wpulse(wpulse),
            .wpulseen(wpulseen),
            .fwen(fwen),
            .q(q_int[i])
        );
    end
endgenerate

reg [14:0] pre_adr;

always @(posedge clk) begin
    if (rst) begin
        pre_adr <= {15{1'b0}};
    end
    else if (ren) begin
        pre_adr <= adr;
    end
end

always @(*) begin
    for (integer i = 0; i < `INTEL32KX32SRAM_BANKS; i++) begin
        ren_int[i] = 1'b0;
        wen_int[i] = 1'b0;
        q = {32{1'b0}};
    end

    for (integer i = 0; i < `INTEL32KX32SRAM_BANKS; i++) begin
        if (adr >= i * 8192 && adr < (i + 1) * 8192) begin
            ren_int[i] = ren;
            wen_int[i] = wen;
        end
        if (pre_adr >= i * 8192 && pre_adr < (i + 1) * 8192) begin
            q = q_int[i];
        end
    end
end

endmodule