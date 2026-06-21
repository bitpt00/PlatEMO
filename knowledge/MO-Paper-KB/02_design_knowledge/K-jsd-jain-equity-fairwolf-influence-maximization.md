---
knowledge_id: K-jsd-jain-equity-fairwolf-influence-maximization
name: JSD-Jain 比例公平扩散与 FairWolf 种子搜索
type: architecture
status: active
source_papers: [P2026-0165]
aliases: [FairWolf, FMOIM, Fair Multi-objective Influence Maximisation, equity fair influence maximization, JSD Jain fairness, JS similarity fairness, proportional allocation fairness, explorer-augmented leader selection, HV-triggered perturbation, discrete multi-objective grey wolf optimizer, 公平影响力最大化, 社区比例公平扩散, JSD公平, Jain公平, 离散种子集搜索]
promotion_reason: P2026-0165 单篇提出但接口完整：先把 fair influence maximisation 建成 `spread + equity fairness` 双目标，公平目标由 realised activation distribution 与 community-size reference 的 JSD alignment 和 `P_j/Q_j` 的 Jain proportional balance 组成；再用 FairWolf 在固定预算 seed set 上做离散 set-swap 搜索，并用 sparse explorer leaders 与 HV-triggered perturbation 改善 Pareto front 覆盖和停滞。该架构可直接迁移到公共健康触达、广告曝光、推荐资源分配和公平图干预。
---

# JSD-Jain 比例公平扩散与 FairWolf 种子搜索

## 核心内容

在公平扩散或影响力最大化中，不只最大化总激活数，也不只用一个黑箱 fairness score。先把每个候选 seed set 的社区激活比例 `P` 与期望参考比例 `Q` 对齐：JSD similarity 衡量整体分布是否接近参考，Jain fairness index 衡量每个社区的 benefit-to-reference ratio 是否均衡。二者合成 equity fairness 目标，与 influence spread 共同形成 Pareto 优化。搜索层直接在固定大小 seed set 上做 set-swap，避免连续编码修补；leader 既来自 non-dominated archive，也来自稀疏 objective-grid 区域；当 archive HV 长时间不改善时，只对部分个体做小扰动。

```text
graph + community partition + seed budget
-> candidate seed set S
-> diffusion simulation estimates spread and community activations
-> P: realised activation shares
-> Q: reference community shares
-> fairness = lambda * JSsim(P,Q) + (1-lambda) * Jain(P/Q)
-> bi-objective archive: max spread, max fairness
-> FairWolf set-swap update with core leaders + sparse explorer leaders
-> HV stagnation triggers small seed swaps
-> Pareto seed sets for spread-fairness trade-off
```

P2026-0165 的实例是 FairWolf：在 8 个真实网络上用 2-hop IC 主评价，并在 Ham 网络上用 full IC 检查主要结论。

## 建立理由

- 为什么值得独立维护：
  - 许多 IM 只看总传播，会让高连接社区过度受益；
  - 单一 fairness proxy 难区分“整体分布错配”和“某些社区比例失衡”；
  - JSD + Jain 的组合把公平诊断拆成两个可解释维度，便于后续偏好调节；
  - fixed-budget seed set 是离散集合，set-swap update 比连续向量修补更直接；
  - sparse explorer leaders 与 HV-triggered perturbation 是通用 archive-based 离散 MOO 停滞处理层。
- 单篇具体方法的直接复用价值：
  - P2026-0165 给出 FMOIM 定义、JSD/Jain 公平目标、FairWolf Algorithm 2、discrete position update、explorer leader selection、HV perturbation、8 个真实网络、消融、参数敏感性、full IC 对照和公平解释图。
- 与已有设计知识的区别：
  - 不同于“逐步熵公平与 Dirichlet 权重的扩散优化”：该知识关注扩散过程中每一步的群体触达公平和自适应权重；本知识关注终态/评价窗口内的社区比例分配公平，并用 JSD + Jain 拆解公平含义。
  - 不同于“连续时间竞争扩散的多目标图干预 RL”：该知识处理竞争信息、传播时间和多轮 RL 干预；本知识处理 fixed-budget seed set 的 Pareto 搜索和社区分配公平。
  - 不同于“级联失效鲁棒影响与结构成本种子优化”：该知识关注攻击/级联失效下的鲁棒影响和结构成本；本知识关注正常传播中的社区公平分配。
  - 不同于一般 MOGWO archive：本知识把 continuous update 改成 seed-set swap，并显式增加稀疏 explorer leader 与 HV stagnation 触发扰动。

## 解决的问题

- 适用场景：
  - influence maximization、public health messaging、emergency information diffusion、广告触达、推荐曝光、教育/就业机会传播；
  - 图节点可划分为社区、地区、人群或业务 group；
  - 需要同时看总触达和各 group 是否按某个 reference 公平受益；
  - 决策输出需要一组 Pareto seed sets，而不是单一固定权重解；
  - 种子集合大小固定，候选生成必须保持 cardinality feasibility。
