---
knowledge_id: K-dynamic-clustered-competitive-swarm-cmop
name: 动态聚类限域的竞争群约束搜索
type: architecture
status: active
source_papers: [P2026-0158]
aliases: [DBCCSO, CDASS, clustering-based dynamic adaptive search strategy, clustered competitive swarm optimizer, dynamic cluster number CSO, constrained multi-objective CSO, 动态聚类竞争群, 限域 winner-loser 学习, 约束多目标竞争群优化]
promotion_reason: P2026-0158 单篇提出但接口完整：双群两阶段框架、UPF 稳定性触发 stage switch、主群 objective-space K-means 动态分簇、同簇 CSO winner-loser 更新、参考向量子区的辅助群 diversity enhancement，并在 37 个 benchmark CMOP 和 16 个真实 RWMOP 上给出对比、参数和消融证据，可直接改造 CSO/PSO 类 CMOEA 的子代生成和约束阶段调度。
---

# 动态聚类限域的竞争群约束搜索

## 核心内容

在 constrained MOO 的竞争群算法中，不让 loser 总是从全局随机 winner 学习。早期保持一个整体 swarm，使 winner-loser 学习具备跨越大不可行区的全局收敛能力；当辅助群接近 UPF 后，切入 CPF 精修阶段，用 objective-space clustering 把主群拆成多个局部 sub-swarms，只允许同簇内部竞争更新。簇数随评价进度和 swarm objective change 动态调整，使算法在“整体穿越障碍”和“局部开发 CPF”之间切换。

```text
stage 1:
    auxiliary swarm ignores constraints and explores UPF
    main swarm uses nc = 1 for global competitive learning

stage switch:
    if AS objective changes are stable over G generations:
        enter stage 2

stage 2:
    auxiliary swarm selects reference-vector representatives using CV + direction
    main swarm computes dynamic cluster number nc
    K-means in objective space
    run CSO CompetitiveUpdate inside each cluster
```

## 建立理由

- 为什么值得独立维护：
  - CSO 类算法在 CMOP 中收敛快，但 CPF 附近远距离 winner-loser 学习会把子代拉离局部可行前沿；
  - 固定分簇会在早期削弱跨不可行区能力，在后期又可能留下 sub-swarm 间空隙；
  - 动态簇数把 reproduction 的信息流半径变成可调搜索控制量；
  - 该结构可插入 CSO/PSO/DE 风格 CMOEA 的 offspring generation 层，而不依赖昂贵模型训练。
- 与已有设计知识的区别：
  - 不同于 `K-trend-orthogonal-dualswarm-constrained-search`：本知识不传递趋势方向或正交补方向，而是限制竞争学习的局部范围。
  - 不同于 `K-game-competitive-dual-population-resource-allocation`：本知识不分配主/辅 offspring 预算，而是调节主群的学习半径和辅助群阶段角色。
  - 不同于 `K-adaptive-subregion-multidirectional-swarm-update`：本知识面向 constrained MOO 的 feasibility/CPF 阶段控制，不是大规模 MOO 的多方向 winner update。
  - 不同于 `K-adaptive-constraint-violation-granularity`：本知识的聚类对象是 reproduction scope，非 CV 表达粒度。

## 解决的问题

- 适用场景：
  - CMOP 存在大不可行区、狭窄/断裂 feasible regions、UPF 与 CPF 分离；
  - CSO/PSO winner-loser update 早期很快，但后期 CPF 附近局部开发弱；
  - 全局学习容易导致局部可行前沿附近的子代偏离；
  - 固定 reference/niche 或固定 cluster number 难随种群状态变化；
  - 需要兼顾可行性发现、收敛和目标空间分布。
- 现有方法为什么会失败或不足：
  - loser 向远距离 winner 学习时，后代可能跨出可行边界或离开 CPF 邻域；
  - 过早局部分簇会阻断有用的全局 winner 信息，难穿越大不可行区；
  - 固定多簇会在 sub-swarms 之间留下分布空洞；
  - 只用可行性压力选择会聚集到易可行片段；
  - 只追 UPF 的辅助群后期不能保证 CPF 多样性。
