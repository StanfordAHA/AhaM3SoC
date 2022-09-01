//------------------------------------------------------------------------------
// Verilog 2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose  : SWO Capture Gadget
//------------------------------------------------------------------------------
// Process  : None
//------------------------------------------------------------------------------
//
// Author   : Gedeon Nyengele
// Date     : August 25, 2022
//------------------------------------------------------------------------------
//
// Note:
//  - CLK is the baudrate clock
//------------------------------------------------------------------------------

module SWOCapture #(
    parameter DONE_CHAR     = 8'h04,        // Simulation termination character
    parameter BUF_SIZE      = 80
)(
    input   wire            CLK,
    input   wire            RESETn,
    input   wire            SWO
);

    localparam CHAR_CR      = 8'h0D;
    localparam CHAR_LF      = 8'h0A;

    //
    // Internal Signals
    //

    wire    [7:0]           w_rx_char;
    reg     [8:0]           r_rx_char;
    wire                    char_received;
    reg     [7:0]           line_buf[(BUF_SIZE-1):0];
    reg     [31:0]          idx;
    integer                 i;

    //
    // Receive Shift Register
    //

    always @(posedge CLK or negedge RESETn)
    if (!RESETn)
        r_rx_char   <= {9{1'b1}};
    else
    begin
        if (char_received)
            r_rx_char   <= {9{1'b1}};
        else
            r_rx_char   <= {SWO, r_rx_char[8:1]};
    end

    //
    // Received Character
    //

    assign char_received    = ~r_rx_char[0];
    assign w_rx_char        = r_rx_char[8:1];

    //
    // Message String Output
    //

    always @(posedge CLK or negedge RESETn)
    if (!RESETn)
    begin
        idx     = 32'd0;
        for (i = 0; i < BUF_SIZE; i = i + 1)
            line_buf[i] = 8'h00;
    end
    else if (char_received)
    begin
        // Carriage Return or Line Feed
        if ((w_rx_char == CHAR_CR) | (w_rx_char == CHAR_LF))
        begin
            $write("%t [SWO]: ", $time);
            for (i = 0; i < idx; i = i + 1)
                $write("%s", line_buf[i]);
            $write("\n");
            idx = 32'd0;
        end

        // DONE Signal
        else if(w_rx_char == DONE_CHAR)
        begin
            $write("%t [SWO]: Simulation Ended\n", $time);
            $stop;
        end

        // Any Other Character
        else
        begin
            line_buf[idx]   = w_rx_char;
            idx             = idx + 1;

            // Flush buffer if needed
            if (idx >= BUF_SIZE)
            begin
                $write("%t [SWO]: ", $time);
                for (i = 0; i < BUF_SIZE; i++)
                    $write("%s", line_buf[i]);
                $write("\n");
                idx = 32'd0;
            end
        end
    end
endmodule
