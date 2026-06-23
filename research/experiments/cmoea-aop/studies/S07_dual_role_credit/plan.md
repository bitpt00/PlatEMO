# S07 双种群角色化 Credit 实验

## 目的

S05-S06 显示 `Survival-Credit-AOP` 和 `Dual-Survival-Credit-AOP` 稳定，`Objective-Credit-AOP` 有局部潜力，但固定双种群比例不够稳。S07 的目标是把这些线索合成一个更明确的方法方向：两个种群分别维护算子比例，并且使用符合各自角色的 credit 信号。

## 方法变体

- `Dual-Role-Credit-AOP-v1`：主种群使用 `survival + feasibility + CV score`；辅助种群使用 `objective score + survival`。
- `Dual-Role-Credit-AOP-v2`：主种群更偏 `CV score`；辅助种群更偏 `objective score`，并给辅助种群更高探索下限。
- `Dual-Role-Credit-AOP-v3`：v1 的平滑版本，使用较小更新步长和较高下限，避免比例抖动。

## 对照算法

- EMCMO
- CMOEA-AOP
- Equal-AOP
- Survival-Credit-AOP
- Objective-Credit-AOP
- Dual-Survival-Credit-AOP
- Dual-Role-Credit-AOP-v1
- Dual-Role-Credit-AOP-v2
- Dual-Role-Credit-AOP-v3

## 实验问题

使用论文同一组 33 个约束多目标测试问题：

- CF1-CF10
- LIRCMOP1-LIRCMOP14
- DASCMOP1-DASCMOP9

## 设置

- 种群规模：`N = 100`
- 最大评价次数：`maxFE = 50000`
- 独立运行次数：`runs = 5`
- 指标：`IGD`、`HV`、`Feasible_rate`

## 关注问题

1. 双种群角色化 credit 是否比共享 `Survival-Credit-AOP` 更稳？
2. 主种群约束 credit、辅助种群目标 credit 的分工是否能带来可解释收益？
3. 三个 `Dual-Role` 版本中，强反馈、探索下限和平滑更新哪一种更合适？
4. 如果 `Dual-Role` 只接近但不超过最强基线，它是否仍能提供更有论文价值的机制解释？

## 输出

- `runs.csv`：每次运行的最终指标。
- `problem_means.csv`：每个算法/问题的均值与严格失败标记。
- `trace_summary.csv`：有 `policyTrace` 的算法整体轨迹汇总。
- `trace_phase_summary.csv`：早期、中期、后期轨迹汇总。
- `summary.md`：中文统计分析和下一步 S08 筛选结论。
- 原始 `.mat` 与 worker 日志保存在 `research/experiments/cmoea-aop/results/S07_dual_role_credit/`，不提交 Git。
