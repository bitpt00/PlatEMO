---
knowledge_id: K-dominance-decomposition-coevolution-stage-switching
name: 支配-分解双框架协同与阶段切换
type: architecture
status: active
source_papers: [P2026-0185]
aliases: [CoDD, dominance-decomposition coevolution, dual-framework CMOEA, DE/sharing/1, tolerance-based selection, relevance-based selection, UPF-to-CPF switching, Tchebycheff fluctuation stage judgment, 支配分解协同, 双框架约束多目标, 强协同CMOEA, 阶段切换]
promotion_reason: 单篇论文提出但接口完整，包含 dominance 与 decomposition 两个完整 population、逐代收紧的容忍约束、UPF-to-CPF 聚合函数阶段切换、DE/sharing/1 父代级共享、角度相关 offspring 共享和多套 CMOP/真实问题证据，可直接改造双种群 CMOEA。
---

# 支配-分解双框架协同与阶段切换

## 核心内容

在 constrained MOO 中，不把 dominance-based 与 decomposition-based 选择混在一个种群里，也不让辅助种群只追 UPF，而是维护两个完整 population。Dominance population 用逐代收紧的 constraint violation tolerance 处理可行性，并接收两个种群的 offspring，避免 CDP 过早只保留局部可行区域。Decomposition population 先用权重方向搜索 UPF；当每个个体的 Tchebycheff 聚合值在最近窗口内都趋稳时，切换到加入 CV penalty 的聚合函数，转向 CPF。两个 population 还通过 DE/sharing/1 在 offspring generation 阶段交换 parent difference，在 environmental selection 阶段交换 offspring。

```text
P1: dominance population
    dynamic relaxed constraints
    tolerance-based selection from P1 union O1 union O2

P2: decomposition population
    stage 1: Tchebycheff search toward UPF
    stage judgment: aggregation-value fluctuation
    stage 2: CV-penalized Tchebycheff search toward CPF
    relevance-based selection with angle-matched O1 offspring

cross-population sharing:
    DE/sharing/1 parent-level difference vector
    offspring-level sharing in both environmental selections
```

P2026-0185 的 CoDD 是该模式的实例：`P1` 使用 dominance/tolerance selection，`P2` 使用 decomposition/stage switching，输出 archive 用 SPEA2 维护。

## 建立理由

- 为什么值得独立维护：
  - Dominance-based CMOEA 擅长可行性处理但容易陷入局部可行区域；
  - Decomposition-based CMOEA 擅长方向覆盖和多样性，但在 UPF 远离 CPF 时后期可能浪费预算；
  - 多数 coevolutionary CMOEA 只采用一种框架或弱共享，无法充分利用两类框架互补性；
  - Parent-level 与 offspring-level 双重共享提供了比单纯环境选择迁移更强的协同接口。
- 单篇具体方法的直接复用价值：
  - P2026-0185 给出 CoDD Algorithm 1-4、DE/sharing/1、tolerance-based selection、stage judgment、CV-penalized aggregation、relevance-based selection、复杂度、四套 benchmark、真实 CMOP 和多个消融证据。
- 与已有设计知识的区别：
  - 不同于“双档案自适应约束松弛与局部收敛选择”：该知识控制 leading archive 是否考虑约束；本知识是两个不同 CMOEA 框架的 population 级强协同，并有 parent-level DE sharing。
  - 不同于“约束边界远距不可行辅助引导”：该知识筛选边界不可行解；本知识不以不可行边界 fitness 为核心，而是 dominance/decomposition 框架互补。
  - 不同于“变量自适应 UPF 档案重构”：该知识面向大规模变量分组和 archive reconstruction；本知识面向框架协同和聚合函数 stage switching。
  - 不同于“分解-支配双选择的稀疏探索”：该知识在单个 MOEA/D 中叠加 SPEA-II 全局选择；本知识维护两个独立 population，各自采用完整 dominance/decomposition 机制。
  - 不同于“目标约简层级种群与约束相关激活”：该知识按目标子集建立层级 population；本知识按算法框架差异建立双 population。

## 解决的问题

- 适用场景：
  - CMOP 存在窄可行域、断裂 CPF、大不可行区域或 UPF/CPF 分离；
  - 单一 dominance-based CMOEA 可行性强但多样性不足；
  - 单一 decomposition-based CMOEA 方向覆盖好但 UPF 辅助后期可能失效；
  - 希望在同一算法中保留两类框架的选择压力；
  - 算法允许维护两个 population，并能记录/交换父代与 offspring。
