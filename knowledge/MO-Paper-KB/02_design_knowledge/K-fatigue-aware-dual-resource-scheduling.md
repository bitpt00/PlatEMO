---
knowledge_id: K-fatigue-aware-dual-resource-scheduling
name: 疲劳感知的机器-工人双资源调度建模
type: architecture
status: active
source_papers: [P2026-0273]
aliases: [FJSP-WF-DRC, human-aware FJSP, worker fatigue scheduling, dual resource job shop, HRV NASA-TLX fatigue model, fatigue Gini objective, 人因调度, 工人疲劳调度, 机器工人双资源, 疲劳公平]
promotion_reason: 单篇论文提出但建模接口完整，包含机器-工人双资源兼容约束、工序-机器-工人三段编码、HRV 与 NASA-TLX 复合疲劳系数、非线性疲劳恢复/累积、疲劳阈值和 Gini 疲劳均衡目标，可迁移到人因车间调度、装配、维修和动态重调度。
---

# 疲劳感知的机器-工人双资源调度建模

## 核心内容

在人因制造调度中，不只为每道工序选择机器，还要选择具备技能的工人，并显式模拟工人在作业中的疲劳累积和空闲时的恢复。每个调度解同时包含 operation sequence、machine assignment 和 worker assignment；解码时按时间推进，计算每名工人的开始疲劳、结束疲劳、休息恢复和疲劳安全阈值。目标除了 makespan 和 total cost，还加入 worker fatigue imbalance，例如最终疲劳水平的 Gini coefficient。

```text
jobs and operations
-> choose feasible machine-worker pair for each operation
-> decode schedule with precedence, machine and worker exclusivity
-> compute fatigue coefficient from task intensity + HRV + NASA-TLX
-> propagate fatigue accumulation and recovery over time
-> enforce fatigue threshold / minimum rest
-> optimize Cmax, cost and fatigue imbalance
```

P2026-0273 的 FJSP-WF-DRC 是该模式的实例：每个解编码为 `(J,M,W)`，疲劳系数由作业强度、HRV 的 SDNN/SD1/LF-HF 和 NASA-TLX 六个分量共同决定，最终用 `Cmax`、`TC` 和 `FGC` 三目标评价。

## 建立理由

- 为什么值得独立维护：
  - 传统 FJSP 常把工人当作隐含资源或固定班组，难以反映机器-工人双资源耦合；
  - 人因制造需要把 worker well-being 与效率/成本共同优化；
  - 疲劳是时序状态，必须随工序、休息间隔和任务强度动态传播，不能只作为静态 workload；
  - Gini fatigue objective 提供了可插入 Pareto 搜索的公平性目标。
- 单篇具体方法的直接复用价值：
  - P2026-0273 给出 FJSP-WF-DRC MILP、三段编码、疲劳累积/恢复公式、疲劳阈值、最短休息时间、启发式初始化和 30 个实例实验。
- 与已有设计知识的区别：
  - 不同于“同索引分段决策种群协同进化”：该知识是多段种群架构；本知识是人因双资源调度问题的建模和解码评价层。
  - 不同于“时段分解随机拼接的约束调度搜索”：本知识不按时间块分解，而是在完整 schedule 中传播工人疲劳状态。
  - 不同于一般多资源调度：本知识把工人疲劳作为状态约束和公平目标，而非仅作为资源容量。

## 解决的问题

- 适用场景：
  - FJSP、装配、维修、仓储、护理、质检等需要同时分配机器/设备和人员的调度；
  - 工人技能、疲劳、安全阈值或公平性影响可行性与质量；
  - 可获取或可估计作业强度、生理指标、主观负荷或历史疲劳数据；
  - 需要在效率、成本和 worker well-being 之间给出 Pareto trade-off。
- 现有方法为什么会失败或不足：
  - 只优化机器 makespan 会把疲劳集中到少数高技能工人；
  - 静态工人负载均衡不能反映连续作业后的非线性疲劳增长；
  - 忽略恢复会高估或低估休息间隔价值；
  - 只用单一疲劳指标容易受噪声或个体差异影响。
- 仍需解决的问题：
  - HRV/NASA-TLX 数据采集成本和噪声；
  - 疲劳阈值和恢复率的个体化标定；
  - 疲劳公平目标与产能/成本目标冲突时的决策解释；
  - 动态扰动下疲劳状态实时更新。

## 为什么可能有效

```text
machine assignment determines processing time and cost
worker assignment determines skill feasibility and fatigue trajectory
-> joint machine-worker decoding avoids infeasible labor plans
-> fatigue accumulation/recovery captures temporal health risk
-> threshold creates safety barrier
-> Gini objective discourages fatigue concentration
-> Pareto front exposes efficiency-cost-wellbeing trade-offs
```

