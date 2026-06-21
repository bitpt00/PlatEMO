---
knowledge_id: K-pareto-metropolis-discrete-substitution-search
name: 非支配退火的离散替换优先级搜索
type: method
status: active
source_papers: [P2026-0291]
aliases: [MOSA-S2, multiobjective simulated annealing, Pareto-rank Metropolis acceptance, nondominated sorting simulated annealing, stopword substitution attack, rubbish text attack, discrete substitution priority search, 非支配排序模拟退火, Pareto退火, 离散替换搜索, 垃圾文本攻击]
promotion_reason: 单篇论文提出但接口明确，包含离散替换候选构造、重要性采样、单双扰动候选、非支配排序 rank、温度控制的 Metropolis 接受和多组消融证据，可直接改造文本攻击、反事实解释、离散输入修复和符号候选搜索中的多目标优先级优化。
---

# 非支配退火的离散替换优先级搜索

## 核心内容

当一个离散替换任务同时追求多个冲突目标时，不把目标硬加权成单目标，而是在每个温度下生成一批候选替换，对候选做非支配排序，再用 Pareto rank 与温度共同决定是否接受新解。支配当前解的候选直接接受；不支配的候选也可以按 Metropolis probability 被接受，从而保留模拟退火跳出局部最优的能力。

```text
current discrete solution
-> importance-aware candidate sampling
-> single/double or other local perturbations
-> filter candidates by hard constraints
-> nondominated sorting on conflicting objectives
-> accept dominating candidate
-> otherwise accept by rank-temperature probability
-> cool temperature and repeat
```

P2026-0291 的实例是 MOSA-S2：在 rubbish text attack 中，目标是高 modification rate 和高 model confidence，约束是模型预测标签不变。算法用 stopwords 或语法约束候选替换实义词，并用该非支配退火机制搜索替换优先级。

## 建立理由

- 为什么值得独立维护：
  - 许多离散替换任务有“改得越多越好”和“保持某种约束/性能越高越好”的冲突，固定权重会偏向单一目标。
  - 纯贪心或只接受支配解容易局部最优，模拟退火的概率接受能提供受控探索。
  - 该机制与文本领域解耦，可迁移到反事实生成、离散推荐修改、符号程序修复、组合候选替换和鲁棒样本生成。
- 单篇具体方法的直接复用价值：
  - P2026-0291 给出 Algorithm 1-2、参数调优、六数据集七模型主实验、消融、候选库分析、语法约束变体、LLM 扩展和 retraining/transferability 证据；
  - 消融明确说明 nondominated sorting、composite disturbance、gradient ranking 和 temperature-based acceptance 各有贡献。
- 与已有设计知识的区别：
  - 不同于“因果领域引导的离散反事实搜索”：该知识用因果/domain 矩阵指导变异；本知识解决多目标离散替换的接受和优先级搜索。
  - 不同于“单侧规则-分类器双阶段 Pareto 进化”：该知识是规则/分类器双层进化；本知识是单个离散序列的局部替换退火。
  - 不同于“成功率反馈的算子与参数自适应选择”：该知识调度算子和参数；本知识调度候选替换顺序并用 Pareto rank 接受。
  - 不同于普通 NSGA-II 环境选择：这里非支配排序嵌入模拟退火的单轨搜索过程，而不是维护完整种群演化。

## 解决的问题

- 适用场景：
  - 离散输入由 token、部件、规则、路径节点、特征或符号组成；
  - 需要逐步替换/删除/插入元素；
  - 存在硬约束，如预测标签不变、可行性不破坏、业务规则满足；
  - 至少两个目标冲突，如修改率、置信度、语义距离、查询数、可读性、成本；
  - 每次候选评价有查询/计算成本，不能盲目枚举全空间。
- 现有做法为什么会失败或不足：
  - 固定 weighted sum 需要人为权重，且容易错过不同权衡区域；
  - 静态重要性顺序无法保证 top-k 组合最优；
  - 只做 single perturbation 候选太少，容易被局部邻域限制；
  - 只接受支配当前解的候选会失去跳出局部最优的机会；
  - 候选库越大查询越多，需要重要性采样和小词库/小候选集策略。
- 仍需解决的问题：
  - 多目标数超过 2 时，rank-only acceptance 可能缺少 diversity pressure；
  - 接受概率参数和温度调度仍需任务调优；
  - 查询昂贵任务中候选生成和模型评价仍可能成为瓶颈；
  - 对强约束离散问题，过滤后候选集可能过小。

## 为什么可能有效

