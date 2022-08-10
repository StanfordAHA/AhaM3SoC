module SramAddrGen(
  input  [31:0] CurAddr,
  input  [7:0]  Len,
  input  [2:0]  Size,
  input  [1:0]  Burst,
  output [31:0] NextAddr
);
  wire [11:0] iCurAddr = CurAddr[11:0]; // @[SramAddrGen.scala 27:30]
  wire [1:0] _iSize_T_3 = 3'h2 == Size ? 2'h2 : {{1'd0}, 3'h1 == Size}; // @[Mux.scala 81:58]
  wire [1:0] _iSize_T_5 = 3'h3 == Size ? 2'h3 : _iSize_T_3; // @[Mux.scala 81:58]
  wire [2:0] _iSize_T_7 = 3'h4 == Size ? 3'h4 : {{1'd0}, _iSize_T_5}; // @[Mux.scala 81:58]
  wire [2:0] _iSize_T_9 = 3'h5 == Size ? 3'h5 : _iSize_T_7; // @[Mux.scala 81:58]
  wire [2:0] _iSize_T_11 = 3'h6 == Size ? 3'h6 : _iSize_T_9; // @[Mux.scala 81:58]
  wire [2:0] iSize = 3'h7 == Size ? 3'h7 : _iSize_T_11; // @[Mux.scala 81:58]
  wire [11:0] wordAddress = iCurAddr >> iSize; // @[SramAddrGen.scala 34:32]
  wire [11:0] _incrNextAddr_T_1 = wordAddress + 12'h1; // @[SramAddrGen.scala 37:37]
  wire [18:0] _GEN_1 = {{7'd0}, _incrNextAddr_T_1}; // @[SramAddrGen.scala 37:44]
  wire [18:0] incrNextAddr = _GEN_1 << iSize; // @[SramAddrGen.scala 37:44]
  wire [3:0] _wrapBound_T_3 = ~Len[3:0]; // @[SramAddrGen.scala 40:68]
  wire [3:0] _wrapBound_T_4 = wordAddress[3:0] & _wrapBound_T_3; // @[SramAddrGen.scala 40:66]
  wire [11:0] _wrapBound_T_5 = {wordAddress[11:4],_wrapBound_T_4}; // @[Cat.scala 31:58]
  wire [18:0] _GEN_2 = {{7'd0}, _wrapBound_T_5}; // @[SramAddrGen.scala 40:80]
  wire [18:0] wrapBound = _GEN_2 << iSize; // @[SramAddrGen.scala 40:80]
  wire [4:0] _totSize_T_1 = Len[3:0] + 4'h1; // @[SramAddrGen.scala 41:33]
  wire [11:0] _GEN_3 = {{7'd0}, _totSize_T_1}; // @[SramAddrGen.scala 41:41]
  wire [11:0] totSize = _GEN_3 << iSize; // @[SramAddrGen.scala 41:41]
  wire [18:0] _GEN_0 = {{7'd0}, totSize}; // @[SramAddrGen.scala 42:55]
  wire [18:0] _wrapNextAddr_T_1 = wrapBound + _GEN_0; // @[SramAddrGen.scala 42:55]
  wire [18:0] wrapNextAddr = incrNextAddr == _wrapNextAddr_T_1 ? wrapBound : incrNextAddr; // @[SramAddrGen.scala 42:27]
  wire [31:0] _iNextAddr_T_3 = 2'h1 == Burst ? {{13'd0}, incrNextAddr} : CurAddr; // @[Mux.scala 81:58]
  wire [31:0] _iNextAddr_T_5 = 2'h2 == Burst ? {{13'd0}, wrapNextAddr} : _iNextAddr_T_3; // @[Mux.scala 81:58]
  wire [11:0] iNextAddr = _iNextAddr_T_5[11:0]; // @[SramAddrGen.scala 28:27 44:15]
  assign NextAddr = {CurAddr[31:12],iNextAddr}; // @[Cat.scala 31:58]
endmodule
module WriteEngine(
  input         ACLK,
  input         ARESETn,
  output        S_AXI_AW_ready,
  input         S_AXI_AW_valid,
  input  [3:0]  S_AXI_AW_bits_ID,
  input  [31:0] S_AXI_AW_bits_ADDR,
  input  [7:0]  S_AXI_AW_bits_LEN,
  input  [2:0]  S_AXI_AW_bits_SIZE,
  input  [1:0]  S_AXI_AW_bits_BURST,
  output        S_AXI_W_ready,
  input         S_AXI_W_valid,
  input  [63:0] S_AXI_W_bits_DATA,
  input  [7:0]  S_AXI_W_bits_STRB,
  input         S_AXI_W_bits_LAST,
  input         S_AXI_B_ready,
  output        S_AXI_B_valid,
  output [3:0]  S_AXI_B_bits_ID,
  input         Ready,
  output        Valid,
  output [31:0] Addr,
  output [63:0] Data,
  output [7:0]  Strb
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire [31:0] NextAddr_m_CurAddr; // @[SramAddrGen.scala 51:23]
  wire [7:0] NextAddr_m_Len; // @[SramAddrGen.scala 51:23]
  wire [2:0] NextAddr_m_Size; // @[SramAddrGen.scala 51:23]
  wire [1:0] NextAddr_m_Burst; // @[SramAddrGen.scala 51:23]
  wire [31:0] NextAddr_m_NextAddr; // @[SramAddrGen.scala 51:23]
  wire  reset = ~ARESETn; // @[WriteEngine.scala 38:33]
  reg [31:0] iAddr; // @[WriteEngine.scala 46:34]
  reg  iAddrValid; // @[WriteEngine.scala 48:34]
  reg [7:0] iLen; // @[WriteEngine.scala 51:34]
  reg [2:0] iSize; // @[WriteEngine.scala 52:34]
  reg [1:0] iBurst; // @[WriteEngine.scala 53:34]
  reg [3:0] iBID; // @[WriteEngine.scala 54:34]
  reg  iBValid; // @[WriteEngine.scala 55:34]
  wire  iAwReady = ~iAddrValid; // @[WriteEngine.scala 77:28]
  wire  _iAddrValidNext_T = iAwReady & S_AXI_AW_valid; // @[WriteEngine.scala 64:46]
  wire  _iAddrValidNext_T_1 = iBValid & S_AXI_B_ready; // @[WriteEngine.scala 66:49]
  wire  _iAddrValidNext_T_2 = iBValid & S_AXI_B_ready ? 1'h0 : iAddrValid; // @[WriteEngine.scala 66:40]
  wire  iValid = iAddrValid & S_AXI_W_valid; // @[WriteEngine.scala 157:31]
  wire  _iBValidNext_T_3 = _iAddrValidNext_T_1 ? 1'h0 : iBValid; // @[WriteEngine.scala 113:36]
  wire [31:0] NextAddr = NextAddr_m_NextAddr; // @[WriteEngine.scala 164:25 47:31]
  SramAddrGen NextAddr_m ( // @[SramAddrGen.scala 51:23]
    .CurAddr(NextAddr_m_CurAddr),
    .Len(NextAddr_m_Len),
    .Size(NextAddr_m_Size),
    .Burst(NextAddr_m_Burst),
    .NextAddr(NextAddr_m_NextAddr)
  );
  assign S_AXI_AW_ready = ~iAddrValid; // @[WriteEngine.scala 77:28]
  assign S_AXI_W_ready = iAddrValid & Ready; // @[WriteEngine.scala 84:39]
  assign S_AXI_B_valid = iBValid; // @[WriteEngine.scala 120:25]
  assign S_AXI_B_bits_ID = iBID; // @[WriteEngine.scala 99:29]
  assign Valid = iAddrValid & S_AXI_W_valid; // @[WriteEngine.scala 157:31]
  assign Addr = iAddr; // @[WriteEngine.scala 173:17]
  assign Data = S_AXI_W_bits_DATA; // @[WriteEngine.scala 185:17]
  assign Strb = S_AXI_W_bits_STRB; // @[WriteEngine.scala 179:17]
  assign NextAddr_m_CurAddr = iAddr; // @[SramAddrGen.scala 52:21]
  assign NextAddr_m_Len = iLen; // @[SramAddrGen.scala 53:21]
  assign NextAddr_m_Size = iSize; // @[SramAddrGen.scala 54:21]
  assign NextAddr_m_Burst = iBurst; // @[SramAddrGen.scala 55:21]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 165:32]
      iAddr <= 32'h0;
    end else if (_iAddrValidNext_T) begin // @[WriteEngine.scala 167:36]
      iAddr <= S_AXI_AW_bits_ADDR;
    end else if (iValid & Ready) begin
      iAddr <= NextAddr;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 64:36]
      iAddrValid <= 1'h0;
    end else begin
      iAddrValid <= iAwReady & S_AXI_AW_valid | _iAddrValidNext_T_2;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 126:28]
      iLen <= 8'h0;
    end else if (_iAddrValidNext_T) begin // @[WriteEngine.scala 128:32]
      iLen <= S_AXI_AW_bits_LEN;
    end else if (_iAddrValidNext_T_1) begin
      iLen <= 8'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 135:28]
      iSize <= 3'h0;
    end else if (_iAddrValidNext_T) begin // @[WriteEngine.scala 137:32]
      iSize <= S_AXI_AW_bits_SIZE;
    end else if (_iAddrValidNext_T_1) begin
      iSize <= 3'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 144:29]
      iBurst <= 2'h0;
    end else if (_iAddrValidNext_T) begin // @[WriteEngine.scala 146:32]
      iBurst <= S_AXI_AW_bits_BURST;
    end else if (_iAddrValidNext_T_1) begin
      iBurst <= 2'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 90:28]
      iBID <= 4'h0;
    end else if (_iAddrValidNext_T) begin // @[WriteEngine.scala 92:32]
      iBID <= S_AXI_AW_bits_ID;
    end else if (_iAddrValidNext_T_1) begin
      iBID <= 4'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[WriteEngine.scala 111:32]
      iBValid <= 1'h0;
    end else begin
      iBValid <= iValid & S_AXI_W_bits_LAST & Ready | _iBValidNext_T_3;
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
  iAddr = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  iAddrValid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  iLen = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  iSize = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  iBurst = _RAND_4[1:0];
  _RAND_5 = {1{`RANDOM}};
  iBID = _RAND_5[3:0];
  _RAND_6 = {1{`RANDOM}};
  iBValid = _RAND_6[0:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    iAddr = 32'h0;
  end
  if (reset) begin
    iAddrValid = 1'h0;
  end
  if (reset) begin
    iLen = 8'h0;
  end
  if (reset) begin
    iSize = 3'h0;
  end
  if (reset) begin
    iBurst = 2'h0;
  end
  if (reset) begin
    iBID = 4'h0;
  end
  if (reset) begin
    iBValid = 1'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ReadEngine(
  input         ACLK,
  input         ARESETn,
  output        S_AXI_AR_ready,
  input         S_AXI_AR_valid,
  input  [3:0]  S_AXI_AR_bits_ID,
  input  [31:0] S_AXI_AR_bits_ADDR,
  input  [7:0]  S_AXI_AR_bits_LEN,
  input  [2:0]  S_AXI_AR_bits_SIZE,
  input  [1:0]  S_AXI_AR_bits_BURST,
  input         S_AXI_R_ready,
  output        S_AXI_R_valid,
  output [3:0]  S_AXI_R_bits_ID,
  output [63:0] S_AXI_R_bits_DATA,
  output        S_AXI_R_bits_LAST,
  input         Ready,
  output        Valid,
  output [31:0] Addr,
  input  [63:0] Data
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
  wire [31:0] NextAddr_m_CurAddr; // @[SramAddrGen.scala 51:23]
  wire [7:0] NextAddr_m_Len; // @[SramAddrGen.scala 51:23]
  wire [2:0] NextAddr_m_Size; // @[SramAddrGen.scala 51:23]
  wire [1:0] NextAddr_m_Burst; // @[SramAddrGen.scala 51:23]
  wire [31:0] NextAddr_m_NextAddr; // @[SramAddrGen.scala 51:23]
  wire  reset = ~ARESETn; // @[ReadEngine.scala 37:33]
  reg [31:0] iAddr; // @[ReadEngine.scala 45:34]
  reg  iAddrValid; // @[ReadEngine.scala 46:34]
  reg [7:0] iLen; // @[ReadEngine.scala 50:34]
  reg [2:0] iSize; // @[ReadEngine.scala 51:34]
  reg [1:0] iBurst; // @[ReadEngine.scala 52:34]
  reg [3:0] iRID; // @[ReadEngine.scala 53:34]
  reg  iRLast; // @[ReadEngine.scala 54:34]
  reg  iRValid; // @[ReadEngine.scala 55:34]
  reg  iValid; // @[ReadEngine.scala 57:34]
  reg [7:0] iCounter; // @[ReadEngine.scala 59:34]
  wire  iARReady = ~iAddrValid; // @[ReadEngine.scala 79:32]
  wire  _iAddrValidNext_T = iARReady & S_AXI_AR_valid; // @[ReadEngine.scala 65:46]
  wire  _iAddrValidNext_T_2 = iRValid & iRLast & S_AXI_R_ready; // @[ReadEngine.scala 67:58]
  wire  _iAddrValidNext_T_3 = iRValid & iRLast & S_AXI_R_ready ? 1'h0 : iAddrValid; // @[ReadEngine.scala 67:40]
  wire  _iRValidNext_T = iValid & Ready; // @[ReadEngine.scala 101:40]
  wire  _iRValidNext_T_3 = iRValid & S_AXI_R_ready; // @[ReadEngine.scala 105:49]
  wire  _iRValidNext_T_4 = iRValid & S_AXI_R_ready ? 1'h0 : iRValid; // @[ReadEngine.scala 105:40]
  wire  _iRValidNext_T_5 = iRValid & ~S_AXI_R_ready | _iRValidNext_T_4; // @[ReadEngine.scala 103:36]
  wire  iLast = iCounter == 8'h0; // @[ReadEngine.scala 214:33]
  wire  _iRLastNext_T_3 = _iRValidNext_T_3 ? 1'h0 : iRLast; // @[ReadEngine.scala 133:36]
  wire  _iValidNext_T_2 = iLast & Ready ? 1'h0 : iValid; // @[ReadEngine.scala 178:36]
  wire [31:0] NextAddr = NextAddr_m_NextAddr; // @[ReadEngine.scala 190:21 47:31]
  wire [7:0] _iCounterNext_T_3 = iCounter - 8'h1; // @[ReadEngine.scala 209:46]
  SramAddrGen NextAddr_m ( // @[SramAddrGen.scala 51:23]
    .CurAddr(NextAddr_m_CurAddr),
    .Len(NextAddr_m_Len),
    .Size(NextAddr_m_Size),
    .Burst(NextAddr_m_Burst),
    .NextAddr(NextAddr_m_NextAddr)
  );
  assign S_AXI_AR_ready = ~iAddrValid; // @[ReadEngine.scala 79:32]
  assign S_AXI_R_valid = iRValid; // @[ReadEngine.scala 113:25]
  assign S_AXI_R_bits_ID = iRID; // @[ReadEngine.scala 95:29]
  assign S_AXI_R_bits_DATA = Data; // @[ReadEngine.scala 119:29]
  assign S_AXI_R_bits_LAST = iRLast; // @[ReadEngine.scala 139:29]
  assign Valid = iValid; // @[ReadEngine.scala 184:17]
  assign Addr = iAddr; // @[ReadEngine.scala 200:17]
  assign NextAddr_m_CurAddr = iAddr; // @[SramAddrGen.scala 52:21]
  assign NextAddr_m_Len = iLen; // @[SramAddrGen.scala 53:21]
  assign NextAddr_m_Size = iSize; // @[SramAddrGen.scala 54:21]
  assign NextAddr_m_Burst = iBurst; // @[SramAddrGen.scala 55:21]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 192:28]
      iAddr <= 32'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 194:32]
      iAddr <= S_AXI_AR_bits_ADDR;
    end else if (Ready) begin
      iAddr <= NextAddr;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 65:36]
      iAddrValid <= 1'h0;
    end else begin
      iAddrValid <= iARReady & S_AXI_AR_valid | _iAddrValidNext_T_3;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 145:28]
      iLen <= 8'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 147:32]
      iLen <= S_AXI_AR_bits_LEN;
    end else if (_iAddrValidNext_T_2) begin
      iLen <= 8'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 154:29]
      iSize <= 3'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 156:32]
      iSize <= S_AXI_AR_bits_SIZE;
    end else if (_iAddrValidNext_T_2) begin
      iSize <= 3'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 163:30]
      iBurst <= 2'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 165:32]
      iBurst <= S_AXI_AR_bits_BURST;
    end else if (_iAddrValidNext_T_2) begin
      iBurst <= 2'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 86:28]
      iRID <= 4'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 88:32]
      iRID <= S_AXI_AR_bits_ID;
    end else if (_iAddrValidNext_T_2) begin
      iRID <= 4'h0;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 131:32]
      iRLast <= 1'h0;
    end else begin
      iRLast <= iValid & iLast & Ready | _iRLastNext_T_3;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 101:32]
      iRValid <= 1'h0;
    end else begin
      iRValid <= iValid & Ready | _iRValidNext_T_5;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 176:32]
      iValid <= 1'h0;
    end else begin
      iValid <= _iAddrValidNext_T | _iValidNext_T_2;
    end
  end
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[ReadEngine.scala 206:32]
      iCounter <= 8'h0;
    end else if (_iAddrValidNext_T) begin // @[ReadEngine.scala 208:36]
      iCounter <= S_AXI_AR_bits_LEN;
    end else if (_iRValidNext_T) begin
      iCounter <= _iCounterNext_T_3;
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
  iAddr = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  iAddrValid = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  iLen = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  iSize = _RAND_3[2:0];
  _RAND_4 = {1{`RANDOM}};
  iBurst = _RAND_4[1:0];
  _RAND_5 = {1{`RANDOM}};
  iRID = _RAND_5[3:0];
  _RAND_6 = {1{`RANDOM}};
  iRLast = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  iRValid = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  iValid = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  iCounter = _RAND_9[7:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    iAddr = 32'h0;
  end
  if (reset) begin
    iAddrValid = 1'h0;
  end
  if (reset) begin
    iLen = 8'h0;
  end
  if (reset) begin
    iSize = 3'h0;
  end
  if (reset) begin
    iBurst = 2'h0;
  end
  if (reset) begin
    iRID = 4'h0;
  end
  if (reset) begin
    iRLast = 1'h0;
  end
  if (reset) begin
    iRValid = 1'h0;
  end
  if (reset) begin
    iValid = 1'h0;
  end
  if (reset) begin
    iCounter = 8'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module SramArbiter(
  input   ACLK,
  input   ARESETn,
  input   WrValid,
  output  WrReady,
  input   RdValid,
  output  RdReady
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  wire  reset = ~ARESETn; // @[SramArbiter.scala 26:34]
  reg  choice; // @[SramArbiter.scala 35:34]
  wire [1:0] _T = {WrValid,RdValid}; // @[Cat.scala 31:58]
  wire  _choiceNext_T = ~choice; // @[SramArbiter.scala 60:32]
  wire  _GEN_1 = 2'h2 == _T | _choiceNext_T; // @[SramArbiter.scala 49:40 57:29]
  assign WrReady = choice; // @[SramArbiter.scala 67:21]
  assign RdReady = ~choice; // @[SramArbiter.scala 68:24]
  always @(posedge ACLK or posedge reset) begin
    if (reset) begin // @[SramArbiter.scala 49:40]
      choice <= 1'h0; // @[SramArbiter.scala 51:29]
    end else if (!(2'h0 == _T)) begin // @[SramArbiter.scala 49:40]
      if (2'h1 == _T) begin
        choice <= 1'h0;
      end else begin
        choice <= _GEN_1;
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
  choice = _RAND_0[0:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    choice = 1'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AXItoSRAM(
  input         ACLK,
  input         ARESETn,
  input  [3:0]  S_AXI_AWID,
  input  [31:0] S_AXI_AWADDR,
  input  [7:0]  S_AXI_AWLEN,
  input  [2:0]  S_AXI_AWSIZE,
  input  [1:0]  S_AXI_AWBURST,
  input         S_AXI_AWLOCK,
  input  [3:0]  S_AXI_AWCACHE,
  input  [2:0]  S_AXI_AWPROT,
  input         S_AXI_AWVALID,
  output        S_AXI_AWREADY,
  input  [63:0] S_AXI_WDATA,
  input  [7:0]  S_AXI_WSTRB,
  input         S_AXI_WLAST,
  input         S_AXI_WVALID,
  output        S_AXI_WREADY,
  output [3:0]  S_AXI_BID,
  output [1:0]  S_AXI_BRESP,
  output        S_AXI_BVALID,
  input         S_AXI_BREADY,
  input  [3:0]  S_AXI_ARID,
  input  [31:0] S_AXI_ARADDR,
  input  [7:0]  S_AXI_ARLEN,
  input  [2:0]  S_AXI_ARSIZE,
  input  [1:0]  S_AXI_ARBURST,
  input         S_AXI_ARLOCK,
  input  [3:0]  S_AXI_ARCACHE,
  input  [2:0]  S_AXI_ARPROT,
  input         S_AXI_ARVALID,
  output        S_AXI_ARREADY,
  output [3:0]  S_AXI_RID,
  output [63:0] S_AXI_RDATA,
  output [1:0]  S_AXI_RRESP,
  output        S_AXI_RLAST,
  output        S_AXI_RVALID,
  input         S_AXI_RREADY,
  output        SRAM_CEn,
  output [31:0] SRAM_ADDR,
  output [63:0] SRAM_WDATA,
  output        SRAM_WEn,
  output [7:0]  SRAM_WBEn,
  input  [63:0] SRAM_RDATA
);
  wire  wrIE_ACLK; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_ARESETn; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_AW_ready; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_AW_valid; // @[AXItoSRAM.scala 48:29]
  wire [3:0] wrIE_S_AXI_AW_bits_ID; // @[AXItoSRAM.scala 48:29]
  wire [31:0] wrIE_S_AXI_AW_bits_ADDR; // @[AXItoSRAM.scala 48:29]
  wire [7:0] wrIE_S_AXI_AW_bits_LEN; // @[AXItoSRAM.scala 48:29]
  wire [2:0] wrIE_S_AXI_AW_bits_SIZE; // @[AXItoSRAM.scala 48:29]
  wire [1:0] wrIE_S_AXI_AW_bits_BURST; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_W_ready; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_W_valid; // @[AXItoSRAM.scala 48:29]
  wire [63:0] wrIE_S_AXI_W_bits_DATA; // @[AXItoSRAM.scala 48:29]
  wire [7:0] wrIE_S_AXI_W_bits_STRB; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_W_bits_LAST; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_B_ready; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_S_AXI_B_valid; // @[AXItoSRAM.scala 48:29]
  wire [3:0] wrIE_S_AXI_B_bits_ID; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_Ready; // @[AXItoSRAM.scala 48:29]
  wire  wrIE_Valid; // @[AXItoSRAM.scala 48:29]
  wire [31:0] wrIE_Addr; // @[AXItoSRAM.scala 48:29]
  wire [63:0] wrIE_Data; // @[AXItoSRAM.scala 48:29]
  wire [7:0] wrIE_Strb; // @[AXItoSRAM.scala 48:29]
  wire  rdIE_ACLK; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_ARESETn; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_S_AXI_AR_ready; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_S_AXI_AR_valid; // @[AXItoSRAM.scala 49:29]
  wire [3:0] rdIE_S_AXI_AR_bits_ID; // @[AXItoSRAM.scala 49:29]
  wire [31:0] rdIE_S_AXI_AR_bits_ADDR; // @[AXItoSRAM.scala 49:29]
  wire [7:0] rdIE_S_AXI_AR_bits_LEN; // @[AXItoSRAM.scala 49:29]
  wire [2:0] rdIE_S_AXI_AR_bits_SIZE; // @[AXItoSRAM.scala 49:29]
  wire [1:0] rdIE_S_AXI_AR_bits_BURST; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_S_AXI_R_ready; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_S_AXI_R_valid; // @[AXItoSRAM.scala 49:29]
  wire [3:0] rdIE_S_AXI_R_bits_ID; // @[AXItoSRAM.scala 49:29]
  wire [63:0] rdIE_S_AXI_R_bits_DATA; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_S_AXI_R_bits_LAST; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_Ready; // @[AXItoSRAM.scala 49:29]
  wire  rdIE_Valid; // @[AXItoSRAM.scala 49:29]
  wire [31:0] rdIE_Addr; // @[AXItoSRAM.scala 49:29]
  wire [63:0] rdIE_Data; // @[AXItoSRAM.scala 49:29]
  wire  arbiter_ACLK; // @[AXItoSRAM.scala 50:29]
  wire  arbiter_ARESETn; // @[AXItoSRAM.scala 50:29]
  wire  arbiter_WrValid; // @[AXItoSRAM.scala 50:29]
  wire  arbiter_WrReady; // @[AXItoSRAM.scala 50:29]
  wire  arbiter_RdValid; // @[AXItoSRAM.scala 50:29]
  wire  arbiter_RdReady; // @[AXItoSRAM.scala 50:29]
  wire  _SRAM_CEn_T = wrIE_Ready & wrIE_Valid; // @[AXItoSRAM.scala 69:42]
  WriteEngine wrIE ( // @[AXItoSRAM.scala 48:29]
    .ACLK(wrIE_ACLK),
    .ARESETn(wrIE_ARESETn),
    .S_AXI_AW_ready(wrIE_S_AXI_AW_ready),
    .S_AXI_AW_valid(wrIE_S_AXI_AW_valid),
    .S_AXI_AW_bits_ID(wrIE_S_AXI_AW_bits_ID),
    .S_AXI_AW_bits_ADDR(wrIE_S_AXI_AW_bits_ADDR),
    .S_AXI_AW_bits_LEN(wrIE_S_AXI_AW_bits_LEN),
    .S_AXI_AW_bits_SIZE(wrIE_S_AXI_AW_bits_SIZE),
    .S_AXI_AW_bits_BURST(wrIE_S_AXI_AW_bits_BURST),
    .S_AXI_W_ready(wrIE_S_AXI_W_ready),
    .S_AXI_W_valid(wrIE_S_AXI_W_valid),
    .S_AXI_W_bits_DATA(wrIE_S_AXI_W_bits_DATA),
    .S_AXI_W_bits_STRB(wrIE_S_AXI_W_bits_STRB),
    .S_AXI_W_bits_LAST(wrIE_S_AXI_W_bits_LAST),
    .S_AXI_B_ready(wrIE_S_AXI_B_ready),
    .S_AXI_B_valid(wrIE_S_AXI_B_valid),
    .S_AXI_B_bits_ID(wrIE_S_AXI_B_bits_ID),
    .Ready(wrIE_Ready),
    .Valid(wrIE_Valid),
    .Addr(wrIE_Addr),
    .Data(wrIE_Data),
    .Strb(wrIE_Strb)
  );
  ReadEngine rdIE ( // @[AXItoSRAM.scala 49:29]
    .ACLK(rdIE_ACLK),
    .ARESETn(rdIE_ARESETn),
    .S_AXI_AR_ready(rdIE_S_AXI_AR_ready),
    .S_AXI_AR_valid(rdIE_S_AXI_AR_valid),
    .S_AXI_AR_bits_ID(rdIE_S_AXI_AR_bits_ID),
    .S_AXI_AR_bits_ADDR(rdIE_S_AXI_AR_bits_ADDR),
    .S_AXI_AR_bits_LEN(rdIE_S_AXI_AR_bits_LEN),
    .S_AXI_AR_bits_SIZE(rdIE_S_AXI_AR_bits_SIZE),
    .S_AXI_AR_bits_BURST(rdIE_S_AXI_AR_bits_BURST),
    .S_AXI_R_ready(rdIE_S_AXI_R_ready),
    .S_AXI_R_valid(rdIE_S_AXI_R_valid),
    .S_AXI_R_bits_ID(rdIE_S_AXI_R_bits_ID),
    .S_AXI_R_bits_DATA(rdIE_S_AXI_R_bits_DATA),
    .S_AXI_R_bits_LAST(rdIE_S_AXI_R_bits_LAST),
    .Ready(rdIE_Ready),
    .Valid(rdIE_Valid),
    .Addr(rdIE_Addr),
    .Data(rdIE_Data)
  );
  SramArbiter arbiter ( // @[AXItoSRAM.scala 50:29]
    .ACLK(arbiter_ACLK),
    .ARESETn(arbiter_ARESETn),
    .WrValid(arbiter_WrValid),
    .WrReady(arbiter_WrReady),
    .RdValid(arbiter_RdValid),
    .RdReady(arbiter_RdReady)
  );
  assign S_AXI_AWREADY = wrIE_S_AXI_AW_ready; // @[AXItoSRAM.scala 54:25]
  assign S_AXI_WREADY = wrIE_S_AXI_W_ready; // @[AXItoSRAM.scala 54:25]
  assign S_AXI_BID = wrIE_S_AXI_B_bits_ID; // @[AXItoSRAM.scala 54:25]
  assign S_AXI_BRESP = 2'h0; // @[AXItoSRAM.scala 54:25]
  assign S_AXI_BVALID = wrIE_S_AXI_B_valid; // @[AXItoSRAM.scala 54:25]
  assign S_AXI_ARREADY = rdIE_S_AXI_AR_ready; // @[AXItoSRAM.scala 59:25]
  assign S_AXI_RID = rdIE_S_AXI_R_bits_ID; // @[AXItoSRAM.scala 59:25]
  assign S_AXI_RDATA = rdIE_S_AXI_R_bits_DATA; // @[AXItoSRAM.scala 59:25]
  assign S_AXI_RRESP = 2'h0; // @[AXItoSRAM.scala 59:25]
  assign S_AXI_RLAST = rdIE_S_AXI_R_bits_LAST; // @[AXItoSRAM.scala 59:25]
  assign S_AXI_RVALID = rdIE_S_AXI_R_valid; // @[AXItoSRAM.scala 59:25]
  assign SRAM_CEn = ~(wrIE_Ready & wrIE_Valid | rdIE_Ready & rdIE_Valid); // @[AXItoSRAM.scala 69:28]
  assign SRAM_ADDR = wrIE_Ready ? wrIE_Addr : rdIE_Addr; // @[AXItoSRAM.scala 68:31]
  assign SRAM_WDATA = wrIE_Data; // @[AXItoSRAM.scala 70:25]
  assign SRAM_WEn = ~_SRAM_CEn_T; // @[AXItoSRAM.scala 71:28]
  assign SRAM_WBEn = ~wrIE_Strb; // @[AXItoSRAM.scala 72:28]
  assign wrIE_ACLK = ACLK; // @[AXItoSRAM.scala 52:25]
  assign wrIE_ARESETn = ARESETn; // @[AXItoSRAM.scala 53:25]
  assign wrIE_S_AXI_AW_valid = S_AXI_AWVALID; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_AW_bits_ID = S_AXI_AWID; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_AW_bits_ADDR = S_AXI_AWADDR; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_AW_bits_LEN = S_AXI_AWLEN; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_AW_bits_SIZE = S_AXI_AWSIZE; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_AW_bits_BURST = S_AXI_AWBURST; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_W_valid = S_AXI_WVALID; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_W_bits_DATA = S_AXI_WDATA; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_W_bits_STRB = S_AXI_WSTRB; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_W_bits_LAST = S_AXI_WLAST; // @[AXItoSRAM.scala 54:25]
  assign wrIE_S_AXI_B_ready = S_AXI_BREADY; // @[AXItoSRAM.scala 54:25]
  assign wrIE_Ready = arbiter_WrReady; // @[AXItoSRAM.scala 55:25]
  assign rdIE_ACLK = ACLK; // @[AXItoSRAM.scala 57:25]
  assign rdIE_ARESETn = ARESETn; // @[AXItoSRAM.scala 58:25]
  assign rdIE_S_AXI_AR_valid = S_AXI_ARVALID; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_AR_bits_ID = S_AXI_ARID; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_AR_bits_ADDR = S_AXI_ARADDR; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_AR_bits_LEN = S_AXI_ARLEN; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_AR_bits_SIZE = S_AXI_ARSIZE; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_AR_bits_BURST = S_AXI_ARBURST; // @[AXItoSRAM.scala 59:25]
  assign rdIE_S_AXI_R_ready = S_AXI_RREADY; // @[AXItoSRAM.scala 59:25]
  assign rdIE_Ready = arbiter_RdReady; // @[AXItoSRAM.scala 60:25]
  assign rdIE_Data = SRAM_RDATA; // @[AXItoSRAM.scala 61:25]
  assign arbiter_ACLK = ACLK; // @[AXItoSRAM.scala 63:25]
  assign arbiter_ARESETn = ARESETn; // @[AXItoSRAM.scala 64:25]
  assign arbiter_WrValid = wrIE_Valid; // @[AXItoSRAM.scala 65:25]
  assign arbiter_RdValid = rdIE_Valid; // @[AXItoSRAM.scala 66:25]
endmodule
