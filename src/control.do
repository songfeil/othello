# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in alu.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns placeChess.v


# Load simulation using alu as the top level simulation module.
vsim control

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#    input clk,
#   input resetn,
#    input go,
#	input start,
force {go} 0 0
force {move_up} 0 0
force {move_down} 0 0
force {move_left} 0 0
force {move_right} 0 0
force {win} 0 0
force {place} 0 0
force {restart} 0 0, 1 15
force {clk} 0 0, 1 10 -r 20
force {go} 1 35, 0 55
force {move_up} 1 95, 0 115
force {place} 1 130, 0 180

run 400ns