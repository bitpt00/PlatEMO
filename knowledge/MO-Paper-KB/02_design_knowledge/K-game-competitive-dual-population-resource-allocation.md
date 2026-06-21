---
knowledge_id: K-game-competitive-dual-population-resource-allocation
name: 博弈竞争驱动的双种群资源分配与辅助选择
type: architecture
status: active
source_papers: [P2026-0053, P2026-0131]
aliases: [DGCMOEA, AAPEA, dynamic game CMOEA, Cournot-inspired offspring allocation, adaptive auxiliary population size, competition-driven two-stage evolutionary algorithm, rank-based adversarial win-rate, spatial perturbation sensitivity, dual-population CMOEA, dynamic resource allocation, auxiliary environmental selection, CSO winner-loser update, feasibility-ratio stage switching, 博弈资源分配, 双种群约束优化, 辅助种群选择, 主辅种群 offspring 分配, 辅助种群规模自适应]
promotion_reason: 两篇论文共同支持双种群 CMOEA 中“辅助搜索资源必须随搜索状态动态调节”的模式：P2026-0053 给出主/辅双种群分工、rank-based win-rate、空间扰动敏感性、Cournot-inspired offspring allocation 和跨种群 DE 交互；P2026-0131 给出可行率触发两阶段、辅群规模按评价进度与主群拥挤状态自适应收缩、CSO 改造胜败双更新和真实工程验证。该知识可直接改造双种群约束多目标算法的辅助选择、资源控制和竞争搜索层。
---

# 博弈竞争驱动的双种群资源分配与辅助选择

## 核心内容

在双种群 CMOEA 中，不固定主种群和辅助种群的 offspring 预算。主种群负责可行收敛和 CPF exploitation，辅助种群负责 relaxed infeasible exploration。辅助种群环境选择用相对竞争 win-rate 降低极端不可行 outlier 的影响，再用空间扰动敏感性保留结构多样性贡献者。资源层把每个种群的质量成本和空间多样性合成竞争度，按 Cournot-inspired 公式动态分配下一代 offspring 数，并保留最小资源防止某个种群完全失活。

同一模式也可以用“辅助种群容量”而不是 offspring 配额来实现。P2026-0131 的 AAPEA 保持主种群固定大小，第一阶段让辅助种群忽略约束做全局探索，并用评价进度和主群 crowding-distance ratio 共同决定 `AuxSize`；主群可行率达到阈值后，辅助种群被撤除，评价资源集中到主群可行域精修。其竞争搜索算子还把经典 CSO 的 loser-only update 改成 winner/loser 同时更新：loser 学 winner 和随机个体，winner 学 elite 和随机个体。

```text
P1: CDP, feasible/CPF exploitation
P2: epsilon-relaxed auxiliary selection
    baseline fitness -> pairwise win-rate
    decision-space sensitivity -> structural diversity
    S_i = exp(win-rate) * log(1 + sensitivity)

resource allocation:
    Q_k = objective + constraint quality cost
    D_k = decision-space diversity
    eta_k = D_k / (Q_k + delta)
    alpha_1 = max(2 eta_1 - eta_2, 0)
    alpha_2 = max(2 eta_2 - eta_1, 0)
    split 2NP offspring between P1 and P2 with boundary protection
```

该知识的核心不是一般“双种群”或“约束松弛”，而是把辅助群的选择质量与主/辅群的 offspring 预算闭环联动：谁当前更有“低成本高多样性”的搜索优势，谁获得更多下一代生成资源。

## 建立理由

- 为什么值得独立维护：
  - 双种群 CMOEA 的关键风险是资源失衡：辅助群过强会在 infeasible space 空转，主群过强又会过早困在局部可行区；
  - 固定 `N1=N2` 或手工阶段切换无法响应当前搜索状态；
  - 只按绝对 CV/fitness 选辅助个体容易受尺度和极端不可行 outliers 影响；
  - P2026-0053 给出明确的 score、allocation 公式和消融证据，可作为通用资源控制层。
- 单篇具体方法的直接复用价值：
  - Algorithm 1-3 直接给出主/辅环境选择、跨群 DE 和 `N1,N2` 更新；
  - 42 个 benchmark、D=50/100/200 高维扩展、三类工程问题和四个消融 variants 支持完整机制。
  - P2026-0131 给出另一类资源接口：`AuxSize` 由 `feval/fmax` 与主群 `CDR` 控制，`F >= alpha` 时撤除辅群；Algorithm 1-3、37 个 benchmark、三类工程问题和两个消融 variants 支持其有效性。
