---
knowledge_id: K-comment-aware-length-constrained-summary-selection
name: 评论感知的长度约束摘要多目标句子选择
type: architecture
status: active
source_papers: [P2026-0021]
aliases: [CSMOCS, comment-based summarization MOO, reader-aware extractive summarization, length-aware summary repair, document-comment centroid objectives, multi-objective sentence selection, 评论摘要, 读者感知摘要, 长度约束摘要修复, 多目标句子选择]
promotion_reason: 单篇论文提出但结构接口清晰：把抽取式摘要表示为句子二进制子集，用文档中心、评论中心和句间冗余构造三目标，并将长度约束嵌入 add/remove/exchange mutation 与 repair。该架构可迁移到新闻评论、产品评论、审稿意见、客服反馈和日志事件等“主文档 + 外部关注点”的摘要任务。
---

# 评论感知的长度约束摘要多目标句子选择

## 核心内容

在有源文档和外部读者/用户反馈的摘要任务中，不只按源文档 salience 选句，而是把摘要建模为多目标句子子集选择。一个候选摘要同时评价：对源文档主题的覆盖、对外部评论/反馈关注点的相关性、摘要内部冗余。长度约束不只作为事后过滤，而是在 mutation 与 repair 中直接处理：添加、删除和替换句子时优先选择能改善内容覆盖和评论相关性的句子；超长摘要通过删除低综合相关性的句子恢复可行。

```text
source documents + comments/feedback
-> preprocess and filter noisy comments
-> document centroid + comment centroid
-> binary sentence selection
-> objectives: source coverage, comment relevance, redundancy reduction
-> length-aware add/remove/exchange mutation
-> repair overlong summaries
-> Pareto archive of summaries
```

P2026-0021 的 CSMOCS 实例中，句子和评论用 tf-isf 向量表示；文档 centroid 和评论 centroid 分别作为内容覆盖和评论相关性目标；句间 cosine similarity 用于降低冗余；RA-MDS 摘要长度为 100 words；multi-objective cuckoo search 用 Pareto dominance、rank 和 crowding distance 维护非支配摘要。

## 建立理由

- 为什么值得独立维护：
  - 很多摘要场景同时有主文档和用户反馈，二者的重点不完全一致；
  - 评论/反馈通常噪声大，直接拼接到文档会稀释源文档主题；
  - 摘要长度是强约束，若只靠惩罚函数，搜索会产生大量不可用候选；
  - 该结构把“外部关注点”作为独立目标，便于后续按读者偏好或业务阶段选解。
- 单篇具体方法的直接复用价值：
  - P2026-0021 给出三目标建模、comment filtering、问题定制 mutation/repair、多目标 swarm search、RA-MDS 实验和 18 个方法对比；
  - 实验显示 CSMOCS 在 ROUGE-1/2/L/SU4 上均超过 extractive、compressive 和 abstractive 对比方法。
- 与已有设计知识的区别：
  - 不同于“非支配退火的离散替换优先级搜索”：该知识逐步替换离散 token/符号并用 Metropolis 接受；本知识选择摘要句子子集并显式处理长度约束和评论相关目标。
  - 不同于“可行组合矩阵驱动的稀疏初始化与预评价修复”：该知识处理任务-资源组合的 row-level 可行性；本知识处理文本摘要的全局长度可行性和语义相关性修复。
  - 不同于“CRITIC-TOPSIS 评价反馈引导演化”：该知识是通用决策绩效反馈；本知识的目标和修复都来自 reader-aware summarization 结构。

## 解决的问题

- 适用场景：
  - 新闻/论坛/产品页面/客服记录等同时包含主文档和用户评论；
  - 需要生成 extractive summary，并保持固定或近似固定长度；
  - 评论、反馈或外部关注点与主文档主题相关但有噪声；
  - 希望输出多个 trade-off 摘要，或根据不同用户偏好选择最终摘要；
  - 可接受基于句子子集的优化，而不要求生成全新句子。
- 现有方法为什么会失败或不足：
  - 只看源文档 salience 会忽略评论中读者真正关心的信息；
  - 只看评论会被噪声、跑题或重复观点带偏；
  - 固定加权单目标会掩盖“源文档覆盖 vs 评论关注 vs 冗余”的权衡；
  - 长度违规后简单截断可能删除关键句或保留冗余句。
- 仍需解决的问题：
  - 评论过滤如何处理语义相关但词面不重合的反馈；
  - 句子选择后如何保证连贯性、事实一致性和实体指代完整；
  - 最终 Pareto 摘要如何按用户群体或任务偏好选解；
  - ROUGE 与真实读者满意度之间的偏差。

## 为什么可能有效

```text
source document and comments have overlapping but different focus
-> separate centroids preserve two relevance signals
-> redundancy objective avoids repeating the same salient content
-> length-aware mutation makes local moves feasible and meaningful
-> repair removes low-value sentences instead of arbitrary truncation
-> Pareto archive exposes alternative reader-aware summaries
```

