---
knowledge_id: K-som-topology-dualtask-constrained-multimodal-coevolution
name: SOM 拓扑双任务的约束多模态协同
type: architecture
status: active
source_papers: [P2026-0116]
aliases: [DSCMMOEA, dual-task-assisted self-organizing map evolutionary algorithm, SOM-assisted CMMOP, constrained multimodal dual-task coevolution, dynamic offspring sharing, adaptive dual-space pruning, self-organizing map CMMOEA, 约束多模态双任务, SOM拓扑学习, 双空间自适应剪枝]
promotion_reason: 单篇论文提出但流程完整，包含受约束 SOM 主任务、无约束辅助任务、动态 offspring sharing、目标/决策双空间 fitness、adaptive pruning、CMMOP/CMOP/真实选址/RWMOP 证据和组件消融，可直接改造 CMMOP、带约束 MMOP 和需要多解可行设计的进化算法架构。
---

# SOM 拓扑双任务的约束多模态协同

## 核心内容

在 constrained multimodal multi-objective optimization 中，不把“找可行 CPF”和“跨越不可行区探索”压进同一个 population。维护两个互补任务：主任务保留原约束，并用 SOM 学习当前可行 Pareto front/solution sets 的拓扑；辅助任务忽略约束，只追 objective-promising 区域，允许利用高质量 infeasible solutions 穿越断裂可行域。两任务每代共享 offspring，最后用同时考虑目标空间和决策空间的 fitness 与 pruning 选择下一代。

P2026-0116 的 DSCMMOEA 是该模式的实例：`P1` 是 constrained main task，`P2` 是 unconstrained auxiliary task；`P1` 训练 SOM 并用神经元邻域组织父代选择，`P2` 用常规 GA/DE 探索；环境选择按双空间 density 和 adaptive pruning 保留在目标和决策空间都不拥挤的解。

```text
P1: constrained main task
    objective dominance + constraint dominance
    train SOM on P1
    winner-neighbor mating -> O1

P2: unconstrained auxiliary task
    objective dominance only
    GA/DE offspring -> O2

dynamic offspring sharing:
    O2 helps P1 cross infeasible gaps
    feasible/well-converged P1 information guides P2

environmental selection:
    convergence + dual-space density fitness
    if nondominated set too large:
        compare most-crowded decision-space solution
        with most-crowded objective-space solution
        prune the worse one sequentially
```

## 建立理由

- 为什么值得独立维护：
  - CMMOP 同时要求 constraint satisfaction、CPF convergence、objective-space diversity 和 decision-space CPS coverage；
  - CMOEA 的约束处理容易只保留局部可行 PF，MMOEA 的多模态机制又通常不能处理复杂约束；
  - 无约束辅助任务可以跨越 infeasible regions，但必须由受约束主任务和双空间选择回收，避免长期追错 UPF；
  - SOM 提供轻量拓扑保持学习器，适合 CPF/CPS 拓扑未知、可行域离散或断裂的场景。
- 单篇具体方法的直接复用价值：
  - P2026-0116 给出 Algorithm 1-4，明确了双任务框架、fitness assignment、SOM training、dynamic environmental selection 和 adaptive pruning；
  - CHT、双任务、权重和 pruning 均有变体消融；
  - 实验覆盖 CMMF/CMMOP、MW/CF/C_DTLZ、site selection 和 RWMOP；
  - 作者报告 computational complexity 为 `O(MN^2 log N)`，运行时间处于对比算法中低水平。
- 与已有设计知识的区别：
  - 不同于“迁移成功率门控的约束-无约束双任务协同”：该知识用 cross-task survival rate 和阈值门控迁移；本知识没有显式迁移率门控，核心是 SOM 主任务拓扑学习和双空间 adaptive pruning。
  - 不同于“局部流形双知识迁移与资源分配”：该知识面向多任务优化中已有任务之间的 LPCA/SOM 局部流形迁移；本知识在单个 CMMOP 内部人为构造 constrained/unconstrained 两个任务。
  - 不同于“时空图学习的多模态 PS 子代生成”：该知识用 GNN/GCN 直接生成 MMOP 子代；本知识用 SOM 组织主任务 mating，并把约束处理和无约束辅助任务作为架构核心。
  - 不同于“UPF/SPF 奖励双种群约束搜索”：该知识奖励 UPF/SPF 专家贡献；本知识主要处理多模态 CPS 覆盖，并用双空间 pruning 保留多个等价解集。

## 解决的问题

- 适用场景：
  - 可行域被 infeasible regions 分割成多个离散或狭窄区域；
  - 同一个 CPF 对应多个相距较远的 CPS；
  - 约束去掉后 objective landscape 能提供跨域探索信息；
  - 决策空间距离能大致反映不同 CPS 的分离；
  - 可以维护至少两个 population，并承担 SOM 和双空间密度计算。
