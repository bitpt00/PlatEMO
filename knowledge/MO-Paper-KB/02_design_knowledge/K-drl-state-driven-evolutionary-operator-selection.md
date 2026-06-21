---
knowledge_id: K-drl-state-driven-evolutionary-operator-selection
name: 状态驱动的 DRL 演化算子选择
type: method
status: active
source_papers: [P2026-0042, P2026-0239, P2026-0244, P2026-0201, P2026-0285, P2026-0209, P2026-0273, P2026-0117, P2026-0020, P2026-0035, P2026-0137]
aliases: [MMOEA-DRL operator selection, DQN adaptive operator selection, DRL-based operator selection, Q-learning local search selection, CMOEA-TS, temporal sequence of constrained handling selection, CMOEA-AOP, automated operator portfolio, DDPG operator portfolio, AHMOA-RL operator selection, Q-learning GA DE PSO LS scheduling, Q-MCEAK search strategy selection, IDPSO dual Q-learning, Q-learning PSO parameter control, Q-learning population migration control, diversity-state migration sizing, RL-CNSGA-II, LBABC, Q-learning path operator selection, MO-QL-HH, Q-learning multi-objective hyper-heuristic, MCUCSP low-level heuristic selection, HV-stagnation epsilon decay, state-driven operator scheduling, 强化学习算子选择, Q-learning局部搜索算子选择, Q-learning路径算子选择, Q-learning搜索策略选择, Q-learning超启发式排课, CHT算子联合选择, DQN算子调度, 算子组合比例控制, 交通信号算子调度, PSO参数Q学习控制, 种群迁移规模Q学习, 多样性状态迁移控制]
promotion_reason: 多篇论文共同支持，状态、动作、奖励、经验回放、网络更新和插入位置明确；证据已覆盖单算子选择、局部搜索算子调度、CHT+遗传算子联合动作、DDPG 连续算子组合比例、交通信号优化中的 GA/DE/PSO/LS Q-learning 调度、生产-配送调度中的交叉/变异/KLS 策略组合选择、FJSP 中双 Q-learning 对 PSO/DE 参数与局部搜索策略的分层控制、双种群 NSGA-II 中基于多样性状态的迁移规模控制、双资源 EDFJSP 中基于收敛/分布状态的 critical-path/block 邻域调度、移动机器人路径规划中基于三目标短板状态的路径算子 Q-learning 选择，以及多校区多目标排课中按离散化目标状态选择随机/贪婪低层启发式，可直接改造多算子进化算法的子代生成和参数/迁移控制层。
---

# 状态驱动的 DRL 演化算子选择

## 核心内容

把进化算法中的候选搜索算子视为强化学习动作，把当前种群或档案的搜索状态编码为状态变量，并用 DQN 学习“在该状态下选择某个算子后的长期收益”。经验不足时随机探索，积累经验后训练网络；后续每代根据当前状态选择算子，同时保留少量随机探索。

```text
提取当前种群/档案状态
-> 选择演化算子作为动作
-> 用该算子生成 offspring
-> 环境选择并更新档案
-> 根据新旧状态变化计算 reward
-> 写入 replay buffer
-> 周期性训练或更新 DQN
-> 下一代按状态选择算子
```

P2026-0042 的实例将该控制器嵌入多模态多目标优化，状态由决策空间分布、目标空间分布和决策空间范围组成，动作集合为 GA 与 DE。

P2026-0239 给出一个更轻量的 tabular Q-learning 变体：动作集合不是 GA/DE，而是 13 个调度领域局部搜索算子；算法维护 Q-table/R-table，用 `epsilon`-greedy 探索和 useful/other 奖励调度速度调整、单工厂序列调整和跨工厂序列调整。该证据支持“RL/Q-learning 算子调度”这一上位机制，不应理解为 DQN 或丰富状态编码本身的新增证据。

P2026-0244 将该机制扩展到 constrained MOO：每个动作是一个 `(constraint-handling technique, genetic operator)` 组合，DQN 根据可行性、收敛性、多样性和阶段 flag 选择下一代动作，并用同时考虑 objective improvement 与 constraint satisfaction 的 reward 训练。

P2026-0201 进一步把动作从“选择单一算子或离散算子组合”扩展为 automated operator portfolio：DDPG actor 根据 population 的 convergence、diversity、feasibility 和评价进度输出 GA/SBX、DE/rand/1、DE/best/1 的使用比例，使同一代 offspring 由多个搜索范式共同生成。

P2026-0285 在大规模交通信号优化中给出 tabular Q-learning 实例：状态包含 population diversity、relative HV improvement、normalized generation index、memory statistics 和 global/local phase flag，动作是 GA、DE、PSO、LS 四类算子，reward 为相对 HV increase，并在全局区域协调和局部路口精修两个阶段复用同一类算子调度接口。

P2026-0209 给出 integrated flow shop-distribution scheduling 中的 tabular Q-learning 实例：状态由当前非支配解集相对上一轮的 coverage 和 distribution 变化定义，动作不是单个算子，而是 crossover、mutation 与 knowledge-based local search 的三种策略组合，reward 根据状态是否转向最优/最差搜索状态取 `+1/0/-1`。

