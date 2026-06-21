---
knowledge_id: K-rl-stagewise-moea-portfolio-selection
name: RL 阶段式 MOEA 组合选择与多样性重置
type: architecture
status: active
source_papers: [P2026-0015]
aliases: [RL-MOEA, stage-wise MOEA selection, DQN algorithm selection, MOEA portfolio selection, diversity population reset, mixed-feature MOP, 强化学习算法组合选择, 阶段式 MOEA 调度, 多样性种群重置]
promotion_reason: 单篇论文提出但接口完整，包含候选完整 MOEA action set、阶段式 MDP、收敛/多样性状态、终端 HV reward、DQN/Q-learning 训练、训练/优化双模式、算法切换时基于 diversity population 的部分种群重置，以及 ZUM 混合特征测试套件和消融/敏感性证据；其控制粒度是完整优化框架选择，区别于已有算子级 DRL 调度。
---

# RL 阶段式 MOEA 组合选择与多样性重置

## 核心内容

把多个互补的完整 MOEA 作为算法组合，而不是只把交叉、变异或局部搜索算子作为动作。强化学习 agent 每隔若干代读取当前种群状态，选择下一阶段执行哪一个 MOEA；当选择的算法发生切换时，用一个独立维护的 diversity population 替换当前种群的一部分个体，避免切换后种群分布过窄或被上一算法的偏置锁死。

```text
candidate MOEA portfolio
-> stage-level state extraction from current population
-> RL/DQN selects one MOEA for the next G generations
-> selected MOEA evolves current population
-> diversity population stores far-apart nondominated solutions
-> if selected MOEA changes, reset part of current population from diversity population
-> terminal HV reward updates the policy
```

关键点是：控制层调度的是“完整算法范式”，例如 dominance-based、decomposition-based 和 many-subpopulation MOEA，而不是同一算法内部的 variation operator。算法切换同时需要 population handover 机制，否则换框架可能只是在同一个偏置种群上继续搜索。

## 建立理由

- 为什么值得独立维护：
  - 复杂 MOP 可能同时包含 separable、interacting 和 imbalanced variables，单一 MOEA 的结构偏置很难覆盖所有特征。
  - 传统算法选择通常在运行前完成，而混合特征问题中不同阶段需要的算法可能不同。
  - 与算子级 DRL 调度相比，本机制能直接切换环境选择、分解结构、子种群组织和 variation pipeline。
  - Diversity population reset 提供了算法切换时的分布保护接口，是单纯 action selection 没有覆盖的部分。
- 单篇具体方法的直接复用价值：
  - P2026-0015 给出 NSGA-II、MOEA/D-DE 和 MOEA/D-M2M 三算法 action set；
  - 状态、动作、reward、训练/优化模式、Q-learning 与 DQN 版本、算法切换重置和 ZUM 混合特征 benchmark 都有明确公式或算法流程；
  - 在 ZUM1-ZUM5 的 10D/20D 全部 10 个实例上取得最优平均 IGD 和 HV。
- 与已有设计知识的区别：
  - 不同于“状态驱动的 DRL 演化算子选择”：该卡主要在同一算法内部选择 GA/DE/PSO/LS、CHT、参数、迁移规模或算子比例；本知识选择的是完整 MOEA 框架。
  - 不同于“成功率反馈的算子与参数自适应选择”：本知识用 MDP 和 DQN/Q-learning 估计阶段级长期收益，并且 reward 可来自最终 HV。
  - 不同于“统计等价驱动的多标签算法选择”：后者用于离线推荐一组统计等价算法；本知识在单次优化过程中动态切换算法。

## 解决的问题

- 适用场景：
  - 已有多个互补 MOEA，每个算法擅长不同问题特征；
  - 问题特征混合或会随搜索阶段表现不同；
  - 能统一候选 MOEA 的 population interface；
  - 评价预算足以支撑阶段级策略学习或使用离线训练好的 policy；
  - 需要在算法组合中保留多样性，而不是让当前算法偏置完全决定下一阶段。
- 现有方法为什么会失败或不足：
  - 固定单一算法会放大其结构偏置。
  - 随机轮换或固定阶段表无法利用当前种群状态。
  - 只调 crossover/mutation 不一定能改变环境选择、分解方式和子种群组织。
  - 算法切换若没有 population handover，可能继承前一算法造成的分布塌缩。
