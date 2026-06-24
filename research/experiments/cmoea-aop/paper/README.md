# SCOP-CMOEA 论文写作材料索引

这个目录保存从当前实验结果进入论文写作阶段所需的核心设计文档。

## 文档

| 文件 | 用途 |
| --- | --- |
| `SCOP_paper_experiment_design.md` | 论文实验章节设计：需要做哪些实验、出哪些表、画哪些图、正式 S11 如何设置 |
| `SCOP_paper_story_design.md` | 论文故事和算法叙事：如何把 SCOP-CMOEA 讲成一个独立的新算法，而不是 CMOEA-AOP 的小修改 |

## 相关结果文件

| 文件 | 用途 |
| --- | --- |
| `../summaries/S10_algorithm_selection_from_screen.md` | 基于 S10a 的 22 个算法排序和正式对比算法筛选 |
| `../summaries/S10_platemo_screen_analysis.md` | S10a 自动统计摘要 |
| `../summaries/S10_platemo_screen_result_interpretation.md` | S10a 结果解释和下一步建议 |
| `../studies/S10_external_comparison/runs.csv` | S10a 6160 行运行结果汇总 |
| `../studies/S10_external_comparison/problem_means.csv` | S10a 每个算法在每个问题上的均值统计 |

## 当前论文主线

建议论文中心句：

```text
Environmental selection can serve as a credit assignment mechanism for offspring generation.
```

中文：

```text
环境选择不仅决定谁被保留，也能告诉我们下一代应该由谁来产生更多 offspring。
```

建议正式主实验：

```text
10 个算法，56 个问题，30 次独立运行，N=100，maxFE=100000。
```

主表算法：

```text
SCOP-CMOEA, CMOEA-AOP, EMCMO, ICMA, IMTCMO,
DRLOS-EMCMO, CMOES, DPCPRA, PPS, C-TAEA
```
