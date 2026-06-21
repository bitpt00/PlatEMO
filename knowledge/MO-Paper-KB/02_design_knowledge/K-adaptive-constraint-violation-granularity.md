---
knowledge_id: K-adaptive-constraint-violation-granularity
name: 自适应约束违反粒度评估
type: method
status: active
source_papers: [P2026-0234]
aliases: [ACVE, CCVE, adaptive constraint violation evaluation, constraint information granularity, clustered CV reassignment, coarse-to-fine CVE, DDCo, 自适应CVE, 约束违反粒度, 聚类重赋CV]
promotion_reason: 单篇论文提出但接口清晰，包含 objective-space 聚类重赋 CV、可行比例 sigmoid 粒度调度、NCVE/BCVE 折中、可插拔 CHT 组合和双种群 CCVE 扩展，可直接改造多类 CMOEA 的约束评估层
---

# 自适应约束违反粒度评估

## 核心内容

把 constrained MOEA 中的 constraint violation evaluation 从固定规则改成状态自适应粒度。先用原始约束计算每个解的 `CV`，再在目标空间聚类；同一簇内所有解共享该簇最小 `CV`。簇数由可行解比例和演化阶段控制：早期簇少，多个解共享粗粒度 `CV`，约束压力弱、目标探索强；后期簇多，`CV` 变细，约束满足和 CPF 收敛压力增强。

```text
raw constraint values
-> NCVE raw CV
-> feasible ratio P_fea
-> decide cluster number n_c
-> K-means in objective space
-> each cluster receives min raw CV
-> CHT uses reassigned CV for selection
```

DDCo 中进一步把该思想扩展为 CCVE：主种群用 NCVE 追可行性，辅助种群用 coevolution-adjusted CVE 调节 objective exploration 与 feasibility pull-back。

## 建立理由

- 为什么值得独立维护：
  - 它不是新的 CHT，而是改变 CHT 之前的 `CV` 表达方式，可插入 CDP、SR、epsilon、penalty、MOO-based 等多类 CHT。
  - 它把 NCVE 和 BCVE 视为约束信息粒度的两个极端，提供一个可连续调度的中间层。
  - 它能与现有不可行解辅助、双种群、约束代理、epsilon 规则等机制组合。
- 单篇具体方法的直接复用价值：
  - P2026-0234 给出 ACVE Algorithm 1、CCVE Algorithm 3、NCVE/BCVE 对比、六类 CHT 插拔实验、DDCo 综合实验和电池充电应用。
- 与已有设计知识的区别：
  - 不同于“约束边界远距不可行辅助引导”：该知识回答辅助种群保留哪些不可行解；本知识回答这些解的 `CV` 应以多粗粒度进入选择。
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识用动态边界定义不可行辅助指标；本知识重写底层 `CV`，可作为该指标或其他 CHT 的输入层。
  - 不同于“EID 动态约束优先级”：该知识按约束维度排序和分配阶段；本知识把多个解按目标空间簇共享 `CV`，调节信息粒度。
  - 不同于“全局-局部约束代理”：该知识关注如何预测约束值；本知识关注预测或真实约束值之后如何表达给 selection。

## 解决的问题

- 适用场景：
  - CMOP 中早期需要跨越 infeasible obstacles 或探索多个 feasible regions；
  - 后期又需要足够强的可行性压力逼近 CPF；
  - 现有 CHT 对 `CV` 过敏或过钝；
  - 想在不大改 CHT 的情况下调节 constraint/objective balance；
  - 能够在每代保存父代、子代和 objective values。
- 现有方法为什么会失败或不足：
  - NCVE 太细，早期可能让低 `CV` 个体支配选择，错过远处小 feasible regions；
  - BCVE 太粗，后期无法区分不可行解离可行域的距离；
  - 只调 CHT 参数常常把“约束信息有多少”与“选择规则怎么用”混在一起；
  - 双种群辅助若没有合适 CVE，辅助种群可能太快跟随主种群或越过可行域。

## 为什么可能有效

```text
early stage: few feasible solutions
-> small n_c
-> many solutions share CV
-> objective diversity can guide exploration across infeasible regions

middle stage: feasible ratio grows
-> n_c increases
-> CV levels become finer
-> valuable infeasible solutions near different feasible regions survive

late stage: force n_c = 2Np
-> fine CV information
-> pull population toward feasibility and CPF
```

关键假设是：目标空间聚类能把相近 tradeoff 区域中的解放在一起，簇内最小 `CV` 可以合理保护同一区域内具有探索价值的不可行解。如果 objective-space cluster 与可行域结构严重错位，ACVE 会把不该保护的解降低 `CV`。

