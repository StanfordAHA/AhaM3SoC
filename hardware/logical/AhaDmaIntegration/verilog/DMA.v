module APBRegFile(
  input         ACLK,
  input         ARESETn,
  output        GO_Pulse,
  output        IRQEnable,
  output        IRQClear_Pulse,
  output [31:0] SrcAddr,
  output [31:0] DstAddr,
  output [31:0] Length,
  input         Busy,
  input         IRQStatus,
  input  [1:0]  StatCode,
  input  [31:0] setup_phase_RegIntf_PADDR,
  input         setup_phase_RegIntf_PSEL,
  input         setup_phase_RegIntf_PENABLE,
  input         setup_phase_RegIntf_PWRITE,
  input  [31:0] setup_phase_RegIntf_PWDATA,
  output        setup_phase_RegIntf_PREADY,
  output [31:0] setup_phase_RegIntf_PRDATA,
  output        setup_phase_RegIntf_PSLVERR
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_REG_INIT
  wire  reset = ~ARESETn; // @[APBRegFile.scala 30:38]
  reg  reg_go_pulse; // @[APBRegFile.scala 39:71]
  reg  reg_ie; // @[APBRegFile.scala 40:71]
  reg  reg_intclr_pulse; // @[APBRegFile.scala 41:71]
  reg [31:0] reg_src_addr; // @[APBRegFile.scala 42:71]
  reg [31:0] reg_dst_addr; // @[APBRegFile.scala 43:71]
  reg [31:0] reg_length; // @[APBRegFile.scala 44:71]
  reg [31:0] prdata; // @[APBRegFile.scala 49:71]
  reg  pready; // @[APBRegFile.scala 50:71]
  reg  pslverr; // @[APBRegFile.scala 51:71]
  wire  setup_phase = setup_phase_RegIntf_PSEL & ~setup_phase_RegIntf_PENABLE; // @[APBRegFile.scala 58:45]
  wire  wr_en = setup_phase & setup_phase_RegIntf_PWRITE; // @[APBRegFile.scala 59:44]
  wire  rd_en = setup_phase & ~setup_phase_RegIntf_PWRITE; // @[APBRegFile.scala 60:44]
  wire  _T_2 = wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h0; // @[APBRegFile.scala 75:21]
  wire [1:0] _reg_data_out_T = {reg_ie,1'h0}; // @[Cat.scala 31:58]
  wire [3:0] _reg_data_out_T_1 = {StatCode,IRQStatus,Busy}; // @[Cat.scala 31:58]
  wire [30:0] _GEN_6 = 3'h6 == setup_phase_RegIntf_PADDR[4:2] ? 31'h5a5a5a5a : 31'h0; // @[APBRegFile.scala 133:25 134:38 140:37]
  wire [31:0] _GEN_7 = 3'h5 == setup_phase_RegIntf_PADDR[4:2] ? reg_length : {{1'd0}, _GEN_6}; // @[APBRegFile.scala 134:38 139:37]
  wire [31:0] _GEN_8 = 3'h4 == setup_phase_RegIntf_PADDR[4:2] ? reg_dst_addr : _GEN_7; // @[APBRegFile.scala 134:38 138:37]
  wire  _T_26 = setup_phase_RegIntf_PADDR[4:2] > 3'h6; // @[APBRegFile.scala 163:39]
  assign GO_Pulse = reg_go_pulse; // @[APBRegFile.scala 81:21]
  assign IRQEnable = reg_ie; // @[APBRegFile.scala 101:21]
  assign IRQClear_Pulse = reg_intclr_pulse; // @[APBRegFile.scala 92:25]
  assign SrcAddr = reg_src_addr; // @[APBRegFile.scala 110:17]
  assign DstAddr = reg_dst_addr; // @[APBRegFile.scala 119:17]
  assign Length = reg_length; // @[APBRegFile.scala 128:16]
  assign setup_phase_RegIntf_PREADY = pready; // @[APBRegFile.scala 66:29]
  assign setup_phase_RegIntf_PRDATA = prdata; // @[APBRegFile.scala 65:29]
  assign setup_phase_RegIntf_PSLVERR = pslverr; // @[APBRegFile.scala 67:29]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 75:55]
      reg_go_pulse <= 1'h0; // @[APBRegFile.scala 76:29]
    end else begin
      reg_go_pulse <= wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h0 & setup_phase_RegIntf_PWDATA[0]; // @[APBRegFile.scala 78:29]
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 97:55]
      reg_ie <= 1'h0; // @[APBRegFile.scala 98:21]
    end else if (_T_2) begin // @[APBRegFile.scala 40:71]
      reg_ie <= setup_phase_RegIntf_PWDATA[1];
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 86:55]
      reg_intclr_pulse <= 1'h0; // @[APBRegFile.scala 87:33]
    end else begin
      reg_intclr_pulse <= wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h2 & setup_phase_RegIntf_PWDATA[1]; // @[APBRegFile.scala 89:33]
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 106:55]
      reg_src_addr <= 32'h0; // @[APBRegFile.scala 107:27]
    end else if (wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h3) begin // @[APBRegFile.scala 42:71]
      reg_src_addr <= setup_phase_RegIntf_PWDATA;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 115:55]
      reg_dst_addr <= 32'h0; // @[APBRegFile.scala 116:27]
    end else if (wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h4) begin // @[APBRegFile.scala 43:71]
      reg_dst_addr <= setup_phase_RegIntf_PWDATA;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 124:55]
      reg_length <= 32'h0; // @[APBRegFile.scala 125:25]
    end else if (wr_en & setup_phase_RegIntf_PADDR[4:2] == 3'h5) begin // @[APBRegFile.scala 44:71]
      reg_length <= setup_phase_RegIntf_PWDATA;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 146:22]
      prdata <= 32'h0; // @[APBRegFile.scala 134:38 135:37 134:38 136:37 134:38 137:37]
    end else if (rd_en) begin // @[APBRegFile.scala 49:71]
      if (3'h0 == setup_phase_RegIntf_PADDR[4:2]) begin
        prdata <= {{30'd0}, _reg_data_out_T};
      end else if (3'h1 == setup_phase_RegIntf_PADDR[4:2]) begin
        prdata <= {{28'd0}, _reg_data_out_T_1};
      end else if (3'h3 == setup_phase_RegIntf_PADDR[4:2]) begin
        prdata <= reg_src_addr;
      end else begin
        prdata <= _GEN_8;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 60:44]
      pready <= 1'h0;
    end else begin
      pready <= setup_phase & ~setup_phase_RegIntf_PWRITE;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[APBRegFile.scala 162:22]
      pslverr <= 1'h0;
    end else begin
      pslverr <= rd_en & _T_26; // @[APBRegFile.scala 169:21]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  reg_go_pulse = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  reg_ie = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  reg_intclr_pulse = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  reg_src_addr = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  reg_dst_addr = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  reg_length = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  prdata = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  pready = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  pslverr = _RAND_8[0:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    reg_go_pulse = 1'h0;
  end
  if (reset) begin
    reg_ie = 1'h0;
  end
  if (reset) begin
    reg_intclr_pulse = 1'h0;
  end
  if (reset) begin
    reg_src_addr = 32'h0;
  end
  if (reset) begin
    reg_dst_addr = 32'h0;
  end
  if (reset) begin
    reg_length = 32'h0;
  end
  if (reset) begin
    prdata = 32'h0;
  end
  if (reset) begin
    pready = 1'h0;
  end
  if (reset) begin
    pslverr = 1'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Splitter(
  input         ACLK,
  input         ARESETn,
  output        TransCmdIntf_ready,
  input         TransCmdIntf_valid,
  input  [31:0] TransCmdIntf_bits_NumBytes,
  input  [31:0] TransCmdIntf_bits_Address,
  input         TransStatIntf_ready,
  output        TransStatIntf_valid,
  output [1:0]  TransStatIntf_bits,
  input         XferCmdIntf_ready,
  output        XferCmdIntf_valid,
  output [11:0] XferCmdIntf_bits_NumBytes,
  output [31:0] XferCmdIntf_bits_Address,
  output        XferStatIntf_ready,
  input         XferStatIntf_valid,
  input  [1:0]  XferStatIntf_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  wire  reset = ~ARESETn; // @[Splitter.scala 54:34]
  reg [1:0] state; // @[Splitter.scala 72:67]
  reg [31:0] cur_num_bytes; // @[Splitter.scala 73:67]
  reg [31:0] rem_bytes; // @[Splitter.scala 74:67]
  wire [11:0] _GEN_28 = {{1'd0}, TransCmdIntf_bits_Address[10:0]}; // @[Splitter.scala 75:44]
  wire [11:0] bBytes = 12'h800 - _GEN_28; // @[Splitter.scala 75:44]
  reg [31:0] cur_addr; // @[Splitter.scala 76:67]
  wire [31:0] _next_addr_T = {{11'd0}, cur_addr[31:11]}; // @[Splitter.scala 77:38]
  wire [31:0] _next_addr_T_2 = _next_addr_T + 32'h1; // @[Splitter.scala 77:63]
  wire [42:0] _GEN_30 = {_next_addr_T_2, 11'h0}; // @[Splitter.scala 77:70]
  wire [46:0] next_addr = {{4'd0}, _GEN_30}; // @[Splitter.scala 77:70]
  reg [1:0] trans_status; // @[Splitter.scala 78:67]
  wire  _T_2 = 2'h0 == state; // @[Splitter.scala 85:24]
  wire  _T_8 = 2'h2 == state; // @[Splitter.scala 85:24]
  wire [1:0] _GEN_2 = rem_bytes > 32'h0 ? 2'h1 : 2'h3; // @[Splitter.scala 101:33 98:44 99:33]
  wire [1:0] _GEN_4 = TransStatIntf_ready ? 2'h0 : state; // @[Splitter.scala 106:44 107:29 72:67]
  wire [31:0] _GEN_9 = TransCmdIntf_valid ? TransCmdIntf_bits_Address : cur_addr; // @[Splitter.scala 117:43 118:33 76:67]
  wire [46:0] _GEN_10 = XferStatIntf_valid ? next_addr : {{15'd0}, cur_addr}; // @[Splitter.scala 122:43 123:33 76:67]
  wire [46:0] _GEN_11 = _T_8 ? _GEN_10 : {{15'd0}, cur_addr}; // @[Splitter.scala 115:24 76:67]
  wire [46:0] _GEN_12 = _T_2 ? {{15'd0}, _GEN_9} : _GEN_11; // @[Splitter.scala 115:24]
  wire [31:0] _GEN_31 = {{20'd0}, bBytes}; // @[Splitter.scala 134:34]
  wire [31:0] _rem_bytes_T_1 = TransCmdIntf_bits_NumBytes - _GEN_31; // @[Splitter.scala 136:71]
  wire [31:0] _rem_bytes_T_3 = rem_bytes - 32'h800; // @[Splitter.scala 147:54]
  assign TransCmdIntf_ready = state == 2'h0; // @[Splitter.scala 175:46]
  assign TransStatIntf_valid = state == 2'h3; // @[Splitter.scala 176:46]
  assign TransStatIntf_bits = trans_status; // @[Splitter.scala 170:37]
  assign XferCmdIntf_valid = state == 2'h1; // @[Splitter.scala 186:46]
  assign XferCmdIntf_bits_NumBytes = cur_num_bytes[11:0]; // @[Splitter.scala 187:37]
  assign XferCmdIntf_bits_Address = cur_addr; // @[Splitter.scala 188:37]
  assign XferStatIntf_ready = state == 2'h2; // @[Splitter.scala 181:46]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Splitter.scala 85:24]
      state <= 2'h0; // @[Splitter.scala 87:43 88:29 72:67]
    end else if (2'h0 == state) begin // @[Splitter.scala 85:24]
      if (TransCmdIntf_valid) begin // @[Splitter.scala 92:42]
        state <= 2'h1; // @[Splitter.scala 93:29]
      end
    end else if (2'h1 == state) begin // @[Splitter.scala 85:24]
      if (XferCmdIntf_ready) begin // @[Splitter.scala 97:43]
        state <= 2'h2;
      end
    end else if (2'h2 == state) begin // @[Splitter.scala 85:24]
      if (XferStatIntf_valid) begin
        state <= _GEN_2;
      end
    end else if (2'h3 == state) begin // @[Splitter.scala 72:67]
      state <= _GEN_4;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Splitter.scala 131:24]
      cur_num_bytes <= 32'h0; // @[Splitter.scala 133:43 134:65 135:41 138:41 73:67]
    end else if (_T_2) begin // @[Splitter.scala 131:24]
      if (TransCmdIntf_valid) begin // @[Splitter.scala 144:43]
        if (_GEN_31 <= TransCmdIntf_bits_NumBytes) begin // @[Splitter.scala 145:57]
          cur_num_bytes <= {{20'd0}, bBytes}; // @[Splitter.scala 146:41]
        end else begin
          cur_num_bytes <= TransCmdIntf_bits_NumBytes; // @[Splitter.scala 149:41]
        end
      end
    end else if (_T_8) begin // @[Splitter.scala 73:67]
      if (XferStatIntf_valid) begin
        if (rem_bytes > 32'h800) begin
          cur_num_bytes <= 32'h800;
        end else begin
          cur_num_bytes <= rem_bytes;
        end
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Splitter.scala 131:24]
      rem_bytes <= 32'h0; // @[Splitter.scala 133:43 134:65 136:41 139:41 74:67]
    end else if (_T_2) begin // @[Splitter.scala 131:24]
      if (TransCmdIntf_valid) begin // @[Splitter.scala 144:43]
        if (_GEN_31 <= TransCmdIntf_bits_NumBytes) begin // @[Splitter.scala 145:57]
          rem_bytes <= _rem_bytes_T_1; // @[Splitter.scala 147:41]
        end else begin
          rem_bytes <= 32'h0; // @[Splitter.scala 150:41]
        end
      end
    end else if (_T_8) begin // @[Splitter.scala 74:67]
      if (XferStatIntf_valid) begin
        if (rem_bytes > 32'h800) begin
          rem_bytes <= _rem_bytes_T_3;
        end else begin
          rem_bytes <= 32'h0;
        end
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Splitter.scala 76:67]
      cur_addr <= 32'h0; // @[Splitter.scala 76:67]
    end else begin
      cur_addr <= _GEN_12[31:0];
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Splitter.scala 159:24]
      trans_status <= 2'h0; // @[Splitter.scala 161:33]
    end else if (_T_2) begin // @[Splitter.scala 159:24]
      trans_status <= 2'h0; // @[Splitter.scala 164:75 165:37 78:67]
    end else if (_T_8) begin // @[Splitter.scala 78:67]
      if (XferStatIntf_valid & TransStatIntf_bits == 2'h0) begin
        trans_status <= XferStatIntf_bits;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  cur_num_bytes = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  rem_bytes = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  cur_addr = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  trans_status = _RAND_4[1:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    state = 2'h0;
  end
  if (reset) begin
    cur_num_bytes = 32'h0;
  end
  if (reset) begin
    rem_bytes = 32'h0;
  end
  if (reset) begin
    cur_addr = 32'h0;
  end
  if (reset) begin
    trans_status = 2'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Controller(
  input         ACLK,
  input         ARESETn,
  output        Irq,
  input         RdCmdIntf_ready,
  output        RdCmdIntf_valid,
  output [11:0] RdCmdIntf_bits_NumBytes,
  output [31:0] RdCmdIntf_bits_Address,
  output        RdStatIntf_ready,
  input         RdStatIntf_valid,
  input  [1:0]  RdStatIntf_bits,
  input         WrCmdIntf_ready,
  output        WrCmdIntf_valid,
  output [11:0] WrCmdIntf_bits_NumBytes,
  output [31:0] WrCmdIntf_bits_Address,
  output        WrStatIntf_ready,
  input         WrStatIntf_valid,
  input  [1:0]  WrStatIntf_bits,
  input  [31:0] reg_file_RegIntf_RegIntf_PADDR,
  input         reg_file_RegIntf_RegIntf_PSEL,
  input         reg_file_RegIntf_RegIntf_PENABLE,
  input         reg_file_RegIntf_RegIntf_PWRITE,
  input  [31:0] reg_file_RegIntf_RegIntf_PWDATA,
  output        reg_file_RegIntf_RegIntf_PREADY,
  output [31:0] reg_file_RegIntf_RegIntf_PRDATA,
  output        reg_file_RegIntf_RegIntf_PSLVERR
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
`endif // RANDOMIZE_REG_INIT
  wire  reg_file_ACLK; // @[Controller.scala 96:35]
  wire  reg_file_ARESETn; // @[Controller.scala 96:35]
  wire  reg_file_GO_Pulse; // @[Controller.scala 96:35]
  wire  reg_file_IRQEnable; // @[Controller.scala 96:35]
  wire  reg_file_IRQClear_Pulse; // @[Controller.scala 96:35]
  wire [31:0] reg_file_SrcAddr; // @[Controller.scala 96:35]
  wire [31:0] reg_file_DstAddr; // @[Controller.scala 96:35]
  wire [31:0] reg_file_Length; // @[Controller.scala 96:35]
  wire  reg_file_Busy; // @[Controller.scala 96:35]
  wire  reg_file_IRQStatus; // @[Controller.scala 96:35]
  wire [1:0] reg_file_StatCode; // @[Controller.scala 96:35]
  wire [31:0] reg_file_setup_phase_RegIntf_PADDR; // @[Controller.scala 96:35]
  wire  reg_file_setup_phase_RegIntf_PSEL; // @[Controller.scala 96:35]
  wire  reg_file_setup_phase_RegIntf_PENABLE; // @[Controller.scala 96:35]
  wire  reg_file_setup_phase_RegIntf_PWRITE; // @[Controller.scala 96:35]
  wire [31:0] reg_file_setup_phase_RegIntf_PWDATA; // @[Controller.scala 96:35]
  wire  reg_file_setup_phase_RegIntf_PREADY; // @[Controller.scala 96:35]
  wire [31:0] reg_file_setup_phase_RegIntf_PRDATA; // @[Controller.scala 96:35]
  wire  reg_file_setup_phase_RegIntf_PSLVERR; // @[Controller.scala 96:35]
  wire  rd_splitter_ACLK; // @[Controller.scala 126:45]
  wire  rd_splitter_ARESETn; // @[Controller.scala 126:45]
  wire  rd_splitter_TransCmdIntf_ready; // @[Controller.scala 126:45]
  wire  rd_splitter_TransCmdIntf_valid; // @[Controller.scala 126:45]
  wire [31:0] rd_splitter_TransCmdIntf_bits_NumBytes; // @[Controller.scala 126:45]
  wire [31:0] rd_splitter_TransCmdIntf_bits_Address; // @[Controller.scala 126:45]
  wire  rd_splitter_TransStatIntf_ready; // @[Controller.scala 126:45]
  wire  rd_splitter_TransStatIntf_valid; // @[Controller.scala 126:45]
  wire [1:0] rd_splitter_TransStatIntf_bits; // @[Controller.scala 126:45]
  wire  rd_splitter_XferCmdIntf_ready; // @[Controller.scala 126:45]
  wire  rd_splitter_XferCmdIntf_valid; // @[Controller.scala 126:45]
  wire [11:0] rd_splitter_XferCmdIntf_bits_NumBytes; // @[Controller.scala 126:45]
  wire [31:0] rd_splitter_XferCmdIntf_bits_Address; // @[Controller.scala 126:45]
  wire  rd_splitter_XferStatIntf_ready; // @[Controller.scala 126:45]
  wire  rd_splitter_XferStatIntf_valid; // @[Controller.scala 126:45]
  wire [1:0] rd_splitter_XferStatIntf_bits; // @[Controller.scala 126:45]
  wire  wr_splitter_ACLK; // @[Controller.scala 157:45]
  wire  wr_splitter_ARESETn; // @[Controller.scala 157:45]
  wire  wr_splitter_TransCmdIntf_ready; // @[Controller.scala 157:45]
  wire  wr_splitter_TransCmdIntf_valid; // @[Controller.scala 157:45]
  wire [31:0] wr_splitter_TransCmdIntf_bits_NumBytes; // @[Controller.scala 157:45]
  wire [31:0] wr_splitter_TransCmdIntf_bits_Address; // @[Controller.scala 157:45]
  wire  wr_splitter_TransStatIntf_ready; // @[Controller.scala 157:45]
  wire  wr_splitter_TransStatIntf_valid; // @[Controller.scala 157:45]
  wire [1:0] wr_splitter_TransStatIntf_bits; // @[Controller.scala 157:45]
  wire  wr_splitter_XferCmdIntf_ready; // @[Controller.scala 157:45]
  wire  wr_splitter_XferCmdIntf_valid; // @[Controller.scala 157:45]
  wire [11:0] wr_splitter_XferCmdIntf_bits_NumBytes; // @[Controller.scala 157:45]
  wire [31:0] wr_splitter_XferCmdIntf_bits_Address; // @[Controller.scala 157:45]
  wire  wr_splitter_XferStatIntf_ready; // @[Controller.scala 157:45]
  wire  wr_splitter_XferStatIntf_valid; // @[Controller.scala 157:45]
  wire [1:0] wr_splitter_XferStatIntf_bits; // @[Controller.scala 157:45]
  wire  reset = ~ARESETn; // @[Controller.scala 68:38]
  reg [1:0] state; // @[Controller.scala 74:67]
  reg  busy; // @[Controller.scala 89:67]
  reg  irq_status; // @[Controller.scala 90:67]
  reg [1:0] stat_code; // @[Controller.scala 91:67]
  reg  rd_trans_cmd_valid; // @[Controller.scala 118:79]
  reg [31:0] rd_trans_cmd_bits_NumBytes; // @[Controller.scala 120:48]
  reg [31:0] rd_trans_cmd_bits_Address; // @[Controller.scala 120:48]
  reg  wr_trans_cmd_valid; // @[Controller.scala 149:79]
  reg [31:0] wr_trans_cmd_bits_NumBytes; // @[Controller.scala 151:48]
  reg [31:0] wr_trans_cmd_bits_Address; // @[Controller.scala 151:48]
  reg  read_cmd_posted; // @[Controller.scala 179:71]
  reg  write_cmd_posted; // @[Controller.scala 180:71]
  reg  read_stat_posted; // @[Controller.scala 181:71]
  reg  write_stat_posted; // @[Controller.scala 182:71]
  reg [1:0] read_stat; // @[Controller.scala 183:71]
  reg [1:0] write_stat; // @[Controller.scala 184:71]
  reg [1:0] err_stat; // @[Controller.scala 185:71]
  wire  _T_2 = 2'h0 == state; // @[Controller.scala 192:24]
  wire [31:0] length = reg_file_Length; // @[Controller.scala 112:25 84:31]
  wire  go_pulse = reg_file_GO_Pulse; // @[Controller.scala 107:25 79:31]
  wire  _T_4 = go_pulse & length == 32'h0; // @[Controller.scala 194:32]
  wire  _T_7 = 2'h1 == state; // @[Controller.scala 192:24]
  wire  _T_11 = 2'h2 == state; // @[Controller.scala 192:24]
  wire  _T_12 = read_stat_posted & write_stat_posted; // @[Controller.scala 206:40]
  wire  irq_enable = reg_file_IRQEnable; // @[Controller.scala 108:25 80:31]
  wire  irq_clear_pulse = reg_file_IRQClear_Pulse; // @[Controller.scala 109:25 81:31]
  wire  _GEN_9 = irq_clear_pulse ? 1'h0 : irq_status; // @[Controller.scala 241:38 242:25 90:67]
  wire  _T_25 = err_stat != 2'h0; // @[Controller.scala 251:36]
  wire  rd_trans_stat_valid = rd_splitter_TransStatIntf_valid; // @[Controller.scala 123:43 140:37]
  wire [1:0] rd_trans_stat_bits = rd_splitter_TransStatIntf_bits; // @[Controller.scala 124:43 141:37]
  wire  _GEN_16 = rd_trans_stat_valid | _T_25 | read_stat_posted; // @[Controller.scala 272:66 274:41 181:71]
  wire  wr_trans_stat_valid = wr_splitter_TransStatIntf_valid; // @[Controller.scala 154:43 171:37]
  wire [1:0] wr_trans_stat_bits = wr_splitter_TransStatIntf_bits; // @[Controller.scala 155:43 172:37]
  wire  _GEN_22 = wr_trans_stat_valid | _T_25 | write_stat_posted; // @[Controller.scala 291:66 293:42 182:71]
  wire  _T_47 = go_pulse & length != 32'h0; // @[Controller.scala 306:32]
  wire [31:0] src_addr = reg_file_SrcAddr; // @[Controller.scala 110:25 82:31]
  wire  rd_trans_cmd_ready = rd_splitter_TransCmdIntf_ready; // @[Controller.scala 117:43 136:37]
  wire  _GEN_30 = rd_trans_cmd_ready | read_cmd_posted; // @[Controller.scala 315:43 316:49 179:71]
  wire [31:0] dst_addr = reg_file_DstAddr; // @[Controller.scala 111:25 83:31]
  wire  wr_trans_cmd_ready = wr_splitter_TransCmdIntf_ready; // @[Controller.scala 148:43 167:37]
  wire  _GEN_41 = wr_trans_cmd_ready | write_cmd_posted; // @[Controller.scala 337:43 338:49 180:71]
  APBRegFile reg_file ( // @[Controller.scala 96:35]
    .ACLK(reg_file_ACLK),
    .ARESETn(reg_file_ARESETn),
    .GO_Pulse(reg_file_GO_Pulse),
    .IRQEnable(reg_file_IRQEnable),
    .IRQClear_Pulse(reg_file_IRQClear_Pulse),
    .SrcAddr(reg_file_SrcAddr),
    .DstAddr(reg_file_DstAddr),
    .Length(reg_file_Length),
    .Busy(reg_file_Busy),
    .IRQStatus(reg_file_IRQStatus),
    .StatCode(reg_file_StatCode),
    .setup_phase_RegIntf_PADDR(reg_file_setup_phase_RegIntf_PADDR),
    .setup_phase_RegIntf_PSEL(reg_file_setup_phase_RegIntf_PSEL),
    .setup_phase_RegIntf_PENABLE(reg_file_setup_phase_RegIntf_PENABLE),
    .setup_phase_RegIntf_PWRITE(reg_file_setup_phase_RegIntf_PWRITE),
    .setup_phase_RegIntf_PWDATA(reg_file_setup_phase_RegIntf_PWDATA),
    .setup_phase_RegIntf_PREADY(reg_file_setup_phase_RegIntf_PREADY),
    .setup_phase_RegIntf_PRDATA(reg_file_setup_phase_RegIntf_PRDATA),
    .setup_phase_RegIntf_PSLVERR(reg_file_setup_phase_RegIntf_PSLVERR)
  );
  Splitter rd_splitter ( // @[Controller.scala 126:45]
    .ACLK(rd_splitter_ACLK),
    .ARESETn(rd_splitter_ARESETn),
    .TransCmdIntf_ready(rd_splitter_TransCmdIntf_ready),
    .TransCmdIntf_valid(rd_splitter_TransCmdIntf_valid),
    .TransCmdIntf_bits_NumBytes(rd_splitter_TransCmdIntf_bits_NumBytes),
    .TransCmdIntf_bits_Address(rd_splitter_TransCmdIntf_bits_Address),
    .TransStatIntf_ready(rd_splitter_TransStatIntf_ready),
    .TransStatIntf_valid(rd_splitter_TransStatIntf_valid),
    .TransStatIntf_bits(rd_splitter_TransStatIntf_bits),
    .XferCmdIntf_ready(rd_splitter_XferCmdIntf_ready),
    .XferCmdIntf_valid(rd_splitter_XferCmdIntf_valid),
    .XferCmdIntf_bits_NumBytes(rd_splitter_XferCmdIntf_bits_NumBytes),
    .XferCmdIntf_bits_Address(rd_splitter_XferCmdIntf_bits_Address),
    .XferStatIntf_ready(rd_splitter_XferStatIntf_ready),
    .XferStatIntf_valid(rd_splitter_XferStatIntf_valid),
    .XferStatIntf_bits(rd_splitter_XferStatIntf_bits)
  );
  Splitter wr_splitter ( // @[Controller.scala 157:45]
    .ACLK(wr_splitter_ACLK),
    .ARESETn(wr_splitter_ARESETn),
    .TransCmdIntf_ready(wr_splitter_TransCmdIntf_ready),
    .TransCmdIntf_valid(wr_splitter_TransCmdIntf_valid),
    .TransCmdIntf_bits_NumBytes(wr_splitter_TransCmdIntf_bits_NumBytes),
    .TransCmdIntf_bits_Address(wr_splitter_TransCmdIntf_bits_Address),
    .TransStatIntf_ready(wr_splitter_TransStatIntf_ready),
    .TransStatIntf_valid(wr_splitter_TransStatIntf_valid),
    .TransStatIntf_bits(wr_splitter_TransStatIntf_bits),
    .XferCmdIntf_ready(wr_splitter_XferCmdIntf_ready),
    .XferCmdIntf_valid(wr_splitter_XferCmdIntf_valid),
    .XferCmdIntf_bits_NumBytes(wr_splitter_XferCmdIntf_bits_NumBytes),
    .XferCmdIntf_bits_Address(wr_splitter_XferCmdIntf_bits_Address),
    .XferStatIntf_ready(wr_splitter_XferStatIntf_ready),
    .XferStatIntf_valid(wr_splitter_XferStatIntf_valid),
    .XferStatIntf_bits(wr_splitter_XferStatIntf_bits)
  );
  assign Irq = irq_status & irq_enable; // @[Controller.scala 215:31]
  assign RdCmdIntf_valid = rd_splitter_XferCmdIntf_valid; // @[Controller.scala 142:37]
  assign RdCmdIntf_bits_NumBytes = rd_splitter_XferCmdIntf_bits_NumBytes; // @[Controller.scala 142:37]
  assign RdCmdIntf_bits_Address = rd_splitter_XferCmdIntf_bits_Address; // @[Controller.scala 142:37]
  assign RdStatIntf_ready = rd_splitter_XferStatIntf_ready; // @[Controller.scala 143:37]
  assign WrCmdIntf_valid = wr_splitter_XferCmdIntf_valid; // @[Controller.scala 173:37]
  assign WrCmdIntf_bits_NumBytes = wr_splitter_XferCmdIntf_bits_NumBytes; // @[Controller.scala 173:37]
  assign WrCmdIntf_bits_Address = wr_splitter_XferCmdIntf_bits_Address; // @[Controller.scala 173:37]
  assign WrStatIntf_ready = wr_splitter_XferStatIntf_ready; // @[Controller.scala 174:37]
  assign reg_file_RegIntf_RegIntf_PREADY = reg_file_setup_phase_RegIntf_PREADY; // @[Controller.scala 103:25]
  assign reg_file_RegIntf_RegIntf_PRDATA = reg_file_setup_phase_RegIntf_PRDATA; // @[Controller.scala 103:25]
  assign reg_file_RegIntf_RegIntf_PSLVERR = reg_file_setup_phase_RegIntf_PSLVERR; // @[Controller.scala 103:25]
  assign reg_file_ACLK = ACLK; // @[Controller.scala 101:25]
  assign reg_file_ARESETn = ARESETn; // @[Controller.scala 102:25]
  assign reg_file_Busy = busy; // @[Controller.scala 104:25]
  assign reg_file_IRQStatus = irq_status; // @[Controller.scala 105:25]
  assign reg_file_StatCode = stat_code; // @[Controller.scala 106:25]
  assign reg_file_setup_phase_RegIntf_PADDR = reg_file_RegIntf_RegIntf_PADDR; // @[Controller.scala 103:25]
  assign reg_file_setup_phase_RegIntf_PSEL = reg_file_RegIntf_RegIntf_PSEL; // @[Controller.scala 103:25]
  assign reg_file_setup_phase_RegIntf_PENABLE = reg_file_RegIntf_RegIntf_PENABLE; // @[Controller.scala 103:25]
  assign reg_file_setup_phase_RegIntf_PWRITE = reg_file_RegIntf_RegIntf_PWRITE; // @[Controller.scala 103:25]
  assign reg_file_setup_phase_RegIntf_PWDATA = reg_file_RegIntf_RegIntf_PWDATA; // @[Controller.scala 103:25]
  assign rd_splitter_ACLK = ACLK; // @[Controller.scala 134:37]
  assign rd_splitter_ARESETn = ARESETn; // @[Controller.scala 135:37]
  assign rd_splitter_TransCmdIntf_valid = rd_trans_cmd_valid; // @[Controller.scala 137:37]
  assign rd_splitter_TransCmdIntf_bits_NumBytes = rd_trans_cmd_bits_NumBytes; // @[Controller.scala 138:37]
  assign rd_splitter_TransCmdIntf_bits_Address = rd_trans_cmd_bits_Address; // @[Controller.scala 138:37]
  assign rd_splitter_TransStatIntf_ready = state == 2'h2; // @[Controller.scala 279:38]
  assign rd_splitter_XferCmdIntf_ready = RdCmdIntf_ready; // @[Controller.scala 142:37]
  assign rd_splitter_XferStatIntf_valid = RdStatIntf_valid; // @[Controller.scala 143:37]
  assign rd_splitter_XferStatIntf_bits = RdStatIntf_bits; // @[Controller.scala 143:37]
  assign wr_splitter_ACLK = ACLK; // @[Controller.scala 165:37]
  assign wr_splitter_ARESETn = ARESETn; // @[Controller.scala 166:37]
  assign wr_splitter_TransCmdIntf_valid = wr_trans_cmd_valid; // @[Controller.scala 168:37]
  assign wr_splitter_TransCmdIntf_bits_NumBytes = wr_trans_cmd_bits_NumBytes; // @[Controller.scala 169:37]
  assign wr_splitter_TransCmdIntf_bits_Address = wr_trans_cmd_bits_Address; // @[Controller.scala 169:37]
  assign wr_splitter_TransStatIntf_ready = state == 2'h2; // @[Controller.scala 298:38]
  assign wr_splitter_XferCmdIntf_ready = WrCmdIntf_ready; // @[Controller.scala 173:37]
  assign wr_splitter_XferStatIntf_valid = WrStatIntf_valid; // @[Controller.scala 174:37]
  assign wr_splitter_XferStatIntf_bits = WrStatIntf_bits; // @[Controller.scala 174:37]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 192:24]
      state <= 2'h0; // @[Controller.scala 194:53 195:29 196:39 197:29 74:67]
    end else if (2'h0 == state) begin // @[Controller.scala 192:24]
      if (go_pulse & length == 32'h0) begin // @[Controller.scala 201:60]
        state <= 2'h2; // @[Controller.scala 202:29]
      end else if (go_pulse) begin // @[Controller.scala 74:67]
        state <= 2'h1;
      end
    end else if (2'h1 == state) begin // @[Controller.scala 192:24]
      if (read_cmd_posted & write_cmd_posted) begin // @[Controller.scala 206:62]
        state <= 2'h2; // @[Controller.scala 207:29]
      end
    end else if (2'h2 == state) begin // @[Controller.scala 74:67]
      if (read_stat_posted & write_stat_posted) begin
        state <= 2'h0;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 234:26]
      busy <= 1'h0;
    end else begin
      busy <= state != 2'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 239:75]
      irq_status <= 1'h0; // @[Controller.scala 240:25]
    end else begin
      irq_status <= state == 2'h2 & read_stat_posted & write_stat_posted | _GEN_9;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 248:24]
      stat_code <= 2'h0; // @[Controller.scala 250:62 251:45 252:37 253:52 254:37 256:37 91:67]
    end else if (_T_11) begin // @[Controller.scala 91:67]
      if (_T_12) begin
        if (err_stat != 2'h0) begin
          stat_code <= err_stat;
        end else if (read_stat != 2'h0) begin
          stat_code <= read_stat;
        end else begin
          stat_code <= write_stat;
        end
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 303:24]
      rd_trans_cmd_valid <= 1'h0;
    end else if (_T_2) begin // @[Controller.scala 303:24]
      rd_trans_cmd_valid <= _T_47; // @[Controller.scala 315:43 317:49 118:79]
    end else if (_T_7) begin // @[Controller.scala 118:79]
      if (rd_trans_cmd_ready) begin
        rd_trans_cmd_valid <= 1'h0;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 303:24]
      rd_trans_cmd_bits_NumBytes <= 32'h0; // @[Controller.scala 120:48 306:53 308:49]
    end else if (_T_2) begin // @[Controller.scala 120:48]
      if (go_pulse & length != 32'h0) begin
        rd_trans_cmd_bits_NumBytes <= length;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 303:24]
      rd_trans_cmd_bits_Address <= 32'h0; // @[Controller.scala 120:48 306:53 309:49]
    end else if (_T_2) begin // @[Controller.scala 120:48]
      if (go_pulse & length != 32'h0) begin
        rd_trans_cmd_bits_Address <= src_addr;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 325:24]
      wr_trans_cmd_valid <= 1'h0;
    end else if (_T_2) begin // @[Controller.scala 325:24]
      wr_trans_cmd_valid <= _T_47; // @[Controller.scala 337:43 339:49 149:79]
    end else if (_T_7) begin // @[Controller.scala 149:79]
      if (wr_trans_cmd_ready) begin
        wr_trans_cmd_valid <= 1'h0;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 325:24]
      wr_trans_cmd_bits_NumBytes <= 32'h0; // @[Controller.scala 151:48 328:53 330:49]
    end else if (_T_2) begin // @[Controller.scala 151:48]
      if (_T_47) begin
        wr_trans_cmd_bits_NumBytes <= length;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 325:24]
      wr_trans_cmd_bits_Address <= 32'h0; // @[Controller.scala 151:48 328:53 331:49]
    end else if (_T_2) begin // @[Controller.scala 151:48]
      if (_T_47) begin
        wr_trans_cmd_bits_Address <= dst_addr;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 303:24]
      read_cmd_posted <= 1'h0; // @[Controller.scala 305:49]
    end else if (_T_2) begin // @[Controller.scala 303:24]
      read_cmd_posted <= 1'h0;
    end else if (_T_7) begin // @[Controller.scala 179:71]
      read_cmd_posted <= _GEN_30;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 325:24]
      write_cmd_posted <= 1'h0; // @[Controller.scala 327:49]
    end else if (_T_2) begin // @[Controller.scala 325:24]
      write_cmd_posted <= 1'h0;
    end else if (_T_7) begin // @[Controller.scala 180:71]
      write_cmd_posted <= _GEN_41;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 266:24]
      read_stat_posted <= 1'h0; // @[Controller.scala 269:41]
    end else if (_T_2) begin // @[Controller.scala 266:24]
      read_stat_posted <= 1'h0;
    end else if (_T_11) begin // @[Controller.scala 181:71]
      read_stat_posted <= _GEN_16;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 285:24]
      write_stat_posted <= 1'h0; // @[Controller.scala 288:42]
    end else if (_T_2) begin // @[Controller.scala 285:24]
      write_stat_posted <= 1'h0;
    end else if (_T_11) begin // @[Controller.scala 182:71]
      write_stat_posted <= _GEN_22;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 266:24]
      read_stat <= 2'h0; // @[Controller.scala 268:41]
    end else if (_T_2) begin // @[Controller.scala 266:24]
      read_stat <= 2'h0; // @[Controller.scala 272:66 273:41 183:71]
    end else if (_T_11) begin // @[Controller.scala 183:71]
      if (rd_trans_stat_valid | _T_25) begin
        read_stat <= rd_trans_stat_bits;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 285:24]
      write_stat <= 2'h0; // @[Controller.scala 287:42]
    end else if (_T_2) begin // @[Controller.scala 285:24]
      write_stat <= 2'h0; // @[Controller.scala 291:66 292:42 184:71]
    end else if (_T_11) begin // @[Controller.scala 184:71]
      if (wr_trans_stat_valid | _T_25) begin
        write_stat <= wr_trans_stat_bits;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Controller.scala 220:24]
      err_stat <= 2'h0; // @[Controller.scala 222:53 223:33 225:33]
    end else if (_T_2) begin // @[Controller.scala 185:71]
      if (_T_4) begin
        err_stat <= 2'h2;
      end else begin
        err_stat <= 2'h0;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  busy = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  irq_status = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  stat_code = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  rd_trans_cmd_valid = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  rd_trans_cmd_bits_NumBytes = _RAND_5[31:0];
  _RAND_6 = {1{`RANDOM}};
  rd_trans_cmd_bits_Address = _RAND_6[31:0];
  _RAND_7 = {1{`RANDOM}};
  wr_trans_cmd_valid = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wr_trans_cmd_bits_NumBytes = _RAND_8[31:0];
  _RAND_9 = {1{`RANDOM}};
  wr_trans_cmd_bits_Address = _RAND_9[31:0];
  _RAND_10 = {1{`RANDOM}};
  read_cmd_posted = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  write_cmd_posted = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  read_stat_posted = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  write_stat_posted = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  read_stat = _RAND_14[1:0];
  _RAND_15 = {1{`RANDOM}};
  write_stat = _RAND_15[1:0];
  _RAND_16 = {1{`RANDOM}};
  err_stat = _RAND_16[1:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    state = 2'h0;
  end
  if (reset) begin
    busy = 1'h0;
  end
  if (reset) begin
    irq_status = 1'h0;
  end
  if (reset) begin
    stat_code = 2'h0;
  end
  if (reset) begin
    rd_trans_cmd_valid = 1'h0;
  end
  if (reset) begin
    rd_trans_cmd_bits_NumBytes = 32'h0;
  end
  if (reset) begin
    rd_trans_cmd_bits_Address = 32'h0;
  end
  if (reset) begin
    wr_trans_cmd_valid = 1'h0;
  end
  if (reset) begin
    wr_trans_cmd_bits_NumBytes = 32'h0;
  end
  if (reset) begin
    wr_trans_cmd_bits_Address = 32'h0;
  end
  if (reset) begin
    read_cmd_posted = 1'h0;
  end
  if (reset) begin
    write_cmd_posted = 1'h0;
  end
  if (reset) begin
    read_stat_posted = 1'h0;
  end
  if (reset) begin
    write_stat_posted = 1'h0;
  end
  if (reset) begin
    read_stat = 2'h0;
  end
  if (reset) begin
    write_stat = 2'h0;
  end
  if (reset) begin
    err_stat = 2'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Reader(
  input         ACLK,
  input         ARESETn,
  output        CmdIntf_ready,
  input         CmdIntf_valid,
  input  [11:0] CmdIntf_bits_NumBytes,
  input  [31:0] CmdIntf_bits_Address,
  input         StatIntf_ready,
  output        StatIntf_valid,
  output [1:0]  StatIntf_bits,
  input         DataIntf_ready,
  output        DataIntf_valid,
  output [63:0] DataIntf_bits,
  input         ReadIntf_AR_ready,
  output        ReadIntf_AR_valid,
  output [31:0] ReadIntf_AR_bits_ADDR,
  output [7:0]  ReadIntf_AR_bits_LEN,
  output [2:0]  ReadIntf_AR_bits_SIZE,
  output [1:0]  ReadIntf_AR_bits_BURST,
  output [3:0]  ReadIntf_AR_bits_CACHE,
  output [2:0]  ReadIntf_AR_bits_PROT,
  output        ReadIntf_R_ready,
  input         ReadIntf_R_valid,
  input  [63:0] ReadIntf_R_bits_DATA,
  input  [1:0]  ReadIntf_R_bits_RESP,
  input         ReadIntf_R_bits_LAST
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_REG_INIT
  wire  reset = ~ARESETn; // @[Reader.scala 58:34]
  reg [1:0] state; // @[Reader.scala 64:63]
  reg [1:0] read_resp; // @[Reader.scala 66:63]
  wire [31:0] _ar_addr_T = {{3'd0}, CmdIntf_bits_Address[31:3]}; // @[Reader.scala 70:45]
  wire [34:0] ar_addr = {_ar_addr_T, 3'h0}; // @[Reader.scala 70:59]
  reg  ar_valid; // @[Reader.scala 72:63]
  reg [31:0] ar_payload_ADDR; // @[Reader.scala 74:32]
  reg [7:0] ar_payload_LEN; // @[Reader.scala 74:32]
  reg [2:0] ar_payload_SIZE; // @[Reader.scala 74:32]
  reg [1:0] ar_payload_BURST; // @[Reader.scala 74:32]
  reg [3:0] ar_payload_CACHE; // @[Reader.scala 74:32]
  reg [2:0] ar_payload_PROT; // @[Reader.scala 74:32]
  wire  _T_2 = 2'h0 == state; // @[Reader.scala 84:24]
  wire  _T_5 = 2'h1 == state; // @[Reader.scala 84:24]
  wire  _T_8 = 2'h2 == state; // @[Reader.scala 84:24]
  wire  _last_beat_T = ReadIntf_R_valid & ReadIntf_R_ready; // @[Reader.scala 167:41]
  wire  last_beat = ReadIntf_R_valid & ReadIntf_R_ready & ReadIntf_R_bits_LAST; // @[Reader.scala 167:61]
  wire [1:0] _GEN_3 = StatIntf_ready ? 2'h0 : state; // @[Reader.scala 101:39 102:29 64:63]
  wire [34:0] _GEN_10 = CmdIntf_valid ? ar_addr : {{3'd0}, ar_payload_ADDR}; // @[Reader.scala 112:38 115:41 74:32]
  wire [11:0] _ar_len_T = {{3'd0}, CmdIntf_bits_NumBytes[11:3]}; // @[Reader.scala 168:48]
  wire  _ar_len_T_2 = |CmdIntf_bits_NumBytes[2:0]; // @[Reader.scala 169:62]
  wire [11:0] _GEN_35 = {{11'd0}, _ar_len_T_2}; // @[Reader.scala 168:62]
  wire [11:0] _ar_len_T_4 = _ar_len_T + _GEN_35; // @[Reader.scala 168:62]
  wire [11:0] _ar_len_T_6 = _ar_len_T_4 - 12'h1; // @[Reader.scala 169:67]
  wire [7:0] ar_len = _ar_len_T_6[7:0]; // @[Reader.scala 168:21 71:27]
  wire [34:0] _GEN_21 = _T_2 ? _GEN_10 : {{3'd0}, ar_payload_ADDR}; // @[Reader.scala 110:24 74:32]
  wire  _T_26 = state == 2'h2; // @[Reader.scala 156:21]
  assign CmdIntf_ready = state == 2'h0; // @[Reader.scala 186:34]
  assign StatIntf_valid = state == 2'h3; // @[Reader.scala 174:34]
  assign StatIntf_bits = read_resp; // @[Reader.scala 175:25]
  assign DataIntf_valid = _T_26 & ReadIntf_R_valid; // @[Reader.scala 180:46]
  assign DataIntf_bits = ReadIntf_R_bits_DATA; // @[Reader.scala 181:25]
  assign ReadIntf_AR_valid = ar_valid; // @[Reader.scala 133:29]
  assign ReadIntf_AR_bits_ADDR = ar_payload_ADDR; // @[Reader.scala 134:29]
  assign ReadIntf_AR_bits_LEN = ar_payload_LEN; // @[Reader.scala 134:29]
  assign ReadIntf_AR_bits_SIZE = ar_payload_SIZE; // @[Reader.scala 134:29]
  assign ReadIntf_AR_bits_BURST = ar_payload_BURST; // @[Reader.scala 134:29]
  assign ReadIntf_AR_bits_CACHE = ar_payload_CACHE; // @[Reader.scala 134:29]
  assign ReadIntf_AR_bits_PROT = ar_payload_PROT; // @[Reader.scala 134:29]
  assign ReadIntf_R_ready = state == 2'h2 & DataIntf_ready; // @[Reader.scala 156:32 157:25 159:25]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 84:24]
      state <= 2'h0; // @[Reader.scala 86:38 87:29 64:63]
    end else if (2'h0 == state) begin // @[Reader.scala 84:24]
      if (CmdIntf_valid) begin // @[Reader.scala 91:42]
        state <= 2'h1; // @[Reader.scala 92:29]
      end
    end else if (2'h1 == state) begin // @[Reader.scala 84:24]
      if (ReadIntf_AR_ready) begin // @[Reader.scala 96:34]
        state <= 2'h2; // @[Reader.scala 97:29]
      end
    end else if (2'h2 == state) begin // @[Reader.scala 84:24]
      if (last_beat) begin
        state <= 2'h3;
      end
    end else if (2'h3 == state) begin // @[Reader.scala 64:63]
      state <= _GEN_3;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 140:24]
      read_resp <= 2'h0; // @[Reader.scala 142:29]
    end else if (_T_2) begin // @[Reader.scala 140:24]
      read_resp <= 2'h0; // @[Reader.scala 145:61 146:46 147:37 66:{63,63}]
    end else if (_T_8) begin // @[Reader.scala 66:63]
      if (_last_beat_T) begin
        if (read_resp == 2'h0) begin
          read_resp <= ReadIntf_R_bits_RESP;
        end
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_valid <= 1'h0;
    end else if (_T_2) begin // @[Reader.scala 110:24]
      ar_valid <= CmdIntf_valid; // @[Reader.scala 127:42 128:41 72:63]
    end else if (_T_5) begin // @[Reader.scala 72:63]
      if (ReadIntf_AR_ready) begin
        ar_valid <= 1'h0;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 74:32]
      ar_payload_ADDR <= 32'h0; // @[Reader.scala 74:32]
    end else begin
      ar_payload_ADDR <= _GEN_21[31:0];
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_payload_LEN <= 8'h0; // @[Reader.scala 112:38 116:41 74:32]
    end else if (_T_2) begin // @[Reader.scala 74:32]
      if (CmdIntf_valid) begin
        ar_payload_LEN <= ar_len;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_payload_SIZE <= 3'h0; // @[Reader.scala 112:38 117:41 74:32]
    end else if (_T_2) begin // @[Reader.scala 74:32]
      if (CmdIntf_valid) begin
        ar_payload_SIZE <= 3'h3;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_payload_BURST <= 2'h0; // @[Reader.scala 112:38 118:41 74:32]
    end else if (_T_2) begin // @[Reader.scala 74:32]
      if (CmdIntf_valid) begin
        ar_payload_BURST <= 2'h1;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_payload_CACHE <= 4'h0; // @[Reader.scala 112:38 120:41 74:32]
    end else if (_T_2) begin // @[Reader.scala 74:32]
      if (CmdIntf_valid) begin
        ar_payload_CACHE <= 4'h2;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Reader.scala 110:24]
      ar_payload_PROT <= 3'h0; // @[Reader.scala 112:38 121:41 74:32]
    end else if (_T_2) begin // @[Reader.scala 74:32]
      if (CmdIntf_valid) begin
        ar_payload_PROT <= 3'h2;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  read_resp = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  ar_valid = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  ar_payload_ADDR = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  ar_payload_LEN = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  ar_payload_SIZE = _RAND_5[2:0];
  _RAND_6 = {1{`RANDOM}};
  ar_payload_BURST = _RAND_6[1:0];
  _RAND_7 = {1{`RANDOM}};
  ar_payload_CACHE = _RAND_7[3:0];
  _RAND_8 = {1{`RANDOM}};
  ar_payload_PROT = _RAND_8[2:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    state = 2'h0;
  end
  if (reset) begin
    read_resp = 2'h0;
  end
  if (reset) begin
    ar_valid = 1'h0;
  end
  if (reset) begin
    ar_payload_ADDR = 32'h0;
  end
  if (reset) begin
    ar_payload_LEN = 8'h0;
  end
  if (reset) begin
    ar_payload_SIZE = 3'h0;
  end
  if (reset) begin
    ar_payload_BURST = 2'h0;
  end
  if (reset) begin
    ar_payload_CACHE = 4'h0;
  end
  if (reset) begin
    ar_payload_PROT = 3'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Writer(
  input         ACLK,
  input         ARESETn,
  output        CmdIntf_ready,
  input         CmdIntf_valid,
  input  [11:0] CmdIntf_bits_NumBytes,
  input  [31:0] CmdIntf_bits_Address,
  input         StatIntf_ready,
  output        StatIntf_valid,
  output [1:0]  StatIntf_bits,
  output        DataIntf_ready,
  input         DataIntf_valid,
  input  [63:0] DataIntf_bits,
  input         WriteIntf_AW_ready,
  output        WriteIntf_AW_valid,
  output [31:0] WriteIntf_AW_bits_ADDR,
  output [7:0]  WriteIntf_AW_bits_LEN,
  output [2:0]  WriteIntf_AW_bits_SIZE,
  output [1:0]  WriteIntf_AW_bits_BURST,
  output [3:0]  WriteIntf_AW_bits_CACHE,
  output [2:0]  WriteIntf_AW_bits_PROT,
  input         WriteIntf_W_ready,
  output        WriteIntf_W_valid,
  output [63:0] WriteIntf_W_bits_DATA,
  output [7:0]  WriteIntf_W_bits_STRB,
  output        WriteIntf_W_bits_LAST,
  output        WriteIntf_B_ready,
  input         WriteIntf_B_valid,
  input  [1:0]  WriteIntf_B_bits_RESP
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
`endif // RANDOMIZE_REG_INIT
  wire  reset = ~ARESETn; // @[Writer.scala 58:34]
  reg [2:0] state; // @[Writer.scala 66:63]
  reg [1:0] write_resp; // @[Writer.scala 67:63]
  reg [11:0] num_bytes; // @[Writer.scala 68:63]
  wire [31:0] _aw_addr_T = {{3'd0}, CmdIntf_bits_Address[31:3]}; // @[Writer.scala 73:45]
  wire [34:0] aw_addr = {_aw_addr_T, 3'h0}; // @[Writer.scala 73:59]
  reg  aw_valid; // @[Writer.scala 75:63]
  reg [31:0] aw_payload_ADDR; // @[Writer.scala 77:33]
  reg [7:0] aw_payload_LEN; // @[Writer.scala 77:33]
  reg [2:0] aw_payload_SIZE; // @[Writer.scala 77:33]
  reg [1:0] aw_payload_BURST; // @[Writer.scala 77:33]
  reg [3:0] aw_payload_CACHE; // @[Writer.scala 77:33]
  reg [2:0] aw_payload_PROT; // @[Writer.scala 77:33]
  wire  _T_2 = 3'h0 == state; // @[Writer.scala 90:25]
  wire  _T_5 = 3'h1 == state; // @[Writer.scala 90:25]
  wire  _T_8 = 3'h2 == state; // @[Writer.scala 90:25]
  wire  _last_beat_T = WriteIntf_W_valid & WriteIntf_W_ready; // @[Writer.scala 234:42]
  wire  last_beat = WriteIntf_W_valid & WriteIntf_W_ready & WriteIntf_W_bits_LAST; // @[Writer.scala 234:63]
  wire  _T_11 = 3'h3 == state; // @[Writer.scala 90:25]
  wire [2:0] _GEN_3 = WriteIntf_B_valid ? 3'h4 : state; // @[Writer.scala 107:43 108:29 66:63]
  wire [2:0] _GEN_4 = StatIntf_ready ? 3'h0 : state; // @[Writer.scala 112:40 113:29 66:63]
  wire [2:0] _GEN_5 = 3'h4 == state ? _GEN_4 : state; // @[Writer.scala 90:25 66:63]
  wire [34:0] _GEN_12 = CmdIntf_valid ? aw_addr : {{3'd0}, aw_payload_ADDR}; // @[Writer.scala 123:39 126:42 77:33]
  wire [11:0] _aw_len_T = {{3'd0}, CmdIntf_bits_NumBytes[11:3]}; // @[Writer.scala 235:49]
  wire  _aw_len_T_2 = |CmdIntf_bits_NumBytes[2:0]; // @[Writer.scala 236:63]
  wire [11:0] _GEN_54 = {{11'd0}, _aw_len_T_2}; // @[Writer.scala 235:63]
  wire [11:0] _aw_len_T_4 = _aw_len_T + _GEN_54; // @[Writer.scala 235:63]
  wire [11:0] _aw_len_T_6 = _aw_len_T_4 - 12'h1; // @[Writer.scala 236:68]
  wire [7:0] aw_len = _aw_len_T_6[7:0]; // @[Writer.scala 235:22 74:27]
  wire [34:0] _GEN_23 = _T_2 ? _GEN_12 : {{3'd0}, aw_payload_ADDR}; // @[Writer.scala 121:25 77:33]
  wire  _T_27 = state == 3'h2; // @[Writer.scala 164:22]
  wire [11:0] _num_bytes_T_1 = num_bytes - 12'h8; // @[Writer.scala 184:50]
  wire [6:0] _GEN_41 = 3'h1 == num_bytes[2:0] ? 7'h1 : 7'h0; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_42 = 3'h2 == num_bytes[2:0] ? 7'h3 : _GEN_41; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_43 = 3'h3 == num_bytes[2:0] ? 7'h7 : _GEN_42; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_44 = 3'h4 == num_bytes[2:0] ? 7'hf : _GEN_43; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_45 = 3'h5 == num_bytes[2:0] ? 7'h1f : _GEN_44; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_46 = 3'h6 == num_bytes[2:0] ? 7'h3f : _GEN_45; // @[Writer.scala 201:{26,26}]
  wire [6:0] _GEN_47 = 3'h7 == num_bytes[2:0] ? 7'h7f : _GEN_46; // @[Writer.scala 201:{26,26}]
  wire [7:0] _GEN_48 = num_bytes >= 12'h8 ? 8'hff : {{1'd0}, _GEN_47}; // @[Writer.scala 198:44 199:26 201:26]
  assign CmdIntf_ready = state == 3'h0; // @[Writer.scala 252:34]
  assign StatIntf_valid = state == 3'h4; // @[Writer.scala 246:38]
  assign StatIntf_bits = write_resp; // @[Writer.scala 247:29]
  assign DataIntf_ready = _T_27 & WriteIntf_W_ready; // @[Writer.scala 257:46]
  assign WriteIntf_AW_valid = aw_valid; // @[Writer.scala 144:33]
  assign WriteIntf_AW_bits_ADDR = aw_payload_ADDR; // @[Writer.scala 145:33]
  assign WriteIntf_AW_bits_LEN = aw_payload_LEN; // @[Writer.scala 145:33]
  assign WriteIntf_AW_bits_SIZE = aw_payload_SIZE; // @[Writer.scala 145:33]
  assign WriteIntf_AW_bits_BURST = aw_payload_BURST; // @[Writer.scala 145:33]
  assign WriteIntf_AW_bits_CACHE = aw_payload_CACHE; // @[Writer.scala 145:33]
  assign WriteIntf_AW_bits_PROT = aw_payload_PROT; // @[Writer.scala 145:33]
  assign WriteIntf_W_valid = _T_27 & DataIntf_valid; // @[Writer.scala 212:33 213:25 215:25]
  assign WriteIntf_W_bits_DATA = state == 3'h2 ? DataIntf_bits : 64'h0; // @[Writer.scala 164:33 165:37 167:37]
  assign WriteIntf_W_bits_STRB = _T_27 ? _GEN_48 : 8'h0; // @[Writer.scala 197:33 204:22]
  assign WriteIntf_W_bits_LAST = _T_27 & num_bytes <= 12'h8; // @[Writer.scala 223:33 224:25 226:25]
  assign WriteIntf_B_ready = state == 3'h3; // @[Writer.scala 241:38]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 90:25]
      state <= 3'h0; // @[Writer.scala 92:39 93:29 66:63]
    end else if (3'h0 == state) begin // @[Writer.scala 90:25]
      if (CmdIntf_valid) begin // @[Writer.scala 97:43]
        state <= 3'h1; // @[Writer.scala 98:29]
      end
    end else if (3'h1 == state) begin // @[Writer.scala 90:25]
      if (WriteIntf_AW_ready) begin // @[Writer.scala 102:35]
        state <= 3'h2; // @[Writer.scala 103:29]
      end
    end else if (3'h2 == state) begin // @[Writer.scala 90:25]
      if (last_beat) begin
        state <= 3'h3;
      end
    end else if (3'h3 == state) begin
      state <= _GEN_3;
    end else begin
      state <= _GEN_5;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 150:25]
      write_resp <= 2'h0; // @[Writer.scala 152:33]
    end else if (_T_2) begin // @[Writer.scala 150:25]
      write_resp <= 2'h0; // @[Writer.scala 155:43 156:33 67:63]
    end else if (_T_11) begin // @[Writer.scala 67:63]
      if (WriteIntf_B_valid) begin
        write_resp <= WriteIntf_B_bits_RESP;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 173:25]
      num_bytes <= 12'h0; // @[Writer.scala 175:39 176:33 178:33]
    end else if (_T_2) begin // @[Writer.scala 173:25]
      if (CmdIntf_valid) begin // @[Writer.scala 182:63]
        num_bytes <= CmdIntf_bits_NumBytes; // @[Writer.scala 183:50 184:37 68:63]
      end else begin
        num_bytes <= 12'h0; // @[Writer.scala 68:63]
      end
    end else if (_T_8) begin // @[Writer.scala 173:25]
      if (_last_beat_T) begin // @[Writer.scala 189:29]
        if (num_bytes > 12'h8) begin
          num_bytes <= _num_bytes_T_1;
        end
      end
    end else if (_T_11) begin // @[Writer.scala 68:63]
      num_bytes <= 12'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_valid <= 1'h0;
    end else if (_T_2) begin // @[Writer.scala 121:25]
      aw_valid <= CmdIntf_valid; // @[Writer.scala 138:44 139:42 75:63]
    end else if (_T_5) begin // @[Writer.scala 75:63]
      if (WriteIntf_AW_ready) begin
        aw_valid <= 1'h0;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 77:33]
      aw_payload_ADDR <= 32'h0; // @[Writer.scala 77:33]
    end else begin
      aw_payload_ADDR <= _GEN_23[31:0];
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_payload_LEN <= 8'h0; // @[Writer.scala 123:39 127:42 77:33]
    end else if (_T_2) begin // @[Writer.scala 77:33]
      if (CmdIntf_valid) begin
        aw_payload_LEN <= aw_len;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_payload_SIZE <= 3'h0; // @[Writer.scala 123:39 128:42 77:33]
    end else if (_T_2) begin // @[Writer.scala 77:33]
      if (CmdIntf_valid) begin
        aw_payload_SIZE <= 3'h3;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_payload_BURST <= 2'h0; // @[Writer.scala 123:39 129:42 77:33]
    end else if (_T_2) begin // @[Writer.scala 77:33]
      if (CmdIntf_valid) begin
        aw_payload_BURST <= 2'h1;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_payload_CACHE <= 4'h0; // @[Writer.scala 123:39 131:42 77:33]
    end else if (_T_2) begin // @[Writer.scala 77:33]
      if (CmdIntf_valid) begin
        aw_payload_CACHE <= 4'h2;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[Writer.scala 121:25]
      aw_payload_PROT <= 3'h0; // @[Writer.scala 123:39 132:42 77:33]
    end else if (_T_2) begin // @[Writer.scala 77:33]
      if (CmdIntf_valid) begin
        aw_payload_PROT <= 3'h2;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  write_resp = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  num_bytes = _RAND_2[11:0];
  _RAND_3 = {1{`RANDOM}};
  aw_valid = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  aw_payload_ADDR = _RAND_4[31:0];
  _RAND_5 = {1{`RANDOM}};
  aw_payload_LEN = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  aw_payload_SIZE = _RAND_6[2:0];
  _RAND_7 = {1{`RANDOM}};
  aw_payload_BURST = _RAND_7[1:0];
  _RAND_8 = {1{`RANDOM}};
  aw_payload_CACHE = _RAND_8[3:0];
  _RAND_9 = {1{`RANDOM}};
  aw_payload_PROT = _RAND_9[2:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    state = 3'h0;
  end
  if (reset) begin
    write_resp = 2'h0;
  end
  if (reset) begin
    num_bytes = 12'h0;
  end
  if (reset) begin
    aw_valid = 1'h0;
  end
  if (reset) begin
    aw_payload_ADDR = 32'h0;
  end
  if (reset) begin
    aw_payload_LEN = 8'h0;
  end
  if (reset) begin
    aw_payload_SIZE = 3'h0;
  end
  if (reset) begin
    aw_payload_BURST = 2'h0;
  end
  if (reset) begin
    aw_payload_CACHE = 4'h0;
  end
  if (reset) begin
    aw_payload_PROT = 3'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module PeekQueue(
  input         ACLK,
  input         ARESETn,
  output        EnqIntf_ready,
  input         EnqIntf_valid,
  input  [63:0] EnqIntf_bits,
  input         DeqIntf_ready,
  output        DeqIntf_valid,
  output [63:0] DeqIntf_bits
);
`ifdef RANDOMIZE_MEM_INIT
  reg [63:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] mem [0:255]; // @[PeekQueue.scala 57:26]
  wire  mem_DeqIntf_bits_MPORT_en; // @[PeekQueue.scala 57:26]
  wire [7:0] mem_DeqIntf_bits_MPORT_addr; // @[PeekQueue.scala 57:26]
  wire [63:0] mem_DeqIntf_bits_MPORT_data; // @[PeekQueue.scala 57:26]
  wire [63:0] mem_MPORT_data; // @[PeekQueue.scala 57:26]
  wire [7:0] mem_MPORT_addr; // @[PeekQueue.scala 57:26]
  wire  mem_MPORT_mask; // @[PeekQueue.scala 57:26]
  wire  mem_MPORT_en; // @[PeekQueue.scala 57:26]
  wire  reset = ~ARESETn; // @[PeekQueue.scala 44:34]
  reg [8:0] counter; // @[PeekQueue.scala 52:63]
  reg [7:0] rdptr; // @[PeekQueue.scala 53:63]
  reg [7:0] wrptr; // @[PeekQueue.scala 54:63]
  wire  _T = EnqIntf_ready & EnqIntf_valid; // @[PeekQueue.scala 64:29]
  wire [8:0] _counter_T_1 = counter + 9'h1; // @[PeekQueue.scala 69:36]
  wire  _T_4 = DeqIntf_ready & DeqIntf_valid; // @[PeekQueue.scala 70:35]
  wire [8:0] _counter_T_3 = counter - 9'h1; // @[PeekQueue.scala 72:36]
  wire [7:0] _rdptr_T_1 = rdptr + 8'h1; // @[PeekQueue.scala 79:34]
  wire [7:0] _wrptr_T_1 = wrptr + 8'h1; // @[PeekQueue.scala 86:34]
  assign mem_DeqIntf_bits_MPORT_en = 1'h1;
  assign mem_DeqIntf_bits_MPORT_addr = rdptr;
  assign mem_DeqIntf_bits_MPORT_data = mem[mem_DeqIntf_bits_MPORT_addr]; // @[PeekQueue.scala 57:26]
  assign mem_MPORT_data = EnqIntf_bits;
  assign mem_MPORT_addr = wrptr;
  assign mem_MPORT_mask = 1'h1;
  assign mem_MPORT_en = EnqIntf_ready & EnqIntf_valid;
  assign EnqIntf_ready = counter != 9'h100; // @[PeekQueue.scala 104:36]
  assign DeqIntf_valid = counter != 9'h0; // @[PeekQueue.scala 105:36]
  assign DeqIntf_bits = mem_DeqIntf_bits_MPORT_data; // @[PeekQueue.scala 99:25]
  always @(posedge ACLK) begin
    if (mem_MPORT_en & mem_MPORT_mask) begin
      mem[mem_MPORT_addr] <= mem_MPORT_data; // @[PeekQueue.scala 57:26]
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[PeekQueue.scala 64:81]
      counter <= 9'h0; // @[PeekQueue.scala 66:25]
    end else if (!(EnqIntf_ready & EnqIntf_valid & DeqIntf_ready & DeqIntf_valid)) begin // @[PeekQueue.scala 67:53]
      if (_T) begin // @[PeekQueue.scala 70:53]
        counter <= _counter_T_1; // @[PeekQueue.scala 72:25]
      end else if (DeqIntf_ready & DeqIntf_valid) begin // @[PeekQueue.scala 52:63]
        counter <= _counter_T_3;
      end
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[PeekQueue.scala 78:47]
      rdptr <= 8'h0; // @[PeekQueue.scala 79:25]
    end else if (_T_4) begin // @[PeekQueue.scala 53:63]
      rdptr <= _rdptr_T_1;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[PeekQueue.scala 85:47]
      wrptr <= 8'h0; // @[PeekQueue.scala 86:25]
    end else if (_T) begin // @[PeekQueue.scala 54:63]
      wrptr <= _wrptr_T_1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {2{`RANDOM}};
  for (initvar = 0; initvar < 256; initvar = initvar+1)
    mem[initvar] = _RAND_0[63:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  counter = _RAND_1[8:0];
  _RAND_2 = {1{`RANDOM}};
  rdptr = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  wrptr = _RAND_3[7:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    counter = 9'h0;
  end
  if (reset) begin
    rdptr = 8'h0;
  end
  if (reset) begin
    wrptr = 8'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module DataMover(
  input         ACLK,
  input         ARESETn,
  output        RdCmdIntf_ready,
  input         RdCmdIntf_valid,
  input  [11:0] RdCmdIntf_bits_NumBytes,
  input  [31:0] RdCmdIntf_bits_Address,
  input         RdStatIntf_ready,
  output        RdStatIntf_valid,
  output [1:0]  RdStatIntf_bits,
  output        WrCmdIntf_ready,
  input         WrCmdIntf_valid,
  input  [11:0] WrCmdIntf_bits_NumBytes,
  input  [31:0] WrCmdIntf_bits_Address,
  input         WrStatIntf_ready,
  output        WrStatIntf_valid,
  output [1:0]  WrStatIntf_bits,
  output [31:0] M_AXI_AWADDR,
  output [7:0]  M_AXI_AWLEN,
  output [2:0]  M_AXI_AWSIZE,
  output [1:0]  M_AXI_AWBURST,
  output [3:0]  M_AXI_AWCACHE,
  output [2:0]  M_AXI_AWPROT,
  output        M_AXI_AWVALID,
  input         M_AXI_AWREADY,
  output [63:0] M_AXI_WDATA,
  output [7:0]  M_AXI_WSTRB,
  output        M_AXI_WLAST,
  output        M_AXI_WVALID,
  input         M_AXI_WREADY,
  input  [1:0]  M_AXI_BRESP,
  input         M_AXI_BVALID,
  output        M_AXI_BREADY,
  output [31:0] M_AXI_ARADDR,
  output [7:0]  M_AXI_ARLEN,
  output [2:0]  M_AXI_ARSIZE,
  output [1:0]  M_AXI_ARBURST,
  output [3:0]  M_AXI_ARCACHE,
  output [2:0]  M_AXI_ARPROT,
  output        M_AXI_ARVALID,
  input         M_AXI_ARREADY,
  input  [63:0] M_AXI_RDATA,
  input  [1:0]  M_AXI_RRESP,
  input         M_AXI_RLAST,
  input         M_AXI_RVALID,
  output        M_AXI_RREADY
);
  wire  reader_ACLK; // @[DataMover.scala 72:33]
  wire  reader_ARESETn; // @[DataMover.scala 72:33]
  wire  reader_CmdIntf_ready; // @[DataMover.scala 72:33]
  wire  reader_CmdIntf_valid; // @[DataMover.scala 72:33]
  wire [11:0] reader_CmdIntf_bits_NumBytes; // @[DataMover.scala 72:33]
  wire [31:0] reader_CmdIntf_bits_Address; // @[DataMover.scala 72:33]
  wire  reader_StatIntf_ready; // @[DataMover.scala 72:33]
  wire  reader_StatIntf_valid; // @[DataMover.scala 72:33]
  wire [1:0] reader_StatIntf_bits; // @[DataMover.scala 72:33]
  wire  reader_DataIntf_ready; // @[DataMover.scala 72:33]
  wire  reader_DataIntf_valid; // @[DataMover.scala 72:33]
  wire [63:0] reader_DataIntf_bits; // @[DataMover.scala 72:33]
  wire  reader_ReadIntf_AR_ready; // @[DataMover.scala 72:33]
  wire  reader_ReadIntf_AR_valid; // @[DataMover.scala 72:33]
  wire [31:0] reader_ReadIntf_AR_bits_ADDR; // @[DataMover.scala 72:33]
  wire [7:0] reader_ReadIntf_AR_bits_LEN; // @[DataMover.scala 72:33]
  wire [2:0] reader_ReadIntf_AR_bits_SIZE; // @[DataMover.scala 72:33]
  wire [1:0] reader_ReadIntf_AR_bits_BURST; // @[DataMover.scala 72:33]
  wire [3:0] reader_ReadIntf_AR_bits_CACHE; // @[DataMover.scala 72:33]
  wire [2:0] reader_ReadIntf_AR_bits_PROT; // @[DataMover.scala 72:33]
  wire  reader_ReadIntf_R_ready; // @[DataMover.scala 72:33]
  wire  reader_ReadIntf_R_valid; // @[DataMover.scala 72:33]
  wire [63:0] reader_ReadIntf_R_bits_DATA; // @[DataMover.scala 72:33]
  wire [1:0] reader_ReadIntf_R_bits_RESP; // @[DataMover.scala 72:33]
  wire  reader_ReadIntf_R_bits_LAST; // @[DataMover.scala 72:33]
  wire  writer_ACLK; // @[DataMover.scala 73:33]
  wire  writer_ARESETn; // @[DataMover.scala 73:33]
  wire  writer_CmdIntf_ready; // @[DataMover.scala 73:33]
  wire  writer_CmdIntf_valid; // @[DataMover.scala 73:33]
  wire [11:0] writer_CmdIntf_bits_NumBytes; // @[DataMover.scala 73:33]
  wire [31:0] writer_CmdIntf_bits_Address; // @[DataMover.scala 73:33]
  wire  writer_StatIntf_ready; // @[DataMover.scala 73:33]
  wire  writer_StatIntf_valid; // @[DataMover.scala 73:33]
  wire [1:0] writer_StatIntf_bits; // @[DataMover.scala 73:33]
  wire  writer_DataIntf_ready; // @[DataMover.scala 73:33]
  wire  writer_DataIntf_valid; // @[DataMover.scala 73:33]
  wire [63:0] writer_DataIntf_bits; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_AW_ready; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_AW_valid; // @[DataMover.scala 73:33]
  wire [31:0] writer_WriteIntf_AW_bits_ADDR; // @[DataMover.scala 73:33]
  wire [7:0] writer_WriteIntf_AW_bits_LEN; // @[DataMover.scala 73:33]
  wire [2:0] writer_WriteIntf_AW_bits_SIZE; // @[DataMover.scala 73:33]
  wire [1:0] writer_WriteIntf_AW_bits_BURST; // @[DataMover.scala 73:33]
  wire [3:0] writer_WriteIntf_AW_bits_CACHE; // @[DataMover.scala 73:33]
  wire [2:0] writer_WriteIntf_AW_bits_PROT; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_W_ready; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_W_valid; // @[DataMover.scala 73:33]
  wire [63:0] writer_WriteIntf_W_bits_DATA; // @[DataMover.scala 73:33]
  wire [7:0] writer_WriteIntf_W_bits_STRB; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_W_bits_LAST; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_B_ready; // @[DataMover.scala 73:33]
  wire  writer_WriteIntf_B_valid; // @[DataMover.scala 73:33]
  wire [1:0] writer_WriteIntf_B_bits_RESP; // @[DataMover.scala 73:33]
  wire  peekQueue_ACLK; // @[DataMover.scala 74:33]
  wire  peekQueue_ARESETn; // @[DataMover.scala 74:33]
  wire  peekQueue_EnqIntf_ready; // @[DataMover.scala 74:33]
  wire  peekQueue_EnqIntf_valid; // @[DataMover.scala 74:33]
  wire [63:0] peekQueue_EnqIntf_bits; // @[DataMover.scala 74:33]
  wire  peekQueue_DeqIntf_ready; // @[DataMover.scala 74:33]
  wire  peekQueue_DeqIntf_valid; // @[DataMover.scala 74:33]
  wire [63:0] peekQueue_DeqIntf_bits; // @[DataMover.scala 74:33]
  Reader reader ( // @[DataMover.scala 72:33]
    .ACLK(reader_ACLK),
    .ARESETn(reader_ARESETn),
    .CmdIntf_ready(reader_CmdIntf_ready),
    .CmdIntf_valid(reader_CmdIntf_valid),
    .CmdIntf_bits_NumBytes(reader_CmdIntf_bits_NumBytes),
    .CmdIntf_bits_Address(reader_CmdIntf_bits_Address),
    .StatIntf_ready(reader_StatIntf_ready),
    .StatIntf_valid(reader_StatIntf_valid),
    .StatIntf_bits(reader_StatIntf_bits),
    .DataIntf_ready(reader_DataIntf_ready),
    .DataIntf_valid(reader_DataIntf_valid),
    .DataIntf_bits(reader_DataIntf_bits),
    .ReadIntf_AR_ready(reader_ReadIntf_AR_ready),
    .ReadIntf_AR_valid(reader_ReadIntf_AR_valid),
    .ReadIntf_AR_bits_ADDR(reader_ReadIntf_AR_bits_ADDR),
    .ReadIntf_AR_bits_LEN(reader_ReadIntf_AR_bits_LEN),
    .ReadIntf_AR_bits_SIZE(reader_ReadIntf_AR_bits_SIZE),
    .ReadIntf_AR_bits_BURST(reader_ReadIntf_AR_bits_BURST),
    .ReadIntf_AR_bits_CACHE(reader_ReadIntf_AR_bits_CACHE),
    .ReadIntf_AR_bits_PROT(reader_ReadIntf_AR_bits_PROT),
    .ReadIntf_R_ready(reader_ReadIntf_R_ready),
    .ReadIntf_R_valid(reader_ReadIntf_R_valid),
    .ReadIntf_R_bits_DATA(reader_ReadIntf_R_bits_DATA),
    .ReadIntf_R_bits_RESP(reader_ReadIntf_R_bits_RESP),
    .ReadIntf_R_bits_LAST(reader_ReadIntf_R_bits_LAST)
  );
  Writer writer ( // @[DataMover.scala 73:33]
    .ACLK(writer_ACLK),
    .ARESETn(writer_ARESETn),
    .CmdIntf_ready(writer_CmdIntf_ready),
    .CmdIntf_valid(writer_CmdIntf_valid),
    .CmdIntf_bits_NumBytes(writer_CmdIntf_bits_NumBytes),
    .CmdIntf_bits_Address(writer_CmdIntf_bits_Address),
    .StatIntf_ready(writer_StatIntf_ready),
    .StatIntf_valid(writer_StatIntf_valid),
    .StatIntf_bits(writer_StatIntf_bits),
    .DataIntf_ready(writer_DataIntf_ready),
    .DataIntf_valid(writer_DataIntf_valid),
    .DataIntf_bits(writer_DataIntf_bits),
    .WriteIntf_AW_ready(writer_WriteIntf_AW_ready),
    .WriteIntf_AW_valid(writer_WriteIntf_AW_valid),
    .WriteIntf_AW_bits_ADDR(writer_WriteIntf_AW_bits_ADDR),
    .WriteIntf_AW_bits_LEN(writer_WriteIntf_AW_bits_LEN),
    .WriteIntf_AW_bits_SIZE(writer_WriteIntf_AW_bits_SIZE),
    .WriteIntf_AW_bits_BURST(writer_WriteIntf_AW_bits_BURST),
    .WriteIntf_AW_bits_CACHE(writer_WriteIntf_AW_bits_CACHE),
    .WriteIntf_AW_bits_PROT(writer_WriteIntf_AW_bits_PROT),
    .WriteIntf_W_ready(writer_WriteIntf_W_ready),
    .WriteIntf_W_valid(writer_WriteIntf_W_valid),
    .WriteIntf_W_bits_DATA(writer_WriteIntf_W_bits_DATA),
    .WriteIntf_W_bits_STRB(writer_WriteIntf_W_bits_STRB),
    .WriteIntf_W_bits_LAST(writer_WriteIntf_W_bits_LAST),
    .WriteIntf_B_ready(writer_WriteIntf_B_ready),
    .WriteIntf_B_valid(writer_WriteIntf_B_valid),
    .WriteIntf_B_bits_RESP(writer_WriteIntf_B_bits_RESP)
  );
  PeekQueue peekQueue ( // @[DataMover.scala 74:33]
    .ACLK(peekQueue_ACLK),
    .ARESETn(peekQueue_ARESETn),
    .EnqIntf_ready(peekQueue_EnqIntf_ready),
    .EnqIntf_valid(peekQueue_EnqIntf_valid),
    .EnqIntf_bits(peekQueue_EnqIntf_bits),
    .DeqIntf_ready(peekQueue_DeqIntf_ready),
    .DeqIntf_valid(peekQueue_DeqIntf_valid),
    .DeqIntf_bits(peekQueue_DeqIntf_bits)
  );
  assign RdCmdIntf_ready = reader_CmdIntf_ready; // @[DataMover.scala 81:25]
  assign RdStatIntf_valid = reader_StatIntf_valid; // @[DataMover.scala 82:25]
  assign RdStatIntf_bits = reader_StatIntf_bits; // @[DataMover.scala 82:25]
  assign WrCmdIntf_ready = writer_CmdIntf_ready; // @[DataMover.scala 90:25]
  assign WrStatIntf_valid = writer_StatIntf_valid; // @[DataMover.scala 91:25]
  assign WrStatIntf_bits = writer_StatIntf_bits; // @[DataMover.scala 91:25]
  assign M_AXI_AWADDR = writer_WriteIntf_AW_bits_ADDR; // @[DataMover.scala 92:25]
  assign M_AXI_AWLEN = writer_WriteIntf_AW_bits_LEN; // @[DataMover.scala 92:25]
  assign M_AXI_AWSIZE = writer_WriteIntf_AW_bits_SIZE; // @[DataMover.scala 92:25]
  assign M_AXI_AWBURST = writer_WriteIntf_AW_bits_BURST; // @[DataMover.scala 92:25]
  assign M_AXI_AWCACHE = writer_WriteIntf_AW_bits_CACHE; // @[DataMover.scala 92:25]
  assign M_AXI_AWPROT = writer_WriteIntf_AW_bits_PROT; // @[DataMover.scala 92:25]
  assign M_AXI_AWVALID = writer_WriteIntf_AW_valid; // @[DataMover.scala 92:25]
  assign M_AXI_WDATA = writer_WriteIntf_W_bits_DATA; // @[DataMover.scala 92:25]
  assign M_AXI_WSTRB = writer_WriteIntf_W_bits_STRB; // @[DataMover.scala 92:25]
  assign M_AXI_WLAST = writer_WriteIntf_W_bits_LAST; // @[DataMover.scala 92:25]
  assign M_AXI_WVALID = writer_WriteIntf_W_valid; // @[DataMover.scala 92:25]
  assign M_AXI_BREADY = writer_WriteIntf_B_ready; // @[DataMover.scala 92:25]
  assign M_AXI_ARADDR = reader_ReadIntf_AR_bits_ADDR; // @[DataMover.scala 83:25]
  assign M_AXI_ARLEN = reader_ReadIntf_AR_bits_LEN; // @[DataMover.scala 83:25]
  assign M_AXI_ARSIZE = reader_ReadIntf_AR_bits_SIZE; // @[DataMover.scala 83:25]
  assign M_AXI_ARBURST = reader_ReadIntf_AR_bits_BURST; // @[DataMover.scala 83:25]
  assign M_AXI_ARCACHE = reader_ReadIntf_AR_bits_CACHE; // @[DataMover.scala 83:25]
  assign M_AXI_ARPROT = reader_ReadIntf_AR_bits_PROT; // @[DataMover.scala 83:25]
  assign M_AXI_ARVALID = reader_ReadIntf_AR_valid; // @[DataMover.scala 83:25]
  assign M_AXI_RREADY = reader_ReadIntf_R_ready; // @[DataMover.scala 83:25]
  assign reader_ACLK = ACLK; // @[DataMover.scala 79:25]
  assign reader_ARESETn = ARESETn; // @[DataMover.scala 80:25]
  assign reader_CmdIntf_valid = RdCmdIntf_valid; // @[DataMover.scala 81:25]
  assign reader_CmdIntf_bits_NumBytes = RdCmdIntf_bits_NumBytes; // @[DataMover.scala 81:25]
  assign reader_CmdIntf_bits_Address = RdCmdIntf_bits_Address; // @[DataMover.scala 81:25]
  assign reader_StatIntf_ready = RdStatIntf_ready; // @[DataMover.scala 82:25]
  assign reader_DataIntf_ready = peekQueue_EnqIntf_ready; // @[DataMover.scala 99:25]
  assign reader_ReadIntf_AR_ready = M_AXI_ARREADY; // @[DataMover.scala 83:25]
  assign reader_ReadIntf_R_valid = M_AXI_RVALID; // @[DataMover.scala 83:25]
  assign reader_ReadIntf_R_bits_DATA = M_AXI_RDATA; // @[DataMover.scala 83:25]
  assign reader_ReadIntf_R_bits_RESP = M_AXI_RRESP; // @[DataMover.scala 83:25]
  assign reader_ReadIntf_R_bits_LAST = M_AXI_RLAST; // @[DataMover.scala 83:25]
  assign writer_ACLK = ACLK; // @[DataMover.scala 88:25]
  assign writer_ARESETn = ARESETn; // @[DataMover.scala 89:25]
  assign writer_CmdIntf_valid = WrCmdIntf_valid; // @[DataMover.scala 90:25]
  assign writer_CmdIntf_bits_NumBytes = WrCmdIntf_bits_NumBytes; // @[DataMover.scala 90:25]
  assign writer_CmdIntf_bits_Address = WrCmdIntf_bits_Address; // @[DataMover.scala 90:25]
  assign writer_StatIntf_ready = WrStatIntf_ready; // @[DataMover.scala 91:25]
  assign writer_DataIntf_valid = peekQueue_DeqIntf_valid; // @[DataMover.scala 100:25]
  assign writer_DataIntf_bits = peekQueue_DeqIntf_bits; // @[DataMover.scala 100:25]
  assign writer_WriteIntf_AW_ready = M_AXI_AWREADY; // @[DataMover.scala 92:25]
  assign writer_WriteIntf_W_ready = M_AXI_WREADY; // @[DataMover.scala 92:25]
  assign writer_WriteIntf_B_valid = M_AXI_BVALID; // @[DataMover.scala 92:25]
  assign writer_WriteIntf_B_bits_RESP = M_AXI_BRESP; // @[DataMover.scala 92:25]
  assign peekQueue_ACLK = ACLK; // @[DataMover.scala 97:25]
  assign peekQueue_ARESETn = ARESETn; // @[DataMover.scala 98:25]
  assign peekQueue_EnqIntf_valid = reader_DataIntf_valid; // @[DataMover.scala 99:25]
  assign peekQueue_EnqIntf_bits = reader_DataIntf_bits; // @[DataMover.scala 99:25]
  assign peekQueue_DeqIntf_ready = writer_DataIntf_ready; // @[DataMover.scala 100:25]
endmodule
module DMA(
  input         ACLK,
  input         ARESETn,
  output        Irq,
  output [1:0]  M_AXI_AWID,
  output [31:0] M_AXI_AWADDR,
  output [7:0]  M_AXI_AWLEN,
  output [2:0]  M_AXI_AWSIZE,
  output [1:0]  M_AXI_AWBURST,
  output        M_AXI_AWLOCK,
  output [3:0]  M_AXI_AWCACHE,
  output [2:0]  M_AXI_AWPROT,
  output        M_AXI_AWVALID,
  input         M_AXI_AWREADY,
  output [63:0] M_AXI_WDATA,
  output [7:0]  M_AXI_WSTRB,
  output        M_AXI_WLAST,
  output        M_AXI_WVALID,
  input         M_AXI_WREADY,
  input  [1:0]  M_AXI_BID,
  input  [1:0]  M_AXI_BRESP,
  input         M_AXI_BVALID,
  output        M_AXI_BREADY,
  output [1:0]  M_AXI_ARID,
  output [31:0] M_AXI_ARADDR,
  output [7:0]  M_AXI_ARLEN,
  output [2:0]  M_AXI_ARSIZE,
  output [1:0]  M_AXI_ARBURST,
  output        M_AXI_ARLOCK,
  output [3:0]  M_AXI_ARCACHE,
  output [2:0]  M_AXI_ARPROT,
  output        M_AXI_ARVALID,
  input         M_AXI_ARREADY,
  input  [1:0]  M_AXI_RID,
  input  [63:0] M_AXI_RDATA,
  input  [1:0]  M_AXI_RRESP,
  input         M_AXI_RLAST,
  input         M_AXI_RVALID,
  output        M_AXI_RREADY,
  input  [31:0] RegIntf_PADDR,
  input         RegIntf_PSEL,
  input         RegIntf_PENABLE,
  input         RegIntf_PWRITE,
  input  [31:0] RegIntf_PWDATA,
  output        RegIntf_PREADY,
  output [31:0] RegIntf_PRDATA,
  output        RegIntf_PSLVERR
);
  wire  controller_ACLK; // @[DMA.scala 62:29]
  wire  controller_ARESETn; // @[DMA.scala 62:29]
  wire  controller_Irq; // @[DMA.scala 62:29]
  wire  controller_RdCmdIntf_ready; // @[DMA.scala 62:29]
  wire  controller_RdCmdIntf_valid; // @[DMA.scala 62:29]
  wire [11:0] controller_RdCmdIntf_bits_NumBytes; // @[DMA.scala 62:29]
  wire [31:0] controller_RdCmdIntf_bits_Address; // @[DMA.scala 62:29]
  wire  controller_RdStatIntf_ready; // @[DMA.scala 62:29]
  wire  controller_RdStatIntf_valid; // @[DMA.scala 62:29]
  wire [1:0] controller_RdStatIntf_bits; // @[DMA.scala 62:29]
  wire  controller_WrCmdIntf_ready; // @[DMA.scala 62:29]
  wire  controller_WrCmdIntf_valid; // @[DMA.scala 62:29]
  wire [11:0] controller_WrCmdIntf_bits_NumBytes; // @[DMA.scala 62:29]
  wire [31:0] controller_WrCmdIntf_bits_Address; // @[DMA.scala 62:29]
  wire  controller_WrStatIntf_ready; // @[DMA.scala 62:29]
  wire  controller_WrStatIntf_valid; // @[DMA.scala 62:29]
  wire [1:0] controller_WrStatIntf_bits; // @[DMA.scala 62:29]
  wire [31:0] controller_reg_file_RegIntf_RegIntf_PADDR; // @[DMA.scala 62:29]
  wire  controller_reg_file_RegIntf_RegIntf_PSEL; // @[DMA.scala 62:29]
  wire  controller_reg_file_RegIntf_RegIntf_PENABLE; // @[DMA.scala 62:29]
  wire  controller_reg_file_RegIntf_RegIntf_PWRITE; // @[DMA.scala 62:29]
  wire [31:0] controller_reg_file_RegIntf_RegIntf_PWDATA; // @[DMA.scala 62:29]
  wire  controller_reg_file_RegIntf_RegIntf_PREADY; // @[DMA.scala 62:29]
  wire [31:0] controller_reg_file_RegIntf_RegIntf_PRDATA; // @[DMA.scala 62:29]
  wire  controller_reg_file_RegIntf_RegIntf_PSLVERR; // @[DMA.scala 62:29]
  wire  data_mover_ACLK; // @[DMA.scala 75:29]
  wire  data_mover_ARESETn; // @[DMA.scala 75:29]
  wire  data_mover_RdCmdIntf_ready; // @[DMA.scala 75:29]
  wire  data_mover_RdCmdIntf_valid; // @[DMA.scala 75:29]
  wire [11:0] data_mover_RdCmdIntf_bits_NumBytes; // @[DMA.scala 75:29]
  wire [31:0] data_mover_RdCmdIntf_bits_Address; // @[DMA.scala 75:29]
  wire  data_mover_RdStatIntf_ready; // @[DMA.scala 75:29]
  wire  data_mover_RdStatIntf_valid; // @[DMA.scala 75:29]
  wire [1:0] data_mover_RdStatIntf_bits; // @[DMA.scala 75:29]
  wire  data_mover_WrCmdIntf_ready; // @[DMA.scala 75:29]
  wire  data_mover_WrCmdIntf_valid; // @[DMA.scala 75:29]
  wire [11:0] data_mover_WrCmdIntf_bits_NumBytes; // @[DMA.scala 75:29]
  wire [31:0] data_mover_WrCmdIntf_bits_Address; // @[DMA.scala 75:29]
  wire  data_mover_WrStatIntf_ready; // @[DMA.scala 75:29]
  wire  data_mover_WrStatIntf_valid; // @[DMA.scala 75:29]
  wire [1:0] data_mover_WrStatIntf_bits; // @[DMA.scala 75:29]
  wire [31:0] data_mover_M_AXI_AWADDR; // @[DMA.scala 75:29]
  wire [7:0] data_mover_M_AXI_AWLEN; // @[DMA.scala 75:29]
  wire [2:0] data_mover_M_AXI_AWSIZE; // @[DMA.scala 75:29]
  wire [1:0] data_mover_M_AXI_AWBURST; // @[DMA.scala 75:29]
  wire [3:0] data_mover_M_AXI_AWCACHE; // @[DMA.scala 75:29]
  wire [2:0] data_mover_M_AXI_AWPROT; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_AWVALID; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_AWREADY; // @[DMA.scala 75:29]
  wire [63:0] data_mover_M_AXI_WDATA; // @[DMA.scala 75:29]
  wire [7:0] data_mover_M_AXI_WSTRB; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_WLAST; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_WVALID; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_WREADY; // @[DMA.scala 75:29]
  wire [1:0] data_mover_M_AXI_BRESP; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_BVALID; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_BREADY; // @[DMA.scala 75:29]
  wire [31:0] data_mover_M_AXI_ARADDR; // @[DMA.scala 75:29]
  wire [7:0] data_mover_M_AXI_ARLEN; // @[DMA.scala 75:29]
  wire [2:0] data_mover_M_AXI_ARSIZE; // @[DMA.scala 75:29]
  wire [1:0] data_mover_M_AXI_ARBURST; // @[DMA.scala 75:29]
  wire [3:0] data_mover_M_AXI_ARCACHE; // @[DMA.scala 75:29]
  wire [2:0] data_mover_M_AXI_ARPROT; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_ARVALID; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_ARREADY; // @[DMA.scala 75:29]
  wire [63:0] data_mover_M_AXI_RDATA; // @[DMA.scala 75:29]
  wire [1:0] data_mover_M_AXI_RRESP; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_RLAST; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_RVALID; // @[DMA.scala 75:29]
  wire  data_mover_M_AXI_RREADY; // @[DMA.scala 75:29]
  Controller controller ( // @[DMA.scala 62:29]
    .ACLK(controller_ACLK),
    .ARESETn(controller_ARESETn),
    .Irq(controller_Irq),
    .RdCmdIntf_ready(controller_RdCmdIntf_ready),
    .RdCmdIntf_valid(controller_RdCmdIntf_valid),
    .RdCmdIntf_bits_NumBytes(controller_RdCmdIntf_bits_NumBytes),
    .RdCmdIntf_bits_Address(controller_RdCmdIntf_bits_Address),
    .RdStatIntf_ready(controller_RdStatIntf_ready),
    .RdStatIntf_valid(controller_RdStatIntf_valid),
    .RdStatIntf_bits(controller_RdStatIntf_bits),
    .WrCmdIntf_ready(controller_WrCmdIntf_ready),
    .WrCmdIntf_valid(controller_WrCmdIntf_valid),
    .WrCmdIntf_bits_NumBytes(controller_WrCmdIntf_bits_NumBytes),
    .WrCmdIntf_bits_Address(controller_WrCmdIntf_bits_Address),
    .WrStatIntf_ready(controller_WrStatIntf_ready),
    .WrStatIntf_valid(controller_WrStatIntf_valid),
    .WrStatIntf_bits(controller_WrStatIntf_bits),
    .reg_file_RegIntf_RegIntf_PADDR(controller_reg_file_RegIntf_RegIntf_PADDR),
    .reg_file_RegIntf_RegIntf_PSEL(controller_reg_file_RegIntf_RegIntf_PSEL),
    .reg_file_RegIntf_RegIntf_PENABLE(controller_reg_file_RegIntf_RegIntf_PENABLE),
    .reg_file_RegIntf_RegIntf_PWRITE(controller_reg_file_RegIntf_RegIntf_PWRITE),
    .reg_file_RegIntf_RegIntf_PWDATA(controller_reg_file_RegIntf_RegIntf_PWDATA),
    .reg_file_RegIntf_RegIntf_PREADY(controller_reg_file_RegIntf_RegIntf_PREADY),
    .reg_file_RegIntf_RegIntf_PRDATA(controller_reg_file_RegIntf_RegIntf_PRDATA),
    .reg_file_RegIntf_RegIntf_PSLVERR(controller_reg_file_RegIntf_RegIntf_PSLVERR)
  );
  DataMover data_mover ( // @[DMA.scala 75:29]
    .ACLK(data_mover_ACLK),
    .ARESETn(data_mover_ARESETn),
    .RdCmdIntf_ready(data_mover_RdCmdIntf_ready),
    .RdCmdIntf_valid(data_mover_RdCmdIntf_valid),
    .RdCmdIntf_bits_NumBytes(data_mover_RdCmdIntf_bits_NumBytes),
    .RdCmdIntf_bits_Address(data_mover_RdCmdIntf_bits_Address),
    .RdStatIntf_ready(data_mover_RdStatIntf_ready),
    .RdStatIntf_valid(data_mover_RdStatIntf_valid),
    .RdStatIntf_bits(data_mover_RdStatIntf_bits),
    .WrCmdIntf_ready(data_mover_WrCmdIntf_ready),
    .WrCmdIntf_valid(data_mover_WrCmdIntf_valid),
    .WrCmdIntf_bits_NumBytes(data_mover_WrCmdIntf_bits_NumBytes),
    .WrCmdIntf_bits_Address(data_mover_WrCmdIntf_bits_Address),
    .WrStatIntf_ready(data_mover_WrStatIntf_ready),
    .WrStatIntf_valid(data_mover_WrStatIntf_valid),
    .WrStatIntf_bits(data_mover_WrStatIntf_bits),
    .M_AXI_AWADDR(data_mover_M_AXI_AWADDR),
    .M_AXI_AWLEN(data_mover_M_AXI_AWLEN),
    .M_AXI_AWSIZE(data_mover_M_AXI_AWSIZE),
    .M_AXI_AWBURST(data_mover_M_AXI_AWBURST),
    .M_AXI_AWCACHE(data_mover_M_AXI_AWCACHE),
    .M_AXI_AWPROT(data_mover_M_AXI_AWPROT),
    .M_AXI_AWVALID(data_mover_M_AXI_AWVALID),
    .M_AXI_AWREADY(data_mover_M_AXI_AWREADY),
    .M_AXI_WDATA(data_mover_M_AXI_WDATA),
    .M_AXI_WSTRB(data_mover_M_AXI_WSTRB),
    .M_AXI_WLAST(data_mover_M_AXI_WLAST),
    .M_AXI_WVALID(data_mover_M_AXI_WVALID),
    .M_AXI_WREADY(data_mover_M_AXI_WREADY),
    .M_AXI_BRESP(data_mover_M_AXI_BRESP),
    .M_AXI_BVALID(data_mover_M_AXI_BVALID),
    .M_AXI_BREADY(data_mover_M_AXI_BREADY),
    .M_AXI_ARADDR(data_mover_M_AXI_ARADDR),
    .M_AXI_ARLEN(data_mover_M_AXI_ARLEN),
    .M_AXI_ARSIZE(data_mover_M_AXI_ARSIZE),
    .M_AXI_ARBURST(data_mover_M_AXI_ARBURST),
    .M_AXI_ARCACHE(data_mover_M_AXI_ARCACHE),
    .M_AXI_ARPROT(data_mover_M_AXI_ARPROT),
    .M_AXI_ARVALID(data_mover_M_AXI_ARVALID),
    .M_AXI_ARREADY(data_mover_M_AXI_ARREADY),
    .M_AXI_RDATA(data_mover_M_AXI_RDATA),
    .M_AXI_RRESP(data_mover_M_AXI_RRESP),
    .M_AXI_RLAST(data_mover_M_AXI_RLAST),
    .M_AXI_RVALID(data_mover_M_AXI_RVALID),
    .M_AXI_RREADY(data_mover_M_AXI_RREADY)
  );
  assign Irq = controller_Irq; // @[DMA.scala 92:29]
  assign M_AXI_AWID = 2'h0; // @[DMA.scala 96:29]
  assign M_AXI_AWADDR = data_mover_M_AXI_AWADDR; // @[DMA.scala 96:29]
  assign M_AXI_AWLEN = data_mover_M_AXI_AWLEN; // @[DMA.scala 96:29]
  assign M_AXI_AWSIZE = data_mover_M_AXI_AWSIZE; // @[DMA.scala 96:29]
  assign M_AXI_AWBURST = data_mover_M_AXI_AWBURST; // @[DMA.scala 96:29]
  assign M_AXI_AWLOCK = 1'h0; // @[DMA.scala 96:29]
  assign M_AXI_AWCACHE = data_mover_M_AXI_AWCACHE; // @[DMA.scala 96:29]
  assign M_AXI_AWPROT = data_mover_M_AXI_AWPROT; // @[DMA.scala 96:29]
  assign M_AXI_AWVALID = data_mover_M_AXI_AWVALID; // @[DMA.scala 96:29]
  assign M_AXI_WDATA = data_mover_M_AXI_WDATA; // @[DMA.scala 96:29]
  assign M_AXI_WSTRB = data_mover_M_AXI_WSTRB; // @[DMA.scala 96:29]
  assign M_AXI_WLAST = data_mover_M_AXI_WLAST; // @[DMA.scala 96:29]
  assign M_AXI_WVALID = data_mover_M_AXI_WVALID; // @[DMA.scala 96:29]
  assign M_AXI_BREADY = data_mover_M_AXI_BREADY; // @[DMA.scala 96:29]
  assign M_AXI_ARID = 2'h0; // @[DMA.scala 96:29]
  assign M_AXI_ARADDR = data_mover_M_AXI_ARADDR; // @[DMA.scala 96:29]
  assign M_AXI_ARLEN = data_mover_M_AXI_ARLEN; // @[DMA.scala 96:29]
  assign M_AXI_ARSIZE = data_mover_M_AXI_ARSIZE; // @[DMA.scala 96:29]
  assign M_AXI_ARBURST = data_mover_M_AXI_ARBURST; // @[DMA.scala 96:29]
  assign M_AXI_ARLOCK = 1'h0; // @[DMA.scala 96:29]
  assign M_AXI_ARCACHE = data_mover_M_AXI_ARCACHE; // @[DMA.scala 96:29]
  assign M_AXI_ARPROT = data_mover_M_AXI_ARPROT; // @[DMA.scala 96:29]
  assign M_AXI_ARVALID = data_mover_M_AXI_ARVALID; // @[DMA.scala 96:29]
  assign M_AXI_RREADY = data_mover_M_AXI_RREADY; // @[DMA.scala 96:29]
  assign RegIntf_PREADY = controller_reg_file_RegIntf_RegIntf_PREADY; // @[DMA.scala 91:29]
  assign RegIntf_PRDATA = controller_reg_file_RegIntf_RegIntf_PRDATA; // @[DMA.scala 91:29]
  assign RegIntf_PSLVERR = controller_reg_file_RegIntf_RegIntf_PSLVERR; // @[DMA.scala 91:29]
  assign controller_ACLK = ACLK; // @[DMA.scala 89:29]
  assign controller_ARESETn = ARESETn; // @[DMA.scala 90:29]
  assign controller_RdCmdIntf_ready = data_mover_RdCmdIntf_ready; // @[DMA.scala 98:29]
  assign controller_RdStatIntf_valid = data_mover_RdStatIntf_valid; // @[DMA.scala 99:29]
  assign controller_RdStatIntf_bits = data_mover_RdStatIntf_bits; // @[DMA.scala 99:29]
  assign controller_WrCmdIntf_ready = data_mover_WrCmdIntf_ready; // @[DMA.scala 101:29]
  assign controller_WrStatIntf_valid = data_mover_WrStatIntf_valid; // @[DMA.scala 102:29]
  assign controller_WrStatIntf_bits = data_mover_WrStatIntf_bits; // @[DMA.scala 102:29]
  assign controller_reg_file_RegIntf_RegIntf_PADDR = RegIntf_PADDR; // @[DMA.scala 91:29]
  assign controller_reg_file_RegIntf_RegIntf_PSEL = RegIntf_PSEL; // @[DMA.scala 91:29]
  assign controller_reg_file_RegIntf_RegIntf_PENABLE = RegIntf_PENABLE; // @[DMA.scala 91:29]
  assign controller_reg_file_RegIntf_RegIntf_PWRITE = RegIntf_PWRITE; // @[DMA.scala 91:29]
  assign controller_reg_file_RegIntf_RegIntf_PWDATA = RegIntf_PWDATA; // @[DMA.scala 91:29]
  assign data_mover_ACLK = ACLK; // @[DMA.scala 94:29]
  assign data_mover_ARESETn = ARESETn; // @[DMA.scala 95:29]
  assign data_mover_RdCmdIntf_valid = controller_RdCmdIntf_valid; // @[DMA.scala 98:29]
  assign data_mover_RdCmdIntf_bits_NumBytes = controller_RdCmdIntf_bits_NumBytes; // @[DMA.scala 98:29]
  assign data_mover_RdCmdIntf_bits_Address = controller_RdCmdIntf_bits_Address; // @[DMA.scala 98:29]
  assign data_mover_RdStatIntf_ready = controller_RdStatIntf_ready; // @[DMA.scala 99:29]
  assign data_mover_WrCmdIntf_valid = controller_WrCmdIntf_valid; // @[DMA.scala 101:29]
  assign data_mover_WrCmdIntf_bits_NumBytes = controller_WrCmdIntf_bits_NumBytes; // @[DMA.scala 101:29]
  assign data_mover_WrCmdIntf_bits_Address = controller_WrCmdIntf_bits_Address; // @[DMA.scala 101:29]
  assign data_mover_WrStatIntf_ready = controller_WrStatIntf_ready; // @[DMA.scala 102:29]
  assign data_mover_M_AXI_AWREADY = M_AXI_AWREADY; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_WREADY = M_AXI_WREADY; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_BRESP = M_AXI_BRESP; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_BVALID = M_AXI_BVALID; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_ARREADY = M_AXI_ARREADY; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_RDATA = M_AXI_RDATA; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_RRESP = M_AXI_RRESP; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_RLAST = M_AXI_RLAST; // @[DMA.scala 96:29]
  assign data_mover_M_AXI_RVALID = M_AXI_RVALID; // @[DMA.scala 96:29]
endmodule
