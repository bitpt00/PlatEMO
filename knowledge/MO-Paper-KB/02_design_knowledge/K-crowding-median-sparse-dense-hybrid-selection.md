---
knowledge_id: K-crowding-median-sparse-dense-hybrid-selection
name: 拥挤中位分区的稀疏优先混合选择
type: method
status: active
source_papers: [P2026-0208]
aliases: [HS-NSGA-II hybrid selection, crowding distance median grouping, sparse-dense dynamic grouping, sparse-first NSGA-II truncation, median crowding split, hybrid selection-based NSGA-II, 稀疏密集动态分组, 中位拥挤距离选择, 稀疏优先环境选择]
promotion_reason: 单篇论文提出但接口明确，包含目标归一化、拥挤距离第一阶段保留、中位拥挤距离稀疏/密集分组和稀疏区偏置配额，可直接改造 NSGA-II 或 rank-based MOEA 的下一代截断选择。
---

# 拥挤中位分区的稀疏优先混合选择

## 核心内容

在 NSGA-II 或 rank-based MOEA 的下一代截断阶段，不只按 crowding distance 一次性排序。先保留一批 crowding distance 最大的代表性/边界个体，再对剩余候选按 crowding distance 的中位数动态划分为 sparse region 和 dense region，最后用大于一半的配额优先从稀疏区补齐，密集区只保留少量质量较好的解。

P2026-0208 的 HS-NSGA-II 将该机制用于航天器规避三目标 MOP：先做目标归一化，再在 next-generation selection 中执行两阶段混合选择，以改善 Pareto 策略集合的多样性、覆盖和 HV。

```text
combined population
-> nondominated sorting
-> critical/candidate front P with remaining quota eta
-> normalize objectives if scales differ
-> compute crowding distance D
-> stage 1: select top floor(eta/2) by D
-> stage 2: split remaining candidates by median(D)
       sparse region: D >= D_med
       dense region: D < D_med
-> allocate more than half of remaining quota to sparse region
-> next population
```

## 建立理由

- 为什么值得独立维护：
  - 标准 NSGA-II 的 crowding-distance truncation 是许多算法的可替换模块；
  - 该方法给出低成本、实现明确的二阶段选择接口，不需要参考向量、HV contribution 或额外代理模型；
  - 中位拥挤距离提供了随当前候选分布动态变化的稀疏/密集阈值；
  - 稀疏区配额能显式减少欠代表区域被截断的风险。
- 单篇具体方法的直接复用价值：
  - P2026-0208 给出 HS-NSGA-II Algorithm 1、拥挤距离公式、两阶段选择流程、归一化说明和六算法对比；
  - 在航天器规避三目标 MOP 中，HS-NSGA-II 相对标准 NSGA-II、归一化 NSGA-II、NSGA-III、MOPSO、MODE 和 SPEA2 获得最高 `HV` 和最高平均拥挤距离。
- 与已有设计知识的区别：
  - 不同于“目标值均衡的二级环境选择”：该知识处理 many-objective 离散 PF 中 crowding distance 大量平局和 objective-value multiplicity 缺失；本知识面向连续三目标或低中维 MOP，用中位拥挤度分区和稀疏配额直接改造 NSGA-II 截断。
  - 不同于“分解-支配双选择的稀疏探索”：该知识以 MOEA/D 子问题为基座，并叠加 SPEA-II 全局选择和稀疏探索；本知识不依赖分解子问题，只替换 rank-based 下一代选择。
  - 不同于“目标空间流形嵌入的多样性选择”：该知识重建目标空间图和潜在流形距离；本知识仍使用经典 crowding distance，只改变保留顺序和配额。
  - 不同于 MMOP 中的 density/niching 选择：本知识主要维护目标空间 Pareto front 分布，不处理决策空间多模态 Pareto sets。

## 解决的问题

- 适用场景：
  - NSGA-II 或类似非支配排序算法在 critical front 中需要截断；
  - 目标空间存在欠代表区域，标准 crowding distance 选择后覆盖不均；
  - 目标尺度差异较大，需要先归一化再比较距离；
  - 希望提高 Pareto set/front 的代表性，而不想引入高成本 indicator 或 reference-vector 机制；
  - 2-3 个目标、候选规模中等、连续目标值较多的 MOP。
- 现有方法为什么会失败或不足：
  - 标准 crowding-distance 排序偏向极端和局部大间隔个体，但没有明确控制稀疏区和密集区的总体配额；
  - 如果早期随机或局部搜索让某些目标区域样本少，常规截断可能持续保留密集区高质量解，欠代表区域恢复慢；
  - 目标量级差异会让 crowding distance 和支配关系被大尺度目标主导；
  - 只做目标归一化可以缓解尺度问题，但不能保证稀疏区域被足量保留。
