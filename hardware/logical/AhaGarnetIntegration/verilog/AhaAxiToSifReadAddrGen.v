//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface - Address Generator for Read Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 27, 2020
//------------------------------------------------------------------------------
module AhaAxiToSifReadAddrGen (
    input   wire            ACLK,
    input   wire            ARESETn,

    input   wire [31:0]     ARADDR,
    input   wire [1:0]      ARBURST,
    input   wire [2:0]      ARSIZE,
    input   wire [7:0]      ARLEN,
    input   wire            ARVALID,
    output  wire            ARREADY,

    input   wire            RVALID,
    input   wire            RREADY,
    input   wire            RLAST,

    output  wire [31:0]     SIF_RD_ADDR,
    output  wire            SIF_RD_EN
);

  wire unused = (| ARBURST);

  reg         src_sel;

  reg         arready_r;

  reg [31:0]  AddrIncr;
  reg [31:0]  FinalAddr;
  reg [31:0]  NextRdAddr;
  reg         NextRdEn;

  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) src_sel <= 1'b0;
    else if(ARVALID & arready_r) src_sel <= 1'b1;
    else if (RVALID & RREADY & RLAST) src_sel <= 1'b0;
  end

  always @ (posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) arready_r <= 1'b1;
    else if (ARVALID & arready_r) arready_r <= 1'b0;
    else if(RVALID & RREADY & RLAST) arready_r <= 1'b1;
  end

  always @ (posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) AddrIncr <= 32'h0;
    else if(ARVALID & arready_r) begin
      case (ARSIZE)
        3'b000  : AddrIncr  <= {{28{1'b0}}, 4'h1};
        3'b001  : AddrIncr  <= {{28{1'b0}}, 4'h2};
        3'b010  : AddrIncr  <= {{28{1'b0}}, 4'h4};
        3'b011  : AddrIncr  <= {{28{1'b0}}, 4'h8};
        default : AddrIncr  <= {32{1'bx}};
      endcase
    end
  end

  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) FinalAddr  <= {32{1'b0}};
    else if(ARVALID & arready_r) begin
      case (ARSIZE)
        3'b000  : FinalAddr <= ARADDR + {{24{1'b0}}, ARLEN};
        3'b001  : FinalAddr <= ARADDR + {{23{1'b0}}, ARLEN, 1'b0};
        3'b010  : FinalAddr <= ARADDR + {{22{1'b0}}, ARLEN, 2'b00};
        3'b011  : FinalAddr <= ARADDR + {{21{1'b0}}, ARLEN, 3'b000};
        default : FinalAddr <= {32{1'bx}};
      endcase
    end
  end

  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) NextRdAddr <= {32{1'b0}};
    else if(ARVALID & arready_r) NextRdAddr <= ARADDR;
    else if(src_sel && NextRdAddr < FinalAddr) NextRdAddr <= NextRdAddr + AddrIncr;
  end

  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) NextRdEn <= 1'b0;
    else if(ARVALID & arready_r) NextRdEn <= 1'b1;
    else if(src_sel && NextRdAddr < FinalAddr) NextRdEn <= 1'b1;
    else NextRdEn <= 1'b0;
  end

  assign ARREADY      = arready_r;
  assign SIF_RD_EN    = NextRdEn;
  assign SIF_RD_ADDR  = {NextRdAddr[31:3], 3'b000};

endmodule
