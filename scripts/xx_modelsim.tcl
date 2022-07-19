vlib work
vlog *.v
vsim work.testbench
add wave -radix bin sim:/testbench/i_top/*
run -all
wave zoom full
