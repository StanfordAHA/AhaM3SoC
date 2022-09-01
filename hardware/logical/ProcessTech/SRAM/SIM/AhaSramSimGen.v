//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : SRAM Simulation View Generator
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 9, 2022
//------------------------------------------------------------------------------

module AhaSramSimGen #(
    parameter ADDR_WIDTH,
    parameter DATA_WIDTH,
    parameter IMAGE_FILE
) (
    input   wire                        CLK,
    input   wire                        RESETn,
    input   wire                        CS,
    input   wire [(DATA_WIDTH/8)-1:0]   WE,
    input   wire [(ADDR_WIDTH-1):0]     ADDR,
    input   wire [(DATA_WIDTH-1):0]     WDATA,
    output  wire [(DATA_WIDTH-1):0]     RDATA
);

    //
    // Local Parameters
    //

    localparam MEM_DEPTH    = (1 << ADDR_WIDTH);
    localparam STRB_WIDTH   = DATA_WIDTH/8;

    //
    // Internal Signals
    //

    integer                 i, fd;
    reg [(DATA_WIDTH-1):0]  memQ;
    reg [(DATA_WIDTH-1):0]  memD;

    //
    // Memory Array
    //

    reg [(DATA_WIDTH-1):0]  memory[MEM_DEPTH-1:0];

    //
    // Load Memory
    //

    initial
    begin : MemInit
        fd = $fopen(IMAGE_FILE, "r");
        if (fd != 0)
        begin
            $fclose(fd);
            $readmemh(IMAGE_FILE, memory);
        end
    end

    //
    // Memory Write
    //

    always @(posedge CLK)
    begin : MemWrite
        if (CS)
        begin
            memD    = memory[ADDR];
            for (i = 0; i < STRB_WIDTH; i=i+1)
                if (WE[i])
                    memD[i*8 +: 8] = WDATA[i*8 +: 8];
            memory[ADDR] = memD;
        end
    end

    //
    // Memory Read
    //

    always @(posedge CLK or negedge RESETn)
        if (~RESETn)
            memQ    <= {DATA_WIDTH{1'b0}};
        else if (CS)
            memQ    <= memory[ADDR];

    //
    // Output Assignments
    //

    assign RDATA    = memQ;

endmodule
