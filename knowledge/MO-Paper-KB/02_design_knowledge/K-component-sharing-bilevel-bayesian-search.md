---
knowledge_id: K-component-sharing-bilevel-bayesian-search
name: 共享变量上层搜索的贝叶斯双层采样
type: method
status: active
source_papers: [P2026-0242]
aliases: [BBS, CSLCB, component-sharing MOO, regular front optimization, shared-variable bilevel acquisition, Bayesian bi-level search, component-sharing LCB, 共享组件偏好, 共享变量双层采样, regular front]
promotion_reason: 单篇论文提出但建模对象、上层共享变量搜索、下层 RF 近似、GP 代理、CSLCB acquisition、batch 真实评价和评价指标完整，可直接迁移到昂贵模块化设计、产品族设计和共享组件多目标优化
---

# 共享变量上层搜索的贝叶斯双层采样

## 核心内容

当决策者希望最终输出的一组 Pareto tradeoff 方案共享某些指定组件时，把这些组件对应的变量设为共享变量 `s`，其余为非共享变量 `x`。固定 `s` 后，求解 `min_x F(x,s)` 得到 regular front (RF)；上层目标是在共享变量空间中寻找使 RF 的质量指标最大化的 `s`。若 `F(x,s)` 昂贵，用一个全局数据集训练目标 GP，并用 component-sharing LCB (CSLCB) 估计每个候选 `s` 的 optimistic RF-HV，再选择少量 `(x,s)` 做真实评价。

```text
指定共享变量 s 和非共享变量 x
-> 固定 s 后 lower-level MOP 产生 RF(s)
-> upper-level objective: maximize HV(RF(s))
-> 全部真实评价 D={(x,s),F(x,s)} 训练多目标 GP
-> CSLCB: 用 mu-beta*sigma 构造 optimistic RF(s)
-> NestedEBS/BO 搜索最有希望的 s
-> 从该 s 的 lower-level candidates 中 batch 选择真实评价点
-> 返回同一 s 下的 nondominated solutions
```

## 建立理由

- 为什么值得独立维护：
  - 共享组件偏好不是单个解的约束，而是整个最终解集之间的跨解一致性约束。
  - 普通 Pareto optimality 可能与共享组件偏好冲突，直接优化 PF 可能找不到最优共享解集。
  - BBS/CSLCB 给出完整可迁移接口：共享变量上层、非共享变量下层、RF 质量指标、代理模型、采样函数和专用评价指标。
- 单篇具体方法的直接复用价值：
  - P2026-0242 给出 component-sharing MOO 双层公式、BBS Algorithm 1、CSLCB Algorithm 2、六个 benchmark、BWBUG CFD 真实应用和参数敏感性。
  - 方法针对昂贵评价，适合材料/结构/空气水动力/产品族设计中“共用部件 + 多性能折中”的实际问题。
- 与已有设计知识的区别：
  - 不同于“POMIS 约束的元获取策略学习”：该知识约束因果干预集并学习 acquisition policy；本知识约束最终解集共享指定变量，并用 RF-level acquisition 搜索共享变量。
  - 不同于普通 surrogate-assisted MOO：本知识的采样单位不是单个 Pareto 点，而是某个共享变量对应的一整条 lower-level RF。
  - 不同于 preference-conditioned Pareto set learning：本知识处理跨多个最终解的组件一致性，不是给单个偏好向量快速输出一个折中解。

## 解决的问题

- 适用场景：
  - 产品族、模块化设计或平台化设计需要多个方案共享某些组件；
  - 共享组件会影响多个性能目标，不能只用成本后处理；
  - 决策者已明确哪些变量应共享；
  - 单次真实评价昂贵，需要有限 FE 下同时确定共享变量和对应 RF。
- 现有方法为什么会失败或不足：
  - 经典 MOO 追求 PF，可能输出共享变量差异很大的解集；
  - 后处理从 PF 中找共享变量，在 optimal RF 与 PF 不重合时无效；
  - 对每个候选共享变量独立运行 MOBO 会重复浪费样本；
  - 只训练生成共享解的模型缺少“哪个共享变量最优”的明确定义。
- 仍需解决的问题：
  - 高维 `s` 和 `x` 下 GP 与嵌套 acquisition 优化都可能失效；
  - 近似共享、离散共享和制造成本模型尚需扩展；
  - 多个共享变量候选 RF 的不确定性如何更准确比较。

## 为什么可能有效

```text
共享偏好作用于最终解集
-> 固定共享变量后才能定义一组可制造的 tradeoff 解
-> RF-HV 把该共享变量下的整体性能压成上层质量
-> 统一 GP 利用所有 (x,s) 历史评价
-> LCB optimism 同时考虑均值和不确定性
-> acquisition 把预算分给可能产生高质量 RF 的共享变量
```

关键假设是：共享变量事先可识别，且同一全局 surrogate 能从不同 `s` 的评价中学习到对新 `s` 有用的信息。如果不同共享变量区域之间几乎无统计相关，统一 GP 的样本复用价值会下降。

## 如何用于算法创新

### 局部创新

- 把 RF 质量指标从 HV 换成 R2、IGD、偏好加权 HV、robust HV 或制造成本惩罚 HV。
- 将 CSLCB 的 `mu-beta*sigma` 换成 Thompson sampling、EHVI、entropy search 或 risk-aware lower confidence bound。
- 将 `gamma` 阈值设为预算自适应：早期低阈值探索共享变量，后期高阈值集中逼近当前 RF。
- 对 lower-level candidate selection 加入 diversity、uncertainty、cost 或 shared-variable neighborhood coverage。
- 在 shared variable 分组中使用容差，把“完全相同组件”扩展为“制造上可共用的近似组件”。

