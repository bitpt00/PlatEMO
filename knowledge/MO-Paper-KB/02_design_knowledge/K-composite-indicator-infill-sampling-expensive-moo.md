---
knowledge_id: K-composite-indicator-infill-sampling-expensive-moo
name: 复合指标引导的昂贵多目标填充采样
type: method
status: active
source_papers: [P2026-0127]
aliases: [CI-EMO, composite indicator-guided infilling sampling, composite indicator infill, distribution-diversity-convergence indicator, 昂贵多目标复合指标采样, 复合指标填充采样]
promotion_reason: 单篇论文提出但接口清晰，包含代理候选生成后的 distribution/diversity/convergence 三指标计算、归一化、随机加权合成和单点真实评价选择，可直接作为昂贵 MOO/SAEA 的可插拔 infill sampling 层。
---

# 复合指标引导的昂贵多目标填充采样

## 核心内容

在昂贵多目标优化中，不直接把代理搜索得到的最优候选拿去真实评价，而是先从三个低成本位置指标评价候选：与当前真实非支配解的目标空间夹角表示 distribution 缺口，归一化目标空间最近邻距离表示 diversity / boundary expansion，到数据库 ideal point 的距离型信息表示 convergence。三个指标各自归一化后，用随机权重合成为 composite indicator，选择得分最高的候选做真实评价。

```text
true-evaluation database D
-> train objective-wise surrogate models
-> surrogate-assisted MOEA generates candidate population P*
-> compute I1: angular distribution gap to nondominated D
-> compute I2: normalized objective-space nearest-neighbor diversity
-> compute I3: distance-to-ideal convergence pressure
-> normalize indicators and combine with random weights
-> evaluate the best-CI candidate with expensive true objectives
-> add it to D and repeat
```

P2026-0127 的 CI-EMO 是该模式的一个实例：用 GP/Kriging 作每目标代理，用 NSGA-III 在代理目标上产生候选种群，每轮只选择 1 个候选真实评价。

## 建立理由

- 为什么值得独立维护：
  - 昂贵 MOO 的关键瓶颈不是只在代理模型精度，也在“代理候选中哪一个值得真实评价”。
  - 单一 convergence、diversity 或 uncertainty 采样标准容易错过 PF 的均匀覆盖；只合并 convergence/diversity 也可能忽略 distribution。
  - 该知识把 infill sampling 设计成轻量、目标空间位置驱动、与底层代理搜索算法解耦的模块。
- 单篇具体方法的直接复用价值：
  - P2026-0127 给出 Algorithm 1-3、`I1/I2/I3` 计算流程、归一化与随机权重合成、单指标/去指标/去归一化/采样数量消融，以及 DTLZ/ZDT/MaF/真实工程问题证据。
- 与已有设计知识的区别：
  - 不同于“愿望-保留水平驱动的复合质量指标”：该知识用于离线算法评价和 QI 聚合；本知识用于在线 infill sampling，选择下一次真实昂贵评价的候选点。
  - 不同于“稳定度调权的鲁棒代理搜索与双指标候选筛选”：该知识面向变量扰动下的 expensive robust MOO，用扰动重采样的 robust optimality 和 diversity 选点；本知识面向普通 EMOP/EMaOP，用 distribution/diversity/convergence 位置指标选点。
  - 不同于“CMA 局部区域与 MAB 多获取函数代理搜索”：该知识通过局部区域、acquisition portfolio 和 MAB 组织代理搜索；本知识可作为任意代理搜索后的候选选择层。

## 解决的问题

- 适用场景：
  - 单次真实目标评价昂贵，评价预算只有几百次；
  - 代理模型可以产生一个候选种群，但无法可靠判断所有候选的真实优劣；
  - 希望每轮只真实评价 1 个或少量候选；
  - 需要同时兼顾 PF 均匀分布、边界扩展和收敛；
  - GP/RBF/RF/分类代理等模型都可用，但不希望强依赖少样本 uncertainty。
- 现有方法为什么会失败或不足：
  - 只按预测目标最优选点会过度 exploit 代理误差；
  - 只按 uncertainty 选点会在少样本下受不可靠方差估计影响；
  - 只按 diversity 或角度补空会选到远离 PF 的点；
  - 固定权重组合会在断裂或复杂 PF 上长期偏向某一指标。
- 仍需解决的问题：
  - 多模态或强 deceptive 问题中，候选种群若整体远离 PF，目标空间 distribution 指标难以补救；
  - 高维目标下角度、距离和非支配解集合的区分度可能下降；
  - 批量真实评价时，多点之间需要额外去冗余；
  - 随机权重鲁棒但缺少问题特异性，需自适应调权。

