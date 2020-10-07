//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to Simple Interface - Data Capture for Read Channel
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 27, 2020
//------------------------------------------------------------------------------
module AhaAxiToSifReadData (
    input   wire            ACLK,
    input   wire            ARESETn,

    input   wire [7:0]      ARLEN,
    input   wire            ARVALID,
    input   wire            ARREADY,

    input   wire            RREADY,
    output  wire            RVALID,
    output  wire            RLAST,
    output  wire [63:0]     RDATA,

    input   wire [63:0]     SIF_RD_DATA,
    input   wire            SIF_RD_VALID
);

  wire empty;
  wire rvalid_w;
  wire rlast_w;
  wire push_req_n;
  wire pop_req_n;

  reg [7:0] count;

  assign push_req_n = ~SIF_RD_VALID;

  wire [63:0] rdata_w;
  assign RDATA = rdata_w;

  CW_fifo_s1_sf  #(
    .width        (64),
    .depth        (32)
  ) u_fifo (
    .clk          (ACLK),
    .rst_n        (ARESETn),

    .push_req_n   (push_req_n),
    .pop_req_n    (pop_req_n),
    .diag_n       (1'b1),
    .data_in      (SIF_RD_DATA),

    .empty        (empty),
    .almost_empty (),
    .half_full    (),
    .almost_full  (),
    .full         (),
    .error        (),
    .data_out     (rdata_w)
  );

  always @ (posedge ACLK or negedge ARESETn) begin
    if(~ARESETn) count <= 8'h00;
    else if(ARVALID & ARREADY) count <= ARLEN;
    else if(rvalid_w && RREADY && count > 8'h00) count <= count - 1'b1;
  end

  //always @(posedge ACLK or negedge ARESETn) begin
  //  if(~ARESETn) pop_req_n <= 1'b1;
  //  else if(RREADY & rvalid_w) pop_req_n <= 1'b0;
  //  else pop_req_n <= 1'b1;
//end
  assign pop_req_n = ~(~empty & RREADY);

  assign rvalid_w   = ~empty;
  assign rlast_w    = rvalid_w && (count == 8'h00);
  assign RVALID     = rvalid_w;
  assign RLAST      = rlast_w;

endmodule
