#=========================================================================
# ptpx.tcl
#=========================================================================
# Use Synopsys PrimeTime to run power analysis
#
# - Gate-level power analysis
# - Averaged power analysis
# - save_session is your friend
#
# Requires:
#
# - *.v    -- gate-level netlist
# - *.saif -- switching activity dump from gate-level simulation
# - *.sdc  -- constraints (e.g., create_clock) from PnR
# - *.spef -- parasitics from PnR
#
# Author : Kalhan Koul
# Date   : Mar 30, 2022
#

#-------------------------------------------------------------------------
# Setup
#-------------------------------------------------------------------------

# Set up design name

set ptpx_design_name "GarnetSOC_pad_frame"

# Set up paths and libraries

set_app_var search_path    ". ./ptpx_source/timing"
set_app_var target_library "./ptpx_source/timing/stdcells-base-nom-typical.db"
set_app_var link_library   "* [glob -nocomplain ./ptpx_source/timing/*.db]"

# Set up power analysis

# set pwr_mode averaged
set         pwr_mode                          averaged
set_app_var power_enable_analysis             true
set_app_var report_default_significant_digits 3

if { [info exists pwr_mode] } {
    if { $pwr_mode == "averaged" } {

        set_app_var power_analysis_mode averaged

    } elseif { $pwr_mode == "time_based" } {

        set_app_var power_analysis_mode time_based
        set_app_var power_enable_merged_fsdb true
        set_app_var power_enable_concurrent_event_analysis true

    } else {
        puts "Error: pwr_mode variable not set to averaged or time_based"
        exit
    }
} else {
    puts "Error: pwr_mode variable not set"
    exit
}

# multi-core

set_host_options -max_cores 16

#-------------------------------------------------------------------------
# Read and Link design
#-------------------------------------------------------------------------

# read in the netlist

set netlist_files [glob -nocomplain ./ptpx_source/netlist/*.v]
puts $netlist_files
foreach netlist $netlist_files {
    if { [file exists $netlist ]} {
        puts "\n  > Info: Sourcing $netlist\"\n"
        read_verilog $netlist
    } else {
        puts "\n  > Warn: No netlist $netlist found\"\n"
    }
}

# set the current design

current_design ${ptpx_design_name}

# linking

link_design

# checkpoint

save_session checkpoint_0_after_link

#-------------------------------------------------------------------------
# Read SDC file
#-------------------------------------------------------------------------

set sdc_files [glob -nocomplain ./ptpx_source/constraint/*.sdc]
puts $sdc_files
foreach sdc $sdc_files {
    if {[ file exists $sdc ]} {
        puts "\n  > Info: Sourcing $sdc\"\n"
        if {[string first "design" $sdc] != -1} {
            source $sdc
        } else {
            set block [file rootname [file tail $sdc]]
            foreach_in_collection instance [all_instances -hierarchy $block] {
                load_constraints $sdc -scope [get_object_name $instance]
            }
        }
    } else {
      puts "\n  > Warn: No sdc constraint file found\"\n"
    }
}

# checkpoint

save_session checkpoint_1_after_sdc

#-------------------------------------------------------------------------
# Loop Breaking
#-------------------------------------------------------------------------

source ./scripts/loop_break_Interconnect.tcl

# checkpoint

save_session checkpoint_2_after_break_loop

#-------------------------------------------------------------------------
# Read SPEF file
#-------------------------------------------------------------------------

set spef_files [glob -nocomplain ./ptpx_source/parasitics/*.spef]
puts $spef_files
foreach spef $spef_files {
    if {[ file exists $spef ]} {
        puts "\n  > Info: Sourcing $spef\"\n"
        set block [file rootname [file tail $spef]]
        if {$block=="design"} {
            read_parasitics -format spef $spef -keep_capacitive_coupling
        } else {
            read_parasitics -format spef $spef -keep_capacitive_coupling -path [all_instances -hierarchy $block]
        }
    }  else {
        puts "\n  > Warn: No spef parasitic $spef found\"\n"
    }
}

# checkpoint

save_session checkpoint_3_after_spef

#-------------------------------------------------------------------------
# Report Checks
#-------------------------------------------------------------------------

report_annotated_parasitics -check                            > reports/${ptpx_design_name}.parasitics.rpt
check_constraints           -verbose                          > reports/${ptpx_design_name}.checkconstraints.rpt
# report_activity_file_check $ptpx_saif -strip_path "Tbench/u_soc" > reports/${ptpx_design_name}.activity.pre.rpt

#-------------------------------------------------------------------------
# Read Activity
#-------------------------------------------------------------------------

# reads in the activity file
# [PWR FSDB] Start kernel: @T = 65195248,000 ps
# [PWR FSDB] End kernel  : @T = 65202828,000 ps

read_fsdb "./inputs/run.fsdb" -strip_path Tbench/u_soc -time {65195248 65202828}

# checkpoint

save_session checkpoint_4_after_activity

#-------------------------------------------------------------------------
# Timing Analysis
# Note: If fails on segfault, increase stack size with
#       'ulimit -s unlimited' in terminal
#-------------------------------------------------------------------------

# timing analysis

update_timing -full

# checkpoint

save_session checkpoint_5_after_timing

#-------------------------------------------------------------------------
# Power Analysis
#-------------------------------------------------------------------------

# Shows possible power problems for design

check_power > ./reports/${ptpx_design_name}.checkpower.rpt

# perform power analysis

update_power

# checkpoint

save_session checkpoint_6_after_power

#-------------------------------------------------------------------------
# Final reports
#-------------------------------------------------------------------------

report_switching_activity                                       > ./reports/${ptpx_design_name}.activity.post.rpt
report_power -nosplit -hierarchy -levels 6 -sort_by total_power > ./reports/${ptpx_design_name}.power.rpt
report_power -nosplit -hierarchy                                > ./reports/${ptpx_design_name}.power.hier.rpt
report_power -nosplit -hierarchy -leaf -levels 10               > ./reports/${ptpx_design_name}.power.cell.rpt

#-------------------------------------------------------------------------
# Done
#-------------------------------------------------------------------------

exit
