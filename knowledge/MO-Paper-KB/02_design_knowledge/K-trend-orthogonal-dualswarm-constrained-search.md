---
knowledge_id: K-trend-orthogonal-dualswarm-constrained-search
name: 趋势-正交互补的双群约束搜索
type: architecture
status: active
source_papers: [P2026-0275]
aliases: [DSOCOL, collaborative orthogonal learning, COL, trend learning, orthogonal learning, niche-guided subset selection, NGSS, dual-swarm constrained optimizer, direction-guided CMOEA, 趋势学习, 正交学习, 双群约束优化, 互补子空间搜索, niche容量选择]
promotion_reason: 单篇论文提出但机制完整，包含约束松弛主群、CDP 辅群、niche 内 winner-loser/边界趋势学习、主趋势正交补搜索、三层 niche-guided subset selection、标准/大规模/欺骗约束/真实 CMOP 实验和多组件消融，可直接改造双种群 CMOEA、CSO/PSO 子代生成和复杂可行域搜索。
---

# 趋势-正交互补的双群约束搜索

## 核心内容

在复杂 CMOP 中，不只让多个种群交换优秀解坐标，而是让一个主群学习“向 CPF 收敛的趋势方向”，再让辅助群沿该趋势的正交补方向搜索互补子空间。主群负责跨越不可行障碍和快速逼近 CPF，辅群负责减少重复搜索并扩展 CPF 分布；环境选择上，主群使用较强收敛/可行性选择，辅群使用 niche 容量控制来补充目标空间稀疏区域。

```text
main swarm S1:
    relaxed constraint evaluation
    select winner/loser representatives in each niche
    trend = local winner-loser vector + global boundary-to-winner vector
    generate trend offspring

auxiliary swarm S2:
    feasible/CDP pressure
    receive trend from S1
    choose feasible or low-CV anchor in same niche
    generate offspring along orthogonal complement of trend

selection:
    S1 <- convergence-oriented environmental selection
    S2 <- niche-guided subset selection with local capacity and sparse-niche filling
```

## 建立理由

- 为什么值得独立维护：
  - 多种群 CMOEA 常把知识传递理解为 solution transfer，但复杂约束景观中“如何移动”比“复制哪里”更有价值；
  - 趋势方向和正交补方向提供了一个清晰的 convergence-diversity 几何分工；
  - 该机制可插入 CSO/PSO/DE/MOEA 的子代生成层，不依赖显式 auxiliary task 重构；
  - NGSS 提供了对离散/断裂 CPF 的目标空间容量控制接口。
- 单篇具体方法的直接复用价值：
  - P2026-0275 给出 DSOCOL Algorithm 1-5、趋势/正交学习解释、NGSS 三层选择、复杂度、33 benchmark、大规模扩展、FCP 欺骗约束、10 个真实应用和五组消融。
- 与已有设计知识的区别：
  - 不同于“支配-分解双框架协同与阶段切换”：该知识维护 dominance/decomposition 两个完整框架并做 UPF-to-CPF stage switching；本知识维护两个 competitive swarms，并共享趋势方向及其正交补。
  - 不同于“参考子区约束学习与高斯胜者进化”：该知识用参考子区控制 winner/loser 学习和高斯 winner 更新；本知识的主导信息是跨群 trend transfer 和 orthogonal exploration。
  - 不同于“目标分解的高斯演化方向学习”：该知识长期学习目标级概率方向模型；本知识在每个 niche 即时构造几何趋势和正交补。
  - 不同于“自适应子区多方向竞争更新”：该知识围绕子区代表做多方向探索；本知识用约束主群的收敛趋势定义辅群互补方向。

## 解决的问题

- 适用场景：
  - CMOP 存在大不可行区域、狭窄可行域、局部可行陷阱、离散或断裂 CPF；
  - 既需要穿越 infeasible barriers，又需要在 CPF 多个片段上保持均匀分布；
  - 多种群或多任务算法只交换坐标，容易产生冗余探索；
  - CSO/PSO/DE 等 reproduction 过随机，缺少可复用方向知识；
  - 目标数较低或中等，niche/weight-vector 划分仍能表达分布区域。
- 现有方法为什么会失败或不足：
  - CDP 可能过早只保留局部可行区；
  - epsilon/penalty 方法若没有分布维护，会沿单一路径聚集；
  - solution transfer 只能告诉另一个群“哪里好”，不能告诉它“沿什么方向继续探索”；
  - 所有群沿同一收敛方向搜索会浪费评价，并遗漏 orthogonal/complementary regions；
  - crowding 或普通环境选择不一定能补回空的 CPF fragments。
- 仍需解决的问题：
  - 高维决策空间中正交补维数很大，如何选少量有效正交方向；
  - `T_COL` 和 niche 数 `K` 的自适应控制；
  - 强离散、混合变量和复杂修复约束下，方向向量如何合法化；
  - many-objective 下 dominance 和 weight-vector niche 都可能退化。

## 为什么可能有效