- 现有方法为什么会失败或不足：
  - total spread 最大化偏向 hub-rich communities；
  - maximin fairness 可能过度保护最弱社区并牺牲总扩散；
  - 只看 final coverage fairness 可能无法解释偏差来自整体分布还是局部社区；
  - 标准连续 GWO/PSO 在集合空间中会产生非法或重复节点；
  - archive leader 过度集中会让 Pareto front 只覆盖一小段 trade-off。
- 仍需解决的问题：
  - reference `Q` 是否应只按社区规模，还是应加入脆弱性、风险、政策优先级；
  - 结构社区能否代表真实公平群体；
  - 2-hop 近似与 full diffusion 在不同网络上的偏差；
  - Monte Carlo 噪声如何影响 JSD/Jain 的稳定性；
  - 大图中扩散仿真、archive 和 HV monitoring 的成本控制。

## 为什么可能有效

```text
spread maximization over-serves structurally central communities
-> add community allocation objective

single equity score hides why unfairness occurs
-> JSD checks global distribution alignment
-> Jain checks community-wise proportional balance

seed selection is a fixed-size set problem
-> set-swap update preserves feasibility by construction

leaders can crowd around one PF segment
-> explorer leaders from sparse grid cells broaden guidance

archive improvement can stall
-> HV window detects stagnation and triggers small perturbations
```

关键假设是：社区划分和 reference allocation 是合理的公平评价上下文，扩散仿真能稳定估计每个社区激活比例。如果 group label 不可靠、reference 本身有争议，或真实任务更重视早期触达而非终态比例，本知识需要与过程公平、偏好学习或约束式公平结合。

## 实现接口

- 输入：
  - 图 `G=(V,E)`；
  - seed budget `k`；
  - node-to-community mapping 或 soft group membership；
  - reference allocation `Q`，默认可用 community-size proportions；
  - diffusion model，例如 IC/LT/SIR/log replay；
  - Monte Carlo 次数、最大扩散步数或 full cascade setting；
  - `lambda`、archive size、population size、grid parameters、`n_explorers`、HV window `tau`、perturbation ratio。
- 输出：
  - 每个候选 seed set 的 `spread`、`JSsim`、`Jain`、`fairness`；
  - Pareto archive；
  - 每个社区的 allocation bias `P_j-Q_j`；
  - 可部署 seed set 或 Pareto set，外加 POF/POI/WAD 等解释指标。
- 插入位置：
  - fair influence maximization fitness；
  - recommendation exposure allocation；
  - public health or emergency campaign targeting；
  - graph intervention seed selection；
  - 任意离散集合型 MOEA 的 leader selection、archive pruning 或 stagnation handling。

最小实现：

```text
initialize population of k-node seed sets
archive <- nondominated(population by spread and fairness)

for t in 1..MaxIt:
    leaders <- core_archive_leaders(archive)
    leaders += sparse_grid_explorer_leaders(archive, n_explorers)

    for each seed set S:
        leader <- sample(leaders)
        if abs(A(t)) < 1:
            S_new <- swap_toward_leader(S, leader, k)
        else:
            S_new <- swap_away_from_leader(S, leader, V, k)
        if S_new == S:
            S_new <- random_k_seed_set(V, k)

        spread, P <- simulate_diffusion(S_new)
        fairness <- lambda * JSsim(P,Q) + (1-lambda) * Jain(P/Q)

    archive <- nondominated_grid_update(archive union population)
    if HV_range(last_tau_archives) < epsilon_HV:
        perturb selected seed sets by one random swap

return archive
```

## 如何用于算法创新

### 局部创新

- 把 `Q` 改成需求/风险加权参考，例如 `Q_j proportional population_j * vulnerability_j`。
- 把固定 `lambda` 改成决策者偏好、POF/POI、HV contribution 或 under-service severity 驱动的动态权重。
- 将 `WAD=max_j |P_j-Q_j|` 作为第三目标、epsilon constraint 或 archive tie-breaker。
- 用 bootstrap 或置信下界计算 `JSsim` 和 `Jain`，减少 Monte Carlo 噪声导致的 leader 误选。
- 将 explorer leader 从 objective sparse grid 扩展到 fairness-deficient community sparse grid。
- 将 2-hop/full IC 做多保真评价：普通候选低保真，archive leaders 高保真复评。

### 结构创新

- 终态比例公平 + 过程公平双层架构：

```text
diffusion simulator
-> final proportional fairness: JSD + Jain
-> temporal fairness: step-wise entropy or delay penalty
-> multiobjective archive
-> preference selector chooses deployment seed set
```

- 公平诊断反馈式种子替换：

```text
community bias vector P-Q
-> detect under-served communities
-> bias replacement nodes toward those communities
-> preserve Pareto archive and spread diversity
```

