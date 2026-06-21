---
knowledge_id: K-prior-knowledge-embedded-surrogate-mix-optimization
name: 代理驱动的可持续材料配比多目标优化
type: method
status: active
source_papers: [P2026-0060, P2026-0067, P2026-0027]
aliases: [KENN mix optimization, prior knowledge embedded neural network, physics-informed surrogate mix design, governing-equation embedded surrogate, NSGA-II mix optimization, surrogate-assisted mix design, XGBoost mix optimization, XGB-GWO mix optimization, SHAP-guided mix design, MOPSO mix optimization, MOGWO mix optimization, entropy-TOPSIS mix selection, ML-MOO-LCA mix design, sustainable material mix optimization, GPRC mix optimization, FACB mix optimization, cement-stabilized soil mix optimization, 先验知识嵌入神经网络, 配比优化代理, 可持续材料配比优化代理]
promotion_reason: 三篇论文共同支持“配方数据/实验数据 -> 性能预测代理 -> 碳排放/成本/能耗解析目标 -> 多目标优化 -> 候选验证、MCDM 选解或 LCA/稳健性检查”的流程；P2026-0060 给出先验方程约束 KENN、NSGA-II 和实验验证，P2026-0067 给出多来源 FACB 数据、XGBoost/SHAP、CO2 排放公式、MOPSO/灰狼优化和排放系数/养护龄期稳健性检查，P2026-0027 给出 624 组水泥稳定软土数据、XGB-GWO、NSGA-II、entropy-TOPSIS 和 cradle-to-gate LCA，可迁移到材料配方、工艺参数和其他工程配方优化问题。
---

# 代理驱动的可持续材料配比多目标优化

## 核心内容

先把实验或文献配方数据标准化为有物理意义的比例变量，再训练一个性能预测代理。代理可以是受领域控制方程约束的神经网络，也可以是经跨来源验证、元启发式调参和 SHAP 解释校验的树集成模型。优化时不直接用昂贵实验评价性能，而是把代理作为性能目标函数，并把成本、碳排放、能耗等指标写成组分用量函数，交给 NSGA-II、MOPSO、MOGWO 等多目标优化器产生 Pareto 配比。最后用理想点、TOPSIS、entropy-TOPSIS、偏好规则、真实实验、LCA 或排放因子/工况敏感性检查来筛选和验证候选。

```text
多来源配方-性能数据或新实验数据
-> 尺度与试验条件标准化
-> 构造物理比例变量
-> 训练  先验约束代理 或 可解释树集成代理
-> 代理性能目标 + 成本/CO2/能耗目标 + 工程/组成约束
-> 多目标优化生成 Pareto 配方
-> 折中选解、真实验证、LCA 或稳健性检查
-> 回灌数据并监控分布外风险
```

## 建立理由

- 为什么值得独立维护：材料和工艺配方优化常常数据少、实验贵、变量强耦合，并且需要同时考虑性能、成本、碳排放、能耗和耐久性。纯数据代理容易学到统计相关而非可外推机理，纯经验公式又难刻画高阶非线性；该设计把代理训练、工程约束、可持续性解析目标、多目标搜索和验证/稳健性检查串成一个可复用闭环。
- 跨论文支持：
  - P2026-0060 给出 GPRC 实例，使用 292 组文献数据训练 KENN，测试集 `R2=0.9126`，再用 NSGA-II 优化强度、CO2、能耗和成本，并在 C30/C50/C70 实验中把强度预测误差控制在 5.0% 内。
  - P2026-0067 给出 FACB 实例，先制造 18 种配比、450 块砖，并汇总 90 组实验数据和 210 组文献数据；XGBoost 在测试/验证集上取得较好性能，随后用 MOPSO 与灰狼优化在强度和 CO2 排放之间生成 Pareto 配比，并报告 31-35% CO2 减排和约 8% 强度提升。
  - P2026-0027 给出水泥稳定软土实例，624 组文献样本训练 UCS 代理，XGB-GWO 优化超参数，NSGA-II 生成 UCS-cost Pareto 解，entropy-TOPSIS 选最终 mix，再用 cradle-to-gate LCA 检查碳排放和多项环境影响。
