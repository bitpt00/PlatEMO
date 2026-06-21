---
knowledge_id: K-cma-local-region-mab-multiacquisition-saea
name: CMA 局部区域与 MAB 多获取函数代理搜索
type: architecture
status: active
source_papers: [P2026-0101]
aliases: [AS-SMEA, CMA-RIU, LS-IMA, MASS, adaptive local region search, multi-acquisition SAEA, MAB-guided acquisition selection, CMA local region surrogate search, high-dimensional expensive MOO surrogate, 自适应局部区域代理搜索, 多获取函数代理辅助进化算法]
promotion_reason: P2026-0101 单篇提出但接口完整，覆盖 CMA-style 局部区域初始化/更新、全局 GP+TS+HV 标量化重启、局部 GP 多 acquisition 代理 MOP、RHVI/HVKG full-information MAB 候选选择，并在 69 个高维昂贵 benchmark、消融、参数敏感性、runtime 和 VLSI 真实设计流上给出证据，可复用为高维昂贵 MOO 的代理管理架构。
---

# CMA 局部区域与 MAB 多获取函数代理搜索

## 核心内容

在 high-dimensional expensive MOO 中，不直接依赖单一全局 GP 或固定降维，而是在原始高维决策空间里维护多个可自适应更新的局部搜索区域。每个区域用 CMA-style 均值和协方差描述高质量样本分布，形成椭球搜索范围；区域内训练局部 GP，并用多个 acquisition functions 生成不同搜索偏好的候选解集。随后将每个 acquisition 的候选解集视为 bandit arm，用 RHVI/HVKG 奖励选择少量代表解做真实评价。

```text
initial expensive samples
-> nondominated set and archive
-> choose diverse local-region centers
-> estimate CMA-style ellipsoid per region
-> train local GP models
-> build EI/UCB/TS/PI/PE surrogate MOPs
-> optimize each surrogate MOP
-> score candidate sets by RHVI + HVKG MAB reward
-> evaluate selected representatives
-> update/restart local regions and archive
```

该知识的核心是把“哪里搜索”和“用哪种 acquisition 取样”都变成自适应决策：CMA-RIU 负责局部区域的生命周期，MASS 负责多 acquisition 真实评价预算分配。

## 建立理由

- 为什么值得独立维护：
  - 高维昂贵 MOO 中，全局 GP 容易因样本稀疏和维度灾难而不稳定；
  - 固定降维会损失变量结构，固定局部区域又难适应搜索阶段变化；
  - 单一 acquisition 无法长期同时兼顾 exploration、exploitation、uncertainty probing 和 Pareto coverage；
  - 真实评价预算少，必须把“候选集级别”的价值判断做成低成本、可解释的代理调度机制。
- 单篇具体方法的直接复用价值：
  - P2026-0101 给出 Algorithm 1-4、区域初始化/重启、MASS 奖励设计、复杂度近似、cumulative HV regret 分析，以及 benchmark/VLSI 验证。
- 与已有设计知识的区别：
  - 不同于“MLP 子空间筛选与稀疏 GP 的高维昂贵 MOO”：该知识先识别低维敏感子空间再建 sparse GP；本知识保留原始高维空间，通过多局部椭球区域降低代理建模难度。
  - 不同于“目标级自适应代理与双空间 infill 采样”：该知识按目标选择代理模型并在决策/目标双空间采样；本知识固定 GP 建模接口，核心在 region lifecycle 与 acquisition-set bandit selection。
  - 不同于“SAMOEA 问题属性-组件-场景设计矩阵”：该知识提供综述分类和组件选择框架；本知识是一套具体架构，可作为 SAEA 主循环实现。
  - 不同于“代理训练的注意力残差子代生成器”：该知识学习 offspring generator；本知识不训练生成器，而是调度局部 GP acquisition candidates。

## 解决的问题

- 适用场景：
  - 连续 high-dimensional expensive MOO；
  - 决策变量维度高但高质量样本在局部区域内有可估计分布；
  - 真实评价预算很少，需要多种 acquisition 同时竞争；
  - 目标评估可异步或批量返回少量真实评价结果；
  - 问题存在多个 promising basins，固定单一区域或单一 trust region 易早熟。
- 现有方法为什么会失败或不足：
  - 全局 surrogate 在高维空间中样本过稀，预测均值和不确定性都会不可靠；
  - 降维型 SAEA 需要预设或学习合适子空间，若变量交互复杂则容易错删信息；
  - decomposition/indicator/trust-region 分区依赖权重、指标或阈值，搜索环境变化后不易重新布置；
  - 固定 acquisition 会在不同阶段产生偏置，例如早期开发过强或后期探索过多；
  - 逐个候选解选择容易忽略候选集对 Pareto front 的整体贡献。
- 仍需解决的问题：
  - HV/RHVI/HVKG 在 many-objective 或大候选集下计算成本较高；
  - 局部区域数、每轮真实评价候选数和 restart 频率仍需调参；
  - 对约束、多保真、混合变量或强离散问题，需要额外处理可行性和编码；
  - CMA 协方差估计依赖局部样本质量，早期样本偏差可能导致区域形状误导。

## 为什么可能有效

```text
high-dimensional global modeling is unreliable
-> restrict modeling to several promising ellipsoidal regions
-> each local GP sees denser and more coherent samples
-> multiple acquisition functions expose different search intentions
-> candidate-set reward uses Pareto-level HV information
-> bandit memory discounts stale acquisition performance
-> real evaluations flow to the currently useful region/acquisition pairs
-> region restart prevents permanent commitment to poor basins
```

关键假设是：局部高质量样本的分布能被均值/协方差近似表达，且局部区域内代理模型比全局代理更可靠。若 Pareto set 高度非椭球、多模态区域极窄或样本噪声很强，CMA-style 区域可能需要更稳健的 density model 或 ensemble region model。

