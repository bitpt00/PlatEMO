---
knowledge_id: K-component-schema-preservation-reconstruction
name: 可分解组件的 schema 级保存与重构
type: method
status: active
source_papers: [P2026-0206]
aliases: [schema-guided solution reconstruction, SGSR, adaptive elite schema preservation, AESP, schemata repository, component-level reconstruction, building-block preservation, 模式级重构, 组件仓库, 优质组件保存]
promotion_reason: 单篇论文提出但接口明确，包含组件/schema 定义、当前种群+仓库合并、按组件位置构造 ranking matrix、最差组件定向替换、跨组件约束重评、age-based repository 更新，可直接改造由多个可局部评价组件组成的 CMOEA 或多智能体路径/调度算法。
---

# 可分解组件的 schema 级保存与重构

## 核心内容

当一个完整解由多个相对独立但又存在全局耦合约束的组件组成时，不只按完整解优劣决定保留和淘汰。算法维护一个 component/schema repository，把差解中仍有价值的组件保存下来；周期性识别当前解中最差的组件，用同位置或兼容位置的优质组件替换，然后重新评价完整解来验证跨组件约束。

P2026-0206 的 SGCMOEA 实例中，一个多 UAV 路径规划解由多条单 UAV 路径组成，每条 UAV path 是一个 schema。SGSR 在当前种群和 schema repository 中为每个 UAV 位置构造 ranking matrix，找到目标解中最差 UAV path，并用同位置最优 UAV path 替换。AESP 则在重构成功或失败后都尝试把候选 schema 写入仓库，并用 age-based replacement 防止仓库陈旧。

```text
complete solution = component_1 + ... + component_M
-> evaluate full solution and component-level contributions
-> keep schema repository with age
-> periodically merge population and repository
-> rank components at each position
-> replace worst component with best compatible component
-> reevaluate coupled constraints
-> update population and repository
```

## 建立理由

- 为什么值得独立维护：
  - 很多多目标工程问题的完整解是多路径、多机器、多任务、多模块或多子系统的组合；
  - 整解级选择会把差整体中的优质组件一起淘汰，浪费 building blocks；
  - 单独多种群演化每个组件会带来协调和全局约束评价负担；
  - schema repository 与定向重构提供了介于整解搜索和多种群分解之间的轻量接口。
- 单篇具体方法的直接复用价值：
  - P2026-0206 给出 SGSR Algorithm 2、AESP Algorithm 3、schema ranking matrix、age vector、重构验证和组件消融；
  - 在六个真实地形 MUPP 实例上，SGCMOEA 的 SR 全部为 100%，HV 全部最佳；
  - 组件实验显示 AESP 和 SGSR 都有贡献，分别影响约束满足和 HV。
- 与已有设计知识的区别：
  - 不同于“变量自适应 UPF 档案重构”：该知识按变量类型与阶段重构整个人口；本知识按完整解内部组件保存和替换 schema。
  - 不同于“层级路径重构的约束感知 MRTA”：该知识围绕路线/机器人层级和特定电量/容量瓶颈修复；本知识是通用 component-level schema repository 与重构机制。
  - 不同于“Top-K 感知的共享组件集合双层搜索”：该知识优化最终方案集共享变量；本知识保存和复用解内部局部组件。
  - 不同于“非支配掩码相似性引导的稀疏模式继承”：该知识继承稀疏 mask 模式；本知识处理任意可分解组件并带跨组件约束验证。

## 解决的问题

- 适用场景：
  - 完整解由多个组件组成，如多 UAV path、多机器人 route、多机器 schedule、多产品模块、多子系统设计；
  - 每个组件至少有一部分目标或约束可局部评价；
  - 存在少量跨组件约束或全局目标，需要重构后整体验证；
  - 低质量完整解中可能包含高质量组件；
  - 纯整解选择导致 building block 丢失，而纯多种群分解协调成本过高。