- 现有方法为什么会失败或不足：
  - CDP 过早过滤不可行解，会丢失靠近其它可行区的有益候选；
  - 一直搜索 UPF 在 UPF 远离 CPF 时浪费预算；
  - 固定阶段切换无法反映 decomposition population 是否真的已经在 UPF 稳定；
  - 仅在 environmental selection 中共享 offspring，未利用另一 population 的 parent direction；
  - 单框架 coevolution 难以覆盖复杂 CMOP 中不同搜索需求。
- 仍需解决的问题：
  - 两个 population 的评价预算和共享强度如何自适应；
  - 聚合值波动阈值是否能稳健判断所有参考方向；
  - 高目标数下 dominance pressure 与 Tchebycheff 权重覆盖都可能退化；
  - `O(N^3)` environmental selection / archive update 在大种群或昂贵评价中成本较高。

## 为什么可能有效

```text
complex CMOP has feasibility, convergence, and diversity difficulties
-> dominance population supplies feasibility pressure and infeasible-solution filtering
-> decomposition population supplies directional coverage and UPF exploration
-> stage switching stops wasting budget on UPF once it stabilizes
-> CV penalty pulls decomposition population back toward CPF
-> DE/sharing/1 injects search directions from the other framework
-> relevance/tolerance selections accept useful cross-population offspring
```

关键假设是：dominance 与 decomposition 的搜索偏差不同且互补，UPF 在早期至少提供一定目标方向信息，聚合值稳定能近似表示 UPF 搜索已充分。如果 UPF 与 CPF 完全无关、两个 population 分布长期不兼容，或参考方向无法覆盖 CPF 结构，强共享可能产生负迁移。

## 实现接口

- 输入：
  - 原始 CMOP 的 objectives、constraints、constraint violation；
  - dominance population `P1` 与 decomposition population `P2`；
  - weight vectors、ideal/nadir points；
  - tolerance schedule 参数；
  - stage window `T`、threshold `sigma`、CV penalty `theta`；
  - DE operators 和 boundary repair。
- 输出：
  - 更新后的 `P1`、`P2`；
  - 输出 archive `A`；
  - 当前 stage flag `SF`；
  - cross-population offspring / parent-sharing logs。
- 插入位置：
  - 双种群 CMOEA 的顶层结构；
  - decomposition-based CMOEA 的 UPF-to-CPF 切换层；
  - dominance-based CMOEA 的 relaxed constraint selection；
  - 多种群算法的 mating / migration operator。
- 最小实现：

```text
initialize P1, P2, archive A
initialize W, zmin, zmax, tolerance t, stage SF = 1

for generation g:
    O1 <- DE_rand_to_best_or_current_to_rand(P1)
    O1 <- O1 union DE_sharing(current_from=P1, difference_from=P2)

    O2 <- DE_rand_1(P2)
    O2 <- O2 union DE_sharing(current_from=P2, difference_from=P1)

    t <- tolerance_schedule(g)
    FS <- {x in P1 union O1 union O2 | CV(x) <= t}
    IFS <- remaining candidates
    P1 <- dominance_truncate_or_fill(FS, IFS, N)

    if aggregation_values_stable(P2, T, sigma):
        SF <- 2
    if SF == 1:
        agg <- modified_tchebycheff_g1
    else:
        fr <- feasible_ratio(P2)
        agg <- g1 + theta * (1 - fr) * CV

    for each weight vector w_i:
        candidate_from_P2 <- own offspring O2_i
        candidate_from_P1 <- argmin_angle(normalized_objective(O1), w_i)
        P2 <- neighborhood_update(P2, candidate_from_P2, candidate_from_P1, agg)

    A <- SPEA2_update(A union O1 union O2)
```

P2026-0185 的默认设置：

- `T=200`；
- `sigma=0.001`；
- `theta=50`；
- population size `N=91`；
- benchmark evaluations `300000`，real-world evaluations `50000`；
- DE `CR=1`、`F=0.5`；
- archive update 使用 SPEA2；
- 总体复杂度 `O(N^3)`。

## 如何用于算法创新

### 局部创新

