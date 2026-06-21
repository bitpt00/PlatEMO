---
knowledge_id: K-samoea-problem-component-scenario-design-matrix
name: SAMOEA 问题属性-组件-场景设计矩阵
type: architecture
status: active
source_papers: [P2026-0202]
aliases: [SAMOEA taxonomy, surrogate-assisted EMO design matrix, expensive MOO taxonomy, surrogate model management, infill criteria taxonomy, LLM-assisted SAMOEA, privacy-preserving SAMOEA, 代理辅助多目标综述, 昂贵多目标优化设计矩阵, SAMOEA选型框架]
promotion_reason: 综述论文提出并系统整理的设计框架，覆盖问题属性、评价指标、代理模型管理、infill 准则、加速机制、特殊场景、应用域和未来方向，可作为后续 SAMOEA 论文查重、归类、选型和组合创新的总览索引。
---

# SAMOEA 问题属性-组件-场景设计矩阵

## 核心内容

设计 surrogate-assisted MOEA 时，先不要直接选 GP、RBF 或某个 infill。应先识别昂贵多目标问题的属性：目标是否 coupled/decoupled，目标数是否 many-objective，PF 是否 irregular，变量是 continuous/discrete/mixed，是否 high-dimensional，是否 constrained/dynamic，是否 data-driven 或有 domain knowledge。然后再选择 surrogate type、infill criteria、acceleration mechanisms 和 special-scenario modules。

```text
expensive MOO problem
-> problem attributes:
      objective structure, variables, constraints/dynamics, data/knowledge
-> surrogate management:
      regression, classification, relation, hybrid
-> infill criteria:
      EI/PI/UCB/EHVI, class probability, boundary, ranking uncertainty
-> acceleration:
      decomposition, multi-population, PS/PF learning, KT, specialized operators
-> scenario modules:
      multimodal, heterogeneous, transfer, preference, RL, decomposition, inverse
-> evaluation:
      solution quality + model quality + computation efficiency
```

P2026-0202 是一篇约 300 篇文献的 SAMOEA survey，这张卡把其综述框架转化为可执行的算法设计和知识库归类矩阵。

## 建立理由

- 为什么值得独立维护：
  - 知识库已有多个具体 surrogate-assisted 方法，但缺少一张上层设计地图来说明这些方法的适用边界。
  - SAMOEA 的成败常由 problem attribute、surrogate type、infill 和真实评价预算共同决定，单看算法名称容易误判。
  - 该综述把 problem taxonomy、core components、special scenarios、applications 和 future directions 放在一个框架中，可作为后续查重基准。
- 单篇具体方法的直接复用价值：
  - P2026-0202 明确给出 SAMOEA 基础流程、评价指标三分法、问题属性分类、模型管理分类、infill 分类和特殊场景列表。
  - 综述覆盖近年 emerging scenarios：LLM-assisted、privacy-preserving、RL-based、inverse modeling、heterogeneous objectives。
  - 对设计新 SAMOEA 时如何组合模块有直接指导价值。
- 与已有设计知识的区别：
  - 不同于“自适应代理内环加速器”：该知识是一个具体加速模块；本知识是上层选型和归类矩阵。
  - 不同于“目标级自适应代理与双空间 infill 采样”：该知识处理目标级 surrogate 选择和双空间真实评价；本知识覆盖所有 surrogate family 与 infill 类别。
  - 不同于“共享汉明核 MOKRR 子问题协同”：该知识面向二进制昂贵 MOO；本知识用于判断何时需要离散/关系/分类代理或 decomposition。
  - 不同于普通 survey 摘要：本知识把综述内容转写成可用的设计步骤和证据边界。

## 解决的问题

- 适用场景：
  - 新建或改造 surrogate-assisted MOEA；
  - 为昂贵 MOO 选择 surrogate model 和 infill；
  - 需要判断已有 SAMOEA 卡是否重复或互补；
  - 需要为具体应用解释为什么选某类代理；
  - 需要制定 benchmark 和评价指标。
- 现有做法为什么会失败或不足：
  - 只选 GP/EHVI 可能在 high-dimensional、mixed-variable 或 many-objective 中不可扩展。
  - 只看 objective call 会忽略 surrogate 训练和 infill 计算开销。
  - 只看 RMSE 会忽略 ranking consistency 和最终优化效用。
  - 只在全局建模会错过 multimodal、heterogeneous、irregular PF 或 ROI 场景的局部需求。
  - 静态代理配置难适应 dynamic、noisy、privacy-sensitive 或 distributed settings。
