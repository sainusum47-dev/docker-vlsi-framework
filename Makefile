	.RECIPEPREFIX = >
.PHONY: all lint sim synth timing power ppa compare clean

all: compare-flow

compare-flow:
> ./scripts/run_comparison.sh

lint:
> ./scripts/lint.sh

sim:
> ./scripts/simulate.sh

synth:
> ./scripts/synth.sh

timing: synth
> ./scripts/timing.sh

power: synth
> docker run --rm -i -v "$(CURDIR):/data" openroad/opensta < scripts/power.tcl > reports/timing/power.txt

ppa: sim lint timing power
> docker run --rm --user "$$(id -u):$$(id -g)" -v "$(CURDIR):/workspace" vlsi-rtl-framework python3 /workspace/scripts/ppa_report.py

compare:
> python3 scripts/compare_ppa.py

clean:
> rm -f alu_sim reports/simulation/sim.log reports/lint/lint.log
> rm -f reports/synthesis/synth.log reports/synthesis/alu_stat.txt reports/synthesis/alu_netlist.v
> rm -f reports/timing/timing.txt reports/timing/power.txt reports/ppa/ppa_report.txt
> rm -f reports/ppa/comparison_report.txt
