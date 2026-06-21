---
knowledge_id: K-dynamic-auxiliary-population-diversity-constraint-coevolution
name: 动态辅助种群多样性增强的约束协同进化
type: architecture
status: active
source_papers: [P2026-0164]
aliases: [CMOCEA-DDAP, dynamic diversity-enhanced auxiliary population, dynamic auxiliary population, diversity archive, multi-strategy cooperative CHT, MainPop AuPop coevolution, constrained co-evolutionary auxiliary population, 动态多样性增强辅助种群, 主辅种群协同约束处理, 多样性档案辅助种群]
promotion_reason: P2026-0164 单篇提出但接口完整：MainPop/AuPop/DA 三角色框架、辅助种群与多样性档案线性缩减、MainPop 双策略 CHT、AuPop diversity-preferential CHT、MainPop 自适应多算子 DE、AuPop GA 搜索，能直接改造双种群 CMOEA 的辅助规模、档案采样、约束处理和搜索算子层；论文在 56 个 benchmark CMOP、21 个机械设计问题和七类消融中给出证据。
---

# 动态辅助种群多样性增强的约束协同进化

## 核心内容

在 constrained multi-objective optimization 中，可以把双种群框架拆成三个互补角色：主种群 `MainPop` 同时考虑 objectives 和 constraints，并作为最终输出；辅助种群 `AuPop` 忽略 constraints，维护 objective-space diversity 和跨 infeasible regions 的探索信息；多样性档案 `DA` 从 `MainPop + AuPop + DA` 的非支配候选中按参考向量角度采样，给 `AuPop` 注入方向均匀的历史材料。`AuPop` 和 `DA` 的大小随评价进度线性缩减，使早期探索更宽，后期把预算和选择压力回收到可行收敛。

```text
initialize MainPop, AuPop, DA = empty

while budget remains:
    DA <- angular_diversity_sampling(DA + MainPop + AuPop)

    Au_off <- GA(AuPop + DA, size = 0.5 * |AuPop_t|)
    AuPop <- objective_only_selection(AuPop + Au_off + DA,
                                      random_survival_decreasing)

    Main_off <- adaptive_DE(MainPop, rank1(MainPop + AuPop))
    MainPop <- cooperative_CHT_selection(MainPop + AuPop + Main_off)

return nondominated(MainPop)
```

该知识的关键不是“有一个辅助种群”，而是把辅助种群的规模、随机保留比例和 diversity archive 都做成阶段性衰减的多样性供给系统，同时让主群用约束感知选择把这些信息筛回 CPF。

## 建立理由

- 为什么值得独立维护：
  - CMOP 中不可行区域常包含跨越狭窄/断裂可行域的有用方向，但辅助群若长期等规模无约束探索会浪费后期预算；
  - `AuPop` 只负责目标空间探索，`MainPop` 负责可行收敛，角色清晰，可移植到多类 CMOEA；
  - `DA` 让 MainPop 信息不是直接污染 AuPop，而是经过方向均匀采样后再引导辅助群；
  - MainPop 的双策略 CHT 解决“稠密非支配 front 上 ranking-based CHT 分布差”的局部问题；
  - P2026-0164 提供 Algorithm 1-6、复杂度、56 个 benchmark、21 个真实问题、七类消融和参数分析。
- 与已有设计知识的区别：
  - 不同于“博弈竞争驱动的双种群资源分配与辅助选择”：该知识按主/辅群质量和多样性竞争分配 offspring 或收缩辅助规模；本知识核心是 `AuPop + DA` 的动态多样性供给和 MainPop/AuPop CHT 分工，不使用 Cournot 式资源分配。
  - 不同于“UPF/SPF 奖励双种群约束搜索”：该知识在 UPF/SPF guidance 与 fuzzy objective-CV balance 两个专家之间用 archive reward 调度；本知识没有单约束 SPF 选择，而是让 AuPop 持续忽略 constraints 并通过 DA 和 MainPop CHT 回收。
  - 不同于“动态聚类限域的竞争群约束搜索”：该知识调节 CSO winner-loser 学习半径和 objective-space clusters；本知识调节辅助群/档案容量和主辅约束处理。
  - 不同于“自适应约束违反粒度评估”：该知识改变 CHT 前的 CV 表达；本知识改变主辅群架构和多样性档案。
  - 不同于“状态驱动的 DRL 演化算子选择”：该知识用学习器选择算子或策略；本知识的 operator selection 只是 MainPop 内部模块，架构重点在动态辅助多样性供给。

