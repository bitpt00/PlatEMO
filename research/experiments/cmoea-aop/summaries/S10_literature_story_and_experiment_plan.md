# S10 文献调研、论文故事与后续实验方案

## 1. 调研目的

本轮调研读取了 `E:\多目标优化\MO-Paper-KB\01_papers` 中与约束多目标优化、算子选择、资源分配、双种群/多种群协同和真实应用相关的 2026 年论文卡片。目标不是继续解释 `CMOEA-AOP`，而是从已有 S09 结果中抽象出一个可以独立成文的新算法故事，并确定下一步论文级对比实验的算法、测试集和应用补充。

S09 当前最关键的实验信号是：`Survival-Credit-AOP` 在 33 个论文问题、10 个算法、10 个独立种子、`N=100`、`maxFE=100000` 的内部确认实验中平均排名第一，且没有失败运行。它相对原始 `CMOEA-AOP` 的问题级结果为 24 胜、9 负、0 平。这个信号支持把主线从 `BiSCOP-CMOEA` 调整为更简单、更可解释的 `SCOP-CMOEA`。

## 2. 2026 文献中的共性趋势

近年的 CMOP 论文有一个很明显的共同趋势：大家不再只设计一个新的约束处理规则，而是在问“有限评估预算应该分给谁”。

典型分配对象包括：

- 分给不同约束：例如 DPCMOEA、ARACMO、DPCPRA 一类方法根据约束难度、约束一致性或约束优先级分配搜索资源。
- 分给不同种群或档案：例如 DGCMOEA、ACREA、CMOCEA-DDAP、PFCEA 等方法让主种群、辅助种群或档案承担不同角色，并动态调整辅助强度。
- 分给不同阶段：例如 TriMT-EA、ToP、PPS、DEPEA 等方法把搜索拆成无约束探索、约束回收、CPF 开发等阶段。
- 分给不同策略或算子：例如 CMOEA-AOP、CMOEA-TS、DRLOS 类方法用强化学习或状态反馈选择算子、约束处理技术或其组合。
- 分给不同应用结构：例如 UAV 路径规划用 schema 级组件重构，水库调度用目标约简层级种群，煤矿综合能源调度用时间分块。

这说明我们的切入点可以更大一些：不是“某个算法的 DDPG 是否必要”，而是“在 CMOP 中，offspring generation 的预算也需要被动态分配，并且可以由环境选择产生的生存反馈来完成”。

## 3. 关键论文启发

| 论文 | 方法关键词 | 对我们的启发 |
| --- | --- | --- |
| CMOEA-AOP | DDPG 学习 GA、DE/rand、DE/best 的比例 | 证明 operator portfolio 是有价值的问题，但复杂 RL 不是唯一方案 |
| CMOEA-TS | DQN 选择 CHT + 遗传算子序列 | 说明“策略选择的时间序列”是新趋势，但训练成本和动作空间仍是问题 |
| DPCMOEA | 动态约束优先级与协同 offspring 生成 | 资源调度可以由轻量反馈驱动，而不一定依赖深度学习 |
| ARACMO | 约束难度加权的多辅助种群资源分配 | “资源分配”已经是 2026 CMOP 的主线之一 |
| DGCMOEA | 主/辅种群 Cournot 式动态 offspring 分配 | 资源可以直接体现为 offspring 数量，而不是只改变选择准则 |
| ACREA | leading archive 是否回收约束由 AP/AL 距离决定 | 辅助搜索需要反馈判断，避免长期错误探索 |
| DEPEA | CV 不可信时用 escaping population 主动逃离 UPF | 说明单一可行性信号有时会误导，算法需要保留多种搜索行为 |
| CMOCEA-DDAP | 动态辅助种群、多样性档案、自适应 DE | 算子和种群角色可以协同，但复杂结构未必总带来收益 |
| NMOEA | 小生境内自适应选择搜索算子和 CHT | 局部搜索行为也可以按反馈调整 |
| SGCMOEA / LMSC / TDCEA | UAV schema、水库层级种群、能源时间分块 | 应用论文重视“结构化信息复用”，不是只跑标准 benchmark |

## 4. 建议的论文故事线

建议把主线写成：

> 在约束多目标优化中，真正稀缺的不是算子数量，而是评估预算。不同搜索算子会产生不同类型的 offspring，但只有经过当前约束环境和环境选择检验后仍能存活的 offspring，才真正说明该算子适合当前搜索状态。因此，可以把环境选择从一个“淘汰器”提升为一个“信用分配器”，用 offspring 的生存结果在线调度后续算子组合。

