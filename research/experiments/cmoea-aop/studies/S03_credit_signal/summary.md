# S03 信用信号实验总结

## 当前状态

S03 credit-fast 已完成。

## 执行记录

- 问题集合：CF1-CF10、LIRCMOP1-LIRCMOP14、DASCMOP1-DASCMOP9，共 33 个问题。
- 实验矩阵：8 个算法/策略 x 33 个问题 x 3 个 seeds = 792 个任务。
- 设置：`N = 100`，`maxFE = 20000`，指标 = IGD、HV、Feasible_rate。
- 策略：CMOEA-AOP、Equal-AOP、Survival-Credit-AOP、Feasibility-Credit-AOP、CV-Credit-AOP、Objective-Credit-AOP、Mixed-Credit-AOP、Sliding-Survival-Credit-AOP。
- 8 个 MATLAB worker 并行分片运行完成。
- 792 个任务全部完成，状态均为 `ok`，无 error。
- 本目录的 `runs.csv` 当前对应 credit-fast。

## 初步观察

下面只是低预算 `maxFE = 20000`、3 个 seeds 的初筛统计，不应作为最终论文级结论。

| 算法/策略 | 可行率为 0 的行数 | Mean feasible rate | Mean finite IGD | 问题级最优次数 | 平均问题排名 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Objective-Credit-AOP | 15 | 0.8480 | 0.2962 | 2 | 3.424 |
| Survival-Credit-AOP | 15 | 0.8418 | 0.2987 | 3 | 4.242 |
| Sliding-Survival-Credit-AOP | 15 | 0.8472 | 0.3092 | 5 | 4.273 |
| CV-Credit-AOP | 15 | 0.8389 | 0.2821 | 2 | 4.394 |
| Mixed-Credit-AOP | 15 | 0.8357 | 0.3113 | 4 | 4.394 |
| Feasibility-Credit-AOP | 15 | 0.8485 | 0.3014 | 4 | 4.848 |
| Equal-AOP | 15 | 0.8366 | 0.2844 | 6 | 4.939 |
| CMOEA-AOP | 13 | 0.8492 | 0.3226 | 2 | 5.485 |

主要信号：

- Objective-Credit-AOP 的平均问题排名最好，说明“目标改进相关反馈”值得继续关注。
- Equal-AOP 的问题级最优次数最多，但平均排名较靠后，可能意味着它在少数问题上很好，在另一些问题上不稳。
- Feasibility-Credit-AOP 没有明显压过其他 credit，说明单纯按可行 offspring 比例调比例可能不足。
- CMOEA-AOP 的可行率略稳，但低预算下平均排名不占优。
