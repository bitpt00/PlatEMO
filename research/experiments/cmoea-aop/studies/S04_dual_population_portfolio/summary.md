# S04 双种群 Portfolio 实验总结

## 当前状态

S04 dual-population-fast 已完成。

## 执行记录

- 问题集合：CF1-CF10、LIRCMOP1-LIRCMOP14、DASCMOP1-DASCMOP9，共 33 个问题。
- 实验矩阵：7 个算法/策略 x 33 个问题 x 3 个 seeds = 693 个任务。
- 设置：`N = 100`，`maxFE = 20000`，指标 = IGD、HV、Feasible_rate。
- 策略：EMCMO、CMOEA-AOP、Equal-AOP、Dual-Static-Split-AOP、Dual-Feasibility-Explore-AOP、Dual-Survival-Credit-AOP、Dual-Mixed-Credit-AOP。
- 8 个 MATLAB worker 并行分片运行完成。
- 693 个任务全部完成，状态均为 `ok`，无 error。
- 本目录的 `runs.csv` 当前对应 dual-population-fast。

## 初步观察

下面只是低预算 `maxFE = 20000`、3 个 seeds 的初筛统计，不应作为最终论文级结论。

| 算法/策略 | 可行率为 0 的行数 | Mean feasible rate | Mean finite IGD | 问题级最优次数 | 平均问题排名 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Dual-Survival-Credit-AOP | 15 | 0.8485 | 0.2661 | 6 | 3.121 |
| Dual-Static-Split-AOP | 15 | 0.7990 | 0.3004 | 4 | 3.606 |
| Equal-AOP | 15 | 0.8485 | 0.3050 | 1 | 3.788 |
| Dual-Feasibility-Explore-AOP | 15 | 0.8485 | 0.2816 | 8 | 3.970 |
| CMOEA-AOP | 14 | 0.8276 | 0.2789 | 3 | 4.212 |
| Dual-Mixed-Credit-AOP | 15 | 0.8485 | 0.2897 | 2 | 4.545 |
| EMCMO | 0 | 1.0000 | 0.3281 | 9 | 4.758 |

主要信号：

- Dual-Survival-Credit-AOP 的平均问题排名最好，说明两个种群分别维护 portfolio credit 是有潜力的方向。
- Dual-Feasibility-Explore-AOP 的问题级最优次数较多，但平均排名不是最优，可能是问题依赖较强。
- EMCMO 仍然可行性最稳，但目标收敛/分布指标不一定占优。
- 双种群不同 portfolio 值得继续分析，尤其要看它是否能在不牺牲可行性的情况下改善 IGD。
