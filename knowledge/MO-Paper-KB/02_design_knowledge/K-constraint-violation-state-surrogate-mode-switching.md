---
knowledge_id: K-constraint-violation-state-surrogate-mode-switching
name: 约束违反状态驱动的代理搜索模式切换
type: method
status: active
source_papers: [P2026-0151]
aliases: [CASA, CV-driven surrogate mode switching, constraint-violation adaptive search, stage-adaptive surrogate management, 约束违反自适应搜索, 三档案代理管理]
promotion_reason: 单篇论文提出但流程完整，包含约束状态识别、三搜索模式、三档案数据源和 KTA2/KCCMO 代理搜索接口，可直接用于昂贵约束多目标算法的模式调度与代理管理
---

# 约束违反状态驱动的代理搜索模式切换

## 核心内容

在昂贵约束多目标优化中，把当前种群的约束满足状态作为搜索模式调度信号。算法先做短期无约束代理搜索快速靠近 unconstrained PF；随后根据仍被违反的约束数量，将搜索切换为全不可行、部分可行或全可行模式，并为每种模式启用不同档案组合、约束代理和搜索子算法。

```text
初始真实评价样本
-> 建立 DA/CA/FA 三类档案
-> 先做短期无约束代理搜索
-> 统计约束违反状态 numViol
-> 全不可行: [CA; FA] + KCCMO 全局可行性恢复
-> 部分可行: [DA; FA] + KCCMO 只修复不可行子集
-> 全可行: [CA; DA] + KTA2 提升收敛和多样性
-> 少量真实评价校正并更新档案/代理
```

## 建立理由

- 为什么值得独立维护：它提供了明确的“约束状态 -> 搜索模式 -> 档案数据源 -> 代理建模目标”映射，可嵌入其他 expensive constrained MOEA/SAEA。
- 单篇具体方法的直接复用价值：P2026-0151 给出 Algorithm 3、三种状态、三类档案、KTA2/KCCMO 组合、消融、36 个 benchmark 和 6 个真实约束问题证据。
- 与已有设计知识的区别：
  - 不同于“自适应代理内环加速器”：该知识主要面向无约束 MOOP 的代理候选回灌和退出；本知识面向约束昂贵 MOO 的模式切换和约束代理训练数据管理。
  - 不同于“不可行解辅助的种群组成管理”：该知识不只保留不可行解，而是按约束状态改变搜索子算法和 surrogate 数据源。
  - 不同于“环境变化严重度驱动的多策略预测响应”：该知识的状态来自约束违反，而不是动态环境变化；作用位置是 ECMOP 的搜索阶段调度。
  - 不同于“更新状态驱动的双参考点切换”：本知识切换的是约束/无约束代理搜索模式和档案组合，而非分解参考点。

## 解决的问题

- 适用场景：
  - 真实目标或约束评价昂贵；
  - 约束数量多，完整约束 surrogate 建模成本高或样本不足；
  - 可行域狭窄、断裂或早期难以找到；
  - 不同搜索阶段对可行性恢复、收敛和多样性的需求不同；
  - 算法能维护真实评价档案并训练目标/约束代理。
- 现有方法为什么会失败或不足：
  - 单一代理策略无法同时适合全不可行、部分可行和全可行状态；
  - 固定 unconstrained-first 可能在复杂约束下长期追逐不可行 UPF；
  - 可行样本稀缺会导致约束代理边界偏差；
  - 全种群约束搜索在部分可行时会浪费计算在已可行个体上；
  - 完全依赖可行优先会降低不可行边界附近的探索。
- 仍需解决的问题：
  - 切换信号如何同时反映约束违反数量、程度和可行率；
  - 代理训练样本如何避免档案偏置；
  - 多目标数和碎片化 PF 下如何维持足够分布；
  - 模式切换开销如何和优化收益平衡。

## 为什么可能有效