## 解决的问题

- 适用场景：
  - 可行域狭窄、断裂或被 infeasible regions 分隔；
  - 需要利用无约束/不可行搜索信息，但最终输出必须来自约束感知主种群；
  - 固定辅助种群规模或固定随机保留比例会导致早期探索不足或后期无效空转；
  - 环境选择可接受两个群体和一个 diversity archive 的额外维护成本；
  - 目标数较低或中等，参考向量角度采样仍能表示目标空间方向覆盖。
- 现有方法为什么会失败或不足：
  - 单种群 CDP/CHT 容易过早集中到局部可行区域；
  - 长期追 UPF 的辅助群在 UPF 与 CPF 分离时可能误导主群；
  - ranking-based CHT 在 dense PF 上可能缺少均匀性；
  - 单一 DE mutation operator 难同时跨 infeasible regions 和精修 CPF；
  - 直接混合主辅群信息可能破坏辅助群 diversity，因此需要中间 `DA`。
- 仍需解决的问题：
  - 如何判断 AuPop 的无约束探索何时失去贡献；
  - UPF 远离 CPF 时如何提前降低 AuPop 权重；
  - `DA` 的 reference-vector sampling 在 many-objective 或 disconnected CPF 上是否足够；
  - 线性缩减是否应改为状态反馈；
  - MainPop Strategy I 的触发是否能更精确地反映 distribution density。

## 为什么可能有效

```text
CMOP has infeasible barriers and narrow feasible regions
-> AuPop ignores constraints and explores objective-promising regions

unconstrained exploration can become noisy or costly
-> AuPop and DA shrink over time

MainPop needs both feasibility and objective search
-> dual-strategy CHT switches between ranking balance and density-aware selection

AuPop needs diversity more than feasibility
-> objective-only selection plus early random survival

historical nondominated material may fill missing directions
-> DA samples by reference-vector angle and feasibility/CV fallback
```

关键假设是：早期 objective-only exploration 能提供通向 CPF 的有用方向，并且动态缩减足以在后期抑制无约束误导。如果 UPF 与 CPF 距离很远，或者 CPF irregular 且稠密，辅助探索可能在中期仍未回到 CPF，导致主群后期缺少预算做均匀性修复。

## 实现接口

- 输入：
  - 主种群 `MainPop`，辅助种群 `AuPop`，多样性档案 `DA`；
  - objective values、constraint violation、feasibility flags；
  - reference vectors for `DA` sampling；
  - `Na_max/Na_min`、`Nd_max/Nd_min`、`beta`、perturbation probability `alpha`；
  - MainPop 搜索算子池和 success-rate archive。
- 输出：
  - 下一代 `MainPop`、`AuPop`、`DA`；
  - 当前 `Na`、`Nd`、AuPop 随机保留数量 `NS`；
  - MainPop operator group selection probability；
  - 最终 `nondominated(MainPop)`。
- 插入位置：
  - 双种群 CMOEA 的 auxiliary population control；
  - auxiliary archive update / truncation；
  - MainPop environmental selection 的 CHT；
  - offspring generation 的 operator portfolio。
- P2026-0164 默认实例：
  - `N=100`，`Na_max=Nd_max=50`，`Na_min=Nd_min=4`；
  - `alpha=0.01`，`CR=0.05`，`beta=1.0`；
  - MainPop 使用四个 DE mutation operators，分成带 crossover 与不带 crossover 两组；
  - AuPop 每代只生成 `Na/2` 个 offspring；
  - 最大评价次数 60000，SBX/PM 用于辅助群。
- 最小实现：

```text
DA <- empty
archive_p <- queue(maxlen = k)

while fes <= max_fes:
    Nd <- linear_decrease(Nd_max, Nd_min, fes/max_fes)
    DA <- update_DA(DA, MainPop, AuPop, Nd)

    Na <- even(linear_decrease(Na_max, Na_min, fes/max_fes))
    parents_A <- tournament_select(AuPop + DA, by = Pareto_rank_crowding, n = Na)
    Au_off <- SBX_PM(parents_A, n = Na/2)

    NS <- min(N - ceil(fes/max_fes * N), 0.5 * N)
    AuPop <- select_best_objective_only(AuPop + Au_off + DA, N - NS)
             union random_remaining(NS)

    ps <- probability_from_recent_success(archive_p)
    Main_off <- empty
    for i in 1..N:
        if rand <= ps:
            off <- DE_group_with_crossover(MainPop, rank1(MainPop + AuPop))
        else:
            off <- DE_group_without_crossover(MainPop, rank1(MainPop + AuPop))
            off <- early_dimension_reset(off, alpha, fes/max_fes)
        Main_off.add(off)

    MainPop <- select_by_dual_strategy_CHT(MainPop + AuPop + Main_off, N, beta)
    update operator success archive using F2 fitness

return nondominated(MainPop)
```