P2026-0273 给出 FJSP-WF-DRC 中的双 tabular Q-learning 实例：参数控制器根据迭代阶段、种群多样性和 Pareto 质量调节 `wi,c1,c2,nu,F,CR` 等 PSO/DE 参数与粒子比例；局部搜索控制器为 elite particles 在标准 PSO、原始局部搜索、关键路径优化、反转、机器重分配和工人重分配之间选动作。

P2026-0117 给出应急多式联运中的 tabular Q-learning 迁移控制实例：状态是两个种群当前 diversity 与初始 diversity 的比值组合，动作不是选择算子，而是增大、减小或保持双种群 migration size `m(t)`；每隔若干代触发 migration，用学习到的 `m(t)` 控制种群间交换个体规模。

P2026-0020 给出双资源节能分布式 FJSP 中的 tabular Q-learning 局部搜索实例：状态由 `Delta AMD` 与 `Delta ND` 的正负组合离散为 4 类，动作是 6 个 worker workload、critical path 和 critical block 邻域，reward 为 best objective vector 是否被新解支配，并用 success-rate 自适应 `epsilon` 控制探索。

P2026-0035 给出移动机器人三目标路径规划中的 tabular Q-learning 实例：每个 non-dominated path 是一个 agent，状态由 path length、safety、smoothness 相对当前 elite set 均值的优劣组合成 8 类，动作是 path crossing、mutation、insertion、shortening、safety 和 smoothness 六个路径算子，reward 由新旧路径的 Pareto dominance 关系给 `+1/0/-1`。

P2026-0137 给出多校区大学课程排程中的 tabular Q-learning hyper-heuristic 实例：状态是当前课表三目标值相对 reference point 的离散化向量，动作是 10 个 low-level heuristic operators，其中 4 个 random operators 负责探索、6 个 greedy operators 负责通勤/教室/课时偏好的定向开发；reward 按动作前后多目标相对改善计算，`epsilon` 根据 HV 停滞自适应衰减。

## 建立理由

- 为什么值得独立维护：
  - 多算子进化算法普遍存在算子何时使用、对哪个搜索状态使用的问题。
  - 该方法给出清晰的控制接口：状态特征、动作集合、奖励、经验回放、网络更新和探索策略。
  - 它不依赖某个特定测试集，可迁移到多目标、约束、多模态或大规模优化中的算子调度。
- 单篇具体方法的直接复用价值：
  - P2026-0042 明确给出 Algorithm 1-3、DQN 参数、replay buffer 门槛、greedy 概率和两阶段嵌入方式；
  - 与固定 GA/DE 变体相比，自适应选择在 IDMP 多数测试上更稳定；
  - 在 CEC2019 和 IDMP 上，rPSP 与 IGDX 排名显示该策略对决策空间多模态覆盖有明显帮助。
  - P2026-0201 给出 DDPG actor-critic、连续 portfolio ratio action、CMOP 状态特征、HV improvement reward、33 个 CMOP benchmark 和单算子消融，支持从“选算子”升级为“分配算子比例”。
  - P2026-0285 给出 Q-table、epsilon-greedy、HV reward、global/local phase flag 和四城交通仿真消融证据，支持该机制在工程型大规模 MOO 中作为 meta-controller 使用。
  - P2026-0209 给出 C/D-metric archive state、三类 search strategy action、`+1/0/-1` 状态转移 reward 和随机动作消融，支持该机制在复杂生产-配送调度中调度交叉、变异和 KLS 的组合。
  - P2026-0273 给出双 Q-learning 控制器、15 个参数动作、6 个局部搜索动作、population-level 与 individual-level reward，并通过 IDPSO_nql 消融支持 Q-learning 在人因 FJSP 中的作用。
  - P2026-0117 给出 diversity-state、increase/decrease/keep migration-size action、epsilon-greedy Q-table 和双种群 RL-CNSGA-II 流程，支持把该机制用于 population communication parameter，而不只用于 offspring operator。
  - P2026-0035 给出路径规划中的 objective-deficiency state、六个 path-level local operators、dominance reward 和随机选择消融，支持该机制在组合/路径编码个体的局部结构编辑中使用。
  - P2026-0137 给出 course timetabling 中的 objective-vector state、random/greedy LLH action set、多目标改善 reward、HV-stagnation exploration decay 和去 random/greedy operator 的消融，支持该机制作为 multi-objective hyper-heuristic 的高层调度器。
- 与已有设计知识的区别：
  - 不同于“成功率反馈的算子与参数自适应选择”：这里不只统计近期成功率，而是用状态表示和 Q-learning 估计算子长期收益。
  - 不同于资源分配：它调度的是子代生成算子，不直接分配评价预算。
  - 不同于固定阶段切换：阶段信息可以作为状态或框架条件，但实际算子选择由学习策略决定。

## 解决的问题

- 适用场景：
  - 算法有多个可替换的变异、交叉、局部搜索、修复或代理生成算子；
  - 不同算子在不同搜索阶段、不同区域或不同种群分布下收益不同；
  - 可以定义状态特征和 reward，并追踪算子对后代及种群更新的贡献；
  - 固定、轮换或随机算子选择导致搜索不稳定。
