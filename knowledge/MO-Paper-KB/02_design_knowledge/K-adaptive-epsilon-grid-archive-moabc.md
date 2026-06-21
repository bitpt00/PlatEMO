---
knowledge_id: K-adaptive-epsilon-grid-archive-moabc
name: 自适应 ε 支配与网格档案的多目标蜂群搜索
type: method
status: active
source_papers: [P2026-0294]
aliases: [Adaptive epsilon MOABC, Adaptive ε MOABC, adaptive epsilon dominance, epsilon-dominance archive, grid pruning archive, multi-objective artificial bee colony, archive-based MOABC, ε支配蜂群, 网格档案剪枝, 多目标人工蜂群]
promotion_reason: P2026-0294 将自适应 ε-dominance、外部非支配档案和 objective-grid pruning 明确嵌入 ABC 的 employed/onlooker/scout 三阶段，形成可直接迁移到 swarm/MOEA 档案控制和多目标工程优化的具体方法接口。
---

# 自适应 ε 支配与网格档案的多目标蜂群搜索

## 核心内容

在 archive-based swarm 或 MOEA 中，不直接用普通 Pareto dominance 管理全部选择与档案。先引入随迭代递减的 ε-dominance：早期 ε 较大，支配关系更少，更多候选可作为近似非支配解保留下来以扩展搜索；后期 ε 逐渐变小并趋近 Pareto dominance，选择压力增强，推动收敛。并行维护 external non-dominated archive；每轮把当前种群与 archive 合并、筛掉 ε-dominated 解。若 archive 超过容量，则把 objective space 归一化划分为网格，优先从 overcrowded cells 中删解，保留 sparse cells，以兼顾规模控制和前沿覆盖。

```text
population + external archive
-> epsilon schedule: epsilon_max -> epsilon_min
-> offspring generation by ABC / swarm / MOEA operator
-> epsilon-dominance replacement
-> merge population and archive
-> epsilon-nondominated filtering
-> if archive overflow: objective-grid density pruning
-> archive guides next selection and final Pareto set
```

P2026-0294 的具体实例是 Adaptive ε MOABC：employed bees 和 onlooker bees 生成邻域候选后，仅在 offspring ε-dominates parent 时替换；onlooker selection 使用 ε-rank 与 density/grid occupancy 形成 fitness；scout bee 用随机重启补探索；archive update 用 ε-nondominated sorting 和 grid pruning 输出 Pareto approximation。

## 建立理由

- 为什么值得独立维护：
  - 普通 Pareto dominance 在多目标搜索中常出现选择压力弱、互不支配解过多、archive 迅速膨胀的问题。
  - 固定 crowding distance 或随机截断只在超容量时工作，不能同时调节搜索阶段的 dominance pressure。
  - ε-dominance、external archive 和 grid pruning 是三个可拆卸接口，可嵌入 ABC、PSO、DE、GA、MOEA/D 或代理辅助算法。
  - 工程 MOO 中决策者通常需要有限但分散的候选集，archive 控制比单纯追求末代种群表现更重要。
- 单篇具体方法的直接复用价值：
  - P2026-0294 给出完整算法结构：初始化、adaptive ε、employed/onlooker/scout replacement、archive merge、grid pruning 和 benchmark/OPF 验证。
  - 该机制不依赖 OPF 特定变量，可以作为通用多目标 swarm 的 selection/archive layer。
  - 消融显示 fixed ε 和 no-grid variants 会暴露收敛或多样性问题，支持三件套一起使用。
- 与已有设计知识的区别：
  - 不同于“拥挤中位分区的稀疏优先混合选择”：该知识主要处理 NSGA-II critical front 的截断；本知识把 ε-dominance 贯穿 offspring replacement、onlooker selection 和 external archive update。
  - 不同于“自适应约束违反粒度评估”：该知识调节 constraint violation 的粒度；本知识调节 objective dominance pressure 和 archive density。
  - 不同于“业务偏好约束的多段染色体搜索”：该知识用 epsilon thresholds 表达业务可接受区域；本知识中的 ε 是随迭代变化的 dominance tolerance。
  - 不同于“变量自适应 UPF 档案重构”：该知识使用 UPF/CPF archive 进行约束搜索阶段重构；本知识关注普通多目标 archive 的容量和分布控制。

## 解决的问题

- 适用场景：
  - 使用 swarm / evolutionary reproduction，但缺少稳定多目标选择压力；
  - archive size 有上限，需要保留分布均匀的 Pareto approximation；
  - 普通 dominance 产生过多非支配解，crowding 或随机截断导致前沿局部聚集；
  - 需要 early exploration 与 late convergence 的阶段性平衡；
  - objective values 可归一化并可计算网格 occupancy。
- 现有方法为什么会失败或不足：
  - 普通 Pareto dominance 对高维或冲突强的问题选择压力太弱，父子替换常无法发生。
  - 固定 ε 太大可能长期保留粗糙解，太小又接近普通 dominance，参数敏感。
  - 单独 external archive 只保精英，不解决 archive overflow 和代表性。
  - 单独 grid pruning 只在删除时控制密度，不提供搜索过程中的收敛压力调度。
- 仍需解决的问题：
  - ε schedule 若只按迭代线性下降，可能无法适应不同 problem difficulty 或前沿形态。
  - 固定 grid resolution 在 many-objective、高度弯曲或尺度变化大的 PF 上可能失效。
  - 对 constrained MOO，仅在 objective 上做 ε-dominance 不足以处理 feasibility 和 constraint violation。

## 为什么可能有效

