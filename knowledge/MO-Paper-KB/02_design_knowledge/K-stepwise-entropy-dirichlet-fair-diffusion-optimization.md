---
knowledge_id: K-stepwise-entropy-dirichlet-fair-diffusion-optimization
name: 逐步熵公平与 Dirichlet 权重的扩散优化
type: architecture
status: active
source_papers: [P2026-0086]
aliases: [AdaFairIM, step-wise entropy fairness, temporal fairness influence maximization, Dirichlet adaptive weighting, fairness-aware influence maximization, trajectory-aware fairness, cumulative step-wise fairness, fair diffusion optimization, 时序公平影响力最大化, 逐步熵公平, Dirichlet 自适应权重, 公平扩散优化]
promotion_reason: 单篇论文提出但实现接口完整，包含扩散步级群体熵、公平-影响双目标适应度、Dirichlet 贝叶斯权重更新、Pareto/crowding leader、外部非支配 archive 与 TOPSIS 选解，可直接迁移到影响力最大化、谣言阻断、应急信息传播、公共健康触达和推荐曝光等扩散型多目标优化问题。
---

# 逐步熵公平与 Dirichlet 权重的扩散优化

## 核心内容

在扩散/传播型多目标优化中，不只在传播结束后检查群体覆盖是否公平，而是在每个扩散步统计不同群体的累计激活/触达比例，用 group entropy 描述“信息是否及时且均衡地到达”。该时序公平目标与传播范围、成本、速度等目标一起进入优化。权重不固定人工设定，而是从 Dirichlet 分布采样，并根据本代 accepted/rejected 解的历史表现更新参数。搜索层使用 Pareto dominance、crowding distance 和外部非支配 archive 保留多样化折中，最终用 TOPSIS 或其他 MCDM 方法选择可部署单解。

```text
candidate seed / relay / intervention set
-> diffusion simulator records activated groups at each step
-> cumulative step-wise entropy H(t)
-> objectives: spread / fairness / cost / time ...
-> Dirichlet-sampled weights for scalar fitness or search pressure
-> accepted/rejected solutions update theta
-> Pareto + crowding leader/archive preserve tradeoff diversity
-> TOPSIS / preference rule selects final deployment solution
```

P2026-0086 的实例 AdaFairIM 用 SIR 扩散、影响力最大化、群体公平、二目标 Dirichlet 权重、binary ABCICA 搜索、两个 Pareto leader、外部 archive 和 TOPSIS 终选构成完整流程。

## 建立理由

- 为什么值得独立维护：
  - 许多公平扩散优化只看终态覆盖，会漏掉“早期只触达多数群体、少数群体被延迟触达”的过程不公平。
  - 过程公平可以直接转化为 fitness 监控器，插入任意扩散仿真和 MOEA/MORL/metaheuristic。
  - Dirichlet 权重更新提供了比固定权重更柔性的 spread-fairness 平衡方式，可用于不同数据集、seed budget 和传播强度。
  - Pareto leader/archive 与 MCDM 终选把“搜索中保留多样性”和“部署时需要单解”连接起来。
- 单篇具体方法的直接复用价值：
  - P2026-0086 给出 step-wise entropy 公式、Dirichlet sampling/update、leader selection、archive maintenance、TOPSIS final selection，以及六个 synthetic/real-world 网络的对比、敏感性与公平策略分析。
- 与已有设计知识的区别：
  - 不同于“连续时间竞争扩散的多目标图干预 RL”：该知识重点是 GCN+A2C 多轮干预和传播时间目标；本知识重点是群体公平随扩散步演化的评价与权重/档案控制。
  - 不同于“波前扩散控制的车联网中继传播优化”：该知识控制通信中继概率、范围、同步和冗余；本知识控制扩散优化中的公平度量和目标权衡。
  - 不同于“CRITIC-TOPSIS 评价反馈引导演化”：该知识把 MCDM 评价前移并反馈搜索；本知识的 TOPSIS 只是终选层，核心创新在 step-wise fairness 与 Dirichlet 权重。
  - 不同于普通 entropy diversity：这里的熵不是种群多样性或 seed set 结构多样性，而是扩散轨迹中的 group activation fairness。

## 解决的问题

- 适用场景：
  - influence maximization、rumor blocking、public health messaging、job/scholarship information dissemination、emergency alert、推荐曝光、广告触达等扩散型任务；
  - 存在 demographic groups、communities、地区、风险人群或优先人群；
  - 早期触达本身重要，不能只看最终覆盖；
  - 可以通过仿真、日志或在线传播记录获得每个时间步的群体激活数；
  - 需要在 spread/fairness/cost/time 等目标之间保留折中。
- 现有方法为什么会失败或不足：
  - 终态公平会把“先让 A 群体全部获得信息，最后才触达 B 群体”的路径判定为公平；
  - 极值型 group fairness 指标对多群体和群体规模差异敏感，可能忽略中间群体；
  - 固定权重或人工权重依赖数据集和任务阶段，容易偏向 spread 或 fairness；
  - 单一 leader 或单一标量最优会丢失 Pareto tradeoff；
  - 纯 Pareto front 输出又缺少最终可部署单解选择。