- 现有方法为什么会失败或不足：
  - 固定算子容易偏向探索或开发中的一端；
  - 随机算子选择不利用当前环境；
  - 短期成功率只能反映局部一代或一个窗口，未必代表长期档案收益；
  - 人工阶段规则难以覆盖复杂问题的状态变化。
- 仍需解决的问题：
  - 状态特征过粗会让 DQN 学不到真实搜索需求；
  - reward 设计可能鼓励短期拥挤度改善而非最终 Pareto 质量；
  - DQN 训练成本、稳定性和超参数会影响实际收益。

## 为什么可能有效

```text
不同算子擅长不同搜索状态
-> 种群分布和档案变化可作为状态信号
-> reward 反馈算子带来的搜索改进
-> DQN 学习状态-动作收益，而不只看最近成功率
-> 算法随搜索环境动态选择更合适的生成机制
```

关键假设是：当前种群/档案状态能够预测不同算子的后续收益，并且 reward 与最终优化质量有足够一致性。

## 实现接口

- 输入：
  - 候选算子集合；
  - 状态特征，如目标空间分布、决策空间分布、可行性比例、档案增量、参考向量覆盖或阶段信息；
  - reward 定义，如支配关系改善、拥挤度改善、HV/IGD 贡献、可行性恢复或档案新颖性；
  - replay buffer、探索概率、网络结构和训练周期。
- 输出：
  - 当前代选择的算子；
  - 可选的动作价值、探索标记和训练日志。
- 插入位置：子代生成前，用于选择生成 offspring 的算子或算子族。
- P2026-0042 的默认实例：
  - 状态 `S_t = (ave_Dec_t, ave_Obj_t, ave_Range_t)`；
  - 动作为 GA 和 DE；
  - replay buffer 最小经验数为 10；
  - greedy 概率为 0.95；
  - DQN 两个隐藏层，每层 40 个神经元；
  - 初始训练迭代 `8e4`，更新训练迭代 `8e3`；
  - 学习率 0.01，weight decay `1e-5`；
  - 每 10 代更新一次网络。
- P2026-0239 的轻量实例：
  - 动作为 13 个 local search operators；
  - 动作类别包括 main/nonmain path 速度加减、最大 TTD/TEC 工厂内 swap/insert、最大 TTD/TEC 工厂与其他工厂间 swap/insert；
  - 使用 Q-table 和 R-table，不训练神经网络；
  - `epsilon`-greedy 保留随机探索；
  - reward 为动作 useful 时 `+1`，否则 `-1`；
  - 插入位置为 DDE 全局序列更新之后的局部搜索阶段。
- P2026-0244 的 CMOP 实例：
  - 状态包含 feasible ratio、feasible nondominated ratio、ideal point、population center、平均距离、标准差和 stage flag；
  - 动作为 `ICV / epsilon / CDP` 三类 CHT 与 `DE/rand/1/bin / DE/rand/2/bin / SBX` 三类遗传算子的 9 个组合；
  - reward 分两阶段：早期偏 objective improvement，后期按不可行/全可行状态分别考虑 CV、可行 archive 更新和 diversity；
  - replay sample 为 `(s_t, a_t, R_t, s_{t+1})`，用 main/target DQN 训练；
  - 插入位置为 CMOEA 的每代 offspring generation 与 constrained environmental selection 控制层。
- P2026-0201 的 portfolio 实例：
  - 状态为 `s=(con, div, fea, lambda)`，分别表示 objective average、objective dispersion、average CV 和评价进度；
  - 动作为 GA/SBX、DE/rand/1、DE/best/1 的使用比例，actor 末层用 softmax 保证比例范围；
  - reward 为当前 population 相对上一代的 HV improvement；
  - 使用 DDPG 的 actor、critic、target actor、target critic 和 experience pool；
  - 插入位置为 CMOEA offspring generation controller，论文实验中嵌入 EMCMO。
- P2026-0285 的交通控制实例：
  - 状态为 `s_g=(D_g, DeltaHV_g, tau_g, mu_g, sigma_g, chi_g)`，分别表示 population diversity、上一代相对 HV improvement、归一化代数、近期 objective evaluations 的均值/标准差和 global/local phase flag；
  - 动作为 GA、DE、PSO、LS 四类 evolutionary operators；
  - reward 为 offspring 生成前后 Pareto front approximation 的相对 HV increase；
  - policy 使用 `epsilon`-greedy，Q-values 存在离散 `(state, action)` hash table 中；
  - 插入位置为 AHMOA-RL 的 global coordination phase 和 local refinement phase 的 offspring generation。
- P2026-0209 的生产-配送调度实例：
  - 状态用 C-metric 和 distribution difference 比较当前 nondominated set `T_t` 与上一轮 `T_{t-1}`，形成 4 个离散状态；
  - 动作为三种 search strategies：`a1` 使用 crossover+mutation，`a2` 使用 crossover+KLS，`a3` 使用 mutation+KLS；
  - reward 按状态转移定义，转向状态 1 给 `+1`，转向状态 4 给 `-1`，其他为 `0`；
  - 使用 `epsilon`-greedy 选择动作，Q-table 与进化搜索同步更新；
  - 插入位置为 Q-MCEAK 三种群并行演化前的全局策略选择层。
