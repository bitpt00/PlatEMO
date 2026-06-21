---
knowledge_id: K-transfer-success-gated-constrained-unconstrained-multitask
name: 迁移成功率门控的约束-无约束双任务协同
type: architecture
status: active
source_papers: [P2026-0008]
aliases: [M3TMO, constrained-unconstrained multitask coevolution, transfer success rate prediction, CalKTRate, cross-task survival rate, constrained multimodal MOO multitasking, main task subtask transfer, 迁移成功率预测, 约束无约束双任务, 多任务约束多模态优化]
promotion_reason: 单篇论文提出但接口完整，包含原约束主任务、无约束目标子任务、前期非过滤交换、后期 cross-task survival 迁移成功率估计、历史迁移率修正、阈值门控、子任务随机重启和目标/决策双空间 fitness，可迁移到 CMOP、CMMOP、带约束 MMOP 和其他需要辅助无约束搜索的进化算法。
---

# 迁移成功率门控的约束-无约束双任务协同

## 核心内容

在 constrained MOP 或 constrained multimodal MOP 中，把同一个问题拆成两个互补任务：主任务保留原约束，负责最终可行 Pareto 解；子任务忽略约束，只在目标空间快速探索。前期让两任务宽松交换信息以跨越 infeasible regions；后期用 cross-task survival 估计信息迁移成功率，只有当对方任务信息在本任务选择中显示有效时，才加强跨任务注入，否则继续各自探索或局部搜索。

```text
Task A: original constrained problem
Task B: unconstrained objective problem

Stage 1:
    loose exchange between A and B
    each task selects in its own criterion

Stage 2:
    generate offspring in A and B
    evaluate B information under A selection
    evaluate A information under B selection
    update KT-Rate with historical correction
    if KT-Rate passes threshold:
        inject selected individuals from source task
    else:
        continue local task search
    restart stagnant subtask individuals
```

P2026-0008 的 M3TMO 是该模式的实例：`PopA` 处理原始约束问题，`PopB` 处理无约束问题，`CalKTRate` 用对方任务的环境选择保留情况和历史成功率判断信息是否值得迁移。

## 建立理由

- 为什么值得独立维护：
  - CMOP 中无约束任务常能帮助跨越不可行区，但无控制交换会带来负迁移；
  - CMMOP 不只要目标空间收敛，还要决策空间多模态覆盖，普通双种群约束算法不一定保留多个 PS；
  - 该方法把“辅助无约束搜索”与“迁移有效性检测”解耦，给出可复用的迁移准入层；
  - cross-task survival 比静态任务相似度更贴近当前搜索阶段。
- 单篇具体方法的直接复用价值：
  - P2026-0008 给出主/子任务更新、`CalKTRate`、历史修正、阈值控制、random restart、双空间 fitness 和 CMMOP 消融证据。
- 与已有设计知识的区别：
  - 不同于“多邻域多知识的分解式多任务迁移”：该知识面向多任务优化 benchmark 中已有任务之间的子问题/邻域/算子路由；本知识面向单个约束问题内部构造一个无约束辅助任务，并用跨任务保留率门控迁移。
  - 不同于“UPF/SPF 奖励双种群约束搜索”：该知识通过 archive contribution 调度 UPF/SPF 专家和目标-CV 平衡专家；本知识通过 source task 个体在 target task 环境选择中的保留情况估计迁移成功率。
  - 不同于“动态辅助任务构造”：该知识改变辅助任务维度、变量子集或任务池；本知识固定主/子任务定义，动态控制迁移准入和强度。
  - 不同于“MMOP 八机制组合设计框架”：该知识是综述型机制分类；本知识是具体可实现的 constrained multimodal multitasking 架构。

## 解决的问题

- 适用场景：
  - 可行域被大面积 infeasible regions 分割；
  - 原始问题存在多个 feasible Pareto solution sets 或局部可行区域；
  - 去掉约束后的 objective landscape 更易搜索；
  - 无约束解有时能提供跨越 infeasible region 的方向，但并非始终有效；
  - 算法能为同一编码维护至少两个 population。
- 现有方法为什么会失败或不足：
  - 固定无约束辅助种群会在后期把主任务拉向不可行 UPF；
  - 随机或固定概率迁移不能区分当前阶段的正迁移和负迁移；
  - 只靠 constrained population 容易困在局部可行域；
  - 传统 MMEA 的 clustering/niching 可能没有约束处理能力；
  - 只看目标空间 fitness 会丢失 CMMOP 所需的决策空间覆盖。
- 仍需解决的问题：
  - 迁移成功率是否应按 reference region、niche 或约束边界局部计算；
  - 阈值 `beta` 和历史权重 `lambda` 如何自适应；
  - 当无约束子任务与 CPF 完全无关时如何快速降权；
  - 高维和动态场景中，双任务维护成本与收益如何平衡。

