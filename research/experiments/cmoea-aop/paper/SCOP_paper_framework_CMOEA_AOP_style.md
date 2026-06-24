# SCOP-CMOEA 论文框架：按 CMOEA-AOP 结构复刻

参考主模板：

```text
Deep Reinforcement Learning-Assisted Automated Operator Portfolio for Constrained Multi-objective Optimization
```

本文档只搭论文框架，不写完整正文。章节标题用英文，说明用中文。整体结构一比一参照 CMOEA-AOP：Introduction -> Related Work and Motivation -> Proposed Algorithm -> Empirical Studies -> Conclusion。

## Title

英文题目候选：

```text
Environmental Selection as Credit Assignment: A Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization
```

短题目候选：

```text
Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization
```

中文理解：

```text
基于环境选择生存信用的约束多目标优化算子组合方法
```

## Abstract

按 CMOEA-AOP 摘要结构写 4 句。

1. CMOP 中固定 offspring 生成策略难以适应不同问题和不同搜索阶段。
2. 多算子 portfolio 可以提供互补搜索行为，但关键是如何分配每个算子的 offspring 生成比例。
3. 提出 SCOP-CMOEA，用环境选择后的 offspring 存活结果作为 survival credit，在线更新 GA/SBX、DE/rand/1、DE/best/1 的比例。
4. 在标准 CMOP 和真实问题上与多类 PlatEMO 算法比较，并通过消融说明 survival credit 的有效性和可解释性。

## Index Terms

```text
Constrained multi-objective optimization;
evolutionary algorithm;
operator portfolio;
environmental selection;
credit assignment.
```

## I. Introduction

### 写作目标

对应 CMOEA-AOP 的 Introduction。先讲 CMOP 难点，再讲固定算子和单一搜索行为的问题，最后引出本文的 survival-credit operator portfolio。

### 段落框架

第一段：CMOP 的基本困难。

- 同时优化多个冲突目标。
- 需要满足复杂约束。
- 可行域可能狭窄、断裂、被不可行区域隔开。
- 不同问题和不同阶段需要不同搜索行为。

第二段：现有 CMOEA 的搜索行为通常依赖固定 variation operators 或固定策略。

- GA/SBX、DE/rand/1、DE/best/1 等算子有不同搜索偏好。
- 单一算子或固定组合难以稳定适应所有 CMOP。

第三段：operator portfolio 的必要性。

- 多算子共同生成 offspring，可以同时保留探索和开发。
- 问题不是“要不要多个算子”，而是“每代应该由哪个算子产生多少 offspring”。

第四段：现有动态算子控制的不足。

- 固定比例不自适应。
- 随机比例不可解释。
- 阶段规则依赖人工设定。
- 深度强化学习需要状态设计、训练和额外参数。

第五段：本文思想。

- 环境选择已经综合了约束、目标和分布压力。
- 某个算子的 offspring 如果更容易在环境选择后存活，说明它对当前搜索更有用。
- 用这个 survival credit 反过来分配下一代 offspring 生成比例。

### Contributions

按 CMOEA-AOP 的贡献写法列 3-4 条。

1. We propose a survival-credit operator portfolio mechanism for constrained multi-objective optimization.
2. We design SCOP-CMOEA, which adaptively allocates offspring generation resources among GA/SBX, DE/rand/1, and DE/best/1 according to environmental-selection feedback.
3. We conduct mechanism ablation studies to compare fixed portfolios, random portfolios, stage portfolios, DDPG-based portfolios, and different credit signals.
4. Extensive experiments on standard and real-world CMOPs verify the competitiveness, simplicity, and interpretability of SCOP-CMOEA.

## II. Related Work and Motivation

对应 CMOEA-AOP 的第二章，保留三个小节。

## A. Constrained Multi-objective Optimization

### 写作任务

介绍 CMOP 和 CMOEA 背景，不展开太多算法细节。

### 内容要点

