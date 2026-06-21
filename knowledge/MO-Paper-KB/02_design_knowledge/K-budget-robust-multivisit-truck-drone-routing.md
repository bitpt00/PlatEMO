---
knowledge_id: K-budget-robust-multivisit-truck-drone-routing
name: 预算鲁棒的多访卡车-无人机救援路径
type: architecture
status: active
source_papers: [P2026-0125]
aliases: [MOVRPD-UTs, epsilon-AMOSA-ALNS, ε-AMOSA-ALNS, robust truck-drone routing, multi-visit drone routing, humanitarian truck-drone logistics, budget uncertainty truck travel time, Gini satisfaction allocation, 多访无人机路径, 卡车无人机协同救援, 预算不确定路径, 灾后鲁棒配送]
promotion_reason: P2026-0125 单篇提出但结构完整：第一阶段用 Gini satisfaction fairness 分配有限救援物资，第二阶段在 Bertsimas budget uncertainty set 下优化多车多无人机多访路径，并用 `epsilon`-dominance 控制 AMOSA archive、用 ALNS 问题定制 destroy-repair 产生邻域解；该架构可迁移到灾后救援、应急医疗、移动充电、城市空地协同配送和其他道路时间不确定的多模式路径场景。
---

# 预算鲁棒的多访卡车-无人机救援路径

## 核心内容

在灾后或应急配送中，把救援公平性、道路时间不确定和空地协同路径合并考虑。先在物资不足时按受灾点满足度做公平分配，再把实际分配量输入卡车-无人机协同路径模型。卡车承担主路线和移动补给/充电站角色，无人机从卡车发射、一次 sortie 服务多个节点，并在后续节点与卡车会合。卡车行驶时间用预算不确定集建模，决策者通过 uncertainty budget 控制保守程度。搜索层用 `epsilon`-dominance 限制非支配 archive，并用 AMOSA 的退火接受机制结合 ALNS 的问题定制破坏-修复算子输出成本-时间 Pareto front。

```text
scarce relief supplies
-> Stage 1: satisfaction fairness allocation by Gini index
-> delivered demand for each affected area
-> Stage 2: truck-drone routing with multi-visit sorties
-> truck travel time budget uncertainty
-> robust arrival-time counterpart
-> epsilon archive + AMOSA acceptance
-> ALNS destroy/repair neighborhood
-> Pareto plans for cost and delivery time
-> out-of-sample robustness check
```

P2026-0125 的实例是 MOVRPD-UTs：土耳其 Kartal 区灾后救援配送，Marmara Region Disaster Center 作为 depot，多车多无人机多访配送，在卡车时间扰动下最小化总配送时间和总成本。

## 建立理由

- 为什么值得独立维护：
  - 应急物流不能只追最短时间或最低成本，物资满足度公平本身是建模目标；
  - 灾后卡车路径受道路损毁影响更大，无人机可作为绕开道路不确定性的补偿资源；
  - 多访无人机 sortie 可更充分利用载荷和续航，区别于传统单访 truck-drone routing；
  - 预算不确定集适合缺少可靠概率分布的灾后快速决策；
  - `epsilon` archive 和 ALNS 邻域让复杂组合路径问题能输出有限且分布较好的 Pareto 候选。
- 与已有设计知识的区别：
  - 不同于“多场景鲁棒的锁-泊位-卡车联动调度”：该知识把水位、泊位效率、卡车速度展开为多场景并用领域解码器评价锁/泊位/卡车联动；本知识采用预算不确定集处理卡车弧时间，并强调公平分配、移动卡车充电站和多访无人机 sortie。
  - 不同于“松弛分布驱动的稳健动态路由”：该知识通过 slack distribution 为未来动态请求预留插入空间；本知识处理静态灾后实例中的道路时间鲁棒性和空地协同配送。
  - 不同于“自适应 ε 支配与网格档案的多目标蜂群搜索”：该知识是通用 ABC/swarm 档案控制层；本知识把 `epsilon`-dominance 嵌入 AMOSA-ALNS，并由 truck-drone destroy/repair 算子驱动。
  - 不同于“业务偏好约束的多段染色体搜索”：该知识把业务阈值转成 epsilon 约束；本知识中的 `epsilon` 是 objective-space archive diversity 控制。

