---
knowledge_id: K-variable-adaptive-upf-archive-population-reconstruction
name: 变量自适应 UPF 档案重构
type: architecture
status: active
source_papers: [P2026-0198]
aliases: [LCMVAPR, variable adaptive optimization, archive-assisted population reconstruction, UPF-to-CPF, LSCMOP, convergence-related variables, diversity-related variables, large-scale constrained MOO, 变量自适应优化, 档案辅助种群重构, 收敛变量, 多样性变量]
promotion_reason: 单篇论文提出但接口完整，包含变量类型分析、收敛/多样性变量自适应全局搜索、UPF-CPF 档案保存和参考子区中位距种群重构，可直接改造大规模约束多目标算法的阶段控制与局部初始化层
---

# 变量自适应 UPF 档案重构

## 核心内容

在大规模约束多目标优化中，把搜索拆成两个明确阶段。第一阶段暂时忽略约束，用变量分析把决策变量分成收敛相关变量和多样性相关变量，并按目标值进展自适应切换优化重点，快速接近 UPF 和潜在优质目标区域。这个阶段不只留下末代种群，而是维护一个包含 UPF 附近、低 CV 以及 UPF/CPF 之间候选的 archive。第二阶段用 archive 重构局部搜索初始种群：按参考向量划分子区，并在每个子区内用到 ideal point 的距离中位数筛选代表个体，再进入约束感知 CPF 搜索。

```text
decision variable analysis
-> convergence-related variables x_c and diversity-related variables x_d
-> x_c correlation grouping into subx_c

global stage, constraints ignored:
    optimize subx_c in turn for convergence
    if objective progress stagnates -> optimize x_d for diversity
    if diversity progress stagnates -> stop global stage
    archive <- offspring and promising solutions

local stage:
    assign archive solutions to reference-vector subregions
    select median-distance representatives in each subregion
    reconstruct initial population
    constrained environmental selection toward CPF
```

## 建立理由

- 为什么值得独立维护：
  - 该知识回答 LSCMOP 中两个常见问题：如何在高维变量空间快速获得目标收敛方向，以及当 UPF 与 CPF 不一致时如何把无约束搜索结果转成可行性搜索起点。
  - 变量自适应阶段控制、archive 桥接和 population reconstruction 是可替换、可组合的算法接口。
- 单篇具体方法的直接复用价值：
  - P2026-0198 给出 LCMVAPR Algorithm 1-4、变量分组、阶段切换、archive 更新、重构规则、消融、43 个 benchmark 问题和 5 个 real-world 问题证据。
- 与已有设计知识的区别：
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识用双松弛边界围绕可行区域保留不可行解，并用 VGDE reproduction；本知识先无约束变量自适应搜索，再用 archive 重构局部初始种群。
  - 不同于“双档案自适应约束松弛与局部收敛选择”：该知识关注 leading archive 是否重新考虑约束以及 primary archive 的局部收敛；本知识关注从全局 archive 中选择什么样的解来初始化局部 CPF 搜索。
  - 不同于“约束边界远距不可行辅助引导”：该知识筛选靠边界且远离主种群的不可行解；本知识用参考子区和距离中位数在 UPF-CPF 桥接 archive 中重构整个人口。
  - 不同于“双空间分层自适应资源分配”：该知识分配变量组和子种群评价预算；本知识把变量类型优化和约束阶段切换绑定到 UPF-to-CPF 重构。

## 解决的问题

- 适用场景：
  - 决策变量数量大，常规全变量 SBX/PM 或 DE 收敛慢；
  - 目标与约束共同作用导致可行域稀疏，CPF 可能远离 UPF；
  - 变量对收敛和多样性的作用不同，且可以通过扰动或历史响应粗略识别；
  - 需要在有限预算内先获得目标方向，再进行约束精修。
- 现有方法为什么会失败或不足：
  - 一开始就强约束搜索容易在高维稀疏可行域中停滞；
  - 只追 UPF 的辅助搜索在后期可能偏离 CPF；
  - 直接把全局末代种群交给局部搜索，在 UPF/CPF 距离较大时初始化位置不佳；
  - 固定交替优化变量组会消耗预算，无法根据目标进展及时切换。
- 仍需解决的问题：
  - 如何稳健估计 UPF 与 CPF 的距离；
  - 如何识别 constraint-repair variables，而不只区分目标收敛/多样性变量；
  - 如何在昂贵评价或超高维问题中降低变量分析成本；
  - archive 中距离中位数筛选是否适合所有 CPF/UPF 几何关系。

## 为什么可能有效

```text
LSCMOP 高维且可行域稀疏
-> 早期强可行性压力难以产生有效 offspring
-> 忽略约束先找到目标空间 promising regions

变量对目标收敛和分布的作用不同
-> 先优化 x_c 快速靠近 ideal/UPF
-> 停滞后优化 x_d 扩展 UPF 覆盖
-> 避免全变量无差别扰动稀释关键变量

UPF 与 CPF 可能分离
-> 不直接继承末代 UPF 种群
-> archive 保留桥接候选
-> 按参考子区重构初始种群
-> 局部阶段从更接近 CPF 且有分布的起点搜索
```

