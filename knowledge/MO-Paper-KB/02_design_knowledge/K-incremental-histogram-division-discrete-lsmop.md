---
knowledge_id: K-incremental-histogram-division-discrete-lsmop
name: 增量直方图与决策空间划分的离散大规模 MOO
type: method
status: active
source_papers: [P2026-0200]
aliases: [TSLEA, AIHLM, DSD, adaptive incremental histogram learning model, decision space division, histogram-guided MOEA, discrete LSMOP, edge task offloading MOEA, 两阶段学习引导, 增量直方图, 决策空间划分, 离散大规模多目标优化]
promotion_reason: 单篇论文提出但接口明确，包含变量级离散直方图模型、历史-当前概率增量更新、Pareto rank 加权 bin height、全局采样、决策空间聚类分区和局部子区直方图搜索，可直接改造离散大规模 MOO、任务分配和资源调度类问题。
---

# 增量直方图与决策空间划分的离散大规模 MOO

## 核心内容

对离散大规模多目标问题，不把变量强行 relaxation 到连续空间，也不先做降维丢弃变量，而是为每个离散决策变量维护一个 histogram probability model。每个 bin 表示该变量取某个离散值的概率；概率由历史模型和当前 population 的 Pareto-rank 加权分布增量更新。算法先在全局原始离散空间中按直方图采样，再把 population 聚类成多个 decision-space subregions，在每个子区域内重建局部直方图并采样精修。

```text
discrete high-dimensional population
-> per-variable histogram PRO_i
-> update by historical PRO_i and current rank-weighted PD_i
-> sample offspring directly in original discrete space
-> cluster population into decision-space subregions
-> build local histograms inside each subregion
-> local sampling search and environmental selection
```

P2026-0200 的 TSLEA 将该方法用于 edge task offloading，决策变量是每个任务分配到哪个 edge server，目标为 delay、cost 和 load balance。

## 建立理由

- 为什么值得独立维护：
  - 很多 LSMOEA 面向连续变量，处理离散任务分配时需要 relaxation 或修复，容易引入不稳定。
  - 变量分组、降维和 problem transformation 可能丢失原高维离散空间的有用结构。
  - 直方图模型轻量、无参数分布假设，天然适配每个变量取值集合不同的离散问题。
  - 历史-当前增量更新能在保持全局统计记忆的同时跟随 population 演化。
- 单篇具体方法的直接复用价值：
  - P2026-0200 给出 TSLEA、AIHLM、DSD、复杂度、三真实数据集、60 个任务卸载实例、EA/ML 双线对比和消融。
  - 消融显示 AIHLM 与 local search 均提升 HV；TSLEA-ALL 去掉二者后整体最差。
  - 该方法可以脱离 edge task offloading，作为离散 LSMOP 的通用 offspring generator。
- 与已有设计知识的区别：
  - 不同于“连续偏好编码的学习引导离散 MOO”：该知识把离散 Top-K 问题转成连续偏好分数并学习改进方向；本知识直接维护每个离散变量的取值概率，不做连续化编码。
  - 不同于“收敛区间变量重要性与自感知资源分配”：该知识扰动连续变量估计重要性并分组分配预算；本知识用离散直方图直接生成候选。
  - 不同于“决策-目标双空间双种群均匀搜索”：该知识通过双种群和空间均匀性控制交配；本知识用 probability model 学习变量取值分布。
  - 不同于普通 EDA：本知识用 Pareto rank 加权 bin height 和 decision-space division 形成全局-局部两阶段搜索。

## 解决的问题

- 适用场景：
  - 决策变量数百到数千；
  - 每个变量是离散类别、资源编号、路径节点、机器/服务器/车辆分配或任务模式；
  - 目标为多目标或 many-objective，需要保持收敛和多样性；
  - 连续化搜索和修复容易造成不稳定；
  - 仍希望保留原始高维离散空间信息。
- 现有方法为什么会失败或不足：
  - SBX/多项式变异等连续算子不适合类别型变量；
  - variable grouping 和 decision reduction 会降低维度，但可能删掉仍有价值的变量区域；
  - shallow neural model 只用当前代样本，训练不足时容易过拟合或误导；
  - winner-loser 学习只利用局部配对关系，忽视整个 population 的离散分布；
  - 纯全局概率采样后期 exploitation 不足。
- 仍需解决的问题：
  - 变量间强依赖时，独立 per-variable histograms 可能破坏组合结构；
  - 取值数很大时，每个变量维护完整 histogram 成本上升；
  - Euclidean clustering 对类别型变量未必最合适；
  - 动态环境中历史概率可能过时。

## 为什么可能有效

```text
good solutions reveal useful discrete value frequencies
-> Pareto rank gives multiobjective superiority signal
-> rank-weighted histogram raises probability of values used by good solutions
-> historical probability smooths sampling and avoids one-generation noise
-> global sampling preserves original high-dimensional coverage
-> subregion histograms exploit local regularities around promising clusters
```

