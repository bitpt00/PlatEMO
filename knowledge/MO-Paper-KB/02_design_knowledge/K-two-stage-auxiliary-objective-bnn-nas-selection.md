---
knowledge_id: K-two-stage-auxiliary-objective-bnn-nas-selection
name: 两阶段辅助目标的 BNN-NAS 小模型陷阱规避
type: method
status: active
source_papers: [P2026-0180]
aliases: [MO-TS-BNAS, two-stage auxiliary objective NAS, small model trap, auxiliary-objective environmental selection, delayed training rewards, BNN NAS selection, 两阶段辅助目标, 小模型陷阱, 辅助目标非支配排序, 权重共享NAS]
promotion_reason: 单篇论文提出但机制明确，可直接移植到 NAS、模型压缩和其他性能-资源多目标搜索的环境选择中，用于缓解权重共享或低保真评价早期偏向小模型的问题
---

# 两阶段辅助目标的 BNN-NAS 小模型陷阱规避

## 核心内容

在 one-shot NAS、BNN NAS 或其他权重共享/低保真性能-资源搜索中，小模型常因训练更快、评价噪声更小、资源目标更容易优化而在早期支配较大模型。两阶段辅助目标选择先把“保留有潜力的大模型”显式写进辅助非支配排序，让含参数操作得到足够训练；随后再回到真实性能-资源目标，同时保留一部分辅助排序个体维持资源轴多样性。

最小流程：

```text
parent + offspring
-> evaluate true objectives: error f1, model size/resource f2
-> build auxiliary objectives: fa = f1 * (1 - f2), fb = 1 - f2
-> F1: nondominated sort by (f1, f2)
-> F2: nondominated sort by (fa, fb)

stage 1:
  select next population mainly from F2
  protect larger/slow-start candidates

stage 2:
  alternately select from F1 and F2
  converge to true Pareto front while retaining size diversity
```

这里的公式来自 P2026-0180 Sec. III-C 正文例子：Markdown 中公式图片缺失，但作者用数值计算说明 `fb = 1 - f2`，`fa = f1 * (1 - f2)`。跨问题复用时应先把资源目标归一化到可比较尺度。

## 建立理由

- 为什么值得独立维护：
  - 该机制不是 BNN 专属训练技巧，而是一种可插入环境选择的选择压力调度；
  - 它处理的是“评价时滞和资源目标共同造成小模型早熟支配”的问题，可迁移到普通 NAS、模型压缩、硬件感知搜索和低保真多目标架构搜索；
  - 它提供了明确接口：真实目标排序、辅助目标排序、阶段切换和交替选择比例。
- 与已有设计知识的区别：
  - 不同于“复杂度分组的目标子空间排序”：复杂度分组按资源区间切 objective space，并在各预算区间内独立排序；本知识通过辅助目标改写支配关系，并用阶段调度控制何时保护大模型、何时回到真实目标。
  - 不同于“多保真不确定集成的 NAS 评价加速”：多保真集成处理短训评价的不确定性和重评预算；本知识不建立性能预测器，而是在环境选择中补偿 slow-start candidates。
  - 不同于“可训练性约束的在线分类器辅助 NAS”：在线分类器用于过滤低潜力或不可训练结构；本知识不做候选准入，而是改变排序目标和生存概率。
  - 不同于“确定性新颖性衰减的神经进化权重调度”：新颖性调度平衡结构探索和性能开发；本知识专门针对性能-资源搜索中的小模型偏置。

## 解决的问题

- 适用场景：
  - NAS 或模型压缩同时优化 error/accuracy 与 model size、FLOPs、MAdds、latency、energy；
  - 使用 one-shot weight sharing、partial training、mini-batch validation 或其他低保真评价；
  - 大模型、复杂模块或含参数操作需要更多训练步才能表现潜力；
  - 最终需要多个资源预算上的 Pareto candidates，而不是单个最小模型。
- 现有方法为什么会失败或不足：
  - 普通 NSGA-II 按 `error` 和 `size` 排序，会让小而早熟的模型同时占据精度和规模优势；
  - 仅加入 `1 - size` 或 `1/size` 可能保留极小和极大模型，但中等规模候选不足；
  - crowding distance 只能在同一前沿内维护几何分布，不能修复早期评价偏差造成的支配关系；
  - 若前期大模型已被淘汰，后期真实目标排序没有机会恢复这些结构。

