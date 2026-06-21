---
knowledge_id: K-reference-vector-hierarchical-priority-upf-cpf-guidance
name: 参考向量分层优先的 UPF-CPF 三群协同
type: architecture
status: active
source_papers: [P2026-0159]
aliases: [ATMC, adaptive two-stage multi-population coevolution, reference-vector-guided hierarchical priority selection, HPS, UPF-to-CPF guidance, dynamic epsilon constraint relaxation, adaptive population stopping, 三群协同, 分层优先选择, 参考向量约束松弛, UPF到CPF引导]
promotion_reason: 单篇论文提出但架构接口完整，包含探索种群、引导收敛种群、可行开发档案三角色，两阶段 UPF-to-CPF 转换，稳定+停滞双条件阶段切换，基于 UPF/CPF 重叠 proxy 的探索种群暂停，以及参考向量逐方向三层优先选择，可直接改造复杂 CMOP 的多种群资源调度与环境选择。
---

# 参考向量分层优先的 UPF-CPF 三群协同

## 核心内容

在复杂约束多目标优化中，不把“可行性优先”作为唯一选择逻辑，也不让无约束辅助种群长期盲目追 UPF。先用探索种群和引导收敛种群忽略约束，获得尽可能完整的 UPF 方向覆盖；当探索种群在目标空间同时稳定且停滞后，进入 UPF-to-CPF 引导阶段。此时通过动态收缩的 `epsilon` 约束边界和参考向量分层优先选择，为每个方向选择一个代表解：优先选 `epsilon` 可行且在 objectives+CV 上非支配的 elite，其次选 `epsilon` 可行解，再选不可行解，必要时用全局非支配解 fallback。最终可行解由独立可行开发档案输出，松弛不可行解只承担方向引导。

```text
P1: unconstrained exploration and stage monitor
P2: UPF coverage -> epsilon-relaxed direction-wise CPF guidance
P3: feasibility-exploitation archive and final output

Stage I:
    P1, P2 ignore constraints
    P3 preserves feasible solutions

Stage II:
    epsilon shrinks
    each reference vector selects one representative by:
        SRank1 elite -> SRank2 epsilon-feasible -> SRank3 infeasible -> fallback
    optionally stop P1 when UPF/CPF overlap is low
```

该知识的核心是“逐方向保留桥接候选”，让约束松弛不只是告诉算法什么时候进入可行区，还告诉算法从哪些方向均匀进入 CPF。

## 建立理由

- 为什么值得独立维护：
  - 复杂 CMOP 中 CPF 可能狭窄、断裂，单个易达可行片段会吸走全种群；
  - 只靠动态 `epsilon` 或 CDP 无法保证每个 objective direction 都有代表；
  - 普通辅助种群追 UPF 后，如果没有方向级筛选，UPF 信息难以均匀映射到 CPF；
  - P2026-0159 给出完整三种群框架、HPS 伪代码、阶段切换、消融、参数灵敏度、49 个 benchmark 和 7 个真实问题证据。
- 单篇具体方法的直接复用价值：
  - HPS 可以独立替换复杂 CMOEA 的辅助种群环境选择；
  - dual-condition stage transition 可移植到其它 UPF-first 或 push-pull 框架；
  - adaptive stopping 给多种群资源调度提供简单接口；
  - 独立可行档案使 relaxation 用于搜索引导而不污染最终输出。
- 与已有设计知识的区别：
  - 不同于约束边界远距不可行辅助引导：该知识按边界距离和主群距离筛选不可行解，本知识按 reference vector 逐方向三层优先选择；
  - 不同于 UPF 参照动态逃逸种群：该知识通过慢/快逃逸保留 suboptimal solutions，本知识通过 HPS 和动态 `epsilon` 从 UPF 均匀拉向 CPF；
  - 不同于 FSM 多阶段调度：本知识是二阶段切换加探索种群暂停，不是四状态事件机；
  - 不同于约束难度加权多辅助种群：本知识按搜索角色分群，不按单个约束维度分群；
  - 不同于普通自适应 ε-dominance 档案：本知识的 `epsilon` 是约束违反容忍阈值，并服务于 direction-wise CPF guidance。

