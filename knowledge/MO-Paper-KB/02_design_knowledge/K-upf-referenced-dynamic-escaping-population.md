---
knowledge_id: K-upf-referenced-dynamic-escaping-population
name: UPF 参照的动态逃逸种群
type: architecture
status: active
source_papers: [P2026-0271]
aliases: [DEPEA, escaping population, EP, slow escape mode, rapid escape mode, deceptive constraints, DCMOP, UPF escaping, one-way fine-grained cooperation, boundary diversity enhancement, 动态逃逸种群, 欺骗约束, 次优保留逃逸]
promotion_reason: 单篇论文提出但接口清楚，包含 UPF 参照逃逸、按子区保留 second-best/worst 的可控逃逸速度、AP 到 EP 的可行解单向合作、MP 后期 CPF 开发和 BDES，可直接改造 CV 不可信或 UPF/CPF 分离的 CMOEA。
---

# UPF 参照的动态逃逸种群

## 核心内容

在 deceptive constrained MOP 中，`CV` 可能不能表示“离可行前沿有多近”。这时可以把容易识别的 UPF 当作参照，不让所有种群都沿低 `CV` 方向搜索，而是设置一个 escaping population。该种群忽略约束，在每个 reference-vector subregion 中故意保留 objective fitness 较差的个体：前期保留 second-best 形成慢速逃逸，细致搜索 UPF 附近和中距离区域；后期保留 worst 形成快速逃逸，探索更远区域。一旦某个子区发现可行解，就停止该子区逃逸并转向开发可行区域。

```text
AP: objective-only convergence to UPF
EP: objective-only escape from UPF
    slow mode  -> retain second-best in each subregion
    rapid mode -> retain worst in each subregion
    feasible found -> stop escape in that subregion
MP: feasibility-oriented CPF exploitation

AP feasible solutions only -> EP
EP / MP weak cooperation in CPF phase
MP sparse-boundary seeds -> DE/seed/1 offspring
```

P2026-0271 的 DEPEA 是该模式的实例：AP 收敛到 UPF，EP 动态逃逸，MP 在后期用 CDP 探索 CPF；AP 与 EP 的 UPF 阶段只允许可行解从 AP 单向共享到 EP，避免普通 weak cooperation 阻碍 EP 的逃逸。

## 建立理由

- 为什么值得独立维护：
  - 许多 CMOEA 默认 `CV` 越小越接近 CPF，但 deceptive constraints 会让这个假设反转；
  - 只追 UPF 的辅助种群在 CPF 远离 UPF 时无法覆盖目标区域；
  - 直接均匀采样可能能穿透 deceptive regions，但评价浪费大；
  - 通过“保留次优/最差”制造逃逸力，给出了一个简单可插拔的 objective-only exploration 机制；
  - 逃逸停止和 AP feasible-only sharing 让该机制也能兼容普通 NCMOP。
- 单篇具体方法的直接复用价值：
  - P2026-0271 给出 EP 设计逻辑、slow/rapid escape mode、Algorithm 1-5、单向合作、BDES、13 个算法对比和多组消融。
- 与已有设计知识的区别：
  - 不同于“约束边界远距不可行辅助引导”：该知识依赖低 `CV` + 远离主群选择边界不可行解；本知识在 `CV` 不可信时故意不使用 `CV` 来驱动 EP，而是从 UPF 参照逃逸。
  - 不同于“双边界不可行辅助指标与分组 DE”：该知识用松弛约束边界管理不可行辅助；本知识用 objective fitness rank 控制逃逸速度。
  - 不同于“FNDS 诱导的 promising region 分层选择”：该知识需要已有 FNDS 作为 region anchors；本知识在可行锚点不足或 `CV` 欺骗时先用 UPF anchor 和 EP 搜索远端区域。
  - 不同于“变量自适应 UPF 档案重构”：该知识从 UPF/CPF 桥接 archive 重构种群；本知识持续维护一个动态逃逸种群，并按阶段改变逃逸速度。

## 解决的问题

