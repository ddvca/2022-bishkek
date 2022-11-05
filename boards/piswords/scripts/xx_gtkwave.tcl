# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb.clk
lappend all_signals tb.key
lappend all_signals tb.sw
lappend all_signals tb.i_top.led
lappend all_signals tb.i_top.abcdefgh
lappend all_signals tb.i_top.digit

# If this signal is not commented out and is not used, it makes annoying sound
# lappend all_signals tb.i_top.buzzer

lappend all_signals tb.i_top.vsync
lappend all_signals tb.i_top.hsync
lappend all_signals tb.i_top.rgb

source xx_gtkwave_extra.tcl

set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