- 现有方法为什么会失败或不足：
  - 可行优先或 CDP 容易过早收缩到局部可行域；
  - 只追 UPF 的无约束辅助种群可能长期远离 CPF；
  - 只看 objective crowding 会保留目标空间分散但决策空间重复的解；
  - 直接把 decision/objective crowding 相加会让一个空间的优势掩盖另一个空间的严重拥挤；
  - 复杂 CPF/CPS 拓扑事先未知，预定义图或固定邻域可能带来偏置。
- 仍需解决的问题：
  - 如何在线判断无约束辅助任务是否正在负迁移；
  - SOM 神经元数、初始半径和训练频率如何自适应；
  - 高维下双空间距离和 density 是否稳定；
  - many-objective 下 adaptive pruning 如何避免二级选择成本过高；
  - 离散/混合变量 CMMOP 中如何定义 SOM 输入和邻域。

## 为什么可能有效

```text
CMMOP has disconnected feasible regions
-> constrained main task alone may stay in one feasible island
-> unconstrained auxiliary task can traverse infeasible gaps
-> shared offspring brings candidate directions back to main task

CMMOP has multiple equivalent CPSs
-> objective-space convergence is not enough
-> SOM preserves topology of current decision/objective distribution
-> dual-space density fitness encourages CPS coverage

single-space truncation loses diversity
-> adaptive pruning checks decision and objective crowding separately
-> survivors must be acceptable in both spaces
```

关键假设是：无约束辅助任务产生的 objective-promising infeasible solutions 与 CPF/CPS 至少部分相关，且 SOM 从当前主任务 population 学到的拓扑不会严重偏离真实 CPS。若 UPF 与 CPF 完全分离、早期主任务样本过少或高维距离失真，辅助共享和 SOM 邻域都可能误导搜索。

## 实现接口

- 输入：
  - 原始 objectives、constraints 和总约束违反 `CV`；
  - 主任务 population `P1` 与辅助任务 population `P2`；
  - SOM 网络规模、初始 learning rate、初始 neighborhood radius `sigma`；
  - decision-space distance 与 objective-space distance；
  - population size `N` 和最大迭代数 `G`。
- 输出：
  - 更新后的主任务 population，作为最终解集；
  - 可追踪的辅助任务贡献、offspring source labels、dual-space density、pruning records；
  - SOM 神经元权重和 winner-neighbor 交配关系。
- 插入位置：
  - CMMOP 专用 MOEA 框架；
  - MMOEA 加约束处理时的架构层；
  - CMOP 中需要保留多个可行设计备选方案的双种群算法；
  - 工程选址、布局、路径规划或多解设计中的可行域断裂场景。
- 最小实现：

```text
initialize P1, P2, SOM
for g in 1..G:
    fit1 = constrained_fitness(P1)
    fit2 = unconstrained_fitness(P2)

    SOM = train_som(P1, fit1, g, G)
    O1 = som_neighbor_reproduction(P1, SOM, fit1)
    O2 = ga_de_reproduction(P2)

    C1 = P1 + O1 + selected(O2)
    C2 = P2 + O2 + selected(O1)

    P1 = dual_space_environmental_selection(C1, N, constrained=True)
    P2 = dual_space_environmental_selection(C2, N, constrained=False)

return P1
```

## 如何用于算法创新

### 局部创新

- 用 per-region transfer survival rate 控制 `O1/O2` 共享强度，避免全局无差别交换。
- 将 SOM 半径 `sigma` 与 feasible ratio、IGDX stagnation 或 CPS cluster count 绑定。
- 用 growing SOM 或 neural gas 自动适配未知 CPS 数量和形状。
- 在辅助任务中加入 boundary-distance 或 feasibility classifier，优先共享可修复 infeasible offspring。
- 把 adaptive pruning 的 crowding distance 替换为 local entropy、nearest-neighbor graph sparsity 或 topology persistence。

### 结构创新

- 通用 CMMOP 架构：

```text
constrained topology-preserving main task
+ unconstrained infeasible explorer
+ dynamic offspring exchange
+ dual-space fitness
+ adaptive dual-space pruning
```

- 与迁移门控结合：对每个 reference vector 或 decision cluster 估计 source offspring 的保留率，只在正迁移区域共享。
- 与代理模型结合：辅助任务先用 surrogate 评估不可行 offspring 的可修复性，再交给主任务真实评价。
- 与 graph reproduction 结合：SOM 负责全局拓扑分区，GNN/GCN 在每个 SOM 邻域内生成局部候选。
- 与多目标选址/布局结合：每个可行岛维护一个 SOM neighborhood，输出多个可替换工程方案。

## 适用条件与风险

- 适用条件：
  - 约束可行域断裂或窄小；
  - 问题需要多个等价可行解，而不是只要一个收敛解；
  - 无约束目标优质区域与可行 CPF 有一定相关性；
  - 决策空间距离能区分 CPS；
  - 计算预算足以支持双种群、SOM 和 `O(MN^2 log N)` 级选择。
