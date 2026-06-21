---
knowledge_id: K-service-age-dynamic-premaintenance-green-rhfs-scheduling
name: 服务寿命-碳排耦合的动态预维护调度
type: architecture
status: active
source_papers: [P2026-0087]
aliases: [PM-AD-RHFS, service-age aware preventive maintenance, machine aging green scheduling, dynamic pre-maintenance scheduling, age-energy mapping, reliability-threshold maintenance insertion, green reentrant hybrid flow shop, 寿命感知预维护, 机器老化碳排调度, 动态预维护, 绿色重入混合流水车间]
promotion_reason: P2026-0087 单篇提出但建模接口清楚：用 Weibull reliability 和 service life threshold 触发 PM，用服务寿命同时驱动 maintenance duration 与 processing energy/carbon emissions，并在 RHFS 解码中按 idle-gap 优先、已有间隔搜索、右移补救三类策略插入 PM。该架构可迁移到半导体、光学、航空复材、热处理等高价值设备的绿色调度与维护协同优化。
---

# 服务寿命-碳排耦合的动态预维护调度

## 核心内容

在绿色制造调度中，不把机器能耗、维护时间和故障风险视为固定参数，而是把机器的 accumulated service life 作为解码状态。每安排一个加工操作，就更新机器年龄和可靠性；若执行下一操作后可靠性会低于阈值，则提前插入 preventive maintenance。PM 优先利用当前工序前或机器已有加工任务之间的 idle gap；如果没有合适窗口，再右移当前工序，把 PM 插到上一任务后。维护后机器年龄按恢复因子下降，但不完全归零；后续加工能耗和碳排按新的服务寿命重新计算。最终输出 makespan-carbon Pareto schedules。

```text
candidate schedule / priority list
-> decode operations in RHFS order
-> for selected machine k:
       predict R_k(age_k + processing_time)
       if reliability below threshold:
           pm_time <- PM_duration(age_k)
           insert PM into idle gap if possible
           otherwise right-shift current operation
           age_k <- residual_age_after_PM(age_k)
-> process operation
-> carbon += energy_rate(age_k) * processing_time * carbon_factor
-> age_k += processing_time
-> objectives: makespan, total carbon emissions
```

P2026-0087 的实例是 PM-AD-RHFS：用该解码/建模层配合 CHIO-DECM，在随机 benchmark 和 OLED ARRAY workshop 案例上验证。

## 建立理由

- 为什么值得独立维护：
  - 很多绿色调度只调节 idle energy、速度或启停状态，仍把加工能耗本身视为固定；
  - 设备老化会提高能耗和维护难度，若不进入目标函数，会低估碳排并错判 PM timing；
  - 维护若只在达到阈值时直接插入，会破坏排程并扩大 makespan；
  - 将 PM 作为解码状态而非外部计划，可以让任意 MOEA/元启发式在评价时获得更真实的 makespan-carbon trade-off。
- 单篇具体方法的直接复用价值：
  - P2026-0087 给出 reliability threshold、service-age PM time、service-age energy mapping、动态 PM 插入规则、PM-AD-RHFS 模型、CHIO-DECM 求解、benchmark、消融和真实半导体案例。
- 与已有设计知识的区别：
  - 不同于“前向事件解码与反向能耗压缩调度”：该知识用前向可行排程和后向移动压缩 idle energy；本知识的核心状态是 machine age/reliability，并主动插入 PM。
  - 不同于“能量反馈自适应机器重启调度”：该知识决定 standby/shutdown/restart，重启不是维护；本知识处理 PM 对机器年龄、能耗和生产时间的联动影响。
  - 不同于“右移-调速协同节能解码”：该知识通过右移制造降速窗口；本知识右移是 PM 插入失败时的可行性补救，并会重置部分机器年龄。
  - 不同于普通 predictive maintenance：本知识把 PM 作为多目标调度解码和 Pareto 评价的一部分。

## 解决的问题

- 适用场景：
  - reentrant/hybrid/flexible flow shop、job shop 或其它多阶段高价值设备调度；
  - 机器连续高负载，服务寿命影响能耗、故障概率和维护耗时；
  - 可以估计 reliability curve、energy-age curve 和 PM duration-age curve；
  - 目标包含 makespan、carbon emissions、energy cost、maintenance cost 或 reliability；
  - schedule 中存在可利用的 idle windows。
