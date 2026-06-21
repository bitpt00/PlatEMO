---
knowledge_id: K-objective-centroid-trend-guided-dynamic-selection
name: 目标质心趋势引导的动态选择
type: method
status: active
source_papers: [P2026-0263]
aliases: [ADNSGA-II, trend-aware selection, objective centroid trend, global trend vector, synergy factor, trend-guided NSGA-II, centroid-based dynamic selection, 动态趋势选择, 目标质心趋势, 趋势协同因子]
promotion_reason: 单篇论文提出但机制完整，包含目标空间前沿质心趋势估计、个体趋势协同因子、自适应趋势权重和 rank/diversity 选择融合，能复用到连续漂移的动态多目标优化、在线调度和资源管理。
---

# 目标质心趋势引导的动态选择

## 核心内容

在动态多目标优化中，不要只在检测到环境变化时做一次响应，然后把后续搜索当作静态 MOEA。可以把每代非支配前沿在目标空间中的质心移动看作全局环境趋势，再计算个体目标变化方向与该趋势的一致性，把这种 synergy 作为非支配排序和多样性选择之外的软偏置。趋势强、方向稳定时，顺应趋势的解更容易保留；趋势弱或不可信时，权重回落，搜索接近普通 NSGA-II。

```text
current nondominated set
-> objective-space centroid Cg
-> trend vector Tg = Cg - Cg-1
-> individual objective movement direction
-> cosine synergy with Tg
-> rank / diversity / synergy fused score
-> next generation follows dynamic trend softly
```

P2026-0263 的 ADNSGA-II 是该模式的实例：它在 DNSGA-II/NSGA-II 框架中加入 centroid-based global trend vector、individual synergy factor 和 adaptive trend-guided selection。

## 建立理由

- 为什么值得独立维护：
  - 它把动态环境信息放入每代 selection，而不是只用于变化检测后的 reinitialization；
  - 只依赖已评价目标值即可估计趋势，额外评价成本低；
  - 与 NSGA-II、DNSGA-II、archive、prediction 和 reference-vector 框架都容易组合；
  - 在云资源调度、AGV 调度、在线推荐等连续漂移场景中，环境变化常有可观测方向。
- 与已有设计知识的区别：
  - 不同于“环境变化严重度驱动的多策略预测响应”：后者根据变化严重度选择新环境初始化策略；本知识关注每代选择压力的趋势偏置。
  - 不同于“无特征表示的目标空间动态迁移”：后者在历史环境之间直接迁移 PF 解；本知识基于相邻代目标质心估计在线趋势。
  - 不同于“二阶导数双域自适应动态预测”：后者用 PS/PF 二阶信息预测种群；本知识不直接生成预测解，而是调节 survival selection。
  - 不同于普通动态随机移民：本知识不是增加扰动，而是改变保留哪些解。

## 解决的问题

- 适用场景：
  - 动态 MOO 中环境连续、渐进或高频变化；
  - PF/POS 在目标空间中有可观测漂移；
  - 响应初始化后还需要快速追踪正在移动的 Pareto front；
  - 目标值历史可缓存，计算质心和余弦一致性的成本可承受；
  - 实际系统有 CPU、负载、需求、拥塞等状态变量，可辅助构造趋势。
- 现有方法为什么会失败或不足：
  - change detection + response + static search 会在两次检测之间忽略持续漂移；
  - 静态 rank/crowding 只看当前代相对关系，不能识别谁正在顺应环境方向；
  - 预测初始化若方向偏差，后续静态搜索缺少纠偏；
  - 随机移民能增加多样性，但不能稳定提供趋势追踪压力。

## 为什么可能有效

- 非支配前沿目标质心是一个低成本的全局统计量，能捕捉 PF 整体移动方向。
- 个体目标变化方向与全局趋势一致时，说明它不仅当前表现好，还可能在未来几代保持相对优势。
- 将 synergy 作为软偏置而不是硬约束，可以减少错误趋势估计造成的灾难性选择。
- 自适应趋势权重让变化幅度大时更积极追踪，变化弱时更依赖常规 rank 和 diversity。
- 该机制复用已评价目标向量，主要增加 `O(MN)` 级线性代价，通常不改变目标函数评价预算。

## 实现接口

- 输入：
  - 当前代和上一代目标向量；
  - 当前非支配解集或 selected archive；
  - 每个个体的代际对应关系，或可替代的 parent/offspring 参考点；
  - 趋势权重调度函数 `omega_g`；
  - 原有 rank、crowding、reference vector 或 indicator selection 输出。
- 输出：
  - 全局或局部 trend vector；
  - 每个候选个体的 synergy score；
  - 融合趋势偏置后的选择顺序。
- 插入位置：
  - NSGA-II/DNSGA-II survival selection；
  - dynamic MOEA response 之后的稳定追踪阶段；
  - reference-vector 环境选择的 tie-breaker 或 weight adjustment；
  - 在线调度系统的多目标滚动优化器。

最小流程：

```text
for each generation g:
    Pstar <- nondominated solutions in population
    Cg <- centroid of objectives in Pstar
    Tg <- Cg - Cg-1

    for each candidate x:
        dx_obj <- objective movement direction of x
        Sx <- cosine(dx_obj, Tg)
        score_x <- fuse(rank_x, crowding_x, Sx, omega_g)

    select next population by rank, score and diversity
```

可扩展为局部趋势版本：

```text
partition nondominated front by reference vectors or clusters
compute local centroid trend for each region
assign candidate to nearest region
compute local synergy
select with region-aware trend bias
```

## 如何用于算法创新

### 局部创新

