---
knowledge_id: K-approximation-sparsity-multiobjective-broad-learning
name: 近似-稀疏双目标宽度学习训练
type: architecture
status: active
source_papers: [P2026-0025]
aliases: [MoBLS, multi-objective broad learning system, approximation-sparsity BLS, strongly convex sparse operator, generalized Pareto BLS, GWSO, global-winner swarm optimizer, half-threshold pruning, 宽度学习多目标训练, 强凸稀疏算子, 近似稀疏双目标]
promotion_reason: P2026-0025 单篇提出但训练接口完整，把 BLS 的 regularized objective 拆成 approximation 与 hidden-weight sparsity 两个目标，并给出强凸稀疏算子、sparse/non-sparse Pareto 维护、GWSO 群体更新和 half-threshold 剪枝；可迁移到宽度学习、浅层随机特征模型、轻量神经模型和模型压缩型多目标训练。
---

# 近似-稀疏双目标宽度学习训练

## 核心内容

对 BLS 或类似随机特征/宽度学习模型，不把误差项和正则项压成单一加权 loss，而是显式建立两个目标：模型输出对 label 的 approximation degree，以及 hidden layer weights / hidden neurons 的 sparsity。训练时用强凸稀疏算子生成 sparse hidden weights，同时保留 non-sparse 个体作为精度补偿；再用 Pareto 维护和群体竞争优化在“拟合好”和“结构稀疏”之间搜索折中。

```text
random hidden weights population
-> strongly convex sparse operator
-> sparse + non-sparse weights both evaluated
-> objectives: approximation degree, sparsity degree
-> generalized Pareto maintenance
-> global-winner swarm optimizer
-> half-threshold neuron pruning
-> sparse robust BLS model
```

## 建立理由

- 为什么值得独立维护：
  - BLS 的单目标正则化形式掩盖了 accuracy/compression tradeoff；
  - hidden weights 通常随机给定，缺少面向泛化和压缩的结构化搜索；
  - 对 neuron number 敏感的宽度模型，需要一种能在多个宽度配置下保持稳健的训练框架；
  - 该思路不依赖深层 NAS，可直接改造 BLS、随机特征网络、ELM、浅层 surrogate 和轻量分类器。
- 与已有设计知识的区别：
  - 不同于稀疏大规模 MOO 的变量选择：本知识稀疏的是模型 hidden weights/neurons，不是优化问题决策变量。
  - 不同于 NAS：本知识主要在固定 BLS 宽度候选和 hidden-weight population 上训练与剪枝，不搜索复杂网络拓扑。
  - 不同于普通 CSO/PSO 更新：本知识的竞争优化器服务于 approximation-sparsity 模型训练，并与 Pareto maintenance 和 sparse operator 绑定。
  - 不同于 Pareto 模型选解：本知识产生模型训练过程中的 Pareto 搜索，不只是从已训练模型集合中选一个折中模型。

## 解决的问题

- 适用场景：
  - BLS、ELM、random feature model 或其他 hidden layer 随机/弱训练的浅层模型；
  - 同时关心 generalization accuracy、模型稀疏性、inference time 或可部署性；
  - neuron 数量、hidden weights 或 regularization 系数对性能高度敏感；
  - 可以用 population 表示 hidden weights 或结构参数；
  - 输出层可用闭式解或低成本优化快速重算。
- 现有方法为什么会失败或不足：
  - 单一 regularization weight 需要人工调参，且只能给出一个偏好点；
  - 只优化 output layer weights 会忽略 hidden representation 的稀疏结构；
  - 随机 hidden weights 使不同 neuron 配置表现波动大；
  - 先训练再剪枝可能破坏原本的 approximation；
  - PSO 训练成本较高，CSO winner 静止又可能导致高质量个体停滞。
- 仍需解决的问题：
  - 如何为不同数据规模和噪声水平设置 sparsity schedule；
  - 如何在分类、回归、增量学习和数据流场景下稳定更新 Pareto population；
  - 如何选择最终模型，避免只看 accuracy 而忽略部署成本。

## 为什么可能有效