- P2026-0273 的人因 FJSP 实例：
  - 状态由 iteration stage、population diversity 和 Pareto front quality 加权组合并离散为 21 个状态；
  - 参数动作是 15 类 `wi,c1,c2,nu,F,CR` 组合，用于同时控制 PSO 惯性/学习因子、elite/chasing 比例和 DE 参数；
  - 局部搜索动作包括 standard PSO update、original local search、critical path optimization、reverse operation、machine reassignment、worker reassignment；
  - 参数控制 reward 由 Pareto improvement 与 diversity improvement 组成；局部搜索 reward 由 `Cmax`、cost 和 fatigue objective 的改善组成；
  - 插入位置为 IDPSO 每代粒子分类后的参数适配和 elite particles 精修阶段。
- P2026-0117 的双种群迁移实例：
  - 状态为两个 population 当前 diversity 相对 initial diversity 的变化组合，共 9 个离散状态；
  - 动作为 migration size `m(t)` 的 increase、decrease 或 keep unchanged；
  - 使用 epsilon-greedy 选择动作，Q-table 按 `Q(s,a) <- Q(s,a) + alpha[r + gamma max Q(s',a') - Q(s,a)]` 更新；
  - migration 可按固定周期触发，例如每 50 generations；
  - 插入位置为 RL-CNSGA-II 的 dual-population coevolution communication layer，而不是普通 crossover/mutation 前。
- P2026-0020 的双资源 EDFJSP 实例：
  - 状态用 `Delta AMD` 表示收敛改进、用 `Delta ND` 表示相邻解分布变化，按二者正负组合成 4 个离散状态；
  - 动作为 `NS1-NS6` 六个局部搜索算子，其中 `NS1/NS2` 重分配工人以降低最大 workload，`NS3-NS6` 围绕 critical path/block 做 swap、insert、首尾移动和 block merge；
  - reward 为 `+1/-1`，当新 best objective vector 支配上一 best 时给正奖励；
  - `epsilon` 按局部搜索成功率自适应，`P_suc>0.6` 时向 0.1 收敛，否则向 0.5 增加；
  - 插入位置为 QMOMA 的 elite archive local refinement 阶段，位于 enhanced NSGA-III environmental selection 之后。
- P2026-0035 的移动机器人路径规划实例：
  - 状态为每条 non-dominated path 相对当前 non-dominated set 的三目标短板，path length、safety、smoothness 分别按是否优于均值离散，共 8 个状态；
  - 动作为 `path crossing / mutation / insertion / shortening / safety / smoothness` 六个路径级算子；
  - reward 为 dominance feedback：新路径支配旧路径为 `+1`，互不支配为 `0`，被旧路径支配为 `-1`；
  - 策略使用随运行时间提高的 greedy probability，早期更多随机探索，后期更多利用 Q-table；
  - 插入位置为 LBABC 的 onlooker bee phase，只对 non-dominated solution set 做局部精修。
- P2026-0137 的 multi-campus course scheduling 实例：
  - 状态为当前课表的三个归一化目标值 `TT/CU/CCI`，离散到 0-3 后组成 state vector；
  - 动作为 10 个 LLH：course swap、course move、campus swap、timeslot swap、evening adjustment、class dispersion、teacher preference、course-period adaptation、commute reduction、classroom utilization minimization；
  - reward 为动作前后各目标相对 reference point 的改善和；
  - `epsilon`-greedy 负责探索/利用，`epsilon` 根据最近 10 代 HV 改善是否停滞在上下界内调整；
  - 插入位置为 MO-QL-HH 的 high-level strategy，每个个体先由 Q-table 选 LLH，再经 decode-repair-evaluate 后更新 Pareto front 与 Q-table。

## 如何用于算法创新

### 局部创新

- 把动作集合扩展为变异算子、交叉算子、参数区间、局部搜索、修复算子和重启策略。
- 将状态从全局平均值扩展为分区域、分簇、分参考向量或分约束状态的特征。
- 用 HV 增量、档案新增解、IGDX 改善、可行性恢复或多样性缺口填补定义 reward。
- 用 Double DQN、Dueling DQN、UCB 探索或 Thompson sampling 处理 Q 值过估计和探索不足。
- 让 DQN/DDPG 输出算子组合、概率分布或连续比例向量，而不是单一算子。

### 结构创新

- 构建统一策略控制层：

```text
搜索状态感知
-> 同时选择算子、参数、档案父代来源和阶段模式
-> 子代生成与环境选择
-> 多维 reward 更新策略层
```

- 将短期成功率反馈作为 DQN 的先验特征，形成“低成本统计 + 长期回报学习”的双层控制。
- 按 Pareto 区域维护多个策略网络，使不同前沿片段或不同等价 PS 使用不同算子调度。
- 在昂贵优化中把代理筛选、真实评价和局部搜索也纳入同一个动作空间。

## 适用条件与风险

