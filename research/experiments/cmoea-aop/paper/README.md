# SCOP-CMOEA 论文执行材料

这个目录只保留下一步实验、统计、出图和写作前准备的可执行方案。

## 当前唯一方案文档

| 文件 | 用途 |
| --- | --- |
| `SCOP_next_execution_plan.md` | 接下来马上做哪些实验、怎么启动、怎么检查、怎么汇总、哪些图表由哪些脚本生成 |

## 正式实验配置

| 配置文件 | 用途 |
| --- | --- |
| `../configs/s11_main_30run_config.m` | 10 算法、56 标准问题、30 run 主实验 |
| `../configs/s12_portfolio_ablation_30run_config.m` | portfolio 消融 |
| `../configs/s13_credit_signal_30run_config.m` | credit 信号消融 |
| `../configs/s14_parameter_sensitivity_config.m` | 参数敏感性 |
| `../configs/s15_rwmop_application_config.m` | RWMOP 应用实验 |

## 马上执行

第一步启动 S11：

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s11_main_30run_config
```
