---
knowledge_id: K-dual-boundary-infeasible-indicator-vgde
name: 双边界不可行辅助指标与分组 DE
type: method
status: active
source_papers: [P2026-0221]
aliases: [ILCMO, infeasibility-assisted dynamic indicator, dual relaxed constraint boundaries, VGDE, large-scale constrained MOO, 双松弛约束边界, 不可行辅助动态指标, 变量分组DE]
promotion_reason: 单篇论文提出但接口完整，包含可行性静态指标、双松弛约束边界动态指标、双种群分工、变量分组 DE 和多组消融证据，可直接改造大规模约束多目标优化的环境选择与子代生成层
---

# 双边界不可行辅助指标与分组 DE

## 核心内容

在大规模约束多目标优化中，用两个互补指标驱动两个种群。主种群用 feasibility-oriented indicator 保留可行非支配解并持续逼近 CPF；辅助种群用两个动态松弛约束边界在可行解附近划分 exploration/exploitation regions，保留有助于跨越不可行障碍和扩展局部多样性的不可行解。子代生成时用变量分组 DE 先在低维子空间高效搜索，再逐步回到完整变量空间精修。

```text
P1: evaluate by I_s
    -> retain feasible nondominated and low-CV high-quality solutions

P2: evaluate by I_d
    -> alpha_t defines local search boundary
    -> beta_t splits exploration/exploitation regions
    -> preserve evenly distributed solutions around feasible regions

VGDE:
    rank population -> Se / Sp
    group variables
    Se: intra-learning for diversity
    Sp: inter-learning from Se for convergence
    rho: low-dimensional search early, full-dimensional search later
```

## 建立理由

- 为什么值得独立维护：
  - 高维约束优化同时需要找到可行域、利用有价值不可行解、维持局部多样性和降低 reproduction 维度；
  - 该知识把这些需求分解到两个指标、两个种群和 VGDE 子代生成，模块边界清楚。
- 单篇具体方法的直接复用价值：
  - P2026-0221 给出 `I_s`、`I_d`、Theorems 1-7、Algorithms 1-4、VGDE 和多组消融；
  - 证据覆盖 50-1000 维四套 benchmark、小规模 CMOP、microgrid dispatch 和策略消融。
- 与已有设计知识的区别：
  - 不同于“约束边界远距不可行辅助引导”：该知识用阶段切换、CV 目标和主群距离筛辅助不可行解；本知识用两个数学 indicator 和双松弛边界定义 local exploration/exploitation regions。
  - 不同于“不可行解辅助的种群组成管理”：本知识不只控制可行/不可行比例，而是用 `alpha_t/beta_t` 和 subregion truncation 维护 CPF 周边均匀搜索。
  - 不同于“约束违反状态驱动的代理搜索模式切换”：本知识不依赖 surrogate，也不是按 fully/partially feasible 状态切换代理模式。
  - 不同于“大规模变量类型挖掘/资源分配”：本知识的变量处理是 reproduction 层的动态分组 DE，并与约束指标紧密耦合。

## 解决的问题

- 适用场景：
  - 大规模 CMOP/LSCMOP，变量维度高且约束复杂；
  - 可行区域小、断裂、离 UPF 远，或目标空间中有大量 local infeasible regions；
  - 需要利用 promising infeasible solutions 但又不能让不可行解无边界扩散；
  - 完整变量空间搜索过慢，需要变量组子空间加速。
- 现有方法为什么会失败或不足：
  - 纯 feasibility-first 会过早收敛到局部可行区；
  - 无约束/UPF 辅助种群在 CPF 远离 UPF 时会浪费资源；
  - 单一 epsilon 边界缺少对 CPF 周边 exploitation diversity 的控制；
  - 始终低维分组会损失全局多样性，始终全维搜索又收敛慢。
- 仍需解决的问题：
  - 初始 `alpha_0` 如何稳健设定；
  - 如何识别 `P2` 是否正在搜索无效不可行区域；
  - 如何为黑箱变量构造更有效分组；
  - 如何将该机制扩展到昂贵评价、动态约束和多模态约束。

## 为什么可能有效

```text
LSCMOP 可行域难找且高维搜索慢
-> P1 用 I_s 稳定保留可行非支配解
-> P2 不直接追 UPF, 而围绕 P1/可行信息定义 alpha_t local region
-> beta_t 随可行比例收紧, 在探索障碍和开发 CPF 周边间切换
-> subregion truncation 防止 P2 聚集在局部
-> VGDE 降低早期搜索维度并后期全维微调
```

关键假设是：初始或早期种群的 constraint violation 分布能给出有意义的 `alpha_t` 搜索边界；如果初始最大 CV 极小或为 0，`I_d` 的局部搜索区域会过窄，辅助搜索价值下降。

## 如何用于算法创新

### 局部创新

- 在任意双种群 CMOEA 中，将辅助种群选择替换为 `I_d` 双边界指标，主种群保留原 CDP/epsilon/indicator。
- 把 `alpha_t` 改为 CV 分位数、外部 infeasible archive 半径或 feasibility-ratio feedback，而不是初始最大 CV。
- 用变量约束敏感性、梯度/扰动响应、互信息或历史成功率形成 VGDE 分组。
- 将 `I_d` 的 subregion truncation 与参考向量、SDE、angle diversity 或 decision diversity 结合。

### 结构创新

- 构建 LSCMOP 控制器：