- 仍需解决的问题：
  - 过程不公平和网络结构自然传播延迟之间的区分；
  - 熵公平是否需要按 `log(m)` 归一化、按群体规模加权或加入 exposure delay；
  - Dirichlet 更新对随机扩散噪声是否敏感；
  - TOPSIS 的理想点、归一化和目标权重如何与真实决策偏好一致。

## 为什么可能有效

```text
early access matters
-> fairness must be measured inside the diffusion trajectory

groups may be balanced at final time
-> cumulative entropy penalizes early concentration without strict per-step overreaction

spread/fairness tradeoff changes with network and seed budget
-> Dirichlet weights learn objective emphasis from accepted/rejected solutions

adaptive scalar fitness may collapse diversity
-> Pareto leader selection and external archive keep multiple tradeoffs

deployment needs one seed set
-> TOPSIS or preference rule chooses a reproducible compromise
```

关键假设是：扩散仿真或真实日志能可靠记录每步群体激活，且任务确实重视早期触达。如果只有最终覆盖重要，或群体身份不可用/不可用作决策，step-wise fairness 会增加不必要复杂度。若传播过程噪声很高，Dirichlet 权重更新需要平滑或置信控制。

## 实现接口

- 输入：
  - 图或传播网络、seed/relay/intervention budget；
  - 节点所属 group 或软群体概率；
  - 扩散模型或传播日志，能够输出每个 step 的 activated nodes；
  - spread/cost/time 等其他目标；
  - 初始 Dirichlet 参数、学习率、惩罚因子、archive size、leader 数。
- 输出：
  - 候选解的 `spread`、`H_stepwise`、综合适应度或 Pareto rank；
  - 更新后的 Dirichlet 参数 `theta`；
  - 外部非支配 archive 和 leader set；
  - 最终部署解及其 TOPSIS/preference score。
- 插入位置：
  - influence maximization fitness evaluation；
  - rumor blocking / counter-rumor seed selection；
  - V2V/robot swarm/emergency dissemination relay policy search；
  - recommendation exposure scheduling；
  - public health campaign target selection；
  - 任意 population-based MOEA 的 leader、gbest、reference solution 或 archive selection。

最小实现：

```text
for each candidate S:
    A_t_by_group = run_diffusion_and_record_groups(S)
    spread = final_activated_count / |V|
    H = mean_t entropy(cumulative_group_counts_t)
    alpha_S ~ Dirichlet(theta)
    fitness = alpha_S[0] * spread + alpha_S[1] * H

accept/reject candidates by host algorithm
theta += eta(t) * (mean_alpha_accepted - gamma * mean_alpha_rejected)
theta = max(theta, epsilon)

rank candidates by Pareto(spread, H)
archive = nondominated_merge_and_crowding_truncate(archive, rank1)
leaders = top_crowding(F1(population) union archive)
final_solution = TOPSIS(archive or nondominated set)
```

## 如何用于算法创新

### 局部创新

- 将终态 fairness objective 替换为 cumulative step-wise entropy、strict step-wise entropy 或 group delay penalty。
- 对不同 diffusion phases 使用不同公平强度：早期高权重，中后期逐渐平衡 spread。
- 将 Dirichlet 参数从全局一个 `theta` 改为按社区、参考向量、archive cluster 或 seed budget 分簇维护。
- 将 binary accept/reject reward 改成 per-objective improvement、Pareto rank improvement、hypervolume contribution 或 fairness violation reduction。
- 在大图中使用 fixed small `L` 快筛，leader/archive 再用 full diffusion 或 Monte Carlo 多次复评。
- 把 TOPSIS 换成偏好参考点、VIKOR、PROMETHEE、epsilon-constraint 或 decision-maker interactive selection。

### 结构创新

- 通用 fair diffusion optimizer：

```text
diffusion simulator / log replay
-> temporal fairness monitor
-> adaptive objective weighting
-> Pareto-diverse leader/archive controller
-> preference-aware final selector
```

- 与图干预 RL 结合：RL policy 选择干预节点，reward 同时包含 influence/time 和 step-wise group fairness。
- 与 V2V 波前传播结合：relay probability 不只优化 coverage/delay/overhead，也约束不同区域或车辆类型的早期接收公平。
- 与推荐系统结合：把用户曝光过程视为 diffusion trajectory，监控不同群体在早期推荐位或早期传播轮次中的 exposure entropy。
- 与 OT fairness 结合：step-wise entropy 捕捉单次轨迹内时序不公平，OT fairness 捕捉多次 stochastic realizations 间的不公平。

## 适用条件与风险

- 适用条件：
  - 群体标签、群体概率或可解释社区可获得；
  - 扩散过程有 step/time 概念，早期触达具有实际价值；
  - 能承担比终态评价更高的仿真或日志处理成本；
  - 需要在公平与传播性能之间保留可解释折中；
  - 决策流程接受最终 MCDM 或偏好规则选解。
