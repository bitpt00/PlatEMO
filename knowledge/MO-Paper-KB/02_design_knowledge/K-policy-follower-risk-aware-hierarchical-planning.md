---
knowledge_id: K-policy-follower-risk-aware-hierarchical-planning
name: 策略跟随评估的风险感知层级多目标规划
type: method
status: active
source_papers: [P2026-0143, P2026-0059, P2026-0117]
aliases: [policy-based hierarchical MOO, policy follower evaluation, risk-aware infrastructure planning, CVaR-assisted hierarchical optimization, hierarchical RSU UAV planning, NSGA-II greedy recovery planning, layout-recovery follower evaluation, embedded dual-layer MOEA, outer route planning inner allocation, pre-planning post-adjustment, 策略跟随器, 层级多目标规划, CVaR风险评估, 贪心恢复序列, 布局恢复协同优化, 内嵌双层演化算法, 预规划事后调整]
promotion_reason: P2026-0143、P2026-0059 和 P2026-0117 分别在 RSU-UAV 通信规划、安全设施布局/灾后恢复规划、多式联运应急物流中给出“上层 MOEA 搜索长期方案、下层可行策略或场景优化 follower 评估运营/恢复/分配效果、场景风险或扰动指标随 Pareto 解输出”的完整接口，可直接移植到基础设施、调度和资源规划类多目标问题。
---

# 策略跟随评估的风险感知层级多目标规划

## 核心内容

当一个规划问题天然分成“长期战略设计”和“短期运营调度”两层时，不一定要精确求解完整双层优化。可以让上层 MOEA 搜索长期方案，让下层用一个快速、可行、可解释的运营策略作为 follower 评估每个方案的实际服务效果。上层目标使用成本、覆盖、鲁棒性等平均或结构指标；场景扰动下的 CVaR、VaR 或 worst-k 指标作为风险诊断随 Pareto 解一起输出。

```text
长期设计变量
-> 上层 MOEA 生成候选方案
-> 下层 policy follower 生成可行运营排程
-> 计算成本、服务水平、鲁棒性等目标
-> 场景扰动评估尾部风险
-> 非支配选择保留 Pareto 方案
-> 输出方案集 + 风险诊断
```

## 建立理由

- 为什么值得独立维护：很多工程规划都有层级结构，例如设施选址-车辆调度、产线配置-作业排程、能源设施建设-实时调度。精确双层求解太慢，而完全忽略下层运营又会得到不可执行方案。policy follower 是一个折中：牺牲下层最优性，换取可行、快速和可解释的上层评价。
- 具体方法的直接复用价值：
  - P2026-0143 在城市 V2X RSU-UAV 规划中给出完整实现：上层 NSGA-II 搜索 RSU 坐标和 UAV 数量，下层状态感知贪心策略处理电量、返航和充电，场景 CVaR 报告需求波动与设备故障下的覆盖短缺。
  - P2026-0059 在安全设施布局中给出第二个实现：上层 mixed-coded NSGA-II 搜索设施坐标、朝向和建筑材料，下层 embedded greedy algorithm 根据爆炸损伤、mission dependency 和 repair-team 约束生成恢复序列并计算 operational downtime。
- 与已有设计知识的区别：
  - 不同于“故障子问题辅助的双种群协同重调度”：本知识不在故障后构造辅助子问题种群，而是用下层运营策略评估上层长期方案。
  - 不同于“结构-场景双罚项的模糊鲁棒随机规划”：本知识不构造随机-模糊罚项模型，而是在 MOEA 评价链路中加入场景尾部风险报告。
  - 不同于“预测代理驱动的实时多目标控制优化”：本知识的核心不是训练预测代理做实时控制，而是用可行运营策略近似双层 follower。

## 解决的问题

- 适用场景：
  - 长期建设、配置或部署会影响后续短期调度；
  - 下层调度有复杂状态约束，如电量、库存、返航、维修、充电或换线；
  - 目标包括成本、覆盖、服务水平、鲁棒性、公平性或均衡性；
  - 需要输出多个 Pareto 方案，供预算和风险偏好不同的决策者选择；
  - 存在需求波动、设备故障、天气、突发事件等不确定场景。
