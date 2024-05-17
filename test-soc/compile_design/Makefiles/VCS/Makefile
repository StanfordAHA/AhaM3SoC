ARM_IP_PATH					:= $(abspath $(ARM_IP_DIR))
AHA_IP_PATH					:= $(abspath $(AHA_IP_DIR))
TOP_DIR 					:= $(abspath $(TOP_DIR))

# ==============================================================================
# VCS Options
# ------------------------------------------------------------------------------

# Common
VCS_COMPILE_OPTS	:= +v2k -noIncrComp -debug_access+all -full64 +libext+.v+.sv -kdb
VCS_COMPILE_OPTS	+= -j8
VCS_COMPILE_OPTS	+= -sverilog -timescale=1ns/1ps
VCS_COMPILE_OPTS	+= -assert svaext
VCS_COMPILE_OPTS	+= +vcs+initreg+random
VCS_COMPILE_OPTS	+= +lint=PCWM,TFIPC
VCS_COMPILE_OPTS	+= +define+TLX_FWD_DATA_LO_WIDTH=$(TLX_FWD_DATA_LO_WIDTH)
VCS_COMPILE_OPTS	+= +define+TLX_REV_DATA_LO_WIDTH=$(TLX_REV_DATA_LO_WIDTH)

# RTL or GATE-LEVEL Simulation
ifeq ($(SIM_TYPE),RTL)
	VCS_COMPILE_OPTS	+= +define+IMPL_RTL
	VCS_COMPILE_OPTS	+= $(TOP_DIR)/inputs/design.v
	VCS_COMPILE_OPTS	+= -debug_region+cell+encrypt
	VCS_COMPILE_OPTS	+= +define+INTC_FUNCTIONAL
	VCS_COMPILE_OPTS	+= +define+INTC_MEM_NOXHANDLING
	VCS_COMPILE_OPTS	+= +define+INTC_SVA_OFF
	VCS_COMPILE_OPTS	+= +define+INTC_NO_PWR_PINS
	VCS_COMPILE_OPTS	+= +define+FUNCTIONAL
	VCS_COMPILE_OPTS	+= +define+INTCNOPWR
	VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/SRAM/SIM
	VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/StdCells/SIM
else
	VCS_COMPILE_OPTS	+= +define+IMPL_GATELEVEL
	VCS_COMPILE_OPTS	+= +define+SDF_ANNOTATION
	VCS_COMPILE_OPTS	+= +csdf+precompile
	VCS_COMPILE_OPTS	+= +overlap
	VCS_COMPILE_OPTS	+= +neg_tchk
	VCS_COMPILE_OPTS	+= -negdelay
	VCS_COMPILE_OPTS	+= +optconfigfile+config.cfg 
	VCS_COMPILE_OPTS	+= +define+INTC_MEM_NOXHANDLING
	VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/SRAM/ASIC/INTEL
	VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/StdCells/ASIC/INTEL
endif

# Check if GEN_PWR_SAIF exists and is set to True
ifeq ($(GEN_PWR_SAIF),True)
	VCS_COMPILE_OPTS	+= +define+GEN_PWR_SAIF
endif

# VCS_COMPILE_OPTS	+= +define+SDF_DELEY_SPEC=\"MAXIMUM\"

# VCS_COMPILE_OPTS	+= +define+SDF_TILE_PE    =\"/sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/outputs/Tile_PE.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TILE_MEM   =\"/sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/outputs/Tile_MemCore.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TILE_ARRAY =\"/sim/pohan/garnet_build/1203/17-tile_array/outputs/tile_array.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_GLB_TILE   =\"/sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_GLB_TOP    =\"/sim/pohan/garnet_build/1203/15-glb_top/outputs/glb_top.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TOP        =\"/sim/pohan/garnet_build/1203/31-cadence-innovus-signoff/outputs/design.sdf\"