- 与已有设计知识的区别：
  - 不同于“约束难度加权的多辅助种群资源分配与合并”：该知识按多个 constraint-specific auxiliary populations 分配资源；本知识按主/辅功能种群的竞争度分配 offspring。
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识用 alpha/beta 松弛边界和变量分组；本知识用 win-rate + spatial sensitivity 做辅助选择，并用 game allocation 调节主/辅预算。
  - 不同于“双空间分层自适应资源分配”：该知识按目标空间区域和变量组分配评价预算；本知识按 dual-population search role 分配 offspring 数。
  - 不同于“状态驱动的 DRL 演化算子选择”：本知识不训练策略网络，而是显式计算竞争度。

## 解决的问题

- 适用场景：
  - CMOP 有可行域狭窄、断裂或 UPF/CPF 分离；
  - 主/辅双种群可以共享 offspring 或跨群取差分向量；
  - 需要同时利用 feasible exploitation 和 infeasible exploration；
  - 固定辅助资源比例会导致早期探索不足或后期不可行空转；
  - 希望资源分配规则无需额外训练模型。
- 现有方法为什么会失败或不足：
  - 主/辅群等资源时，某一方可能在当前阶段低效但仍消耗大量评价；
  - 辅助群只按 relaxed CV 或 objective 排序，容易丢失结构多样性；
  - 绝对 fitness 差值在 severe constraint violation 下不稳；
  - 辅助群长期保留不可行多样性，可能饿死主群；
  - 仅靠阶段切换无法处理不同问题、不同阶段的资源需求差异。
- 仍需解决的问题：
  - 如何识别“高 diversity 但无效”的不可行游走；
  - 如何在无可行解或主群停滞时强制资源回流；
  - `D/Q` 型竞争度是否应加入 feasible ratio、constraint progress 或 archive contribution；
  - 空间扰动敏感性在高维强耦合问题中是否仍有稳定意义。

## 为什么可能有效

```text
P1 gives feasible convergence pressure
P2 preserves relaxed infeasible information and diversity
-> cross-population DE transfers useful variation

auxiliary selection uses ranks rather than magnitudes
-> robust to extreme constraint outliers

spatial sensitivity rewards structural influence
-> prevents auxiliary population from collapsing

resource allocation uses eta = diversity / quality_cost
-> more budget goes to currently useful search role
-> boundary protection keeps both roles alive
```

关键假设是：`Q` 能反映种群的 convergence/feasibility 成本，`D` 能反映继续探索的潜力，且二者的比值能预测下一阶段 offspring 的边际收益。P2026-0053 的 CF8/CF10 失败说明该假设在极窄、孤立、欺骗性可行域中会失效。

## 实现接口

- 输入：
  - 主种群 `P1`、辅助种群 `P2`；
  - objective matrix、constraint violation matrix、decision matrix；
  - epsilon relaxation schedule；
  - 主/辅 DE 或其它可跨群生成 offspring 的算子；
  - population size `NP`、总评价预算。
- 输出：
  - 更新后的主种群 `P1`；
  - 更新后的辅助种群 `P2`；
  - 下一代 offspring counts `N1,N2`，或辅助种群容量 `AuxSize`；
  - 可选日志：`Q1,Q2,D1,D2,eta1,eta2,N1,N2`、`AuxSize`、可行率、主群停滞轮数。
- 插入位置：
  - 双种群 CMOEA 的环境选择层；
  - 辅助种群 selection scoring；
  - 主/辅 offspring 预算控制器；
  - 跨种群 DE/PSO/GA 繁殖模块。
- 最小实现：

```text
initialize P1
P2 <- P1
N1 <- NP
N2 <- NP

while budget remains:
    O1 <- exploitation_operator(P1, P2, N1)
    O2 <- exploration_operator(P1, P2, N2)
    O <- O1 union O2

    P1 <- CDP_select(P1 union O, NP)
    P2 <- auxiliary_select_by_winrate_sensitivity(P2 union O, NP, epsilon_t)

    for k in {P1, P2}:
        Q_k <- quality_cost(objectives, constraints)
        D_k <- mean_pairwise_distance(decisions)
        eta_k <- D_k / (Q_k + delta)

    N1, N2 <- cournot_split(eta_1, eta_2, total=2*NP, min_each=1)

return feasible nondominated solutions from P1
```

