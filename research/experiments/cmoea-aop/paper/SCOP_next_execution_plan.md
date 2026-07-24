# SCOP-CMOEA 全局实验补齐方案

更新日期：2026-07-24

目标：把 SCOP-CMOEA 的实验包补齐到可以直接写论文，而不是继续零散探索。当前已经完成的结果要尽量复用，后续只补论文闭环中缺失的部分。

## 1. 当前暂停状态

- 当前 SCOP MATLAB 进程已经停止，MATLAB 进程数为 0。
- 原来的 `scop` 自动心跳监控已经删除，不会再自动重启补跑。
- S12 已有 `12545 / 15120` 个 MAT。
- S13 已有 `10835 / 15120` 个 MAT。
- 后续恢复时不需要重跑，只用 `MissingOnly` 从缺失任务继续。

## 2. 论文主线

SCOP-CMOEA 不写成对 CMOEA-AOP 的小修补，也不以“DDPG 是否必要”作为论文题目。

建议主线写成：

```text
在约束多目标优化中，offspring generation 的算子预算本身是一种搜索资源。
SCOP-CMOEA 用环境选择后的生存反馈，为不同生成算子分配资源，
从而形成一种简单、低成本、可解释的自适应算子组合机制。
```

核心关键词：

```text
survival-credit operator portfolio
offspring generation resource allocation
adaptive operator portfolio for constrained multi-objective optimization
```

## 3. 参考补实验方案对照

参考另一篇文章的方案后，SCOP 这篇也应该形成五层闭环：

| 层级 | 作用 | SCOP 对应实验 | 当前状态 | 是否还要补 |
| --- | --- | --- | --- | --- |
| E1 主性能外部对比 | 证明算法有竞争力 | S11 主实验 | 已完成 | 不需要重跑 |
| E2 机制消融 | 证明核心机制不是偶然调参 | S12 + S13 | 正在补，已暂停 | 必须完成 |
| E3 参数稳定性 | 证明参数不敏感 | S14 | 未开始 | 必须完成 |
| E4 泛化/应用 | 证明不只在标准问题有效 | S15 RWMOP | 未开始 | 建议完成 |
| E5 图表与统计闭环 | 支撑论文写作 | 收敛曲线、最终解、runtime、Wilcoxon、Friedman | 部分已有数据 | 必须整理 |

此外，建议增加一个较小的 baseline 补强实验：

| 层级 | 作用 | 建议实验 | 是否必须 |
| --- | --- | --- | --- |
| E6 参考论文 baseline 补强 | 补齐 CMOEA-AOP 和 CMOEA-2S 语境中常见但 S11 未放入主表的算法 | S16 reference-baseline supplement | 建议做 |

高预算实验暂时不作为必做：

```text
S17 high-budget robustness:
只在主结果需要更强说服力时做。
建议选 LIR-CMOP / DAS-CMOP / DOC 代表问题，5-6 个算法，maxFE = 200000 或 300000。
```

## 4. 已有实验怎样复用

| 实验 | 规模 | 用途 |
| --- | --- | --- |
| S01-S04 | 低预算机制拆解 | 写动机和发现过程，不作为最终性能结论 |
| S05-S09 | 候选方法确认 | 写算法形成过程和机制证据 |
| S10 | PlatEMO 多算法筛选 | 说明 S11 baseline 选择依据 |
| S11 | 10 算法 × 56 问题 × 30 run | 论文主性能表 |
| S12 | 9 方法 × 56 问题 × 30 run | portfolio 消融，需补完 |
| S13 | 9 方法 × 56 问题 × 30 run | credit 信号消融，需补完 |

S11 已经足够做主表：

```text
算法：10 个
问题：56 个
runs：30
N：100
maxFE：100000
```

56 个问题包括：

```text
CF1-CF10
LIRCMOP1-LIRCMOP14
DASCMOP1-DASCMOP9
MW1-MW14
DOC1-DOC9
```

## 5. 还需要补哪些实验

### P0：必须补完

1. S12 portfolio 消融补完到 `15120` 个 MAT。
2. S13 credit 信号消融补完到 `15120` 个 MAT。
3. S14 参数敏感性跑完：`16 × 15 × 20 = 4800`。
4. S15 RWMOP 应用实验跑完：`8 × 20 × 30 = 4800`。
5. 为 S11-S15 导出 `runs.csv`、`problem_means.csv`、`trace_summary.csv`、`trace_phase_summary.csv`。
6. 生成正式统计表：IGD、HV、Feasible_rate、runtime、Wilcoxon、Friedman、suite-level rank。
7. 生成正式图：算法框架图、机制发现图、算子比例轨迹、消融柱状图、参数热力图、runtime 图、RWMOP 图。

### P1：建议补强

