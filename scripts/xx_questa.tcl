vlib work
vlog +incdir+.. ../*.sv
vsim -voptargs="+acc" work.tb
add wave -radix bin /tb/i_top/*
run -all
wave zoom full
