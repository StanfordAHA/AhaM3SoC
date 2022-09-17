module TlxMonitor (
    //
    // Forward Streams
    //

    input   wire            FWD_CLK,

    input   wire            FWD_PAYLOAD_TVALID,
    input   wire [39:0]     FWD_PAYLOAD_TDATA,

    input   wire            FWD_FLOW_TVALID,
    input   wire [1:0]      FWD_FLOW_TDATA,

    //
    // Reverse Streams
    //

    input   wire            REV_CLK,

    input   wire            REV_PAYLOAD_TVALID,
    input   wire [79:0]     REV_PAYLOAD_TDATA,

    input   wire            REV_FLOW_TVALID,
    input   wire [2:0]      REV_FLOW_TDATA,

    //
    // AXI Interface
    //

    input   wire [3:0]      AWID,
    input   wire [31:0]     AWADDR,
    input   wire [7:0]      AWLEN,
    input   wire [2:0]      AWSIZE,
    input   wire [1:0]      AWBURST,
    input   wire            AWLOCK,
    input   wire [3:0]      AWCACHE,
    input   wire [2:0]      AWPROT,
    input   wire            AWVALID,
    input   wire            AWREADY,

    input   wire [63:0]     WDATA,
    input   wire [7:0]      WSTRB,
    input   wire            WLAST,
    input   wire            WVALID,
    input   wire            WREADY,

    input   wire [3:0]      BID,
    input   wire [1:0]      BRESP,
    input   wire            BVALID,
    input   wire            BREADY,

    input   wire [3:0]      ARID,
    input   wire [31:0]     ARADDR,
    input   wire [7:0]      ARLEN,
    input   wire [2:0]      ARSIZE,
    input   wire [1:0]      ARBURST,
    input   wire            ARLOCK,
    input   wire [3:0]      ARCACHE,
    input   wire [2:0]      ARPROT,
    input   wire            ARVALID,
    input   wire            ARREADY,

    input   wire [3:0]      RID,
    input   wire [63:0]     RDATA,
    input   wire [1:0]      RRESP,
    input   wire            RLAST,
    input   wire            RVALID,
    input   wire            RREADY
);

    //
    // Forward Flow Monitor
    //

    always @(posedge FWD_CLK)
        if (FWD_FLOW_TVALID)
            $display("FWD Flow [DATA = 0x%H]", FWD_FLOW_TDATA);

    //
    // Forward Data Monitor
    //

    always @(posedge FWD_CLK)
        if (FWD_PAYLOAD_TVALID)
            $display("FWD Payload [DATA = 0x%H]", FWD_PAYLOAD_TDATA);

    //
    // Reverse Flow Monitor
    //

    always @(posedge REV_CLK)
        if (REV_FLOW_TVALID)
            $display("REV Flow [DATA = 0x%H]", REV_FLOW_TDATA);

    //
    // Reverse Payload Monitor
    //

    always @(posedge REV_CLK)
        if (REV_PAYLOAD_TVALID)
            $display("REV Payload [DATA = 0x%H]", REV_PAYLOAD_TDATA);

    //
    // WriteAddress Monitor
    //

    always @(posedge FWD_CLK)
        if (AWVALID & AWREADY)
            $display("WriteAddress Issued [ADDR = 0x%H]", AWADDR);

    //
    // WriteData Monitor
    //

    always @(posedge FWD_CLK)
        if (WVALID & WREADY)
            $display("WriteData Issued [DATA = 0x%H]", WDATA);

    //
    // WriteResponse Monitor
    //

    always @(posedge FWD_CLK)
        if (BVALID & BREADY)
            $display("WriteResponse Issued [RESP = 0x%H]", BRESP);

    //
    // ReadAddress Monitor
    //

    always @(posedge FWD_CLK)
        if (ARVALID & ARREADY)
            $display("ReadAddress Issued [ADDR = 0x%H]", ARADDR);

    //
    // ReadData Monitor
    //

    always @(posedge FWD_CLK)
        if (RVALID & RREADY)
            $display("ReadData Issued [DATA = 0x%H, Last = %B]", RDDATA, RLAST);

endmodule
