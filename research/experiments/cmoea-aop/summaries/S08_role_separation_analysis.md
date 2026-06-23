# S08 强角色分离 Credit 综合分析

## 实验完成情况

S08 完成了 10 个算法、33 个论文问题、5 个 seeds 的角色分离探索实验，共 1650 次运行。设置为 `N = 100`、`maxFE = 50000`，指标为 `IGD`、`HV`、`Feasible_rate`。

结果文件：

- `research/experiments/cmoea-aop/studies/S08_role_separation/runs.csv`
- `research/experiments/cmoea-aop/studies/S08_role_separation/problem_means.csv`
- `research/experiments/cmoea-aop/studies/S08_role_separation/trace_summary.csv`
- `research/experiments/cmoea-aop/studies/S08_role_separation/trace_phase_summary.csv`
- `research/experiments/cmoea-aop/studies/S08_role_separation/summary.md`

原始 `.mat` 和 worker 日志保存在 `research/experiments/cmoea-aop/results/S08_role_separation/`，不提交 Git。

## 背景问题

S07 中 `Dual-Role-Credit-AOP-v1/v2/v3` 使用了不同 credit 信号，但双种群分化度只有 0.026-0.030。这说明两个种群并没有真正学出不同角色。

S08 因此加入了更强的角色机制：

- 主种群偏 GA/DE-best，重视 feasibility、CV score 和 survival。
- 辅助种群偏 DE/rand，重视 objective score 和探索下限。
- 使用软先验、不同下限和阶段先验诱导分工。

## 主要结果

严格失败口径下，平均排名前几名为：

| 算法 | 平均排名 | 失败行数 | 失败问题数 |
| --- | ---: | ---: | ---: |
| Survival-Credit-AOP | 4.303 | 0 | 0 |
| Dual-Survival-Credit-AOP | 4.727 | 0 | 0 |
| Dual-Role-Credit-AOP-v3 | 5.030 | 0 | 0 |
| Dual-Role-Credit-AOP-v2 | 5.212 | 0 | 0 |
| Role-Separated-Credit-AOP-v1 | 5.242 | 0 | 0 |
| Role-Separated-Credit-AOP-v2 | 5.576 | 0 | 0 |

新方法相对原始 `CMOEA-AOP` 均有明显优势，其中 `Role-Separated-Credit-AOP-v1` 相对 CMOEA-AOP 为 24 胜、9 负。

但是，强角色分离版本没有超过 `Survival-Credit-AOP` 和 `Dual-Survival-Credit-AOP`。

## 机制发现

S08 最重要的结果来自轨迹分析：

| 算法 | 双种群分化度 |
| --- | ---: |
| Dual-Role-Credit-AOP-v2 | 0.026 |
| Dual-Role-Credit-AOP-v3 | 0.028 |
| Dual-Survival-Credit-AOP | 0.065 |
| Role-Separated-Credit-AOP-v1 | 0.141 |
| Role-Separated-Credit-AOP-v2 | 0.242 |
| Role-Separated-Credit-AOP-v3 | 0.139 |
| Role-Separated-Credit-AOP-v4 | 0.187 |

这说明 S08 成功解决了 S07 的“分化不足”问题。角色先验确实能让两个种群形成不同的算子比例。

但性能结果显示：

> 分化度越高不等于性能越好。

`Role-Separated-Credit-AOP-v2` 分化最强，但排名弱于 v1。`Role-Separated-Credit-AOP-v4` 使用平滑强分离，也没有改善结果。

因此当前更合理的机制结论是：

> 双种群角色分离需要适度。太弱时没有机制差异，太强时会损害两个种群之间的搜索协同。

## 对论文路线的判断

S08 后，两个论文路线都还成立，但主次应调整：

### 保底路线

`Survival-Credit-AOP` 和 `Dual-Survival-Credit-AOP` 仍是最稳线索。

这条路线可写成：

> CMOEA-AOP 的收益不必依赖 DDPG；简单 survival credit 和双种群 credit 已能提供更稳定、更可解释的替代机制。

### 创新路线

`Role-Separated-Credit-AOP-v1` 是当前最值得保留的角色分离版本。它没有超过最强基线，但提供了一个重要机制发现：

> 明确角色先验可以显著增加双种群分化，但必须保持适度；过强分离不利于整体性能。

如果论文想强调方法创新，可以把 S08 的结果写成“角色分离机制的边界条件”，而不是只追求排名第一。

## S09 推荐算法

建议 S09 高预算确认使用：

- EMCMO
- CMOEA-AOP
- Equal-AOP
- Survival-Credit-AOP
- Dual-Survival-Credit-AOP
- Dual-Role-Credit-AOP-v3
- Role-Separated-Credit-AOP-v1

可选加入：

- Role-Separated-Credit-AOP-v2

加入 v2 的理由不是它最强，而是它代表“强角色分离”，可以帮助论文解释为什么角色分离不能过度。

## 给 Pro 的问题

建议让 Pro 重点分析：

1. S09 是否应把论文主方法定为 `Dual-Survival-Credit-AOP`，还是保留 `Role-Separated-Credit-AOP-v1` 作为方法创新？
2. `Role-Separated-Credit-AOP-v2` 是否值得进入 S09 作为机制对照？
3. 论文叙事是否应从“角色分离更强”调整为“适度角色分离与 survival feedback 的平衡”？