- 现有方法为什么会失败或不足：
  - 单层静态规划忽略运营可行性；
  - 精确双层优化或嵌套 MIP 评价太慢，难以服务 MOEA 的大量候选；
  - 加权和方法只能给出一个偏好点，无法展示方案集；
  - 只看平均覆盖或平均成本会掩盖极端场景下的服务短缺；
  - 下层策略若不验证，会把运营近似误差传递给上层 Pareto 前沿。
- 仍需解决的问题：
  - follower 策略的近似误差如何估计并纳入选择；
  - CVaR 是作为诊断、约束还是第四目标更合适；
  - 场景数量、扰动分布和故障相关性如何校准；
  - 上层算法如何在评价昂贵时自适应分配风险评估预算。

## 为什么可能有效

```text
上层设计决定运营可行域
-> 下层策略快速模拟真实运营约束
-> 评价值比静态模型更接近可执行表现
-> Pareto 搜索保留不同预算和服务偏好的方案
-> CVaR 暴露平均指标看不到的尾部损失
-> 小规模策略验证降低 follower 误导风险
```

关键假设是：下层 policy follower 虽非最优，但在主要运营约束和相对方案排序上足够可靠。如果 follower 对不同上层方案的偏差不一致，MOEA 可能优化出只适合该策略而非真实运营的方案。

## 实现接口

- 输入：
  - 上层设计变量和约束；
  - 下层状态、动作、转移和可行性规则；
  - 下层 policy follower；
  - 平均目标和鲁棒/均衡目标；
  - 场景生成器和风险指标。
- 输出：
  - Pareto 设计方案；
  - 每个方案的下层可行排程或策略执行日志；
  - 平均目标值、鲁棒性指标和 CVaR/尾部风险；
  - follower 策略验证或敏感性检查结果。
- 插入位置：
  - 设施选址-运营调度联合优化；
  - 交通、通信、能源、供应链和应急资源规划；
  - bilevel MOO 的近似 follower 评价层；
  - 数字孪生规划工具中的离线方案生成模块。
- 最小实现：

```text
initialize population of upper_designs

for generation in 1..G:
    offspring <- variation(upper_designs)
    for design in offspring:
        schedule <- policy_follower(design, nominal_demand)
        objectives <- evaluate_nominal(design, schedule)
        risks <- evaluate_scenarios(design, schedule, scenario_set)
        design.metrics <- objectives + risk_report
    upper_designs <- nondominated_selection(upper_designs + offspring)

return pareto_set_with_risk_reports
```

- P2026-0143 的具体实例：
  - 上层变量：RSU 部署掩码、连续 RSU 坐标、每个 RSU 的 UAV 数量；
  - 上层目标：最小成本、最大时空覆盖、最大复合鲁棒性；
  - follower：按需求排序网格，向未被 RSU 覆盖的单元分配最近且电量可行的 UAV；
  - 状态约束：`IDLE/DEPLOYING/COVERING/RETURNING/CHARGING`，飞行、悬停、返航电量和充电；
  - 风险场景：需求乘子、RSU/UAV 故障、天气影响和应急事件；
  - 风险指标：95% CVaR 覆盖短缺。
- P2026-0059 的具体实例：
  - 上层变量：14 个设施的中心坐标、0/90 度朝向和建筑材料；
  - 上层目标：最小爆炸后果、最小建设成本、最小等效运营中断天数；
  - follower：对每个布局/材料方案，先用爆炸损伤模型得到受损设施和 `PFD_i`，再用 greedy recovery sequence 在有限 repair teams 下安排修复顺序；
  - 风险/扰动评估：100 次随机爆炸位置模拟，取最大 total loss 计算爆炸后果；
  - 输出：Pareto layout/security/recovery schemes、布局图和恢复序列图。
- P2026-0117 的具体实例：
  - 上层变量：多式联运 route node sequence 和每段 transportation mode；
  - 上层目标：first-stage worst-case demand 下最小运输时间和成本；
  - follower / lower optimizer：inner GA 在外层给定 routes/modes 后，针对 second-stage real-demand scenario 做 material re-allocation；
  - 风险/扰动评估：polyhedral demand uncertainty set、uncertainty budget `Gamma=beta|J|`、fuzzy TOPSIS demand-point priority；
  - 输出：time-cost Pareto route plans、real-demand allocation feedback 和不同 `epsilon/beta` 下的鲁棒性/成本诊断。

## 如何用于算法创新

### 局部创新

