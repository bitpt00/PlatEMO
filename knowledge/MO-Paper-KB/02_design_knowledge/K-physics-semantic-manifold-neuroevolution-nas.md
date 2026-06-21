---
knowledge_id: K-physics-semantic-manifold-neuroevolution-nas
name: 物理语义-流形联合编码的神经演化 NAS
type: architecture
status: active
source_papers: [P2026-0274]
aliases: [Evo-ManiEarth, multi-objective neuroevolution for physical dynamics, physics semantic NAS, LLM physical semantic gate, manifold-FNO NAS, spectral-manifold hybrid operator search, gamma_LLM, scientific model NAS, 物理语义NAS, 流形FNO搜索, 多目标神经演化科学模型搜索]
promotion_reason: 单篇论文提出但接口明确，包含可进化 LLM 物理语义门控、流形维度、FNO 层数/频率模态、通道和学习率的联合编码，并以 RMSE-FLOPs Pareto 搜索、物理一致性指标、预算公平搜索比较和 prompt 鲁棒性消融支撑，可直接迁移到科学机器学习、神经算子搜索和多模态时空模型设计。
---

# 物理语义-流形联合编码的神经演化 NAS

## 核心内容

在科学机器学习或物理动力学预测中，把“领域物理语义如何注入模型”本身纳入 NAS/神经演化搜索空间，而不是只调网络深度、宽度或 loss 权重。一个候选模型同时编码：

- 物理文本语义分支，例如方程、边界条件、外力、参数 prompt 经 LLM embedding 后的融合强度；
- intrinsic representation 分支，例如 manifold dimension；
- operator backbone 分支，例如 FNO 层数、频率模态和通道宽度；
- optimization/deployment 参数，例如学习率、FLOPs、latency 或 rollout 稳定性。

```text
physical text: equation / boundary / forcing / parameters
-> deterministic LLM semantic embedding
-> spatial adapter and evolvable semantic gate gamma

video or field state
-> encoder
-> evolvable manifold bottleneck d'
-> concatenate gated physical semantics
-> operator blocks, e.g., FNO layers and Fourier modes
-> decoder
-> evaluate RMSE + cost + optional physical metrics
-> multi-objective search returns Pareto model family
```

## 建立理由

- 为什么值得独立维护：
  - 许多科学模型设计的关键不只是网络 topology，而是物理知识以什么形式、什么强度、在什么层级进入模型；
  - 物理文本、流形维度和神经算子结构存在耦合，手工逐项调参难以找到 accuracy-efficiency-physical-consistency 折中；
  - 将语义 gate、流形瓶颈和 operator 参数一起进化，可以输出适配不同预算的模型族。
- 单篇具体方法的直接复用价值：
  - P2026-0274 给出 6 维 genome、NSGA-II 搜索、Evo-ManiEarth forward path、RMSE/FLOPs Pareto 前沿、物理指标、长期 rollout、预算公平搜索对比和 prompt perturbation 消融。
- 与已有设计知识的区别：
  - 不同于“LLM 提示的动态种群时间序列预测”：该知识让 LLM 预测 DMOP 下一环境初始种群；本知识让 LLM 物理语义成为被搜索模型的一部分。
  - 不同于“物理约束晶体编码与结构知识迁移”：该知识搜索晶体结构并迁移空间群/基位点；本知识搜索物理预测神经模型的语义-流形-算子结构。
  - 不同于“复杂度分组的目标子空间排序”和“复杂度均匀采样的双种群 NAS 搜索”：这些知识主要改变 NAS 的选择、初始化或资源覆盖；本知识定义科学模型的多模态搜索空间。
  - 不同于“结构保真的架构编码与修复”：该知识保护 topology backbone；本知识将领域语义与 intrinsic dynamics representation 一并编码。

## 解决的问题

- 适用场景：
  - PDE/ODE/天气/流体/材料过程/工业过程等有物理方程、边界条件、守恒律或领域文本规则的时空预测；
  - 模型需要同时优化预测误差和计算成本；
  - operator learning、FNO、Transformer、CNN 或混合科学模型中存在多个强耦合架构超参数；
  - 物理知识可以被稳定文本化，并能在训练/推理阶段缓存或验证。
- 现有方法为什么会失败或不足：
  - 只用物理 residual loss 可能受 loss imbalance、方程不完整和优化困难影响；
  - 只做 topology NAS 无法回答物理语义是否应注入、注入多强、在哪个 latent 层注入；
  - 只调 FNO 深度或频率模态，容易忽略 latent intrinsic dimension 和语义正则之间的协同；
  - 单一最优模型无法满足不同设备或应用对精度/速度/稳定性的不同偏好。
- 仍需解决的问题：
  - 错误或过时物理 prompt 会被模型认真利用，导致性能退化；
  - LLM embedding 的版本和 prompt 模板影响可复现性；
  - 高成本短训评价限制搜索规模；
  - 物理指标若只后验评估，搜索可能仍偏向像素级误差。