```text
昂贵约束 MOO 的搜索需求随可行性状态改变
-> 全不可行时, 目标优化信息不够可靠, 需要全局降低 CV
-> 部分可行时, 只需重点修复不可行子集, 保留已有可行结构
-> 全可行时, 主要矛盾转为 PF 收敛和多样性
-> 档案按 DA/CA/FA 分工记录分布、收敛、可行性信息
-> 每个状态使用匹配的档案训练代理
-> 少量真实评价不断校正代理和状态判断
```

核心假设是：约束违反状态能较好代表当前搜索阶段；如果状态信号过粗或代理偏差很大，切换可能会误导搜索。

## 实现接口

- 输入：
  - 当前真实评价数据集；
  - 每个候选的目标值、约束值和总 CV；
  - DA、CA、FA 三类档案或等价数据源；
  - objective surrogate 与 constraint surrogate 训练器；
  - 至少两个搜索子程序：无约束目标搜索和可行性导向约束搜索。
- 输出：
  - 当前模式；
  - 对应训练数据和 surrogate；
  - 供真实评价的 promising candidates；
  - 更新后的档案和全局数据集。
- 插入位置：
  - expensive constrained MOEA 的 generation-level controller；
  - surrogate management 层；
  - constraint-handling search stage 之前。
- 最小实现：

```text
initialize A, CA, DA, FA by LHS and true evaluations
for generation in budget:
    if early_unconstrained_phase or numViol(A) == 0:
        train_objective_surrogates(A or CA+DA)
        candidates <- unconstrained_surrogate_search(CA, DA)
    else if numViol(A) == num_constraints:
        train_constraint_surrogates(CA + FA)
        candidates <- feasibility_search_whole_population(CA, FA)
    else:
        train_constraint_surrogates(DA + FA)
        candidates <- feasibility_search_infeasible_subset(DA, FA)

    evaluated <- true_evaluate(select_promising(candidates))
    A <- A union evaluated
    update(CA, DA, FA, evaluated)
```

- P2026-0151 的具体实例：
  - 初始和全可行阶段使用 KTA2；
  - 全不可行和部分可行阶段使用 KCCMO；
  - 初始无约束搜索固定 10 代；
  - DA 通过去重、Pareto dominance 和 crowding-distance truncation 维护分布；
  - FA 通过 SPEA2 fitness assignment 维护可行性相关解；
  - CA 类似 FA，但不考虑约束信息，只保留收敛导向解。

## 如何用于算法创新

### 局部创新

- 将二元可行/不可行切换改为多状态切换，区分全不可行、部分可行和全可行。
- 将 `numViol` 扩展为状态向量：可行率、平均 CV、最大 CV、近可行样本密度、目标指标停滞。
- 用 bandit 或 reinforcement learning 学习模式选择，替代固定 if-else。
- 对部分可行模式只给不可行个体分配 constraint surrogate 搜索预算，降低无效开销。
- 给不同约束类型维护专门 FA，例如等式约束、几何约束、安全约束分别建模。

### 结构创新

- 构建通用 ECMOP 控制器：状态识别器、模式池、档案池、代理池和真实评价校正器分离。
- 与不可行解比例管理结合：模式决定全局搜索压力，不可行比例控制决定种群组成。
- 与代理贡献退出机制结合：若某个模式产生的真实评价贡献下降，自动降权或延长其他模式。
- 与多保真或 Bayesian-evolutionary staged search 结合，在不同阶段切换高低保真模型和进化搜索。

## 适用条件与风险

- 适用条件：
  - 约束违反可被量化并在线统计；
  - 真实评价足够昂贵，值得维护多个代理和档案；
  - 可行域复杂，单一可行优先或单一无约束搜索表现不稳定；
  - 有足够初始样本和持续真实评价来更新代理；
  - 搜索子算法可分离为目标导向和可行性导向模块。
- 不适用或可能失效的条件：
  - 评价便宜，多代理/多档案开销抵消收益；
  - 约束非常简单，单一可行优先已经足够；
  - `numViol` 与实际可行性难度不相关，例如少数约束极难、许多约束极易；
  - 可行域高度多峰或远距离断裂，当前模式缺少全局探索；
  - 高目标数下环境选择无法维持分布。
