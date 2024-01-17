import os
import argparse
from math import ceil, floor

io_list = [
    {'name': 'TLX_REV_PAYLOAD_TDATA_LO', 'bstart': 5, 'width': 5, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_FWD_CLK',              'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_CLK',              'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_PAYLOAD_TVALID',   'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_FWD_PAYLOAD_TVALID',   'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_FWD_FLOW_TVALID',      'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_FWD_FLOW_TDATA',       'bstart': 0, 'width': 2, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_FLOW_TVALID',      'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_FLOW_TDATA',       'bstart': 0, 'width': 3, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'LOOP_BACK',                'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'LOOP_BACK_SELECT',         'bstart': 0, 'width': 4, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'PORESETn',                 'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'MASTER_CLK',               'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'SYSRESETn',                'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'DP_JTAG_TDI',              'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'DP_JTAG_TMS',              'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'DP_JTAG_TRSTn',            'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'DP_JTAG_TDO',              'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'DP_JTAG_TCK',              'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'CGRA_JTAG_TDI',            'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'CGRA_JTAG_TMS',            'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'CGRA_JTAG_TRSTn',          'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'CGRA_JTAG_TDO',            'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'CGRA_JTAG_TCK',            'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'UART0_RXD',                'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'UART0_TXD',                'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'UART1_RXD',                'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'UART1_TXD',                'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TPIU_TRACECLKIN',          'bstart': 0, 'width': 1, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TPIU_TRACE_SWO',           'bstart': 0, 'width': 1, 'direction': 'output', 'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_PAYLOAD_TDATA_LO', 'bstart': 0, 'width': 5, 'direction': 'input',  'pad': 'digital', 'side': 'top'},
    {'name': 'TLX_REV_PAYLOAD_TDATA_LO', 'bstart': 10, 'width': 35,'direction': 'input',  'pad': 'digital', 'side': 'left'},
    {'name': 'TLX_REV_PAYLOAD_TDATA_HI', 'bstart': 0, 'width': 35,'direction': 'input',  'pad': 'digital', 'side': 'right'},
    {'name': 'TLX_FWD_PAYLOAD_TDATA_HI', 'bstart': 0, 'width': 24,'direction': 'output', 'pad': 'digital', 'side': 'bottom'},
    {'name': 'TLX_FWD_PAYLOAD_TDATA_LO', 'bstart': 0, 'width': 16,'direction': 'output', 'pad': 'digital', 'side': 'bottom'}
]

pads = {
    'top'   : [],
    'bottom': [],
    'left'  : [],
    'right' : []
}

pads_postfix = {
    'top'   : 'n1',
    'bottom': 'n1',
    'left'  : 'e1',
    'right' : 'e1'
}

# GPIO Pad template
pad_template = {}
pad_template["input"] = '''gpio_1v2_{orient} {pad_name} (
    .pad          (pad_{io_name}[{bit}]),
    .ana_io_1v2   (), // floating
    .outi_1v2     (), // floating
    .outi         ({io_name}_int[{bit}]),
    .dq           (1'b0),
    .drv0         (out_pad_ds_grp0[0]),
    .drv1         (out_pad_ds_grp0[1]),
    .drv2         (out_pad_ds_grp0[2]),
    .enq          (1'b1), // input pad: output tristate
    .enabq        (1'b0), // input pad: enable receiver
    .pd           (1'b1),
    .puq          (1'b1),
    .pwrupzhl     (1'b0),
    .pwrup_pull_en(1'b0),
    .ppen         (1'b1),
    .prg_slew     (1'b1)
);
'''
pad_template["output"] = '''gpio_1v2_{orient} {pad_name} (
    .pad          (pad_{io_name}[{bit}]),
    .ana_io_1v2   (), // floating
    .outi_1v2     (), // floating
    .outi         (), // floating
    .dq           (~{io_name}_int[{bit}]), // output is inverted
    .drv0         (out_pad_ds_grp0[0]),
    .drv1         (out_pad_ds_grp0[1]),
    .drv2         (out_pad_ds_grp0[2]),
    .enq          (1'b0), // output pad: output enable
    .enabq        (1'b1), // output pad: disable receiver
    .pd           (1'b1),
    .puq          (1'b1),
    .pwrupzhl     (1'b0),
    .pwrup_pull_en(1'b0),
    .ppen         (1'b1),
    .prg_slew     (1'b1)
);
'''

