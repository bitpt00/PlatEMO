---
knowledge_id: K-multineighbor-multiknowledge-mtom-transfer
name: 多邻域多知识的分解式多任务迁移
type: method
status: active
source_papers: [P2026-0191, P2026-0240, P2026-0243]
aliases: [MOMA, MTEA/D-MNK, MMTEA-DAKT, dual-neighborhood multifactorial transfer, Q-learning neighborhood size, positive transfer ratio, multi-neighbor multitask transfer, multiple knowledge types transfer, decomposition-based adaptive knowledge transfer, adaptive subproblems selection, adaptive transfer evolution, AKT, ASS, external neighbor by gray relational analysis, evolutionary trend knowledge, MO-MTO decomposition transfer, 多邻域多任务迁移, 多知识类型迁移, 分解式多任务优化, 子问题自适应选择, 迁移算子池, 双邻域迁移, 正迁移率]
promotion_reason: 多篇论文共同支持的分解式 MO-MTO 迁移知识，包含 MOEA/D 子问题分解、任务内/任务间多邻域、静态决策分布相似性、动态演化趋势知识、解级知识类型/迁移概率控制，以及子问题改进率驱动的迁移比例分配和迁移算子池选择，可直接改造 MO-MTO、工程多场景优化、NAS 和多任务协同搜索。
---

# 多邻域多知识的分解式多任务迁移

## 核心内容

在多目标多任务优化中，不把跨任务迁移简化为随机个体交换、固定迁移概率或单一 crossover，而是把任务分解成可比较的子问题，并在子问题层控制“向谁迁移、迁移多少、用哪类知识/算子迁移”。P2026-0240 的路线为每个分解子问题维护任务内 whole population/internal neighbor、任务间 external neighbor、population evolutionary trend 等多种邻域和知识类型，并给每个解维护知识类型选择概率 `kt` 与迁移概率 `tr`。P2026-0243 的路线进一步根据每个子问题的 fitness improvement rate 选择迁移对象，并用滑动窗口记录迁移算子收益，从 `Sp/Uf/Geo/SBX/DE` 算子池中选择当前更合适的 transfer operator。

```text
tasks -> MOEA/D weight-vector subproblems
for each solution/subproblem:
    estimate subproblem improvement and/or neighbor/task similarity
    choose local/global/internal/external/evolution-trend knowledge or transfer operator
    generate offspring with matching operator
    update internal or external neighbor by ASF improvement
    update external neighbor via intertask similarity when used
    adapt kt/tr or operator credit from search feedback
```

P2026-0191 的 MOMA 将该思想用于 multi-task FFJSS：每个个体维护同任务 internal neighborhood 和跨任务 external neighborhood，用 Q-learning 根据 Pareto front 的收敛/多样性状态选择邻域大小，并从全局 subproblem 视角更新外部邻域以提高 positive transfer ratio。P2026-0240 的 MTEA/D-MNK 用该机制解决汽车形状设计中的 Sedan/SUV 双任务优化，也在 CEC2017/CEC2019 MO-MTO benchmark 上验证。P2026-0243 的 MMTEA-DAKT 则在 CEC2017/CEC2019/CEC2021、many-task MATP 和 CIFAR-10/CIFAR-100 NAS 应用上验证了子问题改进率分配和迁移算子池反馈选择。

## 建立理由

- 为什么值得独立维护：
  - MO-MTO 的核心风险是负迁移和迁移不足；单一知识类型或固定概率无法适应任务相似性、搜索阶段和解质量差异。
  - 该知识把迁移问题拆成清晰接口：子问题分解、邻域/任务关系、知识类型或迁移算子、迁移概率/迁移预算、反馈更新。
  - 它既能改造 MOEA/D-based MTO，也能迁移到多场景工程设计、多工况调度、多数据集 NAS 或多源代理协同。
- 单篇具体方法的直接复用价值：
  - P2026-0240 给出 MTEA/D-MNK Algorithm 1-5、四类邻域结构、external neighbor 灰色关联更新、演化趋势知识、`kt/tr` 自适应更新、19 个 benchmark 和实际汽车应用证据。
  - P2026-0243 给出 MMTEA-DAKT Algorithm 1-3、Adaptive Subproblems Selection、Adaptive Transfer Evolution、滑动窗口算子 credit、三套 MMTOP benchmark、many-task benchmark 和 NAS 应用证据。
