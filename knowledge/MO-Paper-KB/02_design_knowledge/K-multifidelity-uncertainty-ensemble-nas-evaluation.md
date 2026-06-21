---
knowledge_id: K-multifidelity-uncertainty-ensemble-nas-evaluation
name: 多保真不确定集成的 NAS 评价加速
type: method
status: active
source_papers: [P2026-0236]
aliases: [CFMOGP-NAS, CPTES, RSRTA, comprehensive-forecast NAS, uncertainty-aware regression ensemble, combined partial and total evaluation strategy, 多保真NAS评价, 部分完整训练混合评价, 不确定性回归集成, 正则化锦标赛]
promotion_reason: 单篇论文提出但接口明确，包含 partial/full training 混合评价、被淘汰潜力个体 archive 与追加重评、不确定性加权回归集成预测、以及 RSRTA 多样性选择，可直接迁移到 NAS、程序结构搜索和昂贵结构候选优化的评价加速层
---

# 多保真不确定集成的 NAS 评价加速

## 核心内容

在昂贵的神经架构搜索中，不把每个候选都完整训练，也不完全依赖一次短训或单一性能预测器。候选先通过 partial/较短训练进行低成本评价；被 NSGA-II 等环境选择淘汰但仍可能有潜力的个体进入 archive，在后续用更多 epochs 或更新后的训练状态重新评价。与此同时，用多个回归模型综合预测架构性能，并根据预测置信区间/标准误调整模型或样本权重，降低高不确定预测对选择的影响。为了避免种群只围绕当前高精度架构收敛，选择阶段再混合普通 tournament 和 aging-based tournament，保持架构多样性。

```text
architecture population
-> partial / low-cost evaluation
-> NSGA-II selection
-> potentially good eliminated candidates enter archive
-> more epochs / re-evaluation corrects early estimates
-> uncertainty-aware regression ensemble predicts performance
-> regularized tournament + aging preserves diversity
-> Pareto architectures under accuracy, Params, FLOPs
```

## 建立理由

- 为什么值得独立维护：
  - NAS、程序结构搜索、自动算法设计都面临同一个问题：完整评价昂贵，短评估噪声大，单 predictor 易偏；
  - 该知识把“多保真评价”“不确定性预测”和“多样性选择”拆成可替换模块，接口比完整 CFMOGP-NAS 更通用。
- 单篇具体方法的直接复用价值：
  - P2026-0236 给出 CPTES Algorithm 2、uncertainty-aware regression ensemble、RSRTA Algorithm 1，以及 CIFAR-10/100、STL-10、Oxford 102 Flowers 实验证据；
  - 这些模块可嵌入 NSGA-Net、regularized evolution、GP-based NAS、MOEA/D-NAS 或其他结构候选搜索。
- 与已有设计知识的区别：
  - 不同于“可训练性约束的在线分类器辅助 NAS”：该知识用 trainability proxy 和分类器做候选准入门控；本知识重点是多保真训练评价、重评 archive 和不确定性回归集成。
  - 不同于“变量长度与时间扩展的脉冲架构搜索”：该知识定义 SNN 专用编码和目标；本知识不限定网络类型，作用在昂贵评价与选择控制。
  - 不同于“结构保真的架构编码与修复”：该知识保护 backbone path 和拓扑合法性；本知识不做结构修复，而是管理如何评价和保留候选。
  - 不同于普通 surrogate-assisted NAS：本知识显式给短训被淘汰候选留出追加训练通道，并使用不确定性调节预测影响。

## 解决的问题

- 适用场景：
  - 候选解是神经架构、程序树、调度规则或算法配置，单次真实评价昂贵；
  - 低保真评价与高保真评价存在一定正相关，但排序不完全可靠；
  - 可训练一个或多个 performance predictors；
  - 搜索容易因当前高精度候选聚集而损失结构多样性。
- 现有方法为什么会失败或不足：
  - 全部完整训练会耗尽 GPU/仿真预算；
  - 全部 partial training 会让慢热但最终高质量的候选被过早淘汰；
  - 单一 regression predictor 在小样本和训练噪声下可能过拟合；
  - tournament selection 会放大短期最优个体，减少架构多样性；
  - aging evolution 单独使用又可能过度偏向年轻个体，牺牲已验证优质结构。
- 仍需解决的问题：
  - archive 容量和重评频率如何自适应；
  - 不同保真度之间的相关性何时足够可靠；
  - predictor uncertainty 如何校准；
  - 多样性选择与收敛速度之间如何平衡。

## 为什么可能有效

```text
short training is cheap but noisy
-> use it for initial filtering
-> keep suspicious/potential eliminated candidates in archive
-> later re-evaluate with more epochs to correct false negatives
-> ensemble predictors reduce single-model bias
-> uncertainty weighting prevents over-trusting noisy predictions
-> aging/tournament mixture avoids high-accuracy monoculture
```

核心假设是：低保真训练能提供有用但不完全可靠的排序信号，而追加训练和不确定性预测可以修复部分误删风险。如果低/高保真相关性很弱，CPTES archive 可能仍然漏掉关键候选；如果 predictor uncertainty 未校准，集成模型也可能给出一致但错误的推荐。

## 如何用于算法创新

### 局部创新

