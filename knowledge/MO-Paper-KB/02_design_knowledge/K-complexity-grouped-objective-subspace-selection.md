---
knowledge_id: K-complexity-grouped-objective-subspace-selection
name: 复杂度分组的目标子空间排序
type: method
status: active
source_papers: [P2026-0187]
aliases: [population grouping, objective subspace ranking, complexity-grouped selection, complexity subspace archive, budget-stratified Pareto selection, resource-binned NAS selection, 复杂度分组, 目标子空间排序, 预算分层Pareto选择]
promotion_reason: 单篇论文提出但接口明确，包含按复杂度目标切分 objective space、组内独立非支配排序、跨组 archive 合并和下一代选择，可直接移植到 NAS、模型压缩、硬件感知优化和其他性能-资源双目标搜索中以缓解目标优化难度不平衡
---

# 复杂度分组的目标子空间排序

## 核心内容

在性能-资源双目标搜索中，降低复杂度往往比提升性能容易，普通全局 Pareto selection 容易把搜索吸向低复杂度但性能不足的区域。复杂度分组的目标子空间排序先按资源/复杂度目标把 objective space 切成多个预算区间，再在每个区间内独立做非支配排序和潜力解保留。这样，即使某个较高复杂度架构在全局上被更小模型支配，只要它在本预算区间内有潜力，也能被 archive 保留并继续演化。

```text
offspring + archive
-> split by complexity/resource intervals
-> nondominated sorting inside each interval
-> collect local nondominated candidates
-> form archive across budget groups
-> select next population from grouped archive
```

## 建立理由

- 为什么值得独立维护：
  - 该机制不是 LightMix 专属，可插入任何 accuracy-cost、quality-resource 或 performance-latency 型多目标搜索；
  - 它明确处理“一个目标容易优化、另一个目标难优化”的难度不平衡，而不是只改变目标权重；
  - 它能保证不同资源预算档位都有候选继续参与进化，适合实际部署中的多预算 Pareto 需求。
- 与已有设计知识的区别：
  - 不同于“目标值均衡的二级环境选择”：该知识处理 crowding distance 平局和 objective-value multiplicity；本知识按复杂度区间切分目标空间，让局部被全局支配的预算档位候选继续存活。
  - 不同于“多保真不确定集成的 NAS 评价加速”：该知识处理评价成本和不确定性；本知识处理环境选择与 archive 的预算分层。
  - 不同于“可训练性约束的在线分类器辅助 NAS”：该知识用 trainability gate 排除低潜力架构；本知识不做分类准入，而是分组排序保留不同复杂度层次。
  - 不同于“结构保真的架构编码与修复”：该知识维护候选结构合法性和 backbone 信息流；本知识维护目标空间不同复杂度段的搜索多样性。

## 解决的问题

- 适用场景：
  - NAS、模型压缩、硬件感知架构搜索、特征选择、调度或工程设计中同时优化性能和资源；
  - 复杂度目标可通过删除模块、减少通道或缩小规模快速改善；
  - 性能目标评价困难、噪声大或需要复杂结构组合；
  - 用户最终需要多个预算档位下的候选，而不是单一最小复杂度解。
- 现有方法为什么会失败或不足：
  - 全局 Pareto ranking 容易保留大量超低复杂度解，使较高预算但潜在高性能的结构早早消失；
  - 固定 performance-preferred 参数或 scalarization 需要任务调参；
  - 只用 crowding/density 不能保证每个预算区间都有代表；
  - archive 若只存全局非支配解，会忽略“当前全局被支配但在某预算范围内有演化价值”的候选。

## 为什么可能有效

- 资源预算通常是实际部署的外部约束；把目标空间按预算分层，相当于同时求解多个局部 constrained Pareto 子问题。
- 在每个复杂度区间内独立排序，使选择压力从“越小越好”转为“在当前预算内性能-复杂度权衡最好”。
- 局部 archive 保留高预算区域的潜力解，可为后续交叉/变异提供表达力更强的 parent。
- 对多预算输出任务，分组本身就是一种 coverage constraint，能提高最终 Pareto set 在资源轴上的覆盖。

## 实现接口

- 输入：
  - 当前 archive `A_{g-1}`；
  - offspring population `Q_g`；
  - objective values，其中至少一个是 complexity/resource objective；
  - 复杂度阈值或分位数边界；
  - population size `T`。
- 输出：
  - 新 archive `A_g`；
  - 下一代 population `P_g`。
- 插入位置：
  - MOEA 环境选择；
  - NAS archive update；
  - 模型压缩/硬件感知搜索的候选保留；
  - 多预算 Bayesian/evolutionary search 的 batch selection 前。

最小流程：

```text
U <- A_{g-1} union Q_g
groups <- split_by_complexity(U, thresholds)

A_g <- empty
for each group in groups:
    fronts <- nondominated_sort(group)
    A_g <- A_g union first_front(fronts)

if |A_g| > T:
    P_g <- global_nondominated(A_g)
    while |P_g| < T:
        P_g <- P_g union binary_tournament(A_g \ P_g)
elif |A_g| == T:
    P_g <- A_g
else:
    P_g <- rank_select(A_{g-1} union Q_g, T)
```

