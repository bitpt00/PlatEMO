---
knowledge_id: K-complexity-uniform-bipopulation-nas
name: 复杂度均匀采样的双种群 NAS 搜索
type: method
status: active
source_papers: [P2026-0289]
aliases: [MOEA-BUS, bipopulation NAS, uniform sampling NAS, MAdds-uniform initialization, pairwise surrogate ENAS, complexity-stratified initialization, extreme-medium population search, 复杂度均匀初始化, 双种群 NAS, MAdds 分桶采样]
promotion_reason: 单篇论文提出但机制完整，包含按复杂度轴均匀初始化、极端/中等复杂度双种群分工、不对称精英迁移、pairwise surrogate ranking 和权重继承真实评价，可直接改造性能-资源型 NAS、模型压缩和硬件感知多目标结构搜索。
---

# 复杂度均匀采样的双种群 NAS 搜索

## 核心内容

在多目标 NAS 中，架构编码空间并不会天然均匀覆盖资源/复杂度目标。随机采样往往集中在中等 MAdds，导致初始种群、代理训练集和后续演化都缺少低/高复杂度极端候选。复杂度均匀采样先大量随机生成候选并计算 MAdds，再按复杂度分桶均匀选取初始个体；随后把低/高复杂度候选放入一个“极端探索种群”，把中等复杂度候选放入另一个“主密度种群”，两个种群并行搜索并采用不对称精英迁移，既保留极端区域探索，也利用中等区域的大量可行表示。

```text

randomly sample many architectures
-> compute cheap complexity metric, e.g., MAdds
-> sort and select uniformly across complexity bins
-> Pop1 = low/high complexity extreme architectures
-> Pop2 = medium complexity architectures
-> train pairwise surrogate from true-evaluated archive
-> run surrogate-assisted subsearch in each population
-> true-evaluate selected elites with weight inheritance
-> Pop1 elites migrate to Pop1 and Pop2; Pop2 elites stay in Pop2
```

P2026-0289 的 MOEA-BUS 是该模式的实例：搜索 MobileNetV3-style space，目标为 validation error 和 MAdds，surrogate 为 SVM pairwise comparator，真实评价使用 Once-for-All weight inheritance。

## 建立理由

- 为什么值得独立维护：
  - NAS 搜索空间的资源轴分布常高度不均，随机初始化会系统性漏掉极小/极大模型；
  - 复杂度均匀初始化同时改善初始 Pareto coverage 和代理训练数据覆盖；
  - 双种群将“极端预算探索”和“中等预算开发”分开，避免中等模型因数量优势淹没极端模型；
  - 不对称迁移规则比普通 elite exchange 更能保持种群角色差异。
- 单篇具体方法的直接复用价值：
  - P2026-0289 给出 MOEA-BUS、Algorithm 1/2、uniform sampling、bipopulation、SVM pairwise surrogate、OFA weight inheritance、CIFAR/ImageNet 实验和消融。
- 与已有设计知识的区别：
  - 不同于“复杂度分组的目标子空间排序”：该知识按复杂度区间做环境选择/归档；本知识处理初始采样、双种群角色分工和不对称精英迁移，可与其组合。
  - 不同于“架构距离生态位的 NAS 多模态多样性选择”：该知识用架构距离维护结构多样性；本知识用复杂度轴和种群角色维护资源预算覆盖。
  - 不同于“两阶段辅助目标的 BNN-NAS 小模型陷阱规避”：该知识解决小模型早期低保真评价偏置；本知识解决搜索空间复杂度分布不均和极端区域缺样本。

## 解决的问题

- 适用场景：
  - 目标包含 accuracy/error 与 MAdds、Params、latency、energy、memory 等资源指标；
  - 随机编码采样在资源轴上高度偏斜；
  - 高/低资源区域候选数量少但部署上有价值；
  - 真实训练评价昂贵，需要 surrogate 和少量真实评价；
  - 最终希望输出多个预算档位下的架构。
- 现有方法为什么会失败或不足：
  - 随机初始化让代理训练集缺少极端复杂度样本，排序模型容易外推；
  - 全局 NSGA-II 会被中等复杂度密集区域牵引，低/高预算区域父代不足；
  - 普通双向 elite migration 会让高性能中等复杂度架构侵入极端种群；
  - 只靠 crowding distance 不保证资源轴空洞被填补；
  - 只用分组 archive 可能已太晚，初始和早期演化已丢掉极端候选。
