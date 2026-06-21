---
knowledge_id: K-adaptive-route-task-splitting-mrta
name: 自适应路由-任务拆分的多机器人分配
type: architecture
status: active
source_papers: [P2026-0254]
aliases: [AMTSA, adaptive multi-objective task splitting, MTSO, DTPIM, PTSM, BTSM, split MRTA, multi-trip split delivery MRTA, orchard harvesting MRTA, 自适应任务拆分, 多行程任务分配, 分裂配送多机器人]
promotion_reason: 单篇论文提出但架构接口完整，包含路线/拆分混合编码、宏观 route structural optimization、时间与成功率反馈的搜索模式切换、偏离任务识别，以及空间邻近和时间均衡两类拆分机制，可迁移到任务可拆分的多机器人、车辆路径、仓储拣选和农业采摘调度。
---

# 自适应路由-任务拆分的多机器人分配

## 核心内容

在多机器人或多车辆任务分配中，如果一个任务可以被多个执行体或多次出行共同完成，就不要只把个体表示为普通任务排列。更合适的结构是同时维护两层信息：宏观的机器人-route-任务序列，以及微观的 task split ratio。搜索过程先用路线结构算子探索“任务放在哪个机器人、哪条 route、什么访问顺序”，再在后期或局部收敛时，对瓶颈机器人和偏离任务做拆分比例精修。

```text
task set with divisible demand
-> hybrid representation: route sequence + split table
-> early search: route swap / transfer / repartition / intra-route improvement
-> detect bottleneck robot and deviated tasks
-> proximity-based split for spatial efficiency
-> balance-based split for makespan reduction
-> update split ratios, route insertions and nondominated archive
```

P2026-0254 的 AMTSA 是该架构的具体实例：面向果园采摘 MRTA，同时最小化 makespan 和 total energy。它用 `0/1` 分隔符表示多机器人多 route 序列，用 splitting information 记录任务、机器人、route 和比例；早期执行 route structural optimization，后期通过 MTSO、DTPIM、PTSM 和 BTSM 调整瓶颈任务拆分。

## 建立理由

- 为什么值得独立维护：
  - 任务可拆分会把离散路线结构和连续拆分比例耦合，普通 fixed-length permutation 或 giant tour 很难表达；
  - 过早搜索 split ratio 可能锁死路线结构，过晚或完全不搜索 split ratio 又会造成负载和时间失衡；
  - 多 trip 场景下，一个机器人可以执行多条 route，任务拆分后还要同步 route load、service time、capacity 和 objective values；
  - “先宏观路线、后微观拆分”的搜索节奏适合许多 split-delivery、多机器人协作和任务分单问题；
  - 空间邻近拆分和时间均衡拆分分别对应 energy/cost 与 makespan/fairness 两类目标冲突。
- 单篇具体方法的直接复用价值：
  - P2026-0254 给出 AMRTA 模型、混合编码、route structural optimization、MTSO、DTPIM、PTSM、BTSM、自适应模式切换和 1 个真实果园案例 + 15 个构造实例验证。
- 与已有设计知识的区别：
  - 不同于“层级路径重构的约束感知 MRTA”：该知识以电量/容量/充电约束下的 route fragment 重构和小 MILP 分配为核心；本知识以任务可拆分、split ratio 和宏观/微观搜索节奏为核心。
  - 不同于“仓库锚定子路线编码与支配反馈自适应 VNS”：该知识通过 depot/resource anchor 保证前序可行性；本知识不依赖资源前序，而是动态同步路线结构和任务拆分表。
  - 不同于“区域压缩编码与多解路径解码”：该知识压缩路网区域以缩短路径编码；本知识关注任务需求拆分和多机器人负载均衡。
  - 不同于普通 split delivery VRP：本知识显式考虑多机器人多 route 复用和多目标 Pareto 搜索中的拆分触发时机。

## 解决的问题

- 适用场景：
  - 农业采摘、仓储拣选、配送分单、无人机覆盖、清扫/喷洒/巡检等任务需求可拆分的场景；
  - 执行体容量有限，需要多 trip 或多 route；
  - 任务服务量、负载、时间或能耗随 split ratio 变化；
  - 目标包含 makespan、总能耗、总成本、负载均衡、服务延迟或公平性；
  - 可接受同一任务由多个机器人/车辆分担，且有办法协调现场执行。
- 现有方法为什么会失败或不足：
  - 不可拆任务模型会错过负载平衡和瓶颈 route 缓解空间；
  - 只做 split delivery 而不考虑多 trip/多机器人复用，会低估 route assignment 的复杂度；
  - 固定编码难以支持 route 数量变化和拆分关系变化；
  - 随机拆分比例会扩大连续决策空间并拖慢收敛；
  - 只按空间最近拆分可能改善能耗但无法解决 makespan，单纯按时间均衡拆分又可能造成绕路。
