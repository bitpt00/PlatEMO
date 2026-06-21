---
knowledge_id: K-dynamic-reference-point-roi-preference-tracking
name: 动态参考点 ROI 偏好跟踪
type: method
status: active
source_papers: [P2026-0193]
aliases: [DPA, DPA-NSGA-II, DAR-dominance, dynamic adaptive r-dominance, PPM, preference prediction mechanism, dynamic preference DMO, dynamic ROI tracking, reference point prediction, ROI-focused DMOP, 动态偏好, 动态参考点, 兴趣区域跟踪]
promotion_reason: 单篇论文提出但机制清晰，包含动态参考点偏好建模、DAR-dominance 阶段化 ROI 搜索压力、least-squares PPM 偏好预测、环境变化响应接口和 ROI 指标评价，可直接迁移到动态路径规划、项目调度、工业控制和交互式动态多目标优化。
---

# 动态参考点 ROI 偏好跟踪

## 核心内容

在动态多目标优化中，把决策者 reference point 也视作随时间变化的状态，而不是只追踪变化的 Pareto set/front。算法同时维护两个预测层：一层预测环境变化后的种群或 PS/PF，另一层预测 reference point/ROI 的移动趋势。选择层用动态自适应 `r`-dominance 控制偏好强度：新环境初期先保留 Pareto 探索，中期收紧到 ROI，后期放宽以维护 ROI 内多样性。

```text
environment change detected
-> update or predict reference point
-> change response generates new population
-> adaptive r-dominance schedules ROI pressure
-> NSGA-II style environmental selection
-> ROI-focused convergence/diversity evaluation
```

P2026-0193 的 DPA-NSGA-II 实例中，DAR-dominance 动态调节 `delta`，PPM 对历史 reference points 做 least-squares 线性拟合，PPS 负责环境变化后的种群预测。

## 建立理由

- 为什么值得独立维护：
  - 很多动态 MOO 算法追踪完整 PF，但真实决策通常只关心某个随阶段变化的 ROI；
  - 偏好变化有滞后，等 DM 更新 reference point 后再搜索可能来不及到达新 ROI；
  - 固定强度的 reference point dominance 在动态环境中容易早熟或覆盖不足。
- 单篇具体方法的直接复用价值：
  - P2026-0193 给出 DPA framework、DAR 阶段调度、PPM 线性预测、参数敏感性、消融、16 个 benchmark 和 D-PID 应用。
- 与已有设计知识的区别：
  - 不同于“环境变化严重度驱动的多策略预测响应”：本知识预测/跟踪的是 DM preference 和 ROI，不只是 PS/PF 或新环境初始种群。
  - 不同于“更新状态驱动的双参考点切换”：该知识切换分解式搜索参考点模式；本知识用 DM reference point 表达偏好并预测其动态变化。
  - 不同于“二阶导数双域自适应动态预测”：该知识预测 PS/PF 曲率和变化来源；本知识强调偏好轨迹和 ROI-focused selection。

## 解决的问题

- 适用场景：
  - DMOP 中环境和偏好都可能变化；
  - DM 能给出 reference point、aspiration level 或阶段性目标；
  - 只需要逼近 ROI，而非完整 PF；
  - 相邻偏好变化存在一定连续性或可预测性；
  - 需要在每个环境周期内快速给出可用决策。
- 现有方法为什么会失败或不足：
  - 只追踪完整 PF 浪费预算，尤其在变化频繁时来不及收敛；
  - 静态偏好方法不能处理 reference point 变化；
  - 环境预测不等于偏好预测，历史 PS/PF 不一定告诉算法 DM 将关注哪个 ROI；
  - 固定 `r`-dominance 强度无法同时兼顾新环境探索、ROI 收敛和 ROI 内分布。
- 仍需解决的问题：
  - 不规则、突变或噪声偏好下的预测鲁棒性；
  - 多 DM 或多 reference points 下的 ROI 冲突；
  - ROI 指标如何对齐真实决策满意度；
  - 大规模 DMOP 中 nondominated sorting 和 ROI ranking 的效率。

## 为什么可能有效

```text
动态环境早期信息不可靠
-> large delta keeps Pareto exploration

时间窗口有限
-> reduce delta to intensify reference-point pressure

ROI 内仍需多样性
-> increase delta to maintain boundary coverage

reference point changes cause lag
-> fit preference trajectory and guide population ahead
```

关键假设是：reference point 在短期内近似平滑，历史 reference points 含有可外推趋势；同时，DM reference point 与实际可达 ROI 之间关系稳定。如果偏好是突变、反复震荡或受隐藏因素驱动，PPM 的 hypothetical point 可能误导 population。

## 如何用于算法创新

### 局部创新

- 将线性 PPM 替换为 Kalman filter、VAR、Gaussian process、spline 或 neural time-series predictor。
- 用 ROI tracking error 动态调整 `eta`，预测不确定时更信任 DM 当前 reference point。
- 将 `delta` 调度从固定函数改为 feedback control，依据 ROI convergence、spread、change severity 自动调节。
- 同时维护多个 predicted reference points，覆盖不确定的 future ROI。
- 在 interactive MOO 中把 DM 对上一代 ROI 的满意度反馈加入 PPM。