- 与已有设计知识的区别：
  - 不同于“预测代理驱动的实时多目标控制优化”：本知识重点是离线配方/材料设计中的配方数据代理、组分指标函数和候选验证/稳健性检查，不是实时控制场景下的历史数据代理和在线参数推荐。
  - 不同于“自适应代理内环加速器”：本知识不在 MOEA 子代生成中临时加速，而是把训练好的领域代理作为完整工程优化问题的目标函数。
  - 不同于“网格排序成对关系代理筛选”：本知识学习的是可解释性能预测代理，而不是候选间相对优劣分类器。

## 解决的问题

- 适用场景：
  - 材料配比、化工配方、增材制造工艺、食品配方或复合材料设计；
  - 真实实验昂贵，已有数据来自不同文献、批次或设备；
  - 存在可写成方程、约束、经验关系或单调趋势的领域知识；
  - 性能目标与可持续性、成本、能耗、质量稳定性等目标冲突；
  - 需要最终给出可执行配方，而不只是预测模型。
- 现有方法为什么会失败或不足：
  - 纯经验公式表达能力不足，难以覆盖复杂变量交互；
  - 纯神经网络在小样本下可能过拟合，并输出违反物理常识的高收益方案；
  - 普通随机划分可能高估跨材料来源、跨工厂或跨批次的泛化能力；
  - 只做预测不能自动产生满足多目标折中的配方；
  - 只在代理上优化而不实验验证，会把代理误差放大成虚假的 Pareto 改善。
- 仍需解决的问题：
  - 先验方程形式错误时如何避免把偏差硬嵌入代理；
  - 代理不确定性如何进入 Pareto 搜索和折中选解；
  - 新材料体系或新工艺窗口下如何判断需要重训或补充实验；
  - 多来源数据的试验条件差异如何建模，而不只是简单换算。

## 为什么可能有效

```text
领域方程、组分指标和工程约束提供低样本下的合理搜索边界
-> 神经网络或树集成代理学习配方-性能非线性
-> 先验一致性、SHAP/相关性诊断或跨来源验证暴露统计伪相关
-> 多目标优化器在代理上低成本搜索大量候选
-> 少量真实实验、分布外 stress test 或排放因子敏感性检查暴露代理误差
```

核心假设是：配方变量与性能之间存在可学习关系，且领域约束、解释性诊断或跨来源验证能及时发现明显不可信的外推；真实实验或稳健性检查则防止代理前沿被误读为真实前沿。

## 实现接口

- 输入：
  - 配方变量、材料属性、工艺条件和性能标签；
  - 试验条件标准化规则，例如试件尺寸、养护条件或测量口径换算；
  - 领域控制方程、经验关系或可微约束；
  - 成本、CO2、能耗、风险等组分指标表；
  - 工程约束和目标等级要求。
- 输出：
  - 性能预测代理；
  - Pareto 配方集；
  - 推荐折中配方及预测性能；
  - 实验验证误差和可选的数据回灌样本。
- 插入位置：
  - 材料设计或工艺窗口搜索的离线优化层；
  - 数字孪生的配方推荐模块；
  - 代理辅助 MOO 的目标函数层；
  - 主动学习闭环中的候选生成与实验选择阶段。
- 最小实现：

```text
data <- collect_and_standardize(experiments)
X <- build_physical_ratio_features(data)
g <- define_domain_governing_function(X)

surrogate <- train(
    network(X),
    loss = data_fit(network, y)
         + lambda1 * consistency(network, g)
         + lambda2 * fit_governing_function(g, y)
)

pareto <- moo(
    objectives = [
        maximize(surrogate.predict(x)),
        minimize(component_cost(x)),
        minimize(component_co2(x)),
        minimize(component_energy(x))
    ],
    constraints = engineering_bounds(x)
)

selected <- compromise_selection(pareto)
validate_by_experiment(selected)
```

- P2026-0060 的具体实例：
  - 数据：2000-2024 年文献 292 组 GPRC 28 天抗压强度；
  - 变量：11 个配比变量，含碱激发剂/前驱体比、细骨料/前驱体比、RFA/RCA/RCP 替代率、砂率、NaOH/Na2SiO3 模数、FA/GGBS 含量；
  - 代理：8 层 Tanh 神经网络与含单变量项、交互项的控制函数共同训练；
  - 损失：`L_data + 0.1 * L_func + L_func-data`；
  - 优化：NSGA-II，父代 100、子代 200、100 代、交叉 0.95、变异 0.05；
  - 选解：Ideal Point 方法；
  - 验证：C30/C50/C70 每个等级 3 个方案，每组 3 个立方体试件。
