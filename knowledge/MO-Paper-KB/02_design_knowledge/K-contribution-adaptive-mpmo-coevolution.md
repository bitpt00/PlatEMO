---
knowledge_id: K-contribution-adaptive-mpmo-coevolution
name: 贡献自适应的多种群多目标协同
type: method
status: active
source_papers: [P2026-0078]
aliases: [MPCMO, MPMO, multi-population co-evolution, contribution-adaptive evolution, forward distance allocation, median IQR migration, angle-first SDE truncation, 多种群协同, 贡献自适应资源分配, 子种群迁移, 角度SDE档案截断]
promotion_reason: 单篇论文提出但接口明确，包含按目标子种群贡献分配进化机会、基于 median/IQR 的优劣子种群迁移、以及角度优先 SDE 档案截断，可直接移植或改造 many-objective 多种群算法
---

# 贡献自适应的多种群多目标协同

## 核心内容

在 many-objective optimization 中，为每个目标维护一个子种群，但不再让所有子种群等机会进化。每代根据子种群近期在对应目标上的 forward distance 贡献分配进化机会；周期性用 median/IQR 判断各子种群状态并进行优劣配对迁移；外部档案截断时先删除最相似搜索方向上的冗余解，再用 SDE 在局部相似解中比较质量。

```text
M 个目标 -> M 个子种群

每代:
    RFD_m <- 子种群 m 近期 forward distance 贡献
    EP_m  <- normalize(RFD_m + delta)
    按 EP_m 抽取本代进化机会
    使用多源 DE: 当前个体 + 各目标子种群优质个体 + archive 个体

每 R 代:
    对每个子种群计算 median 和 IQR
    收敛好且分散大的子种群排名更优
    优势子种群和劣势子种群配对迁移

档案更新:
    合并 archive、archive offspring、所有子种群
    取非支配解
    若超容量:
        找目标向量夹角最小的一对
        只在这对解中用 SDE 删除较差者
```

## 建立理由

- 为什么值得独立维护：它回答了 MPMO/MaOEA 中三个可直接改造的问题：子种群获得多少进化机会、子种群之间如何交换信息、外部档案满了删谁。
- 单篇具体方法的直接复用价值：P2026-0078 给出完整算法、伪代码、复杂度分析、跨 UF/DTLZ/WFG 的实验、与 CMODE/MPMO-BS 的 MPMO 对比，以及四个关键组件消融。
- 与已有设计知识的区别：
  - 不同于“双空间分层自适应资源分配”：该知识面向子区域、变量组和预算层级；本知识面向 MPMO 中按目标划分的子种群机会分配和迁移。
  - 不同于“参考解引导的跨任务知识迁移”：该知识处理多任务迁移中的负迁移；本知识处理 many-objective 单问题中多个目标子种群的协同。
  - 不同于“目标空间流形嵌入的多样性选择”：该知识通过流形嵌入度量不规则 PF 覆盖；本知识用向量夹角先定位冗余方向，再用 SDE 局部截断档案。
  - 不同于“成功率反馈的算子与参数自适应选择”：该知识选择算子或参数；本知识调度的是目标子种群的进化机会和迁移关系。

## 解决的问题

- 适用场景：
  - 目标数较多，Pareto dominance 选择压力不足；
  - 算法已经采用或计划采用多种群/多子种群结构；
  - 每个子种群可对应一个目标、参考方向、目标簇或搜索区域；
  - 子种群之间进展差异大，等资源分配导致预算浪费；
  - 外部档案包含大量非支配解，需要兼顾方向多样性和局部质量。
- 现有方法为什么会失败或不足：
  - 等机会进化忽略各子种群的实时贡献，低潜力方向和高潜力方向消耗相同预算。
  - 只优化单目标的子种群容易朝极端点集中，难以覆盖中间 PF 区域。
  - 弱迁移或随机迁移无法利用优势子种群信息，也难以帮助劣势子种群跳出局部最优。
  - 直接 SDE 截断可能删除目标空间稀疏方向的解，造成档案覆盖退化。
- 仍需解决的问题：
  - 子种群贡献度应该只看单目标改进，还是结合档案贡献、参考区域缺口和多样性贡献；
  - 多目标强相关、退化 PF 或用户偏好区域下，如何重新定义子种群；
  - 迁移频率和迁移规模如何在线自适应；
  - 高维目标和大档案下，如何降低角度/SDE 截断成本。

## 为什么可能有效

```text
高维目标 -> dominance 退化
-> 按目标拆成多个子种群恢复局部搜索压力
-> 贡献高的子种群获得更多机会，提高预算效率
-> 多源 DE 和迁移避免每个子种群只冲向单目标极端点
-> 档案角度去冗余先保方向覆盖，再用 SDE 保局部质量
-> 收敛、多样性和计算成本形成闭环
```