## 解决的问题

- 适用场景：
  - CPF 与 UPF 存在明显距离，但 UPF 方向仍能提供全局分布线索；
  - 可行域狭窄、断裂或被大不可行区域隔开；
  - 需要在每个目标方向保留桥接候选，而不是只追最容易可行的区域；
  - 评价预算足以维护 2-3 个种群或 archive；
  - 可用 reference vectors 表示期望覆盖方向。
- 现有方法为什么会失败或不足：
  - CDP 会让种群快速聚到已有可行片段；
  - 只追 UPF 的辅助种群在 UPF/CPF 距离大时后期会浪费预算；
  - 普通 constraint relaxation 若无方向机制，收缩时仍可能集中到少数可行方向；
  - angle-based selection 若只是局部比较，不能保证每个方向都获得代表解；
  - 多种群若不停止低贡献群体，会增加常数开销和互相干扰。
- 仍需解决的问题：
  - 如何在线估计每个 reference direction 的贡献，而不是只用全局 `rf`；
  - 如何为断裂 CPF 或大空洞方向自适应关闭/重分配 reference vectors；
  - 如何在 many-objective 下避免均匀 reference vectors 过多且稀疏；
  - 如何让 `epsilon` 收缩速度与局部可行域难度匹配。

## 为什么可能有效

```text
unconstrained P1/P2
-> learn broad UPF directions before feasibility pressure dominates

stability + stagnation switch
-> avoids stopping while population is still drifting toward UPF

dynamic epsilon
-> feasible pressure increases gradually
-> infeasible bridge solutions are not removed too early

reference-vector HPS
-> one direction, one representative
-> easy feasible regions cannot monopolize population

P3 final output
-> relaxed infeasible solutions guide search but final set stays feasible
```

关键假设是：UPF 的方向覆盖对 CPF 仍有指导价值，并且目标空间 reference vectors 能把复杂 CPF 的覆盖需求表达出来。如果 UPF 与 CPF 几何关系很弱，或 CPF 只存在于极少数 reference directions 上，HPS 可能把预算分给无效方向。

## 实现接口

- 输入：
  - CMOP 的 objectives、constraints 和 CV；
  - population size `N` 和 reference vectors；
  - stage transition 窗口 `G`、稳定阈值 `tau_std`、停滞阈值 `tau_mean`；
  - `epsilon` 收缩率 `tau`；
  - exploration stopping 阈值 `beta`；
  - guided offspring 数 `NDE`。
- 输出：
  - `P2` 的 direction-wise guided population；
  - `P3` 的 feasible nondominated archive；
  - stage flag、`epsilon_k`、`continue` 状态；
  - 每个 reference direction 的 selected rank 诊断。
- 插入位置：
  - 多种群 CMOEA 的 Stage II 环境选择；
  - Push-Pull / UPF-first 框架的 Pull 阶段；
  - 约束松弛 CMOEA 的 selection 层；
  - 动态 CMOP 中环境变化后的再引导阶段。
- 最小实现：

```text
initialize P1, P2, P3
flag <- 0
continue <- true
epsilon <- 0

while budget remains:
    if flag == 0:
        evaluate P1, P2 without constraints
        evaluate P3 with constraints
        update flag by stability and stagnation of P1
        if flag == 1:
            epsilon <- mean CV of infeasible members in P2
            rf <- feasible ratio among nondominated P1
            if rf < beta:
                continue <- false
    else:
        epsilon <- (1 - tau) * epsilon

    O1 <- offspring(P1) if continue else empty
    O2 <- boundary_enhanced_DE(P2)
    O3 <- offspring(P3)

    if flag == 0:
        P1, P2 <- unconstrained selection
        P3 <- constrained selection
    else:
        candidates <- P1 + P2 + P3 + O2 if continue else P2 + P3 + O2
        P2 <- HPS(candidates, reference_vectors, epsilon)
        P3 <- constrained selection(...)

return P3
```

HPS:

