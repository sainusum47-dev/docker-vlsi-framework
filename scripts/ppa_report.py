#!/usr/bin/env python3
"""Combine simulation, lint, synthesis, timing and power results into one PPA report."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def read(rel):
    f = ROOT / rel
    if not f.exists():
        sys.exit(f"Missing {rel} - run the earlier scripts first")
    return f.read_text()


def find(pattern, text, what):
    m = re.search(pattern, text, re.M)
    if not m:
        sys.exit(f"Could not find {what}")
    return m


sim = read("reports/simulation/sim.log")
lint = read("reports/lint/lint.log")
stat = read("reports/synthesis/alu_stat.txt")
timing = read("reports/timing/timing.txt")
power = read("reports/timing/power.txt")

total = int(find(r"TOTAL TESTS\s*:\s*(\d+)", sim, "total tests").group(1))
passed = int(find(r"PASSED\s*:\s*(\d+)", sim, "passed tests").group(1))
failed = int(find(r"FAILED\s*:\s*(\d+)", sim, "failed tests").group(1))

lint_warn = len(re.findall(r"^%Warning", lint, re.M))
lint_err = len(re.findall(r"^%Error", lint, re.M))

cells = int(find(r"Number of cells:\s+(\d+)", stat, "cell count").group(1))
area = float(find(r"Chip area.*:\s+([\d.]+)", stat, "chip area").group(1))

delay = float(find(r"^\s*(-?[\d.]+)\s+data arrival time", timing, "arrival time").group(1))
slack_m = find(r"^\s*(-?[\d.]+)\s+slack \((\w+)\)", timing, "slack")
slack = float(slack_m.group(1))
slack_state = slack_m.group(2)

pm = find(r"^Total\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)", power, "total power")
power_mw = float(pm.group(4)) * 1000

lint_status = "PASS" if lint_warn == 0 and lint_err == 0 else "FAIL"
sim_status = "PASS" if failed == 0 and passed == total else "FAIL"

report = f"""================================
       ALU PPA REPORT
================================

Functional Verification
Tests Passed : {passed}
Tests Failed : {failed}
Status       : {sim_status}

Lint
Warnings     : {lint_warn}
Errors       : {lint_err}
Status       : {lint_status}

Synthesis (Sky130 HD, tt 25C 1.8V)
Cell Count   : {cells}
Area         : {area:.2f} um^2

Timing (pre-layout, ideal clock)
Critical Path: {delay:.2f} ns
Slack        : {slack:.2f} ns ({slack_state})

Power (estimate, default activity)
Estimated    : {power_mw:.3f} mW

================================
"""

out = ROOT / "reports" / "ppa" / "ppa_report.txt"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(report)
print(report)
