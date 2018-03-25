# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in alu.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns board_ram.v


# Load simulation using alu as the top level simulation module.
vsim board_ram

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {resetn} 0 0ns
force {clock} 0 0ns, 1 10ns -r 20ns
force {resetn} 1 5ns, 0 15ns
force {x} 10#2 0
force {y} 10#4 0
force {side} 2#10 0
force {detecten} 0 0ns
force {detecten} 1 35ns, 0 100ns

force {writeen} 0 0ns
force {writeen} 1 105ns, 0 200ns

run 300ns