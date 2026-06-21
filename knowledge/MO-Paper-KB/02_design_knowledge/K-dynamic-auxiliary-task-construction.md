---
knowledge_id: K-dynamic-auxiliary-task-construction
name: 动态辅助任务构造
type: method
status: active
source_papers: [P2026-0001, P2026-0190, P2026-0113]
aliases: [动态任务构造, dynamic auxiliary task construction, MOEMT/D, EQV, problem variant pool, dynamic auxiliary task dimension selection, cumulative contribution rate, SAEA-DHT, on-demand helper task, stage-aware helper task, convergence-diversity helper task, 动态辅助任务维度, 问题变体池, 累积贡献率, 按需辅助任务, 阶段感知辅助任务]
promotion_reason: 多篇论文支持的辅助任务动态化机制，能够根据当前搜索状态、历史贡献、变体维度收益或收敛/多样性阶段更新低维辅助任务，避免固定辅助任务与主任务阶段需求错配，可直接改造 EMTO、MFEA、MOEMT、大规模 problem transformation 和高维昂贵 SAEA 框架
---

# 动态辅助任务构造

## 核心内容

在使用辅助任务、低维子空间或简化问题协助主任务搜索时，不把辅助任务固定为初始化时的一组结构，而是让辅助任务随进化阶段和实际贡献变化。实现方式可以是每代根据主任务种群重新生成辅助任务，也可以预先构造多个不同维度的问题变体池，再根据这些变体通过知识迁移产生的有效 offspring 贡献，选择下一阶段最有用的辅助任务；在高维昂贵优化中，也可以根据真实评价档案判断当前更需要收敛还是多样性，从而切换 helper task 所保留的变量子集。

```text
主任务搜索状态 / 候选辅助任务池
-> 生成或选择若干辅助任务
-> 辅助任务与主任务协同优化
-> 记录辅助任务对主任务或其他任务的贡献
-> 更新辅助任务结构、维度或入选概率
-> 下一阶段继续协同搜索
```

P2026-0001 的路线是根据当前主任务种群动态构造低维辅助任务。P2026-0190 的路线是为同一个 LSMOP 维护多个不同维度的 problem variants，用累计贡献率选择当前最合适的辅助任务维度。P2026-0113 的路线是在高维 EMOP 中根据 HV/Con 阶段评估，在 convergence-critical variables 与 diversity-demand variables 之间构造 on-demand helper task，并通过跨维映射把 helper task 的非支配解转回原任务。

## 建立理由

- 为什么值得独立维护：固定辅助任务常只适合某个搜索阶段，早期需要粗粒度低维搜索，后期需要更精细或更宽的辅助空间；动态任务构造提供了可移植的辅助搜索控制层。
- 多篇论文共同支持：
  - P2026-0001 支持“根据当前主任务状态重新生成辅助任务”。
  - P2026-0190 支持“候选低维变体池 + 贡献反馈选择辅助任务维度”。
  - P2026-0113 支持“真实评价档案驱动的收敛/多样性阶段检测 + 按阶段选择 helper task 变量子集”，并把该思想用于高维昂贵 SAEA。
- 与已有设计知识的区别：
  - 不同于“参考解引导的跨任务知识迁移”：该知识回答迁移时用什么参考方向；本知识回答辅助任务本身何时生成、淘汰或调整。
  - 不同于“多邻域多知识的分解式多任务迁移”：该知识在已有多个任务之间路由知识；本知识可动态改变辅助任务集合或变体维度。
  - 不同于“动态参考解管理的问题变换”：该知识管理 problem transformation 的参考锚点；本知识管理辅助任务/低维变体的生命周期。

## 解决的问题

- 适用场景：
  - 主算法使用辅助任务、低维子空间、问题变换、变量分组或简化问题；
  - 不同搜索阶段对辅助任务粒度、维度或目标结构的需求不同；
  - 辅助任务可能从正迁移变为负迁移；
  - 希望在原始任务保持全局正确性的同时利用低维任务快速探索。
  - 高维昂贵 MOO 中真实评价预算少，完整空间代理不稳，需要低维 helper task 提高样本效率。
- 现有方法为什么会失败或不足：
  - 固定低维辅助任务可能在后期限制精细搜索和多样性。
  - 固定维度的问题变换可能丢失原始 LSMOP 的全局/近全局最优解。
  - 固定任务集合无法根据实际贡献淘汰低效辅助任务。
  - 全局 GD/HV 等指标通常评价整个 population，不适合直接归因到某个辅助任务。
  - 在高维 EMOP 中，固定变量子集可能只改善收敛或只改善多样性，无法跟随当前真实评价进展切换重点。
