---
knowledge_id: K-overall-minority-dualtask-feature-selection-transfer
name: 总体-少数类双任务特征选择迁移
type: method
status: active
source_papers: [P2026-0169]
aliases: [CIL-MTFS, class-imbalanced multi-task feature selection, overall-minority dual-task feature selection, minority-error-triggered transfer, cost-sensitive auxiliary task, constrained feature selection, 不均衡特征选择, 少数类误差触发迁移]
promotion_reason: 单篇论文提出但接口明确，包含 overall constrained MOP、minority-sensitive cost objective、full-set-error feasibility threshold、少数类错误触发的 cross-task mating replacement 和消融证据，可直接改造高维不均衡分类、二进制特征选择、传感器选择与子集型 MOO。
---

# 总体-少数类双任务特征选择迁移

## 核心内容

把高维不均衡分类的特征选择拆成两个相关但关注点不同的任务：

```text
T1: overall task
    minimize balanced error + selected feature ratio
    constrain balanced error <= full feature set error
    output feasible non-dominated feature subsets

T2: minority-sensitive task
    minimize cost-sensitive error
    class weights from sample imbalance or current population error

cross-task transfer:
    if a T1 mating parent has minority error worse than T1 average
    replace its paired parent with a T2 parent that is better for minority class
    then crossover/mutation and duplicate removal
```

这样 `T1` 防止输出低特征但高错误的无意义 Pareto 解，`T2` 提供少数类特征信号，迁移机制只在 class-specific performance discrepancy 明显时注入对少数类有用的父代信息。

## 建立理由

- 为什么值得独立维护：高维不均衡特征选择同时有三重冲突：整体分类性能、少数类性能和特征数。该知识给出一个可复用的任务拆分和迁移接口，不要求人工重采样，也不把 minority objective 简单塞进同一个 Pareto front。
- 单篇具体方法的直接复用价值：P2026-0169 给出 `T1/T2` 公式、Algorithm 1-2、minority-error transfer trigger、positive-drift explanation、17 个真实数据集和单任务消融。
- 与已有设计知识的区别：
  - 不同于“参考解引导的跨任务知识迁移”：该知识用全局精英参考解控制迁移方向；本知识用少数类错误差距决定是否从 minority task 替换 mating parent。
  - 不同于“多邻域多知识的分解式多任务迁移”：该知识面向 MO-MTO 的子问题邻域和迁移算子池；本知识面向同一特征选择问题的 problem-formulation-level dual task。
  - 不同于“滤波性能预测的特征子集预筛选”：该知识在评价前用 filter 指标节省 wrapper evaluations；本知识改变任务构造和跨任务 offspring generation。
  - 不同于“单侧规则-分类器双阶段 Pareto 进化”：该知识直接学习可解释规则分类器；本知识输出特征子集，可搭配 KNN、SVM 或其他 classifier。

## 解决的问题

- 适用场景：
  - 高维二进制/子集型特征选择，尤其是 features 远多于 samples；
  - 类别不均衡，少数类或高错误类别是业务关注点；
  - 不希望通过 oversampling/undersampling 改变原始训练数据；
  - 希望输出一组“误差不差于全特征集”的可用 feature subsets，而不是完整但含大量无意义解的 Pareto front。
- 现有方法为什么会失败或不足：
  - 只优化 overall balanced error 和 feature ratio，可能仍漏掉少数类关键特征；
  - 只优化 cost-sensitive/minority objective，可能牺牲 majority/overall performance；
  - 固定 random mating probability 的多任务迁移会传播无关或有害特征子集；
  - 传统 Pareto selection 可能保留“特征很少但 error 极高”的非支配解，增加决策负担。
- 仍需解决的问题：
  - 多少数类或 long-tailed 多类别任务如何设计多个辅助任务；
  - full-set-error threshold 如何避免受全特征集过拟合影响；
  - 如何减少 `T2` 迁移带来的特征数膨胀；
  - 如何与 wrapper evaluation 加速机制结合。

## 为什么可能有效

```text
overall objective can be majority-dominated
-> T1 uses balanced error and feature ratio but constrains error <= full set
-> T2 uses cost-sensitive weights from data imbalance or current errors
-> T2 population stores minority-informative feature subsets
-> T1 individuals with above-average minority error trigger transfer
-> mating parent replacement injects minority features only when needed
-> T1 constraint filters offspring that hurt overall performance
```

