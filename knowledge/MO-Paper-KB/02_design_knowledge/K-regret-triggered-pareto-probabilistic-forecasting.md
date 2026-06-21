---
knowledge_id: K-regret-triggered-pareto-probabilistic-forecasting
name: Regret 触发的 Pareto 概率预测
type: architecture
status: active
source_papers: [P2026-0044]
aliases: [NA-TP Forecasting, AOPF, regret-triggered online forecasting, Pareto probabilistic forecasting, QR-AEP, Q-Risk, PIW, MOTPE forecasting, 概率预测三目标优化, 在线负荷预测, 校准-锐度-Pinball Pareto]
promotion_reason: 单篇论文提出但接口完整，包含因果特征筛选、Transformer 概率预测、loss z-score 动态更新阈值、dynamic local regret 在线更新、QR-AEP/Q-Risk/PIW 三目标 Pareto 操作层，可迁移到负荷、风光功率、需求和流量等在线概率预测任务。
---

# Regret 触发的 Pareto 概率预测

## 核心内容

把在线概率预测系统拆成两层：底层模型只在 streaming loss 显著偏离近期基线且 dynamic local regret 指示需要适应时更新；上层用多目标优化维护预测准确性、概率校准和区间锐度之间的 Pareto 折中。这样部署时不是固定一个“最佳”预测器，而是给运行人员提供多个可解释操作点，例如更稳的校准、更窄的区间或更低的分位误差。

```text
candidate exogenous signals
-> stationarity check + causal feature screening
-> probabilistic sequence model
-> streaming loss, z-score, dynamic local regret
-> trigger sparse online update only when sustained drift appears
-> tri-objective optimization: quantile accuracy / calibration / interval width
-> Pareto operating points for risk-aware deployment
```

P2026-0044 的 NA-TP 是该模式的实例：Granger causality 选择负荷外生特征，Transformer 输出 MLE 或 quantile 预测，AOPF 用 loss z-score 和 DLR 触发在线更新，MOTPE 近似 QR-AEP、Q-Risk 和 PIW 的 Pareto set。

## 建立理由

- 为什么值得独立维护：
  - 很多在线预测系统只优化点误差或单一概率损失，不能同时解释 calibration 与 sharpness；
  - 固定窗口更新会浪费计算，或在概念漂移时反应过慢；
  - 操作系统通常需要按风险偏好选择预测区间，而不是接受唯一模型配置；
  - 将 update trigger 与 Pareto operating point 分离，能同时控制实时成本和预测风险。
- 单篇具体方法的直接复用价值：
  - P2026-0044 给出 NA-TP 框架、AOPF Algorithm 1、QR-AEP/Q-Risk/PIW 目标、MOTPE 设置、Granger 场景构造、多个负荷数据集和在线/概率预测 baseline 对比。
- 与已有设计知识的区别：
  - 不同于“鲁棒解空间观测的时间联动分布预测”：该知识从优化 archive 预测扰动分布并嵌入鲁棒目标；本知识直接面向概率预测模型的在线更新和区间输出。
  - 不同于“预测嵌入的中断感知供应链多目标规划”：该知识把预测参数写入规划约束；本知识把预测模型本身的训练/部署配置做成 Pareto 决策层。
  - 不同于“预测代理驱动的实时多目标控制优化”：该知识用 surrogate 快速优化控制参数；本知识优化 forecast uncertainty 的 accuracy-calibration-sharpness。
  - 不同于常规动态 MOO 预测响应：本知识不预测 Pareto 种群，而是预测外部时序量并把预测质量多目标化。

## 解决的问题

- 适用场景：
  - 电力负荷、风光功率、交通流、云资源 workload、库存需求等在线时序预测；
  - 需要输出 quantile 或 prediction interval，而非只有点预测；
  - 数据分布会因天气、节假日、市场、设备状态或突发事件漂移；
  - 更新成本有限，不能每个时间步完整重训；
  - 业务方需要在 calibration、sharpness、accuracy 和计算成本之间选操作点。
- 现有方法为什么会失败或不足：
  - 离线模型无法跟踪新 regime；
  - 固定周期微调不区分短暂 spike 与持续漂移；
  - 单目标 pinball/NLL 可能给出不可靠或过宽的区间；
  - 后处理 calibration 与训练目标脱节，在 shift 下可能不稳定；
  - 只报告一个模型分数，不能表达不同风险偏好的部署方案。
- 仍需解决的问题：
  - 在线阶段是否需要重跑 Pareto 优化，还是仅在离线 Pareto set 中切换；
  - 如何把极端事件 coverage、update latency 和能源成本也纳入目标；
  - 如何保证区间 coverage 在有限样本和 drift 下仍满足可接受置信水平；
  - 如何在非线性因果关系和隐变量下做稳定特征筛选。

