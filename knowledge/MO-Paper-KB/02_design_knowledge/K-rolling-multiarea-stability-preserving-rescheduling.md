---
knowledge_id: K-rolling-multiarea-stability-preserving-rescheduling
name: 滚动多区域稳定保持重调度
type: architecture
status: active
source_papers: [P2026-0050]
aliases: [RMAJ-LR, rolling multi-area joint local rescheduling, MAJSS, LAT MAT RAT rescheduling, stability-efficient rescheduling, dynamic flight test task scheduling, Task-Aircraft Deviation, Task Order Deviation, Aircraft Completion Time, 滚动多区域重调度, 稳定性重调度, 局部区域扩张]
promotion_reason: 单篇论文提出但接口完整，包含稳定性-效率目标、LAT/MAT/RAT 区域语义、依赖驱动最小扩张、多区域联合搜索、区域尺度连续谱和问题驱动阶段式算子，可迁移到制造、试验、机场、维修、卫星和应急任务等动态重调度场景。
---

# 滚动多区域稳定保持重调度

## 核心内容

该知识把动态重调度中的任务分成三类区域：已经稳定且不再改变的左区、需要重新优化的中区、保持原相对结构并右移的右区。中区不是一次性固定，也不是直接扩到全部未完成任务，而是按任务依赖和扰动传播逐步扩张。多个不同大小的中区分别求解，再合并为 Pareto 重调度方案。

```text
baseline schedule + dynamic event
-> classify tasks by execution state, activation and disruption
-> LATs: fixed stable tasks
-> MATs: reschedulable affected/activated tasks
-> RATs: right-shifted future tasks
-> dependency-driven area expansion
-> solve several MAT sizes as single-area subproblems
-> merge nondominated solutions across areas
-> choose stability-efficiency Pareto rescheduling plans
```

核心不是“局部重调度”本身，而是把局部范围做成可滚动、可扩张、可多尺度合并的策略空间。这样可以在 RSR 的稳定性和 CR 的全局性之间形成连续折中。

## 建立理由

- 为什么值得独立维护：
  - 动态重调度常在全量重排和局部修复之间二选一，前者扰动大且慢，后者易忽略下游影响。
  - 许多调度场景的稳定性成本来自任务分配变化和任务顺序变化，需要显式建模，而不是只看完成时间。
  - 中区大小决定了稳定性、效率和计算成本；把多个中区尺度合并，能自然输出 Pareto 折中。
  - 区域策略可作为 wrapper，内部求解器可以是 MOEA、CP-SAT、MIP、LNS 或启发式。
- 单篇具体方法的直接复用价值：
  - P2026-0050 给出 DFTTS 的 TAD/TOD/ACT 三目标模型、RMAJ-LR 的 AD/AE/MAJSS、MOEA-MSOS 的 AGS/TRAS/TORS，以及 80 任务和 581 任务试飞案例。
- 与已有设计知识的区别：
  - 不同于“故障子问题辅助的双种群协同重调度”：后者把扰动影响子问题作为辅助种群并和主种群迁移；本知识通过 LAT/MAT/RAT 和多尺度区域控制重调度范围，可用任意求解器。
  - 不同于“右移-调速协同节能解码”：后者利用 right-shift 和 speed scaling 做能耗后处理；本知识用 right-shift 保持未来任务稳定，并把中区优化作为核心。
  - 不同于一般 rolling horizon：本知识的窗口由任务激活和依赖传播扩张，并合并多个区域尺度，而不是固定时间窗逐段滚动。
  - 不同于普通局部搜索：本知识明确保留 left/right 区语义，用区域尺度控制计划扰动与计算成本。

## 解决的问题

- 适用场景：
  - 已有 baseline schedule，动态事件导致部分任务不可按原计划执行；
  - 任务之间有 precedence、resource eligibility、time window 或其他依赖；
  - 决策者既关心完成时间，也关心保持原计划稳定；
  - 全量重排太慢或扰动太大，单一区域局部修复又可能缺少全局性；
  - 可以定义“已稳定任务”“受扰动/已激活任务”“未来右移任务”的边界。
