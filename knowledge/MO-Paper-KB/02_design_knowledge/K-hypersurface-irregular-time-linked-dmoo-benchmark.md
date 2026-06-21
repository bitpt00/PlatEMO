---
knowledge_id: K-hypersurface-irregular-time-linked-dmoo-benchmark
name: 超曲面不规则时联动的 DMOO 基准构造
type: method
status: active
source_papers: [P2026-0148]
aliases: [GTS, Generalized Test Suite, pydmoo, dynamic MOO benchmark, hypersurface PS dynamics, pi-digit irregular dynamics, time-linkage benchmark, dynamic rotation matrix benchmark, 动态多目标基准, 超曲面 PS 动态, pi 位数不规则扰动, 时联动基准]
promotion_reason: 单篇论文提出但构造接口完整，包含超曲面 PS 动态、变量贡献不均衡、动态变量交互、pi 位数可复现不规则扰动、历史解质量驱动 time-linkage、11 个 GTS 实例、三组矩阵配置、六个 DMOA 对比和运行时间分析，可直接用于动态多目标算法的分层压力测试与基准生成。
---

# 超曲面不规则时联动的 DMOO 基准构造

## 核心内容

构造动态多目标 benchmark 时，不让 Pareto set 只沿常见超平面移动，而是把 `g(x,t)` 设计成可组合模块：`h1/h2` 控制 PS 在超曲面上的动态形状，`R_II,1(t)` 和 `R_II,2(t)` 控制变量贡献不均衡与非可分交互，pi 小数位提供可复现的不规则时间扰动，`phi(t)` 把上一时刻解质量引入未来 landscape，形成可分层加压的 Generalized Test Suite。

```text
known dynamic MOP form
-> split variables into x_I, x_II,1, x_II,2
-> define h1(x_I,t), h2(x_I,t) for hypersurface PS motion
-> choose R matrices:
   identity -> separable baseline
   diagonal -> imbalanced variable contribution
   PSD with off-diagonal entries -> variable interaction
-> choose time update:
   regular schedule or pi-digit deterministic irregularity
-> optional phi(t) from previous solution quality for time-linkage
-> produce grouped DMOP instances with known PS/PF references
```

它的重点不是提升某个优化器，而是让 benchmark 本身能暴露算法是否只适应了传统超平面动态、规则时间变化或变量可分结构。

## 建立理由

- 为什么值得独立维护：
  - 常用 DMOO benchmark 会影响算法研究方向；如果 PS 动态过于规则，算法可能在标准测试上表现好但实际跟踪能力不足。
  - 该框架把动态难点拆成可控组件，可以做更干净的消融式算法评测。
  - 它同时强调解质量指标和运行时间，适合评估预测型、知识型和机器学习型 DMOA。
- 单篇具体方法的直接复用价值：
  - P2026-0148 给出 GTS1-GTS11、Group 1/2/3 矩阵配置、MIGD/MHV/MMS/Runtime 评价、六个代表性 DMOA 对比和开源实现。
- 与已有设计知识的区别：
  - 不同于“受限子问题变换组合的基准生成”：该知识面向 MMOP 的多个 Pareto set 区域构造；本知识面向连续 DMOO 的时间动态、变量相互作用和 time-linkage。
  - 不同于“收缩-扩散率的不平衡 MOP 多样性诊断”：该知识关注不平衡静态 MOP 的多样性崩塌指标；本知识关注动态 benchmark 生成。
  - 不同于各种 DMOA 响应策略知识：本知识不提供求解器，而是提供评价和压力测试环境。

## 解决的问题

- 适用场景：
  - 需要测试 DMOA 是否能跟踪超曲面 PS，而不只是超平面 PS；
  - 需要区分算法对规则变化和不规则变化的鲁棒性；
  - 需要测试变量贡献不均衡、非可分变量交互对动态跟踪的影响；
  - 需要模拟历史决策质量影响未来问题的 time-linkage；
  - 需要公开、可复现、分组清晰的动态 benchmark。
- 现有方法为什么会失败或不足：
  - FDA/DF/JY/SDP 等常用套件中大量 PS 运动结构较规则，可能偏向特定映射或采样机制。
  - 直接让每个 PS 维度独立变化会让静态问题过难，掩盖动态响应能力差异。
  - RNG-based irregular dynamics 依赖种子和实现环境，跨平台复现实验可能出现细微差异。
  - 只报告 MIGD/HV 等解质而不报告训练/预测时间，会高估复杂预测模型的实际价值。
- 仍需解决的问题：
  - 如何把真实事件流和业务扰动嵌入 GTS，而不是只依赖数学序列；
  - 如何为 time-linkage 下“算法导致的不同未来轨迹”设计公平报告协议；
  - 如何扩展到离散、混合变量、约束、昂贵评价和 many-objective 动态问题。

