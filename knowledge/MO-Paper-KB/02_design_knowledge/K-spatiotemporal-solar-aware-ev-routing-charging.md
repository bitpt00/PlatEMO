---
knowledge_id: K-spatiotemporal-solar-aware-ev-routing-charging
name: 时空光伏收益嵌入的电动车路径充电协同
type: architecture
status: active
source_papers: [P2026-0280]
aliases: [VIPV-WCV, solar-aware EV routing, photovoltaic vehicle routing, mobile PV routing, BESS-aware routing, road-segment irradiance routing, VIPV charging, 光伏电动车路径, 时空光照路径规划, 充电路径协同, 移动光伏路由]
promotion_reason: 单篇论文提出但接口完整，包含道路分段方向/遮阴建模、多面板 VIPV 发电、BESS SOC 约束、充电站插入、路径/充电计划构造和 Pareto 多目标搜索，可迁移到光伏配送车、垃圾收集车、巡检车、移动储能和 V2G/VIPV-to-grid 调度。
---

# 时空光伏收益嵌入的电动车路径充电协同

## 核心内容

将电动车路径规划中的能量模型从“固定耗电 + 充电站补能”扩展为“沿途时空发电 + BESS 储能 + 充电站补能”。道路被划分为带方向、长度和时变遮阴系数的 road elements；车辆车顶、侧面或其他位置的 PV panels 根据太阳几何、路段方向和遮阴产生不同发电量。优化器在生成路线时，同时评估行驶耗能、路上 PV 发电、BESS SOC、充电站访问和任务服务目标，从而得到路径与充电计划的多目标折中。

```text
road network
-> road elements: length, direction, time-varying shading
vehicle PV panels + BESS
-> time/location-dependent solar generation
raw task sequence from MO optimizer
-> route construction with depot and service actions
-> insert charging stations when SOC risk appears
-> compute energy, cost, service-time objectives
-> Pareto route and charging plans
```

P2026-0280 的 VIPV-WCV routing 是该架构的实例：MONAA 搜索 waste site 原始访问序列，启发式构造多辆车完整路线和充电计划，目标同时包括净能耗、运行成本和单位体积垃圾平均等待时间。

## 建立理由

- 为什么值得独立维护：
  - 车身光伏车辆的能量收益由路线、时间、方向、遮阴和面板朝向共同决定，不能用固定发电率或普通 EVRP 能耗模型替代；
  - 将路段级光伏收益嵌入 routing 可改变“什么时候走哪条路、何时充电、派几辆车”的决策；
  - BESS 同时受到路上发电和 CS 充电影响，适合与 route construction 共同处理；
  - 该架构可扩展到移动储能、太阳能配送车、巡检车和 VIPV-to-grid 服务。
- 单篇具体方法的直接复用价值：
  - P2026-0280 给出多面板 PV 发电模型、road element shading model、三目标 VIPV-WCV routing、SOC 约束、MONAA+heuristic route formation、CS 插入、6 个地理/季节案例和 EV-WCV 对比。
- 与已有设计知识的区别：
  - 不同于“层级路径重构的约束感知 MRTA”：该知识修复电量/容量瓶颈下的 route fragments；本知识把时空光伏发电作为路线和充电决策的一部分。
  - 不同于“区域压缩编码与多解路径解码”：该知识压缩路网区域以缩短路径编码；本知识不改变编码粒度，而是增强路段能量评价。
  - 不同于“预测代理驱动的实时多目标控制优化”：该知识用代理/BO 做实时控制参数建议；本知识面向路径与充电计划构造。
  - 不同于普通 EV charging scheduling：这里车辆在路上能生成能量，且发电量随空间和时间变化。

## 解决的问题

- 适用场景：
  - 车辆装有 PV panels，或移动设备能在路径上采集能量；
  - 路线经过区域存在显著光照、遮阴、方位或天气差异；
  - 车辆有 BESS、SOC 安全范围和充电站/补能点；
  - 目标需要平衡能源、成本、服务时间、排放、任务完成率或电网交互；
  - 任务可抽象为访问一组服务节点并在途中可能补能。
- 现有方法为什么会失败或不足：
  - 固定能耗模型忽略 PV 路径收益，可能低估或高估充电需求；
  - 只按最短路或最低电价充电会错过高太阳收益路线；
  - 只在路由后检查 SOC 可能频繁插入不理想充电站；
  - 不考虑遮阴和面板方向会把“晴天但背光/阴影路段”误判为高发电；
  - 单目标经济成本会忽略服务及时性和城市环境需求。
- 仍需解决的问题：
  - Cloudy conditions 和短时天气变化下如何预测/更新太阳资源；
  - CS 插入、充电功率和充电时间如何从启发式升级为联合优化；
  - 路段级光照数据如何从城市 3D、图像或传感器自动获得；
  - 大城市 road elements 过多时如何加速评价；
  - VIPV-to-grid 和任务服务之间如何权衡。

## 为什么可能有效

```text
PV generation depends on route and time
-> road elements expose direction and shading
vehicle panels have different orientations
-> route-specific solar gain can be calculated
BESS SOC couples driving, solar generation and CS charging
-> charging insertion can respect energy feasibility
multiobjective optimizer explores task sequence trade-offs
-> Pareto set reveals energy-cost-service compromises
```

关键假设是：太阳资源和遮阴模型足够可信，且路段级评价成本可接受。如果天气不稳定、城市峡谷遮阴预测误差大，或车辆实际姿态与路段方向不一致，优化出的 solar-aware route 可能过拟合模型。

## 如何用于算法创新

### 局部创新

