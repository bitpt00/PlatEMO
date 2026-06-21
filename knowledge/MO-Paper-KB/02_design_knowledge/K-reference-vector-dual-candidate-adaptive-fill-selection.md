---
knowledge_id: K-reference-vector-dual-candidate-adaptive-fill-selection
name: 参考向量双候选自适应补位选择
type: method
status: active
source_papers: [P2026-0054]
aliases: [RVEAADS, adaptive adjustment strategy, diversity maintenance strategy, convergence promotion strategy, reference vector missing individual fill, APD selection supplement, dual candidate environmental selection, 参考向量补位, 多样性候选集, 收敛候选集, 自适应精英补齐]
promotion_reason: 单篇论文提出但接口明确，包含 reference-vector/APD 初筛后的剩余解管理、多样性候选集、收敛候选集、交集优先、早期多样性/后期收敛补位和 elite retention，可直接改造 RVEA、NSGA-III、MOEA/D 等参考向量环境选择模块。
---

# 参考向量双候选自适应补位选择

## 核心内容

在参考向量引导的 many-objective 环境选择中，标准做法通常是每个非空子空间选一个 APD/PBI 最优解。但在早期或 irregular PF 上，部分子空间为空，最终精英数量可能不足；同时一些靠近相邻参考向量边界、或比同子空间精英更接近理想点的剩余解会被直接丢掉。该机制在初筛后把剩余解分成两个候选集：`DP` 用新参考向量二次划分找回多样性候选，`PP` 用同子空间 L1 收敛比较找回收敛候选。补位时先加入 `DP∩PP`，然后按阶段早期偏 `DP`、后期偏 `PP`，直到填满目标种群规模。

```text
parents + offspring
-> reference-vector/APD initial selection gives S
-> remaining solutions R
-> DP: regenerate/reference repartition for diversity candidates
-> PP: compare convergence with subspace elite for promising candidates
-> add DP intersect PP first
-> early stage fill from DP, late stage fill from PP
-> final environmental selection population
```

## 建立理由

- 为什么值得独立维护：它给出了一个可插入式“初筛后补位层”，专门处理参考向量选择中的空子空间、选不满和剩余优质解浪费问题。
- 单篇具体方法的直接复用价值：P2026-0054 给出 RVEAADS 的 Algorithm 1-5、复杂度、30 次独立运行、DTLZ/WFG/MaF 综合比较、消融和参数敏感性。
- 与已有设计知识的区别：
  - 不同于“层级估计与聚类筛选的有效参考向量”：该知识识别有效参考向量和 critical level；本知识不筛掉参考向量，而是在初筛后用 `DP/PP` 补齐缺失个体。
  - 不同于“自适应子区多方向竞争更新”：该知识改造 CSO/PSO 的 offspring generation 和 winner/loser 信息流；本知识改造 reference-vector environmental selection。
  - 不同于“特殊点引导的代理辅助复杂前沿搜索”：该知识用膝点/断裂点和代理 infill 管理真实评价；本知识不使用代理模型。
  - 不同于普通 elitism：本知识不仅保留已有精英，还显式利用剩余解构造多样性与收敛两个可互补的补位池。

## 解决的问题

- 适用场景：
  - MaOP 或 many-objective benchmark/工程问题；
  - 使用 RVEA、NSGA-III、MOEA/D、PBI、APD 或 reference-vector/subspace selection；
  - 初筛后精英数量不足，或大量剩余解被无差别丢弃；
  - PF 非均匀、局部弯曲或相邻参考向量边界附近存在有价值候选；
  - 想用低额外成本增强收敛-多样性平衡。
- 现有方法为什么会失败或不足：
  - 每个参考向量只选一个最优解，会忽略子空间边界附近的潜在优质解。
  - 空子空间导致最终选中个体数小于预设规模。
  - 固定均匀参考向量在 irregular/nonuniform PF 上会把搜索预算放到无效方向。
  - 只看 APD 可能早期偏收敛、后期局部集中；只看距离理想点又会破坏分布。
- 仍需解决的问题：
  - 阶段切换阈值如何自适应，而不是固定前半段/后半段；
  - `DP` 和 `PP` 候选冲突时如何排序；
  - 动态参考向量由当前精英生成时如何避免早期偏置；
  - 高目标数下 L1 收敛比较是否仍可靠。

## 为什么可能有效

