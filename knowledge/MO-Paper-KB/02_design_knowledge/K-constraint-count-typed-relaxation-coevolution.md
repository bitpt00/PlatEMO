---
knowledge_id: K-constraint-count-typed-relaxation-coevolution
name: 约束数量分型的松弛协同进化
type: architecture
status: active
source_papers: [P2026-0121]
aliases: [MCHEA, multitype constraint handling evolutionary algorithm, WCPC, CPC, SCPC, constraint-count typed CMOEA, sparse constrained population, random constraint relaxation, P1 P2 P3 coevolution, 约束数量分型, 稀疏约束种群, 随机约束松弛, 三种群约束协同]
promotion_reason: 单篇论文提出但流程完整，包含按约束数量划分 WCMOP/MCMOP/SCMOP、P1 无约束探索、P2 单/多约束随机松弛、P3 全约束收敛、CV 变异系数驱动 epsilon relaxation、Algorithm 1-4、57 个 benchmark、9 个对比算法、Wilcoxon 和消融证据，可直接改造 CMOEA 的约束处理架构层。
---

# 约束数量分型的松弛协同进化

## 核心内容

在 constrained MOO 中，不把所有约束问题都交给同一个固定双种群、固定 epsilon 或固定辅助任务。先根据约束数量或更一般的约束状态选择搜索结构：弱约束只启用无约束探索种群和全约束种群；中等约束增加一个只考虑单个约束的稀疏约束松弛种群；强约束则让稀疏约束种群随机保留多个约束，避免单约束辅助丢失过多约束信息。每个种群在同一批 offspring 上按不同约束视角环境选择，形成 UPF、CPF 与二者之间区域的协同搜索。

```text
estimate constraint type

if weak:
    P1: unconstrained search toward UPF / infeasible crossings
    P3: fully constrained search toward CPF

if moderate:
    P1: unconstrained search
    P2: randomly select one constraint, epsilon-relaxed selection
    P3: full CV-constrained selection

if strong:
    P1: unconstrained search
    P2: randomly select a subset of constraints, epsilon-relaxed selection
    P3: full CV-constrained selection
```

P2026-0121 的 MCHEA 用 constraint number 作为最小可实现判据：`n=1` 为 WCPC，`n=2` 为 CPC，`n>2` 为 SCPC；`P2` 的 epsilon relaxation 由 constraint violation 的 coefficient of variation `gamma` 动态调节。

## 建立理由

- 为什么值得独立维护：
  - CMOEA 中常见问题不是“是否利用不可行解”，而是不同约束强度下应该用什么粒度的不可行辅助；
  - 固定无约束辅助可能在强约束下丢失约束信息，固定全约束处理又会在弱/中等约束下过早收缩；
  - 约束数量分型提供了一个低成本、可替换的 constraint-state scheduler 原型。
- 单篇具体方法的直接复用价值：
  - P2026-0121 给出 MCHEA 的 Algorithm 1-4、WCPC/CPC/SCPC 三个子流程、epsilon relaxation、57 个测试问题、9 个 CMOEA 对比、Wilcoxon 和五组消融。
- 与已有设计知识的区别：
  - 不同于“EID 动态约束优先级与协作子代生成”：该知识排序并阶段性处理具体约束；本知识先按约束数量/强度决定启用哪些 population roles。
  - 不同于“相关性排序的自适应辅助问题约束处理”：该知识用约束-目标时间序列相关更新一个辅助问题；本知识用 P1/P2/P3 三类种群同时协同，`P2` 作为 CPF-UPF 中间层。
  - 不同于“约束难度加权的多辅助种群资源分配与合并”：该知识为多个 constraint-specific auxiliary populations 分配资源并合并相似约束；本知识只维护一个 sparse constrained population，并通过单/多约束随机松弛适配 constraint count。
  - 不同于“约束违反状态驱动的代理搜索模式切换”：该知识面向昂贵优化和 surrogate 模式切换；本知识不依赖代理模型，作用于普通 CMOEA 的种群架构。

## 解决的问题

- 适用场景：
  - CMOP 中约束数量或约束强度差异明显；
  - CPF 与 UPF 之间存在可利用的不可行桥接区域；
  - 可单独计算每个约束的 violation；
  - 算法能维护多个 population，并允许同一 offspring 被不同环境选择规则复用；
  - 需要在弱约束的低开销探索、中等约束的局部松弛和强约束的信息保留之间切换。
- 现有方法为什么会失败或不足：
  - 只用全约束 CDP/CV 选择，容易陷入局部可行域；
  - 只追 UPF 的辅助种群在 CPF 远离 UPF 时会误导或浪费；
  - 只考虑单个约束的辅助在强约束中会丢失大量约束信息；
  - 同时处理全部约束会使辅助问题退化为原问题，失去穿越不可行区域的能力；
  - 固定辅助结构很难同时适配 `n=1`、`n=2` 和多约束强约束问题。
- 仍需解决的问题：
  - 约束数量不一定等于约束困难度；
  - 随机约束子集选择可能浪费预算；
  - epsilon relaxation 参数需要更自适应；
  - 多种群共享 offspring 的贡献需要在线度量。

