# S10/S11 全面实验参数口径

## 1. 目标

全面实验的参数要满足三个要求：

```text
和 CMOEA-AOP 原论文可比；
和 2026 年 CMOP 论文的常用设置一致；
计算量可控，可以先筛选再做论文级确认。
```

因此，主实验不采用某一篇论文的特殊预算，而采用领域里最常见、最容易解释的一组公共参数。

## 2. 文献参数调研

| 论文或方法 | 测试集 | 种群规模 | 评价预算 | 独立运行 | 指标与统计 |
| --- | --- | --- | --- | --- | --- |
| CMOEA-AOP | CF, LIR-CMOP, DAS-CMOP，共 33 个 | 100 | 100000 | 30 | IGD, Wilcoxon rank-sum 0.05 |
| DGCMOEA | CF, DAS-CMOP, DOC, LIR-CMOP，共 42 个 | 100 | 100000 | 30 | IGD, HV, feasible solution ratio, Wilcoxon |
| VCGDPEA | LIR-CMOP, MW, CF, DAS-CMOP，共 47 个 | 100 | LIR-CMOP 200000，其它 100000 | 30 | IGD, HV, Wilcoxon, Friedman |
| TriMT-EA | LIR-CMOP, MW, DAS-CMOP, CF, RWMOP | 100 | LIR 300000, DAS 200000, CF/MW/RW 100000 | 30 | IGD, HV, Wilcoxon, Friedman |
| ARACMO | DASCMOP, C-DTLZ/DC-DTLZ, LIR-CMOP, MW | 100 | DAS/LIR 300000, DTLZ/MW 100000 | 30 | IGD, HV, Wilcoxon, Friedman |
| ACREA | LIR-CMOP, DASCMOP, ZXH-CF, RWMOP | 100 | 100000 | 30 | benchmark 用 IGD，真实问题用 HV，Wilcoxon, Friedman |
| DPCMOEA | MW, DASCMOP, LIRCMOP, DOC, C-DTLZ/DC-DTLZ, CF | 100 | 3e6 | 30 | benchmark 用 IGD，真实问题用 HV，Wilcoxon |
| DEPEA | DCMOP, FCP, MW, DAS-CMOP, real-world CMOPs | 未统一采用为本实验直接依据 | 300000 | 30 | IGD+, HV, Wilcoxon |
| PRCEA | DASCMOP, FCP, SDC, LSCM，大规模约束测试 | 100 | 5000*n | 31 | IGD, IGD+, HV, Wilcoxon, Friedman |

可以看到，最稳定的共识是：

```text
N = 100
runs = 30
Wilcoxon 0.05
Friedman average rank
IGD 和 HV 是核心指标
```

差异最大的是 `maxFE`。有些论文统一 100000，有些对 LIR-CMOP、DAS-CMOP 给 200000 到 300000，还有少数大规模或多约束论文使用更高预算。

## 3. 我们采用的主实验参数

主实验建议采用：

```text
N = 100
maxFE = 100000
runs = 30
metrics = IGD, HV, Feasible_rate, runtime
statistics = Wilcoxon rank-sum test 0.05 + Friedman average rank
```

理由：

```text
1. 与 CMOEA-AOP 原论文完全一致，便于说明我们不是靠更大预算获得优势。
2. 与 DGCMOEA、ACREA 等多篇 2026 CMOP 论文的常用预算一致。
3. 对 56 个问题和多个 baseline 来说计算量仍然可控。
4. SCOP-CMOEA 的故事强调轻量、可解释、在线反馈，不宜把主优势建立在超长评价预算上。
```

对于所有对比算法，使用 PlatEMO 默认参数，不额外为某个算法单独调参。这样可以避免实验被质疑为人工偏向某个方法。

## 4. 为什么主实验不直接用更大 FE

部分论文对 LIR-CMOP 和 DAS-CMOP 使用 200000 或 300000 FE，但不建议把它作为第一主实验预算。

原因是：

```text
1. CMOEA-AOP 原论文使用 100000 FE，我们需要先保持直接可比。
2. 22 个算法、56 个问题、30 次运行时，计算量已经很大。
3. 更高 FE 会改变算法优势来源，一些慢热算法可能受益更多，不利于先判断 SCOP 的基本竞争力。
4. 高预算适合作为补充稳健性实验，而不是第一主表。
```

因此，高预算实验建议放在补充实验中：

```text
只选择 S10/S11 中排名靠前或机制上最相关的 5 到 8 个算法；
只在 LIR-CMOP 和 DAS-CMOP 上跑；
maxFE = 300000；
runs = 30。
```

## 5. 分阶段实验设置

### S10a：PlatEMO 宽筛实验

作用：先用较多算法判断哪些 baseline 值得进入论文级确认。

```text
算法：22 个
问题：CF + LIR-CMOP + DAS-CMOP + MW + DOC，共 56 个
N = 100
maxFE = 100000
runs = 5
指标：IGD, HV, Feasible_rate, runtime
任务量：22 * 56 * 5 = 6160 runs
```

S10a 的结果不作为论文最终显著性结论，只用于筛选算法、发现失败问题和估计运行时间。

### S11：论文级外部确认实验

作用：形成论文主表。

```text
算法：从 S10a 中选择 10 到 12 个
问题：核心 56 个
N = 100
maxFE = 100000
runs = 30
指标：IGD, HV, Feasible_rate, runtime
任务量：约 10~12 * 56 * 30 = 16800~20160 runs
```

进入 S11 的算法不只按平均排名选，还要保留代表性：

```text
SCOP-CMOEA 必保留；
EMCMO 必保留；
CMOEA-AOP 必保留；
DRLOS-EMCMO 建议保留；
经典约束处理、多阶段、双种群、多任务、近年强 baseline 各保留代表算法。
```

### S12：扩展测试和应用实验

作用：补充论文完整性，而不是替代 S11。

优先顺序：

```text
RWMOP1-RWMOP20：真实工程问题，使用 HV、Feasible_rate、runtime。
RWMOP1-RWMOP50：如果前 20 个结果稳定，再扩展。
LIR-CMOP + DAS-CMOP 高预算：maxFE = 300000，只跑精选算法。
C-DTLZ / DC-DTLZ：如果最终保留约束优先级或多约束算法作为强 baseline。
FCP / ZXH-CF / SDC / LSCM：作为机制边界或大规模补充，不放入第一主实验。
```

## 6. 指标和统计口径

每个问题上报告：

```text
IGD mean(std)
HV mean(std)
Feasible_rate mean(std)
runtime mean(std)
```

总体统计报告：

```text
相对 SCOP-CMOEA 的 win/tie/loss；
每个测试集上的 Friedman average rank；
全 56 问题上的 Friedman average rank；
失败运行数量和无可行解问题列表；
SCOP-CMOEA 的算子比例轨迹，用于解释机制。
```

显著性检验：

```text
每个问题上使用 Wilcoxon rank-sum test，显著性水平 0.05；
跨问题总体排名使用 Friedman average rank；
必要时补充 Holm/Nemenyi post-hoc，但不作为第一批必须项。
```

## 7. 当前结论

建议现在采用下面的主参数：

```text
N = 100
maxFE = 100000
runs = 30 用于论文级确认
runs = 5 用于 S10a 宽筛
metrics = IGD + HV + Feasible_rate + runtime
statistics = Wilcoxon 0.05 + Friedman rank
```

这个参数口径最稳：它和 CMOEA-AOP 原论文可比，也和 2026 年多数 CMOP 论文一致，同时不会把实验拖入过大的计算预算。
