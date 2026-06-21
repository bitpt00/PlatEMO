---
knowledge_id: K-shared-elite-route-pool-parallel-evolution
name: 共享精英路线池的并行协同进化
type: architecture
status: active
source_papers: [P2026-0108]
aliases: [PEA-MBTND-TS, shared elite routes, coordinated evolution mechanism, CEM, hierarchical crossover and mutation, HCM, multi-polar-angle overlap, component-level elite sharing, parallel subpopulation component pool, 共享精英路线, 共享组件池, 并行子种群协同]
promotion_reason: 单篇论文提出但机制完整，包含并行子种群、共享精英路线池、组件级评分、路线级/站点级分层交叉变异、多极角重叠的空间耦合判定、权重向量非支配选择，以及与无 CEM、SS/ID 判定和 NSGA/MOEA 基线的消融对比，可迁移到路线、任务、模块等组合型多目标搜索。
---

# 共享精英路线池的并行协同进化

## 核心内容

当完整解由多条路线、任务序列或模块组件组成时，并行子种群之间不只迁移完整 elite solutions，而是维护一个共享的高质量组件池。每个子种群独立进化完整解，同时把新产生的组件写入共享池，并在交叉/变异时从共享池取组件做片段交换或替换。这样可以让差完整解中的好组件跨子种群复用，降低并行岛之间弱通信导致的重复搜索。

```text
population S
-> split into Q parallel subpopulations
-> each stream evolves full solutions
-> extract components from offspring
-> score components by domain proxy
-> update shared elite component pool E with capacity E_max
-> crossover/mutation may use components from E
-> merge parent+offspring and select next S
-> reshuffle S into subpopulations
```

P2026-0108 的实例中，组件是公交路线。路线评分为 `passenger boardings / nonlinear factor`，共享池中的精英路线会参与路线片段交叉和 route replacement mutation；路线之间能否交叉由 multi-polar-angle overlap 判定。

## 建立理由

- 为什么值得独立维护：
  - 组合型 MOO 中，一个完整解可能整体不优，但内部某些路线、任务块或模块很有价值。
  - 传统并行岛模型迁移完整个体，通信粒度太粗，容易传播冗余或把好组件随差解一起丢掉。
  - 只维护完整 archive 不能支持算子直接复用组件。
  - 共享组件池可以作为轻量通信层，让多个子种群在保持多样搜索的同时复用 building blocks。
- 单篇具体方法的直接复用价值：
  - P2026-0108 给出共享精英路线池、路线评分、分层交叉/变异、多极角重叠判定和权重向量选择；
  - Table 6 消融显示去掉 CEM 后两城市 HV/IGD 均变差；
  - Table 7 消融显示 multi-polar-angle overlap 优于 shared-stop 和 inter-route distance 两种朴素判定。
- 与已有设计知识的区别：
  - 不同于“可分解组件的 schema 级保存与重构”：该知识周期性识别单个完整解中的最差组件并替换；本知识是并行子种群之间的组件通信层，组件池直接参与 crossover/mutation。
  - 不同于“异步子任务精英池协同进化”：该知识面向分解式结构搜索的子任务异步迁移；本知识面向完整组合解中的路线/组件级共享。
  - 不同于“局部通信精英交互的分布式多目标协同”：该知识迁移邻域 elite individuals；本知识迁移可插入完整解的局部组件。
  - 不同于路线类编码/解码知识：本知识重点是并行协同与组件池通信，而不是某一种路径可行性编码。

## 解决的问题

- 适用场景：
  - 完整解由多个可识别组件组成，例如公交路线、车辆路径、机器人任务链、机器排程片段、网络子结构或产品模块；
  - 组件有可计算的局部质量 proxy；
  - 子种群并行搜索容易重复发现相似局部结构；
  - 优质组件可以跨完整解复用，但仍需完整解评价验证全局耦合；
  - 交叉/变异需要判断组件兼容性，避免无意义重组。
