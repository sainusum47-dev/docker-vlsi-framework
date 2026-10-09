#!/bin/bash
# Synthesize the ALU with Yosys onto Sky130 cells; save stats and netlist.

cd "$(dirname "$0")/.." || exit 1

IMAGE=vlsi-rtl-framework
RTL=${RTL:-rtl/alu.v}
OUT=reports/synthesis
LIB=lib/sky130_fd_sc_hd__tt_025C_1v80.lib

mkdir -p $OUT

if [ ! -f "$LIB" ]; then
    echo "Missing $LIB"
    echo "SYNTHESIS STATUS: FAIL"
    exit 1
fi

echo "Running Yosys synthesis (Sky130)..."
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/workspace" $IMAGE \
    yosys -q -l /workspace/$OUT/synth.log -p "
        read_verilog /workspace/$RTL
        synth -top alu
        abc -liberty /workspace/$LIB
        opt_clean
        tee -o /workspace/$OUT/alu_stat.txt stat -liberty /workspace/$LIB
        write_verilog -noattr /workspace/$OUT/alu_netlist.v
    " || { echo "SYNTHESIS STATUS: FAIL"; exit 1; }

CELLS=$(grep "Number of cells" $OUT/alu_stat.txt | awk '{print $NF}')
AREA=$(grep "Chip area" $OUT/alu_stat.txt | awk '{print $NF}')
FFS=$(grep -c "__dfxtp\|__dfrtp\|__dlxtp" $OUT/alu_stat.txt)

echo "--------------------------------"
echo "Total cells  : $CELLS"
echo "Area (um^2)  : $AREA"
echo "Flip-flops   : $FFS"
echo "Netlist      : $OUT/alu_netlist.v"
echo "SYNTHESIS STATUS: PASS"