- 适用场景：
  - `CV` 与到 CPF 的距离不单调，低 `CV` 个体可能远离真实可行前沿；
  - CPF 可能位于 UPF 一侧或两侧较远处；
  - 需要减少对统一采样或大规模多步变异的依赖；
  - 算法可以按 reference vectors / subregions 管理种群；
  - 需要同时兼容 DCMOP 和普通 NCMOP。
- 现有方法为什么会失败或不足：
  - CDP、epsilon、penalty 和 CV-as-objective 会被 deceptive `CV` 诱导；
  - AP 只追 UPF 时，若初始种群或 UPF 与 CPF 不在同一侧，CPF 不在 AP 搜索范围内；
  - weak cooperation 会把 AP 的强收敛个体塞入 EP，破坏 second-best 保留机制；
  - 完全隔离 AP/EP 又会让 EP 在普通约束问题上逃得过远；
  - 均匀采样发现 feasible regions 后若继续强采样，会浪费评价而降低收敛精度。
- 仍需解决的问题：
  - escape speed 是否应连续自适应，而不是固定 second-best / worst；
  - UPF 参考在 many-objective、高噪声或强退化 PF 下是否稳定；
  - 等式约束定义的 CPF 极窄时，仅靠逃逸仍难精确落在可行区域；
  - 如果 objective-only 方向与可行区域完全无关，EP 可能搜索无效远端区域。

## 为什么可能有效

```text
CV is deceptive
-> do not use CV to decide where EP should move

UPF is objective-defined and easy to approach
-> use AP to anchor UPF
-> use EP to intentionally move away from UPF

retain second-best in subregion
-> weak escape force
-> detailed search around UPF and medium-distance areas

retain worst in subregion
-> strong escape force
-> expand to farther regions after early exploration

feasible solution appears
-> CPF cannot lie in dominated unpromising region behind it
-> stop escape locally and exploit feasible area
```

关键假设是：UPF 与 CPF 的相对位置能为搜索提供有用几何参照，并且从 UPF 逐步向外逃逸会穿过或接近 deceptive CPF 区域。如果可行域与 UPF 完全无几何关系，或 objective-only subregion fitness 与可行边界位置高度错位，逃逸搜索可能变成盲目扩散。

## 实现接口

- 输入：
  - 当前 AP、EP、MP；
  - objective values、constraint values、`CV` 和 feasibility flag；
  - reference/weight vectors；
  - phase state：UPF exploitation 或 CPF exploration；
  - escape mode：slow 或 rapid；
  - phase switch / stop thresholds；
  - GA/DE 子代生成器和 CDP 环境选择器。
- 输出：
  - 更新后的 AP/EP/MP；
  - 每个子区的 escape status；
  - 由 MP 输出的 CPF approximation。
- 插入位置：
  - CMOEA 的辅助种群设计；
  - CV 不可信约束处理的 exploration layer；
  - UPF-CPF 分离问题的阶段切换框架；
  - 多种群 CMOEA 的信息交换策略。
- 最小实现：

```text
initialize AP, EP
phase <- UPF
mode <- slow

while budget remains:
    if phase == UPF:
        AO <- variation(AP)
        EO <- variation(EP)
        feasible_from_AP <- feasible(AP union AO)

        AP <- angle_selection_best(AP union AO, W)
        EP <- escape_selection(EP union EO union feasible_from_AP, W, mode=slow)

        if AP_progress_stagnates() or FE_ratio_exceeds(r):
            MP <- copy(EP)
            phase <- CPF
            mode <- rapid

    else:
        if EP_not_stopped:
            MO <- variation(MP)
            EO <- variation(EP)
            MP <- CDP_selection(MP union MO union EO)
            EP <- escape_selection(EP union MO union EO, W, mode=rapid)
            if EP_progress_stagnates() or FE_ratio_exceeds(l):
                stop_EP()
        else:
            seeds <- sparsest_boundary_solutions(MP)
            MO1 <- DE_seed_1(seeds, MP)
            MO2 <- neighbor_pairing_variation(MP)
            MP <- CDP_selection(MP union MO1 union MO2)

return MP
```

