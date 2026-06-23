# S07 双种群角色化 Credit 实验结果

## 统计口径

- 行数：1485。
- 算法数：9。
- 问题数：33。
- 排名主指标：每个问题上各 run 的 IGD。
- 严格失败规则：某算法在某问题上只要有一个 run 的 `IGD` 或 `Feasible_rate` 为 NaN，或 `Feasible_rate <= 0`，该算法在该问题的严格 IGD 记为 `Inf`。
- 该规则偏保守，目的是把可行性不稳定显式暴露出来。

## 总体排名

| 算法 | 平均排名 | 问题胜场 | 失败行数 | 失败问题数 |
| --- | ---: | ---: | ---: | ---: |
| Dual-Survival-Credit-AOP | 4.182 | 4 | 0 | 0 |
| Dual-Role-Credit-AOP-v3 | 4.545 | 3 | 0 | 0 |
| Dual-Role-Credit-AOP-v2 | 4.667 | 3 | 0 | 0 |
| Equal-AOP | 4.727 | 3 | 0 | 0 |
| Survival-Credit-AOP | 4.848 | 0 | 0 | 0 |
| Dual-Role-Credit-AOP-v1 | 4.939 | 1 | 0 | 0 |
| Objective-Credit-AOP | 5.167 | 2 | 1 | 1 |
| CMOEA-AOP | 5.439 | 9 | 7 | 4 |
| EMCMO | 6.485 | 8 | 0 | 0 |

## 分问题族排名

| 算法 | CF | LIR-CMOP | DAS-CMOP |
| --- | ---: | ---: | ---: |
| Dual-Survival-Credit-AOP | 4.600 | 3.643 | 4.556 |
| Dual-Role-Credit-AOP-v3 | 3.800 | 4.857 | 4.889 |
| Dual-Role-Credit-AOP-v2 | 5.600 | 4.500 | 3.889 |
| Equal-AOP | 3.700 | 5.143 | 5.222 |
| Survival-Credit-AOP | 5.800 | 4.643 | 4.111 |
| Dual-Role-Credit-AOP-v1 | 4.700 | 5.429 | 4.444 |
| Objective-Credit-AOP | 3.900 | 5.143 | 6.611 |
| CMOEA-AOP | 5.300 | 4.714 | 6.722 |
| EMCMO | 7.600 | 6.929 | 4.556 |

## 相对 CMOEA-AOP 的问题级胜负

| 算法 | 胜 | 负 | 平 |
| --- | ---: | ---: | ---: |
| Equal-AOP | 21 | 12 | 0 |
| Dual-Role-Credit-AOP-v1 | 20 | 13 | 0 |
| Dual-Role-Credit-AOP-v3 | 20 | 13 | 0 |
| Dual-Survival-Credit-AOP | 20 | 13 | 0 |
| Dual-Role-Credit-AOP-v2 | 19 | 14 | 0 |
| Survival-Credit-AOP | 18 | 15 | 0 |
| Objective-Credit-AOP | 17 | 15 | 1 |
| EMCMO | 11 | 22 | 0 |

## 机制轨迹摘要

下表只统计存在 `policyTrace` 的算法；EMCMO 如果没有轨迹记录，会自然缺席。

| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 | 可行率最高算子 | 存活率最高算子 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Dual-Role-Credit-AOP-v1 | 0.366 | 0.286 | 0.348 | 0.030 | DE/best | GA |
| Dual-Role-Credit-AOP-v2 | 0.362 | 0.292 | 0.346 | 0.026 | DE/best | GA |
| Dual-Role-Credit-AOP-v3 | 0.363 | 0.291 | 0.347 | 0.028 | DE/best | GA |
| Dual-Survival-Credit-AOP | 0.427 | 0.248 | 0.325 | 0.063 | GA | GA |
| Equal-AOP | 0.333 | 0.333 | 0.333 | 0.000 | DE/best | GA |
| Objective-Credit-AOP | 0.341 | 0.322 | 0.337 | 0.000 | DE/best | GA |
| Survival-Credit-AOP | 0.374 | 0.299 | 0.327 | 0.000 | DE/best | GA |

### 阶段比例

