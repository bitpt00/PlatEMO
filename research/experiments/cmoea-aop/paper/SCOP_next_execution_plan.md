# SCOP-CMOEA 下一步实验与出图执行方案

只保留这份执行文档。目标是把论文实验补齐到可以写稿。

## 1. 先做什么

| 顺序 | 编号 | 内容 | 是否必须 | 结果用途 |
| ---: | --- | --- | --- | --- |
| 1 | S11 | 10 个算法、56 个标准问题、30 run 主实验 | 必须 | 论文主性能表、排名、显著性 |
| 2 | S12 | portfolio 消融，检验单算子/均匀/随机/阶段/SCOP/DDPG | 必须 | 说明收益来自 survival-credit portfolio |
| 3 | S13 | credit 信号消融，比较 feasibility/CV/objective/mixed/sliding | 必须 | 说明为什么 survival credit 是核心 |
| 4 | S14 | `creditAlpha` 和 `creditFloor` 参数敏感性 | 必须 | 说明参数稳定性 |
| 5 | S15 | RWMOP1-RWMOP20 应用实验 | 建议 | 增加真实问题证据 |

先跑 S11。S11 统计完成后再跑 S12 和 S13；S12、S13 可以并行。S14、S15 放后面。

## 2. 已经补好的配置文件

| 实验 | 配置文件 | 运行量 |
| --- | --- | ---: |
| S11 主实验 | `research/experiments/cmoea-aop/configs/s11_main_30run_config.m` | 10 × 56 × 30 = 16800 |
| S12 portfolio 消融 | `research/experiments/cmoea-aop/configs/s12_portfolio_ablation_30run_config.m` | 9 × 56 × 30 = 15120 |
| S13 credit 消融 | `research/experiments/cmoea-aop/configs/s13_credit_signal_30run_config.m` | 9 × 56 × 30 = 15120 |
| S14 参数敏感性 | `research/experiments/cmoea-aop/configs/s14_parameter_sensitivity_config.m` | 16 × 15 × 20 = 4800 |
| S15 RWMOP 应用 | `research/experiments/cmoea-aop/configs/s15_rwmop_application_config.m` | 8 × 20 × 30 = 4800 |

统一设置：

```text
N = 100
MaxFE = 100000
S11/S12/S13/S15 = 30 run
S14 = 20 run
标准问题指标 = IGD, HV, Feasible_rate, runtime
RWMOP 指标 = HV, Feasible_rate, runtime
```

## 3. S11 主实验

### 3.1 对比算法

```text
SCOP-CMOEA
CMOEA-AOP
EMCMO
ICMA
IMTCMO
DRLOS-EMCMO
CMOES
DPCPRA
PPS
C-TAEA
```

### 3.2 测试问题

```text
CF1-CF10
LIRCMOP1-LIRCMOP14
DASCMOP1-DASCMOP9
MW1-MW14
DOC1-DOC9
```

共 56 个问题。这个集合覆盖 CMOEA-AOP 的 CF/LIR/DAS，也覆盖 CMOEA-2S 的 LIR/DOC/CF，并补充 MW。

### 3.3 启动命令

用 CPU 多进程，不用 GPU。20 线程机器建议 12 个 MATLAB worker 起跑。

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s11_main_30run_config
```

补跑缺失任务：

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s11_main_30run_config -MissingOnly
```

检查任务数量：

```powershell
Get-ChildItem .\research\experiments\cmoea-aop\results\S11_main_30run\s11_main_30run -Filter *.mat | Measure-Object
```

完成标准：

```text
MAT 文件数量 = 16800
错误日志中没有未处理失败
```

### 3.4 S11 汇总命令

MATLAB 导出 runs.csv：

```powershell
matlab -batch "cd('E:\多目标优化\PlatEMO-master'); addpath('research\experiments\cmoea-aop\scripts'); summarize_s01_results('s11_main_30run_config'); summarize_policy_traces('s11_main_30run_config');"
```

Python 生成排名摘要：

```powershell
python research\experiments\cmoea-aop\scripts\analyze_runs.py --runs research\experiments\cmoea-aop\studies\S11_main_30run\runs.csv --problem-means research\experiments\cmoea-aop\studies\S11_main_30run\problem_means.csv --summary research\experiments\cmoea-aop\summaries\S11_main_30run_analysis.md --title "S11 主实验 30-run 统计" --baseline CMOEA-AOP --trace-summary research\experiments\cmoea-aop\studies\S11_main_30run\trace_summary.csv --trace-phase research\experiments\cmoea-aop\studies\S11_main_30run\trace_phase_summary.csv
```

S11 需要生成的表：

| 表 | 文件 | 生成方式 |
| --- | --- | --- |
| 主表 1：IGD 平均排名 | `S11_main_30run_analysis.md` | `analyze_runs.py` |
| 主表 2：HV 平均值/排名 | 需新增 `export_paper_tables.py` | Python 从 `runs.csv` 统计 |
| 主表 3：Wilcoxon 胜/平/负 | 需新增 `export_paper_tables.py` | Python，按 30 run 做检验 |
| 主表 4：分问题族排名 | `S11_main_30run_analysis.md` | `analyze_runs.py` |
| 主表 5：FR 和失败问题 | `problem_means.csv` | Python |
| 主表 6：runtime | 需新增 `export_paper_tables.py` | Python 从 `runs.csv` 统计 |