- 仍需解决的问题：
  - objective-space clusters 与 decision-space 可行结构不一致时如何修正；
  - `alpha`、`beta`、`G`、`sigma` 是否能在线自适应；
  - many-objective 下 K-means 与 reference vectors 是否仍有清晰分区意义；
  - 混合变量、离散变量和强修复约束下如何保持同簇竞争更新合法。

## 为什么可能有效

```text
early nc = 1
-> broad winner information helps cross infeasible regions

AS approaches UPF and stage switch fires
-> search shifts from global feasibility discovery to CPF refinement

stage 2 K-means clusters MS near CPF
-> losers learn from nearby winners
-> offspring stay closer to local CPF segments

dynamic nc decreases / temporarily contracts under large delta_F
-> sub-swarms merge
-> gaps are filled and trapped individuals regain global guidance

AS reference-vector selection
-> each objective-space region keeps feasible or low-CV representative
```

关键假设是：种群接近 CPF 后，objective-space 邻近性可以作为限制 CSO 学习范围的合理代理。如果目标空间邻近但决策空间隔离，或者约束边界使同簇内 winner 指向错误可行片段，同簇学习仍可能误导。

## 实现接口

- 输入：
  - main swarm `MS`、auxiliary swarm `AS`、offspring；
  - objective values、constraint violation、decision bounds；
  - CSO/CompetitiveUpdate 算子；
  - stage switch 参数 `G`、`sigma`；
  - cluster 参数 `alpha`、`beta`；
  - reference vectors and epsilon schedule。
- 输出：
  - 下一代 `MS` 和 `AS`；
  - 当前 stage；
  - 当前 cluster number `nc`；
  - 每个 sub-swarm 的 competitive offspring。
- P2026-0158 默认实例：
  - `N=100`，`MaxFES=100000`；
  - `G=300`、`sigma=0.3`；
  - `alpha=0.6`、`beta=0.003`；
  - stage 1 `nc=1`；
  - stage 2 用 Eq. (20) 根据 `delta_F` 和时间衰减动态调整 `nc`；
  - clustering 使用 objective-space K-means；
  - `AS` stage 2 用 `fitness(x)=d1(x)+d2(x)` 选择每个参考向量子区代表。

## 如何用于算法创新

### 局部创新

- 用 decision-objective hybrid distance 替代纯 objective-space K-means，避免目标相近但决策隔离。
- 将 `nc` 控制从手工公式改为基于 feasible ratio、CPF coverage gap、IGD surrogate 或 archive contribution 的反馈控制。
- 在同簇 CompetitiveUpdate 中加入 local constraint-boundary repair，使 offspring 更贴近可行边界。
- 把 fixed K-means 换成 DBSCAN、hierarchical clustering 或 reference-vector sector clustering。
- 对每个簇单独维护 epsilon 或 mutation strength，让困难可行区得到更强探索。

### 结构创新

- 构建“学习半径调度”的 CMOEA 框架：

```text
global learning radius for infeasible traversal
-> stage detector
-> local learning radius for CPF exploitation
-> adaptive merging when gaps or objective shifts appear
-> region-level diversity archive
```

- 与多辅助任务结合：每个 cluster 对应一个局部 relaxed problem 或 constraint subset，后期再合并到全约束 CPF。
- 与代理模型结合：只在 cluster boundary 或 low-confidence clusters 中调用 expensive evaluation / surrogate infill。
- 与资源分配机制结合：不只调节 cluster number，还按 cluster improvement 或 feasible scarcity 分配 offspring quota。

## 适用条件与风险

- 适用条件：
  - 种群规模足以支持多个 sub-swarms；
  - 目标数较低或中等，objective-space clustering 仍有意义；
  - CSO/PSO 类 reproduction 是主要搜索驱动力；
  - CMOP 需要先跨不可行区，再在 CPF 附近细化分布；
  - 可以维护辅助群或至少能计算 UPF/CPF 阶段信号。
- 不适用或可能失效的条件：
  - many-objective 下目标空间距离高度退化；
  - feasible regions 在决策空间强分离，但目标空间重叠；
  - 问题几乎无约束或可行域很宽，阶段和分簇开销可能收益有限；
  - 评价极昂贵而种群规模过小，K-means sub-swarms 无法稳定；
  - `AS` 的 UPF 稳定性不能代表 `MS` 已具备 CPF 精修条件。
