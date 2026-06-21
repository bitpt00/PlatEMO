---
knowledge_id: K-energy-feedback-adaptive-machine-restart-scheduling
name: 能量反馈自适应机器重启调度
type: method
status: active
source_papers: [P2026-0020]
aliases: [energy feedback restart-aware scheduling, adaptive machine restart threshold, worker-aware machine restart, restart-aware EDFJSP, idle energy restart threshold, 能量反馈重启阈值, 机器启停自适应调度, 人机协同机器重启]
promotion_reason: P2026-0020 单篇提出但接口完整：在调度解码时比较 idle standby 与 shutdown/restart 能耗，再用累计重启次数、能量反馈比例和 sigmoid 动态因子更新重启阈值；消融、阈值收敛分析、真实航天复材车间验证和与静态阈值的对比共同支持其可迁移到绿色 job shop、flow shop 和人机协同制造调度。
---

# 能量反馈自适应机器重启调度

## 核心内容

在绿色制造调度中，不把机器 idle gap 一律保持 standby，也不只用固定阈值决定 shutdown/restart。对每个机器空闲区间，先比较持续 standby 能耗与一次 shutdown + restart 的转换能耗；若重启有节能潜力，再用动态阈值控制是否真的触发重启。阈值同时依赖当前 idle/restart 能量比例、累计重启次数和 idle interval 位置，使算法在节能、设备寿命和工人可操作性之间折中。

```text
decode schedule
-> identify machine idle gaps
-> compare standby energy with shutdown/restart energy
-> update base threshold from energy feedback ratio
-> raise effective threshold with cumulative restart count
-> trigger only worthwhile restart decisions
-> evaluate makespan, carbon emission and worker workload
```

P2026-0020 的具体实例是 DRC-EDFJSP-WMR：每次重启需要 worker assignment，因此重启策略不只是机器状态后处理，而是与 operation sequencing、machine selection 和 worker assignment 共同影响 schedule feasibility 与目标值。

## 建立理由

- 为什么值得独立维护：
  - 机器 idle/on/off 控制是绿色调度中的高频结构，但固定 idle threshold 易在不同实例、不同机器负载和不同重启次数下失效。
  - 只比较一次 idle energy 与 transition energy 会忽略频繁启停的设备磨损。
  - P2026-0020 给出可直接嵌入 decoder 的阈值公式、参数范围、消融与真实制造案例，不依赖特定 NSGA-III 实现。
- 与已有设计知识的区别：
  - 不同于“前向事件解码与反向能耗压缩调度”：该知识通过后向移动操作压缩 idle time；本知识决定 idle gap 是否进入 shutdown/restart 状态，并显式用累计重启次数抑制设备磨损。
  - 不同于普通 evolutionary restart 或 population restart：这里的 restart 是生产设备启停决策，不是优化算法重启。
  - 不同于 worker fatigue scheduling：本知识关注机器状态与工人重启操作耦合，不直接建模疲劳恢复。

## 解决的问题

- 适用场景：
  - job shop、flexible job shop、distributed FJSP、flow shop 或 hybrid flow shop；
  - 目标包含 energy consumption、carbon emission、peak energy 或 maintenance/longevity；
  - schedule 中存在可识别的 machine idle gaps；
  - machine startup/shutdown time 与 power 可估计；
  - 机器重启需要人员、机器人或控制资源配合。
- 现有方法为什么会失败或不足：
  - 固定 restart threshold 不能随 idle gap 结构和能耗构成变化；
  - 仅以 `restart energy < standby energy` 为条件会导致短期节能但频繁启停；
  - 只压缩 idle time 不能处理无法消除的长 idle gap；
  - 忽略 worker availability 时，重启可能在 schedule 上不可执行或造成延迟。
- 仍需解决的问题：
  - 如何把真实维护成本、故障风险和热机/冷机状态纳入阈值；
  - 如何与工人技能、疲劳、班次和安全操作规则耦合；
  - 如何在动态新订单、机器故障或实时电价下在线更新阈值。

## 为什么可能有效

```text
long idle gaps waste standby energy
-> shutdown/restart can reduce carbon emission
-> too many restarts accelerate wear
-> energy feedback lowers/relaxes threshold when idle energy dominates
-> cumulative restart penalty increases effective threshold
-> decoder avoids both idle waste and restart overuse
```

关键假设是：idle gap 的 standby energy、shutdown/restart energy 和重启次数能较准确估计，且设备磨损可用累计重启次数的单调惩罚近似。如果设备寿命主要由温度、负载冲击、加工类型或维护状态决定，仅用 `log(1+r_i)` 可能过粗。

## 实现接口

