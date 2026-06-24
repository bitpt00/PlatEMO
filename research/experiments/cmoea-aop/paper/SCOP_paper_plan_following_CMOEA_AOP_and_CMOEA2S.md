# 参照 CMOEA-AOP 与 CMOEA-2S 的 SCOP-CMOEA 论文完整方案

本文档只解决一个问题：现在核心探索实验已经完成，接下来如果要把 SCOP-CMOEA 写成一篇完整论文，还需要补哪些实验、出哪些表、画哪些图，以及论文故事怎样按两篇模板论文的方式组织。

参考模板：

- `2603.16401v1.pdf`：CMOEA-AOP，重点学习其“多算子组合动机、主对比实验、单算子消融、收敛和解集图”的写法。
- `CMOEA-2S.pdf`：重点学习其“分测试集写性能、参数表、进一步讨论、真实问题、消融、参数敏感性、运行时间”的完整实验结构。

## 1. 两篇模板论文给我们的结构

### 1.1 CMOEA-AOP 的可复刻结构

CMOEA-AOP 的论文主线可以概括为：

```text
固定或单一算子难以适应不同 CMOP
        ↓
多算子 portfolio 有必要
        ↓
用 DDPG 学习连续比例
        ↓
在 CF、LIR-CMOP、DAS-CMOP 上验证
        ↓
通过单算子消融说明 portfolio 有效
```

它的实验结构主要包括：

| 位置 | 原论文做法 | 我们的对应做法 |
| --- | --- | --- |
| Motivation figure | 比较不同算子组合在 CF2、CF6、CF9 上的收敛 | 用 S01/S08/S09 的结果画“固定组合、随机比例、survival credit”的机制发现图 |
| Main comparison | 6 个算法，33 个问题，30 run，IGD | 10 个算法，56 个问题，30 run，IGD/HV/FR/runtime |
| Visualization | 典型问题的最终解集图 | 每个重要问题族选 1 个典型问题画最终解集 |
| Convergence | CF6、LIR-CMOP3、LIR-CMOP4 的 IGD 曲线 | 选择 CF、LIR、DAS、DOC、MW 各 1 个代表问题画 IGD/HV 曲线 |
| Ablation | CMOEA-AOP vs 三个单算子版本 | SCOP vs 单算子、均匀、随机、阶段规则、不同信用信号、DDPG-AOP |

CMOEA-AOP 对我们的启发不是“我们要证明 DDPG 不重要”，而是“多算子比例控制必须通过机制实验来讲清楚”。我们的论文要把这个机制进一步提升为：

```text
环境选择可以作为 offspring 生成资源的内生信用分配器。
```

### 1.2 CMOEA-2S 的可复刻结构

CMOEA-2S 的论文主线可以概括为：

```text
多阶段 CMOEA 有价值
        ↓
手工阶段安排不稳
        ↓
用 RLSD 根据种群状态决定阶段
        ↓
在 LIR-CMOP、DOC、CF 和真实问题上验证
        ↓
通过阶段轨迹、消融、参数、时间说明方法合理
```

它的实验章节更完整，适合作为我们正式论文实验部分的骨架。

| 原论文实验小节 | 原论文做法 | 我们的对应小节 |
| --- | --- | --- |
| Compared algorithms and test problems | 先说明对比算法和 LIR/DOC/CF/真实问题 | 先说明 10 个对比算法和 56 个标准问题，再说明 RWMOP |
| Parameter settings | 单独列表说明 GA、DE、算法参数、N、MaxFE、run | 单独给一张参数表，包含 SCOP 的 `creditAlpha` 和 `creditFloor` |
| Performance indicator | IGD、HV、Wilcoxon | IGD、HV、FR、runtime、Wilcoxon、Friedman |
| Performance on LIR-CMOP | 单独一节，表格和文字分析 | 保留每个问题族单独分析 |
| Performance on DOC | 单独一节 | 保留 DOC 分析 |
| Performance on CF | 单独一节 | 保留 CF 分析 |
| Further discussion | 阶段选择轨迹和收敛曲线 | 算子比例轨迹、survival credit 轨迹和收敛曲线 |
| Real-world problems | 4 个真实问题，HV 表 | RWMOP1-RWMOP20 或 RWMOP1-RWMOP50 |
| Ablation study | 去掉 AMM、随机阶段 | 去掉 survival credit，换成 Equal/Random/Stage/其他信用 |
| Parameter sensitivity | 分析阶段长度参数 | 分析 `creditAlpha` 和 `creditFloor` |
| Running time | 报告运行时间 | 报告训练无关、低额外开销的时间优势 |

