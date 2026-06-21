---
knowledge_id: K-mlp-subspace-sparse-gp-asd-infill
name: MLP 子空间筛选与稀疏 GP 的高维昂贵 MOO
type: method
status: active
source_papers: [P2026-0178]
aliases: [MLPSGP-SAEA, MLP grouping, sparse Gaussian process SAEA, ASD infill criterion, pseudo-input SGP, knee point completion, 高维昂贵多目标优化, MLP变量敏感性子空间, 稀疏GP代理, ASD填充准则]
promotion_reason: 单篇论文提出但实现接口完整，包含 MLP 扰动敏感性变量筛选、每目标 sparse GP pseudo-input 建模、LCB/EI 的密度多样性 ASD infill 和膝点全空间补全，可直接改造高维昂贵 MOO/SAEA 的变量子空间、代理建模与真实评价候选选择层。
---

# MLP 子空间筛选与稀疏 GP 的高维昂贵 MOO

## 核心内容

在高维昂贵多目标优化中，不直接在完整决策空间训练标准 GP。先用已评价 archive 训练一个浅层 MLP 近似 `X -> Y`，再对每个决策变量加入小扰动并观察 MLP 输出变化，得到变量重要性。随后按重要性权重无放回抽取一个低维子空间，在该子空间中为每个目标训练 sparse GP，并用 pseudo-input 降低标准 GP 的三次训练复杂度。代理内搜索用 ASD infill，把 LCB 与 EI 分别按样本密度和候选多样性缩放；最终候选只优化子空间变量，未选维度由 archive 膝点填充回完整解后再真实评价。

```text
true archive
-> train shallow MLP on normalized full-space data
-> perturb each variable and score objective sensitivity
-> weighted sample Dsub variables as subspace
-> train objective-wise SGP with k-means pseudo-inputs
-> NSGA-II inner search using ASD = LCB/rho + EI/Div
-> cluster surrogate candidates and nondominated archive points
-> fill unselected dimensions from knee point
-> true evaluate and update archive
```

P2026-0178 的 MLPSGP-SAEA 是该模式的实例：`Dsub` 随问题维度设定，`Mps=10`，每轮真实评价 5 个候选，内层使用 NSGA-II 搜索 SGP+ASD 代理目标。

## 建立理由

- 为什么值得独立维护：
  - 该知识把高维 SAEA 中最容易互相缠绕的三个问题拆开：变量子空间怎么选、GP 怎么降本、infill 怎么在 SGP 不确定性偏差下保持探索和开发。
  - 它不是只做变量分组，也不是只做代理选模，而是给出“子空间概率代理 + 全空间补全”的完整可移植接口。
  - MLP 扰动敏感性避免随机子空间完全盲选；SGP 保留 GP 不确定性接口；ASD 把密度和多样性显式接入 LCB/EI。
- 单篇具体方法的直接复用价值：
  - P2026-0178 给出 Algorithm 1-3、ASD 公式、候选补全图、DTLZ/UF/WFG/LSMOP benchmark、消融、参数敏感性、运行时间和 airfoil 真实应用证据。
- 与已有设计知识的区别：
  - 不同于“目标级自适应代理与双空间 infill 采样”：该知识按每个目标在 GP/RBF 间选模型，并用双空间距离选真实评价点；本知识重点是高维子空间筛选、SGP 降本和 ASD infill。
  - 不同于“自适应代理内环加速器”：该知识把代理内环插入宿主子代与真实评价之间，并用贡献半衰期退出；本知识围绕 SGP 代理自身的子空间建模和候选补全。
  - 不同于“特殊点引导的代理辅助复杂前沿搜索”：该知识把膝点/断裂点作为独立 infill 来源；本知识只用膝点作为未选维度的全空间补全锚点，核心仍是 MLP-SGP-ASD。
  - 不同于“收敛区间变量重要性与自感知资源分配”：该知识用真实扰动评价变量重要性并分配变量组资源；本知识用 MLP surrogate 估计变量敏感性，避免高维昂贵问题中逐变量真实评价。

## 解决的问题