## 为什么可能有效

```text
streaming forecast receives volatile observations
-> z-score normalizes loss against recent baseline
-> dynamic threshold avoids reacting to isolated spikes
-> DLR discounts outdated gradients and tracks recent nonstationarity
-> sparse updates keep amortized runtime near inference cost
-> tri-objective Pareto front exposes calibration-sharpness-accuracy trade-off
-> operator picks a risk-appropriate point instead of trusting a single scalar loss
```

核心假设是：recent loss statistics 足以区分短暂噪声和持续漂移，并且 QR-AEP/Q-Risk/PIW 能覆盖部署所需的主要概率预测质量。若极端事件稀少、loss 分布重尾或外生变量关系非线性且变化快，普通 z-score 和 Granger 筛选可能不足。

## 实现接口

- 输入：
  - 历史目标时序与候选外生变量；
  - 未来已知或可预测的 weather/calendar/event features；
  - 目标 quantile set，例如 `{0.1, 0.5, 0.9}`；
  - online update window、loss smoothing、`c_min/c_max/alpha`；
  - 多目标优化器，例如 MOTPE、NSGA-II、MOEA/D 或 Bayesian MOO。
- 输出：
  - 点预测、quantile forecast 或 parametric distribution；
  - 更新触发记录、update frequency 和 latency；
  - Pareto-efficient configurations；
  - 每个操作点的 quantile loss、coverage risk、interval width 和可选 update cost。
- 插入位置：
  - 实时预测服务的 model update controller；
  - 概率预测训练 pipeline 的 objective layer；
  - 能源/交通/供应链调度器的 uncertainty forecast front-end；
  - 运行人员 dashboard 的风险偏好选解层。
- 最小实现：

```text
offline:
    causal_features <- screen(features, target)
    model <- pretrain_probabilistic_transformer(target, causal_features)
    pareto_set <- MOTPE(
        objectives = [QR_AEP, Q_Risk, PIW],
        variables = [loss weights, model/update hyperparameters]
    )

online:
    for each time t:
        y_hat <- model.predict(window, selected_features)
        loss_t <- probabilistic_loss(y_hat, y_t)
        mu_t, sigma_t <- update_loss_stats(loss_t)
        z_t <- (loss_t - mu_t) / (sigma_t + eps)
        c_t <- clip(c_min + (c_max - c_min) * sigmoid(alpha * z_t), c_min, c_max)

        if loss_t > mu_t + c_t * sigma_t:
            g_t <- exponentially_weighted_recent_gradients(window)
            update_decoder(model, g_t)

        if operating_context_changes:
            select point from pareto_set by risk preference
```

- P2026-0044 的具体实例：
  - Transformer 使用 Conv1D、positional encoding、multi-head self-attention encoder 和 MLE/quantile decoder；
  - update trigger 使用 sliding loss mean/std、z-score 和 sigmoid coefficient；
  - `window_size` 候选包括 hourly 的 24/48/72/168 和 15-min 的 96/192/288/672；
  - MOTPE 每个 scenario 做 30 trials；
  - 表 14 报告 A/B/C 三类 Pareto-efficient regimes。

## 如何用于算法创新

### 局部创新

- 用 MAD、Huber scale 或 rolling quantile 替代标准差，减少 heavy-tail spike 对 z-score 的影响。
- 在 Pareto 目标中加入 update cost、latency、memory、extreme-event coverage 或 CVaR。
- 将 Q-Risk 换成 conformal coverage violation，使部署层有显式 coverage 保证。
- 用 preference-conditioned head 学习连续 risk preference 下的 quantile forecast，而不是离散 Pareto trial。
- 用 nonlinear causal discovery、PCMCI、Granger+attention stability 或 invariant feature selection 替代线性 Granger。

### 结构创新

- forecast-service 架构：feature causality gate、probabilistic backbone、drift/update controller、Pareto operating-point selector、downstream scheduler。
- 与多目标调度结合：预测层输出多个校准-宽度方案，调度层根据备用容量、库存或拥堵状态选择风险等级。
- 与数字孪生结合：digital twin 生成极端场景，Pareto 层评估 forecast sharpness 与风险覆盖。
- 与在线 MOO 结合：将当前 drift severity 作为 preference/context，实时从 Pareto set 切换或增量更新配置。

## 适用条件与风险

- 适用条件：
  - 预测任务需要概率输出或预测区间；
  - 在线样本到达后可以计算即时 loss；
  - 更新成本相对 inference 更高，需要触发机制；
  - 可定义 calibration 和 sharpness 指标；
  - 下游决策者能利用 Pareto 操作点。