- 动态网络滚动公平控制：

```text
time-varying graph snapshots
-> carry previous Pareto seed set
-> local set-swap repair by new P,Q
-> HV or fairness-drift trigger broader perturbation
```

## 适用条件与风险

- 适用条件：
  - 群体/社区划分可获得，并能被用于公平评价；
  - 能定义可辩护的 reference allocation `Q`；
  - seed set 大小固定，且节点选择可由仿真或日志评价；
  - 需要保留 spread-fairness Pareto trade-off；
  - 可承担 population-based Monte Carlo diffusion 成本。
- 不适用或可能失效的条件：
  - 公平更关注早期触达、等待时间或个体级 exposure，而不是最终社区比例；
  - group label 敏感、不可用或法律伦理上不能直接用于优化；
  - 社区数量很多且小社区激活样本稀疏，JSD/Jain 方差高；
  - reference `Q` 按规模分配不符合任务伦理，例如公共健康应优先高风险群体；
  - 网络巨大且每次扩散仿真昂贵，缺少并行或代理评价。
- 计算与实现成本：
  - 每次候选评价需要扩散仿真并统计 community activations；
  - archive dominance 和 grid update 随 archive/population size 增长；
  - HV monitoring 在二目标下便宜，但多目标扩展后成本增加；
  - 高保真 full IC 或大 Monte Carlo 次数需要缓存、增量估计或多保真调度。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0165 | 定义 Fair Multi-objective Influence Maximisation，候选解是固定预算 seed set，输出 spread-fairness Pareto front | 问题建模 | Sec. 3-4 |
| P2026-0165 | 公平目标由 `JSsim(P,Q)` 与 `Jain(P/Q)` 组成，`lambda=0.5` 为默认中性权重 | 作者提出/组合方法 | Sec. 4.3 |
| P2026-0165 | FairWolf 把每个 wolf 编码为 seed set，并用 set-based discrete position update 保持预算约束 | 作者提出的方法 | Sec. 5.2 / Fig. 1 |
| P2026-0165 | Explorer-Augmented Leader Selection 同时使用 core leaders 和 sparse grid explorer leaders | 作者提出的方法 | Sec. 5.2 |
| P2026-0165 | HV-triggered perturbation 在 `Delta HV < epsilon_HV` 时对部分个体做 seed swap | 作者提出的方法 | Sec. 5.2 / Algorithm 2 |
| P2026-0165 | 8 个真实网络，Leiden community detection，`k=30`，`p=0.01/0.05/0.1`，10 次独立运行 | 实验设置 | Sec. 6.1 |
| P2026-0165 | 消融中完整 FairWolf 的 HV、IGD、Spacing、Spread 和 Time 均优于 FMODGWO 与 H-FMODGWO | 消融证据 | Sec. 6.2.1 / Table 5 |
| P2026-0165 | `n_explorers=2`、`perturb=0.15` 的 S9 获得最佳 IGD/HV，`lambda=0.5` 获得最佳 HV | 敏感性证据 | Sec. 6.2.2 / Tables 6-7 |
| P2026-0165 | 主实验平均排名中 FairWolf 综合排名 3.24，为所有算法最好 | 综合对比 | Sec. 6.3.1 / Table 11 |
| P2026-0165 | Ham 网络 full IC 对照中 FairWolf 在三个传播概率下均取得最佳 HV | 近似验证 | Sec. 6.3.3 / Table 12 |
| P2026-0165 | Ham 网络 community allocation bias 分析显示 FairWolf 大多社区偏差接近 0，且 WAD 分布稳定 | 公平解释 | Sec. 6.3.1 / Figs. 6-7 |
| P2026-0165 | Data availability 为数据可按请求提供 | 数据可得性 | Data availability |

## 证据边界

- 当前直接证据来自 P2026-0165 一篇论文。
- 主实验采用 2-hop IC 近似；full IC 只在 Ham 网络做一致性检查。
- Monte Carlo 次数为 10，公平指标可能存在随机估计噪声。
- 作者未在 Markdown 中展示完整公式细节，若复现需核对 PDF 或代码。
- FairWolf 同时包含多个改动，消融只隔离 HV perturbation 与 explorer leader，未完全隔离 persistent grid、set update 和公平目标。
- 社区由 Leiden 结构检测得到，不等同于真实 demographic group。

## 待确认

- `Q` 是否应由人口规模、政策偏好、风险程度或历史欠服务共同决定；
- JSD/Jain 在社区数量极多、社区规模极不均衡时的稳定性；
- 过程公平与终态比例公平怎样联合而不重复惩罚；
- full IC、多跳近似、SIR/LT 模型下 FairWolf 优势是否一致；
- 在百万级节点上是否需要 learned influence surrogate、RIS、parallel simulation 或 streaming archive。
