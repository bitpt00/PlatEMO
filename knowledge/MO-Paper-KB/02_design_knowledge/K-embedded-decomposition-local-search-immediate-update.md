---
knowledge_id: K-embedded-decomposition-local-search-immediate-update
name: 全子问题即时更新的嵌入式分解局部搜索
type: architecture
status: active
source_papers: [P2026-0272]
aliases: [EILS/D, embedded LS hybridization, embedded decomposition local search, cooperative neighborhood exploration, decomposition ILS, local-optimality flags, whole-population perturbation, 嵌入式分解局部搜索, 全子问题即时替换, 多目标组合局部搜索]
promotion_reason: 单篇论文提出但接口清楚，包含局部搜索邻居对全体 scalar subproblems 的即时改进检查、子问题局部最优状态维护、全体局部最优后统一扰动和外部 archive 输出，可直接改造二进制/离散多目标组合优化中的分解式 LS/ILS。
---

# 全子问题即时更新的嵌入式分解局部搜索

## 核心内容

在 decomposition-based 多目标组合优化中，不把每个 scalar subproblem 的局部搜索当作相互独立的黑盒。对当前子问题执行 local search 时，每探索到一个邻居解，就立即计算它对所有子问题的 scalar fitness 是否有改善；若改善，就立刻替换对应子问题的 incumbent，并把该子问题标记为“尚未确认局部最优”。当所有子问题都重新达到各自局部最优后，再对整个 decomposition population 执行 perturbation，作为 ILS 式软重启。

```text
decompose MOCOP into scalar subproblems
-> each subproblem owns incumbent x_i and local-optimal flag LO_i
-> choose a subproblem not locally optimal
-> scan neighbors of x_i
-> each neighbor x' is tested against all scalar subproblems
-> improve any x_j immediately and reset LO_j
-> when all LO_j are true
-> perturb every incumbent and restart local search cycle
-> external archive records all nondominated solutions
```

P2026-0272 的 EILS/D 是该模式的实例：二进制 1-flip LS 中每个邻居会检查全部权重子问题；所有子问题达到局部最优后，对全体解随机翻转 `r` 个 bit，再进入下一轮。

## 建立理由

- 为什么值得独立维护：
  - 普通 ILS/D 把 LS 作为单个子问题的 standalone optimizer，LS 内部发现的候选不能即时贡献给其它权重；
  - 被 LS 结果替换的邻近子问题未必已经局部最优，随后 perturb 会偏离 ILS “局部最优后扰动”的原则；
  - 该设计把 local search 的每次邻域探索变成 decomposition-wide 信息共享；
  - local-optimality flags 给出了一个清晰的状态接口，可迁移到 VNS、ALNS、tabu search 或 exact neighborhood；
  - 全体局部最优后统一 perturb 相当于在 Pareto local optimum set 上做软重启，anytime 表现强。
- 单篇具体方法的直接复用价值：
  - P2026-0272 给出 EILS/D Algorithm 2、IILS/D/CILS/D 对照、10 类算法比较、MNK/MUBQP 双数据集和参数分析。
- 与已有设计知识的区别：
  - 不同于“分解 ILS 的反馈扰动与档案协作”：该知识强调少量子问题、资源分配、PBI/EMA 扰动度和 archive matching；本知识强调 LS 内部每个邻居即时更新所有子问题，以及所有子问题局部最优后统一 perturb。
  - 不同于“结构启发初始化与多目标路径重联”：该知识沿两个精英解生成中间解；本知识在分解子问题内部组织局部搜索和扰动。
  - 不同于“多邻域多知识的分解式多任务迁移”：该知识是任务间知识迁移；本知识是单个 MOCOP 内不同 scalar subproblems 的即时协作。

## 解决的问题

- 适用场景：
  - 二进制、排列、路径、调度、特征选择、MUBQP 等可定义邻域的 MOCOP；
  - decomposition scalar subproblems 有意义；
  - 邻域评价能用增量或缓存快速计算；
  - 希望利用强单目标 LS，同时保持 Pareto archive 输出；
  - 需要更强 anytime performance。
- 现有方法为什么会失败或不足：
  - PLS 无显式 escape，容易停在 Pareto local optimum set；
  - standalone ILS/D 的 LS 过程对其它子问题“不可见”；
  - 普通邻域子问题替换只在 LS 结束后发生，错过 LS 中途的有用邻居；
  - perturbation 若作用于未局部最优 incumbent，会造成搜索效率损失；
  - 非协作或 non-elitist partial walk 可能高预算才追上。
