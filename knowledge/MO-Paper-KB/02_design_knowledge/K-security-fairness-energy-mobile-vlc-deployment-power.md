---
knowledge_id: K-security-fairness-energy-mobile-vlc-deployment-power
name: 安全-公平-能耗耦合的移动光通信部署功率优化
type: architecture
status: active
source_papers: [P2026-0055]
aliases: [UAVDMOP, secure UAV-enabled VLC, energy-efficient UAV VLC, physical-layer security deployment, coverage fairness deployment, joint location power optimization, eavesdropper leakage objective, 安全通信部署, 可见光通信部署, 覆盖公平, 窃听泄漏, 位置功率联合优化]
promotion_reason: 单篇论文提出但建模接口清楚，包含移动通信节点位置、发射功率、覆盖公平、窃听泄漏、运动能耗和安全距离/功率/高度约束，可直接迁移到 UAV-VLC、移动中继、临时通信保障、室内光通信和安全传感网络的多目标部署设计。
---

# 安全-公平-能耗耦合的移动光通信部署功率优化

## 核心内容

在移动通信节点部署问题中，不要只优化覆盖或能耗，而是把安全泄漏显式纳入 Pareto 目标。把每个服务节点的位置和发射功率联合编码，用信道模型计算接收面的服务质量分布，用窃听者或风险区域的可接收信息率计算物理层安全风险，再用节点从初始位置移动到部署位置的运动模型计算能耗。优化输出不是单一部署，而是一组覆盖公平、安全和能耗之间的 Pareto 折中。

```text
service nodes initial positions + receiver/service surface + eavesdropper/risk points
-> channel and received-power model
-> decision variables: node positions + transmit powers
-> f1: coverage fairness / received-power variance
-> f2: information leakage to eavesdropper / secrecy risk
-> f3: motion energy + optional communication energy
-> spatial, altitude, power and safety-distance constraints
-> MOEA / MOEA-D / robust MOEA
-> Pareto deployments + coverage/security/energy maps
```

## 建立理由

- 为什么值得独立维护：安全通信部署类问题常把覆盖、能耗和安全分开处理；这张卡给出一个可复用的联合建模接口，明确哪些变量共同影响三类目标，以及如何把窃听风险转成可优化目标。
- 单篇具体方法的直接复用价值：P2026-0055 在 UAV-enabled VLC 中给出完整三目标问题、约束、MOEA/D 求解流程和多种扰动/规模仿真实验。虽然算法消融不足，但建模接口清楚。
- 与已有设计知识的区别：
  - 不同于“策略跟随评估的风险感知层级多目标规划”：该知识用上层部署 + 下层运营 follower 评估长期方案；本知识是单层连续位置/功率部署模型，核心是物理层安全泄漏目标。
  - 不同于“波前扩散控制的车联网中继传播优化”：该知识控制消息广播波前、中继概率和冗余；本知识优化服务节点的几何部署与功率，不是 packet dissemination。
  - 不同于“链路属性知识调制的离散 PSO 权重更新”：该知识调路由链路权重；本知识调连续空间位置和发射功率。
  - 不同于普通 energy-aware deployment：本知识要求安全泄漏与覆盖公平同时进入目标，而不是作为后验检测。

## 解决的问题

- 适用场景：
  - UAV/移动机器人/临时基站/可见光 LED 节点为区域用户提供通信或照明服务；
  - 服务质量随空间位置、发射方向、功率和信道显著变化；
  - 存在窃听者、敏感区域或安全风险热点；
  - 节点电池、运动距离或发射功率受限；
  - 决策者需要覆盖、安全和能耗的多种折中方案。
- 现有方法为什么会失败或不足：
  - 只优化覆盖会把信号推向窃听区域或消耗过多能量；
  - 只优化安全会牺牲弱覆盖区域的服务公平；
  - 只优化能耗会得到接近初始位置或低功率的保守部署；
  - 固定均匀部署不利用信道和用户分布；
  - 上层加密不能替代物理层泄漏控制，尤其在低算力接收端或密钥分发困难时。
- 仍需解决的问题：
  - 多个或未知窃听者如何建模；
  - partial / statistical CSI 下如何稳健优化；
  - 遮挡、多径、非垂直收发方向和移动接收端如何纳入；
  - 大规模接收网格的评价成本如何压缩；
  - Pareto 解如何按业务偏好选择部署。

## 为什么可能有效

