---
knowledge_id: K-architecture-distance-niching-nas-diversity
name: 架构距离生态位的 NAS 多模态多样性选择
type: method
status: active
source_papers: [P2026-0253]
aliases: [M3NAS, AANS, ADD, architecture-aware niching selection, architectural diversity distance, XOR-distance, tau-distance, node distribution heatmap, structural entropy, architecture diversity NAS, 架构感知生态位选择, 架构多样性距离, 结构熵, 节点分布热图]
promotion_reason: 单篇论文提出但接口明确，包含架构编码距离、语义节点距离、生态位父代选择、用架构距离替代 crowding 的环境选择和无真 Pareto 集的结构多样性评估，可直接改造 NAS、模型池搜索和故障韧性模型集设计
---

# 架构距离生态位的 NAS 多模态多样性选择

## 核心内容

在多目标 NAS 中，不只在 accuracy-cost 目标空间维护 Pareto diversity，还要在架构/决策空间保留多个性能相近但结构不同的模型。这样，当主模型遇到随机故障、输入缺失、攻击或软错误时，可以切换到结构不同的备份模型，或用多架构 ensemble 降低单一结构失效风险。

最小机制：

```text
architecture path encoding
-> define cheap numeric distance, e.g. XOR-distance
-> define semantic operation distance, e.g. tau-distance
-> parent selection by architecture-aware niches
-> nondominated sorting by true objectives
-> critical-front truncation by architectural diversity distance
-> output Pareto set with objective and architecture diversity
```

P2026-0253 的实现包括 AANS 和 ADD：AANS 在随机架构邻域内选择高性能父代，避免全局最优结构垄断 mating；ADD 在同一 Pareto frontier 内按最近架构距离保留更孤立的候选，用架构空间多样性替代 NSGA-II 的 objective crowding。

## 建立理由

- 为什么值得独立维护：
  - 传统 NSGA-II/NAS 只保证目标空间分散，可能输出许多结构相似的模型；
  - 对安全关键或故障敏感任务，结构多样性本身就是鲁棒性资源；
  - 该机制提供明确插入点：父代选择和 critical front 环境截断；
  - 架构距离可按任务替换，适用于 CNN/RNN/Transformer/GNN/NAS cell 和程序结构搜索。
- 与已有设计知识的区别：
  - 不同于“复杂度分组的目标子空间排序”：该知识按资源预算分组；本知识在相似目标性能下按架构空间保留多模态结构。
  - 不同于“两阶段辅助目标的 BNN-NAS 小模型陷阱规避”：该知识处理早期小模型偏置；本知识处理最终模型集的结构同质化和故障韧性。
  - 不同于“结构保真的架构编码与修复”：该知识保证候选结构合法和 backbone 连通；本知识衡量并维护多个合法架构之间的差异。
  - 不同于“多保真不确定集成的 NAS 评价加速”：该知识处理训练成本和性能预测不确定性；本知识处理 architecture diversity。

## 解决的问题

- 适用场景：
  - NAS 输出不是单个模型，而是一组候选模型或部署模型池；
  - 多个架构在 accuracy/size/latency 上相近，但结构差异影响故障响应；
  - 目标空间 diversity 不足以代表决策空间 diversity；
  - 希望同一预算档位下有多个结构备选；
  - 可定义架构路径、操作类型或图结构距离。
- 现有方法为什么会失败或不足：
  - NSGA-II crowding distance 只看 objective values，无法区分结构相似或完全不同的架构；
  - 全局 tournament selection 会反复选择少量高性能架构，导致 offspring 结构收敛；
  - 单目标 NAS 或只看最优 RMSE/accuracy 的搜索不会保留等性能替代结构；
  - 无 ground-truth Pareto set 的 NAS 难用传统 IGD/PSP 指标评价决策空间多样性。

## 为什么可能有效

- 架构空间中不同路径可能有近似 objective values，即存在 multimodal Pareto solutions；
- 对同一目标前沿内的结构孤立候选赋予更高保留机会，可防止最终 Pareto set 被同一操作模式占满；
- 随机架构生态位内父代竞争，让不同局部结构区域都有机会产生 offspring；
- 语义距离比纯编码距离更能反映功能差异，例如 kernel size、trainable parameters、shortcut/dense/identity 的差别；
- 结构多样模型池可在故障或缺失输入下提供互补预测行为。

## 实现接口

- 输入：
  - 架构编码，例如 path vector、cell operation list、DAG adjacency/operation labels；
  - 目标值，例如 validation error、parameters、FLOPs、latency；
  - 架构距离函数 `d_code` 和 `d_semantic`；
  - population size、crowding factor 或 niche sample size；
  - 基础 MOEA，如 NSGA-II、MOEA/D、RVEA。
- 输出：
  - 目标空间非支配且架构空间多样的模型集；
  - 可选：node distribution heatmap、structural entropy、pairwise distance statistics；
  - 可选：模型池 ensemble 或故障切换候选。
- 插入位置：
  - parent selection；
  - environmental selection / critical front truncation；
  - final archive pruning；
  - model pool ensemble construction。

最小实现：

```text
initialize architecture population

for each generation:
    parents <- architecture_aware_niching_selection(P)
    offspring <- crossover_mutation(parents)
    evaluate objectives by supernet / training / surrogate

    U <- P union offspring
    fronts <- nondominated_sort(U)

    for each front:
        ADD[x] <- nearest_neighbor_distance(x, front, d_code, d_semantic)

    P <- keep complete fronts
    fill critical front by descending ADD
```

P2026-0253 的 ADD：

```text
for each individual p in a frontier:
    XOR_p <- distances from p to other individuals by XOR-distance
    tau_p <- distances from p to other individuals by tau-distance
    normalize both vectors
    ADD(p) <- 0.5 * (min(XOR_p) + min(tau_p))
```