dummy_core = '''
// =================================================================
// =              Dummy Core Logic Created For TMA 1               =
// =================================================================
reg        TLX_FWD_CLK_reg;
reg        DP_JTAG_TDO_reg;
reg        CGRA_JTAG_TDO_reg;
reg        LOOP_BACK_reg;
reg        TLX_FWD_PAYLOAD_TVALID_reg;
reg        TLX_FWD_FLOW_TVALID_reg;
reg [1:0]  TLX_FWD_FLOW_TDATA_reg;
reg        TPIU_TRACE_SWO_reg;
reg        UART0_TXD_reg;
reg        UART1_TXD_reg;
reg [23:0] TLX_FWD_PAYLOAD_TDATA_HI_reg;
reg [15:0] TLX_FWD_PAYLOAD_TDATA_LO_reg;

wire [39:0] dummy_logic;
wire [39:0] dummy_a = TLX_REV_PAYLOAD_TDATA_LO_int[39:0];
wire [39:0] dummy_b = {TLX_REV_PAYLOAD_TDATA_LO_int[44:40],
                       TLX_REV_PAYLOAD_TDATA_HI_int};
wire [39:0] dummy_c = {LOOP_BACK_SELECT_int, 
                       TPIU_TRACECLKIN_int,
                       UART0_RXD_int,
                       UART1_RXD_int,
                       TLX_REV_FLOW_TVALID_int,
                       TLX_REV_FLOW_TDATA_int, 29'd0};
assign dummy_logic = dummy_a & dummy_b | dummy_c;

always@(posedge MASTER_CLK_int) begin
    if (SYSRESETn_int) begin
        TLX_FWD_CLK_reg              <= 0;
        DP_JTAG_TDO_reg              <= 0;
        CGRA_JTAG_TDO_reg            <= 0;
        LOOP_BACK_reg                <= 0;
        TLX_FWD_PAYLOAD_TVALID_reg   <= 0;
        TLX_FWD_FLOW_TVALID_reg      <= 0;
        TLX_FWD_FLOW_TDATA_reg       <= 2'd0;
        TPIU_TRACE_SWO_reg           <= 0;
        UART0_TXD_reg                <= 0;
        UART1_TXD_reg                <= 0;
        TLX_FWD_PAYLOAD_TDATA_HI_reg <= 24'd0;
        TLX_FWD_PAYLOAD_TDATA_LO_reg <= 16'd0;
    end
    else begin
        TLX_FWD_CLK_reg              <= DP_JTAG_TCK_int;
        DP_JTAG_TDO_reg              <= DP_JTAG_TDI_int;
        CGRA_JTAG_TDO_reg            <= DP_JTAG_TMS_int;
        LOOP_BACK_reg                <= DP_JTAG_TRSTn_int;
        TLX_FWD_PAYLOAD_TVALID_reg   <= CGRA_JTAG_TCK_int;
        TLX_FWD_FLOW_TVALID_reg      <= CGRA_JTAG_TDI_int;
        TLX_FWD_FLOW_TDATA_reg       <= {CGRA_JTAG_TMS_int, CGRA_JTAG_TRSTn_int};
        TPIU_TRACE_SWO_reg           <= PORESETn_int;
        UART0_TXD_reg                <= TLX_REV_CLK_int;
        UART1_TXD_reg                <= TLX_REV_PAYLOAD_TVALID_int;
        TLX_FWD_PAYLOAD_TDATA_HI_reg <= dummy_logic[0+:24];
        TLX_FWD_PAYLOAD_TDATA_LO_reg <= dummy_logic[24+:16];
    end
end

assign TLX_FWD_CLK_int              = TLX_FWD_CLK_reg;
assign DP_JTAG_TDO_int              = DP_JTAG_TDO_reg;
assign CGRA_JTAG_TDO_int            = CGRA_JTAG_TDO_reg;
assign LOOP_BACK_int                = LOOP_BACK_reg;
assign TLX_FWD_PAYLOAD_TVALID_int   = TLX_FWD_PAYLOAD_TVALID_reg;
assign TLX_FWD_FLOW_TVALID_int      = TLX_FWD_FLOW_TVALID_reg;
assign TLX_FWD_FLOW_TDATA_int       = TLX_FWD_FLOW_TDATA_reg;
assign TPIU_TRACE_SWO_int           = TPIU_TRACE_SWO_reg;
assign UART0_TXD_int                = UART0_TXD_reg;
assign UART1_TXD_int                = UART1_TXD_reg;
assign TLX_FWD_PAYLOAD_TDATA_HI_int = TLX_FWD_PAYLOAD_TDATA_HI_reg;
assign TLX_FWD_PAYLOAD_TDATA_LO_int = TLX_FWD_PAYLOAD_TDATA_LO_reg;
// =================================================================
// =              Dummy Core Logic Created For TMA 1               =
// =================================================================
'''

