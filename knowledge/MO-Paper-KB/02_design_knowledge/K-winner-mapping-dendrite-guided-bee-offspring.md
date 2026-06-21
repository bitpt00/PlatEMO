---
knowledge_id: K-winner-mapping-dendrite-guided-bee-offspring
name: 胜者映射学习引导的蜂群子代生成
type: method
status: active
source_papers: [P2026-0024]
aliases: [DDMOABC, DD-guided offspring, Dendrite Net guided ABC, winner-loser mapping, dendrite net learning, neural guided artificial bee colony, 树突网络引导蜂群, 胜者-败者映射, 学习引导子代生成]
promotion_reason: 单篇论文提出但接口明确，包含二元竞争 winner/loser 样本构造、轻量树突网络学习劣解到优解的映射、边界约束预测和 DE/rand/1 蜂群搜索集成，可直接改造 ABC、PSO、CSO、DE 等群智能算法的子代生成模块
---

# 胜者映射学习引导的蜂群子代生成

## 核心内容

在群智能算法中，用当前种群的二元竞争构造训练数据：较差个体作为输入 `X`，较优个体作为输出 `Y`，训练一个轻量 Dendrite Net 学习“劣解如何移动到优解附近”的非线性映射。生成子代时，网络预测提供方向引导，再与 `DE/rand/1` 或 ABC 的 employed/onlooker/scout 机制结合，使搜索既有学习到的收敛方向，又保留差分扰动和随机重启带来的探索能力。

```text
binary tournament
-> losers X / winners Y
-> train lightweight dendrite net f(X) ~= Y
-> predict guided offspring
-> boundary repair
-> DE/rand/1 + ABC employed/onlooker update
-> scout reset for diversity
```

## 建立理由

- 为什么值得独立维护：它给出了一个清晰的 learning-guided offspring generation 接口，不需要外部标签，直接用进化过程中的 winner/loser 关系构造监督信号。
- 单篇具体方法的直接复用价值：P2026-0024 给出 DD 模型、Algorithm 1-2、DE/rand/1 集成、ZDT 大规模测试、UAV 九场景 HV 对比和消融实验。
- 与已有设计知识的区别：
  - 不同于“成功率反馈的算子与参数自适应”：该知识用历史成功率选择算子和参数；本知识训练一个映射模型来生成或引导子代。
  - 不同于“目标条件化生成式设计采样”：该知识用生成模型按目标偏好产生候选；本知识的监督信号来自种群内部 winner/loser 对，作用位置是群智能搜索更新。
  - 不同于 DRL 算子选择：本知识不学习动作策略，而是学习劣解到优解的候选映射。

## 解决的问题

- 适用场景：
  - ABC、PSO、CSO、DE 等群智能算法局部开发弱或收敛慢；
  - 搜索过程中能够频繁比较个体优劣；
  - 评价预算允许少量模型训练开销；
  - 需要从历史优秀个体中学习方向，但不希望使用重型深度模型或强化学习。
- 现有方法为什么会失败或不足：
  - 原始 ABC 的 employed/onlooker 搜索偏随机，局部开发能力不足。
  - 固定差分扰动能扩大搜索，但不显式学习哪些移动方向更可能产生优解。
  - 复杂深度模型可能训练成本高、样本需求大，不适合每代在线嵌入。
  - 只复制 winner 容易丢失多样性，只随机 scout 又浪费评价。
- 仍需解决的问题：
  - 如何过滤低质量 winner/loser 样本，避免模型学习早期噪声；
  - DD 预测与差分扰动的使用比例如何自适应；
  - 模型训练频率、网络深度和学习率如何随问题规模调整；
  - 多目标场景中 winner 定义如何兼顾收敛和多样性。

## 为什么可能有效

```text
种群中 winner/loser 对包含局部改进方向
-> 监督模型学习 loser 到 winner 的非线性映射
-> 预测子代比纯随机扰动更有方向性
-> DE/rand/1 保留种群差分探索
-> ABC scout 保留随机重启和多样性
-> 学习引导 + 差分扰动 + 随机恢复形成互补
```

关键假设是：当前种群中的 winner 确实包含可复用的改进模式，且这种模式能在相邻候选中泛化。若 winner 只是偶然优势、目标空间多样性不足，或问题高度离散/不可微且映射不连续，模型可能过拟合并误导搜索。

## 实现接口

- 输入：
  - 当前种群及目标值/适应度；
  - winner/loser 选择规则，如二元锦标赛、非支配 rank + crowding distance、indicator ranking；
  - 轻量映射模型，如 Dendrite Net、MLP、RBF、线性/局部模型；
  - 差分扰动或原始群智能更新算子；
  - 边界修复和 scout/reset 规则。
- 输出：
  - DD-guided offspring；
  - 差分扰动 offspring；
  - 更新后的种群和 trial counters。
- 插入位置：
  - ABC employed bee 和 onlooker bee phase；
  - CSO/PSO loser update；
  - DE mutation/crossover 前的候选预引导；
  - MOEA 的 offspring generation module；
  - 路径规划或组合优化中的局部路径修复/细化。
- 最小实现：