## 为什么可能有效

- 权重共享超网中，不同规模架构的“训练成熟度”不一致；早期验证错误混合了结构优劣和训练不足。辅助目标相当于给较大模型一个 warm-up 生存窗口。
- `fa = f1 * (1 - f2)` 让更大模型在误差相近或略差时仍可能在辅助排序中占优，从而抵消资源目标对小模型的单向偏好。
- 第一阶段集中使用辅助排序，可以让含参数分支被充分训练，减少 delayed training rewards；
- 第二阶段交替使用真实目标排序和辅助排序，避免算法长期偏向大模型，同时保留资源轴覆盖。

## 实现接口

- 输入：
  - 候选集合 `U = P_t union Q_t`；
  - 真实性能目标 `f1`，例如 validation error；
  - 资源目标 `f2`，例如 normalized params、FLOPs、latency 或 memory；
  - 最大代数 `T`，当前代数 `t`；
  - population size `M`；
  - 可选：资源目标归一化边界、辅助选择比例、阶段切换点。
- 输出：
  - 下一代 population `P_{t+1}`；
  - 可选：辅助排序 archive 或资源覆盖统计。
- 插入位置：
  - NSGA-II/NSGA-Net/EMONAS 的 environmental selection；
  - one-shot NAS 的候选保留；
  - 模型压缩或量化搜索的性能-成本 Pareto selection；
  - 多保真架构搜索中低保真阶段的 survivor selection。

最小实现：

```text
normalize f2 to [0, 1]
fa <- f1 * (1 - f2)
fb <- 1 - f2

F1 <- nondominated_sort(U, objectives=(f1, f2))
F2 <- nondominated_sort(U, objectives=(fa, fb))

if t < switch_generation:
    P_{t+1} <- rank_and_crowding_select(F2, M)
else:
    P_{t+1} <- alternate_select(F1, F2, M)
```

可把 `switch_generation` 从固定 `T/2` 改为基于资源轴覆盖、validation error variance、HV 改善率或超网训练稳定性的自适应条件。

## 如何用于算法创新

### 局部创新

- 自适应辅助强度：把 `1 - f2` 替换为 `g_t(f2)`，早期强保护大模型，后期逐渐减弱。
- 不确定性感知：当 mini-batch/short-training error 置信区间较宽时，提高辅助排序权重或触发重评。
- 多资源目标：将 `f2` 扩展为 latency、energy、memory 的归一化组合，或为每个资源目标建立独立辅助排序。
- 交替比例调度：根据资源轴覆盖不足、真实 HV 停滞或大模型淘汰率动态调整 `F1:F2` 选择比例。
- 与复杂度分组结合：先按资源区间分组，再在每组内使用辅助目标排序，防止全局小模型偏置和组内早熟同时出现。

### 结构创新

- 构建“slow-start candidate protection”框架：

```text
low-fidelity/weight-sharing evaluation
-> estimate resource-biased early dominance
-> protected auxiliary selection stage
-> true-objective Pareto convergence stage
-> resource-consistent final reconstruction
```

- 将该框架迁移到模型压缩：早期保留较宽/较深/较高 bit-width 结构，后期再按 accuracy-cost Pareto 收敛。
- 将该框架迁移到硬件感知 NAS：早期保护高 latency 但可能高精度的模块，后期按真实 latency/energy 测量收敛。
- 对需要从小代理网络迁移到大网络的 NAS，加入 reconstruction-aware resource objective，避免搜索时规模关系在重建后反转。

## 适用条件与风险

- 适用条件：
  - 资源目标可快速计算或估计；
  - 性能评价存在早期偏差，且偏差系统性不利于较大/复杂候选；
  - 较大模型在训练充分后确实可能提供性能收益；
  - population size 足够支撑辅助排序带来的探索。