- 输入：
  - schedule 解码后每台机器的相邻工序 idle intervals；
  - idle power `IP_k`、shutdown power `SP_k`、restart power `RP_k`、shutdown time `ST_k`、restart time `RT_k`；
  - 当前机器或全局累计重启次数 `r_i`；
  - base threshold `B`、反馈系数 `alpha`、小常数 `epsilon`；
  - 动态因子范围 `[k_min,k_max]` 或 `k_best`。
- 输出：
  - 每个 idle gap 的 machine state：standby 或 shutdown/restart；
  - startup/shutdown 能耗、idle 能耗和对应碳排；
  - 若考虑 worker-aware restart，还输出负责重启的 worker assignment。
- P2026-0020 的默认实例：
  - standby energy：`E_i = IP_f * I_i`；
  - restart energy：`ES_i = SP_f * ST + RP_f * RT`；
  - dynamic threshold：`T_i = B * (1 + k_i * log(1 + r_i))`；
  - energy feedback ratio：`R = E_idle / (E_idle + E_re + epsilon)`；
  - base threshold update：`B <- B * (1 - alpha * R)`；
  - dynamic factor：`k_i = k_min + (k_best-k_min)/(1+exp(-0.1*(i-N_idle/2)))`；
  - 参数：`k_min=0.5`，`k_best=0.8`，`k_i` 范围 `[0.5,1]`。
- 插入位置：
  - permutation 或 multi-part chromosome 的 schedule decoder；
  - energy-aware local search 后的 schedule evaluation；
  - multi-objective scheduling 的 carbon/energy objective calculation；
  - 数字孪生或仿真平台的 schedule feasibility checker。
- 最小实现：

```text
for each machine k:
    r <- restart_count(k)
    for each idle gap i in chronological order:
        E_standby <- IP[k] * idle_time[i]
        E_restart <- SP[k] * ST[k] + RP[k] * RT[k]
        R <- E_standby / (E_standby + E_restart + eps)
        B <- B * (1 - alpha * R)
        k_i <- sigmoid_factor(i, N_idle, k_min, k_best)
        T_i <- B * (1 + k_i * log(1 + r))
        if E_restart < E_standby and saving_or_gap_score(i) >= T_i:
            assign restart worker if required
            mark gap as shutdown/restart
            r <- r + 1
        else:
            mark gap as standby
```

`saving_or_gap_score` 需要按具体论文或系统定义实现。P2026-0020 给出了阈值更新和能耗比较，但 Markdown/PDF 抽取中没有独立伪代码列出该 score 的全部工程细节；复用时应将其绑定到 idle time、energy saving 或 carbon saving 的同尺度量。

## 如何用于算法创新

### 局部创新

- 将 `B` 的更新从单一 energy ratio 扩展为 energy + maintenance + electricity price + worker availability 的多因素反馈。
- 用 per-machine threshold 替代全局 threshold，让高价值/高磨损设备更保守，低风险设备更积极节能。
- 将 `log(1+r_i)` 替换为设备健康模型、剩余寿命估计或维修计划窗口。
- 把 restart decision 做成 local search action：对关键 idle gaps 尝试 standby/restart 翻转，并用 Pareto archive 反馈收益。
- 与 TOU electricity price 结合：高电价时降低阈值，低电价或设备热稳定要求高时提高阈值。

### 结构创新

- 构建 restart-aware decoder：

```text
multi-resource chromosome
-> feasible schedule generation
-> adaptive restart state assignment
-> energy/carbon/longevity evaluation
-> Pareto environmental selection
```

- 与 RL/meta-controller 结合：将 restart threshold parameters 或 standby/restart actions 纳入 action space，reward 同时考虑碳排、makespan、workload 与维护成本。
- 与 worker-aware scheduling 结合：重启操作占用工人或机器人，把 restart feasibility 作为资源约束，而不是简单能耗后处理。
- 与数字孪生结合：用实际 idle energy、startup current、maintenance events 和 missed restart logs 持续校准 `B/alpha/k_i`。

## 适用条件与风险

- 适用条件：
  - idle gaps 足够多且 standby energy 占比较高；
  - startup/shutdown time 不会显著破坏工序 precedence；
  - 能获得机器 idle/startup/shutdown power；
  - 允许在调度层控制机器待机、关机和重启；
  - 现场有人员或自动控制资源执行重启。
- 不适用或可能失效的条件：
  - 机器不允许频繁启停，或启停过程存在复杂安全审批；
  - 重启时间高度随机，导致 schedule feasibility 难保证；
  - 能耗主要来自加工负载而非 idle/standby；
  - 设备磨损不是累计重启次数的单调函数；
  - 工人或机器人重启资源比机器 idle 更瓶颈。
- 计算与实现成本：
  - 解码时需要遍历所有 machine idle gaps，通常低于完整环境选择或局部搜索成本；
  - 若 worker-aware restart 需要额外分配工人，可能引入资源冲突检查；
  - 部署前需要校准 power、time、carbon coefficient 和维护风险参数。
