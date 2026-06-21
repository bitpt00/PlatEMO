---
knowledge_id: K-shrinkage-spread-imbalanced-mop-diversity-diagnostics
name: 收缩-扩散率的不平衡 MOP 多样性诊断
type: method
status: active
source_papers: [P2026-0257]
aliases: [shrinkage-spread rate, global shrinkage rate, local spread rate, net spread rate, imbalanced MOP, epsilon-MDNDS, diversity recovery bound, IMP benchmark, 收缩扩散率, 不平衡多目标优化, 多样性恢复诊断, 净扩散率]
promotion_reason: 单篇论文提出但理论和实现接口完整，包含全局/局部收缩率、全局/局部扩散率、net spread rate、epsilon-MDNDS、定量 imbalanced MOP 定义、多样性恢复概率界和可调 IMP benchmark，可直接用于不平衡 MOP 诊断、benchmark 生成和 diversity-first EMOA 设计。
---

# 收缩-扩散率的不平衡 MOP 多样性诊断

## 核心内容

不平衡多目标问题的关键不是单纯 PF 形状复杂，而是种群一旦聚集到 favored subset，后续随机全局探索和局部开发都几乎没有足够机会重新生成与现有解互不支配的多样化候选。该方法用 shrinkage rate 衡量“新解会支配并淘汰当前解”的概率，用 spread rate 衡量“新解与当前解互不支配并能共存”的概率。二者差值 net spread rate 直接表示多样性动力学：为正则多样性可维持，为负或接近零则容易崩塌且难恢复。

```text
population
-> estimate global shrinkage/spread by search-space sampling
-> estimate local shrinkage/spread by neighborhood direction sampling
-> r_g = q_g - p_g
-> r_l = q_l - p_l
-> epsilon-MDNDS tracks effective distinguishable PF coverage
-> diagnose diversity collapse and recovery potential
-> design selection/dominance mechanisms to keep r_g, r_l positive
```

P2026-0257 用该框架给出 imbalanced MOP 的定量定义，并构造 IMP1-IMP10 作为可调难度测试套件。

## 建立理由

- 为什么值得独立维护：
  - imbalanced MOP 过去多是描述性概念，缺少可计算诊断量；
  - 普通 IGD/HV 只能评价最终结果，不能解释多样性为何崩塌；
  - net spread rate 把 dominance landscape、selection pressure 和 diversity recovery 连接成一个可监控信号；
  - 该框架可用于 benchmark 诊断、算法设计原则和在线控制器。
- 单篇具体方法的直接复用价值：
  - P2026-0257 给出 Definitions 1-6、Theorem 1、Monte Carlo 估计、epsilon-MDNDS、IMP1-IMP10、F8/F81 诊断、五算法对比和扩展十算法验证。
- 与已有设计知识的区别：
  - 不同于“愿望-保留水平驱动的复合质量指标”：该知识聚合离线 QI；本知识解释种群动态和多样性恢复概率。
  - 不同于“受限子问题变换组合的基准生成”：该知识生成多 PS 区域 MMOP；本知识生成/诊断 convergence-diversity imbalance。
  - 不同于“复杂度分组的目标子空间排序”：该知识处理 NAS 中性能/资源目标优化难度不平衡；本知识处理 PF favored/unfavored 区域导致的种群多样性崩塌。
  - 不同于普通 diversity selection：本知识给出何时 diversity 机制足以恢复崩塌的可计算条件。

## 解决的问题

- 适用场景：
  - 算法在某些 MOP 上反复收敛到 PF 少数区域；
  - 怀疑问题存在 favored/unfavored PF 区域；
  - 需要区分“PF/PS 本身复杂”和“convergence-diversity imbalance”；
  - 需要构造可调多样性维护难度的 benchmark；
  - 需要为 diversity-first EMOA 设计 feedback signal。
- 现有方法为什么会失败或不足：
  - crowding distance、reference vectors 或 HV contribution 只能做选择，不能量化恢复概率；
  - 只看最终 IGD/HV 难以分辨是收敛失败还是 diversity collapse；
  - convergence-first selection 在 favored subset 附近会持续淘汰 unfavored 探索个体；
  - aging/stochastic preservation 能延迟崩塌，但若不改变 net spread rate，崩塌后仍难恢复；
  - 固定 benchmark 无法连续调节 imbalance severity。
- 仍需解决的问题：
  - 高维 search space 和复杂约束下 Monte Carlo 估计成本高；
  - 离散/组合问题中局部方向球不自然；
  - 多目标数很高时 epsilon-MDNDS 和 dominance 关系可能退化；
  - 如何把诊断信号稳定嵌入在线算法仍需设计。

## 为什么可能有效

```text
shrinkage rate measures convergence pressure
spread rate measures coexistence opportunity
net spread rate = spread - shrinkage
-> positive: diversity has expected growth/support
-> near zero or negative: diversity contracts or cannot recover
imbalanced MOP = diversity collapse + net spread recovery potential decays
therefore effective algorithms must reduce shrinkage or increase spread
```