- P2026-0067 的具体实例：
  - 数据：18 种 FACB 配比、450 块水浸养护砖、7-120 天龄期实验，并合并 210 组文献数据，总计 300 组样本；
  - 变量：cement、fly ash、sand、stone dust、water、age 预测 compressive strength；
  - 代理：DT、RF、XGBoost、LightGBM 比较，BOA 50 次调参，XGBoost 作为后续优化代理；
  - 泛化检查：同时比较 source-based split 和 random split，并额外留出 Source 4 的 24 个样本做验证；
  - 解释：对 FA-water 高相关特征做 residualization/orthogonalization 后计算 SHAP，检查模型是否依赖 cement、FA 等工程可解释趋势；
  - 目标：最大化 28 天抗压强度，最小化 `CO2 = CCQC + CFQF + CSQS + CSDQSD`；
  - 优化：用粒子群和灰狼多目标优化在组成约束内搜索，输出相近 Pareto front；
  - 稳健性：检查砂/石粉排放因子取最大值和 56 天养护龄期下 Pareto 配比的变化。
- P2026-0027 的具体实例：
  - 数据：624 组 cement-stabilized soft soil 样本，变量为 curing time、water content、binder content、liquid limit、plastic limit、specific gravity、fines content，输出为 UCS；
  - 代理：MLR、DT、RVM、RF、LGBM、XGB 比较，随机 80/20 切分与 10-fold CV，XGB 表现最好；
  - 超参数优化：GWO 与 GA 调 XGB，均设 population size 50、100 iterations、seed 123；XGB-GWO 测试 RMSE 82.168、`R2=0.973`，运行 52 min；
  - 解释：feature importance 与 SHAP 显示重要性排序为 binder content、water content、plastic limit、curing time、liquid limit、specific gravity、fines content；
  - MOO：`min F(x)=[-f1(28,x,c), f2(x)]`，其中 `f1` 为 XGB-GWO 预测 28 天 UCS，`f2` 为 water/binder/soil 成本函数；
  - 约束：Water 619-812 kg/m3、Binder 150-250 kg/m3、Soil 636-931 kg/m3、Water/Binder 3.01-5.34、Binder/Soil 0.16-0.39；
  - 优化与选解：NSGA-II population 100、200 generations、crossover `(0.9,15)`、mutation `(0.1,15)`，entropy-TOPSIS 选最终 mix；
  - 环境评价：OpenLCA v1.11.0、ecoinvent v3.7、ReCiPe 2016 midpoint (H)，功能单位为 1 m3 input materials，比较 Pareto mix 与实验 mix 的 cradle-to-gate impact。

## 如何用于算法创新

### 局部创新

- 把固定损失权重改成基于代理验证误差、先验残差或不确定性的自适应权重。
- 用 GPR、随机森林、神经算子、多保真模型或 ensemble 替换单一神经网络。
- 在 MOO 中加入代理不确定性目标，例如最小化预测方差或最大化保守置信下界。
- 将 Ideal Point 替换为 TOPSIS、VIKOR、AHP、交互式偏好或可行性安全裕度选择。
- 用主动学习选择最能改善代理前沿的下一批实验，而不是只验证最终折中解。

### 结构创新

- 构建“先验代理 + 多目标优化 + 主动实验设计 + 数据回灌”的闭环材料发现系统。
- 把配方变量分为可控设计变量、批次材料属性和环境变量，形成场景条件化配方优化。
- 将生命周期评价数据库、供应链价格波动和材料可得性作为动态目标或约束。
- 用多层优化表达“微观结构指标 -> 宏观性能 -> 工程目标”的链式代理。

## 适用条件与风险

- 适用条件：
  - 有少量到中等规模可清洗的历史或文献数据；
  - 存在至少近似可信的领域关系、经验公式或变量交互假设；
  - 组分用量能映射到成本、碳排放、能耗等外部指标；
  - 可以对少量候选做真实实验或高保真仿真验证；
  - 工程约束能明确写成变量上下界、等式或不等式。