- 仍需解决的问题：
  - 全子问题检查成本随 `mu` 和邻域规模增长；
  - many-objective 下 scalar subproblem 数量和 archive 规模可能过大；
  - 对强约束 MOCOP，邻居共享前需要 feasibility repair 或 constraint-aware scalarization；
  - 极端 PF 区域可能需要额外保护。

## 为什么可能有效

```text
one local move may be poor for current weight but good for another weight
-> test every explored neighbor against all subproblems
-> no useful move is wasted

replacement can invalidate local optimality
-> maintain LO flags
-> revisit subproblems after cross-subproblem improvements

ILS works best after local optimum is reached
-> wait until all subproblems are locally optimal
-> perturb whole local-optimum set
-> archive accumulates nondominated solutions found along the way
```

关键假设是：不同 scalar subproblems 的局部邻域有足够重叠，一个子问题 LS 探索到的邻居常常能改善其它子问题。如果权重子问题之间几乎无共享结构，或者邻域评价成本远高于收益，全子问题即时检查可能不划算。

## 实现接口

- 输入：
  - scalar subproblems / weight vectors `W={w_1,...,w_mu}`；
  - 每个子问题的 incumbent `x_i`；
  - 邻域生成器 `N(x)`；
  - scalarizing function `S(x|w_i)`；
  - perturbation operator；
  - external nondominated archive。
- 输出：
  - 更新后的 decomposition population；
  - non-dominated archive；
  - 每个子问题局部最优状态；
  - perturbation cycles 和 archive contribution 统计。
- 插入位置：
  - MOEA/D-like MOCOP solver 的 local search engine；
  - decomposition ILS/VNS/ALNS 的 inner loop；
  - 二进制/排列问题的 memetic search kernel；
  - archive-based anytime optimizer。
- 最小实现：

```text
initialize x_1,...,x_mu
LO[i] <- false for all i
archive <- nondominated(x_1,...,x_mu)

while budget remains:
    while exists i with LO[i] == false:
        choose such i
        LO[i] <- true
        for x_prime in N(x_i) by pivot rule:
            for j in 1..mu:
                if S(x_prime | w_j) improves S(x_j | w_j):
                    x_j <- x_prime
                    LO[j] <- false
                    archive <- update_archive(archive, x_prime)
        for each j != i:
            if x_j == x_i and x_i was fully checked for w_j:
                LO[j] <- true

    for i in 1..mu:
        x_i <- perturb(x_i)
        LO[i] <- false
        archive <- update_archive(archive, x_i)
```

## 如何用于算法创新

### 局部创新

- 将全子问题检查改为 adaptive subset：只检查邻近权重、最近有贡献的权重或 ROI 权重。
- 用增量评价缓存 `Delta S(move,w_j)`，避免每个邻居全量计算所有 scalar values。
- 对不同子问题使用不同 perturbation strength，由最近 `LO` 周期长度、archive contribution 或重复 basin 检测控制。
- 对 extreme weights 设置边界保护，避免中央区域强、极端区域弱。
- 将 first-improving 换为 candidate-list、best-improving、partial-neighborhood 或 learned move ordering。

### 结构创新

- 构建通用 embedded LS kernel：

```text
decomposition layer
-> shared neighborhood evaluator
-> immediate multi-subproblem replacement
-> local-optimality state manager
-> synchronized perturbation controller
-> external archive
```

- 与 ALNS/VNS 结合：每个 destroy/repair 或 neighborhood move 都即时检查多个子问题，而不是只返回一个权重下的局部最优。
- 与 tensorized/GPU 组合：把 `neighbors x subproblems` 的 scalar improvement 矩阵批量计算。
- 与 preference-based optimization 结合：只对偏好区域子问题做 immediate update，降低交互式优化成本。
- 与 exact neighborhood solver 组合：固定一组 moves 后，用 DP/MILP 批量产生候选，再统一更新多个子问题。

## 适用条件与风险

- 适用条件：
  - 邻域结构明确，邻居评价相对便宜；
  - scalarization 能为不同 PF 区域提供有意义的局部改进信号；
  - 子问题之间存在候选共享价值；
  - external archive 可维护非支配解；
  - 评价预算重视 anytime output。
- 不适用或可能失效的条件：
  - 邻域非常大且无法增量评价，全子问题检查过贵；
  - 目标维度高导致需要大量 subproblems；
  - 约束可行性极稀疏，普通邻域 move 多数不可行；
  - 子问题权重对应完全不同的 basin，交叉更新频繁破坏局部结构；
  - 只允许输出当前 population 而非 archive，WS 等 scalarization 可能覆盖不足。