```text
for each generation:
    X, Y <- [], []
    for k in 1..batch_pairs:
        a, b <- random_two_individuals(P)
        loser, winner <- compare(a, b)
        X.add(loser.decision_vector)
        Y.add(winner.decision_vector)

    model.fit(X, Y, epochs=small_number)

    for each selected parent:
        guided <- model.predict(parent)
        guided <- boundary_repair(guided)

        r1, r2, r3 <- random_distinct(P)
        de_child <- r1 + rand() * (r2 - r3)
        child <- combine_or_select(guided, de_child)

        if child better than parent:
            replace(parent, child)
            trial[parent] <- 0
        else:
            trial[parent] += 1

    for each parent with trial > theta:
        parent <- random_reinitialize()
```

- P2026-0024 的具体设置：
  - DD 网络层数 `nl=3`；
  - 初始学习率 `ac=0.001`；
  - batch training 通常为 2；
  - DDMOABC population size `NP=100`；
  - scout 阈值 `theta=100`；
  - modified `DE/rand/1` 使用 `rand()` 作为差分缩放。

## 如何用于算法创新

### 局部创新

- 将 ABC 的随机 food-source update 替换为 winner-mapping guided update。
- 把 CSO loser update 改为“loser -> predicted winner-like point -> differential refinement”。
- 使用外部 Pareto archive 中的非支配个体作为 winner，提高监督样本质量。
- 为不同目标区域训练多个局部 DD 模型，避免全局单模型平均化多个 Pareto 区域。
- 用模型预测误差或子代成功率动态决定 DD-guided offspring 的比例。

### 结构创新

- 构建“进化过程自监督学习 -> 轻量预测引导 -> 群智能差分搜索 -> 随机重启恢复”的混合优化框架。
- 将 winner/loser 映射模型与多目标环境选择结合，winner 不只由目标值决定，还考虑拥挤距离、参考向量区域和约束违反。
- 在动态优化中保留跨环境 winner/loser 记忆，使新环境变化后模型能快速微调。
- 将该机制作为路径规划算法的局部修复器：学习差路径片段到好路径片段的映射，再由全局 MOEA 选择。

## 适用条件与风险

- 适用条件：
  - 解编码为连续或可连续化向量，便于模型预测和边界修复；
  - 种群中存在可比较的 winner/loser 对；
  - 优劣个体之间的差异包含可泛化的改进规律；
  - 模型训练开销低于由更快收敛节省的评价成本。
- 不适用或可能失效的条件：
  - 组合/排列编码缺少自然连续映射；
  - 早期种群整体质量差，winner 仍远离有效区域；
  - 多目标 winner 选择过度偏向收敛，导致模型牺牲多样性；
  - 模型训练过频或网络过大，时间成本抵消收益。
- 计算与实现成本：
  - 每代需要构造 winner/loser 对并训练轻量模型；
  - 需要边界修复，路径规划中还需要碰撞/地形可行性检查；
  - 若引入多个局部模型，内存和调参成本会增加。
- 解释风险：
  - 性能提升来自 DD、DE/rand/1 和 ABC scout 的组合，不能把全部收益归因于 DD 模型。
  - 若只比较完整算法和原始 ABC，无法区分差分算子与学习模型的独立贡献；需要 MOABC-DE 等消融。
  - HV 或 IGD 提升不等于所有单个目标均更优，工程路径仍需按任务偏好选解。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0024 | DD 模型用二元随机选择得到 inferior/superior solution 作为训练样本，并用于预测新解 | 作者提出的方法 | Sec. 3.2，Algorithm 1，PDF 4-5 |
| P2026-0024 | modified `DE/rand/1` 被嵌入 employed bee 和 onlooker bee phase | 作者提出的方法 | Sec. 3.3-3.4，Eq. (13)，Algorithm 2，PDF 6-7 |
| P2026-0024 | ZDT 大规模测试中 DDMOABC 在 20 组实验中获得 16 个最佳 IGD | benchmark 支持 | Sec. 4，Table 1，PDF 4、9 |
| P2026-0024 | UAV 九场景中 DDMOABC 在 7/9 场景取得最高 HV，且无显著劣势场景 | 工程实验支持 | Sec. 5.2，Table 3，PDF 11-12 |
| P2026-0024 | 相对 MOABC，DDMOABC 平均 HV 提升约 39.1% | 工程实验支持 | Abstract，Sec. 5.2，PDF 1、12 |
| P2026-0024 | 消融中完整 DDMOABC 在 9/9 场景优于 baseline ABC 和 MOABC-DE | 组件消融 | Sec. 5.3，Table 4，PDF 12 |
| P2026-0024 | 作者指出 DD 网络会带来时间影响，是未来改进方向 | 作者局限 | Sec. 6，PDF 15 |

## 证据边界

- 当前只有单篇论文证据。
- ZDT 测试主要是 2 目标连续 benchmark；UAV 场景是 4 目标仿真工程问题。
- 没有充分报告 DD 模块训练时间、总体 runtime 和不同训练频率的敏感性。
- DD-guided strategy 依赖连续路径编码和边界修复，对离散/排列问题需重新设计映射。
- UAV 真实环境中的动态障碍、风场、动力学约束和在线重规划未纳入主要实验。

## 待确认

- winner/loser 样本如何在多目标非支配关系中更稳健地定义；
- DD-guided offspring 和 DE offspring 应如何组合或择优；
- 模型训练频率是否应随搜索阶段下降；
- 在高维、强约束或离散路径规划中如何保持预测可行性；
- 是否能用更简单的线性/局部模型达到相近效果，降低时间成本。
