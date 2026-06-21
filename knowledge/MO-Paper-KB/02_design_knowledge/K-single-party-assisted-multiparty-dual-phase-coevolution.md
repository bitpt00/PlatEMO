---
knowledge_id: K-single-party-assisted-multiparty-dual-phase-coevolution
name: 单方辅助的多方双阶段协同进化
type: method
status: active
source_papers: [P2026-0248]
aliases: [MP-HCEA, multiparty population, single-party populations, dual-phase cooperation, weak cooperation, strong cooperation, dual-search mechanism, multistakeholder recommendation, 多方多目标, 单方辅助种群, 弱强合作, 多利益方推荐]
promotion_reason: 单篇论文提出但接口明确，包含 multiparty population 与 single-party populations 的分工、offspring-sharing 弱合作、parent-sharing 强合作、基于 survival rate 的阶段切换、离散 elite-guided/self-perturbation 双搜索，以及六个真实推荐数据集上的对比和参数证据，可直接改造离散 MPMOP 或多利益方平台优化
---

# 单方辅助的多方双阶段协同进化

## 核心内容

在 multiparty multiobjective optimization 中，不只维护一个面向所有 DM 目标的共同种群，而是同时维护一个 multiparty population `MP` 和多个 single-party populations `SP_i`。`MP` 搜索多方共同非支配解，`SP_i` 分别搜索第 `i` 个 DM 目标空间的 Pareto 解。早期用弱合作共享 offspring，让单方搜索产生的候选进入共同解环境选择；后期用强合作共享 parent，让单方优秀父代与 `MP` 父代交叉，增强共同种群在各方目标上的局部开发。对离散编码，再用 elite-guided search 和 self-perturbation search 进一步改造 `MP` 的次优个体。

```text
Initialize MP and SP_i
early phase:
    MP and SP_i generate offspring independently
    share offspring for environmental selection
    monitor survival of SP offspring in MP
switch condition:
    if weak cooperation no longer successful enough
    -> strong phase
late phase:
    estimate MP/SP_i success on party-i objectives
    exchange dynamic number of parent individuals
    allow cross-population crossover
    apply elite-guided search on MP suboptimal individuals
    fallback to self-perturbation if elite guidance fails
output common nondominated solutions from MP
```

## 建立理由

- 为什么值得独立维护：
  - 多方 MOP 的共同解既要满足整体折中，又不能忽略每个 DM 的单方 Pareto 结构；
  - 单种群 MPMOEA 容易让多方目标的选择压力过强，难以充分探索各方偏好下的优质离散解；
  - 该方法提供了明确的 MP/SP 多种群接口、阶段切换规则和离散局部搜索接口。
- 单篇具体方法的直接复用价值：
  - P2026-0248 给出 Algorithm 1-4，明确 weak cooperation、strong cooperation、switch condition、dual-search 和推荐系统矩阵编码；
  - 主文在六个真实推荐数据集上与 MOO/MPMOO baselines 对比，并给出 `beta` 参数分析。
- 与已有设计知识的区别：
  - 不同于“贡献自适应的多种群多目标协同”：该知识按目标子种群贡献调度 MaOP 搜索；本知识按 decision maker 划分 single-party 辅助种群，并服务于 multiparty common solutions。
  - 不同于“协作式双层多目标反应集决策”：该知识在双层 reaction set 中选择合作响应；本知识是单层 MPMOP 的多种群进化框架。
  - 不同于“局部通信精英交互的分布式多目标协同”：该知识面向通信受限节点间精英迁移；本知识面向多 DM 偏好结构，用阶段合作调节 offspring/parent 信息流。
  - 不同于一般 island model：`SP_i` 不是并行副本，而是优化不同 DM 的单方目标空间。

## 解决的问题

- 适用场景：
  - 多个 DM/stakeholder 各自关注不同目标集合；
  - 需要输出多方共同可接受的 Pareto 解，而非单一社会福利加权解；
  - 决策变量为离散、组合或矩阵编码；
  - 每方目标可以单独执行环境选择，且单方优质结构可能帮助共同解搜索。
- 现有方法为什么会失败或不足：
  - 普通 MOO 把所有目标整体优化，无法体现不同 DM 的利益边界；
  - 单种群 MPMOEA 只在共同空间排序，忽略 single-party Pareto 解对共同解的辅助作用；
  - 早期直接父代强交叉可能把尚未成熟的单方结构强行注入 `MP`，造成噪声迁移；
  - 后期仍只共享子代会限制局部开发，不能让共同种群继承单方优秀基因。