- 仍需解决的问题：
  - 稀疏配额 `varsigma` 如何自适应；
  - 中位数阈值在候选数量少或距离分布极偏时可能不稳；
  - 稀疏区域中的解未必都收敛良好，过度偏向会牺牲质量；
  - many-objective 下 crowding distance 本身区分力会下降，需要替代密度指标。

## 为什么可能有效

```text
objective-scale imbalance
-> normalize objective values
standard NSGA-II truncation may under-cover sparse regions
-> keep top crowding-distance representatives first
-> use median(D) to identify currently sparse vs dense areas
-> reserve more remaining slots for sparse area
-> improve front coverage while retaining dense-area competitors
```

关键假设是：crowding distance 仍能粗略反映目标空间局部稀疏度，并且中位数可以把当前候选分成有意义的 sparse/dense 两组。若 crowding distance 在高维目标空间退化，或稀疏区域只是远离真实 PF 的低质量离群解，该机制可能失效。

## 实现接口

- 输入：
  - 已合并并排序的候选 population；
  - 需要截断的 critical front 或候选集 `P`；
  - 剩余名额 `eta`；
  - 目标值归一化函数；
  - 稀疏区配额参数 `varsigma > 1/2`。
- 输出：
  - 选入下一代的个体集合 `P_next`；
  - 可选的 sparse/dense 区域标签，用于诊断。
- 插入位置：
  - NSGA-II 的 critical front truncation；
  - NSGA-II 变体的 environmental selection；
  - 外部 archive 的容量截断；
  - 多目标控制/工程问题中需要保留代表性策略集的下一代选择。
- 最小实现：

```text
fill P_next with complete nondominated fronts
eta <- N - |P_next|
C <- critical_front

normalize objectives in C
compute crowding_distance D(x) for x in C

k1 <- floor(eta / 2)
P1 <- top_k(C, k1, key = D)
R <- C \ P1

D_med <- median({D(x) | x in R})
S_sparse <- {x in R | D(x) >= D_med}
S_dense  <- {x in R | D(x) < D_med}

k2 <- ceil(varsigma * (eta - k1))
k3 <- eta - k1 - k2

P2 <- top_k(S_sparse, min(k2, |S_sparse|), key = D)
P3 <- top_k(S_dense, eta - k1 - |P2|, key = D)
if |P1 union P2 union P3| < eta:
    fill from remaining R by D or rank-preserving random tie-break

P_next <- P_next union P1 union P2 union P3
```

P2026-0208 的实例中，边界解 crowding distance 设为 infinity；第一阶段选择 `floor(eta/2)` 个 crowding distance 最大的解；第二阶段用中位拥挤距离分组，并令 `varsigma > 1/2` 偏向稀疏区。

## 如何用于算法创新

### 局部创新

- 把 NSGA-II 的 critical front 截断替换成“拥挤距离 top-k + 中位分区 + 稀疏配额”。
- 将 `varsigma` 设为自适应值：当 HV 改善停滞或覆盖空白多时增大，收敛不足时减小。
- 用 `epsilon-box`、reference-vector sector 或 kNN density 替代 crowding distance 中位数，保留同样的稀疏/密集配额结构。
- 在 sparse region 内再按约束裕度、预测不确定性或决策空间 novelty 排序，避免保留低质量离群解。
- 将第一阶段比例从固定 `1/2` 改为由边界点数量、目标数或当前 front 大小控制。

### 结构创新

- 构建轻量 diversity controller：

```text
rank-based MOEA
-> objective normalization
-> density observer
-> sparse/dense quota controller
-> environmental selection
```

- 与离线策略库结合：环境选择不只优化最终指标，还确保策略库覆盖不同规避、控制或调度场景。
- 与动态 MOO 结合：新环境初期提高稀疏区配额恢复覆盖，后期降低配额强化收敛。
- 与 constrained MOO 结合：先按可行性和 rank 分层，再在同层内执行稀疏优先混合选择。
- 与 many-objective 结合时，用 reference-vector occupancy 或 angular density 替代 crowding distance，保留“先代表性保留、再稀疏配额补齐”的框架。

## 适用条件与风险

- 适用条件：
  - 候选集中 crowding distance 或替代密度指标仍有区分力；
  - Pareto front 覆盖比单点收敛更重要；
  - 目标值可可靠归一化；
  - critical front 截断经常发生；
  - 算法预算不适合高成本 HV contribution 或复杂流形嵌入。
