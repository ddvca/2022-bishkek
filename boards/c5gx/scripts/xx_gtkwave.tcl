# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb.clk
lappend all_signals tb.key
lappend all_signals tb.sw
lappend all_signals tb.i_top.led
lappend all_signals tb.i_top.ledg
lappend all_signals tb.i_top.hex0
lappend all_signals tb.i_top.hex1
lappend all_signals tb.i_top.hex2
lappend all_signals tb.i_top.hex3
lappend all_signals tb.i_top.gpio

source xx_gtkwave_extra.tcl

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