# differential clock receiver
diff_clk_rx_inst = '''
diffclock_rx_1v2 u_diff_clk_rx (
      .powergood_vnn                 ( 1'b1              )
    , .diffclkrx_ldo_vref            ( 1'b0              )
    , .diffclkrx_fz_ldo_vinvoltsel   ( 2'b00             )
    , .diffclkrx_fz_ldo_fbtrim       ( 4'b1111           )
    , .diffclkrx_fz_ldo_reftrim      ( 4'b1100           )
    , .diffclkrx_fz_strong_ladder_en ( 1'b0              )
    , .diffclkrx_fz_ldo_faststart    ( 1'b0              )
    , .diffclkrx_fz_ldo_bypass       ( 1'b0              )
    , .diffclkrx_fz_ldo_extrefsel    ( 1'b0              )
    , .diffclkrx_odt_en              ( 1'b1              )
    , .diffclkrx_bias_config         ( 2'b11             )
    , .diffclkrx_ldo_hiz_debug       ( 1'b0              )
    , .diffclkrx_ldo_idq_debug       ( 1'b0              )
    , .diffclkrx_anaviewmux_sel0     ( 1'b0              )
    , .diffclkrx_anaviewmux_sel1     ( 1'b0              )
    , .diffclkrx_viewana_en          ( 1'b0              )
    , .diffclkrx_viewdig_en          ( 1'b0              )
    , .diffclkrx_viewdigdfx_sel      ( 1'b0              )
    , .diffclkrx_clkref              ( 1'b0              )
    , .diffclkrx_rxen                ( 1'b1              )
    , .diffclkrx_viewanabus          (                   )
    , .diffclkrx_viewdigout          (                   )
    , .diffclkrx_inn                 ( pad_diffclkrx_inn )
    , .diffclkrx_inp                 ( pad_diffclkrx_inp )
    , .diffclkrx_out                 ( ALT_MASTER_CLK    )
);
'''

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('--include_core', type=int, default=0, help='Include core (0 or 1)')
parser.add_argument('--include_diff_clock_rx', type=int, default=0, help='Include differential clock receiver (0 or 1)')
parser.add_argument('--top', type=str, default='GarnetSOC_pad_frame', help='Top module name')
args = parser.parse_args()

# top module name
module_name = args.top

# create a folder called genesis_verif to make it backwards compatible
if not os.path.exists('genesis_verif'):
    os.makedirs('genesis_verif')

def get_pin_width(arg_io_list, pin_name):
    width = 0
    for io in arg_io_list:
        if io['name'] == pin_name:
            width += io['width']
    return width