- CMOP 定义：多目标 + 约束。
- 约束处理方法：可行性优先、约束违反度、epsilon 约束、双种群、多阶段、多任务。
- 当前趋势：用不同搜索角色处理不同约束景观。

### 结尾转折

```text
这些方法主要关注约束处理或种群角色，但 offspring 生成资源如何在不同 variation operators 之间分配，仍然需要进一步研究。
```

## B. Existing Operator Adaptation Approaches

### 写作任务

对应 CMOEA-AOP 的 “Existing Operator Adaptation Approaches”。

### 内容要点

- 固定算子：简单但适应性有限。
- 多算子组合：鲁棒性更好，但比例难定。
- 自适应算子选择：根据成功率或性能反馈选择算子。
- 强化学习算子选择：可以学习状态到动作的映射，但训练成本更高。

### 本文切入

```text
本文不引入外部学习器，而是复用进化过程中已经存在的环境选择结果作为信用反馈。
```

## C. Motivation of This Work

### 写作任务

这一节要对应 CMOEA-AOP 的动机图。原论文用不同算子组合在 CF2、CF6、CF9 上的收敛曲线说明不同问题偏好不同 operator portfolio。我们也要用图说明 survival-credit portfolio 的必要性。

### Fig. 1

图名：

```text
Fig. 1. Motivation of survival-credit operator portfolio.
```

图内容：

```text
选择 3 个代表问题：
CF6
DASCMOP8
MW9

比较 4 类策略：
Equal-AOP
Random-AOP
Stage-AOP
SCOP-CMOEA
```

画法：

```text
用 S12 结果画 IGD convergence curves。
MATLAB 从 MAT 导出 metric 曲线 CSV。
Python 画 3 个子图。
```

要表达的结论：

- 不同问题上最合适的比例策略不同。
- 固定或人工阶段规则不能稳定覆盖所有问题。
- survival credit 能根据环境选择反馈自动调整比例。

## III. The Proposed Algorithm

对应 CMOEA-AOP 的第三章。原文小节是：

```text
A. Framework of CMOEA-AOP
B. Automated Operation Portfolio
C. Agent Training
```

我们复刻为：

```text
A. Framework of SCOP-CMOEA
B. Survival-Credit Operator Portfolio
C. Credit Update and Complexity Analysis
```

## A. Framework of SCOP-CMOEA

### 写作任务

说明整体算法框架。沿用 EMCMO/CMOEA-AOP 的双种群框架，但重点写 offspring portfolio 和 survival-credit feedback。

### Fig. 2

图名：

```text
Fig. 2. Framework of SCOP-CMOEA.
```

图内容：

```text
Population 1: constraint-aware selection
Population 2: objective-oriented auxiliary selection
        ↓
GA/SBX, DE/rand/1, DE/best/1 generate labeled offspring
        ↓
Environmental selection
        ↓
Count survived offspring by operator
        ↓
Update operator proportions
```

画法：

```text
用 draw.io、PowerPoint 或 Python matplotlib 画矢量框架图。
最终导出 PDF/SVG。
```

### Algorithm 1

算法名：

```text
Algorithm 1. General framework of SCOP-CMOEA
```

伪代码步骤：

1. 初始化两个种群。
2. 初始化三个算子的比例为 1/3。
3. 每代根据当前比例生成带 source label 的 offspring。
4. 两个种群分别进行环境选择。
5. 统计每个算子生成数 `g_k` 和存活数 `s_k`。
6. 根据 survival credit 更新比例。
7. 直到达到最大评价次数。

## B. Survival-Credit Operator Portfolio

### 写作任务

对应 CMOEA-AOP 的 Automated Operation Portfolio，但把 DDPG action 改成 survival credit。

### 算子

```text
Operator 1: GA/SBX
Operator 2: DE/rand/1
Operator 3: DE/best/1
```

### 核心公式

生成数：

```text
g_k(t)
```

存活数：

```text
s_k(t)
```

survival credit：

