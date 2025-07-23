vlib work
vmap work work

vlog -sv +acc ParamCounter.sv ParamCounter_tb.sv

vsim -c ParamCounter_tb -do "run -all; quit"