关键假设是：无约束 UPF 搜索能提供与 CPF 相关的方向信息，并且 global archive 中确实存在可被约束搜索利用的桥接候选。若 UPF 与 CPF 完全无关，或约束可行域由极窄离散岛组成，archive reconstruction 可能仍无法提供足够可修复的初始个体。

## 实现接口

- 输入：
  - 每个候选的 decision vector、objective values、constraint violation；
  - 变量扰动分析或历史成功率分析模块；
  - reference vectors、ideal point、archive size；
  - 阶段切换参数或在线进展指标。
- 输出：
  - 变量组：`x_c`、`x_d`、`subx_c`；
  - global archive；
  - local search 初始种群；
  - 阶段状态和预算消耗记录。
- 插入位置：
  - LSCMOP 算法的阶段控制器；
  - 双种群/双档案 CMOEA 的辅助无约束搜索转约束搜索接口；
  - 大规模变量分组 reproduction 前的变量选择和预算分配层；
  - 局部搜索或 restart 的 initialization 模块。
- 最小流程：

```text
group_variables():
    perturb each decision variable
    classify variables by objective-space angle response
    split convergence variables by correlation

global_search():
    for each convergence subgroup:
        optimize subgroup
        if objective spread/progress < delta for g generations:
            move to next group or diversity variables
    optimize diversity variables until stagnation
    update archive with objective + CV information

reconstruct_population():
    normalize archive objectives
    assign each solution to nearest reference-vector subregion
    compute distance to ideal point
    in each subregion, select solutions by median-distance rule
    fill population and start constrained local search
```

P2026-0198 的具体设置：

- `g=35`、`delta=0.05`；
- archive size `N=200`；
- variable adaptive optimization 用距离 ideal point 衡量收敛变量优化质量，用候选间夹角衡量多样性变量优化质量；
- archive 更新在规模超限时将 CV 当作额外目标排序，再结合密度和 dominance 保留候选；
- local search 用改进 epsilon-based environmental selection，把约束作为额外目标纳入非支配排序。

## 如何用于算法创新

### 局部创新

- 用可行比例、archive survival rate、UPF-CPF estimated distance 或 HV/IGD 改善替代固定 `g/delta` 停滞阈值。
- 将变量分类扩展为三类：objective-convergence variables、objective-diversity variables、constraint-repair variables。
- 在 archive reconstruction 中把 ideal-distance 中位数替换或扩展为低 CV、可行概率、constraint-boundary distance、reference occupancy、局部密度联合评分。
- 对 reference-vector 子区使用自适应容量，让稀缺或难修复子区获得更多初始个体。
- 用随机投影、代理敏感性、梯度估计或历史成功扰动降低变量分析的 `O(D^2)` 成本。

### 结构创新

- 构建三段式 LSCMOP 框架：

```text
variable-response analysis
-> unconstrained objective-region discovery
-> archive bridge reconstruction
-> constrained CPF refinement
```

- 与双档案 CMOEA 组合：

```text
AU: unconstrained UPF coverage archive
AB: low-CV / boundary bridge archive
AP: feasible CPF archive
reconstruction controller mixes AU and AB by subregion and feasibility signal
```

- 与资源分配机制组合：根据每个变量组最近对 objective progress、CV reduction 和 archive contribution 的贡献动态分配评价预算。
- 与代理辅助 CMOP 组合：用 surrogate 预测 archive 候选的可修复性，只真实评价重构后最有希望的局部初始个体。
- 与动态约束 MOO 组合：环境变化后先用旧 archive 快速重构，再短期变量自适应更新变量组和局部人口。

## 适用条件与风险

- 适用条件：
  - 变量维度高，且变量对目标收敛/分布的影响存在可识别差异；
  - UPF 或无约束目标搜索与 CPF 至少部分相关；
  - 有足够预算做变量分析和一个全局预搜索阶段；
  - 目标值可归一化，reference-vector 子区能近似表示期望分布；
  - algorithm pipeline 支持阶段切换、archive 保存和 population restart/reconstruction。
- 不适用或可能失效的条件：
  - UPF 与 CPF 关系很弱，忽略约束的全局阶段产生大量无用候选；
  - 可行域为极窄离散岛，archive 中缺少可修复解；
  - 变量强非线性耦合导致单变量扰动分类不可靠；
  - 约束尺度极不均衡，CV 作为额外目标排序偏置；
  - 目标维度很高且 reference vectors 稀疏，子区中位距选择不稳定。