- 计算与实现成本：
  - 每代需要 K-means 和两个群体的环境选择；
  - 理论复杂度仍为 `O(MN^2)` 或 `O(N^2 log N)`；
  - 需要调节 `G/sigma/alpha/beta`，且默认值未必跨问题稳健。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0158 | Fig. 1 分析远距离 winner-loser 学习会让 offspring 偏离 CPF，限制到 nearby winner 可增强 CPF 附近局部搜索 | 机制动机 | Sec. 2.5 / Fig. 1 |
| P2026-0158 | Algorithm 1 给出 DBCCSO：主群、辅助群、stage switch、动态 `nc`、K-means 分簇和同簇 CompetitiveUpdate | 算法接口 | Sec. 3.1 / Algorithm 1 |
| P2026-0158 | Stage 1 中辅助群忽略约束，用 GA/DE 促进全局探索和 UPF 收敛，帮助主群穿越 infeasible regions | 阶段机制 | Sec. 3.2.1 / Algorithm 3 |
| P2026-0158 | Stage switch 用过去 `G` 代各目标序列标准差和阈值 `sigma` 判断 AS 是否接近 UPF，默认 `G=300`、`sigma=0.3` | 阶段检测 | Sec. 3.2.1 / Eqs. 16-17 |
| P2026-0158 | Stage 2 辅助群用 reference vectors 划分子区，按 minimum CV 或 `d1+d2` 选择代表，维护 feasibility 与 diversity | 多样性增强 | Sec. 3.2.2 / Algorithm 4 |
| P2026-0158 | CDASS 在 objective space 用 K-means 分簇，stage 1 固定 `nc=1`，stage 2 按 Eq. (20) 动态调整 cluster number | 学习半径调度 | Sec. 3.3 / Eq. 20 |
| P2026-0158 | 在 LIR-CMOP 上 DBCCSO 的 IGD+ 和 HV 均取得 12/14 best，并在 Wilcoxon 中显著优于多数对比算法 | 综合实验 | Sec. 4.2 / Table 1 |
| P2026-0158 | 在 DAS-CMOP 上 DBCCSO 的 IGD+ 和 HV 均取得 5/9 best，DAS-CMOP3 可视化显示覆盖更完整且分布更均匀 | 综合实验 | Sec. 4.2 / Table 2 / Fig. 9 |
| P2026-0158 | 在 MW 上 DBCCSO 的 IGD+ 取得 8/14 best，HV 取得 6/14 best | 综合实验 | Sec. 4.2 / Table 3 |
| P2026-0158 | 消融显示无 CDASS、固定簇数和单阶段 variants 整体弱于 DBCCSO，Friedman ranks 均由 DBCCSO 最优 | 消融实验 | Sec. 4.5 / Tables 5-8 |
| P2026-0158 | 16 个 RWMOP 上 DBCCSO 在 HV 上取得最多 best values，支持真实约束问题泛化 | 真实问题 | Sec. 4.6 / Table 9 |

## 证据边界

- 当前直接证据来自 P2026-0158 一篇算法论文。
- 主要实验在 2-3 目标 benchmark 和 RWMOP 上；many-objective 的效果仍是未来方向。
- CDASS 的增益在 LIR-CMOP/DAS-CMOP 更明显，在 MW 上与固定 `nc=1` 差异较小。
- K-means 只在 objective space 工作，对复杂 decision-space disconnected feasible regions 的适配仍需验证。
- 参数 `G/sigma/alpha/beta` 通过网格实验设定，尚未形成无参或自适应机制。

## 待确认

- `delta_F` 与真实 CPF coverage gap 的相关性是否稳定；
- `nc` 是否应按每个 reference-vector 区域或可行率局部调整；
- 在 high-dimensional decision CMOP 中是否需要变量分组或局部代理辅助；
- 对 disconnected CPF，动态合并簇是否可能误合并不应交流的片段；
- 如何把 CDASS 与现有资源分配、约束粒度和趋势方向学习机制组合。