- 将固定 greedy follower 替换为可学习策略、rolling horizon MIP、局部搜索或 imitation-learned scheduler。
- 把 follower 误差估计作为额外目标或约束，例如“调度不确定性最小化”。
- 将 CVaR 从诊断指标改成第四目标，或设为 `CVaR <= tau` 的风险约束。
- 对 Pareto 候选采用两阶段评价：早期少场景快速筛选，后期多场景精评。
- 用热点、故障历史或风险地图引导初始化和变异，而不仅仅引导位置。

### 结构创新

- 构建“战略设计 MOEA + 运营数字孪生 follower + 场景风险层”的通用工程规划框架。
- 为同一上层方案维护多个 follower，例如保守调度、成本优先调度和服务优先调度，评价策略适应性。
- 将场景风险与偏好交互结合：决策者在 Pareto 前沿上选择预算区间，再按 CVaR 或 worst-case 筛选。
- 将离线规划和在线重规划连接：离线 Pareto 集给资产配置，在线 follower 根据实时需求重新调度。

## 适用条件与风险

- 适用条件：
  - 下层运营可以用可行策略快速模拟；
  - 下层策略至少能保留方案排序的大致可信度；
  - 上层评价需要考虑运营可行性，但无法承受精确嵌套求解；
  - 风险场景可以合理采样；
  - 决策者需要在成本、服务和风险之间选择方案集。
- 不适用或可能失效的条件：
  - 下层最优性对上层排序极其敏感，简单 follower 会系统性偏置；
  - 场景分布未知或故障高度相关但被独立采样简化；
  - 运营策略本身是待优化核心，固定 follower 会限制可达前沿；
  - 约束违反代价不可接受，而 follower 只能近似保证可行；
  - 场景评估太贵，导致上层种群规模和代数过小。
- 计算与实现成本：
  - 比静态评价昂贵，因为每个候选都要运行 follower 和场景评估；
  - 比精确双层求解便宜，适合先生成方案集；
  - 需要维护下层状态模拟器、场景生成器和风险统计。
- 解释风险：
  - Pareto 前沿是相对于指定 follower 的前沿，不等同于真实最优运营前沿；
  - CVaR 作为后验指标时，不保证上层搜索主动优化尾部风险；
  - 如果风险场景设计不充分，低 CVaR 可能只是场景集过窄；
  - 启发式基线可能在某些单点指标上更好，方法价值应看方案集和风险诊断。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0143 | 将 RSU 部署、连续坐标和 UAV 数量作为上层变量，优化成本、覆盖和复合鲁棒性 | 作者提出的方法 | Sec. 3.5，PDF 4 |