## 如何用于算法创新

### 局部创新

- 将手工 `tau`-distance 表替换为 learned architecture embeddings 或 graph kernels。
- 在 AANS 中混合 nearest niche 和 farthest mating：同 niche 内选优，跨 niche 注入结构新颖性。
- 将 ADD 与 uncertainty、robustness、latency variance 或 fault sensitivity 联合。
- 对不同资源预算区间分别维护 architecture diversity，避免只有低预算模型多样。
- 用 structural entropy 反馈调节 mutation rate 或 operation sampling probability。

### 结构创新

- 构建 failure-resilient NAS：

```text
task-specific supernet
-> multiobjective search for accuracy and cost
-> architecture-distance niching
-> robustness-aware validation
-> diverse model pool / switcher / ensemble
```

- 在边缘部署中，让每个设备保留一个主模型和若干结构差异大的备用模型；
- 在安全场景中，将 attack transferability 或 fault correlation 作为架构距离的一部分；
- 在多任务 NAS 中，输出跨任务共享性能好但结构互补的模型族。

## 适用条件与风险

- 适用条件：
  - 架构可以离散编码；
  - 不同架构之间可定义有意义距离；
  - 最终需要模型池或多备选方案；
  - 架构多样性与故障韧性、攻击迁移性或 ensemble 互补性有关；
  - population size 足以覆盖多个 architecture niches。
- 不适用或可能失效的条件：
  - 架构距离与实际行为差异弱相关；
  - 任务只需要单个最优模型，保留多样结构浪费预算；
  - 距离表偏置导致保留功能弱但“看起来不同”的架构；
  - 过度强调架构多样性会牺牲目标收敛；
  - weight-sharing super-net 评价排序不可靠，导致 diverse but low-quality models 被保留。
- 计算与实现成本：
  - 每代需要计算 front 内 pairwise architecture distances；
  - 语义距离表或 embedding 需要维护；
  - 需要额外多样性诊断，如 NDH、SE 或 pairwise distance；
  - 模型池部署会增加存储和切换/集成逻辑。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0253 | 作者指出普通 one-shot NAS 搜索阶段使用 vanilla NSGA-II，只关注目标空间 diversity，忽略架构/决策空间 diversity | 问题动机 | Sec. II-C，PDF 3 |
| P2026-0253 | 将 TSF NAS 看作 MMOP，因为多个不同 architecture paths 可具有相近 RMSE 和参数量 | 问题建模 | Sec. II-B、Sec. V-D，PDF 2-3、12 |
| P2026-0253 | 定义 XOR-distance 和 `tau`-distance，分别衡量路径编码差异和操作语义差异 | 作者提出的方法 | Sec. III-D，Definitions 1-2，Fig. 5，PDF 6-7 |
| P2026-0253 | AANS 使用 crowding factor 采样架构邻域，并在局部候选池中选择父代 | 作者提出的方法 | Sec. III-D，Fig. 6，PDF 7 |
| P2026-0253 | ADD 在同一 frontier 内按最近架构距离计算结构孤立度，并在最后 front 截断时替代 crowding distance | 作者提出的方法 | Sec. III-D，Algorithm 2，PDF 7-8 |
| P2026-0253 | NDH 和 SE 用于在没有 true Pareto set 的 NAS 中评估 architecture diversity | 作者提出的方法 | Sec. III-E，PDF 8 |
| P2026-0253 | Bike `Ly=96` 消融中，M3NAS-TSF 的 SE 为 0.72，高于 NSGA-II-TSF 的 0.55、GARMSE-TSF 的 0.38、GAparams-TSF 的 0.32 | 多样性实验支持 | Sec. V-D，Fig. 10，PDF 12 |
| P2026-0253 | 局部 Pareto 区域中，不同 path 可获得近似 RMSE 和参数量，支持多模态架构解存在 | 多模态证据 | Sec. V-D，Table VI，PDF 12 |
| P2026-0253 | 10% model weights random zeroing 和 10% input missingness 下，M3NAS-TSF_pool 获得最低 RMSE | 故障韧性证据 | Sec. V-E，Tables VII-VIII，PDF 13-14 |
| P2026-0253 | 作者承认 MoTS-Net 单路径搜索忽略低层/高层特征组合，ETTh2 的 super-net derived performance 相关性只略有提升 | 证据边界 | Sec. V-C、Conclusion，PDF 11、14 |

## 证据边界

- 当前证据来自单篇 TSF NAS 论文。
- AANS 具体实现是选取与随机个体最近的 architecture neighbors 形成 niche，并非简单选择最远父代；其多样性收益来自随机 niche 覆盖和局部竞争，需要进一步消融。
- `tau`-distance 依赖手工 reference table，跨搜索空间迁移需重新定义。
- SE/NDH 只统计节点频率，不能完全代表路径级功能多样性或故障相关性。
- M3NAS-TSF_pool 主要在严重故障/缺失下更好，正常或低故障率下可能被单个最优模型超越。
- super-net 排序相关性在 ETTh2 上弱，说明 weight sharing 噪声可能影响 AANS/ADD 的真实收益。

## 待确认

- learned architecture distance 是否优于 XOR/手工 `tau`；
- AANS 的 crowding factor 是否应随 SE、HV 或 population convergence 自适应；
- 架构距离与真实故障相关性、攻击迁移性和 ensemble 互补性的定量关系；
- 在 CNN/Transformer/GNN 等其他 NAS 空间中，ADD 替代 crowding 是否同样有效；
- 如何在不显著牺牲 accuracy-cost Pareto 收敛的前提下提升 architecture diversity。
