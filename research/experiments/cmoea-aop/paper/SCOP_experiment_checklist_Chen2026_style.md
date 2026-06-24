# SCOP-CMOEA 实验部分清单：参考 Chen2026 写法

本文档只回答：实验部分要写哪些内容、已有实验哪些能用、还必须补哪些实验。  
参考论文：`Chen2026_Conditional.pdf`。

## 1. Chen2026 的实验写法

Chen2026 的实验章节结构是：

```text
4. Experiments
  4.1 Experimental setup
    4.1.1 Benchmark problems
    4.1.2 Compared algorithms
    4.1.3 Performance metrics
    4.1.4 Experimental protocol and implementation
  4.2 Results on DTLZ benchmark suite
  4.3 Results on WFG benchmark suite
  4.4 Results on real-world engineering problems
  4.5 Results on constrained problems
  4.6 Ablation study and sensitivity analysis
    4.6.1 Component ablation
    4.6.2 Sensitivity analysis
  5. Discussion
```

它的核心写法：

| 模块 | Chen2026 怎么做 | 我们怎么学 |
| --- | --- | --- |
| 实验设置 | 先讲测试集、对比算法、指标、protocol | 我们也先统一交代 56 个问题、10 个算法、IGD/HV/FR/runtime、30 run |
| 分测试集结果 | DTLZ、WFG、RE、C-DTLZ 分开写 | 我们按 CF、LIR-CMOP、DAS-CMOP、MW、DOC、RWMOP 分开写 |
| 主表 | mean ± std + 统计比较 | 我们用 IGD/HV mean ± std + Wilcoxon + Friedman |
| 总体排序图 | Friedman ranking + Nemenyi | 我们做 Friedman average rank，必要时加 Nemenyi/CD 图 |
| 收敛图 | median IGD over 30 runs，带阴影 | 我们做代表问题 IGD/HV convergence |
| 分布图 | box plot across configurations | 我们做不同问题族的 IGD/HV box plot |
| 解集图 | 代表问题最终解集 | 我们做 CF/LIR/DAS/DOC/MW 代表问题最终解集 |
| 真实问题 | 单独一节 RE benchmark | 我们单独一节 RWMOP |
| 约束问题 | 单独一节 C-DTLZ | 我们本身就是 CMOP，重点写 FR、失败问题、约束困难问题 |
| 消融 | 代表问题 + 核心组件去除 | 我们做 portfolio 消融和 credit 信号消融 |
| 敏感性 | 参数逐个变化 | 我们做 `creditAlpha` 和 `creditFloor` |
| 讨论 | 解释为什么有效、可扩展性、局限 | 我们讨论 survival credit、低训练成本、适用边界 |

## 2. 我们现在的性能是否已经确认

结论：**方向上已经确认，但论文级性能还没有最终确认。**

已有 S10a 是：

```text
22 个算法 × 56 个问题 × 5 run
```

它说明：

- SCOP-CMOEA 在宽筛中排名第 1。
- 相对 CMOEA-AOP 的问题级胜负是 43 胜、12 负、1 平。
- 适合进入正式论文主实验。

但 S10a 不能直接作为论文主结果，因为：

- 只有 5 run，不是论文常用 30 run。
- 不能替代 Wilcoxon 的 30-run 显著性检验。
- 还缺正式 HV、FR、runtime 表格和图。

所以实验部分开写前，至少要完成：

```text
S11 主实验
S12 portfolio 消融
S13 credit 信号消融
```

S14 和 S15 用来让论文更完整。

## 3. 已有实验哪些能用