- 仍需解决的问题：
  - 更多 DM 时 `SP_i` 数量、总人口规模和评价预算如何控制；
  - DM 目标数量不均衡时，`SP_i` 对 `MP` 的影响如何归一化；
  - 约束、动态偏好、隐私和策略性 DM 场景如何扩展。

## 为什么可能有效

```text
single-party populations learn party-specific Pareto structures
-> early offspring sharing exposes MP to broad party-specific candidates
-> survival rate tells whether SP offspring still help MP
-> late parent sharing lets MP inherit mature party-specific genes
-> dynamic transfer size avoids fixed over/under migration
-> elite-guided search repairs suboptimal MP individuals toward Pareto genes
-> self-perturbation restores exploration when elite guidance stalls
```

关键假设是：每个 `SP_i` 的单方优质解包含可迁移到共同解的基因片段，并且共同解可以通过这些片段重组产生。如果各方目标完全冲突、单方最优结构彼此不可兼容，强合作可能放大负迁移。

## 实现接口

- 输入：
  - `M` 个 DMs 及每个 DM 的目标集合 `Obj_i`；
  - multiparty 环境选择规则 `Obj`，通常先按每方视角排序，再把各方 rank 当作新目标排序；
  - 每个 `SP_i` 的 single-party 环境选择规则；
  - 离散编码、交叉、变异和修复函数；
  - weak-to-strong 切换参数 `beta`。
- 输出：
  - `MP` 中的 common nondominated solutions；
  - `SP_i` 的单方搜索状态；
  - 弱合作成功代数、强合作转移规模和 dual-search 成功率。
- 插入位置：
  - MPMOEA 的种群结构层；
  - 多利益方推荐、组合投资、资源调度、平台分配等离散多方决策；
  - 多任务/多偏好 MOEA 中的辅助任务种群。
- P2026-0248 的二方实例：
  - `MP` size 为 `N`，`SP_1` 和 `SP_2` size 为 `N/2`；
  - weak cooperation 中 `MP` 合并 `MP, OP, OP_1, OP_2` 后做 multiparty environmental selection；
  - `SP_i` 合并 `SP_i, OP_i, OP` 后按 `Obj_i` 做 NSGA-II selection；
  - strong cooperation 中先在 `MP ∪ SP_i` 上按 `Obj_i` 选 best `N/2`，用 `MP`/`SP_i` 的 success rate 动态确定互换父代数量；
  - 推荐系统使用用户-推荐列表矩阵编码，dual-search 按行执行。

## 如何用于算法创新

### 局部创新

- 将固定 `beta` 切换替换为迁移成功率、meanHV improvement、multi-party regret、archive survival 或 bandit 控制。
- 在 strong cooperation 中用 mating compatibility、conflict score 或 DM-specific novelty 选择转移父代。
- 将 elite-guided search 中的 common genes 替换为序列片段、图子结构、路径片段、组合块或业务规则模板。
- 为每个 `SP_i` 维护负迁移检测：若其转移个体长期不能在 `MP` 存活，则降低转移概率或只保留候选池。
- 在推荐任务中加入 provider constraints、fairness constraints 或 exposure caps，使 `SP_i` 同时承担可行性修复。

### 结构创新

- 构建多利益方平台优化框架：

```text
stakeholder objective groups
-> one MP for common nondominated solutions
-> one SP_i per stakeholder for party-specific Pareto learning
-> phase controller for offspring/parent sharing
-> discrete structure-aware search on MP
-> common solution set for negotiation or recommendation
```

- 与偏好学习结合：`SP_i` 目标或权重由 DM 在线反馈更新，`MP` 只处理当前共同折中。
- 与隐私保护结合：各 `SP_i` 由对应 DM 本地维护，只向 `MP` 传递脱敏 offspring/parent 或 latent representation。
- 与动态 MPMOP 结合：需求变化时先回到弱合作，重新探索单方变化后的共同区域；稳定后再进入强合作。

## 适用条件与风险

- 适用条件：
  - DM 划分清楚，每个 DM 有可独立优化的目标子集；
  - 单方 Pareto 搜索对共同解搜索有正迁移潜力；
  - 决策编码支持跨种群交叉和离散局部修复；
  - 评价预算足以维护 `MP + M` 个 `SP_i`；
  - 需要输出 solution set，而不是单个加权最优解。