关键假设是：`T2` 中较好的少数类父代确实携带可迁移的特征组合，并且 `T1` 的 feasibility constraint 能挡住负迁移。如果少数类噪声很强、`T2` 过拟合少数样本，或 full feature set threshold 本身不可靠，迁移可能带来不稳。

## 实现接口

- 输入：
  - 训练数据、类别标签、特征数 `D`；
  - 二进制 feature subset encoding；
  - base classifier 和 cross-validation protocol；
  - population size `N`、maximum generations、crossover/mutation operators。
- 核心目标：

```text
T1:
    ferr(x) = 1 - (1/c) * sum_i TP_i / |S_i|
    fratio(x) = (1/D) * sum_d x_d
    minimize (ferr(x), fratio(x))
    subject to ferr(x) - ferr(x_full) <= 0

T2:
    minimize 1 - sum_i w_i * TP_i / |S_i|
    choose class-weight vector from inverse sample size or current population error
```

- 迁移逻辑：

```text
k <- class with smallest sample size
err_k <- average minority error of P1
for each mating pair in MP1:
    if minority_error(parent_a) > err_k:
        replace parent_b by corresponding MP2 parent
    if minority_error(parent_b) > err_k:
        replace parent_a by corresponding MP2 parent
generate offspring by crossover/mutation
remove duplicate feature subsets
evaluate offspring on both tasks
```

- 输出：
  - `P1` 中 feasible non-dominated feature subsets；
  - 可选输出每类 error、selected feature ratio、触发迁移次数和来自 `T2` 的父代比例。

## 如何用于算法创新

### 局部创新

- 把固定 `ferr(x_full)` 约束改为 `ferr(x) <= ferr(x_full) - delta`、置信区间约束或用户给定 minimum acceptable performance。
- 对 `T2` 加入 feature ratio、feature cost 或 stability penalty，避免 minority task 只追分类性能。
- 把迁移触发从单一 minority class 扩展为 per-class error vector，对多个困难类别分别选择 donor task。
- 用 offspring survival rate 或 post-transfer improvement 反馈调整 transfer probability，而不是只按当前 error 差距触发。
- 与 filter-based preselection 组合，先生成 cross-task offspring，再用低成本 filter/wrapper rank 预筛真实评价候选。

### 结构创新

- 多类别 long-tailed 架构：

```text
overall constrained task
-> head-class stability task
-> multiple tail-class or class-cluster tasks
-> class-error-triggered transfer router
-> feasible Pareto output archive
```

- 将 feature selection、sample cleaning 和 classifier hyperparameter tuning 设为三个任务，分别处理噪声样本、特征冗余和模型偏置。
- 用 task-specific archives 记录每类高贡献特征，再通过 overall task 验证其全局可用性。
- 将该模式迁移到传感器选择、基因选择、故障诊断变量选择和推荐特征选择。

## 适用条件与风险

- 适用条件：
  - 类别标签明确，且能统计每类 `TP_i/|S_i|`；
  - 各任务共享同一 feature subset encoding；
  - wrapper evaluation 成本可承受，或已有预筛/代理机制；
  - 业务更关心“可用的高性能少特征子集”，而不是传统完整 Pareto front。
- 不适用或可能失效的条件：
  - 少数类样本极少且标签噪声高，`T2` 容易过拟合；
  - full feature set classifier 表现很差或严重过拟合，阈值约束失去意义；
  - 类别数很多且多个类别同时稀缺，单一 `argmin |S_i|` 无法代表全部 tail classes；
  - 数据分割导致某些 fold 缺少少数类，class-specific error 高方差。
- 计算与实现成本：
  - 每个 offspring 需同时在两个任务上评价，真实成本仍由 classifier training/cross-validation 主导；
  - 每代复杂度不含评价为 `max{O(DN), O(N^2)}`；
  - 需要维护 `P1/P2`、两套 selection 规则和迁移父代替换逻辑。
