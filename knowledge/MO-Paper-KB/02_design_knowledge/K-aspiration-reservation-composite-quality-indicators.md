---
knowledge_id: K-aspiration-reservation-composite-quality-indicators
name: 愿望-保留水平驱动的复合质量指标
type: method
status: active
source_papers: [P2026-0222]
aliases: [DRP-based CQI, W-CQI, S-CQI, M-CQI, composite quality indicators, aspiration-reservation QI aggregation, 复合质量指标, 双参考点指标聚合]
promotion_reason: 单篇论文提出但接口清晰，包含单指标选择、DRP 归一化、弱/强/混合补偿聚合、Pareto compliance 条件和 18 算法 proof-of-concept，可直接用于多目标算法离线评价、算法选择和 indicator-based 搜索设计
---

# 愿望-保留水平驱动的复合质量指标

## 核心内容

将多个 quality indicators (QIs) 聚合为一个或一组 composite QIs 前，先为每个 QI 设定 reservation level 和 aspiration level，再把原始 QI 值映射到统一的 0-3 achievement scale。之后同时计算三类复合指标：W-CQI 允许完全补偿，给总体质量；S-CQI 不允许补偿，暴露最弱单项；M-CQI 折中二者，用于全局排序。

```text
choose QIs
-> convert all to maximization
-> set min/max + reservation/aspiration per QI
-> piece-wise normalize each QI to [0, 3]
   0-1: worse than reservation
   1-2: between reservation and aspiration
   2-3: better than aspiration
-> compute W-CQI, S-CQI, M-CQI
-> diagnose with W vs S and rank with M
```

## 建立理由

- 为什么值得独立维护：
  - 多目标算法评价常被单一 QI 选择左右，多个 QI 又难综合解释；
  - 该知识把“指标聚合”和“偏好阈值解释”结合起来，既能给排名，也能指出性能短板。
- 单篇具体方法的直接复用价值：
  - P2026-0222 给出 DRP-based CQI 的完整计算流程、三种补偿方案、Pareto compliance theorem 和 18 算法实验；
  - 该方法可直接用于 benchmark 报告、算法选择、参数调优和 indicator-based MOEA 设计。
- 与已有设计知识的区别：
  - 不同于“多实现有效距离综合指标”：该知识专门处理 MMOP 中目标空间与决策空间多等价解覆盖；本知识是通用 QI aggregation framework，可聚合任意单指标。
  - 不同于“统计等价驱动的多标签算法选择”：本知识先构造综合评价指标，不直接训练算法选择模型。
  - 不同于一般 HV/IGD/IGD+ 指标：本知识不定义新的单一距离，而是把多个既有指标放到带偏好阈值的统一尺度上。

## 解决的问题

- 适用场景：
  - 需要同时报告 convergence、spread、uniformity、cardinality 或其他多个性能标准；
  - 不同 QI 对算法排名不一致；
  - 希望指标值具有“低于可接受、达到期望、优于期望”的解释；
  - 高维目标下 HV 成本较高，需要可替代的综合评价视角；
  - 需要诊断算法最弱性能标准，而不是只给总体均分。
- 现有方法为什么会失败或不足：
  - 单一 QI 无法覆盖所有质量维度；
  - 加权和聚合会掩盖某一单指标极差的问题；
  - min-max 归一化只有相对位置，没有可接受/理想阈值含义；
  - 只用 HV 作综合评价在高维目标下可能太慢。
- 仍需解决的问题：
  - 如何选择和去冗余高度相关 QI；
  - 如何设定领域合理的 aspiration/reservation levels；
  - 如何在 stochastic/noisy 评价下加入置信区间；
  - 如何把 CQI 作为在线搜索指标时避免过度计算。

## 为什么可能有效

```text
每个 QI 只看部分性能
-> 选择互补 QI 覆盖多个标准
-> DRP 归一化让不同单位/方向可比较
-> reservation/aspiration levels 赋予可解释阈值
-> W-CQI 给总体表现
-> S-CQI 揭示最弱项
-> M-CQI 平衡整体排名与短板约束
```

关键假设是：所选 QI 确实覆盖分析者关心的性能维度，且 reservation/aspiration levels 代表合理偏好。如果阈值只是由不合适的数据集相对给出，CQI 的解释会随数据集偏移。

## 如何用于算法创新

### 局部创新

- 在算法实验报告中，将多指标表格转换为 W/S/M-CQI 三视图，同时保留单 QI 表用于追踪短板来源。
- 用 S-CQI 作为诊断信号：若 S-CQI 由 diversity 指标决定，则提高多样性维护；若由 convergence 指标决定，则加强收敛算子。
- 在算法选择中用 M-CQI 作为综合标签或排序目标，再用 W/S 差距筛除“总体高但短板严重”的候选算法。
- 用领域专家给定的 aspiration/reservation levels 替代纯 percentile levels。

