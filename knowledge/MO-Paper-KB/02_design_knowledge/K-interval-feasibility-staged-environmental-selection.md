---
knowledge_id: K-interval-feasibility-staged-environmental-selection
name: 区间目标-可行率两阶段环境选择
type: method
status: active
source_papers: [P2026-0094]
aliases: [TS-ICMOEA, interval constrained MOEA, interval-valued objective environmental selection, two-level dominance ranking, feasible-rate subprocess switch, CI-CV ranking, CIDP, ICMOP, 区间约束多目标, 区间目标环境选择, 可行率切换]
promotion_reason: 单篇论文提出但环境选择接口明确，包含 interval non-dominated sorting、CI/CV 二级排序、feasible-rate 双子过程切换、低 CV 不可行解填充、CIDP 与 interval crowding，可直接嵌入处理 interval-valued objectives 的 constrained MOEA。
---

# 区间目标-可行率两阶段环境选择

## 核心内容

面向带约束的 interval-valued objective MOP，不先把区间目标压成中点或确定性标量，而是在环境选择中直接保留区间比较。搜索前期用 interval non-dominated sorting 维护区间目标信息，再对临界层用 `CI/CV` 二级排序提升选择压力；搜索后期按 feasible rate 判断当前主要矛盾，低可行率时保留全部可行解并用低 CV 不可行解补位，高可行率时只在可行解中用 constrained interval dominance 和 interval crowding 做收敛-分布选择。

```text
interval-valued objectives + constraints
-> Stage 1: interval NDS
   -> critical front: Pareto sort on (CI, CV)
   -> interval crowding truncation
-> Stage 2: split feasible / infeasible
   -> phi < 0.5: keep feasible + fill low-CV infeasible
   -> phi >= 0.5: CIDP among feasible + interval crowding
-> feasible interval Pareto set
```

P2026-0094 的 TS-ICMOEA 是该模式的实例：它把 evolution budget 前半段用于 interval objective global search，后半段用于 feasible region approximation and exploration，并在 InLIRCMOP/InDC-DTLZ 上验证。

## 建立理由

- 为什么值得独立维护：
  - ICMOP 同时存在区间目标不可比和约束可行性两类选择难题；
  - 只做区间排序会在 high-dimensional objective 下产生大量同层个体；
  - 只做可行优先会过早放弃 infeasible boundary 附近的有用区间目标信息；
  - 该方法给出可复用的环境选择层，不绑定具体编码、交叉变异或应用领域。
- 单篇具体方法的直接复用价值：
  - P2026-0094 给出 `CI`、`CV`、feasible rate、CIDP 和 interval crowding 的完整组合流程；
  - 可嵌入 NSGA-II 类、RVEA/NSGA-III 类或其他 interval objective CMOEA 的 selection 部分。
- 与已有设计知识的区别：
  - 不同于“KDE 区间 Pareto 自适应粒子群”：该知识同时包含数据驱动区间估计和 MOPSO pBest/gBest/archive 更新；本知识只关注带约束 interval objectives 的环境选择。
  - 不同于“双射区间分式目标确定性化变换”：该知识把区间目标映射到实值空间；本知识保留区间目标并直接比较。
  - 不同于“约束违反状态驱动的代理搜索模式切换”：该知识面向昂贵优化和 surrogate 模式调度；本知识不使用代理，只调度环境选择。
  - 不同于“分位数阶段约束分配与边界迁移”：该知识按约束违反分布动态分配约束子集；本知识按整体可行率切换 feasible/infeasible 个体保留规则。

## 解决的问题

- 适用场景：
  - 多目标问题的目标值是区间；
  - 同时存在普通 inequality/equality constraints；
  - 可行域狭窄、断裂、被 infeasible region 包围，早期需要保留有价值不可行解；
  - 目标数较多，interval non-dominated sorting 难以提供足够选择压力；
  - 优化器已有 population、offspring 和环境选择流程。
- 现有方法为什么会失败或不足：
  - 把区间目标转成 midpoint/width 加权目标会丢失上下界语义，且权重敏感；
  - 直接使用普通 Pareto dominance 无法比较 interval-valued objectives；
  - penalty/CDP 类方法容易过早偏向可行性，牺牲 interval objective convergence；
  - 单一 interval dominance 在 many-objective 下同层个体过多；
  - 固定阶段或固定可行性压力难适配不同 ICMOP 的可行率变化。
