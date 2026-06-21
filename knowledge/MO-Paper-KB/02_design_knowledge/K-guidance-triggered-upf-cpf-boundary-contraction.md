---
knowledge_id: K-guidance-triggered-upf-cpf-boundary-contraction
name: 指导失效触发的 UPF-CPF 约束边界收缩
type: architecture
status: active
source_papers: [P2026-0029]
aliases: [VCGDPEA, variable constraint guidance, guidance failure switching, adaptive stage switching, adaptive constraint boundary contraction, UPF guidance, CPF exploitation, Pop1 Pop2 CMOEA, 辅助种群指导失效, 约束边界收缩, UPF到CPF切换, 可变约束引导]
promotion_reason: P2026-0029 单篇提出但接口完整：主种群 `Pop1` 始终用 CDP 搜索 CPF，辅助种群 `Pop2` 先无约束搜索 UPF；通过收敛停滞、连续指导失败和 `Pop2` 非支配比例判断 UPF 信息是否仍能指导主种群；切换后用快速下降的 constraint boundary `VAR` 让 `Pop2` 从 UPF 区域收缩到 CPF 附近。该机制可直接改造双种群/多任务 CMOEA 的辅助任务停止、降权和约束收缩模块。
---

# 指导失效触发的 UPF-CPF 约束边界收缩

## 核心内容

在 constrained MOO 中，不让辅助种群无限期追逐 unconstrained Pareto front (UPF)，也不按固定代数切换到 constrained Pareto front (CPF)。先让辅助种群无约束探索 UPF，为主种群提供跨越不可行区的全局方向；同时在线审计辅助种群是否仍在指导主种群。当辅助种群自身已停滞、连续多代不能让主种群排名受益，或 UPF 已基本形成但对主种群贡献下降时，触发阶段切换。切换后，辅助种群不再无约束搜索，而是在一个快速收缩的约束边界 `VAR` 内选择个体，逐步从 UPF 区域靠近 CPF。

```text
Pop1: CPF search with CDP
Pop2: auxiliary UPF search without constraints

stage 1:
    Pop2 explores UPF and exchanges offspring with Pop1
    monitor Pop2 convergence and Pop2->Pop1 guidance success

if guidance stops or fails:
    switch to stage 2

stage 2:
    VAR starts from average CV and rapidly contracts
    Pop2 selects CV <= VAR first, CV as extra objective when needed
    Pop2 now guides Pop1 near CPF instead of staying on UPF
```

P2026-0029 的 VCGDPEA 是该模式的实例：`Pop1` 使用 CDP，`Pop2` Stage 1 无约束选择，Stage 2 用 constraint boundary contraction；Stage 1 中主种群规模减半，Stage 2 两群同规模并分别采用 DE/current-to-pbest/1 与 DE/rand/1。

## 建立理由

- 为什么值得独立维护：
  - UPF 对 CPF 的帮助依赖问题类型，固定追 UPF 会在 Type IV 问题上浪费大量评价；
  - 固定阶段切换难处理 Type I-III 和 Type IV 的不同需求；
  - 辅助种群是否还在产生指导价值，应由当前搜索证据决定；
  - 快速边界收缩让辅助种群从“无约束探索者”平滑变成“CPF 近邻探索者”；
  - P2026-0029 给出 Algorithm 1、Subalgorithm 2-4、`VAR` 收缩、47 benchmark、4 real-world CMOP、消融和敏感性证据。
- 与已有设计知识的区别：
  - 不同于“UPF/SPF 奖励双种群约束搜索”：该知识维护 PFPop/BPop 两个约束处理专家，并用 archive reward 调度主导权；本知识只有一个 UPF 辅助种群，核心是监测 `Pop2` 对 `Pop1` 的指导失效并触发约束边界收缩。
  - 不同于“支配-分解双框架协同与阶段切换”：该知识按 dominance/decomposition 两个算法框架分工，并用聚合值稳定判断 decomposition population 转 CPF；本知识按主/辅角色分工，判断依据是辅助群对主群的指导情况。
  - 不同于“动态聚类限域的竞争群约束搜索”：该知识在 CSO 中动态限制 winner-loser 学习范围；本知识不聚类主群，而是调整辅助群的约束强度和阶段。
  - 不同于“动态辅助种群多样性增强的约束协同进化”：该知识线性缩减辅助群和多样性档案；本知识不按时间线性缩减，而按指导失效事件切换。
  - 不同于“分位数阶段约束分配与边界迁移”：该知识按约束违反分位数分配主/辅任务；本知识用全局 `VAR` 收缩和指导失败诊断控制 UPF-to-CPF 过渡。

