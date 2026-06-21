---
knowledge_id: K-stability-weighted-robust-surrogate-candidate-selection
name: 稳定度调权的鲁棒代理搜索与双指标候选筛选
type: method
status: active
source_papers: [P2026-0175]
aliases: [KPI, DPAF, dual-perspective aggregation function, robust optimality indicator, DI-PD, expensive robust MOO, Kriging-assisted robust MOO, stability-level weighting, mean-worst robust objective, 双视角鲁棒替代目标, 稳定度调权, 鲁棒候选筛选]
promotion_reason: 单篇论文提出但接口完整，包含 Kriging-LCB 代理评价、平均/最差双视角 DPAF 稳定度调权、基于重采样非支配层分布的 robust optimality indicator、hierarchical clustering 过滤和 ROI/Div 双指标真实评价候选选择，可直接改造 ExRMOP 与不确定多目标优化的代理搜索和 infill 层。
---

# 稳定度调权的鲁棒代理搜索与双指标候选筛选

## 核心内容

在 expensive robust multiobjective optimization 中，不固定使用平均性能或最差性能作为 replaced objective。先用代理模型在每个解的扰动邻域内评价 resampled solutions，计算平均性能和最差性能；再用当前种群的扰动稳定度 `Gamma` 调权：种群稳定时偏向平均性能以保持 optimality，种群不稳定时偏向最差性能以强化 robustness。代理内搜索结束后，不直接选预测最优解真实评价，而是先用 resampled solutions 的全局非支配层分布计算 robust optimality indicator `ROI`，过滤 robust optimality 差的候选，再用 `ROI` 与目标空间数据库距离 `Div` 组成双指标支配关系，选择少量兼顾鲁棒最优性和多样性的候选做真实评价。

```text
true evaluation database
-> train objective-wise surrogate
-> generate offspring and resample each solution under perturbation
-> surrogate evaluates resampled neighborhoods
-> compute average performance and worst performance
-> compute population stability Gamma
-> DPAF = (1-Gamma)*average + Gamma*worst
-> surrogate evolutionary search under DPAF
-> compute ROI from nondomination-level distribution of resamples
-> filter high-ROI candidates by clustering
-> select true-evaluation candidates by ROI + diversity distance
-> update database
```

P2026-0175 的 KPI 是该模式的实例：代理使用 Kriging-LCB，每轮 DPAF-based evolutionary search 运行 20 代，真实评价候选数 `mu=5`，扰动重采样数 `K=50`。

## 建立理由

- 为什么值得独立维护：
  - Robust MOO 中 average perspective 和 worst perspective 的偏好不同：前者偏 optimality，后者偏 robustness。固定使用一方会造成系统偏置。
  - ExRMOP 中真实评价极贵，不能每代真实评价所有新解；需要把鲁棒目标构造和真实评价候选选择都做成代理闭环。
  - `ROI` 把“重采样解所在非支配层的序号”和“跨层范围”合成一个可实现指标，能同时反映扰动下的 optimality 和 robustness。
  - 该设计给出完整接口：代理评价、扰动重采样、双视角 replaced objective、候选过滤、双指标真实评价。
- 单篇具体方法的直接复用价值：
  - P2026-0175 给出 Algorithm 1-4、DPAF 公式、ROI/Div/DI-PD 公式、TP/DTLZ benchmark、组件消融和 LS-DYNA 汽车前端结构真实 ExRMOP 证据。
- 与已有设计知识的区别：
  - 不同于“策略跟随评估的风险感知层级多目标规划”：该知识用下层运营策略和 CVaR 风险诊断评价长期规划方案；本知识面向变量扰动下的 ExRMOP 代理搜索，不是层级 follower 评估。
  - 不同于“结构-场景双罚项的模糊鲁棒随机规划”：该知识在数学规划模型中区分结构和场景约束罚项；本知识是进化代理算法中的鲁棒 replaced objective 与候选筛选。
  - 不同于“网格排序成对关系代理筛选”：该知识学习候选间 pairwise relation；本知识不学习关系代理，而是用扰动重采样的非支配层分布定义 robust optimality。
  - 不同于“收敛-边界两步代理采样更新”：该知识面向昂贵约束 MOO 的收敛/边界训练样本更新；本知识面向不确定扰动鲁棒性和 robust-diverse 候选真实评价。

