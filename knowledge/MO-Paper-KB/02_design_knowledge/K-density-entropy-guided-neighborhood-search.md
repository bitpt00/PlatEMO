---
knowledge_id: K-density-entropy-guided-neighborhood-search
name: 密度聚类-熵权的邻域搜索资源分配
type: method
status: active
source_papers: [P2026-0160]
aliases: [CE-NS, clustering and entropy-guided neighborhood search, DBSCAN objective-space clustering, entropy-guided neighborhood allocation, slope-guided neighborhood selection, unsupervised search resource allocation, density-entropy search budget, 密度聚类邻域搜索, 熵权扰动强度, 斜率引导邻域选择, 无监督邻域搜索资源分配]
promotion_reason: P2026-0160 给出可直接移植的无监督搜索控制接口：先用 DBSCAN 在 elite objective space 中识别局部密度结构，再用 cluster entropy 分配邻域搜索强度，并用 objective slope 选择面向不同目标的 critical-machine/critical-operation 邻域；消融显示去掉该模块或改成随机邻域选择会显著退化。
---

# 密度聚类-熵权的邻域搜索资源分配

## 核心内容

在多目标算法的 elite refinement 或局部搜索阶段，不平均或随机地对每个非支配解做邻域搜索。先把 elite solutions 投影到归一化 objective space，用密度聚类识别过密区、稀疏区和孤立区域；再把每个 cluster 的 objective-space occupancy 离散成网格并计算 entropy，把 entropy 映射为该簇的扰动权重；最后用 cluster 的目标偏置 slope 选择邻域算子组合，使搜索预算、扰动强度和目标方向都由当前 Pareto 区域结构决定。

```text
elite population
-> normalize objectives
-> DBSCAN / density clustering in objective space
-> per-cluster grid entropy
-> entropy-to-weight mapping
-> objective slope / preference diagnosis
-> choose neighborhood portfolio per cluster
-> apply more local search where structure says it is useful
```

P2026-0160 的 CE-NS 是该机制的调度实例：先用 IDUS 选 elite set，再用 DBSCAN 分簇；cluster entropy 决定从该簇抽取多少解；cluster slope `mean(makespan) / mean(TEC)` 决定使用 makespan-first、TEC-first、dominance-improving 或 swap 邻域。

## 建立理由

- 为什么值得独立维护：
  - 很多 MOEA 的局部搜索预算是固定、随机或按个体质量分配，无法感知 Pareto 前沿不同区域的密度和目标偏置。
  - Objective-space 聚类和 entropy 权重是通用接口，可迁移到调度、路径、工程设计、组合优化和昂贵 MOO。
  - 该方法不需要真实 Pareto front，也不需要训练标签，适合嵌入传统 MOEA 的后期精修层。
  - P2026-0160 单独做了无监督模块消融，完整算法相对随机邻域版本在 AGD/AIGD/AHV 上都有改善。
- 与已有设计知识的区别：
  - 不同于“粗细聚类与密度独立竞争的多模态识别”：该知识聚类决策空间以识别多个 Pareto sets；本知识聚类目标空间 elite 区域以分配邻域搜索资源。
  - 不同于“自适应 ε 支配与网格档案的多目标蜂群搜索”：该知识用 ε-dominance 和 grid pruning 管理 archive；本知识用 cluster entropy 和 slope 控制局部搜索强度和方向。
  - 不同于“状态驱动的 DRL 演化算子选择”：本知识不学习长期 Q-value，而是用当前 objective-space 结构做即时无监督控制。
  - 不同于“愿望-保留水平驱动的复合质量指标”：本知识不是离线评价算法质量，而是把结构诊断直接反馈给搜索过程。

## 解决的问题

- 适用场景：
  - 算法维护 elite set、archive 或 non-dominated population；
  - 有一组不同目标偏向的邻域算子或局部搜索动作；
  - 局部搜索成本明显高于普通变异，需要决定对哪些区域多搜；
  - 目标数较低或可用降维/参考方向让 objective-space density 有意义；
  - 不希望依赖真实 PF、训练数据或复杂 DRL 控制器。
- 现有方法为什么会失败或不足：
  - 均匀对所有 elite 做局部搜索会浪费在过密区域；
  - 只按 crowding 或 rank 选解，不能告诉算法应该执行哪类目标方向的邻域；
  - 随机邻域选择容易在已经足够密的 Pareto 区域反复扰动；
  - 固定目标权重或固定邻域组合无法适应前沿不同区域的 objective trade-off。
- 仍需解决的问题：
  - 聚类半径、`MinPts`、grid bins 和 entropy-weight mapping 的自适应；
  - many-objective 下距离集中和网格稀疏；
  - singleton / noise cluster 是否应当保护、开发或削弱；
  - cluster entropy 与真实改进潜力之间的因果关系仍需更多问题验证。

