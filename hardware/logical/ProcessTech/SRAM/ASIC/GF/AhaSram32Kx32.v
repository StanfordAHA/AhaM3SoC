//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : ASIC View of 32K-by-32-bit SRAM (128KB)
//------------------------------------------------------------------------------
// Process  : Global Foundries
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
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

    IN12LP_S1DB_W32768B032M16S8_HB u_sram_32Kx32 (
        .CLK                (CLK),
        .CEN                (CEn),
        .RDWEN              (wen_w),
        .BW                 (bwe),
        .A                  (A),
        .D                  (D),
        .Q                  (Q),
        .MA_SAWL0           (1'b0),
        .MA_SAWL1           (1'b0),
        .MA_STABAS0         (1'b0),
        .MA_STABAS1         (1'b0),
        .MA_VD0             (1'b0),
        .MA_VD1             (1'b0),
        .MA_WL0             (1'b0),
        .MA_WL1             (1'b0),
        .MA_WRAS0           (1'b0),
        .MA_WRAS1           (1'b0),
        .MA_WRT             (1'b0),
        .T_LOGIC            (1'b0),
        .T_Q_RST            (1'b0)
    );
endmodule