- 适用场景：
  - 连续或可连续编码的高维 EMOP，真实评价远贵于 MLP/SGP 训练和代理查询；
  - 标准 GP 训练太慢，但仍希望保留不确定性以使用 LCB/EI 类 infill；
  - 决策变量中存在一部分短期更影响目标的关键变量；
  - 可以维护真实评价 archive，并允许低维候选补全为完整决策向量。
- 现有方法为什么会失败或不足：
  - 完整空间 GP 建模成本随样本数三次增长，高维下训练和矩阵运算都重；
  - 便宜代理替代 GP 可能丢失 uncertainty interface，infill 只能依赖预测值或排序；
  - 固定降维或随机子空间可能丢失关键变量，且无法随搜索过程调整；
  - SGP 仍可能在高维少样本下低估或高估不确定性，普通 EI/LCB 固定权重不稳；
  - 低维代理候选如果没有合理补全，真实评价时可能变成无效或局部集中的完整解。
- 仍需解决的问题：
  - 如何识别强交互变量，避免单变量 MLP perturbation 低估协同变量组；
  - 子空间大小、pseudo-input 数量和 ASD 权重如何自适应；
  - 膝点补全在复杂 PF、断裂 PF 或多模态 PS 中是否会造成区域偏置；
  - 代理训练成本在真实评价不够昂贵时是否划算。

## 为什么可能有效

```text
高维 EMOP 的完整 GP 训练昂贵
-> 用 MLP 快速估计变量对多目标输出的局部敏感性
-> 只在高权重变量子空间训练 SGP
-> pseudo-input 保留概率不确定性并降低 GP 复杂度
-> ASD 在稀疏区域提高 LCB 探索, 在多样性高区域保留 EI 开发
-> k-means 选代表候选减少重复真实评价
-> 膝点补全未选维度保留当前折中解结构
```

关键假设是：MLP 在当前 archive 覆盖区域内的局部扰动响应能够近似变量短期重要性，并且未选维度用膝点填充不会系统性破坏子空间候选的真实表现。如果 MLP 欠拟合、变量强交互、archive 覆盖很偏或膝点识别不稳，该机制可能把代理搜索集中到错误子空间。

## 实现接口

- 输入：
  - 已真实评价 archive `Data={(X,Y)}`；
  - 变量上下界和归一化器；
  - MLP 训练器、扰动幅度 `delta`、子空间大小 `Dsub`；
  - 每目标 SGP 训练器、pseudo-input 数量 `Mps`；
  - 代理内搜索器和真实评价预算。
- 输出：
  - 当前轮子空间变量索引 `Isub`；
  - 每目标 SGP 代理；
  - 少量完整维度候选 `Xnew`；
  - 更新后的真实评价 archive。
- 插入位置：
  - surrogate-assisted MOEA 的 surrogate management 和 infill selection 层；
  - high-dimensional SAEA 的变量分组/降维模块；
  - 任意需要在有限真实 FE 下使用 GP 不确定性的连续高维 MOO。
- 最小实现：

```text
Data_tr <- keep_nondominated_then_random_fill(Data, Nmax)
MLP <- train(normalize(X_tr), normalize(Y_tr))

for d in 1..D:
    X_per <- X_tr
    X_per[:, d] <- X_per[:, d] + delta
    S[d] <- mean_abs(MLP(X_per) - Y_tr_normalized)

Isub <- weighted_sample_without_replacement(indices=1..D, weights=S/sum(S), size=Dsub)
X_sub <- X_tr[:, Isub]

for objective m:
    X_ps <- kmeans_centers(X_sub, Mps)
    SGP[m] <- optimize_pseudo_inputs_and_hyperparams(X_sub, Y_tr[:,m], X_ps)

Q_sub <- inner_MOEA(objectives=ASD(SGP, density=X_sub, diversity=kmeans_centers(X_sub, 10)))
Centers <- kmeans(Q_sub union nondominated(X_sub), k=5)
X_knee <- select_knee_point(Data_tr)
X_new <- fill_unselected_dimensions(Centers, Isub, X_knee)
evaluate_true(X_new)
```

