# GPT 阅读入口

本知识库用于给网页版 GPT 提供多目标优化论文知识和可复用设计知识。阅读时不要默认通读全部文件，先按任务入口读取最小必要上下文。

## 总体阅读顺序

1. 先读本文件，确认当前任务入口。
2. 需要了解知识库规则时，读 `README.md` 和 `项目需求说明_供AI审查.md`。
3. 需要查论文时，优先读 `01_papers/` 中对应论文卡。
4. 需要找可复用方法时，先读 `02_design_knowledge/README.md` 的极简索引，再打开相关设计知识卡。
5. 只有论文卡或设计知识卡信息不足时，才建议回查原始 PDF。

## CMOEA-AOP 实验入口

如果任务是讨论、审查或改进 PlatEMO 中的 CMOEA-AOP，请优先阅读：

```text
01_papers/P2026-0201.md
02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md
```

对应代码在 PlatEMO 仓库：

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/
```

重点判断：

- CMOEA-AOP 的 state、action、reward 是否有可改进空间；
- 修改是否仍保留 automated operator portfolio 的核心思想；
- 新想法应做哪些 baseline、ablation 和 smoke test；
- 实验结果是否足以支持下一步修改。

## 给 GPT 的输出要求

讨论算法修改方向时，请输出：

1. 修改动机：来自哪条论文证据或设计知识；
2. 修改位置：对应 CMOEA-AOP 的哪个模块；
3. 具体方案：state、action、reward、selection 或 operator 的改法；
4. 风险：可能破坏公平性、稳定性或可复现性的地方；
5. 实验验证：最小 smoke test、对照实验和需要记录的指标。

不要直接要求 Codex 大范围重构。先形成一个可执行的小修改，再交给 Codex 实现。