## 为什么可能有效

```text
unconstrained task is easier
-> can find objective-promising regions across infeasible gaps
-> provides candidate directions to constrained main task

but unconstrained task can mislead
-> cross-task survival tests whether source information is useful now
-> historical correction reduces single-generation randomness
-> threshold gates transfer and limits oscillation

CMMOP needs decision-space coverage
-> fitness combines objective-space quality and decision-space distance
-> random restart in subtask reopens unexplored regions
```

关键假设是：source task 个体在 target task 环境选择中被保留，能近似代表当前迁移有用。如果环境选择本身短视、两任务目标尺度不一致，或 source task 只在局部区域有效，全局迁移率可能误判。

## 实现接口

- 输入：
  - 主任务评价：objectives + constraints + `CV`；
  - 子任务评价：objectives only；
  - 两个 population `PopA/PopB`；
  - 两套环境选择函数 `MainTaskEnvironmentSelection` 和 `SubTaskEnvironmentSelection`；
  - transfer threshold `beta`；
  - historical transfer weight `lambda`；
  - stagnation detector 和 restart ratio。
- 输出：
  - 更新后的主任务 population；
  - 可选的子任务 population；
  - 双向 `KT-RateA/KT-RateB`；
  - 可追踪的迁移来源、保留率、决策空间覆盖。
- 插入位置：
  - 双种群 CMOEA；
  - CMMOP/MMEA 中需要加约束处理的算法；
  - push-pull / UPF-first 类约束算法的迁移控制层；
  - EMT/MFEA 框架中的 task interaction controller。
- 最小实现：

```text
initialize PopA for constrained task
initialize PopB for unconstrained task

while budget remains:
    if not phase_transition():
        A_new <- GA(PopA, N/2)
        B_new <- GA(PopB, N/2)
        PopA <- MainSelect(PopA union A_new union B_new, N)
        PopB <- SubSelect(PopB union A_new union B_new, N)
    else:
        A_new <- GA(PopA, N/2)
        B_new <- GA(PopB, N/2)

        A_cross <- MainSelect(PopB union B_new, N)
        KT_A <- historical_update(KT_A, survival_count(A_cross, PopB, B_new), lambda)

        B_cross <- SubSelect(PopA union A_new, N)
        KT_B <- historical_update(KT_B, survival_count(B_cross, PopA, A_new), lambda)

        if KT_A > beta:
            B_in <- random_select(PopB, N/2)
        else:
            B_in <- B_new
        PopA <- MainSelect(PopA union A_new union B_in, N)

        if KT_B > beta:
            A_in <- random_select(PopA, N/2)
        else:
            A_in <- A_new
        PopB <- SubSelect(PopB union A_in union B_new, N)

        if stagnant(PopB):
            restart_some(PopB)
```

## 如何用于算法创新

### 局部创新

- 将固定迁移概率替换为 cross-task survival rate。
- 把 `KT-Rate` 从全局标量改为 per-reference-vector、per-cluster、per-niche 或 per-constraint-boundary 迁移率。
- 对历史迁移率使用指数衰减、滑动窗口、UCB 或 Bayesian success estimator，替代固定 `lambda`。
- 在 `MainSelect` 中同时记录 source labels，区分来自子任务原个体和子任务 offspring 的贡献。
- 对子任务 restart 使用 archive novelty 或未覆盖 feasible region 方向，而不是纯随机初始化。
- 在 CMMOP fitness 中动态调节 objective-space 与 decision-space 权重，避免后期目标收敛被过度决策多样性拖慢。

### 结构创新

- 通用 constrained-unconstrained EMT 架构：

```text
constrained main task
+ unconstrained helper task
+ cross-task survival evaluator
+ transfer gate
+ dual-space fitness / archive
+ stagnation restart
```

- 与 UPF/SPF 机制结合：无约束子任务负责 UPF，若迁移成功率下降则切换到 SPF 或 boundary-infeasible helper。
- 与多模态子群结合：每个 decision-space cluster 维护自己的 unconstrained helper，局部估计迁移成功率。
- 与代理模型结合：用 surrogate 预估 source 个体在 target task 中的 survival probability，减少真实评价或环境选择成本。
- 与动态 CMOEA 结合：环境变化后保留历史 `KT-Rate` 但增加折扣，快速判断无约束历史信息是否仍有效。

## 适用条件与风险

- 适用条件：
  - 约束去掉后问题明显更容易探索；
  - 无约束目标优质区域与可行 PF 或边界有一定相关性；
  - 主/子任务使用相同编码和可共享个体；
  - 环境选择能记录 source 个体是否被保留；
  - 需要在决策空间保留多模态解。