### 结构创新

- 动态偏好 MOO 框架：

```text
environment detector
-> population/PF predictor
-> preference/reference predictor
-> adaptive ROI dominance
-> ROI archive and decision interface
```

- 与工业控制结合：把工况阶段、操作员目标和历史 setpoint preference 输入 preference predictor。
- 与动态路径规划结合：根据时段、拥堵、能耗政策和用户目标预测下一阶段 route ROI。
- 与 project scheduling 结合：把 lifecycle stage 和 deadline/wage preference 切换建成 reference point trajectory。

## 适用条件与风险

- 适用条件：
  - 偏好可用 reference point 或 aspiration vector 表达；
  - reference point 变化有短期连续性；
  - 每个环境周期有足够代数让 ROI 搜索发生作用；
  - 可构造 ROI-focused convergence/diversity metrics；
  - 优化器能检测环境变化并做 change response。
- 不适用或可能失效的条件：
  - 偏好完全突变且历史无预测价值；
  - DM reference point 不可达或与真实满意度不一致；
  - 多个 DM preference 冲突且不能压缩为单 reference point；
  - 变化频率太高，种群尚未响应就再次变化；
  - 高维目标中 ROI 几何复杂，单个 `delta` 难控制覆盖范围。
- 计算与实现成本：
  - PPM 线性拟合成本低；
  - 主要成本仍在 DMOEA 的环境选择和 change response；
  - 需要记录 reference point history、environment change intervals 和 ROI tracking metrics。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0193 | DPA 在环境变化时同时更新 reference point、执行 PPM，并用 PPS 生成新环境初始种群 | 作者提出的方法 | Sec. III-A，Algorithm 1，Fig. 4，PDF 5-6 |
| P2026-0193 | DAR-dominance 用 `delta` 控制 reference point preference strength，`delta=1` 近似 Pareto dominance，`delta=0` 强偏好排序 | 作者提出的方法 | Sec. III-B，PDF 6 |
| P2026-0193 | DAR 在每个环境周期内先用 `delta_init=1` 探索，中期降低 `delta` 收敛 ROI，稳定后升至 `delta_limit` 保持多样性 | 作者提出的方法 | Sec. III-B，Fig. 5，PDF 6-7 |
| P2026-0193 | PPM 将每个 reference coordinate 建成时间线性函数，用 least squares 从历史 reference points 拟合并预测 hypothetical point | 作者提出的方法 | Sec. III-C，Algorithm 2，Fig. 6，PDF 7-8 |
| P2026-0193 | 实验使用 5 FDA、3 dMOP、8 JY 共 16 个 problems，偏好变化模式为 NCP、LCP、CCP | 实验设置 | Sec. IV-A，PDF 8 |
| P2026-0193 | 主实验与 PPS、AE、IT、KL、KTS、HRS、DIP、KTMM 共 8 个 DMOEAs 比较，用 MGD/MSP 和 Friedman/Nemenyi 检验 | 实验设置 | Sec. IV-B/C，PDF 8-9 |
| P2026-0193 | 在 `tau_t=5` 快速变化下，DPA-NSGA-II 在所有 preference change modes 下整体更好，作者归因于直接聚焦 ROI | 综合实验支持 | Sec. V-A，Table I，Fig. 7，PDF 9-10 |
| P2026-0193 | 在 `tau_t=10` 较慢变化下，DPA-NSGA-II 在多数 DMOP 和三种偏好模式下最优，ROI 分布优势明显 | 综合实验支持 | Sec. V-A，Table II，Fig. 7，PDF 10 |
| P2026-0193 | 消融显示完整 DAR-PPM-DPA 的 Friedman/Nemenyi 排名最佳，并显著优于 baseline 和单策略变体 | 消融实验支持 | Sec. V-B，Fig. 8，PDF 10 |
| P2026-0193 | 参数分析显示 `lambda=0.8` 和中等 `eta` 较优，`eta=0.5` 多数问题最优 | 参数证据 | Sec. V-C，Fig. 9，PDF 10-11 |
| P2026-0193 | Runtime 分析显示 DPA-NSGA-II 与先进算法相当或更好，复杂度主要来自 nondominated sorting | 计算效率证据 | Sec. V-D，Fig. 10，PDF 11 |
| P2026-0193 | D-PID control problem 上 DPA-NSGA-II 的 MGD/MSP 优于对比算法，显示 DM guidance 在真实动态控制中有效 | 应用实验支持 | Sec. V-E，Table IV，PDF 11-12 |
| P2026-0193 | 作者指出泛化到 irregular/noisy environments、极端偏好变化和 large-scale optimization 仍需研究 | 作者局限 | Sec. VI，PDF 12 |

## 待确认

- 真实 DM 偏好是否能被单 reference point 和短期线性趋势充分表达；
- ROI-focused MGD/MSP 与用户满意度、决策成本和风险是否一致；
- 偏好突变或多用户冲突时，PPM 是否需要 uncertainty-aware 或 multi-modal prediction；
- 高目标数下 `delta` 与 ROI size 的关系是否仍可解释；
- 与更强 PS/PF 预测器或 second-order dynamic prediction 结合后，DAR/PPM 的独立贡献如何变化。