## 为什么可能有效

```text
physical dynamics have low-dimensional attractors and symbolic constraints
-> manifold bottleneck approximates intrinsic coordinates and reduces noise/cost
-> LLM prompt branch injects equation/boundary/forcing semantics
-> FNO captures spectral evolution in latent coordinates
-> evolvable gate and architecture genes tune the balance for each PDE family
-> MOO returns models along accuracy-cost trade-off, not a brittle single design
```

关键假设是：物理文本描述包含真实有用的约束信息，且模型的空间/频域 representation 能接收这些语义先验。如果方程错误、边界条件遗漏、系统由未知外力主导，或数据分布与 prompt 不一致，语义分支会带来负迁移。

## 实现接口

- 输入：
  - 时空 field/video 数据；
  - 可文本化物理描述：governing equation、boundary conditions、external force、physical parameters；
  - 可实例化的 operator backbone，例如 FNO、Neural Operator、ConvNet、Transformer；
  - search budget 与候选短训策略；
  - cost metric，例如 FLOPs、latency、memory、energy。
- 输出：
  - Pareto model set；
  - 每个候选的 semantic gate、manifold dimension、operator depth/modes/channels；
  - RMSE/cost 与可选物理一致性指标；
  - prompt/LLM embedding 缓存和鲁棒性日志。
- 插入位置：
  - scientific-model NAS；
  - neural operator architecture search；
  - physics-informed surrogate model design；
  - 多设备/多预算模型池生成；
  - 需要 LLM 语义先验但又不想固定注入强度的模型压缩或部署搜索。

P2026-0274 的默认实例：

```text
genome g = (d', L_FNO, C_enc, k_max, alpha_lr, gamma_LLM)
d' in {8,16,32,64,128,256}
L_FNO in {2,3,4,5,6,8}
C_enc in {16,32,64,128}
k_max in {8,12,16,20,24}
alpha_lr in [1e-4,1e-2]
gamma_LLM in [0,1]

objectives:
    f1 = validation RMSE
    f2 = analytical FLOPs

search:
    NSGA-II
    population = 40
    generations = 50
    short training = 30 epochs
    final top-5 Pareto individuals retrained
```

## 如何用于算法创新

### 局部创新

- 把 divergence、mass error、energy-spectrum error 或 rollout growth rate 从后验报告改为搜索目标或约束。
- 让 prompt type、adapter depth、fusion layer 和 LLM model 也成为 gene。
- 加入 prompt provenance score：物理文本置信度低时，自动降低 `gamma_LLM` 或要求人工校验。
- 对 `d'`、`L_FNO` 和 `k_max` 使用耦合变异，避免低维 bottleneck 搭配过多高频模态。
- 用 multi-fidelity 评价：短训先筛 RMSE/FLOPs，再对少量候选测长期 rollout 和物理一致性。
- 将 NSGA-II 替换或集成为 MO-TPE、qEHVI、SA-MOEA、regularized evolution 或 surrogate-assisted search。

### 结构创新

- 构建科学模型三层 genome：

```text
domain semantics layer:
    prompt fields, LLM embedding, semantic gate, safety/provenance
intrinsic dynamics layer:
    manifold dimension, latent coordinates, operator block, spectral modes
deployment layer:
    FLOPs, latency, memory, rollout stability, physical metric constraints
```

- 为不同 PDE family 维护可迁移的 architecture prior，例如 diffusion-dominated 系统偏小 `d'`/浅 FNO，turbulence 系统偏深 operator 和更高语义门控。
- 与模型池部署结合：保留 high-accuracy、balanced、high-efficiency 三类 Pareto 模型，按设备预算或场景风险切换。
- 与自动科学发现结合：把候选方程项、边界描述或守恒律 prompt 也纳入搜索，寻找对预测最关键的物理语义。

## 适用条件与风险

- 适用条件：
  - 物理规则可以被可靠文本化；
  - 候选模型训练和 FLOPs/latency 估计可自动化；
  - 有足够预算进行短训搜索；
  - 需要模型族而不是单个模型；
  - 物理一致性可用低成本指标或后验高保真测试衡量。
- 不适用或可能失效的条件：
  - 方程未知且无法可靠描述，LLM 分支只能产生弱或错误先验；
  - 物理 prompt 与数据生成过程冲突；
  - 任务需要严格实时搜索或频繁重新搜索；
  - LLM 服务不可缓存、不可复现或不允许外部调用；
  - 搜索目标只含 RMSE/FLOPs，可能忽略真实部署中的稳定性、安全和物理守恒。
- 计算与实现成本：
  - 需要为每个候选实例化并短训模型；
  - LLM embedding 可以缓存，但 prompt 管理、版本固定和 adapter 训练仍增加工程复杂度；
  - 大规模搜索需要 GPU 预算和严谨的 evaluation bookkeeping。