## 解决的问题

- 适用场景：
  - 灾后食品、药品、通信设备、移动电源或紧急工具配送；
  - 地面道路时间不确定，但空中配送相对稳定；
  - 每辆地面车可携带多个无人机或移动机器人；
  - 物资不足，需要先做公平或优先级分配；
  - 需要展示成本、时间和鲁棒性之间的多个备选方案。
- 现有方法为什么会失败或不足：
  - 确定性 truck-drone routing 低估受损道路造成的迟到风险；
  - 单访无人机模式不能充分利用载荷和航程；
  - 单目标或加权求解只给一个折中方案，难支持应急指挥中的偏好变化；
  - 普通 Pareto archive 在组合路径搜索中容易膨胀；
  - 只做公平分配不考虑路径可达性，或只做路径优化不考虑满足度公平，都会偏离人道物流目标。
- 仍需解决的问题：
  - Stage 1 与 Stage 2 分离，路径可达性不能反向影响公平分配；
  - Gini fairness 未表示灾区紧急程度和脆弱群体权重；
  - 同质车队和忽略发射/回收/充电时间会低估真实同步约束；
  - 预算不确定集可能对局部道路差异刻画不足；
  - OOS 测试显示鲁棒解更稳定，但 worst-case 场景下均值目标并不总是同时更优。

## 为什么可能有效

```text
relief demand exceeds available supplies
-> fairness allocation prevents severe under-service

roads are disrupted after disaster
-> truck times need robust protection

drones avoid road disruptions and are faster
-> drone sorties can serve remote low-demand nodes

single-visit drone returns too early
-> multi-visit sortie uses payload and endurance better

truck-drone routing has many discrete structures
-> ALNS provides large feasible neighborhood moves

archive may grow quickly
-> epsilon boxes keep a finite representative Pareto set
```

关键假设是：无人机飞行时间比卡车行驶时间稳定，且发射、回收、充电时间相对路线时间可忽略。如果禁飞、天气、通信限制或充电时长成为主导因素，该框架需要加入无人机侧不确定性和更严格的同步资源约束。

## 实现接口

- 输入：
  - 受灾点位置、需求、最低满足度阈值和可用物资总量；
  - depot、道路距离或旅行时间矩阵；
  - 卡车数量、容量、速度、单位成本；
  - 每辆卡车携带的无人机数量、无人机载荷、航程、速度、单位成本；
  - 灾后卡车时间偏差参数 `sigma`、`tau` 或道路级 uncertainty budget；
  - 救援公平指标和成本/时间目标。
- 输出：
  - 每个受灾点实际分配量；
  - 成本-时间 Pareto truck-drone route set；
  - 每条路线的 truck arcs、drone sorties、launch/retrieval nodes 和 waiting nodes；
  - 预算保守程度下的鲁棒到达时间；
  - OOS 稳定性报告。
- 插入位置：
  - disaster relief routing decision support；
  - 城市空地协同即时配送规划；
  - 移动充电车-无人机/机器人补给系统；
  - 战场、山地、洪水或地震后受损道路配送；
  - 多模式应急物流仿真器。
- P2026-0125 默认实例：
  - Stage 1 由 Gurobi 求解公平分配；
  - Stage 2 使用 `epsilon`-AMOSA-ALNS；
  - `T0=15`，`NIND=100`，`beta=0.2`；
  - 卡车容量 `Q=800`，卡车速度 `15 km/h`，卡车成本 `2 yuan/km`；
  - 无人机载荷 `{20,30,40}`，速度 `45 km/h`，航程 `40 min`，成本 `0.2 yuan/km`；
  - 不确定参数 `sigma,tau in {0,0.5,0.9}`。
- 最小实现：

