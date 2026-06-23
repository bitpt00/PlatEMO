# S09 BiSCOP-CMOEA 确认与内部消融综合分析

## 实验完成情况

S09 完成了 10 个算法、33 个论文问题、10 个 seeds、`N = 100`、`maxFE = 100000` 的确认与内部消融实验。理论任务数为 3300 次，其中 3297 次生成有效 `.mat` 结果。

剩余 3 次均为原始 `CMOEA-AOP` 在单独补跑时稳定触发内部索引越界：

- `CMOEA-AOP` on `CF6`, run 5, seed 229605；
- `CMOEA-AOP` on `LIRCMOP4`, run 2, seed 230402；
- `CMOEA-AOP` on `LIRCMOP10`, run 9, seed 231009。

统计脚本已修正为：同一问题上缺失的重复运行按失败 run 处理。因此 S09 的严格统计中，`CMOEA-AOP` 共有 4 个失败 run、4 个失败问题。

结果文件：

- `research/experiments/cmoea-aop/studies/S09_biscop_confirmation/runs.csv`
- `research/experiments/cmoea-aop/studies/S09_biscop_confirmation/problem_means.csv`
- `research/experiments/cmoea-aop/studies/S09_biscop_confirmation/trace_summary.csv`
- `research/experiments/cmoea-aop/studies/S09_biscop_confirmation/trace_phase_summary.csv`
- `research/experiments/cmoea-aop/studies/S09_biscop_confirmation/summary.md`

原始 `.mat` 和 worker 日志保存在 `research/experiments/cmoea-aop/results/S09_biscop_confirmation/`，不提交 Git。

## 总体结果

严格失败口径下的平均排名为：

| 算法 | 平均排名 | 问题胜场 | 失败行数 | 失败问题数 |
| --- | ---: | ---: | ---: | ---: |
| Survival-Credit-AOP | 4.061 | 2 | 0 | 0 |
| Stage-AOP | 4.697 | 6 | 0 | 0 |
| Role-Separated-Credit-AOP-v2 | 4.818 | 5 | 0 | 0 |
| Dual-Survival-Credit-AOP | 4.939 | 4 | 0 | 0 |
| BiSCOP-CMOEA | 4.970 | 2 | 0 | 0 |
| Random-AOP | 5.212 | 4 | 0 | 0 |
| Role-Separated-Credit-AOP-v1 | 5.303 | 3 | 0 | 0 |
| Equal-AOP | 5.333 | 3 | 0 | 0 |
| CMOEA-AOP | 6.909 | 1 | 4 | 4 |
| EMCMO | 8.758 | 3 | 0 | 0 |

这个结果最重要的信息是：

> 当前最适合作为论文主方法的不是 BiSCOP-CMOEA，而是更简单的 Survival-Credit-AOP。

如果需要正式命名，建议把 `Survival-Credit-AOP` 提升为主算法：

```text
SCOP-CMOEA: Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization
```

`BiSCOP-CMOEA` 可以作为双种群协同扩展版本保留，但 S09 不支持把它作为唯一主方法。

## 关键比较

### 1. Survival-Credit-AOP 是当前最稳的主线

`Survival-Credit-AOP` 平均排名第一，且没有失败行。相对 `CMOEA-AOP` 的问题级结果为 24 胜、9 负、0 平。

这说明生存信用本身已经足够强，不需要 DDPG，也不需要显式双种群角色分离。它更适合作为论文中的核心新算法。

### 2. BiSCOP-CMOEA 进入第一梯队，但不是最优主方法

`BiSCOP-CMOEA` 平均排名 4.970，排第 5，没有失败行。它相对 `CMOEA-AOP` 为 22 胜、11 负、0 平，相对 `Dual-Survival-Credit-AOP` 为 19 胜、14 负、0 平。

但是相对 `Survival-Credit-AOP`，`BiSCOP-CMOEA` 为 11 胜、22 负。这说明软耦合双种群 credit 虽然稳定，但没有超过单共享 survival credit。

因此 S09 的判断是：

> 双种群分别控制算子比例不是当前最有效的复杂化方向；单一 survival-credit portfolio 反而更稳。

### 3. Stage-AOP 意外较强，但不适合作为主算法

`Stage-AOP` 平均排名第二，尤其在 LIR-CMOP 上表现较好。它说明阶段性比例确实可能与问题搜索过程有关。

