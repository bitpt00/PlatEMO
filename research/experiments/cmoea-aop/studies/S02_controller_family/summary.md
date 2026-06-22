# S02 控制器家族实验总结

## 当前状态

S02 controller-fast 已完成。

## 执行记录

- 问题集合：CF1-CF10、LIRCMOP1-LIRCMOP14、DASCMOP1-DASCMOP9，共 33 个问题。
- 实验矩阵：6 个算法/策略 x 33 个问题 x 3 个 seeds = 594 个任务。
- 设置：`N = 100`，`maxFE = 20000`，指标 = IGD、HV、Feasible_rate。
- 策略：EMCMO、CMOEA-AOP、Equal-AOP、Random-AOP、Stage-AOP、Survival-Credit-AOP。
- 8 个 MATLAB worker 并行分片运行完成。
- 594 个任务全部完成，状态均为 `ok`，无 error。
- 本目录的 `runs.csv` 当前对应 controller-fast。

## 初步观察

下面只是低预算 `maxFE = 20000`、3 个 seeds 的初筛统计，不应作为最终论文级结论。

| 算法/策略 | 可行率为 0 的行数 | Mean feasible rate | Mean finite IGD | 问题级最优次数 | 平均问题排名 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Stage-AOP | 15 | 0.8452 | 0.2810 | 7 | 2.879 |
| Survival-Credit-AOP | 14 | 0.8436 | 0.3033 | 6 | 2.939 |
| Random-AOP | 15 | 0.8323 | 0.3029 | 4 | 3.455 |
| EMCMO | 0 | 1.0000 | 0.3091 | 9 | 3.788 |
| Equal-AOP | 15 | 0.8485 | 0.2952 | 4 | 3.848 |
| CMOEA-AOP | 13 | 0.8262 | 0.3273 | 3 | 4.091 |

主要信号：

- Stage-AOP 和 Survival-Credit-AOP 在平均问题排名上优于 Equal-AOP、Random-AOP 和 CMOEA-AOP。
- EMCMO 的可行性最稳，没有最终可行率为 0 的行，但 mean finite IGD 和平均排名不是最优。
- 低预算下，简单阶段规则和即时存活反馈已经能接近或超过 DDPG-AOP，应作为后续重点解释对象。