## 实现接口

- 输入：
  - 父代 `P`、子代 `Q`；
  - 每个解的 objective values 和 raw constraint values；
  - 当前代数 `t`、最大代数 `T`、种群规模 `Np`；
  - 下游 CHT。
- 输出：
  - 重赋后的 `CV`；
  - 下游 CHT 可直接使用的 selection input。
- 插入位置：
  - 原始 constraint evaluation 和 CHT/environmental selection 之间；
  - 单种群 CMOEA 的 CVE 层；
  - 双种群 CMOEA 的辅助种群 CVE 层；
  - 代理约束预测后的 `CV` 后处理层。
- 最小实现：

```text
U <- P union Q
raw_cv[x] <- NCVE(x) for x in U
P_fea <- feasible_count(P) / |P|

if t <= 0.7 * T:
    n_c <- max(floor(2*Np / (1 + exp(-10*(P_fea - 0.5)))), 1)
else:
    n_c <- 2*Np

clusters <- kmeans(objectives(U), n_c)
for cluster C in clusters:
    cv_min <- min(raw_cv[x] for x in C)
    for x in C:
        cv_acve[x] <- cv_min

selection(U, objectives, cv_acve, CHT)
```

CCVE 辅助种群扩展：

```text
U <- P2 union Q
P_fea1 <- feasible_count(P1) / |P1|
P_fea2 <- feasible_count(P2) / |P2|

if P_fea1 == 1 and P_fea2 == 0 and all(y in P2 not dominated by any x in P1):
    gamma <- 2

if gamma == 1:
    u1 <- 1 / (1 + exp(10*(t - 0.5)))
    P_fea <- max(P_fea2 - u1 * P_fea1, 0)
else:
    u2 <- 1 / (1 + exp(-10*(t - 0.5)))
    P_fea <- min(P_fea2 + u2 * P_fea1, 1)

n_c <- max(floor(2*Np / (1 + exp(-10*(P_fea - 0.5)))), 1)
cluster_and_reassign_cv(U, n_c)
```

## 如何用于算法创新

### 局部创新

- 将 K-means objective-space clustering 改为 reference-vector sectors、constraint-space clusters、decision-space feasible-boundary clusters 或 learned embeddings。
- 将簇内最小 `CV` 改为低分位数、加权平均、uncertainty-calibrated lower confidence bound，减少单个异常低 `CV` 解拖低整簇 `CV`。
- 让 `n_c` 由可行比例、CV 分布熵、簇内 CV 方差、UPF-CPF 距离或 feasible-region coverage 联合决定。
- 在 CDP、epsilon、SR、VCDP、双边界指标等 CHT 前增加 ACVE 层，比较是否降低 CHT 参数敏感性。
- 在 noisy constraints 中用聚类重赋做 CV 平滑，降低单点评价噪声对 selection 的影响。

### 结构创新

- 构建三层约束平衡框架：

```text
constraint predictor/evaluator
-> CV granularity controller (ACVE/CCVE)
-> constraint handler (CDP/epsilon/SR/VCDP/indicator)
```

- 与双种群 CMOEA 组合：主种群保留细粒度可行性，辅助种群用粗粒度 CV 保持 objective exploration，必要时通过 CCVE 拉回 CPF。
- 与 surrogate-assisted CMOEA 组合：代理预测 raw CV 后，ACVE 根据粒度控制降低早期代理误差对选择的硬影响。
- 与约束优先级调度组合：先按 EID 选择当前处理约束，再对该约束下的 `CV` 做 ACVE 粒度控制。

## 适用条件与风险

- 适用条件：
  - 约束违反可计算或可预测；
  - objective-space 聚类能粗略反映候选 tradeoff 区域；
  - 算法允许在 CHT 前替换 `CV`；
  - 早期探索不可行区域有价值；
  - 后期可通过细粒度 `CV` 拉回 feasible CPF。
- 不适用或可能失效的条件：
  - 可行域结构与 objective-space cluster 几乎无关；
  - 约束非常简单且可行域大，粗粒度 CV 收益不明显；
  - 等式约束或不连续约束导致簇内最小 `CV` 不代表可修复方向；
  - K-means 在高目标数下退化或簇不稳定；
  - 下游 CHT 本身已有强动态约束平衡，叠加 ACVE 可能过度放松约束。
- 计算与实现成本：
  - 每代需要在 `2Np` 个解上做 K-means；
  - 需要维护 raw CV 和 reassigned CV 两套值以便调试；
  - DDCo 还需要双种群、density mating、CCVE crossing detection 和 SPEA2 truncation。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0234 | 作者将 CMOEA 分为 MOEA、CHT 和 CVE 三部分，并指出 CVE 研究相对不足 | 问题定位 | Introduction，PDF 1-2 |
