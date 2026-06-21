---
knowledge_id: K-rank-based-auxiliary-speed-decision-refinement
name: 非支配排名驱动的辅助速度决策修正
type: method
status: active
source_papers: [P2026-0215]
aliases: [rank-based speed selection, auxiliary variable refinement, speed decision repair, route speed selection, nondominated-rank auxiliary decision, 速度档位修正, 辅助变量rank修正, 绿色路由速度选择]
promotion_reason: 单篇论文提出但接口清楚，包含主结构子代、辅助速度极端探测、非支配 rank 比较和逐弧局部修正，可迁移到绿色路由、调度能耗模式、机器速度和其他主结构加辅助档位的组合 MOO
---

# 非支配排名驱动的辅助速度决策修正

## 核心内容

对有两层决策的组合多目标问题，先由遗传操作生成主结构子代，再单独修正辅助档位变量。以绿色路由中的速度档位为例，同一主结构先构造“全最高速度”和“全最低速度”两个极端版本，分别加入当前种群做非支配排序；选择 rank 更优的极端作为起点，然后逐步升高或降低单条弧的速度，只接受能改善个体非支配 rank 的修改。

```text
主结构 H(S) 由交叉/变异生成
-> 构造 Smax = H(S) + 全最高速度
-> 构造 Smin = H(S) + 全最低速度
-> 分别与当前父代 P 合并做非支配排序
-> 选 rank 更好的极端速度向量作为起点
-> 随机选择可改善 arc 调整速度档位
-> 若 P ∪ {S} 中 rank 改善则接受
-> 输出完整个体 S = H(S) + R(S)
```

## 建立理由

- 为什么值得独立维护：很多绿色调度、路由和生产优化问题都有“主结构”与“辅助档位”两类变量。直接随机变异全部变量容易破坏结构或漏掉辅助变量形成的细粒度 tradeoff，该设计给出简单可插拔的辅助变量后修正层。
- 已有跨论文支持，或单篇具体方法的直接复用价值：P2026-0215 在 MO-GpHCRP 中证明许多 NDS 共享 hub location/allocation/routing 而只速度档位不同，并在 AP 实例上得到比 SAA-P 更好的中大规模 Pareto 近似。
- 与已有设计知识的区别：
  - 不同于“结构启发初始化与多目标路径重联”：该知识沿两个精英结构之间生成中间路径；本知识在单个结构子代上修正辅助档位变量。
  - 不同于“成功率反馈的算子与参数自适应选择”：该知识选择算子/参数；本知识直接优化个体内部的辅助速度档位。
  - 不同于“前向事件解码与反向能耗压缩调度”：该知识是调度解码和时间压缩；本知识是通用 rank-based auxiliary decision refinement。
  - 不同于“IUD-ERT-RLS 批调度启发式解码”：该知识从编码构造批和时间；本知识在已可行结构后处理速度/模式档位。

## 解决的问题

- 适用场景：
  - 解由主组合结构和辅助离散/有序档位共同决定；
  - 辅助变量在目标之间形成明显 tradeoff，例如速度越高时间越短但排放/能耗越高；
  - 主结构交叉变异后仍需快速给辅助变量一个合理配置；
  - 当前种群可提供非支配 rank 作为低成本相对质量信号。
- 现有方法为什么会失败或不足：
  - 固定速度或随机速度可能只覆盖 tradeoff 的一小部分；
  - 把速度和主结构一起交叉变异会扩大搜索空间并破坏局部语义；
  - 单目标贪心速度只会偏向时间或排放一端；
  - 完整枚举所有速度组合不可行。
- 仍需解决的问题：
  - rank 改善是否足够敏感，是否需要 crowding/HV 等二级准则；
  - 多个辅助变量强耦合时，单弧逐步调整可能陷入局部；
  - 如何选择调整次数 `c_speed` 和 arc 选择策略。

## 为什么可能有效

```text
主结构决定可行网络骨架
-> 辅助速度决定服务时间与排放的细粒度折中
-> 极端速度探测给出当前结构更有希望的优化方向
-> 非支配 rank 用当前种群作为动态参考系
-> 单步接受 rank 改善, 避免辅助变量随机扰动
-> 同一结构可展开出多个 Pareto 折中
```

核心假设是：辅助变量相对主结构更适合局部修正，并且当前种群的非支配 rank 能反映该子代在目标空间中的相对位置。如果种群尚未形成有效参考，rank 信号会偏噪。

## 如何用于算法创新

### 局部创新

