---
knowledge_id: K-shared-hamming-mokrr-subproblem-infill
name: 共享汉明核 MOKRR 子问题协同
type: architecture
status: active
source_papers: [P2026-0250]
aliases: [MOKRR-SCo, MOKRR, MSCO, DDISC, weighted Hamming kernel, multi-output KRR, expensive binary MOO, subproblem co-optimization, diversity-driven infill, 多目标核岭回归, 加权汉明核, 二进制昂贵多目标优化, 子问题协同优化, 稀疏填充采样]
promotion_reason: 单篇论文提出但接口完整，包含共享加权 Hamming kernel 的多输出 KRR、全局 archive 子问题协同、变量重要性引导二进制变异和 Hamming 稀疏 infill，可直接改造昂贵二进制/组合多目标优化的 surrogate management 与真实评价选点层
---

# 共享汉明核 MOKRR 子问题协同

## 核心内容

面向昂贵二进制多目标优化，不为每个目标独立训练代理，也不只用代理贪婪筛一个候选。先用所有已评价样本训练一个共享加权 Hamming kernel 的多输出 kernel ridge regression (MOKRR)，让多个目标共用二进制相似性结构并利用目标间相关。再在 MOEA/D 式权重子问题上，从全局 archive 中选择父代，用代理预测目标值做多步子问题协同优化 (MSCO)。最后用 Hamming 稀疏度从代理优化后的候选集中选择尚未评价且远离已评价 archive 的候选做真实评价 (DDISC)，降低代理误差导致的早熟。

```text
true-evaluated archive Arc
-> estimate variable importance from sample-pair bit differences and objective differences
-> train multi-output KRR with shared weighted Hamming kernel
-> for each weight-vector subproblem:
       select parents from global Arc by scalarizing value
       run surrogate-driven binary evolution
       use variable-importance-biased bit mutation
       update temporary ideal point by predicted objectives
       obtain promising population P_k
       select sparse unevaluated candidate by Hamming distance to Arc
       true evaluate and update Arc
-> output nondominated archive solutions
```

## 建立理由

- 为什么值得独立维护：
  - 昂贵二进制 MOO 同时需要结构化二进制代理、有限预算下的代理内搜索，以及避免代理误差的真实评价选点。
  - 该知识把这三层拆成清晰接口：multi-output binary kernel surrogate、subproblem co-optimization、diversity-driven infill。
- 单篇具体方法的直接复用价值：
  - P2026-0250 给出 MOKRR-SCo Algorithm 1-3、weighted Hamming kernel、变量重要性估计、MSCO、DDISC、参数敏感性、消融、60 个 MOKP/MNK benchmark 和 10 个 MOFS 数据集证据。
- 与已有设计知识的区别：
  - 不同于“网格排序成对关系代理筛选”：该知识学习解对相对优劣关系；本知识仍回归多目标值，但用共享二进制 kernel 和多输出 KRR。
  - 不同于“目标级自适应代理与双空间 infill 采样”：该知识为每个目标选择 GP/RBF 并用连续/实值距离做双空间 infill；本知识面向二进制空间，强调共享 Hamming kernel、子问题代理内优化和 Hamming 稀疏选点。
  - 不同于“滤波性能预测的特征子集预筛选”：该知识利用特征选择 filter 指标做 wrapper 评价前预筛；本知识是通用 EMBOP 代理建模和分解搜索框架，不依赖特征-标签相关矩阵。
  - 不同于“代理训练的注意力残差子代生成器”：该知识训练神经生成器替代连续 reproduction；本知识用 KRR surrogate 指导二进制交叉/变异和真实评价 infill。

## 解决的问题

- 适用场景：
  - 解为二进制向量或可映射为 binary/subset mask；
  - 单次真实评价昂贵，代理训练和代理查询相对便宜；
  - 多个目标之间存在可利用相关性；
  - 二进制变量对目标空间影响不均，需要变量重要性加权；
  - 希望在分解框架下给每个子问题选择少量真实评价候选。