## 如何用于算法创新

### 局部创新

- 将 MLP perturbation score 替换为 surrogate gradient norm、permutation importance、dropout uncertainty、Jacobian saliency、SHAP-like attribution 或多模型一致性评分。
- 用 top-k + epsilon exploration、softmax temperature、UCB 或 Thompson sampling 替代简单权重无放回抽样。
- 让 `Dsub` 随 FE 阶段、变量重要性熵、代理误差、成功候选比例或停滞状态动态变化。
- 用 local SGP、deep kernel SGP、multi-output SGP、ensemble SGP 或 inducing-point variational GP 替代单一 objective-wise SGP。
- 将 ASD 中的密度和多样性项归一化，并加入 surrogate calibration error、HV contribution、reference-vector coverage 或 constraint violation risk。
- 将膝点补全替换为最近邻补全、多膝点 ensemble、局部 PCA/manifold reconstruction、autoencoder decoder 或区域代表解补全。

### 结构创新

- 构建高维 SAEA 的五层流水线：

```text
variable-importance sensor
-> subspace scheduler
-> sparse probabilistic surrogate
-> density/diversity-aware infill optimizer
-> full-space completion and true evaluation
```

- 维护多个子空间和多个 SGP 代理，让它们根据真实评价贡献竞争下一轮候选名额。
- 与特殊点 infill 结合：普通候选走 MLP-SGP-ASD，膝点或断裂区候选走局部特殊点代理，统一由真实评价调度器分配预算。
- 与自适应资源分配结合：变量重要性不仅决定子空间，还决定不同子空间的内搜索代数、pseudo-input 数量和真实评价候选数。
- 与多保真仿真结合：低保真数据训练 MLP 重要性和 SGP 先验，高保真 FE 只验证 ASD 选出的少量完整候选。

## 适用条件与风险

- 适用条件：
  - 真实评价代价显著高于 MLP/SGP 训练代价；
  - 变量连续或可做有意义的小扰动；
  - 当前 archive 足以训练一个粗略但有方向性的 MLP；
  - 目标函数局部相对平滑，变量敏感性对下一轮搜索有预测价值；
  - 未选变量存在可用的补全锚点，如膝点、代表解或局部邻居。
- 不适用或可能失效的条件：
  - 变量强离散、混合或有复杂可行性约束，小扰动没有自然语义；
  - 目标函数强噪声、不连续或变量尺度归一化不当，MLP 敏感性不稳定；
  - 关键改进依赖多个变量联动，单变量扰动分数无法识别协同贡献；
  - FE 预算极低，archive 太小导致 MLP 和 SGP 都欠训练；
  - PF/PS 多模态或断裂，单个膝点补全会把候选拉回单一区域；
  - 评价不够昂贵时，MLP+SGP+NSGA-II 内循环开销可能超过收益。
- 计算与实现成本：
  - 每轮训练 MLP，并对全部 `D` 个变量做扰动预测；
  - 每个目标训练一个 SGP，优化 pseudo-input 和超参数；
  - 需要维护归一化、子空间索引、SGP 不确定性、密度估计、候选聚类和全空间补全；
  - 大目标数下 objective-wise SGP 成本仍会线性增加。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0178 | 作者指出标准 GP 训练复杂度为 `O(N^3)`，高维 EMOP 中建模成本过高；便宜代理可能牺牲强非线性/耦合问题精度，固定降维可能丢失高维变量信息 | 问题动机 | Sec. I，PDF 1-2 |
