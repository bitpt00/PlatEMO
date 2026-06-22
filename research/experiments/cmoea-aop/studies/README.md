# CMOEA-AOP Studies

This directory separates mechanism-decomposition experiments into small, reviewable studies.

## Study Contract

Each study should eventually use this layout:

```text
plan.md
runs.csv
checkpoints.csv
summary.md
```

For S00, only `plan.md` files are created. `runs.csv`, `checkpoints.csv`, and `summary.md` should be created when real runs exist.

## Studies

| Study | Focus | Plan |
| --- | --- | --- |
| S01_static_portfolios | Static and random operator portfolios. | `S01_static_portfolios/plan.md` |
| S02_controller_family | Alternative lightweight controller families. | `S02_controller_family/plan.md` |
| S03_credit_signal | Reward and credit-signal variants. | `S03_credit_signal/plan.md` |
| S04_dual_population_portfolio | Dual-population and portfolio interactions. | `S04_dual_population_portfolio/plan.md` |

## Recording Rules

- Keep experimental design in `plan.md`.
- Keep final per-run metrics in `runs.csv`.
- Keep process checkpoints in `checkpoints.csv`.
- Keep Codex execution notes and compact conclusions in `summary.md`.
- Keep large raw files under `../results/`.
- Do not modify `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/`.
