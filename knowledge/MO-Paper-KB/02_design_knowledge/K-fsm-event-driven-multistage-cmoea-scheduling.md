---
knowledge_id: K-fsm-event-driven-multistage-cmoea-scheduling
name: 有限状态机驱动的多阶段 CMOEA 策略调度
type: architecture
status: active
source_papers: [P2026-0099]
aliases: [FSM-CMO, finite state machine CMOEA, event-driven state switching, multi-stage constrained MOEA, MPop HPop, state switching mechanism, finite state machine evolutionary algorithm, 有限状态机约束多目标, 事件驱动阶段切换, 多阶段策略调度, 双种群状态调度]
promotion_reason: 单篇论文提出但机制完整，包含有限状态机状态集合、事件触发条件、MPop/HPop 双种群分工、四个状态的 mating/selection/update 策略、State III 稀疏评价、State IV 分布修正、参数敏感性、47 个 benchmark、14 个真实 CMOP 和四状态消融证据，可直接改造多阶段约束多目标算法的顶层策略调度器。
---

# 有限状态机驱动的多阶段 CMOEA 策略调度

## 核心内容

把多阶段约束多目标进化算法写成一个有限状态机：每个状态对应一种搜索任务和一套种群更新策略，每隔若干代读取当前种群状态，依据显式事件规则切换到下一状态。主种群 `MPop` 始终作为最终输出种群，辅助种群 `HPop` 根据状态改变角色：支援多样性、忽略约束穿越大不可行区、用稀疏评价细搜狭窄可行边界、用 truncation 修正最终分布。

```text
state variables:
    rho_M, rho_H: nondominated ratio in MPop/HPop
    HPop_nd feasible or not
    count: repeated I/II switching count
    a: State III evaluation alternation counter
    NFE/maxNFE

FSM states:
    I   initial exploration and diversity support
    II  unconstrained UPF guidance across infeasible regions
    III sparse-boundary exploration by SE + DE
    IV  final distribution refinement by SPEA2 truncation
```

该知识的核心不是“四阶段”本身，而是把阶段切换从固定时间表或单一阈值改成可审计的事件-状态控制器。它可以作为其它 CMOEA/DMOEA/SAEA 的顶层策略调度层。

## 建立理由

- 为什么值得独立维护：
  - 多阶段 CMOEA 的主要风险是阶段错配：合适策略在错误时机使用会浪费评价预算；
  - 传统两阶段或三阶段算法常把切换逻辑写死，难适配大不可行区、窄可行域和最终分布修正之间的冲突；
  - FSM 提供明确接口：状态、事件、动作和下一状态，便于扩展和调试；
  - P2026-0099 给出四状态定义、转移条件、伪代码、参数分析和四状态消融证据。
- 单篇具体方法的直接复用价值：
  - Algorithm 4 可作为 event detector 模板；
  - State I-IV 分别对应初探、UPF crossing、boundary sparse exploration 和 final distribution balancing；
  - MPop/HPop 分工清晰，可替换不同子算法；
  - 消融结果能说明每个 state 对不同 CMOP 类型的作用边界。
- 与已有设计知识的区别：
  - 不同于“支配-分解双框架协同与阶段切换”：该知识按 dominance/decomposition 两套框架分工；本知识按事件触发调度多个搜索状态。
  - 不同于“约束违反状态驱动的代理搜索模式切换”：该知识面向昂贵约束优化的 surrogate mode 和档案数据源切换；本知识不依赖 surrogate，作用于普通 CMOEA 顶层阶段控制。
  - 不同于“状态驱动的 DRL 演化算子选择”：该知识通过 RL 学习 state-action value；本知识使用显式 FSM 规则，易解释但依赖人工阈值。
  - 不同于“变量自适应 UPF 档案重构”：该知识以变量分组、archive 和重构为核心；本知识以状态机和 HPop 策略调度为核心。

## 解决的问题

- 适用场景：
  - CMOP 包含大不可行区域、狭窄可行区域、断裂 CPF 或后期分布均匀性要求；
  - 算法已经有多个策略模块，但缺少统一调度；
  - 需要能解释“为什么此时切换策略”；
  - 希望在单个框架中组合可行性恢复、UPF 引导、边界覆盖和分布修正；
  - 可以维护主/辅两个种群和少量状态变量。
- 现有方法为什么会失败或不足：
  - 固定阶段比例不能判断当前策略是否还在产生改进；
  - 单一可行优先会难以跨越大不可行区；
  - 长期忽略约束会停留在 UPF 或无效不可行区域；
  - 只做早期探索和中期收敛，后期可能缺少均匀分布修正；
  - 人工策略堆叠没有统一状态逻辑，难复用和调试。
- 仍需解决的问题：
  - state variables 如何更完整地表示 feasibility/convergence/diversity；
  - 事件阈值如何自适应，而不是固定 `alpha/count/interval`；
  - 状态切换是否应按 reference subregion 局部发生；
  - 如何减少无用状态执行完成后才能切换的延迟。