- 在绿色车辆路径中，先变异 route，再用 rank-based procedure 设置每条弧速度。
- 在节能调度中，先生成机器顺序/批次，再调整机器速度、功率模式或空闲策略。
- 将接受准则从纯 rank 改为 rank 优先、crowding/HV contribution 次之。
- 用启发式优先选择高载重、高距离、高拥堵或高边际排放弧，而不是随机 arc。
- 把极端探测扩展为多档 anchor，例如最低、经济、最高三种速度模板。

### 结构创新

- 构建二层组合 MOEA：主结构层负责可行骨架，辅助档位层负责目标 tradeoff densification。
- 将辅助变量修正作为 offspring repair，也可作为外部档案后处理，用来在不改变主结构的情况下加密 Pareto 前沿。
- 与 operator selection 结合：如果某类主结构经速度修正后贡献高，则提高对应交叉/变异概率。
- 与代理模型结合：用代理预测哪条弧的速度调整最可能改善 rank，减少反复非支配排序。

## 适用条件与风险

- 适用条件：
  - 辅助变量有明确有序档位；
  - 单次辅助变量调整后能快速重算目标值；
  - 主结构和辅助变量可分离编码；
  - 当前种群规模足以提供有意义的非支配 rank。
- 不适用或可能失效的条件：
  - 辅助变量是连续高维且目标重算昂贵；
  - 辅助变量之间强非线性耦合，单步调整不可靠；
  - rank 大量并列或同 front 个体过多，rank 信号分辨率不足；
  - 目标包含硬时间窗或法规速度约束，局部调速频繁导致不可行。
- 计算与实现成本：
  - 每个子代至少要对 `P ∪ {Smax}` 和 `P ∪ {Smin}` 做排序；
  - 每次候选速度调整还可能触发一次排序或 rank 评估；
  - 相比全局枚举速度组合成本低，但在大种群和多弧路线中仍需缓存和增量评价。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0215 | MO-GpHCRP 将 hub location-allocation-routing 结构 `H(S)` 与速度向量 `R_k(S)` 分开编码 | 作者提出的方法 | Sec. III-B，Fig. 2，PDF 4 |
| P2026-0215 | Rank-based speed selection 先比较全最高速度 `Smax` 和全最低速度 `Smin` 在当前种群中的非支配 rank | 作者提出的方法 | Sec. III-E，Algorithm 3，PDF 6 |
| P2026-0215 | 若低速极端 rank 更好则从低速起点逐步升速，若高速极端 rank 更好则从高速起点逐步降速，每次只接受 rank 改善 | 作者提出的方法 | Sec. III-E，Algorithm 3，PDF 6 |
| P2026-0215 | AP 实例调参显示 `P=100,G=250,Cr=0.9,Mr=0.8` 在 NDS、HI、SSM 和时间之间较优 | 参数证据 | Sec. IV-A，Figs. 3-4，PDF 7-8 |
| P2026-0215 | 中大规模 AP 实例中 `|N|>=25` 多数情况下 NSGA-II 平均表现优于 SAA-P，最大实例 CPU 为 `5637.36s` vs `10103.868s` | 综合实验支持 | Sec. IV-B，Table III，PDF 8-9 |
| P2026-0215 | 25 个 AP 实例上 NDS、HI、SSM 的 Wilcoxon signed-rank `Sig.(2-tailed)=0.00`，支持 NSGA-II Pareto 近似相对 SAA-P 有显著差异 | 统计证据 | Sec. IV-B，Table IV，PDF 9 |
| P2026-0215 | 小实例 Pareto 分析显示部分 NDS 共享 hub pair 和 route 结构，主要由速度选择形成不同 tradeoff | 机制解释 | Sec. V-A，Table V/Fig. 8，PDF 10 |
| P2026-0215 | 作者结论明确指出 speed selection procedure 对发现多样 Pareto frontier approximations 起重要作用 | 机制总结 | Sec. VI，PDF 13 |
| P2026-0215 | 作者未来工作包括研究 adaptive mutation rate 和各 crossover/mutation operator 的单独贡献 | 边界与未来工作 | Sec. VI，PDF 14 |

## 待确认

- 纯 rank 接受是否应加入 crowding distance、epsilon dominance 或 HV contribution；
- `c_speed` 应如何按 route 长度、目标冲突强度或历史收益自适应；
- 大规模场景中能否用增量非支配排序降低速度修正成本；
- 辅助档位不是单调 tradeoff 时，极端速度探测是否仍有效；
- 与随机速度、贪心速度、局部搜索速度和代理速度分配的系统消融仍需补充。
