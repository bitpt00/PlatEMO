# S01 固定算子组合实验计划

## 目标

分离 CMOEA-AOP 中“多个 offspring 算子共同使用”的作用，以及“DDPG 学习算子比例”的作用。

第一问题不是新变体能否超过 CMOEA-AOP，而是更简单的 portfolio policy 是否已经能解释相当一部分行为。

## 代码边界

- 保持 `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/` 不变。
- S01 变体实现在 `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP-Lab/`。
- 使用一个带参数的 lab 算法，而不是为每个 policy 复制一份算法文件。
- 原始 `.mat` 输出放在 `research/experiments/cmoea-aop/results/`。
- 紧凑最终指标写回本 study 目录。

## 策略

基准算法：

| Label | 含义 |
| --- | --- |
| EMCMO | 原始 EMCMO，使用 GA offspring generation。 |
| CMOEA-AOP | 原始基于 DDPG 的 CMOEA-AOP。 |

静态 lab policy：

| Label | GA/SBX | DE/rand/1 | DE/best/1 | 目的 |
| --- | ---: | ---: | ---: | --- |
| GA-only | 1.00 | 0.00 | 0.00 | 复现单 GA 风格 portfolio。 |
| DE-rand-only | 0.00 | 1.00 | 0.00 | 复现单 DE/rand/1 portfolio。 |
| DE-best-only | 0.00 | 0.00 | 1.00 | 复现单 DE/best/1 portfolio。 |
| Equal-AOP | 0.33 | 0.33 | 0.33 | 检验多算子共存本身是否足够。 |
| GA-heavy | 0.60 | 0.20 | 0.20 | 检验偏 GA/SBX 的固定 portfolio。 |
| DE-rand-heavy | 0.20 | 0.60 | 0.20 | 检验偏探索的固定 portfolio。 |
| DE-best-heavy | 0.20 | 0.20 | 0.60 | 检验偏收敛的固定 portfolio。 |
| GA+DE-rand | 0.50 | 0.50 | 0.00 | 检验双算子静态 portfolio。 |
| GA+DE-best | 0.50 | 0.00 | 0.50 | 检验双算子静态 portfolio。 |
| DE-rand+DE-best | 0.00 | 0.50 | 0.50 | 检验两个 DE 算子的静态 portfolio。 |

动态非 DDPG policy 作为第二批实验：

| Label | 目的 |
| --- | --- |
| Random-AOP | 检验随机比例多样性是否能解释效果。 |
| Stage-AOP | 检验 DDPG 是否主要学到早期/中期/后期调度规律。 |
| Survival-Credit-AOP | 检验即时 offspring 存活反馈是否已经足够。 |

## 测试集合

Smoke 测试：

| Problem | 原因 |
| --- | --- |
| CF1 | 简单约束 CF 检查。 |
| LIRCMOP1 | LIR-CMOP 路径和可行性检查。 |
| DASCMOP1 | DAS-CMOP 路径和约束检查。 |

Discovery 集合：

| Problem | 原因 |
| --- | --- |
| CF2 | 论文中用于说明 operator portfolio 差异的案例。 |
| CF6 | 论文中用于 convergence profile 讨论的案例。 |
| CF9 | 论文中用于说明 operator portfolio 差异的案例。 |
| LIRCMOP3 | 来自协议的困难约束案例。 |
| LIRCMOP4 | 来自协议的困难约束案例。 |
| LIRCMOP12 | 论文图中涉及窄小/分离可行域的案例。 |
| DASCMOP1 | 第一个 DAS-CMOP sanity case。 |
| DASCMOP8 | 论文可视化案例。 |

确认实验集合：

只有当 smoke 和 discovery 揭示出值得确认的机制时，才跑论文中的全部 33 个问题。

## 运行规模

| 阶段 | N | maxFE | Seeds |
| --- | ---: | ---: | ---: |
| smoke | 100 | 5000 | 1 |
| discovery-fast | 100 | 20000 | 3 |
| discovery-main | 100 | 50000 | 5 |
| confirmation | 100 | 100000 | 30 |

先从 smoke 开始。所有 policy 都能产生有效输出文件后，再启动 discovery。

## 多 MATLAB 规则

允许同时打开多个 MATLAB 进程。每个 worker 必须运行互不重叠的 task partition，并写入独立 `.mat` 文件。不要让多个 worker 同时追加同一个 CSV。

使用 worker-specific logs；所有 worker 完成后再统一汇总。

## 计划输出

- `runs.csv`：有真实运行结果后写入紧凑最终指标。
- `summary.md`：有真实运行结果后写入 Codex 执行记录和早期解释。
- `checkpoints.csv`：如果需要 generation-level trajectory analysis，再后续添加。