# Generate the pad frame verilog in the above folder
with open('genesis_verif/' + module_name + '.sv', 'w') as f:
    # module IO list
    f.write(f'module {module_name} (\n')
    for i in range(len(io_list)):
        if (io_list[i]['bstart'] != 0):
            continue
        pin_name = io_list[i]['name']
        width = get_pin_width(io_list, pin_name)
        direction = io_list[i]['direction']
        name = f"pad_{pin_name}"
        f.write(f'    {direction} [{width-1}:0] {name},\n')
    if args.include_diff_clock_rx == 1:
        f.write(f'    input pad_diffclkrx_inn,\n')
        f.write(f'    input pad_diffclkrx_inp\n')
        f.write(f'\n);\n')
    else:
        # remove the last comma by moving back 2 characters
        f.seek(f.tell() - 2, os.SEEK_SET)
        f.write(f'\n);\n')

    # create internal wires
    f.write(f'// Now create wires that will connect from pads to core module\n')
    for i in range(len(io_list)):
        if (io_list[i]['bstart'] != 0):
            continue
        else:
            pin_name = io_list[i]['name']
            width = get_pin_width(io_list, pin_name)
            f.write(f"wire [{width-1}:0] {pin_name}_int;\n")
    f.write("wire [2:0] out_pad_ds_grp0;\n")
    f.write("wire [2:0] out_pad_ds_grp1;\n")
    f.write("wire [2:0] out_pad_ds_grp2;\n")
    f.write("wire [2:0] out_pad_ds_grp3;\n")
    f.write("wire [2:0] out_pad_ds_grp4;\n")
    f.write("wire [2:0] out_pad_ds_grp5;\n")
    f.write("wire [2:0] out_pad_ds_grp6;\n")
    f.write("wire [2:0] out_pad_ds_grp7;\n")
    f.write("wire       ALT_MASTER_CLK;\n\n")

    # Instantiate all pads
    for i in range(len(io_list)):
        name = io_list[i]['name']
        bstart = io_list[i]['bstart']
        width = io_list[i]['width']
        direction = io_list[i]['direction']
        pad = io_list[i]['pad']
        side = io_list[i]['side']
        for bit in range(bstart, bstart+width):
            pad_name = f"IOPAD_{side}_{name}_{bit}";
            instance = pad_template[direction].format(orient=pads_postfix[side],
                                                           pad_name=pad_name,
                                                           io_name=name,
                                                           bit=bit)
            f.write(instance)
            pads[side].append(pad_name)
    
    # Instantiate differential clock receiver
    if args.include_diff_clock_rx == 1:
        f.write(diff_clk_rx_inst)
    else:
        f.write("// Differential clock receiver is not included\n")
        f.write("assign ALT_MASTER_CLK = 1'b0;")
    # Create Core
    if args.include_core == 1:
        f.write("AhaGarnetSoC core (\n")
        f.write("  .OUT_PAD_DS_GRP0(out_pad_ds_grp0),\n")
        f.write("  .OUT_PAD_DS_GRP1(out_pad_ds_grp1),\n")
        f.write("  .OUT_PAD_DS_GRP2(out_pad_ds_grp2),\n")
        f.write("  .OUT_PAD_DS_GRP3(out_pad_ds_grp3),\n")
        f.write("  .OUT_PAD_DS_GRP4(out_pad_ds_grp4),\n")
        f.write("  .OUT_PAD_DS_GRP5(out_pad_ds_grp5),\n")
        f.write("  .OUT_PAD_DS_GRP6(out_pad_ds_grp6),\n")
        f.write("  .OUT_PAD_DS_GRP7(out_pad_ds_grp7),\n")
        f.write("  .ALT_MASTER_CLK(ALT_MASTER_CLK),\n")
        for i in range(len(io_list)):
            if (io_list[i]['bstart'] != 0):
                continue
            f.write(f"  .{io_list[i]['name']}({io_list[i]['name']}_int),\n")
        # remove the last comma by moving back 2 characters
        f.seek(f.tell() - 2, os.SEEK_SET)
        f.write(f'\n);\n')
    else:
        f.write(dummy_core)
    
    # Instantiate power pads
    #     under current Intel die frame, the number of power pads must be odd
    #     otherwise io fillers will not be able to fill all the gaps
    signal_between_supply = 4

    for side in ['top', 'bottom', 'left', 'right']:
        # create a new pad list to include power pads
        new_pad_list = []
        # insert the first power pad
        pad_name = f"IOPAD_{side}_SUPPLY_0"
        f.write(f"sup1v8_{pads_postfix[side]} {pad_name} ();\n")
        new_pad_list.append(pad_name)
        # insert the rest of the pads
        n = 0
        p = 1
        while pads[side]:
            pad_name = pads[side].pop(0)
            new_pad_list.append(pad_name)
            n += 1
            if n == signal_between_supply:
                pad_name = f"IOPAD_{side}_SUPPLY_{p}"
                f.write(f"sup1v8_{pads_postfix[side]} {pad_name} ();\n")
                new_pad_list.append(pad_name)
                n = 0
                p += 1
        if p % 2 == 1:
            # if p is even, it means we will have to insert another power pad to make it odd 
            pad_name = f"IOPAD_{side}_SUPPLY_{p}"
            f.write(f"sup1v8_{pads_postfix[side]} {pad_name} ();\n")
            new_pad_list.append(pad_name)
            p += 1
        assert p % 2 == 0, "The number of power pads must be even"
        # update the pad list
        pads[side] = new_pad_list
        print(f'number of pads on side {side} is {len(pads[side])}')

    # Instantiate corner pads
    # f.write("corner_nw1 corner_ur ();\n")
    f.write("ring_terminator_e1 ring_terminator_right ();\n")
    f.write("ring_terminator_n1 ring_terminator_top ();\n")
    # f.write("corner_nw1 corner_ll ();\n")
    f.write("ring_terminator_e1 ring_terminator_left ();\n")
    f.write("ring_terminator_n1 ring_terminator_bottom ();\n")
    f.write("corner_nw1 corner_ul ();\n")
    f.write("corner_nw1 corner_lr ();\n")

    # endmodule
    f.write("endmodule\n")