- 仍需解决的问题：
  - 如何定义足够表达问题特征的状态；
  - 如何在训练成本、泛化能力和在线适配之间折中；
  - 如何扩展到更多候选算法、约束处理和 many-objective 场景；
  - 如何判断算法切换何时应触发重置、重置多少个体。

## 为什么可能有效

```text
不同 MOEA 的结构偏置不同
-> population state 反映当前阶段的收敛和覆盖缺口
-> RL policy 学习哪类算法在该状态下长期收益更高
-> stage-level 切换避免逐代抖动
-> diversity population 在切换时补回稀疏非支配解
-> 混合特征问题上同时利用多个算法的专长
```

关键假设是：当前种群的收敛和多样性状态能预测不同 MOEA 在下一阶段的收益；候选算法确实互补；训练问题覆盖了目标应用中的主要混合特征。

## 实现接口

- 输入：
  - 候选 MOEA 集合，例如 dominance-based、decomposition-based、indicator-based 或子种群型算法；
  - 阶段长度 `G` 和最大代数 `gmax`；
  - 当前种群 `Pc` 和 diversity population 容量 `Nd`；
  - 状态特征，如平均目标值、目标空间稀疏区域数、可行比例、参考向量覆盖或变量交互估计；
  - reward 指标，如 HV、HV improvement、IGD surrogate、archive improvement 或工程目标收益。
- 输出：
  - 下一阶段选择的 MOEA；
  - 可选的 action value、探索标记、切换标记和重置后的 population；
  - diversity population 与训练日志。
- P2026-0015 的默认实例：
  - `A={1,2,3}`，分别对应 NSGA-II with SBX、MOEA/D-DE、MOEA/D-M2M；
  - `s1_t` 为当前种群平均目标值；
  - `s2_t` 为目标空间中少于 `gamma` 个解的稀疏区域数量；
  - 中间 reward 为 0，终端 reward 为 `Pc` 的 HV；
  - DQN 在 ZUM2 20D 训练，优化阶段直接复用训练好的 agent；
  - 若连续两阶段 action 不同，则保留 `Pc` 中较优的 `N-Nd` 个体，并用 `Pd` 替换其余个体。
- Diversity population 维护：
  - 从当前种群提取非支配解集合 `PN`；
  - `Pd` 为空时，随机选一个 `PN` 解，然后反复加入与 `Pd` 距离最远的解直到达到 `Nd`；
  - `Pd` 非空时，只在候选解到 `Pd` 的距离超过阈值 `eta` 时加入，并移除最旧解保持容量。

## 如何用于算法创新

### 局部创新

- 将 action 从三类 MOEA 扩展为 `MOEA + CHT + archive policy`，支持 constrained MOO。
- 将状态扩展为 reference-vector occupancy、feasible ratio、local PF curvature、decision-space clustering 或近期 operator success。
- 用 dense reward 替代纯终端 HV，例如阶段 HV improvement、archive novelty、可行性恢复和区域覆盖增量。
- 对 action switch 设计 adaptive reset ratio：状态越拥挤或 stagnation 越强，替换比例越大。
- 用 bandit/meta-learning 做在线快速适配，减少离线 DQN 对训练分布的依赖。

### 结构创新

- 构建算法组合控制层：

```text
feature-specialist MOEA library
-> unified population and archive interface
-> RL policy selects algorithm per stage
-> handover layer decides reset ratio and source archive
-> selected MOEA runs for G generations
-> evidence logger updates policy and algorithm profile
```

- 将人工混合特征 benchmark 作为 curriculum：先训练 separable/interacting/imbalanced 单特征，再训练随机混合比例实例。
- 为每个候选 MOEA 维护能力 profile，将离线 landscape feature 与在线 population state 共同输入 policy。
- 在昂贵优化中把 surrogate-assisted MOEA、真实评价 MOEA 和局部精修算法作为同一 portfolio 的候选动作。

## 适用条件与风险

- 适用条件：
  - 候选算法确有互补优势；
  - 可以共享或转换 population representation；
  - 阶段长度足够让所选算法产生可观察效果；
  - 有可接受的训练问题或历史优化日志；
  - 终端或阶段 reward 与最终优化质量一致。
- 不适用或可能失效的条件：
  - 评价预算极低，策略尚未发挥作用；
  - 候选算法差异很小，切换只增加复杂度；
  - 状态过粗，无法区分真正的问题特征；
  - 训练分布与目标问题差异过大；
  - 算法切换太频繁，导致搜索抖动或重置破坏收敛。
