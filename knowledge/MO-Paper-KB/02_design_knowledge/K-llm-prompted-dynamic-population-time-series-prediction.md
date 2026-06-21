---
knowledge_id: K-llm-prompted-dynamic-population-time-series-prediction
name: LLM 提示的动态种群时间序列预测
type: architecture
status: active
source_papers: [P2026-0207]
aliases: [LLM-DMOEA, LLM-driven dynamic multiobjective optimization, prompt-based dynamic response, LLM population prediction, CoT dynamic POS prediction, probability density prompt, 动态多目标LLM预测, 提示式动态响应, LLM种群重初始化]
promotion_reason: 单篇论文提出但接口完整，包含历史非支配解文本化、scaling/quantization、个体级与分布级两类 data processor、四类 prompt、LLM 预测新环境初始种群、可接入不同 MOEA solver，并在 expensive/large-scale DMOP、跨 solver、跨 LLM 和动态图公平调试案例上给出证据
---

# LLM 提示的动态种群时间序列预测

## 核心内容

把 DMOP 环境变化后的 population prediction 看作时间序列预测任务。每次环境变化后，将最近若干环境的非支配解或其分布统计量转成紧凑文本，交给 LLM 预测下一环境的初始种群或 POS 分布，再用普通 MOEA 在新环境中精修。

```text
recent nondominated populations
-> scale and quantize numerical values
-> choose representation:
   individual chromosomes
   or Gaussian mean / variance statistics
-> prompt LLM for next environment
-> parse predicted individuals or sample predicted distribution
-> initialize MOEA in new environment
-> refine and store new nondominated set
```

## 建立理由

- 为什么值得独立维护：
  - 传统 prediction-based DMOEA 往往需要为每个问题训练回归、神经网络或 surrogate；
  - 昂贵 DMOP 历史样本少，大规模 DMOP 输入维度高，专用模型的训练和调参成本高；
  - LLM 可作为训练外的通用预测器，通过 prompt 复用时间序列推理能力；
  - 该设计把 LLM 限制在“变化响应/初始种群预测”环节，便于与已有 MOEA solver 拼接。
- 单篇具体方法的直接复用价值：
  - P2026-0207 给出 Algorithm 1-2、两类 data processor、四类 prompts、Gemini/DeepSeek 实验、RM-MEDA/MOEA/D 接入、expensive/large-scale DMOP 证据和动态图公平调试应用。
- 与已有设计知识的区别：
  - 不同于“向量自回归降维动态响应”：该知识训练 PCA+VAR 显式时间序列模型；本知识用 LLM prompt 做少样本预测。
  - 不同于“二阶导数双域自适应动态预测”：该知识手工计算 PS/PF 二阶变化；本知识通过 CoT prompt 让 LLM 推理趋势。
  - 不同于“可执行测试修复的 LLM 算法代码进化”：该知识让 LLM 生成算法程序；本知识让 LLM 生成新环境候选种群或分布统计。
  - 不同于“LLM 语义辅助的多目标推荐演化搜索”：该知识用于推荐语义和 score correction；本知识面向动态优化中的时间序列 population prediction。

## 解决的问题

- 适用场景：
  - DMOP 相邻环境有历史相关性；
  - 环境变化后需要快速生成较好初始种群；
  - 历史数据少，不足以训练可靠专用预测模型；
  - 希望预测模块能接入不同 population-based MOEA；
  - 可以承受一定 LLM inference latency。
- 现有方法为什么会失败或不足：
  - 随机注入只恢复多样性，不利用历史趋势；
  - memory replay 对非周期变化可能过时；
  - 回归/NN/surrogate 预测器需要模型设计、训练数据和超参数；
  - 大规模 DMOP 中直接喂个体序列会产生过长输入。
- 仍需解决的问题：
  - LLM 调用成本和网络延迟可能不适合严格实时场景；
  - 高维个体级输入 token 过长；
  - LLM 输出需要解析、边界修复、约束检查和多样性校验；
  - 单高斯分布不能表达复杂多峰或不连续 POS。

## 为什么可能有效

```text
dynamic POS often has temporal pattern
-> recent nondominated populations encode movement
-> LLM can do few-shot sequence extrapolation
-> prompt avoids training a new predictor
-> predicted population starts closer to new POS
-> MOEA spends fewer evaluations recovering after change
```

关键假设是：历史环境中的 POS 变化包含可外推模式，且文本化/量化不会丢失关键动态信息。若新环境的变化规则突变、PF 从连续变为不连续，或历史 pattern 失效，LLM 外推会误导初始化。