# Settings for the full chip floorplan (v0)
# die_width         = 3924.72
# die_height        = 4084.92
# die_ring_hori     = 12.96
# die_ring_vert     = 13.86
# prs_width         = 58.32
# prs_height        = 57.96
# pad_ring_hori     = 45.36
# pad_ring_vert     = 47.88
# white_space_hori  = 0.54
# white_space_vert  = 0.63
# core_width        = die_width - 2 * (die_ring_hori + white_space_hori + pad_ring_hori)
# core_height       = die_height - 2 * (die_ring_vert + prs_height + white_space_vert + pad_ring_vert)
# margin_width      = die_ring_hori + white_space_hori + pad_ring_hori
# margin_height     = die_ring_vert + prs_height + white_space_vert + pad_ring_vert
# Settings for the full chip floorplan (v1)
die_width         = 3924.72
die_height        = 4084.92
# die_ring_hori     = 12.96
# die_ring_vert     = 13.86
die_ring_hori     = 16.2
die_ring_vert     = 17.64
prs_width         = 58.32
prs_height        = 57.96
pad_ring_hori     = 45.36
pad_ring_vert     = 47.88
white_space_hori  = prs_width - pad_ring_hori
white_space_vert  = prs_height - pad_ring_vert
margin_width      = die_ring_hori + white_space_hori + pad_ring_hori
margin_height     = die_ring_vert + white_space_vert + pad_ring_vert
core_width        = die_width - 2 * margin_width
core_height       = die_height - 2 * margin_height

core_ll_xy = (margin_width, margin_height)
core_lr_xy = (margin_width + core_width, margin_height)
core_ul_xy = (margin_width, margin_height + core_height)
core_ur_xy = (margin_width + core_width, margin_height + core_height)

pads_orientations = {
    'top'   : 'R0',
    'bottom': 'R180',
    'left'  : 'R0',
    'right' : 'R180'
}

corner_pad_xy = {
    'ul': (die_ring_hori + prs_width - pad_ring_hori,
           die_height - die_ring_vert - prs_height),
    'lr': (die_width - die_ring_hori - prs_width,
           die_ring_vert + prs_height - pad_ring_vert),
}

corner_orientations = {
    'ul': 'R0',
    'ur': 'MY',
    'll': 'MX',
    'lr': 'R180'
}

