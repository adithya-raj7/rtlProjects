vlib work
vmap work work

vlog -sv +acc AsyncFifo.sv AsyncFifo_tb.sv

vsim -c AsyncFifo_tb -do "run -all; quit"