关键假设是：文档和评论 centroid 能表达主要语义焦点，且 cosine similarity 足以评价句子相关性。如果评论噪声大、主题多峰或摘要需要深层推理，简单 centroid 可能失效，需要 embedding、topic model 或 LLM-based relevance 替换。

## 如何用于算法创新

### 局部创新

- 将 tf-isf centroid 替换为 SBERT/LLM embedding centroid、topic centroid 或 query-conditioned representation。
- comment filtering 从高频词匹配升级为 semantic retrieval、clustering、stance filtering 或 spam detection。
- 在 mutation score 中加入句子位置、命名实体覆盖、评论 stance、novelty、factuality 或 readability。
- repair 时使用 sequence-aware score，避免删除承接句、定义句或实体首次出现句。
- 将固定长度约束扩展为多档长度 budget，得到短/中/长摘要 Pareto fronts。

### 结构创新

- “主内容 + 外部关注点”摘要器：

```text
main content encoder
-> feedback/comment encoder
-> multi-objective sentence selector
-> feasibility/length repair
-> preference-based summary chooser
```

- 产品评论摘要中，源文档可替换为商品说明，评论目标表示用户痛点；
- 学术审稿辅助中，源文档可替换为论文，外部关注点为审稿意见或讨论记录；
- 事故/日志摘要中，源文档为事件记录，外部关注点为告警、工单或用户反馈。

## 适用条件与风险

- 适用条件：
  - 可将摘要候选表示为句子子集；
  - 有源文档和外部评论/反馈两类文本；
  - 有明确长度 budget；
  - 能计算句子间和句子-centroid 相似度；
  - 用户愿意接受 extractive summary 或可在其基础上再压缩/改写。
- 不适用或可能失效的条件：
  - 需要高度 abstractive 的概括、推理或跨句融合；
  - 评论严重偏题、攻击性强或与源文档词面无重合；
  - 句子长短差异极大，简单删除修复会破坏信息结构；
  - ROUGE 类 n-gram 指标与任务价值不一致；
  - 多语言或跨语言场景下 stemming、stopword 和 tf-isf 不稳定。
- 计算与实现成本：
  - 需要预处理文档和评论、计算句子/评论向量和相似度；
  - mutation/repair 成本主要来自候选句 scoring；
  - P2026-0021 中每个 RA-MDS topic 平均 241.53 秒，未来可通过并行评价、缓存相似度和更小候选池加速。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0021 | 将 comment-based extractive summarization 表示为二进制句子选择向量，并同时优化 content coverage、comment relevance 和 redundancy reduction | 作者提出的方法 | Sec. 3 |
| P2026-0021 | 文档和评论都用 tf-isf 向量表示，并分别计算 document centroid 与 comment centroid | 建模细节 | Sec. 3 |
| P2026-0021 | 预处理包含 sentence segmentation、tokenization、stopword removal、Porter stemming 和基于文档高频词的 comment filtering | 作者提出/采用的方法 | Sec. 4.1 |
| P2026-0021 | mutation 包含 add/remove/exchange 三类句子操作，并用 content coverage 与 comment relevance 条件或 score 决定候选 | 作者提出的方法 | Sec. 4.2 |
| P2026-0021 | repair 对超过 `L+epsilon` 的摘要反复删除 repair score 最低句子，直到满足长度约束 | 作者提出的方法 | Sec. 4.2 |
| P2026-0021 | CSMOCS 用 Pareto dominance 比较 mutated candidate 与随机 nest，并用 Pareto rank/crowding 对双倍 population 截断 | 作者提出的方法 | Sec. 4.3、Algorithm 1 |
| P2026-0021 | RA-MDS 包含 45 个 collections，每个 10 篇文档、1-10 个评论文档和 4 个专家摘要，长度约束 100 words | 实验设置 | Sec. 5.1、Table 1 |
| P2026-0021 | 参数为 population 64、generations 500、mutation probability `1/n`、comment filtering 5%、31 次独立运行 | 实验设置 | Sec. 5.3 |
| P2026-0021 | CSMOCS 平均 ROUGE-1/2/L/SU4 分别为 0.4785、0.1955、0.4319、0.2188 | 实验结果 | Sec. 5.4、Table 2 |
| P2026-0021 | 相对 18 种方法平均提升 ROUGE-1 25.08%、ROUGE-2 33.21%、ROUGE-L 20.75%、ROUGE-SU4 29.03% | 综合实验支持 | Sec. 5.5、Table 3-4 |
| P2026-0021 | 作者未来工作包括 abstractive/compressive 扩展、更多评价场景和 parallel programming 加速 | 作者未来工作 | Sec. 6 |

## 待确认

- 使用 embedding 或 LLM relevance 后，三目标结构是否仍比端到端摘要模型有优势。
- comment filtering 的最佳比例是否应按集合主题、评论数量和噪声水平自适应。
- Repair 删除句子是否会破坏实体首次出现、时间顺序或篇章连贯性。
- 如何从 Pareto archive 中选择最终展示摘要，是否需要用户偏好、MCDM 或交互式选择。
- ROUGE 提升是否能在人工评价、事实一致性和用户满意度中保持。
