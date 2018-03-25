# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in alu.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns enableonce.v


# Load simulation using alu as the top level simulation module.
vsim enableonce

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {resetn} 0 0ns
force {clock} 0 0ns, 1 10ns -r 20ns
force {resetn} 1 5ns, 0 15ns
force {enable} 0 0ns
force {enable} 1 25ns, 0 9000ns
force {enable} 1 10000ns, 0 15300ns

run 22500ns