## 如何用于算法创新

### 局部创新

- 将 `Na/Nd` 线性递减改成由 feasible ratio、CV improvement、UPF-CPF distance surrogate 或 DA contribution 控制。
- 将 AuPop 的 objective-only selection 改为 boundary-infeasible aware selection，优先保留 objective-promising 且 CV 可修复的不可行解。
- 用 reference-vector vacancy、spacing entropy 或 crowding variance 触发 MainPop Strategy I，而不是仅用 CDP rank-1 数量。
- 将 `DA` 的角度采样改成 local component sampling，避免 disconnected CPF 上只覆盖大 component。
- 给 MainPop operator group 使用 delayed survival credit，而不是只看同代 `F2` 改善。
- 将 early perturbation 改成按变量敏感度或 constraint violation gradient 定向重置。

### 结构创新

- 构建“动态多样性供给器”：

```text
objective-only auxiliary explorer
+ angular diversity archive
+ constraint-aware main population
+ state-feedback shrink controller
```

- 与资源分配机制组合：先动态决定是否需要 AuxPop，再决定 AuxPop size、DA size 和 MainPop/AuPop offspring quota。
- 与 UPF/SPF relatedness detector 组合：若 UPF 与 CPF 相关，延长 AuPop；若远离，快速收缩并增强 MainPop CHT。
- 扩展到三种群：UPF explorer、boundary-infeasible explorer、CPF main population，由 `DA` 汇总并选择性回流。
- 在 many-objective CMOP 中将 `DA` sampling 与曲率投影、角度剪枝或 reference-vector HPS 结合。
- 在 expensive CMOP 中只对 `DA` 和 MainPop critical set 做真实评价，其余 AuPop 候选用 surrogate 预筛。

## 适用条件与风险

- 适用条件：
  - infeasible regions 中存在可利用的搜索通道或目标空间线索；
  - 主/辅种群可共享目标值、约束值和 rank-1 候选；
  - 目标空间角度和 reference vectors 能表达需要维护的 diversity；
  - 评价预算足够维护辅助群和档案；
  - 最终解必须由约束感知主群输出。
- 不适用或可能失效的条件：
  - UPF 与 CPF 长期距离很远，辅助群 objective-only search 几乎无贡献；
  - CPF highly irregular、densely distributed，后期需要大量均匀性修复；
  - 目标数很高导致角度/拥挤距离区分力下降；
  - 离散或混合编码下 DE、SBX/PM 与欧氏距离选择不合适；
  - 约束噪声大，CDP ranking 和 feasibility rate 不稳定。
- 计算与实现成本：
  - 更新 `DA`、`AuPop` 和 `MainPop` 都含排序/角度/距离计算；
  - 论文复杂度分析给出主导项为 `O(m(2N + Na)^2)`；
  - 需要维护多套 selection 和 operator-success 统计；
  - 对便宜 benchmark 成本可见，对昂贵工程仿真相对影响较小。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0164 | CMOCEA-DDAP 由 MainPop、AuPop 和 diversity archive 组成，MainPop 最终输出非支配解 | 框架设计 | Sec. 3.2 / Algorithm 1 |