| 实验 | 是否可直接进论文 | 用途 |
| --- | --- | --- |
| S01 固定算子组合 | 不能当主结果 | 可用于动机：固定组合不足 |
| S02 动态比例方式 | 不能当主结果 | 可用于动机：Equal/Random/Stage/Survival 的差异 |
| S03 credit 信号初筛 | 不能当主结果 | 可用于确定 S13 消融方向 |
| S04 双种群组合 | 不放主结果 | 可用于讨论：双种群分开控制不是主线 |
| S05-S06 机制诊断 | 可少量引用 | 可用于说明 survival credit 的形成过程 |
| S07-S09 双种群/候选确认 | 不作为主算法主表 | 可用于说明为什么最终选 SCOP 而不是更复杂的 BiSCOP |
| S10 22 算法筛选 | 可写成实验设计依据 | 用于说明正式对比算法怎么选 |

写论文时的用法：

```text
S01-S10 是 discovery / pilot study，不作为最终性能主证据。
S11-S15 是 paper-level experiments。
```

## 4. 论文实验部分建议结构

直接按 Chen2026 改成我们的版本：

```text
4. Experiments
  4.1 Experimental setup
    4.1.1 Benchmark problems
    4.1.2 Compared algorithms
    4.1.3 Performance metrics
    4.1.4 Experimental protocol and implementation

  4.2 Overall results on standard CMOPs
  4.3 Results by benchmark suite
    4.3.1 Results on CF
    4.3.2 Results on LIR-CMOP
    4.3.3 Results on DAS-CMOP
    4.3.4 Results on MW
    4.3.5 Results on DOC

  4.4 Visualization and convergence analysis
  4.5 Results on real-world problems
  4.6 Ablation study and sensitivity analysis
    4.6.1 Portfolio-policy ablation
    4.6.2 Credit-signal ablation
    4.6.3 Sensitivity analysis

  4.7 Running time and discussion
```

## 5. 必须补做的实验

### S11 主实验

状态：**必须做，尚未完成。**

目的：

```text
确认 SCOP-CMOEA 在 30-run 下是否仍有稳定竞争力。
```

配置：

```text
10 个算法
56 个标准 CMOP
30 run
N = 100
MaxFE = 100000
```

输出：

| 内容 | 对应论文位置 |
| --- | --- |
| IGD mean ± std | 4.2 主结果表 |
| HV mean ± std | 4.2 主结果表 |
| Wilcoxon + / - / = | 4.2 统计比较 |
| Friedman average rank | 4.2 排名图 |
| 分问题族排名 | 4.3 |
| FR 和失败问题 | 4.3/4.7 |
| runtime | 4.7 |

### S12 portfolio 消融

状态：**必须做，尚未完成。**

目的：

```text
回答 SCOP 的收益是不是只来自多算子共存、随机变化或阶段规则。
```

方法：

```text
SCOP-CMOEA
CMOEA-AOP
EMCMO
GA-only
DE-rand-only
DE-best-only
Equal-AOP
Random-AOP
Stage-AOP
```

输出：

| 内容 | 对应论文位置 |
| --- | --- |
| 消融 IGD/HV 排名 | 4.6.1 |
| SCOP 相对各变体的 Wilcoxon | 4.6.1 |
| Equal/Random/Stage/SCOP 收敛曲线 | 4.4 或 4.6.1 |
| operator ratio trajectory | 4.6.1/5 Discussion |

### S13 credit 信号消融

状态：**必须做，尚未完成。**

目的：

```text
回答 survival credit 是否比 feasibility、CV、objective improvement 等信号更合适。
```

方法：

```text
SCOP-CMOEA
Feasibility-Credit-AOP
CV-Credit-AOP
Objective-Credit-AOP
Mixed-Credit-AOP
Sliding-Survival-Credit-AOP
Equal-AOP
EMCMO
CMOEA-AOP
```

输出：

| 内容 | 对应论文位置 |
| --- | --- |
| credit 信号消融表 | 4.6.2 |
| 分问题族表现 | 4.6.2 |
| survival rate heatmap | 5 Discussion |

### S14 参数敏感性

状态：**建议做，尚未完成。**

目的：

```text
说明 SCOP-CMOEA 对 alpha 和 floor 不敏感。
```