- 现有方法为什么会失败或不足：
  - 逐目标 RF/RBF/KRR 忽略目标相关，有限样本下样本效率低；
  - 普通 Hamming kernel 默认每个 bit 等重要，难处理关键变量稀疏或 epistasis；
  - 单轮 pre-screening 只从静态候选池中选点，无法充分利用代理；
  - 代理内贪婪 local search 容易被错误预测拉进局部区域；
  - 只按预测 scalarizing value infill 会持续评价相似候选。
- 仍需解决的问题：
  - 如何在线判断多输出 MOKRR 是否真的比 RF/RBF/逐目标 KRR 更适合当前阶段；
  - 如何在 early stage 小样本下稳定估计变量重要性；
  - 如何让稀疏 infill 同时保留足够收敛压力；
  - 如何扩展到 large-scale binary、混合离散、带约束和多目标数更高的问题。

## 为什么可能有效

```text
多目标昂贵二进制问题样本少
-> 多输出 KRR 共享 kernel, 多目标共同利用样本
-> weighted Hamming kernel 强调对目标变化更关键的 bit

子问题间信息可共享
-> 每个 subproblem 从全局 Arc 选父代
-> 其他 subproblem 发现的优质解可参与当前方向搜索
-> predicted ideal point 动态更新, 降低分解偏置

代理预测不可避免有误差
-> 不只选预测最优候选
-> DDISC 优先真实评价 Hamming 稀疏区域
-> 提升探索并减少重复验证相似解
```

关键假设是：共享 kernel 能捕捉目标间有用相关，变量重要性估计能近似 bit 对目标空间变化的贡献，且 Hamming 稀疏区域代表有信息量的未探索二进制结构。若目标间弱相关、编码存在大量等价表示，或高阶变量交互主导目标变化，MOKRR 和稀疏 infill 的优势可能减弱。

## 实现接口

- 输入：
  - 已真实评价 archive `Arc={(x,F(x))}`，其中 `x in {0,1}^D`；
  - weight vectors、ideal point、scalarizing function；
  - MOKRR regularization `mu`；
  - subproblem population size、mutation rate、代理内迭代数 `t_max`；
  - 每轮真实评价预算。
- 输出：
  - 多输出目标预测器 `F_hat(x)`；
  - 每个变量的 importance weight；
  - 每个权重子问题的 promising population；
  - 被真实评价的 sparse candidates；
  - 更新后的 archive 和非支配解集。
- 插入位置：
  - MOEA/D 或 reference-vector EMBOP 的 surrogate management 层；
  - 二进制特征选择、关键节点选择、模式挖掘、传感器选择等 subset MOO 的评价前优化层；
  - surrogate-assisted combinatorial optimization 的 infill/restart 模块。
- 最小流程：

```text
initialize Arc by N_max true evaluations
generate N_lambda weight vectors

while FEs < MaxFEs:
    theta <- estimate_variable_importance(Arc)
    MOKRR <- train_multi_output_krr(Arc, weighted_hamming(theta), mu)

    for each weight vector lambda_k:
        P_k <- best N solutions in Arc by g(x | lambda_k, z)
        z_hat <- z
        repeat t_max:
            O_k <- uniform_crossover_and_importance_mutation(P_k, theta)
            F_hat(O_k) <- MOKRR.predict(O_k)
            z_hat <- update_predicted_ideal(z_hat, F_hat(O_k))
            P_k <- replace parent by offspring if predicted scalarizing improves

        o_k <- unevaluated solution in P_k with largest Hamming sparsity to Arc
        F(o_k) <- true_evaluate(o_k)
        Arc <- Arc union {o_k}
        update z and scalarizing values
```

P2026-0250 的具体设置：

- `N_max=40`，`N_lambda=21`，`t_max=20`，`mu=0.01`；
- shared mutation rate `p_m=1/D`；
- 最大真实评价数在 MOKP/MNK 上为 500；
- 每个算法 20 次独立运行，Wilcoxon rank-sum test at 0.05。