因此，我们的实验章节应主要学习 CMOEA-2S 的组织方式，动机和消融设计则学习 CMOEA-AOP。

## 2. 我们论文的核心故事

论文不要写成“我们解释了 CMOEA-AOP”或“我们简化了 CMOEA-AOP”。这会把创新点压低。

建议论文中心问题写成：

```text
在约束多目标优化中，有限的 offspring 生成资源应如何在互补算子之间自适应分配？
```

建议中心观点写成：

```text
环境选择不仅决定哪些解被保留，也能反过来告诉算法下一代应该由哪些算子产生更多 offspring。
```

建议算法定位写成：

```text
SCOP-CMOEA 是一种基于环境选择内生反馈的 survival-credit operator portfolio 方法。
```

这条故事和两篇模板论文的关系是：

- 继承 CMOEA-AOP 的“operator portfolio”问题意识。
- 继承 CMOEA-2S 的“根据进化状态自适应调整搜索策略”的写法。
- 但我们的核心不是外部 RL 学习器，而是复用环境选择已经产生的反馈。

## 3. 论文结构建议

### 3.1 Introduction

建议按五段写。

| 段落 | 要讲的内容 | 学习哪篇模板 |
| --- | --- | --- |
| 1 | CMOP 的困难：复杂可行域、不可行屏障、目标和约束冲突 | 两篇都可参考 |
| 2 | 现有方法通过多种群、多阶段、多任务、动态约束处理来分配搜索资源 | CMOEA-2S |
| 3 | offspring 生成资源也是一种关键资源，不同算子有不同搜索行为 | CMOEA-AOP |
| 4 | 现有固定、随机、阶段规则、RL 控制各有成本或适应性问题 | CMOEA-AOP + CMOEA-2S |
| 5 | 引出 survival credit：环境选择后的存活结果可作为算子信用 | 我们自己的核心 |

贡献建议写 4 条：

1. 提出 survival-credit operator portfolio，把环境选择后的 offspring 存活结果用于自适应分配算子生成比例。
2. 设计 SCOP-CMOEA，将 GA/SBX、DE/rand/1、DE/best/1 集成到双种群约束多目标框架中，并用 survival credit 在线更新比例。
3. 通过固定组合、随机比例、阶段比例、DDPG-AOP 和多种信用信号消融，说明 survival credit 是一种有效且可解释的反馈。
4. 在 56 个标准 CMOP 和 RWMOP 真实问题上与多类 PlatEMO 算法比较，验证算法的整体竞争力和低训练成本。

### 3.2 Related Work

建议分三小节，不要围着某一篇论文写。

| 小节 | 内容 | 目的 |
| --- | --- | --- |
| Constraint-handling and auxiliary search in CMOPs | 多阶段、多种群、多任务、约束松弛、可行性优先 | 把论文放到 CMOP 大背景中 |
| Operator portfolio and adaptive variation | 多算子、GA/DE 互补、固定/随机/自适应组合 | 引出 offspring 生成资源分配 |
| Learning-assisted and feedback-driven CMOEAs | DRL、Q-learning、阶段学习、算子学习、轻量反馈 | 说明 SCOP 是训练无关的内生反馈路线 |

### 3.3 Method

建议 Method 章节结构如下：

1. Framework overview
2. Operator portfolio with source labels
3. Survival-credit assignment
4. Proportion update with smoothing and floor
5. Integration with dual populations
6. Complexity analysis

核心公式可以保持简单。

```text
g_k(t): 第 t 代算子 k 生成的 offspring 数量
s_k(t): 这些 offspring 中被环境选择保留的数量
c_k(t) = (s_k(t) + epsilon) / (g_k(t) + K * epsilon)
q_k(t) = c_k(t) / sum_j c_j(t)
p_k(t+1) = (1 - alpha) * p_k(t) + alpha * q_k(t)
```

然后进行下限保护：

```text
p_k(t+1) = max(p_k(t+1), floor)
normalize p(t+1)
```

