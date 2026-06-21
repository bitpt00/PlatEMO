# CMOEA-AOP Variant Ideas

These are candidates for GPT review, not approved changes.

## X1: Feasibility-Aware Reward

Add feasibility progress to the reward so the actor is not guided only by HV improvement.

Review questions:

- Should reward include feasible offspring ratio, CV reduction, or both?
- How should the reward avoid over-favoring feasibility at the cost of diversity?
- Which ablation should isolate the reward effect?

## X2: Per-Constraint State

Replace or supplement average CV with per-constraint summary features.

Review questions:

- How many constraint features are safe for DDPG stability?
- Should features be mean CV, max CV, satisfied ratio, or normalized CV?
- Which CMOPs best test this change?

## X3: Exploration Floor

Prevent the operator portfolio from collapsing too early to a single operator.

Review questions:

- Should exploration be enforced by entropy floor, minimum action ratio, or OU noise schedule?
- Should the floor decay with `FE/maxFE`?
- What baseline variant is needed for fair comparison?