- 现有方法为什么会失败或不足：
  - 完整个体迁移会把低质量组件一起传播；
  - 完整个体选择会淘汰包含少数好组件的差解；
  - 随机组件交叉若不判断兼容性，容易产生无效或破坏性组合；
  - 各子种群完全独立会重复搜索相同 building blocks；
  - 只在目标空间保留非支配解，无法直接指导结构级算子。
- 仍需解决的问题：
  - 组件质量 proxy 和最终多目标贡献可能不一致；
  - 强耦合组件插入新上下文后可能失效；
  - 共享池过强会使子种群同质化；
  - 组件兼容性判定需要针对问题结构设计。

## 为什么可能有效

```text
full solution quality mixes many components
-> good components may appear inside mediocre solutions
-> parallel subpopulations discover different local structures
-> shared pool stores high-score components
-> component-aware crossover/mutation injects useful structures
-> compatibility filter avoids random destructive recombination
-> global selection reevaluates full solutions and preserves diversity
```

关键假设是：组件质量具有一定上下文可迁移性。P2026-0108 中高客流、低绕行的公交路线在不同网络方案中通常仍有价值；若组件价值高度依赖其他组件，必须加强重评估和使用概率控制。

## 实现接口

- 输入：
  - 完整解 population；
  - 组件抽取函数 `components(x)`；
  - 组件质量评分 `score(c)`；
  - 组件兼容性判定 `compatible(c1,c2)`；
  - 组件级 crossover/mutation；
  - 共享池容量 `E_max` 和并行子种群数 `Q`；
  - 完整解评价与多目标选择函数。
- 输出：
  - 更新后的 population；
  - 共享精英组件池；
  - 可选日志：组件被使用次数、组件保留年龄、跨子种群贡献、共享池多样性。
- P2026-0108 的具体实例：

```text
component = bus route
score(route l) = boardings p_l / nonlinear_factor delta_l
E = shared elite routes with capacity E_max

for each subpopulation S_i:
    S_i'  = hierarchical_crossover(S_i, E)
    S_i'' = hierarchical_mutation(S_i', E)
    timetable = synchronized_timetable_construction(S_i'')
    E.update(routes(S_i''), keep top E_max by score)
    A_i = S_i union S_i''

A = union_i A_i
S = weight-vector nondominated_selection(A)
reshuffle S into Q subpopulations
```

- 组件兼容性实例：

```text
two routes are crossable if their polar-angle ranges overlap
under all four poles of the minimal bounding rectangle
```

## 如何用于算法创新

### 局部创新

- 将共享池从单一分数改成多目标组件档案，例如同时保存低成本、高覆盖、高鲁棒性组件。
- 为组件池加入 crowding 或 novelty，避免所有子种群都使用相同组件。
- 根据子种群贡献动态调节共享池读写频率：进展慢的子种群多读，发现新结构的子种群多写。
- 对组件使用加置信度：插入后若完整解评价改善，提升该组件在池中的 credit。
- 将 multi-polar-angle overlap 替换为图距离、流量相关性、learned compatibility 或 constraint-aware feasibility check。

### 结构创新

- 构建组件级岛模型：

```text
island populations keep search diversity
shared component archive keeps reusable building blocks
component credit controls migration intensity
global selection filters incompatible combinations
```

- 与局部搜索结合：共享池提供候选组件，局部搜索只在该组件邻域重排，降低大规模组合搜索成本。
- 与 surrogate 结合：用快速模型预测组件插入后的完整解收益，只对高潜力组合做真实评价。
- 与偏好搜索结合：为不同偏好区域维护不同组件池，例如低成本路线池、高覆盖路线池、低排放路线池。

## 适用条件与风险

- 适用条件：
  - 解可自然分解为多个组件；
  - 组件可以被插入、替换或局部交叉；
  - 组件有局部评价或可解释 proxy；
  - 完整解评价可以验证组件组合后的全局质量；
  - 并行子种群之间允许共享少量结构信息。
- 不适用或可能失效的条件：
  - 组件之间强耦合到无法脱离上下文评分；
  - 组件替换几乎总会破坏可行性且修复成本高；
  - 组件 proxy 与真实目标贡献长期不一致；
  - 共享池容量过小导致有用多样性丢失，过大又引入大量噪声；
  - many-objective 下全局选择压力弱，插入组件后的贡献不易反馈。