```text
c_k(t) = (s_k(t) + epsilon) / (g_k(t) + K * epsilon)
```

归一化目标比例：

```text
q_k(t) = c_k(t) / sum_j c_j(t)
```

平滑更新：

```text
p_k(t+1) = (1 - alpha) p_k(t) + alpha q_k(t)
```

下限保护：

```text
p_k(t+1) = max(p_k(t+1), floor)
normalize p(t+1)
```

### Fig. 3

图名：

```text
Fig. 3. Survival-credit assignment process.
```

图内容：

```text
operator -> labeled offspring -> environmental selection -> survived labels -> credit -> next proportions
```

画法：

```text
用 Python 或 draw.io 画流程图。
不用实验数据。
```

## C. Credit Update and Complexity Analysis

### 写作任务

这一节替代 CMOEA-AOP 的 Agent Training。原文写 DDPG 训练，我们写 survival credit 更新和复杂度。

### 内容要点

- SCOP-CMOEA 不训练神经网络。
- 只额外记录 offspring 来源和存活数量。
- 额外计算量约为 `O(N)`。
- 相对 CMOEA-AOP，减少 replay buffer、actor/critic 更新和动作网络训练。

### Table 1

表名：

```text
Table I. Main differences between CMOEA-AOP and SCOP-CMOEA.
```

表内容：

| 项目 | CMOEA-AOP | SCOP-CMOEA |
| --- | --- | --- |
| 控制方式 | DDPG action | survival credit |
| 是否训练模型 | 是 | 否 |
| 状态设计 | 需要 | 不需要 |
| 输出 | 三算子比例 | 三算子比例 |
| 反馈来源 | reward | environmental selection survival |
| 可解释性 | 中等 | 高 |

## IV. Empirical Studies

对应 CMOEA-AOP 第四章，保留四个小节。

```text
A. Settings of Problems
B. Settings of Algorithms
C. Experimental Results
D. Ablation Studies
```

## A. Settings of Problems

### 写作任务

说明测试问题、维度、目标数、评价次数、参考点和运行次数。

### 主实验问题

```text
CF1-CF10
LIRCMOP1-LIRCMOP14
DASCMOP1-DASCMOP9
MW1-MW14
DOC1-DOC9
```

主实验设置：

```text
N = 100
MaxFE = 100000
independent runs = 30
metrics = IGD, HV, Feasible_rate, runtime
statistical test = Wilcoxon rank-sum test, p = 0.05
overall ranking = Friedman average rank
```

### Table 2

表名：

```text
Table II. Benchmark problems used in the experiments.
```

表内容：

| Suite | Problems | M | D | Main difficulty |
| --- | --- | --- | --- | --- |
| CF | CF1-CF10 | 2/3 | 10 | disconnected/complex constraints |
| LIR-CMOP | LIRCMOP1-LIRCMOP14 | 2/3 | 30 | large infeasible regions |
| DAS-CMOP | DASCMOP1-DASCMOP9 | 2/3 | 30 | difficulty-adjustable constraints |
| MW | MW1-MW14 | 2/3 | varied | narrow feasible regions |
| DOC | DOC1-DOC9 | 2/3 | varied | decision/objective constraints |

## B. Settings of Algorithms

### 写作任务

对应 CMOEA-AOP 的算法设置。说明对比算法、参数、统计符号。

### 主实验算法

```text
SCOP-CMOEA
CMOEA-AOP
EMCMO
ICMA
IMTCMO
DRLOS-EMCMO
CMOES
DPCPRA
PPS
C-TAEA
```

### Table 3

表名：

```text
Table III. Compared algorithms.
```

表内容：

| Type | Algorithm | Reason |
| --- | --- | --- |
| Proposed | SCOP-CMOEA | 本文算法 |
| Direct operator-portfolio baseline | CMOEA-AOP | DDPG portfolio |
| Framework baseline | EMCMO | 同双种群框架 |
| Strong baselines | ICMA, IMTCMO, CMOES, DPCPRA | S10 筛选强算法 |
| Representative CMOEAs | PPS, C-TAEA | 经典约束处理代表 |
| Learning baseline | DRLOS-EMCMO | RL/dynamic operator selection |