- P2026-0053 的默认实例：
  - `P1` 环境选择使用 CDP；
  - `P2` 环境选择使用 normalized objectives、epsilon-relaxed constraints、`v_i`、`w_i`、`rho_i` 和 `S_i`；
  - `O1` 用 `DE/current/best/1`，`O2` 用 `DE/rand/1`；
  - `F` 从 `{0.6,0.8,1.0}` 中随机取，`CR` 从 `{0.1,0.2,1.0}` 中随机取；
  - `N1,N2` 每代按 Cournot-inspired 公式重新分配。

- P2026-0131 的默认实例：
  - `P1` 固定为 `N`，使用 CDP 环境选择 ES1；
  - `P2` 第一阶段使用无约束非支配排序 ES2，并按 `AuxSize` 截断；
  - `AuxSize` 由评价进度和主群 `CDR=CDavg/CDmax` 共同控制，随后用 `MinSize/MaxSize` 保护；
  - `F < alpha` 时主辅协同，`F >= alpha` 时撤除 `P2`，本文 `alpha=0.05`；
  - `O2` 由 CSO 改造竞争算子产生，winner 和 loser 均更新并经 polynomial mutation。

## 如何用于算法创新

### 局部创新

- 给 `eta` 加可行性修正：`eta = D * progress / (Q + delta)`，其中 progress 可用 CV下降、可行率提升或主群 archive 贡献。
- 增加主群保护：若 `P1` 连续若干代无可行解或无 HV/IGD 改善，则强制 `N1 >= rho_min * 2NP`。
- 把 `rho_i` 替换为 objective niche contribution、reference-vector vacancy、SDE contribution 或 decision-space novelty。
- 用 softmax temperature 分配 `N1,N2`，避免 `max(2eta1-eta2,0)` 过硬导致震荡。
- 记录每类 offspring 的 survival rate，反馈修正 `eta`，避免只看父代状态。
- 将固定 `AuxSize` 或线性缩减替换为 `feval + diversity + feasibility progress` 的状态控制器。
- 将经典 CSO 的 loser-only update 改成 winner/loser 双更新，但给 winner 更新加 elite-preservation 或 rollback 防止破坏优质结构。

### 结构创新

- 构建带 watchdog 的双种群 CMOP 控制器：

```text
normal mode:
    Cournot allocation by eta

feasibility emergency mode:
    if no feasible solution for K generations:
        override N1 high
        tighten epsilon
        reduce diversity-only reward

recovery mode:
    after feasible front restored:
        gradually release resources to P2
```

- 扩展到三种群：主群、边界不可行群、全局探索群三方竞争资源。
- 与多约束 CWA 组合：先在主/辅群之间分配总预算，再在辅助群内部按 constraint difficulty 分配子预算。
- 与代理辅助 CMOP 组合：用 surrogate 低成本估算 `Q/D/eta`，真实评价只给高价值 offspring。
- 与动态 CMOP 组合：环境变化后重置 `epsilon_0` 和 `eta`，短期增加辅助探索，随后回流主群。
- 组合 P2026-0053 与 P2026-0131：先用 `AuxSize` 控制辅助群容量，再用 `eta` 或 survival rate 控制主/辅 offspring 预算；当 `F` 稳定后冻结或撤除辅助群。

## 适用条件与风险

- 适用条件：
  - 可计算 objective values、constraint violations 和 decision-space distances；
  - 主/辅群的角色清晰，一个偏 feasible exploitation，一个偏 infeasible exploration；
  - 评价预算允许维护两个种群并计算 pairwise distance；
  - infeasible region 中确实包含有用过渡信息；
  - 希望 resource allocation 是显式可解释公式。
- 不适用或可能失效的条件：
  - 可行域极窄且不可行区域高度欺骗，多样性本身不代表有用性；
  - 决策空间距离与目标/约束结构弱相关；
  - 变量维度极高且距离集中，`rho_i` 和 `D` 区分度下降；
  - 约束噪声大，`Q` 和 win-rate 不稳定；
  - mixed/discrete 编码下 DE 和欧氏距离不合适。