- 仍需解决的问题：
  - 如何评价辅助任务的长期贡献，而不是只看短期 offspring 存活；
  - 如何避免任务频繁更新破坏辅助任务积累的搜索信息；
  - 如何自动确定辅助任务数量、候选维度和更新频率；
  - 低维任务与高维主任务之间如何减少负迁移。

## 为什么可能有效

```text
当前种群和迁移后代反映搜索阶段需求
-> 动态调整辅助任务结构或维度
-> 早期偏向低维粗搜索以加速收敛
-> 后期引入更大/更精细的辅助空间维护多样性
-> 贡献差的任务被降低入选概率
-> 昂贵场景中只让当前阶段最有用的变量子集进入代理内搜索
-> 辅助搜索持续服务主任务当前需求
```

关键假设是：辅助任务的近期贡献、当前主任务种群结构或跨任务 offspring 存活情况能预测下一阶段的任务价值。若贡献评价噪声大、环境选择短期偏置强，动态选择可能误删长期有潜力的辅助任务。

## 实现接口

- 输入：
  - 主任务 population、目标值和可选的变量重要性/参考解；
  - 候选辅助任务生成器或候选变体池；
  - 跨任务迁移/共享机制；
  - 辅助任务贡献记录，如 offspring survival、archive improvement、HV/IGD contribution；
  - 辅助任务数量和更新周期。
  - 若是昂贵优化，还需要真实评价 archive、stage assessment 指标和 infill budget。
- 输出：
  - 当前阶段启用的辅助任务集合；
  - 每个候选任务的贡献分数或入选概率；
  - 可选的辅助任务维度、变量组、参考解或变换函数参数。
  - 可选的 transfer solutions、stage-specific infill candidates 和下一轮阶段标签。
- 插入位置：
  - EMTO/MFEA/MOEMT 的 task construction layer；
  - LSMOP problem transformation 的低维变体选择；
  - 多种群/多子空间算法的辅助搜索单元调度；
  - 代理辅助优化中的辅助模型/任务选择。
  - 高维 SAEA 的 helper task construction、cross-dimensional transfer 和 infill scheduling 层。

P2026-0190 的最小变体池实现：

```text
pool <- {problem_variant(d) for d in candidate_dimensions}
CR[idx] <- 1 for each idx in pool
active <- random_select(pool, K-1)

for each generation:
    optimize original task Task1
    build auxiliary populations for active variants
    O, Q <- multitask_variation_and_CKT(active, Task1)
    P <- environmental_selection(P union O)

    for each active task i:
        IR_i <- assist_count_i(P intersect Q) / |P intersect Q|
        CR[pool_index(i)] <- update(CR[pool_index(i)], IR_i)

    active <- roulette_select(pool, weights=CR, count=K-1)
```

P2026-0190 的具体设置：

- 原始任务为高维 LSMOP，辅助任务为 transformed low-dimensional variants；
- 候选池维度为 `1, 5, 10, 15, 20, 25, 50`；
- active auxiliary tasks 数为 4；
- 使用 weight optimization function `WO` 和 inverse function 做简化/重构；
- internal optimizer 为 NSGA-II；
- CKT 负责不同维度任务间的 knowledge transfer；
- `assist_count_i` 统计 cross-task transfer 产生并在环境选择后保留的 offspring。

P2026-0113 的最小 stage-aware helper task 实现：

```text
ArcN <- normalize(true-evaluated archive)
C1 <- first-rank solutions by nondominated sorting
C2 <- bottom-quarter rank solutions
v_dif <- abs(mean(C1.variables) - mean(C2.variables))
v_c, v_d <- split variables by descending v_dif

if Stage == convergence_urgent:
    helper_task <- optimize variables v_c
else:
    helper_task <- optimize variables v_d

Q, Qh <- surrogate_search(original_task, helper_task)
Th <- cross_dimensional_transfer(nondominated(Qh), Q)
Qf <- Q union Th
Inew <- stage_matched_infill(Qf, Arc, Stage)
true_evaluate(Inew)
Stage <- assess_by_HV_and_best_Con(Arc)
```

## 如何用于算法创新

### 局部创新