## 为什么可能有效

```text
early search uncertain
-> State I preserves diversity and gathers broad parents

large infeasible region
-> State II ignores constraints and moves HPop toward UPF

near feasible boundary but coverage poor
-> State III uses sparse objective-space selection and DE

late stage
-> State IV uses distance truncation to smooth distribution

event detector monitors nondominated-ratio changes
-> switches when current state stops contributing
```

关键假设是：非支配比例变化、HPop 可行非支配解、I/II 往返次数和评价进度足以近似判断当前搜索需求。若这些状态量与真实难点不一致，FSM 会发生早切、晚切或反复切换。

## 实现接口

- 输入：
  - `MPop`、`HPop`；
  - objective values、constraint violations、feasible flags；
  - weight vectors 或 reference vectors；
  - 当前 NFE、maxNFE；
  - state variables：`rho_M0/rho_H0/rho_M/rho_H/count/a/state`；
  - 每个 state 对应的 mating、variation、selection 子程序。
- 输出：
  - 更新后的 `MPop`、`HPop`；
  - 当前 state 和 transition log；
  - 可选：每个 state 的 offspring survival/contribution rate。
- 插入位置：
  - 多阶段 CMOEA 顶层 controller；
  - 双种群 CMOEA 的 HPop 策略调度层；
  - 动态约束 MOO 的环境变化响应层；
  - 多策略 MOEA/SAEA 的模式切换层。
- 最小实现：

```text
initialize MPop, HPop, state=I, count=0, a=0

while budget remains:
    if state == I:
        Q <- diversity-assisted GA mating(MPop, HPop)
    if state == II:
        Q <- unconstrained HPop GA mating(HPop)
    if state == III:
        Q <- DE with HPop
        F <- SE if a even else original objectives
    if state == IV:
        Q <- GA from two HPop halves

    MPop <- update_main_population(MPop, Q)
    HPop <- update_helping_population(state, MPop, HPop, Q, F)

    if inspection_interval_reached:
        rho_M, rho_H <- nondominated_ratios(MPop, HPop)
        state, count, a <- FSM_transition(rho_M, rho_H, HPop_nd, count, a, NFE)

return MPop
```

- P2026-0099 的默认实例：
  - `alpha=0.05`；
  - State IV 触发比例 `0.8*maxNFE`；
  - `count>=2` 触发 State III；
  - 检查间隔 `50`；
  - State III 使用 `k=floor(sqrt(N)+1)` 个邻居；
  - `MPop` 用可行优先、非支配排序、reference-vector association 和 CV 删除；
  - `HPop` 在不同状态下用 SPEA2、SE、SPEA2+CDP 或子区选择。

## 如何用于算法创新

### 局部创新

- 将 `rho_M/rho_H` 扩展为多指标状态：

```text
state_features = [
    feasible_ratio,
    mean_CV_drop,
    HV_or_R2_progress,
    reference_vector_coverage,
    boundary_infeasible_density,
    offspring_survival_rate_by_state
]
```

- 把固定 `count>=2` 改为连续 stagnation score，降低 I/II 无意义往返。
- 让 State III 的 `SE` 替换为 SDE、reference-vector vacancy、local HV contribution 或 decision-space novelty。
- 给 State IV 增加进入条件：只有当可行率和收敛稳定、但分布不均时才触发。
- 记录每个 state 生成 offspring 的生存率，用反馈修正后续 event thresholds。

### 结构创新

- 构建可插拔 FSM 控制器：

```text
State = {
    detector inputs,
    entry action,
    mating operator,
    environmental selection,
    exit condition
}
FSM = transition_table(State, Event)
```

- 将动态约束变化作为事件：

```text
if environment_change_detected:
    state <- re_exploration
    reset rho_M0/rho_H0/count
```

- 在昂贵 CMOP 中：
  - State II 用 surrogate 快速估计 UPF 方向；
  - State III 用局部代理筛选边界候选；
  - 真实评价只给跨状态贡献最高的候选。
- 在多目标调度/路径/供应链中：
  - repair state：恢复可行性；
  - exploration state：穿越不可行或高成本区域；
  - polishing state：局部邻域精修；
  - balancing state：按参考方向或拥挤度均匀化。

## 适用条件与风险

- 适用条件：
  - 存在多个明确互补的搜索策略；
  - 搜索过程能被分解成少数状态；
  - 有可在线计算的状态触发指标；
  - 算法能承受维护两个种群和状态检查的开销；
  - 问题类型确实需要不同阶段解决不同矛盾。
- 不适用或可能失效的条件：
  - CMOP 简单，可行域大且连续，单一策略足够；
  - 状态指标与真实进展弱相关；
  - 评价预算很小，状态往返和后期修正消耗过高；
  - 状态切换必须很快响应，但 FSM 只能在 state 执行完后检查；
  - 高维或大种群下 SPEA2 truncation 成本过高。