```text
main swarm under relaxed constraints can cross infeasible regions
-> local winner-loser vector captures immediate improvement
-> boundary-to-winner vector captures broader search trend
-> trend direction accelerates convergence toward CPF
-> auxiliary swarm uses feasible/low-CV anchor near CPF
-> orthogonal complement explores regions not covered by main trend
-> niche capacity selection prevents all feasible solutions crowding into easy fragments
```

关键假设是：主群选出的 winner/loser 和边界-winner 向量能近似当前有益收敛趋势，且 CPF 局部分布可以通过该趋势的正交补扩展。如果主群趋势错误、约束欺骗使 winner 指向假可行区，或正交方向无法保持可行性，辅群可能放大误导。

## 实现接口

- 输入：
  - 两个 population / swarm `S1`、`S2`；
  - objective values、constraint violation、decision bounds；
  - weight vectors `V` 和 niche assignment；
  - 主群 constraint relaxation schedule `epsilon(t)`；
  - COL trigger frequency `T_COL`；
  - offspring generation 和 environmental selection 接口。
- 输出：
  - main trend offspring `O1`；
  - orthogonal complement offspring `O2`；
  - 更新后的 `S1`、`S2`；
  - 可选 trend success rate、niche fill rate、orthogonal offspring survival rate。
- 插入位置：
  - 双种群 CMOEA 顶层架构；
  - CSO/PSO 的竞争更新之后、环境选择之前；
  - reference-vector CMOEA 的局部子代生成层；
  - 约束调度、工程设计或大规模 CMOP 的可行域探索模块。

P2026-0275 的默认实例：

```text
initialize S1, S2
S1 evaluated with epsilon(t)
S2 evaluated with epsilon = 0
T_COL = 75

for each generation:
    O1 <- CSO-style offspring generation from S1
    O2 <- CSO-style offspring generation from S2
    S1 <- EnvironmentalSelection(S1 union O1 union O2, epsilon(t))
    S2 <- NGSS(S2 union O1 union O2, V)

    if generation mod T_COL == 0:
        for each niche:
            x_w, x_l <- select representatives from S1
            v <- trend_learning(x_w, x_l, bounds, time_weight)
            u_main <- generate along v

            x_b <- feasible-nondominated or low-CV anchor from S2
            v_perp <- orthogonal(v)
            u_aux <- generate along v_perp around x_b

        S1 <- EnvironmentalSelection(S1 union O1_COL union O2_COL)
        S2 <- NGSS(S2 union O1_COL union O2_COL)
```

## 如何用于算法创新

### 局部创新

- 用 archive 中成功穿越不可行区的解对替代随机 winner/loser 代表，降低趋势噪声。
- 将 `Delta1` 和 `Delta2` 的权重由固定时间调度改为可行率、HV 改善、niche 空缺率或 CV 下降率反馈。
- 对每个 niche 维护多个历史趋势，用 Gram-Schmidt/PCA 生成一组正交补方向，而不是单一 `v_perp`。
- 对正交候选先执行可行性修复、constraint surrogate 过滤或 boundary projection。
- 用 orthogonal offspring survival rate 自适应调节 `T_COL` 和正交搜索比例。
- 将 NGSS 的固定容量改成根据 CPF 断裂程度、niche 历史贡献或偏好区域动态分配。

### 结构创新

- 构建三通道约束搜索架构：

```text
trend channel:
    relaxed main swarm learns convergence direction
orthogonal channel:
    auxiliary swarm expands complementary subspace
niche channel:
    capacity-controlled selection fills fragmented CPF
```

- 与边界不可行 archive 结合：趋势方向由 feasible nondominated anchors 与 low-CV boundary infeasible anchors 共同构造。
- 与代理辅助 CMOP 结合：用约束代理判断 orthogonal candidates 是否处在完全不可行区，减少真实评价浪费。
- 与动态/在线约束优化结合：环境变化后主群先学习新趋势，辅群用正交补快速恢复分布。
- 与多任务 CMOP 结合：任务之间传递局部趋势向量和正交方向生成规则，而不是完整解坐标。

## 适用条件与风险

- 适用条件：
  - 决策变量连续或可映射到连续方向空间；
  - 目标数不太高，weight-vector niche 可稳定划分目标空间；
  - 可行域复杂，单一可行性压力容易早熟；
  - 主群在约束松弛下能找到有意义 winner/loser 差异；
  - 评价预算允许维护两个 swarm 和周期性 COL。
- 不适用或可能失效的条件：
  - 离散/排列/图结构无法直接应用向量正交操作；
  - many-objective 中 niche 过多、空 niche 严重或 Pareto dominance 失效；
  - 主群趋势长期受欺骗约束误导；
  - 正交补方向高维且不加筛选，产生大量无效候选；
  - 简单 CMOP 中双群和 NGSS 开销大于收益。
- 计算与实现成本：
  - overall worst-case 为 `O(N^3)`，主因是 SPEA2 truncation；
  - COL/swarm update 主项约 `O(MN^2)`；
  - NGSS 约 `O(MN^2 + DN)`；
  - 需要维护 angle association、niche capacity、epsilon schedule 和正交方向生成。