- 不适用或可能失效的条件：
  - UPF 与 CPF 长期完全分离；
  - 高维连续变量中欧氏距离严重集中；
  - 可行域极窄且辅助 offspring 很难被修复；
  - 目标数很高时 crowding/density 不稳定；
  - 离散或强组合约束下 SOM 权重向量缺少有效语义。
- 计算与实现成本：
  - fitness density 需要 `O(N^2 log N)`；
  - SOM training 约 `O(N^2)`；
  - adaptive environmental selection 约 `O(MN^2 log N)`；
  - 需要维护两套 population 和跨任务 offspring 来源。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0116 | DSCMMOEA 初始化 constrained main task `P1`、unconstrained auxiliary task `P2` 和 SOM，循环执行 fitness、SOM offspring、辅助 offspring、offspring sharing 和环境选择 | 作者提出的方法 | Sec. 3.1、Algorithm 1，PDF 5-6 |
| P2026-0116 | 主任务 convergence index 结合 objective dominance 和 constraint dominance，辅助任务只按 dominance 忽略约束 | 作者提出的方法 | Sec. 3.2、Algorithm 2，PDF 7 |
| P2026-0116 | diversity 由 decision-space 与 objective-space `k=sqrt(N)` 近邻密度合成，decision-space 权重随迭代逐步增加 | 作者提出的方法 | Sec. 3.2，PDF 8 |
| P2026-0116 | SOM training 动态更新 learning rate 和 neighborhood radius，按 winner neuron/neighborhood 组织 mating pool，并用 SBX/PM 生成 offspring | 作者提出的方法 | Sec. 3.3、Algorithm 3，PDF 8-12 |
| P2026-0116 | adaptive pruning 分别找决策空间和目标空间最小 crowding distance 个体，比较后顺序删除表现更差者 | 作者提出的方法 | Sec. 3.4-3.5、Algorithm 4、Fig. 4，PDF 12-14 |
| P2026-0116 | DSCMMOEA+DS 在 31 个 CMMOP 的 IGD 上相对 CDP/ToR/ST 均为 `0/30/1` | CHT 消融支持 | Sec. 4.2、Table 1，PDF 16 |
| P2026-0116 | DSCMMOEA+DS 在 Table 2/3 中分别取得 24 个最优 IGDX 和 30 个最优 CPSP，优于其他 CHT 变体 | CHT 消融支持 | Sec. 4.2、Tables 2-3，PDF 18 |
| P2026-0116 | 双任务变体 `T1/T2/T3` 在 IGDX 上均弱于完整 DSCMMOEA，说明单任务或去约束变体不能同时覆盖所有 CPS | 双任务消融 | Sec. 4.2、Fig. 7，PDF 18 |
| P2026-0116 | 权重和 pruning 变体实验显示完整动态权重与 adaptive pruning 在 CMMOP 上更稳定 | 机制消融 | Sec. 4.2、Fig. 8-9，PDF 12、18-19 |
| P2026-0116 | CMMOP 综合分析认为 DSCMMOEA 在 IGD、IGDX、CPSP 上整体优于十个对比算法，objective/decision rank 最优 | 综合实验支持 | Sec. 4.3.3、Fig. 12-13，PDF 25 |
| P2026-0116 | runtime 处于中低水平，主要额外成本来自 pruning，但总体可接受 | 复杂度与效率证据 | Sec. 3.6、Sec. 4.3.3、Fig. 14，PDF 14、25 |
| P2026-0116 | `sigma=4` 的 SOM 初始邻域半径总体表现最好，过大或过小均会退化 | 参数证据 | Sec. 4.4，PDF 25 |
| P2026-0116 | site selection 中 DSCMMOEA 在 IGD、IGDX、CPSP 上显著优于所有对比算法，并覆盖多个可行最优区域 | 真实 CMMOP 支持 | Sec. 4.5、Table 8、Fig. 16，PDF 28 |
| P2026-0116 | CMOP 上 DSCMMOEA 的 IGD rank 最优、HV rank 仅次于 C-TAEA；RWMOP 上总体仅略弱于 C-CMMO | 兼容性与真实 CMOP 支持 | Sec. 5.2-5.3、Fig. 19-20、Table 10，PDF 29-30 |
| P2026-0116 | 作者未来希望进一步精炼 DSCMMOEA、用于更复杂工程问题并扩展到高维问题 | 边界与未来工作 | Sec. 6，PDF 31 |

## 待确认

- 无约束辅助任务的贡献是否应按局部 CPS/reference region 估计，而不是全局共享；
- SOM topology 在高维决策空间中是否需要降维、metric learning 或局部图约束；
- adaptive pruning 是否能扩展到 many-objective 或离散组合 CMMOP；
- `sigma`、神经元规模和双空间权重是否可由搜索状态自适应；
- 当 feasibility 与 objective quality 严重冲突时，辅助任务的负迁移如何快速识别。
