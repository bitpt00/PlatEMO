---
knowledge_id: K-trainability-constrained-online-classifier-nas
name: 可训练性约束的在线分类器辅助 NAS
type: method
status: active
source_papers: [P2026-0218]
aliases: [CMFNAS, trainability-constrained NAS, classifier-assisted multiobjective NAS, NTK condition constraint, online ESVM environmental selection, 可训练性约束NAS, 分类器辅助NAS]
promotion_reason: 单篇论文提出但实现接口明确，包含低成本可训练性约束、动态好坏标签、代内分类器可靠性检查和候选准入门控，可直接改造 NAS、程序结构搜索或昂贵结构候选筛选
---

# 可训练性约束的在线分类器辅助 NAS

## 核心内容

在昂贵的神经架构搜索中，不把所有候选都训练，也不完全依赖少样本回归预测器。先用一个低成本 trainability proxy 作为硬约束筛掉明显难训练的架构；再从当前多目标种群中按质量指标自动构造 good/poor 标签，训练在线分类器；只有当分类器可靠时，才把分类预测叠加到候选准入规则中。

```text
当前种群 P
-> 计算目标值和 trainability eta
-> 用 I_SDE+ 给 P 排序并标 good/poor
-> 训练/评估在线分类器, 得到 AUC
-> 更新当前 trainability 阈值 eta_t
-> 生成候选架构
-> 若 AUC < beta: 只要求 eta <= eta_t
-> 若 AUC >= beta: 要求 eta <= eta_t 且 classifier 预测 good
-> 真实评价通过门控的候选并更新种群
```

## 建立理由

- 为什么值得独立维护：
  - 架构搜索常同时受昂贵评价、少样本预测偏差和低可训练结构浪费预算困扰；
  - 该知识把“能否训练好”和“相对是否优质”分成两个独立门控，接口清晰，容易插入现有 ENAS/MOEA 框架。
- 单篇具体方法的直接复用价值：
  - P2026-0218 给出 NTK condition number 约束、`I_SDE+` 标签构造、cost-sensitive ESVM、AUC 可靠性判断和环境选择门控的完整流程；
  - 作者在四个缺陷数据集上报告准确率，并在正文结论中说明约束、搜索空间、分类器和种群设置消融均支持方法有效。
- 与已有设计知识的区别：
  - 不同于“网格排序成对关系代理筛选”：本知识不是 pairwise relation surrogate 或真实评价预算分配，而是 NAS 候选准入门控，并显式加入 trainability hard constraint。
  - 不同于“结构保真的架构编码与修复”：本知识不保护 backbone 路径，也不做拓扑修复；它筛除低可训练或分类器判为低质量的候选。
  - 不同于“滤波性能预测的特征子集预筛选”：本知识处理架构/结构候选，可训练性 proxy 是候选自身的优化稳定性，而不是 filter 指标预测 wrapper 评价。

## 解决的问题

- 适用场景：
  - 候选解是神经架构、程序结构、算法配置或其他昂贵结构对象；
  - 真实评价需要训练、仿真或长时间执行；
  - 存在可低成本估计的 trainability、stability、feasibility 或 executability proxy；
  - 回归式性能代理在少样本下偏差大，但相对好/坏分类可能更稳定；
  - 多目标选择中需要同时保留收敛和多样性。
- 现有方法为什么会失败或不足：
  - 全量训练所有候选会把大量预算浪费在明显难训练结构上；
  - 只用 Pareto dominance 给分类器打标签，后期大量个体互不支配，标签区分度不足；
  - 回归代理必须预测绝对性能，少样本、噪声训练和高维结构编码下容易失真；
  - 分类器不可靠时继续硬筛会把搜索方向带偏。
- 仍需解决的问题：
  - trainability proxy 与最终性能不一致时如何保留探索机会；
  - 分类器可靠性阈值、标签比例和约束收紧速度如何自适应；
  - 高维图结构或动态拓扑中如何编码候选以训练稳定分类器。

## 为什么可能有效

```text
低可训练架构通常训练曲线不稳定且性能差
-> 用 trainability proxy 先过滤, 减少无效真实评价
-> 多目标种群中的好坏关系随代变化
-> 每代在线重建标签, 让分类器跟随当前搜索阶段
-> I_SDE+ 同时考虑收敛和多样性, 比单纯 dominance 更有区分度
-> AUC 低时关闭分类器门控, 避免不可靠学习器误导搜索
```

关键假设是：存在一个与候选最终可用性正相关、且比真实评价便宜很多的 trainability proxy；如果该 proxy 对任务不敏感或与最终性能负相关，硬约束会错误删除潜在优质结构。

## 如何用于算法创新

### 局部创新

- 在现有 NSGA-Net、MOEA/D-NAS、regularized evolution 或任意 ENAS 中加入 trainability gate，只训练通过 `eta <= eta_t` 的候选。
- 将分类器从 ESVM 替换为随机森林、图神经网络、pairwise classifier 或 uncertainty-aware model，但保留 AUC/校准误差等可靠性开关。
- 把 `I_SDE+` 标签替换为 hypervolume contribution、reference-vector contribution、rank + crowding 或任务特定质量指标。
- 对被拒绝候选设置小比例抽查预算，监控 proxy 偏差并更新约束阈值。