- 解释风险：
  - 搜索空间、模型组件和搜索算法共同贡献性能，不能把收益全部归因于 LLM 或 NSGA-II；
  - 若 prompt 错误也会影响输出，说明语义通路有效，同时也说明部署时必须校验语义来源。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0274 | 作者指出手工设计 multimodal physical dynamics model 的架构和参数空间巨大，难以平衡精度、效率和泛化 | 问题动机 | Sec. I，PDF 1 |
| P2026-0274 | Genome `g=(d',L_FNO,C_enc,k_max,alpha_lr,gamma_LLM)` 联合编码流形维度、FNO 层数、通道、频率模态、学习率和 LLM 门控 | 作者提出的方法 | Sec. III-A，PDF 3-4 |
| P2026-0274 | Objectives 为 validation RMSE 和 analytical FLOPs；population 40、generations 50、总 2000 evaluations，top-5 Pareto 个体 full retraining | 作者提出的方法/实验设置 | Sec. III-A，PDF 3 |
| P2026-0274 | Forward path 为 Conv2d encoder -> manifold `phi` -> 与 `gamma_LLM F_LLM` 拼接 -> FNO blocks -> decoder；LLM prompt 分支经 depth-wise Conv2d adapter | 作者提出的架构 | Fig. 1、Sec. III-B，PDF 4-6 |
| P2026-0274 | Navier-Stokes Pareto 示例中 balanced Evo-ManiEarth 为 RMSE `0.2465`、FLOPs `571.4M`、`d'=64`、4 FNO layers、32 channels | Pareto 前沿证据 | Sec. IV-C、Table I，PDF 7-8 |
| P2026-0274 | Evo-ManiEarth 在 SEVIR/Kuroshio/Typhoon 和四个已知方程数据上均取得最低 RMSE，如 Diffusion-Reaction `0.0007`、Navier-Stokes `0.2465` | 综合实验支持 | Sec. IV-D、Table II，PDF 8-9 |
| P2026-0274 | 效率比较中 Navier-Stokes 上 Evo-ManiEarth FLOPs `571.42M`、参数 `0.84M`，低于 FNO 的 `743.15M`、`38.71M` | 效率证据 | Sec. IV-E、Table III，PDF 8-9 |
| P2026-0274 | 物理指标上 Evo-ManiEarth 在 Navier-Stokes divergence `4.51e-4`、energy spectrum error `0.0314`，在各 synthetic benchmark 指标最好 | 物理一致性证据 | Sec. IV-F、Table IV，PDF 9-10 |
| P2026-0274 | LLM 消融显示 full prompt RMSE `0.2465`、divergence `4.51e-4`，优于 no physical features、one-hot+MLP、manual structured params 和 partial prompts | 消融证据 | Sec. IV-H/N、Tables V/X，PDF 10-13 |
| P2026-0274 | 长期 autoregressive rollout 到 step 50 时 Evo-ManiEarth RMSE `0.6845`，FNO `1.3421`，ResNet unstable | 稳定性证据 | Sec. IV-K、Table VII，PDF 11-12 |
| P2026-0274 | Budget-fair search comparison 中 NSGA-II/Ours HV `0.572`，高于 Random Search、MO-TPE、qEHVI 和 SA-MOEA；optimized FNO 仍弱于 Evo-ManiEarth | 搜索公平性支持 | Sec. IV-M、Tables VIII-IX，PDF 12 |
| P2026-0274 | Prompt perturbation 中 semantic rewrite/variable renaming 影响小，scrambling 和 wrong-equation 分别导致约 14% 和 31% RMSE 退化 | LLM 语义有效性证据 | Sec. IV-O-P、Table XI，PDF 13 |

## 证据边界

- 当前证据来自单篇论文，且搜索空间、模型组件、训练策略和 NSGA-II 共同作用。
- 完整搜索成本较高，论文报告约 280 A100-hours per benchmark。
- 部分表格和公式在 Markdown/OCR 中混排，精确数值应以 PDF 为准。
- LLM 使用固定 GPT-4o-mini、temperature 0 和缓存策略，跨模型/版本/离线 LLM 的稳定性仍需验证。
- 实验主要面向物理动力学和天气预测，不代表普通视觉 NAS 或无物理语义任务。

## 待确认

- 物理指标直接加入搜索目标是否优于后验报告；
- `gamma_LLM`、`d'`、`L_FNO` 在不同 PDE family 中是否存在可迁移规律；
- cross-attention、FiLM 或 physics-token conditioning 是否优于 depth-wise Conv2d adapter；
- 如何自动发现错误或冲突的物理 prompt；
- 在多分辨率、缺测、观测噪声和真实在线预报场景下是否保持稳定；
- 如何用更低成本的 multi-fidelity/surrogate search 替代完整短训搜索。
