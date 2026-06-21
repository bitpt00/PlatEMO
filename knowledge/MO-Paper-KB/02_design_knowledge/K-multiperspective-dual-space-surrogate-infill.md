---
knowledge_id: K-multiperspective-dual-space-surrogate-infill
name: 多视角双空间代理训练样本采样
type: method
status: active
source_papers: [P2026-0115]
aliases: [MP-SAMaOEA, multi-perspective infill criterion, surrogate training-value infill, decision-objective angle infill, expensive super-many-objective sampling, 多视角填充采样, 双空间训练样本价值]
promotion_reason: 单篇论文提出但接口清晰，包含候选到最近真实训练样本的决策空间距离、目标空间角度、非支配排序选点和代理内 k-means 多样性增强，可迁移到昂贵 many-objective/super-many-objective 代理辅助优化的真实评价调度层。
---

# 多视角双空间代理训练样本采样

## 核心内容

在昂贵 many-objective 或 super-many-objective 优化中，不只问候选解在当前 surrogate 上是否表现好，而是问它作为新训练样本是否能改善 surrogate。对每个代理搜索后的候选，先在真实评价档案中找决策空间最近的训练样本，再计算二者在目标空间中的夹角；用决策距离和目标角度做非支配排序，选择少量非支配候选真实评价并回灌训练集。

```text
true-evaluated archive
-> train one surrogate per objective
-> surrogate-assisted MaOEA generates candidate population
-> for each candidate: nearest archive sample in decision space
-> decision distance + objective-space angle to that sample
-> non-dominated sorting on two training-value indicators
-> true-evaluate selected candidates and update archive
```

P2026-0115 的 MP-SAMaOEA 还在 surrogate-assisted optimizer 内部加入 reference-vector selection 和 k-means-assisted diversity enhancement，避免低保真代理把候选池推到少数方向上，保证后续 infill 有足够可选的训练样本候选。

## 建立理由

- 为什么值得独立维护：
  - 它把 infill criterion 的目标从“当前候选 predicted performance”转向“候选加入训练集后的代理校正价值”，适合评价极贵、每轮只能回灌少量样本的场景。
  - 决策空间距离反映候选是否处在训练集覆盖区域，目标空间角度反映候选与邻近训练样本的响应方向差异，两者互补。
  - 非支配排序保留了“近且角度小的可信校正样本”和“一个视角远、另一个视角仍有结构关系的探索样本”，不用手调加权系数。
- 单篇具体方法的直接复用价值：
  - P2026-0115 给出 MP-SAMaOEA Algorithm 1、Algorithm 2、Fig. 2、DTLZ/WFG 消融、20 目标实验和水资源规划证据。
- 与已有设计知识的区别：
  - 不同于“目标级自适应代理与双空间 infill 采样”：该知识重点是每目标 GP/RBF 选模和双空间稀疏性采样；本知识固定逐目标 GP，重点是候选相对最近训练样本的训练价值。
  - 不同于“MLP 子空间筛选与稀疏 GP 的高维昂贵 MOO”：该知识先处理高维子空间和 sparse GP，本知识主要是 infill 层接口。
  - 不同于“特殊点引导的代理辅助复杂前沿搜索”：该知识围绕膝点和断裂区域调度，本知识不依赖特定 PF 形态。
  - 不同于“网格排序成对关系代理筛选”：该知识训练 pairwise relation surrogate，本知识仍使用 objective-value surrogate，但改造真实评价样本选择。

## 解决的问题

- 适用场景：
  - 真实目标函数评价昂贵，surrogate 训练和查询相对便宜；
  - 目标数很多，逐目标代理误差容易累积；
  - 每轮只能选择少量候选做真实评价；
  - 已维护真实评价 archive，且候选可以与 archive 计算决策空间距离；
  - 需要在 exploitation 和 exploration 间保持柔性折中，而不想设置固定权重。
- 现有方法为什么会失败或不足：
  - 只看代理预测目标值会过度相信低保真前沿；
  - 只看不确定性或稀疏度可能采到远离 Pareto 搜索价值的点；
  - 只看 objective space 无法发现决策空间中重复采样的问题；
  - 只看 decision space 又无法判断局部目标响应是否已经被训练样本解释；
  - 在 super-many-objective 下，代理误差、候选多样性和选择压力都会被目标数放大。
- 仍需解决的问题：
  - 决策距离和目标角度的优化方向、归一化和 tie-breaking 需要明确；
  - 最近训练样本是否足以代表局部训练价值，还是应使用 k-nearest samples；
  - 如何把 GP uncertainty、rank preservation 或真实贡献历史合入同一 infill 排序；
  - 非欧几里得、离散、图结构或等价编码决策空间需要替换距离度量。

## 为什么可能有效

```text
候选靠近真实样本
-> 代理局部预测通常更可信
-> 若目标角度也小，可作为可靠局部校正样本

候选在某个视角远、另一个视角仍有结构联系
-> 可能扩展训练集覆盖或补充前沿边缘信息
-> 非支配排序保留这类探索样本

两个视角都差
-> 难以提升代理且搜索价值不明
-> 不优先消耗真实评价预算
```

关键假设是：候选与最近真实样本的决策空间距离和目标空间角度能近似反映 surrogate 的局部训练缺口。如果决策编码存在大量等价表示、目标映射强不连续或高维距离集中，该假设会变弱。