```text
q_hat <- solve_stage1_fair_allocation(
    minimize = Gini(satisfaction),
    constraints = demand upper bound,
                  minimum satisfaction lambda,
                  total allocated supply)

population <- initialize_truck_routes_by_lowest_cost_insertion()
population <- two_opt(population)
population <- assign_multi_visit_drone_sorties(population, q_hat)
archive <- epsilon_nondominated(population)

while temperature > Tmin:
    destroy <- roulette(weights_destroy)
    repair <- roulette(weights_repair)
    S_new <- repair(destroy(S_cur))
    S_new <- robust_evaluate_with_budget_uncertainty(S_new, sigma, tau)
    S_cur, archive <- AMOSA_accept_and_epsilon_update(S_cur, S_new, archive)
    update_operator_scores_periodically()
    temperature <- alpha * temperature
```

## 如何用于算法创新

### 局部创新

- 把 Gini satisfaction 改成 weighted Gini，引入人口脆弱性、医疗紧急度、道路可达性和避难所容量。
- 将 `sigma/tau` 从全局参数改为道路级参数，由震害等级、拥堵、桥梁状态或遥感信息估计。
- 对 drone launch/retrieval/charging 显式建模，并允许换电或多无人机排队。
- 让 `epsilon` box size 随 archive 密度、决策者偏好区域或搜索阶段自适应调整。
- 在 ALNS 算子选择中加入 contextual bandit，根据当前路线结构选择更合适的 destroy/repair。

### 结构创新

- Fairness-robustness coupled relief planner：

```text
fair allocation
<-> accessibility-aware routing feedback
<-> robust multimodal delivery
<-> OOS risk audit
```

- 与动态应急响应结合：新灾情或道路恢复信息到达后，只重新优化受影响路线和受影响分配量。
- 与多级救援网络结合：上层仓库到临时集散点用卡车，下层集散点到受灾点用 truck-drone multi-visit。
- 与交互式 MOO 结合：指挥员移动时间/成本/鲁棒性滑块，系统在相邻 `epsilon` boxes 中快速推荐路线。
- 与学习型灾情识别结合：遥感或路况模型输出道路级 uncertainty set，鲁棒路径层直接消费。

## 适用条件与风险

- 适用条件：
  - 卡车行驶时间不确定明显高于无人机飞行时间不确定；
  - 可用物资不足，需要公平或优先级分配；
  - 无人机能从卡车发射和回收，且航程/载荷允许多访；
  - 决策时间允许运行元启发式获得 Pareto 候选集；
  - 决策者能接受预算鲁棒带来的保守性。
- 不适用或可能失效的条件：
  - 无人机飞行受强风、禁飞区或通信中断严重影响；
  - 发射、回收、充电或换电时间不可忽略；
  - 物资分配必须与路径可达性强耦合，不能先分配后路径；
  - 需求在执行中快速变化，需要在线重规划；
  - 所有道路扰动有稳定历史分布，随机或分布鲁棒模型可能更合适。
- 计算与实现成本：
  - 第一阶段可由 MILP 求解器处理，第二阶段为组合元启发式；
  - 每次邻域评价需处理 truck-drone 同步、容量、航程和鲁棒到达时间；
  - `epsilon` archive 降低非支配解维护成本，但会牺牲部分前沿精细度；
  - OOS 测试需要额外扰动仿真。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0125 | 研究 post-disaster humanitarian logistics 下 truck-drone collaborative delivery，卡车时间不确定、无人机时间确定 | 问题设定 | Abstract / Sec. 1 |
