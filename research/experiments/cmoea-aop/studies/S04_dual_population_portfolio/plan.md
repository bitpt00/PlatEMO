# S04 Dual Population Portfolio Plan

## Goal

Study how operator portfolios interact with CMOEA-AOP's dual-population behavior.

## Scope

- Start only after S01 through S03 identify credible portfolio and controller choices.
- Keep dual-population changes isolated from unrelated reward or logging changes.
- Keep the original `CMOEA-AOP/` code unchanged.
- Put all experimental code in `CMOEA-AOP-Lab/`.

## Candidate Directions

- Separate portfolios for the two populations.
- Shared portfolio with population-specific credit.
- Stage-aware dual-population portfolio.
- Ablation that disables population-specific adaptation.

## Planned Outputs

- `runs.csv` for final metrics after runs exist.
- `checkpoints.csv` for process-level metrics after runs exist.
- `summary.md` for Codex execution notes and compact conclusions after runs exist.