```text
node position and power jointly determine legitimate channel and leakage channel
-> coverage fairness, security leakage and energy share the same decision variables
-> single-objective tuning pushes risk to another dimension
-> Pareto search exposes feasible trade-offs
-> explicit leakage objective prevents high-power/high-coverage solutions from silently becoming insecure
-> energy objective prevents security/coverage solutions from relying on excessive repositioning
```

核心假设是：信道模型和窃听风险模型足够接近真实环境，至少能正确排序部署方案。如果 eavesdropper CSI、遮挡或接收器分布估计严重错误，优化出的安全 Pareto 前沿可能只是模型内安全。

## 实现接口

- 输入：
  - 服务节点初始位置、可部署区域、高度/姿态约束；
  - 接收点或服务区域采样网格；
  - eavesdropper 位置、风险区域或不确定场景集；
  - 信道模型和噪声模型；
  - 节点运动能耗模型和发射功率范围。
- 决策变量：
  - `x_i, y_i, z_i`：节点部署位置；
  - `p_i` 或 `p_{i,k}`：节点或节点-用户发射功率；
  - 可选：beam direction、association、relay activation、redundancy level。
- 目标函数：
  - `coverage_fairness(X,P)`：接收功率方差、低分位功率、outage ratio 或 Jain fairness；
  - `leakage(X,P)`：窃听者信息率、secrecy outage、worst-case leakage 或 risk-area exposure；
  - `energy(X,P)`：运动能耗、通信能耗、悬停能耗或电池消耗。
- 约束：
  - 空间边界、高度范围、最小节点间距、功率上下界；
  - FOV / LoS / 遮挡可行性；
  - 最小服务质量或最大泄漏阈值；
  - 电量、飞行安全和法规限制。
- 输出：
  - Pareto 部署方案；
  - 覆盖热图、安全泄漏热图和能耗分解；
  - 关键膝点或业务偏好选解；
  - 鲁棒性/敏感性报告。

最小实现：

```text
initialize population of node positions and powers

for generation in 1..G:
    offspring <- position_power_variation(population)
    repair spatial, altitude, power and safety-distance constraints
    for x in offspring:
        Pr <- channel_received_power(x.positions, x.powers, receivers)
        Le <- eavesdropper_information_rate(x.positions, x.powers, risk_points)
        En <- movement_energy(initial_positions, x.positions)
        x.objectives <- [variance(Pr), Le, En]
    population <- nondominated_selection(population + offspring)

return pareto_deployments
```

## 如何用于算法创新

### 局部创新

- 将单点 eavesdropper 改为风险区域网格，优化 `max` / CVaR / worst-k leakage。
- 用低分位接收功率或 outage ratio 替代单纯方差，避免“整体都弱但很均匀”的解。
- 对接收面先聚类或自适应采样，早期用代表点快速评价，后期对候选解全网格精评。
- 对位置和功率使用不同变异算子和步长，并按目标贡献自适应分配更新概率。
- 在 Pareto 选择中加入安全优先过滤：超过泄漏阈值的解只在早期探索保留，后期降权或剔除。

### 结构创新

- 构建安全通信部署数字孪生：

```text
environment map / receiver demand / risk map
-> channel and obstruction simulator
-> multiobjective deployment-power optimizer
-> robust scenario evaluator
-> decision dashboard with coverage/leakage/energy maps
```

- 与层级规划结合：上层决定节点数量、候选部署区域和预算，下层连续优化位置/功率。
- 与在线重部署结合：离线 Pareto 集给出备选部署，在线根据用户分布或风险点变化切换或微调。
- 与主动感知结合：先用少量测量校准信道和风险地图，再运行鲁棒 Pareto 搜索。
- 扩展到应急通信、移动传感器、室内光通信、机器人中继和临时活动通信保障。

## 适用条件与风险

- 适用条件：
  - 服务质量、泄漏风险和能耗都能由位置/功率计算或仿真；
  - 节点位置和功率可控；
  - 接收区域或用户分布可以采样；
  - 安全风险有明确目标点、区域或场景集；
  - 决策者愿意从 Pareto 集中选择折中方案。
- 不适用或可能失效的条件：
  - 窃听者未知且风险区域无法建模；
  - 信道受遮挡/反射/人体移动主导，但模型只用 LoS；
  - 接收用户高速移动，静态部署前沿很快失效；
  - 能耗模型缺少悬停、加减速、通信功耗或安全返航；
  - 覆盖公平目标选择不当，得到均匀但低质量的服务。
