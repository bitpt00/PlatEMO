# S05 候选方法确认实验

## 目的

S01-S04 的 fast 结果显示，轻量动态控制和双种群分别控制都有潜力。S05 不再继续横向扩展大量新变体，而是把少数候选方法放到更高预算下确认，判断这些信号是不是稳定。

## 实验问题

使用论文同一组 33 个约束多目标测试问题：

- CF1-CF10
- LIRCMOP1-LIRCMOP14
- DASCMOP1-DASCMOP9

## 算法

- EMCMO
- CMOEA-AOP
- Equal-AOP
- Stage-AOP
- Survival-Credit-AOP
- Objective-Credit-AOP
- Dual-Survival-Credit-AOP
- Dual-Feasibility-Explore-AOP

## 设置

- 种群规模：`N = 100`
- 最大评价次数：`maxFE = 50000`
- 独立运行次数：`runs = 5`
- 指标：`IGD`、`HV`、`Feasible_rate`

## 关注问题

1. S01-S04 中看到的轻量策略优势是否在更高预算下仍存在？
2. DDPG-AOP 是否只是需要更多评价预算才能发挥作用？
3. 双种群分别控制是否比共享比例更稳定？
4. 哪些方法值得进入 S06 的机制诊断？

## 输出

- `runs.csv`：每次运行的最终指标。
- `summary.md`：中文统计分析和下一步筛选结论。
- 原始 `.mat` 与 worker 日志保存在 `research/experiments/cmoea-aop/results/S05_candidate_confirmation/`，不提交 Git。
