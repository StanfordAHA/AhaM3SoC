TARGET_FOLDER			= temp
RDL_FILE				= platform_ctrl.rdl
ORDT_TOOL				= ./ordt/Ordt.jar
ORDT_PARAM_FILE			= ./ordt/params.txt
ORDT_TARG_LANG			= -verilog

rtl: $(TARGET_FOLDER)
	@(echo "Generated ${TARGET_FOLDER} RTL folder")

$(TARGET_FOLDER): $(RDL_FILE)
	java -jar $(ORDT_TOOL) -parms $(ORDT_PARAM_FILE) $(ORDT_TARG_LANG) $(TARGET_FOLDER)/ $(RDL_FILE)

html: $(RDL_FILE)
	python gen_html.py  $(RDL_FILE)

clean:
	rm -rf $(TARGET_FOLDER) html