## 为什么可能有效

```text
elite set is uneven in objective space
-> dense clusters indicate repeated or locally structured regions
-> sparse / boundary clusters indicate coverage gaps or fragile tradeoffs
-> entropy summarizes how dispersed a cluster is within local objective bins
-> weight controls how many local perturbations are spent there
-> slope diagnoses which objective dominates the local tradeoff
-> neighborhood portfolio targets the objective that has more room to improve
```

关键假设是：当前 elite objective-space distribution 能反映搜索需求，且可用的邻域算子确实具有目标方向差异。如果 objectives 未归一化、PF 强非线性、目标数很高或评价噪声很大，cluster entropy 和 slope 可能误导资源分配。

## 实现接口

- 输入：
  - elite set 或 archive `E`；
  - normalized objective matrix `F(E)`；
  - density clustering 参数，如 `epsilon`、`MinPts`；
  - objective-space discretization 参数，如 `nbins`；
  - entropy-to-budget mapping；
  - neighborhood portfolio，例如 convergence、objective-1-first、objective-2-first、dominance-improving、diversity-improving 算子；
  - 每个 cluster 的目标偏置诊断函数，如 slope、reference-vector angle 或 preference distance。
- 输出：
  - 每个 cluster 的 search budget / perturbation weight；
  - 每个 cluster 对应的 neighborhood strategy set；
  - 局部搜索后的 elite population 或 candidate set；
  - 可选 diagnostics：cluster count、noise ratio、entropy、slope、budget 和改进率。
- 插入位置：
  - MOEA 的 elite/archive refinement；
  - expensive local search 前的预算分配；
  - memetic MOEA 的 local search selector；
  - swarm/DE/GA 的后期 exploitation layer；
  - 调度、路径、组合优化中的 critical-neighborhood selection。

## 可复用流程

```text
E <- select_elites(population, archive, gamma)
Z <- normalize(F(E))
clusters, noise <- density_cluster(Z, epsilon, MinPts)

for each cluster C_i:
    bins <- discretize_objective_space(Z[C_i], nbins)
    H_i <- entropy(histogram(bins))

H_norm <- normalize(H)
for each cluster C_i:
    w_i <- map_entropy_to_weight(H_norm_i)
    B_i <- max(min_budget, round(w_i * size(C_i)))
    s_i <- local_objective_slope(Z[C_i])
    ops_i <- choose_neighborhoods_by_slope(s_i)
    candidates <- sample(C_i, B_i)
    candidates <- apply_neighborhood_portfolio(candidates, ops_i)

E <- update_elites(E union candidates)
```

P2026-0160 的二目标调度实例：

```text
if slope > 2:
    use makespan machine reassignment, makespan insertion, dominance insertion
elif 1 <= slope <= 2:
    use makespan machine reassignment, dominance insertion, swap improvement
elif 0.5 <= slope < 1:
    use TEC machine reassignment, dominance insertion, swap improvement
else:
    use TEC machine reassignment, TEC insertion, dominance insertion
```

## 如何用于算法创新

### 局部创新

- 用 HDBSCAN、nearest-neighbor density、kernel density、reference-vector occupancy 或 manifold density 替换 DBSCAN。
- 将 entropy weight 改为闭环预算：根据 cluster 最近几代 HV/R2 contribution、improvement rate、stagnation age 或 feasibility gain 调节。
- 将 slope 改为 preference vector angle、knee likelihood、objective sensitivity、constraint violation profile 或 decision-maker ROI distance。
- 对 singleton/noise clusters 设置独立策略：保护边界 singleton、削弱明显异常点、或只给少量 probe budget。
- 在 expensive MOO 中，让高 entropy/high uncertainty clusters 优先获得真实评价，低价值 clusters 只用 surrogate refinement。

### 结构创新

- 构建无监督 memetic controller：

```text
objective-space diagnosis
-> cluster budget allocator
-> target-biased neighborhood scheduler
-> archive update and diagnostics
-> feedback to next generation
```

- 与多种群算法结合：每个 cluster 形成临时 subpopulation，并按其 slope 使用不同算子和参数。
- 与偏好优化结合：只对 ROI cluster 做强 local search，对 ROI 外 cluster 保留低频探索。
- 与动态 MOO 结合：cluster count、entropy 或 slope 分布突变可作为环境变化信号。
- 与调度型 MOEA 结合：cluster 诊断决定 critical machine、critical operation、route segment 或 energy compression 的局部搜索预算。

## 适用条件与风险