- 将固定辅助任务、固定变量组、固定低维变体替换为候选池 + 贡献反馈选择。
- 将固定低维 helper task 替换为 convergence/diversity stage-aware helper task。
- 用 offspring survival duration、HV contribution、IGD improvement、feasible archive improvement 或 predicted long-term utility 替代单代 `assist_count`。
- 候选维度池由搜索状态自动生成，例如根据变量重要性分布、有效维度估计或主种群收敛区间调整。
- 设置任务年龄和冷却时间，避免高噪声下频繁切换辅助任务。
- 对不同辅助任务分配不同评价预算，而不是只决定是否入选。
- 在昂贵优化中，用真实评价 archive 的 HV/Con 趋势或 surrogate uncertainty 判断阶段，避免只由代理预测驱动辅助任务切换。

### 结构创新

- 构建动态辅助任务控制器：

```text
task generator / variant pool
-> contribution estimator
-> task scheduler
-> cross-task transfer operator
-> main-task environmental selection
-> feedback update
```

- 与问题变换参考解管理结合：同时动态更新参考解锚点和辅助变体维度。
- 与跨任务知识路由结合：任务集合动态变化，迁移概率和迁移算子也根据任务贡献同步更新。
- 与代理辅助 LSMOP 结合：用低成本代理估计候选辅助任务潜力，只让高潜力任务进入真实评价协同。
- 与高维 SAEA 结合：把 stage sensor、helper-task generator、cross-dimensional transfer 和 stage-matched infill 组成独立控制层。

## 适用条件与风险

- 适用条件：
  - 辅助任务和主任务之间有可共享的表示、参考解或变换函数；
  - 辅助任务贡献可以被追踪到 offspring、archive 或主任务改进；
  - 不同搜索阶段确实需要不同辅助粒度；
  - 主任务仍保留原始空间搜索以避免低维变换丢失最优。
- 不适用或可能失效的条件：
  - 问题结构稳定，固定辅助任务已经足够；
  - 候选任务过多而评价预算不足；
  - 贡献度量短视，导致辅助任务被频繁误删；
  - 主任务与辅助任务表示差异太大，迁移算子无法可靠对齐；
  - 低维变体与原始高维可行/最优结构关系弱。
  - 阶段检测受小样本 archive、deceptive HV improvement 或 flat region 误导，导致长期选择错误 helper task。
- 计算与实现成本：
  - 需要维护候选任务池、贡献分数和任务调度；
  - 多辅助任务会增加环境选择、迁移和种群管理成本；
  - 若每次重新生成任务需要变量重要性分析，成本可能很高；
  - P2026-0190 的 CKT 还需要跨维分组和 least-squares mapping。
  - P2026-0113 需要同时训练原任务和 helper task 的 RBF，并执行跨维 mapping，内部运行时间可能高于更简单的 SAEA。
- 解释风险：
  - P2026-0190 的完整收益来自 EQV、CKT、MOEMT 框架和 problem transformation 的组合，不能把全部性能提升只归因于动态任务选择。
  - P2026-0001/P2026-0190 都主要在连续 LSMOP 或相关 benchmark 上验证，对离散、约束、昂贵问题仍需验证。
  - P2026-0113 的完整收益来自 on-demand helper task、cross-dimensional knowledge transfer、adaptive infill selection 和 RBF/NSGA-II+SDE 组合，不能只归因于辅助任务动态化。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0001 | 每代利用主任务种群重新生成低维辅助任务 | 作者提出的方法 | Algorithm 1-2，PDF 6-9 |
