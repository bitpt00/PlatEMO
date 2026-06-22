# CMOEA-AOP 实验入口

这是供 GPT Pro 审阅、Codex 执行的固定 GitHub 入口。

## 优先阅读

1. 长期研究计划：`RESEARCH_PLAN.md`
2. 子实验工作区：`studies/README.md`
3. 给网页端 GPT Pro 的提示词：`GPT_WEB_PROMPT.md`
4. 基准论文全文 PDF：`papers/2603.16401v1.pdf`
5. 实验协议：`protocol.md`
6. 基准复现实验记录：`baseline_reproduction.md`
7. 候选改进想法：`variant_ideas.md`
8. 知识库入口：`../../../knowledge/MO-Paper-KB/GPT_ENTRY.md`
9. CMOEA-AOP 论文卡片：`../../../knowledge/MO-Paper-KB/01_papers/P2026-0201.md`
10. DRL 算子选择设计卡片：`../../../knowledge/MO-Paper-KB/02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md`

## 需要查看的代码

基准实现：

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/
```

实验变体：

```text
PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP-Lab/
```

关键文件：

- `CMOEAAOP.m`
- `DDPG.m`
- `GenerateSample.m`
- `OperatorConstrainedAOP.m`
- `EnvironmentalSelection.m`
- `CalFitness.m`

GitHub 代码地址：

```text
https://github.com/bitpt00/PlatEMO/tree/codex-test-upload/PlatEMO/Algorithms/Multi-objective%20optimization/CMOEA-AOP
```

## GPT Pro 审阅任务

提出修改建议时，请尽量给出：

1. 来自论文全文、论文卡片或设计知识卡片的依据。
2. 基准 CMOEA-AOP 的失败模式或局限。
3. 需要修改的具体代码模块。
4. 交给 Codex 执行的最小实现方案。
5. 最小 smoke test 和消融实验方案。

## Codex 需要回写的内容

实现后，Codex 应更新：

- `baseline_reproduction.md`：只记录原始基准复现实验；
- 对应 `studies/<study>/summary.md`、`runs.csv`、`checkpoints.csv`：真实实验结果存在后再写；
- `summaries/`：需要跨实验紧凑表格和图时再写；
- 本实验目录：记录实现说明和供 GPT Pro 审阅的材料。
