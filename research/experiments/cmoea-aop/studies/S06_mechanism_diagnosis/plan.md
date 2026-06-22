# S06 机制诊断实验

## 目的

S06 不只比较最终指标，而是解释算子组合为什么有效。实验会记录每代的算子比例、生成数量、存活数量、可行性、CV 信用和目标信用，用于分析不同方法在不同阶段和两个种群上的行为差异。

## 实验问题

使用论文同一组 33 个约束多目标测试问题：

- CF1-CF10
- LIRCMOP1-LIRCMOP14
- DASCMOP1-DASCMOP9

## 算法

- EMCMO
- CMOEA-AOP-Trace
- Equal-AOP
- Stage-AOP
- Survival-Credit-AOP
- Objective-Credit-AOP
- Dual-Survival-Credit-AOP
- Dual-Feasibility-Explore-AOP

其中 `CMOEA-AOP-Trace` 是原始 CMOEA-AOP 控制流的诊断复制版本，只额外记录 DDPG action 和 offspring 统计，不修改原始基线目录。

## 设置

- 种群规模：`N = 100`
- 最大评价次数：`maxFE = 50000`
- 独立运行次数：`runs = 3`
- 指标：`IGD`、`HV`、`Feasible_rate`

## 机制记录

对有 `policyTrace` 的算法，汇总：

- 三个算子的总体比例；
- 早期、中期、后期的比例变化；
- 两个种群各自的比例；
- 各算子的生成数量和存活数量；
- 各算子的 offspring 可行比例；
- CV 信用和 objective 信用的均值。

## 输出

- `runs.csv`：每次运行的最终指标。
- `trace_summary.csv`：每个算法、问题、run 的整体轨迹汇总。
- `trace_phase_summary.csv`：按早期、中期、后期拆分的轨迹汇总。
- `summary.md`：中文机制分析和候选新方法方向。
- 原始 `.mat` 与 worker 日志保存在 `research/experiments/cmoea-aop/results/S06_mechanism_diagnosis/`，不提交 Git。
