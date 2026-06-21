---
knowledge_id: K-object-oriented-public-private-mop-benchmark
name: 对象化公私空间的 MOP 基准生成
type: method
status: active
source_papers: [P2026-0102]
aliases: [OOMOP, object-oriented construction, OOC, object-oriented MOP benchmark, Public Pareto region, private public space benchmark, MOP benchmark factory, many-to-many PS-PF mapping, 对象化测试问题, 公私空间基准, Public Pareto 区域, MOP 类生成器]
promotion_reason: 单篇论文提出但构造接口完整，包含 MOP/Objective/Landscape/Peak/Public Pareto region/Shape 对象层次、private/public variable grouping、Public Pareto region 辐射式目标值计算、local/global PS 控制、PF psi 函数、steep/flat/narrow/many-to-many 等特征生成、PriCQ/PubCQ/OCR 诊断指标和五类 MOEA 压力测试，可直接用于构造连续 MOO benchmark factory。
---

# 对象化公私空间的 MOP 基准生成

## 核心内容

把多目标测试问题的 fitness landscape 拆成可组合对象：每个目标由 private landscape 和 public landscape 组成；private landscape 用峰函数控制目标独有变量的收敛难度；public landscape 用若干 Public Pareto regions 控制目标冲突空间中的 global/local PS、吸引域、PS 形状、PS-PF 映射和 PF 形状。

```text
MOP object
-> Objective objects
   -> Private landscape: peaks in objective-specific variables
   -> Public landscape: Public Pareto regions in shared conflict variables
      -> Shape object controls PS geometry
      -> radiation decay controls attraction basin and local/global dominance
-> psi function maps global Public Pareto regions to PF
-> benchmark instance with known PS/PF and controllable features
```

关键点是：benchmark 不是单个函数，而是一个可编程工厂。它能分别调节“目标独有变量难不难”和“目标冲突区域难不难”，并用 Public Pareto region 的数量、形状、大小、位置、local/global 层级和支配范围构造复杂 MOP 类。

## 建立理由

- 为什么值得独立维护：
  - 现有人工 MOP 套件常存在目标结构同质、PS/PF 规则或局部结构单一的问题。
  - 真实 MOP 可能有目标独有变量、公共冲突变量、多局部 PS、窄吸引域、平坦区域和 many-to-many PS-PF 映射。
  - OOMOP 给出统一对象接口，可持续扩展到 constrained、dynamic 和 many-objective benchmark。
  - PriCQ/PubCQ/OCR 提供了比最终 IGD/HV 更细的过程诊断。
- 单篇具体方法的直接复用价值：
  - P2026-0102 给出对象层次、公式、输入参数、PF 证明、五类 OOMOP 示例和五个经典 MOEAs 的行为差异；
  - 论文展示了当前 MOEA 在 local PS、many-to-many、narrow global PS 和 periodic PF 上的明显失败模式。
- 与已有设计知识的区别：
  - 不同于“受限子问题变换组合的基准生成”：后者从已知标准 MOP 裁剪和几何放置多个组件；本知识从 private/public landscape 对象和 Public Pareto region 辐射机制生成问题。
  - 不同于“超曲面不规则时联动的 DMOO 基准构造”：后者面向动态 MOO 的时间变化、变量交互和 time-linkage；本知识先构造静态连续 MOP 类，并将动态属性作为后续扩展。
  - 不同于“收缩-扩散率的不平衡 MOP 多样性诊断”：后者定义 diversity collapse 诊断和 IMP benchmark；本知识定义可编程的 MOP landscape 组件工厂。

## 解决的问题

- 适用场景：
  - 需要连续 MOP / MMOP benchmark generator；
  - 需要已知 PS/PF 且可控制 PS 数量、位置、形状、大小、吸引域；
  - 需要构造目标结构异构、private/public variables 可分的测试问题；
  - 需要测试算法是否能覆盖多个 PS segments、窄全局吸引域或复杂 PF；
  - 需要生成一类问题而不是单个固定函数。
- 现有方法为什么会失败或不足：
  - SOP combination 异构但高维/多目标下 PS/PF 难解析。
  - Bottom-up 可解析但目标函数结构同质，且 conflict space 通常由目标数间接决定。
  - Polygon 方法可视化强，但 PS/PF 非线性形状控制受限。
  - 固定 benchmark 难以系统区分 private-space convergence 和 public-space conflict difficulty。