- 把单一全局质心换成 reference-vector/local-cluster centroids，处理 PF 局部区域反向移动。
- 对 trend vector 加 uncertainty、directional consistency 或 moving average，趋势不稳定时自动降权。
- 用 decision-space displacement 与 objective-space trend 联合定义 synergy，降低只看目标空间的误导。
- 将 synergy factor 作为 tie-breaker，而不是直接进入主排序，适合对趋势不太确定的场景。
- 用环境变量预测下一代 trend，再与 observed centroid trend 做 ensemble。

### 结构创新

- 构建 trend-aware dynamic optimizer：

```text
change detection / environment observation
-> response initialization
-> centroid or environment trend estimation
-> trend confidence assessment
-> rank-diversity-trend survival selection
-> archive and local boundary preservation
```

- 与策略池结合：趋势置信高时使用 trend-guided selection，置信低时切回随机移民、记忆检索或多样性优先。
- 与多任务动态优化结合：不同任务共享 trend encoder，但保留任务专属 local centroid。
- 与真实在线调度结合：环境状态流提供外部趋势，目标质心提供内生趋势，两者不一致时触发诊断或保守模式。

## 适用条件与风险

- 适用条件：
  - PF 或优质解集在目标空间中的移动具有方向连续性；
  - 目标空间维度不至于让质心统计完全失真；
  - 当前非支配集足够密，质心不被极少数点支配；
  - 趋势偏置强度可调，错误趋势不会完全覆盖 rank/diversity；
  - 环境变化不是完全随机或强突变。
- 不适用或可能失效的条件：
  - 变化只发生在 POS 而 POF 基本不动，目标质心信号弱；
  - PF 断裂、多峰或不同区域移动方向相反，单一质心会平均掉局部趋势；
  - abrupt shift 后相邻代质心差可能滞后；
  - 高维决策空间导致非支配集稀疏，趋势估计和 crowding 都不稳定；
  - 可观测环境变量与目标变化存在非线性滞后，简单相关性投影会误导。
- 计算与实现成本：
  - 每代需要保存上一代质心或目标向量；
  - 对每个候选计算目标方向和余弦相似度，成本约 `O(MN)`；
  - 若使用局部趋势，需要额外聚类或 reference assignment；
  - 需要处理 parent/offspring 身份不连续和初始代无趋势的问题。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0263 | 作者指出传统 DMOEA 采用 change detection、response、static search 三阶段，静态搜索期会忽略连续环境趋势 | 问题动机 | Abstract、Introduction，PDF 1-2 |
| P2026-0263 | 用非支配前沿目标空间质心的连续代差构造 global trend vector | 作者提出的方法 | Sec. III-A，PDF 4 |
| P2026-0263 | 用个体目标变化方向与 global trend 的 cosine similarity 定义 synergy factor | 作者提出的方法 | Sec. III-B，PDF 4-5 |
| P2026-0263 | 将 synergy factor 与 non-dominated rank、crowding distance 和自适应权重结合，形成 trend-guided selection | 作者提出的方法 | Sec. III-C、Algorithm 1，PDF 5-6 |
| P2026-0263 | 趋势建模和 synergy 计算复用已评价目标向量，额外时间主要为线性代价，未增加目标函数评价 | 成本说明 | Sec. III-C、IV-C，PDF 5、8 |
| P2026-0263 | 在 10 个动态 benchmark、3 种动态参数组合上比较 DNSGA-II-A/B、SGEA、CRM-DMOEA、DDIS-MOEA/D、DMOEA/D、DM-DMOEA | 实验设置 | Sec. IV-A-C，PDF 6-8 |
| P2026-0263 | ADNSGA-II 在 MHV best/All 计数中为 `15/30`，在 MIGD best/All 计数中为 `17/30`，优于其他比较算法 | 综合实验支持 | Sec. IV-C、Table I-II，PDF 7-8 |
| P2026-0263 | 与去掉趋势引导的 NDNSGA-II 相比，ADNSGA-II 在多数 `N` 和 `nx` 设置下表现更好 | 消融实验 | Sec. IV-C2，PDF 8-9 |
| P2026-0263 | 每代运行时间约 `0.05-0.07s`，趋势模块运行开销与基线相当 | 运行成本 | Sec. IV-C3，PDF 9 |
| P2026-0263 | 在 dMOP1/dMOP2 的 solution migration 可视化中，ADNSGA-II 轨迹更平滑，说明趋势偏置改善跟踪 | 行为分析 | Sec. IV-C4，PDF 9 |
| P2026-0263 | 微服务调度案例使用 CPU、内存、请求率和队列长度构造趋势，在 Periodic/Burst/Drift/Hybrid 扰动下 HV/IGD 和多目标雷达表现领先 | 应用实验 | Sec. IV-D，PDF 9-10 |
| P2026-0263 | 作者指出当变化只影响 POS 或 POF、突变或高维稀疏时，目标空间趋势可能产生偏置或不稳定 | 局限 | Conclusion，PDF 10 |

## 证据边界

- 当前证据主要来自单篇 ADNSGA-II 论文。
- Benchmark 结果显示整体优势，但 FDA4、dMOP1 等问题存在明显弱项。
- 微服务案例为仿真实验，环境变量到目标空间的趋势映射仍需真实系统验证。
- 单一目标质心可能忽略 PF 局部结构，many-objective 或 highly disconnected PF 尚未充分验证。
- 精确公式和表格数值需回 PDF，当前 Markdown 中部分公式为图片抽取。

## 待确认

- 如何自动判断趋势可信度并安全降权；
- 是否应使用局部质心、边界 anchor 或 reference-vector trends 替代全局质心；
- 趋势选择与 archive、memory、prediction 和 random immigrants 的最佳组合方式；
- 在 high-dimensional decision space 中如何避免非支配集稀疏导致趋势估计不稳定；
- 可观测环境变量到目标空间趋势的非线性、滞后和噪声如何建模。
