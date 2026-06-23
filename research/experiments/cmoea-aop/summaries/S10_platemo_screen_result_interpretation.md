# S10 PlatEMO 全面对比结果解释

## 实验状态

- 实验：S10a PlatEMO 全面对比筛选。
- 规模：22 个算法、56 个约束多目标问题、每个问题 5 次独立运行，共 6160 个结果。
- 参数：N=100，maxFE=100000。
- 状态：6160/6160 已完成，MATLAB 日志未记录失败。
- 原始结果目录：`research/experiments/cmoea-aop/results/S10_external_comparison/s10_platemo_screen/`。
- 汇总表：`research/experiments/cmoea-aop/studies/S10_external_comparison/runs.csv`。
- 分问题均值表：`research/experiments/cmoea-aop/studies/S10_external_comparison/problem_means.csv`。
- 自动统计摘要：`research/experiments/cmoea-aop/summaries/S10_platemo_screen_analysis.md`。

## 最核心的信息

在严格可行性口径下，SCOP-CMOEA 的平均排名是 6.018，在 22 个算法中排名第 1。CMOEA-AOP 的平均排名是 8.705，排名第 5。

相对 CMOEA-AOP，SCOP-CMOEA 在 56 个问题上的问题级胜负为 43 胜、12 负、1 平。按问题级符号检验计算，双侧 p 值约为 3.305e-05。这个数不能替代正式 30-run Wilcoxon 检验，但在 5-run 筛选阶段已经说明：SCOP-CMOEA 的优势不是偶然集中在少数问题上。

按问题族看，SCOP-CMOEA 相对 CMOEA-AOP 的胜负如下：

| 问题族 | 胜 | 负 | 平 |
| --- | ---: | ---: | ---: |
| CF | 7 | 3 | 0 |
| LIR-CMOP | 7 | 7 | 0 |
| DAS-CMOP | 9 | 0 | 0 |
| MW | 14 | 0 | 0 |
| DOC | 6 | 2 | 1 |

这说明 SCOP-CMOEA 对 CMOEA-AOP 的优势主要来自 DAS-CMOP、MW 和 DOC，在 LIR-CMOP 上只是打平，在 CF 上有优势但不是压倒性。

## 它反映了什么机制

这组结果支持一个比“DDPG 学到了复杂策略”更清楚的机制解释：在 EMCMO 式双种群框架中，算子比例不一定需要深度强化学习来控制；只要把环境选择后的存活结果反馈给算子组合，就能形成有效的自适应算子配置。

SCOP-CMOEA 的核心不是预测未来状态，而是把每一代中“哪个算子的 offspring 真正进入下一代”作为信用信号。这个信号天然同时包含可行性、收敛性和多样性，因为最终能否存活是由约束处理和环境选择共同决定的。

这给论文故事提供了一个很好的切入点：约束多目标优化中的算子选择可以不依赖显式状态建模或外部训练，而是让环境选择本身成为算子信用分配器。

## 和其他强算法的关系

SCOP-CMOEA 并不是在每个问题族上都最强。它相对 ICMA 为 30 胜、26 负；相对 IMTCMO 为 32 胜、23 负、1 平；相对 DRLOS-EMCMO 为 31 胜、24 负、1 平。这说明它更像一个整体稳定性很强的通用方法，而不是在所有局部类型上都压倒最强专门方法。

特别是 MW 问题族上，EMCMO 的平均排名是 3.714，DPCPRA 是 5.286，SCOP-CMOEA 是 7.357。也就是说，SCOP-CMOEA 相对 CMOEA-AOP 在 MW 上 14 胜 0 负，但并不代表它是 MW 上的最好方法。这一点对论文很重要：我们不能把故事讲成“全面碾压所有算法”，而应该讲成“一个训练无关、反馈闭环、可解释的算子组合机制，在大范围基准上表现出很强的整体竞争力”。

## 对论文有没有价值

有价值，而且比之前只解释 CMOEA-AOP 更有价值。

如果 S11 的 30-run 确认实验仍然保持类似趋势，SCOP-CMOEA 可以作为一个独立算法提出。它的论文价值不在于批评 CMOEA-AOP，而在于提出一种新的控制思想：

1. 用环境选择后的存活结果作为算子信用。
2. 用信用直接调节多算子 offspring 组合比例。
3. 避免深度强化学习训练、状态设计和超参数不稳定。
4. 保留 EMCMO 双种群框架中可行性任务和无约束任务的互补作用。

可以提炼成的算法思想是：Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization。中文可以理解为“基于存活信用的算子组合约束多目标优化算法”。

## 当前结果的限制

这仍然是筛选实验，不是最终论文结论。

- 每个问题只有 5 次运行，适合筛选，不足以作为正式显著性结果。
- SCOP-CMOEA 目前仍复用 `CMOEA_AOP_Lab` 的实验实现，论文代码应整理成更独立的正式实现。
- SCOP-CMOEA 有 1 个问题出现严格失败记录：DOC5 上 1 个 run 的可行率低于完整可行口径。正式实验中需要重点复查 DOC5。
- 一些问题族上已有算法更强，因此论文实验需要报告整体排名、问题族排名和局部输赢，而不是只讲平均排名。

## 下一步建议

下一步应做 S11 30-run 确认实验，而不是马上再发散设计新方法。

推荐 S11 保留 10 到 12 个对比算法：

| 类型 | 算法 |
| --- | --- |
| 新算法 | SCOP-CMOEA |
| 直接来源/消融参照 | EMCMO、CMOEA-AOP |
| 强竞争者 | ICMA、IMTCMO、DRLOS-EMCMO |
| 问题族补充强者 | DPCPRA、CMOES、CMOEMT |
| 经典/常见约束对比 | C-TAEA、PPS、ToP |

如果运行量太大，可以优先使用 11 个算法：SCOP-CMOEA、EMCMO、CMOEA-AOP、ICMA、IMTCMO、DRLOS-EMCMO、DPCPRA、CMOES、CMOEMT、PPS、C-TAEA。ToP 在 S10a 中失败问题较多，正式主表可以考虑移到补充或不保留。

S11 的目标不是再探索，而是确认三个问题：

1. SCOP-CMOEA 是否在 30-run 下仍保持总体前列。
2. SCOP-CMOEA 相对 CMOEA-AOP 的 43/12/1 优势是否具有显著性。
3. SCOP-CMOEA 的优势是否主要来自 DAS-CMOP、MW、DOC，还是在更高 run 下问题族结构发生变化。