| P2026-0234 | NCVE 提供细粒度连续 CV，早期可能过度偏向 constraints；BCVE 提供粗粒度 CV，后期约束信息不足 | 问题动机 | Introduction、Sec. IV-A，PDF 2、4 |
| P2026-0234 | ACVE 合并 `P` 与 `Q`，先计算 raw CV，再按 `P_fea` 决定 objective-space K-means 簇数 | 作者提出的方法 | Algorithm 1，PDF 5 |
| P2026-0234 | 每个簇内选择最小 raw CV，并重赋给簇内所有解 | 作者提出的方法 | Algorithm 1，PDF 5 |
| P2026-0234 | `n_c` 由 `2Np/(1+exp(-10(P_fea-0.5)))` 调度，`t>0.7T` 时强制 `2Np` | 作者提出的方法 | Eq. (5)，PDF 5 |
| P2026-0234 | 示例分析显示 `P_fea=0` 时 ACVE 保持目标空间多样性，`0<P_fea<1` 时保护接近未探索 feasible regions 的不可行解，后期退化为 NCVE | 机制解释 | Sec. IV-C、Fig. 5、Table I，PDF 6-7 |
| P2026-0234 | ACVE 与 CDP、MOO-based、SR、SP、epsilon、ATM 六类 CHT 结合，并与 NCVE/BCVE 对照 | 插拔性实验 | Sec. VI-C，PDF 10-11 |
| P2026-0234 | 作者总结 ACVE 相比 NCVE/BCVE 更有潜力增强 CHT，收益来自平衡 constraint satisfaction 和 objective optimization | 综合实验结论 | Sec. VI-C，PDF 11 |
| P2026-0234 | DDCo 用 `P1` 作为 NCVE 主种群、`P2` 作为 CCVE 辅助种群，从 CVE 角度构造辅助搜索 | 作者提出的方法 | Sec. V-A、Fig. 6，PDF 7-8 |
| P2026-0234 | CCVE 在 `gamma=1` 时用 `P_fea=max(P_fea2-u1*P_fea1,0)` 让辅助种群保持更多 objective information | 作者提出的方法 | Eq. (8)，PDF 9 |
| P2026-0234 | CCVE 在 crossed feasible regions 后用 `P_fea=min(P_fea2+u2*P_fea1,1)` 拉回辅助种群 | 作者提出的方法 | Eq. (9)，PDF 9 |
| P2026-0234 | DDCo 在 MW、CTP、Zhou’s CF、Zhang’s CF 上与 C-TAEA、CCMO、PPS、ToP、NSGA-II-CDP、ShiP 比较，30 次运行、IGD/IGD+/HV | 实验设置 | Sec. VI-A-D，PDF 9-12 |
| P2026-0234 | 主文总结 DDCo 在四套 benchmark 多数实例上优于 competitors，Friedman 排名在所有情况下最小 | 综合实验支持 | Sec. VI-D，PDF 11-12 |
| P2026-0234 | 电池充电应用中 DDCo 获得最佳平均 HV，并给出 6 个满足约束的代表 charging protocols | 真实应用支持 | Sec. VII-B、Tables V-VI，PDF 13-14 |
| P2026-0234 | 作者未来工作包括引入 gradient/active constraint information，并探索 surrogate-assisted CMOEAs 扩展 DDCo 到 expensive CMOPs | 作者局限与未来工作 | Conclusion，PDF 14 |

## 证据边界

- 当前只有单篇论文证据，且详细函数级表格主要在 supplementary。
- ACVE 的收益部分依赖下游 CHT；对于已高度自适应的 CHT，提升可能较小。
- K-means objective-space 聚类和 `0.7T` 阈值是启发式；论文主文没有给出完全自动的粒度控制器。
- DDCo 的优势来自 ACVE/CCVE、双种群、density mating 和 SPEA2 更新的组合，不能把全部收益单独归因于 ACVE。
- 电池应用使用 reduced-order model，而非每次都调用完整 COMSOL 高保真模型。

## 待确认

- objective-space 聚类是否应换成 constraint-space 或 reference-vector clustering；
- 簇内最小 `CV` 是否会被偶然低 `CV` 噪声解误导；
- many-objective 下 K-means、crowding/density 和 ACVE 粒度是否仍稳定；
- 如何用在线反馈替代固定 sigmoid 和 `0.7T`；
- 与 VCDP、EID、双边界指标、surrogate constraint models 组合时是否会相互增强或过度放松约束。
