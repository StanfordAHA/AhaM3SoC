//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface - Read Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 21, 2020
//------------------------------------------------------------------------------
module AhaAxiToSifRead #(
  parameter  ID_WIDTH   = 4
) (
  input   wire                  ACLK,
  input   wire                  ARESETn,

  input   wire [ID_WIDTH-1:0]   ARID,
  input   wire [31:0]           ARADDR,
  input   wire [7:0]            ARLEN,
  input   wire [2:0]            ARSIZE,
  input   wire [1:0]            ARBURST,
  input   wire                  ARVALID,
  output  wire                  ARREADY,

  output  wire [ID_WIDTH-1:0]   RID,
  output  wire [1:0]            RRESP,
  output  wire                  RLAST,
  output  wire                  RVALID,
  output  wire [63:0]           RDATA,
  input   wire                  RREADY,

  output  wire [31:0]           SIF_RD_ADDR,
  output  wire                  SIF_RD_EN,
  input   wire [63:0]           SIF_RD_DATA,
  input   wire                  SIF_RD_VALID
);

  wire arready_w;
  wire rvalid_w;
  wire rlast_w;

  reg [ID_WIDTH-1:0] rid_r;

  always @(posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) rid_r <= {ID_WIDTH{1'b0}};
    else if(ARVALID & arready_w) rid_r <= ARID;
  end

  AhaAxiToSifReadAddrGen u_addr_gen (
    .ACLK             (ACLK),
    .ARESETn          (ARESETn),

    .ARADDR           (ARADDR),
    .ARBURST          (ARBURST),
    .ARSIZE           (ARSIZE),
    .ARLEN            (ARLEN),
    .ARVALID          (ARVALID),
    .ARREADY          (arready_w),
    .RVALID           (rvalid_w),
    .RREADY           (RREADY),
    .RLAST            (rlast_w),

    .SIF_RD_ADDR      (SIF_RD_ADDR),
    .SIF_RD_EN        (SIF_RD_EN)
  );

  wire [63:0] rdata_w;
  assign RDATA = rdata_w;

  AhaAxiToSifReadData  u_data (
    .ACLK             (ACLK),
    .ARESETn          (ARESETn),

    .ARLEN            (ARLEN),
    .ARVALID          (ARVALID),
    .ARREADY          (arready_w),
    .RREADY           (RREADY),
    .RVALID           (rvalid_w),
    .RLAST            (rlast_w),
    .RDATA            (rdata_w),

    .SIF_RD_DATA      (SIF_RD_DATA),
    .SIF_RD_VALID     (SIF_RD_VALID)
  );

  assign ARREADY    = arready_w;
  assign RVALID     = rvalid_w;
  assign RLAST      = rlast_w;
  assign RID        = rid_r;
  assign RRESP      = 2'b00;

endmodule
