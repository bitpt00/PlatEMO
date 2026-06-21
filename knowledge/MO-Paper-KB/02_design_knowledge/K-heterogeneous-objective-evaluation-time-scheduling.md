---
knowledge_id: K-heterogeneous-objective-evaluation-time-scheduling
name: 异构评价时间的目标-约束真实评价调度
type: method
status: active
source_papers: [P2026-0227, P2026-0107]
aliases: [HET-EMO, HET-NSGA-III, MFE-EM(a)O, MFE-NSGA-III, HFS, MFS, mixed-fidelity evaluation, heterogeneous evaluation times, heterogeneous objectives, heterogeneous constraints, nonuniform latency, objective-wise high-fidelity evaluation, objective-constraint high-fidelity evaluation, RV-guided probabilistic dominance, block-evaluated objectives, block-evaluated constraints, 异构目标评价时间, 异构约束评价时间, 目标级真实评价, 目标-约束真实评价, 非均匀延迟, 解-目标评价调度, 解-约束评价调度]
promotion_reason: P2026-0227 提出目标级 HET-EMO/HFS，P2026-0107 将其扩展为 constrained multi-/many-objective mixed-fidelity evaluation，形成解-目标/解-约束级高保真评价选择、参考向量概率支配、代理误差、评价时间和约束边界联合调度，可直接改造代理辅助优化的真实评价调度层
---

# 异构评价时间的目标-约束真实评价调度

## 核心内容

在代理辅助多目标/多目标约束优化中，把真实评价预算从“选择哪个候选解全函数评价”细化为“选择哪个解的哪个目标或哪个约束高保真评价”。目标侧对每个候选解 `s` 和目标 `m` 计算 HFS/MFS 指标，综合参考向量邻域内的非支配潜力、目标相对评价时间和目标代理预测误差；约束侧根据 surrogate mean/uncertainty 判断解是否明显可行、近边界或明显不可行，只在近边界约束上花高保真预算。

```text
每目标/每约束独立代理 + 函数级评价时间
-> 代理内运行 reference-vector EMO 若干代
-> 合并父代/后代并按参考向量关联
-> 对可行/近可行解计算解-目标 HFS/MFS
-> 对近边界约束计算是否需要高保真校正
-> 只执行高价值目标/约束或软件 block
-> 更新对应 archive 和 surrogate
-> 终止前补齐最终解的全部目标和约束
```

## 建立理由

- 为什么值得独立维护：
  - 工程多目标仿真中，目标函数和约束函数经常来自不同软件、不同物理模块或不同后处理，评价时间差异很大。
  - 传统 SAEA 默认一个 infill 解的所有目标和约束都真实评价，会把时间浪费在当前不关键、远离约束边界或很贵的函数上。
  - 该知识提供的是真实评价调度层，可接入 NSGA-III、RVEA、MOEA/D、BO-MOEA 或其他代理辅助 EMO/MaO。
- 跨论文支持：
  - P2026-0227 给出 HET-EMO、HFS 指标、参考向量概率支配、block objective 扩展、参数敏感性和 234 个实例实验。
  - P2026-0107 给出 MFE-EM(a)O / MFE-NSGA-III，把目标级 HFS 扩展到约束问题，加入 Class I/Class II 约束状态、近边界约束评价、blocked objective-constraint 和无约束/单目标退化证据。
- 与已有设计知识的区别：
  - 不同于“自适应代理内环加速器”：该知识在宿主子代和真实评价之间插入代理内环；本知识重点是函数级真实评价选择和异构评价时间。
  - 不同于“稀疏迁移堆叠的多源代理选择”：该知识融合历史源代理并用 cost-sensitive EI 选完整候选；本知识不做源代理选择，而是决定单个候选的哪些目标或约束需要高保真。
  - 不同于“收敛-边界两步代理采样更新”：该知识面向昂贵约束问题的样本来源；本知识面向异构函数评价时间和 partial objective/constraint evaluation。
  - 不同于普通 cost-aware acquisition：本知识把多目标参考向量覆盖、目标级代理误差和约束边界状态同时纳入调度。

## 解决的问题

- 适用场景：
  - 多个目标和/或约束可独立调用高保真评价，且耗时不同；
  - 每个目标/约束有独立 surrogate 和不确定性估计；
  - 总预算按 wall-clock 或相对评价时间计，而不是只按完整解评价次数计；
  - 需要在多目标搜索中同时维护收敛、参考方向覆盖和约束边界学习；
  - 某些目标/约束可由一个 block simulation 一次性共同输出。