这个故事比“DDPG 是否必要”更适合做论文题目。它不攻击已有算法，也不局限于解释 CMOEA-AOP，而是提出一种新的资源调度思想：

```text
Survival-credit driven offspring resource allocation
```

可以命名为：

```text
SCOP-CMOEA: Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization
```

中文可以写成：

```text
一种生存信用驱动的自适应算子组合约束多目标进化算法
```

核心思想：

- 同一代中同时使用多个互补算子，而不是每代只选一个算子。
- 每个 offspring 保留来源算子标签。
- 环境选择完成后，统计不同算子的 offspring 存活率。
- 用滑动或指数平滑的 survival credit 更新下一代算子比例。
- 设置最小比例下限，避免某个算子被过早淘汰。
- 让“当前问题状态”通过环境选择的结果间接反馈给算子资源分配器。

该故事的优势：

- 轻量：不需要训练 actor-critic，不需要 replay buffer。
- 可解释：每次比例变化都能追溯到 offspring 是否被保留下来。
- 与 CMOP 自然匹配：环境选择已经编码了目标、约束、可行性、多样性等压力。
- 兼容性强：可以嵌入 EMCMO，也可以迁移到其他 CMOEA 框架。
- 实验可讲：S09 已观察到它自然形成早期偏 GA、中后期增加 DE/rand、DE/best 稳定保留的阶段行为。

## 5. 不建议采用的故事线

不建议把论文写成以下形式：

- “CMOEA-AOP 的 DDPG 没有必要。”
- “我们解释了 CMOEA-AOP 的效果来源。”
- “我们提出 CMOEA-AOP 的简化版。”

这些说法会把论文的格局缩小到对一个算法的消融解释。更好的表达是：

> 我们提出一种基于 offspring survival feedback 的算子资源调度方法，它用环境选择产生的自然反馈来在线调配搜索行为。

这样即使后续外部对比中性能不是所有算法第一，也可以作为一种清晰、低成本、可解释的新方法成立。

## 6. 对比算法建议

### 6.1 最小论文级对比集合

建议第一批正式外部对比使用 10 个算法：

| 类别 | 算法 | 选择理由 |
| --- | --- | --- |
| 我们方法 | SCOP-CMOEA | 主方法 |
| 骨架基线 | EMCMO | 证明收益来自 operator portfolio，而不是基础框架 |
| 直接相关 | CMOEA-AOP | DDPG operator portfolio，必须比较 |
| 直接相关 | DRLOS-EMCMO | RL 单算子选择，区分“单算子选择”和“组合比例” |
| 经典约束处理 | C-TAEA | 双档案经典强基线 |
| 经典多阶段 | PPS | push-pull search，CMOP 常用强基线 |
| 经典多阶段 | ToP | 阶段式目标/约束平衡基线 |
| 多任务/双种群 | C3M | 常见 CMOEA 对照，许多论文使用 |
| 双种群/辅助 | BiCo | 双种群协同代表 |
| 多搜索/辅助 | CMOEA-MS | 近年常用强基线 |