- 计算与实现成本：
  - 每个邻居需检查 `mu` 个 scalar subproblems，朴素成本高；
  - 需要维护 `LO` 状态、重复解检测和 archive 更新；
  - external archive unbounded 时可能增长，需要去重和截断策略；
  - 同步 perturb 全体解可能造成评价峰值，可改成分批实现。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0272 | 作者指出 LS-based MO algorithms 容易困于 Pareto local optima，PLS/2PPLS/PPLS-D/DCDG-MOMA 缺少 escape mechanism | 问题动机 | Sec. I-A，PDF 2 |
| P2026-0272 | CILS/D 和 IILS/D 给出 standalone ILS/D；CILS/D 通过邻近子问题扰动起点和替换协作，IILS/D 为独立子问题基线 | 对照方法 | Sec. III-A，Algorithm 1，PDF 3 |
| P2026-0272 | EILS/D 说明 standalone LS 对邻近子问题 oblivious，且替换后不能保证子问题局部最优 | 问题分析 | Sec. III-B，PDF 4 |
| P2026-0272 | Algorithm 2 中 LS 探索到的 `x'` 对所有子问题 `j` 检查 scalar improvement，改善则立即替换并重置 `LO[j]` | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 4 |
| P2026-0272 | 全部子问题达到局部最优后，对所有 incumbent 同时 perturb 并重置 `LO` | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 4 |
| P2026-0272 | MNK 实验覆盖 72 个 landscapes，`M={2,3}`、`N={128,256,512}`、`K={2,4,6,8}`、`rho={-0.4,0,0.4}` | 实验设置 | Sec. IV-A，PDF 5 |
| P2026-0272 | 高预算结果显示 EILS/D、CILS/D、MOW-P 最有竞争力，IILS/D 差于协作版本，支持子问题协作价值 | 综合实验支持 | Sec. IV-B，Table I，PDF 5-6 |
| P2026-0272 | Anytime profiles 显示 EILS/D 超过所有对比算法，包括 CILS/D 和 MOW-P | anytime 支持 | Sec. IV-B，Fig. 1，PDF 5、7 |
| P2026-0272 | EAF 差异显示 EILS/D 在 PF 中央区域优于 MOW-P，且随 `K` 或 `N` 增大优势更明显 | 行为分析 | Sec. IV-B，Fig. 2，PDF 6-7 |
| P2026-0272 | Table II/Fig. 3 显示 WS scalarization 在所有 decomposition algorithms 上显著优于 CHB，尤其规模和目标数增加时 | 参数分析 | Sec. IV-C，Table II/Fig. 3，PDF 7-8 |
| P2026-0272 | perturbation study 显示过强/过弱都不好，`r=8` 在 landscapes 上较稳健，archive 新解随 perturb cycles 增加 | 参数分析 | Sec. IV-C，Figs. 4-5，PDF 8 |
| P2026-0272 | MUBQP 72 个配置中 EILS/D 几乎全胜；双目标仅 5 个实例被 2IaPLS 超过，三目标仅 3 个实例被超过 | 额外验证 | Sec. IV-D，Table III，PDF 9 |
| P2026-0272 | 作者未来工作包括 adaptive perturbation、fitness landscape analysis、推广到 permutation 和 real-world instances | 作者未来工作 | Sec. V，PDF 10 |

## 证据边界

- 当前只有单篇论文证据。
- 主验证集中在二进制 `rho`-MNK landscapes 和 MUBQP，排列/调度/路径等域仍需验证。
- EILS/D 的优势与 unbounded external archive 配合密切；有限 archive 或只看 population 时可能不同。
- WS 优于 CHB 的机制仍是作者假设，需要 landscape analysis。
- 表格 OCR 转写较乱，逐实例精确数值需回查 PDF。

## 待确认

- 全子问题 immediate update 是否应限制在邻域权重内以降低 `O(|N|*mu)` 成本；
- many-objective 下 `mu`、archive size 和 LO 状态管理如何扩展；
- 对约束 MOCOP 是否需要 feasibility-preserving neighborhood 或 repair before sharing；
- adaptive perturbation 应根据哪些 landscape signals 调节；
- 极端 PF 区域弱覆盖是否可通过 edge-weight subproblem 或 hybrid CHB/WS 解决。
