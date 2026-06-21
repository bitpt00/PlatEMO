# CMOEA-AOP Experiment Protocol

## Goal

Use CMOEA-AOP as the first controlled case for testing research modifications in PlatEMO.

## Baseline

Keep the original implementation unchanged:

```text
PlatEMO\Algorithms\Multi-objective optimization\CMOEA-AOP
```

Create modified variants in separate directories.

## First Reproduction Scope

Start with a smoke test:

- CF1
- LIRCMOP1
- DASCMOP1

Then reproduce a small benchmark subset before running the full paper-scale suite:

- CF1, CF6, CF9
- LIRCMOP3, LIRCMOP4, LIRCMOP12
- DASCMOP8

Paper-scale reference setting from the local paper card:

- population size: 100;
- maximum function evaluations: 100000;
- independent runs: 30;
- metric: IGD;
- statistical test: Wilcoxon rank-sum test at 0.05.

## Environment Checks

Record before long runs:

- MATLAB version;
- Deep Learning Toolbox availability;
- current git commit;
- random seed policy;
- PlatEMO version;
- changed algorithm files.

## Result Policy

Raw result files stay in `results/` and are ignored by git. Commit only:

- protocol changes;
- configs;
- scripts;
- compact summaries;
- final tables and figures needed for review.