- 不适用或可能失效的条件：
  - 先验方程与真实机理方向相反，且训练数据不足以纠正；
  - 文献数据混入不同测量口径但无法标准化；
  - 代理被优化器推到训练分布外很远区域；
  - 目标遗漏关键安全、耐久或加工性能；
  - 验证实验太少，无法发现 Pareto 前沿的系统性偏差。
- 计算与实现成本：
  - 需要数据清洗、变量工程、先验函数设计、代理训练、MOO、LCA/成本指标表和实验验证；
  - 相比纯 NSGA-II 优化解析目标，多了代理训练和验证成本；
  - 相比纯实验设计，可显著减少盲目实验次数。
- 解释风险：
  - 代理上的 Pareto 最优不等于真实 Pareto 最优；
  - KENN 的高 R2 不保证每个高强度或分布外配方都可靠；
  - 先验方程的可解释参数可能受数据范围和变量相关性影响；
  - 可持续性指标依赖数据库来源和地区价格，迁移时需重算。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0060 | 从 2000-2024 年文献收集 292 组 GPRC 28 天抗压强度数据，并统一换算到 100 mm 立方体强度 | 数据基础 | Sec. 2.1，PDF 3-4 |
| P2026-0060 | KENN 使用 11 个配比变量、8 层 Tanh 网络，以及含单变量项和交互项的控制函数共同训练 | 作者提出的方法 | Sec. 2.2，PDF 4-6 |
| P2026-0060 | 总损失由数据拟合、控制函数-网络一致性、控制函数-数据一致性三部分组成，权重为 `1, 0.1, 1` | 代理训练机制 | Sec. 2.2.3，PDF 6 |
| P2026-0060 | KENN 测试集 `R2=0.9126`，优于 GDM `R2=0.8121` 和 LSM `R2=0.8461`；测试集 `MAE=3.1989 MPa`、`RMSE=4.1538 MPa` | 预测实验支持 | Sec. 3.1.3，PDF 10-11 |
| P2026-0060 | SHAP 和特征重要性显示 RCP 替代率、砂率、GGBS、细骨料/前驱体比和 RFA 是关键因素 | 解释性证据 | Sec. 3.1.4，PDF 11 |
| P2026-0060 | 将 KENN 强度模型嵌入 NSGA-II，同时优化强度、CO2、能耗和成本，并用 Ideal Point 选解 | 优化流程证据 | Sec. 2.3, 3.2，PDF 7-13 |
| P2026-0060 | C30/C50/C70 实验验证中，所有配比的预测强度误差绝对值小于 5.0%，坍落度处于普通混凝土可接受范围 | 工程验证支持 | Table 5, Sec. 3.2.2，PDF 12-13 |
| P2026-0060 | 作者明确局限：当前仅覆盖钠基碱激发体系和特定材料，未来需扩展激发剂、前驱体与多尺度物理化学特征 | 作者局限 | Sec. 4，PDF 13 |
| P2026-0067 | 制造 18 种 FACB 配比、450 块砖，7-120 天水浸养护；最佳实验配比 M6 在 50% FA 下达到 14.9 MPa | 实验数据基础 | Abstract, Sec. 2, Conclusion，PDF 1、14 |
| P2026-0067 | 汇总 300 组样本，其中 90 组来自本研究实验、210 组来自十余篇文献；输入为 FA、cement、sand、stone dust、water、age，输出为 compressive strength | 多来源数据基础 | Sec. 3，Table 7，PDF 6-7 |
| P2026-0067 | 以 CO2 排放因子构造 `CO2 = CCQC + CFQF + CSQS + CSDQSD`，其中 cement 为 0.88 kg CO2/kg、FA 为 0.00151 kg CO2/kg、sand 与 stone dust 使用区间系数 | 可持续性目标构造 | Sec. 4.1，Eq. (6)，PDF 7 |
| P2026-0067 | source-based split 下测试集 `R2=0.0592`、验证集 `R2=0.6722`，random split 下测试集 `R2=0.9612`、验证集 `R2=0.8014`，说明跨来源分布差异很大 | 泛化边界与数据切分证据 | Sec. 4.2，Table 9，PDF 10 |
| P2026-0067 | XGBoost 在训练/测试/验证集上分别取得 `R2=0.9982/0.9594/0.8799`，RMSE 为 `0.4278/1.9538/1.7977 MPa`，优于 DT/RF/LightGBM 的综合表现 | 代理模型选择证据 | Sec. 4.2，Table 10，PDF 10 |
| P2026-0067 | 随机选取新配比实验验证，五块砖平均强度 24.142 MPa，XGBoost 预测 27.376 MPa，实测为预测值的 88.2%；作者将差异归因于文献来源原材料化学组成差异 | 外部配比验证与误差边界 | Sec. 4.2，PDF 10 |
| P2026-0067 | 对 FA 与 water 高相关特征先 residualization/orthogonalization 再计算 SHAP，避免贡献被随机分摊；SHAP 显示 cement 正向、FA 负向，并与工程趋势一致 | 可解释性与共线性处理 | Sec. 4.3，Fig. 13-14，PDF 10-12 |
| P2026-0067 | 用 XGBoost 代理结合粒子群和灰狼多目标优化，在配比上下界与组分和为 100% 的约束下优化 28 天强度和 CO2 排放；两类优化器得到相似 Pareto front | 代理驱动 MOO 流程 | Sec. 4.4，Fig. 15，PDF 12-13 |
| P2026-0067 | 代理 Pareto 前沿最大强度约 43.7 MPa，相比原始数据库最大 40.49 MPa 提升约 8% | 性能优化证据 | Sec. 4.4，PDF 12-13 |
| P2026-0067 | 从 MOPSO 前沿随机选 3 点，与数据库同等强度样本比较，CO2 排放减少 35.84%、34.78%、31.52% | 减排证据 | Table 13，PDF 14 |
| P2026-0067 | 调高砂/石粉排放系数和检查 56 天龄期后，28 天 Pareto 配比整体仍保持较好 strength-CO2 balance；高强度 56 天区数据稀缺可能使 56 天直接优化漏掉潜在优解 | 稳健性与数据稀缺边界 | Sec. 4.4，Fig. 16，PDF 13-14 |
| P2026-0067 | 作者未来工作建议扩展更多废弃材料、加入纤维，并评估热性能、抗冻性等耐久指标 | 作者未来工作 | Sec. 5，PDF 14 |
| P2026-0027 | 使用 624 组 peer-reviewed cement-stabilized soft soil 样本，输入 CT/WC/BC/LL/PL/SG/FC，输出 UCS，UCS 范围 15-3628.68 kPa | 数据基础 | Sec. 3.1-3.2，Table 1，PDF 4-5 |
| P2026-0027 | 比较 MLR、DT、RVM、RF、LGBM、XGB，XGB 在 20% unseen test 上 RMSE 120.50、`R2=0.94`、`R=0.97`、RSR 0.24，优于其他模型 | 代理模型选择证据 | Sec. 4.1-4.3，Table 3，PDF 10-11 |
| P2026-0027 | 用 GWO 和 GA 优化 XGB 超参数，XGB-GWO 测试 RMSE 82.168、`R2=0.973`、`R=0.987`、RSR 0.162，运行时间 52 min，优于 XGB-GA 的 101 min | 元启发式调参证据 | Sec. 4.4，Table 4，PDF 11-12 |
| P2026-0027 | 10-fold CV 和 Friedman/Wilcoxon 检验显示 XGB-GWO 相比多数 baseline 更稳定/显著，除 base XGB 外改进显著 | 统计验证证据 | Sec. 4.4，Table 5，Fig. 12，PDF 12 |
| P2026-0027 | SHAP 和重要性图共同给出排序：binder content > water content > plastic limit > curing time > liquid limit > specific gravity > fines content；高 water/plastic limit/fines 通常降低 UCS | 可解释性证据 | Sec. 4.5，Fig. 13，PDF 13 |
| P2026-0027 | 用 XGB-GWO 作为 28 天 UCS 目标、polynomial cost function 作为成本目标，NSGA-II 生成 UCS-cost Pareto front，entropy-TOPSIS 权重为 UCS 0.413、cost 0.587 | 代理驱动 MOO 与 MCDM 证据 | Sec. 3.6, 4.6，PDF 6-7、13 |
| P2026-0027 | entropy-TOPSIS 选出的 Mix 1 为 binder 209.78 kg/m3、water 668.53 kg/m3、soil 636 kg/m3，UCS 2243.21 kPa、cost 26.77 USD/m3、`Si=0.847` | 最终配比选解证据 | Table 6-7，PDF 13-14 |
| P2026-0027 | NSGA-II Pareto 解 UCS 范围 1008.63-2262.80 kPa、成本 21.82-27.28 USD/m3；实验数据 UCS 669-2250 kPa、成本 22.70-31.93 USD/m3，Pareto 解整体提供更好 strength-cost tradeoff | Pareto 改善证据 | Sec. 4.6，PDF 13 |
| P2026-0027 | 决策权重敏感性中 UCS 权重 0.30-0.70 时，选解 UCS 约变化 15%、成本约变化 12%，作者认为 entropy-TOPSIS 选解对中等权重扰动稳健 | MCDM 稳健性证据 | Sec. 4.6，Fig. 15，PDF 13 |
| P2026-0027 | CTG LCA 显示 Mix 1 的 GWP 为 159.8 kg CO2 eq，相比最高成本实验 Mix 3 的 190.4 kg CO2 eq 减少 16.07%，同时 UCS 由 1348 提高到 2243.21 kPa、成本降低到 26.77 USD/m3 | LCA 与工程收益证据 | Sec. 4.7，Tables 7-8，PDF 14-15 |
| P2026-0027 | 作者未来工作建议探索 LSTM/CNN 等深度学习结构，扩展到 shear strength、deformation modulus 和更多 soil-binder 组合 | 作者未来工作 | Sec. 5，PDF 15 |