- 不适用或可能失效的条件：
  - 传播只有一次最终结果，没有可观测时间轨迹；
  - group 标签不可用、法律/伦理上不可用于优化，或群体定义不稳定；
  - 网络结构导致某些群体必然晚触达，简单熵惩罚可能误判结构性路径差异；
  - 群体数量很多且激活样本稀疏，entropy 会高方差；
  - 固定 TOPSIS 权重与真实业务偏好不一致。
- 计算与实现成本：
  - 每个候选解需要记录每个 step 的 group counts；
  - Monte Carlo 扩散会放大评价成本；
  - Dirichlet 更新和 Pareto leader selection 成本主要随 population/archive size 增长；
  - 大图需要 parallel diffusion、incremental update、frontier caching 或 multi-fidelity evaluation。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0086 | 指出已有 fairness-aware IM 多在扩散结束后评估公平，无法发现少数群体早期被延迟触达的问题 | 作者提出的问题 | Sec. 1、3.1，PDF 1-4 |
| P2026-0086 | 定义 step-wise entropy：每步统计 group activation proportions，计算 `H(t)` 并对扩散步平均 | 作者提出的方法 | Sec. 4.3.1，PDF 6-7 |
| P2026-0086 | 采用 cumulative step-wise fairness，区别于 final-only fairness 和 strict step-wise fairness | 作者提出的方法 | Sec. 4.3.1，Table 2，PDF 6-7 |
| P2026-0086 | 将 `f1(S)=sigma(S)/|V|` 与 `f2(S)=1/T sum_t H(t)` 合成 influence-fairness 双目标适应度 | 作者提出/集成方法 | Sec. 4.1-4.3，PDF 5-8 |
| P2026-0086 | 用 `alpha~Dirichlet(theta1,theta2)` 采样目标权重，避免固定手工权重 | 作者提出的方法 | Sec. 4.3.2，PDF 8 |
| P2026-0086 | 根据 accepted/rejected solutions 的 sampled alpha 聚合更新 `theta`，并用 `eta(t)` 从探索转向利用 | 作者提出的方法 | Sec. 4.3.2-4.3.4，PDF 8-9 |
| P2026-0086 | 用 Pareto dominance、crowding distance、external archive 从当前 Rank-1 与 archive 中选择两个 leader | 作者提出/集成方法 | Sec. 4.6，PDF 13-14 |
| P2026-0086 | 用 TOPSIS 从非支配候选中选择最终可部署折中解，避免随机或人为选择 Pareto 解 | 作者采用方法 | Sec. 4.7，PDF 14-15 |
| P2026-0086 | 六个 synthetic/real-world 网络、六类 baseline、seed size 4-40 的实验显示 AdaFairIM 在 spread-fairness 折中上整体更优 | 综合实验支持 | Sec. 5.1-5.4，PDF 16-22 |
| P2026-0086 | PoF 多数数据集高于 0.8，Rice-Facebook、Synthetic 2 groups 和 SF 常高于 0.9，说明公平约束没有造成过大 spread 损失 | 实验支持 | Sec. 5.2，Fig. 6，PDF 19-20 |
| P2026-0086 | 固定 `alpha` 分析显示增大 spread 权重会降低 fairness，支持自适应权重必要性 | 机制证据 | Sec. 5.7，Figs. 11-12，PDF 22-24 |
| P2026-0086 | final-only fairness 的 spread 略好，但 cumulative step-wise fairness 能揭示早期不公平并保持可接受 spread | 机制证据 | Sec. 5.8，Figs. 13-14，PDF 24-30 |
| P2026-0086 | 作者提出 full diffusion、fixed small L、truncated multi-fidelity 三类评价策略；大图可对 leader/archive 深度复评 | 扩展建议/证据边界 | Sec. 6.3-6.4，Table 8，PDF 27-31 |
| P2026-0086 | 作者未来工作包括 dynamic networks、node-level + group-level fairness、real-time/partially observed uncertainty-aware fairness | 作者未来工作 | Sec. 8，PDF 32-33 |

## 证据边界

- 当前独立证据来自单篇论文，且实验网络最大为 3560 nodes；百万节点可扩展性主要是理论和策略讨论。
- 多个组件同时集成，缺少完全隔离的消融来分辨 step-wise entropy、Dirichlet weighting、Pareto leader/archive 和 ABCICA 各自贡献。
- PDF 公式显示 `theta` 更新的截断细节不够清晰，复现时需检查原实现。
- 论文声称 fairness metric 范围为 0-1，但公式文本未明确给出 normalized entropy；实现时应显式归一化。
- SIR 随机扩散带来非单调和跨数据集不一致，实际部署需要多次仿真、置信区间或在线监控。

## 待确认

- 过程公平是否会惩罚由网络结构自然造成、并非算法偏置造成的群体到达顺序；
- group overlap、intersectional attributes 和 soft group membership 如何进入 step-wise entropy；
- Dirichlet 权重更新能否在动态图、实时日志或高噪声扩散中稳定；
- 与 OT fairness、Gini、max-min、exposure delay 等公平指标的组合方式；
- TOPSIS 或其他 MCDM 终选如何表达具体场景中的公平优先级。