- 仍需解决的问题：
  - 阶段控制因子如何从固定 `mu` 改成自适应；
  - `phi=0.5` 的双子过程阈值是否应随问题和搜索状态变化；
  - `CI` 是否会在不规则或多峰可行域中产生越界搜索；
  - 区间目标高度重叠时，CIDP 和 interval crowding 是否仍有足够选择压力。

## 为什么可能有效

```text
early search needs interval objective pressure
-> interval NDS keeps uncertainty bounds
-> CI gives convergence pressure toward ideal interval
-> CV prevents total neglect of feasibility

late search needs feasibility-aware refinement
-> low feasible rate: preserve all feasible and approach boundary by low CV
-> high feasible rate: optimize only feasible solutions by interval dominance
-> interval crowding keeps feasible PF spread
```

核心假设是：前期的区间目标搜索能发现足够多 promising regions，后期 feasible rate 能反映搜索主矛盾。如果可行域很窄且早期压力过强，population 可能越过可行域；如果区间比较过度不可比，则二级排序和 crowding 仍可能不足。

## 实现接口

- 输入：
  - 当前 population 和 offspring 合并得到的 `Q`；
  - 每个个体的 interval-valued objective vector；
  - 每个个体的 `CV`；
  - stage control factor `mu` 或等价阶段信号；
  - interval dominance、interval distance 和 interval crowding 函数。
- 输出：
  - 下一代 population；
  - 可选：当前 feasible rate、阶段、`CI`、front ranks 和 interval crowding。
- 插入位置：
  - NSGA-II/NSGA-III/RVEA/MOEA-D 的 environmental selection；
  - interval objective CMOEA 的约束处理层；
  - 不确定工程 MOO 中保留目标上下界的选择层。
- 最小实现：

```text
Q <- P union offspring
if generation <= mu * Tmax:
    fronts <- interval_nondominated_sort(Q)
    P_next <- take_full_fronts(fronts, N)
    L <- first_overflow_front(fronts)
    for x in L:
        CI[x] <- interval_distance_to_ideal_interval(x, Q)
        CV[x] <- total_constraint_violation(x)
    subfronts <- nondominated_sort_by_two_objectives(L, (CI, CV))
    P_next <- fill_by_subfronts(P_next, subfronts, N)
    truncate_by_interval_crowding(P_next, N)
else:
    SF <- {x in Q | CV[x] == 0}
    SI <- Q \ SF
    phi <- |SF| / |Q|
    if phi < 0.5:
        P_next <- SF union lowest_CV(SI, N - |SF|)
    else:
        P_next <- top_N_by_CIDP_and_interval_crowding(SF, N)
return P_next
```

## 如何用于算法创新

### 局部创新

- 将固定 `mu` 改为 adaptive trigger：例如 UPF/CPF 距离、feasible rate plateau、IIGD surrogate、front rank entropy 或 `CI` 改善率。
- 将 `phi=0.5` 改为动态阈值：早期提高可行性恢复，后期降低不可行解比例。
- 在 `CI/CV` 二级排序中加入 interval width、regret、CVaR 或用户风险态度。
- 在低可行率阶段不只按 CV 选 infeasible，而是选低 CV 且 interval objective 分布互补的不可行边界解。
- 用 reference vectors 或 clustering 替代纯 interval crowding，提高 many-objective 下分布维护。

### 结构创新

- 构建通用 interval-constrained selection layer：

```text
interval comparator
+ constraint violation evaluator
+ stage controller
+ feasible-rate subprocess scheduler
+ interval diversity selector
```

- 与区间目标建模层结合：前端可来自 KDE、conformal interval、scenario envelope 或 `psi` 变换回译。
- 与 surrogate-assisted CMOEA 结合：代理预测目标上下界和约束可行概率，环境选择仍保留区间目标。
- 与多种风险偏好并行：多个子种群使用不同 `CI` 或 interval dominance risk attitude，再合并 feasible interval Pareto set。
- 与约束分解结合：当可行率低时，进一步按约束贡献拆分 `CV`，选择覆盖不同约束边界的不可行解。

## 适用条件与风险