- 仍需解决的问题：
  - 分桶边界和 Pop1/Pop2 比例需要与搜索空间分布匹配；
  - MAdds 不一定代表真实硬件 latency；
  - 三目标及多设备资源轴下如何扩展双种群角色仍需设计。

## 为什么可能有效

```text

cheap complexity can be computed before true accuracy evaluation
-> use it to actively cover scarce budget regions
uniform initial archive gives the surrogate comparisons across budgets
role-separated populations prevent medium models from dominating all search
asymmetric elite migration lets extreme discoveries inform medium search
but blocks medium elites from erasing extreme exploration
```

核心假设是：资源/复杂度轴上的稀有区域仍包含潜在有价值的 Pareto 解，且便宜复杂度指标足以指导初始覆盖。如果极端区域天然没有可用高性能模型，或真实部署指标和分桶指标严重不一致，这个机制会浪费真实评价预算。

## 实现接口

- 输入：
  - 架构编码生成器；
  - 便宜复杂度计算器，例如 MAdds/Params/latency proxy；
  - 真实评价器或 weight inheritance evaluator；
  - pairwise 或 regression surrogate；
  - Pop1/Pop2 大小和分桶策略。
- 输出：
  - 覆盖多个复杂度档位的 archive；
  - 极端/中等复杂度两个子种群；
  - 最终 accuracy-complexity Pareto architecture set。
- 插入位置：
  - NAS population initialization；
  - surrogate-assisted evolutionary NAS inner loop；
  - model compression 或 hardware-aware architecture search；
  - 多预算模型库构建。
- 最小实现：

```text

C <- sample_architectures(K_large)
for a in C:
    c[a] <- compute_complexity(a)

bins <- split_range_by_complexity(C)
selected <- take_quota_from_each_bin(bins)
Pop1 <- selected from low/high bins
Pop2 <- selected from medium bins
A <- true_evaluate(Pop1 union Pop2)

for iter in 1..T:
    predictor <- train_pairwise_surrogate(A)
    E1 <- surrogate_subsearch(Pop1, predictor, A)
    E2 <- surrogate_subsearch(Pop2, predictor, A)
    true_evaluate(E1 union E2)
    A <- A union E1 union E2
    Pop1 <- update(Pop1, E1)
    Pop2 <- update(Pop2, E1 union E2)
```

## 如何用于算法创新

### 局部创新

- 将固定 MAdds 分桶改为按候选密度和目标空洞自适应分桶。
- 用真实硬件 latency/energy lookup 替代 MAdds，或用多设备 latency 向量分桶。
- Pop1 不只覆盖低/高复杂度，也可覆盖其他稀有区域，例如高 memory、低 latency、高 accuracy uncertainty。
- 迁移规则从固定 Pop1 -> Pop2 改为 novelty-gated migration，只有能补空洞的 elite 才迁移。
- pairwise SVM 可替换为 GNN comparator、contrastive architecture embedding 或 uncertainty-aware ranker。
- 子搜索中的 diversity selection 可同时考虑 archive distance、complexity bin rarity 和 surrogate uncertainty。

### 结构创新

- 与复杂度分组 archive 组合：

```text

complexity-uniform initialization
-> role-separated bipopulation evolution
-> complexity-grouped archive selection
-> multi-budget final model set
```

- 与架构距离生态位组合：每个复杂度 bin 内再保留结构多样候选，避免同预算结构同质化。
- 与多保真 NAS 结合：低保真/代理评价覆盖所有 bins，高保真真实训练按 bin budget 分配。
- 与动态部署约束结合：当目标设备变化时，重新定义复杂度 bins，并复用已有 archive 做 warm start。

## 适用条件与风险

- 适用条件：
  - 复杂度目标能便宜计算；
  - 编码空间在复杂度轴上存在明显采样偏置；
  - 低/中/高复杂度候选都有潜在部署意义；
  - population 和真实评价预算足以维护两个子种群；
  - surrogate 可利用跨复杂度样本学习相对性能排序。
- 不适用或可能失效的条件：
  - 搜索空间已天然均匀覆盖资源轴；
  - 极端复杂度区域没有应用价值；
  - 复杂度 proxy 与真实硬件指标相关性低；
  - Pop1 规模过小导致极端区域仍无足够演化材料；
  - Pop2 禁止向 Pop1 迁移可能错过“中等模型变异到极端模型”的路径；
  - weight-sharing supernet 排序噪声大，导致 surrogate 学到错误比较关系。
