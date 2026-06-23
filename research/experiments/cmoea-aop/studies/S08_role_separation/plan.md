# S08 强角色分离 Credit 探索实验

## 目的

S07 说明 `Dual-Role-Credit-AOP-v1/v2/v3` 虽然稳定优于原始 `CMOEA-AOP`，但两个种群最终学到的算子比例仍然很接近，双种群分化度只有 0.026-0.030。S08 的目标是继续探索更强的角色分离机制，让主种群和辅助种群不只是使用不同 credit 信号，还通过软先验、不同下限和阶段先验形成更明显的分工。

## 新方法变体

- `Role-Separated-Credit-AOP-v1`：中等强度静态角色先验。主种群偏 GA/DE-best，辅助种群偏 DE/rand。
- `Role-Separated-Credit-AOP-v2`：强角色分离先验。主种群进一步压低 DE/rand，辅助种群提高 DE/rand 下限。
- `Role-Separated-Credit-AOP-v3`：阶段角色先验。早期辅助种群强探索，后期辅助种群逐步增加 DE/best。
- `Role-Separated-Credit-AOP-v4`：平滑强分离版本。使用强角色先验，但降低更新步长，避免比例抖动。

## 对照算法

- CMOEA-AOP
- Equal-AOP
- Survival-Credit-AOP
- Dual-Survival-Credit-AOP
- Dual-Role-Credit-AOP-v2
- Dual-Role-Credit-AOP-v3
- Role-Separated-Credit-AOP-v1
- Role-Separated-Credit-AOP-v2
- Role-Separated-Credit-AOP-v3
- Role-Separated-Credit-AOP-v4

## 实验问题

使用论文同一组 33 个约束多目标测试问题：

- CF1-CF10
- LIRCMOP1-LIRCMOP14
- DASCMOP1-DASCMOP9

## 设置

- 种群规模：`N = 100`
- 最大评价次数：`maxFE = 50000`
- 独立运行次数：`runs = 5`
- 指标：`IGD`、`HV`、`Feasible_rate`

## 判断标准

S08 不是最终论文级确认，而是方法探索。主要看：

1. 平均排名是否接近或超过 `Dual-Survival-Credit-AOP`。
2. 失败行数和失败问题数是否保持较低。
3. 双种群分化度是否明显高于 S07 的 0.026-0.030。
4. 是否能达到或超过 `Dual-Survival-Credit-AOP` 在 S07 的分化度 0.063。
5. 不同问题族上是否出现清晰优势，尤其是 DAS-CMOP。

## 输出

- `runs.csv`：每次运行的最终指标。
- `problem_means.csv`：每个算法/问题的均值与严格失败标记。
- `trace_summary.csv`：有 `policyTrace` 的算法整体轨迹汇总。
- `trace_phase_summary.csv`：早期、中期、后期轨迹汇总。
- `summary.md`：中文统计分析和进入 S09 的候选建议。
- 原始 `.mat` 与 worker 日志保存在 `research/experiments/cmoea-aop/results/S08_role_separation/`，不提交 Git。