Method 里要重点解释为什么 survival 比 feasibility、CV 或 objective improvement 更适合作为信用：

- feasibility 只看是否可行，可能忽略目标收敛和分布。
- CV reduction 只看约束改善，可能偏向目标很差的方向。
- objective improvement 可能鼓励不可行解。
- survival 是环境选择之后的结果，已经融合了约束、目标和分布压力。

## 4. 正式实验总设计

### 4.1 主实验设置

正式主实验建议采用下面设置。

| 项目 | 设置 | 理由 |
| --- | --- | --- |
| 种群规模 | N=100 | 两篇模板论文都使用 100 |
| 最大评价次数 | MaxFE=100000 | 与 CMOEA-AOP 完全一致，也与我们 S10 筛选一致 |
| 独立运行 | 30 run | 两篇模板论文都使用 30 run |
| 指标 | IGD、HV、Feasible rate、Runtime | CMOEA-2S 用 IGD/HV；我们增加 FR 和 runtime |
| 统计检验 | Wilcoxon rank-sum, p=0.05 | 两篇模板论文都使用 Wilcoxon |
| 总体排序 | Friedman average rank | 用于从 56 问题整体排序，补强统计表达 |
| 平台 | PlatEMO | 对比算法必须来自 PlatEMO |

补充实验可以增加一个高预算检查：

```text
MaxFE=200000，选择 LIR-CMOP、DOC、CF 中的代表问题。
```

原因是 CMOEA-2S 使用 200000 FE。这个实验不一定放主表，可以作为补充材料或鲁棒性检查。

### 4.2 对比算法

主实验建议使用 10 个算法。

| 类别 | 算法 | 选择理由 |
| --- | --- | --- |
| 本文算法 | SCOP-CMOEA | survival-credit operator portfolio |
| 直接相关 | CMOEA-AOP | operator portfolio + DDPG，直接相关 |
| 基础框架 | EMCMO | 证明收益不是只来自双种群框架 |
| 强竞争者 | ICMA | S10a 中平均排名第 2 |
| 强竞争者 | IMTCMO | S10a 中平均排名第 3，问题胜场多 |
| 学习/动态类 | DRLOS-EMCMO | 与 RL/动态算子选择相关 |
| 强竞争者 | CMOES | S10a 中整体表现靠前 |
| 问题族补充 | DPCPRA | MW 问题族较强，避免只挑有利算法 |
| 经典代表 | PPS | push-pull 类约束处理代表 |
| 经典代表 | C-TAEA | 双档案约束处理代表 |

可选补充算法：

- `CMOEMT`：如果主表允许 11 个算法，可加入，因为 S10a 整体表现也较强。
- `CMOEA-2S`：如果本地版本能稳定运行，可作为补充对比或附录对比；主实验不强依赖它，因为目前 S10a 筛选体系没有把它纳入统一排序。

### 4.3 测试问题

主实验建议保留 56 个标准问题。

| 问题族 | 数量 | 与模板论文关系 | 作用 |
| --- | ---: | --- | --- |
| CF | 10 | 两篇模板都使用 | 经典复杂约束，含 2/3 目标 |
| LIR-CMOP | 14 | 两篇模板都使用 | 大不可行区域和局部可行前沿 |
| DAS-CMOP | 9 | CMOEA-AOP 使用 | 难度可调约束 |
| DOC | 9 | CMOEA-2S 使用 | 更复杂的约束景观 |
| MW | 14 | 扩展补充 | 窄可行域和复杂边界 |

这 56 个问题应全部保留。原因有三点：

1. CMOEA-AOP 覆盖 CF、LIR、DAS，CMOEA-2S 覆盖 LIR、DOC、CF，我们的 56 个问题正好把两篇模板的主要标准集覆盖完整。
2. S10a 显示 SCOP-CMOEA 在不同问题族上的优势不均匀，删掉某个问题族会改变结论。
3. 56 个问题能支撑“整体竞争力”和“适用边界”两个结论。

真实问题建议使用 PlatEMO 已有的 `RWMOP1-RWMOP50`。

| 方案 | 问题 | 用途 |
| --- | --- | --- |
| 轻量应用实验 | RWMOP1-RWMOP20 | 主文应用补充 |
| 完整应用实验 | RWMOP1-RWMOP50 | 附录或补充材料 |