- 仍需解决的问题：
  - 如何在非欧氏路网、障碍环境或通道约束下识别真正的偏离任务；
  - split ratio 的连续优化、整数化和可行性修复如何保持稳定；
  - 任务拆分导致的同步、拥堵、现场冲突和额外准备时间如何进入模型；
  - 大规模实例中，对所有非支配解做 MTSO 的计算预算如何控制；
  - 异构机器人、动态任务和机器人故障下如何继承 split table。

## 为什么可能有效

```text
route sequence controls spatial structure
-> early macro search prevents premature split-ratio fixation

split ratios control load and completion balance
-> late micro refinement improves convergence near useful structures

bottleneck robot exposes makespan pressure
-> DTPIM chooses candidate tasks on inefficient routes

spatial proximity and temporal balance conflict
-> PTSM and BTSM offer two complementary split moves
```

关键假设是：高质量解的改进通常来自少数瓶颈机器人、偏离任务或不均衡 routes，而不是需要同时重写全部 split ratios。如果所有任务都强耦合、现场同步成本很高，或任务不可自然拆成连续比例，该架构的收益会下降。

## 实现接口

- 输入：
  - 任务位置、需求量/服务量、服务时间或产量；
  - 机器人/车辆容量、速度、能耗、可用时间、route 或 trip 限制；
  - 距离/时间矩阵，必要时包含路网距离而非欧氏距离；
  - 目标函数和可行性检查器；
  - route operators、split operators 和非支配选择模块。
- 个体表示：
  - route sequence：任务访问顺序和机器人/route 分隔符；
  - split table：`task_id, agent_id, route_id, ratio_or_quantity`；
  - route metrics cache：每条 route 的负载、时间、能耗、剩余容量和任务片段；
  - agent schedule metrics：每个机器人/车辆的总时间、总能耗和 route 列表。
- 最小实现：

```text
initialize route sequence and split table

for each generation:
    if macro_search_is_selected:
        apply route swap / route transfer / route repartition
        repair capacity and merge duplicated split records
        improve changed routes by intra-route local search
    else:
        choose nondominated candidate
        find bottleneck agent by completion time
        choose deviated tasks from bottleneck routes
        generate proximity-based split insertions
        generate balance-based split transfers
        keep nondominated feasible variants

    synchronize route sequence and split table
    update objective values and nondominated archive
```

- 插入位置：
  - MOEA 的 encoding/variation layer；
  - ALNS/LNS 的 destroy-repair 阶段；
  - 多机器人调度器的后期 local refinement；
  - split delivery VRP 或 task allocation 的 Pareto archive polishing 阶段。

## 如何用于算法创新

### 局部创新

- 将 DTPIM 的几何 centroid 替换为 graph centroid、row-aware orchard distance、travel-time centrality 或 learned route criticality。
- 让 PTSM/BTSM 的选择由 bandit、UCB、Q-learning 或 offline policy 根据最近 HV improvement 触发。
- 用小规模 LP/MILP、convex search 或 integer rounding optimizer 精修 split ratio，而不是只用启发式比例公式。
- 在 split insertion 时同时考虑任务现场冲突、机器人安全距离、同步等待和 setup cost。
- 对 route metrics 做增量更新，避免每次 split 后全量重算所有路线。
- 给 split table 增加 versioning 或 provenance，用于动态任务新增、机器人故障后的局部恢复。

### 结构创新

- 构建通用 split-MRTA 框架：

```text
hybrid route/split encoding
macro route exploration
bottleneck and critical-task detector
micro split-ratio optimizer
multiobjective archive and restart strategy
```

- 在仓储拣选中，把同一订单行拆给多个机器人，先搜索货架访问 route，再在拥堵或超时机器人上拆分订单量。
- 在城市配送中，把大客户需求拆给多辆车，早期探索车辆路线，后期对最长路线或最高碳排路线做分单。
- 在无人机覆盖中，把区域 coverage task 拆成多个子覆盖量，结合续航和 makespan 做后期再平衡。
- 与充电/换电知识结合：把 bottleneck route 的判断从完成时间扩展为时间、电量、充电等待和能耗综合风险。
- 与 digital twin 结合：现场执行后回传实际采摘速度和剩余任务量，只更新 split table 和受影响 routes。

## 适用条件与风险

- 适用条件：
  - 任务需求可以合法拆分，并能用比例、数量或子任务集合表示；
  - 拆分后的任务片段可在目标函数中独立计入服务时间、载荷或成本；
  - route 层指标可增量计算或快速重算；
  - 执行体容量、route 分隔和任务分配可以通过 repair 保持可行；
  - 多目标冲突中至少存在负载均衡、完成时间或能耗改善空间。
- 不适用或可能失效的条件：
  - 任务不可拆，或拆分带来巨大协调/重复准备成本；
  - 任务服务必须严格同步，单纯 route-level split ratio 不足以描述时空冲突；
  - 路线可行性由复杂时间窗、排队或共享资源主导，简单 route sequence 难以修复；
  - 任务需求很小，拆分比例整数化后基本没有自由度；
  - MTSO 调用过密，导致种群过早围绕少数 route 结构收敛。