参数：

```text
creditAlpha = 0.12, 0.25, 0.35, 0.50
creditFloor = 0.00, 0.03, 0.05, 0.10
```

输出：

| 内容 | 对应论文位置 |
| --- | --- |
| 参数敏感性表 | 4.6.3 |
| alpha/floor heatmap | 4.6.3 |

### S15 RWMOP 应用实验

状态：**建议做，尚未完成。**

目的：

```text
像 Chen2026 的 RE benchmark 一样，给出真实工程问题证据。
```

设置：

```text
RWMOP1-RWMOP20
8 个算法
30 run
指标：HV, Feasible_rate, runtime
```

输出：

| 内容 | 对应论文位置 |
| --- | --- |
| RWMOP HV/FR 表 | 4.5 |
| normalized HV radar 或 box plot | 4.5 |
| 代表问题最终解集 | 4.5 |

## 6. 图表清单

### 主文表格

| 表 | 内容 | 数据来源 | 是否必须 |
| --- | --- | --- | --- |
| Table 1 | Benchmark problems | 手工整理 | 必须 |
| Table 2 | Compared algorithms | S10 筛选结果 | 必须 |
| Table 3 | Parameter settings | config | 必须 |
| Table 4 | S11 IGD/HV 总体排名 | S11 | 必须 |
| Table 5 | Wilcoxon + / - / = | S11 | 必须 |
| Table 6 | Suite-level ranking | S11 | 必须 |
| Table 7 | Portfolio ablation | S12 | 必须 |
| Table 8 | Credit-signal ablation | S13 | 必须 |
| Table 9 | Parameter sensitivity | S14 | 建议 |
| Table 10 | RWMOP HV/FR | S15 | 建议 |

完整 56 问题的 mean ± std 大表放附录。

### 主文图

| 图 | 内容 | 数据来源 | 画法 |
| --- | --- | --- | --- |
| Fig. 1 | 论文方法框架 | 手工 | draw.io 或 Python |
| Fig. 2 | Friedman ranking | S11 | Python |
| Fig. 3 | IGD/HV convergence | S11 | MATLAB 导 CSV，Python 画 |
| Fig. 4 | Box plot across suites | S11 | Python |
| Fig. 5 | Final solution sets | S11 | MATLAB 导 CSV，Python 画 |
| Fig. 6 | Portfolio ablation convergence | S12 | MATLAB 导 CSV，Python 画 |
| Fig. 7 | Operator ratio trajectory | S11/S12 trace | Python |
| Fig. 8 | Survival-rate heatmap | S11/S12 trace | Python |
| Fig. 9 | Parameter sensitivity heatmap | S14 | Python |
| Fig. 10 | RWMOP normalized HV radar/box | S15 | Python |
| Fig. 11 | Runtime comparison | S11/S15 | Python |

## 7. 现在到开始写实验部分的最短路线

最短路线：

```text
1. 跑完 S11。
2. 统计 S11，确认 30-run 排名、显著性和问题族表现。
3. 跑完 S12。
4. 跑完 S13。
5. 先写 4.1-4.4 和 4.6.1-4.6.2。
6. 同时补跑 S14 和 S15。
7. S14/S15 出结果后补 4.5、4.6.3、4.7。
```

如果时间紧，最低论文版本必须有：

```text
S11 + S12 + S13
```

完整论文版本最好有：

```text
S11 + S12 + S13 + S14 + S15
```

## 8. 当前判断

当前可以判断：

```text
SCOP-CMOEA 已经具备进入正式论文实验阶段的性能基础。
```

但还不能写成最终结论：

```text
SCOP-CMOEA 在 30-run 正式实验中显著优于若干强基线。
```

这个结论必须等 S11 完成后再写。

因此下一步不是继续设计新方法，而是：

```text
跑 S11、S12、S13，生成正式表图，然后开始写实验部分。
```
