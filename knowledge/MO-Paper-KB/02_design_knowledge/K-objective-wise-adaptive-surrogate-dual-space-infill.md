---
knowledge_id: K-objective-wise-adaptive-surrogate-dual-space-infill
name: 目标级自适应代理与双空间 infill 采样
type: method
status: active
source_papers: [P2026-0188]
aliases: [EMaOEA-SASM, self-adaptive surrogate model, objective-wise surrogate selection, R2 adaptive model selection, dual-space indicator, DSI infill, per-objective GP/RBF selection, 目标级代理选择, 双空间采样]
promotion_reason: 单篇论文提出但接口完整，包含目标函数级代理模型池选择、holdout `R^2` 反馈、RVEA 代理内搜索和决策/目标双空间真实评价采样，可直接改造昂贵多目标/许多目标优化的 surrogate management 与 infill 层。
---

# 目标级自适应代理与双空间 infill 采样

## 核心内容

在昂贵多目标或许多目标优化中，不默认所有目标函数都适合同一种代理模型。为每个目标函数维护一个候选代理模型池，用已真实评价档案做 holdout/cross-validation，按预测值与真实值的 `R^2` 或类似指标选择当前更匹配的模型；再用选出的目标代理驱动低成本进化搜索，最后用同时考虑决策空间距离、目标空间距离和目标空间拥挤度的 dual-space indicator 选择少量候选做真实评价。

```text
true archive Arc
-> split Arc into train/test for each objective
-> train candidate surrogate types per objective
-> select model type by R2 or validation score
-> run model-assisted MOEA/MaOEA on selected surrogates
-> score candidates by decision distance + objective distance + density
-> true-evaluate top informative candidate
-> update Arc and repeat
```

P2026-0188 的 EMaOEA-SASM 在每个 objective function 上在 GP 与 RBF 间自适应选模，并用 RVEA 产生候选，再用 DSI 选择一个真实评价点。

## 建立理由

- 为什么值得独立维护：
  - 代理辅助优化常把“选择哪个 surrogate”和“选哪个候选真实评价”混在一起；该知识把两者拆成目标级选模和双空间 infill 两个可替换接口。
  - 多/许多目标问题中不同目标函数可能具有不同线性、多峰、噪声或光滑特性，全目标共用一个模型类型容易把某些目标拟合错。
  - 只看 objective space 的 infill 会忽略决策空间中未探索区域，容易在有限评价预算下过度开发局部前沿。
- 单篇具体方法的直接复用价值：
  - P2026-0188 给出 EMaOEA-SASM Algorithm 1-2、70/30 archive split、GP/RBF 模型池、`R^2` 选模、RVEA 代理搜索、DSI 采样、DTLZ/WFG/真实应用证据。
- 与已有设计知识的区别：
  - 不同于“自适应代理内环加速器”：该知识强调代理内环回灌和半衰期退出；本知识强调每个目标函数的代理类型选择和双空间真实评价采样。
  - 不同于“网格排序成对关系代理筛选”：该知识学习解对相对优劣关系；本知识仍做 objective-value surrogate，但按目标函数选择模型类型。
  - 不同于“特殊点引导的代理辅助复杂前沿搜索”：该知识围绕膝点/断裂 PF 调度 infill；本知识用决策/目标空间稀疏性做通用信息采样。
  - 不同于“数据流动态优化的代理超参数迁移”：该知识面对不能主动真实评价的数据流和历史漂移；本知识面对可主动选择真实评价点的昂贵优化。

## 解决的问题

- 适用场景：
  - 真实目标评价昂贵，代理训练和查询相对便宜；
  - 目标数较多，不同目标函数可能有不同函数形态；
  - 可以维护真实评价 archive，并能周期性重训代理；
  - 希望 infill 不只开发当前预测最优区域，也覆盖决策空间和目标空间的稀疏区域；
  - 可使用 RVEA、MOEA/D、NSGA-II 或其他代理内搜索器产生候选。
- 现有方法为什么会失败或不足：
  - 单一 GP/RBF/RF/NN 很难同时适配所有目标函数；
  - 全目标 ensemble 虽稳健但训练和推理成本高；
  - 只用预测目标值会积累代理误差，容易过度开发虚假前沿；
  - 只用 objective-space diversity 可能在决策空间重复采样同一结构；
  - 只用 uncertainty 或 EI 类指标在 many-objective 下容易计算昂贵或不稳定。
- 仍需解决的问题：
  - 验证指标应评价目标值拟合、排序保持还是选点贡献；
  - 模型类型频繁切换时如何保持稳定；
  - DSI 的探索偏置如何与收敛压力平衡；
  - 高目标数和大档案下多模型训练开销如何控制。

## 为什么可能有效

```text
目标函数特性异质
-> 每个目标单独选择代理类型
-> 减少统一模型对局部目标的系统误差
-> 代理内搜索生成低成本候选前沿
-> DSI 偏向决策/目标双空间稀疏区域
-> 真实评价校正代理并扩展 archive
```

关键假设是：holdout 上的拟合指标能反映代理在下一批候选区域的可用性，并且决策空间/目标空间的稀疏性与真实评价信息量正相关。如果代理预测偏差集中在候选区域，或稀疏区域远离真实 PF，DSI 会采到探索性强但收敛价值低的点。