```text
S1 <- nondominated(CV <= epsilon, in objectives + CV)
S2 <- CV <= epsilon
S3 <- CV > epsilon
available <- all candidates

for w in reference_vectors:
    T1 <- available solutions from S1 within angle h of w
    T2 <- available solutions from S2 within angle h of w
    T3 <- available solutions from S3 within angle h of w
    choose smallest-angle solution from first nonempty T1/T2/T3
    if all empty:
        choose smallest-angle solution from global nondominated set
    remove chosen solution from available if it came from T1/T2/T3
```

## 如何用于算法创新

### 局部创新

- 让 `epsilon` 按方向自适应：
  - 每个 reference vector 维护自己的 feasible-hit rate 和 CV quantile；
  - 难方向慢收缩，易方向快收缩；
  - 长期无贡献方向减少 offspring 配额。
- 改造 `rf`：
  - 从全局可行比例改为 direction-wise UPF/CPF overlap；
  - 使用 feasible nondominated contribution、P3 接收率、CV entropy 或 angle coverage 作为 stopping signal；
  - 在 overlap 高的方向暂停 `P1`，低的方向保留探索。
- 改造 HPS 层级：
  - 增加 uncertainty-feasible 层，例如 surrogate 预测可行概率高但尚未真实可行；
  - 在 `SRank3` 中优先选择低 CV 且历史方向稀缺的候选；
  - 把 fallback 从全局非支配改成邻近 reference 的历史 best 或 archive prototype。
- 减少静态 reference waste：
  - 合并长期空方向；
  - 在 CPF 断裂处用 adaptive reference vector split；
  - 用 R2/HV contribution 替代纯角距离。

### 结构创新

- 通用三角色 CMOP 框架：

```text
Scout population:
    objective-only map of UPF and stage monitor

Bridge population:
    epsilon-relaxed direction-wise transition from UPF to CPF

Feasible archive:
    strict feasibility and final output
```

- 与不可行边界搜索组合：
  - HPS 中 `SRank3` 不只按 CV/angle，还按“近边界且远离可行档案”排序；
  - 将边界远距方法作为 `SRank3` 的内部 tie-breaker。
- 与动态约束优化组合：
  - 环境变化后重新激活 `P1`；
  - `P3` 保存旧环境可行档案，`P2` 用 HPS 迁移到新 CPF；
  - 每个 reference direction 记录变化前后的 CV shift。
- 与多任务 CMOP 组合：
  - 不同任务共享 reference-direction diagnostics；
  - 从相似任务迁移“哪些方向难可行、哪些方向需慢收缩”的经验。

## 适用条件与风险

- 适用条件：
  - 目标空间 reference directions 对覆盖需求有意义；
  - UPF 与 CPF 之间存在可利用的方向关系；
  - 约束违反 `CV` 可比较且不会完全欺骗搜索；
  - 评价预算足够支持多种群和 HPS 的常数开销；
  - 最终必须输出严格可行解，因此需要独立可行档案或等价机制。
- 不适用或可能失效的条件：
  - UPF 方向与 CPF 几乎无关，UPF-first 会误导；
  - CPF 只覆盖少数目标方向，固定均匀 reference vectors 大量空转；
  - 严格预算下 Stage I 未能触发切换，三种群长期并行反而降低效率；
  - CV 尺度极不均或长尾，平均 CV 初始化 `epsilon` 不稳；
  - many-objective 中 reference vectors 过多，HPS 选择成本和稀疏性问题加重。
- 计算与实现成本：
  - 需要维护三个种群、跨种群合并、去重和 archive；
  - HPS 需要非支配排序、角度关联和逐方向可用解维护；
  - 静态 reference vectors 可能在无可行方向上浪费选择槽；
  - 参数虽不多，但 `tau/G/beta/NDE` 仍需要合理默认值。