| P2026-0001 | 动态变量重要性辅助任务整体优于无辅助任务或固定任务对照 | 实验与消融支持 | PDF 20-27 |
| P2026-0001 | 变量重要性评价是主要计算成本，任务数量仍固定 | 复杂度分析与未来工作 | PDF 11、27-30 |
| P2026-0190 | MOEMT/D 初始化多个不同维度 problem variants，并从候选池中动态选择 `K-1` 个辅助任务 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 6-7 |
| P2026-0190 | EQV 用 cross-task transfer offspring 在环境选择后的存活贡献计算 `IR` 和累计贡献率 `CR` | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 7-8 |
| P2026-0190 | CKT 在不同维度低维表示之间生成高维 offspring，并用 least-squares mapping matrix 校准任务对应关系 | 作者提出的方法 | Sec. III-C，Algorithm 3-4，Fig. 2，PDF 8-9 |
| P2026-0190 | MOEMT_EQV 相比 MOEMT 在 72 个 LSMOP case 中 30 个显著更好，支持动态辅助维度选择 | 组件消融 | Sec. IV-B，Table II，PDF 10 |
| P2026-0190 | MOEMT_CKT 相比 MOEMT 在 72 个 case 中 29 个显著更好，完整 MOEMT/D 在 47 个 case 中更好 | 组件消融 | Sec. IV-B，Table II，PDF 10-11 |
| P2026-0190 | 二目标 LSMOP 中 MOEMT/D 相对 WOF、LSMOEA/PT、ALMOEA、LERD 在 45/45 个场景均更好 | 综合实验支持 | Sec. IV-C.1，Table III，PDF 11-12 |
| P2026-0190 | 三目标 LSMOP 中 MOEMT/D 相对 WOF、LSMOEA/PT、LERD 分别在 42、43、37 个场景更好 | 综合实验支持 | Sec. IV-C.2，Table IV，PDF 13 |
| P2026-0190 | NN 和 PO 真实问题中 MOEMT/D 获得最优 HV 和更好的解集分布 | 真实应用支持 | Sec. IV-D，Table V，Fig. 6，PDF 14 |
| P2026-0190 | 作者未来工作包括更细粒度贡献度量、更自适应降维/变换和嵌入其他 EMTO 框架 | 作者局限 | Sec. V，PDF 14-15 |
| P2026-0113 | SAEA-DHT 根据 `Arc` 中 first-rank 与 bottom-quarter 解的变量均值差，把变量二分为 convergence-related `v_c` 和 diversity-related `v_d` | 作者提出/采用的方法 | Sec. 3.2，Algorithm 2，PDF 5-6 |
| P2026-0113 | 当前阶段为 convergence urgent 时 helper task 使用 `v_c`，diversity demand 时使用 `v_d`，阶段由 HV improvement 与 best `Con` 共同判断 | 作者提出的方法 | Sec. 3.2、3.6，PDF 5、8 |
| P2026-0113 | Helper task 和 original task 分别用 RBF + NSGA-II+SDE 代理搜索，helper task 非支配解经 distribution alignment 与 fitness-rank matching 映射回原任务 | 作者提出/集成方法 | Sec. 3.3-3.4，Algorithm 3-4，PDF 6-7 |
| P2026-0113 | 无 on-demand helper task 变体 SAEA-DHT-V1 在 100 维 DTLZ/MaF 上相对完整 SAEA-DHT 为 `0/6/8`，支持动态 helper task 的贡献 | 消融实验支持 | Sec. 4.2.1，Table 1，PDF 12 |
| P2026-0113 | Stage switching 与触发条件在 DTLZ1-DTLZ7 上平均相关系数为 `0.5263` 到 `0.7062`，作者认为体现 on-demand 行为 | 机制分析支持 | Sec. 4.2.1，Table 2，PDF 12 |
| P2026-0113 | SAEA-DHT 在 200 维三目标 MaF 上 6/7 个 IGD 最佳，并在 TREE1/3/4/5 上取得最高 HV | 综合与应用证据 | Sec. 4.3.2、4.4，Tables 20、24，PDF 19、22 |
| P2026-0113 | 作者指出变量提取更适合可分问题，强耦合变量、线性跨维映射、RBF 过拟合/噪声和阶段误判仍是主要局限 | 作者局限 | Sec. 5.2，PDF 22-23 |

## 证据边界

- P2026-0001 的卡片早期证据较简略，部分细节需回原文核对。
- P2026-0190 主文表格多为图片占位，精确数值需回 PDF 或 supplementary。
- P2026-0190 候选维度池、辅助任务数、内部优化器等仍是人工设置。
- 对简单 separable landscape，复杂动态辅助任务框架可能不如更轻的算法划算。
- 证据主要覆盖连续 LSMOP 与高维 EMOP；约束、离散、动态、噪声和多保真场景仍需额外验证。
- P2026-0113 的 helper task 变量二分比例固定，且跨维 mapping 为线性假设；复杂非线性强耦合变量下可能失效。

## 待确认

- 如何同时估计短期贡献和长期潜力；
- 辅助任务数量、维度池和更新频率如何自动调节；
- 如何防止动态任务切换导致知识积累中断；
- 贡献反馈是否应按目标空间区域、变量组或参考向量分区；
- 动态辅助任务与动态迁移算子、动态参考解、动态评价预算如何联合控制。
- 在昂贵优化中如何让 stage detection 使用长窗口趋势和不确定性，避免 deceptive HV improvement 造成持续错配。
