# S01 固定算子组合实验总结

## 当前状态

S01 smoke 和 discovery-fast 已完成。

已实现范围：

- 一个带参数的 lab 算法：`CMOEA_AOP_Lab`。
- 静态策略：单算子、三算子均匀组合、偏重固定组合、双算子组合。
- 后续动态非 DDPG 策略已预留：Random-AOP、Stage-AOP、Survival-Credit-AOP。
- 原始结果文件写入 `research/experiments/cmoea-aop/results/S01_static_portfolios/`。
- discovery-fast 表格结果写入本目录的 `runs.csv`。

## Smoke 执行记录

- Smoke 矩阵：12 个算法/策略 x 3 个问题 x 1 次运行 = 36 个任务。
- Smoke 设置：`N = 100`，`maxFE = 5000`，指标 = IGD、HV、Feasible_rate。
- 问题：CF1、LIRCMOP1、DASCMOP1。
- 36 个 smoke 任务全部完成，状态均为 `ok`。
- 已成功使用 4 个 MATLAB worker 做互不重叠的任务分片。
- 原始 CMOEA-AOP 实现没有修改。

## Discovery-Fast 执行记录

- Discovery-fast 问题集合与论文主实验一致：CF1-CF10、LIRCMOP1-LIRCMOP14、DASCMOP1-DASCMOP9，共 33 个问题。
- Discovery-fast 矩阵：12 个算法/策略 x 33 个问题 x 3 个 seeds = 1188 个任务。
- Discovery-fast 设置：`N = 100`，`maxFE = 20000`，指标 = IGD、HV、Feasible_rate。
- 8 个 MATLAB worker 并行分片运行完成。
- 1188 个任务全部完成，状态均为 `ok`，无 error。
- 原始 `.mat` 和 worker logs 保留在 `research/experiments/cmoea-aop/results/S01_static_portfolios/s01_discovery_fast/`。
- 本目录的 `runs.csv` 当前对应 discovery-fast，而不是 smoke。

## Smoke 合理性检查

下面只是低预算单次运行的流程验证结果，不应作为科学结论。

| Problem | 非 NaN IGD 最好的若干结果 |
| --- | --- |
| CF1 | CMOEA-AOP 0.0290；DE-rand-only 0.0384；GA+DE-rand 0.0437 |
| DASCMOP1 | CMOEA-AOP 0.6636；Equal-AOP 0.7324；DE-best-heavy 0.7370 |
| LIRCMOP1 | GA+DE-rand 0.1967；DE-rand-heavy 0.2458；GA+DE-best 0.2733 |

LIRCMOP1 已经暴露出一个对下一阶段有用的信号：有些固定 portfolio 最终没有得到可行解。因此后续解释应把“找到可行解的能力”和“目标前沿收敛能力”分开分析。

## Discovery-Fast 初步观察

下面只是低预算 `maxFE = 20000`、3 个 seeds 的初筛统计，不应作为最终论文级结论。

- 1188 行结果中有 150 行 IGD/HV 为 `NaN`，这些行的 Feasible_rate 均为 0。
- 这说明部分固定 portfolio 在某些问题和 seed 下完全没有得到最终可行解，可行性发现能力需要单独分析。
- 按“每个问题上 3 次运行均有 finite IGD，然后比较 mean IGD”的粗略问题级最优次数：

| 算法/策略 | 问题级最优次数 |
| --- | ---: |
| DE-rand-only | 8 |
| EMCMO | 7 |
| GA+DE-best | 5 |
| DE-best-heavy | 3 |
| CMOEA-AOP | 2 |
| DE-rand-heavy | 2 |
| GA-heavy | 2 |
| Equal-AOP | 2 |
| DE-rand+DE-best | 1 |
| DE-best-only | 1 |

这个现象提示：在较低评价预算下，简单固定 portfolio 已经能解释相当一部分表现；DDPG-AOP 的优势可能需要更高预算、更多 seeds 或特定困难问题上才更明显。下一步应把这些结果交给 GPT Pro 做机制解释，再决定是否进入 `discovery-main` 或直接设计 S02 动态比例对照实验。
