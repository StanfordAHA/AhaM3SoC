//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Power Management Unit
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : May 4, 2020
//------------------------------------------------------------------------------
module AhaPowerMgmtUnit (
  input   wire          CLK,
  input   wire          RESETn,

  // Input Control
  input   wire          DBGPWRUPREQ,
  input   wire          DBGSYSPWRUPREQ,
  input   wire          PMU_WIC_EN_ACK,
  input   wire          PMU_WAKEUP,
  input   wire          SLEEP,
  input   wire          SLEEPDEEP,
  input   wire          SLEEPHOLDACKn,

  input   wire          CPU_CLK_GATE_EN_in,
  input   wire          DAP_CLK_GATE_EN_in,
  input   wire          DMA0_CLK_GATE_EN_in,
  input   wire          DMA1_CLK_GATE_EN_in,
  input   wire          SRAM_CLK_GATE_EN_in,
  input   wire          TLX_CLK_GATE_EN_in,
  input   wire          CGRA_CLK_GATE_EN_in,
  input   wire          NIC_CLK_GATE_EN_in,
  input   wire          TIMER0_CLK_GATE_EN_in,
  input   wire          TIMER1_CLK_GATE_EN_in,
  input   wire          UART0_CLK_GATE_EN_in,
  input   wire          UART1_CLK_GATE_EN_in,
  input   wire          WDOG_CLK_GATE_EN_in,

  // Output Control
  output  wire          DBGPWRUPACK,
  output  wire          DBGSYSPWRUPACK,
  output  wire          SLEEPHOLDREQn,
  output  wire          PMU_WIC_EN_REQ,

  output  wire          CPU_CLK_GATE_EN_out,
  output  wire          DAP_CLK_GATE_EN_out,
  output  wire          DMA0_CLK_GATE_EN_out,
  output  wire          DMA1_CLK_GATE_EN_out,
  output  wire          SRAM_CLK_GATE_EN_out,
  output  wire          TLX_CLK_GATE_EN_out,
  output  wire          CGRA_CLK_GATE_EN_out,
  output  wire          NIC_CLK_GATE_EN_out,
  output  wire          TIMER0_CLK_GATE_EN_out,
  output  wire          TIMER1_CLK_GATE_EN_out,
  output  wire          UART0_CLK_GATE_EN_out,
  output  wire          UART1_CLK_GATE_EN_out,
  output  wire          WDOG_CLK_GATE_EN_out
);

//------------------------------------------------------------------------------
// Unused Features
//------------------------------------------------------------------------------
  wire unused =   SLEEPHOLDACKn |         // WIC is implemented, therefore this is not necessary
                  CPU_CLK_GATE_EN_in;     // CPU clock gate is managed in hardware (use DEEP SLEEP)

  assign SLEEPHOLDREQn = 1'b1;

//------------------------------------------------------------------------------
// Synchronize inputs from different clock domains
//------------------------------------------------------------------------------
  wire dbg_sys_pwr_req_w;
  wire dbg_pwr_req_w;

  AhaDataSync u_dbg_sys_pwr_up_req_sync (
    .CLK        (CLK),
    .RESETn     (RESETn),
    .D          (DBGSYSPWRUPREQ),
    .Q          (dbg_sys_pwr_req_w)
  );

  AhaDataSync u_dbg_pwr_up_req_sync (
    .CLK        (CLK),
    .RESETn     (RESETn),
    .D          (DBGPWRUPREQ),
    .Q          (dbg_pwr_req_w)
  );


//------------------------------------------------------------------------------
// Clock Gates
//------------------------------------------------------------------------------
  assign CPU_CLK_GATE_EN_out    =  ~(dbg_pwr_req_w | dbg_sys_pwr_req_w | ~PMU_WIC_EN_ACK | PMU_WAKEUP) &
                                    (SLEEP | SLEEPDEEP);
  assign DAP_CLK_GATE_EN_out    =  ~dbg_pwr_req_w & (DAP_CLK_GATE_EN_in | SLEEPDEEP);
  assign DMA0_CLK_GATE_EN_out   =   (DMA0_CLK_GATE_EN_in | SLEEPDEEP);
  assign DMA1_CLK_GATE_EN_out   =   (DMA1_CLK_GATE_EN_in | SLEEPDEEP);
  assign SRAM_CLK_GATE_EN_out   =  ~(dbg_pwr_req_w | dbg_sys_pwr_req_w | ~PMU_WIC_EN_ACK | PMU_WAKEUP) &
                                    (SRAM_CLK_GATE_EN_in | SLEEPDEEP);
  assign TLX_CLK_GATE_EN_out    =   (TLX_CLK_GATE_EN_in | SLEEPDEEP);
  assign CGRA_CLK_GATE_EN_out   =   (CGRA_CLK_GATE_EN_in | SLEEPDEEP);
  assign NIC_CLK_GATE_EN_out    =  ~(dbg_pwr_req_w | dbg_sys_pwr_req_w | ~PMU_WIC_EN_ACK | PMU_WAKEUP) &
                                    (NIC_CLK_GATE_EN_in | SLEEPDEEP);
  assign TIMER0_CLK_GATE_EN_out =   (TIMER0_CLK_GATE_EN_in | SLEEPDEEP);
  assign TIMER1_CLK_GATE_EN_out =   (TIMER1_CLK_GATE_EN_in | SLEEPDEEP);
  assign UART0_CLK_GATE_EN_out  =   ~(SLEEP | SLEEPDEEP) & UART0_CLK_GATE_EN_in;
  assign UART1_CLK_GATE_EN_out  =   (UART1_CLK_GATE_EN_in | SLEEPDEEP);
  assign WDOG_CLK_GATE_EN_out   =   WDOG_CLK_GATE_EN_in;

//------------------------------------------------------------------------------
// Debug Requests
//------------------------------------------------------------------------------
  // Send back the request with some delay
  wire dbg_sys_pwr_ack_w;
  wire dbg_pwr_ack_w;

  AhaDataSync u_dbg_sys_pwr_up_ack_sync (
    .CLK        (CLK),
    .RESETn     (RESETn),
    .D          (dbg_sys_pwr_req_w),
    .Q          (dbg_sys_pwr_ack_w)
  );

  AhaDataSync u_dbg_pwr_up_ack_sync (
    .CLK        (CLK),
    .RESETn     (RESETn),
    .D          (dbg_pwr_req_w),
    .Q          (dbg_pwr_ack_w)
  );

  assign DBGPWRUPACK      = dbg_pwr_ack_w;
  assign DBGSYSPWRUPACK   = dbg_sys_pwr_ack_w;

//------------------------------------------------------------------------------
// WIC ENABLE REQ
//------------------------------------------------------------------------------
  reg wic_en_r;
  always @(posedge CLK or negedge RESETn) begin
    if(~RESETn) wic_en_r  <= 1'b0;
    else wic_en_r <= 1'b1;
  end

  assign PMU_WIC_EN_REQ = wic_en_r;

endmodule
