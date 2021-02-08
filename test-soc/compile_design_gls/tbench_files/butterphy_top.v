module butterphy_top (
    input wire jtag_intf_i_phy_tck,
    input wire jtag_intf_i_phy_tdi,
    input wire jtag_intf_i_phy_tms,
    input wire jtag_intf_i_phy_trst_n,
    input wire ext_rstb,
    input wire ext_dump_start,
    output wire jtag_intf_i_phy_tdo
);
    wire unused = jtag_intf_i_phy_tck |
        jtag_intf_i_phy_tdi |
        jtag_intf_i_phy_tms |
        jtag_intf_i_phy_trst_n |
        ext_rstb |
        ext_dump_start;

    assign jtag_intf_i_phy_tdo = 1'b0;
endmodule