- 现有方法为什么会失败或不足：
  - 全函数评价一个候选会浪费昂贵目标或约束预算；
  - 只偏向便宜函数会导致后期关键昂贵目标或边界约束不准；
  - 只看代理误差会把预算花在对 PF/CPF 贡献小的解上；
  - 只看目标质量会忽略某些目标代理已很准、约束远离边界或函数评价过慢；
  - 对明显不可行解全目标评价会浪费预算，对近边界约束不评价又会误判可行性。

## 为什么可能有效

```text
同一候选的不同目标/约束对当前搜索价值不同
-> 代理误差高的目标需要真实校正
-> 参考向量邻域中有非支配潜力的解更值得校正
-> 便宜目标早期可用同样时间获得更多反馈
-> 昂贵目标后期必须补齐以保证真实 PF 质量
-> 近约束边界才最需要高保真约束信息
-> 明显满足/明显违反的约束可暂由 surrogate 支撑
-> 函数级真实评价让每单位时间产生更多有效代理更新
```

关键假设是：目标和约束可被独立高保真评价，或至少可被明确拆成 evaluation blocks；部分高保真/部分代理评价的解能安全参与中间搜索；最终输出前必须补齐所有目标和约束的真实评价。

## 实现接口

- 输入：
  - 当前种群和代理后代；
  - 每个目标 archive `A_f[m]` 和每个约束 archive `A_g[j]`；
  - 每个目标/约束的 surrogate mean/uncertainty；
  - 每个目标/约束平均评价时间 `ET_f[m]`、`ET_g[j]` 或 block evaluation time；
  - 参考向量集合和关联关系；
  - 当前时间预算 `T`、最终补齐预算和可行/近边界阈值 `e`。
- 输出：
  - 需要高保真评价的 `(solution, objective)`、`(solution, constraint)` 或 `(solution, block)` 列表；
  - 更新后的目标/约束 archive 和 surrogate；
  - 带有 partial high-fidelity flags 的下一轮父代；
  - 终止时全函数高保真补齐后的可行非支配解。
- 插入位置：
  - 代理辅助 EMO 的 infill selection / surrogate management 层；
  - 每轮代理搜索结束、真实评价前；
  - 多软件仿真任务调度器、多保真评价调度器或异步资源管理层。
- 最小实现：

```text
initialize A_f[m], A_g[j] with all-function high-fidelity DoE
train surrogate SM_f[m], SM_g[j]
P <- survival_selection(DoE)

while T <= T_max - final_fill_budget:
    Q <- run_EMO_on_surrogates(P, SM_f, SM_g, tS)
    R <- eliminate_duplicates(P union Q)
    predict all objectives/constraints of R by surrogates
    associate R to reference vectors

    ClassI <- feasible_or_near_feasible(R, SM_g, e)
    ClassII <- R \ ClassI

    selected <- []
    if |ClassI| > 0:
        for each reference vector k:
            candidates <- ClassI associated with k
            score each (s, m) by MFS(P_not_worse, ET_f[m], uncertainty_f[s,m])
            choose best not-yet-high-fidelity (s, m)
            selected.append((s, m))
            for each constraint j near boundary for chosen s:
                selected.append((s, j))
        fill remaining slots, if needed, from ClassII by constraint satisfaction
    else:
        s <- least-infeasible solution by overall constraint satisfaction
        j <- closest-to-satisfied constraint of s
        selected.append((s, j))

    high_fidelity_evaluate(selected or related blocks)
    update archives, surrogates, flags and T
    P <- mixed-fidelity survival result

final_evaluate_all_objectives_and_constraints(P)
return feasible_nondominated(P)
```

## 如何用于算法创新

### 局部创新

- 将静态 `ET_f[m]` / `ET_g[j]` 换成在线成本模型，处理随解、软件状态或排队时间变化的仿真耗时。
- 用 conformal uncertainty、ensemble disagreement 或 quantile surrogate 替代 Kriging `sigma`，提升目标误差和约束边界判断的可靠性。
- 将 HFS/MFS 中的参考向量概率支配替换为 HV contribution、IGD+ contribution、R2 contribution 或 preference-region utility。
- 对近边界参数 `e` 做阶段自适应：早期扩大约束学习区域，后期收缩以节省约束评价。
- 为目标/约束设置最小/最大真实评价频率，防止便宜函数或昂贵函数被长期偏置。
- 在不可行阶段允许按预算评价多个最有学习价值的不可行解关键约束，而不是固定只评价一个。

### 结构创新

- 构建多软件仿真调度层：

```text
目标/约束 -> 软件调用块 -> 运行时间/失败率模型
-> 解-目标/解-约束/解-block MFS
-> 并行执行队列
-> partial high-fidelity archive
-> 代理辅助 EMO/MaO
```

