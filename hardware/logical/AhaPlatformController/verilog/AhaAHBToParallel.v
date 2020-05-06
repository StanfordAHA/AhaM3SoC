//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHB to Ordt Parallel Interface Converter
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 5, 2020
//------------------------------------------------------------------------------
module AhaAHBToParallel #(
  parameter ADDR_WIDTH  = 12
)(
  // AHB Interface
  input   wire                      HCLK,
  input   wire                      HRESETn,

  input   wire                      HSEL,
  input   wire [31:0]               HADDR,
  input   wire  [1:0]               HTRANS,
  input   wire                      HWRITE,
  input   wire  [2:0]               HSIZE,
  input   wire  [2:0]               HBURST,
  input   wire  [3:0]               HPROT,
  input   wire  [3:0]               HMASTER,
  input   wire [31:0]               HWDATA,
  input   wire                      HMASTLOCK,
  input   wire                      HREADYMUX,

  output  wire [31:0]               HRDATA,
  output  wire                      HREADYOUT,
  output  wire [1:0]                HRESP,

  // Ordt Parallel Interface
  output  wire [ADDR_WIDTH-1:0]     PAR_ADDR,
  output  wire                      PAR_RD_EN,
  output  wire                      PAR_WR_EN,
  output  wire [3:0]                PAR_WR_STRB,
  output  wire [31:0]               PAR_WR_DATA,
  input   wire [31:0]               PAR_RD_DATA,
  input   wire                      PAR_ACK,
  input   wire                      PAR_NACK
);

  // Unused Wires (to avoid Lint warnings)
  wire unused   = (| HBURST )     |
                  (| HPROT )      |
                  (| HMASTER )    |
                  (| HMASTLOCK )  ;

  // Internal
  wire                    trans_valid;
  wire                    read_valid;
  wire                    write_valid;

  reg   [3:0]             byte_enable;
  reg   [ADDR_WIDTH-1:0]  addr;
  reg                     rd_en_r;
  reg                     wr_en_r;
  reg   [3:0]             wr_strb_r;

  // Valid transaction signals
  assign trans_valid  = HSEL & HREADYMUX & HTRANS[1];
  assign read_valid   = trans_valid & ~HWRITE;
  assign write_valid  = trans_valid & HWRITE;

  // Generate byte enable signals
  always @(*) begin
    case (HSIZE)
      3'b000:   begin
                  case (HADDR[1:0])
                    2'b00:    byte_enable   = 4'b0001;
                    2'b01:    byte_enable   = 4'b0010;
                    2'b10:    byte_enable   = 4'b0100;
                    2'b11:    byte_enable   = 4'b1000;
                  endcase
                end
      3'b001:   begin
                  case (HADDR[1])
                    1'b0:     byte_enable   = 4'b0011;
                    1'b1:     byte_enable   = 4'b1100;
                  endcase
                  end
      3'b010:   byte_enable   = 4'b1111;
      default:  byte_enable   = 4'b0000;
    endcase
  end

  // Transaction Control Registering (Address Phase)
  always @(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
      rd_en_r     <= 1'b0;
      wr_en_r     <= 1'b0;
      wr_strb_r   <= 4'h0;
      addr        <= {ADDR_WIDTH{1'b0}};
    end
    else begin
      rd_en_r     <= read_valid;
      wr_en_r     <= write_valid;
      wr_strb_r   <= byte_enable & {4{trans_valid}};
      addr        <= HADDR[ADDR_WIDTH-1:0];
    end
  end

  // AHB Assignments
  assign  HRDATA    = PAR_RD_DATA;
  assign  HRESP     = 2'b00;
  assign  HREADYOUT = PAR_ACK | PAR_NACK;

  // Parallel Interface Assignments
  assign PAR_ADDR       = addr;
  assign PAR_RD_EN      = rd_en_r;
  assign PAR_WR_EN      = wr_en_r;
  assign PAR_WR_STRB    = wr_strb_r;
  assign PAR_WR_DATA    = HWDATA;
endmodule
