# S05 候选方法确认实验结果

## 统计口径

- 行数：1320。
- 算法数：8。
- 问题数：33。
- 排名主指标：每个问题上各 run 的 IGD。
- 严格失败规则：某算法在某问题上只要有一个 run 的 `IGD` 或 `Feasible_rate` 为 NaN，或 `Feasible_rate <= 0`，该算法在该问题的严格 IGD 记为 `Inf`。
- 该规则偏保守，目的是把可行性不稳定显式暴露出来。

## 总体排名

| 算法 | 平均排名 | 问题胜场 | 失败行数 | 失败问题数 |
| --- | ---: | ---: | ---: | ---: |
| Survival-Credit-AOP | 3.788 | 4 | 0 | 0 |
| Equal-AOP | 3.955 | 5 | 1 | 1 |
| Dual-Survival-Credit-AOP | 3.970 | 3 | 0 | 0 |
| Dual-Feasibility-Explore-AOP | 4.424 | 4 | 2 | 2 |
| Objective-Credit-AOP | 4.455 | 3 | 0 | 0 |
| Stage-AOP | 4.636 | 1 | 4 | 4 |
| CMOEA-AOP | 5.045 | 5 | 8 | 5 |
| EMCMO | 5.727 | 8 | 0 | 0 |

## 分问题族排名

| 算法 | CF | LIR-CMOP | DAS-CMOP |
| --- | ---: | ---: | ---: |
| Survival-Credit-AOP | 3.500 | 4.214 | 3.444 |
| Equal-AOP | 3.700 | 4.214 | 3.833 |
| Dual-Survival-Credit-AOP | 4.700 | 4.000 | 3.111 |
| Dual-Feasibility-Explore-AOP | 4.000 | 4.000 | 5.556 |
| Objective-Credit-AOP | 4.400 | 4.786 | 4.000 |
| Stage-AOP | 4.100 | 4.500 | 5.444 |
| CMOEA-AOP | 4.500 | 4.500 | 6.500 |
| EMCMO | 7.100 | 5.786 | 4.111 |

## 相对 CMOEA-AOP 的问题级胜负

| 算法 | 胜 | 负 | 平 |
| --- | ---: | ---: | ---: |
| Equal-AOP | 21 | 11 | 1 |
| Objective-Credit-AOP | 21 | 12 | 0 |
| Survival-Credit-AOP | 21 | 12 | 0 |
| Dual-Feasibility-Explore-AOP | 20 | 11 | 2 |
| Dual-Survival-Credit-AOP | 20 | 13 | 0 |
| Stage-AOP | 16 | 13 | 4 |
| EMCMO | 11 | 22 | 0 |

## 机制轨迹摘要

下表只统计存在 `policyTrace` 的算法；EMCMO 如果没有轨迹记录，会自然缺席。

| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 | 可行率最高算子 | 存活率最高算子 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Dual-Feasibility-Explore-AOP | 0.500 | 0.000 | 0.500 | 0.400 | GA | GA |
| Dual-Survival-Credit-AOP | 0.425 | 0.250 | 0.325 | 0.064 | GA | GA |
| Equal-AOP | 0.333 | 0.333 | 0.333 | 0.000 | DE/best | GA |
| Objective-Credit-AOP | 0.341 | 0.323 | 0.336 | 0.000 | DE/best | GA |
| Stage-AOP | 0.305 | 0.345 | 0.350 | 0.000 | DE/best | GA |
| Survival-Credit-AOP | 0.376 | 0.299 | 0.326 | 0.000 | DE/best | GA |

### 阶段比例

| 算法 | 阶段 | GA比例 | DE/rand比例 | DE/best比例 |
| --- | --- | ---: | ---: | ---: |
| Dual-Feasibility-Explore-AOP | 早期 | 0.500 | 0.000 | 0.500 |
| Dual-Feasibility-Explore-AOP | 中期 | 0.500 | 0.000 | 0.500 |
| Dual-Feasibility-Explore-AOP | 后期 | 0.500 | 0.000 | 0.500 |
| Dual-Survival-Credit-AOP | 早期 | 0.475 | 0.191 | 0.334 |
| Dual-Survival-Credit-AOP | 中期 | 0.426 | 0.256 | 0.319 |
| Dual-Survival-Credit-AOP | 后期 | 0.385 | 0.289 | 0.326 |
| Equal-AOP | 早期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 中期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 后期 | 0.333 | 0.333 | 0.333 |
| Objective-Credit-AOP | 早期 | 0.351 | 0.317 | 0.332 |
| Objective-Credit-AOP | 中期 | 0.340 | 0.323 | 0.337 |
| Objective-Credit-AOP | 后期 | 0.334 | 0.327 | 0.339 |
| Stage-AOP | 早期 | 0.200 | 0.600 | 0.200 |
| Stage-AOP | 中期 | 0.332 | 0.336 | 0.332 |
| Stage-AOP | 后期 | 0.350 | 0.152 | 0.498 |
| Survival-Credit-AOP | 早期 | 0.460 | 0.213 | 0.327 |
| Survival-Credit-AOP | 中期 | 0.365 | 0.313 | 0.322 |
| Survival-Credit-AOP | 后期 | 0.324 | 0.347 | 0.330 |

机制读法：如果某个方法最终指标接近 CMOEA-AOP，同时轨迹更简单、阶段更清晰或双种群分化更明显，它就比单纯排名更有研究价值。

## 初步结论

- 在严格可行性口径下，当前平均排名最好的方法是 `Survival-Credit-AOP`。
- 有若干简单或可解释方法的平均排名优于基线，这说明研究重点可以放在机制解释和结构化控制，而不是只复现 DDPG。
- 双种群方向中当前较值得继续看的方法是 `Dual-Survival-Credit-AOP`，它直接对应 EMCMO 两个种群的角色差异。
- 单控制器 credit 方向中当前较值得保留的是 `Survival-Credit-AOP`。
- 机制轨迹应优先用于解释“为什么接近或优于 CMOEA-AOP”，尤其关注阶段比例变化和两个种群是否自然分化。
- 这些结果仍属于探索/确认阶段，正式论文级结论还需要更高 runs 和显著性检验。