```text
reference-vector initial selection gives sparse but structured elites
-> remaining solutions are not uniformly bad
-> some improve coverage near new/adjacent directions
-> some improve convergence within their original subspace
-> intersection candidates satisfy both roles
-> early diversity fill widens exploration
-> late convergence fill accelerates PF approximation
```

关键假设是：初筛后剩余解中仍包含有用的多样性或收敛信号，且当前参考向量关联能够大致刻画目标空间区域。如果剩余解整体很差、精英集早期高度偏置，或目标缩放使 L1 范数比较失真，补位策略可能引入噪声个体。

## 实现接口

- 输入：
  - 候选池 `P_c`；
  - 参考向量集合 `V`；
  - 当前迭代 `t` 和最大迭代 `t_max`；
  - 目标种群规模或上界 `N'`；
  - 初筛得到的精英集 `S`；
  - 未选剩余解 `R`；
  - 目标平移/归一化函数、APD/PBI 选择器、非支配排序器。
- 输出：
  - 多样性候选集 `DP`；
  - 收敛候选集 `PP`；
  - 自适应补位集 `Q_t`；
  - 环境选择输出 `G_t = S union Q_t`。
- 插入位置：
  - RVEA 的 APD environmental selection 后；
  - NSGA-III 的 reference point niching 后；
  - MOEA/D/PBI 的每方向精英选择后；
  - reference-vector based MaOEA 的 critical front/last front 截断阶段。
- 最小实现：

```text
S <- reference_vector_apd_select(Pc, V)
R <- Pc \ S

DP <- diversity_candidates(S, R):
    V_new <- build_vectors_from_selected_elites(S)
    repartition R by V_new
    select unselected candidates closest to V_new directions

PP <- convergence_candidates(S, R):
    for each x in R:
        k <- original_reference_subspace(x)
        e <- selected_elite_in_subspace(S, k)
        if norm1(translated_f(x)) <= norm1(translated_f(e)):
            PP.add(x)

Q <- []
EP <- DP intersect PP
Q.add_until_full(EP)
DP <- DP \ EP
PP <- PP \ EP

while |S| + |Q| < N_target:
    if progress(t, t_max) < 0.5:
        Q.add(next_candidate(DP))
    else:
        Q.add(next_candidate(PP))
    if chosen_pool_empty:
        fall back to the other pool or APD-ranked R

G <- S union Q
```

- P2026-0054 的具体设置：
  - 种群规模 105；
  - 最大函数评价次数 525000；
  - SBX distribution index 20、crossover probability 1；
  - polynomial mutation distribution index 20、mutation probability `1/n`；
  - elite retention ratio `r=1/3`；
  - 指标为 HV 和 IGD。

## 如何用于算法创新

### 局部创新

- 把固定 0.5 阶段切换改为按空参考向量比例、HV 增量、IGD 代理或停滞代数自适应。
- 对 `DP` 和 `PP` 统一打分，例如 `score = diversity_gap - lambda * convergence_distance`，避免硬切换。
- 在 `DP` 中优先选择空子区邻近候选，在 `PP` 中优先选择比当前精英收敛改善最大的候选。
- 对 `DP∩PP` 做去拥挤或 niche cap，防止交集集中在少数区域。
- 为 L1 收敛比较加入目标尺度、极端点保护或 Tchebycheff/PBI 替代度量。

### 结构创新

- 构建“三层环境选择”：

```text
Layer 1: nondominated / elite retention for quality inheritance
Layer 2: reference-vector APD/PBI selection for structured coverage
Layer 3: dual candidate adaptive fill for missing niches and discarded value
```

- 与动态参考向量结合：若某方向长期只能靠 `DP` 补位，触发参考向量重定位或邻域拆分。
- 与约束 MOO 结合：`PP` 改为 feasibility-aware convergence，`DP` 保留低 CV 边界多样性候选。
- 与代理辅助 MOO 结合：对 `DP` 和 `PP` 候选分别估计不确定性，优先真实评价“既补空区又高不确定”的候选。
- 与算子调度结合：根据 `DP`/`PP` 来源比例反向调节下一代探索/开发算子预算。

## 适用条件与风险

- 适用条件：
  - 目标空间可按参考向量或 reference points 分区；
  - 初筛后仍保留足够剩余解；
  - 目标值可做平移/归一化；
  - 环境选择输出规模需要稳定控制；
  - 评价成本主要在目标函数而非选择计算，允许 `O(MN^2)` 选择开销。