- 决策风险：
  - 动态阈值若过低可能产生短期碳排优势但增加维护成本；
  - 阈值若过高会退化为 standby 策略，节能收益下降；
  - 只在仿真参数上验证的阈值需要现场数据校准。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0020 | DRC-EDFJSP-WMR 将 machine restart-aware 与 worker assignment 同时纳入 distributed flexible job shop，目标为 makespan、total carbon emissions 和 maximum worker workload | 问题建模 | Sec. 3，PDF 4-7 |
| P2026-0020 | 论文比较 standby energy `E_i=IP_f*I_i` 与 worker-aware restart energy `ES_i=SP_f*ST+RP_f*RT`，说明只有 `ES_i<E_i` 时 restart 才有节能价值 | 能耗分析 | Sec. 3.1，PDF 4 |
| P2026-0020 | 每次 machine restart 必须分配 worker，约束 (15) 明确 restart decision 与 worker assignment 的耦合 | 约束建模 | Sec. 3.3，PDF 6-7 |
| P2026-0020 | 提出 `T_i=B(1+k_i log(1+r_i))`，用累计重启次数和动态因子控制第 `i` 个重启阈值 | 作者提出的方法 | Sec. 4.3.2，Eq. (30)，PDF 9 |
| P2026-0020 | 用 `R=E_idle/(E_idle+E_re+epsilon)` 更新 base threshold `B <- B(1-alpha R)`，使阈值随 idle/restart 能耗反馈变化 | 作者提出的方法 | Sec. 4.3.2，Eq. (31)-(32)，PDF 9 |
| P2026-0020 | `k_i` 通过 sigmoid 在 `[0.5,1]` 范围内变化，实验确定 `k_best=0.8` | 作者提出/参数设置 | Sec. 4.3.2、Table 5，PDF 9、13 |
| P2026-0020 | 消融中加入 energy feedback restart 的 `QMOMA02` 显著优于无 restart-aware baseline `QMOMA01`，作者据此确认 restart strategy 有效 | 消融实验支持 | Sec. 5.5.1，Table 7，PDF 14-15 |
| P2026-0020 | 作者证明 `T_i` 的收敛可归约到 `B` 的收敛，并指出固定阈值方法缺少自适应和收敛保证 | 理论分析 | Sec. 5.5.2，PDF 15-16 |
| P2026-0020 | 与文献静态 restart strategy 相比，提出策略触发更多有效重启并避免满足条件但未执行的无效点 | 机制对比 | Sec. 5.5.2，Fig. 8，PDF 15-16 |
| P2026-0020 | EM02/EM04 Gantt charts 标出 Idle 与 Restart，显示机器数量增加时重启频率上升，验证 restart mechanism 的必要性 | 结果解释 | Sec. 5.7，Figs. 14-15，PDF 21 |
| P2026-0020 | WGe01-WGe08 航天复材车间实验中，QMOMA 的 HV 平均提升 22.8%，Friedman HV/IGD mean rank 均为 1.00 | 工程应用支持 | Sec. 5.8，Tables 13-15，PDF 22-26 |
| P2026-0020 | 作者在 discussion 中指出 worker assignment 可为 machine restart 创造有利条件，二者协同能降低碳排并提升执行效率 | 管理/机制解释 | Sec. 5.9，PDF 22 |

## 证据边界

- 当前直接证据来自 P2026-0020 一篇论文，且 restart strategy 与 QMOMA 的增强 reference-point selection、local search 和 Q-learning 同时出现。
- 消融证明加入 restart-aware strategy 有帮助，但未逐项隔离 `B` 更新、`log(1+r_i)`、sigmoid `k_i` 和 worker-aware assignment 的独立贡献。
- PDF 给出阈值公式和能耗比较，但没有完整独立伪代码说明具体 restart trigger score 的所有工程尺度转换，复现时需要结合作者代码或自行定义。
- 真实应用为航天复材车间数据与扩展实例，尚未报告长期现场部署、真实维护成本或设备寿命数据。
- 机器启停动态、热稳定性、安全联锁、worker skill/fatigue 和不确定 restart time 尚未建模。

## 待确认

- `B <- B(1-alpha R)` 与论文文字中“restart energy 过高时提高阈值”的关系如何在作者实现中处理；
- restart threshold 是否按 machine 独立维护，还是在解码/迭代层全局维护；
- worker restart assignment 是否会占用与加工不同的技能/安全资质；
- 在 TOU 电价、动态订单、机器故障和随机 processing time 下，阈值是否仍稳定；
- 与后向 idle compression、variable speed 和 maintenance scheduling 联合时的优先顺序。