ring_terminator_orientations = {
    'top'    : 'MY',
    'bottom' : 'MX',
    'left'   : 'MX',
    'right'  : 'MY'
}

supply_length = {
    'top'   : 42.12,
    'bottom': 42.12,
    'left'  : 41.58,
    'right' : 41.58
}

gpio_length = {
    'top'   : 43.2,
    'bottom': 43.2,
    'left'  : 47.88,
    'right' : 47.88
}

io_filler_length = {
    'top'   : 2.16,
    'bottom': 2.16,
    'left'  : 2.52,
    'right' : 2.52
}

ring_terminator_length = {
    'top'   : 4.32,
    'bottom': 4.32,
    'left'  : 2.52,
    'right' : 2.52
}

bump_offset = {
    'top'   : 174.912,
    'bottom': 330.864,
    'left'  : 341.82,
    'right' : 341.82
}

bump_interval = {
    'top'   : 155.952,
    'bottom': 155.952,
    'left'  : 156.24,
    'right' : 156.24
}

bump_length = {
    'top'   : 12.0,
    'bottom': 12.0,
    'left'  : 36.0,
    'right' : 36.0
}

def post_process_pos(pos, pre_edge, filler_length, direction):
    gap = pos - pre_edge
    num_fillers = gap / filler_length
    assert direction in ['up', 'down'], f'direction {direction} is not supported'
    # check if num_fillers is close to an integer
    if abs(num_fillers - round(num_fillers)) < 0.0001:
        return pos, direction
    else:
        if (direction == 'up'):
            num_fillers = ceil(num_fillers)
            direction = 'down'
        elif (direction == 'down'):
            num_fillers = floor(num_fillers)
            direction = 'up'
        if num_fillers < 1:
            num_fillers = 1
        return pre_edge + num_fillers * filler_length, direction

pad_core_space_top_bottom = 3 * io_filler_length['left']
pad_core_space_left_right = 3 * io_filler_length['top']

