# S03 信用信号实验计划

## 目标

分离哪一种 reward 或 credit signal 能为算子选择提供真正有用的反馈。

## 范围

- 在 S01 和必要的 controller scaffolding 稳定后启动。
- reward 或 credit-signal 改动要与无关 controller 改动分开。
- 保持原始 `CMOEA-AOP/` 代码不变。
- 所有信号变体放在 `CMOEA-AOP-Lab/`。

## 候选方向

- 可行性改善 credit。
- 目标函数进展 credit。
- 多样性保持 credit。
- 带显式消融的组合 credit。

## 计划输出

- `runs.csv`：有真实运行结果后记录最终指标。
- `checkpoints.csv`：有真实运行结果后记录过程级指标。
- `summary.md`：有真实运行结果后记录 Codex 执行说明和紧凑结论。
