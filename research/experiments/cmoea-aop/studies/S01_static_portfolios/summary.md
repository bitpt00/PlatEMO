# S01 固定算子组合实验总结

## 当前状态

S01 smoke 的实现和验证已经完成。

已实现范围：

- 一个带参数的 lab 算法：`CMOEA_AOP_Lab`。
- 静态策略：单算子、三算子均匀组合、偏重固定组合、双算子组合。
- 后续动态非 DDPG 策略已预留：Random-AOP、Stage-AOP、Survival-Credit-AOP。
- 原始结果文件写入 `research/experiments/cmoea-aop/results/S01_static_portfolios/`。
- smoke 表格结果写入本目录的 `runs.csv`。

## 执行记录

- Smoke 矩阵：12 个算法/策略 x 3 个问题 x 1 次运行 = 36 个任务。
- Smoke 设置：`N = 100`，`maxFE = 5000`，指标 = IGD、HV、Feasible_rate。
- 问题：CF1、LIRCMOP1、DASCMOP1。
- 36 个 smoke 任务全部完成，状态均为 `ok`。
- 已成功使用 4 个 MATLAB worker 做互不重叠的任务分片。
- 原始 CMOEA-AOP 实现没有修改。

## Smoke 合理性检查

下面只是低预算单次运行的流程验证结果，不应作为科学结论。

| Problem | 非 NaN IGD 最好的若干结果 |
| --- | --- |
| CF1 | CMOEA-AOP 0.0290；DE-rand-only 0.0384；GA+DE-rand 0.0437 |
| DASCMOP1 | CMOEA-AOP 0.6636；Equal-AOP 0.7324；DE-best-heavy 0.7370 |
| LIRCMOP1 | GA+DE-rand 0.1967；DE-rand-heavy 0.2458；GA+DE-best 0.2733 |

LIRCMOP1 已经暴露出一个对下一阶段有用的信号：有些固定 portfolio 最终没有得到可行解。因此后续解释应把“找到可行解的能力”和“目标前沿收敛能力”分开分析。
