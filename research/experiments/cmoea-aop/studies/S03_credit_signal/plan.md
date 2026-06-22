# S03 Credit Signal Plan

## Goal

Isolate which reward or credit signal provides useful feedback for operator selection.

## Scope

- Start after S01 and any required controller scaffolding are stable.
- Keep reward or credit-signal changes separate from unrelated controller changes.
- Keep the original `CMOEA-AOP/` code unchanged.
- Put all signal variants in `CMOEA-AOP-Lab/`.

## Candidate Directions

- Feasibility-improvement credit.
- Objective-progress credit.
- Diversity-preservation credit.
- Composite credit with explicit ablation.

## Planned Outputs

- `runs.csv` for final metrics after runs exist.
- `checkpoints.csv` for process-level metrics after runs exist.
- `summary.md` for Codex execution notes and compact conclusions after runs exist.