- 仍需解决的问题：
  - 生成实例的难度量化和分层采样；
  - many-objective 下 PF 形状控制和 `psi` 高维扭曲；
  - constrained/dynamic 属性与 known PS/PF 的兼容；
  - 高维复杂 Public Pareto region 的最近点与对应点计算。

## 为什么可能有效

```text
private variables separate objective-specific convergence pressure
public variables isolate conflict-space difficulty
Public Pareto regions define global and local PS segments
distance/radiation decay makes off-region points dominated
psi function controls objective-space PF geometry
randomized object parameters create problem classes
PriCQ/PubCQ/OCR expose where algorithms fail
```

关键假设是：真实 MOP landscape 可以被拆成若干局部对象特征，算法弱点也能通过这些对象属性被放大和观察。如果真实问题的约束、离散结构或模拟噪声才是主要难点，单纯 OOMOP 静态连续景观还不能完全代表真实场景。

## 实现接口

- 输入参数：
  - `obj_num`：目标数；
  - `pri_var`：每个目标的 private variables 数；
  - `pub_var`：public variables 数；
  - `pri_peak_num`：每个 private space 的 peak 数；
  - `ps_num`：Public Pareto regions 总数；
  - `global_ps_num`：global Public Pareto regions 数；
  - `ps_type`：region 形状类型；
  - `ps_span`：region 大小/跨度；
  - `ps_decay_rate`：local region objective decay；
  - `ps_slope`：region 外辐射衰减斜率；
  - `pf_type`：`psi` / PF 类型；
  - `ymax`：`psi` 最大值。
- 输出：
  - 可评价的 MOP instance；
  - true PS/PF 或可采样参考集；
  - private/public landscape 参数；
  - global/local Public Pareto region 列表；
  - PriCQ、PubCQ、OCR 等过程诊断。
- P2026-0102 的具体流程：

```text
1. assign private variables to each objective and public variables to conflict space
2. construct each private landscape by peak functions
3. generate Public Pareto regions in public space:
       endpoints + shape function + span
       global/local label
       decay rate r and radiation slope w
4. compute objective values:
       private part from objective-specific peaks
       public part from nearest radiant point on Public Pareto regions
5. map global Public Pareto regions to PF using psi
6. sample PS/PF references and run MOEAs
7. report IGD+, IGDX, HV, PriCQ, PubCQ, OCR
```

## 如何用于算法创新

### 局部创新

- 为算法论文增加 OOMOP pressure suite，专门测试 public conflict dimension、local PS 数量、narrow basin 和 many-to-many mapping。
- 在运行时记录 OCR，判断算法是否丢失 global Public Pareto regions，再触发重启、子种群保护或 niching。
- 用 PriCQ / PubCQ 分离诊断：算法是 private-space 收敛差，还是 public-space global PS 定位差。
- 用 OOMOP 自动生成消融问题，固定 PF 形状只改变 PS attraction basin，或固定 PS 只改变 PF irregularity。
- 为多模态多目标算法生成 curriculum：单 global region -> 多 local regions -> many-to-many -> narrow global region -> periodic PF。

### 结构创新

- 构建 benchmark factory：

```text
feature sampler
-> OOMOP object generator
-> reference PS/PF sampler
-> multi-algorithm difficulty labeler
-> curated benchmark suite
-> algorithm failure-mode report
```

- 将 constraints 作为 Public Pareto region 的附加属性：控制 global PS 是否落在 feasible boundary、local feasible pockets 或 disconnected feasible segments。
- 将 dynamics 作为对象属性：region positions、shapes、decay rates、private peaks 和 `psi` 随时间变化，形成 dynamic OOMOP。
- 与算法自动设计结合：根据算法在 OCR/PubCQ/PriCQ 上的失败模式，自动推荐 niching、archive、restart 或 diversity operator。

## 适用条件与风险

- 适用条件：
  - 研究目标是连续 MOO benchmark 构造或算法压力测试；
  - 需要 known PS/PF 或可采样参考集；
  - 希望独立控制 private-space 和 public-space 难度；
  - 可接受参数化人工景观；
  - 需要生成问题类并统计多次随机实例表现。
- 不适用或可能失效的条件：
  - 真实问题主要是混合变量、组合结构或仿真噪声；
  - 约束可行域是核心难点而 OOMOP 未加入约束模块；
  - 高目标数下 PF 形状必须精确指定；
  - Public Pareto region 几何过复杂，nearest/radiant point 计算不稳定；
  - 参数随机化缺少难度分层，导致不同实例之间不可比。
