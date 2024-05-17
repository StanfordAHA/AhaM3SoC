# Loop break constraints

# Set the port search control
# This option controls whether the get_ports command can get ports of current instance.
set port_search_in_current_instance true

foreach_in_collection tile [get_cells -hier -regexp Tile_X\[0-9A-F\]+_Y\[0-9A-F\]+] {
  # set the scope to a specific tile
  current_instance [get_attribute $tile full_name]

  # ======================== scripts borrowed from genlibdb-constraints.tcl ========================
  puts "\[loop_break_Interconnect.tcl\] Setting paths from SB-inputs to SB-outputs to be false paths."
  set_false_path -from [get_ports SB* -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  # We don't want to analyze the full combinational path through PE/MEM core in tile_array level 
  set PE_core_name PE_inst0
  set PE_core_cell [get_cells -quiet $PE_core_name]
  if {[string length $PE_core_cell] == 0} {
      puts "\[loop_break_Interconnect.tcl\] Warning: PE core ($PE_core_name) not found."
      puts "\[loop_break_Interconnect.tcl\]          Possilby because you are running this script on a MEM tile."
  } else {
      puts "\[loop_break_Interconnect.tcl\] Setting paths through PE core ($PE_core_name) to be false paths."
      set_false_path -through $PE_core_cell
  }
  set MEM_core_name MemCore_inst0
  set Mem_core_cell [get_cells -quiet $MEM_core_name]
  if {[string length $Mem_core_cell] == 0} {
      puts "\[loop_break_Interconnect.tcl\] Warning: MEM core ($MEM_core_name) not found."
      puts "\[loop_break_Interconnect.tcl\]          Possilby because you are running this script on a PE tile."
  } else {
      puts "\[loop_break_Interconnect.tcl\] Setting paths through MEM core ($MEM_core_name) to be false paths."
      set_false_path -through $Mem_core_cell
  }
  # We don't want to analyze other inputs to SB_OUT
  set_false_path -from [get_ports *config_config_addr*  -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *config_config_data*  -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *config_read*         -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *config_write*        -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *flush*               -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *read_config_data_in* -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *reset*               -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *stall*               -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  set_false_path -from [get_ports *tile_id*             -filter {direction == in}] -to [get_ports SB* -filter {direction == out}]
  # ======================== scripts borrowed from genlibdb-constraints.tcl ========================

  # reset the scope back to top
  current_instance
}

# Reset the port search control
set port_search_in_current_instance false

# Debugging
# foreach_in_collection tile [get_cells -hier -regexp Tile_X\[0-9A-F\]+_Y\[0-9A-F\]+] {
#   puts [get_attribute $tile full_name]
# }