- 现有方法为什么会失败或不足：
  - 固定加工能耗无法表示老化设备的碳排增长；
  - 固定 PM 时间无法表示老化后维护复杂度；
  - 维护优先模式可能过度牺牲生产效率；
  - 排程优先后再插 PM 容易打断已形成的关键路径；
  - 只做启停/调速不会降低老化带来的 failure risk。
- 仍需解决的问题：
  - random failures 如何与 planned PM threshold 联合建模；
  - PM 需要维护人员、备件、工装或安全审批时如何建资源约束；
  - service-age 曲线如何由真实传感器和维护记录校准；
  - 多设备、多产品工况下是否需要机器级或工艺级阈值；
  - 动态订单和实时电价下 PM 策略如何在线更新。

## 为什么可能有效

```text
machine age accumulates during processing
-> reliability decreases and energy rate increases

maintenance before threshold reduces failure risk and later carbon intensity
-> but PM consumes machine capacity and can delay jobs

idle gaps are hidden opportunities
-> insert PM into idle windows before shifting jobs

PM does not fully renew the machine
-> residual age keeps later energy/PM estimates realistic

makespan and carbon conflict
-> keep Pareto schedules and tune service-life threshold by preference
```

关键假设是：service age 是设备状态的主要 sufficient statistic，且能耗/PM 时间曲线足够可信。如果真实退化由温度、负载谱、工艺类型或环境共同决定，单一累计加工时间会过粗，需要数字孪生或 condition-based features 替换。

## 实现接口

- 输入：
  - scheduling instance：jobs、stages、machines、reentry rounds、processing times；
  - machine reliability function `R_k(t)` 和 threshold `R0`；
  - age reduction factor after PM；
  - PM duration function `T_pm(age)`；
  - energy rate function `e_k(age)` 和 carbon emission factor；
  - candidate priority list、machine assignment rule 或完整 schedule；
  - idle gap search policy。
- 输出：
  - 完整 schedule：operation start/completion、machine assignment、PM start/completion；
  - machine age trajectory 和 PM events；
  - makespan、total carbon emissions、可选 maintenance cost/reliability metrics；
  - threshold sensitivity 或 preference-specific schedule。
- 插入位置：
  - 调度型 MOEA 的 decoder / evaluator；
  - memetic/local search 中的 schedule repair；
  - digital twin scheduling simulator；
  - maintenance-aware dispatching rule；
  - robust/stochastic scheduling 的 scenario evaluator。

最小实现：

```text
decode(priority_list):
    initialize machine ages and schedules
    for each operation in decoded RHFS order:
        k <- choose_machine(operation, rule = SPT or learned policy)
        p <- processing_time(operation, k)

        if R_k(age[k] + p) <= R0:
            T <- PM_duration(age[k])
            slot <- find_idle_gap_before_current_or_between_tasks(k, T)
            if slot exists:
                insert_PM(k, slot, T)
            else:
                right_shift_current_operation_and_insert_PM(k, T)
            age[k] <- residual_age_after_PM(age[k])
            recalculate_future_energy_if schedule already contained tasks

        start, finish <- schedule_operation(operation, k)
        carbon += energy_rate_k(age[k]) * p * carbon_factor
        age[k] += p

    return schedule, makespan(schedule), carbon
```

## 如何用于算法创新

### 局部创新

- 将固定 service life threshold 改成 machine-specific dynamic threshold，由 failure risk、carbon price、due date slack 和 maintenance resource 共同决定。
- 把 PM 插入位置从规则选择改为小规模 Pareto local search，在候选 idle gaps 中评估 makespan/carbon 增量。
- 用 real-time sensor health index 替换累计加工时间，形成 condition-based green scheduling。
- 把 PM duration 和 energy rate 设为不确定区间，用 robust 或 chance-constrained evaluator。
- 将维护人员/备件加入解码状态，避免多个机器同时 PM 时不可执行。

### 结构创新

- Age-aware green decoder：

```text
priority / chromosome
-> RHFS feasible decoding
-> machine age and reliability update
-> PM insertion and carbon recalculation
-> Pareto environmental selection
```

- Maintenance-energy co-optimization portfolio：

```text
age-aware PM insertion
-> remaining idle gaps
-> shutdown/restart decision
-> speed scaling / right shift
-> carbon-cost-reliability Pareto schedules
```

- 数字孪生闭环：

```text
shop-floor logs
-> update energy-age and PM-time curves
-> schedule optimizer consumes calibrated curves
-> realized PM/carbon data feeds back after execution
```

## 适用条件与风险