- 与已有设计知识的区别：
  - 不同于“参考解引导的跨任务知识迁移”：该知识用全局参考解给迁移方向；本知识在 MOEA/D 子问题层维护多邻域，并区分静态/动态、任务内/跨任务知识。
  - 不同于“动态辅助任务构造”：该知识动态生成辅助任务；本知识不生成新任务，而是在已有任务之间控制知识类型和迁移量。
  - 不同于“异步子任务精英池协同进化”：该知识通过精英池共享；本知识通过 neighbor graph、gray relational matching 和 per-solution transfer probability 迁移。
  - 不同于“成功率反馈的算子与参数自适应选择”：该知识的一部分会调迁移算子，但核心对象是跨任务/跨子问题知识路由与迁移预算，而不是普通单任务算子参数。

## 解决的问题

- 适用场景：
  - 多个任务、多种车型、多工况、多数据集或多个相关工程场景需要同时优化；
  - 各任务可映射到统一或可比较的决策空间；
  - 每个任务都是 MOP，且可用 MOEA/D、参考向量或子问题分解；
  - 任务之间既可能有正迁移，也可能因相似性不足而负迁移；
  - 希望在不同搜索阶段使用不同知识源、迁移强度或迁移算子。
- 现有方法为什么会失败或不足：
  - 随机跨任务交配忽略任务相似性；
  - 固定迁移概率不能反映每个解携带信息质量不同；
  - 单一 objective-space knowledge 无法利用决策空间结构；
  - 只看静态分布相似性可能漏掉演化方向一致但当前位置不同的任务；
  - 只看动态趋势可能忽略当前邻域的局部可替换关系；
  - 单一 transfer operator 无法适应不同任务复杂度、编码类型和搜索阶段。
- 仍需解决的问题：
  - 如何在线学习任务图和迁移边权；
  - 如何避免 `kt/tr` 随噪声改进反复波动；
  - 多峰任务中用均值代表邻域分布是否可靠；
  - 多于两个任务时 external neighbor 维护成本和冲突如何控制。

## 为什么可能有效

```text
task similarity varies by region and stage
-> decompose each task into subproblems
-> use internal neighbors for stable local exploitation
-> use external neighbors only where decision distributions are similar
-> use evolutionary trend when dynamic search directions align
-> adapt transfer amount from ASF/Tchebycheff improvement feedback
-> adapt transfer operator from sliding-window transfer success
-> reduce negative transfer while preserving useful cross-task information
```

关键假设是：子问题邻域中的决策分布、演化趋势和近期 improvement rate 能反映可迁移知识。如果任务统一编码不可靠、相似性度量失真、短期改进与长期收益不一致，或目标评价噪声主导 ASF/Tchebycheff 改进，迁移控制可能仍会误导搜索。

## 如何用于算法创新

### 局部创新

- 在 MOEA/D-MTO 中加入 external neighbor：用任务间决策分布相似性为每个 source subproblem 找 target subproblem。
- 把灰色关联分析替换为 MMD、Wasserstein distance、cosine embedding、CCA、domain adaptation loss 或 learned task graph。
- 将 `tr` 的 ASF relative improvement 替换为 HV contribution、IGD improvement、offspring survival rate、constraint repair success 或真实迁移收益。
- 对不同知识类型设置独立成功记忆，而不是单一 `kt`。
- 对 `Sp/Uf/Geo/SBX/DE/repair/generator` 等迁移算子设置滑动窗口、UCB 或 Thompson sampling credit。
- 将 Adaptive Subproblems Selection 从“最快收敛子问题”扩展为 exploration-exploitation 平衡，保留对停滞但有潜力子问题的迁移机会。
- 在 low-similarity tasks 中降低 direct individual transfer，提高 trend/abstract knowledge transfer 比例。
- 将固定 internal/external neighborhood size 改为 Q-learning、bandit 或贡献率反馈控制，并用 positive transfer ratio 监控邻域规模是否导致负迁移。
- 在组合优化中先设计统一编码，再把多邻域迁移分别作用于不同编码片段，例如 routing、sequencing、feature mask 或 architecture block。

### 结构创新

- 构建多任务知识路由器：

```text
task/subproblem graph
-> candidate knowledge types: local, internal, external, trend, surrogate, archive
-> candidate transfer operators: crossover, DE, repair, domain adaptation, generator
-> per-edge, per-subproblem or per-solution transfer probability
-> offspring generation with selected knowledge/operator
-> transfer success feedback
```

- 对多场景工程设计，每个场景保留自己的 Pareto 子问题，同时通过 neighbor graph 共享局部形状/调度/配方模块。
- 与代理模型结合：把 source task 的 surrogate uncertainty 和 target task 的真实改进共同作为迁移准入条件。
- 与动态 MOO 结合：把历史环境视作任务，用演化趋势知识判断哪些历史环境可向当前环境迁移。
- 与 NAS 结合：把不同数据集、模型规模预算或硬件约束视作任务，在子问题层共享架构片段或算子搜索经验。

