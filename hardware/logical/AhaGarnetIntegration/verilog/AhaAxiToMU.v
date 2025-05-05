//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AXI4 to MU-AXI Converter
//------------------------------------------------------------------------------
//
// Author   : Po-Han Chen
// Date     : Apr 3, 2025
//------------------------------------------------------------------------------
module AhaAxiToMU #(
  parameter MU_REG_AXI_DATA_WIDTH = 32,
  parameter ID_WIDTH = 4
) (
  // Clock and Reset
  input   wire         CLK,
  input   wire         RESETn,
  // AXI4 Slave Interface
  input   wire [ID_WIDTH-1:0]   AXI_AWID,
  input   wire [31:0]  AXI_AWADDR,
  input   wire [7:0]   AXI_AWLEN,
  input   wire [2:0]   AXI_AWSIZE,
  input   wire [1:0]   AXI_AWBURST,
  input   wire         AXI_AWLOCK,
  input   wire [3:0]   AXI_AWCACHE,
  input   wire [2:0]   AXI_AWPROT,
  input   wire         AXI_AWVALID,
  output  wire         AXI_AWREADY,
  input   wire [MU_REG_AXI_DATA_WIDTH-1:0]  AXI_WDATA,
  input   wire [3:0]   AXI_WSTRB,
  input   wire         AXI_WLAST,
  input   wire         AXI_WVALID,
  output  wire         AXI_WREADY,
  output  wire [ID_WIDTH-1:0]   AXI_BID,
  output  wire [1:0]   AXI_BRESP,
  output  wire         AXI_BVALID,
  input   wire         AXI_BREADY,
  input   wire [ID_WIDTH-1:0]   AXI_ARID,
  input   wire [31:0]  AXI_ARADDR,
  input   wire [7:0]   AXI_ARLEN,
  input   wire [2:0]   AXI_ARSIZE,
  input   wire [1:0]   AXI_ARBURST,
  input   wire         AXI_ARLOCK,
  input   wire [3:0]   AXI_ARCACHE,
  input   wire [2:0]   AXI_ARPROT,
  input   wire         AXI_ARVALID,
  output  wire         AXI_ARREADY,
  output  wire [ID_WIDTH-1:0]   AXI_RID,
  output  wire [MU_REG_AXI_DATA_WIDTH-1:0]  AXI_RDATA,
  output  wire [1:0]   AXI_RRESP,
  output  wire         AXI_RLAST,
  output  wire         AXI_RVALID,
  input   wire         AXI_RREADY,
  // MU Interface
  input   wire         mu_aw_ready,
  output  wire         mu_aw_valid,
  output  wire         mu_aw_bits_id,
  output  wire [29:0]  mu_aw_bits_addr,
  output  wire [7:0]   mu_aw_bits_len,
  output  wire [2:0]   mu_aw_bits_size,
  input   wire         mu_w_ready,
  output  wire         mu_w_valid,
  output  wire [MU_REG_AXI_DATA_WIDTH-1:0]  mu_w_bits_data,
  output  wire [3:0]   mu_w_bits_strb,
  output  wire         mu_w_bits_last,
  output  wire         mu_b_ready,
  input   wire         mu_b_valid,
  input   wire         mu_ar_ready,
  output  wire         mu_ar_valid,
  output  wire         mu_ar_bits_id,
  output  wire [29:0]  mu_ar_bits_addr,
  output  wire [7:0]   mu_ar_bits_len,
  output  wire [2:0]   mu_ar_bits_size,
  output  wire         mu_r_ready,
  input   wire         mu_r_valid,
  input   wire         mu_r_bits_id,
  input   wire [MU_REG_AXI_DATA_WIDTH-1:0]  mu_r_bits_data,
  input   wire [1:0]   mu_r_bits_resp,
  input   wire         mu_r_bits_last
);

  wire unused = (| AXI_AWBURST)  |
                (| AXI_AWLOCK)   |
                (| AXI_AWCACHE)  |
                (| AXI_AWPROT)   |
                (| AXI_ARBURST)  |
                (| AXI_ARLOCK)   |
                (| AXI_ARCACHE)  |
                (| AXI_ARPROT)   |
                (| mu_r_bits_id) ;

  // ====================================================
  // AW Channel (Write Address)
  // ====================================================
  assign AXI_AWREADY     = mu_aw_ready;
  assign mu_aw_valid     = AXI_AWVALID;
  assign mu_aw_bits_id   = 1'b0;
  // assign mu_aw_bits_addr = AXI_AWADDR[29:0];
  assign mu_aw_bits_addr = {24'b0, AXI_AWADDR[5:0]};
  // assign mu_aw_bits_len  = AXI_AWLEN;
  // assign mu_aw_bits_size = AXI_AWSIZE;
  assign mu_aw_bits_len = 8'b0;
  assign mu_aw_bits_size = 3'd3; // 2^3 = 8 bytes per transfer

  // ====================================================
  // W Channel (Write Data)
  // ====================================================
  assign AXI_WREADY     = mu_w_ready;
  assign mu_w_valid     = AXI_WVALID;
  assign mu_w_bits_data = AXI_WDATA;
  // assign mu_w_bits_strb = AXI_WSTRB;
  // assign mu_w_bits_last = AXI_WLAST;
  assign mu_w_bits_strb = 4'hF; // Strb is all high
  assign mu_w_bits_last = 1'b1;
  // ====================================================
  // B Channel (Write Response)
  // ====================================================
  reg [ID_WIDTH-1:0] bid;
  always@(posedge CLK or negedge RESETn) begin
    if(!RESETn) begin
      bid <= {ID_WIDTH{1'b0}};
    end else if(AXI_AWVALID & AXI_AWREADY) begin
      bid <= AXI_AWID;
    end
  end
  assign AXI_BID    = bid;
  assign AXI_BRESP  = 2'b00;
  assign AXI_BVALID = mu_b_valid;
  assign mu_b_ready = AXI_BREADY;

  // ====================================================
  // AR Channel (Read Address)
  // ====================================================
  assign AXI_ARREADY     = mu_ar_ready;
  assign mu_ar_valid     = AXI_ARVALID;
  assign mu_ar_bits_id   = 1'b0;
  assign mu_ar_bits_addr = AXI_ARADDR[29:0];
  assign mu_ar_bits_len  = AXI_ARLEN;
  assign mu_ar_bits_size = AXI_ARSIZE;

  // ====================================================
  // R Channel (Read Data)
  // ====================================================
  reg [ID_WIDTH-1:0] rid;
  always@(posedge CLK or negedge RESETn) begin
    if(!RESETn) begin
      rid <= {ID_WIDTH{1'b0}};
    end else if(AXI_ARVALID & AXI_ARREADY) begin
      rid <= AXI_ARID;
    end
  end
  assign AXI_RID    = rid;
  assign AXI_RDATA  = mu_r_bits_data;
  assign AXI_RRESP  = mu_r_bits_resp;
  assign AXI_RLAST  = mu_r_bits_last;
  assign AXI_RVALID = mu_r_valid;
  assign mu_r_ready = AXI_RREADY;

endmodule