- 证据风险：
  - 主文很多详细数值在 supplementary materials，主文以统计汇总为主；
  - 真实问题只用 HV，不能分解收敛、可行发现率和覆盖均匀性；
  - ATMC 在 CF8/CF9 等问题上不占优，说明 stage transition 失败时开销会伤害表现；
  - HPS 与 BDE、P3 archive、stopping 的贡献交织，迁移单个组件时收益需重新验证。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0159 | ATMC 由 `P1/P2/P3` 三种群组成，分别承担无约束探索、引导收敛和可行开发输出 | 架构设计 | Sec. 3.1、Algorithm 1，PDF 4、7 |
| P2026-0159 | `epsilon_{k+1}=(1-tau)*epsilon_k`，逐步增强可行性压力并配合 HPS | 约束松弛 | Sec. 3.1、Eq. (6)，PDF 4 |
| P2026-0159 | Stage transition 要同时满足目标标准差稳定条件和目标均值变化停滞条件 | 作者提出的方法 | Sec. 3.2、Eq. (7)-(8)，PDF 6 |
| P2026-0159 | 切换后以 `P2` 不可行个体平均 CV 初始化 `epsilon`，并用 `P1` 非支配可行比例 `rf` 判断是否暂停 `P1` | 资源调度 | Sec. 3.2、Algorithm 2，PDF 6-7 |
| P2026-0159 | BDE 优先使用边界个体作为 base vectors，并在局部邻域和全局随机搜索间切换 | 子代生成 | Sec. 3.3、Algorithm 3，PDF 6-7 |
| P2026-0159 | HPS 将候选分为 `SRank1/SRank2/SRank3`，再对每个 reference vector 逐层选择代表解 | 作者提出的方法 | Sec. 3.4、Algorithm 4，PDF 8 |
| P2026-0159 | HPS 的 fallback 机制在空方向上从全局非支配集选角距离最近解，保证每个方向有代表 | 方向多样性 | Sec. 3.4.2、Fig. 7，PDF 8 |
| P2026-0159 | relaxed infeasible solutions 不会作为最终输出，最终解来自 `P3` 可行开发档案 | 可行性保障 | Sec. 3.5，PDF 9 |
| P2026-0159 | 49 个 benchmark 上，ATMC 相对 11 个 baseline 多数 IGD/HV 比较显著占优 | 综合实验支持 | Sec. 4.3、Table 2，PDF 10 |
| P2026-0159 | 改进 Friedman test 中 ATMC 平均排名最低，IGD `2.24`、HV `2.17` | 全局统计 | Sec. 4.3、Fig. 10，PDF 11-12 |
| P2026-0159 | ATMC-S4 去掉 angle-based direction guidance 后，完整 ATMC 在 49 个问题中 38 个 IGD 更好 | 消融证据 | Sec. 4.4、Table 3，PDF 11-12 |
| P2026-0159 | ATMC-S2 去掉 HPS 三层优先分层后，完整 ATMC 在 19 个问题 IGD 更好，优势问题通常差一到多个数量级 | 消融证据 | Sec. 4.4、Table 3、Fig. 11，PDF 11-12 |
| P2026-0159 | ATMC-S1/S5 消融支持 exploration population stopping 和独立 exploration population 对整体鲁棒性有贡献 | 消融证据 | Sec. 4.4、Table 3，PDF 11-12 |
| P2026-0159 | 参数分析显示 `G` 和 `rf` 较稳健，`NDE` 过大退化，`tau` 到 `0.012` 内较稳健 | 参数证据 | Sec. 4.5、Table 4，PDF 12-13 |
| P2026-0159 | 7 个真实 CMOP 上 ATMC 均取得最高 mean HV，SPWM 系列支持扩展性 | 真实问题支持 | Sec. 4.6、Table 5，PDF 13-14 |

## 证据边界

- 当前证据来自单篇论文，尽管 benchmark、消融和真实问题较完整，但尚无独立复现；
- HPS 的收益与 BDE、P3 archive、adaptive stopping 同时存在，单独迁移 HPS 时需要重新评估；
- 在极少数 CF 问题上 stage transition 未触发导致性能不占优，说明该架构依赖足够预算和合适切换条件；
- 真实工程问题只报告 HV，仍需补充分布、可行率和收敛分解指标。
