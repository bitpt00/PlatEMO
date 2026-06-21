# GPT Start Here

This repository is used as a shared workspace for PlatEMO experiments.

## Current Main Task

CMOEA-AOP research and experiment loop:

```text
research/experiments/cmoea-aop/README.md
```

Prompt for the web GPT reviewer:

```text
research/experiments/cmoea-aop/GPT_WEB_PROMPT.md
```

Full baseline paper PDF:

```text
research/experiments/cmoea-aop/papers/2603.16401v1.pdf
```

## Knowledge Base

The paper knowledge base is mirrored in this repository so GPT can read it from GitHub:

```text
knowledge/MO-Paper-KB/GPT_ENTRY.md
```

For the CMOEA-AOP experiment, start with:

```text
research/experiments/cmoea-aop/papers/2603.16401v1.pdf
knowledge/MO-Paper-KB/01_papers/P2026-0201.md
knowledge/MO-Paper-KB/02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md
```

## Roles

- GPT Pro: reads code, knowledge cards, plans, and result summaries; proposes and reviews research directions.
- Codex: edits code, runs experiments, records changes and results, and updates this GitHub repository.
