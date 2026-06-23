# S09 BiSCOP-CMOEA 确认与内部消融实验结果

## 统计口径

- 行数：3297。
- 算法数：10。
- 问题数：33。
- 排名主指标：每个问题上各 run 的 IGD。
- 严格失败规则：某算法在某问题上只要有一个 run 的 `IGD` 或 `Feasible_rate` 为 NaN，或 `Feasible_rate <= 0`，该算法在该问题的严格 IGD 记为 `Inf`。
- 该规则偏保守，目的是把可行性不稳定显式暴露出来。

## 总体排名

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

## 分问题族排名

| 算法 | CF | LIR-CMOP | DAS-CMOP |
| --- | ---: | ---: | ---: |
| Survival-Credit-AOP | 4.100 | 4.429 | 3.444 |
| Stage-AOP | 4.500 | 4.714 | 4.889 |
| Role-Separated-Credit-AOP-v2 | 3.200 | 5.429 | 5.667 |
| Dual-Survival-Credit-AOP | 4.200 | 5.071 | 5.556 |
| BiSCOP-CMOEA | 5.800 | 4.571 | 4.667 |
| Random-AOP | 4.900 | 5.643 | 4.889 |
| Role-Separated-Credit-AOP-v1 | 6.200 | 5.000 | 4.778 |
| Equal-AOP | 5.400 | 5.429 | 5.111 |
| CMOEA-AOP | 6.900 | 6.143 | 8.111 |
| EMCMO | 9.800 | 8.571 | 7.889 |

## 相对 CMOEA-AOP 的问题级胜负

| 算法 | 胜 | 负 | 平 |
| --- | ---: | ---: | ---: |
| Role-Separated-Credit-AOP-v2 | 25 | 8 | 0 |
| Dual-Survival-Credit-AOP | 24 | 9 | 0 |
| Random-AOP | 24 | 9 | 0 |
| Survival-Credit-AOP | 24 | 9 | 0 |
| BiSCOP-CMOEA | 22 | 11 | 0 |
| Equal-AOP | 22 | 11 | 0 |
| Stage-AOP | 22 | 11 | 0 |
| Role-Separated-Credit-AOP-v1 | 21 | 12 | 0 |
| EMCMO | 11 | 22 | 0 |

## 机制轨迹摘要

下表只统计存在 `policyTrace` 的算法；EMCMO 如果没有轨迹记录，会自然缺席。

| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 | 可行率最高算子 | 存活率最高算子 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| BiSCOP-CMOEA | 0.376 | 0.300 | 0.324 | 0.027 | DE/best | GA |
| Dual-Survival-Credit-AOP | 0.402 | 0.272 | 0.326 | 0.069 | GA | GA |
| Equal-AOP | 0.333 | 0.333 | 0.333 | 0.000 | DE/best | GA |
| Random-AOP | 0.334 | 0.333 | 0.333 | 0.000 | GA | GA |
| Role-Separated-Credit-AOP-v1 | 0.391 | 0.225 | 0.385 | 0.143 | GA | GA |
| Role-Separated-Credit-AOP-v2 | 0.430 | 0.171 | 0.399 | 0.244 | GA | GA |
| Stage-AOP | 0.305 | 0.344 | 0.350 | 0.000 | DE/best | GA |
| Survival-Credit-AOP | 0.347 | 0.324 | 0.330 | 0.000 | DE/best | GA |

### 阶段比例

