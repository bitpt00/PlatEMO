# S01 Static Portfolios Summary

## Current Status

S01 smoke implementation and validation are complete.

Implemented scope:

- One parameterized lab algorithm: `CMOEA_AOP_Lab`.
- Static policies for single operators, equal three-operator portfolio, heavy fixed portfolios, and two-operator portfolios.
- Dynamic non-DDPG policies are scaffolded for later: Random-AOP, Stage-AOP, and Survival-Credit-AOP.
- Raw result files are written under `research/experiments/cmoea-aop/results/S01_static_portfolios/`.
- Tabular smoke results are written to `runs.csv` in this directory.

## Execution Notes

- Smoke matrix: 12 algorithms x 3 problems x 1 run = 36 tasks.
- Smoke settings: `N = 100`, `maxFE = 5000`, metrics = IGD, HV, Feasible_rate.
- Problems: CF1, LIRCMOP1, DASCMOP1.
- All 36 smoke tasks completed with status `ok`.
- Four MATLAB workers were used successfully with disjoint task partitions.
- The original CMOEA-AOP implementation was not modified.

## Smoke Sanity Check

These are low-budget single-run checks for pipeline validation only, not scientific conclusions.

| Problem | Best non-NaN IGD entries |
| --- | --- |
| CF1 | CMOEA-AOP 0.0290; DE-rand-only 0.0384; GA+DE-rand 0.0437 |
| DASCMOP1 | CMOEA-AOP 0.6636; Equal-AOP 0.7324; DE-best-heavy 0.7370 |
| LIRCMOP1 | GA+DE-rand 0.1967; DE-rand-heavy 0.2458; GA+DE-best 0.2733 |

LIRCMOP1 already shows a useful warning sign for the next phase: some fixed portfolios produced no feasible final solutions, so later analysis should separate feasibility discovery from objective convergence.