- 适用条件：
  - 设备老化对能耗、可靠性或维护时间有显著影响；
  - 有足够历史数据或工程模型估计 service-age curves；
  - 排程系统允许 PM 在生产间隙灵活插入；
  - PM 后设备不是完全 as-good-as-new；
  - 决策者需要 makespan-carbon-maintenance trade-off。
- 不适用或可能失效的条件：
  - 设备能耗与年龄无明显关系；
  - 维护只能固定窗口执行，不能由调度器动态插入；
  - 突发故障远比阈值退化更主导；
  - 加工时间、质量和维护效果高度随机但模型仍确定性；
  - 运输、工装、人员或材料约束比机器 PM 更瓶颈。
- 计算与实现成本：
  - 解码时需要维护每台机器的 age trajectory 和 idle gap list；
  - PM 插入后若已有后续任务，需要增量右移和碳排重算；
  - 若加入维护人员、备件或随机故障，状态空间会明显扩大；
  - service-age curves 需要现场数据校准，否则目标值可能有系统偏差。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0087 | 指出 RHFS 中连续高负载会加速机器老化，老化会增加能耗、维护难度和调度风险 | 问题动机 | Sec. 1 |
| P2026-0087 | 用 Weibull failure distribution 建立 reliability function，并由可靠性阈值确定维护 service time | 建模方法 | Sec. 3.1 |
| P2026-0087 | 引入 age reduction factor 表示 PM 后机器不能完全恢复 | 建模方法 | Sec. 3.1 |
| P2026-0087 | 定义 machine maintenance time 与 service life 的函数关系 | 建模方法 | Sec. 3.1 |
| P2026-0087 | 定义 machine energy consumption 与 service age 的函数关系，并说明加工碳排随累计加工时间显著增加 | 建模方法 | Sec. 3.1 |
| P2026-0087 | PM-AD-RHFS 同时最小化 makespan 和 total carbon emissions，并约束可靠性不低于阈值 | 问题建模 | Sec. 3.2 |
| P2026-0087 | 动态 PM 策略在每个操作前检查 `R(age + processing_time)`，不足时先安排 PM 再更新后续任务 | 作者提出的方法 | Sec. 3.3 |
| P2026-0087 | PM 插入优先使用当前工序前 gap、已有 idle interval，最后才右移当前工序 | 作者提出的方法 | Sec. 3.3 / Figs. 4-6 |
| P2026-0087 | CHIO-DECM 用 sparrow-based initialization 和 DECM 求解 PM-AD-RHFS | 求解器 | Sec. 4 |
| P2026-0087 | 20-200 工件 benchmark 上 CHIO-DECM 在 GD/IGD/HV/Epsilon 四项指标上均优于 NSGA-II、SSA、MOPSO、DBO、CHIO、AOA | 综合实验支持 | Sec. 5.3 / Table 9 |
| P2026-0087 | 消融显示 CHIO-DECM 优于只加初始化或只加交叉变异的变体，多数 Wilcoxon 比较显著且 effect size 中到大 | 消融证据 | Sec. 5.3.2 / Tables 15-16 |
| P2026-0087 | OLED ARRAY 案例中动态 PM 平均 makespan 降低 2.35%，平均 carbon emissions 降低 0.89% | 工业案例 | Sec. 6.2.1 / Table 18 |
| P2026-0087 | service life threshold 90-150 形成不同 makespan-carbon trade-off，作者给出排放优先/均衡/交期优先建议区间 | 敏感性证据 | Sec. 6.2.2 |
| P2026-0087 | Data availability 为数据可按请求提供 | 数据可得性 | Data availability |

## 证据边界

- 当前直接证据来自 P2026-0087 一篇论文。
- 关键函数公式多为图片占位，复现需核对 PDF 或代码。
- Benchmark processing times 随机生成，真实案例规模较小且匿名。
- 真实案例中机器初始未使用、service life thresholds 较低，作者承认改进幅度适中。
- 模型未纳入随机故障、processing time uncertainty、维护资源约束、TOU 电价和维护成本目标。
- 求解器 CHIO-DECM 与模型/PM 插入策略耦合展示，模型层的收益还需在其它 MOEA/精确启发式上验证。

## 待确认

- service-age energy curve 和 PM-time curve 在不同机器、产品和工况下如何校准；
- PM 插入导致后续任务右移后，增量重算碳排和机器年龄的高效实现；
- 动态 PM 与 machine shutdown/restart、speed scaling、worker fatigue、spare parts 之间的联合优先级；
- service life threshold 是否应作为决策变量进入 Pareto 搜索；
- random failure scenarios 与 preventive PM threshold 的鲁棒折中。
