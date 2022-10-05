ARM_IP_PATH					:= $(abspath $(ARM_IP_DIR))
AHA_IP_PATH					:= $(abspath $(AHA_IP_DIR))
TOP_DIR 					:= $(abspath $(TOP_DIR))

# ==============================================================================
# VCS Options
# ------------------------------------------------------------------------------

# Linting Options
LINT_OPTS					= +lint=PCWM,TFIPC

# Compile Options
VCS_COMPILE_OPTS 			:= +v2k -noIncrComp -debug -full64 +libext+.v+.sv
VCS_COMPILE_OPTS			+= -sverilog -timescale=1ns/1ps
VCS_COMPILE_OPTS			+= $(LINT_OPTS)
VCS_COMPILE_OPTS			+= +define+TLX_FWD_DATA_LO_WIDTH=$(TLX_FWD_DATA_LO_WIDTH)
VCS_COMPILE_OPTS			+= +define+TLX_REV_DATA_LO_WIDTH=$(TLX_REV_DATA_LO_WIDTH)

# CGRA Exclusion
ifeq ($(SOC_ONLY),True)
	VCS_COMPILE_OPTS		+= +define+NO_CGRA
endif

# XGCD Exclusion
ifeq ($(INCLUDE_XGCD),False)
	VCS_COMPILE_OPTS		+= +define+NO_XGCD
endif

# SIM or ASIC Simulation
ifeq ($(IMPL_VIEW),ASIC)
	VCS_COMPILE_OPTS		+= +define+IMPL_ASIC
else
	VCS_COMPILE_OPTS		+= +define+IMPL_SIM
endif

# Process-Dependent Files
ifeq ($(IMPL_VIEW),ASIC)
	ifeq ($(PROCESS),TSMC)
		VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/SRAM/ASIC/TSMC
		VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/StdCells/ASIC/TSMC
	endif
	ifeq ($(PROCESS),GF)
		VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/SRAM/ASIC/GF
		VCS_COMPILE_OPTS	+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/StdCells/ASIC/GF
	endif
else
	VCS_COMPILE_OPTS		+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/SRAM/SIM
	VCS_COMPILE_OPTS		+= -y $(AHA_IP_PATH)/hardware/logical/ProcessTech/StdCells/SIM
endif

# Garnet RTL
VCS_COMPILE_OPTS			+= -v $(TOP_DIR)/inputs/design.v

# ==============================================================================
# Compilation File Lists
# ------------------------------------------------------------------------------

# Testbench TopLevel File
TBENCH_FILE 				= 	tbench_files/Tbench.v

# File Lists to Generate
TO_GEN_FILE_LISTS			:= 	file-list-tbench.vc	\
								file-list-aha.vc	\
								file-list-cm3.vc	\
								file-list-cmsdk.vc 	\
								file-list-arm_utils.vc \
								file-list-garnet.vc

# Generated File Lists
AUTO_GEN_FILE_LISTS			:= 	file-list-nic.vc		\
								file-list-tlx.vc

# All File Lists
ALL_FILE_LISTS				:= $(foreach file,$(TO_GEN_FILE_LISTS),-f $(file))
ALL_FILE_LISTS				+= $(foreach file,$(AUTO_GEN_FILE_LISTS),-f $(file))

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

# Compilation Target
compile: $(TO_GEN_FILE_LISTS) $(AUTO_GEN_FILE_LISTS) $(TBENCH_FILE)
	vcs $(VCS_COMPILE_OPTS) $(ALL_FILE_LISTS) $(TBENCH_FILE) | tee SIM_compile.log
	cp -rf simv simv.daidir $(TOP_DIR)/outputs