## 解决的问题

- 适用场景：
  - 决策变量存在制造误差、材料波动、环境扰动或其他 perturbation；
  - 单次目标评价昂贵，但代理模型可以近似扰动邻域表现；
  - 希望同时保留 nominal/mean optimality 与 worst-case robustness；
  - 需要从代理搜索产生的大量候选中挑选少量真实评价点；
  - 可以对每个候选生成 resampled solutions，并能定义扰动区域。
- 现有方法为什么会失败或不足：
  - 只用平均性能会选择平均表现好但尾部脆弱的解；
  - 只用最差性能会过度保守，牺牲 optimality；
  - 两个种群分别优化 average/worst 可能通信弱，不能形成单一可控权重；
  - 代理辅助 RMOEA 若仍真实评价每代新解，无法处理真正昂贵场景；
  - 只按预测目标或平均/最差性能选择真实评价候选，可能忽略扰动后非支配层分布和数据库覆盖。
- 仍需解决的问题：
  - 高维扰动和大数据库下代理建模与重采样排序成本很高；
  - `Gamma` 是全局权重，可能无法适配不同 Pareto 区域的稳定性差异；
  - many-objective 下非支配层分布可能退化；
  - 代理误差会同时影响 average、worst、`Gamma` 和 `ROI`。

## 为什么可能有效

```text
average performance rewards optimality
worst performance rewards robustness
population stability indicates whether robustness is already adequate
-> stable population: spend search pressure on optimality
-> unstable population: spend search pressure on robustness
-> DPAF avoids fixed robust-objective bias
resampled NDL distribution measures both rank quality and perturbation spread
-> ROI filters fragile or dominated candidates
-> diversity distance prevents all true evaluations near existing database
```

关键假设是：代理模型在扰动邻域内能给出足够可靠的相对评价，且 `Gamma` 能代表当前种群是否需要更多 robustness pressure。如果代理在扰动边界处偏差大，或不同前沿区域稳定性差异很大，全局 `Gamma` 和 `ROI` 可能误导搜索。

## 实现接口

- 输入：
  - 真实评价数据库 `DB`；
  - 扰动区域定义和 resampling 数 `K`；
  - 每目标代理模型训练器；
  - 代理内 evolutionary search 算子；
  - 每轮真实评价候选数 `mu`。
- 输出：
  - DPAF replaced objectives；
  - 代理搜索最终种群 `OP` 和重采样集合 `RP`；
  - 需要真实评价的候选集合；
  - 更新后的 `DB`。
- 插入位置：
  - Robust MOO/RMOEA 的 replaced objective 层；
  - expensive robust optimization 的 surrogate-assisted search loop；
  - 不确定 MOO 的 infill/candidate selection 层。
- 最小实现：

```text
M <- train_surrogates(DB)
for inner_generation in 1..G:
    UP <- parents union variation(parents)
    for x_i in UP:
        RP_i <- LHS_resample_perturbation_region(x_i, K)
        Fhat_i <- surrogate_LCB(M, RP_i)
        a_i <- average(Fhat_i)
        w_i <- worst(Fhat_i)
        gamma_i <- robustness_from_first_last_NDL_distances(Fhat_i)
    Gamma <- population_stability(gamma)
    DPAF_i <- (1-Gamma) * normalize(a_i) + Gamma * normalize(w_i)
    parents <- environmental_selection(UP, DPAF, surrogate_objectives)

OP <- parents
RP <- resamples_of(OP)
ROI <- nondomination_level_distribution_indicator(RP)
OP1 <- hierarchical_cluster_keep_low_ROI(OP)
Div <- negative_nearest_database_distance(OP1, DB)
C <- select_by_DI_PD_and_ROI(OP1, ROI, Div, mu)
evaluate_true(C)
DB <- DB union C
```

