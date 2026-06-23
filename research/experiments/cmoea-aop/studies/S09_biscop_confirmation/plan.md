# S09 BiSCOP-CMOEA 确认实验计划

## 实验目的

S09 的目的不是继续解释 CMOEA-AOP，而是确认一个新的算法设计是否成立：

> 基于生存信用的双种群协同算子组合算法 BiSCOP-CMOEA。

前面 S05-S08 的实验显示，多算子共存、offspring 生存反馈和双种群分别维护信用都具有稳定价值；同时，S08 也显示强角色分离并不一定提升性能。因此 S09 将把这些发现整理成一个正式主方法，并与必要消融版本比较。

## 主方法设计

`BiSCOP-CMOEA` 使用 GA/SBX、DE/rand/1、DE/best/1 三个 offspring 生成算子。两个种群分别维护 survival credit，但每次更新时混入一个由两个种群共同统计得到的共享 survival credit。

这种设计对应三个原则：

- 用环境选择后的 offspring 存活情况作为算子信用信号；
- 两个种群允许形成不同算子偏好；
- 通过软耦合避免 S08 中观察到的过强角色分离。

## 对比算法

S09 使用 10 个算法：

| 算法 | 作用 |
| --- | --- |
| EMCMO | 原始双种群框架基线 |
| CMOEA-AOP | DDPG 算子比例控制基线 |
| Equal-AOP | 多算子共存、无反馈对照 |
| Random-AOP | 随机动态比例对照 |
| Stage-AOP | 手工阶段规则对照 |
| Survival-Credit-AOP | 单共享 survival credit 对照 |
| Dual-Survival-Credit-AOP | 双种群独立 survival credit 对照 |
| Role-Separated-Credit-AOP-v1 | 温和角色分离对照 |
| Role-Separated-Credit-AOP-v2 | 强角色分离对照 |
| BiSCOP-CMOEA | 本文主方法 |

## 实验设置

- 问题集：论文一致的 33 个问题，包括 CF1-CF10、LIRCMOP1-LIRCMOP14、DASCMOP1-DASCMOP9。
- 种群规模：`N = 100`。
- 最大评价次数：`maxFE = 100000`。
- 重复次数：10 个 seeds。
- 评价指标：`IGD`、`HV`、`Feasible_rate`。
- 总运行数：10 个算法 × 33 个问题 × 10 次 = 3300 次。

## 预期回答的问题

S09 需要回答四个问题：

1. `BiSCOP-CMOEA` 是否能稳定进入第一梯队；
2. 相比 `Equal-AOP`、`Random-AOP`、`Stage-AOP`，survival feedback 是否确实必要；
3. 相比 `Dual-Survival-Credit-AOP`，软耦合是否带来更稳定或更均衡的结果；
4. 相比 `Role-Separated-Credit-AOP-v1/v2`，适度协同是否优于显式强分工。

如果 S09 结果支持这些判断，则后续可以进入 S10 外部 SOTA 对比。
