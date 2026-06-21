---
knowledge_id: K-self-paced-emt-mapping-transform-mm-scheduling
name: 自步辅助任务 EMT 与映射变换多模态调度
type: architecture
status: active
source_papers: [P2026-0184]
aliases: [KEMMA, MMFJSP-S, self-paced auxiliary task, evolutionary multitasking scheduling, knowledge-enhanced EMT, mapping transformation environmental selection, multimodal FJSP, variable-speed FJSP, 自步辅助任务, 映射变换环境选择, 多模态调度]
promotion_reason: 单篇论文提出但系统接口完整，包含简化调度辅助任务、skill-factor 隐式迁移、任务特化知识增强、非支配增强精英显式迁移，以及按机器顺序映射后的决策空间去冗余，可直接迁移到带等价解的组合调度和多模态多目标离散优化。
---

# 自步辅助任务 EMT 与映射变换多模态调度

## 核心内容

在带速度、能耗或复杂工艺约束的调度问题中，完整问题的搜索空间很大，但去掉某些高维决策后的简化问题往往保留了主要排程结构。该架构把完整调度问题作为主任务，把简化调度问题作为辅助任务，在 evolutionary multitasking 框架中同时搜索；再用任务特化局部搜索增强两个任务的精英解，把增强后的非支配解显式迁移到另一任务。环境选择阶段不只看目标空间，还把编码映射为更接近实际排程的机器顺序结构，并在映射后的决策空间中删除冗余个体，从而保留多个目标等价但排程不同的解。

```text
main task: full scheduling problem, e.g., FJSP with speed
auxiliary task: simplified scheduling problem, e.g., FJSP without speed
-> skill-factor genetic implicit transfer
-> task-specific knowledge enhancement
-> nondominated enhanced elites explicitly transfer across tasks
-> objective-space clustering
-> map encoding to machine-order schedule representation
-> remove decision-space redundant schedules
```

P2026-0184 的 KEMMA 是该架构的实例：主任务为可变速度 FJSP-S，辅助任务为不含速度选择的 FJSP，目标为 makespan 与 total energy consumption。

## 建立理由

- 为什么值得独立维护：
  - 多模态组合调度中，多个不同排程可能对应相同目标值，普通 PF 导向选择容易丢失等价方案；
  - 简化调度任务能提供低成本结构知识，但直接迁移会因决策维度不同产生负迁移；
  - 原始编码距离不一定反映解码后 Gantt chart 或机器负载结构的相似性；
  - “辅助任务 + 显式知识增强 + 映射后决策空间选择”是可复用的调度算法骨架。
- 单篇具体方法的直接复用价值：
  - P2026-0184 给出 KEMMA、Algorithms 1-4、辅助任务构造、隐式/显式迁移、任务特化 KES、映射变换环境选择、消融实验和十个算法对比。
- 与已有设计知识的区别：
  - 不同于“稀疏三任务 EMT 与保结构迁移”：该知识面向稀疏大规模连续/混合变量，核心是 union/intersection 稀疏结构；本知识面向组合调度多模态，核心是简化调度辅助任务和排程映射距离。
  - 不同于“动态辅助任务构造”：该知识关注辅助任务随阶段生成/选择；本知识的辅助任务来自调度决策维度削减，并配套映射环境选择。
  - 不同于“故障子问题辅助的双种群协同重调度”：该知识的辅助任务来自动态故障局部子问题；本知识用于静态或一般调度中的多模态等价解保留。
  - 不同于通用 MMOP 聚类/生态位方法：本知识强调组合调度解码结构，避免只在原始编码或目标空间维护多样性。

## 解决的问题

- 适用场景：
  - 柔性作业车间、车辆路径、机器人任务分配、生产线调度等组合 MOO；
  - 存在完整任务和简化任务，例如有/无速度选择、有/无部分资源约束、有/无局部扰动；
  - 多个不同决策方案可得到相同或近似相同目标值；
  - 原始编码距离不能代表实际排程结构相似性；
  - 希望最终输出多个可替代方案，而不是只有目标空间代表点。
- 现有方法为什么会失败或不足：
  - 普通 NSGA-II/MOEA/D 只在目标空间选择，会把等价解当作重复点删除；
  - 通用 EMT 只靠交叉迁移，可能在决策维度或约束不同的任务间产生负迁移；
  - 局部搜索若不区分任务，容易在辅助任务上做无意义动作或在主任务上破坏速度/能耗结构；
  - 用编码 Hamming/Euclidean 距离做多模态保留，会误判解码后几乎相同的排程。
