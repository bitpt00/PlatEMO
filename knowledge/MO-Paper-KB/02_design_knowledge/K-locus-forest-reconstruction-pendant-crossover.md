---
knowledge_id: K-locus-forest-reconstruction-pendant-crossover
name: locus 森林重构与叶节点交叉
type: method
status: active
source_papers: [P2026-0018]
aliases: [forest-structured locus encoding, BFS reconstruction, spanning forest reconstruction, pendant vertex crossover, leaf-node crossover, pseudo local search, locus-based community detection, 叶节点交叉, 森林结构重构, locus 编码社区检测]
promotion_reason: 单篇论文提出但机制接口完整，包含 label-to-locus 的 BFS spanning forest 重构、叶节点边界高概率交叉、标签空间模块度贪婪搜索与 locus 基因同步修补，可直接迁移到图聚类、社区检测和连通结构编码的离散多目标算法。
---

# locus 森林重构与叶节点交叉

## 核心内容

在图划分或社区检测中，如果一个解的编码会自然诱导出树、森林或连通分量结构，就不要把基因位置当成彼此独立的普通数组。先在更容易构造和局部搜索的标签空间中生成或修改分组，再把每个分组重构成以代表节点为根的 spanning forest；演化交叉时，额外识别森林中的 pendant vertices/leaf nodes，把它们视为社区边界或结构可调整点，给予更高交叉概率；局部搜索在标签空间执行，同时把对应 locus 基因修补为目标社区中的邻居，保持编码与划分的大体一致。

```text
label partition
-> per-cluster rooted spanning tree by BFS
-> locus-based representation
-> uniform crossover + extra mask on leaf/boundary vertices
-> decode to labels
-> greedy label move by modularity gain
-> repair changed locus gene to a neighbor in target label
```

该知识的核心不是一般“社区检测”或“图编码”，而是把编码诱导出的森林结构变成初始化、交叉和局部搜索的共同接口。

## 建立理由

- 为什么值得独立维护：
  - 许多离散 MOO 问题中，编码不仅表示变量值，还隐含连通性、路径骨架或组件归属；
  - 普通 uniform crossover/mutation 对所有基因等概率处理，容易破坏结构骨架；
  - 直接在 locus 编码上做局部搜索困难，但标签空间局部移动容易定义；
  - P2026-0018 给出可实现的 reconstruction、pendant crossover 和 pseudo local search，并有真实/合成网络和消融证据。
- 单篇具体方法的直接复用价值：
  - BFS spanning forest reconstruction 可作为 label-to-structure 的通用转换层；
  - pendant/leaf nodes 可作为低成本边界候选，不需要昂贵的全局边界检测；
  - pseudo-LS 展示了如何在更易搜索的表型空间改动，再把改动写回结构基因；
  - mutation omission 提醒：对连通分量敏感编码，随机微扰可能不再是“轻微扰动”。
- 与已有设计知识的区别：
  - 不同于动态多层超图知识：本知识处理静态图上的 locus 森林算子，不搜索动态超边、跨层耦合或成本目标；
  - 不同于稀疏 mask 继承知识：本知识不是学习哪些变量非零，而是维护分组连通结构；
  - 不同于 schema repository 重构：本知识不保存组件库，而是每次从标签划分即时重构 spanning forest；
  - 不同于结构保真 NAS 编码：本知识的结构是图社区/连通分量森林，不是神经网络拓扑合法性。

## 解决的问题

- 适用场景：
  - 解表示可以解码为图上的分组、簇、区域或连通组件；
  - 标签空间容易初始化或局部搜索，但结构编码更利于连通性、搜索空间压缩或可行性；
  - 编码中的叶节点、边界节点、低度节点或桥接边可被快速识别；
  - 目标之间存在折中，需要保留多个社区划分、区域划分或图结构方案。
- 现有方法为什么会失败或不足：
  - 纯标签编码不保证连通性，且搜索空间大；
  - 纯 locus/边编码降低搜索空间，但局部搜索难定义；
  - 普通 mutation 可能把一个局部基因改动放大成全局连通分量改变；
  - 普通 crossover 忽略边界位置，可能在稳定内部节点上浪费扰动预算。
- 仍需解决的问题：
  - 如何把“叶节点”扩展为更稳健的边界置信度；
  - 如何避免 spanning forest reconstruction 过度依赖随机中心节点或随机邻居；
  - 如何给 pseudo local search 加多目标接受准则，而不是只看模块度增益；
  - 如何把 `O(n^3)` 全局相似矩阵替换为可扩展近似。

