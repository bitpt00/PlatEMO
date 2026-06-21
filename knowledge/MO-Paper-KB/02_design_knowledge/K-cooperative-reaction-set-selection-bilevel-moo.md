---
knowledge_id: K-cooperative-reaction-set-selection-bilevel-moo
name: 协作式双层多目标反应集决策
type: method
status: active
source_papers: [P2026-0246]
aliases: [DMC, Decision Making with Cooperation, dynamic cooperation, fixed cooperation, resident-aware decision making, bilevel reaction set selection, optimistic pessimistic bridge, 协作决策, 双层多目标反应集选择, 居民主导决策]
promotion_reason: 单篇论文提出但接口明确，包含下层 reaction set、上层 optimistic/pessimistic 极端、下层 DM profile、固定/动态合作指数和公平增益-损失调节，可直接迁移到能源、交通、云资源、定价和其他存在上下层偏好冲突的 BLMOP。
---

# 协作式双层多目标反应集决策

## 核心内容

在双层多目标优化中，下层求解后通常返回一个 reaction set，而不是唯一 follower 解。传统 optimistic/pessimistic 只假设下层完全配合或完全不利于上层，容易过于极端。该知识在 reaction set 上引入下层决策者 profile 和 cooperation index：先定位上层最想要的 optimistic solution、下层最想要的 resident-aware solution，再在允许边界内按合作程度选择折中解；动态合作版本依据“某一方收益是否至少补偿另一方损失”的公平原则调整合作程度。

```text
upper solution -> lower-level MOO reaction set R
-> identify upper-preferred x* by UL objective
-> identify lower-preferred z by LL profile weights
-> build allowed decision set between x* and z
-> score candidates by UL score + LL score with cooperation q
-> optionally adjust q by gain/loss fairness
-> return selected lower reaction for upper evaluation
```

P2026-0246 的 DMC 用于能源社区中 aggregator 与 residents 的协作决策：aggregator 偏好 self-consumption，residents 按 profile 在 preference satisfaction 与 cost saving 之间取舍。

## 建立理由

- 为什么值得独立维护：
  - BLMOP 的上层评价常被下层多解性困扰；reaction set 选哪个解会显著改变上层搜索方向。
  - Optimistic/pessimistic 两端不适合描述真实组织、人群或部门之间的部分合作。
  - 该知识提供了一个可插拔的中介层：不改变上下层优化器，只改变下层 reaction set 到上层评价的选解规则。
- 单篇具体方法的直接复用价值：
  - P2026-0246 给出 Algorithm 2，覆盖 optimistic、pessimistic、resident-aware、fixed cooperation、dynamic cooperation 五类选解，并在 12 个真实偏好数据集上做敏感性分析。
- 与已有设计知识的区别：
  - 不同于“共享变量上层搜索的贝叶斯双层采样”：该知识关注最终解集共享组件和 RF-level acquisition；本知识关注给定上层解后如何从下层 reaction set 选一个合作响应。
  - 不同于“强化学习调度的下层搜索模式”：该知识决定是否/如何做下层搜索；本知识在下层 reaction set 已有后做偏好协作决策。
  - 不同于普通多准则决策：本知识显式连接上层 objective、下层 profile 和双层 optimistic/pessimistic 语义。

## 解决的问题

- 适用场景：
  - 双层/层级优化中下层有多个 Pareto-optimal 或近似 Pareto reaction；
  - 上层 entity 和下层 DM 的偏好不同但不完全对抗；
  - 下层 DM 的 profile、偏好权重或满意度函数部分可知；
  - 需要在上层收益和下层接受度之间选取可部署解。
- 现有方法为什么会失败或不足：
  - optimistic 可能高估上层可实现收益；
  - pessimistic 可能过度保守，使上层搜索错过实际可协商解；
  - 只按下层偏好选解会让上层无法引导系统目标；
  - 只做加权和缺少上下层允许边界，可能选到一方不可接受的解。
- 仍需解决的问题：
  - 下层 profile 未知或随时间变化时如何学习；
  - 合作指数 `q` 是否应作为可优化/可协商变量；
  - 公平原则是否能处理多下层 DM、多群体或非线性效用。

## 为什么可能有效

```text
reaction set contains many acceptable lower-level tradeoffs
-> upper-preferred and lower-preferred points define negotiation endpoints
-> allowed set removes clearly unacceptable candidates
-> cooperation q encodes willingness to move from lower preference toward upper preference
-> dynamic q shifts only while one side's gain compensates the other's loss
-> selected reaction is more realistic than pure optimistic/pessimistic
```

