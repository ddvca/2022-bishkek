iverilog -g2005-sv *.v
vvp a.out
gtkwave --dump dump.vcd --script xx_gtkwave.tcl
