# S10 外部算法快速对比实验计划

## 目标

S10 的目标是把 `SCOP-CMOEA` 从内部消融实验推进到外部算法对比。这里不再把它写成 `CMOEA_AOP_Lab` 的一个参数变体，而是使用正式算法入口 `SCOP_CMOEA`。

本实验回答三个问题：

1. `SCOP-CMOEA` 面对常用 CMOEA 基线时是否进入第一梯队；
2. 它的优势是否只存在于 CMOEA-AOP 原论文的 33 个问题，还是能扩展到 MW 和 DOC；
3. 它的失败问题集中在哪些测试集上，后续是否需要做 stage prior、双种群信用或真实问题验证。

## 参考 2026 论文后的实验设计

2026 年相关论文的实验通常包含三层：

- 标准 benchmark：LIR-CMOP、DAS-CMOP、MW、CF、DOC、C-DTLZ/DC-DTLZ 等；
- 外部强基线：多阶段、双种群、多任务、强化学习或资源分配类 CMOEA；
- 真实问题：RWMOP、机械设计、电力调度、UAV 路径规划、水库调度或能源系统调度。

S10 先做第一层和第二层，真实问题放到 S12。

## 算法集合

最小外部对比集合为 10 个算法：

| 类型 | 算法 |
| --- | --- |
| 主方法 | SCOP-CMOEA |
| 骨架基线 | EMCMO |
| 直接相关 | CMOEA-AOP |
| 强化学习单算子选择 | DRLOS-EMCMO |
| 经典双档案 | C-TAEA |
| 多阶段 | PPS |
| 多阶段 | ToP |
| 多任务/协同 | C3M |
| 双种群协同 | BiCo |
| 多搜索/辅助 | CMOEA-MS |

如果 S10 结果进入第一梯队，S11 再扩展到 `CCMO`、`CMOEMT`、`MTCMO`、`CMOES` 等算法。

## 测试问题

S10 使用 56 个问题：

```text
CF: 10
LIR-CMOP: 14
DAS-CMOP: 9
MW: 14
DOC: 9
```

其中前 33 个问题与 CMOEA-AOP 原论文和 S09 一致；MW 和 DOC 用于检验泛化能力。

## 运行设置

```text
N = 100
maxFE = 100000
runs = 10
metrics = IGD, HV, Feasible_rate
```

理论任务数：

```text
10 algorithms * 56 problems * 10 runs = 5600 runs
```

建议并行运行多个 MATLAB worker。完成后再根据失败情况用 `run_missing_experiment` 补跑。

## 后续判断

如果 `SCOP-CMOEA` 在总体平均排名和多个问题族上进入前三，进入 S11 论文级确认。

如果只在 CF/LIR/DAS 有优势，但 MW/DOC 明显下降，需要先做一个小规模 S10b：

```text
SCOP-CMOEA
SCOP-CMOEA + weak stage prior
Dual-Survival-Credit-AOP
Role-Separated-Credit-AOP-v2
BiSCOP-CMOEA
```

如果外部强基线明显压过 SCOP-CMOEA，但 SCOP 仍显著优于 EMCMO 和 CMOEA-AOP，则论文可以转为“轻量可解释 operator portfolio”路线，与部分强基线比较，不强行宣称全局最好。

## 可独立成算法的变体判断

当前最适合作为主算法的是 `SCOP-CMOEA`。

可以作为独立算法候选但暂不建议抢主线的变体：

- `Dual-SCOP-CMOEA`：两个种群分别维护 survival credit。思想清楚，但 S09 没有超过单控制器 SCOP。
- `BiSCOP-CMOEA`：双种群软耦合 survival credit。结构更像新算法，但 S09 排名不如 SCOP，适合作为扩展或消融。
- `Role-Separated-Credit-AOP-v2`：主种群偏可行收敛、辅助种群偏探索。CF 上有优势，但泛化不足，适合写成问题依赖机制。
- `SCOP-CMOEA + weak stage prior`：如果后续实验显示能稳定提升，最有潜力成为第二版主算法。

不建议作为独立算法的变体：

- `Equal-AOP`：重要基线，不是新算法；
- `Random-AOP`：重要基线，不是新算法；
- `Stage-AOP`：表现强但规则手写，更适合作为阶段规律对照；
- `Objective/CV/Feasibility-Credit`：除非后续显著优于 survival credit，否则作为信用信号消融即可。

