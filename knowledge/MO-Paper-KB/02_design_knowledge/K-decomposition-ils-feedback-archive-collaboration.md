---
knowledge_id: K-decomposition-ils-feedback-archive-collaboration
name: 分解 ILS 的反馈扰动与档案协作
type: architecture
status: active
source_papers: [P2026-0277]
aliases: [AMOILS/D, decomposition-based ILS, multiobjective iterated local search, adaptive perturbation degree, PBI distance feedback, archive collaborative acceptance, MO-HFVRP, 多目标 ILS, 分解局部搜索, 扰动度自适应, 档案协作接受]
promotion_reason: 单篇论文提出但接口完整，包含少量 scalar subproblems、ILS process pool、utility resource allocation、PBI/EMA perturbation degree control、local threshold acceptance、global archive indicator 和 archive-to-subproblem matching，可迁移到车辆路径、调度、装箱和其他可行域稀疏的多目标组合优化。
---

# 分解 ILS 的反馈扰动与档案协作

## 核心内容

把多目标组合优化分解为少量单目标子问题，每个子问题运行一个 Iterated Local Search。不同于普通均匀运行所有子问题，该框架用历史 scalar improvement 选择值得投入的子问题，用 objective-space distance 反馈调节每个 ILS 的扰动强度，并用 Pareto archive 既作接受判据又作跨子问题的优秀解共享池。

```text
MOCOP
-> few scalar subproblems
-> one ILS process per subproblem
-> utility-based resource allocation
-> perturbation + local search
-> objective-space distance updates perturbation degree
-> local threshold acceptance
-> global archive indicator and matching
-> approximated Pareto front
```

P2026-0277 的 AMOILS/D 是该模式的实例：它用 10 个 weighted-sum subproblems、每 20 代选择 3 个有潜力子问题，PBI-based distance 和 EMA 调节扰动节点数，局部阈值与 Pareto archive 协同决定 reference solution。

## 建立理由

- 为什么值得独立维护：
  - 很多 VRP、调度、装箱、分配类 MOCOP 已有强单目标 ILS/ALNS/VNS，但直接用普通 MOEA 往往可行性差；
  - decomposition 可以复用强单目标局部搜索器，archive 可以补偿单纯 scalarization 的 supported-solution 偏置；
  - resource、perturbation、acceptance 三个控制点接口清楚，可替换且可移植。
- 单篇具体方法的直接复用价值：
  - P2026-0277 给出 AMOILS/D Algorithm 2、constructive initialization、utility formula、PBI distance、EMA perturbation update、local/global acceptance、五类 MO-HFVRP benchmark 和多算法对比。
- 与已有设计知识的区别：
  - 不同于“成功率反馈的算子与参数自适应选择”：该知识根据 offspring 成功率选择算子/参数；本知识根据 objective-space history 调整子问题预算、ILS 扰动和接受。
  - 不同于“双空间分层自适应资源分配”：该知识面向连续/大规模 MOEA 的评价预算；本知识面向少量 MOCOP scalar subproblems 和 ILS processes。
  - 不同于“结构启发初始化与多目标路径重联”：该知识做初始化和精英路径局部搜索；本知识做分解式 ILS 的在线控制和档案协作。

## 解决的问题

- 适用场景：
  - 多目标组合优化可行解稀疏；
  - 已有强单目标局部搜索器；
  - 目标空间不同区域难度不均，均匀子问题预算低效；
  - 需要同时保留 convergence、diversity 和 unsupported efficient solutions。
- 现有方法为什么会失败或不足：
  - 普通 MOEA 交叉/变异在稀疏可行域中容易生成不可行解；
  - 大量 decomposition subproblems 在稀疏可行域中轨迹相似，造成冗余探索；
  - 固定 perturbation degree 难兼顾跳出 basin 和保护 building blocks；
  - 只按当前 scalar fitness 接受新解，会丢掉对其他子问题或全局 PF 有价值的解；
  - 过早/过频繁更新 archive 可能让搜索过于贪婪。
- 仍需解决的问题：
  - 多于两个目标时少量 subproblems 是否足够；
  - archive matching 是否会破坏各子问题已形成的局部结构；
  - objective-space distance 与 decision-space neighborhood 的对应关系可能不稳定；
  - 参数 `L,S,I,d_beta` 需要自动化。

## 为什么可能有效

```text
sparse feasible region favors local-search-based feasible moves
-> ILS jumps between feasible local optima
uneven objective space makes some subproblems harder
-> resource allocation focuses on improving subproblems
fixed perturbation is brittle
-> PBI distance feedback tunes jump size
scalarization can miss globally useful solutions
-> archive guides acceptance and cross-subproblem collaboration
```

关键假设是：单目标局部搜索器能在可行域中高效移动，objective-space history 能反映下一步搜索强度和资源分配需求。如果目标空间距离不能反映决策空间结构，或 archive 中解迁移到其他子问题后局部搜索难以继续改进，效果会下降。

## 如何用于算法创新

### 局部创新

