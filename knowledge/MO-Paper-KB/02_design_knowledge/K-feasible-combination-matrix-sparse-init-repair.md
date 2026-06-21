---
knowledge_id: K-feasible-combination-matrix-sparse-init-repair
name: 可行组合矩阵驱动的稀疏初始化与预评价修复
type: method
status: active
source_papers: [P2026-0266]
aliases: [knowledge-driven sparse initialization, knowledge-driven infeasible repair, KDSI, KDIR, feasible combination matrix, interceptability matrix, SWTA MOP1-5, LSMO-SWTA, pre-evaluation repair, 可拦截矩阵, 可行组合矩阵, 稀疏初始化, 评价前修复]
promotion_reason: 单篇论文提出但接口清晰，包含任务级可行组合矩阵、线性稀疏初始化、评价前不可行组合修复，并在八类算法和 162 个离散约束多目标 assignment 实例上验证为通用 plug-in。
---

# 可行组合矩阵驱动的稀疏初始化与预评价修复

## 核心内容

对于任务-资源-时间这类离散约束多目标 assignment 问题，先把明显不可行的“任务-资源组合”编码成每个任务一张可行组合矩阵。初始化时，不再完全随机生成满分配方案，而是按不同 sparsity 水平优先丢弃没有可行资源组合的任务，生成更接近可行域的初始种群。子代生成后、目标/约束评价前，逐行检查资源组合是否在矩阵中可行；不可行则随机或加权替换为可行组合，若任务本身不可执行则置零放弃。后续普通 CHT 继续处理容量、时序、通道等全局约束。

```text
domain knowledge / feasibility oracle
-> per-task feasible combination matrices KM_k

initialization:
    random population
    assign sparsity levels
    discard non-feasible tasks first
    produce sparse initial population

offspring:
    for each task row:
        if assigned resource pair infeasible:
            replace by feasible pair or discard
    evaluate objectives and global constraints
```

P2026-0266 的 SWTA 实例中，`KM_k(i,j)=1` 表示 sensor `i` 与 weapon `j` 可组合拦截 target `k`。KDSI 使用这些矩阵生成 sparse initial population，KDIR 在评价前修复 offspring 中不可拦截的 sensor-weapon pair。

## 建立理由

- 为什么值得独立维护：
  - 很多离散 assignment 问题的可行域极稀疏，随机初始化和普通交叉变异会产生大量显然不可行的 task-resource pairs；
  - 可行组合矩阵是一个很轻的领域知识接口，不需要改动 MOEA 的 selection、ranking 或 CHT；
  - pre-evaluation repair 不消耗目标/约束评价，可显著提高预算利用率；
  - 初始化和 repair 是两个独立 plug-in，可分别移植到 NSGA-II、MOEA/D、CMOEA、多任务算法或领域启发式。
- 与已有设计知识的区别：
  - 不同于“结构启发初始化与多目标路径重联”：该知识用结构规则生成高质量初始解并沿精英路径搜索；本知识用可行组合矩阵直接过滤不可执行 assignment rows。
  - 不同于“不可行解辅助的种群组成管理”：该知识在评价后控制可行/不可行比例；本知识在评价前修复明显无效组合。
  - 不同于“业务偏好约束的多段染色体搜索”：该知识处理业务目标阈值和多段编码；本知识处理任务-资源 pair 的物理/逻辑可行性。
  - 不同于一般 repair operator：本知识不依赖局部目标信息或随机邻域，而是由每个任务的可行组合表驱动。

## 解决的问题

- 适用场景：
  - 每个任务可分配给若干资源组合，例如 target-sensor-weapon、order-slot-vehicle、job-machine-tool、robot-task-time；
  - 可预先或快速判断某个任务-资源组合是否物理/逻辑可行；
  - 全局约束很复杂，但局部组合可行性可先过滤；
  - 解允许丢弃、延后或不服务部分任务；
  - 随机初始化/变异导致大量无意义不可行候选。
- 现有方法为什么会失败或不足：
  - CHT 在评价后才知道约束违反，浪费大量评价在明显不可行组合上；
  - 随机/LHS/OBL 初始化只改善无约束空间覆盖，不能提高可行组合命中率；
  - 通用 repair 若不知道任务级可行组合，容易在局部随机扰动中反复撞墙；
  - 高维离散编码中，一个 row 的错误组合会牵连全局约束，早期难形成可行基因片段。

## 为什么可能有效