- 仍需解决的问题：
  - 该矩阵给的是设计分类，不是自动算法选择器；
  - 不同模块组合之间缺少统一理论保证；
  - LLM、privacy-preserving 和 theoretical SAMOEA 仍是早期方向；
  - 综述中的模型对比表为高层总结，具体应用还需实验验证。

## 为什么可能有效

```text
SAMOEA failure often comes from mismatch
problem attribute != surrogate assumption
surrogate output != infill criterion
infill cost > saved real evaluations
scenario module missing

taxonomy forces explicit matching
-> fewer blind algorithm choices
-> clearer ablation and comparison
-> easier reuse of existing knowledge cards
```

关键假设是：问题属性可以在算法设计前被较准确地识别。如果真实应用的昂贵性、噪声、约束和动态性未被充分刻画，矩阵选型仍可能失效。

## 实现接口

- 输入：
  - objective evaluation cost 和可用 FE budget；
  - objective coupling、objective count、PF shape 先验；
  - variable type、dimension、search-space scale；
  - constraint、dynamic、noise、data availability；
  - 是否有历史任务、low-fidelity data、expert knowledge、privacy requirement；
  - 实时性、parallel resources 和应用风险。
- 输出：
  - 推荐的 surrogate family；
  - 推荐的 infill type；
  - 是否需要 decomposition、local modeling、transfer learning、RL control、inverse modeling、privacy module；
  - evaluation protocol。
- 插入位置：
  - SAMOEA 论文查重时的 mechanism classifier；
  - 算法设计初期的模块选型表；
  - 实验设计中的指标选择；
  - 知识库中具体 surrogate 卡的上层索引。
- 最小使用流程：

```text
1. Mark problem attributes:
   objectives: coupled / decoupled / many / irregular
   variables: continuous / discrete / mixed / high-dimensional
   setting: constrained / dynamic / data-driven / knowledge-rich

2. Choose surrogate output type:
   exact objective prediction -> regression
   promising/non-promising -> classification
   dominance/ranking/preference -> relation
   mixed needs -> hybrid or ensemble

3. Choose infill:
   uncertainty-aware regression -> EI/PI/UCB/LCB/EHVI
   classifier -> class probability / boundary / sparse-region query
   relation surrogate -> ranking uncertainty / dominance violation

4. Add scenario module:
   multimodal -> local/ensemble models + decision diversity
   heterogeneous -> objective-wise models + budget scheduling
   transfer -> source relevance and negative-transfer guard
   preference -> ROI model and preference update
   RL -> state/reward/action controller for model or infill management
   inverse -> objective-to-decision generator + forward validation

5. Evaluate:
   solution quality + model quality + wall-clock/data efficiency
```

## 如何用于算法创新

### 局部创新

- 把具体 SAMOEA 卡补充一个 `problem attribute fit` 段落，说明适合 coupled/decoupled、continuous/mixed、static/dynamic 中哪类问题。
- 为每个 surrogate-assisted 算法记录模型输出类型：regression、classification、relation 或 hybrid。
- 在实验中同时报告 model ranking consistency、Objective Call 和 wall-clock，而不只报告 HV/IGD。
- 对 many-objective expensive problems，优先考虑 relation/classification surrogate 和 decomposition，而不是直接用全局 GP。
- 对 privacy-sensitive 应用，在 surrogate 训练和真实评价日志中加入 federated 或 differential privacy 约束。

### 结构创新

- SAMOEA 设计向导：

```text
problem profiler
-> surrogate family selector
-> infill selector
-> acceleration module selector
-> scenario-specific safeguards
-> evaluation dashboard
```

- 构建 meta-SAMOEA：让 bandit/RL/LLM 根据该矩阵动态选择 surrogate family、infill 和真实评价分配。
- 建立 knowledge-card recommender：根据新论文的 problem attributes 自动推荐可能重复或可互补的已有设计知识。
- 设计 privacy-aware distributed SAMOEA：federated local surrogates、DP noise、elite migration 和 secure aggregation 共同工作。
- 设计 LLM-assisted SAMOEA 的安全闭环：LLM 负责语义初始化、算子建议和合成数据，surrogate 与真实评价负责校验。

## 适用条件与风险

- 适用条件：
  - 任务确实是 expensive MOO 或 expensive many-objective optimization；
  - 可明确区分真实评价成本和 surrogate 管理开销；
  - 需要在多个 surrogate/infill/accelerator 方案中做选择；
  - 有足够问题描述支持属性诊断。
