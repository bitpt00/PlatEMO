# CMOEA-AOP Experiment Entry

This is the fixed GitHub entry for GPT review and Codex execution.

## Read First

1. Experiment protocol: `protocol.md`
2. Baseline notes: `baseline_reproduction.md`
3. Candidate ideas: `variant_ideas.md`
4. Knowledge-base entry: `../../../knowledge/MO-Paper-KB/GPT_ENTRY.md`
5. CMOEA-AOP paper card: `../../../knowledge/MO-Paper-KB/01_papers/P2026-0201.md`
6. DRL operator-selection design card: `../../../knowledge/MO-Paper-KB/02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md`

## Code To Inspect

Baseline implementation:

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/
```

Key files:

- `CMOEAAOP.m`
- `DDPG.m`
- `GenerateSample.m`
- `OperatorConstrainedAOP.m`
- `EnvironmentalSelection.m`
- `CalFitness.m`

## GPT Review Task

When proposing a modification, please provide:

1. Evidence source from the paper card or design-knowledge card.
2. Failure mode or limitation of baseline CMOEA-AOP.
3. Exact code module to modify.
4. Minimal implementation plan for Codex.
5. Minimal smoke test and ablation plan.

## Codex Output To Review

After implementation, Codex should update:

- `baseline_reproduction.md` or a variant-specific result summary;
- `summaries/` for compact tables and figures;
- `research/ai_loop/...` for implementation notes.
