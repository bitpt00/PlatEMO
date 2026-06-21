---
knowledge_id: K-depot-anchored-subroute-encoding-adaptive-vns
name: 仓库锚定子路线编码与支配反馈自适应 VNS
type: method
status: active
source_papers: [P2026-0281]
aliases: [SRFE, Sub-Route Fusion Encoding, VNS-AS, adaptive shaking, Depot-Exchange, Customer-Relocation, GHDVRPSV, depot-anchored route encoding, sequential visiting VRP, heterogeneous depots VRP, 仓库锚定子路线, 顺序访问车辆路径, 支配反馈扰动]
promotion_reason: 单篇论文提出但接口清楚，包含 depot-anchored sub-route fusion encoding、前序约束客户分配、容量可行初始化、基于支配关系的 DE/CR adaptive shaking，以及子路线内 2-opt/交换和 NNS 约束插入，可迁移到异构多仓、补货前序、多资源路径和强约束组合搜索。
---

# 仓库锚定子路线编码与支配反馈自适应 VNS

## 核心内容

在多仓、多资源或补货前序约束很强的路径问题中，不把个体表示为普通 giant tour，而是把每条 vehicle route 拆成由资源节点锚定的 sub-routes。每个 sub-route 以 depot/resource node 开始，客户或任务只能按其需求来源、容量和前序关系插入合适的 sub-route。搜索时再用当前解与父代的支配关系控制 VNS shaking：当前解明显差时用 depot/resource-level exchange 扩大扰动，当前解明显好时保留结构，互不支配时用 customer/task relocation 做中等扰动。局部搜索只在可维护 sub-route 可行性的邻域内进行。

```text
heterogeneous depots / resource nodes
-> route = sequence of depot-anchored sub-routes
-> assign customers/tasks by source-resource precedence and capacity
-> feasible initialization + sub-route improvement
-> compare current solution with parent
-> dominated: depot/resource exchange with stronger shake
-> dominates: keep structure, no shake
-> nondominated: customer/task relocation
-> sub-route 2-opt, gain-checked exchange, constrained nearest insertion
-> nondominated archive
```

P2026-0281 的 VNS-AS 是该模式的实例：SRFE 控制 GHDVRPSV 中 depot 顺序和客户分配，adaptive shaking 用 DE/CR 在 depot 和 customer 两个粒度切换，local search 用 SR-2-Opt、RE-DR 和 ANI 维护可行性并改善 travel cost 与最长 route cost。

## 建立理由

- 为什么值得独立维护：
  - 强前序约束 VRP 中，不可行解往往不是普通容量超限，而是 depot/resource 访问顺序和客户需求来源不匹配；
  - 只靠 repair 修补 giant tour 会浪费大量搜索预算，且修复后的路线结构可能与原个体差异很大；
  - 将 depot/resource 固定为 sub-route anchor，可以把可行性从后处理提前到编码和邻域定义；
  - 用支配关系控制 shaking，能在多目标搜索中区分结构保护、局部开发和跳出局部最优；
  - depot-level 和 customer-level 两种扰动粒度适合很多“资源点-任务点”混合序列问题。
- 单篇具体方法的直接复用价值：
  - P2026-0281 给出 SRFE、初始化、DE、CR、RE-DR、ANI、复杂度分析、25 个 benchmark cases 和真实物流案例。
- 与已有设计知识的区别：
  - 不同于“区域压缩编码与多解路径解码”：该知识把大路网路径压缩为区域序列并用 decoder 生成多条路线；本知识把 depot/resource 节点作为前序锚点，重点是补货/供应约束下的 route feasibility。
  - 不同于“业务偏好约束的多段染色体搜索”：该知识用多段染色体表示任务、资源槽位和断点，并用 epsilon 约束表达业务偏好；本知识不用阈值扫描，而是把资源访问前序写进 sub-route encoding 和 VNS 邻域。
  - 不同于“分解 ILS 的反馈扰动与档案协作”：该知识是少量 scalar subproblems 和 ILS processes 的多目标架构；本知识是单个 VNS/路线个体内部的前序保持编码与支配反馈 shaking。
  - 不同于“结构启发初始化与多目标路径重联”：该知识强调精英解之间的 path relinking；本知识强调 depot/resource-anchored sub-route 和可行邻域。

## 解决的问题

- 适用场景：
  - 多仓配送、补货式 VRP、移动机器人多资源补给、巡检-补给联合路线、医疗/冷链多温区配送；
  - 任务点需要若干资源，资源点供应能力不同，且访问顺序决定任务可服务性；
  - 普通 route permutation 很容易产生不可行解；
  - 局部搜索可以在 sub-route 内安全执行，跨 sub-route 操作必须经过约束检查；
  - 目标至少包含成本、距离、最长路线、负载均衡或服务质量等多目标折中。
- 现有方法为什么会失败或不足：
  - Giant tour 无法自然表达“先访问哪个 depot 才能服务哪些 customers”；
  - 随机跨 route relocation 会破坏产品来源、容量或前序；
  - 固定 shaking 强度在差解上跳不出去，在好解上又可能破坏有效结构；
  - 只用 depot-level 操作会探索粗糙，只用 customer-level 操作又可能困在 depot sequence 附近；
  - 非支配 archive 如果没有可行性保持编码，会被大量 infeasible 或修复后同质化解污染。
