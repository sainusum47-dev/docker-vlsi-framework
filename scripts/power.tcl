read_liberty /data/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog /data/reports/synthesis/alu_netlist.v
link_design alu
read_sdc /data/constraints/alu.sdc
report_power
exit
