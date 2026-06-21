---
knowledge_id: K-right-shift-speed-scaling-energy-decoding
name: 右移-调速协同节能解码
type: method
status: active
source_papers: [P2026-0145]
aliases: [EEDS, energy-efficient decoding scheme, right-shift speed scaling, right-shift policy with machine speed adjustment, flexible machine speed decoding, 右移节能解码, 调速节能解码, 柔性机器速度解码]
promotion_reason: P2026-0145 单篇提出但接口清楚：在 ODS 可行 schedule 后计算 idle window，按最后作业/最后机器/其他机器规则右移加工区间并更新速度矩阵，可在不增加 makespan 的前提下降低 TEC；该机制可迁移到带可变加工速度的 flow shop、job shop、distributed scheduling 和绿色制造调度。
---

# 右移-调速协同节能解码

## 核心内容

在带 flexible machine speeds 的调度问题中，不只对已有 idle gap 做被动降速，而是在可行 schedule 上主动右移部分加工区间，制造额外可控 idle window。随后用这些窗口降低前序 job 或当前 job 前一台 machine 的 processing speed，在不增加 makespan 的前提下减少加工能耗和空闲能耗。

```text
编码个体 -> ODS/普通解码得到可行 schedule
-> 计算每个 job-machine 的可用 idle time
-> 对最后作业、最后机器、其他机器分情况反向处理
-> right-shift 当前工序加工区间
-> 为前序工序或前一机器创造 idle window
-> 降低可被窗口吸收的加工速度
-> 更新速度矩阵与 TEC
```

P2026-0145 的 LBMA 还采用阶段式使用：前期用 ODS 保持小 makespan 区域探索，后期切换到 EEDS 强化 energy objective。这样避免过早降速导致种群过度偏向低能耗而丢失短 makespan 区域。

## 建立理由

- 为什么值得独立维护：
  - 可变机器速度是绿色调度中的常见辅助决策，但普通速度修正只利用已有 idle time；
  - 右移加工区间可以主动创造更多可用调速窗口，和单纯后向 idle compression、机器启停策略不同；
  - 该机制在解码层实现，不依赖特定交叉/变异算子，适合嵌入 MA、NSGA-II、MOEA/D 或局部搜索框架。
- 与已有设计知识的区别：
  - 不同于“非支配排名驱动的辅助速度决策修正”：该知识用 rank 比较和逐弧/逐变量修正速度；本知识用 schedule 时间结构产生可调速窗口。
  - 不同于“前向事件解码与反向能耗压缩调度”：该知识面向有限 buffer/reentrant flow shop 的可行事件解码和后向 idle 压缩；本知识面向 flexible machine speeds 的 right-shift + speed scaling。
  - 不同于“能量反馈自适应机器重启调度”：该知识决定 standby/shutdown/restart；本知识不改变机器开关状态，而调节加工速度和工序时间位置。

## 解决的问题

- 适用场景：
  - flow shop、permutation flow shop、distributed flow shop、job shop 或 hybrid flow shop；
  - machine processing speed 可离散或连续调节；
  - 目标同时包含 makespan、TEC、carbon emission 或 energy cost；
  - 已有解码器能生成满足 precedence 和 machine capacity 的可行 schedule；
  - 降速会延长 processing time，但可被 idle window 吸收。
- 现有方法为什么会失败或不足：
  - earliest-start decoding 容易留下长 idle gaps，但不主动重排可用窗口；
  - 只降低非关键路径工序速度可能受已有 slack 限制；
  - 单纯 machine speed adjustment 缺少与 right-shift policy 的显式协同；
  - 若在搜索早期全量节能解码，可能让种群忽略短 makespan 解。
- 仍需解决的问题：
  - 如何在连续速度、setup time、transport resource 和 machine on/off 控制共存时保证可行；
  - 如何决定何时切换 ODS/EEDS 或对哪些个体启用 EEDS；
  - 如何在能耗下降与多样性保持之间设置二级接受准则。

## 为什么可能有效

```text
加工速度越低通常加工能耗越低
-> 降速会延长加工时间
-> schedule 中存在 precedence 和 machine idle windows
-> right-shift 可把空闲窗口重新分配到更有降速价值的位置
-> 降速延长的加工时间被窗口吸收
-> makespan 不变但 TEC 下降
```

关键假设是：速度降低带来的能耗收益大于右移后可能增加或重分布的 idle 代价，并且 schedule 中存在足够 slack 可吸收延长加工时间。如果所有机器都处于紧关键路径，EEDS 可用空间会很小。

## 实现接口

- 输入：
  - ODS 或其他解码器生成的可行 schedule；
  - 每个 job/machine 的 base processing time；
  - speed level set 和速度-功率函数；
  - precedence、machine capacity、factory assignment 和 job sequence；
  - 当前 `SS` speed matrix。
- 输出：
  - 更新后的 `SS`；
  - right-shift 后的 start/completion times；
  - makespan 和 TEC。
- 插入位置：
  - 调度型 MOEA/MA 的 decode/evaluation 层；
  - local search 后的 energy repair；
  - external archive 后处理，用于在不改变主结构的情况下降低能耗；
  - 多解码器 portfolio 中的 energy-focused decoder。