## 实现接口

- 输入：
  - 已真实评价数据集 `D`，objective values 和变量上下界；
  - 外部非支配档案 `Arc`；
  - 局部区域数 `L`；
  - acquisition set，例如 `EI/UCB/TS/PI/PE`；
  - 每个 approximate MOP 的代表真实评价候选数 `k`；
  - MAB decay factor `gamma`；
  - 局部区域半径/置信参数、restart 条件和 max FE。
- 输出：
  - 局部区域集合：center、mean、covariance、ellipsoid boundary、local sample set；
  - 每个区域的 local GP models；
  - 每个 acquisition 对应的候选非支配解集；
  - MASS 选择的代表候选集；
  - 更新后的 `D`、`Arc` 和区域状态；
  - diagnostics：region HV contribution、region age、acquisition reward history、restart count、candidate survival。
- 插入位置：
  - expensive MOO/MaOO 的 surrogate management 层；
  - high-dimensional SAEA 的 local-region search module；
  - MOBO 或 Bayesian evolutionary optimization 的 acquisition scheduler；
  - 工业黑箱优化中的少量批量 infill candidate selection。

最小实现：

```text
initialize D by LHS and true evaluations
Arc <- nondominated(D)
Regions <- initialize_regions_by_HVC_and_maxmin(Arc, D)

while FE < MaxFE:
    for region in Regions:
        local_GPs <- fit_GP_per_objective(region.samples)
        candidate_sets <- {}

        for acq in [EI, UCB, TS, PI, PE]:
            surrogate_MOP <- build_objectivewise_acquisition_MOP(local_GPs, acq)
            candidate_sets[acq] <- optimize_by_NSGAII(surrogate_MOP, region.ellipsoid)

        representatives <- {}
        for acq, candidates in candidate_sets:
            representatives[acq] <- select_k_by_HVKG(candidates, Arc, k)
            reward[acq] <- gamma * reward[acq] + RHVI_HVKG(representatives[acq], Arc)

        selected <- argmax_acquisition_reward(reward)
        Y <- true_evaluate(representatives[selected])
        D, Arc, region <- update_data_archive_region(D, Arc, region, Y)

        if restart_needed(region):
            new_center <- global_GP_TS_HV_restart(D, Regions)
            region <- rebuild_region_around(new_center, D)
```

P2026-0101 的默认实例：

- `L=5`；
- 每个 approximate optimization problem 选 `k=3` 个代表解做真实评价；
- NSGA-II population size 100，最大 50 generations；
- MAB decay factor `gamma=0.75`；
- GP 使用 Matérn 5/2 ARD kernel；
- 局部区域椭球阈值 `alpha=0.99735`，近似 3-sigma rule；
- VLSI 真实问题中使用 4 个局部区域、每轮每区域 2 个真实评价候选。

## 评价与监控

- 性能指标：
  - IGD+、HV；
  - 每个 region 的 HV contribution；
  - acquisition reward trajectory；
  - restart 前后的 archive improvement；
  - 单位真实评价的 Pareto 改进。
- 消融建议：
  - 固定局部区域 vs CMA-RIU；
  - 无 restart vs HV-based restart；
  - 单 acquisition vs multi-acquisition；
  - random acquisition selection vs MASS；
  - candidate-level selection vs candidate-set-level selection；
  - 全局 GP vs region-wise local GP。
- 失败诊断：
  - 多数真实评价落在边界且 HV 不增长：acquisition 可能过度探索或区域过大；
  - reward 长期集中在单个 acquisition：需要检查 reward scaling 或候选多样性；
  - restart 频繁但无改进：global GP/TS restart 可能被噪声或 archive 偏差误导；
  - region covariance 退化：局部样本过少或高度共线，需要 shrinkage/regularization。

## 证据

- Benchmark evidence：
  - P2026-0101 在 DTLZ1-7、LSMOP1-9、MaF1-7 的 100/150/200 维设置上，与 6 个 SAEA 比较；
  - 在 DTLZ、LSMOP、MaF 上的 Friedman average rank 分别为 1.86、1.58、1.62；
  - 在超过 70% 测试场景取得最小 IGD+；
  - 2-objective DTLZ 500D 的 7 个问题上均取得最优 IGD+。
- Ablation evidence：
  - CMA-RIU 变体对比显示完整 AS-SMEA 在多数 benchmark 上显著更优；
  - 单 acquisition、随机候选选择、投票聚合均弱于 LS-IMA + MASS；
  - acquisition 选择轨迹显示早期 PI/PE 更常被选中，后期 EI/UCB/TS 动态接管。
- Real-world evidence：
  - RISC-V32I VLSI design flow，134 个工具配置参数，目标为 performance/power/area；
  - 最大真实评价 128；
  - AS-SMEA 平均 HV `1.78e5`，显著优于全部对比方法。

## 可复用变体

- Region model：
  - 用 shrinkage covariance、mixture model、normalizing flow 或 density-ratio model 替代简单 CMA covariance；
  - 对离散/混合变量使用 Hamming kernel 或 categorical embedding 后定义局部区域。
- Acquisition scheduler：
  - 将 acquisition arm 扩展为 acquisition-region pair；
  - 用 contextual bandit 引入 region age、uncertainty、HV stagnation 等状态；
  - 在 many-objective 中用 Monte Carlo HV 或 R2/IGD surrogate reward 替代精确 HV。
- Constraint extension：
  - 为每个局部区域训练 constraint GP；
  - 在 MASS reward 中加入 feasibility probability、CV reduction 或 boundary information；
  - 对 restart center 加入可行性过滤。

