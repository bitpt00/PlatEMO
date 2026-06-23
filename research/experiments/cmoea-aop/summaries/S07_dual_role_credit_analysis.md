# S07 双种群角色化 Credit 综合分析

## 实验完成情况

S07 完成了 9 个算法、33 个论文问题、5 个 seeds 的确认实验，共 1485 次运行。设置为 `N = 100`、`maxFE = 50000`，指标为 `IGD`、`HV`、`Feasible_rate`。

结果文件：

- `research/experiments/cmoea-aop/studies/S07_dual_role_credit/runs.csv`
- `research/experiments/cmoea-aop/studies/S07_dual_role_credit/problem_means.csv`
- `research/experiments/cmoea-aop/studies/S07_dual_role_credit/trace_summary.csv`
- `research/experiments/cmoea-aop/studies/S07_dual_role_credit/trace_phase_summary.csv`
- `research/experiments/cmoea-aop/studies/S07_dual_role_credit/summary.md`

原始 `.mat` 和 worker 日志保存在 `research/experiments/cmoea-aop/results/S07_dual_role_credit/`，不提交 Git。

## 主要发现

### 1. 当前最强方法仍是 Dual-Survival-Credit-AOP

严格失败口径下，`Dual-Survival-Credit-AOP` 平均排名第一：

- 平均排名：4.182
- 问题胜场：4
- 失败行数：0
- 失败问题数：0

这说明目前最稳的创新线索不是复杂角色化 credit，而是两个种群分别维护 survival credit。

### 2. Dual-Role 版本稳定，但没有超过 Dual-Survival

三个角色化版本都稳定优于原始 `CMOEA-AOP`：

- `Dual-Role-Credit-AOP-v3`：平均排名 4.545，20 胜 13 负于 CMOEA-AOP。
- `Dual-Role-Credit-AOP-v2`：平均排名 4.667，19 胜 14 负于 CMOEA-AOP。
- `Dual-Role-Credit-AOP-v1`：平均排名 4.939，20 胜 13 负于 CMOEA-AOP。

但它们都没有超过 `Dual-Survival-Credit-AOP`。这说明“角色化 credit”方向有稳定性，但第一版设计还没有转化成更强性能。

### 3. 当前 Dual-Role 的角色分化不够强

机制轨迹显示：

- `Dual-Role-Credit-AOP-v1` 双种群分化度：0.030
- `Dual-Role-Credit-AOP-v2` 双种群分化度：0.026
- `Dual-Role-Credit-AOP-v3` 双种群分化度：0.028
- `Dual-Survival-Credit-AOP` 双种群分化度：0.063

这说明 v1/v2/v3 虽然使用了不同 credit 信号，但两个种群最终学到的比例仍然接近。当前角色信号太温和，尚未形成清晰的主种群/辅助种群分工。

### 4. v3 和 v2 有不同价值

`Dual-Role-Credit-AOP-v3` 是当前总体最好的角色化版本，尤其在 CF 问题族上排名较好。

`Dual-Role-Credit-AOP-v2` 在 DAS-CMOP 上排名最好，说明更强的 CV 信号和辅助种群探索下限可能对困难约束问题有帮助。

因此，如果继续保留角色化方法，建议保留 v3 和 v2，不再优先保留 v1。

## 当前可以形成的论文判断

S07 后，论文方向需要稍微收敛：

1. 不能直接声称 `Dual-Role-Credit-AOP` 已经是最优新方法。
2. 可以声称“两个种群分别维护 credit”是稳定有效线索。
3. 可以声称“仅靠不同 credit 信号并不足以产生足够强的角色分化”。
4. 下一步的新方法如果继续走角色化路线，需要更显式地诱导两个种群分工。

因此当前最稳的论文候选方法是：

```text
Dual-Survival-Credit-AOP
```

当前最有潜力但需要继续改进的方法方向是：

```text
Role-Separated-Credit-AOP
```

后者应该比 S07 的 Dual-Role 更强地引入角色先验，例如：

- 主种群保持更高 GA/DE-best 下限；
- 辅助种群保持更高 DE/rand 下限；
- 主种群 credit 更重 CV 与 feasibility；
- 辅助种群 credit 更重 objective score 与探索；
- 使用软先验，而不是固定比例。

## 下一步建议

建议不要立刻把 S07 的 Dual-Role 版本拿去做大规模正式验证。更合理的下一步有两个选择：

### 选择 A：确认当前最稳方法

做 S08-confirm：

- `maxFE = 100000`
- `runs = 10`
- 算法：`CMOEA-AOP`、`EMCMO`、`Equal-AOP`、`Survival-Credit-AOP`、`Dual-Survival-Credit-AOP`、`Dual-Role-Credit-AOP-v3`、`Dual-Role-Credit-AOP-v2`

这条线用于确认 `Dual-Survival-Credit-AOP` 是否足够稳，可以作为简单替代方法写论文。

### 选择 B：继续强化角色化创新

做 S08-role-separation：

- 先用 `maxFE = 50000`、5 seeds。
- 实现更强的 `Role-Separated-Credit-AOP`。
- 比较软先验、不同下限、阶段相关角色权重。

这条线更适合发展新方法。如果目标是论文创新性，建议优先走选择 B，再把最好的方法放进正式确认实验。