## 如何用于算法创新

### 局部创新

- 用 MOKRR/RF/RBF/逐目标 KRR 的在线选择器替代固定 MOKRR，选择依据可为 scalarizing rank accuracy、Pareto rank consistency 或真实 infill contribution。
- 将 DDISC 改为混合指标：`predicted convergence + Hamming sparsity + model uncertainty + duplicate penalty`。
- 对每个子问题估计局部变量重要性，而不是全目标共享一个 `theta`。
- 在 early stage 使用 uniform Hamming kernel 或 ensemble，等样本数足够后再启用 importance-weighted kernel。
- 用 Jaccard、learned binary embedding、graph distance 或 constraint-aware distance 替代普通 Hamming 稀疏度。

### 结构创新

- 构建通用 EMBOP surrogate pipeline：

```text
binary structural surrogate
-> decomposition subproblem optimizer
-> sparse/uncertain infill selector
-> true evaluation archive feedback
```

- 与 filter 特征选择结合：filter 指标提供先验变量权重，MOKRR 用真实 wrapper 评价校正。
- 与多任务优化结合：不同数据集/场景共享一个多任务 kernel，子问题 archive 还可跨任务迁移候选。
- 与约束二进制 MOO 结合：为 objective 和 CV 共同训练多输出 surrogate，DDISC 同时考虑稀疏度和可行性风险。
- 与 learned binary generator 结合：MOKRR 不只筛选候选，也为二进制生成器提供 loss 或 reward。

## 适用条件与风险

- 适用条件：
  - 决策变量是二进制或可稳定二值化；
  - 真实评价比 `O(|Arc|^3)` 量级的 KRR 训练和代理内搜索贵得多；
  - 多目标之间存在一定相关，且共享 kernel 不会压制特定目标；
  - Hamming 或其变体可以表达候选之间的结构差异；
  - 有足够 archive 样本用于估计变量重要性。
- 不适用或可能失效的条件：
  - 目标之间几乎无相关，强行共享 kernel 带来负迁移；
  - 高维 large-scale binary 下 archive 很小，变量重要性估计噪声大；
  - 目标由高阶 epistasis 主导，单 bit 重要性和 Hamming 距离难捕捉结构；
  - 搜索需要强收敛时，纯稀疏 DDISC 可能过度探索；
  - 真实评价不太昂贵，代理训练和子问题内循环的开销不划算。
- 计算与实现成本：
  - MOKRR 需要构造 `|Arc| x |Arc|` kernel matrix 并求解 regularized linear system；
  - 每个权重子问题都运行代理内二进制进化；
  - 需要缓存已评价解，避免重复评价；
  - large archive 时需要稀疏 KRR、Nyström、局部代理或滑动窗口。
- 解释风险：
  - 预测 MSE 更低不保证优化结果更好；P2026-0250 低维 MOKP 上就出现 MOKRR 准但 RF 框架更优的情况。
  - DDISC 的优势来自和 MSCO/MOKRR 的组合，不应单独外推为所有 EMBOP 都应优先选最稀疏候选。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0250 | 作者指出 RF/RBF 逐目标建模会忽略目标相关，普通 Hamming 难捕捉二进制结构，pre-screening 和 local search 各有局限 | 问题动机 | Introduction，PDF 1-2 |