- 将 `P1` 的 tolerance schedule 改为可行率、CV 分布熵、边界候选转化率或 stagnation 触发。
- 让 `P2` 的 stage switching 按 reference direction 局部触发，而不是所有个体统一切换。
- 将 `theta*(1-fr)*CV` 扩展为自适应多约束 penalty，例如按 active constraints、CV 粒度或可行性预测加权。
- 用 angle+CV+archive contribution 替代单纯 angle relevance selection。
- 给 DE/sharing/1 加入成功率反馈，动态控制跨 population 差分向量使用概率。

### 结构创新

- 构建三框架协同 CMOEA：

```text
dominance population: feasibility and local CPF refinement
decomposition population: directional coverage and UPF-to-CPF switching
indicator archive/population: global quality and diversity selection
controller: adaptive sharing and resource allocation
```

- 与边界不可行辅助结合：dominance population 保留可行性，decomposition population 保持方向覆盖，第三个 boundary archive 提供低 CV 且远离主群的不可行候选。
- 与动态约束 MOO 结合：环境变化后 dominance population 快速恢复可行性，decomposition population 复用历史方向或 UPF 结构。
- 与代理辅助 CMOP 结合：先用代理筛选跨 population sharing offspring，减少低质量 DE/sharing 真实评价。
- 与 many-objective CMOP 结合：用 reference-vector/indicator selection 替代传统 dominance archive，并筛选少量关键权重方向降低复杂度。

## 适用条件与风险

- 适用条件：
  - 目标数较低或中等，dominance 和 decomposition pressure 仍有意义；
  - UPF 对早期定位有帮助，但后期需要回到 CPF；
  - 可行域狭窄、断裂或多局部可行区域；
  - 评价预算允许两个 population 并行演化；
  - 需要同时利用可行性压力和方向覆盖。
- 不适用或可能失效的条件：
  - UPF 与 CPF 完全无关，stage 1 decomposition 搜索会误导；
  - 可行域简单，单框架 CMOEA 已足够，双 population 开销不划算；
  - 高目标数下 dominance ranking 大量打平，Tchebycheff 权重也难覆盖 CPF；
  - 两个 population 分布差异过大，DE/sharing/1 差分向量产生大量越界/无效 offspring；
  - 聚合值波动受噪声影响，导致过早或过晚切换。
- 计算与实现成本：
  - 需要两个 population 和一个 SPEA2 archive；
  - dominance environmental selection 与 SPEA2 archive update 均可能达到 `O(N^3)`；
  - 需要维护 `T` 代聚合值历史；
  - 需要计算角度相关性和 ideal/nadir normalization。
- 解释风险：
  - CoDD 的收益来自双框架、tolerance selection、stage switching、DE/sharing/1、angle relevance 和 SPEA2 archive 的组合，不能单独归因于某个组件。
  - 主文详细表格多在 Supplementary Material；suite-level 结论明确，但函数级差异需回查补充材料。
  - 真实问题使用 HV，因为真实 CPF 未知，无法完全分解收敛和多样性来源。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0185 | 作者指出 dominance 与 decomposition 框架通常独立使用，但二者在复杂 CMOP 中具有互补搜索行为 | 问题动机 | Introduction / Sec. II-C，PDF 2、4 |