真实问题建议以 HV、feasible rate、runtime 为主，因为真实问题通常没有稳定的理论 PF。

## 5. 需要补出来的数据

### 5.1 S11 主实验数据

这是论文主证据。

```text
10 个算法 × 56 个问题 × 30 run = 16800 次运行
```

需要保存：

- 每次运行的 IGD。
- 每次运行的 HV。
- 每次运行是否找到可行解。
- 每次运行的 runtime。
- 代表问题上的最终种群。
- 代表问题上的收敛曲线。
- SCOP-CMOEA 的算子比例轨迹和 survival credit 轨迹。

S10a 的 5-run 筛选结果只能用于选择对比算法，不能作为最终论文主表。

### 5.2 消融实验数据

消融实验建议分两组。

第一组：算子组合和比例产生方式。

| 方法 | 作用 |
| --- | --- |
| EMCMO | 基础框架 |
| GA-only | 单 GA/SBX |
| DE-rand-only | 单 DE/rand/1 |
| DE-best-only | 单 DE/best/1 |
| Equal-AOP | 三算子均匀比例 |
| Random-AOP | 每代随机比例 |
| Stage-AOP | 人工阶段比例 |
| SCOP-CMOEA | survival-credit 动态比例 |
| CMOEA-AOP | DDPG 动态比例 |

第二组：信用信号。

| 方法 | 信用来源 |
| --- | --- |
| Survival-Credit | offspring 是否被环境选择保留 |
| Feasibility-Credit | offspring 是否可行 |
| CV-Credit | offspring 是否降低约束违反 |
| Objective-Credit | offspring 是否改善目标 |
| Mixed-Credit | survival + feasibility + CV |
| Sliding-Survival-Credit | 最近若干代 survival 的滑动平均 |

如果计算资源足够，两组消融都做 56 问题 30 run。若时间紧，第一组做 56 问题 30 run，第二组先做 56 问题 10 run，再选择关键变体补到 30 run。

### 5.3 参数敏感性数据

建议分析两个参数。

| 参数 | 候选值 |
| --- | --- |
| `creditAlpha` | 0.12, 0.25, 0.35, 0.50 |
| `creditFloor` | 0.00, 0.03, 0.05, 0.10 |

参数敏感性不必全 56 问题 full factorial。建议选 15 个代表问题：

| 问题族 | 代表问题 |
| --- | --- |
| CF | CF3, CF6, CF8 |
| LIR-CMOP | LIRCMOP3, LIRCMOP10, LIRCMOP13 |
| DAS-CMOP | DASCMOP1, DASCMOP5, DASCMOP8 |
| DOC | DOC4, DOC6, DOC8 |
| MW | MW5, MW9, MW12 |

每个参数设置建议 20 或 30 run。主文画热力图或柱状图，附录给表。

### 5.4 真实问题数据

建议先跑：

```text
8 个算法 × RWMOP1-RWMOP20 × 30 run
```

8 个算法可以为：

```text
SCOP-CMOEA, CMOEA-AOP, EMCMO, ICMA, IMTCMO, DRLOS-EMCMO, DPCPRA, PPS
```

如果结果稳定，再扩展到 RWMOP1-RWMOP50。

## 6. 论文应出的表

### 6.1 主文表格

| 表号 | 内容 | 学习来源 | 目的 |
| --- | --- | --- | --- |
| Table 1 | Benchmark characteristics | CMOEA-2S Table 1 | 说明 CF/LIR/DAS/DOC/MW 和 RWMOP |
| Table 2 | Parameter settings | CMOEA-2S Table 2 | 说明 N、MaxFE、run、GA/DE、SCOP 参数 |
| Table 3 | Compared algorithms | 两篇模板 | 说明 10 个算法的类别和年份 |
| Table 4 | Overall Friedman ranking on IGD/HV | 我们补强 | 给出 56 问题总体排序 |
| Table 5 | Wilcoxon win/tie/loss summary | 两篇模板 | 给出 SCOP 相对各算法的显著胜负 |
| Table 6 | Suite-level average ranks | CMOEA-2S 分测试集写法 | 展示 CF/LIR/DAS/DOC/MW 上的差异 |
| Table 7 | Feasible rate summary | CMOEA-2S 的 N/A 思路扩展 | 说明算法找可行解的稳定性 |
| Table 8 | Ablation summary | 两篇模板消融 | 说明 survival credit 的机制贡献 |
| Table 9 | Real-world HV and feasible rate | CMOEA-2S Table 9 | 展示应用价值 |
| Table 10 | Runtime comparison | CMOEA-2S Fig. 10 | 展示训练无关的时间优势 |