## 解决的问题

- 适用场景：
  - CMOP 可行域被大不可行区包围或分裂；
  - UPF 早期可能提供目标方向，但与 CPF 关系未知；
  - 维护一个主种群和一个辅助种群的评价预算可接受；
  - 希望避免辅助无约束搜索长期浪费；
  - 需要在不同 CMOP 类型中自动决定 UPF 搜索深度。
- 现有方法为什么会失败或不足：
  - CDP 主群容易困在局部可行域；
  - 无约束辅助群长期追 UPF，在 UPF 与 CPF 无关时会误导或浪费；
  - 慢速约束边界收缩让辅助群长期停在 UPF-CPF 之间；
  - 固定迭代切换不能感知辅助信息是否已经失效；
  - 单纯收缩辅助群规模不能改变辅助群搜索目标。
- 仍需解决的问题：
  - 指导失败指标可能受短期随机波动影响；
  - `VAR` 收缩速度对不同约束拓扑可能需要局部自适应；
  - many-objective 下 CDP 和非支配比例判断都会变弱；
  - 大规模决策空间中没有专门变量分组、代理或降维模块。

## 为什么可能有效

```text
early CMOP search needs global objective direction
-> Pop2 ignores constraints and approaches UPF
-> Pop1 can receive infeasible but useful directions

UPF may stop helping Pop1
-> monitor convergence stop and guidance failure
-> stop detailed UPF exploration when evidence says it is unhelpful

after switching, Pop2 should not disappear
-> shrink constraint boundary VAR
-> keep near-boundary infeasible/low-CV solutions
-> guide Pop1 around CPF with more relevant information
```

关键假设是：`Pop2` 的 UPF 搜索在早期能提供方向信息，而 `Pop2` 与 `Pop1` 的首层解相对排名、可行比例和非支配比例足以反映指导是否有效。如果 UPF 信息贡献是区域性的，或者某些 CPF 片段需要长期 UPF 辅助，全局一次切换可能过早或过晚。

## 实现接口

- 输入：
  - 原始 objectives 和 constraints；
  - `Pop1`、`Pop2` 及二者 objective、CV、rank、feasibility；
  - CDP comparator；
  - unconstrained nondominated/sorted selection；
  - `VAR` boundary schedule；
  - stage switching thresholds `alpha1`、`lambda1`、`lambda2`、`delta_c`。
- 输出：
  - Stage state；
  - `Pop1` CPF approximation；
  - `Pop2` UPF/near-CPF auxiliary population；
  - guidance failure diagnostics；
  - boundary contraction trace。
- 插入位置：
  - 双种群 CMOEA 的辅助任务控制层；
  - 多任务 CMOP 的 auxiliary task early-stop / shrink layer；
  - UPF/SPF/relaxed-constraint 辅助群的资源调度层；
  - constrained surrogate-assisted MOO 的 low-CV candidate filtering 层。
- P2026-0029 默认实例：
  - `NP=100`；
  - LIRCMOP `MaxFEs=200000`，其它 benchmark 和 real-world problems `MaxFEs=100000`；
  - `CRset=[0.1,0.2,1.0]`；
  - `Fset=[0.6,0.8,1.0]`；
  - `alpha1=0.8`；
  - `lambda1=0.05`；
  - `lambda2=0.3`；
  - 每个问题独立运行 30 次。
- 最小实现：