- 不适用或可能失效的条件：
  - 参考向量完全不适配 PF，补位只是局部修补；
  - 目标值尺度变化大，L1 范数不可靠；
  - 早期精英偏置导致 `V_new` 放大错误区域；
  - 剩余解质量普遍很差，补位会降低选择压力；
  - 强断裂/退化 PF 中需要先调整参考向量而不是只补解。
- 计算与实现成本：
  - 需要维护初筛精英、剩余解、原子空间关联和新参考向量关联；
  - 总体最坏复杂度约 `O(MN^2)`；
  - 增加 `r`、目标上界 `N'`、阶段阈值和候选排序等参数。
- 复现风险：
  - P2026-0054 的预印本伪代码排版存在噪声，Algorithm 5 的阶段条件应以正文“早期多样性、后期收敛”为准；
  - 表格中 `RVEAADC/RVEAADS` 混写，引用时需统一为 RVEAADS；
  - path planning 部分 success rate 正文和 Table 11 不一致。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0054 | RVEAADS 在参考向量 APD 初筛后构造 diversity maintenance、convergence promotion 和 adaptive adjustment 三个补位模块 | 作者提出的方法 | Sec. 3.3，Algorithms 2-5 |
| P2026-0054 | Diversity maintenance 用已选精英生成新参考向量并二次划分，从剩余解中选择有覆盖价值的候选 | 作者提出的方法 | Algorithm 3，Fig. 2 |
| P2026-0054 | Convergence promotion 比较剩余解与同子空间精英的平移目标 L1 范数，筛出更有收敛潜力的候选 | 作者提出的方法 | Algorithm 4，Fig. 3 |
| P2026-0054 | Adaptive adjustment 先加入 `DP∩PP`，再按阶段从多样性或收敛候选中补齐缺失个体 | 作者提出的方法 | Algorithm 5，Fig. 4 |
| P2026-0054 | DTLZ 上 RVEAADS HV 16/42 最佳、IGD 17/42 最佳 | 综合实验支持 | Sec. 4.1，Tables 1-2 |
| P2026-0054 | WFG 上 RVEAADS HV 28/54 最佳、IGD 13/54 最佳，但 WFG2 和高目标数存在弱项 | 综合实验与边界 | Sec. 4.1，Tables 3-4 |
| P2026-0054 | MaF 上 RVEAADS HV 25/54 最佳、IGD 30/54 最佳 | 综合实验支持 | Sec. 4.1，Tables 5-6 |
| P2026-0054 | 四个消融变体显示完整 RVEAADS 整体优于只保留 elite、只用 diversity、只用 convergence 或简化自适应的版本 | 组件证据 | Sec. 4.2，Tables 7-10 |
| P2026-0054 | 参数敏感性显示 `r=1/3` 整体最好，过小削弱 elite retention，过大削弱收敛/补位空间 | 参数证据 | Sec. 4.2，Fig. 12 |
| P2026-0054 | 障碍路径规划中 RVEAADS path length 34.4、Table 11 success rate 95%、convergence Fast | 应用证据 | Sec. 4.3，Table 11 |

## 证据边界

- 当前只有单篇论文证据。
- DTLZ、WFG、MaF 是标准 benchmark，真实工程证据只有一个简化障碍路径规划例子。
- RVEAADS 在退化、断裂、非均匀 PF 和 WFG 高目标数场景下仍可能弱。
- 对 `DP`、`PP` 和 `DP∩PP` 的独立贡献仍可进一步细分消融。
- 固定阶段阈值和固定 `r=1/3` 不一定适合所有目标数和 PF 形状。
- 预印本文本和表格有排版噪声，复现前应核对正式版或代码。

## 待确认

- `DP` 内候选的精确排序和去重规则；
- `PP` 用 L1 范数、PBI、Tchebycheff 或垂直距离哪种更稳；
- 当 `DP` 或 `PP` 为空时的 fallback 是否应使用 APD-ranked leftovers；
- 阶段切换是否应由进度、停滞或空子区比例共同决定；
- 和真正动态参考向量重定位方法结合后，补位层是否仍有独立收益；
- 在约束 MaOP、离散 MaOP 和昂贵 MaOP 中的迁移效果。
