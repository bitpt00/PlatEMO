---
knowledge_id: K-phenotypic-elite-archive-niching-gp-search
name: 行为表征精英档案引导的 GP 搜索收缩与小树小生境
type: method
status: active
source_papers: [P2026-0197]
aliases: [NSGP-II-NA, phenotypic characterization archive, elite individual guided dynamic space optimization, PC-based niching, behavior-driven niching, small-tree representative selection, GP elite archive, 表型表征, 行为表征, 精英档案搜索收缩, 小树小生境, 多目标动态调度]
promotion_reason: 单篇论文提出但接口完整，包含 PC 行为表征、非支配精英 archive、reward/punishment 清洗、archive 距离中位数自适应搜索半径、PC 分组小生境和最小树大小代表选择，可直接改造 GP 调度规则学习、程序搜索和可解释规则演化
---

# 行为表征精英档案引导的 GP 搜索收缩与小树小生境

## 核心内容

在 GP 或程序/规则进化中，不只按目标值和基因型选择个体，而是先用一组代表性决策情境计算个体行为表征 PC。每代把非支配且 PC 不重复的个体存入精英 archive，并用 archive 内 PC 距离的中位数作为自适应搜索半径。新 offspring 必须靠近某个精英行为区域但不与已有 offspring 行为重复，从而把搜索逐步收缩到 promising 行为空间。同时，对当前种群按 PC 分组形成小生境，在组内优先保留 rank 好且树更小的个体，控制规则复杂度和解释性。

```text
GP population evaluated by simulation/objectives
-> nondominated sorting
-> rank-0 and PC-novel individuals enter elite archive
-> archive counters remove unstable mutant elites
-> population grouped by PC
-> rank-weighted group selection + smallest tree representative
-> offspring accepted if 0 < distance_to_archive < alpha
-> alpha = median pairwise PC distance in archive after warm-up
```

## 建立理由

- 为什么值得独立维护：
  - GP 个体的语法结构相似性不一定等于调度/决策行为相似性，行为 PC 更适合做 diversity 与搜索空间控制。
  - 历代非支配规则包含有价值的行为分布信息，archive 可从“保存好个体”升级为“反推 promising 行为半径”。
  - 可解释规则学习不仅要高质量，还要控制树大小；在同一行为小生境中选小树代表是低成本复杂度压缩。
  - 该机制可迁移到调度规则、路由规则、符号回归、规则分类器和其他 GP/程序进化任务。
- 与已有设计知识的区别：
  - 不同于“偏好条件单启发式的 Pareto 集学习”，本知识不把 preference vector 作为输入学习单一 heuristic，而是维护多条 Pareto 规则，并用 PC archive 指导搜索收缩和解释性控制。
  - 不同于“异步子任务精英池协同进化”，本知识不解决多子任务异步通信，而是在单个 MO-GP 搜索中用行为 archive 定义 offspring 接受区域。
  - 不同于“单侧规则-分类器双阶段 Pareto 进化”，本知识不面向分类规则的两阶段 archive，而是面向 GP 程序/调度规则的行为表征、niching 和树大小控制。
  - 不同于普通 external archive，本知识会分析 archive 内 PC 距离分布并反馈到下一代搜索。

## 解决的问题

- 适用场景：
  - 候选解是程序、规则、树、策略或启发式，基因型距离不能可靠反映行为差异；
  - 可构造一组代表性决策情境，用候选的排序、动作或输出形成行为表征；
  - 需要维持 Pareto 解质量与行为多样性，同时避免规则/程序过大；
  - 历代非支配个体的行为区域对后续搜索有指导价值。
- 现有方法为什么会失败或不足：
  - 普通 NSGA-II/GP 在整个 heuristic space 中搜索，容易浪费在远离优质行为区域的个体；
  - archive 只保存精英而不分析分布，无法帮助子代生成；
  - 基于语法或树编辑距离的小生境可能把行为相同但语法不同的规则误当多样；
  - 单纯以 Pareto rank 选择会保留过大的规则树，降低解释性和部署便利性。