- 与多保真优化结合：先决定哪个目标/约束需要更多信息，再决定调用低/中/高保真模型。
- 与 GPU/集群资源管理结合：MFS 加入排队时间、worker 空闲、能耗、费用或仿真失败概率。
- 与 surrogate modeling taxonomy/ASM 结合：MFE 决定“评哪些函数”，ASM 决定“这些函数如何建模或聚合建模”。
- 与偏好优化结合：只对偏好区域参考向量附近的解-目标/解-约束提高高保真密度。

## 适用条件与风险

- 适用条件：
  - 目标和约束能独立评价，或可被明确分成 evaluation blocks；
  - 可获得每个目标/约束的评价时间估计；
  - 每个目标/约束可训练有不确定性输出的 surrogate；
  - 中间阶段允许 mixed high-fidelity/surrogate objective and constraint values；
  - 最终解可在终止前补齐所有目标和约束真实评价。
- 不适用或可能失效的条件：
  - 仿真接口只能一次性输出所有目标和约束，且 partial evaluation 不能节省时间；
  - 目标/约束评价时间高度随机或随候选变化剧烈，静态 `ET` 误导调度；
  - 代理不确定性校准差，HFS/MFS 会过度相信错误代理或漏评关键约束；
  - 约束边界极窄且 surrogate 误差大，Class I/Class II 分割可能把可行域误删；
  - 目标/约束间强相关但独立建模，部分评价可能错过可利用的相关信息；
  - 高维决策空间下 Kriging 训练不稳，函数级调度收益被代理误差抵消。
- 计算与实现成本：
  - 需要维护每个目标/约束的 archive、surrogate 和 high-fidelity flag；
  - 选择阶段要对 `2N x M` 个解-目标组合和相关约束状态打分；
  - 需要处理 partial objective/constraint values 的排序、显示、可行性判断和最终补齐；
  - 工程系统还需异步仿真、失败重试、block 调度和结果缓存管理。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0227 | 提出 HET-EMO，不要求对一个 population member 的所有目标都高保真评价，而是选择解-目标组合 | 作者提出的方法 | Sec. I、III，PDF 1-4 |