# VCS_COMPILE_OPTS	+= +define+SDF_TILE_PE     =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/Tile_PE.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TILE_MEM    =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/Tile_MemCore.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TILE_ARRAY  =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/tile_array.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_GLB_TILE    =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/glb_tile.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_GLB_TOP     =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/glb_top.sdf\"
# VCS_COMPILE_OPTS	+= +define+SDF_TOP         =\"/sim/kkoul/build_gls/10-compile_design/netlist_tapeout/design.sdf\"


# CGRA Exclusion
ifeq ($(SOC_ONLY),True)
	VCS_COMPILE_OPTS	+= +define+NO_CGRA
endif

# JTAG or no JTAG Simulation
ifeq ($(TEST_VIEW),JTAG)
	VCS_COMPILE_OPTS	+= +define+JTAG
else
	VCS_COMPILE_OPTS	+= +define+NO_JTAG
endif

# ==============================================================================
# Compilation File Lists
# ------------------------------------------------------------------------------

# Testbench TopLevel File
TBENCH_FILE 			= 	tbench_files/Tbench.v
TO_GEN_FILE_LISTS		:=
AUTO_GEN_FILE_LISTS		:=
GATE_LEVEL_FILE_LISTS	:=

# File Lists to Generate
ifeq ($(SIM_TYPE),RTL)
	TO_GEN_FILE_LISTS		:= 	file-list-tbench.vc	\
								file-list-aha.vc	\
								file-list-cm3.vc	\
								file-list-cmsdk.vc	\
								file-list-arm_utils.vc	\
								file-list-garnet.vc
	AUTO_GEN_FILE_LISTS		:= 	file-list-nic.vc	\
								file-list-tlx.vc
	GATE_LEVEL_FILE_LISTS	:= 
else
	TO_GEN_FILE_LISTS		:=
	AUTO_GEN_FILE_LISTS		:= 	file-list-nic.vc	\
								file-list-tlx.vc
	GATE_LEVEL_FILE_LISTS	:= file-list-gatelevel-opal.vc
endif

# All File Lists
ALL_FILE_LISTS				:= $(foreach file,$(TO_GEN_FILE_LISTS),-f $(file))
ALL_FILE_LISTS				+= $(foreach file,$(AUTO_GEN_FILE_LISTS),-f $(file))
ALL_FILE_LISTS				+= $(foreach file,$(GATE_LEVEL_FILE_LISTS),-f $(file))

# ==============================================================================
# Targets
# ------------------------------------------------------------------------------

# NIC400 Interconnect File List
file-list-nic.vc:
	python $(TOP_DIR)/scripts/vc_expand_paths.py \
	$(ARM_IP_PATH)/logical/nic400_OnyxIntegration/nic400/verilog/nic400_OnyxIntegration.vc \
	$@

# TLX File List
file-list-tlx.vc:
	python $(TOP_DIR)/scripts/vc_expand_paths.py \
	$(ARM_IP_PATH)/logical/nic400_tlx_AhaIntegration/nic400/verilog/nic400_tlx_AhaIntegration.vc \
	$@

# Targets for File Lists to Generate
$(TO_GEN_FILE_LISTS): file-list-%.vc:
	AHA_IP_DIR=$(AHA_IP_PATH) ARM_IP_DIR=$(ARM_IP_PATH) \
	python $(TOP_DIR)/scripts/vc_expand_paths.py \
	$(TOP_DIR)/file_list_templates/file-list-$*.vc.tmpl $@

# Targets for Gate Level Simulation Filelist
$(GATE_LEVEL_FILE_LISTS): file-list-%.vc:
	AHA_IP_DIR=$(AHA_IP_PATH) ARM_IP_DIR=$(ARM_IP_PATH) \
	python $(TOP_DIR)/scripts/vc_expand_paths.py \
	$(TOP_DIR)/file_list_gatelevel_sim/file-list-$*.vc $@

# Compilation Target
compile: $(TO_GEN_FILE_LISTS) $(AUTO_GEN_FILE_LISTS) $(GATE_LEVEL_FILE_LISTS) $(TBENCH_FILE)
	vcs $(VCS_COMPILE_OPTS) $(ALL_FILE_LISTS) $(TBENCH_FILE) | tee SIM_compile.log
	cp -rf simv simv.daidir $(TOP_DIR)/outputs