- 仍需解决的问题：
  - 对时间窗、动态库存、多次补货、随机需求和异构车辆的扩展需要重新设计 anchor 和 assignment 规则；
  - depot-level exchange 后的客户重插成本可能随产品数和客户数快速上升；
  - 支配关系触发的三分支 shaking 仍是手工规则，可能需要数据驱动调参；
  - many-objective 下支配关系稀疏，adaptive shaking 的状态区分会变弱。

## 为什么可能有效

```text
infeasibility comes from resource precedence
-> encode resource nodes as route anchors
-> assign tasks only after required resources are available
-> local moves stay inside feasible sub-routes when possible
bad current solution needs structural jump
-> depot/resource exchange changes supply sequence
good current solution should preserve structure
-> skip shaking and exploit local search
nondominated trade-off needs moderate exploration
-> customer/task relocation adjusts workload and cost
```

关键假设是：高质量解可以由较稳定的 resource/depot sequence 加上局部客户排列来表达，且支配关系能反映当前结构是否值得保护。如果可行性主要由全局时间同步或随机场景决定，而不是资源访问前序决定，sub-route anchoring 的收益会下降。

## 实现接口

- 输入：
  - resource/depot 节点集合及其供应能力矩阵；
  - customer/task 需求、容量、服务约束和距离/成本矩阵；
  - 初始种群规模、NNS 大小、VNS 停止条件；
  - 可行性检查器和客户重插策略。
- 输出：
  - depot/resource-anchored route representation；
  - 可行初始种群；
  - 经 adaptive shaking 和 local search 改善的 nondominated set；
  - 可复用的 sub-route fragments 或 route archive。
- 插入位置：
  - VRP/MRTA/多资源路径问题的 encoding layer；
  - VNS、ALNS、ILS 的 shaking strategy；
  - 组合多目标算法的 feasibility-preserving local search；
  - depot sequence 或 resource sequence 已知但客户分配困难的 hybrid solver。
- 最小实现：

```text
for each vehicle:
    choose a start depot/resource
    build an ordered list of depot/resource anchors
    create sub-routes under each anchor

for each customer/task:
    find anchors that can supply all required resources
    if multiple anchors are required:
        insert into a sub-route after the last required anchor
    else:
        insert into its source anchor or a feasible later sub-route
    check capacity and route constraints

for each generation:
    compare current solution x_c with parent x_p
    if x_c is dominated by x_p:
        apply resource-anchor exchange with intensity from objective gap
    else if x_c dominates x_p:
        keep x_c unchanged before local search
    else:
        apply customer/task relocation

    improve by sub-route 2-opt
    improve by gain-checked same-sub-route exchange
    improve by nearest-neighbor constrained insertion
    update nondominated archive
```

## 如何用于算法创新

### 局部创新

- 将支配关系三分支替换为 bandit、UCB 或 RL operator selection，让 DE/CR/其它邻域的选择由历史收益决定。
- 把 DE intensity 从目标相对差异扩展为目标差异、route-load imbalance、depot utilization、产品重叠度和最近失败重插次数的组合。
- 为 multi-source customer 设计多种 assignment rule，例如最晚补齐、最早补齐、最低插入成本或负载均衡优先。
- 将 ANI 的 NNS 从几何距离替换为时间依赖 travel time、兼容资源、共同 depot 覆盖或历史成功插入概率。
- 对 sub-route fragments 做 archive reuse，在相似 depot sequence 间迁移局部客户排列。
- 在 local search 中加入 exact insertion、small MILP、dynamic programming 或 regret insertion。

### 结构创新

- 构建强前序路径搜索框架：

```text
resource-anchor encoder
-> feasible assignment decoder
-> state/dominance-aware shaking controller
-> constraint-preserving local neighborhoods
-> nondominated archive and route fragment memory
```

- 与 decomposition local search 结合：不同权重子问题共享 depot sequence 和 sub-route fragments，但各自优化 cost、balance、risk 或 emission。
- 与 digital twin 结合：编码层保证逻辑可行，仿真层评价拥堵、充电、排队和服务时间，archive 只保留仿真可接受解。
- 与 exact solver 混合：固定 depot/resource anchor sequence 后，用 MILP 或 label-setting 精修客户插入和补货量。
- 与交互式优化结合：调度员锁定某些 depot sequence 或车辆后，只对未锁定 sub-routes 执行 VNS。

## 适用条件与风险

- 适用条件：
  - 路线可自然分解为 resource/depot anchors 和 customer/task segments；
  - 可行性主要由资源供应、容量和访问前序决定；
  - 每个任务的资源来源可识别，或至少可由兼容集合表示；
  - 局部搜索能在 sub-route 内安全改善；
  - 多目标搜索需要同时处理距离/成本和负载均衡等目标。