```text
initialize Pop1, Pop2
stage <- 1

while FEs < MaxFEs:
    update_stage_by_guidance_diagnostics(Pop1, Pop2)

    if stage == 1:
        Off1 <- GA(Pop1, n=NP/2)
        Off2 <- mixed_GA_DE_unconstrained(Pop2, n=NP)
        Pop1 <- CDP_select(Pop1 union Off1 union Off2, NP)
        Pop2 <- unconstrained_select(Pop2 union Off2 union Off1, NP)

    else:
        Off1 <- DE_current_to_pbest(Pop1, n=NP)
        Off2 <- DE_rand_1(Pop2, n=NP)
        Pop1 <- CDP_select(Pop1 union Off1 union Off2, NP)
        VAR <- shrink_boundary(CV0, FEs, startFE, MaxFEs)
        MP1 <- {x in Pop2 union Off2 union Off1 | CV(x) <= VAR}
        MP2 <- remaining
        Pop2 <- boundary_select(MP1, MP2, NP)

return Pop1
```

## 如何用于算法创新

### 局部创新

- 将指导失败从 rank/proportion 替换为主种群 archive 的 HV contribution 或 reference-vector coverage gain。
- 给每个 reference vector 或 objective-space region 独立维护 guidance failure 计数，实现区域级切换。
- 将 `VAR` 设为分位数边界，例如当前低 CV 个体的 `q`-quantile，而非全局固定曲线。
- 在 Type I-III 迹象明显时保留小比例无约束 UPF 子群，避免过早失去远端 CPF 方向。
- 把 CDP 替换为 indicator-based feasible selection，改善 many-objective 退化。

### 结构创新

- Auxiliary contribution auditor：

```text
auxiliary population / task
-> measure contribution to main population
-> if contribution positive: keep or increase budget
-> if contribution weak: shrink constraint boundary
-> if contribution negative: stop transfer or reset
```

- 多辅助任务扩展：UPF、各 SPF、relaxed constraint subsets 都独立审计指导贡献，形成任务级状态机。
- 与代理辅助优化结合：若辅助群候选只在 surrogate 上有益而真实评价无益，降低 transfer 权重。
- 与动态 CMOP 结合：环境变化后短期放宽 `VAR`，重新允许 UPF 辅助跨越新不可行区。
- 与大规模 CMOP 结合：在 Stage 1 只对重要变量做主群 CDP 搜索，辅助群负责全变量目标方向探索。

## 适用条件与风险

- 适用条件：
  - UPF 至少可能在早期提供有用方向；
  - 可计算主/辅种群可行比例、非支配比例和合并首层排名；
  - 有足够评价预算维护两个种群；
  - 约束违反度可标量化并用于边界 `VAR`；
  - 主输出由 `Pop1` 负责，辅助群可阶段性改变目标。
- 不适用或可能失效的条件：
  - UPF 与 CPF 完全无关且早期指导也有害；
  - CPF 由多个区域组成，而全局阶段切换会忽略局部差异；
  - many-objective 中非支配比例接近饱和，指导判断失真；
  - 约束违反值尺度极不均，平均 `CV0` 不适合作为边界起点；
  - 高维问题中没有变量分组或降维，双种群评价成本仍高。
- 计算与实现成本：
  - 需要维护两个 `NP` 规模种群；
  - Stage 1 每轮约 `1.5*NP` 评价，Stage 2 每轮约 `2*NP` 评价；
  - 需要额外计算非支配排序、CDP、可行比例和指导失败指标；
  - 相比单种群 CMOEA，内存和选择成本更高，但可减少无效 UPF 搜索。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0029 | VCGDPEA 维护 `Pop1` 和 `Pop2`，`Pop1` 主要搜索 CPF，`Pop2` 用 infeasible/UPF 信息引导 `Pop1` | 框架设计 | Sec. 3.1 / Algorithm 1 |
