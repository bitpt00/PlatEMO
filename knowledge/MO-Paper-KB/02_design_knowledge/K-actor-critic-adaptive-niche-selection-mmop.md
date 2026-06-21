---
knowledge_id: K-actor-critic-adaptive-niche-selection-mmop
name: Actor-Critic 自适应生态位环境选择
type: method
status: active
source_papers: [P2026-0287]
aliases: [AC-MMEA, actor-critic adaptive niche, RL-based niche size, local convergence quality selection, multimodal multiobjective optimization, MMOEA actor critic, 自适应生态位, 强化学习生态位, 局部收敛质量, 多模态多目标]
promotion_reason: 单篇论文提出但接口完整，包含 Con/Div 状态、连续 niche size 动作、状态改善 reward、actor-critic 在线学习、local convergence quality 环境选择和双种群协同框架，可直接改造 MMOP 或局部 dominance 选择算法中的生态位半径控制。
---

# Actor-Critic 自适应生态位环境选择

## 核心内容

在多模态多目标优化中，把 local convergence quality 的 niche size 从固定经验参数改成强化学习连续动作。算法每代用当前种群的收敛状态 `Con` 和决策空间多样性 `Div` 组成状态，actor 输出 niche size 的缩放动作，环境选择后根据 `Div` 是否提升、`Con` 是否下降构造 reward，再由 critic 的 TD error 指导 actor 和 critic 在线更新。

```text
population state: [Con, Div]
-> actor outputs continuous niche action
-> action scales initial niche radius
-> local convergence quality + crowding selection
-> next state and reward from state improvement
-> critic TD error updates actor and critic online
```

P2026-0287 的 AC-MMEA 是该模式的实例：它用 `P1` 维护决策空间多样性和潜在 PS 覆盖，用 `P2` 保存全局收敛性好解；`P1` 的环境选择由 actor-critic 生成的 adaptive niche size 控制。

## 建立理由

- 为什么值得独立维护：
  - niche size 是 MMOP 环境选择中的关键连续参数，直接决定保留潜在 PS 还是强化收敛；
  - actor-critic 能输出连续 action，避免把半径离散成少数固定档位；
  - 方法不需要 labeled data 或 offline training，可嵌入进化过程在线学习。
- 单篇具体方法的直接复用价值：
  - P2026-0287 给出 AC-MMEA Algorithm 2-4、状态/动作/reward、网络结构、复杂度、48 个 MMOP benchmark、真实 map-based application、双种群消融和固定 action 消融。
- 与已有设计知识的区别：
  - 不同于“状态驱动的 DRL 演化算子选择”：该知识的动作是 GA/DE/CHT/局部搜索等离散算子，作用位置是 offspring generation 或策略选择；本知识的动作是连续 niche size，作用位置是 environmental selection。
  - 不同于“级联聚类驱动的多模态子种群阶段管理”：该知识调度子种群划分和阶段；本知识调节局部 dominance 比较半径。
  - 不同于“目标解耦双 Critic 的多目标连续控制”：该知识面向外部工程控制动作和多目标 reward；本知识面向 MOEA 内部选择参数。

## 解决的问题

- 适用场景：
  - MMOP 需要同时覆盖多个等价 PS；
  - 环境选择使用 niche、邻域、局部 dominance 或 local convergence quality；
  - 固定 niche radius 在不同问题、不同阶段或不同决策维度上不稳定；
  - 可以在线计算种群收敛、多样性和状态变化 reward。
- 现有方法为什么会失败或不足：
  - niche 太大时，局部比较接近全局 dominance，潜在 PS 的 dominated solutions 容易被删除；
  - niche 太小时，局部竞争过弱，收敛速度变慢；
  - 阶段式或经验式 niche 缺少实时环境感知；
  - 只选择搜索算子不能直接修正环境选择对多样性和收敛性的偏置。
- 仍需解决的问题：
  - 单一全局 niche action 可能无法同时适配多个局部 PS；
  - 两维状态可能过粗，不能表达模态数量、局部密度和不均衡 PS 难度；
  - actor-critic 在线学习带来额外运行时间和超参数；
  - reward 的短期状态改善不一定等价于最终 PS 完整覆盖。

## 为什么可能有效

```text
MMOP selection needs local competition
-> local competition depends heavily on niche radius
-> Con/Div summarize current convergence-diversity tension
-> actor adjusts radius continuously
-> reward rewards larger diversity and smaller convergence gap
-> selection pressure follows search state instead of fixed parameter
```

关键假设是：`Con` 和 `Div` 足以判断当前搜索更需要扩大局部比较范围还是保护局部多样性，并且状态变化 reward 能提供稳定的在线学习信号。如果 MMOP 的不同 PS 区域差异很大，单个全局 radius 可能仍会偏向容易搜索的区域。

## 如何用于算法创新

### 局部创新