- 现有方法为什么会失败或不足：
  - 整解级 CDP、Pareto selection 或 scalar fitness 会把组件价值混在一起；
  - 一个组件的优劣可能被其他组件的严重约束违反掩盖；
  - 多种群方法需要组合不同子种群个体才能评价全局目标，规模增加时协调复杂；
  - 普通 archive 只保存完整非支配解，不保存差解中的局部可行结构。
- 仍需解决的问题：
  - 组件之间强耦合时，单组件排名可能误导；
  - 组件位置不完全同构时，需要映射或修复；
  - 仓库过大或更新过频会增加评价成本；
  - 保存失败重构中的组件可能保留噪声，需要后续验证机制。

## 为什么可能有效

```text
complete solutions may be poor because of a few bad components
-> other components can still be feasible and high-quality
-> component ranking exposes reusable building blocks
-> targeted replacement repairs the worst component
-> full reevaluation filters harmful combinations
-> age-based repository keeps fresh reusable components
```

关键假设是：组件级优劣在一定程度上可迁移。也就是说，同一位置或兼容任务中的优质组件，插入另一个完整解后有较大概率仍能改善目标或约束；若全局耦合极强，组件脱离原上下文后质量不稳定，本机制收益会下降。

## 实现接口

- 输入：
  - 当前 population；
  - schema repository；
  - 组件划分方式；
  - 每个组件的局部目标/约束贡献；
  - 跨组件约束或完整解验证函数；
  - 组件 age 或 freshness 记录。
- 输出：
  - 重构后的 population；
  - 更新后的 schema repository；
  - schema ranking matrix 和 age vector。
- 插入位置：
  - 常规子代生成与环境选择之后，作为周期性 repair/reconstruction operator；
  - 也可作为 restart、局部搜索或 infeasible solution mining 模块。
- P2026-0206 的默认实例：
  - 每条 UAV path 是一个 schema；
  - 每 5 generations 触发 schema-guided mechanism；
  - `G = P_g union K`；
  - 对每个 UAV 位置 `k`，从 `G` 抽取 schema set `U_k`；
  - 用 CDP 对 `U_k` 排名，可行 schema 优先，可行时按 ASF，不可行时按 total CV；
  - 目标解中 ranking 最差的位置为 `w`；
  - 从 `G` 找第 `w` 个位置 ranking 最好的 schema `pi_best`；
  - 用 `pi_best` 替换目标解的第 `w` 个 schema 得到 `y`；
  - 重算跨 UAV collision constraint `h5` 并用 CDP 验证；
  - AESP 用 age 最大的 repository solution 尝试接收候选 schema，若改善则更新并重置 age。

## 如何用于算法创新

### 局部创新

- 将固定每 5 代触发改为停滞触发、可行率触发或 HV 改善率触发。
- 对每个组件位置维护不同触发频率，优先修复贡献差、约束违反高或历史失败多的位置。
- 用 surrogate 预测 schema replacement 后的完整解质量，只对 promising replacements 做真实评价。
- 在 repository 中记录组件上下文标签，如任务位置、资源状态、时间窗、邻接组件和约束冲突类型。
- 从单组件替换扩展到 top-k 组件联合替换，并用轻量冲突检测筛选组合。
- 对组件 ranking 引入多样性，避免 repository 被相似 schema 占满。

### 结构创新

- 构建通用 component-level CMOEA：

```text
global population
component repository
component quality evaluator
context-aware reconstruction
full-solution verifier
repository freshness manager
```

- 在多机器人任务分配中保存局部可行 route fragments，用于修复新解中的拥堵、能量或时窗瓶颈。
- 在生产调度中保存机器级/工序段级优质 schedule blocks，用于替换导致 tardiness 或能耗高的区段。
- 在模块化工程设计中保存子系统设计块，在满足接口约束后组装完整系统。
- 与约束优先级机制结合：先识别哪类约束由哪个组件触发，再从 repository 中选择对应修复 schema。

## 适用条件与风险

- 适用条件：
  - 组件边界清楚；
  - 组件有可复用意义，而不是完全依赖全局上下文；
  - 至少部分目标/约束可局部分解或增量更新；
  - 完整解验证成本可接受；
  - repository 中组件与目标解组件位置同构或可映射。