## 为什么可能有效

```text
distribution angle finds sparse PF directions
nearest-neighbor distance expands boundary and coverage
ideal-distance convergence prevents sampling only far-away sparse points
normalization makes the three scores comparable
random weights avoid repeatedly enforcing one fixed sampling preference
```

关键假设是：代理搜索产生的候选种群 `P*` 已经包含部分有希望的候选，且数据库中的非支配解能够粗略反映当前 PF 覆盖状态。如果代理候选全部偏离 PF，或数据库非支配解本身严重误导，复合指标只能在坏候选中相对选择，无法单独恢复搜索。

## 实现接口

- 输入：
  - 真实评价数据库 `D`，含决策变量和真实目标值；
  - 代理搜索产生的候选种群 `P*` 及其预测目标值；
  - 数据库目标最小/最大值和当前非支配集 `D_nd`；
  - 每轮真实评价预算 `q`，最小实现为 `q=1`。
- 输出：
  - 候选的 `I1/I2/I3/CI` 分数；
  - 被选中做真实评价的候选集合。
- 插入位置：
  - surrogate-assisted MOEA 的 infill sampling 层；
  - Bayesian optimization 的 acquisition 后处理层；
  - expensive constrained MOO 中可行候选的真实评价调度层；
  - 多保真算法中高保真评价点选择层。
- 最小实现：

```text
D_nd <- nondominated_solutions(D)
for x in P*:
    I1[x] <- min_angle(Fhat(x), F(D_nd))

normalize objectives of P* and D with min/max from D
for x in P*:
    I2[x] <- distance_to_nearest_solution(Fnorm(x), Fnorm(P* union D - {x}))
    I3[x] <- convergence_score_from_distance_to_ideal(Fnorm(x), z)

normalize I1, I2, I3 over P*
draw r1, r2, r3 from U(0, 1)
CI[x] <- r1*I1[x] + r2*I2[x] + r3*I3[x]
return argmax_x CI[x]
```

## 如何用于算法创新

### 局部创新

- 把随机权重改为阶段自适应权重：早期提高 convergence，接近 PF 后提高 distribution 和 diversity。
- 按 reference vector、目标空间 cluster 或候选所在区域独立调节 `I1/I2/I3` 权重。
- 将 `I3` 替换或补充为 LCB、expected improvement、hypervolume improvement 或 surrogate error-aware convergence。
- 将 `I1/I2` 扩展到决策-目标双空间，避免多模态 MOP 只保持目标空间分布而丢失 Pareto set 多样性。
- 在约束问题中增加 feasibility probability、constraint violation boundary distance 或可行域稀疏度作为第四指标。
- 批量 infill 时，先用 CI 排序，再用角度/距离/DPP/clustering 做去冗余，避免一次选中高度相似候选。

### 结构创新

- 构建通用 SAEA infill 层：

```text
candidate generator
-> objective-space status indicators
-> normalized composite infill score
-> true-evaluation scheduler
-> database update
```

- 与局部代理结合：先在多个 reference-vector 局部区生成候选，再在全局数据库上计算 CI，兼顾局部模型精度和全局 PF 覆盖。
- 与多保真优化结合：低保真/代理候选通过 CI 进入高保真队列，高保真结果再校正代理和指标权重。
- 与自动算法配置结合：把是否启用 `I1/I2/I3`、权重策略和 `q` 作为可配置组件，由 racing 或 RL 自动选择。
- 与 large-scale EMOP 结合：变量子空间或降维模型只负责候选生成，CI 仍在真实目标空间判断是否值得评价。

## 适用条件与风险

- 适用条件：
  - 数据库中已有一定数量真实评价点；
  - 目标值可以归一化，且数据库 min/max 不极端失真；
  - 候选种群规模足够，让角度和距离指标有选择空间；
  - 真实评价昂贵到值得每轮精挑细选；
  - 主要关心目标空间 PF 质量。
- 不适用或可能失效的条件：
  - 初始数据库太差或代理候选整体远离 PF；
  - 多模态 MOP 需要保持决策空间多样性，但 CI 只看目标空间；
  - noisy objective 下数据库非支配层不稳定；
  - many-objective 下角度与距离趋同，指标区分度降低；
  - 批量并行评价时直接取 top-q 会选到相似点；
  - 真实约束、评价时间差异或多保真误差未纳入指标。