- 不适用或可能失效的条件：
  - 资源点没有明显前序作用，普通 route permutation 已足够；
  - 任务可拆分、资源可连续混合或车辆可频繁重复补货，导致 anchor 结构过于僵硬；
  - 时间窗、同步、排队等全局约束比资源前序更主导可行性；
  - 目标数太多，支配关系多数为互不支配，shaking 退化为频繁 CR；
  - depot exchange 后重插失败率很高，算法会在 repair 上消耗过多。
- 计算与实现成本：
  - 需要维护 resource supply matrix、客户需求集合和每个 sub-route 的剩余容量；
  - DE 后必须重插受影响客户，成本高于普通 swap；
  - ANI 需要为客户维护 NNS 并进行多约束插入检查；
  - 若每次邻域操作都全量重算 route cost，可引入增量评价降低开销。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0281 | GHDVRPSV 用 supply matrix 表示 depot-product 异构供应，车辆可顺序访问多个 depots 补货后服务客户 | 问题建模 | Sec. III，PDF 3-4 |
| P2026-0281 | 目标为最小化 total travel cost 和最小化 longest route cost，以兼顾成本和 workload balance | 问题建模 | Sec. III，PDF 3-4 |
| P2026-0281 | 作者指出 giant-tour representation 难以控制 depot 位置和顺序，可能产生 infeasible solutions | 问题动机 | Sec. IV-A，PDF 5 |
| P2026-0281 | SRFE 将每条 route 分解为 depot-anchored sub-routes，并通过 depot 位置限制与客户分配规则减少不可行解 | 作者提出的方法 | Sec. IV-A，PDF 5 |
| P2026-0281 | Theorem 1 说明 SRFE solution space 小于 GTR solution space | 理论分析 | Sec. IV-A，PDF 5 |
| P2026-0281 | Two-stage initialization 先随机分配 depots 和容量可行插入客户，再对 sub-routes 做 2-opt | 作者提出/组合方法 | Sec. IV-B，Algorithm 1，PDF 5 |
| P2026-0281 | Adaptive shaking 根据当前解与父代的支配关系选择 DE、CR 或不扰动，DE 强度由目标差异控制 | 作者提出的方法 | Sec. IV-C，Eq. (17)，PDF 6 |
| P2026-0281 | DE 交换不同 sub-routes 的 depots，并将受影响客户移除后重新插入 | 作者提出的方法 | Sec. IV-C，Algorithm 2，PDF 6 |
| P2026-0281 | CR 将客户从一条 route 移到另一条 route 的可行 sub-route，固定扰动强度为 2 | 作者提出/组合方法 | Sec. IV-C，Algorithm 3，PDF 6 |
| P2026-0281 | Local search 使用 SR-2-Opt、RE-DR 和 ANI，ANI 遍历客户最近邻并在约束满足时插入 | 作者提出/组合方法 | Sec. IV-D，Algorithm 5，PDF 6-7 |
| P2026-0281 | VNS-AS 在 K1-K3 上匹配 Gurobi exact solutions；K4-K6 中 Gurobi 7200 s 内无法给出 exact solution，VNS-AS 更快获得多个非支配解 | 小规模验证 | Sec. V-C，PDF 8-9 |
| P2026-0281 | HV 指标上，VNS-AS 在 24/25 个 cases 中显著优于 NSGA-II、CEOA 和 BVNS | 综合实验支持 | Sec. V-D，PDF 9-10 |
| P2026-0281 | IGD 指标上除 K21 外 VNS-AS 均更好；C-metric 显示 22/25 cases 中对比算法超过 90% 的 solutions 被 VNS-AS 支配 | 综合实验支持 | Sec. V-D，PDF 9-10 |
| P2026-0281 | 真实案例中 GHDVRPSV travel cost 544，低于 MDSDVRP 的 620，降低 12.3%；route length 差值从 98 降至 8 | 真实应用支持 | Sec. V-E，PDF 11 |
| P2026-0281 | 作者承认对比算法参数未调优，未来将做参数敏感性并加入更多现实约束 | 作者局限与未来工作 | Sec. VI，PDF 12 |

## 证据边界

- 当前只有单篇论文证据。
- Benchmark 为 TSPLIB 改造案例，真实应用只有 20 个 customers 和 2 个 depots。
- 对比算法参数未系统调优，VNS-AS 优势仍需更公平的调参对照验证。
- 方法只验证双目标，many-objective 场景下支配反馈可能退化。
- SRFE 对 GHDVRPSV 的 depot/product/customer 结构很贴合，迁移时必须重新定义 anchor、assignment 和可行性检查。

## 待确认

- 在更多 depot、更多 product types 和更高 customer demand overlap 下，DE 重插和 ANI 检查的计算成本；
- DE intensity 是否应做目标归一化、平滑或上下界控制；
- 时间窗、服务时间、车辆异构、动态库存和随机需求如何进入 sub-route assignment；
- 与 ALNS、decomposition ILS、hybrid exact search 或 learning-guided operator selection 结合后的收益；
- 当客户允许 split delivery 或车辆允许重复访问 depot 时，SRFE 是否需要变成可重复 anchor encoding。
