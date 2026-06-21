---
knowledge_id: K-quantile-staged-constraint-allocation-boundary-transfer
name: 分位数阶段约束分配与边界迁移
type: architecture
status: active
source_papers: [P2026-0004]
aliases: [TriMT-EA, tri-stage dynamic constraint allocation, boundary-guided search, quantile constraint transfer, constraint state tracking, monotonic main-task constraints, EMT CMOP, 三阶段约束分配, 主辅任务约束迁移, 边界引导知识迁移]
promotion_reason: P2026-0004 单篇提出但机制完整，包含无约束 UPF 探索、逐约束平均违反度分位数分配、约束状态单调转移、共享种群主/辅任务演化、低 CV 不可行边界 exemplar 引导，以及四组 CMOP benchmark、11 个真实 RWMOP、参数和消融证据，可复用为复杂 CMOP 的阶段式约束调度架构。
---

# 分位数阶段约束分配与边界迁移

## 核心内容

在复杂 CMOP 中，不一次性处理所有约束，也不固定辅助任务。先让 population 忽略约束探索 UPF；随后按当前 population 对每个约束的平均违反度排序，用分位数阈值把相对容易满足的约束交给主任务，把难约束留在辅助任务中缓冲和探索。随着搜索推进，辅助任务中的约束只允许单向转入主任务，主任务约束集合单调扩张。最后，主任务处理完整约束，辅助任务提供低 CV 边界不可行个体，对主任务中远离边界信息的个体做方向迁移。

```text
unconstrained exploration
-> population-level mean violation per constraint
-> quantile threshold splits constraints into T1/T2
-> state tracking: T2 constraints can move to T1, never backward
-> T1 expands toward full constraints
-> T2 retains difficult constraints and boundary information
-> boundary infeasible exemplars guide distant T1 individuals
-> constrained selection returns feasible CPF approximation
```

该知识的核心是把约束子集当作可随搜索状态单向迁移的任务资源：第二阶段解决“哪些约束现在该由主任务承担”，第三阶段解决“辅助任务剩下的边界信息如何转化为主任务的局部修正方向”。

## 建立理由

- 为什么值得独立维护：
  - 固定主/辅任务无法反映当前 constraint landscape；
  - 只用总 CV 会掩盖不同约束的难度差异；
  - 逐个约束优先级方法常只给一个处理顺序，而该机制同时维护主任务与辅助任务两个约束子集；
  - 单调状态跟踪能减少约束反复切换造成的搜索震荡；
  - 边界迁移把辅助任务后期积累的不可行侧信息显式转为主任务子代方向。
- 单篇具体方法的直接复用价值：
  - P2026-0004 给出 Algorithm 1-2、逐约束 CV 公式、分位数约束分配、状态跟踪、边界迁移公式、复杂度、参数、消融和 benchmark/real-world 证据。
- 与已有设计知识的区别：
  - 不同于“约束边界远距不可行辅助引导”：该知识回答辅助种群保留哪些不可行解；本知识回答约束如何在主/辅任务之间单向迁移，并把边界引导作为第三阶段动作。
  - 不同于“EID 动态约束优先级与协作子代生成”：该知识以单约束 feasible rate/EID 排出约束处理顺序并维护约束级 archive；本知识以逐约束 mean violation 的分位数阈值同步划分主/辅约束子集。
  - 不同于“相关性排序的自适应辅助问题约束处理”：该知识用约束-目标时间序列相关和约束聚类决定辅助问题更新；本知识只需当前 population 的约束违反分布，控制更轻。
  - 不同于“动态辅助任务构造”：该知识多面向低维任务、问题变体或变量子集；本知识的动态对象是约束集合。

## 解决的问题

- 适用场景：
  - 可行域狭窄、断裂、分布不连续或被大面积 infeasible region 包围；
  - 多个约束难度差异明显，且难度会随 population 移动变化；
  - 希望辅助任务不是固定 UPF/relaxed problem，而是动态吸收未成熟约束；
  - 需要阶段式地从 UPF 过渡到 CPF；
  - 主任务容易在局部可行边界停滞，需要不可行侧低 CV 边界信息推一把。
- 现有方法为什么会失败或不足：
  - 一次性全约束 CDP 会在早期强压可行性，丢失跨 infeasible region 的探索；
  - 长期无约束辅助可能远离 CPF；
  - 固定约束分配不能适应某些约束从“难满足”变成“可纳入主任务”的时刻；
  - 辅助任务若只提供普通 offspring 交换，未必能针对主任务的覆盖缺口；
  - 反复重分配约束会导致主任务目标变化不稳定。
