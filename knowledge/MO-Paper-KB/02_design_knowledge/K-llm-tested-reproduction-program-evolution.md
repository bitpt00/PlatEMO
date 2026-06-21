---
knowledge_id: K-llm-tested-reproduction-program-evolution
name: 可执行测试修复的 LLM 算法代码进化
type: architecture
status: active
source_papers: [P2026-0228]
aliases: [LLMMOP, LLM-assisted MOEA design, LLM program evolution, Pilot Run and Repair, textual crossover mutation, Reproduction evolution, LLM算法设计, 代码进化, 错误驱动修复]
promotion_reason: 单篇论文提出但架构完整，包含 LLM 生成算法代码、独立进程可执行测试、错误驱动修复、动态父代文本交叉变异和多问题并行评分，可直接用于 MOEA 算子、启发式、修复器和选择策略的自动设计
---

# 可执行测试修复的 LLM 算法代码进化

## 核心内容

把算法部件视作程序个体，让 LLM 负责生成、交叉、变异和修复代码；把可执行测试、错误信息和小规模问题评分放进进化闭环。每个候选程序先在 sandbox/独立进程中限时 pilot run，失败时将编译或运行错误作为 prompt 反馈给 LLM 修复，成功后再在 validation problems 上并行评价并按分数参与下一轮文本进化。

```text
task prompt + format
-> LLM generates program population
-> pilot run in isolated process with time limit
-> if error: feed error back to LLM for repair
-> parallel validation scoring
-> dynamic parent selection by score
-> LLM textual crossover and mutation
-> elitist update of program population
```

在 P2026-0228 中，程序个体是 MOEA 的 `Reproduction` 方法，可包含 selection、crossover、mutation、repair 和 problem-specific search strategies。

## 建立理由

- 为什么值得独立维护：
  - LLM 自动设计算法的主要瓶颈不是能否生成代码，而是代码能否运行、错误能否修复、以及生成程序能否在任务分布上迭代变好；
  - 该架构把“程序可执行性”和“优化性能”同时纳入搜索循环，可迁移到不同算法部件设计。
- 单篇具体方法的直接复用价值：
  - P2026-0228 给出完整的 Operator Evolution、Initialization、Crossover、Mutation、Pilot Run and Repair、Parallel Evaluation 流程；
  - 证据覆盖 continuous MOP、MOKP、MOTSP，比较 hand-crafted MOEA 和 EOH，并有 prompt、repair、dynamic selection 消融。
- 与已有设计知识的区别：
  - 不同于“状态驱动的 DRL 演化算子选择”：该知识在固定算子库中选择动作；本知识让 LLM 生成新的可执行算法代码。
  - 不同于“目标条件化生成式设计采样”：该知识生成候选解；本知识生成优化算法部件本身。
  - 不同于“统计等价驱动的多标签算法选择”：该知识选择已有算法集合；本知识自动创造和修复新算法代码。
  - 不同于一般 NAS/结构修复：本知识的修复对象是可执行程序，反馈来自编译、运行和验证任务，而不是网络拓扑合法性。

## 解决的问题

- 适用场景：
  - 需要自动设计或改造算法部件，例如 reproduction、repair、local search、initialization、selection 或 hyper-heuristic；
  - 有一组小规模 validation tasks 可以快速评估候选程序；
  - 候选程序错误频繁，但错误信息可被捕获并反馈给 LLM；
  - 离线搜索成本可接受，希望减少专家手工设计。
- 现有方法为什么会失败或不足：
  - 一次性 LLM 生成代码缺少性能反馈和错误修复；
  - 直接丢弃崩溃程序会浪费潜在创新结构；
  - 固定父代数量和固定 prompt 容易让 LLM 输出相似代码，造成停滞；
  - 手工 MOEA 难以快速适应不同编码和问题族。
- 仍需解决的问题：
  - 如何保证商业 LLM 版本变化下的可复现性；
  - 如何把运行时间、代码复杂度和可维护性纳入评分；
  - 如何避免 validation overfitting；
  - 如何在强安全约束下执行 LLM 生成代码。

## 为什么可能有效

```text
LLM can propose nonstandard algorithm code
-> many proposals contain syntax/runtime/logic errors
-> pilot run converts execution failure into structured feedback
-> repair prompt recovers usable variants instead of discarding them
-> validation score gives task-level fitness
-> dynamic textual crossover changes parent set and prompt content
-> iterative selection accumulates useful design fragments
```

关键假设是：validation tasks 能代表目标问题族，且 LLM 能根据错误信息和父代代码做有意义的修改。如果 validation set 过窄，生成算法可能过拟合；如果错误信息缺失或 sandbox 不充分，修复会变得盲目或不安全。

## 如何用于算法创新

### 局部创新

- 用 LLM 自动生成某个 MOEA 的 mutation、crossover、repair 或 local search 函数，并在小规模测试集上筛选。
- 对已有算子库进行 textual mutation，让 LLM 产生混合算子、阶段切换规则或参数自适应逻辑。
- 将 runtime、HV/IGD、可行率和代码长度加入 score，筛掉高质量但过慢或过复杂的程序。
- 在 repair prompt 中加入单元测试、断言、边界样例、类型签名和失败 trace，提高修复精度。

### 结构创新

- 构建算法工厂：

```text
problem family spec
-> generate initial program population
-> sandbox test and repair
-> evaluate on small validation suite
-> evolve programs by LLM crossover/mutation
-> archive best programs and failure cases
-> test generalization on larger hidden suite
```