- 计算与实现成本：
  - 每代需要 pairwise comparison 和 pairwise distance，复杂度含 `O(N^2(M+D))`；
  - 需要维护两套环境选择和动态 `N1,N2`；
  - 若目标/约束评价昂贵，额外选择成本相对小；若评价极便宜，pairwise 成本可能明显。
- 决策风险：
  - 论文使用 “Cournot-inspired” heuristic，并非严格均衡求解；
  - `S_i` 和 `eta` 的尺度耦合会影响选择压力；
  - `AuxSize` 若只由 crowding distance 驱动，可能误判“分散但远离 CPF”的主群为无需辅助；
  - 消融显示完整机制有效，但不同组件之间强耦合，不能把收益单独归因于某一个公式；
  - CF8/CF10 失败说明必须给资源控制层加停滞检测和可行性保护。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0053 | DGCMOEA 使用 `P1` 和 `P2` 双种群，`P1` 用 CDP，`P2` 用辅助环境选择，`N1,N2` 每代由 Algorithm 3 更新 | 框架设计 | Sec. 3.1、Algorithm 1，PDF 8-9 |
| P2026-0053 | 辅助选择先归一化目标/约束，并用 epsilon relaxation 构造 baseline fitness `v_i` | 辅助选择 | Sec. 3.2、Eq. (5)-(8)，PDF 9-10 |
| P2026-0053 | Pairwise win-rate `P(i≻j)=1/(1+exp(sgn(v_i-v_j)))`，用三值比较降低极端 outlier 影响 | 作者提出的方法 | Sec. 3.2、Eq. (9)-(11)，PDF 10 |
| P2026-0053 | 空间扰动敏感性 `rho_i` 由决策空间归一化方向和构造，衡量结构贡献 | 作者提出的方法 | Sec. 3.2、Eq. (12)，PDF 10 |
| P2026-0053 | 辅助最终得分 `S_i=exp(w_i)*ln(1+rho_i)`，选择 top `NP` | 作者提出的方法 | Sec. 3.2、Eq. (13)、Algorithm 2，PDF 10-11 |
| P2026-0053 | 资源分配中 `lambda=sigma(F)/(sigma(C)+delta)`，`Q=mean(sumF+lambda sumC)`，`D` 为平均 pairwise distance | 资源状态估计 | Sec. 3.3、Eq. (14)-(16)，PDF 11-12 |
| P2026-0053 | 竞争度 `eta=D/(Q+delta)`，`alpha1=max(2eta1-eta2,0)`，`alpha2=max(2eta2-eta1,0)`，按 `2NP` 分配 `N1,N2` | 资源分配公式 | Sec. 3.3、Eq. (17)-(19)、Algorithm 3，PDF 12-13 |
| P2026-0053 | 主群 `DE/current/best/1` 与辅群 `DE/rand/1` 都跨种群取向量，形成信息交互 | 子代生成 | Sec. 3.4，PDF 13 |
| P2026-0053 | 42 个 benchmark、30 次运行、`MaxFES=100000`、`NP=100`，对 7 个 CMOEA baseline 比较 | 实验设置 | Sec. 4，PDF 14-15 |
| P2026-0053 | DAS-CMOP 上 DGCMOEA 保持 100% feasible solution ratio，并在多数函数上优于 baseline | Benchmark 支持 | Sec. 5.2、Table 2，PDF 16 |
| P2026-0053 | D=50/100/200 扩展中，DGCMOEA 在大多数实例上仍显著优于七个 baseline | 高维支持 | Sec. 5.5、Table 3，PDF 15-16 |
| P2026-0053 | Table 4 显示 DGCMOEA 在所有测试套件和维度上平均运行时间最小 | 效率证据 | Sec. 5.5、Table 4，PDF 15-16 |
| P2026-0053 | 工程问题中 DGCMOEA 在 Spring Design 的 IGD 显著优于全部 baseline，且三类工程问题保持 100% feasible solution rate | 工程支持 | Sec. 5.8、Tables 5-6，PDF 25-27 |
| P2026-0053 | 消融中完整 DGCMOEA 显著优于替换辅助选择、固定资源和移除跨群交互的四个 variants | 消融证据 | Sec. 5.10、Tables 9-10，PDF 27-28 |
| P2026-0053 | CF8/CF10 全部运行 FSR 为 0，作者解释为辅助群过度追 infeasible diversity 并饿死主群 | 失败边界 | Sec. 5.11，PDF 28-29 |
| P2026-0131 | AAPEA 第一阶段 `P1` 用 CDP，`P2` 忽略约束并通过交叉候选池与主群共享 offspring；`F >= alpha` 后撤除 `P2` | 框架设计 | Sec. 3.1、Algorithm 1，PDF 6 |
| P2026-0131 | `AuxSize` 由评价进度 `feval/fmax` 与主群 crowding-distance ratio `CDR` 共同控制，`CDR` 小则辅群收缩更慢 | 作者提出的方法 | Sec. 3.2、Eq. (4)-(5)、Algorithm 2，PDF 7 |
| P2026-0131 | Competition-driven search operator 配对产生 winner/loser，loser 学 winner/random，winner 学 elite/random，区别于经典 CSO 只更新 loser | 作者提出/改造方法 | Sec. 3.3、Algorithm 3、Eq. (6)-(9)，PDF 7 |
| P2026-0131 | ES1 始终使用 CDP，ES2 在第一阶段使用无约束非支配排序；阶段切换由主群可行率 `F` 决定，本文 `alpha=0.05` | 环境选择设计 | Sec. 3.1、3.4，PDF 6、8 |
| P2026-0131 | DAS-CMOP、MW、LIR-CMOP 三套 benchmark，30 次运行，AAPEA 在 Friedman IGD/HV 排名中总体第一 | 综合实验支持 | Sec. 4.2，Fig. 3-4，PDF 8-10 |
| P2026-0131 | MW suite 中 AAPEA 在 HV 上 9 个 best results、IGD 上 7 个 best results，显示覆盖和均匀性优势 | Benchmark 支持 | Sec. 4.2.2，Tables 3-4，PDF 10-13 |
| P2026-0131 | 三个真实工程问题 speed reducer、bulk carriers、reactor network 上 AAPEA 的 HV 均为最优 | 工程支持 | Sec. 4.2.4，Table 8，PDF 15 |
| P2026-0131 | 消融中移除竞争算子的 AAPEA-I 和固定辅群大小的 AAPEA-II 各自仅 9 个 benchmark 最优，完整 AAPEA 为 19 个最优 | 消融证据 | Sec. 4.3，Table 9，PDF 15-16 |
| P2026-0131 | 运行时间排名中 AAPEA 位于中间，与 IMTCMO、EMCMMS 类似，快于 CMOES、PPS、CMOEMT、C-TAEA 但慢于 CMOEA-MS/BiCo | 效率边界 | Sec. 4.4，Fig. 11，PDF 16-17 |
| P2026-0131 | 作者指出问题规模或约束结构复杂度增加会提高计算开销，参数设置和更复杂真实场景仍需进一步研究 | 作者局限/未来工作 | Sec. 5，PDF 18 |