## 实现接口

- 输入：
  - DMOP objective function `F(x,t)`；
  - 静态或动态 MOEA solver；
  - 最近 `w` 个环境的 nondominated solutions；
  - prompt type；
  - scaling/quantization 精度；
  - LLM 配置，如 model、temperature、timeout。
- 输出：
  - 下一环境的 predicted initial population；
  - 可选 predicted mean/variance；
  - LLM response、parse errors、latency 和 validation 日志。
- 插入位置：
  - environment change response；
  - population reinitialization；
  - expensive DMOP 的少评价 warm start；
  - large-scale DMOP 的分布统计预测。
- 最小实现：

```text
for each environment t:
    POS_t <- MOEA(F(x,t), Popinit)
    store POS_t

    if t < w:
        Popinit <- random_population()
    else:
        H <- recent POS_{t-w+1:t}
        if prompt in {individual, problem-informed}:
            text <- scale_quantize_individuals(H)
            response <- LLM(prompt, text)
            Popinit <- parse_rescale_individuals(response)
        else:
            stats <- Gaussian_mean_variance(H)
            text <- scale_quantize_stats(stats)
            response <- LLM(prompt, text)
            mu, sigma2 <- parse_rescale_stats(response)
            Popinit <- sample_population(mu, sigma2)
```

P2026-0207 的具体设置：

- 默认 window size `w=5`；
- Prompt 1/2 使用个体级非支配解；
- Prompt 3/4 使用每个环境 POS 的 Gaussian mean 和 diagonal variance；
- Expensive DMOP：`N=10`，decision dimension 10；
- Large-scale DMOP：`N=50`，decision dimension 100；
- 默认 LLM 为 Gemini 1.5 Flash，temperature `1`；
- 跨模型验证使用 DeepSeek-V3。

## 如何用于算法创新

### 局部创新

- 用 PCA、autoencoder、random projection 或 reference-direction grouping 压缩 POS 后再 prompt。
- 把单 Gaussian 改成 mixture of Gaussians，按 PS cluster 或 reference direction 分别预测。
- 设计 constrained output schema，强制 LLM 输出 JSON/CSV，并附带边界、类型和数量校验。
- 在 prompt 中加入上一环境预测误差，让 LLM 进行自校正。
- 根据 token length 和历史拟合误差自动选择 Prompt 1/3/4。
- 对生成 population 先做 cheap surrogate screening，再进入真实 MOEA 评价。

### 结构创新

- 构建 LLM-DMOEA 安全响应层：

```text
change detector
-> history compressor
-> prompt selector
-> LLM predictor
-> parser / repair / validator
-> diversity and feasibility filter
-> MOEA refinement
-> prediction error memory
```

- 与动态预测模型集成：LLM、VAR、Kalman、GP、autoencoder 各自产生候选，环境状态或小预算 probe 决定保留比例。
- 与代理辅助 DMOP 结合：LLM 预测只给 warm start，surrogate 负责筛掉明显差或不可行候选。
- 与人机交互结合：决策者偏好或业务事件可写入 prompt，生成偏好区域内的动态初始种群。

## 适用条件与风险

- 适用条件：
  - 环境变化存在可学习趋势；
  - 历史非支配解质量较稳定；
  - LLM latency 相对一次环境搜索预算可接受；
  - 候选解可被可靠解析和修复；
  - 有静态 solver 对 LLM 预测结果做后续校正。
- 不适用或可能失效的条件：
  - 环境变化突变且历史规律失效；
  - PF/POS 强不连续、多峰，而 prompt 只给单一分布统计；
  - 决策变量高维且无法压缩，token length 过长；
  - 强约束或离散组合空间中 LLM 输出大量不可行解；
  - 真实系统要求毫秒级响应或不能访问外部 LLM 服务。
- 计算与实现成本：
  - 数据处理为 `O(N)`；
  - LLM 推理约为 `O(L^2)`，并有网络 latency；
  - P2026-0207 中 100 维 Prompt 1/2 的时间超过 13 秒，分布型 Prompt 3/4 也约 6 秒量级。
- 解释风险：
  - 实验优势来自 LLM predictor、prompt、量化、solver 和后续 MOEA refinement 的组合；
  - LLM 版本、temperature 和服务延迟会影响可复现性；
  - 论文属于 preliminary case study，尚不是成熟通用 DMOP solver。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0207 | 作者指出 prediction-based DMOEA 低数据效率和低模型可用性限制 expensive/large-scale DMOP | 动机分析 | Sec. I，PDF 1-2 |