## 为什么可能有效

```text
同 PC 个体在代表情境中行为相似
-> 非支配 PC 分布近似提示高价值行为区域
-> archive 距离中位数给出阶段性搜索半径
-> offspring 靠近精英但互不重复，兼顾开发与多样性
-> PC 分组内选择小树，删除行为冗余复杂规则
-> Pareto front 更紧凑、更高质、更易解释
```

关键假设是：选取的决策情境能覆盖真实任务中的关键行为差异，且 PC 距离与目标表现存在足够相关性。若 PC 太粗、决策情境不代表真实分布，或好规则需要远离当前 archive 的新行为模式，该机制可能过早收缩。

## 实现接口

- 行为表征：
  - 准备固定或动态的一组 decision situations；
  - 对每个候选规则，记录其在每个情境下的排序、动作、类别或连续输出离散化结果；
  - 将 routing/sequencing 或多模块行为拼接成 PC 向量。
- Archive update：
  - 非支配排序后取 rank 0 个体；
  - 若与 archive 中个体 PC 距离为 0，则视为重复不加入；
  - 每个 archive 个体维护 counter，表现退化则惩罚，超过阈值移除。
- Niching selection：
  - 当前种群按 PC 完全相同或近邻聚类分组；
  - 组内按 rank 权重选择保留层；
  - 在保留层中选择树大小最小、运行成本最低或复杂度最小的代表。
- Offspring filter：
  - 前若干代使用最大半径或不限制，避免随机 archive 过早主导；
  - 之后计算 archive 内两两 PC 距离分布，用中位数或分位数作为 `alpha`；
  - 接受 `0 < minDistance(offspring, archive) < alpha` 且不与已生成 offspring 重复的候选。

## 如何用于算法创新

### 局部创新

- 将固定随机 PC 情境换成 active situations：优先选历史上区分 Pareto 规则、失败案例或高不确定性的情境。
- 将 PC 完全相同分组扩展为 DBSCAN、Hamming radius 或 learned behavior embedding 聚类。
- 将 `alpha` 中位数替换为多簇局部半径，避免 archive 多峰时全局中位数过大或过小。
- 在组内代表选择中加入 tree size、执行时间、符号可读性、规则稳定性和人工偏好。
- 对 archive counter 使用跨场景稳健性、测试实例泛化或近期贡献率，而不是只看当前 rank。

### 结构创新

- 构建行为驱动的可解释程序搜索框架：

```text
program population
-> behavior characterization
-> elite behavior archive
-> adaptive search radius
-> behavior niching and complexity pruning
-> interpretable Pareto program set
```

- 与偏好条件 GP 结合：用 PC archive 保留不同偏好下行为活跃的规则，同时用小树小生境压缩单规则复杂度。
- 与多任务/多场景调度结合：archive counter 只奖励跨场景稳定的 PC，惩罚只在个别实例上偶然好的 mutant。
- 用于规则分类器或符号回归：PC 可定义为样本输出排序、决策边界响应或局部解释模式。

## 适用条件与风险

- 适用条件：
  - 候选是可解释程序/规则/树，且复杂度需要控制；
  - 能构造代表性行为测试情境；
  - 行为相似性比语法相似性更重要；
  - archive 维护和 PC 计算成本低于仿真评价成本。
- 不适用或可能失效的条件：
  - 决策情境太少或不代表真实任务，PC 距离失真；
  - 初期 archive 被偶然好个体占据，过早收缩搜索；
  - 高质量解需要跨越远离现有精英的行为区域，offspring filter 会阻止探索；
  - 最小树代表选择会偏向欠表达的简单规则；
  - 连续动作/输出难以离散化时，PC 距离设计较难。
- 计算与实现成本：
  - 每代需要为个体计算 PC、分组、archive 距离和树大小；
  - archive 两两距离在 archive 大时需要近似或缓存；
  - offspring filter 可能导致重复生成和拒绝，需设置最大尝试次数。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0197 | 作者指出 NSGP-II 没有利用历代 Pareto fronts 中非支配个体的分布信息指导搜索 | 问题动机 | Sec. I，PDF 2 |
