# CMOEA-AOP 研究计划

这个文件记录围绕 CMOEA-AOP 做机制拆解实验的长期路线图。

## 范围

`S00_directory_setup` 只建立工作区和计划文件，不修改算法代码，也不运行实验。

基准实现保持不变：

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/
```

实验变体统一放在独立沙盒：

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP-Lab/
```

子实验计划、运行汇总和分析记录放在：

```text
research/experiments/cmoea-aop/studies/
```

本地大体量原始输出放在：

```text
research/experiments/cmoea-aop/results/
```

## 执行规则

- 保留 `CMOEA-AOP/` 作为不可改动的基准实现。
- 变体代码写入 `CMOEA-AOP-Lab/`。
- 每个机制问题放入独立 study 目录。
- 只有真实实验数据产生后，才创建或更新 `runs.csv`、`checkpoints.csv` 和 `summary.md`。
- 原始 `.mat`、日志、种子输出、完整种群文件留在 `results/`。
- Git 中提交计划、脚本、紧凑汇总和必要图表，不提交大体量原始输出。

## 子实验路线

| Study | 目的 | 状态 | 当前输出 |
| --- | --- | --- | --- |
| S00_directory_setup | 建立长期工作区和计划文件。 | 已完成 | `RESEARCH_PLAN.md`、`studies/`、`CMOEA-AOP-Lab/` |
| S01_static_portfolios | 检验固定或随机算子组合是否能解释 CMOEA-AOP 部分收益。 | 已完成 discovery-fast | `studies/S01_static_portfolios/plan.md`、`summary.md`、`runs.csv` |
| S02_controller_family | 在理解静态组合基线后，比较轻量级动态控制器。 | 已完成 fast | `studies/S02_controller_family/summary.md`、`runs.csv` |
| S03_credit_signal | 分离 reward 或 credit 信号对算子选择的作用。 | 已完成 fast | `studies/S03_credit_signal/summary.md`、`runs.csv` |
| S04_dual_population_portfolio | 研究双种群行为和算子组合策略之间的关系。 | 已完成 fast | `studies/S04_dual_population_portfolio/summary.md`、`runs.csv` |

## 下一步

S01-S04 fast 实验已经完成后，下一步进入：

```text
GPT Pro 综合机制解释和下一阶段确认实验筛选
```

当前应先解释 33 个问题集上的 fast 结果，再选择少数有潜力的策略进入更高预算确认实验。