## 4. S12 portfolio 消融

### 4.1 方法

```text
SCOP-CMOEA
CMOEA-AOP
EMCMO
GA-only
DE-rand-only
DE-best-only
Equal-AOP
Random-AOP
Stage-AOP
```

### 4.2 启动命令

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s12_portfolio_ablation_30run_config
```

完成标准：

```text
MAT 文件数量 = 15120
```

### 4.3 汇总命令

```powershell
matlab -batch "cd('E:\多目标优化\PlatEMO-master'); addpath('research\experiments\cmoea-aop\scripts'); summarize_s01_results('s12_portfolio_ablation_30run_config'); summarize_policy_traces('s12_portfolio_ablation_30run_config');"
python research\experiments\cmoea-aop\scripts\analyze_runs.py --runs research\experiments\cmoea-aop\studies\S12_portfolio_ablation_30run\runs.csv --problem-means research\experiments\cmoea-aop\studies\S12_portfolio_ablation_30run\problem_means.csv --summary research\experiments\cmoea-aop\summaries\S12_portfolio_ablation_30run_analysis.md --title "S12 portfolio 消融 30-run 统计" --baseline SCOP-CMOEA --trace-summary research\experiments\cmoea-aop\studies\S12_portfolio_ablation_30run\trace_summary.csv --trace-phase research\experiments\cmoea-aop\studies\S12_portfolio_ablation_30run\trace_phase_summary.csv
```

S12 要回答：

```text
SCOP 是否优于单算子、均匀比例、随机比例和人工阶段比例。
```

## 5. S13 credit 信号消融

### 5.1 方法

```text
SCOP-CMOEA
CMOEA-AOP
EMCMO
Equal-AOP
Feasibility-Credit-AOP
CV-Credit-AOP
Objective-Credit-AOP
Mixed-Credit-AOP
Sliding-Survival-Credit-AOP
```

### 5.2 启动命令

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s13_credit_signal_30run_config
```

完成标准：

```text
MAT 文件数量 = 15120
```

### 5.3 汇总命令

```powershell
matlab -batch "cd('E:\多目标优化\PlatEMO-master'); addpath('research\experiments\cmoea-aop\scripts'); summarize_s01_results('s13_credit_signal_30run_config'); summarize_policy_traces('s13_credit_signal_30run_config');"
python research\experiments\cmoea-aop\scripts\analyze_runs.py --runs research\experiments\cmoea-aop\studies\S13_credit_signal_30run\runs.csv --problem-means research\experiments\cmoea-aop\studies\S13_credit_signal_30run\problem_means.csv --summary research\experiments\cmoea-aop\summaries\S13_credit_signal_30run_analysis.md --title "S13 credit 信号消融 30-run 统计" --baseline SCOP-CMOEA --trace-summary research\experiments\cmoea-aop\studies\S13_credit_signal_30run\trace_summary.csv --trace-phase research\experiments\cmoea-aop\studies\S13_credit_signal_30run\trace_phase_summary.csv
```

S13 要回答：

```text
survival 信号是否比 feasibility、CV、objective、mixed、sliding 更适合作为算子信用。
```

## 6. S14 参数敏感性

参数：

```text
creditAlpha = 0.12, 0.25, 0.35, 0.50
creditFloor = 0.00, 0.03, 0.05, 0.10
```

代表问题：

```text
CF3, CF6, CF8
LIRCMOP3, LIRCMOP10, LIRCMOP13
DASCMOP1, DASCMOP5, DASCMOP8
DOC4, DOC6, DOC8
MW5, MW9, MW12
```

启动：

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s14_parameter_sensitivity_config
```

完成标准：

```text
MAT 文件数量 = 4800
```

图：

```text
Python 画热力图。
x 轴 = creditFloor
y 轴 = creditAlpha
颜色 = 平均排名或平均 IGD
输出 = research/experiments/cmoea-aop/paper/figures/F_param_sensitivity.png
```

## 7. S15 RWMOP 应用

问题：

```text
RWMOP1-RWMOP20
```

算法：

```text
SCOP-CMOEA, CMOEA-AOP, EMCMO, ICMA, IMTCMO, DRLOS-EMCMO, DPCPRA, PPS
```

指标：

```text
HV, Feasible_rate, runtime
```

启动：

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s15_rwmop_application_config
```

完成标准：

```text
MAT 文件数量 = 4800
```

## 8. 图怎么画

原则：

```text
MATLAB 只负责跑算法和从 MAT 导出必要 CSV。
Python 负责统计、画图、导出 PNG/PDF。
不手工在 MATLAB Figure 窗口里调图。
```

需要新增 3 个脚本：