| P2026-0227 | HFS 指标结合相对评价时间、RV 邻域内不劣概率和每目标 surrogate prediction error | 作者提出的方法 | Sec. III-C，PDF 4-5 |
| P2026-0227 | 用同一参考向量关联成员之间的代理均值和不确定性计算概率支配/不劣概率 | 作者提出的方法 | Sec. III-C，Fig. 1，PDF 4-5 |
| P2026-0227 | `alpha` 自适应地从早期偏向便宜目标转向后期重视昂贵目标，固定 `alpha=-1/1` 不如自适应稳 | 作者提出的方法/参数证据 | Sec. III-E、Table I，PDF 5-6 |
| P2026-0227 | 对每个参考向量选择 HFS 最大的解-目标组合，并形成 mixed high-fidelity/surrogate 下一代父代 | 作者提出的方法 | Sec. III-D、Algorithm 2、Fig. 2，PDF 5 |
| P2026-0227 | DTLZ2 `(0.9,0.1)` 中 HET-NSGA-III 自动更多评价便宜且更需校正的 `f2`，并在 300 时间单位内完成约 29 次迭代 | 机制证据 | Sec. IV-A、Fig. 4，PDF 8-9 |
| P2026-0227 | 两目标 ZDT/DTLZ 上 HET-NSGA-III 绝大多数实例显著更好或相当，只有一个简单 ZDT1 极端耗时组合中被部分算法超过 | 综合实验支持与边界 | Sec. IV-A、Table II，PDF 7-9 |
| P2026-0227 | 三目标 DTLZ/WFG 上 HET-NSGA-III 对所有测试实例统计上更好或相当 | 综合实验支持 | Sec. IV-B、Table III，PDF 9-11 |
| P2026-0227 | 五目标和八目标 DTLZ/WFG 上，表格结论为 HET-NSGA-III 未被其他五个对比算法显著超越 | many-objective 证据 | Sec. IV-C、Tables IV-V，PDF 10-12 |
| P2026-0227 | four-bar truss 和 crash-worthiness 工程问题中，HET-NSGA-III 显示较好收敛和多样性 | 工程问题支持 | Sec. IV-D、Fig. 6，PDF 12-13 |
| P2026-0227 | `N_DoE≈0.33Tmax`、`eta=20`、`tS≈30` 的敏感性实验支持默认参数；不考虑 surrogate error 的 `eta=infinity` 不可靠 | 参数敏感性 | Sec. IV-E、Fig. 7，PDF 13 |
| P2026-0227 | block-evaluated objectives 中，若同一软件一次输出多个目标，HET-EMO 用 block time 更新 HFS 并避免重复计时 | block 扩展 | Sec. V、Table VI，PDF 13-14 |
| P2026-0227 | 234 个测试与工程实例中，HET-NSGA-III 取得 121 better、111 equivalent、2 worse | 总体证据 | Sec. VI，PDF 14 |
| P2026-0107 | 提出 MFE-EM(a)O / MFE-NSGA-III，把目标级异构评价扩展到目标和约束共同异构的 constrained multi-/many-objective optimization | 作者提出的方法 | Sec. 1-2 |
| P2026-0107 | Class I / Class II 根据 surrogate constraint statistic 判断可行/近可行与明显不可行；目标评价主要给可行/近可行解 | 作者提出的方法 | Sec. 2.1 |
| P2026-0107 | 近约束边界才高保真评价约束，显著可行或显著不可行的约束可暂不评价 | 作者提出的方法 | Sec. 2.1、Fig. 1 |
| P2026-0107 | MFS 指标继承 HET-NSGA-III 的参考向量概率、评价时间与代理不确定性，并用于选择解-目标组合 | 作者提出的方法 | Sec. 2.1-2.2 |
| P2026-0107 | 两目标约束问题 21 个场景中，MFE-NSGA-III 相对 NSGA-III 全部更好，相对 SA-NSGA-III 15 个更好，且不显著差于任何对比算法 | 综合实验支持 | Sec. 3.1、Table 1 |
| P2026-0107 | C2DTLZ2 `(0.5,0.33|0.17)` 中约束高保真调用更少，便宜目标调用更多，同时取得更好 PF | 机制证据 | Sec. 3.1、Fig. 3 |
| P2026-0107 | 三目标 C2DTLZ2/MW14 的 10 个场景中 9 个更好、1 个与 SA-NSGA-III 相当；五/八目标 C2DTLZ2 的 10 个场景中 8 个更好、2 个相当 | many-objective 证据 | Sec. 3.2、Table 2 |
| P2026-0107 | welded-beam 和 carside 8 个工程异构场景中，MFE-NSGA-III 相对 NSGA-III 和 SA-NSGA-III 全部最佳 | 工程问题支持 | Sec. 3.3、Table 3 |
| P2026-0107 | carside/disc brake blocked objective-constraint 场景中，同一 block 内目标/约束一起评价，3 个场景均不差且显著优于对比算法 | block 约束扩展 | Sec. 4、Table 4、Fig. 8 |
| P2026-0107 | 无约束多目标 28 个场景中，MFE-NSGA-III 与 HET-NSGA-III 统计相当，说明约束扩展保留了原目标级能力 | 退化/兼容性证据 | Sec. 5.1、Table 5 |
| P2026-0107 | 单目标约束 G1/G4/G10 的 15 个场景中，MFE-NSGA-III 全部优于 RGA 和 SA-NSGA-III | 退化/泛化证据 | Sec. 5.2、Table 6 |
| P2026-0107 | `e=-0.25` 和 `e=-0.5` 在敏感性实验中较稳；`e=-2` 会过度评价约束，`e=-0.05` 容易边界过窄 | 参数敏感性 | Sec. 6、Table 7 |

## 证据边界

- 目标级 HFS 证据来自 P2026-0227，目标-约束级 MFE 证据来自 P2026-0107；两者同属作者路线，仍需要其他独立团队和真实工业流程复现。
- P2026-0227 主要变量维度为 10，P2026-0107 覆盖 2-10 变量；高维、混合变量和强噪声约束场景需另证。
- 平均评价时间 `ET` 被视为已知、预设或可估计，尚未系统处理随机耗时、排队时间、异步并行和失败重试。
- HFS/MFS 是启发式组合，虽然实验强，但各项权重、`eta`、`alpha(T)`、`e` 在新领域需重新校准。
- 部分高保真评价只适合中间搜索，最终输出必须全目标/全约束高保真补齐。
- 当前 block mapping 由实验问题设定给出，真实软件调用图中的目标/约束依赖关系可能更复杂。

## 待确认

- 对随候选和资源状态变化的 evaluation time，是否应训练 objective/constraint-wise cost surrogate；
- 目标和约束相关性强时，独立 surrogate 是否浪费跨函数信息；
- 在噪声、多保真、异步并行仿真下，HFS/MFS 应如何改写；
- 如何对 partial high-fidelity population 做更严格的不确定性传播和可行性风险控制；
- 高维、混合变量和真实多软件工程流程中，维护函数级 archive 的开销是否仍可接受。