| P2026-0143 | 下层使用状态感知贪心调度，处理 UAV 可用状态、电量、返航和充电约束 | 作者提出的方法 | Sec. 4.3，PDF 5-6 |
| P2026-0143 | 场景风险包含需求 `U(0.7,1.3)`、RSU/UAV 故障、天气影响和应急事件，报告 95% CVaR | 风险评估机制 | Sec. 4.4，PDF 6 |
| P2026-0143 | 柏林中心区数据经 10% 子采样后得到 16,394 个 traffic states，服务区离散为 25 x 25 网格 | 数据与实验设置 | Sec. 5.1，PDF 6-7 |
| P2026-0143 | 代表性运行得到 17 个非支配方案，成本 330.6-1353.8 kEUR，覆盖 10.52%-66.65%，CVaR 0.426-0.905 | Pareto 方案证据 | Tables 3-5，PDF 7-8 |
| P2026-0143 | 鲁棒性与 `1-CVaR` 的 Pearson 相关为 0.85、Spearman 相关为 0.60 | 风险指标对齐证据 | Sec. 5.2.3，PDF 8 |
| P2026-0143 | Greedy+swap 只比 Greedy 覆盖提升约 0.68 个百分点，但运行时间为 3.44x | follower 验证 | Table 8，PDF 8-9 |
| P2026-0143 | 10 seed best-compromise 的 HV 为 `0.182 +/- 0.054`，覆盖 `61.33% +/- 9.79%`，显示中等稳定性 | 稳定性证据 | Table 6，PDF 8 |
| P2026-0143 | 作者未来工作包括 SINR 覆盖、多 UAV 协同、在线自适应、现场验证和数字孪生集成 | 作者局限与未来工作 | Sec. 6，PDF 9-10 |
| P2026-0059 | 上层 mixed-coded NSGA-II 编码每个设施的 `(x_i,y_i,theta_i,M_i)`，连续坐标用 SBX/多项式变异，离散朝向/材料用单点交叉和均匀变异 | 作者提出/采用的方法 | Sec. 5，Eq. (33)，PDF 10 |
| P2026-0059 | 恢复序列不直接编码；每个候选布局评价时调用 embedded greedy algorithm，根据损伤百分比和恢复优先级优化 `sigma` 并计算 `O3` | follower 评价机制 | Sec. 5，Fig. 7，PDF 9-10 |
| P2026-0059 | 爆炸后果用 100 次随机 explosion attack 模拟，并取最大 total loss；目标同时包括爆炸后果、建设成本和 operational impact | 场景风险评价 | Sec. 3、6.1，PDF 3-4、11 |
| P2026-0059 | 假设军事基地案例生成 97 个 Pareto solutions，`O1` 范围 `6.7%-55.1%`、成本 `$7.74M-$9.49M`、运营影响 `0.4-9.1 days` | Pareto 方案证据 | Sec. 6.2-6.3，Fig. 8，PDF 12 |
| P2026-0059 | 作者指出 `>50` 个设施时 Monte Carlo 爆炸评价和约束检查会造成可扩展性问题，建议 hierarchical/decomposition 和 surrogate models | 作者局限与未来工作 | Sec. 6.3.2，PDF 12-13 |
| P2026-0117 | 外层 RL-CNSGA-II 进行 first-stage route/mode bi-objective planning，内层 GA 根据 real demand scenario 优化 second-stage material re-allocation，并把最优解反馈给外层 | 层级 follower/下层优化机制 | Sec. 4.1、4.3，PDF 8、12 |
| P2026-0117 | Two-stage robust model 先基于 worst-case demand 做 pre-planning，再按真实需求 post-adjustment，目标为 time/cost 和 allocation cost/shortage penalty | 问题建模 | Sec. 3.2.3，PDF 6-8 |
| P2026-0117 | Solomon-derived 30-200 node 实例上，完整算法相对 NSGA-II/SPEA-II 在多数设置更优；第一目标平均改善 `14%/2.6%`，第二目标改善 `0.25%/1.8%` | 综合实验支持 | Sec. 5.2-5.3，Table 6，PDF 12-15 |
| P2026-0117 | 参数分析显示高 `beta` 和高 `epsilon` 会明显抬高成本，`beta=0.9` 时成本随 `epsilon` 上升约 80%，支持将场景不确定性诊断随方案输出 | 风险敏感性证据 | Sec. 5.4，Table 7、Fig. 12，PDF 15-16 |

## 证据边界

- 当前主要来自三篇工程规划论文证据，场景分别为通信覆盖规划、安全设施布局/灾后恢复规划、多式联运应急物流。
- 下层 follower 没有与精确最优调度在大规模实例上比较。
- CVaR 是报告指标，不是主优化目标，因此风险改善主要来自鲁棒性目标间接带动。
- 实验种群规模和代数较小，复杂城市和更大资产规模下的收敛性仍需验证。
- 覆盖模型采用服务半径抽象，缺少 SINR、干扰和真实通信链路验证。
- 部分启发式基线在单点指标上表现很强，方法优势应理解为生成风险可解释的 Pareto 方案集。
- P2026-0059 的 follower 规则和爆炸模拟没有与精确 recovery scheduling、直接编码恢复序列或其他 MOEA 做消融对比；案例为假设基地，且单次爆炸/二维平面假设限制了外推。
- P2026-0117 的 inner GA follower 没有与精确 allocation solver 或 rolling-horizon solver 对比，且缺少隔离 inner GA、RL migration 和 two-stage robust model 的逐项消融。

## 待确认

- 如何在线估计 follower 策略误差，并防止上层过拟合 follower；
- 是否应把 CVaR 直接纳入目标或约束；
- 场景风险评估的样本数如何自适应分配到候选方案；
- 多 follower、多风险偏好和在线重规划如何统一到一个框架；
- 在供应链、能源、制造和应急资源场景中是否仍能复现收益。
- 当 follower 是 greedy recovery sequence 时，如何验证其相对最优恢复策略的排序偏差；
- 对 adversarial threat 场景，如何把攻击者选点、灾后恢复和长期布局放入统一的 defender-attacker-follower 框架。
