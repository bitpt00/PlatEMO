---
knowledge_id: K-experience-level-evolution-preference-morl
name: 经验偏好权重进化的多目标强化学习
type: architecture
status: active
source_papers: [P2026-0259]
aliases: [E2MORL, Experience Evolution-guided MORL, experience-level evolution, preference weight evolution, evolutionary MORL replay, preference-conditioned MORL, superior experience injection, 经验级进化, 偏好权重进化, 多目标强化学习经验回放]
promotion_reason: 单篇论文提出但框架接口完整，包含经验个体种群、偏好权重交叉变异、agent utility 分区记录、superior experience 过滤、RL injection 和 crowding diversity 更新，可直接改造 preference-conditioned MORL 或 off-policy 多目标 RL 的 replay 增强层。
---

# 经验偏好权重进化的多目标强化学习

## 核心内容

在 preference-conditioned MORL 中，不进化高维 policy parameters，而是把一个 episode 的 replay experiences 作为个体，只进化这些经验携带的 preference weight。每次 RL agent 与环境交互产生一个 episode buffer，并记录当前 agent 在该偏好区域的最好 scalar utility；EA 对经验个体的权重做交叉和变异，只有当重标后的经验 utility 超过当前 agent 在对应偏好区域的表现时，才把该经验复制到 replay buffer 中训练 agent。

```text
preference-conditioned MORL agent
-> collect episode buffer B with weight w and vector return f
-> inject B into experience population by dominance/crowding
-> evolve preference weights of population episodes
-> evaluate offspring by w_c^T f versus agent utility U[w_c]
-> only superior relabeled experiences enter replay buffer
-> train MORL agent with original and filtered evolved experiences
```

P2026-0259 的 E2MORL 将该架构分别嵌入 TD7、TD3 和 DDQN 的多目标版本，在 MuJoCo、DST 和 FTN 任务上验证。

## 建立理由

- 为什么值得独立维护：
  - ERL 与 MORL 的结合常被 policy population 评价成本卡住，尤其是 preference-conditioned policy。
  - 经验级进化把搜索空间从 policy parameters 降到 preference weights，评价也从环境交互变成 `w^T f` utility 比较。
  - 该机制给 replay buffer 增加一个“质量可控的偏好重标生成器”，比随机 HER 更适合不均衡偏好学习。
- 单篇具体方法的直接复用价值：
  - P2026-0259 给出 Algorithms 1-4，包含 RL optimization、RL injection、EA optimization 和 EA injection 完整闭环。
  - 消融显示 experience-level evolution 对 HV/PF 覆盖有贡献，随机 HER 在部分环境反而降低性能。
  - action discrepancy 分析显示进化生成经验比 HER 更接近当前 policy，off-policy 程度更低。
- 与已有设计知识的区别：
  - 不同于“先验引导与信息增益回放的样本高效 MORL”：该知识用先验策略 warm start 和 TD error/信息增益优先采样；本知识不依赖专家先验，而是进化已有 episode 的 preference labels 并用 agent utility 过滤。
  - 不同于“Tchebycheff-ESR 分解式非凸 MORL”：该知识关注非凸 PF 的 scalarization 和 full-return policy gradient；本知识关注 off-policy replay 经验生成和 ERL/MORL 交互。
  - 不同于“目标解耦双 Critic 的多目标连续控制”：该知识为每个目标建 critic 并按偏好更新 actor；本知识是可叠加在偏好条件 actor-critic 或 value-based MORL 上的经验增强架构。
  - 不同于普通 HER 或 preference relabeling：本知识不会随机重标所有 transition，而是经过 utility superiority 和 population diversity 选择。

## 解决的问题

- 适用场景：
  - preference-conditioned MORL 或 off-policy MORL；
  - 不同 preference weights 学习进度不均衡；
  - 环境交互昂贵，但已有 replay experiences 可重用；
  - 想引入 EA/RL 混合机制，又不希望评价或进化 policy population；
  - 可以用 weighted-sum 或其他 utility 评价一条 trajectory 在某个偏好下的价值。
- 现有方法为什么会失败或不足：
  - policy-parameter ERL 面临高维搜索和大量 episode evaluation；
  - 只用少量偏好评价 policy 会漏掉优质条件策略；
  - 随机 HER 容易产生低质量重标经验；
  - 普通 replay buffer 不知道哪些偏好区域正缺高质量经验；
  - multi-policy MORL 需要维护大量策略和 archive。
- 仍需解决的问题：
  - 高目标数下 preference space 分区数快速增长；
  - `w^T f` 只适合线性偏好或可线性近似的目标权衡；
  - 经验重标仍然是 off-policy 学习，质量过滤不能完全消除 distribution shift；
  - population 额外占内存，且可能偏向早期易得状态分布。

## 为什么可能有效

```text
preference-conditioned policy learns unevenly across weights
-> one episode collected under w may be valuable for another w'
-> random w' relabeling often produces weak or harmful experiences
-> evolve w' around successful episode weights
-> compare w'^T f against current agent utility in the same preference region
-> keep only experiences that beat current agent
-> replay buffer receives higher-value, lower-discrepancy training samples
```

