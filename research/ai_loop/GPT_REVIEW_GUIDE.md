# GPT Review Guide

Use GPT Pro as the research reviewer and planning brain.

## Before Code Changes

Provide GPT with:

- `research/experiments/cmoea-aop/protocol.md`
- `research/experiments/cmoea-aop/variant_ideas.md`
- `research/kb_links.md`
- the relevant algorithm files under `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/`

Ask GPT to review:

- whether the proposed modification matches the paper evidence;
- which exact algorithm module should be changed;
- what baseline and ablation experiments are needed;
- what risks may invalidate the conclusion.

## After Code Changes

Provide GPT with:

- changed file list;
- key diffs or a concise Codex change log;
- smoke-test result;
- any unexpected runtime behavior.

Ask GPT to check:

- whether implementation matches the intended research idea;
- whether the experiment protocol is still fair;
- whether additional ablations or controls are needed.