- 把 utility selection 替换为 UCB、Thompson sampling、expected improvement 或 marginal HV contribution。
- 将 PBI-based distance 换成 normalized objective distance、local HV contribution、Tchebycheff residual 或 learned landscape distance。
- 对不同 subproblem 维护不同 perturbation degree、operator portfolio 和 acceptance threshold。
- Archive matching 加入 decision-space similarity 或 repair cost，避免跨子问题 reference solution 不兼容。
- 让 archive update interval 根据新非支配解率或 diversity loss 自适应，而不是固定 `I`。

### 结构创新

- MOCOP 通用框架：

```text
decomposition layer
single-objective local-search solver pool
resource controller
perturbation controller
archive-mediated collaboration layer
Pareto archive output
```

- 将 ILS 替换为 ALNS、VNS、LNS、tabu search 或 exact neighborhood solver。
- 在车辆路径、生产调度、装箱、设施选址和网络设计中复用已有单目标 solver，并通过 archive 层扩展到多目标。
- 与 preference-based search 结合：只为 ROI 附近 subproblems 分配更多 ILS 预算，archive 保留全局备选。

## 适用条件与风险

- 适用条件：
  - 有可行解生成器和可行局部搜索/修复算子；
  - 单目标 scalar subproblem 有意义；
  - 目标空间可计算稳定的 scalar improvement 和距离；
  - 非支配 archive 可维护在可接受规模；
  - 评价预算足以让每个 ILS process 形成历史反馈。
- 不适用或可能失效的条件：
  - 可行域稠密且普通 MOEA 已足够有效；
  - 局部搜索成本过高或邻域结构弱；
  - 目标强非凸且 supported solutions 很少，WS 子问题严重偏置；
  - 目标尺度变化大而缺少归一化，PBI/utility 失真；
  - Archive 太大，matching 和 dominance 检查成本过高。
- 计算与实现成本：
  - 需要维护每个 subproblem 的 reference solution、utility、perturbation degree 和 recent distance EMA；
  - 需要 Pareto archive、周期匹配和 dominance/score 查询；
  - 局部搜索器本身可能是主要计算瓶颈。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0277 | AMOILS/D 将 MO-HFVRP 分解成少量 WS subproblems，并为每个 subproblem 运行 ILS process | 作者提出的方法 | Sec. V-B，Algorithm 2，PDF 6-7 |
| P2026-0277 | 使用 utility-based 资源分配，每 20 代从 10 个 subproblems 中选 3 个 promising candidates | 作者提出的方法 | Sec. V-C，PDF 7 |
| P2026-0277 | 用 PBI-based distance 衡量新解和 reference solution 在目标空间中的距离，结合 EMA 更新 perturbation degree | 作者提出的方法 | Sec. V-D，PDF 7-8 |
| P2026-0277 | Local acceptance threshold 允许略差解被接受，提升每个 ILS process 的探索性 | 作者提出的方法 | Sec. V-E，PDF 8 |
| P2026-0277 | Global archive 既作接受 indicator，又在周期更新后为各 subproblem 匹配最合适 solution | 作者提出的方法 | Sec. V-E，PDF 8 |
| P2026-0277 | 8-customer 示例显示 HVRPFD/HVRPD feasible proportion 仅 0.04%，FSM 变体约 21.33%，支持稀疏可行域动机 | 问题分析证据 | Sec. IV-A，Tables II-III，PDF 4-5 |
| P2026-0277 | 随机可行目标向量显示 objective vectors 分布不均，接近 PF 的区域更稀疏 | 问题分析证据 | Sec. IV-A，Fig. 3，PDF 5 |
| P2026-0277 | AMOILS/D 在五类 MO-HFVRP 上相对 WS10A、TCH10A、WSPLS10A、WS100、NSGA-II、MOEA/D 整体排名最佳 | 综合实验支持 | Sec. VI-B，Tables IV-V，PDF 9-11 |
| P2026-0277 | ILS-based algorithms 平均排名优于 NSGA-II/MOEA/D，支持稀疏可行 VRP 中局部搜索主体更合适 | 算法路线证据 | Sec. VI-B，PDF 9-10 |
| P2026-0277 | WS10A 优于 TCH10A，WS10A 优于 WS100，说明 WS 和少量 subproblems 更适合该问题 | 组件选择证据 | Sec. VI-B，PDF 10-11 |
| P2026-0277 | 作者说明补充材料中 ablation studies 支持 AMOILS/D 各组件有效性 | 消融证据说明 | Sec. VII，PDF 11-12 |
| P2026-0277 | 作者未来工作包括更全面公平建模、扩展数据集和多目标 reproduction operators | 作者未来工作 | Sec. VII，PDF 12 |

## 待确认

- 多目标数增加时，少量 WS subproblems 与 archive 能否覆盖足够 trade-off；
- PBI distance 与实际 decision-space basin 距离之间的相关性；
- Archive matching 的收益和负迁移风险如何检测；
- 参数 `L,S,I,omega0,d_beta` 如何自动化或按实例特征设定；
- 该架构迁移到调度、装箱、选址等 MOCOP 时需要哪些问题特定局部搜索接口。
