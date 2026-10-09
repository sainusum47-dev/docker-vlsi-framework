#!/usr/bin/env bash

set -o pipefail

cd "$(dirname "$0")/.." || exit 1

IMAGE=vlsi-rtl-framework
RTL=${RTL:-rtl/alu.v}
TB=${TB:-tb/alu_tb.v}
LOG=reports/simulation/sim.log

mkdir -p reports/simulation waveforms

echo "[1/2] Compiling RTL and testbench..."

if ! docker run --rm -v "$PWD:/workspace" "$IMAGE" \
    iverilog -o /workspace/alu_sim \
    "/workspace/$RTL" "/workspace/$TB"; then
    echo "SIMULATION STATUS: FAIL (compilation failed)"
    exit 1
fi

echo "[2/2] Running simulation..."

if ! docker run --rm -w /workspace/tb -v "$PWD:/workspace" "$IMAGE" \
    /workspace/alu_sim 2>&1 | tee "$LOG"; then
    echo "SIMULATION STATUS: FAIL (simulator error)"
    exit 1
fi

if ! grep -Eq 'TOTAL TESTS[[:space:]]*:[[:space:]]*[0-9]+' "$LOG"; then
    echo "SIMULATION STATUS: FAIL (test summary missing)"
    exit 1
fi

if ! grep -Eq 'FAILED[[:space:]]*:[[:space:]]*0([[:space:]]|$)' "$LOG"; then
    echo "SIMULATION STATUS: FAIL (one or more tests failed)"
    exit 1
fi

if ! grep -q 'ALU TEST COMPLETED' "$LOG"; then
    echo "SIMULATION STATUS: FAIL (simulation incomplete)"
    exit 1
fi

echo "SIMULATION STATUS: PASS"
exit 0
