vlib work
vlog *.v
vsim work.tb
add wave -radix bin sim:/tb/i_top/*
run -all
wave zoom full