- 不适用或可能失效的条件：
  - 只有点预测需求且误差代价近似对称；
  - 标签延迟很长，无法及时计算 streaming loss；
  - 突发事件导致 loss statistics 完全失效；
  - 外生变量不可获得或未来值不可预测；
  - 业务方只接受固定 SLA，不接受 Pareto 选点。
- 计算与实现成本：
  - 需要维护 rolling loss statistics、recent gradients 和 update controller；
  - 多目标超参数优化需要额外离线预算；
  - 若在线重跑 Pareto 优化，必须控制 trial 数或使用 warm-start/incremental surrogate。
- 解释风险：
  - Granger causality 不是干预因果，可能受共线和隐变量影响。
  - `Value` 不适用本知识；这里的控制信号是 update threshold 和 Pareto objective，不是资源调度概率。
  - Pareto solutions 的 A/B/C 标签是操作 regime，不代表绝对排名。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0044 | NA-TP 由 Granger causal feature selection、Transformer forecasting、AOPF 和 multi-objective optimization 四阶段组成 | 作者提出的方法 | Sec. 3.1，Fig. 1，PDF 5 |
| P2026-0044 | AOPF 使用 streaming loss 的滑动均值、标准差和 z-score 计算动态阈值系数 `c_t` | 作者提出的方法 | Sec. 3.4.4，Algorithm 1，PDF 8 |
| P2026-0044 | 触发更新时，使用 dynamic local regret 的指数加权梯度并用 Adam 更新 decoder 参数 | 作者提出的方法 | Sec. 3.4.2-3.4.4，PDF 7-8 |
| P2026-0044 | QR-AEP、Q-Risk、PIW 分别对应分位精度、概率校准和预测区间锐度 | 作者提出的方法 | Sec. 3.5.2，Table 4，PDF 8 |
| P2026-0044 | QR-AEP 的 under-/over-prediction 惩罚通过 controlled error scenarios 与 cost sensitivity regression 估计 | 作者提出的方法 | Sec. 3.5.4，PDF 9 |
| P2026-0044 | Transformer 使用 Conv1D、positional encoding、multi-head self-attention encoder 和 MLE/quantile decoder | 作者提出/组合方法 | Sec. 3.6，PDF 9-10 |
| P2026-0044 | Vietnam 与 Valencia_Spain 的 Granger 测试筛出 solar/UV/calendar/generation/weather/cyclic variables | 实验支持 | Sec. 4.1，Table 7，PDF 11 |
| P2026-0044 | AOPF-enabled Transformer 相对 offline Transformer 通常改善 RMSE/MAPE、CRPS 和 Winkler95，且只需 sparse updates | 综合实验支持 | Sec. 4.5.1，Table 10-11，PDF 14 |
| P2026-0044 | 相对 SARIMA Online、LSTM Online 以及 Informer-Q、Autoformer-Q、TFT、DeepAR，NA-TP variants 多数场景 best 或 second-best | 综合实验支持 | Sec. 4.5.1，Table 12-13，PDF 14-16 |
| P2026-0044 | MOTPE 每个 scenario 30 trials，报告代表性 Pareto-efficient A/B/C regimes | 多目标实验支持 | Sec. 4.5.2，Table 14，PDF 15-17 |
| P2026-0044 | Table 14 显示 Q-Risk、Pinball 和 PIW 之间存在稳定 trade-off，Pareto set 可作为 operator decision layer | 多目标实验支持 | Sec. 4.5.2，PDF 17 |
| P2026-0044 | 作者未来工作包括 advanced attention、domain-adaptive transformers、更大多源数据和 streaming/digital twin/CPS 集成 | 作者未来工作 | Conclusion，PDF 18 |

## 证据边界

- 当前只有单篇论文证据。
- 表 10-13 在 Markdown 中主要为图片占位，当前卡片依赖正文总结，未逐项验证所有数值。
- MOTPE 每个场景 30 trials，Pareto approximation 可能较粗。
- 成本不对称模型用简化 error scenario 和固定 `alpha_u/alpha_o`，不一定反映所有电力市场规则。
- Granger feature selection 偏线性和滞后相关，非线性或隐藏因果机制可能未被捕捉。

## 待确认

- 在线部署时是否需要动态切换 Pareto 操作点，还是固定一个配置；
- decoder-only update 是否足以适应长期 regime shift；
- coverage guarantee 是否需要 conformal 或 Bayesian calibration 兜底；
- update trigger 是否应使用 robust statistics 以应对 extreme spikes；
- 多目标优化是否能加入真实 update cost 和下游调度风险指标。