# Generate io_file (place the IO Pads)
with open("io_pad_placement.tcl", "w") as f:
    for side in ['top', 'bottom', 'left', 'right']:
        # can be arbitrary, but set it to be the same as the ring terminator length
        if side in ['top', 'bottom']:
            space_between_terminator_and_corner = 2 * ring_terminator_length[side]
        else:
            space_between_terminator_and_corner = 4 * ring_terminator_length[side]
        # compute the total length of the pads on this side
        pad_length_sum = 0
        for pad in pads[side]:
            if 'SUPPLY' in pad:
                pad_length_sum += supply_length[side]
            else:
                pad_length_sum += gpio_length[side]
        pad_length_sum += ring_terminator_length[side]
        pad_length_sum += space_between_terminator_and_corner

        # compute how many fillers are needed
        if side in ['top', 'bottom']:
            total_gap_length = core_width - pad_length_sum + pad_core_space_left_right
        else:
            total_gap_length = core_height - pad_length_sum + pad_core_space_top_bottom
        num_filler = total_gap_length / io_filler_length[side]
        # make sure it is very close to an integer
        assert abs(num_filler - round(num_filler)) < 0.01, f'number of fillers on side {side} is not close to an integer: {num_filler:.2f}'
        num_filler = round(num_filler)

        # --- Compute the positions for the pads (v0): 1 Ring with 4 corners, pads equally spaced
        # num_filler_per_gap = floor(round(num_filler) / (len(pads[side]) + 1))
        # remaining_fillers = round(num_filler) - num_filler_per_gap * (len(pads[side]) + 1)
        # # print(f'on side {side}, fillers per gap is {num_filler_per_gap}, remaining is {remaining_fillers}')
        # # Start putting pads
        # if side == 'top':
        #     x, y = corner_pad_xy['ul']
        #     x += pad_ring_hori
        # elif side == 'bottom':
        #     x, y = corner_pad_xy['ll']
        #     x += pad_ring_hori
        # elif side == 'left':
        #     x, y = corner_pad_xy['ll']
        #     y += pad_ring_vert
        # else:
        #     x, y = corner_pad_xy['lr']
        #     y += pad_ring_vert
        # for pad in pads[side]:
        #     if remaining_fillers > 0:
        #         gap_fillers = num_filler_per_gap + 1
        #         remaining_fillers -= 1
        #     else:
        #         gap_fillers = num_filler_per_gap
        #     # compute the x and y coordinates
        #     if   side == 'top'   : x = x + gap_fillers * io_filler_length[side]
        #     elif side == 'bottom': x = x + gap_fillers * io_filler_length[side]
        #     elif side == 'left'  : y = y + gap_fillers * io_filler_length[side]
        #     else                 : y = y + gap_fillers * io_filler_length[side]
        #     f.write(f'placeInstance {pad} {x:.2f} {y:.2f} {pads_orientations[side]}\n')
        #     # advance to the next pad start position
        #     io_cell_length = supply_length[side] if 'SUPPLY' in pad else gpio_length[side]
        #     if   side == 'top'   : x = x + io_cell_length
        #     elif side == 'bottom': x = x + io_cell_length
        #     elif side == 'left'  : y = y + io_cell_length
        #     else                 : y = y + io_cell_length
        
        # --- Compute the positions for the pads (v1) : 2 half rings with 2 corners and 4 terminators, pads equally spaced
        # num_gaps = len(pads[side]) + 1
        # num_filler_per_gap = floor(num_filler / num_gaps)
        # remaining_fillers = num_filler - num_filler_per_gap * num_gaps
        # print(f'on side {side}, fillers per gap is {num_filler_per_gap}, remaining is {remaining_fillers}')
        # # Start putting pads
        # if side == 'top':
        #     x, y = core_ul_xy
        # elif side == 'bottom':
        #     x, y = core_ll_xy
        #     x += space_between_terminator_and_corner
        #     y -= pad_ring_vert
        #     f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
        #     x += ring_terminator_length[side]
        # elif side == 'left':
        #     x, y = core_ll_xy
        #     x -= pad_ring_hori
        #     y += space_between_terminator_and_corner
        #     f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
        #     y += ring_terminator_length[side]
        # else:
        #     x, y = core_lr_xy
        # for pad in pads[side]:
        #     if remaining_fillers > 0:
        #         gap_fillers = num_filler_per_gap + 1
        #         remaining_fillers -= 1
        #     else:
        #         gap_fillers = num_filler_per_gap
        #     # compute the x and y coordinates
        #     if   side == 'top'   : x = x + gap_fillers * io_filler_length[side]
        #     elif side == 'bottom': x = x + gap_fillers * io_filler_length[side]
        #     elif side == 'left'  : y = y + gap_fillers * io_filler_length[side]
        #     else                 : y = y + gap_fillers * io_filler_length[side]
        #     f.write(f'placeInstance {pad} {x:.2f} {y:.2f} {pads_orientations[side]}\n')
        #     # advance to the next pad start position
        #     io_cell_length = supply_length[side] if 'SUPPLY' in pad else gpio_length[side]
        #     if   side == 'top'   : x = x + io_cell_length
        #     elif side == 'bottom': x = x + io_cell_length
        #     elif side == 'left'  : y = y + io_cell_length
        #     else                 : y = y + io_cell_length
        # if side == 'top':
        #     if remaining_fillers > 0:
        #         gap_fillers = num_filler_per_gap + 1
        #         remaining_fillers -= 1
        #     else:
        #         gap_fillers = num_filler_per_gap
        #     # compute the x and y coordinates
        #     x = x + gap_fillers * io_filler_length[side]
        #     f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
        # elif side == 'right':
        #     if remaining_fillers > 0:
        #         gap_fillers = num_filler_per_gap + 1
        #         remaining_fillers -= 1
        #     else:
        #         gap_fillers = num_filler_per_gap
        #     # compute the x and y coordinates
        #     y = y + gap_fillers * io_filler_length[side]
        #     f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
        
        # --- Compute the positions for the pads (v2) : 2 half rings with 2 corners and 4 terminators, pads put between bumps
        # Put starting ring terminators and initialize pad positions 
        if side == 'top':
            x, y = core_ul_xy
            x -= pad_core_space_left_right
            y += pad_core_space_top_bottom
            pre_edge = x
        elif side == 'bottom':
            x, y = core_ll_xy
            x += space_between_terminator_and_corner
            y -= pad_ring_vert
            y -= pad_core_space_top_bottom
            f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
            pre_edge = x + ring_terminator_length[side]
        elif side == 'left':
            x, y = core_ll_xy
            x -= pad_core_space_left_right
            x -= pad_ring_hori
            y += space_between_terminator_and_corner
            f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
            pre_edge = y + ring_terminator_length[side]
        elif side == 'right':
            x, y = core_lr_xy
            x += pad_core_space_left_right
            y -= pad_core_space_top_bottom
            pre_edge = y
            
        # we call the space between two bumps a slot
        # for top/bottom, we fit two/three pads in a slot in an alternating fashion
        # for left/right, we fit two pads in a slot
        pads_per_slot = 2
        slot_start = bump_offset[side]
        round_dir = 'up' # alternating between 'up' and 'down'
        while pads[side]:
            for n in range(1, pads_per_slot+1):
                pad = pads[side].pop(0)
                io_cell_length = supply_length[side] if 'SUPPLY' in pad else gpio_length[side]
                space = (bump_interval[side] - bump_length[side] - pads_per_slot*io_cell_length) / (pads_per_slot + 1)
                new_pos = slot_start + n * space + (n - 1) * io_cell_length
                # make sure it has integer multiple of fillers between the previous edge
                new_pos, round_dir = post_process_pos(pos=new_pos,
                                                      pre_edge=pre_edge,
                                                      filler_length=io_filler_length[side],
                                                      direction=round_dir)
                pre_edge = new_pos + io_cell_length
                # update the x/y to the new position
                if   side == 'top'   : x = new_pos
                elif side == 'bottom': x = new_pos
                elif side == 'left'  : y = new_pos
                else                 : y = new_pos
                f.write(f'placeInstance {pad} {x:.2f} {y:.2f} {pads_orientations[side]}\n')
                # alternating pad orientation on east/west side
                if side == 'left':
                    if pads_orientations[side] == 'R0':
                        pads_orientations[side] = 'MX'
                    elif pads_orientations[side] == 'MX':
                        pads_orientations[side] = 'R0'
                elif side == 'right':
                    if pads_orientations[side] == 'R180':
                        pads_orientations[side] = 'MY'
                    elif pads_orientations[side] == 'MY':
                        pads_orientations[side] = 'R180'
                # check if we still have pad on this side
                if not pads[side]:
                    break
            # advance to the next slot
            slot_start = slot_start + bump_interval[side]
            if side in ['top', 'bottom']:
                if pads_per_slot == 2:
                    pads_per_slot = 3
                else:
                    pads_per_slot = 2
        if side == 'top':
            bound_pos, _ = core_ur_xy
            # compute the x and y coordinates
            x = bound_pos - ring_terminator_length[side] - space_between_terminator_and_corner
            f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
        elif side == 'right':
            _, bound_pos = core_ur_xy
            # compute the x and y coordinates
            y = bound_pos - ring_terminator_length[side] - space_between_terminator_and_corner
            f.write(f'placeInstance ring_terminator_{side} {x:.2f} {y:.2f} {ring_terminator_orientations[side]}\n')
    # upper-left corner
    corner = 'ul'
    x, y = corner_pad_xy[corner]
    x -= pad_core_space_left_right
    y += pad_core_space_top_bottom
    f.write(f'placeInstance corner_{corner} {x:.2f} {y:.2f} {corner_orientations[corner]}\n')
    # lower-right corner
    corner = 'lr'
    x, y = corner_pad_xy[corner]
    x += pad_core_space_left_right
    y -= pad_core_space_top_bottom
    f.write(f'placeInstance corner_{corner} {x:.2f} {y:.2f} {corner_orientations[corner]}\n')

with open("io_file", "w") as f:
    f.write('deprecated\n')