#!/bin/bash
# Run OpenSTA on the synthesized ALU netlist and summarize the result.

cd "$(dirname "$0")/.." || exit 1

IMAGE=openroad/opensta
OUT=reports/timing
NETLIST=reports/synthesis/alu_netlist.v

mkdir -p $OUT

if [ ! -f "$NETLIST" ]; then
    echo "Missing $NETLIST - run ./scripts/synth.sh first"
    echo "TIMING STATUS: FAIL"
    exit 1
fi

echo "Running OpenSTA..."
docker run --rm -i -v "$PWD:/data" $IMAGE < scripts/timing.tcl > $OUT/timing.txt 2>&1

DELAY=$(grep "data arrival time" $OUT/timing.txt | head -1 | awk '{print $1}')
SLACK=$(grep "slack (" $OUT/timing.txt | head -1 | awk '{print $1}')

if [ -z "$DELAY" ] || [ -z "$SLACK" ]; then
    echo "Could not read timing results - see $OUT/timing.txt"
    echo "TIMING STATUS: FAIL"
    exit 1
fi

echo "--------------------------------"
echo "Critical path (ns) : $DELAY"
echo "Worst slack (ns)   : $SLACK"
echo "Full report        : $OUT/timing.txt"

if grep -q "VIOLATED" $OUT/timing.txt; then
    echo "TIMING STATUS: VIOLATED"
    exit 1
else
    echo "TIMING STATUS: MET"
    exit 0
fi