关键假设是：疲劳系数和恢复模型足够代表真实工人状态，并且调度系统能获得可靠的工人技能、作业强度和生理/主观数据。如果疲劳输入误差大，算法可能输出看似均衡但实际不安全的排程。

## 如何用于算法创新

### 局部创新

- 将 worker selection 纳入任意 FJSP/VRP/assembly decoder，而不是只在后处理阶段平衡工作量。
- 把 fatigue threshold violation 作为硬约束、epsilon 约束或 risk objective。
- 用 max fatigue、Gini、Theil index、CVaR fatigue 或个体超阈概率替代单一 fatigue balance。
- 将工人重分配、休息插入和关键路径疲劳缓解作为局部搜索算子。
- 让可穿戴设备实时更新 HRV 因子，并触发滚动重调度。

### 结构创新

- 人因调度框架：

```text
dual-resource encoder
-> fatigue-state decoder
-> safety constraint layer
-> multiobjective optimizer
-> worker-facing Pareto decision support
```

- 与鲁棒/动态调度结合：把 HRV 传感误差、工人离岗和外部疲劳扰动作为情景或分布。
- 与 RL 策略层结合：状态包含 fatigue imbalance、near-threshold worker count 和 recovery slack，动作选择搜索算子或插入休息。
- 与数字孪生结合：用现场传感器校正疲劳模型，并把预测疲劳回写调度优化。

## 适用条件与风险

- 适用条件：
  - 工序需要工人和机器共同完成；
  - 工人技能集合和机器兼容集合明确；
  - 可估计每个工序的疲劳强度、加工时间和成本；
  - 可以跟踪或近似每名工人的疲劳状态。
- 不适用或可能失效的条件：
  - 工人只是监督多台机器且不直接影响工序疲劳；
  - 疲劳数据不可获得或个人差异极大；
  - 调度周期太短，疲劳恢复/累积模型无法体现；
  - 安全法规要求确定性医学评估，而模型仅是优化代理。
- 计算与实现成本：
  - 解码要维护每名工人的时间线和疲劳状态；
  - 需要额外收集 HRV、NASA-TLX 或替代指标；
  - 多目标 Pareto 输出需要给管理者提供可解释 trade-off。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0273 | FJSP-WF-DRC 同时考虑 machine resources 与 worker resources，每道工序只能选择可行机器-工人组合 | 问题建模 | Sec. II-B/C，PDF 3 |
| P2026-0273 | 目标为最小化 `Cmax`、`TC` 和 worker fatigue imbalance `FGC` | 目标建模 | Sec. II-B/C，PDF 3 |
| P2026-0273 | 解编码为 `(J,M,W)`，分别表示 operation sequence、machine assignment 和 worker assignment | 编码证据 | Sec. III-A，PDF 4 |
| P2026-0273 | 初始化机器按最短处理时间或处理时间×机器成本，工人按处理时间×工人成本或最低疲劳选择 | 初始化与可行性 | Sec. III-B，PDF 4 |
| P2026-0273 | 疲劳系数结合 operation intensity、HRV 的 SDNN/SD1/LF-HF 和 NASA-TLX 六个 subscales | 疲劳模型 | Sec. III-E，PDF 7-8 |
| P2026-0273 | 模型包含休息时间、指数恢复、疲劳累积、疲劳安全阈值和最短休息时间计算 | 疲劳传播与安全 | Sec. III-E，Eq. (39)-(43)，PDF 8 |
| P2026-0273 | 实验在 Brandimarte、Dauzere、Hurink 数据集上模拟疲劳数据，覆盖 30 个不同规模实例和多种工人数系数 | 实验范围 | Sec. IV-A，PDF 9 |
| P2026-0273 | 作者指出疲劳数据输入准确性是方法限制，未来可用可穿戴设备实时采集 HRV/NASA-TLX 并动态更新疲劳系数 | 边界与未来工作 | Sec. IV-C、V，PDF 12-13 |

## 证据边界

- 当前只有单篇论文证据。
- 疲劳数据由仿真生成，尚未用真实 HRV/NASA-TLX 在线数据验证。
- NASA-TLX 是主观量表，实时或高频调度中如何采集仍需工程方案。
- 论文比较主要验证 IDPSO 搜索效果，不单独比较不同疲劳模型或公平指标。
- 疲劳阈值、恢复率和 HRV 权重的个体化标定不足。

## 待确认

- HRV、NASA-TLX 和任务强度的权重如何按工人、岗位和班次自适应；
- 疲劳阈值应作为硬约束、软约束还是风险目标；
- Gini fatigue imbalance 是否会掩盖单个工人极端疲劳；
- 真实车间中可穿戴设备噪声、缺失数据和隐私如何处理；
- 动态扰动下如何保留历史 Pareto 解并快速重调度。