- 仍需解决的问题：
  - 如何自动选择 `tau`、`alpha/beta` 和 `tau_b`；
  - 如何处理多个约束尺度差异大导致 mean violation 排序失真；
  - 如何让边界 exemplar 在高维决策空间中的方向更可靠；
  - 如何扩展到 constrained many-objective、large-scale 或 expensive CMOP。

## 为什么可能有效

```text
early UPF exploration preserves broad objective diversity
-> low-violation constraints enter main task first
-> main task always has solvable feasibility pressure
-> high-violation constraints remain in auxiliary task
-> difficult constraints are explored without immediately blocking T1
-> as violations drop, constraints migrate T2 -> T1
-> full constraints are introduced only after enough feasibility structure exists
-> low-CV infeasible boundary exemplars guide uncovered T1 regions
```

关键假设是：当前 population 的逐约束平均违反度可以近似表示约束处理难度，并且低 CV 不可行个体确实携带通往 CPF 的边界方向。如果某个约束平均违反低但对优质 CPF 区段高度关键，或者低 CV 不可行个体位于错误边界，分配和迁移会误导搜索。

## 实现接口

- 输入：
  - 当前 population `P`；
  - 每个个体的 objectives 和每个约束的 violation；
  - 约束集合 `C={c_1,...,c_K}`；
  - 阶段比例或阶段切换判据；
  - constraint transfer quantile `tau`；
  - boundary quantile `tau_b`；
  - guidance strength `lambda` 和 perturbation scale `omega`；
  - constrained environmental selection。
- 输出：
  - 主任务约束子集 `C_T1`；
  - 辅助任务约束子集 `C_T2`；
  - 约束状态向量 `sigma`；
  - 主/辅任务视图 `P1/P2`；
  - 边界 guidance set `E`；
  - boundary-guided offspring。
- 插入位置：
  - multi-stage CMOEA 的阶段控制器；
  - EMT-based CMOEA 的 task construction layer；
  - constraint handler 之前的 constraint-subset scheduler；
  - 双种群或单种群多任务 CMOP 框架的 auxiliary-to-main transfer module。

最小实现：

```text
initialize P
sigma[k] <- 0 for all constraints

while not stop:
    if stage == unconstrained:
        P <- evolve_without_constraints(P)
        if objective_median_change_small(P) and all_nondominated(P):
            stage <- dynamic_allocation

    else if stage == dynamic_allocation:
        for each constraint ck:
            cv[k] <- mean_violation(P, ck)
        q <- quantile(cv, tau)

        for each constraint ck:
            if sigma[k] == 1:
                assign ck to T1
            else if cv[k] <= q:
                assign ck to T1
                sigma[k] <- 1
            else:
                assign ck to T2
                sigma[k] <- 2

        P1 <- constrained_selection(P, constraints=C_T1)
        P2 <- constrained_selection(P, constraints=C_T2)
        P <- shared_variation_and_merge(P1, P2)

        if no sigma changes from 2 to 1:
            stage <- full_constraint

    else:
        P1 <- constrained_selection(P, constraints=all_constraints)
        E <- low_cv_infeasible_boundary_set(P2, tau_b)
        S <- farthest_T1_individuals_from_E(P1, E, count=min(|E|, |P1|))
        O <- {}
        for xi in S:
            xg <- nearest_in_objective_space(xi, E)
            O.add(xi + lambda*(xg - xi) + omega*normal_noise())
        P <- constrained_selection(P1 union O, constraints=all_constraints)
```

P2026-0004 的默认实例：

- `N=100`；
- `alpha=0.2`，`beta=0.5`；
- constraint transfer quantile `tau=0.5`；
- boundary exploration quantile `tau_b=0.1`；
- GA：SBX + PM；
- DE：`CR=1`，`F=0.5`；
- 每代复杂度近似 `O(M*NP^2)`。

## 评价与监控

- 过程指标：
  - 每个约束的 `cv_k` 轨迹；
  - `sigma=2 -> 1` 的约束迁移次数和时机；
  - `|C_T1|/|C|` 随代数变化；
  - guidance set `E` 的大小和平均 CV；
  - guided offspring 的存活率、可行转化率和 HV/IGD 贡献。