- 解释风险：
  - DSOCOL 收益来自双群分工、winner update、COL 和 NGSS 的组合；
  - Table IV 中 DSOCOL vs DSOCOL5 的 HV p-value 在 Markdown 表中为 `0.226421`，说明 orthogonal learning 对 HV 的统计显著性可能不如正文概括那样强；
  - `K` 的默认公式在 Markdown OCR 中有噪声，应以 PDF 或代码为准。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0275 | 作者指出现有多种群/多任务 CMOEA 主要传递解坐标，忽略进化方向信息，导致冗余和低效搜索 | 问题动机 | Sec. I，PDF 1-2 |
| P2026-0275 | DSOCOL 维护 `S1`、`S2` 两个 swarm，`S1` 用 `epsilon(t)` 松弛约束，`S2` 用 `epsilon=0` 强化可行性 | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4 |
| P2026-0275 | COL 每 `T_COL=75` 代执行一次，并在每个 niche 内产生 `O1` 和 `O2` | 作者提出的方法 | Sec. III-A-B，Algorithm 1/3，PDF 4-6 |
| P2026-0275 | Trend learning 从 `S1` 的 winner/loser 代表构造 `Delta1=x_w-x_l`，并用边界到 winner 的 `Delta2=x_w-x_r` 表示全局趋势 | 作者提出的方法 | Sec. III-B，PDF 5-6 |
| P2026-0275 | 时间变化系数早期偏重全局探索向量，后期偏重局部开发向量 | 作者提出的方法 | Sec. III-B，PDF 6 |
| P2026-0275 | Orthogonal learning 以 `S2` 中 feasible nondominated 或最低 CV 代表为锚点，沿主趋势的正交方向生成辅群候选 | 作者提出的方法 | Sec. III-B，Algorithm 3，PDF 6-7 |
| P2026-0275 | NGSS 先按 CDP 分 `Phi_nf/Phi_rem`，再按 angle niche 做容量截断，最后用 residual 补充稀疏 niche | 作者提出的方法 | Sec. III-C，Algorithm 5，PDF 7-8 |
| P2026-0275 | 标准 33 个 benchmark 上，DSOCOL 在 IGD 19 个问题显著占优；HV 相对 9 个对比算法的显著胜出数最高可达 33/33 | 综合实验支持 | Sec. IV-B、Table I，PDF 9-10 |
| P2026-0275 | Friedman test 中 DSOCOL 的 IGD/HV 平均排名为 `2.0909`/`2.3788`，相对 9 个对比算法 p-values 均低于 0.05 | 统计证据 | Sec. IV-B、Table II，PDF 10 |
| P2026-0275 | 大规模 `D=500/1000` benchmark 中 DSOCOL 在 IGD/HV 上对多数算法有明显优势，Friedman test 仍排名最好 | 大规模支持 | Sec. IV-B，PDF 10 |
| P2026-0275 | FCP 欺骗约束 suite 中 DSOCOL 在 5 个实例中 4 个最好，其它多数算法 FCP1-4 无法找到可行域 | 欺骗约束支持 | Sec. IV-B，PDF 10 |
| P2026-0275 | 消融中 DSOCOL 优于无 NGSS、无 COL、无 trend、无 orthogonal 和仅 PM winner 版本，支持各模块必要性 | 消融证据 | Sec. IV-C，Table III，PDF 10-12 |
| P2026-0275 | DSOCOL4 缺少 trend learning 时最差，说明无主趋势的正交探索会浪费评价 | 机制分析 | Sec. IV-C，PDF 12 |
| P2026-0275 | DSOCOL5 有 trend 但无 orthogonal 时收敛类似但分布不如 DSOCOL，说明正交补有助于 diversity | 机制分析 | Sec. IV-C，Fig. 6，PDF 11-12 |
| P2026-0275 | 10 个真实 RWCMOP 中 DSOCOL 整体表现最好，多个对比算法无法找到可行解 | 真实应用支持 | Sec. IV-E、Table V，PDF 12-13 |
| P2026-0275 | 作者未来工作为扩展到 constrained many-objective optimization，并在 Cartesian products 上做 orthogonal search | 作者未来工作 | Sec. V，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- 主文许多函数级详细表格在 Supplementary，Markdown 只含汇总。
- 公式和参数在 Markdown 中存在 OCR 噪声，尤其 `K` 的默认设置和 Eq. (8)/(9) 的精确形式。
- 实验主要是连续变量 CMOP，离散/混合/组合约束问题尚未验证。
- 真实应用只报告 HV，因为真实 CPF 未知。
- Many-objective 扩展是未来工作，当前证据主要是 2-3 目标。

## 待确认

- 如何自动选择正交补方向数量和 basis；
- `T_COL`、`K`、主辅群资源比例是否应自适应；
- 趋势方向是否应使用 archive/历史成功率过滤；
- 约束欺骗下如何检测主群趋势被误导；
- 离散、排列、混合变量中如何定义 orthogonal learning；
- 与 dominance/decomposition 双框架、边界不可行 archive 或代理约束模型结合时收益是否互补。