| 算法 | 阶段 | GA比例 | DE/rand比例 | DE/best比例 |
| --- | --- | ---: | ---: | ---: |
| Dual-Role-Credit-AOP-v1 | 早期 | 0.378 | 0.279 | 0.342 |
| Dual-Role-Credit-AOP-v1 | 中期 | 0.366 | 0.286 | 0.347 |
| Dual-Role-Credit-AOP-v1 | 后期 | 0.357 | 0.291 | 0.352 |
| Dual-Role-Credit-AOP-v2 | 早期 | 0.376 | 0.283 | 0.342 |
| Dual-Role-Credit-AOP-v2 | 中期 | 0.361 | 0.293 | 0.346 |
| Dual-Role-Credit-AOP-v2 | 后期 | 0.352 | 0.296 | 0.351 |
| Dual-Role-Credit-AOP-v3 | 早期 | 0.371 | 0.286 | 0.342 |
| Dual-Role-Credit-AOP-v3 | 中期 | 0.365 | 0.290 | 0.346 |
| Dual-Role-Credit-AOP-v3 | 后期 | 0.353 | 0.295 | 0.352 |
| Dual-Survival-Credit-AOP | 早期 | 0.477 | 0.191 | 0.332 |
| Dual-Survival-Credit-AOP | 中期 | 0.431 | 0.251 | 0.318 |
| Dual-Survival-Credit-AOP | 后期 | 0.381 | 0.290 | 0.329 |
| Equal-AOP | 早期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 中期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 后期 | 0.333 | 0.333 | 0.333 |
| Objective-Credit-AOP | 早期 | 0.351 | 0.317 | 0.332 |
| Objective-Credit-AOP | 中期 | 0.340 | 0.323 | 0.337 |
| Objective-Credit-AOP | 后期 | 0.335 | 0.326 | 0.339 |
| Survival-Credit-AOP | 早期 | 0.457 | 0.217 | 0.326 |
| Survival-Credit-AOP | 中期 | 0.364 | 0.312 | 0.323 |
| Survival-Credit-AOP | 后期 | 0.322 | 0.345 | 0.332 |

机制读法：如果某个方法最终指标接近 CMOEA-AOP，同时轨迹更简单、阶段更清晰或双种群分化更明显，它就比单纯排名更有研究价值。

## 初步结论

- 在严格可行性口径下，当前平均排名最好的方法是 `Dual-Survival-Credit-AOP`。
- 有若干简单或可解释方法的平均排名优于基线，这说明研究重点可以放在机制解释和结构化控制，而不是只复现 DDPG。
- 双种群方向中当前较值得继续看的方法是 `Dual-Survival-Credit-AOP`，它直接对应 EMCMO 两个种群的角色差异。
- 单控制器 credit 方向中当前较值得保留的是 `Survival-Credit-AOP`。
- 机制轨迹应优先用于解释“为什么接近或优于 CMOEA-AOP”，尤其关注阶段比例变化和两个种群是否自然分化。
- 这些结果仍属于探索/确认阶段，正式论文级结论还需要更高 runs 和显著性检验。

## 人工解读

S07 的结果不支持“当前三个 Dual-Role 版本已经优于 Dual-Survival-Credit-AOP”。更准确的结论是：

- `Dual-Role-Credit-AOP-v1/v2/v3` 都稳定优于原始 `CMOEA-AOP`，并且没有失败行，说明角色化 credit 方向没有破坏稳定性。
- 三个 Dual-Role 版本中，`v3` 的总体排名最好，`v2` 在 DAS-CMOP 上最好。`v1` 相对较弱。
- 当前最强、最稳的仍是 `Dual-Survival-Credit-AOP`。它没有显式区分主种群和辅助种群的 credit 含义，但平均排名最好。
- 机制轨迹显示，三个 Dual-Role 版本的双种群分化度只有 0.026-0.030，明显低于 `Dual-Survival-Credit-AOP` 的 0.063。这说明当前角色化信号太温和，两个种群最后学到的比例仍然比较接近。
- 因此，S07 的价值不是证明 Dual-Role 已经成功，而是发现了一个关键问题：仅仅把主种群 credit 写成约束信号、辅助种群 credit 写成目标信号，还不足以产生清晰的角色分化。

## 下一步筛选建议

如果进入更高预算确认，建议保留：

- `CMOEA-AOP`
- `EMCMO`
- `Equal-AOP`
- `Survival-Credit-AOP`
- `Dual-Survival-Credit-AOP`
- `Dual-Role-Credit-AOP-v3`
- `Dual-Role-Credit-AOP-v2`

其中：

- `Dual-Survival-Credit-AOP` 是当前主候选方法。
- `Dual-Role-Credit-AOP-v3` 是当前最好的角色化版本。
- `Dual-Role-Credit-AOP-v2` 在 DAS-CMOP 上有价值，可以作为困难约束问题的角色化候选。

如果继续做方法创新，而不是直接做高预算确认，下一步应该强化角色分化，例如引入软先验比例、问题阶段相关权重，或让主种群和辅助种群使用不同探索下限。
