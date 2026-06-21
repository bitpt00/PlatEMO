---
knowledge_id: K-bounded-wait-feasible-action-state-augmented-rl-control
name: 等待上界可行动作过滤与状态增强 RL 控制
type: method
status: active
source_papers: [P2026-0278]
aliases: [DFASD, ACSCS, dynamic feasible action set derivation, adaptive crosswalk state combined system, action-space filtering, state-space augmentation, bounded waiting time, RL safety shield, feasible action mask, traffic signal control, maxCWSI, 可行动作集, 动作过滤, 状态增强, 等待上界]
promotion_reason: 单篇论文提出但接口清晰，包含服务等待上界建模、动作-服务集合映射、动态可行动作集、DQN target action mask、状态增强软约束和事件触发 FPD，可直接迁移到离散动作 RL 中的安全/服务约束控制
---

# 等待上界可行动作过滤与状态增强 RL 控制

## 核心内容

在离散动作 RL 控制中，将“某些对象必须在最大等待时间内被服务”的要求转化为可行动作集过滤。每个动作对应一组会被服务的对象，每个对象维护 elapsed waiting time 和最大允许间隔。当某些对象即将达到上界时，从能服务这些对象的动作集合中动态构造 feasible action set，策略只能在该集合中选动作，DQN target 的下一步 max 也只在下一步 feasible set 中计算。与此同时，可以把未来上界触发信息作为 state augmentation，让策略提前避开硬约束被动触发。

```text
service objects with max wait interval
-> map action a to served object set S(a)
-> track elapsed wait for each object
-> predict which objects will hit max wait soon
-> feasible actions = union/actions that serve those objects
-> RL action selection and target max use feasible actions
-> optional state augmentation encodes future violation timing
```

## 建立理由

- 为什么值得独立维护：
  - 很多 RL 控制任务中，reward penalty 只能降低违规概率，不能保证硬服务约束。
  - action mask/shield 若只用于当前决策而不用于 DQN target，训练目标和执行策略会不一致。
  - 状态增强能让策略提前学习约束压力，减少硬过滤对主目标优化的干扰。
  - 该机制可迁移到交通信号、机器人服务、充电/补能调度、急救优先、边缘任务轮询和其他 bounded-wait 服务系统。
- 与已有设计知识的区别：
  - 不同于“目标解耦双 Critic 的多目标连续控制”，本知识面向离散动作和硬可行动作过滤，不是连续动作的多 critic 回报建模。
  - 不同于“预测代理驱动的实时多目标控制优化”，本知识不通过代理模型和贝叶斯优化给参数建议，而是在 RL 决策时动态屏蔽不可接受动作。
  - 不同于“强化学习调度的下层搜索模式”，本知识调度的是环境控制动作的可行集合，不是双层优化中的下层搜索强度。
  - 不同于普通 reward shaping，本知识用 hard action-space filtering 给出约束保证。

## 解决的问题

- 适用场景：
  - 动作是离散 phase/mode/resource allocation；
  - 每个动作能明确服务一组对象或满足一组约束；
  - 对象有最大等待时间、最大红灯间隔、SLA deadline 或安全服务上界；
  - 允许用规则层在 RL 策略外部过滤动作。
- 现有方法为什么会失败或不足：
  - 单纯加权 reward 会在低流量或低权重对象上产生长期等待；
  - 只优化平均等待时间会掩盖尾部服务违规；
  - 状态中没有未来约束压力时，agent 难以提前准备；
  - 固定周期规则能保证服务但实时效率低。

## 为什么可能有效

```text
服务上界是硬约束
-> 先找将要达到上界的对象
-> 只允许选择能服务它们的动作
-> 约束满足不再依赖 reward 权重调参
-> 状态增强让 agent 学到未来约束压力
-> hard shield 少触发时主目标优化空间更大
```

关键假设是：每个约束对象至少有一个动作可以及时服务，且同时触发的对象集合存在可行 action union 或可按优先级拆解。若动作集合本身无法同时满足多个 impending deadlines，必须加入冲突分解、优先级或应急 fallback。

## 实现接口

- 输入：
  - 全动作集合 `A`；
  - 对象集合 `O`；
  - 每个对象 `o` 的 maximum interval/deadline；
  - elapsed wait `ET(o,t)`；
  - 服务映射 `serve(a) subset O` 或反向集合 `A_o={a | o in serve(a)}`；
  - RL Q-values 或 policy logits。
- Feasible action derivation：
  - 当前已有对象达到 deadline，则 `SFA = A_o`；
  - 若下一步/后续几步会有多个对象达到 deadline，则 `SFA = union A_o` 或求满足多对象的 action intersection/cover；
  - 若无对象逼近 deadline，则 `SFA = A`。
- DQN 使用：
  - 执行动作时 `argmax_{a in SFA(t)} Q(s_t,a)`；
  - target 计算时 `max_{a in SFA(t+T)} Q_target(s_{t+T},a)`；
  - 探索时随机动作也从 `SFA` 中采样。
- State augmentation：
  - 添加未来若干步各对象达到上界的 binary/timing matrix；
  - 让网络提前学习约束压力，减少最后一刻硬过滤。

## 如何用于算法创新

### 局部创新