```text
conflicting objectives
-> weighted sum biases the search
-> nondominated sorting keeps trade-off information

discrete local search
-> greedy order gets trapped
-> temperature acceptance allows temporary worse ranks

candidate explosion
-> importance sampling focuses likely safe edits
-> composite perturbation expands useful neighborhoods
```

关键假设是：候选 perturbation 后能被快速评价，并且 Pareto rank 足以表示当前候选质量。如果目标噪声大、候选评价不稳定或 rank 大量打平，需要增加 crowding、indicator 或 uncertainty-aware acceptance。

## 实现接口

- 输入：
  - 当前离散解 `x`；
  - 可替换位置集合；
  - 每个位置的候选替换集合；
  - hard constraint checker；
  - objective vector evaluator；
  - position importance estimator；
  - 初始温度、冷却率、内部采样步数、接受概率参数。
- 输出：
  - 最终替换后的离散解；
  - 可选的 Pareto candidate archive；
  - 每步修改记录和查询数。
- 最小流程：

```text
rank positions by ascending importance
T <- T0
while T > Tmin:
    S_t <- sample_positions_by_inverse_importance(radius=delta, step=t)
    C_t <- empty

    for each position i in S_t:
        x1 <- replace_one(x, i, best_candidate(i))
        if constraint_ok(x1):
            C_t <- C_t union {x1}

        for each position j in S_t \ {i}:
            x2 <- replace_one(x1, j, best_candidate(j))
            if constraint_ok(x2):
                C_t <- C_t union {x2}

    fronts <- nondominated_sort(C_t)
    x_new <- choose_candidate(fronts)

    if rank(x_new) < rank(x):
        x <- x_new
    else:
        accept with probability exp(-(rank(x_new)-rank(x)) / (beta*T))

    T <- alpha*T
```

- P2026-0291 默认参数线索：
  - `K=15` internal simulation steps；
  - `T0=1000`；
  - `alpha=0.90`；
  - sampling radius `delta=2`；
  - Metropolis scale `beta=100`；
  - `Tmin = alpha^n * T0`，随输入长度自适应。

## 如何用于算法创新

### 局部创新

- 用 crowding distance 或 hypervolume contribution 修正 rank-only acceptance，鼓励 Pareto front 多样性。
- 把 candidate best replacement 从单目标最大 MC 改成小型 Pareto selection，同时考虑约束余量、语义距离和查询成本。
- 将 importance estimator 从 gradient 换成 deletion score、SHAP、attention rollout、surrogate sensitivity、domain causal score 或历史成功率。
- 将 single/double perturbation 扩展为 variable-size perturbation，并用预算控制最大编辑数。
- 对查询昂贵任务，用 surrogate model 预筛候选，只对 Pareto promising candidates 调用真实模型。
- 将温度和 `beta` 在线调节：若连续若干步无 rank 改善，提高接受概率或扩大候选半径。

### 结构创新

- 通用离散替换优化器：

```text
candidate generator
-> constraint filter
-> objective evaluator
-> nondominated sorter
-> Metropolis acceptor
-> query/budget controller
```

- 反事实解释场景：目标为 outcome change、改动成本小、可行动作保持、自然性高；用非支配退火搜索可行反事实。
- 鲁棒训练样本生成：目标为模型置信度异常、输入扰动大、人工不可读/可读程度可控；输出用于数据增强或安全审计。
- 符号程序/规则修复：目标为测试通过率、改动规模、规则复杂度和业务约束，替换对象为语句、规则或条件。

## 适用条件与风险

- 适用条件：
  - 可离散地生成局部替换候选；
  - 每个候选能计算多个目标并判断硬约束；
  - 评价预算允许每个温度生成一批候选；
  - 需要在多目标间保留 tradeoff，而不是只追求单个标量目标。
- 不适用或可能失效的条件：
  - 候选空间连续且无自然离散替换；
  - 约束极严导致候选几乎全被过滤；
  - 目标评价噪声大，非支配 rank 不稳定；
  - 高目标数下大多数候选互不支配，rank 失去区分力；
  - 攻击型用途若无防御/审计边界，可能带来安全风险。
- 计算与实现成本：
  - 每个温度需要候选生成、模型查询/真实评价和非支配排序；
  - 双扰动使候选数近似随采样集合平方增长，需要限制 `K`、半径和候选库大小；
  - 大候选库显著增加查询量，P2026-0291 中 SW-spaCy 比 SW-10 查询多很多。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0291 | 将 rubbish text attack 转换为预测不变约束下的多目标优化，目标包括文本差异和原标签置信度 | 问题建模 | Sec. III-A，PDF 3-4 |