核心假设是：Pareto dominance 或改造后的 dominance 关系主导种群存活，且随机全局/局部采样能近似算法产生新解的机会结构。如果算法强依赖模型生成、修复算子或问题专用启发式，简单均匀采样估计的 rates 可能低估实际恢复能力。

## 实现接口

- 输入：
  - 当前 population 与目标值；
  - 可采样的 search space 或参考采样集；
  - 可采样的局部邻域方向；
  - dominance 或改造后的 dominance relation；
  - Monte Carlo sample size `M`；
  - `epsilon-MDNDS` 的距离阈值 `epsilon` 和崩塌阈值 `K`。
- 输出：
  - `p_g(P)`、`q_g(P)`、`p_l(P)`、`q_l(P)`；
  - `r_g(P)`、`r_l(P)`；
  - `|epsilon-MDNDS|`；
  - imbalance diagnosis 和 diversity recovery warning。
- 插入位置：
  - benchmark characterization；
  - EMOA 运行时多样性监控；
  - dominance/partition/niche 参数控制；
  - algorithm selection 或 restart policy。
- 最小实现：

```text
estimate_global_rates(P, M):
    U <- sample_uniform_search_space(M)
    for x in P:
        p_g[x] <- mean(u dominates x for u in U)
        q_g[x] <- mean(u nondominated_with x for u in U)
    return mean(p_g), mean(q_g)

estimate_local_rates(P, M, delta):
    for x in P:
        U <- sample_unit_directions(M)
        X_local <- x + delta * U
        p_l[x] <- mean(x_local dominates x)
        q_l[x] <- mean(x_local nondominated_with x)
    return mean(p_l), mean(q_l)

r_g <- q_g - p_g
r_l <- q_l - p_l
N_eps <- cardinality(epsilon_MDNDS(P))
```

## 如何用于算法创新

### 局部创新

- 当 `r_g<0` 时增加全局探索或跨区域移民；当 `r_l<0` 时调高局部 diversity preservation。
- 用 `r_g/r_l` 反馈调节 epsilon-dominance、D-dominance、reference-vector subregion 或 niching radius。
- 在每个 objective subregion 单独估计 net spread rate，对低 spread 子区提高保留名额。
- 在 mutation/crossover 中偏向能产生 spread direction 的局部扰动，而不是只强化 Pareto improvement direction。
- 设计 collapse detector：`|epsilon-MDNDS|<K` 且 `r_g/r_l` 接近 0 时触发重启、反向搜索或保留 inferior solutions。

### 结构创新

- Imbalanced-MOP 专用 EMOA：

```text
diversity dynamics observer
-> net spread diagnosis
-> dominance relation controller
-> subregion quota controller
-> spread-direction variation
```

- Benchmark factory：用目标 `r_g/r_l` 和 `epsilon-MDNDS` 作为难度标签，生成 mild/medium/severe imbalance 实例。
- Algorithm selection：检测出 imbalanced MOP 时优先推荐 MOEA/D-M2M、DrEA、D-dominance、objective partitioning 或 diversity-first frameworks。
- 与多模态 MOO 结合：目标空间 net spread 负责 PF 覆盖，决策空间多实现指标负责 PS 覆盖。

## 适用条件与风险

- 适用条件：
  - 可以定义支配关系和互不支配关系；
  - search space 或近似采样集可得；
  - 局部邻域采样有自然定义；
  - 目标是诊断 diversity collapse 或设计 diversity-first 机制；
  - 问题的主要困难来自 favored/unfavored PF 区域，而不是纯噪声或评价误差。
- 不适用或可能失效的条件：
  - 高维连续空间中均匀采样极低效，global rates 估计方差大；
  - 组合/离散问题无自然单位方向球；
  - 强约束问题中大量随机样本不可行，需要可行域采样替代；
  - many-objective 下 dominance 几乎失效，spread/shrinkage 都可能失真；
  - 算法使用强模型生成器或领域修复，均匀随机采样不代表实际 offspring 分布；
  - `epsilon` 或 `K` 设置不合适会误判 collapse。
- 计算与实现成本：
  - Monte Carlo 估计对 population size 和 sample size 线性或近线性增长；
  - local rate 需要大量局部方向评价或目标近似；
  - 若目标评价昂贵，必须用代理、缓存或已评价邻域样本估计；
  - online 使用时应低频触发或只对子区代表解计算。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0257 | 作者指出 imbalanced MOP 的 favored subset 更易访问，unfavored subset 难发现，convergence-first EMOAs 会早熟到 favored subset | 问题动机 | Introduction，PDF 1-2 |