| P2026-0125 | MOVRPD-UTs 包含多辆卡车、每车多架无人机、每次 sortie 可服务多个客户 | 问题扩展 | Sec. 1 / Sec. 3 |
| P2026-0125 | 第一阶段用 Gini index 量化受灾点满足度公平，约束包括上限、最低满足度和总供应量 | 公平分配 | Sec. 3 / Sec. 4.1 |
| P2026-0125 | 第二阶段目标为最小化 delivery time 和 total traveling cost | 双目标路径 | Sec. 4.2 |
| P2026-0125 | 用 Bertsimas budget uncertainty set 表示卡车 travel time，`Gamma_k` 控制最多受扰动弧数 | 鲁棒建模 | Sec. 4.3 |
| P2026-0125 | `Gamma_k=round(sigma*|A_k|)`，最大偏差由 `tau` 控制，二者表示不确定水平 | 参数含义 | Sec. 4.3 |
| P2026-0125 | 个体表示包括卡车访问序列、无人机访问序列、launch 节点和 retrieval 节点 | 编码设计 | Sec. 5.1 |
| P2026-0125 | 初始解先构造 truck-only CVRP，再用 2-opt，并为卡车路线分配无人机 sortie | 初始化 | Sec. 5.2 |
| P2026-0125 | `epsilon`-dominance 保持非支配 boxes，每个 box 至多一个代表解 | 档案控制 | Sec. 5.3.2 |
| P2026-0125 | AMOSA 中用 amount of dominance 和温度控制接受概率 | 全局搜索 | Sec. 5.4 |
| P2026-0125 | ALNS 含 Shaw、Cluster、Random、Worst destroy 与 Regret-2、Greedy、Drone-priority、Random drone-priority repair | 邻域算子 | Sec. 5.5 |
| P2026-0125 | DoE 调参选择 `(T0,NIND,beta)=(15,100,0.2)` | 参数校准 | Sec. 6.1 |
| P2026-0125 | 相比 NSGA-II、MOEA/D、SPEA2，`epsilon`-AMOSA-ALNS 在多数实例的 HV/IGD 上最好，成本降低约 8%-28%、时间降低约 13%-40% | 算法对比 | Sec. 6.2.1 |
| P2026-0125 | 消融中 HV 相比 AMOSA 提升 77.71%、相比 ALNS 提升 9.38%，IGD 分别提升 30.25% 和 4.04% | 消融证据 | Sec. 6.2.2 |
| P2026-0125 | Kartal 案例使用人口中心和避难所坐标，按人口密度重标需求，12.5% 居民留在避难所 | 真实案例 | Sec. 6.3 |
| P2026-0125 | 多访模式平均无人机弧数减少 23.9521%，无人机距离减少 32.3535%，卡车距离减少 1.9649% | 多访证据 | Sec. 6.4 |
| P2026-0125 | `sigma/tau` 增大时 Pareto set 向更长配送时间方向移动，成本不呈单调趋势 | 不确定性敏感性 | Sec. 6.6 |
| P2026-0125 | OOS-1 中鲁棒解平均成本比确定性解低约 6.2%，平均时间低约 9.8%；OOS-2 中成本标准差更小 | OOS 鲁棒性 | Sec. 6.7 |
| P2026-0125 | 作者指出局限包括同质 truck-drone 配对和忽略无人机发射、回收、充电时间 | 局限 | Sec. 7 |
| P2026-0125 | Data availability 为数据可按请求提供 | 数据可得性 | Data availability |

## 证据边界

- 当前直接证据来自 P2026-0125 一篇论文。
- Markdown 中多处公式为图片省略，鲁棒 counterpart 和算子细节需结合 PDF 或代码复核。
- 案例集中在土耳其 Kartal 区，其他地形、灾种、法规和无人机运行环境仍需验证。
- 模型假设无人机时间确定且发射/回收/充电可忽略，真实复杂环境中可能不成立。
- 第一阶段公平分配与第二阶段路径优化是串联关系，尚未证明迭代耦合会否更好。
- `epsilon`-dominance 的粒度设置对前沿代表性可能有影响，论文证据主要来自该实验设定。

## 待确认

- 公平分配是否应由路径可达性和服务时间反向修正；
- Gini、weighted Gini、max-min satisfaction 和 deprivation cost 哪个更符合不同灾种；
- 预算不确定集能否从实时路况或遥感灾损中自动估计；
- 无人机不确定性、禁飞约束和充电排队加入后，多访模式优势是否仍稳定；
- `epsilon` archive 与 AMOSA clustering、crowding 或 hypervolume pruning 相比的收益边界。
