---
knowledge_id: K-sparse-transfer-stacking-many-problem-surrogates
name: 稀疏迁移堆叠的多源代理选择
type: method
status: active
source_papers: [P2026-0220]
aliases: [MOSTS, many-problem surrogates, sparse transfer stacking, sparse source surrogate selection, cost-sensitive EI, censored SVR, negative transfer avoidance, 稀疏迁移堆叠, 多源代理选择, 成本敏感 EI]
promotion_reason: 单篇论文提出，但多源代理稀疏融合、ADMM 求解、成本敏感采样和 censored SVR 成本建模接口完整，可迁移到昂贵多目标优化、历史模型库复用、NAS 和超参数调优
---

# 稀疏迁移堆叠的多源代理选择

## 核心内容

当历史库中存在许多源问题代理模型时，不手动挑选源模型，也不把所有源模型等权或密集 stacking。把源代理和目标代理视为一组专家，用带非负、sum-to-one 约束的稀疏系数做 meta-regression；相关源保留非零权重，无关源被压到 0，从而减少 negative transfer。若真实评价成本差异大，再用成本敏感 acquisition 优先选择“信息收益高且评价便宜”的候选。

```text
历史源代理库 + 少量目标真实样本
-> 源代理和目标代理都对目标样本做预测
-> 稀疏 transfer stacking 求混合系数
-> 无关源权重趋近 0
-> 代理融合预测目标候选 fitness/uncertainty
-> cost-sensitive EI 选择下一真实评价点
```

## 建立理由

- 为什么值得独立维护：
  - many-problem 场景中源模型数量多，负迁移不再是小概率问题，而是默认风险。
  - 稀疏系数同时承担模型融合和源选择功能，比手动挑源更稳定、比 dense stacking 更抗噪。
  - 成本敏感采样把 FE 数量和实际计算时间区分开，适合 NAS、超参数调优和仿真时间差异大的工程问题。
- 与已有设计知识的区别：
  - 不同于“数据流动态优化的代理超参数迁移”，这里迁移的是历史源代理的预测能力，而不是相邻时间步代理超参数。
  - 不同于普通代理采样卡片，这里重点是 many-source surrogate selection 和 negative transfer avoidance。
  - 不同于 NAS 在线分类器卡片，这里不训练好坏分类器，而是对多个历史代理做稀疏融合。

## 解决的问题

- 适用场景：
  - 历史上已解决多个相关昂贵优化问题，并保存了代理模型；
  - 当前目标问题真实评价预算少；
  - 源问题与目标问题相关性未知；
  - 评价成本在候选之间差异明显；
  - 希望源模型选择可解释、可在线更新。
- 现有方法为什么会失败或不足：
  - 从零训练目标代理样本少、收敛慢；
  - dense transfer stacking 会让无关源参与预测，导致 negative transfer；
  - 手动挑选源模型缺少统一标准；
  - 只按 EI/不确定性选点可能偏向高收益但极慢的候选，实际时间成本过高。

## 为什么可能有效

```text
少数源问题与目标问题真正相关
-> 目标样本上的预测误差能反映源相关性
-> 稀疏 meta-regression 自动分配少量非零系数
-> 低相关源被剔除
-> 融合代理更接近目标景观
-> cost-sensitive EI 避免把预算耗在过慢候选上
```

关键假设是：历史源代理在目标训练样本上的预测表现能揭示源-目标相关性，且真实评价成本可以被可靠预测或至少近似排序。

## 实现接口

- 输入：
  - 历史源代理模型集合；
  - 当前目标问题少量真实评价样本；
  - 多目标到标量的 aggregation 方式；
  - 目标代理模型；
  - 候选评价成本记录或 cost surrogate。
- 代理融合：
  - 源代理对目标样本做预测；
  - 目标代理用 leave-one-out 方式对目标样本做预测；
  - 解非负、sum-to-one、稀疏约束下的 meta-regression；
  - 用混合系数得到融合预测均值和方差。
- 稀疏求解：
  - 用 `l1` 近似 `l0`；
  - 可用 ADMM 拆分二次项、稀疏项和约束；
  - 每次新增真实评价后重新估计系数。
- 真实评价点选择：
  - 用融合代理估计 fitness 和 uncertainty；
  - 用 SVR 或其他成本模型估计 `c(x)`；
  - 选择 cost-sensitive EI 最大的候选；
  - 真实评价后同时更新目标训练集和成本训练集。
