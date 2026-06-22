# S02 Controller Family Plan

## Goal

Compare lightweight controller families after S01 establishes static and random portfolio baselines.

## Scope

- Build only on evidence from S01.
- Keep the original `CMOEA-AOP/` code unchanged.
- Put controller-family variants in `CMOEA-AOP-Lab/`.
- Do not run this study until S01 has enough summary data.

## Candidate Directions

- Rule-based stage controller.
- Bandit-style controller.
- Credit-smoothed adaptive controller.
- Minimal learned controller, if justified by S01.

## Planned Outputs

- `runs.csv` for final metrics after runs exist.
- `checkpoints.csv` for process-level metrics after runs exist.
- `summary.md` for Codex execution notes and compact conclusions after runs exist.
