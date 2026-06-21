---
knowledge_id: K-preference-conditioned-single-heuristic-ps-learning
name: 偏好条件单启发式的 Pareto 集学习
type: architecture
status: active
source_papers: [P2026-0232]
aliases: [PSLGP, Pareto set learning GP, preference-conditioned scheduling heuristic, single preference-conditioned heuristic, preference diversity, 偏好条件启发式, 单启发式Pareto集学习]
promotion_reason: 单篇论文提出但架构清晰，包含偏好输入 GP 表示、跨偏好 KNN 代理评价、HV/IGD/GD 聚合、weighted-sum 补充、preference diversity、多准则选择、brood preselection 和偏好轮换，可直接迁移到实时多目标调度和启发式学习
---

# 偏好条件单启发式的 Pareto 集学习

## 核心内容

在需要实时响应用户偏好的多目标动态决策中，不维护一组不同 tradeoff 的启发式，而是学习一个把 preference vector 作为输入的单一启发式。该启发式在不同 preference 下应产生不同决策行为，并映射到 Pareto front 的相应区域。训练时用一个 main preference 做真实评价，用行为相似性的 surrogate 估计其他 preferences 下表现，再用多准则选择和 preference diversity 保证“同一个 heuristic 真的会随偏好变化”。

```text
GP heuristic trees include preference terminals
-> true evaluation under main preference
-> KNN surrogate estimates other preferences via behavior PC
-> aggregate cross-preference performance
-> reward preference diversity
-> rotate main preference each generation
-> output one preference-conditioned heuristic
```

## 建立理由

- 为什么值得独立维护：
  - 很多 MOO 方法输出一组解或一组策略，但实际部署需要根据用户偏好实时选择或调度；一个偏好条件单策略可降低部署复杂度；
  - 该架构给出了如何训练单策略覆盖 Pareto set 的完整机制，而不只是把偏好拼到输入中。
- 单篇具体方法的直接复用价值：
  - P2026-0232 给出 PSLGP Algorithm 1-4、preference-conditioned GP representation、KNN surrogate、three aggregation strategies、preference diversity、main preference rotation、消融和 solution distribution 分析；
  - 适合迁移到动态调度、路由、装箱、服务编排和其他需要实时 preference-conditioned heuristic 的 MOO。
- 与已有设计知识的区别：
  - 不同于“目标条件化生成式设计采样”：该知识生成候选解；本知识学习一个可解释启发式/策略，使其按偏好实时生成决策。
  - 不同于“连续偏好编码的学习引导离散 MOO”：该知识用机器学习辅助离散解生成；本知识把偏好直接作为 GP heuristic terminal，并输出单个调度规则。
  - 不同于“多目标 GP 构造特征库的随机 DRL 选择”：该知识构造和选择相似度特征；本知识构造偏好条件决策规则。
  - 不同于传统多目标 GP：传统方法输出一组 heuristics，本知识输出一个 preference-conditioned heuristic。

## 解决的问题

- 适用场景：
  - 多目标动态调度或实时决策，用户偏好会在运行时变化；
  - 多个独立 heuristic 难以管理、选择或解释；
  - 决策规则需要可解释，GP tree 比深度网络更合适；
  - 真实跨偏好评价昂贵，但可以用行为表征估计相近个体表现。
- 现有方法为什么会失败或不足：
  - 多 heuristic Pareto set 需要额外 selection layer，实时应用复杂；
  - 神经 Pareto set learning 模型结构复杂且解释性弱；
  - 简单加入 preference input 不保证 heuristic 行为随偏好变化；
  - 只在一个偏好下真实评价会导致其他偏好长期依赖代理误差。
- 仍需解决的问题：
  - 高负载或极端动态场景下单 heuristic 是否有足够表达能力；
  - preference diversity 与真实 Pareto alignment 之间如何校准；
  - 多目标数增加时 preference set 和 aggregation 如何扩展；
  - 如何防止树过大降低可解释性。

## 为什么可能有效

```text
preference terminals enter routing/sequencing trees
-> same heuristic can change priority calculation online
-> main preference evaluation provides exact anchor
-> KNN behavior surrogate cheaply fills other preference performance
-> aggregation metrics select heuristics that cover multiple tradeoffs
-> preference diversity keeps preference inputs behaviorally active
-> preference rotation prevents permanent surrogate-only regions
```

关键假设是：phenotypic characterization 能捕捉调度规则行为差异，且不同 preference 下行为差异与目标空间 tradeoff 相关。如果行为 PC 太粗、shop floor 过载导致所有决策被瓶颈主导，偏好输入可能难以形成可控 Pareto mapping。

## 如何用于算法创新

### 局部创新

- 给现有 GP dispatching rules 加入 preference terminals，直接改造为 preference-conditioned rule。
- 在多目标 routing、vehicle dispatch、machine assignment 或 batch scheduling 中加入 preference diversity 作为选择或正则项。
- 将 KNN PC surrogate 换成 learned behavior embedding surrogate，用少量真实仿真覆盖更多 preferences。
- 对弱覆盖 preference region 增加真实评价，替代简单轮换。
- 将 HV/IGD/GD 聚合换成 preference regret、R2、Tchebycheff 或用户 utility aggregation。

### 结构创新

- 构建单策略 Pareto set learning 闭环：

```text
conditioned policy/heuristic
-> evaluate anchor preference exactly
-> estimate other preferences cheaply
-> measure solution coverage + preference responsiveness
-> rotate or adapt preference curriculum
-> deploy one policy with online preference input
```

