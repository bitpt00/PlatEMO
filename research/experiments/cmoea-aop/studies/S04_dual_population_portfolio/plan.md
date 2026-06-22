# S04 双种群 Portfolio 实验计划

## 目标

研究 operator portfolio 与 CMOEA-AOP 双种群行为之间的交互关系。

## 范围

- 只有当 S01 到 S03 识别出可信的 portfolio 和 controller 选择后，才启动本 study。
- 双种群改动要与无关 reward 或 logging 改动隔离。
- 保持原始 `CMOEA-AOP/` 代码不变。
- 所有实验代码放在 `CMOEA-AOP-Lab/`。

## 候选方向

- 两个种群使用不同 portfolio。
- 共享 portfolio，但使用 population-specific credit。
- stage-aware 的双种群 portfolio。
- 禁用 population-specific adaptation 的消融实验。

## 计划输出

- `runs.csv`：有真实运行结果后记录最终指标。
- `checkpoints.csv`：有真实运行结果后记录过程级指标。
- `summary.md`：有真实运行结果后记录 Codex 执行说明和紧凑结论。