## 如何用于算法创新

### 局部创新

- 给任意 SAEA 的每目标代理增加模型池：GP、RBF、RF、SVR、NN、dropout NN、多项式或局部代理。
- 用 cross-validation `R^2`、Kendall tau、rank preservation、Pareto rank consistency、calibration error 或真实贡献历史选择模型。
- 将 DSI 与 EI/LCB/EHVI、APD、HV contribution、constraint violation reduction 线性或 bandit 混合。
- 让 DSI 的决策距离使用变量分组、Mahalanobis distance、learned embedding 或 Hamming distance，以适配大规模、混合或离散变量。
- 对早期小样本阶段使用 soft model weights 或 ensemble average，样本足够后再硬选择单模型。

### 结构创新

- 构建目标级模型路由器：

```text
objective m
-> candidate models
-> validation/ranking score
-> selected or weighted surrogate
-> shared candidate generator
-> infill scheduler with convergence/exploration criteria
```

- 将模型选择与真实评价预算调度结合：某个目标代理误差大时，优先评价能校正该目标的候选。
- 与特殊点 infill 结合：普通候选用 DSI，膝点/断裂候选用局部代理和不确定性，统一竞争真实评价预算。
- 与异构目标评价时间结合：每个解-目标不仅选 surrogate type，也决定是否触发该目标的高保真评价。

## 适用条件与风险

- 适用条件：
  - 已真实评价样本足以支撑至少简易 holdout 或交叉验证；
  - 候选代理模型的训练成本低于节省的真实评价成本；
  - 每个目标函数可以单独建模，目标间耦合不强到必须使用多输出模型；
  - 决策空间距离和目标空间距离对未探索区域有意义。
- 不适用或可能失效的条件：
  - 样本极少，70/30 划分导致 `R^2` 方差过大；
  - 目标函数强噪声或不可预测，所有代理 validation score 都不可靠；
  - 决策空间存在等价编码或强非欧几里得结构，欧氏距离误导 DSI；
  - 问题主要是 convergence-driven，过强探索会牺牲收敛；
  - 目标数和 archive 规模很大，多目标多模型重训成本过高。
- 计算与实现成本：
  - 每轮每目标至少训练多个候选代理；
  - GP 训练随样本数立方增长，需考虑稀疏 GP、局部 GP、RBF 或缓存；
  - 需要维护 archive split、归一化、模型选择记录、候选距离和拥挤度计算。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0188 | EMaOEA-SASM 包含 initialization、adaptive model selection、surrogate training、model-assisted optimization 和 infill sampling 五个组件 | 作者提出的方法 | Sec. II-A，Algorithm 1，PDF 3-4 |
| P2026-0188 | Adaptive Model Selection 将 `Arc` 分成 70% `TRD` 和 30% `TED`，对每个目标分别训练 GP/RBF 并用 `R^2` 选择模型 | 作者提出的方法 | Sec. II-B，Algorithm 2，PDF 4 |
| P2026-0188 | DSI 先找候选在决策空间的 archive 最近邻，再用目标空间距离作为半径统计拥挤度，以选择双空间更有探索价值的真实评价点 | 作者提出的方法 | Sec. II-C，Fig. 1，PDF 4-5 |
| P2026-0188 | 选模消融中，EMaOEA-SASM 在 WFG8/WFG9 上比固定 RBF 更好于 12 个函数，和固定 GP 性能接近但运行时间显著更低 | 消融实验支持 | Sec. III-B，Table II，PDF 6-7 |
| P2026-0188 | DTLZ 上 EMaOEA-SASM 相比六个 SAEA 分别在 36、44、34、31、29、31 个 of 49 instances 上更好 | 综合实验支持 | Sec. III-C，Table S1，PDF 6 |
| P2026-0188 | WFG 上 EMaOEA-SASM 相比六个 SAEA 分别在 51、59、43、60、34、54 个 of 63 instances 上更好 | 综合实验支持 | Sec. III-C，Table S2，PDF 6 |
| P2026-0188 | DTLZ+WFG 共 112 个问题上，EMaOEA-SASM 相比六个对比算法分别更好于 87、103、77、91、63、95 个 | 综合实验支持 | Sec. III-C，Table III，PDF 7 |
| P2026-0188 | RPO 真实问题中 EMaOEA-SASM 获得最高 HV；HEV 问题 median 不是最好但 IQR 和范围更小 | 真实应用支持 | Sec. III-D，Table IV，Fig. 5，PDF 8 |
| P2026-0188 | 作者指出 DSI 只考虑双空间 crowdedness，未来要把 convergence performance 纳入 infill criterion | 作者局限与未来工作 | Sec. IV，PDF 9 |

## 待确认

- `R^2`、rank correlation、uncertainty calibration 和真实 HV/IGD contribution 哪个更适合作为模型选择 credit；
- DSI 中决策距离、目标距离和拥挤度的尺度归一化是否稳定；
- 早期样本极少时是否应使用 soft ensemble 而非硬模型选择；
- 如何在 convergence-driven 问题上避免过度探索；
- 对约束、多模态、离散/混合变量、噪声和异构评价时间是否需要专门距离与采样准则。