| P2026-0029 | Stage 1 中 `Pop2` 不考虑约束搜索 UPF，`Pop1` 用 `NP/2` offspring 减少早期约束搜索资源 | 阶段分工 | Sec. 3.1 / Subalgorithm 2 |
| P2026-0029 | Stage 2 中 `Pop1` 用 DE/current-to-pbest/1 开发，`Pop2` 用 DE/rand/1 提供方向 | 算子分工 | Sec. 3.1 / Subalgorithm 3 |
| P2026-0029 | `VAR` 在 Stage 1 保持 `CV0`，Stage 2 快速下降，比 MTCMO 的收缩更快 | 边界收缩 | Sec. 3.2 / Fig. 4 |
| P2026-0029 | `CV <= VAR` 个体进入 `MP1`，若 `MP1` 过多则 CV 作为额外目标参与选择 | 边界选择 | Sec. 3.2 |
| P2026-0029 | Stage switching 使用 `Pop2` 收敛停滞、连续指导失败、`Pop2` 非支配比例等三类条件 | 阶段切换 | Sec. 3.3 / Subalgorithm 4 |
| P2026-0029 | LIRCMOP1 和 LIRCMOP12 可视化显示 VCGDPEA 比 CAEAD/IMTCMO 更快调整辅助搜索方向 | 过程证据 | Sec. 3.4 / Fig. 5-10 |
| P2026-0029 | 比较 10 个 CMOEA：CMOEAD、NSGA-III、C3M、MSCEA、CAEAD、BiCo、URCMO、IMTCMO、MCCMO、APSEA | 实验设置 | Sec. 4 |
| P2026-0029 | 47 个 benchmark 包括 LIRCMOP、MW、CF、DASCMOP，独立运行 30 次，指标为 IGD/HV | 实验设置 | Sec. 4 |
| P2026-0029 | `NP=100`，LIRCMOP 最大评价 200000，其它 benchmark 和真实问题 100000 | 参数设置 | Sec. 4 |
| P2026-0029 | 多问题 Wilcoxon test 中所有 `p` 值低于 0.05 且 `R+ > R-`，Friedman test 中 VCGDPEA 平均排名最小 | 统计证据 | Sec. 4.3 |
| P2026-0029 | 50/100 维 LIRCMOP 和 DASCMOP 扩展实验显示 VCGDPEA 在高维 CMOP 上仍有强竞争力 | 高维证据 | Sec. 4.4 |
| P2026-0029 | 五目标 ZXH_CF 中 VCGDPEA 性能下降，弱于 CMOEAD、MSCEA、MCCMO、APSEA | 证据边界 | Sec. 4.5 |
| P2026-0029 | 四个真实 CMOP 中 VCGDPEA 的 HV 最大或相近，包括 batch plant、flow sheeting、two-reactor、power distribution planning | 真实问题 | Sec. 4.6 |
| P2026-0029 | 消融中 VCGDPEA 的 Friedman ranking 最小，IGD 为 1.8085，HV 为 1.9043 | 消融证据 | Sec. 4.7.1 / Table 15 |
| P2026-0029 | VCGDPEA-VAR 对比为 `2/23/22`，支持本文边界收缩策略 | 边界消融 | Sec. 4.7.2 / Table 16 |
| P2026-0029 | GA-only 和 DE-only 变体多数问题不如 VCGDPEA，支持 stage-specific hybrid strategy | 算子消融 | Sec. 4.7.3 / Table 17 |
| P2026-0029 | `NP`、`Pm`、`alpha`、`lambda1`、`lambda2` 敏感性分析显示性能不敏感 | 参数边界 | Sec. 4.8 |
| P2026-0029 | 作者承认 large-scale CMOP 和 many-objective CMOP 上存在性能下降 | 局限 | Sec. 5 |
| P2026-0029 | Data availability 为数据可按请求提供 | 数据可得性 | Data availability |

## 证据边界

- 当前直接证据来自 P2026-0029 一篇论文。
- 公式多处以图片省略，`VAR` 具体函数和指导失败指标细节需用 PDF 或代码复核。
- Many-objective CMOP 上性能下降，说明 CDP 和非支配比例判断存在扩展风险。
- 作者明确承认缺少 large-scale CMOP 专用策略。
- Stage switching 是全局一次切换，未验证局部/区域级切换是否更优。
- 真实问题覆盖 4 个经典工程 CMOP，但动态、昂贵评价和混合离散约束仍需验证。

## 待确认

- 指导失败是否应直接用主种群 archive improvement 定义；
- `VAR` 边界应全局收缩还是按 constraint / region / reference vector 分别收缩；
- Stage 1 主种群规模缩减是否适合所有约束强度；
- 替换 CDP 后 many-objective 表现能否改善且不破坏阶段切换；
- 在大规模 CMOP 中应与变量分组、代理模型还是稀疏搜索模块组合。