### 6.2 附录表格

完整 56 问题的均值和标准差建议放附录：

- IGD mean/std full table。
- HV mean/std full table。
- 每个问题族的 Wilcoxon 结果。
- 参数敏感性完整表。
- RWMOP1-RWMOP50 完整表。

这样主文不会被超长表格淹没，但证据完整。

## 7. 论文应出的图

### 7.1 故事和方法图

| 图号 | 内容 | 学习来源 | 作用 |
| --- | --- | --- | --- |
| Fig. 1 | Offspring generation resource allocation motivation | CMOEA-AOP Fig. 1 | 用实验现象说明不同算子/比例在不同问题上表现不同 |
| Fig. 2 | SCOP-CMOEA framework | 两篇模板的算法框架图 | 展示双种群、多算子、survival credit 闭环 |
| Fig. 3 | Survival credit assignment | 我们自己的核心 | 说明 source label、environmental selection、credit update |
| Fig. 4 | Mechanism discovery path | 我们的探索过程 | 从固定组合、动态比例、信用信号到 SCOP |

Fig. 4 要谨慎写。它不是实验流水账，而是“机制抽象图”。建议标题：

```text
From mechanism decomposition to survival-credit operator portfolio
```

### 7.2 性能图

| 图号 | 内容 | 代表问题建议 | 学习来源 |
| --- | --- | --- | --- |
| Fig. 5 | 最终解集图 | CF2, LIRCMOP11, DASCMOP8, DOC4, MW9 | CMOEA-AOP Fig. 3/4, CMOEA-2S Fig. 3/4/5 |
| Fig. 6 | IGD 收敛曲线 | CF6, LIRCMOP3, DASCMOP5, DOC8, MW12 | CMOEA-AOP Fig. 5, CMOEA-2S Fig. 7 |
| Fig. 7 | 算子比例轨迹 | 同 Fig. 6 问题 | CMOEA-2S stage trace 的对应版本 |
| Fig. 8 | Survival credit 热力图 | 56 问题按问题族排列 | 我们自己的机制图 |
| Fig. 9 | 消融收敛曲线 | LIRCMOP3, DASCMOP8, DOC8 | CMOEA-2S Fig. 8 |
| Fig. 10 | 参数敏感性图 | 15 个代表问题 | CMOEA-2S Fig. 9 |
| Fig. 11 | 平均运行时间图 | 56 问题均值 | CMOEA-2S Fig. 10 |

最终解集图不要选太多。主文建议 5 个左右，每个问题族 1 个；附录可放更多。

## 8. 实验章节的 1:1 复刻版目录

建议正式论文实验章节写成如下结构。

```text
4. Experimental Studies
   4.1 Experimental Settings
       4.1.1 Benchmark Problems
       4.1.2 Compared Algorithms
       4.1.3 Parameter Settings
       4.1.4 Performance Indicators and Statistical Tests

   4.2 Overall Performance on Standard CMOPs
       Table: Friedman ranking
       Table: Wilcoxon summary
       Table: suite-level ranks

   4.3 Performance on Different Benchmark Suites
       4.3.1 Performance on CF
       4.3.2 Performance on LIR-CMOP
       4.3.3 Performance on DAS-CMOP
       4.3.4 Performance on DOC
       4.3.5 Performance on MW

   4.4 Visualization and Convergence Analysis
       final solution sets
       IGD/HV convergence curves

   4.5 Further Discussion on Operator Portfolio
       operator proportion traces
       survival-credit heatmaps
       problem-suite preference analysis

   4.6 Ablation Study
       portfolio mechanism ablation
       credit signal ablation

   4.7 Parameter Sensitivity Analysis
       creditAlpha
       creditFloor

   4.8 Performance on Real-World Problems
       RWMOP HV
       feasible rate

   4.9 Running Time Analysis
       runtime table/figure
       complexity discussion
```