### Table 4

表名：

```text
Table IV. Parameter settings.
```

表内容：

| Parameter | Value |
| --- | --- |
| Population size | 100 |
| MaxFE | 100000 |
| Runs | 30 |
| SBX crossover probability | 1 |
| Polynomial mutation probability | 1/D |
| Distribution index | 20 |
| DE CR | 1 |
| DE F | 0.5 |
| SCOP alpha | 0.35 |
| SCOP floor | 0.05 |

## C. Experimental Results

### 写作任务

对应 CMOEA-AOP 的 Table I、Fig. 3、Fig. 4、Fig. 5。

### Table 5

表名：

```text
Table V. IGD results of compared algorithms on standard CMOPs.
```

内容：

```text
56 个问题的 IGD mean/std。
主文可以放压缩版，完整表放 appendix。
标记 + / - / =，以 SCOP-CMOEA 为基准。
```

### Table 6

表名：

```text
Table VI. HV results of compared algorithms on standard CMOPs.
```

内容：

```text
56 个问题的 HV mean/std。
标记 + / - / =。
```

### Table 7

表名：

```text
Table VII. Overall rankings and win/tie/loss summary.
```

内容：

```text
Friedman 平均排名。
SCOP-CMOEA 相对每个算法的 Wilcoxon 胜/平/负。
分问题族排名：CF, LIR-CMOP, DAS-CMOP, MW, DOC。
```

### Fig. 4

图名：

```text
Fig. 4. Final populations obtained by different algorithms.
```

对应 CMOEA-AOP 的最终解集图。

代表问题：

```text
CF6
LIRCMOP11
DASCMOP8
DOC8
MW9
```

画法：

```text
MATLAB 从 S11 MAT 导出最终 PopObj/PopCon。
Python 画散点图。
只画 SCOP-CMOEA、CMOEA-AOP、EMCMO、最强对手 1-2 个。
```

### Fig. 5

图名：

```text
Fig. 5. Mean IGD convergence profiles.
```

对应 CMOEA-AOP 的收敛曲线图。

代表问题：

```text
CF6
LIRCMOP3
DASCMOP8
DOC8
MW9
```

画法：

```text
MATLAB 导出每个 run 的 IGD 曲线。
Python 求均值和标准误，画曲线。
```

## D. Ablation Studies

### 写作任务

对应 CMOEA-AOP 的 Table II。原文只比较完整 CMOEA-AOP 和三个单算子版本。我们复刻但扩展为两张消融表。

### D.1 Portfolio Ablation

实验编号：

```text
S12
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

### Table 8

表名：

```text
Table VIII. Ablation study on portfolio policies.
```

内容：

```text
IGD/HV 平均排名。
SCOP-CMOEA 相对每个变体的 Wilcoxon 胜/平/负。
分问题族排名。
```

### D.2 Credit Signal Ablation

实验编号：

```text
S13
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

### Table 9

表名：

```text
Table IX. Ablation study on credit signals.
```

内容：

```text
说明 survival credit 是否优于 feasibility、CV、objective、mixed 和 sliding survival。
```

### Fig. 6

图名：

```text
Fig. 6. Operator proportion trajectories of SCOP-CMOEA.
```

内容：

```text
选择 CF6、DASCMOP8、DOC8。
画 GA/SBX、DE/rand/1、DE/best/1 的比例随 FE 变化。
```

画法：

```text
直接用 S11 或 S12 的 policyTrace。
MATLAB 已有 summarize_policy_traces.m 生成 trace_summary.csv 和 trace_phase_summary.csv。
Python 画轨迹图。
```

### Fig. 7

图名：

```text
Fig. 7. Survival rates of different operators.
```

内容：

