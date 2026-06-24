# SCOP-CMOEA 论文实验设计方案

## 1. 实验设计目标

这篇论文的实验部分要回答三个层次的问题。

第一，SCOP-CMOEA 是否是一个有竞争力的约束多目标优化算法。这个问题由正式 30-run 对比实验回答。

第二，SCOP-CMOEA 的优势是否来自 survival-credit operator portfolio，而不是仅仅来自 EMCMO 框架、多算子共存或随机比例变化。这个问题由机制消融实验回答。

第三，survival credit 是否能形成可解释的搜索行为。这个问题由算子比例轨迹、存活率轨迹、问题族分析和典型 PF 图回答。

因此论文实验不能只放一张大表。参考 2026 年 CMOP 论文的写法，完整实验结构应包含：主 benchmark、统计检验、消融、参数敏感性、机制可视化、运行时间和真实问题。

## 2. 参考论文给我们的实验模板

| 论文 | 实验写法 | 对我们的启发 |
| --- | --- | --- |
| TriMT-EA | 标准 CMOP + RWMOP；IGD/HV；30 run；Wilcoxon + Friedman；消融和参数敏感性 | 我们也应有标准问题、真实问题、消融和参数分析 |
| DSOCOL | 标准 CMOP、大规模/欺骗约束、real-world；Friedman + Holm；多变体消融 | 正式结果要有统计检验和机制变体，不只报均值 |
| M3TMO | CMOP + CMMOP + 应用；主/辅任务消融；迁移成功率分析 | 我们可以用“EMCMO 双种群 + 算子信用”讲机制 |
| NMOEA | CF/MW benchmark；算子/约束处理消融；真实电力调度应用 | 算子自适应机制必须有固定算子或去自适应对照 |
| SSCF | IGD/HV/FR；Friedman 和 post-hoc；边界采样机制解释 | 可行率 FR 应保留，避免只看 IGD/HV |
| RL 算子选择论文 | 固定算子、随机算子、学习算子对照；状态/奖励解释 | 我们要强调 survival credit 是训练无关的反馈控制 |

结论：我们的实验章节应按“性能、统计、机制、可解释性、应用”展开。

## 3. 正式主实验 S11

### 3.1 对比算法

推荐主实验使用 10 个算法。

| 类型 | 算法 | 选择理由 |
| --- | --- | --- |
| 本文算法 | SCOP-CMOEA | survival-credit operator portfolio |
| 直接相关 | CMOEA-AOP | DDPG 控制算子比例，必须比较 |
| 基础框架 | EMCMO | 证明收益不是只来自双种群框架 |
| 强竞争者 | ICMA | S10a 平均排名第 2 |
| 强竞争者 | IMTCMO | S10a 平均排名第 3，问题胜场最多 |
| 强竞争者 | DRLOS-EMCMO | RL/动态选择类强对手，和 EMCMO 关系近 |
| 强竞争者 | CMOES | S10a 平均排名第 6 |
| 问题族补充 | DPCPRA | MW 问题族很强，防止只挑有利算法 |
| 经典约束方法 | PPS | push-pull 类经典方法 |
| 经典约束方法 | C-TAEA | 双档案经典方法 |

可选增加 CMOEMT，形成 11 个算法。CMOEMT 在 S10a 排名第 7，整体不弱。若计算资源允许，建议加入；若主表希望简洁，放到补充实验。

不建议主表保留 ToP。S10a 中 ToP 失败问题较多，平均排名最后。除非审稿或目标期刊特别期待它，否则不适合放进主表。

### 3.2 测试问题

正式主实验建议继续使用 56 个问题。

| 问题族 | 数量 | 作用 |
| --- | ---: | --- |
| CF | 10 | 与 CMOEA-AOP 原论文重合，检验经典复杂约束 |
| LIR-CMOP | 14 | 检验大不可行区域和局部可行前沿 |
| DAS-CMOP | 9 | 检验难度可调约束 |
| MW | 14 | 检验窄可行域和复杂边界 |
| DOC | 9 | 补充更复杂约束景观 |

这 56 个问题应作为主 benchmark 全部保留。原因是 S10a 已经显示 SCOP-CMOEA 的优势在不同问题族上不均匀：DAS-CMOP、MW、DOC 上更强，LIR-CMOP 上接近打平。如果删掉某些问题族，会改变论文结论。

### 3.3 参数设置

主实验建议采用统一设置：

| 项目 | 设置 |
| --- | --- |
| 种群规模 | N=100 |
| 最大评价次数 | maxFE=100000 |
| 独立运行次数 | 30 |
| 指标 | IGD、HV、Feasible rate、Runtime |
| 统计检验 | Wilcoxon rank-sum test, p=0.05 |
| 总体排序 | Friedman average rank |
| 后验比较 | Holm 或 Bergmann-Hommel，可作为补充 |

为什么主实验先用 maxFE=100000：S10a 已经在这个预算下形成清晰结果，而且 56 个问题与 10 个算法的 30-run 总量已经较大。为了与部分 2026 论文中更高预算设置对齐，可以增加一个补充实验：LIR-CMOP 用 300000 FE、DAS-CMOP 用 200000 FE，测试 SCOP-CMOEA 在长预算下是否仍稳定。