```text
feasible-driver population (I_s)
-> infeasible-local-diversity population (I_d)
-> dynamic grouped reproduction (VGDE)
-> cross-population merge and information injection
```

- 在 expensive CMOP 中把 `I_d` 用作候选预筛指标，只真实评价 `alpha/beta` 边界内有贡献的不可行候选。
- 在 dynamic constrained MOP 中将 `alpha_t` 重置为变化检测后的 CV 分布分位数，并让 `P2` 快速重建可行域周边覆盖。

## 适用条件与风险

- 适用条件：
  - 目标和约束均可评价，能计算整体 constraint violation；
  - 高维变量可分组，且分组后局部搜索仍能产生有效改进；
  - 有足够评价预算让 `P2` 的不可行探索反馈到 `P1`；
  - CPF 周边不可行区域确实包含有价值搜索信息。
- 不适用或可能失效的条件：
  - 初始 CV 最大值太小，`alpha_t` 边界无法覆盖有用不可行区域；
  - CPF 与有价值不可行区域相距很远，local boundary 不足以提供探索；
  - 变量强耦合且分组破坏关键依赖；
  - 约束噪声大，CV 排序和边界判断不稳定。
- 计算与实现成本：
  - 每代需计算 pairwise/indicator fitness 和 subregion truncation；
  - 双种群和双 offspring 合并会增加评价和选择管理成本；
  - VGDE 需要分组机制、`rho` 调度、intra/inter learning operator 和 PM。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0221 | `I_s(x|P) >= 0` 当且仅当 `x` 是 feasible nondominated solution；且可行解优先于不可行解，低 CV 不可行解优先 | 理论性质 | Sec. III-A，Theorems 1-3，PDF 4 |
| P2026-0221 | `I_d` 使用 `alpha_t` 和 `beta_t` 两个松弛边界，分别定义 local search regions 和 exploration/exploitation regions | 作者提出的方法 | Sec. III-B，PDF 4-5 |
| P2026-0221 | `I_d` 可识别 exploitation regions，并在拥挤的 beta-infeasible 解中删除较大 CV 个体，最终 `alpha_t=beta_t=0` 时与 `I_s` 等价 | 理论性质 | Sec. III-B，Theorems 4-7，PDF 5 |
| P2026-0221 | ILCMO 用 `P1`/`P2` 分别基于 `I_s`/`I_d` 评价，且 `P1` 参与 `P2` 更新以提供可行信息 | 框架设计 | Sec. IV-A，Algorithm 1，PDF 5-6 |
| P2026-0221 | VGDE 将种群分为 `Se`/`Sp`，使用 ordered grouping、动态 `rho`、intralearning 和 interlearning DE | 作者提出的方法 | Sec. IV-B，Algorithm 2，PDF 6-7 |
| P2026-0221 | LIRCMOP4 `D=500` search behavior 显示 `P2` 能覆盖 CPF 周围不可行区域并帮助 `P1` 改善最终分布 | 机制解释 | Sec. VI-A，Fig. 4，PDF 8 |
| P2026-0221 | DASCMOP3 变体中 ILCMO 输出种群可行比例保持 `100%`，DGEA 从 `31.4%` 降到 `9.5%` | 泛化实验支持 | Sec. VI-B，PDF 9 |
| P2026-0221 | DASCMOP 上 LCMOEA 在 IGD/IGD+/HV 分别只有 3/2/1 个函数优于 ILCMO，21/23/23 个函数差于 ILCMO | 对比实验支持 | Sec. VII-A，PDF 10 |
| P2026-0221 | SDC 上 ILCMO 在 45 个函数中 IGD/IGD+/HV 分别有 32/33/31 个 best results | 对比实验支持 | Sec. VII-A，PDF 10 |
| P2026-0221 | LSCM 上 ILCMO 在 36 个函数中 IGD/IGD+/HV 分别有 21/21/16 个 best results | 对比实验支持 | Sec. VII-A，PDF 10 |
| P2026-0221 | Microgrid dispatch `D=144` 中 ILCMO 显著优于 7 个 peer algorithms，DGEA 30 次运行均未找到可行解 | 真实应用证据 | Sec. VII-C，Table III，PDF 12 |
| P2026-0221 | 六种 `I_d` 边界变体中完整 ILCMO 显著更优，说明 `alpha_t` 与 `beta_t` 同时必要 | 消融实验支持 | Sec. VII-D，Table IV，PDF 12-13 |
| P2026-0221 | 完整 ILCMO 相比 `ILCMO_VGDE0` 在 50 个函数上 IGD/IGD+/HV 分别 35/37/36 个更优；`ILCMO_VGDE1` 最差且部分问题无可行解 | VGDE 消融支持 | Sec. VII-D，Table V，PDF 13 |
| P2026-0221 | ordered grouping 通常表现最佳，linear grouping 只在变量天然有序的 LSCM 上更适合 | 分组机制证据 | Sec. VII-D，Table VI，PDF 13 |
| P2026-0221 | 作者指出 `I_d` 依赖初始最大 CV，未来需研究初始 `alpha` 设置，并扩展到 expensive/multimodal/dynamic | 边界与未来工作 | Sec. VIII，PDF 13 |

## 待确认

- 补充材料中的完整 Wilcoxon/Friedman 统计、参数敏感性和函数级结果需要后续补读。
- 当初始 CV 极小或全可行时，是否能自动扩展 `alpha_t` 搜索范围。
- 在强耦合变量、混合变量和昂贵评价下，VGDE 与双边界指标的收益是否仍稳定。