## 如何用于算法创新

### 局部创新

- 将 DPAF 的 average/worst 扩展为 mean、variance、quantile、CVaR、probability of failure、regret 或 reliability index。
- 把全局 `Gamma` 改为 reference-vector、cluster 或 subpopulation 级 `Gamma`，不同前沿区域独立调节 optimality/robustness 压力。
- 给 `Gamma` 加入代理不确定性校准：代理越不可靠，越保守或越优先真实评价校准点。
- 将 hierarchical clustering 从二分过滤改为多层预算分配，让部分高 `ROI` 但高不确定候选仍有探索机会。
- 把 `Div` 从目标空间最近邻距离扩展为决策-目标双空间距离、robust objective-space distance 或 scenario coverage distance。
- 用 sparse GP、local GP、RBF ensemble、multi-fidelity surrogate 或 conformal prediction 替换 Kriging-LCB。

### 结构创新

- 构建 ExRMOP 通用代理框架：

```text
perturbation sampler
-> surrogate neighborhood evaluator
-> multi-perspective robustness aggregator
-> robust-diverse infill selector
-> true evaluation database updater
```

- 与高维子空间代理结合：先用变量重要性或 active subspace 降低代理输入维度，再在子空间内执行 DPAF 和 ROI。
- 与多保真仿真结合：低保真模型用于大量 perturbation resampling，高保真 FE 只验证 DI-PD 选中的候选。
- 与偏好优化结合：决策者可调 `Gamma` 或给定最低 robustness threshold，DPAF 自动在 ROI 区域内寻找偏好解。
- 与鲁棒约束处理结合：把 constraint violation 在扰动邻域的 NDL/quantile 纳入 `ROI` 或 DI-PD。

## 适用条件与风险

- 适用条件：
  - 变量扰动范围可以定义并采样；
  - 真实评价昂贵，代理和重采样评价相对便宜；
  - 代理能在局部扰动邻域提供有用排序；
  - 目标数不太高，非支配排序仍有区分力；
  - 需要在 optimality 和 robustness 间动态折中，而不是固定风险态度。
- 不适用或可能失效的条件：
  - 变量维数高且数据库大，Kriging 训练和 `NK` 重采样排序过重；
  - 目标数很高，resampled solutions 大多互不支配，`ROI` 区分度下降；
  - 扰动分布不明确或非盒形，LHS 在扰动区域内采样不代表真实不确定性；
  - 代理在扰动边界或 worst-case 区域误差大；
  - 真实鲁棒性由稀有极端事件决定，固定 `K` 重采样可能漏掉风险；
  - 全局 `Gamma` 掩盖不同区域稳定性差异。
- 计算与实现成本：
  - 每轮训练 `m` 个代理；
  - 代理内每代对 `2N` 个解各生成 `K` 个重采样解；
  - DPAF 和 ROI 均依赖非支配排序；
  - KPI 复杂度主要为 `O(mD|DB|^3 + mN^2K^2)`，高维或大 `DB` 时需替换或压缩代理。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0175 | 作者指出 average perspective 偏 optimality、worst perspective 偏 robustness，既有 replaced objectives 往往忽略二者互补 | 问题动机 | Sec. I，Fig. 1，PDF 1-2 |