### 3.4 主实验应出的表

| 表号 | 内容 | 目的 |
| --- | --- | --- |
| Table 1 | 测试问题和参数设置 | 说明 56 个问题、N、maxFE、run、指标 |
| Table 2 | 对比算法列表和类别 | 说明为什么选这些算法 |
| Table 3 | IGD 均值和标准差，按问题列出 | 主性能表 |
| Table 4 | HV 均值和标准差，按问题列出 | 主性能表 |
| Table 5 | Feasible rate 或失败问题统计 | 说明可行性稳定性 |
| Table 6 | Wilcoxon 胜/负/平汇总 | 展示相对各对比算法的显著性 |
| Table 7 | Friedman 平均排名 | 展示整体排序 |
| Table 8 | 按问题族的平均排名 | 展示 CF/LIR/DAS/MW/DOC 上的差异 |
| Table 9 | Runtime 平均值和排名 | 说明无训练开销的计算优势 |

主文不一定放下所有 56 个问题的 IGD/HV 完整表。可以主文放 Friedman、Wilcoxon 汇总、问题族排名和关键均值表，完整 56 问题均值/标准差放附录。

### 3.5 主实验应出的图

| 图号 | 内容 | 目的 |
| --- | --- | --- |
| Fig. 1 | SCOP-CMOEA 总体框架图 | 说明双种群、算子组合、survival credit 闭环 |
| Fig. 2 | Survival credit 更新示意图 | 说明 offspring 标记、环境选择、信用更新 |
| Fig. 3 | S10a 发现路线图 | 说明从拆解 CMOEA-AOP 到形成 SCOP-CMOEA |
| Fig. 4 | 典型问题的 PF/CPF 散点图 | 展示收敛和分布，例如 DASCMOP、MW、DOC 各选 1-2 个 |
| Fig. 5 | IGD 收敛曲线 | 展示不同算法随 FE 的收敛过程 |
| Fig. 6 | 算子比例随 FE 变化曲线 | 展示 survival credit 学到的阶段性行为 |
| Fig. 7 | 算子存活率热力图 | 展示不同问题族偏好的算子不同 |
| Fig. 8 | 问题族平均排名雷达图或柱状图 | 展示 SCOP-CMOEA 的优势分布 |

Fig. 3 很重要。它不是最终实验结论图，而是论文故事图：先拆多算子、再拆动态比例、再拆信用信号、最后形成 survival-credit operator portfolio。这个图能把论文从“改别人算法”提升到“通过机制发现提出新算法”。

## 4. 机制消融实验

机制消融应分成两组。

### 4.1 算子组合与动态比例消融

这一组回答：SCOP-CMOEA 的收益是不是只来自多算子共存或随机动态。

推荐方法：

| 方法 | 含义 |
| --- | --- |
| EMCMO | 基础框架，不做 operator portfolio |
| GA-only | 只用 GA/SBX |
| DE-rand-only | 只用 DE/rand/1 |
| DE-best-only | 只用 DE/best/1 |
| Equal-AOP | 三算子均匀比例 |
| Random-AOP | 每代随机比例 |
| Stage-AOP | 人工阶段比例 |
| SCOP-CMOEA | survival credit 动态比例 |
| CMOEA-AOP | DDPG 动态比例 |

建议在 56 个问题上做 30 run；如果时间紧，可以先用 56 个问题 10 run，主文写 30 run 结果。

应出表：

- 消融 IGD/HV 平均排名。
- 相对 SCOP-CMOEA 的胜/负/平。
- 按问题族的消融排名。

应出图：

- Equal、Random、Stage、SCOP、CMOEA-AOP 的算子比例轨迹对比。
- 典型问题上消融方法的 IGD 收敛曲线。

### 4.2 信用信号消融

这一组回答：为什么 survival 是合适的信用，而不是只看可行率、CV 或目标改进。

推荐方法：

| 方法 | 信用信号 |
| --- | --- |
| Survival-Credit | offspring 是否被环境选择保留 |
| Feasibility-Credit | offspring 是否可行 |
| CV-Credit | offspring 是否降低约束违反 |
| Objective-Credit | offspring 是否改善目标 |
| Mixed-Credit | survival + feasibility + CV |
| Sliding-Survival-Credit | 平滑 survival credit |

应出表：

- 各信用信号的平均排名。
- 各问题族排名。
- 相对 survival credit 的胜/负/平。

应出图：

- 不同信用信号下的算子比例轨迹。
- 信用信号和最终性能的相关图。

这组实验是论文机制解释的核心。它能证明 SCOP-CMOEA 不是随便选了一个反馈，而是 survival feedback 在 CMOP 中天然整合了目标、约束和多样性压力。

## 5. 参数敏感性实验

SCOP-CMOEA 至少需要分析两个参数。

