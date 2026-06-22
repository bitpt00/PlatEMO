# CMOEA-AOP Research Plan

This file is the long-term route map for mechanism-decomposition experiments around CMOEA-AOP.

## Scope

S00_directory_setup establishes the workspace only. It does not modify algorithm code and does not run experiments.

The baseline implementation remains unchanged:

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/
```

Experimental variants belong in the lab sandbox:

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP-Lab/
```

Study plans, run summaries, and analysis notes belong under:

```text
research/experiments/cmoea-aop/studies/
```

Large raw local outputs belong under:

```text
research/experiments/cmoea-aop/results/
```

## Operating Rules

- Preserve `CMOEA-AOP/` as the baseline implementation.
- Put variant code in `CMOEA-AOP-Lab/`.
- Keep each mechanism question in its own study directory.
- Create `runs.csv`, `checkpoints.csv`, and `summary.md` only after real experiment data exists.
- Keep raw `.mat`, logs, seed outputs, and full population files in `results/`.
- Commit plans, scripts, compact summaries, and necessary figures; do not commit large raw outputs.

## Study Roadmap

| Study | Purpose | Status | Current output |
| --- | --- | --- | --- |
| S00_directory_setup | Establish the long-term workspace and planning files. | Complete | `RESEARCH_PLAN.md`, `studies/`, `CMOEA-AOP-Lab/` |
| S01_static_portfolios | Test whether simple fixed or random operator portfolios explain part of CMOEA-AOP's benefit. | Planned | `studies/S01_static_portfolios/plan.md` |
| S02_controller_family | Compare lightweight controller families after the static portfolio baselines are understood. | Planned | `studies/S02_controller_family/plan.md` |
| S03_credit_signal | Isolate which reward or credit signal best supports operator selection. | Planned | `studies/S03_credit_signal/plan.md` |
| S04_dual_population_portfolio | Study interactions between dual-population behavior and operator portfolios. | Planned | `studies/S04_dual_population_portfolio/plan.md` |

## Next Step

After S00 is reviewed, start:

```text
S01_static_portfolios implementation and discovery runs
```

That step should create only the MATLAB code and result files needed for the S01 study.