- 适用条件：
  - 目标上下界或区间目标可可靠计算；
  - 约束违反可汇总为 `CV`；
  - 希望输出保留区间语义的 Pareto set；
  - 环境选择是主要可改造接口；
  - evaluation budget 足以分前后阶段搜索。
- 不适用或可能失效的条件：
  - 区间目标其实只是噪声极大的估计，interval dominance 不稳定；
  - 可行域极窄且早期全局搜索过强，容易越过 feasible region；
  - 目标区间大量重叠，interval NDS 和 CIDP 均产生过多不可比解；
  - true PF/CPF 难以获得，IIGD 类指标无法可靠评估；
  - 约束也具有 interval uncertainty，但算法只按确定性 `CV` 处理。
- 计算与实现成本：
  - 主要成本来自 interval non-dominated sorting 和 CIDP，最坏约 `O(MN^2)`；
  - 需要实现 interval distance、interval probability dominance 和 interval crowding；
  - 如果前端区间来自采样或代理，额外成本取决于区间估计方式。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0094 | TS-ICMOEA 将 ICMOP 搜索分成前期 global search 和后期 feasible region approximation/exploration | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 4-5 |
| P2026-0094 | 第一阶段先用 interval non-dominated sorting，再对临界层用 `min(CI,CV)` 二目标排序 | 作者提出的方法 | Sec. 3.2，Algorithm 2，Eq. (10)，PDF 5-6 |
| P2026-0094 | `CI` 定义为个体区间目标到全局理想区间点的总 interval distance | 作者提出的方法 | Sec. 3.2，Eq. (11)，PDF 6 |
| P2026-0094 | 第二阶段按 feasible rate `phi` 切换双子过程，`phi<0.5` 时保留全部可行解并用低 CV 不可行解补位 | 作者提出的方法 | Sec. 3.3，Algorithm 3，Eq. (12)，PDF 6-7 |
| P2026-0094 | `phi>=0.5` 时使用 CIDP 和 interval crowding 在可行解中选择 top `N` | 作者提出的方法 | Sec. 3.3，PDF 7 |
| P2026-0094 | 复杂度分析给出第一阶段和第二阶段环境选择最坏均为 `O(MN^2)` | 复杂度分析 | Sec. 3.4，PDF 7 |
| P2026-0094 | `mu=0.5` 在 `0.3/0.5/0.7` 三组 stage control factors 中综合表现最好 | 参数实验支持 | Sec. 4.4.1，Table 3，PDF 9-10 |
| P2026-0094 | TS-ICMOEA 在 InLIRCMOP1-4 上取得最佳 IIGD，并保持 final feasible rate 为 1.0 | 综合实验支持 | Sec. 4.4.2，Tables 4-5，PDF 10-12 |
| P2026-0094 | 低维 ICMOP 中对比算法显著优于 TS-ICMOEA 的数量通常为 0-1，显著劣于 TS-ICMOEA 的数量为 8-14 | 统计支持 | Sec. 4.4.2，PDF 12 |
| P2026-0094 | 4-15 objectives 的 InDC-DTLZ 可统计实例中，没有对比算法显著优于 TS-ICMOEA，many-objective 优势更明显 | Many-objective 实验支持 | Sec. 4.4.3，Table 6，PDF 13-15 |
| P2026-0094 | 作者指出第一阶段过强选择压力可能让 population 越过可行域，导致部分 InDC-DTLZ3 上性能不如对比算法 | 适用边界 | Sec. 4.4.2，PDF 12 |
| P2026-0094 | 作者未来工作包括扩展到具有 complex interval constraints 的其他 ICMOP，并调整 transmission factor | 作者未来工作 | Sec. 5，PDF 16 |

## 待确认

- `mu` 和 `phi` 是否能由可行率变化、`CI` 收敛速度或 interval dominance 打平程度自适应决定；
- `CI` 使用全局理想区间点是否会在 disconnected feasible regions 中造成系统性越界；
- interval crowding 在 many-objective 和高度重叠区间下是否足够，是否需要 reference-vector 或 indicator 替代；
- 如何扩展到 interval constraints、chance constraints 或 fuzzy constraints；
- 在真实工程 ICMOP 中，interval bounds 的来源和可信度如何影响环境选择。

