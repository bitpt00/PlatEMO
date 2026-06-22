# 基准复现实验记录

## Smoke 测试

| 日期 | 算法 | 问题 | N | maxFE | Seed | 状态 | 备注 |
|---|---|---:|---:|---:|---:|---|---|
| 待定 | CMOEA-AOP | CF1 | 100 | 待定 | 待定 | 待运行 |  |
| 待定 | CMOEA-AOP | LIRCMOP1 | 100 | 待定 | 待定 | 待运行 |  |
| 待定 | CMOEA-AOP | DASCMOP1 | 100 | 待定 | 待定 | 待运行 |  |

## 复现问题

- 基准算法能否在 MATLAB R2023a 中无错误运行？
- DDPG 训练只需要 Deep Learning Toolbox，还是还需要其他 toolbox？
- 固定随机种子下最终指标是否足够稳定？
- 实现中的 state、action、reward 是否与论文卡片描述一致？
