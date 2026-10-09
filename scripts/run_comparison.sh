#!/bin/bash
set -Eeuo pipefail

cd "$(dirname "$0")/.." || exit 1

run_variant() {
    local name="$1"
    local rtl="$2"
    local dest="results/$name"

    echo ""
    echo "========================================"
    echo "Running $name ALU: $rtl"
    echo "========================================"

    echo "$rtl" > /tmp/alu_source_rtl.txt

    RTL="$rtl" ./scripts/lint.sh
    RTL="$rtl" ./scripts/simulate.sh
    RTL="$rtl" ./scripts/synth.sh

    ./scripts/timing.sh

    docker run --rm -i \
        -v "$PWD:/data" \
        openroad/opensta \
        < scripts/power.tcl \
        > reports/timing/power.txt

    docker run --rm --user "$(id -u):$(id -g)" \
        -v "$PWD:/workspace" \
        vlsi-rtl-framework \
        python3 /workspace/scripts/ppa_report.py

    # Save this run's reports separately.
    mkdir -p "$dest"/{lint,simulation,synthesis,timing,ppa,rtl}

    cp reports/lint/lint.log "$dest/lint/lint.log"
    cp reports/simulation/sim.log "$dest/simulation/sim.log"

    cp reports/synthesis/synth.log "$dest/synthesis/synth.log"
    cp reports/synthesis/alu_stat.txt "$dest/synthesis/alu_stat.txt"
    cp reports/synthesis/alu_netlist.v "$dest/synthesis/alu_netlist.v"

    cp reports/timing/timing.txt "$dest/timing/timing.txt"
    cp reports/timing/power.txt "$dest/timing/power.txt"
    cp reports/ppa/ppa_report.txt "$dest/ppa/ppa_report.txt"

    cp "$rtl" "$dest/rtl/"

    echo "$rtl" > "$dest/source_rtl.txt"

    echo ""
    echo "Saved $name results to $dest"
    cat "$dest/ppa/ppa_report.txt"
}

run_variant baseline rtl/alu.v
run_variant optimized rtl/alu_optimized.v

echo ""
echo "========================================"
echo "COMPARING FRESHLY GENERATED RESULTS"
echo "========================================"

python3 scripts/compare_ppa.py

echo ""
echo "COMPARISON WORKFLOW COMPLETE"
