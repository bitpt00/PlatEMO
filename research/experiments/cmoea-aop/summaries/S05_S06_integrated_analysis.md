# S05-S06 综合分析

## 已完成内容

本轮完成了两个阶段：

- S05 候选方法确认实验：8 个算法，33 个论文问题，`N = 100`，`maxFE = 50000`，5 个 seeds，共 1320 次运行。
- S06 机制诊断实验：8 个算法，33 个论文问题，`N = 100`，`maxFE = 50000`，3 个 seeds，共 792 次运行，并为有 `policyTrace` 的算法导出了机制轨迹。

完整结果位置：

- `research/experiments/cmoea-aop/studies/S05_candidate_confirmation/runs.csv`
- `research/experiments/cmoea-aop/studies/S05_candidate_confirmation/summary.md`
- `research/experiments/cmoea-aop/studies/S05_candidate_confirmation/trace_summary.csv`
- `research/experiments/cmoea-aop/studies/S05_candidate_confirmation/trace_phase_summary.csv`
- `research/experiments/cmoea-aop/studies/S06_mechanism_diagnosis/runs.csv`
- `research/experiments/cmoea-aop/studies/S06_mechanism_diagnosis/summary.md`
- `research/experiments/cmoea-aop/studies/S06_mechanism_diagnosis/trace_summary.csv`
- `research/experiments/cmoea-aop/studies/S06_mechanism_diagnosis/trace_phase_summary.csv`

原始 `.mat` 文件和 worker 日志保存在 `research/experiments/cmoea-aop/results/`，该目录不提交 Git。

## 主要结论

### 1. DDPG-AOP 在 50k 预算下不是唯一解释

S05 中，原始 CMOEA-AOP 的严格平均排名为 5.045，低于 `Survival-Credit-AOP`、`Equal-AOP`、`Dual-Survival-Credit-AOP`、`Dual-Feasibility-Explore-AOP` 和 `Objective-Credit-AOP`。它还有 8 行失败、5 个失败问题。

S06 中，用行为等价的 `CMOEA-AOP-Trace` 记录 DDPG action 后，它的平均排名为 4.258，仍低于 `Survival-Credit-AOP`、`Dual-Survival-Credit-AOP` 和 `Objective-Credit-AOP`。

这说明在当前预算和问题集上，CMOEA-AOP 的效果不能简单归因于 DDPG 学习比例。多算子共存、简单反馈和双种群结构本身都能解释相当一部分效果。

### 2. 多算子共存是强基线

`Equal-AOP` 在 S05 中平均排名 3.955，问题级相对 CMOEA-AOP 为 21 胜、11 负、1 平。它没有任何学习机制，只是三算子均匀共存。

这支持一个重要解释：CMOEA-AOP 的收益里有一部分来自“同时保留 GA、DE/rand、DE/best 三种 offspring 来源”，而不一定来自复杂的强化学习控制。

### 3. Survival-Credit 是当前最稳的轻量方法

`Survival-Credit-AOP` 在 S05 和 S06 都是严格平均排名第一：

- S05：平均排名 3.788，失败行数 0，失败问题数 0。
- S06：平均排名 4.000，失败行数 0，失败问题数 0。

它的机制轨迹也比较清楚：早期偏 GA，随后逐渐降低 GA 比例，DE/rand 略有上升，DE/best 保持中等比例。这不是手工 Stage 规则，而是由 offspring 存活反馈自然形成的平滑变化。

### 4. Objective-Credit 有价值，但稳定性略弱

`Objective-Credit-AOP` 在 S06 中相对 `CMOEA-AOP-Trace` 是 18 胜、14 负、1 平，是问题级胜负上最积极的轻量方法。它说明 objective improvement 不是无效信号。

但它在 S06 有 1 行失败、1 个失败问题，稳定性略弱于 `Survival-Credit-AOP` 和 `Dual-Survival-Credit-AOP`。因此 objective 信号更适合作为辅助种群的信用来源，而不是直接替代全部控制信号。

### 5. 双种群方向有价值，但不能只靠固定分化

`Dual-Survival-Credit-AOP` 在 S05 排名第三，在 S06 排名第二，并且两次都没有失败行和失败问题。这说明两个种群分别维护 credit 是稳定方向。

但是 `Dual-Feasibility-Explore-AOP` 的双种群分化度最高，S06 中却没有问题胜场，DAS-CMOP 排名也偏弱。这说明“主种群偏可行、辅助种群偏探索”的方向是对的，但不能简单固定成硬比例。固定强分工可能过早限制搜索。

更合理的方向是：两个种群分别使用不同 credit 信号，让分工从反馈中产生，而不是完全手写。

### 6. DDPG 的 action 更像温和偏 DE，而不是强阶段策略

S06 中 `CMOEA-AOP-Trace` 的平均比例为：

- GA：0.267
- DE/rand：0.354
- DE/best：0.379

阶段上看：

- 早期：0.262 / 0.386 / 0.352
- 中期：0.262 / 0.348 / 0.390
- 后期：0.278 / 0.336 / 0.386

它没有表现出很强的阶段跳变，也没有区分两个种群。这说明 DDPG 在这些设置下更像是在维持一个温和偏 DE 的混合比例，而不是学到复杂的阶段调度。

这也解释了为什么 `Stage-AOP` 没有稳定接近 DDPG：手写 Stage 过于粗糙；而 `Survival-Credit-AOP` 这种连续反馈更接近有效行为。

## 建议形成的新方法方向

下一步最值得定型的方法不是单纯 `Survival-Credit-AOP`，而是：

```text
Dual-Role-Credit-AOP
```

核心思想：

- 主种群使用 feasibility-aware survival credit：重视存活、可行性、CV 下降。
- 辅助种群使用 objective-aware survival credit：重视存活、目标改善，并保留一定探索下限。
- 两个种群分别维护算子比例。
- 使用滑动平均和平滑更新，避免固定强分工带来的僵硬。

它的研究价值在于：

1. 比 DDPG 更简单，不需要神经网络和 replay buffer。
2. 比 Equal-AOP 更有反馈机制。
3. 比 Stage-AOP 更连续、更自适应。
4. 比固定双种群分工更柔和。
5. 与 EMCMO 的双种群角色天然对应，解释性更强。

## 下一步实验建议

建议把下一轮定义为 S07：

- 实现 `Dual-Role-Credit-AOP`。
- 与 `CMOEA-AOP`、`Equal-AOP`、`Survival-Credit-AOP`、`Objective-Credit-AOP`、`Dual-Survival-Credit-AOP`、`EMCMO` 比较。
- 先用 `maxFE = 50000`、5 seeds、33 个论文问题快速确认。
- 如果稳定，再做 `maxFE = 100000`、10 seeds。

这条线的目标不是证明一定超过 CMOEA-AOP，而是提出一个更可解释的替代机制：约束多目标优化中的算子 portfolio 不一定需要 DDPG，轻量 credit 和双种群角色分化可能已经足够解释主要收益。
