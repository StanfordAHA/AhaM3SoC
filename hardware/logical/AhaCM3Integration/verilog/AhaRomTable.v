//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: AHA CM3 ROM Table
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 11, 2020
//------------------------------------------------------------------------------
module AhaRomTable (
  input         PCLK,           // APB Clock
  input         PRESETn,        // APB Reset
  input         PSEL,           // APB Select
  input         PENABLE,        // APB Enable
  input  [11:2] PADDR,          // APB Address
  input         PWRITE,         // APB Write
  output [31:0] PRDATA          // APB Read Data
);

  // Local controls
  wire          unused = PENABLE;
  wire          addr_reg_we;
  wire    [5:0] nxt_addr_reg;
  reg     [5:0] addr_reg;

  reg    [31:0] apb_rdata;
  assign PRDATA  = apb_rdata;

  // ---------------------------------------------------------------------------
  // Control registration. Map addresses into two regions
  // Only supports 4 LSBs of address
  // ---------------------------------------------------------------------------
  assign addr_reg_we  = PSEL & ~PWRITE;
  assign nxt_addr_reg = {&PADDR[11:6], ~|PADDR[11:6],PADDR[5:2]};

  always @ (posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      addr_reg <= 6'b000000;
    else if (addr_reg_we)
      addr_reg <= nxt_addr_reg;

  // ---------------------------------------------------------------------------
  // Read Multiplexor
  // ---------------------------------------------------------------------------
  always @*
    case (addr_reg)
      // --------------------------------------------------------------------
      // ROM table entries for debug components inside the Cortex-M3 processor.
      //
      // NVIC (0x000) - Do not modify
      6'b0_1_0000 : apb_rdata = 32'hFFF0F003;
      // DWT  (0x004) - Do not modify
      6'b0_1_0001 : apb_rdata = 32'hFFF02003;
      // FPB  (0x008) - Do not modify
      6'b0_1_0010 : apb_rdata = 32'hFFF03003;
      // ITM  (0x00C) - Do not modify
      6'b0_1_0011 : apb_rdata = 32'hFFF01003;
      // TPIU (0x010)
      6'b0_1_0100 : apb_rdata = 32'hFFF41003;
      // Target Identification IDs - for identification of target platform
      // PID4
      6'b1_0_0100 : apb_rdata = 32'h00000004;
      // PID5
      6'b1_0_0101 : apb_rdata = 32'h00000000;
      // PID6
      6'b1_0_0110 : apb_rdata = 32'h00000000;
      // PID7
      6'b1_0_0111 : apb_rdata = 32'h00000000;
      // PID0
      6'b1_0_1000 : apb_rdata = 32'h000000C3;
      // PID1
      6'b1_0_1001 : apb_rdata = 32'h000000B4;
      // PID2
      6'b1_0_1010 : apb_rdata = 32'h0000001B;
      // PID3
      6'b1_0_1011 : apb_rdata = 32'h00000000;
      // MEMTYPE - Indicates that system memory can be accessed
      6'b1_0_0011 : apb_rdata = 32'h00000001;
      // Do not modify the following ID registers
      // CID0
      6'b1_0_1100 : apb_rdata = 32'h0000000D;
      // CID1
      6'b1_0_1101 : apb_rdata = 32'h00000010;
      // CID2
      6'b1_0_1110 : apb_rdata = 32'h00000005;
      // CID3
      6'b1_0_1111 : apb_rdata = 32'h000000B1;
      // No EXTRA ROM ENTRY since PPB is not exported
      6'b0_1_0111 : apb_rdata = 32'h00000000;

      default     : apb_rdata = 32'h00000000;
    endcase
endmodule