| P2026-0197 | 用 20 个 routing 和 20 个 sequencing 决策情境形成 40-D PC，并用 PC 距离判断行为相似和 archive 重复 | 作者采用/组合方法 | Sec. III-B、Eq. (1)、Table I，PDF 4-5 |
| P2026-0197 | Algorithm 1 将 rank 0 且 PC 不重复的个体加入 elite archive，并用 counter 移除表现退化的 mutant individuals | 作者提出的方法 | Sec. III-B、Algorithm 1，PDF 4-5 |
| P2026-0197 | Algorithm 2 和 Fig. 4 按 PC 分组，用 `1/(rank+1)` 概率加权选择，并在同组中保留 tree size 最小个体 | 作者提出的方法 | Sec. III-C、Algorithm 2，PDF 5 |
| P2026-0197 | Elite-guided dynamic space optimization 用 offspring 到 archive 的最小 PC 距离与自适应 `alpha` 控制搜索空间，前 5 代使用最大距离避免早熟 | 作者提出的方法 | Sec. III-D、Fig. 5，PDF 5-6 |
| P2026-0197 | `alpha` 取 archive 内个体两两 PC 距离的中位数，作者认为可抗 outlier 并保持搜索空间不太宽/窄 | 机制设计 | Sec. III-D，PDF 6 |
| P2026-0197 | NSGP-II-NA 在 12 个 MO-DFJSS 场景中整体取得更高 HV、更低 IGD，并优于 NSGP-II 和 NSGP-II-N | 综合实验支持 | Sec. V-A、Table IV、Figs. 6-7，PDF 7-10 |
| P2026-0197 | NSGP-II-NA 优于 8 个人工 routing/sequencing rule 组合，显示演化规则泛化能力 | 应用实验支持 | Sec. V-A、Table V，PDF 8-9 |
| P2026-0197 | NSGP-II-NA 的 learned Pareto fronts 在 12 个场景中支配 NSGP-II 的 fronts | Pareto front 证据 | Sec. V-C、Fig. 10，PDF 10-11 |
| P2026-0197 | 规则大小实验显示 niching strategy 在多数场景中以相近 fitness 得到更小规则树，提高解释性 | 消融/解释性支持 | Sec. V-D、Fig. 11，PDF 10-11 |
| P2026-0197 | Entropy 曲线显示 NSGP-II-NA 多样性最高；自适应距离下降并稳定，说明搜索空间逐渐聚焦 | 机制分析 | Sec. V-E、VI-C、Figs. 12、15，PDF 11-13 |
| P2026-0197 | 训练时间与 NSGP-II 无显著差异，说明改进质量未明显增加计算成本 | 成本证据 | Sec. VI-D、Table VI，PDF 13 |
| P2026-0197 | 作者未来工作包括优化 niching strategy 并探索其他 dynamic events | 作者未来工作 | Sec. VII，PDF 14 |

## 证据边界

- 当前只有单篇论文证据。
- 验证对象是 MO-DFJSS 的 GP 调度规则，其他 GP/程序搜索任务需复验。
- 实验只覆盖动态随机新作业到达，未覆盖机器故障、紧急插单、运输约束等复杂动态事件。
- 所有场景为二目标组合，many-objective 调度下 PC archive 和小生境效果仍未知。
- PC 情境随机选取，若情境集不稳定或不代表真实部署分布，行为距离可能失真。

## 待确认

- 如何自动选择或更新最有区分度的 PC decision situations；
- archive 多峰时是否应使用簇内局部 `alpha`；
- 在高噪声仿真中，counter 处罚阈值是否需要统计置信度；
- 小树代表选择与 Pareto 质量之间的长期 tradeoff；
- 与偏好条件 GP、代理评价和多动态事件仿真结合后的效果。
