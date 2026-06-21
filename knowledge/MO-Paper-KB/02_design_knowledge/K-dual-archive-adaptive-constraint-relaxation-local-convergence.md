---
knowledge_id: K-dual-archive-adaptive-constraint-relaxation-local-convergence
name: 双档案自适应约束松弛与局部收敛选择
type: method
status: active
source_papers: [P2026-0189]
aliases: [ACREA, ACR, adaptive constraint relaxation, leading archive, primary archive, constraint-aware local convergence, diversity integrated selection, 自适应约束松弛, 双档案CMOEA, 局部收敛指标, 决策空间多样性选择]
promotion_reason: 单篇论文提出但接口明确，包含 primary/leading archive 弱协同、后期按 archive 相对距离自适应决定 leading archive 是否考虑约束、约束感知局部收敛指标和决策空间多样性截断，可直接改造双种群或双档案 CMOEA
---

# 双档案自适应约束松弛与局部收敛选择

## 核心内容

在约束多目标优化中，不让辅助档案始终忽略约束追逐 UPF，而是让它早期完全放松约束、后期根据它与主档案的相对位置动态决定是否重新考虑约束。主档案始终面向 CPF 和可行性，并用约束感知的局部收敛指标保留不同邻域的潜在优质解，再用决策空间距离截断维护多个断裂可行区域的覆盖。

```text
primary archive AP: constrained CPF search
leading archive AL:
    early stage -> ignore constraints, locate UPF / promising regions
    late stage:
        if AL close to AP -> keep relaxing constraints
        if AL far from AP -> use constrained selection, pull back to CPF
AP update:
    constraint-aware local convergence
    decision-space diversity truncation
```

## 建立理由

- 为什么值得独立维护：它回答了双档案 CMOEA 中两个常见问题：辅助档案何时应从 UPF 探索回到 CPF，以及主档案如何同时保留局部收敛和决策空间多样性。
- 单篇具体方法的直接复用价值：P2026-0189 给出 ACREA Algorithm 1、ACR 公式、local convergence indicator 公式、复杂度、消融、三套 benchmark 和 18 个真实 CMOP 证据。
- 与已有设计知识的区别：
  - 不同于“约束边界远距不可行辅助引导”：该知识筛选靠边界且远离主种群的不可行解；本知识控制 leading archive 是否考虑约束，并用 primary archive 的局部收敛维护决策空间多样性。
  - 不同于“自适应约束违反粒度评估”：该知识重写 `CV` 信息粒度；本知识不重赋 `CV`，而是切换 leading archive 的约束选择规则。
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识围绕辅助种群的双边界不可行指标；本知识围绕双 archive 相对距离与局部收敛截断。
  - 不同于“一般不可行解辅助种群组成管理”：该知识控制主种群可行/不可行比例；本知识强调 leading/primary archive 的角色分工和决策空间覆盖。

## 解决的问题

- 适用场景：
  - CPF 与 UPF 不重合，且长期追 UPF 会误导搜索；
  - 可行域狭窄、断裂或多个 CPF 片段对应不同决策空间区域；
  - 主种群可行性优先容易局部收敛；
  - 希望保留辅助档案早期跨越不可行障碍的能力，又避免后期浪费预算。
- 现有方法为什么会失败或不足：
  - 辅助档案始终忽略约束，在 UPF/CPF 距离大时会持续产生无用 offspring。
  - 固定阶段切换无法判断当前辅助档案是否真的偏离主档案。
  - 原始 local convergence indicator 会保留无邻居的 infeasible local optimum。
  - 只看目标空间 diversity 可能遗漏断裂 CPF 对应的决策空间区域。
- 仍需解决的问题：
  - `dmean(AP)` 与 `IGD(AP,AL)` 是否能在所有尺度下稳定判断 archive 偏离；
  - high-dimensional objective/decision space 中的邻域和距离计算；
  - 如何让阶段阈值 `0.5 MaxGen` 和距离判据自适应；
  - 混合变量、离散变量或冗余变量下决策空间距离是否可靠。

## 为什么可能有效

```text
早期可行性压力过强
-> 容易被大不可行障碍挡住
-> leading archive 放松约束快速发现 UPF / 潜在方向

后期 UPF 与 CPF 偏离
-> 无约束 leading archive 可能浪费预算
-> 用 AP spread 与 AP-AL 距离比较判断是否拉回

CPF 断裂或多决策区域
-> 全局选择易只保留一个区域
-> 约束感知 local convergence 保留各邻域潜力解
-> decision-space truncation 维护区域覆盖
```