- 不适用或可能失效的条件：
  - 所有目标/约束都强耦合，单组件质量不可定义；
  - 组件插入后需要大规模级联修复；
  - repository 保存的组件与当前任务位置、资源状态或时序上下文不兼容；
  - 频繁重构破坏全局协同结构，导致搜索振荡；
  - 组件 ranking 只看可行性，忽略多样性或长期潜力。
- 计算与实现成本：
  - 需要维护 schema repository、ranking matrix 和 age vector；
  - 组件局部贡献需要缓存；
  - 跨组件约束仍需重算；
  - 若组件数和 repository size 很大，ranking 与验证成本会明显增加；
  - 可用 surrogate、采样排名或分批更新降低成本。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0206 | MUPP 完整解由所有 UAV 控制点串接而成，每个 UAV control point sequence 被定义为 schema unit | 问题编码/作者定义 | Sec. III-A，Fig. 2，PDF 4 |
| P2026-0206 | Motivation example 显示整体更差的 Solution 2 含 UAV1/UAV3 的零约束违反路径，整解淘汰会丢失优质 schema | 问题诊断 | Sec. II-D，Table I/Fig. 1，PDF 3-4 |
| P2026-0206 | SGCMOEA 在 MOEA/D-CDP 上每 5 代执行 SGSR 和 AESP | 完整流程 | Sec. IV-A，Algorithm 1，PDF 6-7 |
| P2026-0206 | SGSR 合并 population 和 repository，按 UAV 位置构造 ranking matrix，并用同位置最优 schema 替换目标解最差 schema | 作者提出的方法 | Sec. IV-B，Algorithm 2，PDF 7 |
| P2026-0206 | `f1/f2/h1-h4` 可复用单 UAV 局部贡献，`h5` 因跨 UAV 交互需替换后重算 | 实现接口/证据边界 | Sec. IV-B/C，PDF 7-8 |
| P2026-0206 | AESP 验证重构是否优于原解，成功/失败均提取候选 schema，并用 age-based 规则更新 repository | 作者提出的方法 | Sec. IV-C，Algorithm 3，PDF 8 |
| P2026-0206 | SGCMOEA 在六个真实地形 MUPP 实例上 SR 均为 100%，其他算法在 UMP3A/UMP3B 明显退化 | 实验支持 | Sec. V-C，Table III，PDF 9 |
| P2026-0206 | SGCMOEA 在六个实例上 HV 全部最佳，Wilcoxon 检验显示相对对比算法显著优或不劣 | 实验支持 | Sec. V-C，Table IV，PDF 10 |
| P2026-0206 | Schema contribution rate 初期为 100%，中期降至 10%-30%，后期仍周期性上升，说明 schema transfer 持续有效 | 机制分析 | Sec. V-E，Fig. 7，PDF 10-11 |
| P2026-0206 | 去掉 AESP 时 SR 降至 97%，去掉 SGSR 时 HV 降低，完整 SGCMOEA 在 UMP2A/UMP2B HV 和 SR 最好 | 消融支持 | Sec. V-F，Table V，PDF 11 |

## 证据边界

- 当前主要证据来自多 UAV path planning；迁移到其他组合/调度问题需重新定义 schema 和兼容位置。
- SGCMOEA 的运行时间较长，作者明确计划用 surrogate-assisted optimization 降低成本。
- 当前正文实验最多 7 UAV，更大 fleet 下 schema ranking、repository 和跨 UAV collision verification 的成本仍需验证。
- 组件 ranking 对 `h5` 这类跨组件约束只能间接处理，组合后仍可能失败。
- AESP/SGSR 的消融只在 UMP2A/UMP2B 主文呈现，更多参数敏感性在 supplementary 中。

## 待确认

- 如何自适应选择 schema update interval；
- repository size、age 更新和多样性维护如何影响长期搜索；
- 强耦合组件问题中是否应从单组件替换改为多组件联合替换；
- 组件兼容性是否需要 learned context embedding；
- surrogate 是否能可靠预测 schema replacement 后的跨组件约束；
- 是否能在动态 MUPP 或在线重规划中复用历史 schema repository。