## 证据边界

- 当前有三篇论文证据，分别覆盖 GPRC 的先验方程嵌入 KENN+NSGA-II+实验验证，FACB 的 XGBoost/SHAP+MOPSO/GWO+排放系数/龄期稳健性分析，以及 cement-stabilized soft soil 的 XGB-GWO+NSGA-II+entropy-TOPSIS+LCA。
- P2026-0060 的 KENN 没有与纯 NN 或其他现代 surrogate 做完整消融，无法单独量化每个损失项贡献。
- NSGA-II 是工程优化载体，论文没有证明该优化器优于其他 MOO 算法。
- 实验验证只覆盖三种强度等级和该研究指定的材料体系。
- 环境和成本目标依赖材料指标表，地区、供应链或数据库变化会改变优化结果。
- P2026-0067 显示 source-based split 的测试集 `R2=0.0592`，说明跨文献/跨原料来源外推风险很高；random split 的高指标不能单独证明跨来源部署可靠。
- P2026-0067 的 Pareto 优化主要在 XGBoost 代理上完成，未对 Pareto 推荐配比逐一做真实制砖验证；随机新配比实验仍有约 12% 偏差。
- P2026-0067 的多目标优化器细节较少，粒子群与灰狼的参数、收敛和公平比较不足。
- P2026-0067 的长期高强度样本稀缺，作者也指出 90/120 天数据集中在 10-20 MPa，长龄期高强外推需要谨慎。
- P2026-0027 的 MOO 目标只直接优化 UCS 和成本，LCA 是后处理比较，不是优化目标本身。
- P2026-0027 使用随机 80/20 切分，缺少按文献来源或土类的外推 stress test；训练 `R2≈0.999` 仍需警惕数据泄漏或分布内高估。
- P2026-0027 的最优 mix 是代理+NSGA-II+TOPSIS 选解，未报告对该 mix 的新实验制样验证；LCA 采用平均全球供应链，地区能源结构与运输条件变化会影响结论。

## 待确认

- 先验函数形式如何系统构建，而不是依赖人工经验；
- 代理不确定性如何进入约束、目标和折中选解；
- 如何设计主动学习批次，让下一轮实验最大化修正 Pareto 前沿；
- 对钾基激发剂、偏高岭土、赤泥或其他再生材料体系是否仍稳定；
- 当耐久性、收缩、工作性和强度一起作为目标时，是否需要多输出先验代理。
- 对纯树集成代理路线，source-based split、leave-one-source-out 和原料化学组成条件化建模应如何组合，才能减少文献数据混合导致的伪泛化；
- SHAP 解释应如何从“趋势一致”升级为可约束搜索的规则或先验损失；
- Pareto 配比应选择多少点做真实实验，才能以较小成本校准代理前沿。
- LCA 应作为后处理、约束还是第三目标进入优化，如何避免选出 cost/strength 好但其他环境指标差的配比；
- entropy-TOPSIS 权重对工程偏好、法规阈值和项目规模变化是否仍稳定。