- 可行组合矩阵把领域知识压缩成低成本查询，避免算法反复学习“哪些 pair 根本不可行”。
- 稀疏初始化承认资源有限或任务不可执行这一事实，初始种群覆盖不同服务规模，而不是强行服务所有任务。
- 优先丢弃不可执行任务，能减少初始 CV 并提高 HV 起点。
- 评价前 repair 先保证 row-level feasibility，把全局 CHT 的压力集中到容量、时间、冲突等 higher-order constraints。
- 随机选择可行 pair 保留一定多样性，避免每次都修成同一 greedy 组合。

## 实现接口

- 输入：
  - 任务集合 `K`；
  - 资源集合或资源组合集合，例如 `I x J`；
  - 可行性判定器 `feasible(k, resource_combo)`；
  - 原始初始化器和子代生成器；
  - 是否允许任务 discard 的编码规则；
  - sparsity schedule。
- 输出：
  - 每个任务的可行组合矩阵或 sparse list `KM_k`；
  - sparse initial population；
  - repaired offspring population；
  - 可选的 infeasible-combination statistics。
- 插入位置：
  - initialization 之后、第一次评价之前；
  - offspring generation 之后、目标/约束评价之前；
  - restart、mutation、crossover 或 local search 后的合法化层；
  - 多目标组合优化平台的 domain oracle interface。

最小流程：

```text
build_knowledge():
    for each task k:
        KM_k <- all feasible resource combinations for k

sparse_initialization(P0):
    compute sparsity level s_i for each solution p_i
    K_non <- {k | KM_k has no feasible combination}
    for p_i:
        discard <- choose s_i tasks, prioritizing K_non
        set one variable in each selected task row to 0
    return P

pre_evaluation_repair(O):
    for o in O:
        for each task row k:
            combo <- assigned resources in row k
            if combo infeasible under KM_k:
                Q <- feasible combinations in KM_k
                if Q is empty:
                    discard task k
                else:
                    replace combo with random or weighted combo from Q
    return repaired O
```

## 如何用于算法创新

### 局部创新

- 将 binary matrix 扩展为 probabilistic feasibility matrix，处理传感器误差、需求预测或故障概率。
- Repair 时按资源负载、目标价值、时间余量、拥挤度或历史 offspring survival rate 加权选择可行组合。
- Sparsity schedule 根据资源总容量、不可行任务比例和目标价值分层自适应，而不是线性固定。
- 增加二级 repair：先修 row-level pair feasibility，再修 capacity、time-window、sequence 或 channel conflicts。
- 记录哪些 `KM_k` rows 经常被修复，用作 mutation mask 或 adaptive operator 的反馈。

### 结构创新

- 构建离散约束 MOO 的 knowledge wrapper：

```text
domain data
-> feasible combination oracle
-> sparse initialization
-> row-level pre-evaluation repair
-> standard CHT / environmental selection
-> optional global repair for high-order constraints
```

- 在物流中：order-cargo/vehicle/slot matrix 先过滤不能装载或不兼容的组合，再由 VRP/装载约束处理全局路线和容量。
- 在多机器人任务分配中：task-robot-time matrix 先过滤能力、电量、地理不可达组合，再优化 makespan/energy/risk。
- 在生产调度中：job-machine-tool matrix 先过滤不能加工的机器组合，再处理换型、产能和工期。
- 在动态场景中：矩阵随时间或环境状态更新，环境变化后只 repair 受影响任务 rows。

## 适用条件与风险

- 适用条件：
  - 有可靠 domain data 或快速可行性判定器；
  - 局部组合可行性与全局约束可分层处理；
  - 解编码有可独立检查的 task rows；
  - 允许部分任务不服务、延后或置零；
  - 可行组合矩阵足够稀疏，过滤收益明显。
- 不适用或可能失效的条件：
  - 可行性主要由全局交互决定，单个 task-resource pair 本身没有意义；
  - 必须服务所有任务且没有可行组合时不可简单置零；
  - 矩阵知识过时或有误，可能误删真实可行组合；
  - 目标价值高度依赖全局组合，随机 repair 可能降低高价值任务覆盖；
  - 资源冲突强烈时，只修局部 pair 仍会产生大量全局不可行解。
