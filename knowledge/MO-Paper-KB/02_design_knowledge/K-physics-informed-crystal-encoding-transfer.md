---
knowledge_id: K-physics-informed-crystal-encoding-transfer
name: 物理约束晶体编码与结构知识迁移
type: architecture
status: active
source_papers: [P2026-0212]
aliases: [PEMOMG, physics-guided evolutionary multi-objective material generation, physics-informed material encoding, physics-informed ETO, space-group transfer, crystal structure knowledge transfer, 物理信息晶体编码, 空间群迁移, 晶体材料进化迁移优化]
promotion_reason: 单篇论文提出但接口完整，包含空间群-基原子位点-晶格参数物理编码、CIF/原子距离/元素约束过滤、形成能/EAH/原子距离四目标优化，以及从简单晶体系向复杂晶体系迁移空间群和基原子位点等结构知识，可直接改造晶体材料生成、强物理对称约束结构搜索和多任务材料优化。
---

# 物理约束晶体编码与结构知识迁移

## 核心内容

在晶体材料等强物理约束结构设计中，不直接让生成模型或演化算法在原始原子列表中盲目搜索，而是把结构编码为 `M=(E', S', P, G)`：基元素、基原子位点、晶格参数和空间群对称操作。搜索过程中同时用 CIF 可读性、空间群变换一致性和原子距离过滤无效结构，并把形成能、能量高于凸包、最小/最大原子距离作为多目标优化对象。对于新材料系统，先在较简单源元素系统中优化出物理合法晶体，再抽取空间群、基原子位点分布和晶格参数相关性，迁移重构目标任务初始种群。

```text
source material system
-> physics-informed crystal encoding
-> constraints: base elements, CIF validity, atomic distance
-> multi-objective evolution: FE, EAH, min/max distance
-> extract high-fitness structural knowledge
   space group + base atomic sites + lattice correlations
-> reconstruct target task initial population
-> target material evolution under same physical objectives/constraints
```

## 建立理由

- 为什么值得独立维护：
  - 它把“结构合法性”从后处理修复前移到编码、约束过滤和目标设计中，适合晶体、分子、材料结构、机器人构型等有强不变性/对称性的搜索问题。
  - 它的迁移单元不是完整解或黑箱生成器，而是物理可解释的结构组合：空间群、基原子位点和晶格参数相关性。
  - 它同时提供可替换接口：编码器、约束判别器、目标评价器、MOEA 和 ETO 初始化器。
- 单篇具体方法的直接复用价值：
  - P2026-0212 给出 PEMOMG 的编码、约束、四目标 MOO、Algorithm 1、参数设置、消融、DFT 个案和 ETO 加速证据；
  - ETO 在稀土/锕系三元晶体目标任务中把达到 100% CIF success 的代数从接近 40 代提前到约 19 代，作者报告至少减少 50% 迭代和 68.0% 计算时间。
- 与已有设计知识的区别：
  - 不同于“目标条件化生成式设计采样”：本知识不依赖目标条件训练生成模型，而是用物理编码和演化搜索直接生成并优化晶体。
  - 不同于“GAN 分布学习的自适应多任务知识迁移”：本知识迁移的是空间群/基位点/晶格相关性等领域结构知识，不是训练 source-target 生成模型。
  - 不同于“多邻域多知识的分解式多任务迁移”：本知识不以 MOEA/D 子问题邻域和算子池为核心，而是面向晶体表示的跨材料系统结构初始化。
  - 不同于一般材料配比代理优化：本知识优化的是晶体结构表示本身，而不是只优化配方、工艺或宏观参数。

## 解决的问题

- 适用场景：
  - 晶体材料、分子构型、周期结构、超材料单元、晶格机器人等候选需要满足对称性、不变性、几何可行性或物理合法性；
  - 高质量训练数据不足，黑箱生成模型容易过拟合或无法保证物理约束；
  - 需要同时优化热力学/能量、结构有效性和多样性；
  - 存在较简单源任务，可从中提取目标任务可复用的物理结构组合。
- 现有方法为什么会失败或不足：
  - 直接在原子列表或高维参数中变异会产生大量不可读、重叠、断裂或违反空间群的无效结构；
  - 只把物理约束作为后处理会浪费评价预算，并可能让演化选择学习到错误方向；
  - 生成模型需要大量高质量晶体数据，新元素族或稀有材料系统往往缺少数据；
  - 直接跨任务复制完整解会被元素差异破坏，黑箱迁移不容易解释负迁移来源。
- 仍需解决的问题：
  - 如何自动度量源/目标材料系统的结构相似性；
  - 如何决定迁移知识比例和何时停止迁移；
  - 形成能和 EAH 近似误差如何传递到 Pareto 选择；
  - 如何把可合成性、力学/电子性能和 DFT 主动验证纳入闭环。

## 为什么可能有效

```text
crystal structure has symmetries and invariances
-> encode with space-group operations and base atoms
-> many invalid permutations/translations/rotations collapse to one valid representation
-> CIF and distance checks remove impossible candidates before selection
-> FE/EAH guide thermodynamic stability, min/max distance guide geometric cohesion
-> source systems reveal reusable crystallographic combinations
-> target initialization starts closer to physically valid regions
-> fewer infeasible offspring and faster convergence to valid crystals
```

关键假设是：源任务和目标任务共享足够的晶体物理规律，例如空间群可行性、基原子位点分布或晶格参数相关性。如果目标材料系统有完全不同的化学键合、离子半径、价态或稳定相空间，迁移结构可能产生负迁移。

## 如何用于算法创新

### 局部创新