| 脚本 | 语言 | 作用 |
| --- | --- | --- |
| `scripts/export_final_populations.m` | MATLAB | 从代表问题 MAT 文件导出最终 PopObj/PopCon CSV |
| `scripts/export_convergence_curves.m` | MATLAB | 从 metric 结构导出每个 run 的 IGD/HV 曲线 CSV |
| `scripts/plot_paper_figures.py` | Python | 从 CSV/runs/trace 画全部论文图 |

### 8.1 论文图清单

| 图 | 数据来源 | 画图脚本 | 输出文件 |
| --- | --- | --- | --- |
| F1 算法框架图 | 手工结构数据 | Python/mermaid 二选一，最终用矢量图 | `paper/figures/F1_framework.pdf` |
| F2 机制发现图 | S01-S09 summary + 手工整理小表 | Python 画流程图 | `paper/figures/F2_discovery_path.pdf` |
| F3 最终解集散点图 | S11 代表问题最终种群 | MATLAB 导 CSV，Python 画 | `paper/figures/F3_final_solutions.pdf` |
| F4 IGD 收敛曲线 | S11 metric 曲线 | MATLAB 导 CSV，Python 画 | `paper/figures/F4_convergence_igd.pdf` |
| F5 算子比例轨迹 | S11/S12 `trace_phase_summary.csv` 和原始 trace | Python 画 | `paper/figures/F5_operator_ratios.pdf` |
| F6 survival credit 热力图 | S11/S12 `trace_summary.csv` | Python 画 | `paper/figures/F6_survival_heatmap.pdf` |
| F7 portfolio 消融柱状图 | S12 `runs.csv` | Python 画 | `paper/figures/F7_portfolio_ablation.pdf` |
| F8 credit 信号消融柱状图 | S13 `runs.csv` | Python 画 | `paper/figures/F8_credit_ablation.pdf` |
| F9 参数敏感性热力图 | S14 `runs.csv` | Python 画 | `paper/figures/F9_parameter_sensitivity.pdf` |
| F10 runtime 箱线图 | S11 `runs.csv` | Python 画 | `paper/figures/F10_runtime.pdf` |
| F11 RWMOP HV 箱线图 | S15 `runs.csv` | Python 画 | `paper/figures/F11_rwmop_hv.pdf` |

### 8.2 代表问题

最终解集图和收敛曲线先固定这些问题：

```text
CF6
LIRCMOP11
DASCMOP8
DOC8
MW9
```

如果 S11 结果显示某个问题更有代表性，再替换，但每个问题族最多保留 1 个主文图。

## 9. 表怎么做

需要新增：

```text
research/experiments/cmoea-aop/scripts/export_paper_tables.py
```

它从 `runs.csv` 和 `problem_means.csv` 生成：

| 表 | 内容 | 文件 |
| --- | --- | --- |
| T1 | benchmark 与参数设置 | `paper/tables/T1_settings.md` |
| T2 | 对比算法、年份、类别 | `paper/tables/T2_algorithms.md` |
| T3 | S11 IGD/HV 总体排名 | `paper/tables/T3_main_rank.md` |
| T4 | S11 Wilcoxon 胜/平/负 | `paper/tables/T4_wilcoxon.md` |
| T5 | 分问题族排名 | `paper/tables/T5_suite_rank.md` |
| T6 | S12 portfolio 消融 | `paper/tables/T6_portfolio_ablation.md` |
| T7 | S13 credit 消融 | `paper/tables/T7_credit_ablation.md` |
| T8 | S14 参数敏感性 | `paper/tables/T8_parameter.md` |
| T9 | S15 RWMOP HV/FR | `paper/tables/T9_rwmop.md` |
| T10 | runtime | `paper/tables/T10_runtime.md` |

主文不放 56 问题完整大表。完整大表放附录：

```text
paper/tables/appendix_igd_full.csv
paper/tables/appendix_hv_full.csv
```

## 10. 当前最小可执行路线

按这个顺序做，不再中途改方向：

```text
1. 启动 S11。
2. 每 2-3 小时检查一次 MAT 数量和错误日志。
3. S11 到 16800 后，导出 runs.csv、trace_summary.csv、problem_means.csv。
4. 生成 S11 统计摘要，确认 SCOP 的 30-run 排名和胜负。
5. 启动 S12 和 S13，可同时开两批，但总 MATLAB worker 不超过 12-14。
6. S12/S13 完成后先生成消融表和轨迹图。
7. 再启动 S14。
8. 最后启动 S15。
9. 数据全齐后写 `export_paper_tables.py` 和 `plot_paper_figures.py`，生成全部表图。
```

20 线程 CPU 建议：

```text
普通阶段：12 个 MATLAB worker
如果内存稳定且无明显卡顿：14 个 worker
不要开 GPU
每个 MATLAB 内部 maxNumCompThreads(1)
```

## 11. 第一条马上执行的命令

```powershell
.\research\experiments\cmoea-aop\scripts\start_s10a_cpu_workers.ps1 -WorkerCount 12 -ConfigName s11_main_30run_config
```