```text
按问题族统计三个算子的平均 survival rate。
画 heatmap 或 grouped bar。
```

## Optional Extension: Following CMOEA-2S

如果篇幅允许，补充 CMOEA-2S 风格的完整实验。

### E. Parameter Sensitivity Analysis

实验编号：

```text
S14
```

参数：

```text
creditAlpha = 0.12, 0.25, 0.35, 0.50
creditFloor = 0.00, 0.03, 0.05, 0.10
```

### Fig. 8

```text
Parameter sensitivity of alpha and floor.
```

画法：

```text
Python 画 heatmap。
```

### F. Performance on Real-world Problems

实验编号：

```text
S15
```

问题：

```text
RWMOP1-RWMOP20
```

### Table 10

```text
Table X. HV and feasible rate results on RWMOPs.
```

### G. Running Time Analysis

### Fig. 9

```text
Running time comparison.
```

画法：

```text
Python 从 S11 runs.csv 的 runtime 列画 boxplot 或 bar chart。
```

## V. Conclusion

### 写作任务

对应 CMOEA-AOP 的 Conclusion。

### 段落框架

第一段：总结本文提出 SCOP-CMOEA。

- 用 environmental selection survival 作为 credit assignment。
- 在线调整多算子 offspring 生成比例。

第二段：总结实验结果。

- 主实验说明整体竞争力。
- 消融说明 survival credit 的必要性。
- 轨迹图说明可解释性。

第三段：未来工作。

- 扩展到更多算子。
- 两个种群分别维护 credit controller。
- 用更复杂真实应用验证。
- 与轻量学习模型结合。

## References

需要引用的类型：

1. CMOEA-AOP 原论文。
2. EMCMO。
3. DRLOS-EMCMO。
4. C-TAEA、PPS 等对比算法。
5. CF、LIR-CMOP、DAS-CMOP、MW、DOC benchmark。
6. RWMOP benchmark。

## 图表总清单

| 编号 | 类型 | 内容 | 数据来源 |
| --- | --- | --- | --- |
| Fig. 1 | 动机图 | Equal/Random/Stage/SCOP 收敛对比 | S12 |
| Fig. 2 | 框架图 | SCOP-CMOEA 总体流程 | 手工绘制 |
| Fig. 3 | 机制图 | survival credit 分配过程 | 手工绘制 |
| Fig. 4 | 结果图 | 最终解集散点 | S11 |
| Fig. 5 | 结果图 | IGD 收敛曲线 | S11 |
| Fig. 6 | 机制图 | 算子比例轨迹 | S11/S12 policyTrace |
| Fig. 7 | 机制图 | 算子 survival rate 热力图 | S11/S12 trace |
| Fig. 8 | 参数图 | alpha/floor 敏感性 | S14 |
| Fig. 9 | 时间图 | runtime comparison | S11 |
| Table I | 方法表 | CMOEA-AOP vs SCOP-CMOEA | 手工 |
| Table II | 问题表 | benchmark settings | 手工 |
| Table III | 算法表 | compared algorithms | 手工 |
| Table IV | 参数表 | parameter settings | 手工 |
| Table V | 主结果 | IGD | S11 |
| Table VI | 主结果 | HV | S11 |
| Table VII | 统计 | ranking + win/tie/loss | S11 |
| Table VIII | 消融 | portfolio policies | S12 |
| Table IX | 消融 | credit signals | S13 |
| Table X | 应用 | RWMOP HV/FR | S15 |

## 需要马上补的数据

```text
S11: 主实验，必须先完成。
S12: portfolio 消融，用于 Fig. 1 和 Table VIII。
S13: credit 信号消融，用于 Table IX。
S14: 参数敏感性，用于 Fig. 8。
S15: RWMOP，用于 Table X。
```

## 和执行计划的关系

具体怎么跑实验、怎么检查 MAT 数量、怎么导出 CSV，看：

```text
research/experiments/cmoea-aop/paper/SCOP_next_execution_plan.md
```