- 不适用或可能失效的条件：
  - 任务真实最优区域确实在极小模型附近，辅助保护会浪费预算；
  - 资源目标没有归一化，`1 - f2` 或乘积项会失去意义；
  - 大模型性能差不是训练不足而是结构不适配，辅助排序会延长无效候选寿命；
  - mini-batch validation 噪声过大，辅助目标可能放大偶然误差；
  - 从搜索网络到重建网络的资源映射不一致，搜索到的 Pareto 规模关系可能不稳定。
- 计算与实现成本：
  - 每代需要两次 nondominated sorting 或等价排序；
  - 需要维护阶段切换和交替选择逻辑；
  - 若结合 path dropout、重复验证或重评机制，会增加训练与实现复杂度。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0180 | 作者指出直接把 OSNAS 与多目标 EA 用于 BNN 会因 delayed training rewards 和 weight sharing 落入 small model trap，轻量 BNN 中更严重 | 问题动机 | Introduction，Sec. II-B，PDF 2-3 |
| P2026-0180 | Fig. 6 和正文说明普通多目标算法会快速收敛到较小模型，较大含参数操作因早期训练不足被淘汰 | 机制观察 | Sec. III-C，Fig. 6，PDF 6 |
| P2026-0180 | 提出两个辅助目标 `fa` 和 `fb`，正文例子显示 `fb = 1 - f2`，`fa = f1 * (1 - f2)`，用于让大模型在误差相近或早期略差时仍可保留 | 作者提出的方法 | Sec. III-C，PDF 6 |
| P2026-0180 | Algorithm 2 同时生成 `F1` 真实目标排序和 `F2` 辅助目标排序；第一阶段从 `F2` 选择，第二阶段从 `F1/F2` 交替选择 | 作者提出的方法 | Sec. III-E，Algorithm 2，PDF 7 |
| P2026-0180 | 第二阶段加入 path dropout，作者认为可在超网预热后减轻过拟合并增强泛化 | 组件设计 | Sec. III-E，PDF 7 |
| P2026-0180 | 直接搜索会产生包含大量 parameterless operations 的 degenerate architectures，本文策略搜索到的 cell 结构更符合预期 | 机制可视化 | Sec. IV-B，Fig. 8，PDF 9 |
| P2026-0180 | 与 CARS-style `f1` 和 `1/f2` 二次排序相比，本文两阶段策略更能保留 medium/large models 并改善规模多样性 | 消融实验 | Sec. IV-E，Fig. 9，PDF 11 |
| P2026-0180 | Stage division 消融显示 `T/3` 虽 HV 可好但仍会落入 small model trap，作者最终选择 `T/2` 作为时间、收敛和多样性的折中 | 参数消融 | Sec. IV-E，Fig. 10，Table VI，PDF 12 |
| P2026-0180 | CIFAR10 和 ImageNet 实验显示 MO-TS-BNAS 一次搜索得到多个不同规模 BNN，搜索时间约 0.26 GPU day | 综合实验支持 | Sec. IV-B-D，Tables II-III，PDF 8-10 |

## 证据边界

- 当前证据来自单篇 BNN NAS 论文，且与 binarized search space、ApproxSign training、path dropout 和 improved mini-batch evaluation 共同作用。
- Markdown 中核心辅助目标公式为图片占位，公式按正文数值例子记录；复现前应以 PDF 原公式为准。
- 实验主要验证 CIFAR10 搜索和 ImageNet 迁移，没有在普通 CNN NAS、真实硬件 latency 或非视觉 NAS 上验证。
- 作者指出搜索阶段和重建阶段的规模关系可能不一致，这限制了资源目标的直接可靠性。
- HV 并不能充分代表模型规模多样性；论文也显示 `T/3` 可有较好 HV 但仍不适合迁移。

## 待确认

- 辅助目标是否应固定为乘积形式，还是应改为 rank-based、log-size、uncertainty-aware 或 learned compensation；
- 资源目标的归一化边界如何设置，尤其是动态搜索空间或多硬件平台场景；
- 阶段切换点能否由超网训练稳定性、大模型存活率或资源覆盖自动决定；
- 在非 BNN NAS 中，slow-start 是否同样主要由模型大小导致，还是由操作类型、深度、训练曲线或数据增强造成；
- 如何与复杂度分组 archive、多保真重评和真实硬件测量结合，避免保留大模型但最终部署收益不足。