## 为什么可能有效

```text
weak constraints:
    P3 can usually maintain feasibility
    P1 supplies diversity and infeasible crossing information

moderate constraints:
    one-constraint P2 searches between UPF and CPF
    epsilon keeps useful infeasible solutions without fully ignoring constraints

strong constraints:
    single-constraint P2 loses too much information
    random multi-constraint P2 preserves partial feasibility structure

P1, P2, P3 receive the same offspring
-> each population keeps candidates useful under its own constraint lens
-> P3 obtains more routes to CPF without abandoning feasibility
```

关键假设是：UPF、CPF 和部分松弛前沿之间存在有用的信息传递；并且 `P2` 的随机约束子集能以足够概率覆盖关键约束组合。如果 CPF 与 UPF 完全无关，或少数隐藏约束决定全部可行性，随机松弛可能低效。

## 实现接口

- 输入：
  - 初始种群规模 `N`；
  - 每个候选的 objective values；
  - per-constraint violation values 和 total `CV`；
  - constraint count 或更丰富的 constraint-state estimator；
  - epsilon 更新参数与可行率统计。
- 输出：
  - 更新后的 `P1`、`P2`、`P3`；
  - 最终 CPF 近似，通常输出 `P3`；
  - 可选日志：constraint type、`P2` 选择的约束子集、`gamma`、epsilon、各 population offspring survival。
- 插入位置：
  - CMOEA 的 population architecture 层；
  - constraint handling technique selector；
  - infeasible-assisted auxiliary population；
  - 多种群 CMOEA 的 offspring sharing 与环境选择阶段。
- P2026-0121 的最小实例：

```text
P1 <- random initial population
n <- number of constraints

if n == 1:
    P3 <- random initial population
    while not stop:
        Off <- variation(tournament(P1 fitness union P3 fitness))
        P1 <- environmental_selection(P1 union Off, unconstrained)
        P3 <- environmental_selection(P3 union Off, full CV)

if n == 2:
    P2, P3 <- random initial populations
    while not stop:
        r1 <- randomly select one constraint
        gamma <- coefficient_of_variation(CV)
        epsilon <- update_epsilon(gamma, feasible_ratio)
        Off <- variation(tournament(P1/P2/P3 fitness))
        P1 <- select(P1 union Off, unconstrained)
        P2 <- select(P2 union Off, epsilon on r1)
        P3 <- select(P3 union Off, full CV)

if n > 2:
    P2, P3 <- random initial populations
    while not stop:
        r2 <- randomly select number and subset of constraints
        gamma <- coefficient_of_variation(CV)
        epsilon <- update_epsilon(gamma, feasible_ratio)
        Off <- variation(tournament(P1/P2/P3 fitness))
        P1 <- select(P1 union Off, unconstrained)
        P2 <- select(P2 union Off, epsilon on selected constraints)
        P3 <- select(P3 union Off, full CV)
```

## 如何用于算法创新

### 局部创新

- 用 feasible ratio、mean/max CV、CV variance、active-constraint count、repair success rate 替换简单 `n=1/2/>2` 分型。
- 把 `P2` 的随机约束子集改为 EID 排序、CWA 难度权重、约束-目标相关、constraint similarity grouping 或 bandit selection。
- 为 `P2` 设置资源配额：弱约束低配额，强约束高配额，贡献低时休眠。
- 用 `P2` offspring survival 或进入 `P3` 的贡献来在线调整 epsilon。
- 为不同约束子集维护短期 mini-archives，避免每代完全随机导致记忆丢失。

### 结构创新

- 构建约束状态驱动的多种群 CMOEA：

```text
constraint state estimator
-> population role activator
-> P1/P2/P3 offspring sharing
-> epsilon and subset-size controller
-> contribution feedback
-> CPF archive
```

- 与 EID 结合：EID 决定 `P2` 当前优先松弛或保留哪些约束，MCHEA 负责 population role 分型。
- 与约束难度资源分配结合：多个 `P2` 子群按 constraint subset 难度分配 offspring。
- 与代理辅助 CMOP 结合：评价昂贵时，只对最可能进入 `P3` 的 `P2` 候选做真实评价。
- 与动态 CMOP 结合：环境变化后重估 constraint state，临时增强 `P1/P2` 探索，再逐渐回到 `P3`。

## 适用条件与风险

- 适用条件：
  - 约束可分解并可单独计算 violation；
  - 不可行区域含有可通向 CPF 的有用搜索路径；
  - 种群规模和评价预算足以维护至少两到三个 population roles；
  - 普通全约束搜索容易停滞，普通无约束辅助又会偏离 CPF；
  - 需要低成本的约束结构选择器。
- 不适用或可能失效的条件：
  - constraint count 与真实可行难度无关；
  - 单个隐藏硬约束决定可行性，随机松弛会反复忽略关键约束；
  - UPF 与 CPF 完全分离且无可用桥接路径；
  - 约束不可单独评价，只能返回总可行/不可行黑箱；
  - 离散/组合问题中随机 offspring 很难通过 `P2` 松弛转化为可行解。
