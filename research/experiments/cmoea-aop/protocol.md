# CMOEA-AOP 实验协议

## 目标

以 CMOEA-AOP 作为第一个受控案例，在 PlatEMO 中测试机制拆解和算法修改方案。

## 基准

原始实现保持不变：

```text
PlatEMO\Algorithms\Multi-objective optimization\CMOEA-AOP
```

所有修改版本都放入独立目录。

## 第一阶段复现范围

先从 smoke test 开始：

- CF1
- LIRCMOP1
- DASCMOP1

S01 扩大规模时，问题集合直接对齐论文主实验，但先使用较低预算做机制发现：

- CF1-CF10
- LIRCMOP1-LIRCMOP14
- DASCMOP1-DASCMOP9

该阶段不是论文级最终统计，而是使用 `maxFE = 20000`、3 个独立 seeds 观察固定算子组合的机制差异。

本地论文卡片记录的论文规模参考设置：

- 种群规模：100；
- 最大函数评价次数：100000；
- 独立运行次数：30；
- 指标：IGD；
- 统计检验：0.05 显著性水平的 Wilcoxon rank-sum test。

## 环境检查

长时间运行前记录：

- MATLAB 版本；
- Deep Learning Toolbox 是否可用；
- 当前 git commit；
- 随机种子策略；
- PlatEMO 版本；
- 已修改的算法文件。

## 结果管理

原始结果文件留在 `results/`，不进入 git。只提交：

- 实验协议修改；
- 配置文件；
- 脚本；
- 紧凑汇总；
- 审阅所需的最终表格和图。
