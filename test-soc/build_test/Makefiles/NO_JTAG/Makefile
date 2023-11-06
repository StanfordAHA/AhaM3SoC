TEST_DIR 		:= $(abspath $(ARM_IP_DIR)/software/testcodes/$(TESTNAME))
PARENT_DIR 		:= $(abspath $(TOP_DIR))

all: ROM_IMAGE

ROM_IMAGE:
	cd $(TEST_DIR) ; \
	$(MAKE)
	od -v -A n -t x4 --width=4 $(TEST_DIR)/$(TESTNAME).bin > $(PARENT_DIR)/outputs/ROM.hex
	cd $(TEST_DIR) ; \
	$(MAKE) clean