- 计算与实现成本：
  - WCPC 维护两种群，CPC/SCPC 维护三种群；
  - 每代需要多个环境选择与 fitness 计算；
  - 作者给出的总复杂度为 `O(N^3)`，主要来自环境选择的截断方法；
  - 相比单种群 CMOEA，日志、调参和消融成本更高。
- 解释风险：
  - MCHEA 的优势来自三种群协同、epsilon relaxation、约束分型和基础算子的共同作用；
  - HV 相对 CMOOSEMCMO 未达到显著差异，说明不是所有质量维度都稳定压倒对比方法；
  - 消融显示局部变体在少数问题上可能更好，完整框架是稳健折中而非逐实例最优。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0121 | 作者提出 MCHEA，并按约束数量把 CMOP 分为 weak、moderate、strong 三类 | 作者提出的方法 | Abstract，Introduction，PDF 1-2 |
| P2026-0121 | Algorithm 1 根据 `n==1`、`n==2`、`n>2` 初始化不同 population 并调用 WCPC/CPC/SCPC | 作者提出的框架 | Sec. 3，Algorithm 1，PDF 4 |
| P2026-0121 | WCPC 中 `P1` 为 unconstrained population，`P3` 为 constrained population，`P1` 穿越不可行区域帮助 `P3` 找到更多可行区域 | 作者提出的方法 | Sec. 3.1，Algorithm 2，PDF 4-5 |
| P2026-0121 | CPC 在 `n=2` 时构造 sparse constrained population `P2`，随机选择一个约束并用 epsilon relaxation 保留部分不可行解 | 作者提出的方法 | Sec. 3.2，Algorithm 3，PDF 5-6 |
| P2026-0121 | 作者解释 CPC 随机选择单约束可以避免固定松弛的偏置，且 epsilon 由 `gamma` 控制以限制不可靠探索 | 机制说明 | Sec. 3.2，PDF 5-6 |
| P2026-0121 | SCPC 在 `n>2` 时让 `P2` 随机选择多个约束，避免只考虑一个约束造成信息损失 | 作者提出的方法 | Sec. 3.3，Algorithm 4，PDF 6 |
| P2026-0121 | MCHEA 总计算复杂度为 `O(N^3)` | 成本证据 | Sec. 3.4，PDF 6 |
| P2026-0121 | 实验使用 MW、DTLZ、LIRCMOP 和 17 个 real-world problems，共 57 个问题，并按 TYPE-I/II/III 列出约束数 | 实验设置 | Sec. 4.1，Table 1，PDF 7 |
| P2026-0121 | 对比 9 个 CMOEA，`FEs=100000`、`N=100`、30 次运行，指标为 HV 和 IGD | 实验设置 | Sec. 4.1，PDF 7 |
| P2026-0121 | Wilcoxon Table 4 中 HV 相对 8 个算法显著更好，只有相对 CMOOSEMCMO 不显著；IGD 相对 9 个算法均显著更好 | 统计证据 | Sec. 4.4，Table 4，PDF 12 |
| P2026-0121 | 收敛曲线显示 MCHEA 在多组 TYPE-I/II/III 问题上持续收敛，并在 MW5、MW10 等复杂约束问题中早期收敛快 | 机制证据 | Sec. 4.5，Figs. 8-9，PDF 10、12 |
| P2026-0121 | 分布图显示 MCHEA 在 MW8、DC1_DTLZ1、LIRCMOP14、MW13、RWMOP25 等问题上分布更均匀或 CPF 捕捉更完整 | 可视化证据 | Sec. 4.5，Fig. 10，PDF 12-13 |
| P2026-0121 | 消融显示无约束种群增强探索但缺 feasibility control，全约束种群增强收敛但降低多样性，constraint-aware relaxation 可逃离局部但过度使用会不稳定 | 消融解释 | Sec. 4.6，Tables A.1-A.5，PDF 12-16 |
| P2026-0121 | 作者指出完全未知 black-box 目标/约束时，识别约束类别困难，需要额外 learning 或 problem characterization | 作者局限与未来工作 | Sec. 5，PDF 16 |

## 证据边界

- 当前只有单篇论文证据。
- 约束强弱以数量粗分，未直接衡量约束活跃度、可行域体积、修复难度或目标贡献。
- `P2` 约束子集随机选择，未和 EID、CWA、相关性排序等更精细 constraint scheduler 直接比较。
- HV 相对 CMOOSEMCMO 不显著，强约束和 LIRCMOP 部分问题上其他算法可更强。
- 实验主要覆盖连续 benchmark 和 RWMOP benchmark，离散、混合变量、昂贵评价、动态约束和噪声约束尚无直接证据。
- 消融说明各组件互补，但不能精确分解三种群、epsilon、随机约束选择和基础算子各自贡献。

## 待确认

- 如何用更细的 constraint-state estimator 替代简单 constraint count；
- `P2` 的约束子集大小与选择概率如何自适应；
- `gamma` 是否应结合 feasible ratio、CV decrease rate、offspring survival 和 archive contribution；
- 多个 `P2` 子群是否比单个随机 `P2` 更稳定；
- 在组合优化、动态约束和完全黑箱约束中如何实现可行修复与约束类型识别。