| P2026-0250 | MOKRR-SCo 每轮训练 MOKRR，用 MSCO 为每个子问题生成 `P_k`，再用 DDISC 选候选真实评价并更新 archive | 完整流程 | Sec. III，Algorithm 1，PDF 3-4 |
| P2026-0250 | MOKRR 使用 shared weighted Hamming kernel 和多输出 KRR 共同拟合多个目标 | 作者提出的方法 | Sec. III-A，PDF 4-5 |
| P2026-0250 | 变量重要性由样本对 bit 相同/不同与目标空间差异估计，并归一化后进入 kernel | 作者提出的方法 | Sec. III-A，PDF 4-5 |
| P2026-0250 | MSCO 从全局 archive 为每个子问题选择父代，使用 uniform crossover、重要性引导 bit mutation 和 predicted scalarizing replacement | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 5-6 |
| P2026-0250 | MSCO 在代理内搜索中动态更新 predicted temporary ideal point，避免固定 ideal point 偏置 | 作者提出的方法 | Sec. III-B，PDF 6 |
| P2026-0250 | DDISC 从 `P_k` 中选择未评价且 Hamming 稀疏度最高的候选做真实评价 | 作者提出的方法 | Sec. III-C，Algorithm 3，PDF 6-7 |
| P2026-0250 | 参数敏感性推荐 `N_max=40`、`N_lambda=21`、`t_max=20`、`mu=0.01`，并解释过大/过小设置的退化原因 | 参数分析 | Sec. IV-B，Table I，PDF 7 |
| P2026-0250 | MOKRR-SCo 相比 RF-SCo/RBF-SCo 在 16/20 和 15/20 个问题上显著更好，MOKRR 预测 MSE 通常最低 | 代理消融支持 | Sec. IV-C，Table II，Fig. 1，PDF 8-9 |
| P2026-0250 | MOKRR-SCo 全部优于 noVIE 和逐目标 KRR 变体，支持变量重要性和多目标联合建模 | 代理消融支持 | Sec. IV-C，PDF 8-9 |
| P2026-0250 | MOKRR-SCo 相比 MOKRR-VNS 在 13/20 个问题显著更好，说明 MSCO 比预定义邻域搜索更有效 | 搜索组件消融 | Sec. IV-C，PDF 9 |
| P2026-0250 | MOKRR-SCo 相比 convergence-driven infill 在 9/20 个问题显著更好、2 个更差，支持 DDISC 但也暴露收敛损失风险 | infill 消融 | Sec. IV-C，PDF 9 |
| P2026-0250 | 60 个 MOKP/MNK 实例中 MOKRR-SCo 取得 53 个 best performance，平均排名 1.22，Friedman `p<0.05` | 综合实验支持 | Sec. IV-D，Table III，PDF 9-11 |
| P2026-0250 | 相比 NSGA-II、SMS-EMOA、MOEA/D、MCEA/D、LDS-AF、MOEA/D-RFTS、SANS，MOKRR-SCo 显著更好的实例数分别为 60、60、57、56、53、51、60 | 统计支持 | Sec. IV-D，PDF 9 |
| P2026-0250 | MOFS 10 个数据集上，MOKRR-SCo 在 9 个数据集显著优于所有对比算法，仅与 SANS 在 1 个数据集相当 | 真实应用支持 | Sec. IV-E，Table IV，PDF 12 |
| P2026-0250 | 作者指出低维 MOKP 上 MOKRR 准确但优化不总最佳，未来需自适应协调 surrogate modeling 和 search behavior | 局限与未来工作 | Sec. IV-D / V，PDF 11-12 |

## 证据边界

- 当前只有单篇论文证据。
- HV 的主实验详细结果在补充材料，主文主要展示 IGD+ 表和 HV 统计摘要。
- Benchmark 最大维度为 `D=200`，作者也把 large-scale expensive binary MOO 留作未来工作。
- MOFS 细节在补充材料，主文只报告 HV 统计摘要。
- MOKRR 的预测优势不总能转化为优化优势，说明 model-search-infill 协同仍需在线控制。

## 待确认

- 如何用真实评价后的贡献反馈选择 MOKRR、RF、RBF 或 ensemble。
- DDISC 中 Hamming 稀疏度和预测收敛项的最佳权衡是否应随阶段变化。
- 变量重要性估计是否能处理高阶 epistasis、强冗余和等价编码。
- 在 `D >> 200` 或 `M > 3` 时，KRR 训练、子问题数量和真实评价预算如何共同缩放。
- 对显式约束 EMBOP，应把 CV 放进多输出代理、单独建模，还是用约束专用 infill。