关键假设是：下层 profile 能被一个权重向量或效用函数近似，且上下层双方愿意以可比的 normalized gain/loss 进行协商。如果真实偏好不可观测、不可比较或策略性隐瞒，DMC 可能只是启发式近似。

## 如何用于算法创新

### 局部创新

- 在任意 nested BLMOEA 中，用 DMC 替换 optimistic/pessimistic lower reaction selection。
- 将下层 profile 从固定权重扩展为偏好分布、risk aversion、fairness constraints 或 historical behavior model。
- 将 fixed cooperation `q` 作为上层决策变量，让优化器同时学习设计变量和可协作程度。
- 将 dynamic cooperation 的 gain/loss 准则替换为 Nash bargaining、regret minimization、Kalai-Smorodinsky、social welfare 或约束满足概率。
- 对多下层群体设置多个 profile，并用 group fairness 或最大遗憾控制选解。

### 结构创新

- 构建层级协商中介：

```text
upper optimizer
-> lower MOO reaction set
-> preference/profile model for lower DM
-> cooperation/bargaining module
-> selected deployable lower response
-> upper fitness feedback
```

- 在能源、交通需求管理、云资源定价、供应链契约、平台补贴等问题中，把价格/政策作为上层变量，把用户/企业反应前沿作为下层 reaction set。
- 与偏好学习结合：用真实部署反馈更新 lower profile 和 feasible cooperation range。

## 适用条件与风险

- 适用条件：
  - 下层优化能返回覆盖较好的 reaction set；
  - 上下层目标都能在 reaction set 上评价或归一化；
  - 存在可解释的下层 profile 或权重；
  - 系统允许部分合作，而不是严格对抗或严格服从。
- 不适用或可能失效的条件：
  - 下层只有唯一最优解，reaction set 选择空间不存在；
  - 下层 DM 不可影响且 profile 未知，optimistic/RA 假设都站不住；
  - 上下层收益不可比，dynamic gain/loss 调节失真；
  - 多个下层群体之间本身有强冲突，单一 profile 无法代表；
  - reaction set 质量差，DMC 只能在错误候选中折中。
- 计算与实现成本：
  - 需要保留下层 external population/reaction set，而不是只返回一个解；
  - 需要为每个 reaction 解计算上层 objective 或 proxy；
  - dynamic cooperation 需重复调整 `q` 并重算候选 score，但开销通常小于下层优化本身。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0246 | DMC 支持 optimistic、pessimistic、resident-aware、fixed cooperation 和 dynamic cooperation 五类 reaction selection | 作者提出的方法 | Sec. III-C；Sec. IV-B，Algorithm 2，PDF 6-8 |
| P2026-0246 | Resident-aware approach 用居民 profile `v` 构造下层目标权重，选择 weight vector 最接近 profile 的下层解 | 作者提出的方法 | Sec. IV-B，Algorithm 2，PDF 7 |
| P2026-0246 | Fixed cooperation 用合作指数 `q` 加权上层 score 与下层 score，并在 optimistic 解与 LL-desired 解限定的边界内选解 | 作者提出的方法 | Sec. IV-B，PDF 7 |
| P2026-0246 | Dynamic cooperation 根据上下层 gain/loss 的公平原则增减 `q`，并让 `q` 从上层 parent 传递给 offspring | 作者提出的方法 | Sec. IV-B，Algorithm 2，PDF 7-8 |
| P2026-0246 | Dynamic-q DMC 在 Small datasets 上随居民 profile 变化保持稳定，`S/D/C` 最大变化为 15 kWh、1.09、4.88 | 决策实验支持 | Sec. VI-B，Fig. 9，PDF 13 |
| P2026-0246 | Dynamic-q DMC 接近 optimistic approach，最坏差距为 16 kWh、0.73 dissatisfaction-units 和 2.11 cost units | 决策实验支持 | Sec. VI-B，PDF 13 |
| P2026-0246 | 当居民完全优先 preference satisfaction 时，增加 cooperation/optimism 可显著改善 self-consumption 和 cost，但会牺牲 dissatisfaction | 机制/敏感性支持 | Sec. VI-B，PDF 13-14 |
| P2026-0246 | 作者认为在已知 LL preference 且允许合作时，dynamic-q DMC 是 extreme UL approaches 的可行替代 | 作者结论 | Sec. VI-B，PDF 14 |

## 待确认

- 下层 profile 如何从真实行为中估计，而不是由实验预设；
- 合作指数 `q` 的继承、变异或学习是否会影响上层搜索稳定性；
- 多个居民群体、多个下层 DM 或策略性响应时如何扩展；
- gain/loss 是否应使用归一化目标值、效用函数、货币化收益或 regret；
- 反应集稀疏或不准确时，DMC 是否会放大下层搜索误差。