## 证据边界

- 当前有两篇论文证据，但都来自连续变量 CMOP/工程问题，离散、混合变量和昂贵评价场景仍需验证。
- 论文为 Journal Pre-proof，最终版本可能有格式和局部表述变化。
- “dynamic game / Cournot”是启发式公式，不是严格博弈均衡理论证明。
- CF8/CF10 上完全失败，说明该资源分配在极窄欺骗可行域中有结构性风险。
- `rho_i` 和 `D` 都基于决策空间欧氏距离，高维、混合变量和离散编码场景可能失真。
- 工程问题只有三类，且 Speed Reducer 上 DGCMOEA 不全面占优。
- 消融验证完整机制有效，但无法完全分离 win-rate、spatial sensitivity、cross-population DE 和 dynamic allocation 的独立贡献。
- P2026-0131 的 `alpha=0.05` 和 elite ratio 0.1 为固定参数；论文未系统展示阶段切换阈值、`MinSize/MaxSize` 或 `CDR` 公式变体的敏感性。
- P2026-0131 的消融主要报告 HV，组件对 IGD、可行率和阶段切换时机的影响还不充分。

## 待确认

- 如何自动检测 infeasible diversity 是否无效；
- 主群长期无可行解时，资源 override 的阈值和强度如何设定；
- `eta=D/Q` 是否需要加入 feasible ratio、CV improvement 和 offspring survival；
- `AuxSize` 是否应加入 feasibility progress、CV 下降率、offspring survival 或 CPF 覆盖率；
- 空间扰动敏感性在高维距离集中时是否需要降维或参考向量替代；
- 该机制在离散、混合变量、昂贵评价和动态约束问题中的稳定性如何。
