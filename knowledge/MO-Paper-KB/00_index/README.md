# 索引与规则

本目录只保存知识库入口信息：

- `papers.csv`：论文 ID、标题、原始文件路径和处理状态；
- `paper_queue.ps1`：自动发现、去重、领取和完成标记；
- `paper_processing_sop.md`：单篇论文的最简处理流程。
- `新对话处理单篇论文_执行指令.md`：每次新开 AI 对话时使用的完整执行入口。

不在本目录维护方法、证据、关系或算法结构等复杂索引。需要查找或判断设计知识是否重复时，直接全文搜索论文卡和设计知识卡正文。

## 队列命令

```powershell
# 扫描新增文件并查看队列状态
& 'E:\多目标优化\MO-Paper-KB\00_index\paper_queue.ps1' -Action status

# 自动领取下一篇并标记为 in_progress
& 'E:\多目标优化\MO-Paper-KB\00_index\paper_queue.ps1' -Action claim

# 成功完成后标记为 extracted
& 'E:\多目标优化\MO-Paper-KB\00_index\paper_queue.ps1' -Action complete -PaperId P2026-0002

# 未完成时释放，退回 unprocessed
& 'E:\多目标优化\MO-Paper-KB\00_index\paper_queue.ps1' -Action release -PaperId P2026-0002
```

状态含义：

```text
unprocessed  等待处理
in_progress  已被某个对话领取
extracted    已完成详细论文卡
reviewed     已进一步复核
missing-md   尚缺 Markdown
missing-pdf  尚缺 PDF
```