这个结构基本就是把 CMOEA-2S 的实验章节复制成我们的版本，再把 CMOEA-AOP 的多算子动机和消融嵌进去。

## 9. 从现在开始的执行顺序

### 第一阶段：补齐主论文数据

目标：得到可以支撑论文主结论的数据。

1. 跑 S11 主实验：10 算法、56 问题、30 run、N=100、MaxFE=100000。
2. 统计 IGD、HV、FR、runtime。
3. 生成 Wilcoxon、Friedman、问题族排名。
4. 保存代表问题最终种群和收敛曲线。

完成后可以写：

```text
SCOP-CMOEA 在大规模标准 CMOP benchmark 上具有整体竞争力。
```

### 第二阶段：补齐机制证据

目标：证明算法不是偶然调参，而是 survival credit 机制有效。

1. 跑算子组合和比例方式消融。
2. 跑信用信号消融。
3. 画算子比例轨迹和 survival credit 热力图。
4. 画典型问题消融收敛曲线。

完成后可以写：

```text
SCOP-CMOEA 的主要收益来自 survival-credit driven portfolio allocation，而不是简单多算子共存、随机动态或固定阶段规则。
```

### 第三阶段：补齐论文完整性

目标：让实验章节像正式 2026 论文，而不是只有主表。

1. 参数敏感性：`creditAlpha` 和 `creditFloor`。
2. RWMOP 应用实验。
3. 运行时间分析。
4. 高预算补充实验，检查 MaxFE=200000 下是否稳定。

完成后可以写：

```text
SCOP-CMOEA 是一个训练无关、参数不敏感、可解释且在标准和真实问题上都具有竞争力的方法。
```

### 第四阶段：写作

建议写作顺序：

1. 先写 Experimental Settings，因为数据和设置最客观。
2. 再写 Results and Discussion，因为表格出来后容易写。
3. 再写 Method，因为需要和结果中的机制图对应。
4. 最后写 Introduction 和 Abstract，因为故事要根据最终结果收口。

## 10. 当前状态和还缺什么

### 已经完成

- 已经完成围绕 CMOEA-AOP 的机制拆解探索。
- 已经完成 S10a 的 22 算法、56 问题、5-run 筛选。
- 已经得到正式对比算法 shortlist。
- 已经形成 SCOP-CMOEA 的核心论文故事：environmental selection as credit assignment。

### 还不能直接写正式论文主结果的原因

- S10a 是 5-run 筛选，不是 30-run 正式实验。
- 主实验还需要 HV、FR、runtime。
- 机制图需要从最终 30-run 或代表 run 中整理比例轨迹和存活轨迹。
- 真实问题和参数敏感性还没有形成论文级证据。

### 下一步最应该做的事

按优先级排序：

1. S11 主实验 30-run。
2. S11 统计分析和主表。
3. 机制消融 30-run。
4. 机制图和收敛图。
5. 参数敏感性。
6. RWMOP 应用实验。
7. runtime 和高预算补充。

如果资源有限，必须先完成 1 到 4。没有主实验，论文缺性能证据；没有消融和机制图，论文缺创新证据。

## 11. 这篇论文最终可以讲成什么

如果 S11 和消融结果确认当前趋势，论文可以形成下面的主结论：

```text
SCOP-CMOEA demonstrates that environmental selection can be reused as an endogenous credit assignment mechanism for adaptive offspring generation in constrained multi-objective optimization.
```

中文：

```text
SCOP-CMOEA 说明，环境选择不仅可以筛选解，还可以作为一种内生信用机制，指导约束多目标优化中的 offspring 生成资源分配。
```

这个结论的价值在于：

- 它不是只解释某个已有算法。
- 它不是把 DDPG 简化一下。
- 它提出了一条不同于外部学习器的路线：从进化过程自身产生反馈。
- 它可以自然扩展到更多算子、更多种群角色、更多约束处理框架。

建议论文题目方向：

1. `Environmental Selection as Credit Assignment: A Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization`
2. `Survival-Credit Operator Portfolio for Constrained Multi-objective Evolutionary Optimization`
3. `Feedback-Driven Offspring Resource Allocation for Constrained Multi-objective Optimization`

最推荐第 1 个。它直接把论文故事讲出来：环境选择不只是选择器，也是信用分配器。