| P2026-0178 | Algorithm 1 将 MLP 子空间选择、每目标 SGP、NSGA-II+ASD、`k`-means 代表选择和膝点补全整合为 MLPSGP-SAEA | 作者提出的方法 | Sec. III-A，Algorithm 1，PDF 4 |
| P2026-0178 | Algorithm 2 通过对每个变量加 `delta=0.01` 并计算 MLP 预测目标变化，得到变量重要性，再按权重无放回采样 `Dsub` 维 | 作者提出的方法 | Sec. III-B，Algorithm 2，PDF 4-5 |
| P2026-0178 | Algorithm 3 用 `k`-means 初始化 `Mps` pseudo-input，最大化 SGP marginal log-likelihood，并用连续 10 次小于 `1e-4` 的改善触发早停 | 作者提出的方法 | Sec. III-C，Algorithm 3，PDF 5 |
| P2026-0178 | ASD 定义为 `LCB/rho + EI/Div`，其中 `rho` 来自核密度估计，`Div` 来自候选到子空间聚类中心的距离 | 作者提出的方法 | Sec. III-D，Eq. (9)-(11)，PDF 5-6 |
| P2026-0178 | 子空间候选和训练档案非支配解经 `k`-means 选中心，未选维度由训练档案膝点填充，恢复完整空间候选再真实评价 | 作者提出的方法 | Sec. III-E，Fig. 2，PDF 6 |
| P2026-0178 | LSMOP 200/500/1000 维上，ADSAPSO、AVG-SAEA、MLPSGP-SAEA 分别在 0、6、21 个 test instances 中最优，作者据此认为方法有较好 scalability 和 stability | 综合实验支持 | Sec. IV-B，Table V，PDF 10 |
| P2026-0178 | MLP grouping + ASD 消融中，完整 MLPSGP-SAEA 相比 AESGP-SAEA、PCASGP-SAEA、MLPEI-SAEA、MLPLCB-SAEA 表现更稳定/优越 | 消融实验支持 | Sec. IV-C，Table VI，PDF 10-11 |
| P2026-0178 | 膝点补全相对随机解、随机非支配解和膝点+随机非支配混合补全，在补充材料中显示更好的分布-收敛平衡 | 机制实验支持 | Sec. IV-D，Table S-II，PDF 10-11 |
| P2026-0178 | MLP 隐层神经元 `varpi=sqrt(M+D)+3` 多数测试 IGD 稳定，但 100 维运行时间明显增加；超过 100 维时作者建议 `varpi=5` 作效率折中 | 参数敏感性 | Sec. IV-E，PDF 11 |
| P2026-0178 | 扰动值敏感性显示 `delta=0.01` 效果最好；运行时间比较显示 MLPSGP-SAEA 和 ADSAPSO 显著快于其他算法 | 参数/效率证据 | Sec. IV-F-G，PDF 11-12 |
| P2026-0178 | NACA0012 airfoil 双目标优化中，MLPSGP-SAEA 在 best、mean、median、worst HV 上优于七个代理辅助 EA | 真实应用支持 | Sec. IV-H，Table VII，PDF 12 |
| P2026-0178 | 作者指出复杂前沿上膝点准确识别和定位困难，且 infill criterion optimizer 会显著影响性能，未来需研究更准确膝点和更高效优化器 | 作者局限与未来工作 | Sec. V，PDF 13 |

## 证据边界

- 当前只有单篇论文证据；虽然 benchmark 范围较广，但真实工程应用只有一个 20 维 airfoil 设计问题。
- LSMOP 超高维实验只与 ADSAPSO、AVG-SAEA 比较，不能说明相对所有高维 SAEA 都占优。
- Markdown 中表格多为图片占位，逐项数值需回查 PDF 或 supplementary。
- MLP grouping 的变量敏感性主要是单变量扰动，论文没有专门验证强变量交互或混合变量问题。
- `Dsub`、`Mps`、隐层神经元数、扰动幅度等参数仍需任务相关调节。
- 膝点补全的有效性依赖膝点识别质量；作者也把复杂前沿膝点定位列为未来工作。

## 待确认

- 如何在 MLP 重要性中显式建模变量交互，避免遗漏协同变量组；
- `Dsub` 和 `Mps` 是否能由代理误差、真实评价贡献或密度自适应控制；
- ASD 中 LCB/EI、`rho`、`Div` 的尺度归一化和 bandwidth 设置如何影响不同问题；
- 膝点补全是否应扩展为多代表补全或局部流形补全；
- 在 constrained、noisy、mixed-variable、many-objective、multimodal PS 和多工程问题上的稳定性；
- 多个子空间 SGP 并行或 ensemble 是否能降低单一子空间误判风险。
