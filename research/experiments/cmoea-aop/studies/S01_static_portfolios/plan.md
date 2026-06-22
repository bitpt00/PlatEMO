# S01 Static Portfolios Plan

## Goal

Test whether fixed, staged, or random operator portfolios can explain part of the baseline CMOEA-AOP performance before adding adaptive controller complexity.

## Scope

- Use the original `CMOEA-AOP/` directory only as the baseline reference.
- Put all experimental MATLAB code in `CMOEA-AOP-Lab/`.
- Do not create result files until discovery runs have been executed.

## Candidate Variants

- Fixed uniform operator portfolio.
- Fixed biased portfolios based on baseline operator usage hypotheses.
- Random portfolio sampled per generation or checkpoint.
- Simple staged portfolio that changes ratios across early, middle, and late search.

## Planned Outputs

- `runs.csv` for final metrics after runs exist.
- `checkpoints.csv` for process-level metrics after runs exist.
- `summary.md` for Codex execution notes and compact conclusions after runs exist.