- 现有方法为什么会失败或不足：
  - RSR 对稳定性友好，但可能把所有后续任务整体推迟，效率低；
  - CR 搜索空间最大，计算慢且会产生大量不必要变动；
  - LR 的 rescheduling window 若过小，无法吸收依赖传播；若过大，又接近 CR；
  - 固定窗口 rolling horizon 不知道哪些后继任务因依赖被激活；
  - 单目标加权会把稳定性和效率压成一个偏好点，难给调度员选择。
- 仍需解决的问题：
  - 如何自动估计扰动传播深度和选择中区尺度；
  - 如何在多次连续扰动下防止右区不断漂移；
  - 如何把人类调度员偏好嵌入 Pareto 解选择；
  - 如何把更多真实资源约束纳入区域扩张和求解器接口。

## 为什么可能有效

```text
dynamic event affects a local frontier first
-> freeze tasks already stable or safely executing
-> optimize only affected and newly activated tasks
-> right-shift distant future tasks to preserve plan structure
-> expand middle area only when dependencies require it
-> solve multiple middle-area sizes
-> smaller areas give stability and speed
-> larger areas recover efficiency
-> merged solutions approximate the stability-efficiency tradeoff
```

有效性的关键假设是：扰动影响可以通过任务依赖和执行状态逐步传播，而不必一开始就重排全部任务。多个中区尺度提供了不同扰动半径的候选解，Pareto 选择再决定哪些尺度值得保留。

## 如何用于算法创新

### 局部创新

- 用关键路径 slack、资源冲突传播、graph reachability 或仿真 sensitivity 替代简单 Task Activation。
- 根据实时预算自适应设定 `x,y,z`：预算紧时少 SA、小扩张；扰动严重时多 SA、大扩张。
- 对 LAT/RAT 加软约束：允许少量高收益变动，但引入稳定性罚项或审批成本。
- 在 MATs 内使用 CP-SAT/LNS/MIP，外层用 Pareto selection 合并多区域结果。
- 为每次 Area Expansion 训练收益预测器，跳过预计无收益的扩张。

### 结构创新

- 构建多尺度动态调度框架：

```text
event detection
-> affected-frontier extraction
-> multi-scale rescheduling areas
-> heterogeneous solvers per area
-> nondominated merge
-> operator or human preference selection
-> deploy and update baseline
```

- 与双种群重调度结合：每个 MATs 作为一个辅助子问题，主种群负责合并不同区域修复候选。
- 与鲁棒调度结合：RAT 不只是右移，还可插入 buffer 或保留备用资源，防止后续扰动。
- 与交互式 MOO 结合：让调度员设定最大 TAD/TOD 或最小 ACT aspiration，快速筛选 Pareto 解。
- 与数字孪生结合：用实时执行状态、飞机健康状态和天气窗口持续更新 LAT/MAT/RAT。

## 适用条件与风险

- 适用条件：
  - 有 baseline schedule 和可追踪的任务执行状态；
  - 可识别动态事件和受影响任务；
  - 任务依赖或资源可行性可以驱动区域扩张；
  - 稳定性可被任务分配变化、顺序变化、时间偏移或其他指标量化；
  - 中区子问题能被可用优化器在有限时间内求解。
- 不适用或可能失效的条件：
  - 扰动直接影响全系统，几乎所有任务都必须重新优化；
  - 任务依赖过密，少量扩张很快覆盖全部任务；
  - baseline schedule 本身质量很差，保持稳定反而固化低质量结构；
  - 稳定性指标与真实协调成本不一致；
  - 连续扰动频率高于优化响应速度。
- 计算与实现成本：
  - 需要维护任务状态、依赖图、可执行资源集合和 baseline schedule；
  - 多个 SA 会增加总求解次数，必须通过 `z` 或并行计算控制成本；
  - 大规模任务下，中区扩大后 MOEA 评价和环境选择仍会变慢；
  - 实际部署需要解释每个方案改动了哪些任务和为什么改动。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0050 | DFTTS 中动态事件包括 aircraft malfunctions、new task insertions 和 task re-executions | 问题定义 | Sec. 3.2，PDF 4 |