- 将 nearest CS insertion 替换为 top-k CS Pareto insertion，同时比较 detour、SOC margin、电价和后续太阳收益。
- 将 charging time 从贪心 min 规则改为动态规划、MPC 或 learned charging policy。
- 对 raw task sequence 的 variation 加入 solar window mutation，例如优先在高辐照时间访问长距离路段。
- 用 cloud forecast scenarios 生成 robust Pareto routes，而不是单一 clear-sky 路径。
- 对 road element 评价做缓存和增量更新，降低 MOEA 每个候选的能量计算成本。

### 结构创新

- 构建 mobile energy routing 框架：

```text
spatiotemporal energy map
vehicle PV/BESS model
task/service route optimizer
charging/V2G action optimizer
multiobjective selection and decision support
```

- 在太阳能配送车中，同时优化客户访问顺序、充电站和高光照道路选择。
- 在巡检/清扫/垃圾收集机器人中，把任务服务时间和路上采能窗口联合调度。
- 在移动储能或应急车辆中，将 VIPV-to-grid 放电服务加入目标和约束。
- 与数字孪生结合：城市 3D/街景/车载感知更新遮阴图，优化器滚动重规划。

## 适用条件与风险

- 适用条件：
  - 车辆 PV 面板位置、面积、效率和朝向可建模；
  - 道路可获得方向、长度、交通速度和遮阴/辐照数据；
  - BESS SOC 和充电行为可在路线评价中快速更新；
  - 任务允许在出发前或滚动过程中选择路线和充电计划；
  - PV 发电量相对于能耗不至于完全可忽略。
- 不适用或可能失效的条件：
  - 天气高度随机且缺少可靠 forecast；
  - 车辆在实际道路中的姿态、停靠方向或遮挡与模型差异大；
  - PV 面积小、能量贡献远低于建模误差；
  - 充电站排队、占用和功率限制比 PV 收益更主导，但模型未纳入；
  - 实时计算预算不足以评估大量 road elements。
- 计算与实现成本：
  - 需要 road element 光照数据和 PV/BESS 参数；
  - 每条候选 route 都要做时间推进、能耗/发电和 SOC 更新；
  - 多目标搜索还需维护 Pareto set；
  - 若引入 cloud scenarios、3D shading 或 V2G，评价成本会明显增加。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0280 | 使用 ASHRAE clear sky model 建立 direct/diffuse irradiance 模型，支持 clear-sky VIPV 路径规划 | 能源建模 | Sec. II-A，PDF 4 |
| P2026-0280 | 多个 PV panels 的总发电量由各 panel irradiance、area、conversion factor 和 shading factor 计算 | 能源建模 | Sec. II-B，PDF 5 |
| P2026-0280 | Road 被划分为 road elements，每个 element 包含 length、direction 和 time-varying shading factor | 路段建模 | Sec. III-B，Fig. 3，PDF 5 |
| P2026-0280 | Action node sequence 扩展为 full route，使用 Floyd-Warshall 在相邻 action nodes 间插入 passing nodes | 路由表示 | Sec. IV-B，PDF 6 |
| P2026-0280 | 三个目标分别为 net-energy consumption、total operating cost 和 average waste collection time | 多目标建模 | Sec. IV-C，PDF 6-7 |
| P2026-0280 | 约束包括 depot 出发/返回、所有 WS 一次收集、deadline、载废容量、SOC 安全范围和仅在 CS 充电 | 可行性约束 | Sec. IV-D，PDF 7-8 |
| P2026-0280 | MONAA 只搜索 raw WS node sequence，启发式插入 depot/CS 并构造完整路线和充电计划 | 求解架构 | Sec. V-A，Algorithms 1-3，PDF 8-9 |
| P2026-0280 | SOC 不足时插入 nearest CS；充电功率为最大功率，充电时间由可用 BESS 容量和剩余路线能量需求决定 | 充电策略 | Sec. V-A-B，PDF 9 |
| P2026-0280 | Sydney 仿真网络含 1 depot、18 WSs、5 CSs、3 RNs 和 652 roads，road elements 长度为 0.1 km | 实验设置 | Sec. VI-A，PDF 10 |
| P2026-0280 | MONAA 生成 35 个 non-dominated solutions，并用 R-method 选择最终方案 | Pareto 搜索证据 | Sec. VI-B，Fig. 5，PDF 10-11 |
| P2026-0280 | 最终方案派出 3 辆 VIPV-WCV，均早于 3 pm deadline 完成任务 | 可行方案证据 | Sec. VI-B，PDF 11 |
| P2026-0280 | VIPV-WCV 在路上产生 54.79 kWh，占总能耗 20.76%；grid charging energy 比 EV-WCV 低 24%，charging cost 低 23.7% | 对比实验支持 | Sec. VI-B，Table IV/Figs. 7-8，PDF 11-12 |
| P2026-0280 | Singapore summer PV 覆盖 21.94%，Sydney summer 20.76%，Vancouver summer 12.22%，说明地理位置影响明显 | 地理/季节证据 | Sec. VI-C，Table V，PDF 13 |
| P2026-0280 | 作者未来工作包括 cloudy conditions 下的 RL/multi-agent routing，以及 VIPV-to-grid 应急能源服务 | 作者未来工作 | Sec. VII，PDF 14 |

## 待确认

- Cloudy/rainy conditions 下光伏预测误差如何影响 Pareto route；
- 充电站选择和充电时长是否应与 raw route sequence 联合优化；
- Road element shading factor 的现实获取成本和误差；
- 在更大城市网络中，路段级发电评价能否实时滚动；
- 与 ALNS、MOEA/D、NSGA-II、MPC 或 RL-based EV routing 的系统比较仍需补充。