- 消融建议：
  - 无第一阶段；
  - 无动态约束分配，直接全约束；
  - 动态分配但不做 state tracking；
  - 第三阶段无 boundary-guided transfer；
  - boundary set 按低 CV、远距、constraint-specific CV 或混合指标分别筛选；
  - 分位数阈值 vs EID/可行比例/相关性排序。
- 失败诊断：
  - `C_T1` 过早包含多数约束且 feasible ratio 很低：`tau` 可能过大或约束尺度未归一；
  - `C_T2` 长期不迁移：难约束需要局部修复、单约束 archive 或更强辅助搜索；
  - guided offspring 很少存活：`lambda/omega` 或 objective-space 最近邻可能不适合当前问题；
  - 最终解集中边界过度聚集：`tau_b` 太小或只引导远距个体不足以覆盖全部 CPF。

## 证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0004 | TriMT-EA 将搜索分为 unconstrained exploration、dynamic constraint allocation、full-constraint convergence 三阶段 | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 5-6 |
| P2026-0004 | 用逐约束 mean violation 和 quantile threshold `Q_tau(cv)` 将约束分给主/辅任务 | 作者提出的方法 | Sec. 3.3.1，Eq. (5)-(9)，PDF 7 |
| P2026-0004 | `sigma_k=0/1/2` 状态跟踪保证主任务约束集合单调扩张，辅助约束只能转入主任务 | 作者提出的方法 | Sec. 3.3.2，Eq. (10)，PDF 8-9 |
| P2026-0004 | 第三阶段用 `0<cv<=zeta` 的辅助任务不可行个体构造 guidance set，并引导主任务远距个体 | 作者提出的方法 | Sec. 3.4，Eq. (11)-(17)，PDF 9-10 |
| P2026-0004 | 单代复杂度近似 `O(M*NP^2)`，与多数 CMOEA 同阶 | 复杂度 | Sec. 3.5，PDF 10 |
| P2026-0004 | 与 8 个 CMOEA 在 LIR-CMOP、MW、DAS-CMOP、CF 上比较，TriMT-EA 在多个窄/断裂/曲线可行域问题表现突出 | 综合实验支持 | Sec. 4.2，PDF 12-24 |
| P2026-0004 | Wilcoxon summary 中 TriMT-EA 相对 8 个对比算法的 IGD/HV 均 `p<0.05`，且 `R+>R-` | 统计支持 | Sec. 4.3，Table 6，PDF 25 |
| P2026-0004 | Friedman average ranking 中 TriMT-EA 在 IGD/HV 上均取得最低平均秩 | 统计支持 | Sec. 4.3，Fig. 9，PDF 27 |
| P2026-0004 | 去掉第一阶段、第二阶段或第三阶段迁移的消融均明显弱于完整 TriMT-EA | 消融支持 | Sec. 4.5，Table 7，PDF 26 |
| P2026-0004 | RWMOP1-11 真实约束问题上，TriMT-EA 在多数实例获得最佳 HV | 真实问题支持 | Sec. 4.6，PDF 24 |

## 证据边界

- 当前是单篇论文证据。
- 主文 benchmark 结果很多，但 ablation 细节主要以 supplementary documents 支撑。
- 参数 `alpha/beta/tau/tau_b` 仍是预设候选中择优，而不是完全自适应。
- 真实问题只用 HV，真实 CPF 未知，难以分解收敛与多样性贡献。
- 约束 mean violation 没有显式处理尺度归一化和约束相关性，复杂多尺度约束可能误导分位数分配。
- 边界迁移用 objective-space 最近邻和 decision-space 方向更新，高维冗余变量或强非线性映射下可能不稳定。

## 可复用变体

- 将 `cv_k` 替换为 normalized CV、feasible ratio、CV下降速度、修复成功率或 constraint-objective correlation。
- 将固定 `tau` 改为按 feasible ratio、迁移成功率或 `C_T1` 扩张速度自适应。
- 为长期停留在 `T2` 的约束建立 constraint-specific archive 或局部 repair operator。
- 对 guidance set `E` 按约束类型分层，避免总 CV 掩盖关键约束边界。
- 将 `x_i + lambda(x_g-x_i)` 改为 DE/current-to-boundary、projected repair、surrogate feasibility direction 或 manifold-aware update。
- 与 EID/相关性排序组合：EID 决定约束优先级，分位数机制决定同阶段主/辅任务划分，边界迁移负责第三阶段局部修正。

