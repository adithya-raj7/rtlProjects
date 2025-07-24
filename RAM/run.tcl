vlib work
vmap work work

vlog -sv +acc DualPortRAM.sv DualPortRAM_tb.sv

vsim -c DualPortRAM_tb -do "run -all; quit"