关键假设是：trajectory vector return `f` 能代表这批 transition 在不同偏好下的训练价值，且超过当前 agent utility 的重标经验确实能改善 policy，而不只是离线评价上更好。

## 实现接口

- 输入：
  - preference-conditioned MORL agent，如 TD3/TD7/DDQN 的多目标版本；
  - replay buffer `R`；
  - experience population `P = {B_i}`，其中每个 `B_i` 为一个 episode buffer；
  - 个体 vector fitness `F = {f_i}`；
  - agent utility array `U`，按 preference subspace 记录最大 utility；
  - preference sampling distribution `D`；
  - population size、preference partition count、mutation strength。
- 输出：
  - 更新后的 preference-conditioned policy 或 value function；
  - 被过滤后的 evolved experiences；
  - 可覆盖多偏好的 Pareto front approximation。
- 插入位置：
  - off-policy MORL 的 replay buffer 入口；
  - ERL 框架中 EA 与 RL 的交互层；
  - preference-conditioned policy 的数据增强模块。
- 最小流程：

```text
for each episode:
    w <- sample_and_normalize(D)
    B, f <- rollout(agent, w)
    append B to replay buffer
    update U[region(w)] with w^T f
    train agent for len(B) gradient steps

    P <- inject_rl_episode(P, B, f, dominance_then_crowding)

    B_evolved <- empty
    for selected parents in P:
        w_c <- crossover_or_mutate(parent_weights)
        normalize w_c
        if w_c^T f_parent > U[region(w_c)]:
            B_evolved <- B_evolved + relabel(parent_buffer, w_c)
        if utility_margin(w_c, f_parent, U) > utility_margin(w_parent, f_parent, U):
            update parent weight to w_c

    append filtered B_evolved to replay buffer
```

- P2026-0259 的默认实例：
  - population size `n=20`；
  - continuous tasks replay buffer size `1e6`，discrete tasks 为 `1e4`；
  - learning rate `3e-4`，discount factor `0.99`；
  - Gaussian mutation `sigma=0.1`；
  - 二目标、三目标、六目标任务中的 utility 分区数 `k` 分别为 `100`、`20`、`4`；
  - 初始 10% training steps 禁用 EA injection；
  - 每条原始 transition 最多生成 5 条新 transition。

## 如何用于算法创新

### 局部创新

- 将 utility `w^T f` 替换为 Tchebycheff、R2、CVaR、constraint-aware utility 或 preference-region HV contribution。
- 将 agent utility `U` 从最大值改成分位数、置信上界或 ensemble uncertainty 形式，避免偶然高回报造成过滤过严。
- 用 learned proposal network、CMA-ES 或 bandit 生成 candidate preference weights，替代手工交叉/变异。
- 在过滤条件中加入 TD error、policy action discrepancy、state novelty 或 rare preference coverage。
- 将个体从完整 episode 拆成 sub-trajectory、skill segment 或 option-level buffer。

### 结构创新

- 通用 MORL replay 进化层：

```text
experience archive
-> preference-weight evolution
-> utility and off-policy safety filter
-> replay buffer augmentation
-> preference-conditioned MORL policy
```

- 与先验引导 MORL 结合：先用 prior policy 生成安全初始 experiences，再对这些 experiences 的偏好标签做质量过滤式进化。
- 与非凸 MORL/D 结合：对每条 trajectory 用 Tchebycheff/ESR utility 判断是否值得注入某个子问题 replay。
- 与 offline MORL 结合：在固定数据集中为 trajectories 搜索高价值 preference labels，同时用 behavior-policy discrepancy 控制保守性。
- 与多智能体 MORL 结合：按 agent、团队角色或任务阶段维护局部 experience population，再做全局偏好过滤。

## 适用条件与风险

- 适用条件：
  - 可获得 vector reward 或 episode vector return；
  - 基础算法能使用 off-policy replay；
  - preference-conditioned policy/value network 接受 weight 输入；
  - 线性或可计算 utility 能表达主要偏好；
  - 任务中存在跨偏好经验迁移价值。
- 不适用或可能失效的条件：
  - reward 极稀疏或 trajectory return 噪声很大，utility 比较不可靠；
  - 高目标数导致 preference partitions 过稀，`U` 记录长期缺数据；
  - 环境高度非平稳，旧 episode 重标经验与当前 policy 差异过大；
  - 偏好是非线性、阈值型或强约束型，但仍用 simple weighted sum 过滤；
  - on-policy MORL 算法无法直接吸收 replay buffer 中的重标经验。
- 计算与实现成本：
  - 需要维护 experience population 和 per-region utility table；
  - replay buffer 变大，训练样本来源更复杂；
  - 需要实现 dominance/crowding injection 和 preference-level crossover/mutation；
  - population size 增大能提高多样性，但会增加内存负担。