## 适用条件与风险

- 适用条件：
  - 存在多个相关任务，且可以统一编码或跨任务映射；
  - 每个任务有足够 population/subproblem 支持邻域统计；
  - 子问题聚合函数能衡量 offspring 对局部目标方向的改进；
  - 至少能记录迁移后短期 success/failure 或 improvement；
  - 任务间相似性不是完全未知或完全为负。
- 不适用或可能失效的条件：
  - 任务决策空间语义不一致，均值/方差相似不代表可迁移；
  - 任务数量很大，external neighbor 更新和相似性矩阵成本过高；
  - 任务间真实相关性强非线性，多变量均值和灰色关联难以捕捉；
  - 评价噪声使 ASF improvement 不稳定，`tr` 更新误判；
  - 滑动窗口过短时，偶然成功会让 transfer operator credit 偏置；
  - 只选择最快收敛子问题可能加剧 exploitation，忽略困难但有潜力的区域；
  - 过度跨任务迁移会削弱任务特定可行性或约束满足。
- 计算与实现成本：
  - 需要维护每个任务/子问题的 internal/external neighbors、ideal points、`kt/tr`；
  - external neighbor 更新需要计算源/目标邻域决策统计和相似度；
  - evolutionary trend 需要维护历史均值/标准差；
  - 算子池式 AKT 需要记录 operator/improvement 滑动窗口并处理冷启动；
  - 代码复杂度显著高于普通 MOEA/D-MTO，但可逐模块启用。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0240 | MTEA/D-MNK 在 MOEA/D 框架下为每个任务生成 weight vectors，把 MO-MTO 分解成子问题并维护 internal/external neighbors | 作者提出的方法 | Sec. III-C，Algorithm 1-2，PDF 6-7 |