- 计算与实现成本：
  - 需要构造和存储 `|K|` 张矩阵或 sparse lists；
  - 初始化和 repair 要遍历任务 rows；
  - 矩阵构造若依赖几何/仿真，需要缓存；
  - 若 feasible combinations 很多，repair 采样需做高效索引。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0266 | LSMO-SWTA 决策空间随 targets 和 resources 指数膨胀，复杂时空约束导致可行域极稀疏 | 问题动机 | Abstract、Introduction，PDF 1-2 |
| P2026-0266 | SWTA MOP1-5 提供 value、cost、timeliness、risk 四类目标和 target/sensor/weapon 三类约束 | Benchmark 建模 | Sec. II-B-C，PDF 3-5 |
| P2026-0266 | 每个 target 编码为 `[i_k,j_k,t_k]`，任一分量为 0 表示 discard，该 target 最多被拦截一次 | 编码设计 | Sec. II-B、III-A，PDF 3、7-8 |
| P2026-0266 | `KM_k` 枚举 target `k` 的 sensor-weapon 组合是否可拦截，用于知识驱动初始化和 repair | 作者提出的方法 | Sec. III-B-C，PDF 8-9 |
| P2026-0266 | KDSI 根据 sparsity level 优先选择不可拦截 targets 构造 sparse matrix，并用 `p_i' ⊙ SM_i` 修改初始种群 | 作者提出的方法 | Sec. III-B、Algorithm 2，PDF 8-9 |
| P2026-0266 | KDIR 在评价前检测 offspring 中每个 target 的 sensor-weapon 组合，不可行则从 `KM_k` 中随机选可行组合或置零 | 作者提出的方法 | Sec. III-C、Algorithm 3，PDF 9-10 |
| P2026-0266 | Repair 不调用目标/约束函数，且与后评估 CHT 解耦，因此可作为 generic plug-in 嵌入多算法 | 机制说明 | Sec. III-C，PDF 9 |
| P2026-0266 | 实验覆盖 162 个 SWTA MOP1-5 instances、2/3/4 objectives、centralized/decentralized attacks、8 个算法、20 次运行 | 实验设置 | Sec. IV-A，PDF 10 |
| P2026-0266 | KD variants 在 162 个实例上达到 best performance 的比例为 86.4%、96.9%、94.4%、93.2%、88.9%、98.8%、88.9%、92.6% | 综合实验支持 | Sec. IV-B，PDF 12 |
| P2026-0266 | KDSI 与 random initialization 对比，在 SWTA MOP5 12 cases x 8 algorithms 中 95/96 次显著改进 | 初始化消融 | Sec. IV-C、Table V，PDF 12-13 |
| P2026-0266 | KD-NSGAII-CDP 与 RAN/LHS/OBL initialization 对比，在 12 cases 中均 rank first，三类初始化均 12/0/0 显著差于 KD | 初始化对比 | Sec. IV-C、Table VII，PDF 13 |
| P2026-0266 | KDIR 与 no-repair variants 对比，在 12 cases x 8 algorithms 中 96/96 次显著改进 | Repair 消融 | Sec. IV-D、Table VI，PDF 13-14 |
| P2026-0266 | KD repair 与 SR/NR/OR repair 对比，KD-NSGAII-CDP 在几乎所有 cases 最高 HV，平均 rank 为 1 | Repair 对比 | Sec. IV-D、Table VIII，PDF 14 |
| P2026-0266 | 作者指出未考虑 relay detection、sequential interception、fixed-length encoding 的超大规模瓶颈，以及知识仅到 target level | 作者局限 | Conclusion，PDF 14 |

## 证据边界

- 当前证据来自单篇 SWTA benchmark/heuristics 论文。
- 算法优势同时来自 KDSI 和 KDIR，综合比较不能完全分解二者贡献，需看专门消融。
- KDIR 只保证 task-level sensor-weapon pair feasibility，不能直接保证全局 capacity、channel 和 firing-time constraints。
- 主文大量具体 HV/FR/CT 数据在 supplementary，当前卡片保存主文汇总。
- Source code 在线可用性未在本次抽取中验证。

## 待确认

- 如何把 target-level matrix 扩展到 scheme-level 或 sequence-level constraints；
- 当所有任务都必须服务时，置零 discard 的替代修复策略；
- 动态场景中 `KM_k` 如何快速更新并避免过时知识误导；
- 可行组合矩阵与全局 CHT/repair 的最佳分层接口；
- 在非 SWTA 的 assignment、routing、scheduling 问题中，矩阵构造成本和过滤收益是否仍成正比。