- 适用条件：
  - objectives 可归一化且距离/密度有意义；
  - elite set 数量足以支持聚类和 entropy 估计；
  - 邻域算子存在可解释的目标方向差异；
  - 局部搜索开销值得通过资源分配来节省；
  - 问题的 Pareto 区域结构在若干代内不会完全随机震荡。
- 不适用或可能失效的条件：
  - many-objective 下 objective-space 距离集中，DBSCAN 和 grid entropy 都可能失真；
  - 目标强噪声或归一化不稳导致 slope 方向反复跳变；
  - `MinPts` 太小会把异常点当成 cluster，太大又会丢失边界稀疏区域；
  - entropy 高未必代表值得开发，可能只是簇内噪声或弱收敛；
  - 目标方向邻域算子若没有真实偏置，slope-guided selection 作用会变弱。
- 计算与实现成本：
  - 聚类一般为 `O(d gamma log gamma)` 到 `O(d gamma^2)`；
  - entropy 统计为 `O(gamma + |clusters| * nbins^2)`；
  - 总成本通常由后续 neighborhood search 主导；
  - 需要记录 cluster-level diagnostics 才能调参与排查误导。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0160 | Algorithm 7 先用 IDUS 选 elite population，再用 DBSCAN 在 elite objective space 中生成 clusters 和 noise | 作者提出的方法 | Sec. 4.5，Algorithm 7，PDF 9-10 |
| P2026-0160 | CE-NS 将每个 cluster 的 objective-space occupancy 离散成 `nbins x nbins`，用 entropy 计算并归一化扰动权重 | 作者提出的方法 | Sec. 4.5.2，Eqs. 25-28，PDF 10-11 |
| P2026-0160 | Cluster slope `s_i = mean normalized makespan / mean normalized TEC` 决定使用 `NS1-NS6` 中哪组 critical-machine/operation 邻域 | 作者提出的方法 | Sec. 4.5.2，Algorithm 7，PDF 10-11 |
| P2026-0160 | `NS1/NS2` 重新分配 critical machines，`NS3/NS4` 重插 critical operations，`NS5/NS6` 做 dominance insertion 或 swap improvement | 作者提出/组合方法 | Sec. 4.5.2，PDF 11 |
| P2026-0160 | 五组件消融显示去掉 CE-NS 后 AIGD/AHV 明显退化，作者认为 CE-NS 是最关键组件 | 组件消融支持 | Sec. 5.4，Figs. 12-13，PDF 16-17 |
| P2026-0160 | 去掉 unsupervised learning 并用 random neighborhood selection 替代后，完整 CEUL-MOEA 约提升 `AGD 30%`、`AIGD 12%`、`AHV 4%` | 无监督模块消融 | Sec. 5.5，Fig. 16，PDF 17-18 |
| P2026-0160 | 275 个 RHFSP 实例上，CEUL-MOEA 相对六个对比算法在 AGD/AIGD/AHV 上分别约优 `38%-99%`、`72%-95%`、`26%-91%` | 综合实验支持 | Sec. 5.6，Tables 9-10，PDF 18-21 |
| P2026-0160 | OLED ARRAY workshop 案例中 CEUL-MOEA 取得 `GD=0.000`、`IGD=0.049`、`HV=0.855`，能耗 trade-off 更好 | 应用案例 | Sec. 5.9，Table 15，PDF 22-23 |
| P2026-0160 | 作者承认无监督模块对参数敏感，未来将研究 adaptive parameter control、graph representations 和 end-to-end DRL | 局限与未来工作 | Limitations/Future work，PDF 23 |

## 证据边界

- 当前只有 P2026-0160 一篇直接证据，且应用集中于 two-objective RHFSP。
- CE-NS 与 IEI-LS、双编码双种群、IDUS 和 ED-BA 同时存在，综合优势不能完全归因于 CE-NS。
- 无监督模块消融支持 CE-NS 相对随机邻域选择有效，但没有分别隔离 DBSCAN、entropy weight、slope rule 和每个 `NS` 算子的贡献。
- 公式和部分图在 Markdown 中为图片占位，复现需要回 PDF 或代码。
- `MinPts=1`、`epsilon=0.1`、`nbins=50` 和 slope 阈值 `0.5/1/2` 主要来自该实验设定，跨问题自适应仍未解决。

## 待确认

- many-objective 场景下用 reference-vector subregion 代替 DBSCAN 是否更稳；
- cluster entropy 应该偏向开发高 entropy 区域，还是补强低 entropy / sparse 区域；
- singleton/noise cluster 的预算是否应与边界保留、异常检测或 uncertainty 结合；
- slope 阈值是否能从 preference、objective range 或 online sensitivity 自动推导；
- 与 DRL/bandit 算子选择结合时，CE-NS 作为状态诊断还是直接策略更合适。