### 结构创新

- 设计多任务 RF 学习框架：多个候选 `s` 的 lower-level MOP 同时共享代理、档案和 acquisition 信息。
- 构建产品族优化闭环：

```text
DM 指定可共享部件
-> BBS 找候选共享变量与 RF
-> 成本/制造模型评价共享收益
-> CFD/仿真真实评价更新代理
-> 输出一组同组件多性能设计
```

- 与 Pareto set learning 结合：用神经网络表示固定 `s` 下的 RF，再由 CSLCB/BO 在 `s` 空间选择训练重点。
- 与多保真仿真结合：低保真模型快速筛选共享变量，高保真预算用于验证 promising RF。

## 适用条件与风险

- 适用条件：
  - 共享变量的语义明确，且最终解集需要完全或近似共享这些变量；
  - 每次真实评价昂贵，样本复用有价值；
  - lower-level RF 可以由有限权重向量或生成模型近似；
  - 有合适参考点或质量指标评价 RF。
- 不适用或可能失效的条件：
  - 决策者并不知道哪些变量应共享，需要先发现 regularity；
  - 共享偏好只影响成本且不影响性能，简单成本模型可能足够；
  - 目标维度或变量维度过高，GP 和 HV 计算成本过大；
  - 目标函数强多峰、强不连续，GP optimistic RF 误导采样；
  - 多个不同共享变量在制造上都可接受但数值不完全相同，硬分组可能过严。
- 计算与实现成本：
  - 每轮需要训练 `m` 个目标 GP；
  - CSLCB 优化本身是嵌套问题，需要 MOEA/D-DE 反复近似 lower-level RF；
  - HV-based batch selection 和 RF 评价在高目标数下成本增加；
  - 真实评价预算低时，`beta/gamma` 对探索-开发平衡较敏感。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0242 | 将 component-sharing MOO 定义为上层最大化固定共享变量下 RF 的 HV、下层求 `min_x F(x,s)` 的特殊双层 MOP | 作者提出的方法 | Sec. II-A、Eq. (1)，PDF 3 |
| P2026-0242 | 指出 RegEMO 先找 PF 再分析固定变量，而本文假设共享变量是 DM prior preference，不必先找原始 PF | 作者观点/差异 | Sec. II-B.1，PDF 3 |
| P2026-0242 | BBS 用全部观测数据为每个目标训练 GP，避免 nested 方法对每个共享变量独立求解 lower-level MOP 的昂贵浪费 | 作者提出的方法 | Sec. III-A、Fig. 4，PDF 5 |
| P2026-0242 | CSLCB 用 `mu-beta*sigma` 构造 optimistic objective，并以 fixed `s` 下 optimistic RF 的 HV 作为 bi-level acquisition | 作者提出的方法 | Sec. III-B、Eq. (5)，PDF 5 |
| P2026-0242 | Algorithm 1 给出 BBS：LHS 初始化、GP 拟合、CSLCB 优化、batch 真实评价、更新最佳共享变量并返回同一 `s*` 下的非支配解 | 作者提出的方法 | Sec. III-C、Algorithm 1，PDF 6 |
| P2026-0242 | Algorithm 2 用 NestedEBS + GP/EI 优化 CSLCB，并用 `gamma` 阈值避免小幅过探索 | 作者提出的方法 | Sec. III-C、Algorithm 2，PDF 6 |
| P2026-0242 | 提出 component-sharing HV、HV difference 和 accuracy 三个指标，用于评价共享 RF 质量与共享变量定位误差 | 评价方法 | Sec. IV-B，PDF 7-8 |
| P2026-0242 | NestedEBS 在便宜目标 benchmark 上相对 mRegEMO、EPSL、RRA 整体更能定位 optimal shared variables 和 optimal RF | 实验支持 | Sec. V-B、Table II、Fig. 6，PDF 8-9 |
| P2026-0242 | BBS 在昂贵 benchmark 上相对 RegMOBO、RegSAEA、BPSL、BBS-RRA 在 component-sharing accuracy 和 HV difference 上显著更优或相当 | 综合实验支持 | Sec. V-C、Tables III-IV、Fig. 7，PDF 9-11 |
| P2026-0242 | BWBUG CFD 应用中 BBS 的 component-sharing HV 为 `212.6033`，高于 RegMOBO 的 `168.8330`，并找到 39 个满足共享偏好的设计 | 真实应用支持 | Sec. V-D、Figs. 8-10，PDF 11-13 |
| P2026-0242 | 作者指出 BBS 受维度灾难、GP 复杂目标拟合和 NestedEBS 搜索效率限制 | 作者局限 | Sec. VI，PDF 13 |

## 待确认

- 如何将完全共享变量扩展为近似共享、离散共享或结构共享；
- RF-level acquisition 在三目标以上或 many-objective 中如何降低 HV 成本；
- 高维 `s/x` 下是否应使用 trust-region、additive GP、latent representation 或 neural surrogate；
- 如何在多个可接受共享组件方案之间引入制造成本、鲁棒性和 DM 偏好；
- NestedEBS 与 multitask MOBO、multi-fidelity BO 或 Pareto set learning 结合后能否显著降低 acquisition 优化成本。