- 解释风险：
  - 输出特征更多不一定是失败，可能是 full-set-error constraint 对性能的保护；
  - HV 较低不一定代表更差，因为算法主动排除了应用上无意义的高误差区域；
  - cost-sensitive weights 同时受样本比例和当前 population error 影响，实验报告应分解每类性能。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0169 | `T1` 定义为 constrained multi-objective feature selection，目标为 balanced error 与 selected feature ratio，约束为 `ferr(x)<=ferr(x_full)` | 作者提出的方法 | Sec. III-A，Eq. (1)-(3)，PDF 4 |
| P2026-0169 | `T2` 使用 cost-sensitive objective，class weights 来自 inverse sample size 或当前 population 平均错误率 | 作者提出的方法 | Sec. III-A，Eq. (4)-(5)，PDF 4-5 |
| P2026-0169 | Algorithm 1 用 `P1/P2` 双任务评价、分任务 mating selection、cross-task genetic transfer 和分任务 environmental selection | 作者提出的方法 | Sec. III-B，Algorithm 1，PDF 5 |
| P2026-0169 | Algorithm 2 识别最小样本类 `k`，用 `P1` 平均 minority error 判断是否用 `MP2` 父代替换 `MP1` 配对父代 | 作者提出的方法 | Sec. III-C，Algorithm 2，PDF 6-7 |
| P2026-0169 | 分析给出 `E[mu'_1]=mu_1+ptr(mu_2-mu_1)`，说明在 `mu_2>mu_1` 且触发迁移时 minority performance 有正漂移 | 理论解释 | Sec. III-D，Eq. (6)，PDF 7 |
| P2026-0169 | 17 个真实数据集覆盖 22-22283 个特征、32-1593 个样本、IR 1.00-9.08 | 实验设置 | Table I，PDF 8 |
| P2026-0169 | CIL-MTFS 相比 full feature set 在至少 12/17 数据集的分类指标上更好，同时显著减少特征；Yeoh-2002-v1 和 CNS 是高维示例 | 综合实验支持 | Sec. V-A，Table II，PDF 9 |
| P2026-0169 | KNN F1-score、G-mean、MCER 中 CIL-MTFS 的 Friedman rank 分别为 2.5882、2.8824、2.5294，主文表中均为第一 | 对比实验支持 | Tables III-V，PDF 10-11 |
| P2026-0169 | Fig. 2 显示 CIL-MTFS 输出多位于 full feature set error 阈值以下或附近，其他方法会保留高 error 非支配解 | 机制可视化 | Sec. V-C，Fig. 2，PDF 11-12 |
| P2026-0169 | HV 排名不总是最好，作者解释为 CIL-MTFS 聚焦可用区域而非完整 Pareto front | 证据边界/指标解释 | Sec. V-D，PDF 12 |
| P2026-0169 | Ablation 中 CIL-MTFS 在 MCER/F1/G-mean 上分别显著优于 CIL-T1FS 的 6/8/8 个数据集，优于 CIL-T2FS 的 4/6/6 个数据集 | 消融实验支持 | Sec. V-E，Table VI，PDF 12-13 |
| P2026-0169 | 作者未来工作包括 long-tailed classification、进一步减少特征、结合 sample cleaning 和 sample selection | 作者未来工作 | Sec. VI，PDF 13 |

## 证据边界

- 当前只有单篇论文证据，尚缺独立复现和跨数据划分稳定性分析。
- 主要证据来自 tabular classification；图像长尾、数据流、文本或多标签不均衡任务尚未验证。
- CIL-MTFS 输出可能选更多特征，这是方法主动保护分类性能的代价。
- 复杂度分析省略 classifier training cost，真实成本可能远高于算法控制流成本。
- Weighted SVM 和 HV 的部分结果依赖 supplement，主文只给出摘要性解释。

## 待确认

- 多 minority classes 下是否应维护多个 `T2` 或按 class cluster 构造辅助任务；
- full-set threshold 是否应根据 validation/test generalization 而不是 training error 设置；
- cost-sensitive weight 选择规则是否应平滑或同时融合 `w_dat` 与 `w_alg`；
- transfer trigger 是否应加入 majority degradation、feature ratio 和 offspring survival feedback；
- 与 filter predictor、surrogate 或 sample cleaning 组合时如何分配评价预算。