- 不适用或可能失效的条件：
  - 各方目标极端冲突，单方优秀基因几乎不能共存；
  - DM 数量很多，`SP_i` 维护成本线性上升；
  - 单方种群过强导致 `MP` 后期同质化或偏向某个 DM；
  - `beta` 设置不当：过小会弱合作过久、局部开发不足，过大会过早强合作、探索不足；
  - 推荐/组合编码存在复杂约束但修复算子不足，会产生不可用候选。
- 计算与实现成本：
  - 主要额外成本来自多个 population 的 nondominated sorting；
  - 论文给出的 nondominated sorting 总复杂度为 `O((2F + M)N^2)`；
  - 需要维护不同 population 的来源标签、转移规模、重复基因修复和多方环境选择。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0248 | MP-HCEA 使用一个 `MP` 搜索多方共同 Pareto 解，多个 `SP_i` 分别搜索每个 DM 的 Pareto 解 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 5-6 |
| P2026-0248 | Weak cooperation 早期共享 offspring：`MP` 合并 `MP, OP, OP_1, OP_2` 后按 multiparty selection 更新，`SP_i` 合并 `SP_i, OP_i, OP` 后按单方 NSGA-II selection 更新 | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 6-7 |
| P2026-0248 | Strong cooperation 后期共享 parent，并根据 `MP` 与 `SP_i` 在第 `i` 方目标上的 success rate 动态确定互换个体数量 | 作者提出的方法 | Sec. III-B，Algorithm 3，PDF 7-8 |
| P2026-0248 | 弱强切换由 `SP` offspring 在 `MP` 中的 survival rate 与 `beta` 控制，并比较 `sucGen/gen` 与 `gen/maxGen` | 作者提出的方法 | Sec. III-B，PDF 8 |
| P2026-0248 | Dual-search 先用 Pareto optimal individuals 的 common genes 引导第二前沿个体；若 Pareto optimal 数量未增加，则执行 self-perturbation | 作者提出的方法 | Sec. III-C，Algorithm 4，PDF 8-9 |
| P2026-0248 | Multistakeholder recommendation 中，用户目标为 predicted rating 和 item coverage，提供方目标为 provider diversity 和 provider exposure | 应用建模 | Sec. IV-B，PDF 10 |
| P2026-0248 | MP-HCEA 在六个 Movielens/Netflix 数据集上相对 NSGA-II、MOEA/D、SMS-EMOA、OptMPNDS3、MOEA/D-MP、SMS-MPEMOA 的共同非支配解更优 | 综合实验支持 | Sec. V-B，Fig. 5，PDF 12-13 |
| P2026-0248 | Table VI 显示 MP-HCEA 在所有六个数据集上取得最佳 meanHV，并经 Wilcoxon rank sum test 与 baselines 比较 | 综合实验支持 | Sec. V-B，Table VI，PDF 13 |
| P2026-0248 | `beta=0` 或 `beta=1` 表现较差，`beta=0.2` 平均较好，说明弱合作和强合作都重要且早期探索应占更多代数 | 参数/机制证据 | Sec. V-C，Table VII，PDF 13-14 |
| P2026-0248 | 作者未来工作包括 constrained MPMOPs 和 dynamic MPMOPs | 作者局限与未来工作 | Sec. VI，PDF 14 |

## 证据边界

- 当前只有单篇论文证据。
- 主文表格多为图片占位，精确 meanHV、MPIGD 和 variant 数值需回看 PDF 或补充材料。
- 七个变体的详细消融结果主要在 supplementary material，主文只概述。
- Provider-item 关系在公开数据中缺失，实验按已有文献做随机 provider assignment，现实平台结构仍需验证。
- 实验集中在推荐系统矩阵编码，其他离散 MPMOP 如 knapsack、portfolio、scheduling、sensor placement 尚未主文验证。

## 待确认

- 更多 DM 或不均衡 DM 目标数下，`MP/SP_i` 的规模如何设置；
- `beta` 是否可由迁移成功率或性能增益自动学习；
- 如何防止 strong cooperation 后期让 `MP` 被某个 `SP_i` 主导；
- 复杂约束、动态偏好和隐私保护下如何改造 parent/offspring sharing；
- dual-search 在排列、集合、图和路径编码中应如何定义 common genes 与重复修复。