关键假设是：优质个体在单变量取值频率上包含可复用信息。如果问题的性能主要由高阶变量组合决定，而单变量边际分布很弱，独立直方图会不足，需要加入 pairwise 或 block-wise dependency model。

## 实现接口

- 输入：
  - 离散 population `P`；
  - 每个变量的可行取值集合或上下界；
  - 多目标 fitness 和 Pareto rank；
  - population size `S`、变量数 `D`、最大取值数 `K`；
  - generation index `g`、最大代数 `Gmax`；
  - subregion 数 `alpha` 和 local search ratio `theta`。
- 输出：
  - 全局 histogram model `PRO_i`；
  - 各 subregion 的局部 histogram；
  - 采样 offspring；
  - 更新后的 non-dominated population。
- 插入位置：
  - 离散 MOEA 的 reproduction operator；
  - 大规模任务分配、资源调度、路由选择、服务部署的候选生成层；
  - 与 NSGA-II、MOEA/D、RVEA 或其他环境选择器组合。
- 最小流程：

```text
initialize PRO_i[j] uniformly for every variable i and value j

for generation g:
    rank <- nondominated_sort(P)
    for each variable i:
        WH_i[j] <- rank_weighted_count(P, i, j, rank)
        PD_i[j] <- normalize(WH_i[j])
        lr <- g / Gmax
        PRO_i[j] <- (1 - lr) * PRO_i[j] + lr * PD_i[j]

    O_global <- sample_each_variable_from(PRO_i)

    clusters <- cluster_population(P, alpha)
    for each cluster q:
        region <- centroid_radius_region(cluster q)
        PRO_q <- build_or_update_local_histogram(cluster q)
        O_local <- sample_within_region(PRO_q, theta)

    P <- environmental_selection(P + O_global + O_local)
```

- P2026-0200 的默认实例：
  - edge task offloading 三目标：delay、economic cost、load balancing；
  - problem scale：`K={25,50,75,100,125}` servers，tasks `{100,500,1000,3000}`；
  - population size `S=100`；
  - maximum fitness evaluations `1.0e5`；
  - `theta=0.3`；
  - `alpha=5`；
  - HV reference point 由所有算法多次运行得到的 nadir point 乘以 `1.1`。

## 如何用于算法创新

### 局部创新

- 将 Pareto rank weight 换成 HV contribution、R2 contribution、reference-vector scarcity 或 constraint violation-aware score。
- 对每个变量维护 entropy，熵过低时注入随机探索或重置低置信 bins。
- 用 adaptive `lr` 替换 `g/Gmax`，由 HV 改善率、model drift、population entropy 或 stagnation 控制。
- 把独立 histogram 扩展为 pairwise histogram、factor graph、Bayesian network 或 block-wise EDA，处理变量依赖。
- DSD 中用 Hamming distance、Gower distance、assignment-specific distance 或 graph edit distance 替代 Euclidean distance。

### 结构创新

- 离散 LSMOP 两阶段 EDA：

```text
global marginal probability learning
-> original-space discrete sampling
-> decision-space clustering
-> local probability refinement
-> MOEA environmental selection
```

- 与动态优化结合：维护短期和长期两套 histograms，环境变化后优先使用短期模型。
- 与鲁棒调度结合：bin score 同时考虑目标均值、方差和最坏场景表现。
- 与在线决策结合：离线 TSLEA 产出高质量 Pareto templates，在线系统根据当前负载快速选择或微调。
- 与迁移优化结合：把上一个城市、时间段、服务器配置或任务类型学到的 histogram 作为新任务初始化。

## 适用条件与风险

- 适用条件：
  - 决策变量是离散类别或整数编号；
  - 每个变量的可行取值集合可枚举；
  - 优质解在变量边际分布上有稳定统计信号；
  - 可以接受每代维护 `D*K` 级别概率表；
  - 有适合的环境选择器处理多目标 trade-off。
- 不适用或可能失效的条件：
  - 变量间强耦合，单变量取值本身没有意义；
  - 取值空间巨大且不可枚举；
  - 可行性依赖复杂全局约束，逐变量采样后大多不可行；
  - 动态系统变化快，历史模型持续误导；
  - 类别变量没有自然几何意义，但仍用 Euclidean clustering 划分局部区域。
- 计算与实现成本：
  - global search 约 `O(DSK)`；
  - local search 约 `O(alpha DSK)`；
  - 非支配排序环境选择约 `O(N^3)`；
  - 高维高取值数下需稀疏 histogram 或 top-k bin 压缩。
