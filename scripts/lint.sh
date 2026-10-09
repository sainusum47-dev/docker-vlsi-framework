#!/bin/bash
# Run Verilator lint on the ALU inside Docker and save a report.

cd "$(dirname "$0")/.." || exit 1

IMAGE=vlsi-rtl-framework
RTL=${RTL:-rtl/alu.v}
LOG=reports/lint/lint.log

mkdir -p reports/lint

echo "Running Verilator lint..."
docker run --rm -v "$PWD:/workspace" $IMAGE \
    verilator --lint-only -Wall /workspace/$RTL > "$LOG" 2>&1
RC=$?

WARNINGS=$(grep -c "^%Warning" "$LOG")
ERRORS=$(grep "^%Error" "$LOG" | grep -vc "Exiting due to")

cat "$LOG"
echo "--------------------------------"
echo "Warnings: $WARNINGS"
echo "Errors  : $ERRORS"

if [ "$RC" -eq 0 ]; then
    echo "LINT STATUS: PASS"
    exit 0
else
    echo "LINT STATUS: FAIL"
    exit 1
fi