- 计算与实现成本：
  - 需要维护组件池、评分和兼容性判定；
  - 每次使用组件后仍需完整解评价；
  - P2026-0108 没有提供 wall-clock 并行加速比，不能把效果完全解释为并行计算加速；
  - multi-polar-angle overlap 可预计算站点相对极点角度，降低重复判定成本。
- 解释风险：
  - 共享组件池提升的是结构复用和多样性，不等同于普通精英个体迁移；
  - 组件评分是领域启发式，不是严格的 Pareto 贡献；
  - 若所有子种群频繁读取同一共享池，可能损害岛模型本应保持的探索差异。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0108 | PEA-MBTND-TS 将主种群划分为多个并行子种群，并通过 shared elite routes 协同进化 | 作者提出的方法 | Abstract，Sec. 3，PDF 1、4 |
| P2026-0108 | 作者明确区别于共享 elite solutions，强调完整优解中也可能包含 inferior routes，因此共享路线组件更合适 | 设计逻辑 | Sec. 3，PDF 4 |
| P2026-0108 | 精英路线评分采用 `d_l = p_l / delta_l`，综合登车人数与路线非线性系数 | 组件评分 | Sec. 3.2.1，PDF 5 |
| P2026-0108 | 每个子种群依次执行分层交叉、分层变异、同步时刻表构造、共享池更新和父子合并 | 算法流程 | Sec. 3.2.2，PDF 5 |
| P2026-0108 | 共享精英路线参与 inter-route stop crossover，实现子种群间路线片段交换 | 组件级交叉 | Sec. 3.3.2，PDF 6 |
| P2026-0108 | Multi-polar-angle overlap 用四个参考极点判断两条路线是否适合交叉，避免 shared-stop 和距离阈值的不足 | 兼容性判定 | Sec. 3.3.3，PDF 6-7 |
| P2026-0108 | Route-level mutation 中 replace route 会用共享精英路线替换个体中的路线 | 组件级变异 | Sec. 3.4，PDF 7 |
| P2026-0108 | Weight-vector nondominated ranking 用 Das-Dennis 权重和 Chebyshev aggregation 改善选择分布 | 全局选择 | Sec. 3.6，PDF 8 |
| P2026-0108 | Yiwu 与 Wuhan 两个路网案例，20 次运行，PEA-MBTND-TS 在 HV/IGD 上优于 MOEA/D、NSGA-II、NSGA-III 及其 HCM 版本 | 综合实验支持 | Sec. 4.4，Table 5，PDF 10-11 |
| P2026-0108 | 去掉 CEM 后解集更聚集；Table 6 中两城市 HV/IGD 均变差 | 消融支持 | Sec. 4.5，Table 6，PDF 11-12 |
| P2026-0108 | Multi-polar-angle overlap 优于 shared-stop 和 inter-route distance 判定；Table 7 中两城市 HV/IGD 均最佳 | 消融支持 | Sec. 4.6，Table 7，PDF 12-13 |

## 证据边界

- 当前只有单篇论文证据。
- 证据来自公交网络设计场景，组件为路线；迁移到其他组合问题需重新定义组件评分和兼容性。
- OD demand 是随机生成，真实需求数据下组件评分和同步收益仍需验证。
- 论文没有报告并行计算 speedup 或通信开销；“并行”效果主要通过协同进化质量体现。
- PEA-MBTND-TS 的优势同时来自 MBTND-TS 模型、HCM、CEM、STC 和选择机制，不能把所有性能提升都单独归因于共享精英路线池。

## 待确认

- 如何自动学习组件评分，而不是手工设计 `passenger / detour` proxy；
- 如何控制共享池强度以避免子种群同质化；
- 如何在强约束组合问题中保证组件插入后的可行性；
- 如何量化每个共享组件对完整解改进的真实贡献；
- 是否可以为不同 Pareto 区域维护多个偏好特化组件池。