- 在 high-load 场景中使用 hybrid deployment：默认 single heuristic，若 preference coverage confidence 低则切换到小型 heuristic archive。
- 将偏好条件 GP 与 online learning 结合，运行中根据实际用户偏好分布继续微调 preference terminals 的影响。
- 在工业调度中把 preference vector 接入人机界面，让用户实时改变 tardiness/flowtime 权重，而不更换调度规则。

## 适用条件与风险

- 适用条件：
  - 决策规则可表示为函数/树/策略，能接收 preference vector；
  - 可以定义一组代表性 preferences 用于训练；
  - 有可计算的行为表征 PC 或可替代 embedding；
  - 单个 heuristic 的表达能力足以覆盖目标 tradeoff 的主要变化。
- 不适用或可能失效的条件：
  - 高 utilization 或强瓶颈场景中，调度行为受约束主导，偏好输入影响有限；
  - 目标数很多导致 preference space 高维，轮换和覆盖困难；
  - 偏好与最优解区域关系高度不连续；
  - KNN surrogate 估计误差大，误导 selection 和 preselection；
  - 单 heuristic 管理简单但方差更大，可能不如多 heuristic set 稳定。
- 计算与实现成本：
  - 每代只对 main preference 做真实仿真，其他 preferences 由 KNN surrogate 估计；
  - Brood recombination 生成 `5N` 候选，提高候选质量但增加 surrogate/preselection 成本；
  - preference diversity 需要计算多个 preferences 下的 PC。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0232 | PSLGP 输出单个 preference-conditioned scheduling heuristic，而不是一组 Pareto-front heuristics | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4 |
| P2026-0232 | Individual 由 routing tree 和 sequencing tree 组成，并把 preferences 作为 tree construction 的 terminal/input | 作者提出的方法 | Sec. III-B，Fig. 3，PDF 4-5 |
| P2026-0232 | Fitness evaluation 对 main preference 做真实评价，对其他 preferences 用 KNN surrogate 基于 PC 相似性估计 | 作者提出的方法 | Sec. III-C，Algorithms 2-3，PDF 5-6 |
| P2026-0232 | 提出 HV、IGD、GD 三种 cross-preference aggregation strategies，形成 PSLGP-H/I/G | 作者提出的方法 | Sec. III-C，PDF 6 |
| P2026-0232 | Weighted-sum value 用于补充 HV/IGD/GD 对非前沿 performance values 的忽略 | 作者提出的方法 | Sec. III-C，PDF 6 |
| P2026-0232 | Preference diversity 通过不同 preferences 下 PC 的平均距离衡量 heuristic 行为是否响应偏好 | 作者提出的方法 | Sec. III-C，Algorithm 4，PDF 6-7 |
| P2026-0232 | Multicriteria selection 依次使用 rank、fit、wsum、prediv 选择父代 | 作者提出的方法 | Sec. III-D，PDF 7 |
| P2026-0232 | Brood recombination 生成 5 倍候选，并用 upcoming main preference 的 KNN surrogate 和 niching preselection 选下一代 | 作者提出的方法 | Sec. III-E，PDF 7 |
| P2026-0232 | Main preference rotation 让不同 preference 都获得真实评价机会，提高跨偏好泛化 | 作者提出的方法 | Sec. III-F，PDF 7 |
| P2026-0232 | 实验使用 10-machine、5000-job 动态仿真，5 个 utilization levels，两个二目标组合共 10 个 scenarios | 实验设置 | Sec. IV-A-B，PDF 7-8 |
| P2026-0232 | HV/IGD/GD 结果显示 PSLGP-I 整体最好，HV 和 IGD average rank 均为 1.8 | 综合实验支持 | Sec. V-A，Tables IV-VI，PDF 8-10 |
| P2026-0232 | `WFmax-Tmax, 0.90` 等极端高负载场景中 PSLGP variants 可能弱于 NSGP-II | 适用边界 | Sec. V-A，PDF 8-10 |
| P2026-0232 | 消融显示去掉 brood recombination/preselection 或 multicriteria selection 均降低 HV/IGD/GD，完整 PSLGP-I 排名最好 | 消融实验支持 | Sec. V-B，Tables VII-IX，PDF 10-11 |
| P2026-0232 | Preference group 可视化显示 learned heuristic 能将不同 preferences 映射到不同 solution regions，但部分场景存在重叠 | 机制分析 | Sec. VI-A，Fig. 8，PDF 11-12 |
| P2026-0232 | 多个 learned heuristics 分布分析显示部分 heuristic 覆盖广，部分只覆盖小区域，说明覆盖仍需增强 | 机制边界 | Sec. VI-B，Fig. 9，PDF 12 |
| P2026-0232 | 作者未来工作包括提高 preference-conditioned heuristic 的鲁棒性、改进 aggregation、加入 adaptive mechanisms 和 hybrid methods | 未来工作 | Sec. VII，PDF 13 |

## 待确认

- Table II-III 和多张结果表在当前 Markdown 中为图片占位，精确参数和数值需回看 PDF 或 supplementary。
- 多目标数超过 2 时 preference diversity 和 aggregation 是否仍稳定。
- KNN PC surrogate 在真实工厂数据、非平稳 job arrival 和随机扰动下的误差。
- 如何将单 heuristic 的可解释树结构展示给调度员，并定位 preference terminals 的作用。
