---
knowledge_id: K-coarse-fine-clustering-density-competing-mmop
name: 粗细聚类与密度独立竞争的多模态识别
type: method
status: active
source_papers: [P2026-0237]
aliases: [TSCICEA, two-stage clustering, independent competing strategy, ICS, K-means DBSCAN MMOP, coarse-to-fine modality clustering, density-aware competing, 粗细聚类, 两阶段聚类, 独立竞争, 密度自适应子种群选择]
promotion_reason: 单篇论文提出但接口完整，包含 K-means 粗聚类、DBSCAN 细聚类、动态半径、阶段阈值、子种群密度驱动的局部/全局竞争切换和多组消融证据，可直接改造 MMOP 多子种群环境选择与模态识别层
---

# 粗细聚类与密度独立竞争的多模态识别

## 核心内容

在多模态多目标优化中，先根据演化阶段选择不同聚类粒度：早期种群分散，使用 K-means 快速粗分多个潜在模态区域；后期种群已聚集，使用 DBSCAN 按密度细分并修正早期错聚个体。聚类后，每个子种群被视为负责一个模态，并独立执行竞争选择：密度高或规模足够的子种群用局部 fitness 加强内部精细竞争，密度低的子种群用全局 dominance/neighborhood fitness 降低局部过压，避免小模态被误杀。

```text
Joint population
-> early stage: K-means, K by Calinski-Harabasz
-> late stage: DBSCAN, dynamic epsilon
-> subpopulations as modality candidates
-> if subpopulation dense enough: local competing
-> otherwise: global competing
-> merge survivors from all subpopulations
```

## 建立理由

- 为什么值得独立维护：
  - 它把 MMOP 的模态识别拆成“阶段化聚类”和“子种群密度自适应选择”两个清楚接口；
  - 许多多子种群算法可以直接替换其固定聚类或统一 survivor selection，而不用复用完整 TSCICEA。
- 单篇具体方法的直接复用价值：
  - P2026-0237 给出 TSCICEA Algorithm 1、ICS Algorithm 2、参数敏感性、K-means/DBSCAN 消融、Competing1/2 消融和 46 个 benchmark 证据；
  - 复杂度为常见 EMO 可接受的 `O(MN^2)` 级别，且论文报告平均 CPU time 最低。
- 与已有设计知识的区别：
  - 不同于“级联聚类驱动的多模态子种群阶段管理”：该知识依赖级联聚类、相似子种群合并和 NMI 阶段稳定性，主要来自稀疏大规模 MMOP；本知识使用 K-means/DBSCAN 粗细切换，并增加密度驱动的独立竞争选择。
  - 不同于“全局非支配占比驱动的子种群均衡进化”：该知识解决子种群进化进度不均衡；本知识先解决模态划分和每个子群内部采用哪种竞争方式。
  - 不同于“时空图学习的多模态 PS 子代生成”：该知识学习历史图并生成子代；本知识不训练模型，作用于环境选择和模态识别。
  - 不同于一般 K-means 聚类 MMOEA：这里明确早期用 K-means 粗定位、后期用 DBSCAN 修正错聚，并让子群选择压力随密度改变。

## 解决的问题

- 适用场景：
  - MMOP 中多个等价 PS 在决策空间形成可聚类区域；
  - 早期种群分散、后期逐渐聚集，固定聚类方法不稳定；
  - 不同模态密度、规模和搜索难度不同；
  - 算法可以维护多个子种群并允许子种群并行选择。
- 现有方法为什么会失败或不足：
  - 固定 K-means 容易在后期复杂形状或噪声点上错分；
  - 固定 DBSCAN 在早期缺少粗定位时容易盲目聚类并丢失模态；
  - 所有子种群使用同一局部竞争会压制小/稀疏模态；
  - 所有子种群使用全局比较又会削弱密集模态内的精细识别。
- 仍需解决的问题：
  - 阶段阈值 `p` 如何自适应；
  - DBSCAN 半径和 `Minpts` 对尺度/维度的敏感性；
  - 子种群名额 `PN_i` 是否能保护小而重要的模态；
  - 约束、动态或混合变量 MMOP 中的聚类距离如何定义。

## 为什么可能有效

```text
early population is scattered
-> K-means quickly estimates rough modality locations
late population is clustered and may contain misassignments
-> DBSCAN uses density to refine complex modality shapes
each modality has different local density
-> dense subpopulations benefit from local competition
-> sparse subpopulations need global comparison and less pressure
-> multiple modalities are identified independently and in parallel
```

关键假设是：种群分布确实从分散向多个模态簇聚集，且决策空间距离能反映模态归属。如果真实 PS 交错、尺度差异大或模态间距不稳定，K-means/DBSCAN 都可能产生错分；此时需要学习距离、子空间聚类或模态档案纠偏。

## 如何用于算法创新

### 局部创新

- 在已有 MMOEA 的环境选择前加入两阶段聚类，将固定 K-means 或固定 DBSCAN 替换为粗细切换。
- 用 HDBSCAN、nearest-better clustering、谱聚类或 GMM 替换 DBSCAN/K-means，但保留“早期粗定位、后期细修正”结构。
- 将 `p=0.9` 替换为聚类稳定性、NMI、density entropy、模态数变化或 PS 覆盖改进触发。
- 将 ICS 的 Competing1/2 替换为局部 HV contribution、decision-space novelty、reference-vector rank 或可行性边界 fitness。
- 对小子种群设置最小保留名额或不确定性保护，防止 rare modality 被删除。