`escape_selection` 的核心：

```text
for each subregion i:
    Cur <- candidates assigned to i
    if Cur is empty:
        Neighbor <- three closest candidates to subregion i
        select second-best if slow else worst
    else if no feasible solution in Cur:
        rank Cur by objective-only angle fitness
        select second-best if slow else worst
    else:
        select best feasible by CDP
```

## 如何用于算法创新

### 局部创新

- 将 fixed second-best / worst 改为 adaptive escape quantile，例如 `rank = ceil(q_t * |Cur|)`，`q_t` 由 feasible discovery rate 或 stagnation 调节。
- 用多个 EP 并行维护不同 escape speeds，类似 multi-scouts；MP 根据可行贡献或 CPF 覆盖选择性吸收。
- AP 到 EP 的共享从 feasible-only 扩展为 repair-success candidates、feasible probability high candidates 或 low-uncertainty candidates。
- 在 EP 发现可行解后，用局部 projection、constraint repair 或 equality root-finding 精修，改善等式约束弱点。
- BDES seed 选择可加入 active-constraint diversity、objective boundary、reference-vector occupancy，而不只用 kNN decision distance。

### 结构创新

- 构建 CV-unreliable CMOEA：

```text
UPF anchor population
-> escaping scout population with adaptive speed
-> feasibility exploitation population
-> constrained information gate
-> boundary/sparse-region intensification
```

- 与自适应 CV 粒度组合：EP 完全 objective-only，MP 用逐步细化的 `CV`，AP 只负责 UPF anchor 和 feasible stop signal。
- 与 surrogate-assisted CMOP 组合：代理预测 feasible probability、UPF-CPF distance 或 constraint activity，用于控制 escape speed 和真实评价候选。
- 与 dynamic constrained MOP 组合：环境变化后重启 EP，沿旧 UPF/新 UPF 差异方向快速逃逸，寻找新 CPF。
- 与多任务 CMOEA 组合：把 slow/medium/rapid escape 当作辅助任务，各任务用可行贡献和区域覆盖决定资源分配。

## 适用条件与风险

- 适用条件：
  - 目标函数可稳定引导 AP 接近 UPF；
  - CPF 与 UPF 有某种可通过 outward search 探索的相对几何关系；
  - 可按 reference vectors 或 angle subregions 维持分布；
  - 有足够预算维护至少两个或三个种群；
  - 可行性检测可靠，即使 `CV` 大小不可靠。
- 不适用或可能失效的条件：
  - CPF 完全由极窄等式约束定义，逃逸种群很难精确命中；
  - UPF 与 CPF 无关，objective-only 逃逸方向不穿过有价值可行区域；
  - many-objective 中 angle subregions 过稀，second-best/worst 的层次含义变弱；
  - 约束评价噪声导致 feasible flag 不可靠，AP feasible-only sharing 可能误导 EP；
  - 多种群预算不足，EP 逃逸会挤占 MP exploitation。
- 计算与实现成本：
  - 至少维护 AP、EP、MP 三套 population state；
  - 每代需要 subregion assignment 和 angle fitness ranking；
  - BDES 需要 MP 内 pairwise distance 或 kNN 计算；
  - 若使用多个 EP 或 adaptive quantile，状态控制和参数调度复杂度会上升。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0271 | 作者定义 deceptive constraint：沿 CPF 法线更近的不可行解可能有更大 `CV`，使 `CV` 不再可靠 | 问题定义 | Sec. I，PDF 1-2 |
