# 设计知识卡

本目录保存能够跨论文复用，并可用于局部创新或结构创新的高价值知识。当前优先保存能够直接改造算法的具体方法。

设计知识可以是一种方法、一个底层原理或一种架构思路，但不再分别建立目录。每张卡统一说明：

```text
知识是什么
解决什么问题
为什么可能有效
如何用于局部创新
如何用于结构创新
适用条件和风险
论文证据
```

设计知识卡不是每篇论文一张。同一个知识只建立一张卡，由后续论文持续补充证据、适用条件和限制。

## 建卡规则

建立新卡前，必须先使用名称、别名、解决的问题和作用机制搜索现有卡片。

新建设计知识卡必须满足：

1. 能够明确说明如何用于修改算法或设计结构；
2. 能够说明解决的问题、作用机制、适用条件和风险；
3. 具有可追溯的论文证据；
4. 值得未来跨论文查询和复用。

同时还应满足以下情况之一：

- 已被至少两篇论文采用、讨论或共同支持；
- 虽然只来自一篇论文，但属于实现明确、可以直接移植或改造算法的具体方法；
- 当前研究已经明确准备使用该知识。

单篇论文中抽象出的原理、架构思路和未成熟判断，默认留在论文卡。无法判断是否与现有卡重复时，也先留在论文卡。

## 使用方式

为减少每次处理论文或设计创新时的重复阅读，默认先查看下方极简索引，不直接读取全部设计知识卡。

```text
先查看极简索引
-> 找到可能相同或相关的设计知识
-> 只打开相关卡片进行详细比较
-> 索引无法判断时，再使用关键词全文搜索
-> 不默认通读整个目录
```

创建或重命名设计知识卡，或者名称、主要解决问题、使用位置、类型、来源论文发生变化时，应同步更新下方索引。只补充卡内细节且索引字段没有变化时，不需要修改索引。极简索引只负责导航，不能替代设计知识卡中的完整证据和适用条件。

## 极简索引

