# CMOEA-AOP 子实验

本目录把机制拆解实验拆成较小、便于审阅的 study。

## Study 约定

每个 study 最终建议采用下面结构：

```text
plan.md
runs.csv
checkpoints.csv
summary.md
```

对 S00 来说，只创建 `plan.md`。`runs.csv`、`checkpoints.csv` 和 `summary.md` 应在真实运行结果出现后再创建。

## 子实验列表

| Study | 关注点 | 计划文件 |
| --- | --- | --- |
| S01_static_portfolios | 固定和随机算子组合。 | `S01_static_portfolios/plan.md` |
| S02_controller_family | 其他轻量级动态控制器。 | `S02_controller_family/plan.md` |
| S03_credit_signal | reward 和 credit signal 变体。 | `S03_credit_signal/plan.md` |
| S04_dual_population_portfolio | 双种群和算子组合的交互。 | `S04_dual_population_portfolio/plan.md` |

## 记录规则

- 实验设计写在 `plan.md`。
- 每次运行的最终指标写在 `runs.csv`。
- 过程检查点写在 `checkpoints.csv`。
- Codex 执行记录和紧凑结论写在 `summary.md`。
- 大体量原始文件放在 `../results/`。
- 不修改 `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/`。