## 如何用于算法创新

### 局部创新

- 把 `Dis` 从普通欧氏距离替换为变量分组距离、Mahalanobis distance、Hamming distance、edit distance、graph distance 或 learned latent distance。
- 把 `Ang` 替换或扩展为 local ranking disagreement、Jacobian direction difference、posterior predictive variance、conformal residual 或 Pareto-rank consistency。
- 用 k-nearest archive samples 的均值/方差替代单个最近样本，降低偶然邻居误导。
- 将非支配排序后的第一前沿再按 HV contribution、APD、uncertainty 或 reference-vector coverage 做二级选择。
- 在 early stage 偏向大 `Dis` 探索，在 late stage 偏向小 `Dis` 与稳定角度校正，用阶段参数调节排序或采样概率。

### 结构创新

- 构建训练价值驱动的 surrogate management：

```text
archive health diagnostics
-> candidate training-value indicators
-> infill frontier selection
-> true evaluation
-> per-objective surrogate error audit
-> adjust next candidate-generation pressure
```

- 与 objective-wise model selection 结合：对误差大的目标，增加目标角度或该目标 residual 相关指标权重。
- 与 reference-vector MaOEA 结合：每个参考方向先保留若干候选，再在方向内做训练价值排序，避免所有真实评价集中到同一方向。
- 与异构评价时间结合：训练价值指标除以预计评价时间，选择单位成本信息量高的候选。
- 与 active learning 结合：把非支配训练价值前沿作为 acquisition pool，再用 batch diversity 去重。

## 适用条件与风险

- 适用条件：
  - archive 中已有足够真实评价样本，可以计算稳定的最近邻关系；
  - 决策空间距离与局部函数相似性大体相关；
  - 目标空间角度能表达响应方向差异；
  - 每轮真实评价预算足够小，使 infill 选择质量成为关键；
  - 代理内搜索能产生覆盖多个参考方向的候选池。
- 不适用或可能失效的条件：
  - 高维连续空间中欧氏距离集中，最近邻区分度很低；
  - 决策变量有强等价编码，距离近不代表行为相似，距离远也可能表示同一方案；
  - 目标函数强噪声、强不连续或多模态，使最近样本角度无法代表局部结构；
  - irregular 或 multimodal PF 需要专门保留多等价 PS，本方法本身没有该机制；
  - 真实评价预算并不紧张时，复杂 infill 可能不如直接增加评价样本。
- 计算与实现成本：
  - 每轮要计算候选到 archive 的最近邻，archive 较大时需 KD-tree、ANN 或分批距离；
  - 每目标 GP 训练仍可能有 `O(|Arc|^3)` 成本；
  - reference-vector association 和 k-means diversity enhancement 增加代理内循环开销；
  - 指标方向和尺度处理不当会改变非支配排序结果。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0115 | MP-SAMaOEA 包含 LHS 初始化、逐目标 GP、代理内优化、multi-perspective infill 和 archive 回灌 | 作者提出的方法 | Sec. 3.1，Algorithm 1，PDF 3-4 |
| P2026-0115 | k-means-assisted diversity enhancement 在某参考向量方向候选数超过 `2|Pop|/3` 时，将子群分为 `ceil(mu/3)` 个簇并每簇选近 ideal 解 | 作者提出的方法 | Sec. 3.2.2，PDF 4 |
| P2026-0115 | Algorithm 2 对每个候选计算到最近训练样本的 decision-space Euclidean distance 和 objective-space angle，并做非支配排序选真实评价点 | 作者提出的方法 | Sec. 3.3，Algorithm 2，Fig. 2，PDF 4-5 |
| P2026-0115 | 消融中完整 MP-SAMaOEA 对只用决策距离的 DEC 变体为 `8/0/4`，对只用目标角度的 OBJ 变体为 `12/0/0` | 消融实验支持 | Sec. 4.2，Table 1，PDF 6 |
| P2026-0115 | WFG 上 MP-SAMaOEA 在 27 个实例中取得 25 个 best，且相比五个 baseline 的 IGD+ better counts 为 21、25、19、27、24 | 综合实验支持 | Sec. 4.3.1，PDF 6 |
| P2026-0115 | DTLZ 上整体最好，best result 数为 11；相比五个 baseline 的 better counts 为 17、18、17、13、15 | 综合实验支持 | Sec. 4.3.2，Markdown/PDF 6-7 |
| P2026-0115 | 水资源规划问题中 MP-SAMaOEA 获得最高 HV `4.3544e-1 (2.65e-3)` | 真实应用支持 | Sec. 4.4，Table 4，Markdown/PDF 8 |
| P2026-0115 | 作者指出 MP-SAMaOEA 缺少处理 multi-modal 或 irregular PF 的策略 | 作者局限 | Sec. 5，Markdown/PDF 8 |

## 待确认

- Algorithm 2 中 `negative Ang_i` 与正文“smaller angle”之间的排序方向应如何在代码中实现；
- 单最近训练样本是否足够，还是 k-nearest 或局部密度更稳定；
- 决策距离、目标角度、uncertainty 和 predicted convergence 是否应统一成四目标 infill；
- 在离散、组合、图结构或生成模型潜空间中，什么距离最能代表训练价值；
- 对 multimodal PS 或 irregular PF，是否需要把 niche/mode preservation 与本 infill 前沿联合起来。
