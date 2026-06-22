# CMOEA-AOP 候选变体想法

这些想法只作为 GPT Pro 审阅的候选项，不代表已经批准修改。

## X1：可行性敏感 Reward

在 reward 中加入可行性进展，使 actor 不只被 HV improvement 引导。

审阅问题：

- reward 应该包含可行 offspring 比例、CV 下降，还是二者都包含？
- 如何避免 reward 过度偏向可行性而牺牲多样性？
- 需要什么消融实验才能分离 reward 的作用？

## X2：按约束展开的 State

用每个约束的统计特征替代或补充平均 CV。

审阅问题：

- 为保持 DDPG 稳定，约束特征数量应控制到多少？
- 特征应使用 mean CV、max CV、约束满足比例，还是 normalized CV？
- 哪些 CMOP 最适合测试这个修改？

## X3：探索下限

防止算子组合过早坍缩到单一算子。

审阅问题：

- 探索应通过 entropy floor、minimum action ratio，还是 OU noise schedule 保证？
- 探索下限是否应随 `FE/maxFE` 衰减？
- 为公平比较，需要哪个基线变体？
