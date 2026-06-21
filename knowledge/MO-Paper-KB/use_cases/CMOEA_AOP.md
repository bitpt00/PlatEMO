# CMOEA-AOP 用例入口

## 目标

为 PlatEMO 中的 CMOEA-AOP 实验提供论文证据和可复用设计知识，支持网页版 GPT 产生可执行的算法修改建议。

## 必读文件

- `../01_papers/P2026-0201.md`
- `../02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md`

## 可讨论的修改方向

这些方向只是讨论入口，不是已经批准的实验方案：

1. Reward 改造：在 HV improvement 之外加入 CV reduction、feasible offspring ratio 或 operator cost。
2. State 改造：从 average CV 扩展到 per-constraint summary，避免少数关键约束被平均值掩盖。
3. Action 改造：在算子比例之外加入参数比例、修复比例或局部搜索比例。
4. Exploration 改造：给 operator portfolio 加 entropy floor 或 minimum ratio，避免早期塌缩为单一算子。
5. Transfer 改造：重新审查两个 population 之间的 offspring/solution transfer 触发条件。

## GPT 审查问题

请优先回答：

- 这个改法是否有论文证据支撑？
- 它对应 CMOEA-AOP 的哪个失败模式？
- 它改的是局部模块还是整体结构？
- 最小实现应该改哪些文件？
- 最小实验需要哪些问题、运行次数和指标？

## Codex 执行边界

Codex 执行时应保留原始 `CMOEA-AOP` 目录作为 baseline。新想法应复制成单独算法目录，例如：

```text
CMOEA-AOP-X1
```

先通过小规模 smoke test，再考虑完整 benchmark。
