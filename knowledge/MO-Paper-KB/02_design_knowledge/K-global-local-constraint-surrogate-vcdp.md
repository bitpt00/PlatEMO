---
knowledge_id: K-global-local-constraint-surrogate-vcdp
name: 全局-局部约束代理与向量场景约束支配
type: method
status: active
source_papers: [P2026-0229]
aliases: [EM-SAEA, ensemble-based constraint surrogate, global-local constraint GP, VCDP, vector-based constrained dominance, expensive constrained MOO, 全局局部约束代理, 向量约束支配]
promotion_reason: 单篇论文提出但接口完整，包含全局/局部约束 GP ensemble、参考向量局部样本构造、不确定性模型选择、VCDP 三场景约束处理和两阶段 ECMOP 优化，可直接改造 surrogate-assisted CMOEA
---

# 全局-局部约束代理与向量场景约束支配

## 核心内容

在昂贵约束多目标优化中，把约束函数的代理建模从单一全局模型改成 global + local ensemble。全局模型用全部样本拟合整体趋势，局部模型按目标空间参考向量分区拟合局部 feasible landscape；预测时用约束不确定性选择更可信的 global 或 local 预测。同时，用 reference-vector angular sector 定义 VCDP：可行解看目标聚合值，同区不可行解优先 CV，异区不可行解按当前 feasible ratio 在目标探索和约束满足间切换。

```text
archive samples
-> train objective GPs globally
-> train constraint global GP + local GPs per reference-vector region
-> predict candidate constraints with global/local uncertainty choice
-> compare candidates by VCDP scenarios
-> infill and true re-evaluation update archive
```

## 建立理由

- 为什么值得独立维护：
  - ECMOP 中约束预测错误会直接破坏可行性判断，约束 surrogate 需要比目标 surrogate 更精细；
  - 该知识同时处理“约束地形怎么建模”和“预测约束怎么用于选择”，比单独的代理或单独 CHT 更完整。
- 单篇具体方法的直接复用价值：
  - P2026-0229 给出 EM-SAEA 框架、Algorithm 1-3、复杂度、44 个 benchmark、5 个真实问题、global/local 消融、两阶段消融和 CHT 对比；
  - 可直接替换既有 SAEA/CMOEA 中的 constraint surrogate 和 dominance comparison。
- 与已有设计知识的区别：
  - 不同于“约束违反状态驱动的代理搜索模式切换”：该知识按可行状态切换不同搜索模式和代理数据源；本知识重点是约束函数 global/local ensemble 与 VCDP 选择规则。
  - 不同于“收敛-边界两步代理采样更新”：该知识关注训练集和真实评价样本如何选；本知识关注约束代理如何拟合复杂 feasible landscape。
  - 不同于“特殊点引导的代理辅助复杂前沿搜索”：该知识面向膝点和断裂 PF 的无约束/弱约束昂贵 MOO；本知识面向 ECMOP 的约束预测和 constraint handling。
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识不使用 surrogate，核心是双松弛边界指标和变量分组；本知识依赖代理和有限 FEs。

## 解决的问题

- 适用场景：
  - 真实评价昂贵，FEs 很少；
  - 可行域狭窄、断裂或局部地形复杂；
  - 约束值预测误差会明显误导 population selection；
  - 目标优化和约束满足之间需要阶段化和平衡。
- 现有方法为什么会失败或不足：
  - 全局 constraint surrogate 要拟合完整复杂 landscape，容易错过局部可行边界；
  - 只用 local surrogate 早期样本不足，局部模型不稳定；
  - 普通 CDP 过度优先 feasibility，易困在局部可行区域；
  - 简单随机约束放松没有区分同一目标区域和不同目标区域，可能损害多样性或可行性。
- 仍需解决的问题：
  - 如何自适应确定 local regions 数量；
  - 如何校准 global/local uncertainty；
  - 如何处理 equality、mixed-variable、noisy 或 hidden constraints；
  - 如何在高维决策空间中降低 GP 训练成本。

## 为什么可能有效

```text
ECMOP feasible landscape often complex
-> global GP captures coarse trend with scarce samples
-> local GPs capture narrow/disconnected feasible boundaries after samples accumulate
-> uncertainty choice avoids committing to unreliable local/global model
-> VCDP compares similar-sector solutions mainly by CV to preserve local feasibility
-> VCDP compares cross-sector solutions partly by objectives to retain diverse infeasible bridges
-> two-stage search first approaches UPF, then redirects toward CPF
```

关键假设是：目标空间参考向量分区能近似区分不同约束局部地形，且 GP uncertainty 能反映模型可信度。如果 objective-space 分区和真实 feasible regions 不对应，或者 uncertainty 严重失准，global/local 选择会失效。

## 如何用于算法创新

### 局部创新

- 在 K-RVEA、KTA2、CSEA、TEA 或任意 ECMOP SAEA 中，将 constraint surrogate 替换为 global-local ensemble。
- 对每个 constraint 采用不同 local partition，例如按 CV boundary clustering 而非目标参考向量。
- 将 global/local 二选一改为 uncertainty-weighted averaging，避免硬切换。
- 在 VCDP 中把 feasible ratio `pf` 换成可行率变化、CV 分位数、uncertainty 或 local feasible coverage。
- 在 infill sampling 中优先选择 global/local 分歧大的点，主动提升约束 surrogate。