| P2026-0291 | MOSA-S2 使用 NLTK stopwords 替换 nouns/adjectives/verbs/adverbs，并为每个词选择最大化原标签概率的候选 | 作者提出的方法 | Sec. III-B，PDF 4 |
| P2026-0291 | 使用 gradient-based word importance ranking，优先替换低重要性词 | 作者采用/组合 | Sec. III-C.1，PDF 4 |
| P2026-0291 | 重要性采样半径随时间扩大，并结合 single/double composite perturbation 生成候选 | 作者提出的方法 | Sec. III-C.2，Algorithm 2，PDF 4-5 |
| P2026-0291 | 对候选集使用 NSGA-II fast nondominated sorting，并用 nondomination rank 与温度构造 Metropolis 接受概率 | 作者提出的方法 | Sec. III-C.2，Algorithm 1，PDF 5 |
| P2026-0291 | 六数据集七模型实验中，MOSA-S2 的 MC 平均比 IR 高 `11.39%`、比 AGPS 高 `3%`，且比原输入平均 MC 高 `4.53%` | 综合实验支持 | Sec. IV-D，Table II，PDF 6-7 |
| P2026-0291 | MOSA-S2 的 MR 比 IR 高 `6.54%`、比 AGPS 高 `4.19%`，作者认为其更接近 Pareto tradeoff | 多目标效果 | Sec. IV-D，Table II，PDF 7 |
| P2026-0291 | MOSA-S2 的 PPL 比 IR 高 `29.84%`、比 AGPS 高 `13.05%`，且 SIM 保持优势 | 生成质量 | Sec. IV-D，Table II-III，PDF 7 |
| P2026-0291 | Human evaluation 中 MOSA-S2 在 IMDB/SNLI 上 plausibility 和 grammaticality 最低，符合 human-incomprehensible 目标 | 人评支持 | Sec. IV-E，Table V，PDF 8 |
| P2026-0291 | 去掉 nondominated sorting 后 MC 降 `7.06%`、MR 降 `4.22%` | 消融实验 | Sec. V-A，Table VI，PDF 8-9 |
| P2026-0291 | 去掉 temperature-based probabilistic acceptance 后 MC 降 `3.75%`、MR 降 `3.25%` | 消融实验 | Sec. V-A，Table VI，PDF 9 |
| P2026-0291 | SW-10 小候选库仅需 `960` queries，SW-spaCy 大候选库需 `23875` queries，说明候选库规模直接影响查询成本 | 候选库分析 | Sec. V-E.1，Table VIII，PDF 10 |
| P2026-0291 | Grammatical constraints 在 AG News 上把 queries 从 `13893` 降到 `278`，MC 仍为 `97.36%`，并提高可读性 | 变体证据 | Sec. V-E.2，Table VIII-IX，PDF 10-11 |
| P2026-0291 | LLM 实验显示 Llama-2/Vicuna/GPT-3.5/GPT-4o 均存在 undersensitivity；GPT-4o 相对更稳健 | LLM 扩展 | Sec. VI，Table X，PDF 11-12 |
| P2026-0291 | 参数实验给出 `K=15`、`T0=1000`、`alpha=0.90`、`delta=2`、`beta=100` 等默认值 | 参数证据 | Sec. VII，Table XI-XIV，PDF 12-13 |

## 证据边界

- 当前只有单篇论文证据。
- 核心应用是 text rubbish attack；跨到其他离散替换任务需要重新定义目标、约束和候选生成器。
- 多数精确数值在 Markdown 中为表格图片占位，需回 PDF 复核。
- LLM 实验样本规模较小，且闭源模型置信度/分类设置可能受 prompt 和 API 版本影响。
- Rank-only acceptance 在多目标数较多或非支配关系稀疏时可能不够。
- 攻击生成方法应优先用于安全审计、防御训练和鲁棒性评估。

## 待确认

- 接受概率是否应同时考虑 rank difference 和 crowding/indicator contribution；
- 多目标数大于 2 时，是否需要 epsilon-dominance、R2/HV 指标或 preference-guided ranking；
- 能否用代理模型降低查询成本，尤其在 LLM 或昂贵仿真中；
- 候选库能否在线压缩为少量高价值替换，而不牺牲多样性；
- 防御训练中如何平衡 clean accuracy、adversarial robustness 和 rubbish undersensitivity；
- 在多语言、代码、表格、图结构或组合优化编码上的替换候选如何构造。