```text
large epsilon at early search
-> fewer dominance eliminations
-> archive admits wider exploratory candidates
-> grid pruning prevents collapse into dense regions

smaller epsilon at late search
-> dominance relation approaches Pareto dominance
-> more inferior candidates removed
-> archive keeps sparse but better front approximation
```

关键假设是：ε 的下降速度与问题搜索阶段大致匹配，并且 objective-space 网格能反映“哪些区域过密、哪些区域稀疏”。如果目标数很高、PF 强非线性或 objective normalization 不稳定，grid occupancy 可能变得稀疏失真，需要 reference vectors、manifold density 或 HV/R2 contribution 替代。

## 实现接口

- 输入：
  - 当前 population `P` 和 objective matrix `F(P)`；
  - external archive `A` 和 archive capacity `A_max`；
  - `epsilon_max`、`epsilon_min`、最大迭代数 `T` 或反馈式 ε 调度器；
  - grid resolution `G` 与 objective normalization 方法；
  - offspring generator，例如 ABC neighbor search、DE mutation、PSO velocity update、GA crossover/mutation。
- 输出：
  - 更新后的 population；
  - bounded non-dominated archive；
  - 每代 archive density、nondominated ratio、epsilon value 和 pruning diagnostics。

## 可复用流程

```text
epsilon(t):
    return epsilon_max - (epsilon_max - epsilon_min) * t / T

epsilon_dominates(a, b, eps):
    return all(f_k(a) <= f_k(b) - eps for k in objectives)
           and any(f_k(a) < f_k(b) - eps for k in objectives)

iteration(t):
    eps <- epsilon(t)
    for each parent x_i:
        v_i <- offspring_generator(x_i, population)
        if epsilon_dominates(v_i, x_i, eps):
            x_i <- v_i

    A <- epsilon_nondominated_filter(A union population, eps)
    if size(A) > A_max:
        A <- prune_overcrowded_grid_cells(A, A_max)
```

P2026-0294 的 onlooker selection 还可加入：

```text
q_i = 1 / (rank_epsilon_i + density_i + delta)
p_i = q_i / sum(q)
```

其中 `rank_epsilon_i` 越低越好，`density_i` 可来自 crowding 或 grid occupancy。

## 可用于算法创新

- 把线性 ε schedule 改成闭环调度：根据 archive growth rate、HV stagnation、IGD proxy、feasible ratio、nondominated ratio 或 grid entropy 自动调整。
- 将 grid pruning 改为 adaptive hypergrid、reference-vector occupancy、R2/HV contribution、kNN density 或 learned front manifold density。
- 在 constrained MOO 中加入 feasibility-aware ε-dominance：先比较可行性，再对 objectives 和 CV 使用不同 ε。
- 对 swarm 算法，将 scout/restart 指向 archive sparse cells，而不是全局随机重启。
- 用 archive pruning diagnostics 做资源分配：拥挤区域减少 offspring budget，稀疏或未覆盖区域增加采样。
- 与 surrogate-assisted optimizer 结合：surrogate 先产生候选，真实评价只给 ε-nondominated 且位于 sparse cells 的候选。

## 论文证据

| 来源 | 证据 | 位置 |
|---|---|---|
| P2026-0294 | Algorithm 1 将 initialization、adaptive ε-dominance、employed/onlooker/scout phases、archive update 和 grid pruning 串成 Adaptive ε MOABC | Sec. 3，Algorithm 1，PDF 8-10 |
| P2026-0294 | 论文说明 ε 从 `epsilon_max` 逐步降到 `epsilon_min`，早期促进 exploration，后期提高 convergence pressure | Sec. 3.1，PDF 10-12 |
| P2026-0294 | External archive 保存跨代非支配解，避免 ABC perturbation 和 scout replacement 丢失 elite solutions | Sec. 3.2，PDF 12 |
| P2026-0294 | Grid pruning 将 objective space 划为 hypercubic cells，archive 超限时优先删除 dense cells 中的解并保留 sparse regions | Sec. 3.3，PDF 12-13 |
| P2026-0294 | ZDT/DTLZ/WFG benchmark 中，Adaptive ε MOABC 在 GD/IGD 上相对 MOPSO 显著更好；Wilcoxon test 显示 GD/IGD 差异显著而 HV 不显著 | Sec. 6.1，Table 4-5，PDF 21-25 |
| P2026-0294 | IEEE 14/30/57-bus MOOPF 中，Adaptive ε MOABC 的 spread 为 `1.7227/0.9603/1.8248`，作者用作更宽前沿覆盖证据 | Sec. 6.2，Table 9，PDF 27-29 |
| P2026-0294 | Ablation 中 Fixed ε 版本 GD/IGD 更差；No-grid pruning 有时收敛数值更低但被作者认为牺牲多样性，支持 adaptive ε 和 grid pruning 的组合必要性 | Sec. 6.2.2，Table 12，PDF 31 |

## 证据边界

- P2026-0294 为 Journal Pre-proof，Markdown 中部分公式和伪代码为图片抽取；复现需核对 PDF 或源代码。
- 该论文中 HV 差异不显著，不能把方法概括为所有指标全面更优。
- OPF 案例只到 IEEE 57-bus，且 renewable uncertainty 未显式建模；大规模真实 grid 仍需验证。
- 57-bus C-Metric 中 MOPSO 支配 Adaptive ε MOABC 的比例达到 `0.5000`，说明该方法在更大系统上仍可能存在局部收敛或覆盖不足。
- Grid pruning 的效果依赖 objective normalization、grid resolution 和 archive capacity；many-objective 场景中可能需要替代密度估计。