| P2026-0175 | Algorithm 1 给出 KPI：Kriging 建模、20 代 DPAF 代理搜索、双指标候选筛选、真实评价更新数据库 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4 |
| P2026-0175 | Kriging 的预测均值和不确定性用 LCB 形式 `y_hat - s_hat` 近似原始目标，鼓励一定探索 | 作者采用/组合方法 | Sec. II-B，Eq. (7)-(9)，PDF 4 |
| P2026-0175 | Algorithm 2 对每个解的 `K` 个 perturbation resamples 计算 average/worst performance、`gamma` 和 population stability `Gamma` | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 4-5 |
| P2026-0175 | DPAF 公式为 `(1-Gamma)*a/a_max + Gamma*w/w_max`；`Gamma` 小偏 average，`Gamma` 大偏 worst | 作者提出的方法 | Sec. III-B，Eq. (17)，PDF 5 |
| P2026-0175 | Algorithm 3 在 Kriging 代理上用 DPAF 做 20 代 SBX/PM 搜索和环境选择 | 作者提出的方法 | Sec. III-C，Algorithm 3，PDF 6 |
| P2026-0175 | Algorithm 4 先用 `ROI` 和 hierarchical clustering 淘汰 robust optimality 差的候选，再用 `ROI` 与 `Div` 的 DI-PD 选 `mu` 个真实评价候选 | 作者提出的方法 | Sec. III-D，Algorithm 4，PDF 7 |
| P2026-0175 | `ROI` 是每个候选 resampled solutions 所在全局非支配层序号的平均，层序号高或跨层范围大都会增大 `ROI` | 作者提出的方法 | Sec. III-D，Eq. (18)，PDF 7 |
| P2026-0175 | `Div` 定义为到数据库最近邻目标空间距离的负值，因此值越小越能增强数据库 diversity | 作者提出的方法 | Sec. III-D，Eq. (19)，PDF 7 |
| P2026-0175 | TP 上 KPI 在 25/27 个问题取得最小 `Rmean` 和 `Rworst`；DTLZ 上 KPI 在 10 个问题上最好，高于各对比算法 | 综合实验支持 | Sec. IV-D，Tables IV-VII，PDF 9-10 |
| P2026-0175 | KPI 用 300 FEs 多数情况下优于 MOEA-RE/CNSDE-DVC 的 3000 FEs，支持代理用于 ExRMOP | FE 效率证据 | Sec. IV-D，PDF 10 |
| P2026-0175 | Friedman test 中 KPI 的 `Rmean` 平均排名 2.00、`Rworst` 平均排名 2.06，为九个算法最佳 | 综合排名证据 | Sec. IV-D，Fig. 7，PDF 11 |
| P2026-0175 | DPAF 消融中 KPI 在 `Rmean` 上胜过 KPI-Ave/KPI-Wor/KPI-TwoArch2 的问题数为 13/8/16，在 `Rworst` 上为 12/9/16 | 消融实验支持 | Sec. IV-E，Table VIII，PDF 11 |
| P2026-0175 | Candidate selection 消融显示去掉 hierarchical clustering 或用 average/worst 替换 `ROI` 后多数 TP 问题退化 | 消融实验支持 | Sec. IV-E，Table VIII，PDF 11 |
| P2026-0175 | 汽车前端结构 LS-DYNA 设计中每次评价约 1 小时，KPI 在 5 次运行的 `Rmean/Rworst` 上最稳定且均值小于六个竞争算法 | 真实应用支持 | Sec. V，Fig. 9、Table X，PDF 12 |
| P2026-0175 | 作者承认本文只考虑最多 20 维低维 ExRMOP，未来将扩展到高维 ExRMOP | 作者局限与未来工作 | Sec. VI，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- Benchmark 决策维度最高 20，真实应用只有 6 维；高维 ExRMOP 尚未验证。
- 表格多为图片，逐项数值需从 PDF 或 supplementary 核验。
- 多个对比算法是用 MEOF 改造的 expensive MOO 算法，不一定代表专门设计的最强 ExRMOP 版本。
- Kriging 训练复杂度和 `K=50` 重采样排序会限制大规模应用。
- 论文没有系统讨论噪声、约束、many-objective、非盒形扰动和稀有尾部风险。

## 待确认

- 如何把 KPI 扩展到高维问题：稀疏/局部/降维 Kriging、子空间扰动采样或训练集压缩是否足够；
- `Gamma` 是否应区域化、目标化或随搜索阶段加平滑；
- `ROI` 在 many-objective 或高度退化前沿上是否还能区分 robust optimality；
- 固定 `K=50` 是否能捕获真实制造/材料扰动的尾部风险；
- 代理不确定性如何进入 DPAF、`ROI` 和候选真实评价决策；
- 与约束鲁棒、多保真仿真、混合变量和动态扰动场景如何结合。
