# S08 强角色分离 Credit 探索实验结果

## 统计口径

- 行数：1650。
- 算法数：10。
- 问题数：33。
- 排名主指标：每个问题上各 run 的 IGD。
- 严格失败规则：某算法在某问题上只要有一个 run 的 `IGD` 或 `Feasible_rate` 为 NaN，或 `Feasible_rate <= 0`，该算法在该问题的严格 IGD 记为 `Inf`。
- 该规则偏保守，目的是把可行性不稳定显式暴露出来。

## 总体排名

| 算法 | 平均排名 | 问题胜场 | 失败行数 | 失败问题数 |
| --- | ---: | ---: | ---: | ---: |
| Survival-Credit-AOP | 4.303 | 9 | 0 | 0 |
| Dual-Survival-Credit-AOP | 4.727 | 3 | 0 | 0 |
| Dual-Role-Credit-AOP-v3 | 5.030 | 2 | 0 | 0 |
| Dual-Role-Credit-AOP-v2 | 5.212 | 3 | 0 | 0 |
| Role-Separated-Credit-AOP-v1 | 5.242 | 2 | 0 | 0 |
| Role-Separated-Credit-AOP-v2 | 5.576 | 4 | 0 | 0 |
| Role-Separated-Credit-AOP-v3 | 5.682 | 4 | 1 | 1 |
| Equal-AOP | 6.000 | 1 | 1 | 1 |
| Role-Separated-Credit-AOP-v4 | 6.182 | 1 | 1 | 1 |
| CMOEA-AOP | 7.045 | 4 | 6 | 4 |

## 分问题族排名

| 算法 | CF | LIR-CMOP | DAS-CMOP |
| --- | ---: | ---: | ---: |
| Survival-Credit-AOP | 4.800 | 4.143 | 4.000 |
| Dual-Survival-Credit-AOP | 4.200 | 5.143 | 4.667 |
| Dual-Role-Credit-AOP-v3 | 5.400 | 5.286 | 4.222 |
| Dual-Role-Credit-AOP-v2 | 5.100 | 5.929 | 4.222 |
| Role-Separated-Credit-AOP-v1 | 5.800 | 5.286 | 4.556 |
| Role-Separated-Credit-AOP-v2 | 5.700 | 5.214 | 6.000 |
| Role-Separated-Credit-AOP-v3 | 4.300 | 6.643 | 5.722 |
| Equal-AOP | 6.900 | 4.929 | 6.667 |
| Role-Separated-Credit-AOP-v4 | 5.300 | 6.571 | 6.556 |
| CMOEA-AOP | 7.500 | 5.857 | 8.389 |

## 相对 CMOEA-AOP 的问题级胜负

| 算法 | 胜 | 负 | 平 |
| --- | ---: | ---: | ---: |
| Dual-Role-Credit-AOP-v3 | 25 | 8 | 0 |
| Role-Separated-Credit-AOP-v1 | 24 | 9 | 0 |
| Dual-Survival-Credit-AOP | 23 | 10 | 0 |
| Survival-Credit-AOP | 23 | 10 | 0 |
| Role-Separated-Credit-AOP-v3 | 22 | 10 | 1 |
| Dual-Role-Credit-AOP-v2 | 22 | 11 | 0 |
| Role-Separated-Credit-AOP-v4 | 20 | 12 | 1 |
| Role-Separated-Credit-AOP-v2 | 20 | 13 | 0 |
| Equal-AOP | 19 | 13 | 1 |

## 机制轨迹摘要

下表只统计存在 `policyTrace` 的算法；EMCMO 如果没有轨迹记录，会自然缺席。

| 算法 | GA比例 | DE/rand比例 | DE/best比例 | 双种群分化度 | 可行率最高算子 | 存活率最高算子 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Dual-Role-Credit-AOP-v2 | 0.362 | 0.292 | 0.346 | 0.026 | DE/best | GA |
| Dual-Role-Credit-AOP-v3 | 0.365 | 0.288 | 0.346 | 0.028 | DE/best | GA |
| Dual-Survival-Credit-AOP | 0.432 | 0.247 | 0.321 | 0.065 | GA | GA |
| Equal-AOP | 0.333 | 0.333 | 0.333 | 0.000 | GA | GA |
| Role-Separated-Credit-AOP-v1 | 0.392 | 0.225 | 0.383 | 0.141 | GA | GA |
| Role-Separated-Credit-AOP-v2 | 0.429 | 0.173 | 0.398 | 0.242 | GA | GA |
| Role-Separated-Credit-AOP-v3 | 0.397 | 0.227 | 0.376 | 0.139 | GA | GA |
| Role-Separated-Credit-AOP-v4 | 0.413 | 0.200 | 0.387 | 0.187 | GA | GA |
| Survival-Credit-AOP | 0.377 | 0.300 | 0.323 | 0.000 | DE/best | GA |

### 阶段比例