- censored cost：
  - 对超过 cutoff 的样本，记录为成本大于 `kappa`；
  - 用 censored regression 保留 lower-bound 信息，而不是丢弃样本。

## 如何用于算法创新

### 局部创新

- 用 group lasso 让同一问题族、同一保真度或同一数据子集的源模型成组选择。
- 用动态正则强度：早期更依赖源代理，后期随目标样本增加提高目标代理权重。
- 将 cost-sensitive EI 扩展为多资源 acquisition，同时考虑时间、能耗、费用和失败风险。
- 用不确定性校准或 conformal prediction 修正源代理在目标域上的过度自信。

### 结构创新

- 构建历史问题代理库：

```text
问题元数据 -> 源代理模型 -> 目标样本预测矩阵
-> 稀疏系数学习 -> 相关源解释
-> 融合代理 -> 成本敏感真实评价
```

- 把稀疏系数作为源问题相似性记录，长期维护“哪些源常被选中”的可解释知识图谱。
- 将 many-problem surrogate 与多任务贝叶斯优化、NAS benchmark 或工业仿真平台结合。

## 适用条件与风险

- 适用条件：
  - 源代理能在目标决策变量上产生预测，或可通过映射对齐；
  - 目标问题有少量真实样本用于估计源相关性；
  - 源模型之间存在稀疏相关结构；
  - 评价成本可观测并能被近似预测。
- 不适用或可能失效的条件：
  - 源和目标决策空间/特征空间不可对齐；
  - 没有任何相关源，稀疏 stacking 仍可能受噪声误导；
  - 目标样本太少，源相关性估计不稳定；
  - 评价成本与决策变量关系弱，cost surrogate 排序不可靠；
  - 过强稀疏正则误删弱相关但互补的源模型。
- 计算与实现成本：
  - 需要存储和调用多个源代理；
  - 每轮更新混合系数；
  - 若源模型数量很大，预测矩阵和 ADMM 求解仍有开销；
  - 需要额外维护成本数据和成本代理。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0220 | MOSTS 面向 many-problem surrogate，使用 sparse transfer stacking 自动选择相关源模型以避免 negative transfer | 作者提出的方法 | Sec. I、III-A-B，PDF 2-6 |
| P2026-0220 | 混合系数满足非负与 sum-to-one 约束，并用 `l1` 近似 `l0` 稀疏约束，ADMM 求解 | 作者提出的方法 | Sec. III-B、Algorithm 3，PDF 5-6 |
| P2026-0220 | cost-sensitive EI 同时考虑 predicted fitness、uncertainty 和 evaluation cost，并用改进 SVR 预测成本 | 作者提出的方法 | Sec. III-C，PDF 6-7 |
| P2026-0220 | DTLZ 系数可视化显示 sparse transfer stacking 能把低相似源模型权重压到 0 | 机制证据 | Sec. IV-A2、Fig. 1，PDF 8 |
| P2026-0220 | DTLZ2/5/6 上 MOSTS 在 100/200/300/1000 FEs 均取得最好 IGD | 综合实验支持 | Sec. IV-A3、Table II，PDF 8-10 |
| P2026-0220 | Object detection 超参数调优中，MOSTS 在 YOLOv5/Faster R-CNN 多数据集上取得最好或接近最好 HV | 应用实验支持 | Sec. IV-B1、Table IV，PDF 10-12 |
| P2026-0220 | NAS 中 MOSTS 在 FE=300/1000 时三个问题 HV 均优于其他方法，并在按计算时间绘图时收敛最好 | 应用实验支持 | Sec. IV-B2、Table V、Fig. 5，PDF 12-13 |
| P2026-0220 | 作者未来方向是处理源和目标优化问题拥有不同类型代理模型的情形 | 作者局限 | Sec. V，PDF 13 |

## 证据边界

- 当前只有单篇论文证据。
- 源代理预训练成本不计入目标问题优化成本。
- 当前主要验证同构或可直接调用的源代理，异构源/目标代理仍是未来方向。
- 多目标训练标签来自 aggregation，尚未验证直接多输出 sparse stacking 是否更优。
- cost-sensitive 部分主要以计算时间为成本，其他资源成本需要单独建模。

## 待确认

- 源模型数量极大时，预测矩阵构造和 ADMM 更新是否仍足够快；
- 正则参数如何自适应设置，避免过稀疏或过密；
- 没有相关源时能否自动退化为目标代理主导；
- 异构决策空间、异构代理类型和不同目标数之间如何迁移；
- cost surrogate 不准时是否会破坏 Pareto 搜索质量。
