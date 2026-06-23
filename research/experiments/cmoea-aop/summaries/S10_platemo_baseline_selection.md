# S10 对比算法选择方法：从 2026 论文到 PlatEMO 可运行候选池

## 1. 基本约束

本研究的正式对比算法必须满足一个硬条件：

```text
算法必须已经存在于当前本地 PlatEMO 目录中，并且有可调用的 classdef。
```

因此，2026 论文中出现但本地没有实现的算法，只能作为文献背景或思想参照，不能进入正式实验表格。

本地已确认不存在的代表性 2026 算法包括：

```text
DGCMOEA, DPCMOEA, ACREA, DEPEA, VCGDPEA, NMOEA, CMOEA-TS
```

这些算法可以用来解释近年趋势，例如资源分配、双种群协同、约束优先级和强化学习策略选择，但不能作为我们当前实验的直接 baseline。

## 2. 从 2026 论文学到的 baseline 选择方法

2026 年相关 CMOP 论文选择对比算法时，通常不是只找最新算法，而是覆盖几个互补类别。

第一类是同骨架或直接相关算法。  
它们用来说明新方法的收益到底来自哪里。对我们来说，`EMCMO` 是同骨架基线，`CMOEA-AOP` 是最直接的 operator portfolio 对照，`DRLOS-EMCMO` 是强化学习单算子选择对照。

第二类是原论文使用过的对比算法。  
它们保证我们的结果可以和出发论文建立连续性。对 CMOEA-AOP 来说，这一类包括 `EMCMO`、`BiCo`、`AGE-MOEA-II`、`TSTI`、`DRLOS-EMCMO`。

第三类是经典约束处理路线。  
这类算法不一定最新，但代表了领域里长期稳定的比较对象，例如双档案、双种群、多阶段、push-pull、epsilon 或约束辅助选择。对应本地可用算法包括 `C-TAEA`、`PPS`、`ToP`、`CCMO`、`CMOEA-MS`、`CMOES`、`CAEAD`。

第四类是多任务、多种群或辅助搜索路线。  
近年 CMOP 论文经常把这类方法作为强 baseline，因为它们和复杂可行域、UPF/CPF 关系、不可行解利用直接相关。对应本地可用算法包括 `C3M`、`CMOEMT`、`MTCMO`、`IMTCMO`、`APSEA`、`ICMA`。

第五类是近年本地已有的强竞争算法。  
如果算法已经在 PlatEMO 里，并且代表 2026 论文常见的新趋势，可以放入初筛。例如 `DPCPRA` 和 `PRCEA` 分别代表约束优先级或 promising-region 资源利用方向。

第六类是备用或专题算法。  
例如 `CMODRL`、`CMOQLMT`、`CSEMT`、`EMCMMS`、`ILCMO`、`LCMEA`、`CMOCSO` 等也在本地，但它们更适合在发现特定失败模式后补充，而不是第一轮全部放入。

## 3. 当前建议的初筛候选池

第一轮不直接做最终论文级 30 次运行，而是先做一个本地 PlatEMO 宽筛。目标是多放一些合理 baseline，再从结果里筛掉弱算法、失败算法和冗余算法。

建议 S10a 使用 22 个算法：

| 类别 | 算法标签 | PlatEMO class | 选择理由 |
| --- | --- | --- | --- |
| 我们的方法 | SCOP-CMOEA | `SCOP_CMOEA` | 主算法 |
| 同骨架 | EMCMO | `EMCMO` | 验证收益是否来自 operator portfolio |
| 直接相关 | CMOEA-AOP | `CMOEAAOP` | DDPG 连续比例学习对照 |
| 直接相关 | DRLOS-EMCMO | `DRLOSEMCMO` | 强化学习单算子选择对照 |
| 原论文对照 | BiCo | `BiCo` | CMOEA-AOP 原论文 baseline |
| 原论文对照 | AGE-MOEA-II | `AGEMOEAII` | CMOEA-AOP 原论文 baseline |
| 原论文对照 | TSTI | `TSTI` | CMOEA-AOP 原论文 baseline |
| 双档案 | C-TAEA | `CTAEA` | 经典强基线 |
| 多阶段 | PPS | `PPS` | push-pull search 代表 |
| 多阶段 | ToP | `ToP` | two-phase 代表 |
| 多任务协同 | C3M | `C3M` | 常见多任务 CMOEA 对照 |
| 双种群 | CCMO | `CCMO` | 经典双种群协同 |
| 多阶段搜索 | CMOEA-MS | `CMOEAMS` | 常用强 baseline |
| 约束处理 | CMOES | `CMOES` | 多篇论文使用的约束处理 baseline |
| 约束辅助 | CAEAD | `CAEAD` | 自适应约束/辅助搜索代表 |
| 辅助种群 | APSEA | `APSEA` | 辅助种群资源调整代表 |
| 进化多任务 | CMOEMT | `CMOEMT` | EMT-based CMOEA 代表 |
| 多任务 | MTCMO | `MTCMO` | 多任务约束优化代表 |
| 不可行信息 | ICMA | `ICMA` | 多篇近年论文使用 |
| 改进多任务 | IMTCMO | `IMTCMO` | 复杂约束常见强对照 |
| 约束优先级 | DPCPRA | `DPCPRA` | 本地已有，贴近 2026 资源调度趋势 |
| promising region | PRCEA | `PRCEA` | 本地已有，代表 promising-region 方向 |

这个候选池比 S10 当前 10 个算法更宽，但仍然全部来自本地 PlatEMO。

## 4. 建议的筛选节奏

S10a 做本地宽筛：

```text
算法：22 个
问题：CF + LIR-CMOP + DAS-CMOP + MW + DOC，共 56 个
runs：5
N：100
maxFE：100000
指标：IGD, HV, feasible rate, runtime
任务量：22 * 56 * 5 = 6160 runs
```

S10a 的目的不是给论文最终表格，而是选出进入论文级确认的算法。

S10b 或 S11 做论文级确认：

```text
算法：10 到 12 个
问题：核心 56 个，可视结果加入 RWMOP
runs：30
N：100
maxFE：100000
```

进入最终对比的算法不只按平均排名选，还要保留必要类别：

```text
SCOP-CMOEA 必保留
EMCMO 必保留
CMOEA-AOP 必保留
DRLOS-EMCMO 建议保留
每个主要机制类别至少保留一个强算法
如果某个算法只在特定测试集明显强，也可作为边界对照保留
```

## 5. 当前不建议进入第一轮的本地算法

以下算法本地存在，但不建议第一轮全部纳入：

```text
CMODRL, CMOQLMT, CSEMT, EMCMMS, ILCMO, LCMEA, CMOCSO, MSCMO, MCCMO, NSBiDiCo, URCMO, cDPEA, tDEACPBI
```

原因不是它们不重要，而是第一轮已经覆盖了同骨架、直接相关、经典约束处理、多阶段、双种群、多任务和近年资源调度方向。若 S10a 显示 SCOP-CMOEA 在某类问题上失败，再从这些备用算法中补充更有针对性的对照。

## 6. 对论文写法的意义

这种 baseline 选择方法能支撑一个更稳的论文叙事：

```text
我们不是只和某一个原算法比较，也不是只挑最新算法比较，而是把 SCOP-CMOEA 放到约束多目标优化的几类主流机制中检验。
```

如果 SCOP-CMOEA 在多类 baseline 中仍有竞争力，就可以说明 survival-credit operator portfolio 是一种独立有效的资源分配机制。

如果它只在部分测试集领先，也仍然有价值：我们可以明确它适合哪类约束景观，并把失败问题作为后续算法扩展方向。