| 算法 | 阶段 | GA比例 | DE/rand比例 | DE/best比例 |
| --- | --- | ---: | ---: | ---: |
| Dual-Role-Credit-AOP-v2 | 早期 | 0.377 | 0.283 | 0.341 |
| Dual-Role-Credit-AOP-v2 | 中期 | 0.361 | 0.294 | 0.345 |
| Dual-Role-Credit-AOP-v2 | 后期 | 0.352 | 0.297 | 0.351 |
| Dual-Role-Credit-AOP-v3 | 早期 | 0.372 | 0.286 | 0.342 |
| Dual-Role-Credit-AOP-v3 | 中期 | 0.367 | 0.288 | 0.345 |
| Dual-Role-Credit-AOP-v3 | 后期 | 0.357 | 0.291 | 0.352 |
| Dual-Survival-Credit-AOP | 早期 | 0.471 | 0.195 | 0.334 |
| Dual-Survival-Credit-AOP | 中期 | 0.436 | 0.250 | 0.314 |
| Dual-Survival-Credit-AOP | 后期 | 0.394 | 0.285 | 0.321 |
| Equal-AOP | 早期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 中期 | 0.333 | 0.333 | 0.333 |
| Equal-AOP | 后期 | 0.333 | 0.333 | 0.333 |
| Role-Separated-Credit-AOP-v1 | 早期 | 0.399 | 0.224 | 0.378 |
| Role-Separated-Credit-AOP-v1 | 中期 | 0.392 | 0.225 | 0.383 |
| Role-Separated-Credit-AOP-v1 | 后期 | 0.387 | 0.227 | 0.386 |
| Role-Separated-Credit-AOP-v2 | 早期 | 0.433 | 0.174 | 0.393 |
| Role-Separated-Credit-AOP-v2 | 中期 | 0.430 | 0.172 | 0.399 |
| Role-Separated-Credit-AOP-v2 | 后期 | 0.426 | 0.173 | 0.401 |
| Role-Separated-Credit-AOP-v3 | 早期 | 0.363 | 0.248 | 0.388 |
| Role-Separated-Credit-AOP-v3 | 中期 | 0.400 | 0.228 | 0.371 |
| Role-Separated-Credit-AOP-v3 | 后期 | 0.419 | 0.207 | 0.374 |
| Role-Separated-Credit-AOP-v4 | 早期 | 0.412 | 0.208 | 0.380 |
| Role-Separated-Credit-AOP-v4 | 中期 | 0.416 | 0.196 | 0.388 |
| Role-Separated-Credit-AOP-v4 | 后期 | 0.410 | 0.199 | 0.392 |
| Survival-Credit-AOP | 早期 | 0.455 | 0.219 | 0.326 |
| Survival-Credit-AOP | 中期 | 0.367 | 0.314 | 0.319 |
| Survival-Credit-AOP | 后期 | 0.328 | 0.345 | 0.327 |

机制读法：如果某个方法最终指标接近 CMOEA-AOP，同时轨迹更简单、阶段更清晰或双种群分化更明显，它就比单纯排名更有研究价值。

## 初步结论

- 在严格可行性口径下，当前平均排名最好的方法是 `Survival-Credit-AOP`。
- 有若干简单或可解释方法的平均排名优于基线，这说明研究重点可以放在机制解释和结构化控制，而不是只复现 DDPG。
- 双种群方向中当前较值得继续看的方法是 `Dual-Survival-Credit-AOP`，它直接对应 EMCMO 两个种群的角色差异。
- 单控制器 credit 方向中当前较值得保留的是 `Survival-Credit-AOP`。
- 机制轨迹应优先用于解释“为什么接近或优于 CMOEA-AOP”，尤其关注阶段比例变化和两个种群是否自然分化。
- 这些结果仍属于探索/确认阶段，正式论文级结论还需要更高 runs 和显著性检验。

## 人工解读

S08 的关键发现不是“强角色分离版本超过了所有基线”，而是：

> 强角色分离可以显著提高双种群分化度，但分化本身不会自动带来更好性能。

具体看：

- `Role-Separated-Credit-AOP-v1/v2/v3/v4` 的双种群分化度分别为 0.141、0.242、0.139、0.187，明显高于 S07 中 `Dual-Role` 的 0.026-0.030，也高于 `Dual-Survival-Credit-AOP` 的 0.065。
- 但是平均排名最好的仍是 `Survival-Credit-AOP`，其次是 `Dual-Survival-Credit-AOP`。强分离版本没有超过它们。
- `Role-Separated-Credit-AOP-v1` 是当前最好的强角色分离版本，平均排名 5.242，且没有失败行。
- `Role-Separated-Credit-AOP-v2` 分化最强，但平均排名下降到 5.576，说明过强先验可能限制搜索。
- `Role-Separated-Credit-AOP-v3` 在 CF 问题族上排名较好，但在 LIR-CMOP 和 DAS-CMOP 上不稳，并出现 1 个失败问题。
- `Role-Separated-Credit-AOP-v4` 平滑强分离没有带来明显收益，反而排名较弱。

这说明 S07 的问题确实被解决了一半：S08 让两个种群分开了。但新的问题是：分得太开以后，性能不一定更好。当前更合理的判断是：

> 角色分离需要适度。太弱时没有机制差异，太强时损害搜索协同。

## 对论文路线的影响

S08 后，论文主线建议进一步收敛：

- 保底方法线：`Survival-Credit-AOP` 和 `Dual-Survival-Credit-AOP` 仍然最稳，适合进入 S09 高预算确认。
- 角色分离线：`Role-Separated-Credit-AOP-v1` 可以作为“适度角色分离”的代表进入 S09；`Role-Separated-Credit-AOP-v2` 可作为“强分离但性能下降”的机制对照，不一定进入正式大规模确认。
- S08 提供了一个可写的机制结论：双种群不应简单追求越分化越好，角色先验必须和 feedback 保持平衡。

## S09 候选建议

建议 S09 高预算确认保留：

- `EMCMO`
- `CMOEA-AOP`
- `Equal-AOP`
- `Survival-Credit-AOP`
- `Dual-Survival-Credit-AOP`
- `Dual-Role-Credit-AOP-v3`
- `Role-Separated-Credit-AOP-v1`

如果想保留一个强分离机制对照，可以额外加入：

- `Role-Separated-Credit-AOP-v2`

S09 的重点应从“继续找更多变体”转为“确认最稳方法 + 验证适度角色分离是否值得保留”。
