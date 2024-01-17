##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Name of Input File
#
##############################################################################
INPUT_FILE	= GarnetSOC_pad_frame.svp
INPUT_FILE_PY	= GarnetSOC_pad_frame.py

##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Name of Top Design Entry
#
##############################################################################
TOP_NAME		= GarnetSOC_pad_frame

##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Name of Top Design Entry
#
##############################################################################
ifdef include_core
  INCLUDE_CORE		= $(include_core)
else
  INCLUDE_CORE          = 1
endif

ifdef include_diff_clock_rx
  INCLUDE_DIFF_CLOCK_RX = $(include_diff_clock_rx)
else
  INCLUDE_DIFF_CLOCK_RX = 1
endif

##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Output Directory
#
##############################################################################
OUT_DIR 		?= .

##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Path Records
#
# Do not modify this section
##############################################################################
TARG_DIR 		:= $(abspath $(OUT_DIR))
CUR_DIR  		:= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))


################################################################################
#
# Entry Target
#
all: python

	################################################################################
	#
	# Genesis Run Target
	#
genesis:
	mkdir -p $(TARG_DIR) ; \
	cd $(TARG_DIR) ; \
	Genesis2.pl -parse -generate -top $(TOP_NAME) -input $(CUR_DIR)/$(INPUT_FILE) -parameter $(TOP_NAME).include_core=$(INCLUDE_CORE); \
	cd $(CUR_DIR)

python:
	mkdir -p $(TARG_DIR) ; \
	cd $(TARG_DIR) ; \
	python3 $(CUR_DIR)/$(INPUT_FILE_PY) --top $(TOP_NAME) --include_core $(INCLUDE_CORE) --include_diff_clock_rx $(INCLUDE_DIFF_CLOCK_RX); \
	cd $(CUR_DIR)