- 计算与实现成本：
  - 变量分组最坏 `O(D^2)`；
  - 需要维护 archive、reference-vector 分配和阶段切换状态；
  - 若 global stage 过长，局部 CPF 搜索预算不足；若过短，archive 质量不足。
- 解释风险：
  - LCMVAPR 的收益来自变量自适应、archive 更新、population reconstruction 和局部约束搜索组合，不能单独归因于距离中位数规则。
  - 论文主文部分结果表为图片/补充材料，精确函数级数值需回查原 PDF 或 supplementary。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0198 | 作者指出 LSCMOP 中复杂变量耦合、巨大搜索空间和可行域稀疏导致收敛慢、可行解难找 | 问题动机 | Introduction，PDF 1-2 |
| P2026-0198 | LCMVAPR 包含 global search 和 local search 两阶段，前者执行变量自适应优化并维护 archive，后者执行 archive-assisted population reconstruction | 框架设计 | Sec. III-A，Algorithm 1，Fig. 3，PDF 4-5 |
| P2026-0198 | 变量分析将变量分为 convergence-related 和 diversity-related，并进一步对 convergence variables 分组 | 作者提出/采用方法 | Sec. II-B / III，PDF 3-5 |
| P2026-0198 | Variable adaptive optimization 先优化 convergence variable subgroups，目标值停滞后切换 diversity variables，并在 diversity 优化停滞后结束全局阶段 | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 5-6 |
| P2026-0198 | Archive update 将 CV 作为额外目标参与排序，保留 UPF 和 CPF 之间的 promising solutions | 作者提出的方法 | Sec. III-C，Algorithm 3，PDF 6 |
| P2026-0198 | Population reconstruction 按 reference-vector subregion 和 ideal-distance 中位数选择 archive 个体作为局部搜索初始种群 | 作者提出的方法 | Sec. III-D，Algorithm 4，PDF 6-7 |
| P2026-0198 | LIRCMOP3 search behavior 显示种群先靠近 UPF，再通过重构靠近 CPF，局部搜索最终找到多个离散 CPF 片段 | 机制解释 | Sec. IV-A / Fig. 4，PDF 8 |
| P2026-0198 | LIRCMOP 56 个函数上，六个对比算法相对 LCMVAPR 显著更差的数量约为 42-54 个 | 对比实验支持 | Sec. IV-B，Table I-II，PDF 8-10 |
| P2026-0198 | MW benchmark 中 LCMVAPR 在多数函数和维度上最优，并在 37/56 个函数上可行率达到 100% | 对比实验支持 | Sec. IV-B，PDF 10-11 |
| P2026-0198 | C-DTLZ/DC-DTLZ 中 LCMVAPR 在 32/40 个函数上最佳 IGD、34/40 个函数上最佳 HV，且所有函数都找到可行解 | 对比实验支持 | Sec. IV-B，PDF 11 |
| P2026-0198 | `LCMVAPR_LMEA` 消融在 38 个函数中 36 个显著差于完整算法，支持自适应变量优化而非固定交替 | 消融实验支持 | Sec. IV-C，PDF 12 |
| P2026-0198 | `LCMVAPR_UPF` 在 CPF 与 UPF 距离较远的 LIRCMOP1-4 上明显较差，支持 archive-assisted reconstruction | 消融实验支持 | Sec. IV-C，PDF 12 |
| P2026-0198 | `LCMVAPR_random1/random2` 弱于完整中位距重构，说明子区内选择规则有贡献 | 消融实验支持 | Sec. IV-C，PDF 12 |
| P2026-0198 | DEED 3 个算例和 TREE 2 个算例上，LCMVAPR 的 HV 均优于六个对比算法 | 真实应用支持 | Sec. IV-D，PDF 13 |
| P2026-0198 | 作者指出当前未设计针对非均匀变量-目标相关性的算子或 CHT，未来需研究更复杂 LSCMOP benchmark 和更高效 CHT | 作者局限与未来工作 | Conclusion，PDF 14 |

## 证据边界

- 当前只有单篇论文证据。
- 主文中的大量具体数值表为图片或补充材料，当前卡片保存的是正文可读统计结论。
- 在 LIRCMOP10/11 高维离散可行区域、CLSMOP 非均匀变量-目标相关性场景中，LCMVAPR 仍有不足。
- 真实应用只报告 HV，真实 CPF 未知，不能完全分解收敛、多样性和可行性贡献。
- 变量分析依赖单变量扰动和目标空间角度，强耦合变量下可能误分组。

## 待确认

- 距离中位数规则在 CPF 位于 ideal point 远侧、UPF 包围 CPF 或多段 CPF 时是否总能选出更可修复个体。
- `g=35`、`delta=0.05`、archive size `N=200` 对不同维度和预算是否需要自适应。
- CV 作为额外目标排序时是否应做约束归一化或按约束重要性加权。
- 是否可以用 archive 中个体进入局部阶段后的 survival rate 反向学习更好的 reconstruction policy。
