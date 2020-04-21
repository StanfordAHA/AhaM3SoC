ARM_IP_PATH	:= $(abspath $(ARM_IP_DIR))
AHA_IP_PATH := $(abspath $(AHA_IP_DIR))
CUR_DIR 		:= $(abspath .)

# VCS Options
LINT_OPT	:= +lint=PCWM,TFIPC
VCS_COMPILE_OPTS 	:= +v2k -noIncrComp -debug -full64 +libext+.v+.sv -sverilog -timescale=1ns/1ps $(LINT_OPT)

ifeq ($(SOC_ONLY),True)
	VCS_COMPILE_OPTS += +define+NO_CGRA
endif

VCS_COMPILE_OPTS += +define+CGRA_RD_WS=$(CGRA_RD_WS)

# Testbench File
TBENCH_FILE 			:= tbench_files/Tbench.v

# Design Files
TO_GEN_FILE_LISTS		:= file-list-tbench.vc file-list-aha.vc file-list-cm3.vc \
											 file-list-cmsdk.vc file-list-arm_utils.vc file-list-garnet.vc
AUTO_GEN_FILE_LISTS	:= file-list-nic.vc file-list-dma.vc file-list-tlx.vc

# Top Design
TOP_DESIGN 	:= $(AHA_IP_DIR)/hardware/logical/AhaGarnetSoC/verilog/AhaGarnetSoC.v

# All File Lists
ALL_FILE_LISTS := $(foreach file,$(TO_GEN_FILE_LISTS),-f $(file))
ALL_FILE_LISTS += $(foreach file,$(AUTO_GEN_FILE_LISTS),-f $(file))

compile: $(TO_GEN_FILE_LISTS) $(AUTO_GEN_FILE_LISTS)
	vcs $(VCS_COMPILE_OPTS) $(ALL_FILE_LISTS)  $(TBENCH_FILE) | tee vcs_compile.log
	cp -rf simv simv.daidir outputs/

file-list-nic.vc:
	./vc_expand_paths.py $(ARM_IP_PATH)/logical/nic400_AhaIntegration/nic400/verilog/nic400_AhaIntegration.vc $@

file-list-dma.vc:
	./vc_expand_paths.py $(ARM_IP_PATH)/logical/DMA330_AhaIntegration/logical/pl330_dma_AhaIntegration/pl330_dma_AhaIntegration/verilog/files.vc $@

file-list-tlx.vc:
	./vc_expand_paths.py $(ARM_IP_PATH)/logical/nic400_tlx_AhaIntegration/nic400/verilog/nic400_tlx_AhaIntegration.vc $@

$(TO_GEN_FILE_LISTS): file-list-%.vc:
	AHA_IP_DIR=$(AHA_IP_PATH) ARM_IP_DIR=$(ARM_IP_PATH) \
	./vc_expand_paths.py file_list_templates/file-list-$*.vc.tmpl $@