- 不适用或可能失效的条件：
  - UPF 与 CPF 完全分离，且无约束解长期无助于可行性；
  - 可行域极窄，辅助解与主任务 feasible boundary 距离过大；
  - 高维问题中双任务 + cross-task selection 成本过高；
  - 动态问题中历史迁移率快速过期；
  - decision-space distance 不可靠，fitness 的多模态项可能误导选择。
- 计算与实现成本：
  - 每代需要两套 population 和两套环境选择；
  - 第二阶段还需要额外 cross-task selection 估计 `KT-Rate`；
  - 若环境选择类似 SPEA2 且同时考虑目标/决策距离，复杂度可达 `max{O(dN^3), O(mN^3)}`；
  - 需要维护迁移历史和停滞检测。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0008 | M3TMO 维护 `PopA` 主任务和 `PopB` 子任务，主任务考虑约束，子任务忽略约束 | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 3-4 |
| P2026-0008 | 第一阶段 `PopA/PopB` 各生成 `N/2` offspring，并在两个任务的环境选择中无过滤交换 | 作者提出的方法 | Sec. 3.2，Algorithm 2，PDF 4 |
| P2026-0008 | 第二阶段先计算双向 `KT-Rate`，再根据阈值判断是否从对方任务随机选择个体参与环境选择 | 作者提出的方法 | Sec. 3.3，Algorithm 3，PDF 4-5 |
| P2026-0008 | `CalKTRate` 通过把 source population 放入 target task 环境选择，统计被筛选个体数来估计迁移有效性 | 作者提出的方法 | Sec. 3.4，Algorithm 4，Eq. (6)，PDF 5 |
| P2026-0008 | 迁移率公式引入历史成功率，减少单代随机性并避免第二阶段完全不交换信息 | 作者提出的方法 | Sec. 3.4，PDF 5 |
| P2026-0008 | Fitness 同时考虑 objective-space convergence/diversity 和 decision-space nearest-neighbor distance | 作者提出/组合方法 | Sec. 3.5，PDF 5 |
| P2026-0008 | M3TMO 在 CF 上整体优于 BiCo、CMOEAD、CTAEA、MSCMO，并与 PPS/MOEADDAE 接近 | 综合实验支持 | Sec. 4.4，Tables 1-2，PDF 6-8 |
| P2026-0008 | DASCMOP 上 M3TMO 在 narrow feasible domains 中会退化，但在 DASCMOP5 等问题上获得更均匀 PF 和更多 feasible regions | 综合实验与边界 | Sec. 4.5，Fig. 7，PDF 8-9 |
| P2026-0008 | MW 上 M3TMO 排名第一 7 次、第二 6 次，但 MW11 受决策空间分布不一致影响较大 | 综合实验与边界 | Sec. 4.6，PDF 9 |
| P2026-0008 | CMMOP 中 M3TMO 相比 CMMOCEA 仅在 CMMOP2 和 CMMOP6 更差，其余更好或相当 | CMMOP 实验支持 | Sec. 4.8，Table 4，PDF 11-12 |
| P2026-0008 | 相比 DNNSGAII、MMEAWI、MMOEAC、MO Ring PSO SCD 和 TriMOEATAR，M3TMO 在 CMMOP IGDX 上整体优势明显 | CMMOP 实验支持 | Sec. 4.8，Table 3，PDF 11 |
| P2026-0008 | Portfolio real-world problem 中 M3TMO HV 为 `0.76536`，优于列出的 BiCo、CCMO、CMOEAD、MTCMO | 真实问题支持 | Sec. 4.9，Table 5，PDF 12 |
| P2026-0008 | 去掉任务 B 的 `M3TMO-1` 相对完整 M3TMO 为 `0/13/1`，支持无约束子任务的贡献 | 消融支持 | Sec. 4.10.1，Table 6，PDF 13 |
| P2026-0008 | 去掉迁移成功率过滤的 `M3TMO-2` 相对完整 M3TMO 为 `0/7/7`，支持迁移准入机制 | 消融支持 | Sec. 4.10.2，Table 7，PDF 13 |
| P2026-0008 | 参数分析显示 `lambda=0.05` 优于 `0` 和 `0.15`，历史经验需要少量但不宜过强 | 参数证据 | Sec. 4.11，Table 8，PDF 13-14 |
| P2026-0008 | 作者指出 M3TMO 在高维和动态问题上表现较弱，未来需重点研究 | 作者局限 | Sec. 5，PDF 14 |

## 待确认

- `KT-Rate` 是否应按局部 niche/reference region 维护，而不是全局一份；
- threshold `beta` 在不同问题上是否需要自适应或学习；
- 历史迁移率应使用固定 `lambda`、滑动窗口还是折扣累计；
- 当主/子任务目标空间相近但可行性完全不同，cross-task survival 是否会高估迁移价值；
- 如何扩展到高维、动态、离散混合变量和昂贵评价场景。