- 仍需解决的问题：
  - 如何选择最有帮助的简化任务；
  - 不同任务间转移多少精英、朝哪个方向转移；
  - 排程映射距离如何适配不同编码和约束；
  - 目标等价解需要保留到什么粒度。

## 为什么可能有效

```text
simplified task has smaller search space
-> discovers useful machine/order structure earlier
task-specific local search improves elites before transfer
-> transferred knowledge is less noisy
explicit conversion handles missing/extra decision components
-> reduces negative transfer between different task dimensions
schedule mapping measures decoded structure
-> environmental selection deletes true redundancies, not useful alternatives
```

核心假设是：简化任务与主任务共享关键排程结构，且映射后的机器顺序表示比原始编码更接近实际调度相似性。如果简化任务和主任务目标冲突严重，或映射表示遗漏关键约束，该架构可能误导搜索或保留错误的多样性。

## 实现接口

- 输入：
  - 主调度任务 `T1` 的编码、解码、评价器；
  - 简化调度任务 `T2` 的编码、解码、评价器；
  - 跨任务转换规则，例如补速度、删速度、修复不可行调度；
  - 任务特化局部搜索或 repair operators；
  - objective-space clustering 和 decision-space distance/crowding 规则；
  - 任务分配比例、`RMP` 和 archive 更新规则。
- 输出：
  - 主任务 Pareto front；
  - 多个目标等价或近等价的 Pareto schedules；
  - 可追踪的跨任务迁移 archive。
- 插入位置：
  - 调度类 MOEA 的子代生成阶段；
  - memetic local search 后的 elite transfer；
  - multimodal environmental selection；
  - 多任务或多模型调度优化框架。
- 最小实现：

```text
initialize P with skill factors for T1 and T2
initialize archive Omega

while budget remains:
    Q1 <- genetic_implicit_transfer(P, RMP)
    P <- P union Q1

    E1 <- task_specific_local_search(elites from T1)
    E2 <- task_specific_local_search(elites from T2)
    X12 <- convert nondominated(E1) to T2
    X21 <- convert nondominated(E2) to T1
    P <- P union E1 union E2 union X12 union X21

    P <- environmental_select_by_objectives_and_mapped_schedule(P)
    Omega <- update_archive(Omega, P)
```

## 如何用于算法创新

### 局部创新

- 将固定辅助任务改为多个简化任务，例如无速度、无运输、局部机器子集、低保真工艺时间。
- 用任务贡献、迁移成功率或 negative-transfer detector 动态调整 `alpha`、`RMP` 和显式迁移数量。
- `T2 -> T1` 时不要固定最低速度，可根据 reference point、能耗预算或关键路径 slack 自适应补速度。
- 用图神经网络 schedule embedding 或 operation-machine bipartite embedding 替代手工 `[job,operation,speed]` 映射。
- 在 objective clustering 内加入 preference/ROI，只为决策者关心区域保留多个等价排程。
- 把 KES 替换为领域专用 repair、dispatching-rule mutation、局部 MILP 或 CP-SAT 改善器。

### 结构创新

- 多辅助任务调度 EMT：

```text
full task
-> no-speed auxiliary
-> no-transport auxiliary
-> machine-subset auxiliary
-> disturbance-local auxiliary
-> contribution-gated explicit transfer
```

- 与动态重调度结合：正常调度任务保留全局结构，故障子问题作为辅助任务快速修复，再显式迁移到全局重调度。
- 与多模态指标结合：环境选择同时约束 PF 指标和 PS 指标，例如 IGDX、多实现有效距离或等价解比例。
- 与偏好优化结合：在目标空间接近参考点或 ROI 的簇内加强决策空间去冗余，其他区域只保留少量代表。

## 适用条件与风险

- 适用条件：
  - 可以定义与主任务共享结构的简化任务；
  - 主任务和辅助任务之间有明确、可修复的编码转换；
  - 局部搜索或领域知识能改善调度 elite；
  - 解码后的排程可映射为可比较的结构表示；
  - 用户或下游系统确实需要多个等价/近等价方案。
- 不适用或可能失效的条件：
  - 简化任务与主任务相关性弱，辅助任务优质解在主任务上不可行或很差；
  - 决策维度差异太大，补全/删除变量会系统性偏置搜索；
  - 映射距离忽略关键资源、运输、批处理或工人约束；
  - 多模态保留过强导致收敛压力不足；
  - 局部搜索成本过高，压缩了全局探索预算。
