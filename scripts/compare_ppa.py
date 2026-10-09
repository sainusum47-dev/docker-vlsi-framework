from pathlib import Path
import re

BASE = Path("results/baseline/ppa/ppa_report.txt")
OPT = Path("results/optimized/ppa/ppa_report.txt")
OUT = Path("reports/ppa/comparison_report.txt")

def read_report(path):
    text = path.read_text()
    patterns = {
        "cells": r"Cell Count\s*:\s*(\d+)",
        "area": r"Area\s*:\s*([\d.]+)",
        "delay": r"Critical Path:\s*([\d.]+)",
        "slack": r"Slack\s*:\s*([-\d.]+)",
        "power": r"Estimated\s*:\s*([\d.]+)",
        "passed": r"Tests Passed\s*:\s*(\d+)",
        "failed": r"Tests Failed\s*:\s*(\d+)",
    }
    data = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, text)
        if not match:
            raise ValueError(f"Missing {key} in {path}")
        data[key] = float(match.group(1))
    return data

baseline = read_report(BASE)
optimized = read_report(OPT)

def reduction(old, new):
    return (old - new) / old * 100 if old else 0

lines = [
    "BASELINE vs OPTIMIZED ALU",
    "=" * 34,
    f"Cell count: {baseline['cells']:.0f} -> {optimized['cells']:.0f} "
    f"({reduction(baseline['cells'], optimized['cells']):.2f}% reduction)",
    f"Area: {baseline['area']:.2f} -> {optimized['area']:.2f} um^2 "
    f"({reduction(baseline['area'], optimized['area']):.2f}% reduction)",
    f"Critical path: {baseline['delay']:.2f} -> {optimized['delay']:.2f} ns "
    f"({reduction(baseline['delay'], optimized['delay']):.2f}% reduction)",
    f"Slack: {baseline['slack']:.2f} -> {optimized['slack']:.2f} ns",
    f"Estimated power: {baseline['power']:.3f} -> {optimized['power']:.3f} mW "
    f"({reduction(baseline['power'], optimized['power']):.2f}% reduction)",
    f"Functional tests: {baseline['passed']:.0f} -> {optimized['passed']:.0f} passed",
    f"Failed tests: {baseline['failed']:.0f} -> {optimized['failed']:.0f}",
    "",
    "Note: Power is an estimate using the configured default activity.",
    "Timing is pre-layout and depends on the applied constraints.",
]

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text("\n".join(lines) + "\n")
print("\n".join(lines))
print(f"\nSaved report: {OUT}")