- 计算与实现成本：
  - 需要维护 route sequence 与 split table 的双向同步；
  - route 操作后必须合并、修复和重算受影响 split records；
  - PTSM/BTSM 要枚举候选接收 route 和插入位置，规模大时需 top-k 剪枝；
  - 若加入整数比例、同步冲突或异构能力，split refinement 可能需要精确优化器辅助。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0254 | AMRTA 同时考虑 orchard harvesting 中的多机器人、多 route、任务可拆分、机器人复用和 load-dependent energy | 问题建模 | Sec. III，PDF 3-5 |
| P2026-0254 | 目标为最小化 makespan 和 total energy，约束包括任务完成、容量、route 分配、负载传播和子回路消除 | 问题建模 | Sec. III，PDF 3-5 |
| P2026-0254 | 作者指出 task splittability 与 multiple routes 导致 variable-length/dynamic solution structure，固定编码不足 | 问题动机 | Introduction，PDF 1-2 |
| P2026-0254 | Hybrid encoding 用 `0` 分隔机器人、`1` 分隔同机器人多 route，并用 splitting information 记录 task/robot/route/ratio | 作者提出的方法 | Sec. IV-A，Fig. 2，PDF 5 |
| P2026-0254 | 自适应搜索参数按时间预算和 MTSO 成功比例调节，使早期偏 route structural optimization、后期偏 task splitting | 作者提出的方法 | Sec. IV-B，Algorithm 1，PDF 5-6 |
| P2026-0254 | ITO 使用四类 route 间任务交换/转移并采用 compound move strategy，允许中间劣解帮助跳出局部最优 | 作者提出/组合方法 | Sec. IV-C，PDF 6-7 |
| P2026-0254 | ISA 在初始化和 route 修改后优化路线内访问顺序，避免全量重复搜索 | 作者提出/组合方法 | Sec. IV-C，PDF 7 |
| P2026-0254 | MTSO 针对 bottleneck robot，在非支配解中逐个进行任务拆分精修 | 作者提出的方法 | Sec. IV-D，PDF 7 |
| P2026-0254 | DTPIM 根据 route centroid、depot 方向和相对距离识别 deviated task points | 作者提出的方法 | Sec. IV-D，PDF 7-8 |
| P2026-0254 | PTSM 根据空间邻近、接收 route 容量余量和时间平衡计算 split ratio，并评估插入位置 | 作者提出的方法 | Sec. IV-D，PDF 8 |
| P2026-0254 | BTSM 在最大和最小完工时间机器人之间构造独立 cycle 或插入已有 cycle，以缓解 makespan imbalance | 作者提出的方法 | Sec. IV-D，PDF 8-9 |
| P2026-0254 | 真实果园案例含约 660 个 harvestable trees 和 5 个 robots，AMTSA 的 Pareto front 与 knee solution 优于或支配多数对比算法 | 真实案例支持 | Sec. V-B，PDF 10-12 |
| P2026-0254 | 15 个构造实例上，AMTSA 在 HV、Friedman rank、post-hoc test 和 Cliff's delta 中整体优于 AMOEA、CDABC、MODABC、NSGA-II、RNSGA、RMOEA/D | 综合实验支持 | Sec. V-C，PDF 12-16 |
| P2026-0254 | 固定 `P`、禁用 DTPIM/PTSM/BTSM 和禁用成功率反馈的消融结果支持自适应模式和 MTSO 组件贡献 | 消融支持 | Sec. V-D，PDF 16-18 |
| P2026-0254 | 作者未来工作包括严格续航/充电、动态事件、异构团队、物流仓储迁移、learning-based MRTA 和实体机器人验证 | 作者未来工作 | Sec. VI，PDF 18 |

## 证据边界

- 当前只有单篇论文证据。
- 真实果园案例仍主要是仿真求解与数据案例，缺少实体多机器人闭环实验。
- 机器人同质、无故障，且未把严格电池容量、充电排队和动态任务纳入核心模型。
- 部分公式和图形在 Markdown 中为图片占位，精确实现需要回查 PDF。
- AMTSA 在 Pro7 上不总是优于 AMOEA，说明强随机探索在个别实例仍可能找到更高 HV。

## 待确认

- DTPIM 在非欧氏果园道路、障碍物或真实行间通道中是否仍能准确识别偏离任务；
- split ratio 的整数化、同步执行和现场协调成本对 makespan-energy Pareto 前沿的影响；
- MTSO 对大规模数千任务、动态滚动重规划或实时调度的计算上限；
- 与 ALNS/LNS、matheuristic、MOEA/D decomposition 和 exact split-delivery solver 的公平比较；
- 异构机器人、机器人故障、新任务到达和充电/换电约束下，混合编码与 split table 如何扩展。