- 计算与实现成本：
  - 需要维护 `MPop/HPop` 两个种群；
  - 需要保存 state、count、rho 历史和 transition logs；
  - `O(N^3)` truncation / environmental selection 可能成为瓶颈；
  - 多状态使调参与调试复杂度上升。
- 决策风险：
  - 显式 FSM 易解释，但阈值经验性强；
  - 固定 80% 进入 State IV 可能在搜索未完成时过早转入分布修正；
  - 只看非支配比例可能无法识别“非支配数稳定但 CV 继续改善”的情况；
  - State III 的 SE 公式和文本描述存在轻微不一致，复现需核对代码。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0099 | FSM-CMO 定义四个状态，使用 Algorithm 1 在每轮执行 state strategy 后调用 state switching mechanism | 框架设计 | Sec. 3.1、Algorithm 1，PDF 5 |
| P2026-0099 | MPop 作为输出种群，先保留可行解，再用非支配排序、reference-vector association 和 CV 删除完成更新 | 主种群更新 | Algorithm 2，PDF 6 |
| P2026-0099 | HPop 在 State I/II/III/IV 分别用子区补充、SPEA2、SE selection、SPEA2+CDP/SPEA2 | 辅助种群更新 | Algorithm 3，PDF 6 |
| P2026-0099 | FSM 输入包括 `rho_M0/rho_M/rho_H0/rho_H/HPop_nd/a/count/NFE`，输出下一状态和更新后的状态变量 | 状态变量 | Sec. 3.2、Eq. (5)-(7)，PDF 7 |
| P2026-0099 | event table 包含 `|rho_M-rho_M0|`、`HPop_nd(CV=0)`、`|rho_H-rho_H0|`、`count>=2` 和 `NFE>=0.8 maxNFE` | 转移规则 | Table 4、Algorithm 4，PDF 8 |
| P2026-0099 | State I 根据 `rho_m/rho_h` 和 `exp(-NFE/maxNFE)` 选择父代来源，用 GA 生成 offspring | State I 设计 | Algorithm 5，PDF 8 |
| P2026-0099 | State II 使用 HPop 父代且 HPop 忽略约束，目标是推动 MPop 穿越大不可行区域 | State II 设计 | Sec. 3.4、Algorithm 6，PDF 9 |
| P2026-0099 | State III 使用 DE 和 `SE` 稀疏评价，`k=floor(sqrt(N)+1)`，距离越大 `SE` 越小，偏好稀疏边界 | State III 设计 | Eq. (8)-(12)、Algorithm 7，PDF 9 |
| P2026-0099 | State IV 将 HPop 分两半，分别进行 constrained/unconstrained 评价，并用 SPEA2 truncation 调整分布 | State IV 设计 | Algorithm 8，PDF 9 |
| P2026-0099 | 参数敏感性得出默认 `alpha=0.05`、State IV 触发比例 `0.8`、`count=2`、检查间隔 `50`，ANOVA 中 D/C 贡献率最高 | 参数证据 | Sec. 4.2、Tables 5-8，PDF 10-12 |
| P2026-0099 | SE 与 crowding distance 对比中 FSM-CMO 在 21 个复杂问题上 IGD/HV 均为 `0/18/3` | 组件证据 | Sec. 4.3、Table 10，PDF 12 |
| P2026-0099 | MW11 和 LIRCMOP6 中 HPop contribution 与性能提升相关，分别支持 State IV 和 State II/III 的作用 | 机制分析 | Sec. 4.4、Fig. 4，PDF 13 |
| P2026-0099 | DTLZ、MW、LIR-CMOP、DAS-CMOP 47 个 benchmark 和 7 个 baseline 的 IGD/HV 比较显示 FSM-CMO 整体领先或竞争 | Benchmark 支持 | Sec. 4.5、Tables 11-18，PDF 14-18 |
| P2026-0099 | 14 个 RWCMOP 中 FSM-CMO 在 8 个问题 HV 最高，Two Reactor 上部分 baseline 为 NaN 而 FSM-CMO 有可行 HV | 工程支持 | Sec. 4.6、Tables 19-20，PDF 20-21 |
| P2026-0099 | 移除任意 state 均导致对应问题类型上 rank 退化；完整 FSM-CMO 在四套 benchmark 平均 rank 均最优 | 消融证据 | Sec. 4.7、Table 21，PDF 20-22 |
| P2026-0099 | 作者指出经验阈值、state 完成后才能切换和 `O(N^3)` 高维瓶颈是主要限制 | 风险边界 | Sec. 5，PDF 22-23 |

## 证据边界

- 当前只有单篇论文证据；
- FSM 状态变量和阈值仍是人工设计，不是自动学习；
- 实验覆盖广，但对超高维和动态约束问题只是未来设想；
- 真实问题只报告 HV，不足以分解可行性、收敛和分布贡献；
- 可复用重点是“FSM 顶层调度器”，不应机械照搬四个状态和阈值。