| P2026-0185 | 作者指出现有 coevolutionary CMOEA 信息共享低效、过度关注 UPF，尤其在 UPF 远离 CPF 时浪费资源 | 问题动机 | Introduction / Sec. II-C，PDF 2、4 |
| P2026-0185 | CoDD 同时初始化 dominance-based `P1` 和 decomposition-based `P2`，并通过 coupled sharing DE、两类环境选择和 SPEA2 archive 输出 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4-5 |
| P2026-0185 | `P1` 优化带逐代收紧 tolerance 的 dynamic CMOP，`t_g` 最终收敛到 0 | 作者提出/采用方法 | Sec. III-B，Eq. (9)-(11)，PDF 5 |
| P2026-0185 | DE/sharing/1 中当前个体来自一个 population，差分向量来自另一个 population，实现 parent-level information sharing | 作者提出的方法 | Sec. III-B，Algorithm 2，Eq. (12)，Fig. 3，PDF 5-6 |
| P2026-0185 | Tolerance-based selection 从 `P1 union O1 union O2` 中按 tolerance feasible set 选择，避免 CDP 只保留局部可行区 | 作者提出的方法 | Sec. III-B，Algorithm 3，Fig. 4，PDF 6 |
| P2026-0185 | `P2` stage 1 使用 modified Tchebycheff 搜索 UPF，并用每个个体最近 `T` 代聚合值标准差判断 stage switching | 作者提出的方法 | Sec. III-C，Eq. (13)-(17)，PDF 6-7 |
| P2026-0185 | `P2` stage 2 使用 `g2=g1+theta*(1-fr)*CV(x)` 从 UPF 转向 CPF | 作者提出的方法 | Sec. III-C，Eq. (18)，PDF 7 |
| P2026-0185 | Relevance-based selection 用归一化 objective 与 weight vector 的夹角，从 `O1` 中选择相关 offspring 参与 `P2` 邻域更新 | 作者提出的方法 | Sec. III-C，Algorithm 4，Eq. (19)-(20)，PDF 7 |
| P2026-0185 | LIR-CMOP 上 CoDD 在 IGD/HV 各 7 个函数最佳，并在极窄可行域问题上仍保持 convergence 和 diversity | 综合实验支持 | Sec. IV-B.1，Table I，PDF 9 |
| P2026-0185 | DAS-CMOP 上 CoDD 在 IGD 6 个、HV 5 个函数最佳，未最佳问题也与最优同量级 | 综合实验支持 | Sec. IV-B.2，Table I，PDF 9 |
| P2026-0185 | DOC 上 CoDD 在 IGD 9/9、HV 8/9 函数最佳，能处理 decision/objective space constraints 和小可行域 | 综合实验支持 | Sec. IV-B.3，PDF 9-10 |
| P2026-0185 | CF 上 CoDD 在 IGD 8 个函数最佳，HV 与 IGD 结果一致，作者归因于 objective switching、双框架合作和 DE/sharing/1 | 综合实验支持 | Sec. IV-B.4，PDF 10 |
| P2026-0185 | 全部 benchmark Friedman 平均排名中 CoDD 的 IGD/HV 为 1.691/2.155，均排名第一，p-values 小于 0.05 或 0.01 | 统计证据 | Sec. IV-B.5，Table II，PDF 10 |
| P2026-0185 | CoDD3 优于单框架 CoDD1/CoDD2，完整 CoDD 优于无 DE/sharing 的 CoDD3，支持双框架和信息共享 | 消融实验支持 | Sec. IV-C，PDF 10-11 |
| P2026-0185 | DE/sharing/1 的 DE/rand/1 版本优于 DE/rand/2、DE/best/1、DE/best/2 变体 | 机制消融 | Sec. IV-E，PDF 11 |
| P2026-0185 | 聚合值阶段判断优于 PPS-MOEA/D stage rule、直接 objective value rule 和 fixed parameter rule | 机制消融 | Sec. IV-F，PDF 11 |
| P2026-0185 | Angle-based relevance selection 优于禁用、随机和欧氏距离选择 | 机制消融 | Sec. IV-G，PDF 11-12 |
| P2026-0185 | 5 个 real-world CMOP 中 CoDD 在 4 个 HV 最优，FRD 上未最优但竞争性强 | 真实问题支持 | Sec. IV-H，Table III，PDF 12 |
| P2026-0185 | 作者未来计划研究 dominance/decomposition 的动态适应，以及进一步集成 indicator-based framework | 作者未来工作 | Conclusion，PDF 12 |

## 证据边界

- 当前只有单篇论文证据。
- 大量函数级数值、可视化和消融表在 supplementary；主文只给 suite-level summary。
- CoDD 使用固定参数 `T=200`、`sigma=0.001`、`theta=50`，泛化到不同预算/规模需重新调参。
- 总体复杂度 `O(N^3)`，大规模/昂贵 CMOP 中可能偏重。
- 真实问题只报告 HV，真实 CPF 未知。
- 代码需向作者索取，当前复现便利性有限。

## 待确认

- 两个 population 的资源分配是否应按贡献自适应，而不是固定等规模；
- `P2` 是否应分方向异步切换 stage，避免少数不稳定方向拖延整体切换；
- DE/sharing/1 是否需要根据跨 population offspring survival rate 自适应开关；
- `P1` 的 tolerance schedule 是否应由可行率和 CV 分布反馈控制；
- indicator-based framework 如何与现有双框架合并且不进一步推高复杂度；
- many-objective CMOP 中 dominance pressure 退化时，该架构应如何改写。
