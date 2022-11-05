rd /s /q run
mkdir run
cd run

iverilog -g2005-sv -I .. ../*.sv
vvp a.out
gtkwave --dump dump.vcd --script ../xx_gtkwave.tcl