复杂度分组可以是固定阈值、分位数阈值、reference budget、用户预算或硬件约束区间。

## 如何用于算法创新

### 局部创新

- 把固定复杂度阈值改为按 archive quantiles 自适应更新，保证每个 group 个体数接近。
- 在组内排序时加入 uncertainty、hypervolume contribution、reference-vector density 或 surrogate reliability。
- 用二维资源网格分组，例如 `latency x memory`、`Params x MAdds`、`cost x energy`。
- 为每个复杂度组设置不同 mutation/crossover rate，高预算组偏探索表达力，低预算组偏压缩和精修。
- 对组间 parent selection 加入跨预算交配，让高预算结构向低预算结构迁移有效模块。

### 结构创新

- 构建“预算分层 Pareto archive”：

```text
global search population
-> budget-grouped local Pareto archives
-> group-aware reproduction
-> multi-budget final model set
```

- 与硬件感知 NAS 结合：每个目标设备或 latency bin 拥有局部 archive，最终直接输出多设备候选。
- 与昂贵评价结合：低保真代理先在所有预算组内保留局部潜力解，再把真实评价预算分配给各组代表。
- 与多任务/多场景优化结合：把“场景约束”或“用户预算”当作分组轴，避免单一容易场景吸走搜索。

## 适用条件与风险

- 适用条件：
  - 资源/复杂度目标可快速计算；
  - 不同资源预算下的候选都可能有实际价值；
  - 目标优化难度不平衡明显；
  - archive 或 population 足够大，能支持多个 groups。
- 不适用或可能失效的条件：
  - 复杂度阈值设置不合理，导致某些组为空或过满；
  - 高复杂度区域确实没有应用价值，分组会浪费预算；
  - 性能代理偏向某些复杂度段，组内排序仍会有偏；
  - 资源目标多维但被压成单一复杂度值，可能误保留硬件上不可部署的候选；
  - 分组过细会降低每组选择压力，分组过粗则退化为普通全局 Pareto。
- 计算与实现成本：
  - 需要额外维护 group assignment 和 grouped archive；
  - 组内 non-dominated sorting 可降低每次排序规模，但 archive 合并和补齐逻辑更复杂；
  - 自适应阈值需要额外监控资源分布。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0187 | 作者指出多目标 NAS 中 architecture complexity 和 performance 的优化难度严重不平衡，搜索会过度优化更容易的复杂度目标 | 问题动机 | Introduction、Sec. IV-D，PDF 2、7 |
| P2026-0187 | LightMixNets 搜索中按复杂度切分 objective space，在每个 complexity subspace 内独立做 non-dominated sorting | 作者提出的方法 | Sec. IV-D、Fig. 7、Algorithm 2，PDF 7 |
| P2026-0187 | CIFAR 实验按 #Params 阈值 `[0.5M,1M,1.5M,2M]` 划分 5 个 subpopulations；ImageNet 按 #MAdds `[200M,300M,400M,500M]` 分组 | 实现设置 | Sec. V-B，PDF 8 |
| P2026-0187 | `size(A_g)>T` 时先选 global non-dominated architectures，再用 binary tournament 补齐；`size(A_g)<T` 时回到 `A_{g-1} ∪ Q_g` 全局排序补齐 | 作者提出的方法 | Sec. IV-D、Algorithm 2，PDF 7 |
| P2026-0187 | Search trajectory 显示 archive 多样性随进化增加，作者认为主要受益于 population grouping | 机制观察 | Sec. VI-C、Fig. 9，PDF 10-11 |
| P2026-0187 | 无 grouping 时最终 archive 都低于 1.1M #Params；有 grouping 后能探索更高复杂度区域，并在重叠区找到更优架构 | 消融实验 | Sec. VI-G、Fig. 12，PDF 13 |
| P2026-0187 | 完整 LightMix 搜索在 CIFAR 和 ImageNet 上快速得到多个不同复杂度档位的 LightMixNets，搜索成本分别约 0.02 和 0.3 GPU days | 综合实验支持 | Abstract、Sec. VI-A-B，PDF 1、9-10 |

## 证据边界

- 当前证据来自单篇 NAS 论文，且与 LightMix search space 和 NASWOT proxy 同时使用。
- 该机制的收益与复杂度阈值有关；论文使用人工固定阈值，没有给出自动分组策略。
- Population grouping、LightMix block、NASWOT 和 search space 共同贡献性能，不能把所有结果单独归因于 grouping。
- 论文主要用 #Params/#MAdds，没有直接验证真实硬件 latency、energy 或 memory peak。

## 待确认

- 动态复杂度阈值是否优于固定阈值；
- 对三目标以上资源目标，应该用多维网格还是主资源轴分组；
- 与 reference-vector MOEA 或 epsilon-constraint MOEA 的关系和冗余度；
- 在非 NAS 的工程设计问题中，局部被全局支配解是否同样具有后续演化价值；
- 如何把真实硬件测量噪声纳入组内排序。