但 Stage-AOP 是手写规则，不具备反馈自适应机制。它更适合作为重要消融基线，说明“阶段节奏”有价值；不建议把它作为论文主算法。

后续如果继续改进，可以考虑：

```text
Survival credit + weak stage prior
```

但这应当作为后续小规模探索，而不是立刻替代当前主线。

### 4. Role-Separated-v2 对 CF 问题有效，但泛化不足

`Role-Separated-Credit-AOP-v2` 总体排名第三，在 CF 问题族平均排名第一，但在 LIR-CMOP 和 DAS-CMOP 上下降明显。

这说明强角色分离不是无效，而是问题依赖明显。它更像一种针对部分问题结构有效的机制，而不是通用主方法。

### 5. CMOEA-AOP 稳定性继续偏弱

在 100k FE、10 seeds 下，`CMOEA-AOP` 平均排名 6.909，并出现 4 个失败 run、4 个失败问题。相对多个轻量方法，它的稳定性和平均排名都不占优。

这为论文提供了很强的实验动机：

> 复杂 DDPG 控制并不是获得有效算子组合的必要条件；更简单的 survival-credit portfolio 可以取得更稳定的综合表现。

## 机制轨迹解读

主要机制指标为：

| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 |
| --- | ---: | ---: | ---: | ---: |
| Survival-Credit-AOP | 0.347 | 0.324 | 0.330 | 0.000 |
| Dual-Survival-Credit-AOP | 0.402 | 0.272 | 0.326 | 0.069 |
| BiSCOP-CMOEA | 0.376 | 0.300 | 0.324 | 0.027 |
| Role-Separated-Credit-AOP-v1 | 0.391 | 0.225 | 0.385 | 0.143 |
| Role-Separated-Credit-AOP-v2 | 0.430 | 0.171 | 0.399 | 0.244 |

`Survival-Credit-AOP` 的阶段变化为：

- 早期：GA 0.423，DE/rand 0.250，DE/best 0.326；
- 中期：GA 0.327，DE/rand 0.342，DE/best 0.331；
- 后期：GA 0.313，DE/rand 0.355，DE/best 0.331。

这条轨迹很适合写论文：它不是固定阶段规则，但自然形成了“早期更偏 GA，中后期增加 DE/rand，DE/best 保持稳定”的动态调节。也就是说，survival credit 可以从环境选择反馈中自动形成阶段行为。

## 对论文路线的影响

S09 后建议论文主线调整为：

```text
提出 SCOP-CMOEA，而不是以 BiSCOP-CMOEA 作为唯一主方法。
```

更合适的论文题目方向：

```text
一种生存信用驱动的自适应算子组合约束多目标进化算法
```

英文可写为：

```text
A Survival-Credit Driven Operator Portfolio Evolutionary Algorithm for Constrained Multi-objective Optimization
```

主要贡献可以组织为：

1. 提出 survival-credit operator portfolio，用 offspring 在环境选择中的存活情况直接评价算子有效性；
2. 设计平滑更新和最小比例保护，使 GA、DE/rand、DE/best 能够持续共存并动态调整；
3. 证明该机制相比 Equal、Random、Stage、DDPG-AOP 和 EMCMO 更稳定或更有竞争力；
4. 通过 BiSCOP、Dual-Survival 和 Role-Separated 消融说明：更复杂的双种群分工不是必然收益，过强角色分离存在泛化风险。

## 下一步建议

S09 已经足够支持把主方法从 `BiSCOP-CMOEA` 调整为 `SCOP-CMOEA`。下一步建议：

1. 在代码中增加一个正式算法入口 `SCOP_CMOEA`，不要只作为 `CMOEA_AOP_Lab` 的参数变体；
2. 做 S10 外部算法对比，至少包括 EMCMO、CMOEA-AOP、C-TAEA、ToP、PPS、CMOEA-MS、MOEA/D-IEpsilon 等；
3. 补充 Wilcoxon 显著性检验和运行时间/复杂度比较；
4. 可选做一个小规模探索：`Survival-Credit + weak stage prior`，因为 S09 中 Stage-AOP 排名第二，阶段信息可能能进一步增强主方法。

当前最稳的论文判断是：

> SCOP-CMOEA 是一个轻量、稳定、可解释的自适应算子组合算法；它的核心价值不是复现或解释 CMOEA-AOP，而是用更直接的生存信用机制提出一种新的 constrained MOEA operator portfolio 方法。