- 计算与实现成本：
  - `I1` 需要候选与数据库非支配集计算角度；
  - `I2` 需要候选与数据库/候选集合计算最近邻距离；
  - `I3` 只需到 ideal point 的距离型计算；
  - P2026-0127 给出的 CI 候选选择复杂度为 `O(m n N)`，通常小于 GP 训练 `O(m n^3)` 和代理内进化搜索成本。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0127 | 作者指出 EMOP/EMaOP 中真实评价预算少，candidate selection 对 SAEA 性能关键 | 问题动机 | Abstract、Sec. I，PDF 1-2 |
| P2026-0127 | 论文区分 distribution 和 diversity：前者是解集在 PF 上均匀分布，后者更偏边界扩展和目标空间极端区域探索 | 概念区分 | Sec. I，PDF 2 |
| P2026-0127 | Algorithm 1 给出 CI-EMO：LHS 初始化、每目标 GP、SA-NSGA-III 生成候选、CI 选点、真实评价更新数据库 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4 |
| P2026-0127 | Algorithm 2 用 NSGA-III 在代理目标上生成候选种群 `P*` | 作者采用/组合方法 | Sec. III-B，Algorithm 2，PDF 4 |
| P2026-0127 | Algorithm 3 用非支配数据库解计算 `I1`，用归一化目标空间最近邻距离计算 `I2`，用到 ideal point 的距离型指标计算 `I3`，再随机加权合成 CI | 作者提出的方法 | Sec. III-C，Algorithm 3，PDF 4-5 |
| P2026-0127 | DTLZ/ZDT 19 个 EMOP 的 IGD+ 上，CI-EMO 相对五个对比算法胜出数为 18/12/9/15/14，劣于数为 0/4/4/3/3 | 综合实验支持 | Sec. IV-B，Table 1，PDF 5-6 |
| P2026-0127 | MaF 33 个 EMaOP 的 IGD+ 上，CI-EMO 相对五个对比算法胜出数为 29/15/15/26/25，劣于数为 1/5/10/4/4 | many-objective 支持 | Sec. IV-C，Table 2，PDF 6-7 |
| P2026-0127 | 单指标消融显示 `I1-EMO/I2-EMO/I3-EMO` 整体均弱于 CI-EMO，其中 `I3` 单独使用最容易缺少多样性 | 消融实验支持 | Sec. IV-E，PDF 8-9 |
| P2026-0127 | 去掉任一指标都会导致退化；不同问题偏好不同指标，说明复合而非固定单指标有必要 | 消融实验支持 | Sec. IV-E，PDF 9 |
| P2026-0127 | `CI-EMO-no-Norm` 在 11 个问题上显著劣于 CI-EMO，说明指标归一化重要 | 消融实验支持 | Sec. IV-E，PDF 9 |
| P2026-0127 | 固定权重与随机权重整体相近，但随机权重在 ZDT3 断裂 PF 上更鲁棒，能避免固定偏好 | 参数/机制证据 | Sec. IV-E，PDF 9-10 |
| P2026-0127 | 采样数量实验中 q=5/q=10 通常退化，作者认为不必要的候选会浪费真实评价预算 | 参数/预算证据 | Sec. IV-E，PDF 10 |
| P2026-0127 | CI 选择复杂度为 `O(m n N)`，相对 GP 训练和 SA-NSGA-III 内部搜索较轻 | 复杂度说明 | Sec. IV-D，PDF 8 |
| P2026-0127 | Gear train 和 two bar truss 工程问题上 CI-EMO 的 HV 最佳，car side impact 上不是最佳但处于前列 | 真实应用支持 | Sec. IV-F，Table 7，PDF 10 |
| P2026-0127 | 作者指出随机权重缺少 specificity，未来会研究自适应权重，并扩展到大规模优化 | 作者局限与未来工作 | Conclusion，PDF 11 |

## 证据边界

- 当前只有单篇论文证据。
- 指标主要依赖目标空间，未系统验证决策空间多模态、多等价 Pareto set 或 noisy objective。
- 多模态 ZDT4/DTLZ3 上仍困难，说明代理候选质量不足时 CI 不能单独解决收敛问题。
- 批量真实评价只做了 q 数量消融，没有给出严格的并行 batch infill 设计。
- 部分 HV 表来自 supplementary，主卡只记录作者报告的胜负统计。

## 待确认

- `I1/I2/I3` 权重是否应按阶段、reference vector 或问题特征自适应；
- many-objective 下角度与距离指标是否需要降维、局部归一化或 reference-vector 分区；
- noisy/uncertain 评价下如何稳定数据库非支配集和 ideal point；
- 约束、混合变量、多保真和异构评价时间场景中应加入哪些额外指标；
- 批量并行昂贵评价时如何在 CI top candidates 中去冗余。