| P2026-0050 | 三目标为 TAD、TOD、ACT，分别对应任务-飞机分配稳定性、任务顺序稳定性和完成时间效率 | 多目标建模 | Sec. 3.3，PDF 4 |
| P2026-0050 | RMAJ-LR 将任务划分为 LATs、MATs、RATs，对应 unchanged、rescheduled、right-shifted tasks | 作者提出的方法 | Sec. 4.1，PDF 5 |
| P2026-0050 | AD 结合 rolling window、Task Activation 和动态事件类型确定初始区域 | 区域划分 | Sec. 4.2 |
| P2026-0050 | AE 依据新激活后继任务最小扩张 MATs，并收缩 RATs；作者强调不是最大化重调度范围 | 区域扩张 | Sec. 4.3、Algorithm 1，PDF 6 |
| P2026-0050 | MAJSS 通过多个 SA 求解不同 MATs 尺度，并合并成 best rescheduling set | 多区域搜索 | Sec. 4.4、Algorithm 2，PDF 6-7 |
| P2026-0050 | 参数 `x,y,z` 控制 SA 数量、每个 SA 扩张次数和每个 SA 迭代数；`y=0` 近似 RSR，`y -> infinity` 近似 CR | 策略连续谱 | Sec. 4.4 |
| P2026-0050 | MOEA-MSOS 用 AGS、TRAS、TORS 分别面向 ACT、TAD、TOD 设计阶段式优化策略 | 求解器配套 | Sec. 5.3，PDF 8-9 |
| P2026-0050 | 主实验为 80 个 flight tasks，population 50、crossover 0.7、mutation 0.5、100 iterations，20 次独立运行 | 实验设置 | Sec. 6.2，PDF 10 |
| P2026-0050 | RMAJ-LR MA1 相对 CR 将 HV 从 `8.97e-01` 提升到 `9.76e-01`，IGD 从 `4.20e-03` 降到 `1.31e-03`，time 从 `31.70s` 降到 `24.23s` | RMAJ-LR 性能证据 | Table 2，PDF 10 |
| P2026-0050 | RSR 保持 `TAD=0`、`TOD=0`，但 ACT 达 `1538.00`，显示纯右移稳定但效率差 | 基线机制证据 | Table 2 |
| P2026-0050 | MA4 仍优于所有 SAs 的 convergence，且 `x*y` 增大时 RMAJ-LR 越接近 CR，性能和多样性变差 | MAJSS 机制证据 | Sec. 6.2.2、Table 3 |
| P2026-0050 | SA 任务数从 7 增至 65 时，计算时间从 `21.43s` 增到 `31.70s` | 区域规模成本 | Table 4，PDF 14 |
| P2026-0050 | MOEA-MSOS 在 SA6 下 HV `8.97e-01`，显著优于 NSGA-II、NSGA-III、MODE 的 `4.05e-01/3.93e-01/3.59e-01` | 配套算法证据 | Table 5，PDF 16 |
| P2026-0050 | 消融中 no AGS/no TRAS/no TORS 的 HV 均低于完整 MOEA-MSOS，IGD 也显著变差 | 算子消融 | Table 8，PDF 17 |
| P2026-0050 | 新任务插入、任务返工、三类扰动同时发生时，RMAJ-LR 在 HV/IGD/SP 或 TAD/TOD/ACT 上总体优于 CR，且时间更低 | 多扰动验证 | Table 11-13，PDF 20 |
| P2026-0050 | 真实 581 tasks、5 aircraft 大案例中，CR time 为 `1732.50s`，RMAJ-LR 多个 MA 在 HV/IGD 更优且 time 为 `1022.74-1398.92s` | 大规模案例 | Sec. 6.5.2、Table 14，PDF 21 |
| P2026-0050 | 作者局限指出当前未包含 time windows、task combinability、aircraft load、fuel consumption、crew availability，且真实扰动可能更复杂 | 证据边界 | Sec. 7，PDF 20 |

## 待确认

- 区域扩张参数如何自动适配扰动严重度、实时算力和任务依赖密度；
- TAD/TOD 是否需要按任务关键度、团队协调成本、风险等级加权；
- 多次连续扰动下 baseline 如何更新，是否会积累 right-shift 延迟；
- 当中区由多个不连通扰动簇组成时，是否应拆成多个子区域并行求解；
- 如何把 Pareto 重调度方案解释成调度员可快速审阅的任务改动清单。
