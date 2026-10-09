# Virtual clock: 12 ns period. No clock port exists in the combinational ALU.
create_clock -name vclk -period 12
set_input_delay  0 -clock vclk [all_inputs]
set_output_delay 0 -clock vclk [all_outputs]