- 计算与实现成本：
  - 需要保存完整生成参数和随机种子；
  - 需要为每个实例采样 PS/PF reference sets；
  - PriCQ/PubCQ/OCR 需要访问 region/peak 元数据；
  - 高维 public space 中最近 region 查询可能需要加速结构。
- 解释风险：
  - OOMOP 生成的失败模式可说明算法在某类人工结构下的弱点，不能直接等同真实工程失败。
  - `psi` 控制的低维 PF 形状在高目标数下会发生几何扭曲。
  - OCR 反映 global Public Pareto region 覆盖，不等价于最终 objective-space distribution quality。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0102 | 提出 object-oriented construction，将 MOP 分解为 MOP、Objective、Private/Public landscape、Public Pareto region、Peak、Shape 等对象 | 作者提出的方法 | Sec. 3.1，Fig. 4，PDF 4 |
| P2026-0102 | 定义 private variables、public variables、Public Pareto region、global/local PS 等术语 | 框架定义 | Sec. 3.1.1，PDF 4 |
| P2026-0102 | 每个目标由 private-space objective 和 public-space objective 两部分相加构成 | 作者提出的方法 | Sec. 3.1.3，PDF 4-5 |
| P2026-0102 | Private space 用 moving peak / general peak function 构造，可替换为经典多峰优化问题 | 作者提出/采用 | Sec. 3.2，PDF 5 |
| P2026-0102 | Public Pareto region 被视为辐射源，region 外点按距离衰减并被 region 支配 | 作者提出的方法 | Sec. 3.3.1、3.3.3，PDF 5-6 |
| P2026-0102 | Public Pareto region 的形状可由端点、非线性变换和 swept area 构造 | 作者提出的方法 | Sec. 3.3.2，Fig. 7，PDF 6 |
| P2026-0102 | 用 `psi` 函数设计 PF，并证明相关 non-dominance / PF 关系 | 作者提出/理论支持 | Sec. 3.4、6.2-6.3，PDF 6-7、17-19 |
| P2026-0102 | Table 5 显示 OOC 比 SOP、bottom-up、polygon 更能控制 PS 位置、数量、形状、大小、mapping 和 attraction basin | 方法对比 | Sec. 4.1.8，Table 5，PDF 10-11 |
| P2026-0102 | OOMOP1 相比 ZDT1 收敛更慢，显示 public conflict-space 维度对算法收敛有更大压力 | 实验支持 | Sec. 4.2.3，Fig. 13，PDF 11-12 |
| P2026-0102 | OOMOP2 中 local PS 增多后，所有算法找到 global PS 的概率不足 60% | 压力测试 | Sec. 4.2.4，Fig. 14-15，PDF 12-13 |
| P2026-0102 | Many-to-many mapping 下，算法丢失 PS segment 会导致 PF segment 缺失 | 压力测试 | Sec. 4.2.5，Fig. 16，PDF 13-14 |
| P2026-0102 | Narrow global Public Pareto region 中所有 MOEAs 的 OCR 快速接近 0，转向 local PS | 压力测试 | Sec. 4.2.6，Fig. 18，PDF 13-14 |
| P2026-0102 | Tri-objective periodic PF 中没有一个 tested MOEA 完美解决，IBEA IGD+ 最好但覆盖仍不均 | 压力测试 | Sec. 4.2.7，Fig. 19-20，PDF 14-16 |
| P2026-0102 | 作者未来工作包括 many-objective、constrained MOP 和 dynamic MOP 扩展 | 局限与未来工作 | Conclusion，PDF 16 |

## 证据边界

- 当前只有单篇论文证据。
- 实验主要是 bi-objective 和 tri-objective，many-objective 仍是未来工作。
- 论文展示了构造能力和算法差异，但没有形成固定公开套件的完整难度分层。
- OOMOP 需要访问生成元数据才能计算 PriCQ/PubCQ/OCR，黑盒 benchmark 使用时需另行封装。
- 与真实 MOP 的相似性主要通过特征例子说明，还缺少大规模真实问题统计匹配。

## 待确认

- 如何定义 OOMOP 实例的难度等级和最小代表测试集；
- many-objective 中 `psi`、Public Pareto region 和 PF 采样如何稳定实现；
- constrained OOMOP 中如何保持 known feasible PS/PF；
- dynamic OOMOP 中对象属性变化是否会保持跨时间可追踪性；
- 如何将 OOMOP 参数自动反推到某类真实问题的 landscape 特征。
