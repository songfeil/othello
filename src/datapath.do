# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in alu.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns datapath.v enableonce.v


# Load simulation using alu as the top level simulation module.
vsim datapath

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#   input turn_side, move_up, move_down, move_left, move_right, plot_empty, plot_box, place_disk,
#	input resetn,
#	input clk,

force {resetn} 1 0, 0 15
force {clock} 0 0, 1 10 -r 20
#force {resetn}

force {turn_side} 0 0
force {move_up} 0 0
force {move_down} 0 0
force {move_left} 0 0
force {move_right} 0 0
force {plot_empty} 0 0
force {plot_box} 0 0
force {place_disk} 0 0
force {move_down} 1 25, 0 65
force {move_down} 1 95, 0 150
force {turn_side} 1 65, 0 200
force {plot_box} 1 200, 0 300

run 500ns