- 计算与实现成本：
  - 需要包装多个 MOEA 的统一接口；
  - 需要维护 diversity population 和 action history；
  - DQN/Q-learning 训练增加额外成本，但可离线完成；
  - 若 action set 扩大，需要更强泛化模型或分层 action 设计。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0015 | RL-MOEA 将演化过程建模为 MDP，用 state representation 捕捉 population distribution，并用 HV 作为 reward | 作者提出的方法 | Abstract，PDF 1 |
| P2026-0015 | 框架维护 current population `Pc` 和 diversity population `Pd`，分别用于 offspring generation 和算法切换后的多样性重置 | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 5 |
| P2026-0015 | Action space 为 NSGA-II with SBX、MOEA/D-DE、MOEA/D-M2M 三个完整 MOEA，而不是单个 variation operator | 作者提出的方法 | Sec. 3.1，PDF 6 |
| P2026-0015 | 状态由平均目标值 `s1` 和目标空间稀疏区域计数 `s2` 构成，分别刻画收敛和多样性 | 状态设计 | Sec. 3.1，Fig. 3，PDF 6 |
| P2026-0015 | 中间阶段 reward 为 0，终端 reward 为当前种群 HV；作者同时给出 Q-learning 和 DQN 训练版本 | Reward 与训练设计 | Sec. 3.1、Algorithm 4，PDF 6 |
| P2026-0015 | ZUM1-ZUM5 将 separable、interacting 和 imbalanced variables 合成到同一 MOP 中，并提供 true PF/PS | Benchmark 设计 | Sec. 2、Table 1，PDF 4-5 |
| P2026-0015 | DQN 只在 ZUM2 20D 训练，然后用于其他 benchmark 和 ZUM 实例 | 泛化实验设置 | Sec. 4，PDF 7-8 |
| P2026-0015 | 在 UF/ZDT/MOP 共 17 个 benchmark 上，RL-MOEA 获得 7 个最优 IGD，但不总是优于单个专长算法 | 综合实验支持与边界 | Sec. 4.2，PDF 7-9 |
| P2026-0015 | 在 ZUM1-ZUM5 的 10D/20D 共 10 个混合特征实例上，RL-MOEA 获得全部最低平均 IGD 和全部最好 HV | 混合特征实验支持 | Sec. 4.3，Tables 2-3，PDF 8-9 |
| P2026-0015 | 收敛曲线显示 RL-MOEA 在所有 ZUM 实例上最快，NSGA-II/SBX 早期快但中期停滞 | 过程实验支持 | Sec. 4.3，Figs. 4-5，PDF 9 |
| P2026-0015 | DQN 相比 tabular Q-learning 在 17 个标准 benchmark 中 9 个更优、6 个相当、1 个更差，泛化性更好 | 消融/对比支持 | Sec. 4.4，PDF 9-10 |
| P2026-0015 | `Nd` 敏感性实验显示 performance 对 diversity population size 不太敏感，`Nd=30` 最好、`Nd=10` 最弱 | 参数敏感性 | Sec. 4.5，PDF 10-11 |
| P2026-0015 | 作者未来工作包括实际工程/经济问题建模、领域知识和约束处理 | 局限与未来方向 | Conclusion，PDF 11 |

## 证据边界

- 当前只有单篇论文证据。
- Action set 只有三个候选 MOEA，尚未验证更大算法库或层级 action space。
- DQN 训练只使用 ZUM2 20D，一个训练点不足以证明广泛分布外泛化。
- 状态表达较粗，只覆盖平均目标值和目标空间稀疏区域数量。
- Reward 为终端 HV，训练反馈稀疏；在昂贵评价或强噪声问题中可能不稳定。
- 论文主要是 bi-objective artificial benchmark 与经典测试函数，真实工程问题仍是未来工作。
- ZUM 结果能支持混合特征压力测试，但不能单独证明 diversity reset、DQN 和算法组合三者各自贡献；还需要更细粒度消融。

## 待确认

- 多算法 action set 扩大后如何避免训练样本稀疏；
- many-objective 场景下状态和 HV reward 如何替换或近似；
- constrained MOP 中是否应将 CHT 与 MOEA 组成联合动作；
- action switch 的 reset ratio 是否应自适应；
- 离线训练、在线微调和跨问题迁移之间如何分配预算；
- 如何判断候选 MOEA 的互补性足够支撑 portfolio controller。

