---
knowledge_id: K-offline-surrogate-industrial-setpoint-pareto-optimization
name: 离线数据代理驱动的工业过程 Pareto 设定优化
type: architecture
status: active
source_papers: [P2026-0132]
aliases: [DD-MODE, SaMODE, offline industrial surrogate optimization, data-driven process setpoint optimization, XGBoost surrogate process optimization, surrogate setpoint Pareto optimization, entropy-weighted Pareto selection, 工业过程代理优化, 离线数据代理, 工艺设定优化, 熵权Pareto选解]
promotion_reason: 单篇论文提出但流程完整，包含历史生产数据时滞对齐、约束过滤、XGBoost 目标代理、安全上下界工艺参数搜索、代理上 Pareto 优化、SMS/HV 贡献选择、自适应局部搜索和熵权折中选解，可迁移到高温反应器、化工、污水处理、半导体等黑箱工业过程设定优化。
---

# 离线数据代理驱动的工业过程 Pareto 设定优化

## 核心内容

把难以机理建模的工业过程当作带时滞的黑箱系统。先用历史生产数据做时间对齐、约束过滤和异常清洗，训练输入工艺设定到关键质量/排放/产量指标的代理模型；再把多个原始指标聚合或保留为多目标优化问题，在安全操作上下界内搜索 Pareto setpoints；最后用熵权、TOPSIS、Nash bargaining 或人工偏好从 Pareto set 中选出可执行工艺设定，并在后续生产或小批次验证中回灌数据。

```text
historical plant data
-> time-lag alignment + constraint filtering + outlier removal
-> engineered process variables and safety bounds
-> surrogate model for output indicators
-> multiobjective setpoint model
-> safe bounded Pareto optimizer
-> Pareto setpoints
-> MCDM / preference selection
-> plant validation and data feedback
```

## 建立理由

- 为什么值得独立维护：很多工业过程机理复杂、在线试错昂贵，但有历史数据和明确安全操作窗口。本知识给出“离线代理作为目标函数 + 安全 bounds 内 Pareto 搜索 + 工艺折中选解”的落地接口。
- 单篇具体方法的直接复用价值：P2026-0132 在 RHF 工艺中给出完整实例，包括 31 天工业数据、18 个工艺变量、6 个代理输出、双目标聚合、SaMODE 求解、统计比较、消融和熵权选解。
- 与已有设计知识的区别：
  - 不同于“自适应代理内环加速器”：该知识在 MOEA 过程中在线训练短期代理并回灌真实评价；本知识是先训练离线工业代理，把代理作为完整目标函数进行设定搜索。
  - 不同于“代理驱动的可持续材料配比多目标优化”：该知识强调材料/工艺配方数据、组分指标目标和实验或稳健性验证；本知识强调历史生产数据的时滞对齐、安全过滤、工艺设定 bounds 和运行数据驱动的 setpoint 优化。
  - 不同于“代理-仿真混合的不确定性评价加速”：该知识在优化中混合 Monte Carlo/代理评价；本知识当前以离线代理全量评价为主，后续验证和回灌是部署层。
  - 不同于“CRITIC-TOPSIS 评价反馈引导演化”：该知识把 MCDM 反馈到演化循环；本知识的 MCDM 是 Pareto 后处理选解。

## 解决的问题

- 适用场景：
  - 化工、高温冶金、污水处理、半导体工艺、能源系统等复杂连续工业过程；
  - 机理模型难以准确、实时仿真昂贵或参数难校准；
  - 有历史生产数据和明确操作上下界；
  - 多个质量、产量、能耗、排放或成本指标相互冲突；
  - 需要输出可执行 setpoints，而不是只训练预测模型。
- 现有方法为什么会失败或不足：
  - 经验规则适应不了原料、设备状态和环境变化；
  - 纯机理模型构建慢且对真实工况泛化差；
  - 单目标优化会把风险推到未优化指标上；
  - 只做预测不产生可执行工艺设定；
  - 代理优化若无安全 bounds 和后验验证，容易外推到危险区域。
- 仍需解决的问题：
  - 代理不确定性如何进入搜索和选解；
  - 被优化器推到历史数据稀疏区域时如何限制外推；
  - Pareto setpoints 如何转成低层控制指令；
  - 离线推荐如何通过在线数据持续更新。

## 为什么可能有效

```text
industrial process is hard to model mechanistically
-> historical data captures practical operating regimes
-> time-lag alignment maps upstream setpoints to delayed outputs
-> surrogate evaluation is cheap enough for MOEA search
-> safety bounds prevent obviously infeasible setpoints
-> Pareto set exposes objective trade-offs
-> MCDM/post-selection converts Pareto set to deployable setpoint
```