- 计算与实现成本：
  - 需要同时维护两个任务的评价、编码转换和 skill factor；
  - 任务特化 KES 增加领域建模成本；
  - objective clustering 与 decision-space crowding 增加环境选择复杂度；
  - 对大规模调度实例，需要对局部搜索和聚类做增量化或采样。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0184 | 作者指出可变速度 FJSP 中不同排程可得到相同 makespan 和 TEC，存在多模态属性 | 问题诊断 | Introduction，Sec. II，PDF 1-3 |
| P2026-0184 | KEMMA 同时维护主任务 FJSP-S 和简化辅助任务 FJSP，辅助任务不含速度选择且搜索空间更小 | 作者提出的方法 | Sec. III-A，PDF 4 |
| P2026-0184 | Genetic implicit transfer 使用 skill factor 和 `RMP` 决定任务内或跨任务交叉变异，offspring 只在对应任务评价 | 作者组合方法 | Algorithm 2，PDF 5 |
| P2026-0184 | Knowledge enhancement 为主任务设计 N8 与降速策略，为辅助任务设计 N6 与最短加工机台策略 | 作者提出/组合方法 | Sec. III-C，Algorithm 3，PDF 5-7 |
| P2026-0184 | 增强种群中的非支配解被显式转移到另一任务；`T2 -> T1` 补最低速度，`T1 -> T2` 丢弃速度 | 作者提出/组合方法 | Algorithm 3，PDF 6 |
| P2026-0184 | Mapping transformation 将编码映射为按机器顺序的 `[job,operation,speed]`，辅助任务忽略 speed | 作者提出的方法 | Sec. III-D，PDF 7-8 |
| P2026-0184 | 环境选择先按目标空间聚类，再在映射后的决策空间用拥挤距离删除冗余个体 | 作者提出的方法 | Algorithm 4，PDF 7-8 |
| P2026-0184 | Taguchi 参数实验推荐 `N=100`、`alpha=0.9`、`RMP=0.7` | 参数证据 | Sec. IV-B，PDF 8-9 |
| P2026-0184 | 消融中 KEMMA-AT 和 KEMMA-T 明显更差，说明辅助任务与知识迁移对性能重要 | 消融支持 | Sec. IV-C，supplementary tables |
| P2026-0184 | KEMMA 显著优于 KEMMA-KET，说明显式迁移有效；与 KEMMA-GIT/KEMMA-KE 只在部分指标无显著差异 | 消融支持 | Sec. IV-C，supplementary tables |
| P2026-0184 | KEMMA-MTES 排名最差且显著差于 KEMMA，说明映射变换环境选择对多模态调度关键 | 消融支持 | Sec. IV-C，supplementary tables |
| P2026-0184 | 与 MOEA/D、NSGA-II、DSSEA、HREA、BOEA、MO-MFEA、EMTMA、BLKT-DE、NSGA-MSPM、APHMA 对比，KEMMA 整体排名靠前 | 综合对比支持 | Sec. IV-D，PDF 10-13 |
| P2026-0184 | MK02 的 multimodal solution ratio 分析显示 KEMMA 能维持合理等价解比例，部分普通算法因重复或多样性损失接近 0 | 多模态保留证据 | Sec. IV-E，Fig. 10，supplementary |
| P2026-0184 | 作者未来工作包括真实调度多模态属性、知识迁移方向/数量、调度决策空间优化 | 作者局限与未来工作 | Conclusion，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- 具体数值表格和部分邻域定义在图片或 supplementary 中，需回查 PDF/补充材料。
- 实验为 MK/DP benchmark 和设定速度等级，真实车间数据尚未验证。
- KEMMA 同时包含 EMT、KES、mapping selection 和 energy-saving strategy，综合收益不能完全归因于单一组件。
- 映射距离针对 FJSP-S 编码设计，迁移到 VRP、MRTA 或批调度时需要重新定义。

## 待确认

- 简化辅助任务是否应固定为去掉速度，还是根据问题自动选择要删去的决策维度；
- 显式迁移的方向和数量能否由任务相似度或贡献自适应控制；
- 映射后的 schedule distance 是否能处理运输时间、setup time、worker assignment 和 batching；
- 多目标为三目标或 many-objective 时，objective clustering 与 PS 保留如何平衡；
- 与 IGDX、多实现有效距离等 MMOP 指标结合后是否能稳定提升决策空间覆盖。