- 在现有 NAS 算法中加入 CPTES：把被淘汰但高不确定、高 diversity 或接近 Pareto 边界的候选放入重评 archive。
- 把 RF/KNN/LR/SVM 集成替换为 GNN predictor、Bayesian neural network、rank predictor、learning-curve extrapolator 或 conformal ensemble。
- 用 predictor uncertainty 决定候选训练 epochs：不确定但潜力高的候选追加训练，低不确定且劣质的候选直接淘汰。
- 将 RSRTA 嵌入 NSGA-Net 或 regularized evolution，动态调节普通 tournament 与 aging selection 比例。
- 把目标扩展为真实 latency、energy、memory 和 robustness，并让多保真评价覆盖 proxy latency 与实测 latency。

### 结构创新

- 构建昂贵结构搜索的评价控制器：

```text
low-fidelity evaluator
-> candidate risk/potential classifier
-> re-evaluation archive
-> uncertainty-calibrated predictor ensemble
-> diversity-aware parent selection
-> high-fidelity validation
```

- 在自动算法设计中，把“短 benchmark run”作为 partial evaluation，把长 run/多实例 run 作为 total evaluation，用 CPTES 管理候选算法。
- 与可训练性门控结合：先用 trainability/stability proxy 去除明显坏候选，再用多保真 archive 保护可能慢热的候选。

## 适用条件与风险

- 适用条件：
  - 低保真评价成本远低于高保真评价；
  - 低/高保真评价具有正相关或至少能排除明显差候选；
  - 可保存候选参数和训练状态，以便后续追加 epochs 或重评；
  - 搜索空间足够大，多样性维护有实际价值；
  - predictor 的训练样本覆盖主要架构类型。
- 不适用或可能失效的条件：
  - 短训 ranking 与长训 ranking 经常反转；
  - 候选训练不可断点续训，重评 archive 需要完全重训，成本过高；
  - 训练噪声主导性能差异，confidence interval 无法校准；
  - 搜索空间很小或真实评价便宜，复杂评价控制得不偿失；
  - aging 机制过强，导致已验证优质个体被过快淘汰。
- 计算与实现成本：
  - 需要维护 archive、训练 epoch 计划和候选训练状态；
  - 需要训练多个 regression models 或一个 ensemble predictor；
  - 需要估计预测不确定性并调节权重；
  - RSRTA 需要维护 individual age counter 和 alternative set。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0236 | CFMOGP-NAS 用 MOGP 搜索 CNN 架构，目标包含 accuracy、Params 和 FLOPs | 作者提出的方法 | Sec. III-A，Fig. 2，PDF 4 |
| P2026-0236 | RSRTA 在普通 tournament selection 与 aging-based tournament 间随机切换，并维护 alternative set 和 age counter | 作者提出的方法 | Sec. III-C，Algorithm 1，PDF 6-7 |
| P2026-0236 | CPTES 先用 NSGA-II 筛选 parent+offspring，再把潜在优秀淘汰个体放入 archive 并随 epoch 更新重评 | 作者提出的方法 | Sec. III-D，Algorithm 2，PDF 7-8 |
| P2026-0236 | Regression agent 使用 RF、KNN、LR、SVM 等 stacked generalization，并用置信区间/标准误进行不确定性权重调整 | 作者提出的方法 | Sec. III-D，Fig. 6，PDF 8 |
| P2026-0236 | CIFAR-10/CIFAR-100 case study 分别达到 97.55% 和 79.62% accuracy，平均 search time 为 0.43 GPU days，参数量约 2.2M | 综合实验支持 | Sec. IV-B，Table III，PDF 8-9 |
| P2026-0236 | 摘要报告 CFMOGP-NAS 可减少约 50% search time 而不牺牲 accuracy | 摘要证据 | Abstract，PDF 1 |
| P2026-0236 | CIFAR-100 上 0.43 GPU days 达到 79.62%，作者对比 AmoebaNet 3150 GPU days/81.07% 与 LargeEvo 2750 GPU days/77.00% | 对比实验支持 | Sec. IV-B，PDF 9 |
| P2026-0236 | 完整 agent model 相比传统 regression 变体更好；regression 变体 retraining 后 CIFAR-10 为 90.96%、CIFAR-100 为 74.55% | 消融/对比支持 | Sec. IV-D，Fig. 14-15，PDF 12 |
| P2026-0236 | RSRTA 相对单独 tournament 或 aging evolution 有优势，且 `delta=0.3` 时平均 accuracy 最好 | 组件证据 | Sec. IV-D，Fig. 16，Table VI，PDF 12-13 |
| P2026-0236 | NRSRTA 消融显示完整方法在 accuracy、recall、F1-score 等综合指标上更有竞争力，尽管 CIFAR-100 accuracy 略低 | 消融证据 | Sec. IV-D，Table VIII，PDF 13 |
| P2026-0236 | CPTES 相比纯完整/纯部分训练，在 accuracy 与 time 之间取得较优平均表现 | 组件证据 | Sec. IV-D，Fig. 17，PDF 13 |
| P2026-0236 | 作者指出数据分布变化下需要及时更新 evolutionary updates 和模型维护，复杂 skip connections 管理仍值得研究 | 作者局限与未来工作 | Sec. V，PDF 14 |

## 待确认

- 当前 Markdown 中多张表为图片占位，`delta`、epoch、NRSRTA 和 CPTES 的精确数值需要回看 PDF 图表或源码。
- CES/PES/CPTES 的文字描述与常规命名略不一致，复现前需确认作者对 full/partial epoch 的具体定义。
- Regression ensemble 的不确定性是否经过校准，还是仅为启发式置信区间。
- CPTES archive 的容量、保留代数和重评资源比例如何设置，以及是否对搜索成本敏感。
- 与 weight sharing、one-shot NAS、learning-curve extrapolation 结合后是否仍有独立收益。
