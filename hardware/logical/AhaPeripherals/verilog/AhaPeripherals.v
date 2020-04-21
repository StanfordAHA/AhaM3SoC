//-----------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// Purpose: Peripherals Integration
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : Apr 16, 2020
//------------------------------------------------------------------------------
module AhaPeripherals (
  // Bus Interface
  input   wire            HCLK,
  input   wire            HRESETn,

  input   wire            HSEL,
  input   wire [31:0]     HADDR,
  input   wire  [1:0]     HTRANS,
  input   wire            HWRITE,
  input   wire  [2:0]     HSIZE,
  input   wire  [2:0]     HBURST,
  input   wire  [3:0]     HPROT,
  input   wire [31:0]     HWDATA,
  input   wire            HREADYMUX,

  output  wire [31:0]     HRDATA,
  output  wire            HREADYOUT,
  output  wire  [1:0]     HRESP,

  // TIMER 0
  input   wire            TIMER0_PCLK,
  input   wire            TIMER0_PCLKEN,
  input   wire            TIMER0_PRESETn,
  output  wire            TIMER0_INT,

  // TIMER 1
  input   wire            TIMER1_PCLK,
  input   wire            TIMER1_PCLKEN,
  input   wire            TIMER1_PRESETn,
  output  wire            TIMER1_INT,

  // UART 0
  input   wire            UART0_PCLK,
  input   wire            UART0_PCLKEN,
  input   wire            UART0_PRESETn,
  input   wire            UART0_RXD,
  output  wire            UART0_TXD,
  output  wire            UART0_TXINT,
  output  wire            UART0_RXINT,
  output  wire            UART0_TXOVRINT,
  output  wire            UART0_RXOVRINT,
  output  wire            UART0_UARTINT,

  // UART 1
  input   wire            UART1_PCLK,
  input   wire            UART1_PCLKEN,
  input   wire            UART1_PRESETn,
  input   wire            UART1_RXD,
  output  wire            UART1_TXD,
  output  wire            UART1_TXINT,
  output  wire            UART1_RXINT,
  output  wire            UART1_TXOVRINT,
  output  wire            UART1_RXOVRINT,
  output  wire            UART1_UARTINT,

  // Watchdog
  input   wire            WDOG_PCLK,
  input   wire            WDOG_PCLKEN,
  input   wire            WDOG_PRESETn,
  output  wire            WDOG_INT,
  output  wire            WDOG_RESET,

  // DMA 0
  input   wire            DMA0_PCLKEN,

  output  wire [11:0]     DMA0_PADDR,
  output  wire            DMA0_PENABLE,
  output  wire            DMA0_PWRITE,
  output  wire            DMA0_PSEL,
  output  wire [31:0]     DMA0_PWDATA,

  input   wire [31:0]     DMA0_PRDATA,
  input   wire            DMA0_PREADY,
  input   wire            DMA0_PSLVERR,

  // DMA 1
  input   wire            DMA1_PCLKEN,

  output  wire [11:0]     DMA1_PADDR,
  output  wire            DMA1_PENABLE,
  output  wire            DMA1_PWRITE,
  output  wire            DMA1_PSEL,
  output  wire [31:0]     DMA1_PWDATA,

  input   wire [31:0]     DMA1_PRDATA,
  input   wire            DMA1_PREADY,
  input   wire            DMA1_PSLVERR
);

  // TIMER 0 Wires
  wire            timer0_hsel;
  wire [31:0]     timer0_haddr;
  wire  [1:0]     timer0_htrans;
  wire            timer0_hwrite;
  wire  [2:0]     timer0_hsize;
  wire  [2:0]     timer0_hburst;
  wire  [3:0]     timer0_hprot;
  wire [31:0]     timer0_hwdata;
  wire            timer0_hreadymux;

  wire [31:0]     timer0_hrdata;
  wire            timer0_hreadyout;
  wire  [1:0]     timer0_hresp;

  // TIMER 1 Wires
  wire            timer1_hsel;
  wire [31:0]     timer1_haddr;
  wire  [1:0]     timer1_htrans;
  wire            timer1_hwrite;
  wire  [2:0]     timer1_hsize;
  wire  [2:0]     timer1_hburst;
  wire  [3:0]     timer1_hprot;
  wire [31:0]     timer1_hwdata;
  wire            timer1_hreadymux;

  wire [31:0]     timer1_hrdata;
  wire            timer1_hreadyout;
  wire  [1:0]     timer1_hresp;

  // UART 0 Wires
  wire            uart0_hsel;
  wire [31:0]     uart0_haddr;
  wire  [1:0]     uart0_htrans;
  wire            uart0_hwrite;
  wire  [2:0]     uart0_hsize;
  wire  [2:0]     uart0_hburst;
  wire  [3:0]     uart0_hprot;
  wire [31:0]     uart0_hwdata;
  wire            uart0_hreadymux;

  wire [31:0]     uart0_hrdata;
  wire            uart0_hreadyout;
  wire  [1:0]     uart0_hresp;

  // UART 1 Wires
  wire            uart1_hsel;
  wire [31:0]     uart1_haddr;
  wire  [1:0]     uart1_htrans;
  wire            uart1_hwrite;
  wire  [2:0]     uart1_hsize;
  wire  [2:0]     uart1_hburst;
  wire  [3:0]     uart1_hprot;
  wire [31:0]     uart1_hwdata;
  wire            uart1_hreadymux;

  wire [31:0]     uart1_hrdata;
  wire            uart1_hreadyout;
  wire  [1:0]     uart1_hresp;

  // WDOG Wires
  wire            wdog_hsel;
  wire [31:0]     wdog_haddr;
  wire  [1:0]     wdog_htrans;
  wire            wdog_hwrite;
  wire  [2:0]     wdog_hsize;
  wire  [2:0]     wdog_hburst;
  wire  [3:0]     wdog_hprot;
  wire [31:0]     wdog_hwdata;
  wire            wdog_hreadymux;

  wire [31:0]     wdog_hrdata;
  wire            wdog_hreadyout;
  wire  [1:0]     wdog_hresp;

  // DMA 0 Wires
  wire            dma0_hsel;
  wire [31:0]     dma0_haddr;
  wire  [1:0]     dma0_htrans;
  wire            dma0_hwrite;
  wire  [2:0]     dma0_hsize;
  wire  [2:0]     dma0_hburst;
  wire  [3:0]     dma0_hprot;
  wire [31:0]     dma0_hwdata;
  wire            dma0_hreadymux;

  wire [31:0]     dma0_hrdata;
  wire            dma0_hreadyout;
  wire  [1:0]     dma0_hresp;

  // DMA 1 Wires
  wire            dma1_hsel;
  wire [31:0]     dma1_haddr;
  wire  [1:0]     dma1_htrans;
  wire            dma1_hwrite;
  wire  [2:0]     dma1_hsize;
  wire  [2:0]     dma1_hburst;
  wire  [3:0]     dma1_hprot;
  wire [31:0]     dma1_hwdata;
  wire            dma1_hreadymux;

  wire [31:0]     dma1_hrdata;
  wire            dma1_hreadyout;
  wire  [1:0]     dma1_hresp;


  // Peripheral Interconnect
  AhaPeriphAhbMtx u_periph_ahb_mtx (
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .REMAP                (4'h0),

    // System Port
    .HSELSYSTEM           (HSEL),
    .HADDRSYSTEM          (HADDR),
    .HTRANSSYSTEM         (HTRANS),
    .HWRITESYSTEM         (HWRITE),
    .HSIZESYSTEM          (HSIZE),
    .HBURSTSYSTEM         (HBURST),
    .HPROTSYSTEM          (HPROT),
    .HMASTERSYSTEM        (4'h0),
    .HWDATASYSTEM         (HWDATA),
    .HMASTLOCKSYSTEM      (1'b0),
    .HREADYSYSTEM         (HREADYMUX),

    .HRDATASYSTEM         (HRDATA),
    .HREADYOUTSYSTEM      (HREADYOUT),
    .HRESPSYSTEM          (HRESP),

    // TIMER0 Port
    .HSELTIMER0           (timer0_hsel),
    .HADDRTIMER0          (timer0_haddr),
    .HTRANSTIMER0         (timer0_htrans),
    .HWRITETIMER0         (timer0_hwrite),
    .HSIZETIMER0          (timer0_hsize),
    .HBURSTTIMER0         (timer0_hburst),
    .HPROTTIMER0          (timer0_hprot),
    .HMASTERTIMER0        (/*unused*/),
    .HWDATATIMER0         (timer0_hwdata),
    .HMASTLOCKTIMER0      (/*unused*/),
    .HREADYMUXTIMER0      (timer0_hreadymux),

    .HRDATATIMER0         (timer0_hrdata),
    .HREADYOUTTIMER0      (timer0_hreadyout),
    .HRESPTIMER0          (timer0_hresp),

    // TIMER1 Port
    .HSELTIMER1           (timer1_hsel),
    .HADDRTIMER1          (timer1_haddr),
    .HTRANSTIMER1         (timer1_htrans),
    .HWRITETIMER1         (timer1_hwrite),
    .HSIZETIMER1          (timer1_hsize),
    .HBURSTTIMER1         (timer1_hburst),
    .HPROTTIMER1          (timer1_hprot),
    .HMASTERTIMER1        (/*unused*/),
    .HWDATATIMER1         (timer1_hwdata),
    .HMASTLOCKTIMER1      (/*unused*/),
    .HREADYMUXTIMER1      (timer1_hreadymux),

    .HRDATATIMER1         (timer1_hrdata),
    .HREADYOUTTIMER1      (timer1_hreadyout),
    .HRESPTIMER1          (timer1_hresp),

    // UART0 Port
    .HSELUART0            (uart0_hsel),
    .HADDRUART0           (uart0_haddr),
    .HTRANSUART0          (uart0_htrans),
    .HWRITEUART0          (uart0_hwrite),
    .HSIZEUART0           (uart0_hsize),
    .HBURSTUART0          (uart0_hburst),
    .HPROTUART0           (uart0_hprot),
    .HMASTERUART0         (/*unused*/),
    .HWDATAUART0          (uart0_hwdata),
    .HMASTLOCKUART0       (/*unused*/),
    .HREADYMUXUART0       (uart0_hreadymux),

    .HRDATAUART0          (uart0_hrdata),
    .HREADYOUTUART0       (uart0_hreadyout),
    .HRESPUART0           (uart0_hresp),

    // UART1 Port
    .HSELUART1            (uart1_hsel),
    .HADDRUART1           (uart1_haddr),
    .HTRANSUART1          (uart1_htrans),
    .HWRITEUART1          (uart1_hwrite),
    .HSIZEUART1           (uart1_hsize),
    .HBURSTUART1          (uart1_hburst),
    .HPROTUART1           (uart1_hprot),
    .HMASTERUART1         (/*unused*/),
    .HWDATAUART1          (uart1_hwdata),
    .HMASTLOCKUART1       (/*unused*/),
    .HREADYMUXUART1       (uart1_hreadymux),

    .HRDATAUART1          (uart1_hrdata),
    .HREADYOUTUART1       (uart1_hreadyout),
    .HRESPUART1           (uart1_hresp),

    // WDOG Port
    .HSELWDOG             (wdog_hsel),
    .HADDRWDOG            (wdog_haddr),
    .HTRANSWDOG           (wdog_htrans),
    .HWRITEWDOG           (wdog_hwrite),
    .HSIZEWDOG            (wdog_hsize),
    .HBURSTWDOG           (wdog_hburst),
    .HPROTWDOG            (wdog_hprot),
    .HMASTERWDOG          (/*unused*/),
    .HWDATAWDOG           (wdog_hwdata),
    .HMASTLOCKWDOG        (/*unused*/),
    .HREADYMUXWDOG        (wdog_hreadymux),

    .HRDATAWDOG           (wdog_hrdata),
    .HREADYOUTWDOG        (wdog_hreadyout),
    .HRESPWDOG            (wdog_hresp),

    // DMA0 Port
    .HSELDMA0             (dma0_hsel),
    .HADDRDMA0            (dma0_haddr),
    .HTRANSDMA0           (dma0_htrans),
    .HWRITEDMA0           (dma0_hwrite),
    .HSIZEDMA0            (dma0_hsize),
    .HBURSTDMA0           (dma0_hburst),
    .HPROTDMA0            (dma0_hprot),
    .HMASTERDMA0          (/*unused*/),
    .HWDATADMA0           (dma0_hwdata),
    .HMASTLOCKDMA0        (/*unused*/),
    .HREADYMUXDMA0        (dma0_hreadymux),

    .HRDATADMA0           (dma0_hrdata),
    .HREADYOUTDMA0        (dma0_hreadyout),
    .HRESPDMA0            (dma0_hresp),

    // DMA1 Port
    .HSELDMA1             (dma1_hsel),
    .HADDRDMA1            (dma1_haddr),
    .HTRANSDMA1           (dma1_htrans),
    .HWRITEDMA1           (dma1_hwrite),
    .HSIZEDMA1            (dma1_hsize),
    .HBURSTDMA1           (dma1_hburst),
    .HPROTDMA1            (dma1_hprot),
    .HMASTERDMA1          (/*unused*/),
    .HWDATADMA1           (dma1_hwdata),
    .HMASTLOCKDMA1        (/*unused*/),
    .HREADYMUXDMA1        (dma1_hreadymux),

    .HRDATADMA1           (dma1_hrdata),
    .HREADYOUTDMA1        (dma1_hreadyout),
    .HRESPDMA1            (dma1_hresp),

    // Test
    .SCANENABLE           (1'b0),
    .SCANINHCLK           (1'b0),

    .SCANOUTHCLK          (/*unused*/)
  );

  // TIMER 0 Instance
  AhaTimerIntegration u_timer_0 (
    // System Bus Interface
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .HSEL                 (timer0_hsel),
    .HADDR                (timer0_haddr),
    .HTRANS               (timer0_htrans),
    .HWRITE               (timer0_hwrite),
    .HSIZE                (timer0_hsize),
    .HBURST               (timer0_hburst),
    .HPROT                (timer0_hprot),
    .HWDATA               (timer0_hwdata),
    .HREADYMUX            (timer0_hreadymux),

    .HRDATA               (timer0_hrdata),
    .HREADYOUT            (timer0_hreadyout),
    .HRESP                (timer0_hresp),

    // Peripheral Interface
    .PCLK                 (TIMER0_PCLK),
    .PCLKEN               (TIMER0_PCLKEN),
    .PRESETn              (TIMER0_PRESETn),

    // Interrupts
    .TIMERINT             (TIMER0_INT)
  );

  // TIMER 1 Instance
  AhaTimerIntegration u_timer_1 (
    // System Bus Interface
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .HSEL                 (timer1_hsel),
    .HADDR                (timer1_haddr),
    .HTRANS               (timer1_htrans),
    .HWRITE               (timer1_hwrite),
    .HSIZE                (timer1_hsize),
    .HBURST               (timer1_hburst),
    .HPROT                (timer1_hprot),
    .HWDATA               (timer1_hwdata),
    .HREADYMUX            (timer1_hreadymux),

    .HRDATA               (timer1_hrdata),
    .HREADYOUT            (timer1_hreadyout),
    .HRESP                (timer1_hresp),

    // Peripheral Interface
    .PCLK                 (TIMER1_PCLK),
    .PCLKEN               (TIMER1_PCLKEN),
    .PRESETn              (TIMER1_PRESETn),

    // Interrupts
    .TIMERINT             (TIMER1_INT)
  );

  // UART 0 Instance
  AhaUartIntegration u_uart_0 (
    // System Bus Interface
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .HSEL                 (uart0_hsel),
    .HADDR                (uart0_haddr),
    .HTRANS               (uart0_htrans),
    .HWRITE               (uart0_hwrite),
    .HSIZE                (uart0_hsize),
    .HBURST               (uart0_hburst),
    .HPROT                (uart0_hprot),
    .HWDATA               (uart0_hwdata),
    .HREADYMUX            (uart0_hreadymux),

    .HRDATA               (uart0_hrdata),
    .HREADYOUT            (uart0_hreadyout),
    .HRESP                (uart0_hresp),

    // Peripheral Interface
    .PCLK                 (UART0_PCLK),
    .PCLKEN               (UART0_PCLKEN),
    .PRESETn              (UART0_PRESETn),

    .RXD                  (UART0_RXD),
    .TXD                  (UART0_TXD),

    // Interrupts
    .TXINT                (UART0_TXINT),
    .RXINT                (UART0_RXINT),
    .TXOVRINT             (UART0_TXOVRINT),
    .RXOVRINT             (UART0_RXOVRINT),
    .UARTINT              (UART0_UARTINT)
  );

  // UART 1 Instance
  AhaUartIntegration u_uart_1 (
    // System Bus Interface
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .HSEL                 (uart1_hsel),
    .HADDR                (uart1_haddr),
    .HTRANS               (uart1_htrans),
    .HWRITE               (uart1_hwrite),
    .HSIZE                (uart1_hsize),
    .HBURST               (uart1_hburst),
    .HPROT                (uart1_hprot),
    .HWDATA               (uart1_hwdata),
    .HREADYMUX            (uart1_hreadymux),

    .HRDATA               (uart1_hrdata),
    .HREADYOUT            (uart1_hreadyout),
    .HRESP                (uart1_hresp),

    // Peripheral Interface
    .PCLK                 (UART1_PCLK),
    .PCLKEN               (UART1_PCLKEN),
    .PRESETn              (UART1_PRESETn),

    .RXD                  (UART1_RXD),
    .TXD                  (UART1_TXD),

    // Interrupts
    .TXINT                (UART1_TXINT),
    .RXINT                (UART1_RXINT),
    .TXOVRINT             (UART1_TXOVRINT),
    .RXOVRINT             (UART1_RXOVRINT),
    .UARTINT              (UART1_UARTINT)
  );

  // WDOG Instance
  AhaWdogIntegration u_wdog (
    // System Bus Interface
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),

    .HSEL                 (wdog_hsel),
    .HADDR                (wdog_haddr),
    .HTRANS               (wdog_htrans),
    .HWRITE               (wdog_hwrite),
    .HSIZE                (wdog_hsize),
    .HBURST               (wdog_hburst),
    .HPROT                (wdog_hprot),
    .HWDATA               (wdog_hwdata),
    .HREADYMUX            (wdog_hreadymux),

    .HRDATA               (wdog_hrdata),
    .HREADYOUT            (wdog_hreadyout),
    .HRESP                (wdog_hresp),

    // Peripheral Interface
    .PCLK                 (WDOG_PCLK),
    .PCLKEN               (WDOG_PCLKEN),
    .PRESETn              (WDOG_PRESETn),

    // Interrupts
    .WDOG_INT             (WDOG_INT),
    .WDOG_RESET           (WDOG_RESET)
  );

  // DMA0 APB Interface Instantiation
  cmsdk_ahb_to_apb #(
    .ADDRWIDTH            (12),
    .REGISTER_RDATA       (1),
    .REGISTER_WDATA       (0)
  ) u_cmsdk_ahb_apb_bridge_dma_0 (
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),
    .PCLKEN               (DMA0_PCLKEN),

    .HSEL                 (dma0_hsel),
    .HADDR                (dma0_haddr[11:0]),
    .HTRANS               (dma0_htrans),
    .HSIZE                (dma0_hsize),
    .HPROT                (dma0_hprot),
    .HWRITE               (dma0_hwrite),
    .HREADY               (dma0_hreadymux),
    .HWDATA               (dma0_hwdata),

    .HREADYOUT            (dma0_hreadyout),
    .HRDATA               (dma0_hrdata),
    .HRESP                (dma0_hresp[0]),

    .PADDR                (DMA0_PADDR),
    .PENABLE              (DMA0_PENABLE),
    .PWRITE               (DMA0_PWRITE),
    .PSTRB                (/*unused*/),
    .PPROT                (/*unused*/),
    .PWDATA               (DMA0_PWDATA),
    .PSEL                 (DMA0_PSEL),

    .APBACTIVE            (/*unused*/),

    .PRDATA               (DMA0_PRDATA),
    .PREADY               (DMA0_PREADY),
    .PSLVERR              (DMA0_PSLVERR)
  );

  assign dma0_hresp[1]  = 1'b0;

  // DMA1 APB Interface Instantiation
  cmsdk_ahb_to_apb #(
    .ADDRWIDTH            (12),
    .REGISTER_RDATA       (1),
    .REGISTER_WDATA       (0)
  ) u_cmsdk_ahb_apb_bridge_dma_1 (
    .HCLK                 (HCLK),
    .HRESETn              (HRESETn),
    .PCLKEN               (DMA1_PCLKEN),

    .HSEL                 (dma1_hsel),
    .HADDR                (dma1_haddr[11:0]),
    .HTRANS               (dma1_htrans),
    .HSIZE                (dma1_hsize),
    .HPROT                (dma1_hprot),
    .HWRITE               (dma1_hwrite),
    .HREADY               (dma1_hreadymux),
    .HWDATA               (dma1_hwdata),

    .HREADYOUT            (dma1_hreadyout),
    .HRDATA               (dma1_hrdata),
    .HRESP                (dma1_hresp[0]),

    .PADDR                (DMA1_PADDR),
    .PENABLE              (DMA1_PENABLE),
    .PWRITE               (DMA1_PWRITE),
    .PSTRB                (/*unused*/),
    .PPROT                (/*unused*/),
    .PWDATA               (DMA1_PWDATA),
    .PSEL                 (DMA1_PSEL),

    .APBACTIVE            (/*unused*/),

    .PRDATA               (DMA1_PRDATA),
    .PREADY               (DMA1_PREADY),
    .PSLVERR              (DMA1_PSLVERR)
  );

  assign dma1_hresp[1]  = 1'b0;

endmodule