关键假设是：primary archive 的分布尺度能代表当前 CPF 搜索的有效覆盖，leading archive 到 primary archive 的距离能反映辅助信息是否仍有用；同时，决策空间邻近关系与 CPF 分段覆盖存在一定对应。若 AP 已经早熟或决策变量高度冗余，距离判据可能误导。

## 实现接口

- 输入：
  - primary archive `AP`、leading archive `AL`；
  - 每个候选的 objective values、constraint violation 和 decision vectors；
  - 总代数 `MaxGen`、当前代 `gen`、种群规模 `N`；
  - 无约束环境选择器和约束环境选择器；
  - neighborhood / distance calculator。
- 输出：
  - 更新后的 `AP` 和 `AL`；
  - 可由 `AL` 注入 `AP` 的 offspring 或候选。
- 插入位置：
  - 双档案或双种群 CMOEA 的 auxiliary archive update；
  - constrained environmental selection 中的 local convergence ranking；
  - 针对断裂 feasible regions 的 diversity truncation 层。
- 最小流程：

```text
AP <- initial population
AL <- initial population

for gen in 1..MaxGen:
    if gen / MaxGen < 0.5:
        delta_CV <- 1          # AL ignores constraints
    else:
        dmean <- average_pairwise_distance(AP)
        inter <- IGD(AP, AL)   # distance from AL to AP
        if dmean >= inter:
            delta_CV <- 1      # AL is close enough; keep objective exploration
        else:
            delta_CV <- 0      # AL diverged; consider constraints

    OL <- variation(tournament_selection(AL))
    if delta_CV == 1:
        AL <- environmental_selection(AL union OL, constraints=false)
    else:
        AL <- environmental_selection(AL union OL, constraints=true)

    AP <- constraint_local_convergence_selection(AP union OP union OL)
    AP <- decision_space_diversity_truncation(AP, N)
```

P2026-0189 的具体设置：

- 前 50% evolution 中 `AL` 始终不考虑约束；
- 后 50% 每代用 `dmean(AP)` 与 `IGD(AP,AL)` 设定二值 `delta_CV`；
- `delta_CV=1` 时，`AL` 用 non-dominated sorting 和 crowding distance，不考虑 constraint violation；
- `delta_CV=0` 时，`AL` 用 constrained dominance principle；
- `AP` 的 local convergence 结合全局 constraint domination 和 objective-space neighborhood dominance；
- 最后用归一化 decision-vector distance 做 diversity integrated selection；
- 复杂度为 `O(MN^2)`。

## 如何用于算法创新

### 局部创新

- 用 feasible HV contribution、archive survival rate、CPF proximity 或 prediction error 替代 `dmean/IGD` 的硬判据。
- 将固定 `0.5 MaxGen` 改为由可行比例、UPF-CPF 距离、AP stagnation 或 AL 贡献率触发。
- 把 objective-space neighborhood 改成 reference-vector sector、epsilon box、constraint-space neighborhood 或 learned manifold neighborhood。
- 在 decision-space truncation 中融合目标空间、决策空间和约束空间距离，减少冗余变量误导。
- 对不同约束或不同 CPF 片段维护多个 leading archives，分别决定是否约束回收。

### 结构创新

- 构建三档案 CMOEA：

```text
AP: feasible CPF convergence
AU: unconstrained UPF exploration
AB: boundary / low-CV diverse infeasible candidates
controller: allocate selection pressure and offspring exchange by contribution
```

- 与自适应 CV 粒度组合：当 `AL` 放松约束时使用粗粒度或簇级 CV，回归 CPF 时使用细粒度 CV。
- 与代理辅助 CMOP 组合：用 surrogate 估计 `AL` 候选靠近 CPF 的概率，减少无用真实评价。
- 与强化学习控制组合：把 `delta_CV`、archive exchange rate、local neighborhood size 和 truncation distance 权重作为动作。

## 适用条件与风险

- 适用条件：
  - 有明确的 objective values、constraint violation 和 decision vectors；
  - UPF 或无约束搜索能提供早期方向信息；
  - CPF/feasible regions 可能断裂，决策空间覆盖很重要；
  - 可以维护两个 archive，并允许 leading archive offspring 注入 primary archive。
- 不适用或可能失效的条件：
  - UPF 与 CPF 完全无关，早期无约束探索会强烈误导；
  - 可行域简单且 CPF 连续，双档案和 local convergence 成本可能过重；
  - primary archive 已早熟，`dmean` 很小会过早把 `AL` 拉回；
  - 高维目标或决策空间距离集中，邻域和截断失效；
  - 约束违反尺度或目标尺度未归一化，archive distance 判据偏置。
