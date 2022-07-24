# User config
set ::env(DESIGN_NAME) snail_moore_fsm_sv

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.sv]

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

# Added area (does not synthesize otherwise)
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) {0 0 100 100}