- 解释风险：
  - 该方法生成的是训练经验，不是直接保证 Pareto-optimal policy；
  - “superior experience” 由当前 agent utility 定义，早期 utility 估计差时过滤标准可能偏移；
  - 消融支持框架有效，但理论上高回报经验为何促进 MORL 仍未完全解释。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0259 | 作者指出传统 ERL 进化 policy parameters，preference-conditioned policy 需要大量偏好评价且参数空间高维 | 问题动机 | Introduction、Sec. II-C，PDF 1-4 |
| P2026-0259 | E2MORL 被定位为第一个 experience-level evolutionary framework in ERL，进化对象是 experiences 的 preference weights | 作者提出的方法 | Introduction、Table I，PDF 2 |
| P2026-0259 | Algorithm 1 将整体流程拆成 RL optimization、RL injection、EA optimization 和 EA injection | 作者提出的方法 | Sec. III-A、Algorithm 1，PDF 5 |
| P2026-0259 | Algorithm 2 在 RL interaction 中记录 episode buffer `R'`、vector fitness `f_R'`，并用 `w^T f_R'` 更新 agent utility array `U` | 作者提出的方法 | Sec. III-A、Algorithm 2，PDF 5 |
| P2026-0259 | Algorithm 3 用 dominance 和 crowding distance 将 RL agent 的 episode 候选注入 experience population | 作者提出的方法 | Sec. III-A/C、Algorithm 3，PDF 6-7 |
| P2026-0259 | Algorithm 4 对 preference weights 做单点交叉和 Gaussian mutation，并只复制 utility 高于 agent 的重标经验 | 作者提出的方法 | Sec. III-B、Algorithm 4，PDF 6 |
| P2026-0259 | 作者限制每条原始 transition 最多生成 5 条新 transition，并在初始 10% training steps 禁用 EA injection | 实现细节 | Sec. III-A，PDF 6 |
| P2026-0259 | 在 HalfCheetah、Walker、Hopper、Ant-2、Humanoid、Ant-3 上，E2MORL-TD7/TD3 在多数 HV 和 SP 指标上优于对比方法 | 综合实验支持 | Sec. IV-D、Table IV，PDF 8-9 |
| P2026-0259 | 在 Deep Sea Treasure 与 Fruit Tree Navigation 上，E2MORL-DDQN 相比 Envelope MORL 和 PD-MORL 获得更好或相当的 HV/SP | 离散任务支持 | Sec. IV-D、Table V，PDF 8-9 |
| P2026-0259 | 消融显示去掉 evolution 或用 HER 替代 evolution 会降低 Ant-2、Walker、Humanoid 的 HV 或 PF 质量 | 消融实验支持 | Sec. IV-E、Table VI、Fig. 5，PDF 9-11 |
| P2026-0259 | 更换 arithmetic crossover/uniform mutation 后性能接近，说明框架不依赖特定进化算子 | 组件稳健性 | Sec. IV-E、Table VI，PDF 9-11 |
| P2026-0259 | population size 增大通常有利于更密 PF，但 `n=20` 后收益有限且内存增加 | 参数分析 | Sec. IV-F、Table VII、Fig. 6，PDF 9-11 |
| P2026-0259 | `k` 和 `sigma` 敏感性较低，二目标中 `k=100`、`sigma` 在 `0.05` 到 `0.5` 范围内表现稳定 | 参数分析 | Sec. IV-F、Tables VIII-IX，PDF 9-12 |
| P2026-0259 | 运行时间分析显示 proposed evolutionary method 只带来较小额外计算负担，E2MORL-TD3 比 PD-MORL 更快 | 成本分析 | Sec. IV-G、Fig. 8，PDF 10-12 |
| P2026-0259 | 与 PD-MORL 的 HER 相比，E2MORL 生成经验的 action discrepancy 显著更低，更接近当前 policy | 机制分析 | Sec. IV-H、Fig. 12，PDF 14 |
| P2026-0259 | 作者指出高回报 experiences 在 MORL 中的理论作用仍缺少系统分析，未来需更好利用 population 额外经验 | 局限与未来工作 | Conclusion，PDF 14 |

## 证据边界

- 当前只有单篇论文证据。
- 实验集中在模拟控制和离散 benchmark，真实机器人、真实工业控制和非平稳环境未验证。
- E2MORL 的 utility filter 默认使用线性加权 vector return，非线性偏好和强约束偏好需重设评价函数。
- 高目标数下 preference partition 和 population 覆盖能力尚不充分明确。
- Markdown 中公式图片化较多，精确符号、边界条件和部分图中数值需回查 PDF。

## 待确认

- 如何理论化 high-return relabeled experiences 对 preference-conditioned MORL 的贡献；
- utility array `U` 是否应按时间衰减或加入 uncertainty；
- action discrepancy 是否可以在线作为过滤条件，而不仅是事后分析指标；
- 在 offline MORL 或真实系统中如何避免重标经验造成过度乐观；
- 高目标数和非线性偏好下，preference weight evolution 应如何设计。
