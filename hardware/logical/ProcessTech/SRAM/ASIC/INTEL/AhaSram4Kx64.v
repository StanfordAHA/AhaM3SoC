//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : ASIC View of 4K-by-64-bit SRAM (32KB)
//------------------------------------------------------------------------------
// Process  : Intel
//------------------------------------------------------------------------------
//
// Author   : Kathleen Feng
// Date     : 18 October 2023
//------------------------------------------------------------------------------

module AhaSram4Kx64 #( parameter IMAGE_FILE = "None" )
(
    input   wire            CLK,
    input   wire            RESETn,
    input   wire            CEn,
    input   wire [7:0]      WEn,
    input   wire [11:0]     A,
    input   wire [63:0]     D,
    output  wire [63:0]     Q
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
    wire [7:0]              lane4_wen;
    wire [7:0]              lane5_wen;
    wire [7:0]              lane6_wen;
    wire [7:0]              lane7_wen;
    wire [63:0]             bwen;
    wire [63:0]             bwe;
    wire                    wen_w;

    assign lane0_wen        = {8{WEn[0]}};
    assign lane1_wen        = {8{WEn[1]}};
    assign lane2_wen        = {8{WEn[2]}};
    assign lane3_wen        = {8{WEn[3]}};
    assign lane4_wen        = {8{WEn[4]}};
    assign lane5_wen        = {8{WEn[5]}};
    assign lane6_wen        = {8{WEn[6]}};
    assign lane7_wen        = {8{WEn[7]}};

    assign bwen             = { lane7_wen, lane6_wen, lane5_wen, lane4_wen,
                                lane3_wen, lane2_wen, lane1_wen, lane0_wen };
    assign wen_w            = (& WEn);
    
    assign bwe = ~bwen;

    //
    // Instantiate SRAM Macro
    //

    wire clkbyp = 1'b0;
    wire mcen = 1'b0;
    wire [2:0] mc = 3'b000;
    wire wpulseen = 1'b0;
    wire [1:0] wpulse = 2'b00;
    wire [1:0] wa = 2'b00;

    ip224uhdlp1p11rf_4096x64m4b2c1s1_t0r0p0d0a1m1h u_sram_4Kx64 (
       .clk(CLK),
       .ren(wen_w & ~CEn), // read when we don't write
       .wen(~wen_w & ~CEn),
       .adr(A),
       .mc(mc),
       .mcen(mcen),
       .clkbyp(clkbyp),
       .din(D),
       .wbeb(bwen),
       .wa(wa),
       .wpulse(wpulse),
       .wpulseen(wpulseen),
       .fwen(!RESETn),
       .q(Q)
    );
endmodule