| 算法 | 阶段 | GA比例 | DE/rand比例 | DE/best比例 |
| --- | --- | ---: | ---: | ---: |
| BiSCOP-CMOEA | 早期 | 0.435 | 0.239 | 0.326 |
| BiSCOP-CMOEA | 中期 | 0.360 | 0.317 | 0.323 |
| BiSCOP-CMOEA | 后期 | 0.352 | 0.324 | 0.324 |
| Dual-Survival-Credit-AOP | 早期 | 0.460 | 0.206 | 0.334 |
| Dual-Survival-Credit-AOP | 中期 | 0.388 | 0.287 | 0.325 |
| Dual-Survival-Credit-AOP | 后期 | 0.376 | 0.304 | 0.320 |
| Equal-AOP | 早期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 中期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 后期 | 0.333 | 0.333 | 0.333 |
| Random-AOP | 早期 | 0.334 | 0.334 | 0.332 |
| Random-AOP | 中期 | 0.335 | 0.333 | 0.333 |
| Random-AOP | 后期 | 0.333 | 0.333 | 0.334 |
| Role-Separated-Credit-AOP-v1 | 早期 | 0.400 | 0.220 | 0.380 |
| Role-Separated-Credit-AOP-v1 | 中期 | 0.389 | 0.225 | 0.386 |
| Role-Separated-Credit-AOP-v1 | 后期 | 0.386 | 0.227 | 0.386 |
| Role-Separated-Credit-AOP-v2 | 早期 | 0.435 | 0.169 | 0.395 |
| Role-Separated-Credit-AOP-v2 | 中期 | 0.428 | 0.172 | 0.401 |
| Role-Separated-Credit-AOP-v2 | 后期 | 0.428 | 0.171 | 0.401 |
| Stage-AOP | 早期 | 0.200 | 0.600 | 0.200 |
| Stage-AOP | 中期 | 0.333 | 0.335 | 0.333 |
| Stage-AOP | 后期 | 0.350 | 0.151 | 0.499 |
| Survival-Credit-AOP | 早期 | 0.423 | 0.250 | 0.326 |
| Survival-Credit-AOP | 中期 | 0.327 | 0.342 | 0.331 |
| Survival-Credit-AOP | 后期 | 0.313 | 0.355 | 0.331 |

机制读法：如果某个方法最终指标接近 CMOEA-AOP，同时轨迹更简单、阶段更清晰或双种群分化更明显，它就比单纯排名更有研究价值。

## 初步结论

- 在严格可行性口径下，当前平均排名最好的方法是 `Survival-Credit-AOP`。
- 有若干简单或可解释方法的平均排名优于基线，这说明研究重点可以放在机制解释和结构化控制，而不是只复现 DDPG。
- 双种群方向中当前较值得继续看的方法是 `Dual-Survival-Credit-AOP`，它直接对应 EMCMO 两个种群的角色差异。
- 单控制器 credit 方向中当前较值得保留的是 `Survival-Credit-AOP`。
- 机制轨迹应优先用于解释“为什么接近或优于 CMOEA-AOP”，尤其关注阶段比例变化和两个种群是否自然分化。
- 这些结果仍属于探索/确认阶段，正式论文级结论还需要更高 runs 和显著性检验。

## 人工解读

S09 的核心结论不是 `BiSCOP-CMOEA` 成为最优主方法，而是更简单的 `Survival-Credit-AOP` 在 100k FE、10 seeds 下仍然最稳。它平均排名第一、没有失败行，并且相对 `CMOEA-AOP` 为 24 胜、9 负、0 平。

因此论文主线建议从 `BiSCOP-CMOEA` 调整为 `SCOP-CMOEA`：

```text
SCOP-CMOEA: Survival-Credit Operator Portfolio for Constrained Multi-objective Optimization
```

`BiSCOP-CMOEA`、`Dual-Survival-Credit-AOP` 和 `Role-Separated-Credit-AOP` 更适合作为内部消融，用来说明双种群分别控制、软耦合和强角色分离并不是必然收益。

S09 还显示 `Stage-AOP` 排名第二，说明阶段性比例信息有价值；但 Stage 是手写规则，不适合作为主算法。后续如果继续探索，可以测试 `Survival-Credit + weak stage prior`。

当前可写成论文的价值是：提出一种生存信用驱动的自适应算子组合算法，而不是围绕 CMOEA-AOP 做解释。核心主张是：在约束多目标优化中，offspring 经环境选择后的存活情况可以作为直接、低成本、可解释的算子信用信号。
