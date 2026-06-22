# S01 Static Portfolios Plan

## Goal

Separate the effect of using multiple offspring operators from the effect of DDPG learning the operator ratios in CMOEA-AOP.

The first question is not whether a new variant beats CMOEA-AOP. The first question is whether a simpler portfolio policy can explain much of the observed behavior.

## Code Boundary

- Keep `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/` unchanged.
- Implement S01 variants in `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP-Lab/`.
- Use one parameterized lab algorithm instead of copying one algorithm file per policy.
- Store raw `.mat` outputs under `research/experiments/cmoea-aop/results/`.
- Write compact final metrics to this study directory.

## Policies

Baseline algorithms:

| Label | Meaning |
| --- | --- |
| EMCMO | Original EMCMO with GA offspring generation. |
| CMOEA-AOP | Original DDPG-based CMOEA-AOP. |

Static lab policies:

| Label | GA/SBX | DE/rand/1 | DE/best/1 | Purpose |
| --- | ---: | ---: | ---: | --- |
| GA-only | 1.00 | 0.00 | 0.00 | Reproduce single GA-style portfolio. |
| DE-rand-only | 0.00 | 1.00 | 0.00 | Reproduce single DE/rand/1 portfolio. |
| DE-best-only | 0.00 | 0.00 | 1.00 | Reproduce single DE/best/1 portfolio. |
| Equal-AOP | 0.33 | 0.33 | 0.33 | Test whether multi-operator coexistence alone is enough. |
| GA-heavy | 0.60 | 0.20 | 0.20 | Test GA/SBX-biased fixed portfolio. |
| DE-rand-heavy | 0.20 | 0.60 | 0.20 | Test exploration-biased fixed portfolio. |
| DE-best-heavy | 0.20 | 0.20 | 0.60 | Test convergence-biased fixed portfolio. |
| GA+DE-rand | 0.50 | 0.50 | 0.00 | Test two-operator static portfolio. |
| GA+DE-best | 0.50 | 0.00 | 0.50 | Test two-operator static portfolio. |
| DE-rand+DE-best | 0.00 | 0.50 | 0.50 | Test two-DE static portfolio. |

Dynamic non-DDPG policies are implemented only as a second batch:

| Label | Purpose |
| --- | --- |
| Random-AOP | Test whether random ratio diversity explains the effect. |
| Stage-AOP | Test whether DDPG mainly learns an early/middle/late schedule. |
| Survival-Credit-AOP | Test whether immediate offspring survival feedback is enough. |

## Test Sets

Smoke test:

| Problem | Reason |
| --- | --- |
| CF1 | Simple constrained CF check. |
| LIRCMOP1 | LIR-CMOP path and feasibility check. |
| DASCMOP1 | DAS-CMOP path and constraint check. |

Discovery set:

| Problem | Reason |
| --- | --- |
| CF2 | Used in the paper motivation for operator-portfolio differences. |
| CF6 | Used in paper convergence-profile discussion. |
| CF9 | Used in the paper motivation for operator-portfolio differences. |
| LIRCMOP3 | Difficult constrained case from protocol. |
| LIRCMOP4 | Difficult constrained case from protocol. |
| LIRCMOP12 | Narrow/separated feasible regions in paper figures. |
| DASCMOP1 | First DAS-CMOP sanity case. |
| DASCMOP8 | Paper visualization case. |

Confirmation set:

Use all 33 paper problems only if the smoke and discovery runs reveal a mechanism worth confirming.

## Run Sizes

| Stage | N | maxFE | Seeds |
| --- | ---: | ---: | ---: |
| smoke | 100 | 5000 | 1 |
| discovery-fast | 100 | 20000 | 3 |
| discovery-main | 100 | 50000 | 5 |
| confirmation | 100 | 100000 | 30 |

Start with smoke. Do not launch discovery until all policies produce valid output files.

## Parallel MATLAB Rule

Multiple MATLAB processes are allowed. Each worker must run a disjoint task partition and write independent `.mat` files. Do not let multiple workers append to the same CSV.

Use worker-specific logs and summarize after all workers finish.

## Planned Outputs

- `runs.csv`: compact final metrics after runs exist.
- `summary.md`: Codex execution notes and early interpretation after runs exist.
- `checkpoints.csv`: add later if we need generation-level trajectory analysis.
