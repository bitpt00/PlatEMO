# 给网页端 GPT Pro 的提示词

请你作为多目标优化研究顾问，基于 GitHub 上的论文全文、算法代码和知识库，为 CMOEA-AOP 提出有实验价值的机制解释和后续改进方向。

## 必读资料

请按顺序阅读：

1. 完整基准论文 PDF：
   `research/experiments/cmoea-aop/papers/2603.16401v1.pdf`
2. CMOEA-AOP 原始代码：
   `PlatEMO/Algorithms/Multi-objective optimization/CMOEA-AOP/`
3. 论文卡片：
   `knowledge/MO-Paper-KB/01_papers/P2026-0201.md`
4. 相关设计知识卡片：
   `knowledge/MO-Paper-KB/02_design_knowledge/K-drl-state-driven-evolutionary-operator-selection.md`
5. 实验协议：
   `research/experiments/cmoea-aop/protocol.md`
6. 候选想法草案：
   `research/experiments/cmoea-aop/variant_ideas.md`
7. 已完成或正在进行的子实验：
   `research/experiments/cmoea-aop/studies/`

代码目录的 GitHub URL：

```text
https://github.com/bitpt00/PlatEMO/tree/codex-test-upload/PlatEMO/Algorithms/Multi-objective%20optimization/CMOEA-AOP
```

## 你的任务

请不要直接写代码。请先做研究判断，输出适合交给 Codex 执行的算法实验建议。

重点分析：

1. CMOEA-AOP 的 `state`、`action`、`reward`、`operator allocation`、`population transfer` 或 `environmental selection` 中，哪些位置最值得改；
2. 论文中是否有作者明确提到的局限、未来工作或实验边界；
3. 知识库中有哪些设计知识可以迁移到 CMOEA-AOP；
4. 哪些修改是“小而可验证”的，适合作为下一批实验；
5. 哪些修改风险太高，暂时不适合让 Codex 实现。

## 输出格式

请输出 3 到 5 个候选方向。每个方向按下面格式写：

```text
方向名称：
修改动机：
论文/PDF 证据：
知识库证据：
需要修改的代码文件：
具体修改方案：
最小实验验证：
预期收益：
主要风险：
是否建议作为下一批实验：
```

最后请给出一个排序，明确推荐下一批让 Codex 实现哪个方向。