- 不适用或可能失效的条件：
  - 目标数较高，crowding distance 大量相近或退化；
  - 稀疏区域主要是未收敛离群点，保留它们会拖慢整体搜索；
  - 目标尺度或约束违反未处理好，密度分区会被无关尺度主导；
  - Pareto front 很规则且标准 NSGA-II 已充分覆盖，额外分区收益有限；
  - 候选数量太少，中位数划分随机性强。
- 计算与实现成本：
  - 主要增加一次中位数计算和两组配额选择，成本接近标准 NSGA-II 截断；
  - 需要处理 sparse/dense 一组为空或名额不足的补齐逻辑；
  - 需要记录归一化边界，避免目标区间过窄导致数值不稳。
- 解释风险：
  - P2026-0208 同时使用目标归一化和混合选择，对性能提升的单独贡献没有完整消融；
  - `D_mean` 较高不必然等于分布更均匀，需要结合 `sigma`、HV、IGD 或可视化判断；
  - 航天器规避问题的收益可能来自领域建模与 MOP 转换，不能完全归因于选择机制。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0208 | 标准 NSGA-II 被认为难以探索 underrepresented areas，因此需要 hybrid selection 生成更有代表性的规避策略 | 问题动机 | Sec. III-B，PDF 6 |
| P2026-0208 | HS-NSGA-II 保留 NSGA-II 初始化、评价、非支配排序、选择、交叉、变异、合并和终止等核心步骤，只改造 next-generation selection | 方法接口 | Sec. III-B，PDF 6 |
| P2026-0208 | 因 `xi1` 与 `xi2/xi3` 量级差异明显，作者在 fitness evaluation 中做目标归一化 | 实现细节 | Sec. III-B，PDF 6 |
| P2026-0208 | 第一阶段基于 crowding distance 选择 top `floor(eta/2)` 个体，边界解距离设为 infinity | 作者提出的方法 | Sec. III-B，PDF 6-7 |
| P2026-0208 | 第二阶段按 median crowding distance 将剩余候选划分为 sparse region 和 dense region，并用 `varsigma > 1/2` 偏向 sparse region | 作者提出的方法 | Sec. III-B，PDF 7 |
| P2026-0208 | Algorithm 1 汇总 HS-NSGA-II 流程，并将混合选择用于输出代表性 Pareto front | 完整流程 | Algorithm 1，PDF 7 |
| P2026-0208 | 30 次独立运行中，HS-NSGA-II 的 `HV=3.26166` 和 `D_mean=0.050793` 最高，优于六个对比算法 | 实验支持 | Sec. IV-B，Table II，PDF 8 |
| P2026-0208 | SPEA2 的 `sigma=0.21811` 最低但 `HV=3.05654` 较低，说明只追均匀性可能牺牲高质量区域 | 边界/解释证据 | Sec. IV-B，Table II，PDF 8 |
| P2026-0208 | Fig. 2 显示 HS-NSGA-II 的 Pareto front 覆盖更宽且更优 | 可视化证据 | Sec. IV-B，Fig. 2，PDF 8 |
| P2026-0208 | Fig. 3 显示 HS-NSGA-II 取得最高且稳定的 HV 收敛，MODE 初期快但停在较低 HV，NSGA-III 在该三目标问题上表现弱 | 收敛证据 | Sec. IV-B，Fig. 3，PDF 9 |

## 证据边界

- 当前只有单篇论文证据，且应用场景是航天器规避三目标 MOP。
- 对比中包含 standard NSGA-II with normalization，但未给出“只使用混合选择不归一化”和“只使用第一阶段/第二阶段”的完整消融。
- 实验主场景较少，尚不能确认该选择机制在通用 benchmark 上稳定优于 NSGA-II、NSGA-III 或 indicator-based MOEA。
- `sigma` 并非 HS-NSGA-II 最优，说明稀疏优先机制提升 HV 和覆盖的同时不一定得到最均匀分布。
- 目标数升高后 crowding distance 可能退化，需替换为 reference-vector、angular 或 learned density。

## 待确认

- `floor(eta/2)` 的第一阶段比例是否应随目标数、front size 或边界点数量变化；
- `varsigma` 的最优范围和自适应控制方式；
- 中位拥挤距离是否优于分位数、kNN 密度、epsilon-box occupancy 或 reference-region density；
- 在标准 ZDT/DTLZ/WFG、约束 MOP、动态 MOP 和昂贵 MOP 中是否仍能稳定提升 IGD/HV；
- 如何避免稀疏优先保留未收敛离群点；
- 与 objective-value multiplicity balancing、HV contribution 或 manifold embedding selection 的组合是否互补。