- 不适用或可能失效的条件：
  - 目标函数便宜，surrogate 管理开销超过收益；
  - 问题属性严重未知，初期 profile 本身不可靠；
  - 数据分布强漂移但算法仍使用静态 surrogate；
  - 隐私、部署安全或硬约束要求未体现在模型和 infill 中；
  - LLM 生成候选未经可验证校验直接进入真实系统。
- 计算与实现成本：
  - 矩阵本身不增加算法成本；
  - 但若按矩阵加入 ensemble、hybrid、RL、privacy 或 distributed modules，系统复杂度会显著上升；
  - 需要额外记录 model metrics、wall-clock、source relevance 等元数据。
- 解释风险：
  - 这是一张基于 survey 的设计框架，不是经消融证明的单一算法。
  - 综述对不同路线的评价来自多篇文献综合，不代表所有具体实现都满足相同结论。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0202 | 综述覆盖约 300 篇文献，并提出按 problem attributes 和 algorithmic design models 的层级分类 | 综述贡献 | Introduction，PDF 1-2 |
| P2026-0202 | SAMOEA 基础流程包括 initialization、surrogate model optimization、evolutionary search 和 termination criteria | 框架总结 | Sec. II-B、Fig. 2，PDF 2-3 |
| P2026-0202 | 评价指标被分为 solution quality、model performance 和 computational efficiency 三类 | 评价协议 | Sec. II-C、Table I，PDF 3-4 |
| P2026-0202 | problem attributes 分类包括 objective space structure、decision variable space、dynamics/constraints 和 augmented optimization methods | 分类框架 | Sec. III、Fig. 3，PDF 4-6 |
| P2026-0202 | objective space 中讨论 coupled/decoupled objectives、multi/many objectives、regular/irregular PF | 问题属性 | Sec. III-A，PDF 4-5 |
| P2026-0202 | decision variable space 中讨论 continuous/discrete/mixed variables、high-dimensional variables 和 large-scale search spaces | 问题属性 | Sec. III-B，PDF 5 |
| P2026-0202 | surrogate management 分为 regression-based、classification-based、relation-based 和 hybrid surrogate models | 设计组件 | Sec. IV-A，PDF 6-8 |
| P2026-0202 | infill criteria 与 surrogate type 紧密耦合，包括 EI/PI/UCB/LCB/EHVI、classification boundary 和 ranking uncertainty | 设计组件 | Sec. IV-B，PDF 8 |
| P2026-0202 | acceleration mechanisms 包括 decomposition/multi-population/collaborative frameworks、PS/PF learning、special operators 和 knowledge transfer | 设计组件 | Sec. IV-C，PDF 8-9 |
| P2026-0202 | special scenarios 包括 multimodal、heterogeneous objectives/constraints、transfer learning、preference、RL、decomposition 和 inverse modeling | 场景分类 | Sec. V、Fig. 4，PDF 9-11 |
| P2026-0202 | 综述列出 benchmark 和真实应用，包括 building、compressor、battery、motor、robotics、NAS、molecular 和 chemical process | 应用综述 | Sec. VI、Table III，PDF 11-13 |
| P2026-0202 | 未来方向包括 efficient/robust surrogate models、parallel/distributed、LLM-assisted、privacy-preserving 和 theoretical analysis | 未来方向 | Sec. VII，PDF 13-15 |
| P2026-0202 | 理论分析部分提出 HV regret、EHVI regret、PAC bounds、surrogate bias 与 evolutionary distortions 等开放问题 | 理论边界 | Sec. VII-E，PDF 14-15 |

## 证据边界

- 当前是一篇 survey，不是单一可复现实验算法。
- 表格为图片占位，模型对比和应用域细节需回查 PDF。
- 综述覆盖到 2025/2026 附近，但 SAMOEA、LLM 和 privacy 方向更新很快。
- 许多建议仍是开放方向，如 LLM-assisted、privacy-preserving 和 theoretical SAMOEAs，不能当作成熟结论。
- 该矩阵适合归类和选型，具体算法性能仍需针对任务做消融和真实评价。

## 待确认

- 能否把该矩阵形式化为自动 algorithm selection 或 configuration system；
- 不同 problem attributes 之间冲突时如何排序优先级；
- LLM-assisted SAMOEA 的 benchmark、可复现性和安全校验标准；
- federated/private surrogate 的优化精度和隐私预算如何平衡；
- 如何把 HV regret、EHVI regret 与 population-based evolutionary dynamics 统一起来。