- 为不同问题族维护 program archive，新问题先检索相似问题的高分算法代码，再让 LLM 局部变异。
- 将 expert rules 写成 soft constraints 或 scoring rubrics，与 LLM 程序进化结合，减少黑箱问题早期低质量生成。
- 建立失败模式库，把常见越界、死循环、维度不匹配、约束修复错误转成 reusable repair prompts。

## 适用条件与风险

- 适用条件：
  - 候选算法部件有明确输入输出格式；
  - 可以自动运行和评分；
  - 有资源执行多次 LLM 调用和 validation runs；
  - 可以用 sandbox、时间限制和错误捕获保护运行环境；
  - validation set 与未来 testing set 同属一个问题族。
- 不适用或可能失效的条件：
  - 评价极其昂贵，无法支持程序种群进化；
  - 任务缺少稳定自动评分，只能人工判断；
  - LLM 生成代码不可安全执行或依赖不可控外部资源；
  - validation set 太小，导致程序过拟合特定实例；
  - 实时在线优化场景无法承受 LLM 调用和程序搜索开销。
- 计算与实现成本：
  - 成本包含 LLM 调用、pilot run、repair trials 和多问题并行评价；
  - P2026-0228 中 program population `Nev=10`，fitness evaluation 100，pilot run time limit `MaxT=2000s`，repair trials `Ntrial=2`；
  - LLMMOP 在 MOTSP 上得到高质量但 runtime 最长，说明评分需显式考虑效率。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0228 | LLMMOP 将 MOEA 的 `Reproduction` 方法作为程序个体，经过 initialization、dynamic selection、crossover、mutation、parallel evaluation 和 elitist update | 作者提出的方法 | Sec. III，Algorithm 1，PDF 4-5 |
| P2026-0228 | Initialization prompt 包含 task/system、problem description、requirements 和输出 format，用于生成初始 reproduction population | 作者提出的方法 | Sec. III-A，Algorithm 2，PDF 5 |
| P2026-0228 | Dynamic Reproduction Selection 按 score 计算选择概率，并随机选择 `Ns` 个父代用于 textual crossover | 作者提出的方法 | Sec. III-B，PDF 5 |
| P2026-0228 | Crossover 和 Mutation 分别让 LLM 基于多个父代代码或单个代码生成新 reproduction，mutation 概率为 `1/2` | 作者提出的方法 | Sec. III-C/D，Algorithms 3-4，PDF 6 |
| P2026-0228 | Pilot Run and Repair 用独立进程限时执行候选代码，捕获 error 后把错误信息加入 repair prompt 与 LLM 对话修复 | 作者提出的方法 | Sec. III-E，Algorithm 5，PDF 6-7 |
| P2026-0228 | 实验覆盖 CMOP、MOKP 和 MOTSP，validation 用小规模实例，testing 用更大规模实例检验泛化 | 实验设置 | Sec. IV-A，PDF 7-8 |
| P2026-0228 | LLMMOP 在 testing CMOP 上取得最低 average IGD，尤其在 ZDT6、DTLZ1、DTLZ6 等困难任务上更好 | 综合实验支持 | Sec. IV-B，Table II，PDF 9 |
| P2026-0228 | LLMMOP 在 testing MOKP 上取得最好 average HV，并生成有效 repair function，例如移除 heaviest item 满足容量约束 | 综合实验支持 | Sec. IV-B，Table III，PDF 10 |
| P2026-0228 | LLMMOP 在 testing MOTSP 上取得最好或竞争性泛化表现，说明 validation 最优不一定 testing 最优 | 综合实验支持 | Sec. IV-B，Table IV，PDF 11 |
| P2026-0228 | Efficiency analysis 显示 LLMMOP 在 CMOP/MOKP 上有竞争力，但 MOTSP runtime 约 841 s，为对比方法中最慢 | 成本边界 | Sec. IV-B，Table V，PDF 12 |
| P2026-0228 | 不同 LLM 实验显示 LLMMOP 对 GPT4、GPT4O、Gemini、Claude 均有效，Claude 最优 reproduction 包含 hybrid strategy 与自适应算子 | 跨模型支持 | Sec. IV-C，Fig. 7，PDF 12 |
| P2026-0228 | Informative prompting 相比 concise prompting 在 MOKP/MOTSP 初始化 reproduction quality 上更好，MOTSP 差异更明显 | 消融实验支持 | Sec. IV-D，Fig. 8，PDF 13 |
| P2026-0228 | Pilot Run and Repair 实验中 GPT4 初始成功率较低但 repair success rate 为 81.8%，GPT4O/Gemini 初始可执行率约 80% | 机制证据 | Sec. IV-D，Table VI，PDF 13 |
| P2026-0228 | 去掉 dynamic selection 的 GPT4-no-dc 在 CMOP validation 上停滞，带 dynamic selection 的版本持续提升 | 消融实验支持 | Sec. IV-D，Fig. 9，PDF 13 |
| P2026-0228 | 未来工作包括融合专家知识提升黑箱优化效率，并研究不同 LLM 的算法生成质量和一致性 | 未来工作 | Sec. V，PDF 14 |

## 待确认

- 主文表格在当前 Markdown 中为图片占位，精确数值需后续从 PDF 表格或 supplementary 补全。
- 生成算法对商业 LLM 版本更新、温度和 prompt 细节的敏感性。
- 如何设计隐藏 testing suite 防止 validation overfitting。
- 如何将安全 sandbox、依赖管理、代码静态分析和资源限制纳入标准流程。