```text
BLS hidden weights shape representation capacity
-> random hidden weights cause neuron-count sensitivity
-> sparse operator removes weak hidden connections
-> non-sparse variants protect approximation ability
-> Pareto maintenance keeps both accuracy and sparsity candidates
-> GWSO uses global/winner information to refine hidden weights
-> half-threshold pruning turns weight sparsity into faster inference
```

关键假设是：hidden-weight sparsity 与泛化能力、推理成本之间存在可利用的正相关或折中关系。如果任务需要密集交互特征，或 sparse operator 过早剪掉关键连接，该框架可能损害精度。

## 实现接口

- 输入：
  - training samples `X` 和 labels `Y`；
  - BLS hidden structure parameters，如 mapped feature groups `N`、nodes per group `K`、enhanced nodes `M`；
  - population size `P`、iterations `T`；
  - sparse schedule `iota(t)`；
  - pruning threshold `theta`；
  - output layer solver。
- 输出：
  - sparse hidden layer weights `U_sparse/V_sparse`；
  - output layer weights `W`；
  - pruned mapped/enhanced feature nodes；
  - approximation-sparsity Pareto candidates；
  - final deployed BLS model。
- P2026-0025 的默认实例：
  - inputs normalized to `[-1,1]`，labels 用 one-hot encoding；
  - initial `U/V` elements sampled from `[-1,1]`；
  - activation functions 使用 logsig；
  - `lambda=1e-5`；
  - MoBLS 参数：`T=50`、`P=100`、`b1=0.5`、`b2=1.5`、`theta=0.1`；
  - `N,K in {8,16}`，`M in {40,80,160}` 用于鲁棒性测试。
- 最小实现：

```text
initialize population of hidden weights U,V
for t in 1..T:
    for each individual p:
        Usp,Vsp <- sparse_operator(U,V,iota(t))
        W_sparse <- solve_output_weights(X,Y,Usp,Vsp)
        W_dense  <- solve_output_weights(X,Y,U,V)
        evaluate approximation and sparsity for sparse/dense variants

    P <- generalized_pareto_maintenance(sparse_population, dense_population)
    P <- GWSO_update(P, approximation_scores)

for each individual:
    prune mapped nodes by count(|u_i| > theta) > floor(D/2)
    prune enhanced nodes by count(|v_j| > theta) > floor(NK/2)
    recompute output weights
select/deploy model according to accuracy-sparsity preference
```

## 如何用于算法创新

### 局部创新

- 将 `iota(t)` 从线性下降改为由 validation accuracy、population diversity 或 sparsity stagnation 自适应调整。
- 把 half-threshold pruning 改为按 validation contribution、Shapley score、Fisher sensitivity 或 group-lasso norm 剪枝。
- 在 Pareto maintenance 中加入第三目标，如 inference latency、calibration error、robustness 或 fairness。
- 用 crowding distance、epsilon dominance 或 hypervolume contribution 替换原文的简化 pairwise replacement。
- 将 GWSO 的 winner/global 更新概率按 approximation-sparsity region 自适应调节。

### 结构创新

- 构建三目标轻量模型训练：

```text
accuracy objective
+ sparsity objective
+ robustness/latency objective
-> Pareto population of deployable shallow models
```

- 把该框架用于 surrogate-assisted MOO：训练一组 accuracy-sparsity Pareto surrogate，再按优化阶段选择高精度或低延迟 surrogate。
- 在 incremental BLS 中维护历史 Pareto population，新数据到来时只局部更新 sparse hidden weights。
- 与模型选解层结合：用 Nash bargaining、knee point 或 deployment constraint 从 approximation-sparsity Pareto set 中选最终模型。

## 适用条件与风险

- 适用条件：
  - 输出层可快速重算，使 population training 成本可接受；
  - hidden weights 或 hidden neurons 有明显冗余；
  - 稀疏化后的模型仍能保留主要特征表示；
  - 任务允许用 validation/test accuracy 评价 approximation。
- 不适用或可能失效的条件：
  - 深层端到端模型中 hidden representation 强耦合，简单元素级 sparse operator 破坏训练；
  - 数据很少且噪声大，population 评价方差过高；
  - 任务需要密集特征交互，稀疏剪枝会显著降精度；
  - 推理成本不是瓶颈，population training 的额外成本不划算；
  - 只用训练误差做 approximation objective，可能过拟合。