关键假设是：各子种群的近期单目标推进能近似表示未来搜索价值，并且不同目标子种群之间存在可迁移的信息。若 PF 退化到低维流形、目标强相关或目标尺度严重不均，按单目标划分的贡献度可能失真。

## 实现接口

- 输入：
  - `M` 个目标或搜索方向；
  - `M` 个子种群及其目标值；
  - 外部档案 `A`；
  - 每个候选的决策变量和目标向量；
  - 子种群进展窗口 `R`、档案容量 `N_A`；
  - DE 变异、交叉和参数自适应模块。
- 输出：
  - 更新后的子种群；
  - 更新后的外部非支配档案；
  - 每个子种群的近期贡献、进化概率和迁移状态统计。
- 插入位置：
  - MPMO/MaOEA 的子种群调度模块；
  - 多种群算法的 migration layer；
  - 外部档案 update/truncation；
  - DE 或其他演化算子的引导个体选择模块。
- 最小实现：

```text
for generation:
    for each subpopulation m:
        FD_m <- sum of positive objective-m improvements
        RFD_m <- sum_recent(FD_m, window=R)

    delta <- average(RFD)
    EP_m <- (RFD_m + delta) / sum_j(RFD_j + delta)

    repeat M times:
        m <- roulette(EP)
        offspring <- variation(
            current=subpop[m],
            guides=best_individuals_from_all_subpops,
            archive=random_archive_individual
        )
        update subpop[m]

    if generation % R == 0:
        for each subpopulation m:
            med_m <- standardized median of objective m values
            iqr_m <- standardized IQR of objective m values
            rank_m <- ascending_rank(med_m) + descending_rank(iqr_m)
        pair superior and inferior subpopulations
        migrate inferior worse-than-Q3 individuals to superior
        migrate superior random worse-than-Q1 individuals to inferior

    A <- nondominated(A + archive_offspring + all_subpops)
    while size(A) > N_A:
        (x, y) <- pair with smallest objective-vector angle
        remove worse_SDE(x, y)
```

- P2026-0078 的具体实例：
  - `M` 个子种群，每个子种群优化一个目标；
  - `R=10` 用于近期 forward distance 统计和周期性迁移；
  - 改进 DE 变异同时使用当前个体、所有子种群的目标最优个体、随机档案个体和差分向量；
  - 迁移时用单目标值的 `min/Q1/Q2/Q3/max` 标准化 median 和 IQR；
  - 档案截断时目标值先由 ideal/nadir 归一化，再用向量夹角和 SDE。

## 如何用于算法创新

### 局部创新

- 在已有 MPMO 中替换等机会子种群调度，用贡献度或档案贡献度分配进化机会。
- 将 forward distance 扩展为混合贡献：单目标推进、archive non-dominated survival、参考向量覆盖缺口和 HV contribution。
- 把 median/IQR 迁移排序替换为更稳健的分位数统计、目标相关性修正或阶段状态分类器。
- 将角度优先 SDE 截断改为近邻近似、参考方向分桶或流形邻域截断，以降低高档案规模成本。
- 在 DE 之外的算子中复用多源引导思想，例如 PSO leader、GA crossover parent 或 diffusion/generative candidate guide。

### 结构创新

- 构建四层 MaOEA：目标子种群层、贡献调度层、迁移通信层、方向去冗余档案层。
- 与代理辅助优化结合：用 surrogate 估计每个子种群下一批候选的潜在贡献，再分配真实评价预算。
- 与多任务优化结合：把目标子种群当作任务节点，使用迁移成功率学习动态任务图。
- 与偏好优化结合：把用户偏好区域变成基础概率偏置，贡献调度只在偏置基础上自适应调整。
- 与动态多目标优化结合：环境变化后先提高低贡献但高不确定子种群的探索概率，再逐步回到贡献驱动。

## 适用条件与风险

- 适用条件：
  - 目标数较多，单种群 dominance-based selection 明显失压；
  - 子种群可以清晰对应目标、方向或区域；
  - 每个子种群的近期贡献可被稳定估计；
  - 子种群之间存在可共享的搜索信息；
  - 外部档案规模足够大，需要主动截断维护方向覆盖。
- 不适用或可能失效的条件：
  - 目标数少且 dominance selection 已足够有效；
  - 目标强相关或 PF 明显退化，按单目标划分会产生冗余子种群；
  - 问题目标尺度差异极大，forward distance、median 和 IQR 未归一化会误导调度；
  - 欺骗性、多峰性或强不可分离问题中，短期 forward distance 不一定代表长期潜力；
  - 档案容量很小，角度优先截断可能过度保方向而牺牲局部收敛。