- 计算与实现成本：
  - 每代需要非支配排序、archive 距离、local convergence dominance 和决策空间距离；
  - 论文给出总体复杂度 `O(MN^2)`，与多种 CMOEA 同阶，但常数项更高；
  - local convergence 和两档案维护在 very large-scale CMOP 中可能成为瓶颈。
- 解释风险：
  - ACREA 的收益来自 ACR、local convergence、decision-space truncation、双档案交换和 GA/MOEA 选择的组合，不能单独归因于 `dmean/IGD` 判据。
  - 对 LIRCMOP8 和 LIRCMOP12，部分变体优于完整 ACREA，说明机制存在问题依赖性。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0189 | 作者指出辅助 archive 长期不考虑约束会在 UPF/CPF 不一致时浪费资源并提供错误信息 | 问题动机 | Introduction / Sec. III，PDF 1、4 |
| P2026-0189 | ACREA 维护 primary archive 和 leading archive，并分两阶段更新 leading archive | 作者提出的方法 | Sec. III-A，Algorithm 1，Fig. 4，PDF 4-6 |
| P2026-0189 | ACR 用 `dmean(AP)` 和 `IGD(AP,AL)` 决定 `delta_CV`，控制 `AL` 是否考虑约束 | 作者提出的方法 | Sec. III-B，Eq. (8)-(10)，PDF 5-6 |
| P2026-0189 | 约束感知 local convergence indicator 将 constraint domination 和 objective-space neighborhood dominance 合并 | 作者提出的方法 | Sec. III-C.1，Fig. 5，PDF 7-8 |
| P2026-0189 | Diversity integrated selection 用归一化 decision vectors 的距离进行截断 | 作者提出的方法 | Sec. III-C.2，PDF 8 |
| P2026-0189 | LIRCMOP 上 ACREA 在 14 个问题中 10 个取得最佳 IGD，LIRCMOP9/12 可视化中完整覆盖 CPF | 综合实验支持 | Sec. IV-B.1，Table I，Fig. 6-7，PDF 9-10 |
| P2026-0189 | DASCMOP 上 ACREA 在 9 个问题中 5 个最佳，DASCMOP6/8 可视化显示窄可行域和分离 PF 覆盖更好 | 综合实验支持 | Sec. IV-B.2，Table II，Fig. 8-9，PDF 10-11 |
| P2026-0189 | ZXH-CF 上 ACREA 在 9 个问题中 7 个最佳 | 综合实验支持 | Sec. IV-B.3，Table III，PDF 12 |
| P2026-0189 | 18 个 real-world CMOP 中 ACREA 在 11 个问题上获得最佳 HV | 真实应用支持 | Sec. IV-C，Table IV，PDF 12-13 |
| P2026-0189 | Friedman 平均排名为 LIRCMOP 1.85、DASCMOP 2.11、ZXH-CF 1.55、real-world 1.52，整体最佳 | 统计支持 | Sec. IV-D，Fig. 10，PDF 12-13 |
| P2026-0189 | ACREA-v1/v2/v3 消融分别验证 ACR、local convergence indicator 和 diversity integrated selection 的贡献 | 组件消融 | Sec. IV-E.1，Table V，PDF 13-14 |
| P2026-0189 | LIRCMOP7 search behavior 显示 `AL` 后期因距离过大而考虑约束并回到 CPF 附近 | 机制解释 | Sec. IV-E.2，Fig. 12，PDF 14 |
| P2026-0189 | 作者指出双档案和 local convergence 额外成本、高维瓶颈、缺少自适应参数调节是局限 | 作者局限 | Conclusion，PDF 14-15 |

## 证据边界

- 当前只有单篇论文证据。
- 主文数值表为图片占位，精确表格需回 PDF 或 supplementary。
- 多数实验为固定 `N=100`、`NFE=100000` 和固定参数；低预算或超大规模情况未充分验证。
- many-objective CMOP 只在未来工作中提及，暂无直接证据。
- 决策空间多样性是否等价于 CPF 覆盖依赖问题结构，不能无条件外推。

## 待确认

- `dmean/IGD` 判据是否应归一化到 objective/decision/constraint 多个空间；
- `AL` 对 `AP` 的贡献是否可以用 offspring survival rate 或 feasible archive improvement 直接度量；
- local convergence 的 neighborhood size 是否应随可行比例或 CPF 断裂程度调节；
- 在 high-dimensional decision space 中是否需要先做变量分组或降维再算决策距离；
- 如何与边界不可行档案、自适应 CV 粒度或动态约束优先级联合使用。