- 适用条件：
  - 候选算子数量适中，且各自有互补搜索行为；
  - 能以低成本计算状态特征；
  - reward 与最终优化目标或档案质量相关；
  - 评价预算足以积累经验并训练策略。
- 不适用或可能失效的条件：
  - 问题太小或预算太低，策略尚未学习就已结束；
  - 状态高度噪声或不可区分，DQN 只能学到随机策略；
  - reward 偏向短期局部改善，长期收敛或多样性受损；
  - 算子成本差异很大但 reward 没有计入成本。
- 计算与实现成本：
  - 需要维护 replay buffer 和网络训练；
  - 每代需要计算状态和记录动作-奖励；
  - 网络较小时代价可控，但仍高于纯成功率统计或 bandit 方法。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0042 | 将算子选择建模为 DQN 决策，状态包含决策空间分布、目标空间分布和决策空间范围，动作集合为候选算子 | 作者提出的方法 | Sec. 3.1、3.3，PDF 4、6 |
| P2026-0042 | Algorithm 2-3 给出 replay buffer、随机探索、greedy 选择、网络初始化和周期更新流程 | 作者提出的方法 | Sec. 3.2、Algorithm 2-3，PDF 5-7 |
| P2026-0042 | CEC2019 上 rPSP 和 IGDX 平均排名均为 1.67，最好次数均为 13/22 | 综合实验支持 | Sec. 4.2、Table 3，PDF 8-12 |
| P2026-0042 | IDMP 上 rPSP 和 IGDX 平均排名均为 1.42，最好次数均为 9/12 | 综合实验支持 | Sec. 4.2、Table 3，PDF 8-12 |
| P2026-0042 | 与固定 GA/DE 变体相比，自适应选择在 IDMP 多个测试上更稳定 | 消融实验支持 | Sec. 4.5、Fig. 22，PDF 15-17 |
| P2026-0042 | 作者说明未来可用 Double DQN 和 Dueling DQN 改进当前策略 | 作者未来工作 | Sec. 5，PDF 19 |
| P2026-0239 | QTCDDE 将 13 个速度、单工厂和多工厂局部搜索算子作为 Q-learning 动作，用 Q-table/R-table、`epsilon`-greedy 和 useful/other 奖励自适应选择 | 作者提出/采用的方法 | Sec. III-D、Algorithm 2、Eq. (32)-(35)，PDF 8 |
| P2026-0239 | 将 Q-learning 选择替换为随机局部搜索选择的 QTCDDEnq 在 ONVG、C metric 和 Wilcoxon 检验上显著弱于 QTCDDE | 消融实验支持 | Sec. IV-E，PDF 12 |
| P2026-0239 | 作者未来工作包括引入其他 self-learning techniques 来求解具体调度问题 | 作者未来工作 | Sec. V，PDF 14 |
| P2026-0244 | 将每代 CHT 与 genetic operator 的联合选择定义为 temporal sequence，并用 DQN 预测下一代动作 | 作者提出的方法 | Sec. III-A-B、Definition 1、Algorithm 1，PDF 4-5 |
| P2026-0244 | 状态使用 feasibility、convergence、diversity 和 stage flag，动作空间为 3 个 CHT 与 3 个 genetic operator 的 9 个组合 | 作者提出的方法 | Sec. III-B.1-B.2、Table I，PDF 5-6 |
| P2026-0244 | 两阶段 credit assignment 同时考虑 objective improvement、constraint violation、可行 archive 更新和 diversity；只用 IGD reward 的 TS-h 显著弱于完整方法 | 作者提出的方法/消融支持 | Sec. III-B.3、V-G，PDF 6-7、13 |
| P2026-0244 | CMOEA-TS 在 MW、LIR-CMOP、DAS-CMOP 和 UAV path planning 上整体优于九个 CMOEA，Friedman 平均排名最佳 | 综合实验支持 | Sec. V-B，PDF 10-11 |
| P2026-0244 | 与随机动作 TS-g 相比，CMOEA-TS 在 28 个 MW/LIR-CMOP 问题中 26 个 HV 显著更好，支持发现 temporal sequence 模式 | 消融实验支持 | Sec. V-C、Fig. 6，PDF 11-12 |
| P2026-0244 | 固定单一 CHT 或固定单一 genetic operator 的变体整体弱于自动选择，支持联合选择的必要性 | 消融实验支持 | Sec. V-E-F、Fig. 7，PDF 12-13 |
| P2026-0201 | Fig. 1 中只用 GA、只用 DE、GA/DE 半半的最佳表现随 CF2/CF6/CF9 改变，说明固定 operator portfolio 不具普适性 | 动机实验 | Sec. II-C，Fig. 1，PDF 4 |
| P2026-0201 | AOP action 不是单一 operator，而是 GA/SBX、DE/rand/1、DE/best/1 的使用比例；作者认为这可避免单一搜索范式和随机高 reward 误导 | 作者提出的方法 | Sec. III-B，PDF 5-6 |
| P2026-0201 | 状态 `s=(con, div, fea, lambda)` 同时提取 convergence、diversity、feasibility 和 evolutionary stage | 作者提出的方法 | Sec. III-B，Eq. (3)-(5)，PDF 6-7 |
| P2026-0201 | Reward 使用 population HV 相对上一代的 improvement，经验样本为 `(s_t,a_t,r_t,s_{t+1})` | 作者提出/采用的方法 | Sec. III-B，PDF 7 |
| P2026-0201 | DDPG 用 actor 输出连续 operator portfolio、critic 评价 state-action value，target networks soft update 稳定训练 | 作者采用/组合方法 | Sec. III-C，Eq. (6)-(9)，PDF 7 |
| P2026-0201 | CF/LIR-CMOP/DAS-CMOP 共 33 个实例中 CMOEA-AOP 23 个 IGD 最佳，并相对 EMCMO/Bico/AGEMOEA-II/TSTI/DRLOS 分别在 26/25/31/30/20 个实例显著更好 | 综合实验支持 | Sec. IV-C，Table I，PDF 9 |
| P2026-0201 | 单算子消融中 CMOEA-AOP 相对只用 genetic operator、DE/rand/1、DE/best/1 的变体分别在 28/16/16 个实例显著更好 | 消融实验支持 | Sec. IV-D，Table II，PDF 10 |
| P2026-0201 | 作者未来工作包括扩展到 unconstrained MOP、用 per-constraint features 替代整体 CV、探索 LLM for operator portfolio | 作者未来工作 | Sec. V，PDF 11 |
| P2026-0285 | AHMOA-RL 用 Q-learning 根据 diversity、HV improvement、generation index、memory statistics 和 phase flag 选择 GA/DE/PSO/LS | 作者提出/组合方法 | Sec. IV-C，Algorithm 1，PDF 7-8 |
| P2026-0285 | 同一 Q-learning operator-selection 机制嵌入 global coordination 和 local refinement 两个阶段 | 作者提出/组合方法 | Sec. IV-D，Algorithm 2，PDF 8-9 |
| P2026-0285 | 去掉 RL 策略的 AHMOA 在四城延误均更差；AHMOA-RL/AHMOA 分别为 Manhattan 13.9/18.8、Paris 8.7/21.7、Istanbul 20.0/23.5、Sao Paulo 14.0/25.1 秒 | 消融实验支持 | Sec. V-C.7，PDF 12-13 |
| P2026-0285 | 统一 Manhattan CTM replay 中，AHMOA-RL 取得最低 delay `6.56e7`，并保持 competitive stability 和极小 robustness score | 工程应用对比 | Sec. V-D，PDF 14-15 |
| P2026-0285 | 作者未来工作包括接入实时数据流做事件驱动重优化，以及分布式实现支持 metropolitan-scale near-real-time coordination | 作者未来工作 | Sec. VI，PDF 15 |
| P2026-0209 | Q-MCEAK 用 C-metric 和 distribution difference 将 nondominated set 的相邻迭代变化定义为 4 个状态 | 作者提出/采用的方法 | Sec. IV-F、Table I，PDF 8 |
| P2026-0209 | 动作集合为三种 search strategies：crossover+mutation、crossover+KLS、mutation+KLS，并用 `epsilon`-greedy 选择 | 作者提出/采用的方法 | Sec. IV-F，PDF 8 |
| P2026-0209 | Reward 根据状态转移给 `+1/0/-1`，Q-table 用学习率 `beta` 和折扣因子 `gamma` 在线更新 | 作者采用的方法 | Sec. IV-F，PDF 8 |
| P2026-0209 | 随机动作选择的 R-MCEAK 在 IGD/HV 和 Friedman/Nemenyi 检验中显著弱于 Q-MCEAK | 消融实验支持 | Sec. V-D，PDF 9-10 |
| P2026-0209 | 策略选择比例显示早期偏 crossover+mutation 全局搜索，后期偏 mutation+KLS 局部搜索，说明 Q-learning 学到阶段性策略切换 | 机制分析支持 | Sec. V-D、Fig. 5，PDF 9-10 |
| P2026-0273 | IDPSO 使用两个 Q-learning 控制器：一个调节 `wi,c1,c2,nu,F,CR` 参数组合，另一个为 elite particles 选择局部搜索策略 | 作者提出/组合方法 | Sec. III-D，PDF 6-7 |
| P2026-0273 | 状态由迭代阶段、种群多样性和 Pareto 质量离散化；参数 reward 来自 Pareto/diversity improvement，局部策略 reward 来自三目标改善 | 状态与奖励设计 | Sec. III-D、Eq. (26)-(31)，PDF 6-7 |
| P2026-0273 | `IDPSO_nql` 去掉 Q-learning 后在 ONVG、C metric 和 IGD 的 Wilcoxon test 中显著弱于 IDPSO | 消融实验支持 | Sec. IV-C、Table I，PDF 10-11 |
| P2026-0273 | 作者指出 Q-learning 效果依赖状态离散化和 reward 设计，迁移到差异问题域可能需要重调 | 边界说明 | Sec. IV-C，PDF 12 |
| P2026-0117 | RL-CNSGA-II 用两个种群的 diversity ratio 定义 9 个状态，动作为调整 population migration size `m(t)` | 作者提出/组合方法 | Sec. 4.2.5，Table 2，PDF 10-11 |
| P2026-0117 | Algorithm 1 用 epsilon-greedy 选择迁移动作并更新 Q-table，训练后用策略调节双种群迁移规模 | 作者提出/采用的方法 | Sec. 4.2.5，Algorithm 1，PDF 11-12 |
| P2026-0117 | 与 NSGA-II/SPEA-II 相比，RL-CNSGA-II 在多数测试设置上更优；第一目标平均相对 NSGA-II/SPEA-II 改善 `14%/2.6%`，第二目标改善 `0.25%/1.8%` | 工程应用对比 | Sec. 5.3，Table 6，PDF 14-15 |
| P2026-0117 | 作者未来工作包括深度融合 DRL 与 evolutionary algorithms、distributed optimization 和高维问题扩展 | 作者未来工作 | Sec. 6，PDF 16 |
| P2026-0020 | QMOMA 用 `Delta AMD` 与 `Delta ND` 的正负组合定义 4 个搜索状态，用 Q-learning 选择六个 local neighborhood search operators | 作者提出/采用的方法 | Sec. 4.6.2，Eq. (40)-(44)，PDF 11 |
| P2026-0020 | `NS1/NS2` 面向 worker workload，`NS3-NS6` 面向 critical path/block 的 adjacent swap、block-end insertion、首尾移动和 adjacent block merge | 动作设计 | Sec. 4.6.2，PDF 11-12 |
| P2026-0020 | Reward 为 best objective vector 改善则 `+1`，否则 `-1`；`epsilon` 根据 operator success rate 在 `[0.1,0.5]` 内自适应升降 | 状态-奖励-策略设计 | Sec. 4.6.2，Eq. (45)-(47)，PDF 12 |
| P2026-0020 | 完整 QMOMA05 相比无 Q-learning adaptive selection 的 QMOMA04，平均 `f1/f2/f3` 分别改善 `2.1%/0.2%/8.7%`，并在 HV/IGD 上平均提升 `32%/11.4%` | 消融实验支持 | Sec. 5.5.1、5.5.3，PDF 14-17 |
| P2026-0020 | EM01 算子调用统计显示 `NS6` 最高、`NS4/NS3` 次之，策略能优先调用更有效邻域但未完全放弃其它动作 | 机制分析支持 | Sec. 5.5.3，Figs. 9-10，PDF 16-17 |
| P2026-0020 | 与 MOEA/d-M2M、NSGAIISDR、NSGA-III、PREA、IMA 相比，QMOMA 在 50 个 benchmark 中 48 个最佳，HV/IGD 相对最佳竞争者平均提升 `26.4%/67.3%` | 综合实验支持 | Sec. 5.7，Table 9，PDF 19-20 |
| P2026-0035 | LBABC 在 onlooker bee phase 把每个 non-dominated path 视为 agent，共享 Q-table 选择六个 path-level evolutionary operators | 作者提出的方法 | Sec. 4.5 / Algorithm 8 |
| P2026-0035 | 状态由 path length、safety、smoothness 相对当前 non-dominated set 均值的优劣组合成 8 类 | 状态设计 | Sec. 4.5.1 / Table 1 |
| P2026-0035 | Reward 由新旧路径 dominance 关系定义为 `+1/0/-1`，并用随时间增大的 greedy probability 平衡探索和利用 | 状态-奖励-策略设计 | Sec. 4.5.1 / Eq. (11)-(12) |
| P2026-0035 | 用随机策略替代 Q-learning 的 `LBABC_NQ` 在 16 个路径规划实例上 HV 均弱于 LBABC，平均 RPI 为 `2.68`，ANOVA p-value 为 `3.6756e-5` | 消融实验支持 | Sec. 5.4.3 / Table 9 / Fig. 12 |
| P2026-0035 | LBABC 在 16 个实例上 HV 和 IGD 全部最优，平均 HV 为 `0.7098`，平均 IGD 为 `0.32` | 综合实验支持 | Sec. 5.5 / Tables 11 and 15 |
| P2026-0137 | MO-QL-HH 将多校区课程排程的当前三目标值离散化为 Q-learning state，并把 10 个 random/greedy LLH 作为 action | 作者提出/采用的方法 | Sec. 3.3-3.5，Algorithm 3，PDF 9-13 |
| P2026-0137 | Reward 根据动作前后 `TT/CU/CCI` 相对 reference point 的改善计算，`epsilon` 根据 HV 停滞自适应调整 | 状态-奖励-策略设计 | Sec. 3.3，Eq. 24-26，PDF 10 |
| P2026-0137 | 20 个多校区排课实例中，MO-QL-HH 在 HV 上除 1 个实例外均最佳，在 IGD 上除 3 个实例外均最佳，C-metric 相对多数算法全实例占优 | 综合实验支持 | Sec. 4.4，Tables 9-11，PDF 18-19 |
| P2026-0137 | 去掉 greedy operators 或 random operators 的变体在 HV、IGD、C-metric 和收敛曲线上整体弱于完整 MO-QL-HH | 消融实验支持 | Sec. 4.5，Tables 13-14，Fig. 11，PDF 19-20 |
| P2026-0137 | 作者未来工作包括用 deep reinforcement learning 近似更大状态空间 Q-values，并处理动态扰动/实时重排 | 作者未来工作 | Sec. 5，PDF 20-21 |