- 计算与实现成本：
  - 每个候选通常需要对所有接收点和服务节点计算信道，基础复杂度约为 `O(N x U)`；
  - 多场景鲁棒评估会再乘以场景数；
  - 高保真光线追踪或 packet-level 模拟需要代理、缓存或分层评估；
  - 多目标后处理需要业务偏好或 MCDM 选择部署方案。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0055 | UAV-enabled VLC 场景包含多个 LED-UAV、地面 receivers 和一个 unauthorized eavesdropper，均为 single photodetector | 应用设置 | Abstract、Sec. 2.1，PDF 1、3 |
| P2026-0055 | UAVDMOP 联合优化 UAV 位置和 transmission power，使接收面光功率均匀、窃听信息率低、UAV 能耗低 | 问题建模 | Sec. 3.1，PDF 4-6 |
| P2026-0055 | `f1` 用接收面采样点 received optical power 方差表示 coverage fairness | 作者目标设计 | Sec. 3.1，PDF 5 |
| P2026-0055 | `f2` 最小化 eavesdropper 接收的信息率，显式表示 physical-layer security 风险 | 作者目标设计 | Sec. 3.1，Remark 1，PDF 5-6 |
| P2026-0055 | `f3` 用 rotary-wing UAV propulsion power 和移动时间计算从初始位置到部署位置的 motion energy | 作者目标设计 | Sec. 2.5、3.1、Remark 2，PDF 4-6 |
| P2026-0055 | 约束包括水平边界、高度固定或范围限制、功率上下界、`omega` 调节因子和 UAV 最小安全距离 | 约束接口 | Eq. 14，PDF 5-6 |
| P2026-0055 | MOEA/D-CICM 用 circle map 初始化 transmission power，并用按物理含义分块的交叉变异更新位置/功率 | 求解接口 | Sec. 4.2，Algorithm 1-2，PDF 8-10 |
| P2026-0055 | Case 1 8 UAV 中 MOEA/D-CICM 得到 `f1=0.3176, f2=0.3120, f3=0.7138`，优于主要对比方法和随机/均匀部署 | 主实验支持 | Table 3，PDF 4 |
| P2026-0055 | 8 UAV 场景中高质量通信区域面积约从 initial/random/uniform 的 `40.97/43.34/44.58 m^2` 提升到 `50.19 m^2` | 覆盖可视化支持 | Sec. 5.2.1，Fig. 5，PDF 11-12 |
| P2026-0055 | Case 2 12 UAV 中 MOEA/D-CICM 得到 `f1=0.5577, f2=0.3504, f3=3.5071`，相对 MOEA/D/MOCRY/MOPSO/MOFPA 整体更优 | 主实验支持 | Table 4，PDF 4、12 |
| P2026-0055 | 在 receiver distribution、UAV height `[7,8] m`、channel uncertainty、position dynamics、6-16 UAV/3600-14400 receivers 等条件下做扩展仿真 | 鲁棒/扩展验证 | Sec. 6，Tables 13-32，PDF 18-38 |
| P2026-0055 | 作者承认 known eavesdropper CSI 是理想化假设，但将其作为 PLS 常用 benchmark 和上界评估设定 | 建模边界 | Sec. 5.3，PDF 13 |

## 证据边界

- 证据来自单篇 UAV-enabled VLC 仿真论文，尚无真实硬件部署。
- MOEA/D-CICM 缺少清晰消融，无法分离 circle-map 初始化和 crossover mutation 的独立贡献。
- 表格显示 `f2/f3` 优势更稳定，`f1` 在部分距离约束或动态场景中不总是最佳。
- Known eavesdropper CSI、单 eavesdropper、LoS 信道和垂直收发方向简化了真实安全风险。
- 论文中 `P_i,k` 与 `P_{1 x U}` 的功率变量表述存在不一致，复现前需统一。
- 运动能耗模型忽略或简化加减速、悬停和复杂轨迹能耗。
- 部分 Markdown 表格错位，关键公式和表格需要回 PDF 核验。

## 待确认

- 多 eavesdropper、未知 eavesdropper 或统计 CSI 下的鲁棒目标如何定义；
- 覆盖公平应使用方差、最低分位功率、outage ratio 还是服务效用；
- 大规模接收面和多场景鲁棒评估如何代理化；
- 如何把 UAV 轨迹、悬停时间、返航电量和在线重部署纳入同一 Pareto 模型；
- 安全、覆盖和能耗三目标后处理应采用 knee point、Nash bargaining、CVaR 约束还是业务偏好交互。