这些算法本地 PlatEMO 都已经存在，路径在 `PlatEMO\Algorithms\Multi-objective optimization\` 下。

### 6.2 加强版对比集合

如果计算资源允许，建议扩展到 14 个算法：

```text
SCOP-CMOEA, EMCMO, CMOEA-AOP, DRLOS-EMCMO,
C-TAEA, PPS, ToP, C3M, BiCo, CMOEA-MS,
CCMO, CMOEMT, MTCMO, CMOES
```

可选再加入：

```text
CMODRL, CSEMT, APSEA, URCMO, DPCPRA
```

但不建议一开始就把集合扩得过大。算法越多，失败修复和统计时间越高。第一篇论文更需要一个干净、可信、可解释的结果。

## 7. 测试集建议

### 7.1 第一层：与 CMOEA-AOP 保持一致

必须保留：

```text
CF: 10 个
LIR-CMOP: 14 个
DAS-CMOP: 9 个
合计 33 个
```

理由：

- 这是我们 S09 已经跑过的核心范围。
- 也是 CMOEA-AOP 原论文使用的范围。
- 有利于证明 SCOP-CMOEA 不是在新问题上“避开”直接对手。

### 7.2 第二层：扩展到 2026 文献高频测试集

建议加入：

```text
MW: 14 个
DOC: 9 个
```

这样主 benchmark 变为：

```text
CF + LIR-CMOP + DAS-CMOP + MW + DOC = 56 个问题
```

理由：

- MW、DOC 在 2026 年多篇 CMOP 论文中频繁出现。
- MW 通常可行域极窄，能检验 survival credit 是否过度偏向短期存活。
- DOC 能补充更复杂的约束景观。

### 7.3 第三层：补充泛化/困难问题

可作为补充实验，不建议一开始放进主实验：

```text
FCP: 5 个，检验欺骗性约束
ZXH-CF: 9 或 16 个，检验复杂约束与高维/多目标结构
RWMOPs: 真实工程问题，建议先选 18 个或 20 个，再考虑全 50 个
```

FCP 和 DEPEA 的故事更接近“CV 不可信、需要逃逸种群”，不一定是 SCOP-CMOEA 的主战场。可以用来说明边界，而不是强行要求最好。

### 7.4 运行设置建议

第一批外部确认：

```text
N = 100
maxFE = 100000
runs = 10
指标 = IGD + HV + feasible rate + runtime
统计 = Wilcoxon rank-sum + Friedman rank
```

论文级最终实验：

```text
N = 100
runs = 30
maxFE = 100000 为主
LIR-CMOP / DAS-CMOP 可补充 200000 或 300000 FE 的稳健性实验
```

## 8. 应用实验建议

### 8.1 首选应用：RWMOPs

本地 PlatEMO 已经有 `RWMOP1` 到 `RWMOP50`，覆盖压力容器、焊接梁、齿轮、车身、桁架、过程综合、电力系统规划等真实工程问题。

优点：

- 已经在本地可跑，不需要额外建模。
- 多篇 2026 CMOP 论文使用 real-world CMOP 作为补充实验。
- 可以用 HV、可行率和运行时间报告结果。

建议：

```text
先跑 RWMOP1-RWMOP20 做快速验证。
若结果稳定，再扩展到 RWMOP1-RWMOP50。
```

### 8.2 次选应用：电力/能源调度

文献中出现的相关方向包括：

- power dispatch problems；
- coal mine integrated energy system dispatch；
- cascade reservoir scheduling；
- power distribution system planning。

这些方向和“资源分配”故事相性很好。但除 RWMOP 内已有问题外，重新实现完整应用模型的成本较高。建议作为第二篇或扩展实验，不作为当前主论文的必要条件。

### 8.3 不建议当前优先实现的应用

UAV 路径规划、煤矿能源系统和水库调度都很有故事性，但它们的算法成功往往依赖问题结构定制，例如 schema、时间分块或层级种群。SCOP-CMOEA 是通用 CMOP 方法，直接拿这些复杂应用对比，可能会被领域特定算法压制，也会显著增加实现和验证成本。

## 9. 推荐实验路线

### S10：外部算法快速确认

目的：

```text
验证 SCOP-CMOEA 在外部 SOTA CMOEA 里是否有论文级竞争力。
```

设置：

```text
算法：10 个最小集合
问题：CF + LIR-CMOP + DAS-CMOP + MW + DOC，共 56 个
runs：10
N：100
maxFE：100000
```

输出：

- IGD/HV/feasible rate/runtime；
- 每个测试集平均排名；
- 相对每个 baseline 的胜/负/平；
- SCOP-CMOEA 的比例轨迹；
- 失败问题列表。

### S11：论文级确认

触发条件：

```text
S10 中 SCOP-CMOEA 至少进入第一梯队，且没有系统性失败问题。
```

设置：

```text
算法：10 到 14 个
问题：核心 56 个，可加 RWMOP1-RWMOP20
runs：30
```

输出：

- 论文表格；
- Wilcoxon/Friedman；
- 箱线图或收敛曲线；
- 典型问题可视化；
- 消融实验。

### S12：应用补充

优先级：

```text
RWMOP1-RWMOP20 -> RWMOP1-RWMOP50 -> 特定能源/调度应用
```

如果 RWMOP 表现好，可以作为论文应用实验。如果 RWMOP 表现一般，也仍可作为“真实问题泛化边界”讨论。

## 10. 当前最适合写成论文的价值点

当前最有价值的切入点是：

> 提出一种轻量、可解释、由环境选择反馈驱动的算子组合资源调度机制，用 offspring survival credit 在线控制多算子生成比例，使 constrained MOEA 能够在不训练深度强化学习模型的情况下实现问题自适应的搜索行为切换。

它的论文价值不在于“比 CMOEA-AOP 更简单”，而在于：

- 把环境选择的结果转化为搜索行为的信用信号；
- 把 operator selection 从“选择一个算子”扩展为“调度一组 offspring 生成源”；
- 把资源分配从种群/约束/阶段进一步推进到 offspring source 层；
- 在 S09 中已经表现出稳定的内部竞争力；
- 后续若外部对比成立，可以形成一篇完整的通用 CMOP 算法论文。

