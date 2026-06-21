---
knowledge_id: K-topology-and-evolution-sparse-guidance-vectors
name: 拓扑-演化双源稀疏引导向量
type: architecture
status: active
source_papers: [P2026-0091]
aliases: [TSSKEA, sparse knowledge guided MMOP, topology prior vector, historical sparse vector, current sparse vector, PV-SV-CV guidance, VSSPS, sparse biomarker optimization, 稀疏知识引导, 拓扑先验稀疏搜索, 历史非支配频率, 当前父代频率]
promotion_reason: 单篇论文提出但接口完整，包含稀疏条纹初始化、领域拓扑先验、历史非支配频率、当前父代频率、两阶段控制和可选潜空间生成，可直接迁移到特征选择、网络节点/边选择、稀疏组合设计和其他二进制大规模稀疏 MMOP/MOP。
---

# 拓扑-演化双源稀疏引导向量

## 核心内容

在大规模稀疏二进制多目标或多模态多目标问题中，把“哪些变量值得被置 1”表示成三类可直接用于繁殖的逐变量指导向量：领域结构先验 `PV`、历史非支配解激活频率 `SV`、当前父代激活频率 `CV`。初始化时先用不同稀疏率的条纹采样覆盖变量空间，演化前期只用相对稳定的领域先验，后期再融合历史和当前稀疏模式，并可把指导向量映射到潜空间生成子代。

```text
varied sparse stripe initialization
-> topology/domain-prior vector PV
-> historical nondominated activation vector SV
-> current parent activation vector CV
-> early stage: PV-guided sparse offspring
-> late stage: PV/SV/CV or latent-space CV-guided offspring
-> sparse Pareto / multimodal solution set
```

P2026-0091 的 TSSKEA 是该模式的实例：它在 PDNB/PDENB 识别中用分子交互网络度构造 `PV`，用历史非支配解构造 `SV`，用当前父代构造 `CV`，再在双亲二进制向量的差异位点上决定变量激活或去激活。

## 建立理由

- 为什么值得独立维护：
  - 许多高维二进制 MOP 的核心瓶颈不是目标函数形式，而是最优解只激活极少变量；
  - 单纯随机初始化会漏掉许多变量，单纯历史学习早期又缺少可靠样本；
  - 领域结构知识、历史 elite 模式和当前 population 状态各有偏差，但可互补。
- 单篇具体方法的直接复用价值：
  - P2026-0091 给出 VSSPS、`PV/SV/CV` 构造、两阶段使用规则、与 RBM 潜空间结合的完整实现路径；
  - 这些组件不依赖癌症应用本身，可以迁移到一般网络节点/边选择、特征选择、稀疏神经连接选择和组合设计。
- 与已有设计知识的区别：
  - 不同于“稀疏三任务 EMT 与保结构迁移”：该知识通过三任务和跨维迁移处理稀疏性；本知识在同一搜索空间中用逐变量指导向量驱动稀疏模式。
  - 不同于“质量-稀疏四象限的个体定制学习”：该知识按个体质量和稀疏度划分种群；本知识按变量被激活的结构先验和演化频率指导双亲差异位点。
  - 不同于“非支配掩码相似性引导的稀疏模式继承”：该知识继承或复用完整 mask；本知识把 mask 压缩为变量级概率/优先级，可以与任意二进制 crossover/latent generator 结合。
  - 不同于“统计排名引导的子集进化算子”：该知识偏向静态或统计筛选排序；本知识显式区分领域拓扑、历史 elite 和当前父代三种知识源，并用阶段机制调度。

## 解决的问题

- 适用场景：
  - 决策向量是二进制或可转成 mask 的稀疏选择问题；
  - 变量维度高，真实有效变量占比很小；
  - 存在可转成变量优先级的领域结构知识，例如网络度、路径中心性、特征相关图、依赖图、物理连接或任务可行组合；
  - 希望输出多个等价或互补 sparse Pareto solutions；
  - 可从非支配档案和当前父代中统计变量激活频率。
- 现有方法为什么会失败或不足：
  - 随机初始化在极稀疏空间中覆盖不足；
  - 只靠单变量重要性会忽略演化中出现的变量组合；
  - 只靠历史非支配频率会在早期样本少或噪声大时过早锁定错误稀疏模式；
  - 只靠当前父代频率会受局部收敛和短期漂移影响；
  - 潜空间生成若没有外部稀疏知识，容易学到当前档案的偏差。
- 仍需解决的问题：
  - 三类向量的权重或使用概率如何自适应；
  - 指导向量如何表达变量间组合依赖，而不仅是边际激活频率；
  - 当领域拓扑先验与目标函数冲突时如何识别和降权；
  - 稀疏率上下界如何自动估计。

## 为什么可能有效

```text
sparse optimum is rare
-> VSSPS prevents early zero-only blind spots
-> PV gives cold-start structural prior
-> SV accumulates long-term successful sparse patterns
-> CV preserves current search diversity and local state
-> staged control reduces noisy early feedback
```

关键假设是：领域结构先验与优质变量存在正相关，历史非支配解中的激活频率能逐步逼近有效稀疏模式，而当前父代频率能补充局部多样性。如果先验结构与目标无关、非支配集质量很差，或变量只有高阶组合才有效，简单逐变量频率可能误导搜索。

## 如何用于算法创新

### 局部创新