- 计算与实现成本：
  - 需要维护 DA/CA/FA 三类档案；
  - 每代需要识别状态、训练/查询 surrogate、协调模式；
  - 运行时高于简单 CMOEA 和轻量 SAEA，但可能低于更复杂的多代理方法。
- 解释风险：
  - “全约束均有违反”不等于整个种群全不可行，也不等于没有有价值目标信息；
  - 部分可行模式只修复不可行子集，可能忽略可行个体附近的更优可行边界；
  - 三档案保留的样本分布会影响代理偏差，不能视为无偏训练集。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0151 | CASA 根据 fully infeasible、partially feasible、fully feasible 三种状态调整从可行性恢复到 PF 逼近的搜索重点 | 作者提出的方法 | Sec. 3.1，PDF 3 |
| P2026-0151 | 初始阶段先执行 10 代 unconstrained surrogate-assisted search，以平衡早期收敛和后续约束搜索预算 | 作者提出的方法 | Sec. 3.2，PDF 3 |
| P2026-0151 | `numViol=C` 时用 `[CA;FA]` 训练约束代理，并用 KCCMO 全局推进可行性 | 作者提出的方法 | Algorithm 3，PDF 4 |
| P2026-0151 | `0<numViol<C` 时用 `[DA;FA]` 训练约束代理，只对不可行子集执行 KCCMO | 作者提出的方法 | Algorithm 3，PDF 4 |
| P2026-0151 | `numViol=0` 或初始无约束阶段用 KTA2 和 CA/DA 促进收敛与多样性 | 作者提出的方法 | Sec. 3.1-3.3，PDF 3-5 |
| P2026-0151 | CASA-C/CASA-A/CASA-K 消融显示完整 CASA 在多数 CF 实例更稳，三变体相对 CASA 的 `+/−/=` 为 `3/5/2`、`2/3/5`、`2/6/2` | 消融实验支持 | Sec. 4.4、Table 1，PDF 6-8 |
| P2026-0151 | DASCMOP 上 CASA 取得 8/9 个最佳 HV，并在所有问题上产生可行解集 | 综合实验支持 | Sec. 4.5、Tables 4-5，PDF 8-12 |
| P2026-0151 | LIRCMOP13-14 上 CASA 明显退化，作者指出三目标选择压力和分布维护不足 | 适用边界 | Sec. 4.5、Tables 6-7，PDF 13-14 |
| P2026-0151 | MW4/MW8/MW14 五目标补充实验中 CASA 取得最佳 IGD+，但作者仍认为退化与目标数和可行域复杂度共同相关 | 扩展实验 | Table 8，PDF 15 |
| P2026-0151 | RWCMOP30-35 上所有对比算法均 N/A，CASA 在六个真实约束问题上均返回有限 IGD+ | 真实问题支持 | Sec. 4.5、Table 9，PDF 15-16 |
| P2026-0151 | CF runtime 中 CASA 运行时高于经典非代理算法和 SSDE，作者将其归因于模式识别、决策和多代理协调开销 | 成本边界 | Table 10，PDF 16 |

## 证据边界

- 当前只有单篇论文证据。
- 消融显示完整 CASA 更稳，但并非每个问题都最优。
- 强多峰、孤立 PF 点、多个断裂可行段和三目标 LIRCMOP 仍是短板。
- 真实问题证据来自 RWCMOP benchmark，不是真实在线昂贵仿真闭环。
- `numViol` 切换信号较粗，未直接度量约束违反程度和可行率。

## 待确认

- 如何设计更细的约束状态表示，避免 `numViol` 误判；
- 如何为每个模式动态分配真实评价预算；
- 如何在线检测某个模式或某类代理开始失效；
- 如何扩展到 many-objective、离散/混合变量、噪声约束和等式约束；
- 如何减少多档案、多代理和模式协调的计算开销。

