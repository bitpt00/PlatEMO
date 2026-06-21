---
knowledge_id: K-risk-prompt-sparse-expert-routing
name: 风险提示驱动的稀疏专家路由
type: architecture
status: active
source_papers: [P2026-0056]
aliases: [ROJS-Net, mutual risk prompt learning, MRPL, multi-gate mixture of experts, sparse top-K expert routing, prompt-guided MoE, risk-optimized joint segmentation, 互风险提示, 稀疏专家门控]
promotion_reason: 单篇论文提出但结构接口完整，包含 shared encoder、learnable universal prompt、task-specific prompt split、top-K sparse gated expert decoders、预训练与消融证据，可直接迁移到多任务/多目标神经模型的冲突缓解和条件化专家选择层。
---

# 风险提示驱动的稀疏专家路由

> 建立本卡前，已用 prompt、mixture/expert、gating/top-K、risk-aware、medical/segmentation 等关键词检索现有设计知识。相近条目包括 LLM prompt 动态响应、物理语义 prompt、top-K sparse attention、MOEA expert imitation 等，但这些卡的 prompt 来源、路由对象和解决的问题不同，未发现重复卡。

## 核心内容

当多个相关任务或目标共享输入表征但优化方向存在冲突时，不只用固定权重或固定多头输出处理冲突，而是在共享表征上生成任务/风险/偏好 prompt，再由 prompt 条件化地激活少量专家模块。典型流程是：

shared feature + learnable/global prompt -> task-specific prompt split -> prompt + shared feature -> sparse gate -> top-K experts -> weighted task output。

prompt 负责把当前样本的任务关系、风险优先级或场景偏好显式送入路由器；稀疏专家池负责提供不同参数子空间，让不同任务或目标在冲突区域使用不同专家组合。

## 建立理由

- 为什么值得独立维护：该知识提供了一个清晰的“风险/偏好上下文 -> 专家路径选择”的架构接口，可用于改造多任务分割、神经 surrogate、多目标策略网络、learned offspring generator 或多目标控制模型。
- 单篇具体方法的直接复用价值：P2026-0056 给出公式(1)-(6)、Fig. 3-6、top-K gate、四专家 decoder、预训练流程、三数据集主实验和两组消融，说明 MRPL 与 MMOE 可以作为可插拔模块测试。
- 与已有设计知识的区别：
  - 不同于 LLM prompt 动态种群预测：本知识的 prompt 是可学习张量/特征 prompt，不是文本 prompt，也不直接预测新环境种群。
  - 不同于物理语义-流形 NAS：本知识不把自然语言物理语义接入 FNO/NAS，而是把任务风险提示接入 expert routing。
  - 不同于稀疏注意力 Actor-Critic：本知识稀疏的是专家路径，不是 task-resource attention 边。
  - 不同于非支配解模仿学习的参数化 MOEA：本知识的 expert 是网络功能模块/decoder，不是多个 MOEA 的解集蒸馏。

## 解决的问题

- 适用场景：多任务或多目标神经模型中，任务共享输入/底层结构，但在局部样本、场景或偏好下需要不同参数路径；例如肿瘤/OAR 联合分割、同时优化精度-安全-成本的控制网络、多目标 surrogate、多任务约束预测或偏好条件策略。
- 现有方法为什么会失败或不足：固定共享 encoder-decoder 会产生任务干扰；单独模型缺少互补信息；共享 encoder 加固定任务 decoder 仍不能根据当前样本动态分配共享/专属参数；只调 loss 权重不能保证特征路径和参数路径随风险场景改变。
- 仍需解决的问题：prompt 中“风险/偏好”是否真实可解释；gate 学到的专家分工是否稳定；专家数和 top-K 如何自适应；如何与显式约束、Pareto 偏好或决策者偏好联动。

## 为什么可能有效

共享表征保留任务间可复用信息，task-specific prompt 把任务差异和场景上下文注入后续路由；通道拆分或其他 disentanglement 机制减少不同任务梯度互相覆盖；top-K 稀疏 gate 让每个任务只使用少量专家，既增加专属参数容量，又限制过拟合和计算开销；预训练 prompt/encoder 可以先学习通用结构先验，再在下游任务中适配风险优先级。

## 如何用于算法创新

### 局部创新