## 为什么可能有效

```text
traditional PS-on-hyperplane benchmarks are too regular
-> algorithms can exploit simple inverse mapping or sampling assumptions
-> hypersurface PS motion removes this shortcut
-> diagonal R exposes variable-importance imbalance
-> PSD off-diagonal R exposes variable interaction / nonseparability
-> pi-digit time perturbation tests irregular response with reproducibility
-> phi(t) links past solution error to future landscape
-> grouped benchmark reveals which dynamic difficulty each algorithm handles
```

关键假设是：benchmark 的静态可解性仍被控制住，性能变化主要来自动态结构而不是无意义的静态复杂化。P2026-0148 用 Group 1/2/3 的分层配置和运行时间分析支持这一点。

## 实现接口

- 输入：
  - 目标数 `M`、决策维数 `D`、时间步数和环境变化频率；
  - 决策变量划分 `x_I, x_II,1, x_II,2`；
  - PS 控制函数 `h1(x_I,t), h2(x_I,t)`；
  - `R_II,1(t), R_II,2(t)` 的矩阵族；
  - 时间更新规则：regular 或 deterministic irregular；
  - 可选 time-linkage 参数 `phi(t)`；
  - true PF/PS 参考点采样规则和运行时间记录协议。
- 输出：
  - 一组动态测试函数；
  - 每个时间步的参考 PF/PS；
  - 可调问题配置，例如 separable、imbalanced、interactive；
  - 指标报告：MIGD/MHV/MMS、DMIGD/DMHV/DMMS、runtime。
- P2026-0148 的具体配置：

```text
GTS1-GTS8: two-objective problems
GTS9-GTS11: three-objective problems
GTS6-GTS8: time-linkage cases

Group 1: R_II,1 = R_II,2 = I
Group 2: R matrices are diagonal, diag = 1,2,3,...
Group 3: R matrices are PSD symmetric matrices with off-diagonal interaction

irregular time: add deterministic perturbation from digits of pi
time-linkage: phi(t) grows with previous estimated knee-point error
```

## 如何用于算法创新

### 局部创新

- 在新 DMOA 论文中把 DF/FDA 结果作为基础，再用 GTS Group 1/2/3 报告算法对超曲面动态、变量不均衡和变量交互的敏感性。
- 将响应策略按 benchmark 组件诊断：规则动态失败、pi 扰动失败、变量交互失败或 time-linkage 失败。
- 为预测模型加入响应时间约束：模型训练和预测时间不得超过环境变化窗口中的可用优化时间。
- 用 GTS 的矩阵配置做 operator ablation：比较同一算法在 separable、diagonal-imbalanced、interactive 三种 landscape 下的退化幅度。

### 结构创新

- 构建动态算法测试流水线：

```text
baseline DF/FDA
-> GTS Group 1 for hypersurface + irregular time
-> GTS Group 2 for contribution imbalance
-> GTS Group 3 for variable interaction
-> GTS6-GTS8 for time-linkage
-> runtime-normalized performance report
```

- 构建 benchmark factory：用统一接口采样 `h1/h2`、`R`、时间扰动和 `phi(t)`，生成分层难度标签。
- 将真实数据流接入时间调度模块：把 pi 位数替换为交通流、负荷、电价、需求或网络事件序列，保持 PS/PF 可追踪部分不变。
- 为 DMOA 训练集设计 curriculum：先训练规则动态，再训练超曲面动态，最后加入变量交互和历史误差传播。

## 适用条件与风险

- 适用条件：
  - 研究对象是连续动态多目标优化；
  - 需要 true PF/PS 或可采样参考点计算 MIGD/MHV/MMS；
  - 希望评价算法在不同动态难点上的鲁棒性，而不只是平均排名；
  - 可以保存完整配置以保证复现。
- 不适用或可能失效的条件：
  - 离散、排列、图结构或混合变量 DMOP 不能直接使用连续 GTS 公式；
  - 真实问题中约束可行性、评价昂贵性或不确定噪声是主难点时，GTS 只覆盖部分压力；
  - 如果 time-linkage 让每个算法面对不同后续 landscape，实验报告必须明确 baseline 和实际联动轨迹；
  - pi 位数是确定性伪随机扰动，不等价于真实非平稳过程。
- 计算与实现成本：
  - Benchmark 本身计算成本不高，P2026-0148 中多数算法在 DF 与 GTS 上的平均运行时间差异小于 10%；
  - 需要为每个时间步保存参考 PF/PS 采样；
  - time-linkage 需要记录上一时刻估计解质量或膝点误差；
  - 预测型算法还要记录训练/预测耗时。