| P2026-0271 | Fig. 1 比较 MW1、DCMOP1 和 FCP1，说明 simple/complex DCMOP 中 `CV` 会误导搜索 | 问题分析 | Sec. I，Fig. 1，PDF 2 |
| P2026-0271 | 作者指出 ICMA/DPTPEA/EMCMMS 等 DCMOP 方法存在 exploitation 不足或采样资源浪费 | 问题动机 | Sec. II-E/F，PDF 5 |
| P2026-0271 | EP 通过忽略约束并保留子区中的 suboptimal solutions 从 UPF 逃逸；slow retain second-best，rapid retain worst | 作者提出的方法 | Sec. III-A，PDF 6 |
| P2026-0271 | DEPEA 由 AP、EP、MP 三种群和 UPF exploitation / CPF exploration 两阶段组成 | 框架设计 | Sec. III-B，Algorithm 1，PDF 7 |
| P2026-0271 | UPF exploitation phase 中 AP 独立追 UPF，EP slow escape，且只有 AP 中可行解单向共享给 EP | 作者提出的方法 | Sec. III-C，Algorithm 2，PDF 7-8 |
| P2026-0271 | Algorithm 3 给出 escape mode 环境选择：无可行解时 slow 选 second-best，rapid 选 worst；有可行解时选最佳可行解 | 作者提出的方法 | Sec. III-C/D，Algorithm 3，PDF 9-10 |
| P2026-0271 | CPF exploration phase 中 MP 复制 EP，MP 用 CDP，EP rapid escape；EP 停止后 MP 用 BDES 和 neighbor pairing 进化 | 作者提出的方法 | Sec. III-D，Algorithm 4，PDF 10 |
| P2026-0271 | BDES 选择最高 kNN sparsity 的 seed，并用 DE/seed/1 生成 offspring 强化 sparse/boundary regions | 作者提出的方法 | Sec. III-D，Algorithm 5，PDF 10-11 |
| P2026-0271 | DCMOP/FCP 11 个问题上，DEPEA 相比 13 个算法 IGD+ 显著更优数量为 11/10/11/11/11/10/9/11/6/10/11/11/9 | 综合实验支持 | Sec. IV-B，Table I，PDF 12 |
| P2026-0271 | FCP5 分析显示只有 DEPEA、EMCMMS、ICMA 找到 upper CPF segment，DEPEA 最好；DPTPEA 因已有可行解不触发 sampling 而失败 | 行为解释 | Sec. IV-B，PDF 12 |
| P2026-0271 | NCMOP 23 个问题上，DEPEA 相比 13 个算法 IGD+ 显著更优数量为 20/19/21/20/20/17/18/21/15/18/15/19/21 | 泛化实验支持 | Sec. IV-B，PDF 12-13 |
| P2026-0271 | 消融中 `noEP` 在 FCP 全部失败，`onlyR` 和 `third` 在 FCP3/FCP4 无可行解，`onlyS` 因 escape 停滞整体弱于 DEPEA | 消融支持 | Sec. IV-C，PDF 13 |
| P2026-0271 | `weakC` 在 FCP3/FCP4 无可行解，说明普通 weak cooperation 会阻碍 EP slow escape；`along` 在 NCMOP 退化，说明 feasible sharing 有助于停止逃逸 | 合作机制消融 | Sec. IV-C，PDF 13-14 |
| P2026-0271 | 作者结论承认 slow escape 对 equality constraints 不足，未来研究 bidirectional/adaptively weighted collaboration | 局限与未来工作 | Sec. V，PDF 14 |

## 证据边界

- 当前只有单篇论文证据。
- 主文大量结果依赖 supplementary，包括 HV、真实问题、参数敏感性、scalability、memory 和完整 rank 统计。
- DEPEA 的优势来自 EP、AP/EP 合作、MP/CDP、BDES 等组合，不能把全部效果归因于逃逸保留规则。
- 对 equality constraints 表现不足，说明逃逸机制更适合找到区域而不是精确投影到等式流形。
- Algorithm 1/4 在 Markdown OCR 中有表格噪声，细节以正文解释为主。

## 待确认

- escape rank 是否应由固定 second-best/worst 改为 adaptive quantile；
- UPF-CPF 几何距离如何在线估计，并用于决定是否需要 EP 或多快逃逸；
- feasible-only sharing 在 noisy constraints、昂贵约束或 surrogate 约束下如何避免误触发；
- BDES 的 decision-space kNN sparsity 是否可替换为 objective/constraint boundary sparsity；
- many-objective DCMOP 中 reference-vector subregion 的层次保留是否仍有效。