S16 reference-baseline supplement。

目的：补齐参考论文常见 baseline，避免审稿时被问为什么没有 BiCo、ToP、CMOEA-MS 等算法。

建议算法：

```text
BiCo
ToP
CMOEA-MS
C3M
TSTI
AGE-MOEA-II
```

建议问题：

```text
CF + LIR-CMOP + DAS-CMOP + MW + DOC，共 56 个问题
```

建议参数：

```text
N = 100
maxFE = 100000
runs = 30
```

运行量：

```text
6 × 56 × 30 = 10080 runs
```

S16 不替代 S11 主表。它作为补充 baseline 表，可以和 S11 中已有的 SCOP-CMOEA、CMOEA-AOP、EMCMO、PPS、C-TAEA 等结果合并分析。

### P2：可选增强

S17 high-budget robustness。

只在 S11-S16 整理后仍需要增强说服力时做。

建议设置：

```text
代表问题：LIRCMOP3, LIRCMOP10, LIRCMOP13, DASCMOP5, DASCMOP8, DOC6, DOC8
算法：SCOP-CMOEA, CMOEA-AOP, EMCMO, DRLOS-EMCMO, PPS, BiCo
maxFE = 200000 或 300000
runs = 30
```

这个实验不是当前写论文的第一优先级。

## 6. 论文表格清单

| 表 | 内容 | 数据来源 |
| --- | --- | --- |
| T1 | 实验参数、测试集、指标 | 手工 + configs |
| T2 | 对比算法、类别、年份 | PlatEMO 算法文件 + 文献 |
| T3 | S11 主实验 IGD/HV 总排名 | S11 `runs.csv` |
| T4 | S11 相对各 baseline 的 Wilcoxon 胜/平/负 | S11 `runs.csv` |
| T5 | CF/LIR/DAS/MW/DOC 分测试集排名 | S11 `problem_means.csv` |
| T6 | S12 portfolio 消融结果 | S12 `runs.csv` |
| T7 | S13 credit 信号消融结果 | S13 `runs.csv` |
| T8 | S14 参数敏感性结果 | S14 `runs.csv` |
| T9 | S15 RWMOP HV/FR/runtime | S15 `runs.csv` |
| T10 | S16 补充 baseline 排名 | S16 + S11 合并 |
| 附录 | 56 问题完整 IGD/HV mean(std) | S11-S16 |

## 7. 论文图清单

| 图 | 内容 | 是否需要新跑算法 |
| --- | --- | --- |
| F1 | SCOP-CMOEA 框架图 | 否 |
| F2 | 从机制拆解到 SCOP 的发现路径 | 否 |
| F3 | 代表问题最终解散点图 | 否，需从 MAT 导出 |
| F4 | IGD/HV 收敛曲线 | 否，需从 metric 导出 |
| F5 | SCOP 算子比例随 FE 变化轨迹 | 否，来自 trace |
| F6 | survival credit / survived offspring 热力图 | 否，来自 trace |
| F7 | portfolio 消融柱状图 | 需要 S12 完成 |
| F8 | credit 信号消融柱状图 | 需要 S13 完成 |
| F9 | 参数敏感性热力图 | 需要 S14 完成 |
| F10 | runtime 箱线图 | 否，来自 runs.csv |
| F11 | RWMOP 应用 HV/FR 图 | 需要 S15 完成 |

代表问题先固定为：

```text
CF6
LIRCMOP11
DASCMOP8
DOC8
MW9
```

统计完成后，如果某个问题更适合作图，再替换。

## 8. 恢复执行顺序

当前先暂停，不立即启动。

后续恢复时按这个顺序：

1. 用 `MissingOnly` 继续 S12 和 S13，直到两个目录都达到 `15120` 个 MAT。
2. 导出 S12/S13 的 CSV 和 trace，并立刻做初步统计。
3. 启动 S14 和 S15，可以并行，各 10 个 worker，总 worker 控制在 20 左右。
4. S14/S15 完成后导出 CSV 和统计表。
5. 如果时间允许，启动 S16 baseline 补强。
6. 数据齐后再写 `export_paper_tables.py` 和 `plot_paper_figures.py`，统一出表和出图。

## 9. 可以开始写论文的最低标准

满足下面条件即可开始写实验部分：

```text
S11 已完成并完成正式统计；
S12 和 S13 完成，能证明 survival-credit portfolio 的必要性；
S14 完成，能说明参数稳定性；
S15 完成，能给出真实问题或应用泛化证据；
runtime、Wilcoxon、Friedman、suite-level rank 都已导出；
至少有 3 类图：机制图、轨迹图、消融图；
S16 如果来不及，可以作为补充实验或修稿增强项。
```

如果 S16 完成，再开始全文写作会更稳。