- 在多任务神经网络中，把固定 decoder head 替换为 prompt-guided sparse MoE head。
- 在多目标 surrogate-assisted optimizer 中，为不同目标、约束、参考方向或偏好区域设置专家 surrogate，用问题状态 prompt 选择 top-K。
- 在 learned offspring generator 或 DRL operator selector 中，将目标冲突特征、可行性状态、偏好向量或风险指标编码为 prompt，再控制生成专家/算子专家的激活。
- 把固定 `K` 改为由不确定性、任务冲突度或资源预算控制的 adaptive-K。

### 结构创新

- 构建“共享感知层 -> 风险/偏好 prompt 层 -> 稀疏专家池 -> 多目标输出/选择层”的通用架构，把多目标冲突从 loss 层前移到表示和参数路由层。
- 将 MOEA 的多个算子、局部搜索器、代理模型或约束处理器视为 expert，由场景 prompt 和搜索状态 gate 动态路由，形成可解释的混合专家优化器。
- 在交互式或偏好驱动 MOO 中，让决策者偏好作为 prompt 影响专家选择，而不是只在最终选解或标量化函数中使用。

## 适用条件与风险

- 适用条件：
  - 任务/目标之间既有共享信息又有局部冲突；
  - 输入特征或外部变量能提供足够的场景、风险或偏好线索；
  - 数据量或预训练资源足以训练 prompt 和专家路由；
  - 目标应用允许一定额外参数和推理成本。
- 不适用或可能失效的条件：
  - 任务完全无关，强行共享会引入负迁移；
  - 风险/偏好信息不可观测，prompt 只能学到数据集偏差；
  - 训练数据太少导致专家塌缩到少数路径；
  - 需要严格可证明约束满足，而隐式 prompt 只能软调节优先级。
- 计算与实现成本：
  - 需要维护多个专家模块和 gate，参数、显存和 FLOPs 高于普通多头网络；
  - 需要记录 gate 权重、专家使用率和任务/目标表现，避免专家长期闲置或过载；
  - 若用于 MOEA 内环，需要控制专家前向调用开销，必要时缓存 prompt 或使用轻量专家。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0056 | ROJS-Net 由一个共享 encoder、四个 expert decoders、两个任务 gate 和 mutual risk prompt module 组成；prompt 与共享特征融合后拆分为 `P_oars/P_tumor` | 作者提出的架构 | Sec. 2.1-2.3、Fig. 3-5、公式(1)，PDF 3-4 |
| P2026-0056 | 作者明确说明当前 risk 是肿瘤分割与 OAR 勾画之间的任务依赖解剖取舍，而非显式临床风险分数 | 机制定义/边界 | Sec. 2.3，PDF 5 |
| P2026-0056 | Gate 使用 noisy top-K sparse MoE，`K=2`，输出为 expert decoder 的 gate-weighted sum；作者用 Softplus 和 top-K 促进可微路由、专家专化和负载平衡 | 作者提出/采用的方法 | Sec. 2.4、公式(2)-(6)，PDF 5 |
| P2026-0056 | 三个数据集上 ROJS-Net 在 tumor/OAR 的 DSC、HD95、ASD 整体优于 3D UNet、VNet、Attention UNet、TransUNet、SwinUNETR 和 UNETR++ | 综合实验支持 | Sec. 3.5-3.7、Tables 1-3，PDF 7-10 |
| P2026-0056 | 在 UNet、TransUNet 和本文 backbone 上分别加入 MMOE/MRPL 均带来不同程度提升，二者合用通常最好 | 模块消融支持 | Sec. 3.8、Tables 4-6，PDF 11-12 |
| P2026-0056 | Shared、multi-task、independent、multi-task+MMOE、ROJS-Net 五种结构消融显示 ROJS-Net 最优；作者认为 prompt+MMOE 缓解了 tumor/OAR 优化冲突 | 架构消融支持 | Sec. 3.9、Fig. 10、Tables 7-9，PDF 12-13 |
| P2026-0056 | 作者指出隐式 prompt 只部分缓解冲突，未来需加入肿瘤性质、复发/转移、剂量、距离、器官损伤等显式风险因素 | 作者局限与未来工作 | Discussion，PDF 14-15 |

## 待确认

- prompt-guided expert routing 在非医学影像、多目标 surrogate 或 MOEA 算子调度中是否仍有效；
- 是否应加入 gate 负载均衡损失、专家多样性损失或显式任务冲突指标；
- 显式风险/偏好 prompt 与隐式可学习 prompt 如何组合才最稳定；
- adaptive expert count、adaptive top-K 与固定 `K=2` 的性能和成本边界。