### 结构创新

- 构建三层候选筛选框架：

```text
结构生成层
-> 低成本可训练性/可执行性约束层
-> 在线分类器相对质量判断层
-> 真实评价与多目标环境选择层
```

- 在结构搜索中区分“形式合法”“可训练/可执行”“值得真实评价”三个层次，避免把可行性修复、代理预测和环境选择混成单一评分。
- 用同一框架处理非神经网络结构，例如控制器拓扑、调度规则组合、仿真流程或启发式算法配置，其中 trainability proxy 可替换为稳定性、运行失败率或早期收敛指标。

## 适用条件与风险

- 适用条件：
  - 能为每个候选快速计算 trainability/stability proxy；
  - 当前种群已有真实目标值，可构造在线 good/poor 标签；
  - 候选编码对分类器可学习，且每代样本量足以做基本可靠性评估；
  - 真实评价成本明显高于 proxy 和分类器训练成本。
- 不适用或可能失效的条件：
  - 最终高性能候选早期看起来低可训练，proxy 会造成过早删除；
  - 任务目标高度噪声，`I_SDE+` 标签频繁翻转，分类器边界不稳定；
  - 搜索空间很小或真实评价便宜，门控成本可能超过收益；
  - 可训练性本身受 optimizer、训练轮数和数据增强强烈影响，单一 proxy 难以泛化。
- 计算与实现成本：
  - 每个候选需要计算 proxy，P2026-0218 中 NTK condition number 单架构低于 1 秒；
  - 每代需要构造标签、训练 ESVM、计算 AUC；
  - 需要维护分类器可靠性阈值、约束收紧参数和标签比例。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0218 | 将 FNN 架构搜索建模为 constrained multiobjective optimization，目标为 `#Params` 和 accuracy，约束为 trainability `eta` | 作者提出的方法 | Sec. III-B，PDF 4-5 |
| P2026-0218 | 用 NTK condition number 分析 trainability，`eta` 越小越好，作者称单个架构计算该指标低于 1 秒 | 机制依据 | Sec. III-B，PDF 4-5 |
| P2026-0218 | 构建 CM/FM/PM/FCM 搜索空间，并用 macro/micro 两级表示表达模块序列和变长超参数 | 作者提出的方法 | Sec. III-C，Fig. 3，PDF 5-6 |
| P2026-0218 | 用 `I_SDE+` 对当前种群排序，前 `tau` 个标为 good，其余标为 poor，并按 7:3 划分训练/评估数据 | 标签构造 | Sec. III-E，Fig. 4，PDF 6-7 |
| P2026-0218 | 用 ESVM 和 cost-sensitive loss 缓解 good/poor 样本不平衡，并用 AUC 判断分类器可靠性 | 分类器管理 | Sec. III-E，PDF 7 |
| P2026-0218 | 环境选择中，`AUC < beta` 时只用 `eta <= eta_t`；`AUC >= beta` 时还要求分类器预测不低于 0.5 | 候选准入规则 | Sec. III-G，Fig. 7，PDF 8 |
| P2026-0218 | 摘要报告 CMFNAS 在 ELPV、CODEBRIM、MIXEDWM38、WM-811K 上 accuracy 分别为 `94.77%`、`81.82%`、`98.99%`、`98.22%` | 综合实验支持 | Abstract，PDF 1 |
| P2026-0218 | ELPV 上 CMFNAS-C (Best) 相比 Light CNN 在 accuracy、precision、recall、F1 上分别提升 `1.15%`、`0.84%`、`0.45%`、`0.0071` | 对比实验支持 | Sec. V-A，Table II，PDF 9 |
| P2026-0218 | CMFNAS-C (Best) dominates HFCNN6/HFCNN10，CMFNAS-B (Best) dominates PV-Darts，作者称 search cost 优于 PV-Darts 且较 DR-FNAS 提升效率和准确率 | 对比实验支持 | Sec. V-A，PDF 9 |
| P2026-0218 | 消融覆盖 constrained multiobjective framework、module-based search space、classifier 和 population setting；正文结论称约束能减少开销并提升准确率，classifier management 很关键 | 消融支持 | Sec. V-B / Sec. VI，PDF 9-10 |
| P2026-0218 | 作者指出当前线性模块组合、简单 FM 和低效 constraint handling 是局限，未来将研究图拓扑、高级 fuzzy theory 和 boundary/repair constraint handling | 边界与未来工作 | Sec. VI，PDF 10 |

## 待确认

- 补充材料中的完整实验设置、四个数据集详细表格和消融数值需要后续补读。
- NTK condition number 在非 FNN、图拓扑 NAS、长训练 schedule 和大数据集上的相关性仍需验证。
- 硬门控与探索多样性之间是否需要随机抽查或不确定性保留机制。