## 为什么可能有效

```text
label-space initialization
-> fast to assign nodes by central-node similarity

BFS reconstruction
-> converts coarse labels into a connected structural genotype

leaf-node crossover
-> spends disruption budget on probable community boundaries

label-space pseudo-LS
-> uses cheap local label moves
-> repairs the structural genotype after each move

no random mutation
-> avoids small locus edits causing large partition jumps
```

关键假设是：高质量划分可以通过相对规整的局部连通骨架表示，边界或叶节点比社区内部节点更适合接受遗传重组。如果图非常树状、叶节点本身就是稳定末端，或真实社区边界主要由高介数桥节点而非叶节点决定，仅靠 pendant vertices 可能不足。

## 实现接口

- 输入：
  - 图 `G=(V,E)` 或可定义邻接关系的问题结构；
  - 一个 label-based partition 或可生成标签的初始化器；
  - 代表/中心节点集合；
  - 邻接矩阵、相似矩阵或局部邻域查询；
  - 交叉概率 `pc1` 和边界/叶节点概率 `pc2`。
- 输出：
  - locus/tree/forest-style genotype；
  - 经过边界交叉的 offspring；
  - 局部搜索后的标签划分或修补后的结构个体。
- 插入位置：
  - 图聚类/社区检测 MOEA 的初始化和 variation 层；
  - 连通区域划分、路网区域编码、任务簇分配的编码修复层；
  - 离散 MOO 中 phenotype-space local search 与 genotype repair 的桥接层。
- 最小实现：

```text
initialize labels:
    choose centers
    assign each non-center node to nearest/similar center

reconstruct(labels):
    for each label group:
        build induced subgraph
        run BFS from center
        set each non-root gene to its BFS parent
    for roots/disconnected nodes:
        set gene to a random neighbor

crossover(parent1, parent2):
    cm1 <- Bernoulli(pc1) over all vertices
    leaves <- pendant vertices in parent1 union parent2
    cm2 <- Bernoulli(pc2) over leaves
    swap genes where cm1 or cm2 is active

pseudo_local_search(individual):
    labels <- decode(individual)
    for node in random order:
        candidate_labels <- labels of neighbors
        c <- argmax modularity_gain(node -> candidate_label)
        labels[node] <- c
        individual[node] <- random neighbor with label c
    return labels at final iteration, otherwise individual
```

## 如何用于算法创新

### 局部创新

- 用更稳健的边界检测替代单纯 pendant vertex：
  - 邻居标签熵；
  - incident cut-edge ratio；
  - local conductance；
  - betweenness 或 bridge score；
  - 多目标贡献下降敏感度。
- 给 `pc1/pc2` 做自适应：
  - 叶节点交换后的 offspring 被保留比例高，则提高 `pc2`；
  - 内部节点交换贡献更大，则提高 `pc1`；
  - 若连通分量大幅震荡或重复解增加，则降低两者。
- 把 pseudo-LS 从单目标模块度改成多目标邻域采样：
  - 对每个节点保留多个非支配标签移动；
  - 用 KKM/RC、modularity、conductance 或目标增量共同筛选；
  - 把局部搜索结果加入 archive 而不是只覆盖原个体。
- 用近似相似度替代全局 diffusion kernel：
  - personalized PageRank；
  - truncated heat kernel；
  - node2vec/GNN embedding 距离；
  - 局部共同邻居或 Jaccard 相似。

### 结构创新

- 构建“表型标签搜索 + 结构基因重构”的通用模板：

```text
phenotype:
    cluster/community/team/region labels

structural genotype:
    forest/tree/path/connected-skeleton pointers

operators:
    label-space initialization
    structure reconstruction
    boundary-focused recombination
    phenotype-space local search
    genotype repair
```

- 在路网区域划分中：
  - 先按交通相似性给道路节点分区；
  - 为每个区生成连通骨架；
  - 只在边界路段或末端路段高概率重组。
- 在任务簇分配中：
  - 先按空间/能力标签分组；
  - 为每组构造可执行的任务连接树；
  - 对叶任务或边界任务执行跨簇交换。
- 在动态图中：
  - 把上一时刻的 forest 作为 warm start；
  - 只对新出现、消失或边界不稳定节点做高概率交叉；
  - 用时间稳定性约束限制 pseudo-LS 的标签移动。

## 适用条件与风险

- 适用条件：
  - 图或邻接关系可靠，邻居集合有实际语义；
  - 标签划分和结构编码之间可以相互转换；
  - 连通性、局部骨架或边界位置对解质量有贡献；
  - 局部搜索的表型增益可以较快计算；
  - 评价预算允许周期性 decode/reconstruct。
