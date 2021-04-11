#=========================================================================
# pt_px.tcl
#=========================================================================
# We use Synopsys Prime-Time to get the power analysis of the PnR Netlist.
#
# This Prime-Time Power analysis step follows the Signoff step to estimate
# the average power of the gate-level netlist using RTL SAIF file.
#
# Author : Shady Agwa, Yanghui Ou
# Date   : May 7, 2019
#




set pt_reports reports
file mkdir ${pt_reports}_reconfigure
file mkdir ${pt_reports}_kernel
lappend search_path ./inputs/power_files 
set pt_target_libraries stdcells.db
lappend pt_target_libraries stdcells-pm.db
lappend pt_target_libraries iocells.db
lappend pt_target_libraries sram_tt.db
lappend pt_target_libraries sram_tt_lake.db
lappend pt_target_libraries stdcells-lvt.db
lappend pt_target_libraries stdcells-ulvt.db
#lappend pt_target_libraries dragonphy_top_tt.lib

set pt_design_name  $::env(design_name)
set pt_clk clk
set pt_uut TOP
set pt_clk_period $::env(clock_period)

set_app_var target_library $pt_target_libraries
set_app_var link_library "* $pt_target_libraries"

set_app_var power_enable_analysis true 

set svr_enable_ansi_style_port_declarations true
set svr_enable_vpp true

current_design "GarnetSOC_pad_frame" 
read_verilog {design.vcs.v glb_top.vcs.v glb_tile.vcs.v global_controller.vcs.v tile_array.vcs.v Tile_MemCore.vcs.v Tile_PE.vcs.v pfiller_dummy.v dragonphy_top.v} 

link_design

#create_clock ${pt_clk} -name ideal_clock1 -period ${pt_clk_period}
read_sdc inputs/power_files/design.sdc -version 2.0 > ${pt_reports}/${pt_design_name}.sdc.rpt
source genlibdb-constraints.tcl
read_parasitics -format spef inputs/power_files/design.spef.gz
#source inputs/design.namemap > ${pt_reports}/${pt_design_name}.map.rpt

read_saif "./inputs/reconfigure.saif" -strip_path "Tbench/u_soc" 
report_power -nosplit -hierarchy -levels 5 -sort_by total_power -verbose > ${pt_reports}_reconfigure/${pt_design_name}.pwr.small.rpt
report_switching_activity > ${pt_reports}/${pt_design_name}_reconfigure.sw.rpt 


read_saif "./inputs/run_1_kernel_plus_setup.saif" -strip_path "Tbench/u_soc" 
report_power -nosplit -hierarchy -levels 5 -sort_by total_power -verbose > ${pt_reports}_kernel/${pt_design_name}.pwr.small.rpt
report_switching_activity > ${pt_reports}/${pt_design_name}_kernel.sw.rpt 
exit
