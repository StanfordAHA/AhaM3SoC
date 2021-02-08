module dragonphy_top (
    input   wire      ext_clk_async_n,
    input   wire      ext_clk_async_p,
    input   wire      ext_clkn,
    input   wire      ext_clkp,
    input   wire      ext_Vcm,
    inout   wire      ext_Vcal,
    input   wire      ext_mdll_clk_refp,
    input   wire      ext_mdll_clk_refn,
    input   wire      ext_mdll_clk_monn,
    input   wire      ext_mdll_clk_monp,
    input   wire      ext_rx_inp,
    input   wire      ext_rx_inn,
    input   wire      ext_rx_inp_test,
    input   wire      ext_rx_inn_test,
    output  wire      clk_out_p,
    output  wire      clk_out_n,
    output  wire      clk_trig_p,
    output  wire      clk_trig_n,
    input   wire      jtag_intf_i_phy_tck,
    input   wire      jtag_intf_i_phy_tdi,
    input   wire      jtag_intf_i_phy_tms,
    input   wire      jtag_intf_i_phy_trst_n,
    input   wire      ext_rstb,
    input   wire      ext_dump_start,
    output  wire      jtag_intf_i_phy_tdo,
    output  wire      clk_cgra,
    input wire ext_tx_outn,
    input wire ext_tx_outp,
	input wire ramp_clock,
    input wire freq_lvl_cross
);
    wire unused =     jtag_intf_i_phy_tck |
                      jtag_intf_i_phy_tdi |
                      jtag_intf_i_phy_tms |
                      jtag_intf_i_phy_trst_n |
                      ext_rstb |
                      ext_dump_start |
                      ext_clk_async_n |
                      ext_clk_async_p |
                      ext_clkn |
                      ext_clkp |
                      ext_Vcm |
                      ext_mdll_clk_refp |
                      ext_mdll_clk_refn |
                      ext_mdll_clk_monn |
                      ext_mdll_clk_monp |
                      ext_rx_inp |
                      ext_rx_inn |
                      ext_rx_inp_test |
                      ext_rx_inn_test |
                      ext_tx_outn |
                      ext_tx_outp |
                      ramp_clock |
                      freq_lvl_cross ;


    reg clk;

    initial begin
      clk = 1'b0;
      forever #0.5 clk = ~clk;
    end

    assign jtag_intf_i_phy_tdo = 1'b0;
    assign clk_cgra = clk;

    assign clk_out_p  = 1'b0;
    assign clk_out_n  = 1'b0;
    assign clk_trig_p = 1'b0;
    assign clk_trig_n = 1'b0;
endmodule