关键假设是：历史数据覆盖了将要优化的安全操作窗口，而且代理在该窗口内能保持可用排序。如果优化器大量探索历史分布外区域，代理前沿会被虚假的高收益预测污染。

## 实现接口

- 输入：
  - 历史工艺设定、原料/环境特征和输出质量/排放/产量数据；
  - 工艺时滞或数据对齐规则；
  - 操作安全上下界、联动约束和异常过滤规则；
  - 指标聚合权重、监管阈值或业务偏好；
  - 代理模型训练器和多目标优化器。
- 输出：
  - 经过验证的代理模型；
  - Pareto setpoints；
  - 推荐折中 setpoint 及指标预测；
  - 代理可信度、约束裕度和后续验证计划。
- 最小实现：

```text
data <- align_by_process_lag(raw_data)
data <- filter_by_operating_bounds_and_remove_outliers(data)
X <- engineer_setpoint_features(data)
Y <- collect_output_indicators(data)

surrogate <- fit_model(X_train, Y_train)
validate(surrogate, X_test, Y_test)

def objectives(lambda):
    z_hat <- surrogate.predict(lambda)
    return aggregate_to_objectives(z_hat)

pareto <- MOEA(
    objectives = objectives,
    constraints = safe_bounds(lambda)
)

selected <- mcdm_select(pareto, preferences_or_entropy_weights)
validate_or_deploy(selected)
update_data_pool()
```

- P2026-0132 的具体实例：
  - `X` 为 18 个 RHF charging-thermal parameters；
  - `Y` 为 particulate、SO2、NOx、DRI pellets、DRI powder、zinc powder；
  - XGBoost 分别预测输出子指标；
  - `f1` 聚合三个污染指标，`f2` 聚合三个产量指标；
  - `min F(lambda) = [f1(lambda), -f2(lambda)]`；
  - SaMODE 用 DE 生成子代、SMS/HV contribution 做环境选择，并用 self-adaptive GLS 从 POS 附近局部扰动；
  - 熵权评价从 POS 中选最低 `EV` 的方案。

## 如何用于算法创新

### 局部创新

- 将 XGBoost 替换为 uncertainty-aware ensemble、conformal regressor、multi-output GP、NGBoost 或 physics-informed surrogate。
- 把固定安全上下界扩展为联动约束，例如温度梯度、压力联锁、能耗上限和污染硬阈值。
- 对代理输出做分布外检测，距离历史样本过远的 setpoint 降权或强制真实验证。
- 将熵权选解替换为 Nash bargaining、knee point、regulatory-first filtering 或交互式偏好。
- 对每个 Pareto 候选生成控制可执行性检查，例如 ramp rate、执行时间和低层控制器可达性。

### 结构创新

- 构建工业数字孪生优化闭环：

```text
data historian / MES / sensors
-> lag-aware data model
-> surrogate and uncertainty layer
-> safe Pareto setpoint optimizer
-> MCDM and operator interface
-> control-system adapter
-> online validation and model update
```

- 采用两层评价：代理快速搜索全局 Pareto set，少量候选进入高保真仿真、小批生产或专家审查。
- 把离线 Pareto set 与在线 RL/MPC 结合：离线提供安全初始 setpoints，在线控制只在安全邻域内微调。
- 对多产品、多原料或多设备场景，训练条件化代理，使 setpoint 优化随工况输入变化。

## 适用条件与风险

- 适用条件：
  - 有足够历史数据覆盖主要工艺窗口；
  - 输入输出存在可学习的时滞映射；
  - 操作 bounds 和关键联锁约束明确；
  - 代理预测比真实试验或高保真仿真便宜得多；
  - 优化结果可以由工艺专家或控制系统验证。
- 不适用或可能失效的条件：
  - 数据只覆盖很窄的保守工况，优化会强外推；
  - 原料组成、设备状态或传感器校准快速漂移；
  - 输出标签延迟或混批严重，无法可靠对齐；
  - 目标聚合掩盖硬约束，如单一污染物超标；
  - 推荐 setpoint 无法被低层控制系统平稳执行。
- 计算与实现成本：
  - 需要数据清洗、时滞建模、代理训练、MOO、后处理选解和部署验证；
  - 代理评价很快时，优化成本通常由非支配排序、HV contribution 或局部搜索主导；
  - 真正部署需要 MLOps/控制系统接口和持续监控。

## 论文证据