- 把 `union A_o` 改为最小覆盖、最大覆盖或优先级加权 feasible action solver。
- 用 learned deadline-risk predictor 替代手写未来扫描，预测哪些对象即将违反约束。
- 对硬过滤触发次数加入 regularization，让策略学会提前安排服务。
- 给低需求对象加入 event-triggered timer，只在检测到真实请求后启动等待上界。
- 将可行动作过滤与 safe exploration、constrained policy optimization 或 control barrier 方法结合。

### 结构创新

- 构建离散控制的 hard-soft constraint RL：

```text
environment state
-> deadline/service-state tracker
-> feasible action shield
-> RL policy over feasible actions
-> state augmentation exposes future constraint pressure
-> reward optimizes efficiency/fairness/priority
```

- 在交通网络中把本地 shield 扩展到多交叉口协调：每个局部 agent 保证本地等待上界，中央 coordinator 只优化跨路口流量。
- 在边缘/云调度中把任务 deadline 映射为必须服务的队列，把 feasible action 设为能处理即将超时任务的服务器分配。
- 在机器人巡检或仓储任务中，把地点/订单最大等待时间映射为服务动作过滤。

## 适用条件与风险

- 适用条件：
  - 可明确枚举动作及其服务对象；
  - deadline/等待上界是可观测或可追踪的；
  - 可行动作过滤开销远小于决策周期；
  - 不同对象的服务冲突可通过动作设计、union/cover 或优先级处理。
- 不适用或可能失效的条件：
  - 动作连续且难以构造显式 feasible set；
  - 同时超时对象之间没有共同可行服务方案；
  - 服务对象检测存在严重误报/漏报；
  - 过强 hard constraint 导致主目标长期受限；
  - 多 agent 场景中局部 feasible action 导致全局拥堵或振荡。
- 计算与实现成本：
  - DFASD 类规则最坏 per-decision 复杂度约 `O(J^2)`，状态增强增加约 `O(J^2)` 维度；
  - 需要维护对象等待计时器和 action-service mapping；
  - target mask、exploration mask 和 deployment mask 必须一致实现。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0278 | 指出现有 pedestrian-aware DRL 依赖细粒度行人数据或简单加权奖励，可能导致低流量行人过久等待 | 问题动机 | Sec. II-D，PDF 4 |
| P2026-0278 | 定义 vehicle phase 与 crosswalk 的映射 `CWS_a`、`ACW_j`，为 action-space filtering 提供基础 | 作者建模 | Sec. III-B，Figs. 2-3，PDF 5-6 |
| P2026-0278 | ACSCS 将未来 crosswalk 达到 `maxCWSI` 的时序编码为 `J x J` crosswalk sub-state，输入 Dueling DQN | 作者提出的方法 | Sec. IV-B，PDF 8 |
| P2026-0278 | DFASD 根据当前和未来几个 time steps 中达到 `maxCWSI` 的 crosswalk 构造 `SFA(t)`，从可行动作集中选择相位 | 作者提出的方法 | Sec. IV-C、Algorithm 1，PDF 8-9 |
| P2026-0278 | DFASD 在 DQN target 中也对下一步 `SFA` 取最大 Q，保证学习目标与执行动作过滤一致 | 作者提出的方法 | Sec. IV-D、Algorithm 2，PDF 10-11 |
| P2026-0278 | 多目标 reward 同时包含车辆等待、队列、公平、应急车辆、车辆最大等待违规、crosswalk max interval 违规和连续违规 | 作者提出/组合方法 | Sec. IV-D，PDF 9-10 |
| P2026-0278 | 消融显示 DFASD 和 DFASD+ACSCS 对 maxCWSI 违规/连续违规为零，ACSCS 相比 Dueling DQN 违规减少超过 60% | 消融实验支持 | Sec. V-B、Figs. 12-14，PDF 14-15 |
| P2026-0278 | 与 PV-TSC、CAMABRL、3DQN Cycle、Cycle Webster 比较，提出方法在 lane fairness、emergency vehicle、pedestrian waiting 和 CWVT 上整体更优 | 综合实验支持 | Sec. V-C、Tables VI-VII，PDF 15-16 |
| P2026-0278 | on/off-peak 和 T-shaped intersection 中，提出方法保持车辆-行人平衡并满足 crosswalk threshold | 场景泛化证据 | Sec. V-D、Tables VIII-IX，PDF 16-17 |
| P2026-0278 | FPD 扩展在低行人密度下只在检测到首个行人后启动 maxCWSI timer，改善车辆流同时保持行人服务 | 扩展机制证据 | Sec. V-E、Table X，PDF 17-18 |
| P2026-0278 | 作者未来工作包括多交叉口协调和实时应急车辆检测、优先路径规划与 signal preemption | 作者未来工作 | Sec. VI，PDF 18-19 |

## 证据边界

- 当前只有单篇论文证据。
- 实验主要为单交叉口仿真，网络级协调和真实部署未验证。
- DFASD 保证依赖 action-service mapping 的可行性；复杂冲突下可能需要额外求解器。
- ACSCS 只是软约束，不能单独保证零违规。
- 行人检测、通信延迟和传感器误差未系统研究。
- 权重、`maxCWSI` 和 FPD 触发规则具有政策和场景依赖。

## 待确认

- 多交叉口中局部 action shield 是否会造成上游/下游拥堵传播；
- 连续动作或大规模离散动作下 feasible action solver 如何扩展；
- 同时有多个硬约束对象且无共同服务动作时的冲突解决；
- 如何学习或自适应设置 `maxCWSI`、reward weights 和 FPD 触发阈值；
- 如何在安全认证或交通法规中验证 hard action filter 的合规性。