| P2026-0240 | 四类邻域结构分别对应 whole population、internal neighbor、external neighbor 和 population evolution trend，覆盖任务内/跨任务、目标空间/决策空间、静态/动态知识 | 作者提出的方法 | Sec. III-C3，Fig. 4，PDF 7-8 |
| P2026-0240 | External neighbor 用灰色关联分析在目标任务中寻找与源任务内部邻域决策均值最相似的子问题邻域，避免无关邻域造成负迁移 | 作者提出的方法 | Sec. III-C4，Algorithm 5，PDF 8-9 |
| P2026-0240 | `kt` 用正态扰动和随机重置更新，`tr` 每 30 代按 ASF relative improvement 更新，以控制知识类型和迁移量 | 作者提出/组合方法 | Algorithm 1；Sec. IV，PDF 6、9 |
| P2026-0240 | CEC2017 上 IGD 18 个任务中 13 个第一、5 个第二；HV 17 个有效任务中 14 个第一、3 个第二 | 综合实验支持 | Sec. IV-D，Table II-III，PDF 11 |
| P2026-0240 | CEC2019 上 MTEA/D-MNK 在每个任务的 IGD 和 HV 上都优于对比算法，Wilcoxon 检验显著优于五个算法 | 综合实验支持 | Sec. IV-D，PDF 11 |
| P2026-0240 | 消融显示完整算法平均 Friedman ranking 最好，去掉所有改进的 MTEA/D-NS 最差，去掉自适应参数的 MTEA/D-NA 第二 | 消融实验支持 | Sec. IV-E，Table V，PDF 12 |
| P2026-0240 | 作者解释 external neighbor 在中低相似任务上更有效，evolutionary trend knowledge 在高中相似任务上更有效，自适应参数可降低负迁移 | 机制解释 | Sec. IV-E，PDF 12 |
| P2026-0240 | 实际 Sedan/SUV 双任务车身优化中，MTEA/D-MNK 的 IGD/HV Friedman ranking 最好，并能产生可视上符合汽车形态的 Pareto designs | 工程应用支持 | Sec. IV-F，Fig. 6-8，Table VII，PDF 12-14 |
| P2026-0191 | MOMA 为 multi-task FFJSS 设计 routing/sequencing 统一表示，并在每个个体上维护 internal neighborhood 与 external neighborhood | 作者提出的方法 | Sec. III-A-B，Fig. 3-4，PDF 4-5 |
| P2026-0191 | Q-learning 根据收敛和多样性变化的四种状态，从 `{5,10,15,20}` 中选择 dual-neighborhood size | 作者提出/采用的方法 | Sec. III-D，PDF 5-6 |
| P2026-0191 | Dual-neighborhood transfer 按概率从 internal/external neighborhoods 选父代，统一表示下执行 POX/UX 和 mutation | 作者提出的方法 | Sec. III-E，Algorithm 1，Fig. 5，PDF 6-7 |
| P2026-0191 | Improved neighborhood update 从全局 subproblem 视角评价 transferred individual，允许其更新其他 subproblem 的邻域 | 作者提出的方法 | Sec. III-F，Fig. 6，PDF 7 |
| P2026-0191 | 八类 multi-task FFJSS 场景中，MOMA 综合 IGD/HV 排名优于 MOMFEA、MTEA/D-DN、LRVMA、MOEA-DCH、NSGA-II、MOEA/D | 综合实验支持 | Sec. IV-D，Tables III-IV，PDF 9-10 |
| P2026-0191 | 消融 Friedman 排名为 `MOMA > Variant2 > Variant1 > MTEA/D-DN`，支持自适应邻域大小与改进邻域更新均有效 | 组件消融 | Sec. IV-D.3，Tables V-VI，PDF 10 |
| P2026-0191 | Positive transfer 分析中 `NW` 和 `R=NP/NT` 排名为 `MOMFEA < MTEA/D-DN < Variant1 < Variant2 < MOMA` | 迁移效率证据 | Sec. V-A，Table VII，PDF 11 |
| P2026-0191 | transfer probability 敏感性显示多数场景推荐 0.1-0.3，高概率通常导致性能退化 | 参数证据 | Sec. V-B，Fig. 8，PDF 11-12 |
| P2026-0191 | 作者指出固定 transfer probability 和迁移知识缺乏解释性是局限 | 作者局限 | Sec. VI，PDF 12 |
| P2026-0243 | MMTEA-DAKT 在 MOEA/D 框架中先用 Adaptive Subproblems Selection 按子问题改进率分配迁移比例，再用 Adaptive Transfer Evolution 从 `Sp/Uf/Geo/SBX/DE` 中选择迁移算子 | 作者提出的方法 | Sec. III-A-C，Algorithm 1-3，PDF 5-7 |
| P2026-0243 | 作者用 MOEA/D 单任务实验显示同组任务达到 `IGD <= 1e-3` 所需 FEs 可相差十倍以上，用算子实验显示 SBX/Geo 等在不同任务和阶段表现不同 | 动机实验支持 | Sec. II-C，Fig. 1-2，PDF 3-4 |
| P2026-0243 | CEC2017 上 MMTEA-DAKT 相比 MO-MFEA-II、MTEA/D-DN、EMTET、MTDE-MKTA 分别在 18/18、18/18、17/18、18/18 个 case 更好 | 综合实验支持 | Sec. IV-D，Table I，PDF 9-10 |
| P2026-0243 | CEC2019 上 MMTEA-DAKT 相对四个 dominance-based 算法在 20、19、20、20 个 case 更好，且优于 MTEA/D-DN 全部 case；CEC2021 上 18 个 case 中 13 个最佳 | 综合实验支持 | Sec. IV-D，Table II-III，PDF 10 |
| P2026-0243 | Many-task MATP1-MATP5 中，MMTEA-DAKT 相比五个对比算法分别更好于 120、141、247、193、137 个问题，MATP2/MATP5 Friedman rank 为 1.2/1.78 | 多任务扩展实验支持 | Sec. IV-D，Table V，PDF 11 |
| P2026-0243 | 消融显示只保留 ASS、只保留 AKT 或去掉两者均弱于完整方法；用 MTEA/D-DN 框架或 MOMFEA-SADE adaptive DE 替换核心模块也不及完整方法 | 消融实验支持 | Sec. IV-E，Table VI；Table S.X，PDF 11-12 |
| P2026-0243 | NAS 应用中，MMTEA-DAKT 同时搜索 CIFAR-10/CIFAR-100，在 NAS-Bench-201 上达到 91.15%/93.93% 与 72.52%/72.11% 的验证/测试准确率 | 应用实验支持 | Sec. V，Table VII，PDF 13 |

## 待确认

- 灰色关联与其他任务相似性度量的相对稳定性；
- `kt/tr` 更新是否应加入长期 credit assignment 和不确定性；
- 子问题改进率和算子滑动窗口是否应按 source-target task pair 条件化；
- ASS 选择最快收敛子问题是否会遗漏停滞但有潜力的困难区域；
- 多于两个任务时，外部邻域和演化趋势知识是否会产生冲突；
- 对强约束、多峰、动态或异构维度任务是否需要先做 domain adaptation；
- 迁移知识是否能被解释为具体变量组、形状区域或工程特征。