- 解释风险：
  - Group 2/3 解质下降不能简单解释为算法整体变差，应定位到变量贡献不均衡或变量交互；
  - 如果算法使用了 benchmark 的解析结构，可能产生新的过拟合；
  - 与传统 DF/FDA 的排名差异正是 benchmark 诊断信号，不应只追求单一综合排名。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0148 | 作者指出 DF/FDA 等常用 benchmark 结构简单但 PS 常在超平面上变化，可能限制现实泛化 | 动机与问题诊断 | Introduction，PDF 2 |
| P2026-0148 | 提出 Generalized Test Suite，贡献包括超曲面 PS 动态、变量贡献不均衡、动态 rotation matrices、pi 位数不规则扰动和 time-linkage | 作者提出的方法 | Abstract，Contribution，PDF 1-2 |
| P2026-0148 | `g(x,t)` 采用 `1<P<D-M` 的中间形式，主文用 `P=2` 构造 benchmark，避免超平面偏置和静态过难两个极端 | 设计机制 | Sec. 3.1，PDF 3 |
| P2026-0148 | 通过调整 `R_II,1(t)` 和 `R_II,2(t)` 对角元素控制变量贡献不均衡 | 作者提出的方法 | Sec. 3.2，PDF 3-4 |
| P2026-0148 | 用时变对称正半定矩阵引入变量交互；Theorem 3.1 给出构造 | 作者提出的方法 | Sec. 3.3，PDF 4 |
| P2026-0148 | 用 pi 小数位构造确定性不规则时间扰动，避免固定 RNG 的跨平台复现风险 | 作者提出的方法 | Sec. 3.4，PDF 5 |
| P2026-0148 | Time-linkage 中 `phi(t)` 由上一时刻真实/估计膝点目标差距驱动，模拟 time-deception 和 error accumulation | 作者提出的方法 | Sec. 3.5，PDF 5 |
| P2026-0148 | GTS 包含 8 个两目标和 3 个三目标问题，GTS6-GTS8 为 time-linkage case，代码开源于 pydmoo | benchmark 实现 | Sec. 4，Tables 2-3，PDF 5-7 |
| P2026-0148 | Group 1/2/3 分别使用单位矩阵、对角不均衡矩阵和带交互的正半定矩阵 | 实验配置 | Sec. 5.1，PDF 7 |
| P2026-0148 | 对 PPS、DPIM、AE、IGP、KGB、KTMM 六个 DMOA，在 `n_t={5,10}`、`tau_t={5,10}`、`T=50`、20 次运行下测试 | 实验设置 | Sec. 5.2-5.3，PDF 7-8 |
| P2026-0148 | GTS Group 2/3 引入不均衡和交互后，DMIGD/DMHV 可出现超过十倍变化，而大多数算法 runtime 没有显著增加 | 综合实验支持 | Sec. 5.5.1，PDF 8 |
| P2026-0148 | DF 上 IGP 排名最好，但在 GTS Group 1 中降至第四；作者归因于超曲面 PS 和不规则扰动挑战其简单采样机制 | 诊断证据 | Sec. 5.5.2，PDF 8-9 |
| P2026-0148 | GTS Group 2/3 中 KGB 因知识引导 Bayesian 分类能处理变量交互，排名接近 PPS | 诊断证据 | Sec. 5.5.2，PDF 9 |
| P2026-0148 | 多数算法在 DF 与 GTS 上平均 runtime 低于 16 秒且差异小于 10%；矩阵配置主要影响解质而非运行时间 | 成本证据 | Sec. 5.6，PDF 10 |
| P2026-0148 | 作者总结框架通过模块化设计精确控制 landscape、变量交互和时间模式，并作为 DMOO benchmark 新标准 | 作者结论 | Sec. 6，PDF 10 |

## 证据边界

- 当前只有单篇论文证据，尚缺独立论文复现或广泛采用。
- GTS 主要验证 2-3 目标连续问题，高维、多目标、离散/混合变量和强约束场景仍未覆盖。
- Time-linkage 的 `phi(t)` 设计有多种可能，作者也承认 IGD/HV 等替代指标计算昂贵，未来需要系统比较。
- pi 位数扰动解决可复现性，但不保证统计性质等同真实非平稳环境。
- 实验比较的是六个代表性 DMOA，不能直接推出所有动态算法类别的优劣。
- 开源实现有助于复现，但复用时仍需固定版本、参考点采样和时间调度配置。

## 待确认

- 如何为 time-linkage benchmark 制定统一公平报告协议；
- 如何加入约束、离散变量、昂贵评价和真实数据流；
- 如何定义动态 benchmark 的难度标尺，而不是只根据算法表现事后解释；
- 是否需要决策空间跟踪指标、切换成本指标和响应时间归一化指标；
- 是否能用自动生成器扩展 `h1/h2` 与 `R` 的组合，同时保持 PF/PS 可解析或可采样。