- P2026-0145 的默认实例：
  - 对 DHPFSP-FMS 使用三层编码 `JS/FS/SS`；
  - 先用 ODS 将每个 factory 转化为单工厂 PFSP-FMS schedule；
  - 根据三类 situation 计算 `I(i,k)` available time；
  - 对最后 job、最后 machine、其他 machines 按 reverse order 应用调速规则；
  - `NFE <= lambda * MaxNFEs` 时使用 ODS，之后使用 EEDS；
  - EEDS 相对 ODS 额外复杂度为 `O(N x K)`。

## 如何用于算法创新

### 局部创新

- 把 fixed stage switch 改为自适应触发：当 archive 的 makespan 极端点稳定后再启用 EEDS。
- 将 right-shift 的候选工序按单位能耗收益排序，而不是完全按反向顺序处理。
- 对同一 schedule 生成多个 energy-refined variants，作为 Pareto 前沿低 TEC 端加密。
- 将速度调整和 TOU electricity price 结合，把高电价区间右移或降速。
- 把 right-shift 后的 speed change 作为局部搜索 action，由 bandit 或成功率反馈选择。

### 结构创新

- 构建双解码器调度 MOEA：

```text
主结构搜索 -> ODS 评价 makespan 端
           -> EEDS 评价 energy 端
           -> archive 合并两类解
           -> 根据 PF 缺口调度解码器调用比例
```

- 与机器启停策略结合：先用 EEDS 降低 processing energy，再对无法利用的长 idle gaps 判断 shutdown/restart。
- 与调度数字孪生结合：用真实功率曲线校准 speed-power 函数和 right-shift 可执行窗口。
- 与多任务/多种群结合：一个种群保持 ODS 快速探索，另一个种群执行 EEDS 能耗开发，再通过 archive 交换解。

## 适用条件与风险

- 适用条件：
  - 机器速度可调且低速有明确能耗收益；
  - processing time 会随速度变化，并且可以被 schedule slack 吸收；
  - precedence/machine capacity 可在右移后快速校验；
  - 能耗模型能区分 processing energy 和 idle energy。
- 不适用或可能失效的条件：
  - 速度降低不显著省能，或低速反而造成单位能耗上升；
  - schedule 几乎无 slack，right-shift 难以创造有效窗口；
  - 工序存在严格 due date、time window 或同步约束，右移会破坏可执行性；
  - setup、transport、worker 或 thermal constraints 比 machine speed 更主导；
  - 早期过度使用 EEDS 导致 makespan 端探索不足。
- 计算与实现成本：
  - 需要为每个候选 schedule 遍历 job-machine idle windows；
  - P2026-0145 报告相对 ODS 增加 `O(N x K)`；
  - 若加入连续速度优化、增量重排或多资源校验，成本会继续上升。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0145 | 作者指出现有 DHPFSP-FMS 多依赖独立 machine speed adjustment，而本文把 right-shift policy 与 speed adjustment 协同使用 | 文献差异/动机 | Sec. 2.2，PDF 3 |
| P2026-0145 | EEDS 在 ODS schedule 后根据三类 available time situation 调整 processing time 和 machine speed | 作者提出的方法 | Sec. 4.2，PDF 7-8 |
| P2026-0145 | EEDS 通过右移当前 job processing period，为前序 job 或前一 machine 创造 idle windows，从而允许降速并降低 TEC | 作者机制解释 | Sec. 4.2，PDF 8 |
| P2026-0145 | LBMA 前期使用 ODS，后期使用 EEDS，以避免过早降速导致小 makespan 区域探索不足 | 作者提出的方法/边界 | Sec. 4.1-4.2，Algorithm 1，PDF 7-8 |
| P2026-0145 | Fig. 14 的 6 个代表实例显示节能策略显著降低 TEC，且 EEDS 优于传统 speed adjustment 策略 | 组件实验支持 | Sec. 5.4，Fig. 14，PDF 16 |
| P2026-0145 | Gantt chart 对比显示 EEDS 相比传统节能策略得到更优 schedule | 机制展示 | Sec. 5.4，Figs. 15-16，PDF 16-17 |
| P2026-0145 | 综合对比中 LBMA 在 22 个实例上 HV/GD/Spread 全面领先，并平均降低 makespan 1.36%、TEC 6.18% | 综合实验支持 | Sec. 5.5，Tables 13-17，PDF 17-19 |
| P2026-0145 | 作者承认 EEDS 需检查所有机器，相对 ODS 复杂度增加 `O(N x K)` | 边界/复杂度 | Conclusion，PDF 18 |

## 证据边界

- 当前直接证据来自 P2026-0145 一篇论文。
- EEDS 与 LBMA 的初始化、LNSS、交叉变异和 NSGA-II 环境选择共同出现，Fig. 14 单独支持节能策略，但综合性能不能完全归因于 EEDS。
- 文中展示了 6 个代表实例的节能对比，未逐表给出所有 22 个实例 EEDS 相对传统策略的显著性检验。
- 该方法目前只在 DHPFSP-FMS 上验证，跨 job shop、hybrid flow shop、动态调度和连续速度场景仍需测试。
- 能耗模型依赖速度-功率关系；真实设备可能受热稳定、维护、安全联锁和工艺质量约束影响。

## 待确认

- ODS/EEDS 切换点是否应按 archive 稳定性、makespan 极端点或 TEC 改善率自适应；
- right-shift 操作和 machine shutdown/restart 策略联合时的优先顺序；
- 连续速度或非凸速度-功率函数下，局部降速是否仍可用简单规则处理；
- 有 setup time、transport resource、worker assignment 和 due-window 约束时如何增量校验可行性；
- 是否能将 EEDS 作为 archive 后处理，以较低频率调用来降低计算成本。