- 计算与实现成本：
  - 每轮要对 `P` 个体计算 sparse/non-sparse 两类输出权重和目标；
  - population-based training 单次训练慢于 classic BLS；
  - sparse/pruned model 可显著降低 inference redundancy；
  - 需要保存多个候选模型或 Pareto candidates 以支持后续选解。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0025 | 作者将 BLS 的 cost function 解释为 approximation degree 与 weight sparsity 两个目标，并据此提出 MoBLS | 问题重构/作者提出 | Sec. 1.2、Sec. 2，PDF 2-3 |
| P2026-0025 | MoBLS 对 hidden layer weights `U/V` 使用 strongly convex sparse operator，得到 `U_sparse/V_sparse` 并分别评价 approximation 与 sparsity | 作者提出的方法 | Sec. 2、Eq. (12)-(16)，PDF 3 |
| P2026-0025 | Sparse 与 non-sparse populations 合并后，用 generalized Pareto structure maintenance 在 approximation 和 sparsity 间保留折中个体 | 作者提出的方法 | Sec. 2，PDF 3 |
| P2026-0025 | GWSO 成对比较个体，并结合 global 和 winner 信息更新 population | 作者提出的方法 | Sec. 2、Eq. (17)-(20)，PDF 3-4 |
| P2026-0025 | Half-threshold scheme 根据 hidden weights 超过 `theta` 的数量剪掉 mapped/enhanced feature neurons | 作者提出的方法 | Sec. 2、Algorithm 1，PDF 4 |
| P2026-0025 | 实验使用 9 个 UCI 类数据集、12 种 neuron 组合、60/40 训练测试划分和 10 次独立实验 | 实验设置 | Sec. 3、Table 1，PDF 4 |
| P2026-0025 | Sonar、Glass、Fertility 及 Appendix 数据集显示 MoBLS 对 neuron number 更稳健，通常取得最高或接近最高 test accuracy | 综合实验支持 | Sec. 3.2、Tables 2-4、Appendix Tables 6-11，PDF 4-8 |
| P2026-0025 | 作者的统计分析显示 MoBLS 的 lower bound、quartile 和 median 等指标显著优于 BLS/MRBLS/OBLS/GC-BLS，worst-case 也常接近或超过对比模型 best result | 统计/稳健性证据 | Sec. 3.3、Figs. 1-3、Appendix Figs. 4-9，PDF 5-6 |
| P2026-0025 | 时间对比显示 MoBLS 单次训练更慢，但 population-based models 可减少反复尝试 neuron 组合；稀疏结构使 inference time 短于 BLS variants | 效率证据 | Sec. 3.4、Table 5，PDF 6-7 |
| P2026-0025 | 作者未来计划将多目标优化机制扩展到 incremental broad learning system | 作者未来工作 | Conclusion，PDF 7 |

## 证据边界

- 当前直接证据来自 P2026-0025 一篇论文。
- 实验主要是 UCI 分类数据集，缺少回归、大规模图像、在线数据流和工业部署验证。
- `MoBLS_PSO/MoBLS_CSO` 主要隔离 optimizer 差异；强凸稀疏算子、Pareto 维护和 half-threshold pruning 的独立消融不足。
- 作者的 statistical significance 描述以 Levene test/boxplot 指标为主，未报告常见 Wilcoxon/Friedman 多算法检验表。
- 公式图片在当前 Markdown 中未完整抽取，复现时需核对 PDF 中 Eq. (13)-(20) 的精确形式。
- Population training 单次成本高于 classic BLS；收益依赖是否真的需要跨 neuron 组合稳健。

## 待确认

- 强凸稀疏算子的阈值 schedule 是否应按 validation performance 自适应；
- sparse/non-sparse Pareto maintenance 是否可替换为标准 NSGA-II/SPEA2 环境选择；
- half-threshold 的 `floor(D/2)` 和 `floor(NK/2)` 是否适合高维稀疏输入；
- 在 regression、incremental BLS、imbalanced classification 和 noisy labels 下是否仍稳定；
- 最终 deployed model 应按 accuracy、sparsity、latency 还是公平/鲁棒约束选择。