- 计算与实现成本：
  - 需要维护多个子种群、近期贡献窗口和迁移统计；
  - 档案截断需要目标向量夹角和 SDE 计算，朴素实现约为 `O(N_A^2 (M + log N_A))`；
  - 相比普通 MPMO 代码复杂度更高，但仍比全局 HV 型高维指标维护更易控制。
- 解释风险：
  - MPCMO 的实验优势来自三件套共同作用，不能把全部收益都归因于机会分配。
  - “贡献高”不等于“未来更重要”，在探索早期或复杂多峰问题中需要保留低贡献方向的最小概率。
  - 角度相近只表示目标方向相似，不一定表示决策空间或局部结构冗余。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0078 | MPCMO 使用 `M` 个子种群，每个子种群对应一个目标，并由外部档案维护全局非支配解 | 作者提出的方法 | Sec. 3，Algorithm 4，PDF 4-8 |
| P2026-0078 | 自适应进化策略根据近期 forward distance 计算 `EP_m`，贡献大的子种群获得更多进化机会，同时所有子种群保留非零机会 | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 4-5 |
| P2026-0078 | 改进 DE 变异引入所有目标子种群的优质个体和外部档案随机个体，避免只沿单目标极端方向搜索 | 作者提出的方法 | Sec. 3.1，Eq. (1)，PDF 4 |
| P2026-0078 | 迁移策略用 median 和 IQR 评价子种群状态，优劣子种群配对交换个体 | 作者提出的方法 | Sec. 3.2，Algorithm 2，PDF 6-7 |
| P2026-0078 | 档案 update-truncation 先定位向量夹角最小的一对解，再用 SDE 删除较差者 | 作者提出的方法 | Sec. 3.3，Algorithm 3，PDF 7-8 |
| P2026-0078 | UF1-10 上 MPCMO 的 IGD 在 10 个问题全部最佳，HV 在 7 个问题最佳 | 综合实验支持 | Sec. 4.2，Table 1，PDF 9-10 |
| P2026-0078 | DTLZ1-7 的 8/10/15 目标实例中，MPCMO 在 17/21 个实例的 IGD best/second-best 统计中有利 | 综合实验支持 | Sec. 4.3，Table 2，PDF 10-12 |
| P2026-0078 | WFG1-9 的 8/10/15 目标实例中，MPCMO 在 19/27 个实例的 IGD best/second-best 统计中有利 | 综合实验支持 | Sec. 4.4，Table 3，PDF 12-14 |
| P2026-0078 | 相对 CMODE，MPCMO 在 UF2、UF4-7、UF10 上表现更好，作者归因于档案截断能保留更多稀疏方向 | MPMO 对比支持 | Sec. 4.6.1，Fig. 8，PDF 15-16 |
| P2026-0078 | 相对 MPMO-BS，MPCMO 在 DTLZ/WFG 的 16 类问题平均结果中优于 12 类 | MPMO 对比支持 | Sec. 4.6.2，Table 6，PDF 16 |
| P2026-0078 | `noAS`、`noMig`、`onlySDE`、`DECtB` 消融均弱于完整 MPCMO，说明四个核心组件对性能有贡献 | 消融实验支持 | Sec. 4.7，Fig. 9，PDF 17-18 |
| P2026-0078 | 作者指出 MPCMO 在 DTLZ5、DTLZ3、WFG1、WFG3 以及 deception/multimodality/inseparability 场景仍需提升 | 作者局限与未来工作 | Sec. 4.3-4.4，Conclusion，PDF 11-18 |

## 证据边界

- 当前只有单篇论文证据。
- 主要证据来自 UF、DTLZ、WFG benchmark，尚缺真实工程 MaOP 或昂贵评价场景证据。
- 消融集中展示在 10-objective DTLZ1 和 WFG5，未对所有测试问题逐一主文报告。
- MPCMO 在 degenerate PF、mixed convex-concave PF、多峰和不可分离场景上并不稳定。
- 子种群按单目标划分是否适合强相关目标或偏好型 MaOP，还需要额外验证。
- 角度优先 SDE 截断保留目标方向覆盖，但不保证决策空间多样性。

## 待确认

- 如何把 forward distance 与档案贡献、参考方向覆盖缺口或 HV contribution 结合；
- 如何自动识别哪些目标子种群冗余，哪些需要拆分或合并；
- 如何根据迁移成功率自适应调整迁移频率、迁移规模和配对方式；
- 如何在大档案或极高目标数下近似计算角度和 SDE；
- 是否能将该三件套独立移植到 CMODE、MPMO-BS、NSGA-III 类参考向量算法或代理辅助 MaOEA 中并保持收益。