| 论文 ID | 证据内容 | 证据类型 | 章节或 PDF 页码 |
|---|---|---|---|
| P2026-0132 | RHF 过程具有多相多物理场耦合，机理建模困难，作者用 XGBoost 学习 charging-thermal parameters 到输出指标的黑箱映射 | 问题动机/代理建模 | Sec. 1、3.2，PDF 1-5 |
| P2026-0132 | 对生产数据进行 time-lag alignment、constraint-based filtering 和 outlier removal，并计算 C/O、Cl/Zn、air-fuel ratio 等关键比例 | 数据处理接口 | Sec. 5.1，PDF 9-10 |
| P2026-0132 | 18 个决策变量包括 6 个 material parameters、7 个 energy parameters 和 5 个 zone temperature parameters，均有实际生产安全上下界 | 决策变量与约束 | Table 3，PDF 8-10 |
| P2026-0132 | XGBoost 预测 particulate、SO2、NOx、DRI pellets、DRI powder、zinc powder 六个输出子指标 | 代理输出 | Sec. 3.2、Table 3，PDF 4-10 |
| P2026-0132 | `f1` 将三个污染指标按税率/惩罚权重聚合，`f2` 将三个产量指标按经济价值/优先级聚合，优化方向为 `[f1, -f2]` | 多目标建模 | Sec. 3.3，Eq. 6-8，PDF 5-6 |
| P2026-0132 | 数据覆盖 31 天、10 min 采样间隔，按 6:2:2 划分 train/validation/test，seed=42，XGBoost 用 grid search 调参 | 代理训练设置 | Sec. 5.2，Table 4，PDF 10 |
| P2026-0132 | Table 5 显示 NOx、DRI pellets、DRI powder、zinc powder 在 `±1.00 std` 内命中率超过 90%，SO2 预测相对较弱 | 代理预测证据 | Table 5，PDF 8、10 |
| P2026-0132 | SaMODE 用 DE 或 self-adaptive GLS 生成子代，合并后用 fast non-dominated sorting 与 HV contribution 的 SMS-based selection 保留种群 | 优化器接口 | Algorithm 1-4，PDF 6-9 |
| P2026-0132 | 与 NSGA-II、NSGA-III、UNSGA-III、MOEA/D、K-RVEA、Age-MOEA-II 比较，SaMODE 在 HV 和 SR average ranks 上最佳，分别为 `1.25` 和 `1.08` | 综合实验支持 | Table 11，PDF 14 |
| P2026-0132 | ANOVA 显示算法类型对 HV、SP、SR 有显著影响，p-values 分别为 `9.8813e-60`、`3.6984e-05`、`7.6737e-34` | 统计显著性 | Table 10，PDF 13-14 |
| P2026-0132 | Ablation 中 SaMODE 相对 SMS-Base、SMS-Periodic 在 HV 和 SR average ranks 上最佳，ANOVA p-values 均小于 0.001 | 组件证据 | Sec. 5.5，Table 13-14，PDF 14-16 |
| P2026-0132 | 熵权评价从 20 个 POS 中选解，平均使污染目标降低 `26.89%`、产量目标提高 `34.66%` | 后处理/案例证据 | Sec. 5.6、Fig. 13，PDF 15-16 |
| P2026-0132 | 作者未来工作提出量化 feed composition、sensor noise 和模型误差，并与过程控制系统集成实现实时闭环 | 作者局限与未来工作 | Sec. 6，PDF 16 |

## 证据边界

- 当前证据来自单篇 RHF 工业数据研究。
- 优化结果主要基于代理预测，缺少在线闭环生产验证或高保真机理仿真复核。
- 数据来自一个钢厂 31 天窗口，跨季节、跨原料和跨设备迁移未知。
- XGBoost 与其他模型的数值比较主要在 Fig. 7 图片中，文本只给出定性结论。
- SO2 预测相对较弱，说明单个关键污染物可能需要单独约束或不确定性处理。
- 熵权选解是后处理，不保证符合监管优先级或操作员偏好。
- SaMODE 的 SP 并非最佳，局部搜索可能牺牲部分均匀分布。

## 待确认

- 如何将代理不确定性、分布外检测和安全控制屏蔽纳入 Pareto 搜索；
- 多指标应聚合成少数目标，还是保留为 many-objective / constrained MOO；
- 推荐 setpoint 如何映射为底层控制器可执行的 ramp、阀位、温控和压力指令；
- 在线反馈数据何时触发代理重训；
- 跨工厂迁移时如何做 domain adaptation 或 meta-learning；
- 小批量真实验证应选择膝点、高不确定点、监管边界点还是最大 predicted gain 点。