### 结构创新

- 构建评价闭环：

```text
run algorithms
-> compute selected QIs
-> DRP normalize with domain thresholds
-> W/S/M-CQI ranking and diagnosis
-> feed diagnosis to algorithm configuration or operator scheduling
```

- 将 CQI 作为 indicator-based MOEA 的 selection indicator，权重和 `lambda` 控制综合补偿程度，S-CQI 防止某一性能标准崩塌。
- 在 automated benchmarking 中为不同问题族维护不同 DRP threshold profiles，形成可解释的跨问题族评价。

## 适用条件与风险

- 适用条件：
  - 单 QI 可计算且方向明确；
  - 评价者能接受或指定 reservation/aspiration levels；
  - 需要综合评价和短板诊断并重；
  - 聚合 QI 的计算成本可承受。
- 不适用或可能失效的条件：
  - QI 之间高度重复但被重复赋权；
  - 阈值由很小或有偏样本估计，导致 0-3 分段失真；
  - 所有 QI 都不 Pareto-compliant 且需要 Pareto compliance 保证；
  - 在线选择中 CQI 计算过慢。
- 计算与实现成本：
  - CQI 成本主要是所有被聚合 QI 的计算成本加上线性归一化/聚合成本；
  - 若选用低成本 QI，可作为高维目标下 HV 的低成本替代综合视角；
  - 若包含 HV 或其他昂贵指标，CQI 也会继承其成本。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0222 | DRP-based normalization 将 QI 值映射到 0-3，0-1 差于 reservation，1-2 介于 reservation/aspiration，2-3 优于 aspiration | 作者提出的方法 | Sec. III，PDF 5 |
| P2026-0222 | W-CQI 是 fully compensatory，S-CQI 是 noncompensatory，M-CQI 是两者线性组合且 `lambda` 控制补偿程度 | 作者提出的方法 | Sec. III，PDF 5-6 |
| P2026-0222 | 若聚合 QI 均 weakly Pareto-compliant 且至少一个 Pareto-compliant，则 W/M-CQI Pareto-compliant，S-CQI weakly Pareto-compliant | 理论性质 | Sec. III，Theorem 1，PDF 6 |
| P2026-0222 | 实验比较 18 个 PlatEMO 算法，在 DTLZ1、IDTLZ2、WFG1 的 3/5/8 目标版本上，每个算法 20 次运行 | 实验设置 | Sec. IV，PDF 6 |
| P2026-0222 | 实验中 reservation/aspiration levels 使用所有算法所有运行 QI 值的 25/75 百分位；M-CQI 使用 `lambda=0.5` | 参数设置 | Sec. IV，PDF 6、8 |
| P2026-0222 | 三目标 DTLZ1 上 LMEA W-CQI 最高但 S-CQI 低于 1.5，说明总体强但有接近 reservation 的短板 | 诊断案例 | Sec. IV-A，Fig. 1，PDF 7-8 |
| P2026-0222 | 同一问题上 EMyOC 的 S-CQI 最高，说明最差 QI 仍在期望区间；EFRRR W-CQI 第三但 S-CQI 低于 1，说明单项低于 reservation | 诊断案例 | Sec. IV-A，PDF 8 |
| P2026-0222 | 三目标 IDTLZ2/WFG1 上 AGEMOEAII W-CQI 最好，S-CQI 分别最好/第二好，W 超过 aspiration 且 S 在期望区间 | 诊断案例 | Sec. IV-A，PDF 8 |
| P2026-0222 | M-CQI 与 HV 排名在顶部和底部相近：AGEMOEAII 在两者下 4/9 个问题第一且其余前 6，DGEA 在两者下 6/9 最差、2/9 倒数第二 | 排名验证 | Sec. IV-A，Table II，PDF 8-9 |
| P2026-0222 | Wilcoxon rank-sum test 支持 M-CQI 排名的鲁棒性，三目标问题上 AGEMOEAII 几乎显著优于所有算法，除 EFRRR 有一个问题相近 | 统计支持 | Sec. IV-A，PDF 9-10 |
| P2026-0222 | 作者指出 CQI 可按需要聚合任意 QI，可用于综合或单一性能标准评价；若单 QI 不耗时，可作为高维目标下 HV 的低成本替代视角 | 适用性说明 | Sec. III / IV-A，PDF 6、10 |
| P2026-0222 | 未来工作包括分析单 QI 排名相对 CQI 的变化、引入多个 desirable reference levels、研究 CQI 在 indicator-based MOEA 中的表现 | 未来工作 | Sec. IV-A / V，PDF 10 |

## 待确认

- Table I 中四个具体单 QI 在当前 Markdown 中为图片占位，后续若需要可从补充材料/原 PDF 表格补全。
- 多个 QI 强相关时的权重校正或去冗余策略。
- 在真实工程 benchmark 中如何设定绝对 aspiration/reservation levels。