- 计算与实现成本：
  - 需要先大量随机采样并计算复杂度；
  - 维护两个子种群、整体 archive 和 pairwise surrogate；
  - pairwise training 样本数量随 archive 近似二次增长，需要采样或压缩；
  - 不对称迁移和分桶参数增加调参成本。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0289 | 作者随机采样 5000 个架构后发现多数集中在 300-400 M MAdds，高/低复杂度架构稀少 | 问题诊断 | Sec. III-C，Fig. 3，PDF 5 |
| P2026-0289 | Uniform sampling 先大量随机采样并计算 MAdds，再按复杂度范围分区，每区选取架构形成更均匀初始种群 | 作者提出的方法 | Sec. III-C，Fig. 4，PDF 5 |
| P2026-0289 | Pop1 包含 large/small architectures，Pop2 包含 medium-sized architectures；二者分别执行搜索 | 作者提出的方法 | Sec. III-A-D，Algorithm 1，PDF 4-6 |
| P2026-0289 | 每轮用 archive 训练 surrogate，两个 population 用 surrogate 辅助 subsearch，然后 elite 做真实评价并更新 archive | 作者提出的方法 | Sec. III-D，Algorithm 1-2，PDF 6-7 |
| P2026-0289 | Surrogate 用 SVM pairwise comparison relation：两两拼接架构编码、预测相对优劣、累积分数作为强度 | 作者采用/组合方法 | Sec. III-E，Fig. 5，PDF 7 |
| P2026-0289 | 真实评价用 Once-for-All supernet 权重继承，候选网络继承后训练，supernet 权重冻结 | 作者采用/组合方法 | Sec. III-E，PDF 7 |
| P2026-0289 | CIFAR-10 上最高平均 accuracy 为 `98.39% ± 0.03`，MOEA-BUS-S 以 281 M MAdds 达到 98.12% | 综合实验支持 | Sec. IV-B，Table II，PDF 8 |
| P2026-0289 | ImageNet 上最佳架构 top-1 80.03%、top-5 94.42%、610 M MAdds；另有架构以 446 M MAdds 达到 78.28% | 综合实验支持 | Abstract、Sec. IV-B，Table III，PDF 1、8-9 |
| P2026-0289 | 消融中 NSGA-II random initialization 集中在 200-400 M；完整 MOEA-BUS 分布更均匀且 HV 持续提高 | 消融实验支持 | Sec. IV-C，Figs. 6-7，PDF 10 |
| P2026-0289 | SVM + Pairwise + Uniform 的 Ktau 为 0.7721，比 0.7052 提升 0.0669，且比 AdaBoost/RF/MLP 至少高 0.035 | Surrogate 消融支持 | Sec. IV-D，Table IV，PDF 10-11 |
| P2026-0289 | Random sampling 初始架构无大于 450 M 的候选；uniform sampling 在 entropy/HV 上优于 random、stratified、LHS | Uniform sampling 消融支持 | Sec. IV-E，Fig. 8、Table V，PDF 11-12 |
| P2026-0289 | 双向 elite exchange 会减少低于 250 M 和高于 450 M 的候选；完整规则 entropy/HV 为 6.32/0.62，双向为 6.07/0.60 | Bipopulation 消融支持 | Sec. IV-F，Fig. 9，PDF 12 |
| P2026-0289 | Pop1/Pop2 比例 `(25,75)` 在性能和计算成本之间最平衡，`(45,135)` 略好但成本更高 | 参数消融支持 | Sec. IV-F，Table VI，PDF 12-13 |
| P2026-0289 | 作者承认当前只验证 MobileNetV3，未来扩展到 ResNet、EfficientNet、ViT、segmentation 和 detection | 作者局限与未来工作 | Sec. V，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- 表格为图片占位，具体对比数值需回查 PDF。
- 搜索空间是 MobileNetV3-style，机制在 Transformer/GNN/检测/分割搜索空间中的效果未验证。
- Search cost 排除了 supernet training cost。
- MAdds 是复杂度 proxy，不等同于真实设备 latency、memory 或能耗。
- Pairwise surrogate、OFA weight inheritance、uniform sampling 和 bipopulation 同时作用，综合性能不能完全归因于任一单独组件。

## 待确认

- 复杂度分桶边界是否应根据候选密度、部署预算或 reference points 自适应；
- Pop1/Pop2 的角色和迁移方向是否适合多资源目标；
- Pop2 禁止回迁 Pop1 是否会在某些搜索空间中过度隔离；
- Pairwise surrogate 的二次样本规模如何在大 archive 下压缩；
- MAdds 均匀是否能带来真实硬件 latency 均匀；
- 与复杂度分组环境选择和架构距离生态位组合时，收益是否叠加。