| P2026-0257 | Definition 1 将 global shrinkage rate 定义为随机 search-space 解支配给定解的概率，等价 dominance region 体积比例 | 作者提出的指标 | Sec. II-A，PDF 3-4 |
| P2026-0257 | Definition 2 将 global spread rate 定义为随机 search-space 解与给定解互不支配的概率 | 作者提出的指标 | Sec. II-A，PDF 4 |
| P2026-0257 | Definition 3/4 分别用局部方向上的 Pareto improvement directions 和 spread directions 定义 local shrinkage/spread rates | 作者提出的指标 | Sec. II-B，PDF 4-5 |
| P2026-0257 | Monte Carlo 方法通过全局 search-space 采样和局部单位 hypersphere 方向采样估计四类 rates | 计算方法 | Sec. II-C，PDF 5-6 |
| P2026-0257 | Definition 5 提出 `epsilon-MDNDS`，用 complete-linkage clustering 统计可区分非支配解簇数 | 作者提出的多样性指标 | Sec. III-A，PDF 6 |
| P2026-0257 | global/local net spread rates 被定义为 `q_g-p_g` 和 `q_l-p_l`，正值支持多样性，负值导致收缩压力 | 核心机制 | Sec. III-B，PDF 7 |
| P2026-0257 | Definition 6 用 diversity collapse 和 net spread recovery potential 衰减两个条件定量定义 imbalanced MOP，实验中 `K<=5` | 作者提出的定义 | Sec. III-C，PDF 7 |
| P2026-0257 | Theorem 1 证明在 imbalanced 条件下，collapse 后让 `epsilon-MDNDS` cardinality 翻倍的概率低于 0.1 | 理论结果 | Sec. III-D，PDF 7-8 |
| P2026-0257 | MOEA/D-M2M 的 objective partitioning 把部分原支配对变为互不竞争，从而降低 shrinkage rates | 算法机理解释 | Sec. III-E，Fig. 3，PDF 8 |
| P2026-0257 | DrEA 的 D-dominance 缩小 dominance region、扩大 mutually nondominated region，同时降低 shrinkage 和提高 spread | 算法机理解释 | Sec. III-E，Fig. 3，PDF 8 |
| P2026-0257 | 构造 IMP1-IMP10，其中 IMP1-6 为二目标，IMP7-10 为三目标，决策维数 30，参数 `c` 控制 imbalance severity | benchmark 构造 | Sec. IV-B，PDF 9 |
| P2026-0257 | Table I 中 IMP1-IMP10 的 `r_l(P)` 均为 `10^-3` 量级，说明接近 PS 后 diversity recovery potential 极低 | benchmark 诊断 | Sec. IV-C，Table I，PDF 11 |
| P2026-0257 | 作者指出 ZCAT 的 difficulty 主要来自 intrinsic problem complexity，不同于本文 convergence-diversity imbalance；F8/F81 满足本文定义 | 概念区分与外部诊断 | Sec. IV-C，PDF 11 |
| P2026-0257 | NSGA-II、MOEA/D、RVEA 在 IMP1-IMP10 上严重丢失多样性，MOEA/D-M2M 和 DrEA 能保持更完整 PF 覆盖 | 实验支持 | Sec. IV-D，Figs. 4-5，PDF 10-11 |
| P2026-0257 | DrEA 和 MOEA/D-M2M 在 IGD/HV 上总体强于 NSGA-II、MOEA/D、RVEA，扩展到十算法后仍保持优势 | 综合对比支持 | Sec. IV-D，Tables II-III、Appendix V，PDF 12-13 |
| P2026-0257 | NSGA-II 在 IMP1/IMP7 上 `r_g/r_l` 快速跌至近 0，而 MOEA/D-M2M 在 IMP7 上保持 `r_g≈0.3`、`r_l≈0.5` | 动态验证 | Sec. IV-D，Fig. 6，PDF 13 |
| P2026-0257 | F8 上 NSGA-II 的 `r_l<0.025` 且衰减，MOEA/D-M2M 的 `r_l` 早期升高并稳定在约 0.3 | 外部 benchmark 动态验证 | Sec. IV-D，Fig. 6，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- IMP1-IMP10 具体函数、定理完整证明、复杂度和附加实验在 Appendix 中，Markdown 只抽取主文摘要。
- Monte Carlo 估计依赖采样空间定义，约束/离散/昂贵问题需改造。
- `epsilon-MDNDS` 的阈值和 `K` 对问题规模、目标数、population size 的泛化仍需更多验证。
- 论文主要提供理论诊断和 benchmark，不直接给出新的可复用优化器。
- 作者对未来工作没有单独展开，后续研究方向需从限制中推断。

## 待确认

- 如何在约束、离散、混合变量、many-objective 和 expensive MOP 中稳定估计 rates；
- 均匀采样 rates 与具体算法 offspring 分布之间偏差有多大；
- `epsilon-MDNDS` 是否应按 reference vectors、PF 曲率或目标尺度自适应；
- net spread rate 反馈控制是否能稳定提升现有 NSGA-II/MOEA/D/RVEA；
- IMP benchmark 参数 `c` 与实际算法难度之间是否可建立单调难度标尺；
- 与多模态 PS 覆盖指标、决策空间多样性指标结合时如何避免重复保护。
