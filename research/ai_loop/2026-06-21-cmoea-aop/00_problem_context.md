# CMOEA-AOP Experiment Context

## Baseline

Algorithm path:

```text
PlatEMO\Algorithms\Multi-objective optimization\CMOEA-AOP
```

Main files:

- `CMOEAAOP.m`
- `DDPG.m`
- `GenerateSample.m`
- `OperatorConstrainedAOP.m`
- `EnvironmentalSelection.m`
- `CalFitness.m`

## Research Starting Point

CMOEA-AOP uses DDPG to output a continuous operator portfolio ratio for GA/SBX, DE/rand/1, and DE/best/1. The controller uses population-level convergence, diversity, feasibility, and evaluation progress signals.

Initial modification targets:

- state representation;
- reward design;
- action-to-offspring allocation;
- exploration control;
- transfer between the two populations.

## External Evidence

Primary local knowledge files:

- `E:\多目标优化\MO-Paper-KB\01_papers\P2026-0201.md`
- `E:\多目标优化\MO-Paper-KB\02_design_knowledge\K-drl-state-driven-evolutionary-operator-selection.md`