| 设计知识 | 主要解决问题 | 可修改或使用位置 | 类型 | 来源论文 |
|---|---|---|---|---|
| [动态辅助任务构造](K-dynamic-auxiliary-task-construction.md) | 固定辅助任务、固定低维变体或单一子空间无法适应搜索阶段变化，尤其在高维昂贵 MOO 中会错配收敛/多样性需求 | 辅助任务生成/选择、低维变量子集、任务维度调度、阶段检测与贡献反馈 | 方法 | P2026-0001, P2026-0190, P2026-0113 |
| [参考解引导的跨任务知识迁移](K-reference-solution-guided-knowledge-transfer.md) | 多任务之间直接迁移可能产生负迁移 | 跨任务知识迁移与个体生成 | 方法 | P2026-0001 |
| [双种群共识的变量类型挖掘](K-dual-population-consensus-variable-type-mining.md) | 稀疏大规模 MOO 中关键非零变量难以识别，冗余变量误激活会浪费搜索预算 | 稀疏编码、变量重要性评分、双种群变量类型分类与类型感知繁殖 | 方法 | P2026-0152 |
| [成功方向标注的双知识大规模 MOEA](K-success-labeled-dual-knowledge-lsmoea.md) | LSMOP 中随机高维子代方向成功率低，静态变量重要性或固定算子又不能利用进化过程中“哪些方向真的成功”的监督信号 | parent-offspring 成功方向采集、XGBoost 变量重要性降维、GMM 成功方向分布采样、reduced-space knowledge-driven reproduction | 方法 | P2026-0153 |
| [反馈驱动的自适应变量分组与组级算子选择](K-feedback-adaptive-variable-grouping-operator-selection.md) | LSMOP 中一次性变量分组成本高且会随搜索阶段失效，统一算子又忽略变量子组异质性 | 梯度近似变量分类、采样交互图、子组 `eta_k` 反馈、停滞触发重分组、组级 exploitation/exploration 算子选择 | 架构 | P2026-0161 |
| [目标空间分群的自编码解集重构](K-objective-clustered-autoencoder-solution-reconstruction.md) | LSMOP 中只在决策空间分组/降维会忽略目标空间区域内 elite solutions 的隐含演化信息 | objective-space 聚类、子群非支配解 autoencoder、encoding crossover/extraction、decoded 重构解集引导、后期多样性子代 | 架构 | P2026-0006 |
| [稀疏三任务 EMT 与保结构迁移](K-sparsity-centric-triple-task-emt.md) | 稀疏大规模 MOO 需要同时识别零变量、精修非零变量并避免低高维迁移时 zero-padding 负迁移 | 原空间主任务、union/intersection 辅助任务、skill factor 迁移与保结构空间对齐 | 架构 | P2026-0249 |
| [质量-稀疏四象限的个体定制学习](K-quality-sparsity-quad-partition-individual-learning.md) | 稀疏大规模 MOO 中只按变量级稀疏先验更新会忽略个体质量、群体协作和 dense-but-good 解的定向修正 | sparsity-quality 四象限种群划分、P1/P2/P3/P4 定制 mask/dec 学习与阶段切换 | 方法 | P2026-0203 |
| [拓扑-演化双源稀疏引导向量](K-topology-and-evolution-sparse-guidance-vectors.md) | 大规模稀疏二进制 MMOP 中随机初始化和静态变量评分难同时利用领域拓扑先验、历史精英稀疏模式和当前多样性 | VSSPS 稀疏条纹初始化、拓扑优先级 PV、非支配历史频率 SV、当前父代频率 CV、早期/后期两阶段子代引导、RBM 潜空间生成 | 架构 | P2026-0091 |
| [不可行解辅助的种群组成管理](K-infeasible-solution-aided-population-management.md) | 稀疏或碎片化可行域导致搜索停滞 | 约束处理、种群选择与组成控制 | 方法 | P2026-0032 |
| [约束边界远距不可行辅助引导](K-boundary-distant-infeasible-auxiliary-guidance.md) | 复杂 CMOP 中辅助种群若只追 UPF 或只看低 CV，难以持续补充主种群未覆盖 CPF 区域 | 辅助种群环境选择、边界不可行档案与双种群知识转移 | 方法 | P2026-0019 |
| [双边界不可行辅助指标与分组 DE](K-dual-boundary-infeasible-indicator-vgde.md) | LSCMOP 中高维变量和复杂约束使可行域难找，局部可行区易拥挤或早熟 | 可行性指标、双松弛约束边界、双种群环境选择与变量分组 DE | 方法 | P2026-0221 |
| [FNDS 诱导的 promising region 分层选择](K-fnds-promising-region-prdd-selection.md) | LSCMOP 中可行域狭窄/断裂，CDP、epsilon 或只追 UPF 难把解扩散到完整 CPF | FNDS 诱导 mutually non-dominated promising region、PR/PR^>/PR^< 分区、EPD/ERPD/PD 三级选择、AES 与 DE 交替繁殖 | 方法 | P2026-0265 |
| [UPF 参照的动态逃逸种群](K-upf-referenced-dynamic-escaping-population.md) | 欺骗约束下 CV 可能与到 CPF 的距离反向，低 CV 会把 CMOEA 引向错误区域 | AP 追 UPF、EP 按子区保留 second-best/worst 主动逃逸、可行解单向共享、MP+BDES 开发 CPF | 架构 | P2026-0271 |
| [变量自适应 UPF 档案重构](K-variable-adaptive-upf-archive-population-reconstruction.md) | LSCMOP 中高维变量耦合、可行域稀疏且 UPF/CPF 可能分离，直接全变量约束搜索收敛慢 | 收敛/多样性变量自适应全局优化、UPF-CPF 档案、参考子区中位距种群重构 | 架构 | P2026-0198 |
| [参考向量分层优先的 UPF-CPF 三群协同](K-reference-vector-hierarchical-priority-upf-cpf-guidance.md) | 复杂 CMOP 中约束松弛若缺少方向级选择，会使种群聚集到易可行 CPF 片段并丢失断裂前沿覆盖 | 探索/引导/可行档案三群、稳定+停滞二阶段切换、动态 CV 松弛、reference-vector 三层 HPS、探索群暂停 | 架构 | P2026-0159 |
| [UPF/SPF 奖励双种群约束搜索](K-upf-spf-rewarded-dual-population-cmop.md) | CMOP 中 UPF/SPF 与 CPF 关系未知，固定前沿引导或固定目标-CV 平衡容易在不同问题类型上错配 | PFPop 先追 UPF 后选最有用单约束 SPF，BPop 用 IFCHT 平衡目标和 CV，archive reward 调度主/辅种群 | 架构 | P2026-0110 |
| [指导失效触发的 UPF-CPF 约束边界收缩](K-guidance-triggered-upf-cpf-boundary-contraction.md) | CMOP 中无约束 UPF 早期有助穿越不可行区，但长期追 UPF 可能在 UPF-CPF 分离时浪费预算或误导主群 | 主群 CDP 搜索 CPF、辅群无约束追 UPF、指导失败/停滞触发阶段切换、Stage 2 快速 `VAR` 约束边界收缩 | 架构 | P2026-0029 |
| [迁移成功率门控的约束-无约束双任务协同](K-transfer-success-gated-constrained-unconstrained-multitask.md) | 约束/多模态 MOO 中无约束辅助任务可帮助跨越不可行域，但固定或过量跨任务交换会造成负迁移和局部振荡 | 原约束主任务、无约束子任务、前期非过滤交换、后期 cross-task survival 迁移成功率、历史修正、阈值门控、目标/决策双空间 fitness | 架构 | P2026-0008 |
| [SOM 拓扑双任务的约束多模态协同](K-som-topology-dualtask-constrained-multimodal-coevolution.md) | CMMOP 中可行域断裂且存在多个等价 CPS，单一 CMOEA 易丢决策空间多样性，普通 MMOEA 又缺少约束处理 | 受约束 SOM 主任务、无约束辅助任务、动态 offspring sharing、双空间 density fitness、adaptive pruning | 架构 | P2026-0116 |
| [EID 动态约束优先级与协作子代生成](K-eid-dynamic-constraint-priority-cooperative-offspring.md) | 静态逐约束处理容易误判约束顺序、浪费预算且忽略约束间协作信息 | 约束优先级调度、资源分配、重初始化与约束级 archive 子代生成 | 方法 | P2026-0226, P2026-0282 |
| [分位数阶段约束分配与边界迁移](K-quantile-staged-constraint-allocation-boundary-transfer.md) | 固定辅助任务或固定约束分配难随当前约束违反分布变化，复杂 CMOP 又需要从 UPF 平滑过渡到 CPF | 无约束探索、逐约束 mean violation 分位数主/辅任务分配、约束状态单调转移、低 CV 边界不可行 exemplar 迁移 | 架构 | P2026-0004 |
| [相关性排序的自适应辅助问题约束处理](K-correlation-sequenced-adaptive-auxiliary-cmop.md) | 固定辅助问题和按困难度逐个加约束难以适配主种群阶段需求，还会忽略约束-目标和约束间耦合 | 约束-目标 Pearson 相关、约束-约束 APC 分组、辅助问题约束子集更新、JSD 协作强度、动态参考点造个体 | 架构 | P2026-0133 |
| [约束数量分型的松弛协同进化](K-constraint-count-typed-relaxation-coevolution.md) | CMOP 中约束数量改变可行域宽窄和搜索瓶颈，固定双种群、单约束辅助或全约束处理容易在弱/中/强约束问题上错配 | 按约束数划分 WCMOP/MCMOP/SCMOP，P1 无约束探索、P3 全约束收敛、P2 单/多约束随机松弛，CV 变异系数自适应 epsilon | 架构 | P2026-0121 |
| [约束难度加权的多辅助种群资源分配与合并](K-constraint-difficulty-weighted-auxiliary-resource-merging.md) | 多约束 CMOEA 若每个约束辅助种群等资源进化，会浪费在已容易满足/相似约束上，且长期追 UPF 的无约束种群后期贡献衰减 | 无约束 UPF 探索阶段、单约束辅助种群、CV 难度 CWA 资源权重、相似约束 CCM 合并、GA 主群与 DE 辅群共享 offspring | 架构 | P2026-0141 |
| [动态辅助种群多样性增强的约束协同进化](K-dynamic-auxiliary-population-diversity-constraint-coevolution.md) | CMOP 中辅助群既要早期提供跨不可行区和目标空间多样性，又不能在 UPF 与 CPF 分离时长期消耗后期可行精修预算 | MainPop/AuPop/DA 三角色、辅助群和多样性档案线性缩减、AuPop objective-only selection、MainPop 双策略 CHT、自适应多算子 DE | 架构 | P2026-0164 |
| [博弈竞争驱动的双种群资源分配与辅助选择](K-game-competitive-dual-population-resource-allocation.md) | 双种群 CMOEA 中固定 offspring 配额、固定辅群规模或只追不可行多样性会造成主/辅资源失衡，极窄可行域下还可能饿死主群 | 主群 CDP 开发、辅群选择/规模自适应、Cournot offspring 分配或 AuxSize 收缩、CSO/DE 竞争搜索、跨群 offspring 交互 | 架构 | P2026-0053, P2026-0131 |
| [动态多层超图的结构-社区联合编码优化](K-dynamic-multilayer-hypergraph-structure-community-cooptimization.md) | 动态多层网络中固定关系结构或只优化社区标签会把临时互动、跨层角色冲突和协调成本混在一起 | 自适应时间窗口、短/长双尺度超边衰减、跨层耦合张量、`Qh/Jc/Sd/Re` 四目标、超边激活+社区标签混合编码 | 架构 | P2026-0092 |
| [locus 森林重构与叶节点交叉](K-locus-forest-reconstruction-pendant-crossover.md) | locus 编码社区检测中普通交叉/变异忽略编码诱导的森林结构，标签空间局部搜索又难保持结构基因一致 | 相似度标签初始化、BFS spanning forest 重构、叶节点边界交叉、标签空间 pseudo-LS 与 locus 修补 | 方法 | P2026-0018 |
| [自适应高阶快照知识迁移的动态社区 MOEA](K-adaptive-high-order-snapshot-knowledge-dcd.md) | 动态社区检测中固定使用上一快照或人工历史权重会在结构突变时负迁移，连续 DMOP 迁移又难适配离散划分空间 | 当前-历史快照相似性 softmax 权重、Adp-HoNMI、first/high-order 切换、高阶 locus 初始化、历史偏置变异与双扰动退火 | 架构 | P2026-0047 |
| [目标约简层级种群与约束相关激活](K-objective-reduction-level-population-correlation-activation.md) | 三目标 CMOP/工程调度中单一三目标种群难覆盖边界极值，所有辅助子种群全开又浪费预算 | 目标子集分层种群、SRCC 目标-约束关系激活、相邻层双向 offspring 共享与 epsilon 环境选择 | 架构 | P2026-0252 |
| [自适应约束违反粒度评估](K-adaptive-constraint-violation-granularity.md) | NCVE 过细易早期过度可行性偏好，BCVE 过粗又会后期缺少可行性收敛压力 | objective-space 聚类重赋 CV、可行比例 sigmoid 粒度调度、双种群 CCVE 辅助搜索 | 方法 | P2026-0234 |
| [双档案自适应约束松弛与局部收敛选择](K-dual-archive-adaptive-constraint-relaxation-local-convergence.md) | 双档案 CMOEA 中辅助档案长期追 UPF 易误导，断裂 CPF 又需要决策空间多样性 | leading archive 自适应约束松弛、primary archive 约束感知局部收敛与决策空间截断 | 方法 | P2026-0189 |
| [支配-分解双框架协同与阶段切换](K-dominance-decomposition-coevolution-stage-switching.md) | 单一 dominance 或 decomposition CMOEA 各有偏置，弱共享和长期追 UPF 难处理复杂 CMOP | dominance/decomposition 双种群、DE/sharing/1、容忍选择、UPF-to-CPF 聚合函数切换与角度相关共享 | 架构 | P2026-0185 |
| [生态位分类驱动的分解子问题资源重分配](K-niche-classified-decomposition-resource-reallocation.md) | 分解式 CMOEA 中不同 reference-vector 子问题对 CPF 贡献不均，uniform 或仅按可行性分配资源会浪费预算或陷入局部可行片段 | Type-1 到 Type-5 生态位分类、主/辅双种群差异化选择、external feasible archive、代际 Gap fitness、Type+fitness mating | 架构 | P2026-0130 |
| [解空间生态位协同的约束多目标搜索](K-solution-space-niche-coevolution-cmop.md) | 复杂 CMOP 中可行域狭窄/断裂时，固定多种群或单一约束处理难同时覆盖分散可行区并避免子群信息孤岛 | 自适应半径 niche 划分、可行角度 leader、低 CV 不可行 leader、密度驱动 GA/DE、可行率驱动约束处理、周期性交互重划分 | 架构 | P2026-0003 |
| [有限状态机驱动的多阶段 CMOEA 策略调度](K-fsm-event-driven-multistage-cmoea-scheduling.md) | 多阶段 CMOEA 若固定阶段或只用单一阈值切换，容易在大不可行区、窄可行边界和后期分布修正之间策略错配 | FSM 事件-状态表、MPop/HPop 双种群分工、I/II/III/IV 四状态策略、非支配比例/可行 HPop/count/NFE 触发切换 | 架构 | P2026-0099 |
| [趋势-正交互补的双群约束搜索](K-trend-orthogonal-dualswarm-constrained-search.md) | 复杂 CMOP 中多群协作若只共享解坐标，会缺少可复用收敛方向，并在同一区域冗余搜索或漏掉断裂 CPF | 约束松弛主群趋势学习、CDP 辅群正交补搜索、winner-loser/边界方向、三层 NGSS niche 容量补稀疏 | 架构 | P2026-0275 |
| [动态聚类限域的竞争群约束搜索](K-dynamic-clustered-competitive-swarm-cmop.md) | CSO 类 CMOP 算法早期需要全局穿越不可行区，后期远距离 winner-loser 学习又会破坏 CPF 附近局部开发 | 主/辅双群两阶段、UPF 稳定性切换、目标空间 K-means 动态簇数、同簇 CSO 更新、参考向量辅助群多样性选择 | 架构 | P2026-0158 |
| [自适应子区多方向竞争更新](K-adaptive-subregion-multidirectional-swarm-update.md) | 大规模优化中局部胜者周围过早收敛 | 子区划分、胜者探索与败者更新 | 方法 | P2026-0037 |
| [多方向模糊采样与多源竞争细化](K-multidirectional-fuzzy-sampling-multisource-cso.md) | 大规模 MOO 中单一代表/稀疏线性采样方向难以同时保证收敛、覆盖和后期精度 | APD 代表解、梯度/边界/正交方向采样、模糊粒度与 MLCSO 细化 | 方法 | P2026-0093 |
| [初始化收敛采样与胜者反向竞争更新](K-initial-convergence-sampling-reverse-winner-cso.md) | 大规模 MOO 中随机初始化收敛慢，普通 CSO loser 单向追随易陷入局部或分布不足 | 初始化收敛采样、CSO/PSO loser 正反向更新与条件重启 | 方法 | P2026-0048 |
| [参考子区约束学习与高斯胜者进化](K-reference-subregion-constrained-learning-gaussian-winner-cso.md) | 大规模 CSO 中随机配对 winner 质量不稳、loser 学习方向抖动且 winner 缺少持续演化 | 参考向量子区配对、同/邻子区 loser 学习、高斯模型辅助 winner 更新 | 方法 | P2026-0173 |
| [邻域动量后处理收敛加速](K-neighborhood-momentum-postprocessing-acceleration.md) | EMOA 在有限评价预算下收敛慢，历史成功方向没有被复用 | 子代生成后的候选后处理与收敛加速 | 方法 | P2026-0154 |
| [胜者映射学习引导的蜂群子代生成](K-winner-mapping-dendrite-guided-bee-offspring.md) | ABC/群智能搜索偏随机、局部开发弱，历史优劣个体关系未被显式学习 | 子代生成、蜂群/差分搜索更新、学习引导候选生成 | 方法 | P2026-0024 |
| [代理训练的注意力残差子代生成器](K-surrogate-trained-attention-residual-offspring-generator.md) | 昂贵高维 MOO 中传统交叉/变异样本效率低，普通代理多只改善筛选而不改善候选生成 | learned offspring generator、RBF surrogate Tchebycheff loss、reference-direction 子问题生成与稀疏 infill | 方法 | P2026-0288 |
| [目标条件化生成式设计采样](K-objective-conditioned-generative-design-sampling.md) | 昂贵多目标问题需要按需求或档案缺口高效生成候选 | 初始化、重启、主动学习与候选生成 | 方法 | P2026-0068, P2026-0138 |
| [物理约束晶体编码与结构知识迁移](K-physics-informed-crystal-encoding-transfer.md) | 晶体材料生成中随机/数据驱动表示容易违反空间群、原子距离和热力学约束，复杂元素系统又缺少训练数据 | 晶体结构编码、约束过滤、多目标材料生成、跨材料系统迁移初始化 | 架构 | P2026-0212 |
| [生成模型潜空间的多目标采样精修](K-latent-generative-mop-sampling-refinement.md) | 生成模型默认采样容易模式坍缩或质量不稳，重新训练又难适配新目标 | 生成/自编码模型潜空间、多目标推理后处理、潜空间交叉/变异、语义目标解析与物理可行过滤 | 方法 | P2026-0171, P2026-0240, P2026-0270 |
| [依赖结构指导的变异算子](K-dependency-structure-guided-variation.md) | 无结构变异破坏变量依赖并扩大搜索空间 | 变量分组与变异算子 | 方法 | P2026-0076 |
| [非支配掩码相似性引导的稀疏模式继承](K-nondominated-mask-similarity-guided-sparse-pattern-inheritance.md) | 单变量或局部模式学习难以快速找到能改善目标值的完整稀疏结构 | 稀疏结构学习、档案更新与后代掩码生成 | 方法 | P2026-0111 |
| [目标分解的高斯演化方向学习](K-objective-wise-gaussian-evolutionary-direction-learning.md) | 既有 KL 框架解对数据少且质量不稳，单一 poor-to-promising 模型会混合不同目标区域的有效方向 | 目标改进解对收集、目标级方向概率模型、位置感知子代方向采样 | 方法 | P2026-0225 |
| [目标空间流形嵌入的多样性选择](K-objective-space-manifold-embedding-diversity-selection.md) | 原空间距离难以表示不规则 PF 的真实覆盖关系 | 环境选择与多样性维护 | 方法 | P2026-0082 |
| [更新状态驱动的双参考点切换](K-update-state-driven-dual-reference-switching.md) | 固定参考模式在复杂 PF 上产生搜索偏置或停滞 | 分解聚合与搜索控制 | 方法 | P2026-0083 |
| [分解-支配双选择的稀疏探索](K-decomposition-dominance-sparse-exploration.md) | MOEA/D 在复杂、断裂或尺度不均 PF 上容易重复、偏置和早熟 | 分解式 MOEA 的环境选择、稀疏探索、标量函数和算子调度 | 方法 | P2026-0100 |
| [密度引导的辅助参考向量再生](K-density-guided-auxiliary-reference-vector-regeneration.md) | irregular/discontinuous/degenerate PF 中固定均匀参考向量会产生无效方向、空子区和局部覆盖缺口 | RVEA/NSGA-III/MOEA/D 参考向量集更新、辅助向量再生、低维 DDGSI/高维 APD 环境选择 | 方法 | P2026-0156 |
| [层级估计与聚类筛选的有效参考向量](K-hierarchical-clustering-effective-reference-vectors.md) | 离散或断裂 PF 中部分参考向量不与 PF 相交，固定分解会浪费搜索资源或误删有效方向 | 分解式环境选择、critical level 选择、参考向量有效性筛选 | 方法 | P2026-0213 |
| [参考向量双候选自适应补位选择](K-reference-vector-dual-candidate-adaptive-fill-selection.md) | many-objective 参考向量初筛常因空子区或单一 APD 最优规则选不满种群，并丢掉兼具覆盖或收敛价值的剩余解 | RVEA/NSGA-III/MOEA-D 环境选择、`DP/PP` 双候选集、交集优先、早期多样性/后期收敛补位 | 方法 | P2026-0054 |
| [曲率投影与角度剪枝的阶段自适应 MaOP 选择](K-curvature-angle-phase-adaptive-maop-selection.md) | MaOP 中 Pareto 支配退化且固定参考向量可能失配，单一指标又易偏向特定 PF 区域 | 当前非支配前沿曲率估计、投影收敛距离、目标向量最小夹角、ADP 角度剪枝、收敛-多样性阶段切换 | 方法 | P2026-0128 |
| [目标值均衡的二级环境选择](K-objective-value-balanced-secondary-selection.md) | many-objective 离散 PF 中 classic crowding distance 大量打平，随机删点会让稀有 Pareto 目标值长期丢失 | NSGA-II critical front 截断、objective-value multiplicity 均衡、reference/HV 替代二级选择 | 方法 | P2026-0238 |
| [拥挤中位分区的稀疏优先混合选择](K-crowding-median-sparse-dense-hybrid-selection.md) | 标准 NSGA-II 截断容易欠覆盖目标空间稀疏区，单独归一化又不能显式保留欠代表区域 | NSGA-II/rank-based MOEA 下一代选择、critical front 截断、archive 容量控制 | 方法 | P2026-0208 |
| [自适应 ε 支配与网格档案的多目标蜂群搜索](K-adaptive-epsilon-grid-archive-moabc.md) | 普通 Pareto 支配在 swarm/MOEA 中选择压力弱且档案易膨胀，固定拥挤截断又难随阶段调节收敛-多样性 | 自适应 ε-dominance、外部非支配档案、objective-grid 剪枝、ABC employed/onlooker/scout ε 替换 | 方法 | P2026-0294 |
| [密度聚类-熵权的邻域搜索资源分配](K-density-entropy-guided-neighborhood-search.md) | Pareto/elite 解在目标空间局部过密或偏向某一目标时，随机/固定邻域搜索会重复扰动同一区域且难按目标冲突方向调强度 | DBSCAN 目标空间聚类、cluster entropy 权重、objective-slope 邻域策略选择、critical-machine/operation 搜索预算分配 | 方法 | P2026-0160 |
| [有序分割的精确 Pareto 前缀动态规划](K-ordered-partition-exact-pareto-dp.md) | 有序分割问题需要精确枚举完整 Pareto 前沿 | 精确求解器与小规模评价基准 | 方法 | P2026-0096 |
| [精确子问题定界与播种的组合多目标 matheuristic](K-exact-subproblem-bounded-matheuristic-seeding.md) | 大规模组合 MOO 中完整多目标精确前沿过慢，纯 MOEA 又缺少质量边界和高质量初始解 | ε-constraint/MILP 投影前沿、lexicographic 极端点、贪婪 Pareto 种子、MOEA archive/population 初始化、exact-bound 质量审计 | 方法 | P2026-0034 |
| [环境变化严重度驱动的多策略预测响应](K-change-severity-adaptive-multi-strategy-prediction.md) | 动态环境变化程度不同，单一响应策略不稳定 | 环境变化响应与新环境种群初始化 | 方法 | P2026-0103 |
| [目标质心趋势引导的动态选择](K-objective-centroid-trend-guided-dynamic-selection.md) | 动态 MOO 中 detect-response-search 范式把环境间搜索视为静态，连续漂移时搜索方向滞后或振荡 | 非支配前沿目标质心移动、global trend vector、individual trend synergy、rank-score 融合与低开销趋势选择偏置 | 方法 | P2026-0263 |
| [无特征表示的目标空间动态迁移](K-featureless-objective-space-dmo-transfer.md) | Tr-DMOEA 的 TCA/latent feature representation 耗时且对线性核迁移解质量贡献有限，复杂迁移未必优于复制历史解 | 环境变化响应、历史 PF 源选择、目标空间直接匹配迁移、copied-vs-transferred 诊断 | 方法 | P2026-0260 |
| [静态优化距离反馈的动态响应策略池](K-static-optimization-distance-feedback-dynamic-response.md) | 固定比例或单一动态响应策略在复杂变化环境中容易失配，个体级扰动反馈又不稳定 | 环境变化响应、子种群策略分配、新环境初始化与策略 credit 更新 | 方法 | P2026-0181 |
| [劣化状态增强 DQN 的动态约束响应策略选择](K-deterioration-state-augmented-dqn-dcmoea-strategy-selection.md) | 动态约束 MOO 中固定响应策略不能区分可行性、多样性和收敛性受损模式，盲目执行会低效或反向 | 可行/多样/收敛劣化状态、pairwise state augmentation、63 动作策略组合、离线 DQN 与在线响应选择 | 方法 | P2026-0261 |
| [带电引导种群的动态预测响应](K-charged-guiding-population-dynamic-prediction.md) | 动态 MOO 中突变会破坏预测种群分布，中心/趋势预测易产生偏差 | 环境变化响应、种群预测、分布维护与预测后纠偏 | 方法 | P2026-0155 |
| [膝点引导的组成结构动态重初始化](K-knee-guided-composition-dynamic-reinitialization.md) | 动态 MOO 中单一预测或随机移民难以同时保持新环境初始种群的收敛、迁移质量和多样性 | 膝点预测、非支配迁移目标域生成、膝点间插值、变化强度分流与种群重初始化 | 方法 | P2026-0147, P2026-0267 |
| [双空间子种群的动态预测响应](K-dual-space-subpopulation-dynamic-prediction.md) | 动态 MOO 中全局中心预测和单空间子群划分难以同时捕捉局部趋势、目标覆盖和决策结构 | 环境变化响应、目标/决策双空间子群划分、中心预测与边界多样性补充 | 方法 | P2026-0079 |
| [重叠区间与历史协作的动态响应](K-overlapping-interval-history-collaborative-dmop-response.md) | 动态 MOO 中全局预测忽略局部趋势，直接复用历史最优又可能在历史失效时误导新环境初始化 | 重叠区间预测、区间边界外推、历史中心/半径可行区域筛选、个体位移趋势兜底 | 方法 | P2026-0118 |
| [子空间对齐分类器的新环境种群筛选](K-subspace-aligned-classifier-dmop-reinitialization.md) | DMOP 环境变化后历史种群标签与当前候选分布不一致，直接迁移或无筛选过采样会造成负迁移或低质量初始化 | source-target 子空间对齐、历史 POS 标签迁移、分类器候选准入与新环境初始种群构造 | 方法 | P2026-0211 |
| [配准轨迹跟踪的任务专属动态约束预测](K-registration-tracked-task-specific-dcmoea-prediction.md) | 动态约束 MOO 中个体对应关系难匹配，双种群初始化和辅助任务选择易偏离当前 CPF | CPD/RMTT 变化响应、CPOP/UPOP 双档案预测、预测 CPF 相似环境识别与 DFTR 辅助种群选择 | 方法 | P2026-0233 |
| [向量自回归降维动态响应](K-vector-autoregressive-pca-dynamic-response.md) | 动态 MOO 中逐变量/中心预测忽略变量联动、多历史相关和参考方向局部差异 | 参考方向历史解轨迹、PCA 降维 VAR 多输出预测、目标/决策双空间环境感知超变异和成功率调度 | 方法 | P2026-0235 |
| [二阶导数双域自适应动态预测](K-second-order-dual-domain-dynamic-prediction.md) | 动态 MOO 中一阶或单空间预测难以捕捉 PS/PF 曲率、加速度和不同变化来源 | PS/PF 双域二阶导数预测、NDS 贡献反馈预测比例分配、目标空间反向映射与新环境重初始化 | 方法 | P2026-0245 |
| [LLM 提示的动态种群时间序列预测](K-llm-prompted-dynamic-population-time-series-prediction.md) | 昂贵或大规模 DMOP 中专用预测模型数据效率低、调参与重训练成本高，随机/记忆响应又难外推新环境 | 历史非支配解文本化、个体级/分布级 prompt、CoT 趋势推理、LLM 预测新环境初始种群与 MOEA 精修 | 架构 | P2026-0207 |
| [演化轨迹对齐的条件扩散动态响应](K-evolutionary-trajectory-aligned-diffusion-dmoea.md) | 大规模动态 MOO 中只学习历史 POS 会浪费演化过程信息，随机重启或简单预测难以快速恢复高维新环境 | 历史 evolution trajectory 监督、previous POS 高斯扩散、`X_pre+diff` 条件去噪、trajectory alignment loss、生成种群少步精修 | 架构 | P2026-0255 |
| [动态参考点 ROI 偏好跟踪](K-dynamic-reference-point-roi-preference-tracking.md) | 动态 MOO 中决策者只关心随环境和偏好变化的 ROI，完整 PF 跟踪会浪费预算且静态参考点会响应滞后 | DAR-dominance、reference point 预测、ROI-focused selection 与 MGD/MSP 评价 | 方法 | P2026-0193 |
| [数据流动态优化的代理超参数迁移](K-data-stream-surrogate-hyperparameter-transfer.md) | DDMOP 中算法不能主动调用真实目标函数，当前数据流又太少，直接训练代理易受历史漂移和样本偏差误导 | 数据流驱动动态 MOO、代理模型超参数迁移、双代理并行搜索与可靠解筛选 | 方法 | P2026-0186 |
| [双射区间分式目标确定性化变换](K-bijective-interval-fractional-determinization.md) | 区间分式目标无法直接交给常规优化器 | 问题建模与目标变换 | 方法 | P2026-0104 |
| [KDE 区间 Pareto 自适应粒子群](K-kde-interval-pareto-adaptive-mopso.md) | 工程系统参数扰动使目标值成为区间，确定性 MOO 容易给出扰动下性能偏离的运行参数 | KDE 目标置信区间、IPOR 区间非支配排序、MOPSO pBest/gBest/archive 更新、粒子均匀度 flight 参数自适应 | 方法 | P2026-0066 |
| [区间目标-可行率两阶段环境选择](K-interval-feasibility-staged-environmental-selection.md) | interval-valued objectives 与约束可行性同时存在时，普通 Pareto/CDP 或 midpoint 加权会丢失区间语义或过早牺牲目标搜索 | interval non-dominated sorting、`CI/CV` 二级排序、feasible-rate 双子过程切换、低 CV 不可行解填充、CIDP+interval crowding | 方法 | P2026-0094 |
| [风险态度驱动的模糊机会约束确定性化](K-risk-attitude-fuzzy-chance-constraint-determinization.md) | generalized/intuitionistic/picture fuzzy MOLP 难以直接表达风险态度并交给常规优化器 | 不确定 MOLP 建模预处理、机会约束确定性化与风险情景扫描 | 方法 | P2026-0089 |
| [结构-场景双罚项的模糊鲁棒随机规划](K-dual-penalty-fuzzy-robust-stochastic-programming.md) | 混合随机-模糊不确定下传统 FRSP 只惩罚场景控制约束，容易忽略结构约束可行性风险 | 供应链/MILP 不确定建模、机会约束、鲁棒罚项与情景评估 | 方法 | P2026-0114 |
| [策略跟随评估的风险感知层级多目标规划](K-policy-follower-risk-aware-hierarchical-planning.md) | 战略部署/布局/路径和短期调度/恢复/分配耦合，精确双层求解过重且平均指标会掩盖尾部风险 | 上层 MOEA、下层可行策略或场景优化 follower、场景风险/扰动评估 | 方法 | P2026-0143, P2026-0059, P2026-0117 |
| [安全-公平-能耗耦合的移动光通信部署功率优化](K-security-fairness-energy-mobile-vlc-deployment-power.md) | 移动通信/光通信节点部署若只优化覆盖或能耗，可能把高功率信号暴露给窃听者，且固定均匀部署难适配用户和风险分布 | 服务节点位置与发射功率联合编码、覆盖公平方差、窃听信息率、运动能耗、安全距离/高度/功率约束 | 架构 | P2026-0055 |
| [均值-最坏双视角的鲁棒分解搜索](K-mean-worst-hybrid-robust-decomposition.md) | RMOP 只用平均表现会漏掉尾部风险，只用最坏表现又可能过保守；同时保留 2m 鲁棒目标会削弱选择压力并放大采样更新成本 | 扰动邻域 LHS 采样、mean/worst robust objectives、modified Tchebycheff 标量化、小候选 elite update、rIGD_mean/rIGD_worst 评价 | 方法 | P2026-0095 |
| [稳定度调权的鲁棒代理搜索与双指标候选筛选](K-stability-weighted-robust-surrogate-candidate-selection.md) | ExRMOP 中平均性能偏最优、最差性能偏鲁棒，单一视角 replaced objective 与全量真实评价都低效 | Kriging LCB 代理、平均/最差视角 DPAF 稳定度调权、resampled NDL robust optimality、diversity DI-PD 候选真实评价 | 方法 | P2026-0175 |
| [代理辅助鲁棒距离的目标扩展选择](K-surrogate-assisted-robust-distance-objective.md) | 决策变量扰动下鲁棒 MOO 若真实评价每个邻域采样点，每代成本会放大到 N×H，固定鲁棒惩罚又难保留折中 | 真实评价档案训练 RBF、扰动邻域 LHS 代理预测、目标空间距离 RDM、归一化后作为额外目标环境选择 | 方法 | P2026-0182 |
| [鲁棒解空间观测的时间联动分布预测](K-solution-space-observed-time-linkage-distribution-rmo.md) | 连续工程系统中当前扰动受历史 setpoints 和外部扰动共同影响，固定鲁棒区间难刻画相邻时刻不确定性的传播 | 相邻 archive 目标/决策空间变化观测、GP 时间联动不确定性分布预测、预测分布采样鲁棒目标、分布变化驱动参数自调节 | 方法 | P2026-0183 |
| [强化学习调度的下层搜索模式](K-rl-lower-level-search-mode-scheduling.md) | 双层 MOO 中总是优先满足下层最优性会消耗大量评价，而暂时忽略下层约束又可能误导上层搜索 | 双层优化、下层搜索模式调度、有效 LLS 反馈与 Q-learning 控制 | 方法 | P2026-0223 |
| [统计等价驱动的多标签算法选择](K-statistical-equivalence-multi-label-algorithm-selection.md) | 单一最佳算法标签忽略统计等价候选 | 算法选择、推荐与组合 | 方法 | P2026-0105 |
| [协同 MOPSO 双标签特征与标签增强](K-collaborative-mopso-bilabel-feature-enhancement.md) | MIML 中 raw features 难刻画标签对关系，统一标签重要性又忽略语义差异 | 标签对原型选择、bi-label 特征生成、标签增强与虚拟标签加权投票 | 架构 | P2026-0195 |
| [可执行测试修复的 LLM 算法代码进化](K-llm-tested-reproduction-program-evolution.md) | LLM 生成算法代码易出错且一次性生成缺少性能反馈，手工 MOEA 算子设计又依赖专家经验 | LLM 程序种群、Pilot Run and Repair、文本交叉变异、多问题评分 | 架构 | P2026-0228 |
| [LLM 语义辅助的多目标推荐演化搜索](K-llm-semantic-assisted-moea-recommendation.md) | 多目标推荐同时面临冷启动、全局收敛和解释不足，直接让 LLM 优化又容易不稳定 | LLM embedding 冷启动、候选约束 prompt、score correction、SDE 与竞争搜索 | 架构 | P2026-0247 |
| [双空间分层自适应资源分配](K-dual-space-hierarchical-resource-allocation.md) | 均匀或单空间资源分配无法同时识别高价值搜索区域、变量组和阶段预算 | 子种群更新、变量组更新与函数评价预算调度 | 方法 | P2026-0112 |
| [收敛区间变量重要性与自感知资源分配](K-convergence-interval-variable-importance-self-aware-resource-allocation.md) | 大规模 MOO 中全局采样变量重要性会随种群收敛失真，静态分组和固定迭代难以把预算给高潜力变量组 | 收敛区间变量扰动、动态 importance-level grouping、估计 PF 的 IGD 改善率早停 | 方法 | P2026-0230 |
| [信息瓶颈引导的潜在维度估计](K-information-bottleneck-latent-dimension-estimation.md) | LSMOP 降维框架中 latent dimension 过小会丢失 Pareto set 信息，过大又削弱降维收益，固定维度难适配不同问题 | 变量扰动收敛/多样性重要性、harmonic mean 重要性水平、信息瓶颈线性维度估计、周期性 latent-space 更新与原空间补偿 | 方法 | P2026-0256 |
| [低频频域参数的问题变换搜索](K-low-frequency-domain-parameter-problem-transformation.md) | LSMOP 中原空间维度过高导致有效后代稀少，DVA/固定低维变换又可能成本高或丢失全局轮廓 | 低频 Fourier 参数编码、decision reconstruction、频域全局子种群、决策域局部精修、跨域个体交换 | 架构 | P2026-0163 |
| [增量直方图与决策空间划分的离散大规模 MOO](K-incremental-histogram-division-discrete-lsmop.md) | 离散大规模 MOO 中连续化算子和降维容易失真，普通采样又难利用历史分布 | 变量级离散直方图、Pareto rank 加权增量更新、全局采样与子区局部直方图搜索 | 方法 | P2026-0200 |
| [稀疏注意力 Actor-Critic 的多约束任务调度](K-sparse-attention-actor-critic-fog-scheduling.md) | 动态雾/边缘任务调度中任务依赖、资源异构和多 QoS 目标导致状态交互膨胀，普通 DRL 或元启发式难兼顾在线适应与可扩展性 | DAG-ready 状态、top-k sparse attention、actor-critic 调度策略、多目标 reward/penalty、元启发式超参数/权重调节 | 架构 | P2026-0162 |
| [决策-目标双空间双种群均匀搜索](K-dual-population-decision-objective-uniform-search.md) | 大规模 MOO 中全局随机交配破坏高维优质结构，而目标空间局部区域又容易采样不足 | 双种群协同、决策空间限制交配、目标空间状态评估与增强采样 | 方法 | P2026-0031 |
| [Pareto set 方向筛选引导的粒子生成](K-pareto-set-direction-screening-guided-pso.md) | 高维 MOPSO 只靠历史 best 容易动量不足和早熟，随机方向采样又浪费评价，难捕捉当前 PS 在决策空间的局部方向 | 参考向量代表解、六类决策方向构造、支配关系筛方向、沿方向采样 archive、SDE guide/explorer 与角度 pbest 配对 | 方法 | P2026-0052 |
| [贡献自适应的多种群多目标协同](K-contribution-adaptive-mpmo-coevolution.md) | MaOP 中单种群选择压力退化，传统 MPMO 等机会分配和弱通信难兼顾收敛、多样性与复杂度 | MPMO 子种群进化机会分配、优劣种群迁移与外部档案截断 | 方法 | P2026-0078 |
| [帕累托原则精英-非精英双轨搜索](K-pareto-principle-elite-nonelite-search.md) | 单一搜索策略难同时集中开发高质量区域并保持全局探索，纯精英牵引又易早熟 | 固定 20% elite / 80% non-elite 角色分区、elite 局部开发、non-elite 受随机 elite 和个人最好解牵引探索、每代重排替换 | 方法 | P2026-0146 |
| [RL 优势概念识别的多概念资源分配](K-rl-advantage-concept-resource-allocation.md) | 多概念 MOO 中固定或纯当前表现的资源分配会浪费预算，或过早淘汰初期弱但后期有潜力的优势概念 | 概念级 Fscore 收敛质量、IGDp 演化潜力、State 门控、RL Value、进化概率与个体配额调度 | 方法 | P2026-0043 |
| [同索引分段决策种群协同进化](K-index-aligned-subdecision-population-coevolution.md) | 多段异构调度编码中统一种群算子难适配 assignment、sequence、speed 等子决策，完全随机拼接又会破坏子段协同 | 分段语义种群、同索引完整解拼接、段专属初始化/交叉/变异与完整解 fitness 回传 | 架构 | P2026-0209 |
| [单方辅助的多方双阶段协同进化](K-single-party-assisted-multiparty-dual-phase-coevolution.md) | 离散 MPMOP 中单种群共同搜索难利用各 DM 的单方 Pareto 结构，过早或过弱迁移又会造成探索/开发失衡 | multiparty population、single-party populations、offspring/parent 双阶段合作、离散双搜索 | 方法 | P2026-0248 |
| [多目标竞争协同进化与渐进收缩决策](K-moccovev-progressive-shrinking-interactive-dm.md) | 多智能体对抗问题中各方策略效果相互依赖，独立优化和离线 Pareto 选择无法处理对手响应与前序承诺 | 双种群对手全集配对评价、轮流响应式 MCDM、equilibrium 检测与 CoV 渐进收缩 | 方法 | P2026-0231 |
| [故障子问题辅助的双种群协同重调度](K-failure-subproblem-assisted-dual-population-rescheduling.md) | 动态设备故障重调度中全量重排成本高且局部修复又忽略下游影响 | 动态调度、扰动恢复、原问题-辅助子问题双种群协同与知识迁移 | 方法 | P2026-0129 |
| [滚动多区域稳定保持重调度](K-rolling-multiarea-stability-preserving-rescheduling.md) | 动态任务重调度中全量重排扰动大且慢，单一区域局部修复又缺少跨区域协调 | LAT/MAT/RAT 区域划分、依赖驱动最小扩张、多区域联合搜索、TAD/TOD/ACT 稳定性-效率 Pareto 折中 | 架构 | P2026-0050 |
| [局部通信精英交互的分布式多目标协同](K-local-communication-elite-interaction-distributed-moo.md) | 通信受限多节点系统中集中式 MOEA 计算慢、单点脆弱且不符合局部通信拓扑 | 多节点本地 MOEA、邻域精英迁移、交互间隔控制与分布式 Pareto 搜索 | 方法 | P2026-0012 |
| [RAOI 行为区参数的多目标群体觅食调优](K-raoi-parameterized-swarm-foraging-tuning.md) | 去中心化 swarm 觅食中局部交互半径和机器人数量会同时影响时间、能耗、负载、完成率和成本，手工调参难暴露折中 | RAOI 行为区参数、swarm size 六目标调优、replica 仿真评价、normalized dynamic table 近邻复用 | 架构 | P2026-0120 |
| [虚拟边界分区的清洁能源多目标调度](K-virtual-boundary-distributed-clean-energy-dispatch.md) | 大规模清洁能源并网调度中集中控制器压力大、隐私弱，区域独立优化又会破坏跨区边界一致性 | bus-splitting 虚拟边界变量、区域并行多目标调度、边界误差评价、动态 Levy 解-参数记忆 | 架构 | P2026-0014 |
| [波前扩散控制的车联网中继传播优化](K-wavefront-diffusion-relay-control-v2v.md) | 高动态车队中路径式或 gossip 式信息广播难同时保证覆盖、低时延、低开销和可靠性 | 信息浓度扩散模型、密度/环境自适应传播参数、连接-负载中继概率、同步/冗余鲁棒控制 | 架构 | P2026-0283 |
| [张量化 GPU 多目标演化算子](K-tensorized-gpu-emo-operators.md) | 传统 EMO/CMOEA 的循环、分支、非支配排序和截断更新难以利用 GPU 并行，直接搬到 GPU 还会受串行环境选择拖累 | 种群/目标/约束张量表示、循环与分支 mask 化、GPU 环境选择、大种群并行搜索与 CMOP 双种群 OC-PUI-ESPU 更新 | 方法 | P2026-0224, P2026-0251 |
| [MMOP 八机制组合设计框架](K-mmop-eight-mechanism-composition-framework.md) | MMOP 同时要求目标空间收敛与多个等价 PS 的决策空间覆盖，单一机制难兼顾探索、开发、记忆和评价 | crowding/indicator/niching/clustering/archive/multi-population/machine-learning/two-stage 的机制组合、适用边界、双空间指标和归因实验 | 架构 | P2026-0204 |
| [Voronoi-模态检测的动态双阶段 MMOP 搜索](K-voronoi-modality-dynamic-two-stage-mmop.md) | 静态 two-stage MMEA 一旦进入开发阶段难恢复漏搜 PS，固定 niche 半径又易错配决策空间模态 | VDEM/D 决策空间 Voronoi 邻域探索、MDS objective segment 内模态检测、SMO/D 模态内分解开发、archive 分模态环境选择、`Cdec/Cobj` 阶段切换 | 架构 | P2026-0123 |
| [孤立解感知的自适应收敛与邻域模糊拥挤](K-isolated-aware-adaptive-convergence-neighborhood-fuzzy-crowding.md) | MMOP 中 local convergence 能保留 local PS 却会误保留无邻域支撑的孤立解，全局 crowding 又难区分分散 PS 内部拥挤 | local/global convergence indicator 自适应切换、决策/目标双空间邻域 crowding、fuzzy fusion、双档案与 PF 解数平衡 | 方法 | P2026-0210 |
| [级联聚类驱动的多模态子种群阶段管理](K-cascade-clustering-stage-switching-subpopulation-management.md) | 大规模稀疏 MMOP 中未知多个等价 PS 容易丢失、重复探索或阶段切换不稳 | 多子种群划分、阶段切换与合并 | 方法 | P2026-0011 |
| [全局非支配占比驱动的子种群均衡进化](K-global-nondominated-ratio-balanced-subpopulation-evolution.md) | 多子种群进化进度不均衡导致部分模态收敛差或丢失 | 子种群更新、额外演化与阶段内平衡 | 方法 | P2026-0011 |
| [粗细聚类与密度独立竞争的多模态识别](K-coarse-fine-clustering-density-competing-mmop.md) | MMOP 中固定聚类难适应早期分散和后期聚集的种群形态，统一竞争压力又会误伤稀疏或困难模态 | K-means/DBSCAN 粗细聚类切换、动态半径、子种群密度诊断与局部/全局竞争选择 | 方法 | P2026-0237 |
| [时空图学习的多模态 PS 子代生成](K-spatiotemporal-graph-ps-offspring-reproduction.md) | MMOP 中复杂且变化的 PS 拓扑难由固定交配或函数代理捕捉，多等价 PS 容易漏搜，模型子代又可能过度贴近父代 | 决策空间邻接图、GraphSAGE/temporal conv、UGCN 上采样、模型-变异混合子代生成、最大差异预筛选 | 方法 | P2026-0219, P2026-0057 |
| [局部正则模型的多模态解集重构](K-local-regularity-model-mmop-population-reconstruction.md) | MMOPsL 中 LOS/GOS 的可接受解流形易被欠收敛样本和候选分布不均误删 | Pareto rank 分层 HPCA、局部正则模型、自组织邻域、概率种群重构 | 方法 | P2026-0172 |
| [Actor-Critic 自适应生态位环境选择](K-actor-critic-adaptive-niche-selection-mmop.md) | MMOP 中固定生态位半径难同时保留潜在 PS 与强化局部收敛 | 局部收敛质量、niche size、环境选择与双种群 MMOP | 方法 | P2026-0287 |
| [自步辅助任务 EMT 与映射变换多模态调度](K-self-paced-emt-mapping-transform-mm-scheduling.md) | 可变速度组合调度中大量不同排程会映射到相同目标值，普通编码距离又难代表真实排程相似性 | 简化调度辅助任务、skill-factor 隐式迁移、任务特化 KES 与显式迁移、按机器顺序映射后的决策空间去冗余 | 架构 | P2026-0184 |
| [SAMOEA 问题属性-组件-场景设计矩阵](K-samoea-problem-component-scenario-design-matrix.md) | 昂贵 MOO 中代理模型、infill 和场景策略常因问题属性不匹配而失效 | problem-attribute taxonomy、surrogate management、infill criteria、special scenarios 与评价协议 | 架构 | P2026-0202 |
| [复合指标引导的昂贵多目标填充采样](K-composite-indicator-infill-sampling-expensive-moo.md) | 昂贵 MOO 中每次真实评价极少，单一 convergence/diversity/uncertainty 采样会漏掉 PF 均匀分布、边界扩展或收敛压力 | GP-assisted NSGA-III 候选生成、distribution angle、MaxMin diversity、ideal-distance convergence、随机权重 CI、单点 infill sampling | 方法 | P2026-0127 |
| [CMA 局部区域与 MAB 多获取函数代理搜索](K-cma-local-region-mab-multiacquisition-saea.md) | 高维昂贵 MOO 中全局 GP 不稳，固定降维/固定局部区域/单一 acquisition 难适应搜索阶段变化 | HVC/max-min 区域中心、CMA 椭球局部区、HV/TS 区域重启、局部 GP 多 acquisition 代理 MOP、RHVI/HVKG-MAB 候选选择 | 架构 | P2026-0101 |
| [自适应代理内环加速器](K-adaptive-surrogate-accelerator.md) | 真实评价昂贵导致进化预算不足 | 子代生成、代理搜索与真实评价分配 | 方法 | P2026-0126 |
| [Transformer 中段替代迭代的 MOEA 加速](K-transformer-midstage-iteration-skip-moea-acceleration.md) | 高复杂度工程 MOEA 每代真实仿真/控制评价耗时，普通代理只改单点评价或单目标加速，难保留多目标解集多样性 | 前段真实迭代采集 objective-to-decision 序列、Transformer 预测中段种群、后段 MOEA 精修、AGS/RWS/adaptive fractional updates | 方法 | P2026-0134 |
| [离线数据代理驱动的工业过程 Pareto 设定优化](K-offline-surrogate-industrial-setpoint-pareto-optimization.md) | 机理复杂工业过程有历史数据但真实试错昂贵，直接经验设定难同时兼顾质量、排放、产量和安全操作边界 | 时滞对齐历史数据、XGBoost/代理目标模型、安全 bounds 工艺设定搜索、SMS/HV 选择、自适应局部搜索、熵权 Pareto 选解 | 架构 | P2026-0132 |
| [多物理仿真代理的工程几何 Pareto 设计验证](K-multiphysics-surrogate-pareto-design-verification.md) | 多物理耦合结构件高保真仿真昂贵，典型几何试算难系统暴露性能冲突，代理 Pareto 若不复核又难落地 | 参数化可制造几何、LHS 高保真样本、Kriging 验证、NSGA-III Pareto 搜索、E-TOPSIS 终选、高保真与多工况复核 | 架构 | P2026-0075 |
| [共享汉明核 MOKRR 子问题协同](K-shared-hamming-mokrr-subproblem-infill.md) | 昂贵二进制 MOO 中逐目标代理样本效率低、普通 Hamming 难表达变量重要性，贪婪代理选点易早熟 | 多输出 KRR 共享加权 Hamming kernel、分解子问题代理内协同、Hamming 稀疏 infill | 架构 | P2026-0250 |
| [目标级自适应代理与双空间 infill 采样](K-objective-wise-adaptive-surrogate-dual-space-infill.md) | 昂贵 many-objective 中不同目标函数适合的代理类型不同，单空间 infill 又易漏掉有信息的未探索区域 | 每目标 GP/RBF 选模、holdout `R^2` 反馈、RVEA 代理搜索、决策/目标双空间真实评价采样 | 方法 | P2026-0188 |
| [多视角双空间代理训练样本采样](K-multiperspective-dual-space-surrogate-infill.md) | 昂贵 super-many-objective 中逐目标代理误差累积，按当前预测表现选点不能保证提升训练集质量 | 最近真实样本决策距离、目标空间角度、非支配 infill 前沿、k-means 代理内多样性增强 | 方法 | P2026-0115 |
| [MLP 子空间筛选与稀疏 GP 的高维昂贵 MOO](K-mlp-subspace-sparse-gp-asd-infill.md) | 高维昂贵 MOO 中标准 GP 训练慢，廉价代理或固定降维又易损失预测精度和不确定性可靠性 | MLP 扰动敏感性子空间采样、每目标稀疏 GP pseudo-input、ASD LCB/EI 密度多样性 infill、膝点补全回原空间 | 方法 | P2026-0178 |
| [稀疏迁移堆叠的多源代理选择](K-sparse-transfer-stacking-many-problem-surrogates.md) | many-problem surrogate 中无关源模型会稀释 stacking 权重并造成 negative transfer，且不同候选真实评价成本差异大 | 历史源代理选择、稀疏代理融合、成本敏感 infill 与真实评价调度 | 方法 | P2026-0220 |
| [异构评价时间的目标-约束真实评价调度](K-heterogeneous-objective-evaluation-time-scheduling.md) | 昂贵代理辅助 MOO/MaOO 中不同目标和约束评价耗时不同，整解全函数高保真评价会浪费 wall-clock 预算 | 解-目标/解-约束级高保真选择、参考向量非支配潜力、代理误差、评价时间与约束边界联合调度 | 方法 | P2026-0227, P2026-0107 |
| [代理-仿真混合的不确定性评价加速](K-surrogate-simulation-hybrid-uncertainty-evaluation.md) | 混合不确定 MOO 中 Monte Carlo 估计目标/约束成本高，纯代理又可能因误差造成可行性误判 | 数据池去重、随机森林不确定参数代理、代理/Monte Carlo 概率混合评价与阈值重训 | 方法 | P2026-0282 |
| [异步子任务精英池协同进化](K-asynchronous-subtask-elite-pool-coevolution.md) | 分解式结构搜索中同步迁移会打断子任务连续演化，弱通信又难复用优质结构 | 多子任务并行演化、精英池共享与迁移通信 | 方法 | P2026-0049 |
| [共享精英路线池的并行协同进化](K-shared-elite-route-pool-parallel-evolution.md) | 组合型 MOO 的完整精英解迁移粒度过粗，差解中的优质路线/组件容易被淘汰，各并行子种群又会重复发现相似局部结构 | 并行子种群、共享精英组件池、组件级评分、分层交叉/变异、多极角重叠兼容性判定与权重向量选择 | 架构 | P2026-0108 |
| [非支配排序迁移的并行岛模型 MOEA](K-nondominated-sorting-migration-island-moea.md) | 并行岛模型中只按单一目标或局部最优迁移会破坏多目标权衡、降低多样性，数据岛独立训练又需要有限同步共享 | Spark/MapReduce 数据岛、worker 本地 MOEA、driver 全岛合并、non-dominated sorting+crowding distance 迁移、测试阶段复用模型系数 | 方法 | P2026-0005 |
| [网格排序成对关系代理筛选](K-grid-ranked-pairwise-relation-surrogate.md) | 昂贵 MOO 中回归代理难以高维精确预测、分类代理样本不平衡 | 代理辅助候选预筛选、训练样本构造与参考点筛选 | 方法 | P2026-0009 |
| [可训练性约束的在线分类器辅助 NAS](K-trainability-constrained-online-classifier-nas.md) | FNN/NAS 候选训练昂贵且低可训练结构会浪费评价，普通回归预测器少样本偏差大 | NAS 环境选择、trainability 约束、在线好坏分类器和候选准入门控 | 方法 | P2026-0218 |
| [多保真不确定集成的 NAS 评价加速](K-multifidelity-uncertainty-ensemble-nas-evaluation.md) | NAS 候选完整训练昂贵，短训评价易误删慢热架构，单一性能预测器又受噪声和样本偏差影响 | partial/full training 混合评价、潜力档案重评、不确定性回归集成和 RSRTA 多样性选择 | 方法 | P2026-0236 |
| [滤波性能预测的特征子集预筛选](K-filter-performance-predictor-feature-subset-preselection.md) | 多目标特征选择中 wrapper 评价昂贵，普通回归/分类代理在高维少样本二进制子集空间中不稳 | filter 指标 rank 校准、相关系数门控预筛、特征数量差异多样性补充 | 方法 | P2026-0214 |
| [统计排名引导的子集演化算子](K-statistical-rank-guided-subset-evolution-operators.md) | 高维子集型 MOO 中随机初始化、交叉和变异容易浪费评价在低相关变量组合上，纯 filter top-k 又忽略组合效应 | 统计/领域变量排名、top-k 阶梯初始化、rank-biased union crossover、rank-biased 与 random mutation 互补、wrapper Pareto 校正 | 方法 | P2026-0030 |
| [交互感知岛模型的多目标生物标志物选择](K-interaction-aware-island-biomarker-selection.md) | 高维 omics/子集选择中变量冗余和交互强，单种群全变量随机重组容易早熟且破坏有用组合 | GRRA 收敛/多样性基因分解、交互子组内收敛优化、diversity genes 角度多样性选择、island 精英迁移 | 架构 | P2026-0090 |
| [任务相关性聚类与统一特征空间的多任务特征选择](K-task-clustered-uniform-space-emt-feature-selection.md) | 多输出/多任务特征选择中任务相关性未知，盲目 EMT 会负迁移；不同预处理又会破坏共享特征编码 | Pearson+Spearman 任务相关性聚类、统一预处理管线、共享二进制种群、任务特异多目标评价与 `N/K` 配额选择 | 架构 | P2026-0028 |
| [总体-少数类双任务特征选择迁移](K-overall-minority-dualtask-feature-selection-transfer.md) | 高维不均衡分类中特征选择若只优化总体性能会忽略少数类，只优化少数类又可能牺牲整体且产生无意义低特征高误差非支配解 | 特征选择任务构造、少数类 cost-sensitive 辅助任务、cross-task mating transfer 与约束环境选择 | 方法 | P2026-0169 |
| [全局-局部约束代理与向量场景约束支配](K-global-local-constraint-surrogate-vcdp.md) | 昂贵约束 MOO 中约束预测误差会直接误导可行性判断，单一全局代理难拟合狭窄或断裂可行域 | 全局/局部约束 GP ensemble、参考向量局部样本、VCDP 约束处理、两阶段 SAEA | 方法 | P2026-0229 |
| [特殊点引导的代理辅助复杂前沿搜索](K-special-point-guided-surrogate-complex-front-search.md) | 昂贵 MOO 中复杂/断裂 PF 的膝点和间断区域样本稀缺，普通代理选点容易盲目或过度开发 | 非支配等级集成代理、膝点置信区间开发、断裂区间探索与参考向量调整 | 方法 | P2026-0013 |
| [约束违反状态驱动的代理搜索模式切换](K-constraint-violation-state-surrogate-mode-switching.md) | 昂贵约束 MOO 中单一代理/搜索模式难以同时处理可行性恢复、收敛和多样性 | 代理管理、约束搜索阶段调度与档案数据源选择 | 方法 | P2026-0151 |
| [收敛-边界两步代理采样更新](K-convergence-boundary-stepwise-surrogate-sampling.md) | 昂贵约束 MOO 中只采目标空间优质解会忽略约束边界可行性预测 | 代理训练集更新、真实评价样本选择与约束边界采样 | 方法 | P2026-0023 |
| [预测代理驱动的实时多目标控制优化](K-predictive-surrogate-driven-real-time-moo-control.md) | 实时工程控制需要在安全约束内快速给出多目标参数建议 | 代理目标建模、贝叶斯 MOO 与实时控制决策 | 方法 | P2026-0041 |
| [可行性阶段调度与变尺度混沌 MODE 控制调参](K-feasibility-staged-chaotic-mode-control-tuning.md) | 控制器隶属函数/权重调参中固定 DE/MODE 难同时发现可行参数、维持 Pareto 分布并避免后期局部聚集 | fuzzy controller MFs、PID/MPC/control allocation 权重、多目标控制参数搜索、可行性筛选与混沌局部精修 | 方法 | P2026-0149 |
| [Pareto 数据关联的在线跟踪选解层](K-pareto-data-association-online-tracking-selection.md) | 在线多目标跟踪中固定加权或级联匹配会在空间、外观和置信度冲突时过早丢弃可行关联假设 | 多目标关联矩阵、虚拟新轨迹/假阳性行、有界 MOEA Pareto 搜索、knee point 与任务优先级单解选择 | 架构 | P2026-0140 |
| [受控通道序列视觉个体识别](K-controlled-channel-sequence-vision-identification.md) | 群体目标自由通过时遮挡、速度波动和单帧模糊会让身份识别不稳定，单纯检测或单帧分类难落地 | 物理分流通道、顶视背部外观、MEB-YOLOv8n+ByteTrack、MIoU 检测框裁剪、Laplace 清晰度过滤、序列投票 | 架构 | P2026-0072 |
| [谱聚类粗细粒度全网仿真控制优化](K-spectral-region-coarse-fine-full-network-control.md) | 图耦合大规模控制问题中，全维直接优化维度过高，局部独立优化又会破坏跨区域协调 | 谱聚类区域压缩、全局协调、局部精修、全网仿真评价与边界流保真 | 架构 | P2026-0285 |
| [GP 不确定性引导的多机数字孪生 RL 迁移](K-gp-uncertainty-guided-rl-digital-twin-transfer.md) | 少样本新机器/新产品工艺优化同时面临多目标、漂移、实时控制和跨机器迁移，单独代理或 RL 都难稳定部署 | 深度特征-GP 数字孪生、GP 后验不确定性引导 SAC/DRL、双时间尺度 embedding、MLTL 多机迁移与 DT Manager 增量闭环 | 架构 | P2026-0168 |
| [多路径丢包下混合观测器控制的多性能 LMI 设计](K-multipath-dropout-hybrid-observer-lmi-control.md) | 切换网络控制中控制输入、测量输出和切换规则均可能丢包，传统观测器又依赖可用 plant dynamics | 三路径 Bernoulli 丢包建模、mode-dependent/independent 混合观测器控制器、MLF/ADT 多性能 LMI 合成 | 方法 | P2026-0174 |
| [代理驱动的可持续材料配比多目标优化](K-prior-knowledge-embedded-surrogate-mix-optimization.md) | 材料配比实验数据少、来源异质且真实试验昂贵，需同时优化强度/性能与碳排放、能耗或成本 | 先验方程约束或可解释 ML 代理、组分 CO2/成本/能耗目标、NSGA-II/MOPSO/GWO 配比优化、MCDM 选解、实验验证/LCA/稳健性检查 | 方法 | P2026-0060, P2026-0067, P2026-0027 |
| [类别生成与退火潜空间强化的多目标材料逆设计](K-acgan-sa-latent-targeted-material-inverse-design.md) | 材料生成模型容易贴近已知数据/Pareto 边界且缺少单性能定向突破，小样本类别内不均衡还会造成 sparse high-performance 区域漏搜 | ACGANs 高性能类别生成、GBRT 代理评价、SA 潜空间 Metropolis 扰动、SHAP/局部置信带可信性检查、active-learning 回灌 | 架构 | P2026-0065 |
| [预测嵌入的中断感知供应链多目标规划](K-prediction-embedded-disruption-aware-supply-chain-moo.md) | 供应链多目标规划中关键供给/质量参数不确定，且中断会同时改变成本、浪费和短缺 | 预测参数嵌入、模糊 MILP、场景分析与 ε-constraint 求解 | 方法 | P2026-0010 |
| [Regret 触发的 Pareto 概率预测](K-regret-triggered-pareto-probabilistic-forecasting.md) | 在线时序概率预测中固定更新和单一损失难同时兼顾漂移适应、概率校准和预测区间锐度 | 因果特征筛选、Transformer 概率预测、loss z-score/DLR 更新触发、QR-AEP/Q-Risk/PIW 三目标 Pareto 操作层 | 架构 | P2026-0044 |
| [残差再分解的多目标集成与区间调节预测](K-residual-redecomposition-multiobjective-ensemble-interval-forecast.md) | 非线性/混沌时间序列中主预测残差仍含可学习结构，传统固定区间为保证覆盖往往过宽 | CEEMD+样本熵去噪、异构模型池竞争、残差再分解、MOLA 残差权重优化、IIAC 覆盖-宽度双目标区间调节 | 架构 | P2026-0016 |
| [时间微批鲁棒多目标神经演化预测](K-robust-temporal-microbatch-moo-neuroforecasting.md) | 高波动能源时序中普通 RNN/attention 会传播冗余时间信息，单一全局误差会掩盖 ramp/drift 时段的误差集群 | temporal micro-batches、shared-weight temporal attention、关键时间步硬过滤、EAET/EVET/EAT 三目标鲁棒训练、LMMSCSO 状态竞争权重优化 | 架构 | P2026-0124 |
| [学习-遗忘与绿色投资耦合的可持续生产多目标建模](K-learning-forgetting-green-investment-sustainable-production-moo.md) | 传统 EPQ 固定生产率/缺陷率且把环保投资外生处理，难以同时评价成本、排放和返工 | EPQ 建模、LaF 动态、缺陷返工、绿色投资和碳交易目标 | 方法 | P2026-0073 |
| [碳税场景驱动的3E随机工业优化](K-carbon-tax-scenario-3e-stochastic-industrial-optimization.md) | 高碳复杂工业流程中固定排放因子和固定碳税会让低碳生产路径优化失真，直接三目标 MINLP 又难工业求解 | 工况聚类、2SLS 排放因子校正、LCA 3E footprint、确定性结构基线、K-means+RKDE 碳税场景概率、两阶段随机生产优化 | 架构 | P2026-0058 |
| [火用感知软硬约束能源调度强化学习](K-exergy-aware-soft-hard-constrained-energy-rl.md) | 多能源微网只按能量数量和 reward penalty 调度会忽略能源质量差异，且连续动作可能越过设备/氢掺混安全边界 | 多源氢流火用核算、cost-carbon-exergy ideal-distance reward、temporal segment state、TD3 soft penalty + hard physical action projection | 架构 | P2026-0074 |
| [瓶颈有效率播种的能效缓冲分配](K-bottleneck-seeded-energy-buffer-allocation.md) | 不可靠串行产线 BAP 中随机缓冲初始解和仿真评价导致收敛慢，且 throughput 与能耗/总缓冲量冲突 | EMM 解析评价、effective-rate/bottleneck 知识初始化、自适应 DE、Golden Ratio 总缓冲收缩、idle-energy 敏感性诊断 | 方法 | P2026-0064 |
| [非支配解模仿学习的参数化 MOEA](K-imitation-learned-parametric-moea.md) | 单一 MOEA 难适配多种复杂 PF，普通算子选择仍受原始决策空间演化限制，Pareto set learning 又缺少多专家自演化 | MOEA expert Pareto 解蒸馏、MTL Transformer 表示、MGDA SL 训练与 PPO 参数空间演化 | 架构 | P2026-0176 |
| [EMOA 档案预训练的 Pareto 集学习](K-emoa-archive-pretrained-pareto-set-learning.md) | PSL 从随机初始化容易陷入复杂景观局部最优，而普通 EMOA 只给有限解集，不能连续响应任意偏好 | EMOA 无界档案、非支配解反 Tchebycheff 偏好标签、preference-solution 监督预训练、PSL 细调、EMOA 收敛检测驱动 FE 分配 | 架构 | P2026-0142 |
| [目标解耦双 Critic 的多目标连续控制](K-objective-decoupled-dual-critic-continuous-control.md) | 连续动作工程控制中单一标量 reward 难以保留多目标长期回报结构 | 多目标强化学习、连续控制与工程决策支持 | 方法 | P2026-0063 |
| [混合参数化动作的多目标集成 Critic RL](K-hybrid-parameterized-action-ensemble-critic-morl.md) | 多目标顺序控制中单 critic 易稀释安全等关键目标，单一离散/连续动作又难兼顾语义稳定性和控制灵活性 | objective-specific ensemble critics、option+continuous-parameter actor、epistemic-uncertainty hybrid exploration 与安全/效率/一致性指标 | 架构 | P2026-0290 |
| [先验引导与信息增益回放的样本高效 MORL](K-prior-guided-informative-replay-morl.md) | 多目标强化学习需要覆盖多偏好，交互样本昂贵且普通回放难以优先利用高价值经验 | MORL 训练循环、先验 warm start、经验回放与偏好重标 | 方法 | P2026-0081 |
| [经验偏好权重进化的多目标强化学习](K-experience-level-evolution-preference-morl.md) | Preference-conditioned MORL 中策略参数进化评价昂贵，随机偏好重标又可能注入低质量经验 | 经验个体种群、偏好权重交叉变异、agent utility 过滤与 replay 增强 | 架构 | P2026-0259 |
| [连续时间竞争扩散的多目标图干预 RL](K-continuous-time-competitive-diffusion-graph-intervention-rl.md) | 图扩散干预中只优化最终影响范围会忽略控制速度，一次性种子组合选择又导致动作空间爆炸 | 连续时间竞争级联、多轮节点干预、GCN 状态编码、A2C 策略和阈值词典多目标奖励 | 方法 | P2026-0166 |
| [级联失效鲁棒影响与结构成本种子优化](K-cascading-failure-cost-aware-robust-influence.md) | 影响力最大化若只看正常网络传播会忽略攻击/级联失效下的功能保持，单一中心性成本又难表达节点结构代价 | `RIcf` 级联鲁棒影响、degree/k-shell/betweenness 结构成本、图上最短路离散随机游走、非支配档案与 TOPSIS 选解 | 方法 | P2026-0135 |
| [逐步熵公平与 Dirichlet 权重的扩散优化](K-stepwise-entropy-dirichlet-fair-diffusion-optimization.md) | 公平扩散/影响力最大化若只看终态覆盖会掩盖少数群体早期触达延迟，固定权重又难适配 spread-fairness 折中 | 扩散步级 group entropy、公平-影响双目标、Dirichlet 贝叶斯权重更新、Pareto/crowding leader、外部非支配 archive 与 TOPSIS 选解 | 架构 | P2026-0086 |
| [JSD-Jain 比例公平扩散与 FairWolf 种子搜索](K-jsd-jain-equity-fairwolf-influence-maximization.md) | 公平影响力最大化只看总扩散或单一公平指标时，难诊断社区比例错配和固定预算离散种子集搜索停滞 | JSD activation-population alignment、Jain proportional balance、公平-影响双目标、离散 set-swap GWO、稀疏 explorer leader、HV 停滞扰动 | 架构 | P2026-0165 |
| [多时间尺度目标分解的多目标分层 RL](K-multiscale-goal-decomposed-mohrl.md) | 工业全流程优化同时有长周期多目标计划、短周期操作跟踪和工况 context，单层或单偏好 RL 难以在线适应 | 上层 Pareto policy set、下层 goal/context-conditioned policy、MOHPG/D、population buffer 与 task-selection | 方法 | P2026-0192 |
| [Tchebycheff-ESR 分解式非凸 MORL](K-tchebycheff-esr-decomposition-morl.md) | MORL/D 中 weighted sum 难以覆盖非凸 Pareto policies，非线性标量化又可能破坏逐步 reward 加性 | ESR/full-return Tchebycheff 标量化、EUPG accrued baseline、权重自适应与子问题参数迁移 | 方法 | P2026-0286 |
| [等待上界可行动作过滤与状态增强 RL 控制](K-bounded-wait-feasible-action-state-augmented-rl-control.md) | 离散动作 RL 中平均奖励或罚项难保证低流量对象的最大等待/服务上界 | dynamic feasible action set、DQN target action mask、deadline/crosswalk state augmentation 与事件触发服务计时 | 方法 | P2026-0278 |
| [跨规模偏好融合的元 DRL 组合优化](K-cross-scale-preference-fused-meta-drl-mocop.md) | 多目标神经组合优化需要同时适应不同目标偏好和远大于训练规模的实例 | 偏好融合注意力、Reptile 元训练、RL inner-loop、zero/few-shot 推理 | 架构 | P2026-0167 |
| [POMIS 约束的元获取策略学习](K-pomis-constrained-meta-acquisition-policy.md) | 因果多目标 BO 的手工 acquisition 难以同时利用因果结构、多目标进展和干预成本 | 因果 MOBO 的干预集选择与 acquisition policy | 方法 | P2026-0119 |
| [拓扑 motif 的膝点感知 MOBO 采样](K-topology-motif-knee-aware-mobo-acquisition.md) | 昂贵工程 MOBO 中 scalarization、HV 或纯 uncertainty acquisition 难显式利用 Pareto front 拓扑和决策相关 knee regions | PH knee localization、motif-aware GNN saliency、GPR uncertainty、scale-normalized convex acquisition、candidate pool+CMA-ES | 方法 | P2026-0045 |
| [共享变量上层搜索的贝叶斯双层采样](K-component-sharing-bilevel-bayesian-search.md) | 昂贵 MOO 中最终方案集需要共享指定组件，普通 PF 搜索可能与共享偏好冲突且 nested MOBO 评价浪费 | 共享变量上层搜索、lower-level RF 近似、CSLCB acquisition 与 batch 真实评价 | 方法 | P2026-0242 |
| [Top-K 感知的共享组件集合双层搜索](K-topk-aware-component-sharing-bilevel-set-search.md) | CSMOO 最终只需少量 top-K 共享组件方案时，先求大 RF/PF 再后处理会浪费下层评价且忽略 K 解内部关系 | K 解拼接编码、HV-guided environment selection、共享变量邻域的并行 lower-level top-K task 协作与 TopK-BLS | 架构 | P2026-0262 |
| [可分解组件的 schema 级保存与重构](K-component-schema-preservation-reconstruction.md) | 完整解粗粒度选择会把差解中的优质路径/任务/模块组件一起淘汰，纯多种群分解又带来协调成本 | 组件/schema ranking matrix、schema repository、最差组件替换、跨组件约束重评与 age-based 仓库更新 | 方法 | P2026-0206 |
| [cGAN 下层前沿预测的双层搜索降本](K-cgan-lower-front-prediction-bilevel-search.md) | 双层 MOO 中逐个上层候选严格下层搜索开销高，拟合高维下层 Pareto set 又训练昂贵且易误导 | cGAN lower-level PF prediction、dGD 下层收敛约束转化、promising 上层向量筛选 | 方法 | P2026-0196 |
| [协作式双层多目标反应集决策](K-cooperative-reaction-set-selection-bilevel-moo.md) | 双层多目标中下层 reaction set 多解，optimistic/pessimistic 选解假设过强且难体现下层 DM 偏好与部分合作 | 下层 profile、上层/下层 desirability、固定/动态 cooperation index、反应集折中选解 | 方法 | P2026-0246 |
| [攻击者路径响应嵌套的多目标网络阻断搜索](K-attacker-path-response-nested-network-interdiction.md) | 网络阻断中静态图指标或单目标下层路径会忽略攻击者重新规划，普通 MOEA 又不利用割边和瓶颈结构 | 上层边阻断 MOEA、下层 BOA 路径反应、ideal-point 代表响应、动态可靠性阈值、下层路径 min-cut 局部搜索 | 架构 | P2026-0109 |
| [因果领域引导的离散反事实搜索](K-causal-domain-guided-discrete-counterfactual-search.md) | 离散反事实推荐需要同时提升结果、控制改动成本，并避免随机变异忽略领域因果结构 | 离散反事实编码、领域引导变异、Pareto 层内偏好选择与在线重规划 | 方法 | P2026-0039 |
| [非支配退火的离散替换优先级搜索](K-pareto-metropolis-discrete-substitution-search.md) | 离散文本/符号替换同时追求大幅扰动和模型预测保持，固定权重或贪心优先级容易局部最优且查询成本高 | stopword/语义候选替换、重要性采样、单双扰动候选、非支配排序 rank 与 Metropolis 温度接受 | 方法 | P2026-0291 |
| [评论感知的长度约束摘要多目标句子选择](K-comment-aware-length-constrained-summary-selection.md) | 主文档摘要若只看源文本会忽略用户评论关注点，直接拼接评论又会引入噪声和冗余 | 文档/评论 centroid 双相关目标、句间冗余目标、评论过滤、长度感知 add/remove/exchange mutation 与 repair | 架构 | P2026-0021 |
| [单侧规则-分类器双阶段 Pareto 进化](K-unilateral-rule-classifier-biphase-pareto-evolution.md) | 不均衡可解释分类中，高风险少数类需要规则覆盖，同时要控制规则数量与约束复杂度 | Michigan 单规则进化、Pittsburgh 规则集分类器进化、互补覆盖 DF、accuracy-interpretability Pareto 选择 | 方法 | P2026-0241 |
| [受限子问题变换组合的基准生成](K-restricted-transformed-composite-benchmark-generation.md) | 缺少可调、可扩展的多模态多目标测试问题 | Benchmark 生成 | 方法 | P2026-0144 |
| [超曲面不规则时联动的 DMOO 基准构造](K-hypersurface-irregular-time-linked-dmoo-benchmark.md) | 常用动态 MOO benchmark 的 PS 超平面运动和规则时间变化会偏向特定算法，难以检验变量不均衡、交互和历史误差传播 | 超曲面 PS 动态、对角贡献不均衡、正半定矩阵变量交互、pi 位数不规则扰动、time-linkage 与 runtime-aware 动态评价 | 方法 | P2026-0148 |
| [对象化公私空间的 MOP 基准生成](K-object-oriented-public-private-mop-benchmark.md) | 现有人工 MOP benchmark 难同时控制目标异构结构、公共冲突空间、复杂 PS/PF 形状和 local/global PS 吸引域 | MOP/Objective/Landscape/Peak/Public Pareto region 对象层次、private/public 变量分组、辐射式 Public Pareto region、`psi` PF 生成、PriCQ/PubCQ/OCR 诊断 | 方法 | P2026-0102 |
| [多实现有效距离综合指标](K-effective-distance-multi-realization-indicator.md) | 只看目标空间会忽略等价 Pareto 解的决策空间覆盖 | 算法评价、档案或环境选择 | 方法 | P2026-0144 |
| [愿望-保留水平驱动的复合质量指标](K-aspiration-reservation-composite-quality-indicators.md) | 单一 QI 难同时评价收敛、规模、spread 和 uniformity，多个 QI 排名冲突且缺少偏好阈值解释 | 算法离线评价、指标聚合、W/S/M 补偿分析与 indicator-based selection | 方法 | P2026-0222 |
| [收缩-扩散率的不平衡 MOP 多样性诊断](K-shrinkage-spread-imbalanced-mop-diversity-diagnostics.md) | 不平衡 MOP 中种群一旦聚集到 favored PF 区域，多样性恢复概率极低，普通 IGD/HV 难解释崩塌机制 | 全局/局部 shrinkage-spread rates、net spread rate、epsilon-MDNDS、可调 IMP benchmark 与 diversity-first 设计原则 | 方法 | P2026-0257 |
| [紧凑 MIP 的 Dominance Move 精确计算](K-compact-mip-dominance-move-indicator.md) | DoM 指标可解释但原 assignment/MIP 精确计算随解集规模产生大量变量和约束，many-objective 场景过慢 | 离线性能评价、binary quality indicator 计算、indicator-based selection、DoM-guided archive/variation | 方法 | P2026-0258 |
| [CRITIC-TOPSIS 评价反馈引导演化](K-critic-topsis-feedback-guided-evolution.md) | 两阶段“先优化后评价”无法把管理偏好和综合绩效及时反馈给搜索过程 | 外部档案排序、MCDM 评价、精英选择与演化方向引导 | 方法 | P2026-0114 |
| [Nash 协商的 Pareto 模型选解](K-nash-bargaining-pareto-model-selection.md) | Pareto 解集后处理若用固定权重、单一 knee point 或人工挑选，容易选到极端方案且难复现 | 目标归一化 utility、disagreement point、NBS 联合盈余乘积、accuracy-parsimony-robustness 公平折中 | 方法 | P2026-0097 |
| [双路径意见演化-多目标共识优化](K-dualpath-opinion-dynamics-multiobjective-consensus.md) | 社交网络大规模群决策中单一最低成本共识难同时保留组内意见多样性、个体满意度和全局共识质量 | trust-aware 分群、DeGroot-HK 组内意见演化、动态 trust 更新、satisfaction-cost-consensus 三目标 MSCC Pareto 调整 | 架构 | P2026-0088 |
| [兼容偏好模型的进化均匀采样](K-evolutionary-compatible-preference-model-sampling.md) | 交互式 EMO 中 DM 只给少量成对比较，直接采样兼容偏好模型在强约束/高维下低效且分布偏斜 | pairwise comparison 偏好反演、compatibility degree、nearest-neighbor 多样性、固定 queue、进化拒绝采样与 IEMO/D scalarizing functions | 方法 | P2026-0106 |
| [成功率反馈的算子与参数自适应选择](K-success-rate-feedback-operator-parameter-adaptation.md) | 固定或随机算子/参数无法适应搜索阶段变化，低使用率但有效的算子还可能被过早淘汰 | 子代生成、算子选择与参数控制、absolute/relative survival 反馈、双激活 GA/DE 使用比例调节、无状态 LNSS 邻域 reward 选择 | 方法 | P2026-0026, P2026-0239, P2026-0163, P2026-0145 |
| [组件模板-竞速自动配置的 MOEA 生成](K-component-template-racing-automatic-moea-configuration.md) | 调度等问题中手工设计 MOEA 难跨场景扩展，在线算子选择又不能一次性生成可复用完整算法 | 通用 MOEA 执行模板、阶段化组件库/参数空间、full/partial 双频 sampling、t-test racing、重复组件组合去重、configure once apply repeatedly | 架构 | P2026-0022 |
| [状态驱动的 DRL 演化算子选择](K-drl-state-driven-evolutionary-operator-selection.md) | 固定、随机或短期反馈算子/参数/迁移控制难以利用搜索状态和长期收益，单一动作又会限制同代搜索范式 | 子代生成、算子/CHT 联合选择、算子组合比例、GA/DE/PSO/LS 调度、交叉/变异/KLS 策略、PSO/DE 参数、双种群迁移规模、critical-path/block、路径级局部搜索与多目标排课 LLH 控制 | 方法 | P2026-0042, P2026-0239, P2026-0244, P2026-0201, P2026-0285, P2026-0209, P2026-0273, P2026-0117, P2026-0020, P2026-0035, P2026-0137 |
| [RL 阶段式 MOEA 组合选择与多样性重置](K-rl-stagewise-moea-portfolio-selection.md) | 混合特征 MOP 中单一 MOEA 结构偏置明显，算子级调度又不能切换环境选择、分解方式和子种群组织 | 完整 MOEA portfolio、阶段式 DQN/Q-learning 选择、收敛/稀疏区域状态、终端 HV reward、算法切换多样性种群重置 | 架构 | P2026-0015 |
| [市场状态奖励-群决策-持续学习的金融 RL](K-market-state-reward-ensemble-continual-rl-trading.md) | 非平稳金融市场中静态 reward 或单一 RL 策略难同时适应 regime 切换、风险控制、交易成本和长期策略退化 | 20 日 market regime 识别、risk-cost-return 动态多目标 reward、A2C/PPO/DDPG/SAC reward-weighted capital allocation、90/30 滚动训练、reward inheritance | 架构 | P2026-0036 |
| [网格片段遮罩的 RL 引导分子演化](K-grid-fragment-masked-rl-molecular-evolution.md) | 多目标分子生成中固定片段库限制 novelty，随机片段重组无效候选多，深度生成模型又降低可解释性 | objective-grid 父代配对、scaffold/side-chain mask、片段切割重组、双 actor-critic 交叉/突变策略与 Pareto-GMean reward | 架构 | P2026-0157 |
| [梯度 VCS 三目标的 HFL 客户端选择](K-gradient-vcs-hfl-client-selection.md) | 固定层级联邦学习中随机或单指标客户端选择会偏向 dominant clients，难同时保证全局精度、收敛和少数客户端公平性 | 固定数量二进制客户端编码、梯度价值/互补多样性/历史一致性三目标、NSGA-II 选择、双层 FedMGDA 聚合 | 架构 | P2026-0295 |
| [多目标 GP 构造特征库的随机 DRL 选择](K-mogp-constructed-feature-library-sdrl-selection.md) | 原始特征或组件表达能力不足，直接 DRL 选择又易过拟合并探索不足，且缺少黄金标签奖励 | MOGP 组件构造、概率 Q 向量子集选择、近似质量奖励与聚合 | 方法 | P2026-0276 |
| [偏好条件单启发式的 Pareto 集学习](K-preference-conditioned-single-heuristic-ps-learning.md) | 多目标动态调度中维护多条 Pareto 启发式复杂，用户偏好实时变化时难以快速选择和切换 | 偏好输入 GP 调度规则、跨偏好 KNN 代理评价、preference diversity、多准则选择与偏好轮换 | 架构 | P2026-0232 |
| [行为表征精英档案引导的 GP 搜索收缩与小树小生境](K-phenotypic-elite-archive-niching-gp-search.md) | GP 调度规则在全启发式空间搜索效率低，普通 archive 不利用行为分布，Pareto 规则树过大又降低解释性 | PC 行为表征、非支配精英 archive、动态搜索半径、PC 小生境与小树代表选择 | 方法 | P2026-0197 |
| [确定性新颖性衰减的神经进化权重调度](K-deterministic-novelty-decay-neuroevolution-weighting.md) | 固定新颖性或固定性能权重难以同时兼顾早期结构探索与后期性能开发 | NAS、神经进化、程序搜索与结构候选选择 | 方法 | P2026-0040 |
| [变量长度与时间扩展的脉冲架构搜索](K-variable-length-temporal-snn-architecture-search.md) | SNN NAS 中固定深度编码和只看空间结构的变异难以自动平衡精度、延迟与能耗 | 变量长度架构编码、深度/通道/时间维变异、精度-脉冲数双目标 NAS | 方法 | P2026-0217 |
| [复杂度分组的目标子空间排序](K-complexity-grouped-objective-subspace-selection.md) | 多目标 NAS/性能-资源搜索中复杂度目标更易优化，普通全局 Pareto 选择会偏向过小低性能候选 | 按复杂度/资源预算切分 objective space、组内非支配排序、分层 archive 与下一代选择 | 方法 | P2026-0187 |
| [持久同调-膝点保拓扑子集选择](K-persistent-homology-knee-subset-moea-selection.md) | 昂贵 MOEA/模型超参数搜索中全种群逐代评价成本高，随机缩小又容易丢失膝点、极端点和 PF 全局形状 | knee solutions、extreme preservation、persistent-homology joint solutions、Wasserstein topology matching 与代表子集评价 | 方法 | P2026-0199 |
| [复杂度均匀采样的双种群 NAS 搜索](K-complexity-uniform-bipopulation-nas.md) | NAS 编码空间在 MAdds 等复杂度轴上天然分布不均，随机初始化和普通双向迁移会漏掉低/高复杂度区域 | MAdds 分桶均匀初始化、低/高复杂度与中等复杂度双种群分工、不对称 elite 迁移、pairwise surrogate 与权重继承评价 | 方法 | P2026-0289 |
| [两阶段辅助目标的 BNN-NAS 小模型陷阱规避](K-two-stage-auxiliary-objective-bnn-nas-selection.md) | 权重共享/低保真 NAS 中小模型早期更快获得好评价并受资源目标偏好，导致较大潜力模型过早淘汰 | 辅助目标非支配排序、早期大模型保护、后期真实/辅助排序交替环境选择 | 方法 | P2026-0180 |
| [架构距离生态位的 NAS 多模态多样性选择](K-architecture-distance-niching-nas-diversity.md) | 多目标 NAS 只看目标空间 crowding 会输出结构相似模型，故障或缺失输入下缺少互补备用架构 | 架构编码/语义距离、AANS 父代生态位选择、ADD 替代 crowding、NDH/SE 多样性评估 | 方法 | P2026-0253 |
| [物理语义-流形联合编码的神经演化 NAS](K-physics-semantic-manifold-neuroevolution-nas.md) | 科学模型 NAS 若只搜拓扑或 loss 权重，难以同时调节物理文本语义、intrinsic manifold 维度和神经算子成本 | LLM 方程/边界 prompt 语义门控、流形维度、FNO 层数/模态、RMSE-FLOPs Pareto 搜索与物理一致性验证 | 架构 | P2026-0274 |
| [风险提示驱动的稀疏专家路由](K-risk-prompt-sparse-expert-routing.md) | 多任务/多目标神经模型中共享表征会产生任务干扰，固定 decoder 或 loss 权重难按场景风险动态分配参数路径 | learnable risk/preference prompt、task-specific prompt split、top-K sparse MoE expert routing、共享-专属参数动态折中 | 架构 | P2026-0056 |
| [近似-稀疏双目标宽度学习训练](K-approximation-sparsity-multiobjective-broad-learning.md) | BLS/随机特征模型把误差和正则压成单目标会掩盖精度-稀疏折中，且性能对 hidden neuron 数量敏感 | approximation-sparsity 双目标、强凸稀疏算子、sparse/non-sparse Pareto 维护、global-winner swarm optimizer、half-threshold 剪枝 | 架构 | P2026-0025 |
| [结构启发初始化与多目标路径重联](K-structure-aware-initialization-multiobjective-path-relinking.md) | 离散/排列型 MOO 中随机初始化和普通变异不利用领域结构，精英解之间的折中区域探索不足 | 初始化、精英局部搜索、离散候选生成与路径重联 | 方法 | P2026-0098 |
| [可行组合矩阵驱动的稀疏初始化与预评价修复](K-feasible-combination-matrix-sparse-init-repair.md) | 离散任务-资源 assignment 的可行组合极稀疏，随机初始化和普通 repair 会把评价浪费在明显不可行组合上 | 任务级可行组合矩阵、线性稀疏初始化、评价前 row-level repair、普通 CHT 解耦 | 方法 | P2026-0266 |
| [司机行为碳排嵌入的多阶段运输可行进化](K-driver-aware-green-transport-feasible-evolution.md) | 绿色多阶段运输若只按距离/车辆排放或随机编码，会忽略司机行为并产生大量违反流量守恒/容量的候选 | 司机-路线-车辆碳排目标/约束、TrIF 期望值确定化、阶段流量矩阵编码、可行初始化与守恒变异、NSGA-III 参考点选择 | 架构 | P2026-0150 |
| [区域压缩编码与多解路径解码](K-region-compressed-route-encoding-multisolution-decoding.md) | 大规模路网路径编码过长且交叉/变异后易断裂，不利于生成多样 Pareto routes | 区域序列编码、相邻区域修复、区域对路径生成与多解解码 | 方法 | P2026-0194 |
| [链路属性知识调制的离散 PSO 权重更新](K-link-attribute-knowledge-modulated-discrete-pso.md) | 图/网络链路权重优化中，无知识的离散更新容易让高容量链路变贵或让低容量枢纽/热点链路过度吸流 | 链路权重编码、Dijkstra+ECMP 解码、带宽/中心性/需求热点门控、离散 PSO 速度更新 | 方法 | P2026-0264 |
| [仓库锚定子路线编码与支配反馈自适应 VNS](K-depot-anchored-subroute-encoding-adaptive-vns.md) | 异构多仓/顺序访问 VRP 中仓库供给、产品容量和客户需求前序强约束使 giant-tour 与普通邻域易产生不可行路线 | depot-anchored sub-route fusion encoding、容量可行初始化、支配反馈 DE/CR shaking、子路线 2-opt/交换与 NNS 约束插入 | 方法 | P2026-0281 |
| [延迟中代局部搜索的 memetic MOEA](K-delayed-midgeneration-local-search-memetic-moea.md) | 离散组合 MOO 中过早局部搜索会早熟，过晚局部搜索又来不及扩散改进，纯 MOEA 还难利用路径/调度邻域结构 | 先 NSGA-II 全局探索、中代触发问题特定 LS、可行 Pareto first-improvement 接受、后续 crowding/非支配排序保多样性 | 方法 | P2026-0033 |
| [松弛分布驱动的稳健动态路由](K-slack-distribution-robust-dynamic-routing.md) | 动态请求会消耗时间窗/容量 buffer，静态鲁棒计划若不考虑未来插入容易后续不可行或成本过高 | STDI 主动 slack 分布目标、低成本扰动容忍鲁棒评价、时空插入与 key-route VND 动态修复 | 架构 | P2026-0268 |
| [连续偏好编码的学习引导离散 MOO](K-continuous-preference-ml-guided-discrete-moo.md) | 离散推荐/组合选择空间不平滑，随机算子难以学习收敛与分布改进方向 | 离散多目标推荐的编码解码、机器学习辅助子代生成与状态触发调度 | 方法 | P2026-0139 |
| [分解 ILS 的反馈扰动与档案协作](K-decomposition-ils-feedback-archive-collaboration.md) | 稀疏可行 MOCOP 中普通 MOEA 可行性差，均匀分解局部搜索又会冗余探索 | 少量 scalar 子问题、ILS 扰动度反馈、资源分配与 archive 协作接受 | 架构 | P2026-0277 |
| [全子问题即时更新的嵌入式分解局部搜索](K-embedded-decomposition-local-search-immediate-update.md) | 分解式 ILS 若把局部搜索当单子问题黑盒，会浪费 LS 中途产生的跨权重有用邻居，并可能在未局部最优解上扰动 | LS 邻居对全部 scalar 子问题即时检查替换、局部最优状态标记、全体局部最优后统一 perturb、外部 archive 输出 | 架构 | P2026-0272 |
| [时段分解随机拼接的约束调度搜索](K-temporal-block-decomposition-random-concatenation-cmoea.md) | 长时域能源调度中变量随时间维度膨胀，局部时段约束多而跨时段约束少，直接全维 CMOEA 可行性和收敛困难 | 时间块子问题预优化、随机变量片段拼接、MP/DAP/SAP 三种群完整问题修复 | 架构 | P2026-0179 |
| [疲劳感知的机器-工人双资源调度建模](K-fatigue-aware-dual-resource-scheduling.md) | 人因制造调度中只优化机器时间/成本会把疲劳集中到少数工人，静态负载又难表示作业-休息时序疲劳 | 工序-机器-工人三段编码、HRV/NASA-TLX 复合疲劳、非线性恢复、疲劳阈值与 Gini 疲劳公平目标 | 架构 | P2026-0273 |
| [层级路径重构的约束感知 MRTA](K-hierarchical-route-reconstruction-constrained-mrta.md) | 电量、容量、多 trip 和负载能耗约束下，全局任务序列难以局部修复路线瓶颈 | route/robot 双层编码、充电后片段重构、最长路线分割与小 MILP 重分配 | 架构 | P2026-0177 |
| [自适应路由-任务拆分的多机器人分配](K-adaptive-route-task-splitting-mrta.md) | 多机器人多行程任务中任务可拆分会把离散路线结构和连续拆分比例耦合，固定编码或过早拆分易导致搜索空间膨胀和负载失衡 | 路线/拆分混合编码、宏观路线结构优化、贡献/时间驱动的 MTSO 调度、偏离任务识别、空间邻近与负载均衡拆分 | 架构 | P2026-0254 |
| [时空光伏收益嵌入的电动车路径充电协同](K-spatiotemporal-solar-aware-ev-routing-charging.md) | 光伏电动车的路上发电随时间、路段方向和遮阴变化，普通 EVRP 固定能耗/充电模型会误判 SOC 与充电需求 | road element 光照建模、VIPV/BESS SOC 评价、充电站插入与多目标路径-充电 Pareto 搜索 | 架构 | P2026-0280 |
| [时空需求预测嵌入的 V2G 双目标充放电调度](K-spatiotemporal-demand-v2g-charging-scheduling.md) | 大规模 EV 充电受出行链、温度、空调、道路拥堵和电价共同影响，TOU 有序充电可能制造新峰值 | Markov/Monte Carlo 时空出行负荷预测、动态电池耗能、V2G 充放电约束、用户成本-电网波动双目标、IMOBFO Pareto 搜索 | 架构 | P2026-0077 |
| [业务偏好约束的多段染色体搜索](K-business-constrained-multipart-chromosome-search.md) | 装载/配载中直接三目标搜索会给出业务不可接受解，普通排列编码又难同时表示任务、资源槽位和多执行体序列 | 多段排列/断点染色体、epsilon 阈值扫描、受限 Pareto 搜索与业务启发式对比 | 方法 | P2026-0279 |
| [依赖诊断驱动的排列 P3-PMX 搜索](K-linkage-diagnosed-permutation-pyramid-pmx.md) | 排列型组合 MOO 中变量依赖结构可能稀疏也可能高度重叠，盲用 linkage 分解或普通 PMX 都会错配 | 多权重 pbELL/wVIG 结构诊断、高 epistasis 判定、parameter-less population pyramid、随机权重标量化、donor-like PMX 与非支配输出 | 架构 | P2026-0046 |
| [递归时间步资源解码的岛模型约束 MOEA](K-recurrent-temporal-resource-decoding-island-moea.md) | 强约束时空资源调度中直接编码完整资源-任务-时间矩阵会产生大量不可行解，维护/故障还会动态切断资源空间 | 优先级/层级/位置紧凑编码、逐时间步资源解码、维护子区间切分、CDP、farthest candidate 与 island parallel evolution | 架构 | P2026-0284 |
| [预算鲁棒的多访卡车-无人机救援路径](K-budget-robust-multivisit-truck-drone-routing.md) | 灾后救援中地面道路时间不确定且物资不足，单访无人机和确定性路径难同时保证公平、效率与鲁棒性 | Gini 满足度公平分配、Bertsimas 预算不确定卡车时间、多访无人机 sortie、`epsilon`-AMOSA-ALNS、OOS 鲁棒审计 | 架构 | P2026-0125 |
| [双链同步通行的船闸-航道动态解码](K-dualchain-synchronous-lock-channel-dynamic-decoding.md) | 锁群/引航道等多阶段通行调度中，任务顺序、资源路径、空间装载、同步速度和等待区容量强耦合，普通编码易产生不可行解 | 任务顺序链+资源路径链、FCFS+BEM 播种、ship placement/navigation/lockage 三阶段动态解码、freeboard/maneuverability 同步速度、FREA fitness、DDE+VNSA | 架构 | P2026-0084 |
| [多场景鲁棒的锁-泊位-卡车联动调度](K-multiscenario-robust-lock-berth-truck-coscheduling.md) | 内河枢纽调度同时受水位差、泊位效率和卡车速度扰动影响，确定性方案容易在部分场景不可执行 | 多场景鲁棒模型、锁/泊位/卡车领域调度解码、二进制通行模式编码、MO-ALNS destroy-repair、外部 Pareto archive 与不确定因素归因 | 架构 | P2026-0038 |
| [非支配排名驱动的辅助速度决策修正](K-rank-based-auxiliary-speed-decision-refinement.md) | 绿色路由/调度中主结构可行后，速度或能耗档位等辅助变量仍决定时间-排放折中，随机设置易漏掉 Pareto 解 | 主结构-辅助变量分层编码、极端档位 rank 探测、逐弧速度修正与前沿加密 | 方法 | P2026-0215 |
| [右移-调速协同节能解码](K-right-shift-speed-scaling-energy-decoding.md) | 带可变机器速度的绿色调度中，单纯利用已有 idle gap 降速难在不增加 makespan 的前提下充分降低 TEC | ODS 后处理、available idle window、right-shift policy、速度矩阵更新、前期 ODS/后期 EEDS 阶段切换 | 方法 | P2026-0145 |
| [前向事件解码与反向能耗压缩调度](K-forward-event-decoding-reverse-energy-compression-scheduling.md) | 有限缓冲/阻塞/重入调度中编码个体难以直接满足可行性并兼顾交期、makespan 和能耗 | 调度解码、反向/后向能耗压缩、关键作业邻域、UCB 算子选择与 EAJ/ETJ/BIJ 理论筛选 | 方法 | P2026-0085, P2026-0160 |
| [能量反馈自适应机器重启调度](K-energy-feedback-adaptive-machine-restart-scheduling.md) | 绿色制造调度中固定机器启停阈值难同时适应 idle 能耗、restart 能耗和频繁启停导致的设备寿命风险 | 调度解码、机器 standby/shutdown/restart 状态决策、碳排目标计算、worker-aware restart 资源约束 | 方法 | P2026-0020 |
| [服务寿命-碳排耦合的动态预维护调度](K-service-age-dynamic-premaintenance-green-rhfs-scheduling.md) | 绿色 RHFS 若把维护时间和加工能耗视为固定，会低估机器老化带来的碳排增长与 PM 对产能的挤占 | Weibull 可靠性阈值、service-age energy/PM-time mapping、空闲窗口优先 PM 插入、右移补救、makespan-carbon Pareto 调度 | 架构 | P2026-0087 |
| [IUD-ERT-RLS 批调度启发式解码](K-iud-ert-rls-batch-scheduling-decoder.md) | 编码个体难以直接满足批容量、到达时间、交期和能耗调度约束 | 调度问题的编码解码、批形成与起始时间安排 | 方法 | P2026-0026 |
| [动态参考解管理的问题变换](K-dynamic-reference-solution-managed-problem-transformation.md) | 固定参考解会让 problem transformation 被过时高维锚点限制 | 大规模多目标问题变换、参考解更新与候选生成 | 方法 | P2026-0007 |
| [多邻域多知识的分解式多任务迁移](K-multineighbor-multiknowledge-mtom-transfer.md) | MO-MTO 中单一知识类型、单一迁移算子和固定迁移概率难以同时避免负迁移与迁移不足 | MOEA/D 子问题、任务内/跨任务邻域、静态/动态知识、邻域规模/迁移概率/迁移算子反馈控制 | 方法 | P2026-0191, P2026-0240, P2026-0243 |
| [局部流形双知识迁移与资源分配](K-local-manifold-dual-knowledge-transfer-allocation.md) | MMTO 中个体/全局分布/演化方向迁移容易受低相似任务、噪声分布或随机性影响，单一知识类型难以通吃高低相似场景 | LPCA/SOM 局部 manifold 与拓扑邻域、SK/LK 或高斯采样迁移、支配条件生成、offspring 贡献反馈资源分配 | 方法 | P2026-0170, P2026-0269 |
| [目标任务质量预测的对齐迁移筛选](K-target-quality-predicted-aligned-transfer-filtering.md) | EMOMTO 中源任务高质量解在异构目标任务中可能是差解，静态对齐或源任务 rank 选择都会造成负迁移 | 源/目标种群对齐、non-dominated/dominated 条件分布、目标任务分类器、迁移候选置信度筛选 | 方法 | P2026-0080 |
| [对抗生成模型分布学习的多任务知识迁移](K-gan-adaptive-knowledge-transfer-momto.md) | MO-MTO/MOMT 中直接个体迁移或固定生成策略难适配任务相似性变化，容易负迁移或浪费生成模型 | GAN/AAE source-target 分布或潜表示学习、迁移强度/阶段控制、生成知识嵌入 inter/intra-task offspring generation | 方法 | P2026-0205, P2026-0136 |
| [结构保真的架构编码与修复](K-structure-preserving-architecture-encoding-repair.md) | 普通结构编码和遗传操作会破坏关键 backbone 信息路径 | NAS、图结构搜索、结构候选生成与可行性修复 | 方法 | P2026-0069 |