### 结构创新

- 构建多模态搜索控制器：

```text
evolution-state monitor
-> coarse/fine clustering selector
-> modality subpopulation manager
-> density-aware competing selector
-> survivor quota allocator
-> parallel modality exploitation
```

- 与子种群均衡进化结合：ICS 先选 survivors，再对全局竞争力低的子群追加局部进化。
- 与图学习子代生成结合：聚类得到的每个模态子群独立构图，分别训练或调用局部 reproduction model。
- 在动态 MMOP 中，用聚类结构突然变化或 DBSCAN 新增簇作为环境变化/模态变化信号。

## 适用条件与风险

- 适用条件：
  - 决策空间距离经过归一化，能大致反映模态相似性；
  - population size 足以支持多个子种群聚类；
  - 评价预算允许每代执行聚类和 ICS；
  - 子种群可独立选择并合并 survivors。
- 不适用或可能失效的条件：
  - 模态在决策空间高度重叠或呈非欧结构；
  - 高维距离集中严重，K-means/DBSCAN 均不稳定；
  - 子种群数量大于人口规模时，单个 survivor 可能不足以维持局部多样性；
  - `p` 过晚会让 K-means 错分持续太久，过早又让 DBSCAN 盲聚；
  - `Minpts` 和 `epsilon` 不合适会把噪声当模态或把小模态当噪声。
- 计算与实现成本：
  - DBSCAN 约 `O(N^2)`，K-means 约 `O(KNT)`，通常简化为 `O(N)`；
  - ICS 约 `O(N^2)`；
  - 每代总体复杂度约 `O(MN^2)`；
  - 实现上需要维护子种群名额分配、动态半径和局部/全局 fitness。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0237 | Algorithm 1 在 `NFE/MaxNFE < p` 时用 K-means，`K` 由 Calinski-Harabasz index 确定；否则用 DBSCAN | 作者提出的方法 | Sec. III-A-B，Algorithm 1，PDF 4-6 |
| P2026-0237 | DBSCAN 半径 `epsilon` 由动态因子 `beta=alpha*(1-NFE/MaxNFE)` 控制，`alpha=0.2`，`Minpts=5` | 作者提出/参数设置 | Sec. III-B，PDF 6 |
| P2026-0237 | Algorithm 2 中，后期且子种群规模大于 `Minpts` 时用 Competing1，否则用 Competing2 | 作者提出的方法 | Sec. III-C，Algorithm 2，PDF 5-7 |
| P2026-0237 | Competing1 在子种群内基于收敛与决策空间多样性 fitness 选择 survivors，适合密集子群 | 作者提出/组合方法 | Sec. III-C，PDF 6 |
| P2026-0237 | Competing2 使用全局 dominance/neighborhood fitness，适合低密度子群，避免局部竞争过强 | 作者提出/组合方法 | Sec. III-C，PDF 6-7 |
| P2026-0237 | 46 个 benchmark 中 TSCICEA 在 `I_EDRX` 上取得 40/46 个 best | 综合实验支持 | Sec. IV-B，Table II，PDF 7-8 |
| P2026-0237 | TSCICEA 在 `I_MST` 上取得 27/46 个 best，整体排名第一 | 综合实验支持 | Sec. IV-B，Table III，PDF 8-9 |
| P2026-0237 | TSCICEA 在 HV 上取得 41/46 个 best，作者归因于 ICS 的有效子种群搜索 | 综合实验支持 | Sec. IV-B，Table IV，PDF 9 |
| P2026-0237 | Friedman test 中 TSCICEA 在 `I_EDRX`、`I_MST`、HV 和综合 rank 上均排名第一 | 统计支持 | Sec. IV-B，Table V，PDF 9-10 |
| P2026-0237 | 46 个问题平均 CPU time 中 TSCICEA 最低，FPITSEA 第二 | 运行效率证据 | Sec. IV-C，Fig. 4，PDF 10 |
| P2026-0237 | 参数分析显示 `p=0.9` 时 `I_EDRX` 和 HV 综合较好，作者推荐该值 | 参数证据 | Sec. IV-D，Fig. 5，PDF 10 |
| P2026-0237 | 仅 K-means 决策空间较好但 HV 较弱，仅 DBSCAN HV 较好但决策空间较弱，two-stage clustering 折中最好 | 组件消融 | Sec. IV-E，Fig. 6，PDF 10-11 |
| P2026-0237 | 仅 Competing1 目标空间较好但决策空间差，仅 Competing2 决策空间较好，ICS 综合最好 | 组件消融 | Sec. IV-F，Fig. 7，PDF 11 |
| P2026-0237 | 作者未来工作包括进一步调参，并用于 wind farm layout optimization 和 engineering design | 未来工作 | Sec. V，PDF 11 |

## 待确认

- 当前 Markdown 中结果表和消融图为图片占位，精确均值、方差和显著性统计需回看 PDF/补充材料。
- `p=0.9` 是否只是该 benchmark 设置下较好，是否能自动调节。
- DBSCAN 的动态半径在高维、变量尺度不均或混合变量中是否可靠。
- 子种群名额分配是否会系统性偏向大模态。
- 与已有级联聚类、子种群均衡和图学习子代生成组合时，收益是否相加还是机制冗余。