- 将固定 niche radius、邻域大小、reference subregion 半径或 local dominance 距离阈值替换为 actor-critic 连续动作。
- 把状态从 `[Con, Div]` 扩展为 `[Con, Div, PS_coverage_gap, archive_novelty, cluster_balance]`。
- 将单个 action 改成多头 action，为不同簇、参考方向或子种群输出不同 niche sizes。
- 用 bandit、PPO、DDPG、SAC 或 Bayesian controller 替代基础 actor-critic，比较连续参数控制稳定性。
- 在 reward 中加入长期档案覆盖、PS 丢失惩罚或 IGDX/PSP 的代理改善。

### 结构创新

- 构建通用选择参数控制层：

```text
search-state encoder
-> continuous controller
-> environmental-selection parameter
-> state-improvement reward
-> online policy update
```

- 与 DRL 算子选择组成双控制器：一个头选择 offspring operator，另一个头控制 niche radius 或 selection pressure。
- 与多子种群 MMOP 结合：每个子种群用局部状态生成自己的 radius，共享 critic 学习全局覆盖收益。
- 与动态 MMOP 结合：环境变化后先增大 niche 保护探索，随后由 actor 根据 reward 自动收缩。

## 适用条件与风险

- 适用条件：
  - 算法已有 local convergence quality、niche dominance、邻域 dominance 或类似局部比较机制；
  - 可以在每代计算收敛和多样性状态；
  - 目标是提升决策空间 PS 覆盖，而不只是目标空间 PF 收敛；
  - 评价预算足以让在线策略形成稳定偏好。
- 不适用或可能失效的条件：
  - 问题不是多模态，决策空间多样性不是关键目标；
  - 预算极低，actor-critic 还未学习就结束；
  - 状态高度噪声或 reward 与最终指标不一致；
  - 复杂约束或离散变量下距离度量不可靠；
  - 运行时间约束严格，无法承受额外 state/reward 和网络更新。
- 计算与实现成本：
  - 基础 AC-MMEA 复杂度为 `O(dN^2)`；
  - actor/critic 网络规模固定时只增加常数级网络计算，但 state/reward 中的距离计算和在线更新仍有实际开销；
  - 需要维护 actor/critic 参数、学习率、discount factor 和 reward 归一化边界。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0287 | AC-MMEA 用 actor-critic 生成自适应 niche size，嵌入 MMOP 环境选择 | 作者提出的方法 | Sec. III-A-C，Algorithms 2-4，PDF 5-7 |
| P2026-0287 | `Con` 基于最好/最差 global convergence quality 集合的平均反向距离，`Div` 为 decision-space crowding distance 均值 | 作者提出的方法 | Sec. III-C，PDF 6 |
| P2026-0287 | Actor 将 `[Con, Div]` 映射为连续 action，并缩放初始化 niche radius | 作者提出的方法 | Sec. III-C，PDF 6 |
| P2026-0287 | Reward 鼓励 `Div` 增大和 `Con` 减小，并对两项进行归一化 | 作者提出的方法 | Sec. III-C，PDF 6-7 |
| P2026-0287 | Actor/critic 采用简单全连接网络，与进化过程在线联合训练，不需要 offline labeled data | 作者提出/集成 | Sec. III-D，Fig. 4，PDF 7 |
| P2026-0287 | 时间复杂度分析给出 AC-MMEA 总体复杂度为 `O(dN^2)` | 复杂度边界 | Sec. III-F，PDF 8 |
| P2026-0287 | 在 MMF、IDMP、MMMOP 共 48 个问题上与十个 MMOEAs 比较，正文称 AC-MMEA 整体排名最好 | 综合实验支持 | Sec. IV-B，Table II，PDF 8-10 |
| P2026-0287 | `AC-MMEA-P1/P2` 消融显示单独多样性种群或收敛种群均弱于完整双种群框架 | 消融实验支持 | Sec. IV-E，Table IV，PDF 11 |
| P2026-0287 | 固定 action 的 R-MMEA 弱于 AC-MMEA，正文称平均 rPSP 改善约 67.86% | 组件消融支持 | Sec. IV-F，PDF 11 |
| P2026-0287 | 用 HREA、MMEA-SND、MMEA-VGAE 的 niche 替换 AC-MMEA niche 后均弱于 AC-MMEA | niche 对比支持 | Sec. IV-G，PDF 11-12 |
| P2026-0287 | AC-MMEA 比传统算法约慢 2-3 倍，但比部分 learning-based MMOEAs 有时间优势 | 计算成本边界 | Sec. IV-H，PDF 12 |
| P2026-0287 | 作者未来工作包括轻量 RL、更高效训练，以及扩展到动态、约束和 many-objective 问题 | 作者未来工作 | Sec. V，PDF 13 |

## 待确认

- `Con/Div` 两维状态是否足以适配强不均衡、多簇和高维 MMOP；
- 是否需要子区域级或子种群级 niche action，而不是单个全局 action；
- reward 是否应包含更长期的 archive coverage 或 PS 完整性估计；
- 与 bandit、成功率反馈、离散半径表或简单 PID 控制相比，actor-critic 的收益边界；
- 在 constrained、dynamic、many-objective、离散和 mixed-variable MMOP 中如何定义稳定距离与 niche radius。