| P2026-0164 | MainPop 不直接参与 AuPop 演化，而是通过合并 MainPop/AuPop/DA 并更新 DA 后间接引导 AuPop | 信息传递 | Sec. 3.2 |
| P2026-0164 | MainPop Strategy I 在 CDP rank-1 个体数超过阈值时使用 SPEA2-style fitness 和 Euclidean distance 保持均匀性 | 作者提出/组合方法 | Sec. 3.3 / Algorithm 2 |
| P2026-0164 | MainPop Strategy II 融合 CDP+crowding ranking 与 Pareto+crowding ranking，前者偏 constraints，后者偏 objectives | 作者提出/组合方法 | Sec. 3.3 / Eq. 7 |
| P2026-0164 | AuPop 忽略 constraints，按 Pareto ranking/crowding distance 选择，并早期随机保留更多个体 | 辅助群选择 | Sec. 3.3 / Algorithm 3 |
| P2026-0164 | MainPop 用四个 DE mutation operators，并按是否 crossover 分成两组，由历史 fitness improvement 决定组选择概率 | 自适应搜索 | Sec. 3.4 / Algorithm 4 |
| P2026-0164 | 随迭代降低的维度重置扰动用于增强早期 exploration 并缓解 stagnation | 扰动策略 | Sec. 3.4 / Algorithm 4 |
| P2026-0164 | AuPop 规模 `Na` 按 Eq. 17 线性缩减，每代只生成 `Na/2` 个 offspring | 动态辅助规模 | Sec. 3.4 / Algorithm 5 |
| P2026-0164 | DA 从 `DA + MainPop + AuPop` 的 CDP rank-1 set 中按 reference-vector angle 采样，优先 feasible，否则最小 CV | 多样性档案 | Sec. 3.5 / Algorithm 6 |
| P2026-0164 | DA 规模 `Nd` 按 Eq. 18 线性缩减，`Nd_max=Na_max`，`Nd_min=Na_min` | 动态档案规模 | Sec. 3.5 |
| P2026-0164 | 复杂度主导项来自 MainPop update，整体为 `O(m(2N + Na)^2)` | 复杂度 | Sec. 3.6 |
| P2026-0164 | benchmark 使用 NCTP、LIR-CMOP、MW、CF 共 56 个问题，对比 14 个 SOTA CMOEAs | 实验设置 | Sec. 4 / Table 1 |
| P2026-0164 | IGD 总计 `58/653/73`，HV 总计 `69/589/126`，总体多数显著优于对比算法 | 综合实验支持 | Sec. 4.2 / Tables 3-4 |
| P2026-0164 | CMOCEA-DDAP 在四个 benchmark suites 上 average feasibility rate 均为 100% | 可行性证据 | Sec. 4.2 / Fig. 7 |
| P2026-0164 | LIR-CMOP 运行时间在 15 个算法中排第 4，MainPop update 是主要耗时组件 | 效率证据 | Sec. 4.2 / Fig. 8 |
| P2026-0164 | 七个消融去除任一模块都会降低性能，去除 diversity enhancement 影响最大 | 消融支持 | Sec. 4.3 / Tables 5-6 |
| P2026-0164 | 无扰动变体在 MW2/MW6 上停滞，完整算法能收敛到 true PF | 机制可视化 | Sec. 4.3 / Fig. 10 |
| P2026-0164 | 只用 MainPop Strategy II 的变体在 MW4/MW8 上分布不如完整算法均匀 | CHT 机制证据 | Sec. 4.3 / Fig. 11 |
| P2026-0164 | 21 个 mechanical design problems 上，CMOCEA-DDAP 整体 HV 优于任何对比算法，Friedman/Scheffe 排名最好 | 真实问题支持 | Sec. 4.5 / Table 13 / Fig. 12 |
| P2026-0164 | 作者指出 UPF 远离 CPF 且 CPF irregular/dense 时算法表现较差，未来需改进主辅协同 CHT | 作者局限/未来工作 | Sec. 4.2 / Sec. 5 |

## 证据边界

- 当前直接证据来自 P2026-0164 一篇算法论文。
- 实验主要覆盖 2-3 目标连续 CMOP 与 mechanical design problems；many-objective、离散/混合变量、动态约束和昂贵评价场景仍未验证。
- 作者报告 CMOCEA-DDAP 在 MW5、MW11、MW12、LIR-CMOP13、CF3 上相对弱，在 CF8-CF10 的 HV 上不如三种群 TPCMaO。
- UPF 与 CPF 距离远时，objective-only AuPop 可能消耗预算并导致后期均匀性修复不足。
- 消融证明完整组合有效，但 `DA`、动态 `Na/Nd`、random survival、MainPop CHT 和 operator selection 的收益仍有耦合。
- `beta`、`alpha`、`CR` 等参数需要设置；参数分析显示过大扰动和过大 `beta` 会显著恶化。

## 待确认

- 如何在线估计 UPF-CPF relatedness 并据此调整 AuPop/DA；
- `DA` 中 infeasible candidates 的低 CV 选择是否足以过滤远离 CPF 的无约束解；
- MainPop 的 Strategy I 是否应由方向覆盖/spacing 触发，而不是 rank-1 数量；
- 在 many-objective 下 Pareto+crowding、Euclidean distance 和 reference-vector angle 是否仍稳定；
- 是否可以把 MainPop operator selection 与主辅资源分配统一成一个 state-feedback controller。