## 证据边界

- 当前有十一篇论文证据；P2026-0042 支持 DQN 状态-动作收益学习，P2026-0239 支持 tabular Q-learning 对领域局部搜索算子的调度，P2026-0244 支持 DQN 对 CHT+遗传算子联合动作的调度，P2026-0201 支持 DDPG 对连续 operator portfolio ratio 的控制，P2026-0285 支持 Q-learning 在工程型交通信号 MOO 中调度 GA/DE/PSO/LS，P2026-0209 支持 Q-learning 在生产-配送调度中调度交叉/变异/KLS 策略组合，P2026-0273 支持双 Q-learning 同时控制 PSO/DE 参数和 elite 局部搜索策略，P2026-0117 支持 Q-learning 控制双种群 migration size，P2026-0020 支持 Q-learning 在双资源 EDFJSP 中调度 critical-path/block 局部搜索算子，P2026-0035 支持 Q-learning 在移动机器人路径规划中调度 path-level local operators，P2026-0137 支持 Q-learning 在多目标排课 hyper-heuristic 中调度随机/贪婪 LLH。
- 实验动作集合主要是 GA 和 DE，尚未证明大动作空间下的稳定性。
- P2026-0239 的动作集合较大但状态表达和 reward 较粗，且不属于 DRL/DQN 实例；尚未与 DQN、UCB 或成功率统计同框比较。
- P2026-0244 的 CMOP 证据依赖小动作池和 benchmark/supplementary 结果，reward 中 IGD 在真实未知 PF 场景下需要替代指标。
- P2026-0201 只在 EMCMO 中嵌入 AOP，动作集合只有三种 variation operators，仍需跨 CMOEA 框架、更多算子类型和真实 CMOP 验证。
- P2026-0201 的 feasibility state 只使用 average CV，可能掩盖单个关键约束；其 HV reward 与最终 IGD 评价之间也需要更细致的对应分析。
- P2026-0285 的性能来自层级搜索、memory-based evaluation、robust objective 和 Q-learning 算子调度的组合，消融只去掉 RL 策略，不能完全隔离每个状态特征或每个算子的独立贡献。
- P2026-0285 使用 tabular Q-learning，状态离散化、Q-table 泛化和算子选择频率细节仍需复核；其证据来自交通仿真而非标准 EMO benchmark。
- P2026-0209 的性能来自三种群协作、KLS、启发式初始化和 Q-learning 的组合，随机动作消融只能证明策略学习有贡献，不能单独隔离每个状态特征或动作组合。
- P2026-0273 的性能来自粒子分类、启发式初始化、PSO+DE 混合、疲劳模型和双 Q-learning 的组合；`IDPSO_nql` 只能证明 Q-learning 有贡献，不能单独隔离参数控制器与局部搜索控制器。
- P2026-0117 缺少去掉 Q-learning migration 或固定 migration size 的消融，现有证据只能说明完整 RL-CNSGA-II 相对 NSGA-II/SPEA-II 的综合优势，不能单独归因于 migration-size 学习。
- P2026-0020 的性能来自增强 NSGA-III、restart-aware decoder、local search 和 Q-learning 的组合；QMOMA04/QMOMA05 消融支持 adaptive operator selection 有贡献，但状态特征、reward 和每个邻域的独立贡献仍未完全隔离。
- P2026-0035 的性能来自 competition initialization、DE employed bee、Q-learning onlooker bee 和 adaptive scout restart 的组合；`LBABC_NQ` 随机动作消融支持 Q-learning 算子选择有贡献，但不能单独说明每个 path operator、状态维度或 reward 取值的独立贡献。
- P2026-0137 的性能来自 MCUCSP 模型、贪婪初始化、编码解码、repair、10 个 LLH 和 Q-learning 选择的组合；去 random/greedy operators 的消融支持完整动作库必要性，但没有单独比较随机动作选择、成功率/bandit 控制和 Q-learning 控制。
- IGDF 结果不总是领先，说明该策略更偏向决策空间覆盖和多模态解集发现。
- 与成功率统计、bandit 或 Thompson sampling 的直接同框消融不足。
- 地图应用只有一个现实案例，工程泛化还需更多验证。

## 待确认

- 状态特征应如何表达多个等价 PS 的局部结构；
- reward 应如何平衡收敛、决策空间覆盖、可行性和计算成本；
- 是否需要按参考向量、簇或约束状态维护多个策略；
- DQN 训练频率、replay buffer 大小和探索概率如何随评价预算自适应；
- 在昂贵优化、动态优化和强约束优化中是否仍比轻量 bandit 控制更划算；
- 连续 operator portfolio 输出如何在小种群中稳定离散为 offspring 数量；
- 是否应把 operator cost、repair success 和 per-constraint violation 纳入 state/reward；
- tabular Q-learning 的状态离散粒度、Q-table 稀疏性和跨场景复用能力如何设置。