- 不适用或可能失效的条件：
  - 分组不需要连通性，结构重构会增加无意义约束；
  - 图极端稀疏且大量叶节点是稳定内部结构，pendant crossover 会扰动错误位置；
  - 中心节点随机性过强，BFS forest 质量不稳定；
  - 局部目标和多目标选择冲突明显，单目标 LS 可能把解推离 Pareto 前沿；
  - 全局相似矩阵计算过重，抵消了后续算子的效率收益。
- 计算与实现成本：
  - 需要维护 genotype-phenotype decode/encode；
  - reconstruction 要处理断开子图和根节点特殊情况；
  - pseudo-LS 修改标签后必须同步修补结构基因；
  - 相似矩阵和局部搜索可能成为大规模图上的主要瓶颈。
- 证据风险：
  - P2026-0018 的参数默认值前后不一致；
  - baseline 结果来自已有文献而非完全同平台复跑；
  - runtime 声明仅供参考；
  - pendant vertex 等价于边界节点是启发式假设，尚缺独立理论证明。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0018 | locus-based representation 将基因解释为节点间链接，解码连通分量得到社区数量，无需预设社区数 | 编码基础 | Sec. 2、Fig. 1，PDF 3 |
| P2026-0018 | 初始化使用 diffusion kernel similarity matrix `S=exp(-(D-A))` 和随机中心节点分配非中心节点 | 初始化设计 | Sec. 4.1、Algorithm 1，PDF 4 |
| P2026-0018 | Reconstruct 对每个中心对应的诱导子图生成 rooted spanning tree，BFS 中非根节点选择父节点作为 locus value | 作者提出的方法 | Sec. 4.1、Algorithm 2，PDF 4 |
| P2026-0018 | 对 locus 森林的 pendant vertices/leaf nodes 设置额外 crossover mask，并认为它们是社区边界候选 | 作者提出的方法 | Sec. 4.2、Fig. 2，PDF 5 |
| P2026-0018 | mutation 被省略，因为 locus 编码小扰动可能引起宏观社区划分大变 | 机制解释 | Sec. 4.2，PDF 5 |
| P2026-0018 | pseudo-LS 解码为标签、按邻居标签最大化 `Delta Q`，再把 locus gene 设为目标社区中的随机邻居 | 作者提出的方法 | Sec. 4.3、Algorithm 3，PDF 5 |
| P2026-0018 | Algorithm 4 将 initialization、pendant crossover、KKM/RC 评价、NSGA-II 环境选择和周期 pseudo-LS 组合 | 算法流程 | Sec. 4.4、Algorithm 4，PDF 5 |
| P2026-0018 | 11 个真实网络上 proposed MOEA 在 modularity 上整体达到 best 或 second best，大规模网络表现更强 | 实验支持 | Sec. 5.4.1、Table 3，PDF 6-7 |
| P2026-0018 | 有 ground truth 的 4 个真实网络上 proposed MOEA 均取得最大 NMI，Karate 和 Polbook 平均 NMI 最好 | 实验支持 | Sec. 5.4.2、Table 4，PDF 7 |
| P2026-0018 | Fb-tvshow 预实验显示随机 mutation `pm=0.1` 未提升模块度且收敛更不稳定 | 设计选择证据 | Sec. 5.5、Fig. 3，PDF 8 |
| P2026-0018 | 初始化变体 A/B/C 在大规模网络上均弱于原始方法，说明相似矩阵初始化与重构组合有效 | 消融证据 | Sec. 5.6、Tables 5-6，PDF 8-9 |
| P2026-0018 | LFR 实验中 `mu=0.1..0.6` 保持较好 NMI，`mu=0.7` 明显退化，`n=500..2500` 下表现仍满意 | 合成实验支持 | Sec. 5.6、Fig. 4，PDF 9 |
| P2026-0018 | 参数分析显示普通 uniform crossover 或只在 pendant points 上交叉均表现较差，中等 `pc1/pc2` 更优 | 参数证据 | Sec. 5.6、Fig. 5，PDF 9 |

## 证据边界

- 该知识目前主要由单篇论文支持，尽管有真实网络、LFR、消融和参数分析，但尚未被独立复现；
- 参数默认值在正文前后不一致，迁移时应把 `pc1/pc2` 作为待调参数；
- 叶节点边界假设在不同图类型上的可靠性需要额外验证；
- 若问题没有清晰邻接关系或连通性要求，重构成 forest 可能只是增加实现负担。