- 解释风险：
  - 算法优越性来自 AIHLM、DSD、环境选择和特定 task offloading 模型组合，不能单独归因于直方图模型。
  - TSLEA 在 ML 对比中更优但波动更大，实时稳定性要求高的应用需要额外策略。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0200 | 将 edge task offloading 建成三目标 LSMOP，目标包括 task time delay、economic cost 和 load balancing | 应用建模 | Sec. III-B，PDF 4-5 |
| P2026-0200 | 个体为 `D` 维向量，每个变量表示任务分配到哪个 edge server，取值来自可覆盖任务的服务器集合 `pi_i` | 编码设计 | Sec. IV-A、Fig. 2、Algorithm 1，PDF 5 |
| P2026-0200 | Algorithm 2 给出 TSLEA，两阶段包括 AIHLM global search 和 DSD local search，再进行环境选择 | 作者提出的方法 | Sec. IV-B、Algorithm 2、Fig. 3，PDF 5-6 |
| P2026-0200 | AIHLM 为每个决策变量维护 histogram，bin 数等于变量可取值数，初始概率均匀 | 作者提出的方法 | Sec. IV-C，PDF 6 |
| P2026-0200 | 直方图用历史 `PRO(g-1)` 和当前 population 分布 `PD(g)` 增量更新，`lr=g/Gmax` | 作者提出的方法 | Sec. IV-C、Eq. (8)，PDF 6 |
| P2026-0200 | 当前分布由 adaptive incremental height 计算，个体 superiority 来自 Pareto rank 和 rank 内个体数 | 作者提出的方法 | Sec. IV-C、Eq. (9)-(11)、Algorithm 3，PDF 6 |
| P2026-0200 | DSD 用 k-means 思路将 population 分成 `alpha` 个 clusters，并由 centroid/radius 定义 subregions | 作者提出的方法 | Sec. IV-D、Algorithm 4，PDF 6-7 |
| P2026-0200 | 每个 subregion 内构建 histogram learning model 并更新 `theta Gmax` 次，用于局部 exploitation | 作者提出的方法 | Sec. IV-D、Algorithm 4，PDF 7 |
| P2026-0200 | TSLEA 总复杂度记录为 `O(N^3 + alpha DSK)` | 复杂度分析 | Sec. IV-E，PDF 7 |
| P2026-0200 | 在 EUA、Google、Alibaba 三个数据集上构造 60 个任务卸载实例，任务数最高 3000，服务器数最高 125 | 实验设置 | Sec. V-B，PDF 7 |
| P2026-0200 | TSLEA 相对 GMDEC、HDDEA、NNCSO、ALMOEA、LMOCSO、NSGAIIENS 分别在 38、31、40、37、47、45 个问题上取得更好 HV | 综合实验支持 | Sec. V-C、Tables III-V，PDF 8-10 |
| P2026-0200 | 收敛曲线显示 TSLEA 在 EUA 多数问题上早期收敛更快，尤其是任务规模 100、500、3000 | 收敛过程支持 | Sec. V-C、Fig. 4，PDF 10 |
| P2026-0200 | 与 OnDisc、RLPNet 对比时，TSLEA 平均目标值更好但标准差较大，作者指出 ML 方法更适合稳定性需求 | ML 对比与边界 | Sec. V-C、Table VI，PDF 11 |
| P2026-0200 | 消融显示 AIHLM 在 14 个 EUA 问题上提升收敛精度，local search 在 13 个问题上有效，TSLEA-ALL 整体最差 | 消融实验支持 | Sec. V-D、Table VII，PDF 11-12 |
| P2026-0200 | 参数分析中 `theta=0.4, alpha=10` 排名最好，但因计算效率选择 `theta=0.3, alpha=5` | 参数分析 | Sec. V-E、Fig. 5，PDF 12 |
| P2026-0200 | 作者指出当前算法是静态 task offloading，未来考虑动态 edge computing、cloud-edge-end collaboration 和 incomplete/noisy data | 局限与未来工作 | Sec. V-E / Conclusion，PDF 12 |

## 证据边界

- 当前只有单篇论文证据。
- 精确公式、Algorithm 图片内容和 Tables III-VII 的数值需回查 PDF。
- 实验为静态批量 offloading，未验证动态到达、服务器移动、队列演化和在线重规划。
- 直方图模型主要学习变量边际概率，变量依赖强的问题可能需要更高阶模型。
- 与 ML 方法比较的单解/解集口径不同，适用结论需要结合应用目标。

## 待确认

- 独立 per-variable histogram 在强耦合离散 LSMOP 上的性能边界；
- 离散类别变量下 DSD 的距离度量和 radius 是否应问题定制；
- 如何压缩高 `D*K` histogram 并支持超大服务器集合；
- 如何在动态 edge computing 中衰减过期概率、复用历史模型；
- 是否可加入 runtime、energy、fairness 或 reliability 等更多目标仍保持稳定。