| P2026-0207 | LLM-DMOEA 将 LLM 作为 dynamic response handler，在检测环境变化后根据前 `w` 个环境非支配解生成新环境初始种群 | 作者提出的方法 | Sec. III、Fig. 1，PDF 3-4 |
| P2026-0207 | Prompt 1/2 通过 scaling 和 quantization 将历史非支配个体转成文本，LLM 响应可解释为 individuals | 作者提出的方法 | Sec. III-A-B、Algorithm 1，PDF 4-5 |
| P2026-0207 | Prompt 3/4 将历史 POS 建模为 Gaussian mean/variance 序列，由 LLM 预测下一环境分布后采样 population | 作者提出的方法 | Sec. III-A-B、Algorithm 2，PDF 4-6 |
| P2026-0207 | Prompt 4 使用 CoT 引导 LLM 分步分析均值和方差的时间变化 | 作者提出的方法 | Sec. III-B，Fig. 5，PDF 6-7 |
| P2026-0207 | LLM-DMOEA 数据处理复杂度 `O(N)`，LLM 推理复杂度由 Transformer self-attention 主导为 `O(L^2)` | 复杂度分析 | Sec. III-C，PDF 7 |
| P2026-0207 | Expensive DMOP 中 LLM-RM-MEDA 在 DF3/4/7/8/11/14 的所有动态参数设置下优于对比算法 | 综合实验支持 | Sec. IV-B、Table I，PDF 7-8 |
| P2026-0207 | LLM-RM-MEDA 在 MHV 上取得 20 个最佳 case，而 DIP/Tr/RI/KT/KTM/IB-RM-MEDA 分别为 1/10/0/3/1/7 | 综合实验支持 | Sec. IV-B，PDF 7 |
| P2026-0207 | Large-scale DMOP 中 LLM-RM-MEDA 取得 15 个最低 MIGD 和 16 个最高 MHV，但长 token 序列造成性能损失 | 综合实验/成本边界 | Sec. IV-B，PDF 7-8 |
| P2026-0207 | 接入 MOEA/D 后，LLM-MOEA/D 在 expensive DMOP 中取得 16 个最佳 MIGD，并在 large-scale DMOP 中取得 15 个最低 MIGD 和 13 个最高 MHV | 跨 solver 支持 | Sec. IV-B，PDF 8 |
| P2026-0207 | Prompt 2 通常弱于 Prompt 1，作者认为复杂数学公式不易被 LLM 理解；DF1 公式较简单时 Prompt 2 最好 | Prompt 对比/机制分析 | Sec. IV-C，PDF 9 |
| P2026-0207 | 高维问题中 Prompt 3/4 明显优于个体级 Prompt 1/2，Prompt 4 因 CoT 在高维中取得 28 个最佳 case | Prompt 对比/机制分析 | Sec. IV-C，PDF 9 |
| P2026-0207 | DeepSeek-V3 实验中 LLM-RM-MEDA 仍取得 19 个最优 MIGD 和 17 个最优 MHV，但表现受 LLM 选择影响 | 跨模型支持 | Sec. IV-E，PDF 10 |
| P2026-0207 | 动态公平调试应用中，LLM-GCN 将 ACC 从 72.59% 提升到 73.20%，`Delta_SP` 从 4.27% 降到 2.44%；LLM-FairGCN 也同时提升 accuracy 与 fairness | 真实应用支持 | Sec. IV-F，PDF 10 |
| P2026-0207 | 100 维时四类 prompt 时间约为 13.83/16.64/5.95/6.47 秒，且 prompt 为人工设计 | 作者局限 | Sec. IV-G，PDF 10 |

## 证据边界

- 当前只有单篇论文证据。
- 主文许多完整 MIGD/MHV 表在 supplementary，卡片只记录正文给出的汇总。
- 默认实验使用商业/在线 LLM，版本、温度、网络延迟和服务策略可能影响可复现性。
- DF9/DF12/DF13 等不连续/gapped POF 问题暴露了平滑分布预测的局限。
- 真实应用只验证 NBA 动态公平调试，其他工程 DMOP 仍需更多案例。

## 待确认

- 如何自动选择 prompt type、window size 和压缩方式。
- 如何让 LLM 输出满足边界、约束、离散性和多样性要求。
- 多峰或不连续 POS 是否应使用 mixture/cluster prompt。
- LLM predictor 与传统 VAR/Kalman/GP/autoencoder predictor 的混合集成如何分配候选比例。
- 如何在不依赖闭源模型和在线服务的情况下保证可复现与低延迟。