- 在材料 MOEA 初始化阶段，用空间群和基原子位点替代纯随机原子坐标。
- 在交叉/变异后加入 CIF readability、空间群一致性、坐标边界和原子距离检查，提前过滤无效后代。
- 将 `Fmind/Fmaxd` 作为几何结构目标或约束，避免只优化能量时产生格式有效但物理断裂的结构。
- 用源任务高适应度个体中的空间群、局部配位、晶格尺度统计初始化目标任务。
- 给迁移模块增加成功率反馈：若迁移后代被过滤或在环境选择中长期淘汰，则降低对应结构知识权重。
- 把形成能/EAH 近似器的不确定性作为额外筛选或 DFT 复核触发条件。

### 结构创新

- 构建材料发现闭环：

```text
physics encoder
-> constraint discriminator
-> multi-objective evolutionary search
-> structural knowledge archive
-> source-target transfer initializer
-> DFT/experiment active validation
-> update objective approximators and transfer archive
```

- 将结构知识拆成多层迁移单元：space group、base site distribution、lattice parameter correlations、element-family compatibility、local coordination motifs。
- 与 MOEA/D 结合时，可让不同 reference directions 对应不同晶系或能量-距离折中区域。
- 与主动学习结合时，用 MOEA 产生候选，用 DFT 验证少量高价值非支配结构，再更新能量代理和结构知识库。
- 将该机制迁移到其他强约束生成任务，例如周期超材料、晶格结构、分子构象或机器人模块连接图。

## 适用条件与风险

- 适用条件：
  - 任务有明确可编码的物理不变性、对称操作或合法性规则；
  - 约束检查比完整真实评价便宜；
  - 有可用的能量或性能近似评价器；
  - 源/目标任务共享部分结构规律；
  - 允许先生成候选，再由 DFT、实验或高保真仿真验证。
- 不适用或可能失效的条件：
  - 目标任务没有稳定可迁移的空间群/对称结构规律；
  - 源任务和目标任务元素化学差异太大，空间群和位点统计不再相关；
  - 物理约束过强导致早期多样性丢失；
  - 形成能/EAH 近似器系统性偏差较大，演化会优化代理漏洞；
  - CIF 可读和距离合格不代表可合成、可稳定存在或性能满足需求。
- 计算与实现成本：
  - 需要维护空间群操作、CIF 生成/解析、原子距离检查和能量近似评价；
  - 混合变量编码需要兼容离散空间群/元素和连续坐标/角度；
  - ETO 需要源任务预优化和结构知识抽取；
  - 高可信材料发现仍需 DFT 或实验验证闭环。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0212 | 用 `M=(E',S',P,G)` 表示晶体：基元素、基原子位点、晶格参数和空间群仿射操作，嵌入排列/平移/旋转/周期不变性 | 作者提出/组合方法 | Sec. IV-A，PDF 5 |
| P2026-0212 | 四目标为 formation energy、energy above hull、minimum atom distance 和 maximum atom distance，对应热力学稳定性和结构几何有效性 | 作者提出/组合方法 | Sec. IV-B.1，PDF 5-6 |
| P2026-0212 | 三约束 Base Elements、CIF、Distance 在初始化和子代生成阶段过滤无效解，CIF 检查包含语法、坐标边界和空间群变换一致性 | 作者提出/采用方法 | Sec. IV-B.2，PDF 6 |
| P2026-0212 | Algorithm 1 给出 PEMOMG：先对任务 T1 随机初始化、约束过滤、目标评价、非支配排序和拥挤距离选择，再从 P1 抽取基原子和空间群初始化后续任务 | 完整流程 | Sec. IV-E、Algorithm 1，PDF 7 |
| P2026-0212 | Table I 报告 10,000 个生成样本中 PEMOMG 在 CIF 和 Distance 两项有效性上达到 100% success rate | 实验支持 | Sec. V-D、Table I，PDF 6、8-9 |
| P2026-0212 | 20 轮实验获得 93,946 个晶体结构，其中 49,870 个三元晶体；二元 CIF 成功率约 200 代后接近 100%，EAH 低于 0.2 eV；三元平均 EAH 通常低于 0.7 eV | 效率与稳定性证据 | Sec. V-E、Fig. 2，PDF 9 |
| P2026-0212 | 消融显示去掉 Distance 约束会使二元 `dmin=0`、`dmax=100`，三元 CIF success 降到 1%；去掉任一距离目标也会导致 CIF validity 灾难性失败 | 消融证据 | Sec. V-F，PDF 9-10 |
| P2026-0212 | DFT 个案 `Zn8Bi8Pb4` 形成能和 EAH 为 0，声子频率均大于 0，电子能带穿过费米能级 | 高保真个案验证 | Sec. V-G、Fig. 4，PDF 10 |
| P2026-0212 | ETO 从简单元素系统迁移空间群、基原子位点分布和晶格参数相关性到镧系/锕系三元晶体任务，平均约第 19 代达到 100% CIF success，无 ETO 接近 40 代 | 迁移机制与加速证据 | Sec. V-H、Fig. 5，PDF 10 |
| P2026-0212 | 作者指出低相似源/目标任务可能产生 negative transfer，需要强任务关联 | 风险说明 | Sec. IV-D，PDF 7 |
| P2026-0212 | 作者承认 formation energy 计算由于缺少真实 DFT 而为近似值 | 证据边界 | Sec. V-I，PDF 11 |

## 待确认

- 如何自动计算源/目标材料系统的相似性，并据此选择可迁移的空间群或局部结构；
- 迁移知识是只用于初始化，还是可在子代生成中持续注入；
- 形成能/EAH 近似器的误差边界如何影响非支配排序；
- 如何将可合成性、稳定相竞争、电子/力学性能和实验约束加入同一框架；
- 是否需要保留随机初始化比例，以防迁移初始化导致结构模式过早收缩；
- 对非晶、低对称、缺陷结构或复杂非化学计量材料是否仍适用。