| 参数 | 建议测试值 | 含义 |
| --- | --- | --- |
| creditAlpha | 0.12, 0.25, 0.35, 0.50 | 信用更新速度 |
| creditFloor | 0.00, 0.03, 0.05, 0.10 | 算子最小保留比例 |

当前默认值为 `creditAlpha=0.35`，`creditFloor=0.05`。

建议不要在全部 56 个问题上做 full factorial 30 run，成本太高。可以选代表性问题：

| 问题族 | 代表问题 |
| --- | --- |
| CF | CF3, CF5, CF8 |
| LIR-CMOP | LIRCMOP3, LIRCMOP10, LIRCMOP13 |
| DAS-CMOP | DASCMOP1, DASCMOP5, DASCMOP9 |
| MW | MW5, MW9, MW12 |
| DOC | DOC1, DOC5, DOC8 |

共 15 个问题，每个设置 20 或 30 run。主文放热力图，附录放完整表。

## 6. 机制可解释性实验

这部分不以“比谁更好”为主，而是解释 SCOP-CMOEA 的工作方式。

建议从 policyTrace 里提取：

1. 三个算子的平均使用比例。
2. 三个算子的 offspring 存活率。
3. 早期、中期、后期的比例变化。
4. 按问题族统计的算子偏好。
5. SCOP-CMOEA 和 CMOEA-AOP 的比例轨迹差异。

可写出的机制结论应类似：

- SCOP-CMOEA 不是固定偏向某一个算子，而是随问题族改变比例。
- Survival credit 往往在早期保留探索型算子，在后期提高更有收敛贡献的算子。
- 不同问题族上的比例差异可以解释性能差异。
- 即使没有 DDPG，环境选择反馈也能形成阶段性搜索行为。

## 7. 真实问题或应用实验

建议增加 RWMOP 应用实验，但不要替代 56 个标准问题。

推荐方案：

| 方案 | 内容 | 用途 |
| --- | --- | --- |
| 轻量方案 | RWMOP1-RWMOP20 | 主文应用补充 |
| 完整方案 | RWMOP1-RWMOP50 | 附录或补充材料 |

对比算法不必保留全部 10 个，可以用 6 到 8 个：

SCOP-CMOEA、CMOEA-AOP、EMCMO、ICMA、IMTCMO、DRLOS-EMCMO、DPCPRA、PPS。

指标：

- HV，主指标，因为真实 CPF 通常未知；
- feasible rate；
- runtime。

应出表：

- RWMOP HV 均值和标准差；
- 可行率；
- Wilcoxon 胜/负/平。

应出图：

- RWMOP 按问题类型的 HV 箱线图；
- 典型工程问题的目标空间散点图。

## 8. 运行时间和复杂度实验

SCOP-CMOEA 的故事里有一个优势：不需要训练 DDPG，不需要 replay buffer，不需要神经网络更新。

因此必须报告运行时间。

建议出两类结果：

1. 理论复杂度对比：SCOP-CMOEA 相对 EMCMO 只增加 offspring 来源标记、存活计数和比例更新，额外复杂度约为 `O(N)`；CMOEA-AOP 还包含 DDPG 训练和动作计算。
2. 实际 runtime 表：在 56 个问题上统计每个算法平均 runtime，并给出 SCOP-CMOEA 与 CMOEA-AOP、EMCMO 的比值。

如果 SCOP-CMOEA 性能强且 runtime 接近 EMCMO，这会成为很有力的卖点。

## 9. 论文实验章节建议结构

建议实验章节按如下顺序写：

1. Experimental Settings
   - benchmark problems
   - compared algorithms
   - parameter settings
   - metrics and statistical tests
2. Overall Performance on Benchmark CMOPs
   - IGD/HV/Friedman/Wilcoxon
3. Performance by Problem Suite
   - CF、LIR-CMOP、DAS-CMOP、MW、DOC 分析
4. Ablation Study
   - operator portfolio 消融
   - credit signal 消融
5. Mechanism Analysis
   - operator ratio trace
   - survival credit trace
   - convergence curves and PF plots
6. Parameter Sensitivity
   - alpha 和 floor
7. Runtime Analysis
8. Real-world CMOPs
9. Discussion
   - 什么时候 SCOP-CMOEA 强
   - 什么时候不占优
   - survival credit 的适用边界

## 10. 实验执行优先级

第一优先级：

1. S11 主实验：10 个算法，56 个问题，30 run。
2. S11 统计表：IGD、HV、FR、runtime、Wilcoxon、Friedman。

第二优先级：

3. 消融实验：EMCMO、Equal、Random、Stage、SCOP、CMOEA-AOP。
4. 信用信号实验：Survival、Feasibility、CV、Objective、Mixed、Sliding。

第三优先级：

5. 机制轨迹图：算子比例、存活率、阶段变化。
6. 参数敏感性：alpha 和 floor。

第四优先级：

7. RWMOP 应用实验。
8. LIR-CMOP/DAS-CMOP 高预算补充实验。

如果时间和算力有限，必须先完成第一优先级和第二优先级。没有 30-run 主实验，论文缺主证据；没有消融，论文缺机制证据。