### 结构创新

- 构建 ECMOP 的双层代理地图：

```text
objective surrogate: global ranking model
constraint surrogate: global trend + local boundary models
constraint handler: sector-aware VCDP
infill: feasible/nonfeasible scenario sampling
```

- 将 stage split 从固定 50% 改为 adaptive controller：当 UPF 收敛、可行率、constraint uncertainty 或 UPF-CPF 距离满足条件时切换。
- 在 high-dimensional ECMOP 中先做 variable grouping 或 sparse GP，再在每组/局部区域训练 constraint ensemble。
- 为 disconnected feasible regions 维护 local model archive，记录哪些 reference sectors 已发现可行岛。

## 适用条件与风险

- 适用条件：
  - 能承受多个 GP 的训练和推理成本；
  - 约束函数连续或足够平滑，GP 有意义；
  - 目标空间参考向量能合理划分候选区域；
  - 有限 FEs 下仍能逐步积累 enough samples 支撑 local models。
- 不适用或可能失效的条件：
  - UPF 与 CPF 距离很大且可行域极窄，固定两阶段切换可能太晚或太早；
  - 高维决策空间导致 GP training/inference 昂贵；
  - 约束强噪声或不连续，GP uncertainty 不能反映真实风险；
  - many-objective 下角扇区稀疏，VCDP 同区/异区判断不稳；
  - equality constraints 未经合理 relaxation。
- 计算与实现成本：
  - 全局 constraint GP 训练约 `O(P*|Arc|^3)`；
  - local GPs 训练约 `O(P*k*|S_i|^3)`；
  - 整体复杂度约 `O(wmax*(M+P)*N*|Arc|^2)`；
  - 论文消融显示完整 ensemble runtime 略高，但在 MW 上仍可接受。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0229 | EM-SAEA 使用两阶段框架：前半预算 objective-oriented，后半预算 constraint-oriented | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4-5 |
| P2026-0229 | 每个约束函数训练一个 global GP 和 `k` 个 local GPs，local training set 由两种 reference-vector assignment 方法取 union | 作者提出的方法 | Sec. III-B，Algorithm 2，Fig. 3，PDF 5-6 |
| P2026-0229 | 候选约束预测时比较 local/global 在所有约束上的 mean uncertainty，采用不确定性更小的预测 | 作者提出的方法 | Sec. III-B，PDF 6 |
| P2026-0229 | VCDP 根据 feasible/infeasible、同一 angular sector 或不同 sector 定义三类 dominance comparison | 作者提出的方法 | Sec. III-C，Fig. 4-5，PDF 6-7 |
| P2026-0229 | constraint-oriented search 中将 VCDP 嵌入 decomposition framework，并限制每个 offspring 最大替换数 `nr` 维护多样性 | 作者提出的方法 | Sec. III-D，Algorithm 3，PDF 7 |
| P2026-0229 | 若最终 surrogate population 无可行解，按 active reference vectors 聚类并选择低 CV 解；若有可行非支配解，选分布好的 `mu` 个重评估 | infill 策略 | Sec. III-D，PDF 7 |
| P2026-0229 | 将 ensemble constraint surrogate 嵌入 K-RVEA、CSEA、RVMM 后均提升 LIRCMOP 表现，说明收益不依赖某个 objective-stage SAEA | 敏感性/泛化证据 | Sec. V-A，Table I，PDF 8 |
| P2026-0229 | C-DTLZ、DC-DTLZ、CF 上 EM-SAEA best 数为 8，并显著优于多数 peer | 综合实验支持 | Sec. V-B，Table II，PDF 9 |
| P2026-0229 | MW、LIRCMOP 上 EM-SAEA best 数为 12，并显著优于各 peer 16-27 个问题不等 | 综合实验支持 | Sec. V-B，Table III，PDF 9-10 |
| P2026-0229 | LIRCMOP1-4 上性能较弱，原因是 UPF-CPF 距离大且可行域极窄，固定 stage split 转向 CPF 需要很多迭代 | 适用边界 | Sec. V-B，Fig. 6，PDF 9-10 |
| P2026-0229 | EM-SAEA-G/L 消融显示完整 ensemble 在 IGD+ 和 FR 上优于仅 global 或仅 local；local 后期在 LIRCMOP11 等断裂可行域调用更多 | 消融实验支持 | Sec. V-C，Figs. 8-9，PDF 11 |
| P2026-0229 | 两阶段消融显示 objective-only、constraint-only 均弱于完整 EM-SAEA；VCDP 优于 CDP、epsilon、SR、ACDP 等 CHT | 消融实验支持 | Sec. V-C，Figs. 10-11，PDF 12 |
| P2026-0229 | RCM 真实问题中 EM-SAEA best 数为 3，并显著优于多数 peer | 真实问题支持 | Sec. V-D，Table IV，PDF 12 |
| P2026-0229 | 作者未来工作包括更准确的模型、更定制的阶段划分和扩展到更高维 decision spaces | 未来工作 | Sec. VI，PDF 13 |

## 待确认

- Supplementary 中包含参数 `k` 具体敏感性和多个消融表，当前卡只记录正文结论。
- local model 分区是否应依据 constraint-space 而非 objective-space。
- GP uncertainty 是否需要校准后再比较 global/local。
- 如何处理 equality constraints、mixed variables 和 noisy constraints。