- 把普通 binary crossover 中“双亲不同的位置随机继承”改为由 `PV/SV/CV` 加权决定。
- 用 archive activation frequency 替换固定 mutation probability，对长期无贡献变量提高置零概率。
- 在 sparse initialization 中使用条纹式 coverage：每个个体有不同稀疏率，每个变量至少获得少量初始激活机会。
- 将 `PV` 从网络度扩展为 PageRank、betweenness、feature relevance、可行组合频率或任务图中心性。
- 对 `SV/CV` 加入时间衰减，避免早期错误模式长期残留。
- 用 guide-vector confidence 控制 mutation strength：高置信变量少扰动，低置信变量多探索。

### 结构创新

- 通用稀疏知识引导架构：

```text
domain-prior extractor
+ elite-history sparse memory
+ current-population sparse state
+ stage/quality controller
+ binary or latent offspring generator
```

- 与 EMT 结合：每个任务维护自己的 `PV/SV/CV`，跨任务迁移时只迁移高置信稀疏变量。
- 与代理模型结合：用 surrogate 预测变量激活贡献，再作为第四类 guide vector 与 `PV/SV/CV` 融合。
- 与多模态维护结合：为不同 niche 或 reference region 维护局部 `SV/CV`，避免所有解收敛到同一稀疏模式。
- 与约束处理结合：用可行解和低 CV 不可行解分别统计两套 `SV`，在可行性与目标优化之间切换。

## 适用条件与风险

- 适用条件：
  - 变量选择具有稀疏性；
  - 变量被置 0/1 的语义清晰；
  - 有可计算的变量级领域先验，或至少可从图/相关性/可行组合中构造先验；
  - 非支配档案规模足够支持频率统计；
  - 算法允许在子代生成算子中访问双亲差异位点。
- 不适用或可能失效的条件：
  - 最优解并不稀疏，或者稀疏率变化极大且难以设定边界；
  - 变量贡献主要来自高阶组合，边际激活频率很弱；
  - 领域先验与优化目标强冲突；
  - 非支配解数量过少，`SV` 退化为噪声；
  - 多模态任务中不同 niche 的有效变量相反，而全局 `SV/CV` 把它们混合。
- 计算与实现成本：
  - `PV` 一次性计算通常为 `O(D)` 到 `O(|E|)`，取决于先验图；
  - `SV/CV` 每代统计约 `O(ND)`；
  - VSSPS 初始化约 `O(ND)`；
  - 若引入 RBM 或其他潜空间模型，还需额外训练开销。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0091 | TSSKEA 将 PCB 识别建模为二进制 LSMMOP，目标为最小 biomarker size 和最大 early-warning score | 作者提出的方法 | Sec. 2.2，Eq. (5)-(6)，PDF 4-5 |
| P2026-0091 | VSSPS 用连续条纹和不同稀疏率初始化 population，保证个体稀疏且覆盖变量位置 | 作者提出的方法 | Sec. 3.1，Fig. 2，PDF 5-6 |
| P2026-0091 | `PV` 由分子交互网络拓扑计算，用于指导变量激活或去激活 | 作者提出的方法 | Sec. 3.2，Fig. 3，PDF 6-7 |
| P2026-0091 | `SV` 由历史非支配解和当前非支配解的变量激活频率加权更新 | 作者提出的方法 | Sec. 3.2，Eq. (2)-(3)，PDF 6 |
| P2026-0091 | `CV` 由当前父代 population 的变量激活频率构成，并用于保持当前搜索状态 | 作者提出的方法 | Sec. 3.2，Eq. (4)，PDF 6 |
| P2026-0091 | 两阶段策略在前半预算只用 `PV`，后半预算引入 `PV/SV/CV` 和 RBM 潜空间生成 | 作者提出的方法 | Sec. 3.3，Algorithm 1，PDF 7-8 |
| P2026-0091 | 相比 MMPDNB-RBM，TSSKEA 在 BRCA/LUSC/LUAD 的 PDNB early-warning score 上分别提升约 2.7、1.4、11.1 倍 | 综合实验支持 | Sec. 4.2，PDF 10-12 |
| P2026-0091 | TSSKEA 在 PDNB/PDENB 的 HV 和 Pareto front 可视化中显示更好收敛性与多样性 | 综合实验支持 | Sec. 4.3，PDF 12-14 |
| P2026-0091 | 去掉 VSSPS、`PV`、`SV` 或 `CV` 的消融变体均劣于完整 TSSKEA | 消融支持 | Sec. 4.5，PDF 15-16 |
| P2026-0091 | 在表达数据缺失、degree-preserved random rewiring 和 cross-validation 测试中，TSSKEA 仍保持较好鲁棒性 | 鲁棒性实验支持 | Sec. 4.6，PDF 16-18 |
| P2026-0091 | 作者指出 VSSPS 仍依赖预设稀疏边界，未来应整合 pathway/PPI 等多源知识并自适应调整 guide-vector 贡献 | 作者局限与未来工作 | Sec. 5，PDF 19 |

## 待确认

- `PV/SV/CV` 是否应在不同 reference region 或 niche 内局部维护，而不是全局维护一份；
- 当领域先验错误时，能否通过贡献反馈快速降权 `PV`；
- VSSPS 的稀疏率上下界能否由 archive sparsity distribution 在线估计；
- 是否需要二阶或图结构 guide vector 来表达变量组合，而不只使用逐变量边际频率；
- RBM 潜空间是否可替换为 VAE、diffusion 或轻量 autoencoder，并保持二进制稀疏可解释性。

