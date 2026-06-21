**==> picture [276 x 285] intentionally omitted <==**

进化多目标优化平台 用户手册 4.15 

生物智能与知识发现（BIMK）研究所 2026 年5 月21 日 

非常感谢使用由安徽大学生物智能与知识发现（BIMK）研究所开发的进化 多目标优化平台PlatEMO。本平台是一个开源免费的代码库，仅供教学与科研使 用，不得用于商业用途。本平台中的代码基于作者对论文的理解编写而成，作者 不对用户因使用代码产生的任何后果负责。包含利用本平台产生的数据的论文应 在正文中声明对PlatEMO 的使用，并引用以下参考文献之一： 

[1] Ye Tian, Weijian Zhu, Xingyi Zhang, and Yaochu Jin, “A practical tutorial on solving optimization problems via PlatEMO,” Neurocomputing, 2023, 518: 190-205. 

[2] Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, “PlatEMO: A MATLAB platform for evolutionary multi-objective optimization [educational forum],” IEEE Computational Intelligence Magazine, 2017, 12(4): 73-87. 

如有任何意见或建议，欢迎联系field910921@gmail.com（田野）。如想将您的 代码添加进PlatEMO 中并公开，也欢迎联系field910921@gmail.com。您可以 在 GitHub 上获取PlatEMO 的最新版本。 

## 目  录 

||目  录|目  录|
|---|---|---|
|一|快速入门............................................................................................................. 1||
|二|通过命令行使用PlatEMO ................................................................................. 3||
||1.|求解测试问题........................................................................................... 3|
||2.|求解自定义问题....................................................................................... 5|
||3.|获取运行结果........................................................................................... 9|
|三|通过图形界面使用PlatEMO ........................................................................... 12||
||1.|测试模块................................................................................................. 12|
||2.|应用模块................................................................................................. 13|
||3.|实验模块................................................................................................. 14|
||4.|创造模块................................................................................................. 15|
||5.|算法、问题和指标的标签..................................................................... 16|
|四|扩展PlatEMO ................................................................................................... 18||
||1.|算法类..................................................................................................... 18|
||2.|问题类..................................................................................................... 20|
||3.|个体类..................................................................................................... 26|
||4.|一次完整的运行过程............................................................................. 27|
||5.|指标函数................................................................................................. 28|
||6.|创建NeuroEA算法............................................................................... 29|
|五|算法列表........................................................................................................... 37||
|六|问题列表........................................................................................................... 50||



一 快速入门 

## 一 快速入门 

软件要求： MATLAB R2018a 或以上（不使用 PlatEMO 图形界面）或 MATLAB R2020b 或以上（使用 PlatEMO 图形界面）及 并行计算工具箱 和 

统计与机器学习工具箱 

PlatEMO 是一个用于求解优化问题的开源平台，它的输入是一个优化问题， 输出是在该优化问题上得到的最优解。一个优化问题满足以下定义： 

**==> picture [219 x 58] intentionally omitted <==**

其中 𝐱 表示该问题的一个解或决策向量，它由 𝐷 个决策变量 𝑥𝑖 组成，其中每个 决策变量可能被限制为实数、整数或二进制数等。 Ω 表示该问题的搜索空间，它 由下界 𝑙1, 𝑙2, … , 𝑙𝐷 和上界 𝑢1, 𝑢2, … , 𝑢𝐷 构成，即任意决策变量始终满足 𝑙𝑖 ≤𝑥𝑖 ≤ 𝑢𝑖 。 𝑓1(𝐱), 𝑓2(𝐱), … , 𝑓𝑀(𝐱) 表示该解的 𝑀 个目标函数值， 𝑔1(𝐱), 𝑔2(𝐱), … , 𝑔𝐾(𝐱) 表 示该解的 𝐾 个约束违反值。 

为了定义一个优化问题，用户至少需要输入以下内容： 

- 每个决策变量的编码方式（实数、整数或二进制数等）； 

- 决策变量的下界 𝑙1, 𝑙2, … , 𝑙𝐷 和上界 𝑢1, 𝑢2, … , 𝑢𝐷 ； 

- 至少一个目标函数 𝑓1(𝐱) 。 

为了更精准地定义问题，用户还能输入以下内容： 

- 多个目标函数 𝑓1(𝐱), 𝑓2(𝐱), … , 𝑓𝑀(𝐱) ； 

- 多个约束函数 𝑔1(𝐱), 𝑔2(𝐱), … , 𝑔𝐾(𝐱) ； 

- 解的初始化函数； 

- 无效解的修复函数； 

- 解的评价函数； 

- 目标和约束的梯度函数； 

1 

PlatEMO 用户手册 

- 各函数计算中使用到的数据（一个任意类型的常量）。 

以上函数均指的是代码函数而非数学函数，即它需要有符合规定的输入和输 出，但不需要有显式的数学表达式。此外，用户还能定义与优化算法相关的内容， 通过选择合适的算法和参数设置以提升优化效果。 

在 MATLAB 中，用户可以用以下三种方式运行主函数文件 `platemo.m` ： 

## 1) 带参数调用主函数： 

```
platemo('problem',@SOP_F1,'algorithm',@GA);
```

可以利用指定的算法来求解指定的测试问题并设置参数，优化结果可以被显示在 窗口中、保存在文件中或作为函数返回值（参阅 求解测试问题 章节）。 

- 2) 带参数调用主函数： 

```
f1 = @(x)sum(x);
g1 = @(x)1-sum(x);
platemo('objFcn',f1,'conFcn',g1,'algorithm',@GA);
```

可以利用指定的算法来求解自定义的问题（参阅 求解自定义问题 章节）。 

- 3) 不带参数调用主函数： 

```
platemo();
```

可以弹出一个带有四个模块的图形界面，其中测试模块用于可视化地研究单个算 法在单个问题上的性能（参阅 测试模块 章节），应用模块用于求解自定义问题（参 阅 应用模块 章节），实验模块用于统计分析多个算法在多个问题上的性能（参阅 实验模块 章节），创造模块用于零代码创建全新的 NeuroEA 算法（参阅 创造模 块 章节）。 

**==> picture [285 x 108] intentionally omitted <==**

2 

二 通过命令行使用 PlatEMO 

## 二 通过命令行使用 PlatEMO 

## 1. 求解测试问题 

- 用户可以以如下形式带参数调用主函数 `platemo()` 来求解测试问题： 

```
platemo('Name1',Value1,'Name2',Value2,'Name3',Value3);
```

## 其中所有可接受的参数列举如下： 

|其中所有可接受的参数列举如下：|其中所有可接受的参数列举如下：|其中所有可接受的参数列举如下：|其中所有可接受的参数列举如下：|
|---|---|---|---|
|参数名<br>数据类型<br>默认值<br>描述||||
|**`'`**`algorithm'`|函数句柄或<br>单元数组|不定|要运行的算法类|
|**`'`**`problem'`|函数句柄或<br>单元数组|不定|要求解的问题类|
|`'N'`|正整数|`100`|种群大小|
|`'M'`|正整数|不定|问题的目标数|
|`'D'`|正整数|不定|问题的变量数|
|`'maxFE'`|正整数|`10000`|最大评价次数|
|`'maxRuntime'`|<br>正数|`inf`|最大运行时间|
|`'save'`|整数|`-10`|保存的种群数|
|`'run'`|正整数|`[]`|当前运行的编号|
|`'metName'`|字符串或单元<br>数组|`{}`|要计算的指标名称|
|`'outputFcn'`|函数句柄|`@DefaultOutput`|每代开始前调用的函数<br>输入一：`ALGORITHM`对象<br>输入二：`PROBLEM`对象<br>输出：无|



- `'algorithm'` 表示待运行的算法，它的值可以是一个算法类的句柄，例如 `@GA` 。它的值还可以是形如 `{@GA,p1,p2,…}` 的单元数组，其中 `p1,p2,…` 指 定了该算法中的参数值。例如以下代码用算法 `@GA` 求解默认问题，并设置了 该算法中的参数值： 

## `platemo('algorithm',{@GA,1,30,1,30});` 

- `'problem'` 表示待求解的测试问题，它的值可以是一个问题类的句柄，例 

3 

PlatEMO 用户手册 

- 如 `@SOP_F1` 。它的值还可以是形如 `{@SOP_F1,p1,p2,…}` 的单元数组，其 中 `p1,p2,…` 指定了该问题中的参数值。例如以下代码用默认算法求解问题 `@WFG1` ，并设置了该问题中的参数值： 

```
platemo('problem',{@WFG1,20});
```

- `'N'` 表示算法使用的种群的大小，它通常等于最终输出的解的个数。例如以 下代码用算法 `@GA` 求解问题 `@SOP_F1` ，并设置种群大小为 50 ： 

```
platemo('algorithm',@GA,'problem',@SOP_F1,'N',50);
```

- `'M'` 表示问题的目标个数，它仅对一些多目标测试问题生效。例如以下代码 用算法 `@NSGAII` 求解具有 5 个目标的 `@DTLZ2` 问题： 

```
platemo('algorithm',@NSGAII,'problem',@DTLZ2,'M',5);
```

- `'D'` 表示问题的变量个数，它仅对一些测试问题生效。例如以下代码用算法 `@GA` 求解具有 100 个变量的 `@SOP_F1` 问题： 

```
platemo('algorithm',@GA,'problem',@SOP_F1,'D',100);
```

- `'maxFE'` 表示算法可用的最大评价次数，它通常等于种群大小乘以迭代次 数。例如以下代码设置算法 `@GA` 的最大评价次数为 20000 ： 

```
platemo('algorithm',@GA,'problem',@SOP_F1,'maxFE',20000);
```

- `'maxRuntime'` 表示算法可用的最大运行时间，单位为秒。当 `'maxRuntime'` 等于默认值 `inf` 时，算法将在 `'maxFE'` 次评价次数后停止； 否则，算法将在 `'maxRuntime'` 秒后停止。例如以下代码设置算法 `@GA` 的最 大运行时间为 10 秒： 

```
platemo('algorithm',@GA,'problem',@SOP_F1,'maxRuntime',10);
```

- `'save'` 表示保存的种群数，该值大于零时优化结果将被保存在文件中，该 值小于零时优化结果将被显示在窗口中（参阅 获取运行结果 章节）。 

- `'run'` 表示当前运行的编号，它附加在保存文件名的末尾，使相同算法在相 同问题上的多次运行结果对应的文件名不同（参阅 获取运行结果 章节）。 

- `'metName'` 表示要计算的指标名称，它可以是一个字符串（单个指标）或 一个单元数组（多个指标）。保存的种群会被计算指定的指标值，并保存在 文件或显示在窗口中（参阅 获取运行结果 章节）。 

- `'outputFcn'` 表示算法每代开始前调用的函数。该函数必须有两个输入和 

4 

二 通过命令行使用 PlatEMO 

零个输出，其中第一个输入是当前的 `ALGORITHM` 对象、第二个输入是当前 的 `PROBLEM` 对象。默认的 `'outputFcn'` 会根据 `'save'` 的值来保存或显示 优化结果。 

注意以上每个参数均有一个默认值，用户可以在调用时省略任意参数。 

## 2. 求解自定义问题 

当不指定参数 `'problem'` 时，用户可以通过指定以下参数来自定义问题： 

|当不指定参数`'problem'`时，用户可以通过指定以下参数来自定义问题：|当不指定参数`'problem'`时，用户可以通过指定以下参数来自定义问题：|当不指定参数`'problem'`时，用户可以通过指定以下参数来自定义问题：|当不指定参数`'problem'`时，用户可以通过指定以下参数来自定义问题：|
|---|---|---|---|
|参数名<br>数据类型<br>默认值<br>描述||||
|**`'`**`objFcn`**`'`**|函数句柄、矩<br>阵或单元数组|`{}`|问题的目标函数；所有目标函数均<br>被最小化<br>输入：一个决策向量<br>输出：目标值（标量）|
|**`'`**`encoding`**`'`**|标量或行向量|`1`|每个变量的编码方式|
|**`'`**`lower`**`'`**|标量或行向量|`0`|每个变量的下界|
|**`'`**`upper`**`'`**|标量或行向量|`1`|每个变量的上界|
|**`'`**`conFcn`**`'`**|函数句柄、矩<br>阵或单元数组|`{}`|问题的约束函数；当且仅当约束违<br>反值小于等于零时，该约束被满足<br>输入：一个决策向量<br>输出：约束违反值（标量）|
|**`'`**`decFcn`**`'`**|函数句柄|`{}`|无效解修复函数<br>输入：一个决策向量<br>输出：修复后的决策向量|
|**`'`**`evalFcn`**`'`**|函数句柄|`{}`|解的评价函数<br>输入：一个决策向量<br>输出一：修复后的决策向量<br>输出二：所有目标值（向量）<br>输出三：所有约束违反值（向量）|
|**`'`**`initFcn`**`'`**|函数句柄|`{}`|种群初始化函数<br>输入：种群大小<br>输出：种群的决策向量构成的矩阵|
|**`'`**`gradFcn`**`'`**|函数句柄|`{}`|目标和约束的梯度函数<br>输入：一个决策向量<br>输出一：目标雅可比矩阵<br>输出二：约束雅可比矩阵|
|**`'`**`data`**`'`**|任意|`{}`|问题的数据|
|**`'`**`once`**`'`**|逻辑|`0`|是否支持同时评价多个解|



5 

PlatEMO 用户手册 

- `'objFcn'` 表示问题的目标函数，它的值可以是一个函数句柄（单目标）、矩 阵（自动拟合出函数）或一个单元数组（多目标）。每个目标函数必须有一 个输入和一个输出，其中输入是一个决策向量、输出是目标值。所有目标函 数均被最小化。例如以下代码利用默认算法求解一个含有六个实数变量的双 目标优化问题： 

```
f1 = @(x)x(1)+sum(x(2:end));
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
platemo('objFcn',{f1,f2},'D',6);
```

𝐷 2 𝐷 其中第一个目标为 𝑥1 + ∑𝑖=2 𝑥𝑖 、第二个目标为 √1 −𝑥1 + ∑𝑖=2 𝑥𝑖 。若一个 目标函数是矩阵，则高斯过程回归会利用该矩阵自动拟合出一个函数，其中 矩阵的每行表示一个样本、每列表示一个变量（除最后一列）或函数值（最 后一列）。例如以下代码求解相同的问题，但目标函数是根据矩阵自动拟合 出来的： 

```
x = rand(50,6);
y1 = x(:,1)+sum(x(:,2:end),2);
y2 = sqrt(1-x(:,1).^2)+sum(x(:,2:end),2);
platemo('objFcn',{[x,y1],[x,y2]},'D',6);
```

- `'encoding'` 表示每个变量的编码方式，它的值可以是一个标量或行向量， 且每维的值可以为 `1` （实数）、 `2` （整数）、 `3` （标签）、 `4` （二进制数）或 `5` （序 列编号）。算法针对不同的编码方式可能使用不同的算子来产生解。例如以 下代码指定三个实数变量、两个整数变量以及一个二进制变量： 

```
f1 = @(x)x(1)+sum(x(2:end));
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
platemo('objFcn',{f1,f2},'encoding',[1,1,1,2,2,4]);
```

问题的变量数 𝐷 将根据 `'encoding'` 的长度自动确定。 

- `'lower'` 和 `'upper'` 分别表示每个变量的下界和上界，它们的值可以是标 量或行向量，且每维的值必须为实数。 `'lower'` 和 `'upper'` 的长度必须与 `'encoding'` 相同。例如以下代码指定搜索空间为 [0,1] × [0,9][5] ： 

```
f1 = @(x)x(1)+sum(x(2:end));
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
platemo('objFcn',{f1,f2},'encoding',[1,1,1,2,2,4],...
'lower',0,'upper',[1,9,9,9,9,9]);
```

6 

二 通过命令行使用 PlatEMO 

- `'conFcn'` 表示问题的约束函数，它的值可以是一个函数句柄（单约束）、矩 阵（自动拟合出函数）或一个单元数组（多约束）。每个约束函数必须有一 个输入和一个输出，其中输入是一个决策向量、输出是约束违反值。当且仅 当约束违反值小于等于零时，该约束被满足。例如以下代码利用默认算法求 解一个双目标优化问题： 

```
f1 = @(x)x(1)+sum(x(2:end));
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
g1 = @(x)1-sum(x(2:end));
platemo('objFcn',{f1,f2},'encoding',[1,1,1,2,2,4],...
'conFcn',g1,'lower',0,'upper',[1,9,9,9,9,9]);
```

6 并添加约束函数 ∑𝑖=2 𝑥𝑖 ≥1 。注意，等式约束必须转换为不等式约束来处理 `,` 详细方法可参阅 该论文 的 3.2 节。若一个约束函数是矩阵，则高斯过程回归 会利用该矩阵自动拟合出一个函数，其中矩阵的每行表示一个样本、每列表 示一个变量（除最后一列）或函数值（最后一列）。例如以下代码求解相同 的问题，但约束函数是根据矩阵自动拟合出来的： 

```
f1 = @(x)x(1)+sum(x(2:end));
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
x = rand(50,6);
y = 1-sum(x(:,2:end),2);
platemo('objFcn',{f1,f2},'encoding',[1,1,1,2,2,4],...
'conFcn',[x,y],'lower',0,'upper',[1,9,9,9,9,9]);
```

- `'decFcn'` 表示问题的无效解修复函数，它的值必须是一个函数句柄。该函 数必须有一个输入和一个输出，其中输入是一个决策向量、输出是修复后的 决策向量。默认的 `'decFcn'` 将所有解的范围限定在 `'lower'` 和 `'upper'` 之间，而以下代码定义了一个新的 `'decFcn'` 限制 𝑥1 为 0.1 的倍数： 

```
f1 = @(x)x(1)+sum(x(2:end));
```

```
f2 = @(x)sqrt(1-x(1)^2)+sum(x(2:end));
g1 = @(x)1-sum(x(2:end));
h = @(x)[round(x(1)/0.1)*0.1,x(2:end)];
platemo('objFcn',{f1,f2},'encoding',[1,1,1,2,2,4],...
'conFcn',g1,'decFcn',h,'lower',0,'upper',[1,9,9,9,9,9]);
```

- `'evalFcn'` 表示解的评价函数，它的值必须是一个函数句柄。该函数必须 有一个输入和三个输出，其中输入是一个决策向量、第一个输出是修复后的 决策向量、第二个输出是目标值向量、第三个输出是约束违反值向量。默认 

7 

PlatEMO 用户手册 

的 `'evalFcn'` 通过依次调用 `'decFcn'` 、 `'objFcn'` 和 `'conFcn'` 来评价解， 而以下代码定义了一个新的 `'evalFcn'` 来同时进行解的修复、目标计算和 约束计算： 

```
function [x,f,g] = Eval(x)
x = [round(x(1)/0.1)*0.1,x(2:end)];
x = max(0,min([1,9,9,9,9,9],x));
f(1) = x(1)+sum(x(2:end));
f(2) = sqrt(1-x(1)^2)+sum(x(2:end));
g = 1-sum(x(2:end));
end
```

接着，以下代码通过仅指定评价函数定义了相同的问题： 

```
platemo('evalFcn',@Eval,'encoding',[1,1,1,2,2,4],...
'lower',0,'upper',[1,9,9,9,9,9]);
```

- `'initFcn'` 表示种群初始化函数，它的值必须是一个函数句柄。该函数必 须有一个输入和一个输出，其中输入是种群大小、输出是种群的决策向量构 成的矩阵。默认的 `'initFcn'` 在整个搜索空间内随机产生初始解，而以下 代码定义了一个新的 `'initFcn'` 以加速收敛： 

```
q = @(N)rand(N,6);
platemo('evalFcn',@Eval,'encoding',[1,1,1,2,2,4],...
'initFcn',q,'lower',0,'upper',[1,9,9,9,9,9]);
```

- `'gradFcn'` 表示目标和约束的梯度函数，它的值必须是一个函数句柄。该 函数必须有一个输入和两个输出，其中输入是一个决策向量、第一个输出是 目标雅可比矩阵、第二个输出是约束雅可比矩阵。默认的梯度函数通过有限 差分来估计梯度，而以下代码定义了一个新的 `'gradFcn'` 以加速收敛： 

```
function [oGrad,cGrad] = Grad(x)
oGrad = [0,x(2:end);0,x(2:end)];
cGrad = [0,x(2:end)-1/5];
end
```

接着，以下代码通过指定梯度函数来更好地求解问题： 

```
platemo('evalFcn',@Eval,'encoding',[1,1,1,2,2,4],...
'gradFcn',@Grad,'lower',0,'upper',[1,9,9,9,9,9]);
```

注意仅有少量算法会使用梯度函数。 

- `'data'` 表示问题的数据，它可以是任意类型的常量。当指定 `'data'` 后，以 

8 

二 通过命令行使用 PlatEMO 

上所有函数必须增加一个输入参数来接收 `'data'` 。例如以下代码求解一个 旋转的单目标优化问题： 

```
d = rand(RandStream('mlfg6331_64','Seed',28),10)*2-1;
[d,~] = qr(d);
f1 = @(x,d)sum((x*d-0.5).^2);
platemo('objFcn',f1,'encoding',ones(1,10),'data',d);
```

- `'once'` 表示是否可以同时评价多个解，它是默认值为零的逻辑变量。当指 定 `'once'` 的值为 `1` 后， `'evalFcn'` 、 `'decFcn'` 、 `'objFcn'` 和 `'conFcn'` 的输入可以为多个决策向量，即同时评价多个解。在函数中使用矩阵运算或 并行计算来支持同时评价多个解，可以显著提升求解效率。例如以下代码将 目标函数改写为矩阵运算： 

```
d = rand(RandStream('mlfg6331_64','Seed',28),10)*2-1;
[d,~] = qr(d);
f1 = @(x,d)sum((x*d-0.5).^2,2);
platemo('objFcn',f1,'encoding',ones(1,10),'data',d,'once',1);
```

除以上定义问题的方式之外，用户还能创建一个自定义问题对象并创建算法 

对象予以求解。例如以下代码利用算法 `@GA` 和算法 `@DE` 求解相同的问题： 

```
d = rand(RandStream('mlfg6331_64','Seed',28),10)*2-1;
[d,~] = qr(d);
f1 = @(x,d)sum((x*d-0.5).^2);
PRO = UserProblem('objFcn',f1,'encoding',ones(1,10),'data',d);
ALG1 = GA();
ALG2 = DE();
ALG1.Solve(PRO);
ALG2.Solve(PRO);
```

## 3. 获取运行结果 

算法运行结束后得到的种群可以被显示在窗口中、保存在文件中或作为函数 返回值。若按以下方式调用主函数： 

```
[Dec,Obj,Con] = platemo('Name1',Value1,'Name2',Value2);
```

则最终种群会被返回，其中 `Dec` 表示种群的决策向量构成的矩阵、 `Obj` 表示种 群的目标值构成的矩阵、 `Con` 表示种群的约束违反值构成的矩阵。若按以下方式 调用主函数： 

9 

PlatEMO 用户手册 

```
platemo('save',Value);
```

则当 `Value` 的值为负整数时（默认情况），得到的种群会被显示在窗口中，用户 可以在窗口中的 `Data source` 菜单选择要显示的内容。当 `Value` 的值为正整 数时，得到的种群会被保存在名为 `PlatEMO\Data\alg\ alg_pro_M_D_run.mat` 的 MAT 文件中，其中 `alg` 表示算法名、 `pro` 表示问 题名、 `M` 表示目标数、 `D` 表示变量数、 `run` 是一个自动确定的正整数以保证不和 已有文件重名。同时，可按以下方式主动指定 `run` 的值： 

```
parfor i = 1 : 100
platemo('save',Value,'run',i);
end
```

则 `run` 的值会被指定为 `1` 到 `100` 。在并行多次运行时，主动指定 `run` 的值可以 避免文件编号混乱或缺失。 

每个保存的数据文件存储一个单元数组 `result` 和一个结构体 `metric` ，其 中 `result` 保存得到的种群、 `metric` 保存指标值。算法的整个优化过程被等分 为 `Value` 块，其中 `result` 的第一列存储每块最后一代时所消耗的评价次数、 `result` 的第二列存储每块最后一代时的种群、 `metric` 存储所有种群的指标值。 

**==> picture [180 x 117] intentionally omitted <==**

**==> picture [138 x 87] intentionally omitted <==**

可以通过参数 `'metName'` 来指定要计算的指标，例如以下代码用算法 `@NSGAII` 求解 `@DTLZ2` 问题，并计算 IGD 和 HV 指标值保存在文件中： 

```
platemo('algorithm',@NSGAII,'problem',@DTLZ2,...
'save',6,'metName',{'IGD','HV'});
```

其中 `'IGD'` 和 `'HV'` 为要计算的指标名（参阅 指标函数 章节）。特别地， IGD 和 HV 是多目标优化中最常用的性能指标，它们的适用范围和参考点定义方法参阅 该论文 的 5.3 节。以上操作均由默认的输出函数 `@DefaultOutput` 实现，用户 可以通过指定 `'outputFcn'` 的值为其它函数来实现自定义的结果展示或保存方 式。此外，可按以下方式计算单个种群的指标值： 

10 

二 通过命令行使用 PlatEMO 

`%` 在执行以下代码之前需先载入 `result pro = DTLZ2(); pro.CalMetric('IGD',result{end});` 

同时，图形界面的实验模块可以自动计算种群的指标值并存储到文件中。 

11 

PlatEMO 用户手册 

## 三 通过图形界面使用 PlatEMO 

## 1. 测试模块 

- 用户可以通过无参数调用主函数 `platemo()` 来使用 PlatEMO 的图形界面： 

## `platemo();` 

图形界面的测试模块会被首先显示，它用于可视化地研究单个算法在单个问题上 的性能。 

**==> picture [414 x 198] intentionally omitted <==**

**----- Start of picture text -----**<br>
步骤 6<br>展示结果<br>步骤 7<br>选择结果<br>步骤 1<br>选择标签<br>步骤 4<br>设置参数<br>步骤 2<br>选择算法<br>步骤 3<br>选择问题 步骤 5<br>控制运行<br>**----- End of picture text -----**<br>


在该模块中，用户能用以下步骤研究单个算法在单个问题上的性能： 

- 步骤 1 ：选择多个标签确定问题类型（参阅 算法、问题和指标的标签 章节）。 

- 步骤 2 ：在列表中选择一个算法。 

- 步骤 3 ：在列表中选择一个问题。 

- 步骤 4 ：设置算法和问题的参数。不同算法和问题可能有不同的参数，在参 数上悬停可查看具体说明。 

- 步骤 5 ：开始、暂停、停止或回退算法的运行；保存当前结果到文件。当前 结果可被保存为一个 𝑁 行 𝐷+ 𝑀+ 𝐾 列的矩阵， 𝑁 表示解的个数， 𝐷 表示决 策变量个数， 𝑀 表示目标个数， 𝐾 表示约束个数。 

- 步骤 6 ：选择要显示的数据，例如当前种群的目标值、变量值和各指标值。 

- 步骤 7 ：选择要显示的历史运行结果。 

12 

三 通过图形界面使用 PlatEMO 

## 2. 应用模块 

用户可以通过图形界面中的菜单切换至应用模块，它用于求解自定义问题。 

**==> picture [415 x 217] intentionally omitted <==**

**----- Start of picture text -----**<br>
步骤 3<br>选择算法<br>步骤 6<br>步骤 2 展示结果<br>验证问题<br>步骤 1<br>定义问题<br>步骤 4 步骤 5<br>设置参数 控制运行<br>**----- End of picture text -----**<br>


## 在该模块中，用户能用以下步骤求解自定义问题： 

- 步骤 1 ：定义一个问题，定义的内容与 求解自定义问题 相同，其中 Encoding scheme 对应 `'encoding'` ，Decision space 对应 `'lower'` 和 `'upper'` ， Data 对应 `'data'` ，Initialization function 对应 `'initFcn'` ，Repair function 对应 `'decFcn'` ，Objective functions 对应 `'objFcn'` ，Constraint functions 对应 `'conFcn'` ，Evaluation function 对应 `'evalFcn'` 。 

- 步骤 2 ：保存或载入问题；检测问题定义的合法性；选择一个问题模板。保 存的问题可在其它模块中打开并求解。 

- 步骤 3 ：在列表中选择一个算法。标签会根据问题定义自动确定（参阅 算法、 问题和指标的标签 章节）。 

- 步骤 4 ：设置算法的参数。不同算法可能有不同的参数，在参数上悬停可查 看具体说明。 

- 步骤 5 ：开始、暂停、停止或回退算法的运行；保存当前结果到文件。当前 结果可被保存为一个 𝑁 行 𝐷+ 𝑀+ 𝐾 列的矩阵， 𝑁 表示解的个数， 𝐷 表示决 策变量个数， 𝑀 表示目标个数， 𝐾 表示约束个数。 

- 步骤 6 ：选择要显示的数据，例如种群的目标值、变量值和各指标值。 

13 

PlatEMO 用户手册 

## 3. 实验模块 

用户可以通过图形界面中的菜单切换至实验模块，它用于统计分析多个算法 在多个问题上的性能。该模块中所有优化结果将被保存至 MAT 文件（参见 获取 运行结果 章节），如文件存在则会直接读取而不运行算法。 

**==> picture [413 x 217] intentionally omitted <==**

**----- Start of picture text -----**<br>
步骤 7<br>展示结果<br>步骤 1<br>选择标签<br>步骤 2<br>选择算法<br>步骤 3<br>选择问题<br>步骤 4<br>保存设置<br>步骤 5 步骤 6<br>设置参数 控制运行<br>**----- End of picture text -----**<br>


在该模块中，用户能用以下步骤比较多个算法在多个问题上的性能： 

- 步骤 1 ：选择多个标签确定问题类型（参阅 算法、问题和指标的标签 章节）。 

- 步骤 2 ：在列表中选择多个算法。 

- 步骤 3 ：在列表中选择多个问题。 

- 步骤 4 ：设置实验重复次数、每次保存的种群个数及保存的文件路径（参阅 获取运行结果 章节）。 

- 步骤 5 ：设置算法和问题的参数。不同算法和问题可能有不同的参数，在参 数上悬停可查看具体说明。此处问题的参数可以设置为向量，这使得同一个 问题可以产生多个不同的测试实例。 

- 步骤 6 ：开始或停止实验的运行；选择串行（单 CPU ）或并行（多 CPU ）运 行实验。 

- 步骤 7 ：选择要显示的指标值；选择要执行的统计分析；保存表格到文件； 将选中的多个单元格的数据显示在图窗中。 

14 

三 通过图形界面使用 PlatEMO 

## 4. 创造模块 

用户可以通过图形界面中的菜单切换至创造模块，它用于创建全新的 NeuroEA 算法，并在指定问题上训练它。关于 NeuroEA 算法的细节可参阅 该论 

- 文 ，以无界面的方式创建 NeuroEA 算法的方法可参阅 创建 NeuroEA 算法 章节。 

**==> picture [415 x 215] intentionally omitted <==**

**----- Start of picture text -----**<br>
步骤 2 步骤 3<br>验证算法 选择问题<br>步骤 5<br>训练算法<br>步骤 1<br>创建算法<br>步骤 6<br>测试算法<br>步骤 4<br>设置参数<br>**----- End of picture text -----**<br>


在该模块中，用户能用以下步骤创建并训练算法： 

- 步骤 1 ：通过点击按钮来添加模块，通过点击两个模块来添加连接，通过拖 动模块和连接来改变布局。模块包含种群模块、算子模块和选择模块，每个 模块有一些预设的超参数和一些待训练的参数；连接表示模块间解的传递方 向和比例。一个算法视为一个以模块为节点、以连接为边的有权有向循环图， 其中第一个节点必须为种群模块、算法至少包含一个算子模块节点、所有节 点必须有前驱和后继节点、所有节点必须互相可达、所有环中必须包含至少 一个种群模块节点。 

- 步骤 2 ：保存或载入算法或模块；生成算法代码；改变显示样式；自动排列 模块；检测算法的合法性；选择一个算法模板。算法训练完成后，可生成算 法代码并在其它模块使用。 

- 步骤 3 ：选择多个标签确定问题类型（参阅 算法、问题和指标的标签 章节）； 在列表中选择一个问题。 

- 步骤 4 ：设置问题的参数。不同问题可能有不同的参数，在参数上悬停可查 看具体说明。 

- 步骤 5 ：在选择的问题上训练算法中所有模块的参数。这个过程可能较慢， 

15 

PlatEMO 用户手册 

较大的模块数目、问题变量数目、种群大小和评价次数可能耗费数天。 

- 步骤 6 ：在选择的问题上测试训练后的算法的性能。 

## 5. 算法、问题和指标的标签 

每个算法、测试问题和指标需要被添加上标签，这些标签以注释的形式添加 在主函数代码的第二行。例如在 `PSO.m` 代码的开头部分： 

```
classdef PSO < ALGORITHM
```

```
% <1995> <single> <real/integer> <large/none> <constrained/none>
```

通过多个标签指定了该算法可求解的问题类型。所有的标签列举如下： 

|通过多个标签指定了该算法可求解的问题类型。所有的标签列举如下：|通过多个标签指定了该算法可求解的问题类型。所有的标签列举如下：|
|---|---|
|标签<br>描述||
|`<single>`|单目标优化：问题含有一个目标函数|
|`<multi>`|多目标优化：问题含有两个或三个目标函数|
|`<many>`|超多目标优化：问题含有四个或更多目标函数|
|`<real>`|连续优化：决策变量为实数|
|`<integer>`|整数优化：决策变量为整数|
|`<label>`|标签优化：决策变量为标签|
|`<binary>`|二进制优化：决策变量为二进制数|
|`<permutation> `|序列优化：决策变量构成一个排列|
|`<large>`|大规模优化：问题含有100或更多的决策变量|
|`<constrained> `|约束优化：问题含有至少一个约束|
|`<expensive>`|昂贵优化：目标函数的计算非常耗时，即最大评价次数非常小|
|`<multimodal> `|多模优化：存在多个目标值接近但决策向量差异很大的最优解，<br>它们都需要被找到|
|`<sparse>`|稀疏优化：最优解中大部分的决策变量均为零|
|`<dynamic>`|动态优化：目标函数和约束函数随时间变化|
|`<multitask>`|多任务优化：同时优化多个问题，每个问题可能含有多个目标函<br>数和约束函数|
|`<bilevel>`|双层优化：旨在寻找上层问题的可行且最优的解，一个解对于上<br>层问题是可行的当且仅当它是下层问题的最优解|
|`<robust>`|鲁棒优化：目标函数和约束函数受噪声影响，旨在寻找受噪声影<br>响尽可能小且尽可能优的解|
|`<none>`|空标签|
|`<min>`|（仅用于指标）该指标值越小表示性能越好|
|`<max>`|（仅用于指标）该指标值越大表示性能越好|



16 

三 通过图形界面使用 PlatEMO 

每个算法可能含有多个标签集合，这些集合的笛卡尔积构成该算法可求解的所有 的问题类型。例如当标签集合为 `<single> <real> <constrained/none>` 时，表示该算法可求解带或不带约束的单目标连续优化问题；若标签集合为 `<single> <real>` ，表示该算法只能求解无约束问题；若标签集合为 `<single> <real> <constrained>` ，表示该算法只能求解有约束问题；若标签集合为 `<single> <real/binary>` ，表示该算法可以求解连续或二进制优化问题。 

每个算法、测试问题和指标都需要被添加至少一个标签，否则它将不会在图 形界面的列表中出现。当用户在图形界面中选择多个标签后，仅有符合该标签组 合的算法、测试问题和指标才会被显示以供选择。标签过滤的具体原理可参阅 这 里 。 PlatEMO 中所有算法和测试问题的标签分别参阅 算法列表 和 问题列表 章节。 

除此之外，每个算法和测试问题可以被添加一个年份标签如 `<2024>` ，这使 得图形界面的列表中的算法和测试问题可以按年份过滤。 

17 

PlatEMO 用户手册 

## 四 扩展 PlatEMO 

## 1. 算法类 

每个算法需要被定义为 `ALGORITHM` 类的子类并保存在 `PlatEMO\ Algorithms` 文件夹中。算法类包含的属性与方法如下： 

|`Algorithms`文件夹中。算法类包含的属性与方法如下：|`Algorithms`文件夹中。算法类包含的属性与方法如下：|`Algorithms`文件夹中。算法类包含的属性与方法如下：|
|---|---|---|
|属性<br>赋值方式<br>描述|||
|`parameter`|用户|算法的参数|
|`save`|用户|每次运行中保存的种群数|
|`run`|用户|当前运行的编号|
|`metName`|用户|要计算的指标名称|
|`outputFcn`|用户|在`NotTerminated()`中调用的函数|
|`pro`|`Solve()`|当前运行中求解的问题对象|
|`result`|`NotTerminated()`|当前运行中保存的种群|
|`metric`|`NotTerminated()`|当前保存的种群的指标值|
|`starttime`|`NotTerminated()`|<br>用于记录当前运行用时|
|方法<br>是否可重定义<br>描述|||
|`ALGORITHM`|不可|设定由用户指定的属性值<br>输入：形如`'Name',Value`的参数设置<br>输出：`ALGORITHM`对象|
|`Solve`|不可|利用算法求解一个问题<br>输入：`PROBLEM`对象<br>输出：无|
|`main`|必须|算法的主体部分<br>输入：`PROBLEM`对象<br>输出：无|
|`NotTerminated`|不可|`main()`中每次迭代前调用的函数<br>输入：`SOLUTION`对象数组，即种群<br>输出：是否达到终止条件（逻辑变量）|
|`ParameterSet`|<br>不可|根据`parameter`设定算法参数<br>输入：默认的参数设置<br>输出：用户指定的参数设置|



每个算法需要继承 `ALGORITHM` 类并重定义方法 `main()` 。例如 `GA.m` 的代码为： 

1 `classdef GA < ALGORITHM` 

2 `% <1992><single><real/integer/label/binary/permutation><large/none><constrained/none>` 3 `% Genetic algorithm` 

18 

四 扩展 PlatEMO 

|4|`% proC ---`|`1`|`--- Probability of crossover`|
|---|---|---|---|
|5|`% disC ---`|`20`|`--- Distribution index of crossover`|
|6|`%proM ---`|`1 --- Expectation of the number of mutated variables`||
|7|`% disM ---`|`20`|`--- Distribution index of mutation`|
|8||||
|9|`%------------------------ Reference -----------------------`|||
|10|`% J. H. Holland, Adaptation in Natural and Artificial`|||
|11|`% Systems,`|`MIT Press, 1992.`||
|12|`%----------------------------------------------------------`|||
|13||||
|14|`methods`|||
|15|`function main(Alg,Pro)`|||
|16||`[proC,disC,proM,disM] = Alg.ParameterSet(1,20,1,20);`||
|17||`P =`|`Pro.Initialization();`|
|18||`while Alg.NotTerminated(P)`||
|19|||`Q = TournamentSelection(2,Pro.N,FitnessSingle(P));`|
|20|||`O = OperatorGA(P(Q),{proC,disC,proM,disM});`|
|21|||`P = [P,O];`|
|22|||`[~,rank] = sort(FitnessSingle(P));`|
|23|||`P = P(rank(1:Pro.N));`|
|24||`end`||
|25|`end`|||
|26|`end`|||
|27|`end`|||



## 各行代码的功能如下： 

- 第 1 行： 继承 `ALGORITHM` 类； 

- 第 2 行： 为算法添加标签（参阅 算法、问题和指标的标签 章节）； 

- 第 3 行： 算法的全称； 

- 第 4-7 行： 参数名 --- 默认值 --- 参数描述，将会显示在图形界面的参数设置 列表中； 

- 第 9-12 行：算法的参考文献； 

- 第 15 行： 重定义算法主体流程的方法； 

- 第 16 行： 获取用户指定的参数设置，其中 `1,20,1,20` 分别表示参数 `proC, disC,proM,disM` 的默认值。 

- 第 17 行： 调用 `PROBLEM` 类的方法获得一个初始种群； 

- 第 18 行： 保存当前种群并检查是否达到终止条件；若达到终止条件则通过抛出 

   - 错误强行终止算法； 

- 第 19 行： 调用公共函数实现基于二元联赛的交配池选择； 

19 

PlatEMO 用户手册 

第 20 行： 调用公共函数产生子代种群； 

第 21 行： 将父子代种群合并； 

第 22 行： 调用公共函数计算种群中解的适应度，并依此对解进行排序； 第 23 行： 保留适应度较好的一半解进入下一代。 

在以上代码中，函数 `ParameterSet()` 和 `NotTerminated()` 是 `ALGORITHM` 类的方法，函数 `Initialization()` 是 `PROBLEM` 类的方法，而 函数 `TournamentSelection()` 、 `FitnessSingle()` 和 `OperatorGA()` 是 在 `PlatEMO\Algorithms\Utility functions` 文件夹中的公共函数。所 有可被算法调用的方法及公共函数列举如下，详细的调用方式参阅代码中的注释。 此外，函数中用于提升算法效率的技术参阅 这里 。 

|此外，函数中用于提升算法效率的技术参阅这里。|此外，函数中用于提升算法效率的技术参阅这里。|
|---|---|
|函数名<br>描述||
|`ALGORITHM.`<br>`NotTerminated`|算法每代前调用的函数，用于保存当前种群及判断是否终止|
|`ALGORITHM.`<br>`ParameterSet`|根据用户的输入设定算法参数|
|`PROBLEM.`<br>`Initialization`|初始化一个种群|
|`PROBLEM.`<br>`Evaluation`|评价一个种群并产生`SOLUTION`对象数组|
|`CrowdingDistance`|<br>计算解的拥挤距离（仅用于多目标优化）|
|`FitnessSingle`|计算解的适应度（仅用于单目标优化）|
|`NDSort`|非支配排序（仅用于多目标优化）|
|`OperatorDE`|差分进化算子|
|`OperatorFEP`|进化规划算子|
|`OperatorGA`|遗传算子|
|`OperatorGAhalf`|遗传算子（仅返回前一半的子代）|
|`OperatorPSO`|粒子群优化算子|
|`RouletteWheel`<br>`Selection`|轮盘赌选择|
|`Tournament`<br>`Selection`|联赛选择|
|`UniformPoint`|产生均匀分布的参考点|



## 2. 问题类 

每个问题需要被定义为 `PROBLEM` 类的子类并保存在 `PlatEMO\ Problems` 文件夹中。问题类包含的属性与方法如下： 

20 

四 扩展 PlatEMO 

|属性|赋值方式|描述|
|---|---|---|
|`N`|用户|求解该问题的算法的种群大小|
|`M`|用户和<br>`Setting()`|问题的目标数|
|`D`|用户和<br>`Setting()`|问题的变量数|
|`maxFE`|用户|求解该问题可使用的最大评价次数|
|`FE`|`Evaluation()`|当前运行中已消耗的评价次数|
|`maxRuntime`|用户|求解该问题可使用的最大运行时间（秒）|
|`encoding`|`Setting()`|每个变量的编码方式|
|`lower`|`Setting()`|每个变量的下界|
|`upper`|`Setting()`|每个变量的上界|
|`optimum`||问题的最优值，例如目标函数的最小值（单目标<br>优化）和前沿面上一组均匀参考点（多目标优化）|
||`GetOptimum()`||
||||
|`PF`|`GetPF()`|问题的前沿面，例如1维曲线（双目标优化）、2<br>维曲面（三目标优化）和可行区域（约束优化）|
|`parameter`|用户|问题的参数|
|方法|是否可重定义|描述|
|`PROBLEM`|不可|设定由用户指定的属性值<br>输入：形如`'Name',Value`的参数设置<br>输出：`PROBLEM`对象|
|`Setting`|必须|设定默认的属性值<br>输入：无<br>输出：无|
|`Initialization`|<br>可以|初始化一个种群<br>输入：种群大小<br>输出：`SOLUTION`对象数组，即种群|
|`Evaluation`|可以|评价一个种群并产生解对象<br>输入：种群的决策向量构成的矩阵<br>输出：`SOLUTION`对象数组，即种群|
|`CalDec`|可以|修复一个种群中的无效解<br>输入：种群的决策向量构成的矩阵<br>输出：修复后的决策向量构成的矩阵|
|`CalObj`|必须|计算一个种群中解的目标值；所有目标函数均被<br>最小化<br>输入：种群的决策向量构成的矩阵<br>输出：种群的目标值构成的矩阵|
|`CalCon`|可以|计算一个种群中解的约束违反值；当且仅当约束|



21 

PlatEMO 用户手册 

|||违反值小于等于零时，约束被满足<br>输入：种群的决策向量构成的矩阵<br>输出：种群的约束违反值构成的矩阵|
|---|---|---|
|`CalGrad`|可以|计算一个解在所有目标和约束上的梯度<br>输入：一个决策向量<br>输出一：目标雅可比矩阵<br>输出二：约束雅可比矩阵|
|`GetOptimum`|可以|产生问题的最优值并保存在`optimum`中<br>输入：最优值的个数<br>输出：最优值集合（矩阵）|
|`GetPF`|可以|产生问题的前沿面并保存在`PF`中<br>输入：无<br>输出：用于绘制前沿面的数据（矩阵或单元数组）|
|`CalMetric`|可以|计算种群的指标值<br>输入一：指标名<br>输入二：`SOLUTION`对象数组，即种群<br>输出：指标值（标量）|
|`DrawDec`|可以|显示一个种群的决策向量<br>输入：`SOLUTION`对象数组，即种群<br>输出：无|
|`DrawObj`|可以|显示一个种群的目标向量<br>输入：`SOLUTION`对象数组，即种群<br>输出：无|
|`ParameterSet`|<br>不可|根据`parameter`设定问题参数<br>输入：默认的参数设置<br>输出：用户指定的参数设置|



每个算法需要继承 `PROBLEM` 类并重定义方法 `Setting()` 和 `CalObj()` 。例如 `SOP_F1.m` 的代码为： 

1 `classdef SOP_F1 < PROBLEM` 2 `% <1999><single><real><expensive/none>` 3 `% Sphere function` 

4 5 `%------------------------ Reference -----------------------` 6 `% X. Yao, Y. Liu, and G. Lin, Evolutionary programming made` 7 `% faster, IEEE Transactions on Evolutionary Computation,` 8 `% 1999, 3(2): 82-102.` 9 `%----------------------------------------------------------` 10 11 `methods` 12 `function Setting(obj)` 

22 

四 扩展 PlatEMO 

13 `obj.M = 1;` 14 `if isempty(obj.D); obj.D = 30; end` 15 `obj.lower = zeros(1,obj.D) – 100;` 16 `obj.upper = zeros(1,obj.D) + 100;` 17 `obj.encoding = ones(1,obj.D);` 18 `end` 19 `function PopObj = CalObj(obj,PopDec)` 20 `PopObj = sum(PopDec.^2,2);` 21 `end` 22 `end` 23 `end` 

## 各行代码的功能如下： 

第 1 行： 继承 `PROBLEM` 类； 

- 第 2 行： 为问题添加标签（参阅 算法、问题和指标的标签 章节）； 

第 3 行： 问题的全称； 

第 5-9 行： 问题的参考文献； 

- 第 12 行： 重定义设定默认属性值的方法； 

- 第 13 行： 设置问题的目标数； 

- 第 14 行： 设置问题的变量数（若未被用户指定）； 

- 第 15-16 行：设置决策变量的上下界； 

- 第 17 行： 设置决策变量的编码方式； 

- 第 19 行： 重定义计算目标函数的方法； 

- 第 20 行： 计算种群中解的目标值。 

除以上代码外，默认的方法 `Initialization()` 用于随机初始化一个种群， 

用户可以重定义该方法来指定特殊的种群初始化策略。例如 `Sparse_NN.m` 将 初始化的种群中随机一半的决策变量置零： 

```
function Population = Initialization(obj,N)
if nargin < 2; N = obj.N; end
PopDec = (rand(N,obj.D)-0.5)*2.*randi([0 1],N,obj.D);
Population = obj.Evaluation(PopDec);
end
```

默认的方法 `CalDec()` 将大于上界的决策变量设为上界值、将小于下界的决策变 量设为下界值，用户可以重定义该方法来指定特殊的解修复策略。例如 `MOKP.m` 修复了超过背包容量限制的解，使得该问题无需添加约束函数： 

23 

PlatEMO 用户手册 

```
function PopDec = CalDec(obj,PopDec)
C = sum(obj.W,2)/2;
[~,rank] = sort(max(obj.P./obj.W));
for i = 1 : size(PopDec,1)
while any(obj.W*PopDec(i,:)'>C)
        k = find(PopDec(i,rank),1);
        PopDec(i,rank(k)) = 0;
end
end
end
```

默认的方法 `CalCon()` 返回零作为解的约束违反值（即解都是满足约束的），用 户可以重定义该方法来指定问题的约束。例如 `CF4.m` 添加了一个约束： 

```
function PopCon = CalCon(obj,X)
t = X(:,2)-sin(6*pi*X(:,1)+2*pi/size(X,2))-0.5*X(:,1)+0.25;
PopCon = -t./(1+exp(4*abs(t)));
end
```

利用 `all(PopCon<=0,2)` 可确定每个解是否满足所有约束。注意等式约束必须 转换为不等式约束来处理 `,` 详细方法可参阅 该论文 的 3.2 节。默认的方法 `Evaluation()` 通过依次调用 `CalDec()` 、 `CalObj()` 和 `CalCon()` 来实例化 `SOLUTION` 对象，同时增加已消耗的评价次数 `FE` 的值。用户可以重定义该方法 在一个函数内完成种群的修复、目标计算和约束计算工作，此时 `CalDec()` 、 `CalObj()` 和 `CalCon()` 将不会被调用。例如 `MW2.m` 同时计算了种群的目标值 与约束违反值： 

```
function Population = Evaluation(obj,varargin)
X = varargin{1};
X=max(min(X,repmat(obj.upper,size(X,1),1)),repmat(obj.lower,size(X,1),1));
z=1-exp(-10*(X(:,obj.M:end)-(repmat(obj.M:obj.D,size(X,1),1)-1)/obj.D).^2);
g = 1+sum((1.5+(0.1/obj.D)*z.^2-1.5*cos(2*pi*z)),2);
PopObj(:,1) = X(:,1);
PopObj(:,2) = g.*(1-PopObj(:,1)./g);
L = sqrt(2)*PopObj(:,2)-sqrt(2)*PopObj(:,1);
PopCon = sum(PopObj,2)-1-0.5*sin(3*pi*l).^8;
Population = SOLUTION(X,PopObj,PopCon,varargin{2:end});
obj.FE = obj.FE+length(Population);
end
```

默认的方法 `CalGrad()` 通过有限差分来估计目标函数和约束函数的梯度，用户 可以重定义该方法以更准确地计算梯度。用户可以重定义方法 `GetOptimum()` 

24 

四 扩展 PlatEMO 

来指定问题的最优值，最优值被用于指标值的计算。例如 `SOP_F8.m` 指定了目 标函数的最小值： 

```
function R = GetOptimum(obj,N)
R = -418.9829*obj.D;
end
```

`DTLZ2.m` 生成了一组前沿面上均匀分布的参考点： 

```
function R = GetOptimum(obj,N)
R = UniformPoint(N,obj.M);
R = R./repmat(sqrt(sum(R.^2,2)),1,obj.M);
end
```

在不同形状前沿面上的采点方法参阅 这里 。用户可以重定义方法 `GetPF()` 来指 定多目标优化问题的前沿面或可行区域，它们被用于 `DrawObj()` 的可视化中。 例如 `DTLZ2.m` 生成了 2 维和 3 维的前沿面数据： 

```
function R = GetPF(obj)
if obj.M == 2
    R = obj.GetOptimum(100);
elseif obj.M == 3
    a = linspace(0,pi/2,10)';
R = {sin(a)*cos(a'),sin(a)*sin(a'),cos(a)*ones(size(a'))};
else
    R = [];
end
end
```

`MW1.m` 生成了可行区域的数据： 

```
function R = GetPF(obj)
[x,y]= meshgrid(linspace(0,1,400),linspace(0,1.5,400));
z     = nan(size(x));
fes   = x+y-1-0.5*sin(2*pi*(sqrt(2)*y-sqrt(2)*x)).^8 <= 0;
z(fes&0.85*x+y>=1) = 0;
R     = {x,y,z};
end
```

默认的方法 `CalMetric()` 将一个种群与问题的最优值 `optimum` 传入指标函数 中进行计算，用户可以重定义该方法来将不同的变量传入指标函数中。例如 `SMMOP1.m` 在计算 IGDX 指标时传入问题的最优解集而非前沿面上的参考点： `function score = CalMetric(obj,metName,Population)` 

25 

PlatEMO 用户手册 

```
switch metName
case'IGDX'
        score = feval(metName,Population,obj.POS);
otherwise
        score = feval(metName,Population,obj.optimum);
end
end
```

默认的方法 `DrawDec()` 显示种群的决策向量（用于图形界面中），用户可以重定 

义该方法来指定特殊的显示方式。例如 `TSP.m` 显示了种群中最优解的路径： 

```
function DrawDec(obj,P)
[~,best] = min(P.objs);
Draw(obj.R(P(best).dec([1:end,1]),:),'-k','LineWidth',1.5);
Draw(obj.R);
end
```

默认的方法 `DrawObj()` 显示种群的目标向量（用于图形界面中），用户可以重定 

义该方法来指定特殊的显示方式。例如 `Sparse_CD.m` 添加了坐标轴的标签： 

```
function DrawObj(obj,P)
Draw(P.objs,{'Kernel k-means','Ratio cut',[]});
end
```

其中 `Draw()` 用于显示数据，它位于 `PlatEMO\GUI` 文件夹中。 

## 3. 个体类 

一个 `SOLUTION` 类的对象表示一个个体（即一个解），一组 `SOLUTION` 类的 

对象表示一个种群。个体类包含的属性与方法如下： 

|属性|赋值方式<br>描述|赋值方式<br>描述|赋值方式<br>描述|
|---|---|---|---|
|`dec`||`PROBLEM.`<br>`Evaluation()`|解的决策向量|
|`obj`||`PROBLEM.`<br>`Evaluation()`|解的目标值|
|`con`||`PROBLEM.`<br>`Evaluation()`|解的约束违反值|
|`add`||`PROBLEM.`<br>`Evaluation()`|解的额外属性值（例如速度）|
|方法|描述|||
|`SOLUTION`|生成`SOLUTION`对象数组|||



26 

四 扩展 PlatEMO 

||输入一：多个解的决策向量构成的矩阵<br>输入二：多个解的目标值构成的矩阵<br>输入三：多个解的约束违反值构成的矩阵<br>输入四：多个解的额外属性值构成的矩阵<br>输出：`SOLUTION`对象数组|
|---|---|
|`decs`|获取多个解的决策向量<br>输入：无<br>输出：多个解的决策向量构成的矩阵|
|`objs`|获取多个解的目标值<br>输入：无<br>输出：多个解的目标值构成的矩阵|
|`cons`|获取多个解的约束违反值<br>输入：无<br>输出：多个解的约束违反值构成的矩阵|
|`adds`|设置并获取多个解的额外属性值<br>输入：默认的额外属性值<br>输出：多个解的额外属性值构成的矩阵|
|`best`|获取种群中可行且最好的解（单目标优化）或可行且非支配的解（多<br>目标优化）<br>输入：无<br>输出：种群中可行且最好的`SOLUTION`对象子数组|



例如，以下代码产生一个具有十个解的种群，并获取其中最好的解的目标值矩阵： 

```
Population = SOLUTION(rand(10,5),rand(10,1),zeros(10,1));
BestObjs   = Population.best.objs
```

注意应只在 `PROBLEM` 类的方法 `Evaluation()` 内调用 `SOLUTION()` 。 

## 4. 一次完整的运行过程 

以下代码利用遗传算法求球面函数的最小值： 

```
Alg = GA();
Pro = SOP_F1();
Alg.Solve(Pro);
```

其中代码 `Alg.Solve(Pro)` 执行时所涉及的函数调用过程如下图所示。 

27 

PlatEMO 用户手册 

**==> picture [414 x 411] intentionally omitted <==**

**----- Start of picture text -----**<br>
ALGORITHM.Solve() ALGORITHM.NotTerminated()<br>1. function solve(obj,Problem) 1. function nofinish = NotTerminated(obj,Population)<br>2.   try 2.   obj.metric.runtime = obj.metric.runtime + toc;<br>3.     obj.result = {}; 3.   if obj.pro.maxRuntime < inf<br>4.     obj.metric = struct('runtime',0); 4.     obj.pro.maxFE=obj.pro.FE*obj.pro.maxRuntime/obj.metric.runtime;<br>5.  obj.pro    = Problem; 5.   end<br>6.     obj.pro.FE = 0; 6.   num   = max(1,abs(obj.save));<br>7.     addpath(fileparts(which(class(obj)))); 7.   index = min(num,size(obj.result,1)+1);<br>8.     addpath(fileparts(which(class(obj.pro)))); 8.   index = max(1,min(index,ceil(num*obj.pro.FE/obj.pro.maxFE)));<br>9.     tic; obj.main(obj.pro); 9.   obj.result(index,:) = {obj.pro.FE,Population};<br>10.  catch err 10.  drawnow('limitrate');<br>11.    if ~strcmp(err.identifier,'PlatEMO:Termination') 11.  obj.outputFcn(obj,obj.pro);<br>12.      rethrow(err);13.    end 12.  nofinish = obj.pro.FE < obj.pro.maxFE;13.  assert(nofinish,'PlatEMO:Termination',''); tic;<br>14.  end 14.end<br>15.end<br>GA.main() 1. 2.   [proC,disC,proM,disM] =3.   Population =4.   5.     MP =functionwhile Algorithm.NotTerminated(Population) main(Algorithm,Problem) TournamentSelection Problem.Initialization() Algorithm.ParameterSet(1,20,1,20)(2,Problem.N;,FitnessSingle(Population); ); ALGORITHM.ParameterSet() 1. 2.   varargout = varargin;3.   specified = ~cellfun(@isempty,obj.parameter);4.   varargout(specified) = obj.parameter(specified);5. functionend  varargout = ParameterSet(obj,varargin)<br>6.     Offspring     =  OperatorGA(Problem,Population(MP),{proC,disC,proM,disM});<br>7.     Population = [Population,Offspring]; FitnessSingle() DefaultOutput()<br>8.     [~,rank]   = sort(FitnessSingle(Population)); 1. function Fitness = FitnessSingle(Population) 1. function Output(Algorithm,Problem)<br>9.     Population = Population(rank(1:Problem.N)); 2.   PopCon  = sum(max(0,Population.cons),2); 2.   ... ...<br>10.  end 3.   Feas    = PopCon <= 0; 3. end<br>11.end 4.   Fitness = Feas.*Population.objs;<br>5.   Fitness = Fitness+~Feas.*(PopCon+1e10);<br>PROBLEM.Initialization() 6. end<br>1. function Population = Initialization(obj,N)<br>2.   if nargin < 2 TournamentSelection() SOLUTION.cons()<br>3.     N = obj.N;4.   end 1. 2.   f        = @(S)reshape(S,[],1);function index = TournamentSelection(K,N,varargin) 1. 2.   v = cat(1,obj.con);function v = cons(obj)<br>5.   P = zeros(N,obj.D);6.   T = arrayfun(@(i)find(obj.encoding==i),1:5,7.   8.     9.   10.  11.    12.  ifendifend ~isempty(T{1})P(:,T{1}) = unifrnd(repmat(obj.lower(T{1}),N,1),repmat(obj.upper(T{1},N,1)); ~isempty(T{2})P(:,T{2})=round(unifrnd(repmat(obj.lower(T{2}),N,1),repmat(obj.upper(T{2},N,1)));'UniformOutput',false); 3.   varargin = cellfun(f,varargin,4.   [Fit,~,Loc] = unique([varargin{:}],4.   [~,rank] = sortrows(Fit);5.   [~,rank] = sort(rank);6.   Parents  = randi(length(varargin{1}),K,N);7.   [~,best] = min(rank(Loc(Parents)),[],1);8.   index    = Parents(best+(0:N-1)*K);9. end 'UniformOutput''rows'); ,false); 3.  SOLUTION.objs() 1. 2.   v = cat(1,obj.obj);3. endfunctionend  v = objs(obj)<br>13.  if ~isempty(T{3})<br>14.    P(:,T{3})=unifrnd(ones(N,length(T{3})),repmat(randi(length(T{3}),N,1),1,length(T{3})));<br>15.  16.  17.    P(:,T{4}) = logical(randi([0 1],N,length(T{4})));18.  19.  20.    [~,P(:,T{5})] = sort(rand(N,length(T{5})),2);21.  endifendifend ~isempty(T{4}) ~isempty(T{5}) OperatorGA() 1. 2.   ... ...3.   4.     Offspring =5.   6. functionendifend evaluated Offspring=OperatorGA(Problem,Parent,Para) Problem.Evaluation(Offspring);<br>22.  Population = obj.Evaluation(P);<br>23.end<br>PROBLEM.CalDec()<br>PROBLEM.Evaluation() 1. function PopDec = CalDec(obj,P)<br>1. function P = Evaluation(obj,varargin) 2.   f    = @(i)find(obj.encoding==i);<br>2.   Dec = obj.CalDec(varargin{1}); 3.   Type = arrayfun(f,1:5,'UniformOutput',false);<br>3.   Obj =4.   Con = obj.CalObj(Dec) obj.CalCon(Dec);; 4.   t    = [Type{1:2}];5.   if ~isempty(t)<br>5.   P   = SOLUTION(Dec,Obj,Con,varargin{2:end}); 6.     P(:,t) = min(P(:,t),repmat(obj.upper(t),size(P,1),1));<br>6.   obj.FE = obj.FE + length(P); 7.     P(:,t) = max(P(:,t),repmat(obj.lower(t),size(P,1),1));8.   end<br>9.   t = [Type{2:5}];<br>SOLUTION.SOLUTION() 10.  if ~isempty(t)<br>1. function obj = SOLUTION(Dec,Obj,Con,Add) 11.    P(:,t) = round(P(:,t));<br>2.   if nargin > 0 12.  end<br>3.     obj(1,size(Dec,1)) = SOLUTION; 13.end<br>4.     for i = 1 : length(obj)<br>5.       obj(i).dec = Dec(i,:);6.       obj(i).obj = Obj(i,:); SOP_F1.CalObj()<br>7.       obj(i).con = Con(i,:); 1. function PopObj = CalObj(obj,PopDec)<br>8.     end 2.   PopObj = sum(PopDec.^2,2);<br>9.     if nargin > 3 3. end<br>10.      for i = 1 : length(obj)<br>11.        obj(i).add = Add(i,:);12.      end PROBLEM.CalCon()<br>13.    end 1. function PopCon = CalCon(obj,PopDec)<br>14.  end 2.   PopCon = zeros(size(PopDec,1),1);<br>15.end 3. end<br>**----- End of picture text -----**<br>


## 5. 指标函数 

每个性能指标需要被定义为一个函数并保存在 `PlatEMO\Metrics` 文件夹 中。例如 `IGD.m` 的代码为： 

1 `function score = IGD(Population,optimum)` 2 `% <min> <multi/many> <real/integer/label/binary/permutation> <large/none> <constrained/none> <expensive/none> <multimodal/none> <sparse/none> <dynamic/none> <robust/none>` 3 `% Inverted generational distance` 

4 5 `%------------------------ Reference -----------------------` 6 `% C. A. Coello Coello and N. C. Cortes, Solving` 7 `% multiobjective optimization problem using an artificial` 8 `% immune system, Genetic Programming and Evolvable` 

28 

四 扩展 PlatEMO 

9 `% Machines, 2005, 6(2): 163-190.` 10 `%----------------------------------------------------------` 11 12 `PopObj = Population.best.objs;` 13 `if size(PopObj,2) ~= size(optimum,2)` 14 `score = nan;` 15 `else` 16 `score = mean(min(pdist2(optimum,PopObj),[],2));` 17 `end` 18 `end` 

各行代码的功能如下： 

- 第 1 行： 函数声明，其中第一个输入为一个种群（即一个 `SOLUTION` 对象数 组）、第二个输入为问题的最优值（即问题的 `optimum` 属性）、输出 为种群的指标值； 

- 第 2 行： 为指标添加标签（参阅 算法、问题和指标的标签 章节）；注意标签 `<min>` 或 `<max>` 必须为第一个标签； 

- 第 3 行： 指标的全称； 

- 第 5-10 行：指标的参考文献； 

- 第 12 行： 获取种群中最好的解（可行且非支配的解）的目标值矩阵； 第 13-14 行：若种群不存在可行解则返回 `nan` ； 

- 第 15-16 行：否则返回可行且非支配的解的指标值。 

## 6. 创建 NeuroEA 算法 

NeuroEA 提供了一种创建新算法的灵活框架，它通过有权有向循环图来定义 算法。图中每个节点表示一个种群处理模块如交叉、变异和选择，图中每条边决 定了解在节点之间的传递方向和比例。每个节点包含许多可以自动训练的参数， 一个充分训练的 NeuroEA 算法可以在训练问题上具有突出的性能。 

一个 NeuroEA 算法通过一个 `BLOCK` 对象数组和一个邻接矩阵来表示。例如 一个具有如下形式的 NeuroEA 算法 

**==> picture [284 x 40] intentionally omitted <==**

**----- Start of picture text -----**<br>
Population Tournament Crossover Mutation Selection<br>**----- End of picture text -----**<br>


可以使用如下代码创建和运行： 

29 

PlatEMO 用户手册 

```
addpath('Algorithms\NeuroEA');
Blocks = [Block_Population
            Block_Tournament(200,10)
            Block_Crossover(2,5)
Block_Mutation(5)
            Block_Selection(100)];
Graph = [0 1 0 0 1
           0 0 1 0 0
           0 0 0 1 0
           0 0 0 0 1
           1 0 0 0 0];
platemo('algorithm',{@NeuroEA,Blocks,Graph},'problem',@SOP_F1);
```

## 一个具有如下形式的多种群 NeuroEA 算法 

**==> picture [284 x 76] intentionally omitted <==**

**----- Start of picture text -----**<br>
Population Tournament Crossover Mutation Selection<br>Population Tournament Crossover Mutation Selection<br>**----- End of picture text -----**<br>


## 可以使用如下代码创建和运行： 

```
addpath('Algorithms\NeuroEA');
Blocks = [Block_Population
Block_Tournament(100,10)
Block_Crossover(2,5)
Block_Mutation(5)
Block_Selection(100)
Block_Population
Block_Tournament(100,10)
Block_Crossover(2,5)
Block_Mutation(5)
Block_Selection(100)];
Graph = [0 1 0 0 1 0 0 0 0 0
0 0 1 0 0 0 0 0 0 0
0 0 0 1 0 0 0 0 0 0
0 0 0 0 1 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 1 0 0 1
0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 1 0
0 0 0 0 0 0 0 0 0 1
0 0 0 0 0 1 0 0 0 0];
platemo('algorithm',{@NeuroEA,Blocks,Graph},'problem',@SOP_F1);
```

30 

四 扩展 PlatEMO 

## 一个具有如下形式的复杂 NeuroEA 算法 

**==> picture [284 x 91] intentionally omitted <==**

**----- Start of picture text -----**<br>
Exchange<br>Tournament<br>Exchange<br>Population Tournament Crossover Mutation Selection<br>Exchange<br>Tournament<br>Exchange<br>**----- End of picture text -----**<br>


## 可以使用如下代码创建和运行： 

```
addpath('Algorithms\NeuroEA');
Blocks = [Block_Population
Block_Tournament(200,10)
Block_Tournament(200,10)
Block_Tournament(200,10)
Block_Exchange(3)
Block_Exchange(3)
Block_Exchange(3)
Block_Exchange(3)
Block_Crossover(2,5)
Block_Mutation(5)
Block_Selection(100)];
Graph = [0 1 1 1 0 0 0 0 0 0 1
0 0 0 0 1/4 1/4 1/4 1/4 0 0 0
0 0 0 0 1/4 1/4 1/4 1/4 0 0 0
0 0 0 0 1/4 1/4 1/4 1/4 0 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 0 1 0
0 0 0 0 0 0 0 0 0 0 1
1 0 0 0 0 0 0 0 0 0 0];
platemo('algorithm',{@NeuroEA,Blocks,Graph},'problem',@SOP_F1);
```

## NeuroEA 算法中的每个模块是模块类的一个实例。一个模块类需要被定义为 

`BLOCK` 类的子类并保存在 `PlatEMO\Algorithms\NeuroEA` 文件夹中。模块 类包含的属性与方法如下： 

|属性|赋值方式|描述|
|---|---|---|
|`parameter`|`ParameterSet()`|模块的参数|
|`lower`|构造函数|每个参数的下界|
|`upper`|构造函数|每个参数的上界|



31 

PlatEMO 用户手册 

|`output`|`Main()`|模块当前的输出种群|
|---|---|---|
|`nextOut`|`Gather()`|下个输出的解在种群中的编号|
|`trainTime`|用户|已训练次数|
|方法|是否可重定义|描述|
|构造函数|必须|设置由用户指定的属性值<br>输入：超参数的设定值<br>输出：`BLOCK`对象|
|`Main`|必须|模块的主体部分<br>输入一：`PROBLEM`对象<br>输入二：该模块的所有前驱模块<br>输入三：从每个前驱模块获取的解的比例<br>输出：无|
|`ParameterAssign`|<br>可以|根据模块的参数确定模块的属性值<br>输入：无<br>输出：无|
|`ParameterSet`|<br>不可|设置多个模块的参数<br>输入：多个模块的参数构成的向量<br>输出：无|
|`parameters`|不可|获取多个模块的参数<br>输入：无<br>输出：多个模块的参数构成的向量|
|`lowers`|不可|获取多个模块的参数的下界<br>输入：无<br>输出：所有参数的下界构成的向量|
|`uppers`|不可|获取多个模块的参数的上界<br>输入：无<br>输出：所有参数的上界构成的向量|
|`Gather`|不可|从所有前驱模块获取解<br>输入一：`PROBLEM`对象<br>输入二：该模块的所有前驱模块<br>输入三：从每个前驱模块获取的解的比例<br>输入四：获取`SOLUTION`对象还是决策变量<br>输入五：值_k_，获取的解的数目必须是_k_的倍数<br>输出：`SOLUTION`对象数组或决策变量矩阵|
|`Validity`|不可|检查NeuroEA算法的合法性<br>输入：邻接矩阵<br>输出：无|



每个模块类需要继承 `BLOCK` 类并重定义构造函数和方法 `Main()` 。例如 `Block_Mutation.m` 的代码为 

32 

四 扩展 PlatEMO 

|1|`classdef Block_Mutation < BLOCK`|
|---|---|
|2|`% Unified mutation for real variables`|
|3|`% nSets --- 5 --- Number of parameter sets`|
|4||
|5|`properties`|
|6|`nSets;`|
|7|`Weight;`|
|8|`Fit;`|
|9|`nDec = 1;`|
|10|`end`|
|11|`methods`|
|12|`function obj = Block_Mutation(nSets)`|
|13|`obj.nSets = nSets;`|
|14|`obj.lower = repmat([0 1e-20],1,nSets);`|
|15|`obj.upper = repmat([1 5],1,nSets);`|
|16|`obj.parameter = unifrnd(obj.lower,ones(1,2*nSets));`|
|17|`obj.ParameterAssign();`|
|18|`end`|
|19|`function ParameterAssign(obj)`|
|20|`obj.Weight = reshape(obj.parameter,[],obj.nSets)';`|
|21|`obj.Weight(:,end) = obj.Weight(:,end)./obj.nDec;`|
|22|`obj.Weight = [obj.Weight;0,max(0,1-sum(obj.Weight(:,end)))];`|
|23|`obj.Fit = cumsum(obj.Weight(:,end));`|
|24|`obj.Fit = obj.Fit./max(obj.Fit);`|
|25|`end`|
|26|`function Main(obj,Problem,Precursors,Ratio)`|
|27|`ParentDec = obj.Gather(Problem,Precursors,Ratio,2,1);`|
|28|`if size(ParentDec,2) ~= obj.nDec`|
|29|`obj.nDec = size(ParentDec,2);`|
|30|`obj.ParameterAssign();`|
|31|`end`|
|32|`r = ParaSampling(size(ParentDec),obj.Weight(:,1),obj.Fit);`|
|33|`obj.output = ParentDec + repmat(Problem.upper-...`|
||`Problem.lower,size(ParentDec,1),1).*r;`|
|34|`end`|
|35|`end`|
|36|`end`|



## 各行代码的功能如下： 

第 1 行： 继承 `BLOCK` 类； 第 2 行： 模块的全称； 第 3 行： 超参数名 --- 默认值 --- 超参数描述，将会显示在图形界面的模块 

33 

PlatEMO 用户手册 

设置面板中； 

第 5-10 行： 模块的特有属性； 

第 12 行： 重定义构造函数； 

第 13 行： 设置一个特有属性的值； 

第 14-15 行：设置模块参数的上下界； 

第 16 行： 随机产生模块参数； 

第 17 行： 调用方法 `ParameterAssign()` 来根据模块参数确定模块的属性值； 第 19-25 行：重定义属性值设置的方法；该方法会在方法 `ParameterSet()` 内被 自动调用； 

第 26 行： 重定义模块主体流程的方法； 

第 27 行： 从所有前驱模块获取解的决策变量矩阵； 

第 28-33 行：通过变异生成新解的决策变量矩阵；该方法会在 `NeuroEA.m` 内被 自动调用。 

平台当前提供了七种用于创建 NeuroEA 算法的模块（即 `BLOCK` 类的子类）， 包括： 

|括：|括：|
|---|---|
|模块<br>描述||
|`Block_Population`|仅用于存储解，没有任何处理过程|
|`Block_Crossover`|基于多个解的交叉产生一个新解|
|`Block_Mutation`|变异一个解|
|`Block_Exchange`|基于多个解的交换产生一个新解|
|`Block_Kopt`|翻转一个解的部分变量的顺序，主要用于序列优化|
|`Block_Tournament`|联赛选择，主要用于交配池选择|
|`Block_Selection`|保留部分解，主要用于环境选择|



这些模块及其超参数的详细介绍可参阅 该论文 。这些模块可以被任意连接以创 

建 NeuroEA 算法，但需要避免以下非法情形： 

|非法情形<br>第一个模块不是种群模块<br>图中不包含任何算子模块<br>一个模块没有前驱模块<br>一个模块没有后继模块<br>一个模块有自环|示例|
|---|---|
||Tournament<br>Population<br>Crossover<br>Mutation<br>Selection|
||Population<br>Tournament<br>Selection|
||Population<br>Tournament<br>Crossover<br>Mutation<br>Selection|
||Population<br>Tournament<br>Crossover<br>Mutation<br>Selection|
||Population<br>Tournament<br>Crossover<br>Mutation<br>Selection|



34 

四 扩展 PlatEMO 

|一个循环中没有种群模块|Population<br>Tournament<br>Crossover<br>Mutation<br>Selection|
|---|---|
|图不是强连通图|Population<br>Crossover<br>Selection<br>Population<br>Mutation|



通过调用方法 `Validity()` 可检查 NeuroEA 算法的合法性。例如以下代码检查 了一个由 `Blocks` 和 `Graph` 定义的 NeuroEA 算法的合法性，且输出由 `Validity()` 抛出的错误 `err` 中存储的非法模块信息： 

```
try
Block.Validity(Graph);
catch err
switch err.identifier
case'BLOCK:NoPopulation'
case'BLOCK:NoOperator'
case'BLOCK:NoInput'
str2num(err.cause{1}.message)
case'BLOCK:NoOutput'
str2num(err.cause{1}.message)
case'BLOCK:SelfLoop'
str2num(err.cause{1}.message)
case'BLOCK:InfLoop'
str2num(err.cause{1}.message)
case'BLOCK:Isolation'
str2num(err.cause{1}.message)
end
end
```

`BLOCK` 类的构造函数的输入是模块的超参数，它们决定了模块的一些特有 属性的值。此外，属性 `parameter` 存储了模块的参数，它们也决定了一些特有 属性的值且可以被训练以显著提升算法的性能。训练过程可以在 创造模块 中或 使用以下代码实现： 

```
addpath('Algorithms\NeuroEA');
Blocks = [Block_Population
            Block_Tournament(200,10)
            Block_Crossover(2,5)
Block_Mutation(5)
            Block_Selection(100)];
Graph = [0 1 0 0 1
           0 0 1 0 0
```

35 

PlatEMO 用户手册 

```
           0 0 0 1 0
           0 0 0 0 1
           1 0 0 0 0];
function y = Fcn(x,data)
data{1}.ParameterSet(x);
for i = 1 : 3
[~,obj] = platemo('algorithm',...
{@NeuroEA,data{1},data{2}},...
'problem',@SOP_F1,...
'outputFcn',@(~,~)[]);
s(i) = min(obj);
end
y = mean(s);
end
platemo('algorithm',@GA,'objFcn',@Fcn,...
'lower',Blocks.lowers,...
'upper',Blocks.uppers,...
'D',length(Blocks.lowers),...
'data',{Blocks,Graph},'N',30,'save',1);
```

以上代码将 NeuroEA 算法的训练视为一个优化问题并利用 `@GA` 求解，其中决策 变量是所有模块的参数，目标函数 `Fcn()` 定义为该 NeuroEA 算法在 `@SOP_F1` 上 三次优化性能的平均值。 

36 

五 算法列表 

## 五 算法列表 

|1<br>2<br>3<br>4<br>5<br>6<br>7<br>8<br>9<br>10 <br>11 <br>12 <br>13 <br>14 <br>15 <br>16 <br>17 <br>18 <br>19 <br>20 <br>21 <br>22 <br>23 <br>24|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||ABC|Artificial bee colony algorithm|√|||√|√||||√|√||||||||
||AB-SAEA|Adaptive Bayesian based surrogate-assisted<br>evolutionaryalgorithm||√|√|√|√||||||√|||||||
||AC-MMEA|Adaptive merging and coordinated offspring<br>generation based multi-modal multi-objective<br>evolutionaryalgorithm||√||√|√||||√|||√|√|||||
||ACO|Ant colony optimization|√|||||||√|√|||||||||
||Adam|Adaptive moment estimation|√|||√|||||√|||||||||
||AdaW|Evolutionary algorithm with adaptive weights||√|√|√|√|√|√|√||||||||||
||ADSAPSO|Adaptive dropout based surrogate-assisted<br>particle swarm optimization||√|√|√|√||||||√|||||||
||AE-NSGA-II|Autoencoding NSGA-II||√||√|√|√|√|√||√||||√||||
||AESSPSO|Adaptive exploration state-space particle<br>swarm optimization|√|||√|√||||√|√||||||||
||AFSEA|Adjoint feature-selection-based evolutionary<br>algorithm||√||√|√||√||√|√|||√|||||
||AGE-II|Approximation-guided evolutionary multi-<br>objective algorithm II||√||√|√|√|√|√||||||||||
||AGE-MOEA|Adaptive geometry estimation-based many-<br>objective evolutionaryalgorithm||√|√|√|√|√|√|√||√||||||||
||AGE-MOEA-II|Adaptive geometry estimation-based many-<br>objective evolutionaryalgorithm II||√|√|√|√|√|√|√||√||||||||
||AGSEA|Automated guiding vector selection-based<br>evolutionaryalgorithm||√||√|√||√||√|√|||√|||||
||AMG-PSL|Adaptive multi-granular Pareto-optimal<br>subspace learning||√||√|√||√||√|√|||√|||||
||A-NSGA-III|Adaptive NSGA-III||√|√|√|√|√|√|√||√||||||||
||APSEA|Adaptive population sizing based<br>evolutionaryalgorithm||√||√|√|√|√|√||√||||||||
||AR-MOEA|Adaptive reference points based multi-<br>objective evolutionaryalgorithm||√|√|√|√|√|√|√||√||||||||
||AutoV|Automated design of variation operators|√|√||√|√||||√|√||||||||
||AVG-SAEA|Adaptive variable grouping based surrogate-<br>assisted evolutionaryalgorithm||√||√|√||||√||√|||||||
||BCE-IBEA|Bi-criterion evolution based IBEA||√|√|√|√|√|√|√||||||||||
||BCE-MOEA/D|Bi-criterion evolution based MOEA/D||√|√|√|√|√|√|√||||||||||
||BFGS|A quasi-Newton method proposed by<br>Broyden,Fletcher,Goldfarb,and Shanno|√|||√|||||√|||||||||
||BiCo|Bidirectional coevolution constrained<br>multiobjective evolutionaryalgorithm||√||√|√|√|√|√||√||||||||



37 

## PlatEMO 用户手册 

|25 <br>26 <br>27 <br>28 <br>29 <br>30 <br>31 <br>32 <br>33 <br>34 <br>35 <br>36 <br>37 <br>38 <br>39 <br>40 <br>41 <br>42 <br>43 <br>44 <br>45 <br>46 <br>47 <br>48 <br>49 <br>50 <br>51|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||BiGE|Bi-goal evolution|||√|√|√|√|√|√||||||||||
||BLEAQII|Bilevel evolutionary algorithm based on<br>quadratic approximations II||√||√||||||√||||||√||
||BL-SAEA|Bi-level surrogate modelling based<br>evolutionaryalgorithm||√||√||||||√||||||√||
||BSPGA|Binary space partition tree based genetic algorithm|√||||||√||√|√||||||||
||C3M|Constraint, multiobjective, multi-stage,<br>multi-constraint evolutionaryalgorithm||√||√|√|√|√|√||√||||||||
||CAEAD|Dual-population evolutionary algorithm based on<br>alternative evolution and degeneration||√||√|√|√|√|√||√||||||||
||CA-MOEA|Clustering based adaptive multi-objective<br>evolutionaryalgorithm||√||√|√|√|√|√||||||||||
||CCGDE3|Cooperative coevolution GDE3||√||√|√||||√|||||||||
||CCMO|Coevolutionary constrained multi-objective<br>optimization framework||√||√|√|√|√|√||√||||||||
||c-DPEA|Constrained dual-population evolutionary algorithm||√||√|√|√|√|√||√||||||||
||CGLP|Correlation-guided layered prediction||√||√|√|√|√|√||||||√||||
||CI-EMO|Composite indicator-guided infilling sampling for<br>expensive multi-objective optimization||√|√|√|||||||√|||||||
||CLIA|Evolutionary algorithm with cascade clustering<br>and referencepoint incremental learning||√|√|√|√|√|√|√||||||||||
||CMaDPPs|Constrained many-objective optimization<br>with determinantalpointprocesses||√|√|√|√|√|√|√||√||||||||
||CMA-ES|Covariance matrix adaptation evolution strategy|√|||√|√||||√|√||||||||
||CMDEIPCM|Constrained multiobjective differential<br>evolution algorithm with an infeasible<br>proportion control mechanism||√||√|√||||√|√||||||||
||CMEGL|Constrained evolutionary multitasking with<br>global and local auxiliarytasks||√||√|√|√|√|√||√||||||||
||CMME|Constrained many-objective evolutionary algorithm with<br>enhanced matingand environmental selections||√||√|√|√|√|√||√||||||||
||CMMO|Coevolutionary multi-modal multi-objective<br>optimization framework||√||√|√|√|√|√||||√||||||
||CMOBR|Constrained multiobjective optimization via<br>both constraint and objective relaxations||√|√|√|√|||||√||||||||
||CMOCSO|Competitive and cooperative swarm optimization<br>constrained multi-objective optimization algorithm||√||√|||||√|√||||||||
||CMODE-FTR|Constrained multiobjective differential<br>evolution based on the fusion of two rankings||√||√|√|||||√||||||||
||CMODRL|Constrained multiobjective optimization via<br>deepreinforcement learning||√||√|√|√|√|√||√||||||||
||CMOEA-2S|Constrained MOEA with two types of<br>evolution stages||√||√||||||√||||||||
||CMOEA-AOP|Automated operator portfolio based<br>constrained MOEA||√||√|√|√|√|√||√||||||||
||CMOEA-CD|Constraint-Pareto dominance and diversity<br>enhancement strategybased constrained MOEA||√|√|√|√|√|√|√||√||||||||
||C-MOEA/D|Constraint-MOEA/D||√|√|√|√|√|√|√||√||||||||



38 

五 算法列表 

|52 <br>53 <br>54 <br>55 <br>56 <br>57 <br>58 <br>59 <br>60 <br>61 <br>62 <br>63 <br>64 <br>65 <br>66 <br>67 <br>68 <br>69 <br>70 <br>71 <br>72 <br>73 <br>74 <br>75 <br>76 <br>77 <br>78|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||CMOEA-MS|Constrained multiobjective evolutionary<br>algorithm with multiple stages||√||√|√|√|√|√||√||||||||
||CMOEA-MSG|Multi-stage constrained multi-objective<br>evolutionaryalgorithm||√||√|√|||||√||||||||
||CMOEBOD|Constrained multiobjective evolutionary Bayesian<br>optimization based on decomposition||√|√|√||||||√|√|||||||
||CMOEMT|Constrained multi-objective optimization based on<br>evolutionarymultitaskingoptimization||√||√||||||√||||||||
||CMOES|Constrained multi-objective optimization<br>based on even search||√||√|√|√|√|√||√||||||||
||CMOPSO|Competitive mechanism based multi-<br>objectiveparticle swarm optimizer||√||√|√|||||||||||||
||CMOQLMT|Constrained multi-objective optimization<br>based onQ-learningand multitasking||√||√||||||√||||||||
||CMOSMA|Constrained multi-objective evolutionary<br>algorithm with self-organizingmap||√|√|√|√|||||√||||||||
||CNSDE/DVC|Constrained nondominated sorting differential<br>evolution based on decision variable classification||√||√|√||||||||||||√|
||CoMMEA|Coevolutionary multimodal multi-objective<br>evolutionaryalgorithm||√||√|√|√|√|√||||√||||||
||CPS-MOEA|Classification and Pareto domination based<br>multi-objective evolutionary||√||√|√||||||√|||||||
||CSEA|Classification based surrogate-assisted<br>evolutionaryalgorithm||√|√|√|||||||√|||||||
||CSEMT|Constraints separation based evolutionary<br>multitasking||√||√|√|√|√|√||√||||||||
||CSO|Competitive swarm optimizer|√|||√|√||||√|√||||||||
||C-TAEA|Two-archive evolutionary algorithm for<br>constrained MOPs||√|√|√|√|√|√|√||√||||||||
||C-TSEA|Constrained two-stage evolutionary algorithm||√|√|√|√|√|√|√||√||||||||
||DAEA|Duplication analysis based evolutionary algorithm||√|||||√|||||||||||
||DBEMTO|Double-balanced evolutionary multi-task<br>optimization||√||√|√|√|√|√||√||||||||
||DCNSGA-III|Dynamic constrained NSGA-III||√|√|√|√|√|√|√||√||||||||
||DE|Differential evolution|√|||√|√||||√|√||||||||
||DEA-GNG|Decomposition based evolutionary algorithm<br>guided by growingneuralgas||√|√|√|√|√|√|√||||||||||
||DGEA|Direction guided evolutionary algorithm||√|√|√|√||||√|||||||||
||DirHV-EI|Expected direction-based hypervolume improvement||√|√|√|√||||||√|||||||
||DISK|Distribution-based Kriging-assisted<br>evolutionaryalgorithm||√|√|√|√||||||√|||||||
||DISKplus|Distribution-based Kriging-assisted<br>constrained evolutionaryalgorithm||√|√|√|√|||||√|√|||||||
||DKCA|Dynamic knowledge-guided coevolutionary<br>algorithm||√||√|||√||√|√|||√|||||
||DM-MOEA|Dual model based multi-objective<br>evolutionaryalgorithm||√||√|√||√||√|√|||√|√||||



39 

## PlatEMO 用户手册 

|79 <br>80 <br>81 <br>82 <br>83 <br>84 <br>85 <br>86 <br>87 <br>88 <br>89 <br>90 <br>91 <br>92 <br>93 <br>94 <br>95 <br>96 <br>97 <br>98 <br>99 <br>100 <br>101 <br>102 <br>103 <br>104 <br>105 <br>106 <br>107|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||DMOEA-eC|Decomposition-based multi-objective evolutionary<br>algorithm with the e-constraint framework||√||√|√|√|√|√||||||||||
||dMOPSO|MOPSO based on decomposition||√||√|√|||||||||||||
||DN-NSGA-II|Decision space based niching NSGA-II||√||√|√|||||||√||||||
||DNSGA-II|Dynamic NSGA-II||√||√|√|√|√|√||||||√||||
||DOA|Dandelion optimization algorithm|√|||√|√||||√|√||||||||
||DPCPRA|Dual-population with dynamic constraint<br>processingand resource allocating||√||√|√|√|√|√||√||||||||
||DP-PPS|Tri-population based push and pull search||√||√||||||√||||||||
||DPVAPS|Dual-population with variable auxiliary<br>population size||√||√|√||||√|√||||||||
||DRLOS-<br>EMCMO|EMCMO with deep reinforcement learning-<br>assisted operator selection||√||√|√|√|√|√||√||||||||
||DRL-SAEA|Deep reinforcement learning-based<br>expensive constrained evolutionaryalgorithm||√||√||||||√|√|||||||
||DSPCMDE|Dynamic selection preference-assisted constrained<br>multiobjective differential evolution||√||√|√|||||√||||||||
||DSSEA|Dynamic subspace search-based evolutionary<br>algorithm||√|√|√|√||||√|√||||||||
||DVCEA|Decision variables classification-based<br>evolutionaryalgorithm||√|√|√|√||||√|√||||||||
||DWU|Dominance-weighted uniformity multi-<br>objective evolutionaryalgorithm||√||√|√|√|√|√||||||||||
||EAG-MOEA/D|<br>External archive guided MOEA/D||√||√|√|√|√|√||||||||||
||ECPO|Electric charged particles optimization|√|||√|√||||√|√||||||||
||EDN-ARMOEA|Efficient dropout neural network based AR-MOEA||√|√|√|√||||||√|||||||
||EFR-RR|Ensemble fitness ranking with a ranking<br>restriction scheme||√|√|√|√|√|√|√||||||||||
||EGES|Efficient grouping evolutionary search||√|√|√|||||√||√|||||||
||EGO|Efficient global optimization|√|||√|√||||||√|||||||
||EIM-EGO|Expected improvement matrix based efficient<br>global optimization||√||√|√||||||√|||||||
||EMCMMS|Evolutionary multitasking with a cooperative<br>multistepmutation strategy||√||√|√|√|√|√||√||||||||
||EMCMO|Evolutionary multitasking-based constrained<br>multiobjective optimization||√||√|√|√|√|√||√||||||||
||EMMOEA|Expensive multi-/many-objective<br>evolutionaryalgorithm||√||√|√||||||√|||||||
||e-MOEA|Epsilon multi-objective evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||EMOSKT|Evolutionary multi-objective optimization<br>with sparsityknowledge transfer||√||√|||√||√|√|||√||√|||
||EM-SAEA|Ensemble-based surrogate model-assisted<br>evolutionaryalgorithm||√|√|√||||||√|√|||||||
||EMyO/C|Evolutionary many-objective optimization<br>algorithm with clustering-based||√|√|√|√|||||||||||||
||ENS-MOEA/D|Ensemble of different neighborhood sizes||√|√|√|√|||||||||||||



40 

五 算法列表 

|108 <br>109 <br>110 <br>111 <br>112 <br>113 <br>114 <br>115 <br>116 <br>117 <br>118 <br>119 <br>120 <br>121 <br>122 <br>123 <br>124 <br>125 <br>126 <br>127 <br>128 <br>129 <br>130 <br>131 <br>132 <br>133 <br>134 <br>135 <br>136|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||based MOEA/D||||||||||||||||||
||ESBCEO|Bayesian co-evolutionary optimization based<br>entropysearch||√||√|||||||√|||||||
||FDV|Fuzzy decision variable framework with<br>various internal optimizers||√|√|√|√||||√|||||||||
||FEP|Fast evolutionary programming|√|||√|√||||√|√||||||||
||FLEA|Fast sampling based evolutionary algorithm||√|√|√|||||√|||||||||
||FRCG|Fletcher-Reeves conjugate gradient|√|||√|||||√|||||||||
||FRCGM|Fletcher-Reeves conjugate gradient (for<br>multi-objective optimization)||√|√|√|||||√|√||||||||
||FROFI|Feasibility rule with the incorporation of<br>objective function information|√|||√|√||||√|√||||||||
||GA|Genetic algorithm|√|||√|√|√|√|√|√|√||||||||
||GCNMOEA|Graph convolutional network based multi-<br>objective evolutionaryalgorithm||√||√|√|||||||||||||
||GDE3|Generalized differential evolution 3||√||√|√|||||√||||||||
||GDVTSF|Generational difference vector based tri-<br>entropystructure framework||√||√|||||√|||||||||
||GFM-MOEA|Generic front modeling based multi-objective<br>evolutionaryalgorithm||√|√|√|√|√|√|√||||||||||
||GLMO|Grouped and linked mutation operator algorithm||√||√|√||||√|||||||||
||g-NSGA-II|g-dominance based NSGA-II||√||√|√|√|√|√||||||||||
||GPSO|Gradient based particle swarm optimization<br>algorithm|√|||√|||||√|√||||||||
||GPSOM|Gradient based particle swarm optimization<br>algorithm(for multi-objective optimization)||√|√|√|||||√|√||||||||
||GrEA|Grid-based evolutionary algorithm|||√|√|√|√|√|√||||||||||
||GWASF-GA|Global weighting achievement scalarizing<br>functiongenetic algorithm||√||√|√|√|√|√||||||||||
||GWO|Grey wolf optimizer|√|||√|√||||√|√||||||||
||HEA|Hyper-dominance based evolutionary algorithm||√|√|√|||√|√||||||||||
||HeE-MOEA|Multiobjective evolutionary algorithm with<br>heterogeneous ensemble based infill criterion||√||√|√||||||√|||||||
||HHC-MMEA|Hybrid hierarchical clustering based multi-<br>modal multi-objective evolutionaryalgorithm||√||√|||||√|||√|√|||||
||hpaEA|Hyperplane assisted evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||HREA|Hierarchy ranking based evolutionary algorithm||√||√|√|||||||√||||||
||HypE|Hypervolume estimation algorithm||√|√|√|√|√|√|√||||||||||
||IBEA|Indicator-based evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||ICMA|Indicator based constrained multi-objective<br>algorithm||√||√|√|||||√||||||||
||I-DBEA|Improved decomposition-based evolutionary<br>algorithm||√|√|√|√|√|√|√||√||||||||
||ILCMO|Indicator-based evolutionary algorithm for large-<br>scale constrained multi-objective optimization||√|√|√|√||||√|√||||||||



41 

## PlatEMO 用户手册 

|137 <br>138 <br>139 <br>140 <br>141 <br>142 <br>143 <br>144 <br>145 <br>146 <br>147 <br>148 <br>149 <br>150 <br>151 <br>152 <br>153 <br>154 <br>155 <br>156 <br>157 <br>158 <br>159 <br>160 <br>161 <br>162 <br>163 <br>164 <br>165|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||IM-C-MOEA/D|Inverse modeling constrained MOEA/D||√||√|√||||√|√||||||||
||IM-MOEA|Inverse modeling based multiobjective<br>evolutionaryalgorithm||√||√|√||||√|||||||||
||IM-MOEA/D|Inverse modeling MOEA/D||√||√|√||||√|||||||||
||IMODE|Improved multi-operator differential evolution|√|||√|√||||√|√||||||||
||IMTCMO|Improved evolutionary multitasking-based CMOEA||√||√|√|√|√|√||√||||||||
||IMTCMO_BS|Improved evolutionary multitasking-based<br>CMOEA with bidirectional sampling||√|√|√|√|√|√|√||√||||||||
||I-SIBEA|Interactive simple indicator-based<br>evolutionaryalgorithm||√||√|√|√|√|√||||||||||
||Izui|An aggregative gradient based multi-<br>objective optimizerproposed byIzui et al.||√|√|√|||||√|√||||||||
||KLEA|Knowledge learning-based evolutionary algorithm||√||√|√||√||√|√|||√|||||
||KL-NSGA-II|Knowledge learning based NSGA-II||√||√|√|√|√|√||√||||√||||
||KMA|Komodo mlipir algorithm|√|||√|√||||√|√||||||||
||KnEA|Knee point driven evolutionary algorithm|||√|√|√|√|√|√||√||||||||
||K-RVEA|Surrogate-assisted RVEA||√|√|√|√||||||√|||||||
||KTA2|Kriging-assisted Two_Arch2||√|√|√|√||||||√|||||||
||KTS|Kriging-assisted evolutionary algorithm with<br>two search modes||√|√||√|||||√|√|||||||
||L2SMEA|Linear subspace surrogate modeling assisted<br>evolutionaryalgorithm|√|||√|||||||√|||||||
||LCMEA|Large-scale constrained multi-objective<br>evolutionaryalgorithm||√||√|||||√|√||||||||
||LCSA|Linear combination-based search algorithm||√|√|√|√||||√|||||||||
||LDS-AF|Low-dimensional surrogate aggregation function||√||√|√||||√||√|||||||
||LERD|Large-scale evolutionary algorithm with<br>reformulated decision variable analysis||√|√|√|||||√|||||||||
||LMEA|Evolutionary algorithm for large-scale many-<br>objective optimization||√|√|√|√||||√|||||||||
||LMOCSO|Large-scale multi-objective competitive<br>swarm optimization algorithm||√|√|√|√||||√|√||||||||
||LMOEA-DS|Large-scale evolutionary multi-objective<br>optimization assisted bydirected sampling||√||√|√||||√|||||||||
||LMPFE|Evolutionary algorithm with local model<br>based Pareto front estimation||√|√|√|√|√|√|√||||||||||
||LRMOEA|Large-scale robust multi-objective<br>evolutionaryalgorithm||√||√|||√||√|√|||√||||√|
||LSMOF|Large-scale multi-objective optimization<br>framework with NSGA-II||√||√|√||||√|||||||||
||MaOEA-CSS|Many-objective evolutionary algorithms<br>based on coordinated selection||√|√|√|√|√|√|√||||||||||
||MaOEA-DDFC|Many-objective evolutionary algorithm based on<br>directional diversityand favorable convergence||√|√|√|√|√|√|√||||||||||
||MaOEA-HAP|Hyper-curvature balanced indicator and||√|√|√|√|√|√|√||||||||||



42 

五 算法列表 

|166 <br>167 <br>168 <br>169 <br>170 <br>171 <br>172 <br>173 <br>174 <br>175 <br>176 <br>177 <br>178 <br>179 <br>180 <br>181 <br>182 <br>183 <br>184 <br>185 <br>186 <br>187 <br>188 <br>189 <br>190 <br>191 <br>192 <br>193|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||adaptive phase exploration co-driven many-<br>objective evolutionaryalgorithm||||||||||||||||||
||MaOEA/IGD|IGD based many-objective evolutionary algorithm|||√|√|√|√|√|√||||||||||
||MaOEA/IT|Many-objective evolutionary algorithms<br>based on an independent two-stage||√|√|√|√|||||√||||||||
||MaOEA-R&D|Many-objective evolutionary algorithm based<br>on objective space reduction|||√|√|√|√|√|√||||||||||
||MCCMO|Multi-population coevolutionary constrained<br>multi-objective optimization||√||√|√|√|√|√||√||||||||
||MCEA/D|Multiple classifiers-assisted evolutionary<br>algorithm based on decomposition||√|√|√|√||||||√|||||||
||MFEA|Multifactorial evolutionary algorithm|√|||√|√|√|√|√|√||||||√|||
||MFEA-II|Multifactorial evolutionary algorithm II|√|||√|√|√|√|√|√||||||√|||
||MFFS|Multiform feature selection||√|||||√|||||||||||
||MFO-SPEA2|Multiform optimization framework based on SPEA2||√||√|√|√|√|√||√||||||||
||MGCEA|Multi-granularity clustering based<br>evolutionaryalgorithm||√||√|||√||√|√|||√|||||
||MGO|Mountain gazelle optimizer|√|||√|√||||√|√||||||||
||MGSAEA|Multigranularity surrogate-assisted<br>constrained evolutionaryalgorithm||√||√||||||√|√|||||||
||MiSACO|Multi surrogate-assisted ant colony optimization|√|||√|√||||||√|||||||
||MMEA-ARM|Adaptive resource management based MMEA||√||√|√||√||√|||√|√|||||
||MMEAPSL|Multimodal multi-objective evolutionary<br>algorithm assisted byPareto set learning||√||√|√|√|√|√||||√||||||
||MMEA-WI|Weighted indicator-based evolutionary algorithm<br>for multimodal multi-objective optimization||√||√|√|||||||√||||||
||MMOEA-BH|Multimodal MOEA with block optimization<br>and hybrid clustering||√||√|√|√|√|√||||√||||||
||MMOPSO|MOPSO with multiple search strategies||√||√|√|||||||||||||
||MO_Ring_<br>PSO_SCD|Multiobjective PSO using ring topology and<br>special crowdingdistance||√||√|√|||||||√||||||
||MOBCA|Multi-objective besiege and conquer algorithm||√||√|√|||||||||||||
||MOCell|Cellular genetic algorithm||√||√|√|√|√|√||√||||||||
||MOCGDE|Multi-objective conjugate gradient and<br>differential evolution algorithm||√|√|√|||||√|√||||||||
||MO-CMA|Multi-objective covariance matrix adaptation<br>evolution strategy||√||√|√|||||||||||||
||MOEA/CKF|Multi-objective evolutionary algorithm based<br>on cross-scale knowledge fusion||√||√|||√||√|√|||√|||||
||MOEA/D|Multiobjective evolutionary algorithm based<br>on decomposition||√|√|√|√|√|√|√||||||||||
||MOEA/D-2WA|MOEA/D with two-type weight vector adjustments||√|√|√|√|√|√|√||√||||||||
||MOEA/D-AWA|MOEA/D with adaptive weight adjustment||√|√|√|√|√|√|√||||||||||
||MOEA/D-CMA|MOEA/D with covariance matrix adaptation<br>evolution strategy||√|√|√|√|||||||||||||



43 

## PlatEMO 用户手册 

|194 <br>195 <br>196 <br>197 <br>198 <br>199 <br>200 <br>201 <br>202 <br>203 <br>204 <br>205 <br>206 <br>207 <br>208 <br>209 <br>210 <br>211 <br>212 <br>213 <br>214 <br>215 <br>216 <br>217 <br>218 <br>219 <br>220 <br>221 <br>222|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||MOEA/D-CMT|MOEA/D with competitive multitasking||√||√||||||√||||||||
||MOEA/DD|Many-objective evolutionary algorithm based<br>on dominance and decomposition||√|√|√|√|√|√|√||√||||||||
||MOEA/D-DAE|<br>MOEA/D with detect-and-escape strategy||√||√|√|√|√|√||√||||||||
||MOEA/D-<br>DCWV|MOEA/D with distribution control of weight<br>vector set||√|√|√|√|√|√|√||||||||||
||MOEA/D-DE|MOEA/D based on differential evolution||√|√|√|√|||||||||||||
||MOEA/D-DQN|<br>MOEA/D based on deep Q-network||√|√|√|√|||||||||||||
||MOEA/D-DRA|MOEA/D with dynamical resource allocation||√|√|√|√|||||||||||||
||MOEA/D-DU|MOEA/D with a distance based updating strategy||√|√|√|√|√|√|√||||||||||
||MOEA/D-<br>DYTS|MOEA/D with dynamic Thompson sampling||√|√|√|√|||||||||||||
||MOEA/D-EGO|MOEA/D with efficient global optimization||√||√|√||||||√|||||||
||MOEA/D-<br>FRRMAB|MOEA/D with fitness-rate-rank-based<br>multiarmed bandit||√|√|√|√|||||||||||||
||MOEA/D-<br>M2M|MOEA/D based on MOP to MOP||√||√|√|||||||||||||
||MOEA/D-<br>MRDL|MOEA/D with maximum relative diversity loss||√||√|√|||||||||||||
||MOEA/D-PaS|MOEA/D with Pareto adaptive scalarizing<br>approximation||√|√|√|√|||||||||||||
||MOEA/D-PFE|MOEA/D with Pareto front estimation||√|√|√|√|√|√|√||||||||||
||MOEA/D-STM|<br>MOEA/D with stable matching||√|√|√|√|||||||||||||
||MOEA/D-UR|MOEA/D with update when required||√|√|√|√|√|√|√||||||||||
||MOEA/D-<br>URAW|MOEA/D with uniform randomly adaptive weights||√|√|√|√|√|√|√||||||||||
||MOEA/DVA|Multi-objective evolutionary algorithm based<br>on decision variable||√||√|√||||√|||||||||
||MOEA/D-VOV|<br>MOEA/D with virtual objective vectors||√|√|√|√|√|√|√||||||||||
||MOEA-IB|MOEA with information bottleneck||√|√|√|||||√|||||||||
||MOEA/IGD-<br>NS|Multi-objective evolutionary algorithm based<br>on an enhanced IGD||√||√|√|√|√|√||||||||||
||MOEA-NZD|Multi-objective evolutionary algorithm with<br>nonzero detection||√|√|√|||||√|√|||√|||||
||MOEA-PC|Multiobjective evolutionary algorithm based<br>onpolar coordinates||√||√|√|||||||||||||
||MOEA/PSL|Multi-objective evolutionary algorithm based<br>on Pareto optimal subspace||√||√|√||√||√|√|||√|||||
||MOEA-RE|Multi-objective evolutionary algorithm with<br>robustness enhancement||√||√|√|√|√|√|||||||||√|
||MO-EGS|Multi-objective evolutionary gradient search||√||√|||||√|||||||||
||MO-L2SMEA|Multi-objective linear subspace surrogate<br>modelingassisted evolutionaryalgorithm||√||√|||||√||√|||||||
||MOMBI-II|Many objective metaheuristic based on the<br>R2 indicator II||√|√|√|√|√|√|√||||||||||



44 

五 算法列表 

|223 <br>224 <br>225 <br>226 <br>227 <br>228 <br>229 <br>230 <br>231 <br>232 <br>233 <br>234 <br>235 <br>236 <br>237 <br>238 <br>239 <br>240 <br>241 <br>242 <br>243 <br>244 <br>245 <br>246 <br>247 <br>248 <br>249 <br>250 <br>251|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||MO-MFEA|Multi-objective multifactorial evolutionary algorithm||√||√|√|√|√|√||√|||||√|||
||MO-MFEA-II|Multi-objective multifactorial evolutionary<br>algorithm II||√||√|√|√|√|√||√|||||√|||
||MOMFEA-<br>SADE|Multi-objective multifactorial evolutionary<br>algorithm with subspace alignment and<br>adaptive differential evolution||√||√|√|√|√|√||√|||||√|||
||MONAS|Multi-objective neural architecture search||√||√|√|√|√|√||||√||||||
||MOPSO|Multi-objective particle swarm optimization||√||√|√|||||||||||||
||MOPSO-CD|MOPSO with crowding distance||√||√|√|||||||||||||
||MOSD|Multiobjective steepest descent||√||√|||||√|√||||||||
||M-PAES|Memetic algorithm with Pareto archived<br>evolution strategy||√||√|√|||||||||||||
||MP-MMEA|Multi-population multi-modal multi-<br>objective evolutionaryalgorithm||√||√|√||||√|||√|√|||||
||MPSO/D|Multi-objective particle swarm optimization<br>algorithm based on decomposition||√|√|√|√|||||||||||||
||MSCEA|Multi-stage constrained multi-objective<br>evolutionaryalgorithm||√||√|√|√|√|√||√||||||||
||MSCMO|Multi-stage constrained multi-objective<br>evolutionaryalgorithm||√||√|√|√|√|√||√||||||||
||MSEA|Multi-stage multi-objective evolutionary algorithm||√||√|√|√|√|√||||||||||
||MSKEA|Multi-stage knowledge-guided evolutionary<br>algorithm||√||√|√||√||√|√|||√|||||
||MSOPS-II|Multiple single objective Pareto sampling II||√|√|√|√|||||√||||||||
||MTCMO|Multitasking constrained multi-objective<br>optimization||√||√|√|√|√|√||√||||||||
||MTDE-MKTA|Multitasking differential evolution with multiple<br>knowledge types and transfer adaptation||√||√|√|√|√|√||√|||||√|||
||MTEA/D-DN|Multiobjective multitask evolutionary algorithm<br>based on decomposition with dual neighborhoods||√||√|√|√|√|√||√|||||√|||
||MTS|Multiple trajectory search||√||√|√|||||||||||||
||MultiObjective<br>EGO|Multi-objective efficient global optimization||√||√|√|||||√|√|||||||
||MVPA|Most valuable player algorithm|√|||√|√||||√|√||||||||
||MyO-DEMR|Many-objective differential evolution with<br>mutation restriction||√|√|√|√|||||||||||||
||NBLEA|Nested bilevel evolutionary algorithm||√||√||||||√||||||√||
||NelderMead|The Nelder-Mead algorithm|√|||√||||||||||||||
||NMPSO|Novel multi-objective particle swarm optimization||√|√|√|√|||||||||||||
||NNDREA-MO|Evolutionary algorithm with neural network-based<br>dimensionalityreduction(multi-objective)||√|||||√||√|√|||√|||||
||NNDREA-SO|Evolutionary algorithm with neural network-based<br>dimensionalityreduction(single-objective)|<br>√||||||√||√|√|||√|||||
||NNIA|Nondominated neighbor immune algorithm||√||√|√|√|√|√||||||||||
||NRV-MOEA|Adaptive normal reference vector-based multi-<br>and many-objective evolutionaryalgorithm||√|√|√|√|√|√|√||||||||||



45 

## PlatEMO 用户手册 

|252 <br>253 <br>254 <br>255 <br>256 <br>257 <br>258 <br>259 <br>260 <br>261 <br>262 <br>263 <br>264 <br>265 <br>266 <br>267 <br>268 <br>269 <br>270 <br>271 <br>272 <br>273 <br>274 <br>275 <br>276 <br>277 <br>278 <br>279 <br>280|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||NSBiDiCo|Non-dominated sorting bidirectional<br>differential coevolution algorithm||√||√|√|√|√|√||√||||||||
||NSGA-II|Nondominated sorting genetic algorithm II||√||√|√|√|√|√||√||||||||
||NSGA-II+ARSBX|NSGA-II with adaptive rotation based<br>simulated binarycrossover||√||√|√|||||√||||||||
||NSGA-II-<br>conflict|NSGA-II with conflict-based partitioning strategy|||√|√|√|√|√|√||||||||||
||NSGA-II-DTI|NSGA-II of Deb's type I robust version||√||√|√|√|√|√||√|||||||√|
||NSGA-III|Nondominated sorting genetic algorithm III||√|√|√|√|√|√|√||√||||||||
||NSGAIII-EHVI|NSGA-III with expected hypervolume improvement||√|√|√|||||||√|||||||
||NSGA-II/SDR|NSGA-II with strengthened dominance relation|||√|√|√|√|√|√||||||||||
||NSLS|Multiobjective optimization framework based on<br>nondominated sortingand local search||√||√|√|||||||||||||
||NUCEA|Non-uniform clustering based evolutionary algorithm||√||√|||√||√|√|||√|||||
||OFA|Optimal foraging algorithm|√|||√|√||||√|√||||||||
||one-by-one EA|Many-objective evolutionary algorithm using<br>a one-by-one selection||√|√|√|√|√|√|√||||||||||
||OSP-NSDE|Non-dominated sorting differential evolution<br>withprediction in the objective space||√||√|√|||||||||||||
||ParEGO|Efficient global optimization for Pareto optimization||√||√|√||||||√|||||||
||PB-NSGA-III|NSGA-III based on Pareto based bi-indicator<br>infill samplingcriterion||√|√|√|√||||||√|||||||
||PB-RVEA|RVEA based on Pareto based bi-indicator<br>infill samplingcriterion||√|√|√|√||||||√|||||||
||PC-SAEA|Pairwise comparison based surrogate-assisted<br>evolutionaryalgorithm||√|√||||||||√|||||||
||PEA|Pareto-based Kriging-assisted constrained<br>multiobjective evolutionaryalgorithm||√||√|√|||||√|√|||||||
||PEAplus|Pareto-based Kriging-assisted constrained<br>multiobjective evolutionaryalgorithmplus||√||√|√|||||√|√|||||||
||PeEA|Pareto front shape estimation based<br>evolutionaryalgorithm||√|√|√|√|√|√|√||||||||||
||PESA-II|Pareto envelope-based selection algorithm II||√||√|√|√|√|√||||||||||
||PICEA-g|Preference-inspired coevolutionary algorithm<br>withgoals||√|√|√|√|√|√|√||||||||||
||PIEA|Performance indicator-based evolutionary algorithm||√|√|√|||||||√|||||||
||PIMD|Probability and mapping crowding distance||√|√|√|||||||√|||||||
||PM-MOEA|Pattern mining based multi-objective<br>evolutionaryalgorithm||√||√|√||√||√|√|||√|||||
||POCEA|Paired offspring generation based constrained<br>evolutionaryalgorithm||√||√|√||||√|√||||||||
||PPS|Push and pull search algorithm||√|√|√|√|||||√||||||||
||PRCEA|Promising region-guided large-scale<br>constrained MOEA||√|√|√|√||||√|√||||||||
||PRDH|Problem reformulation and duplication handling||√|||||√|||||||||||



46 

五 算法列表 

|281 <br>282 <br>283 <br>284 <br>285 <br>286 <br>287 <br>288 <br>289 <br>290 <br>291 <br>292 <br>293 <br>294 <br>295 <br>296 <br>297 <br>298 <br>299 <br>300 <br>301 <br>302 <br>303 <br>304 <br>305 <br>306 <br>307 <br>308 <br>309 <br>310|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||PREA|Promising-region based EMO algorithm||√|√|√|√|√|√|√||||||||||
||PSO|Particle swarm optimization|√|||√|√||||√|√||||||||
||REMO|Expensive multiobjective optimization by<br>relation learningandprediction||√|√|√|||||||√|||||||
||RGA-M1-2|Real-coded genetic algorithm with<br>framework M1-2||√||√||||||√|√|||||||
||RGA-M2-2|Real-coded genetic algorithm with<br>framework M2-2||√||√||||||√|√|||||||
||RM-MEDA|Regularity model-based multiobjective<br>estimation of distribution||√||√|√|||||||||||||
||RMOEA/DVA|Robust multi-objective evolutionary<br>algorithm with decision variable assortment||√||√|√||||||||||||√|
||RMSProp|Root mean square propagation|√|||√|||||√|||||||||
||r-NSGA-II|r-dominance based NSGA-II||√||√|√|√|√|√||||||||||
||RPD-NSGA-II|Reference point dominance-based NSGA-II||√|√|√|√|√|√|√||||||||||
||RPEA|Reference points-based evolutionary algorithm|||√|√|√|√|√|√||||||||||
||RSEA|Radial space division based evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||RVEA|Reference vector guided evolutionary algorithm||√|√|√|√|√|√|√||√||||||||
||RVEAa|RVEA embedded with the reference vector<br>regeneration strategy|||√|√|√|√|√|√||||||||||
||RVEA-iGNG|RVEA based on improved growing neural gas||√|√|√|√|√|√|√||||||||||
||S3-CMA-ES|Scalable small subpopulations based<br>covariance matrix adaptation||√|√|√|√||||√|||||||||
||SA|Simulated annealing|√|||√|√||||√|√||||||||
||SACC-EAM-II|Surrogate-assisted cooperative co-<br>evolutionaryalgorithm of Minamo|√|||√|√||||||√|||||||
||SACOSO|Surrogate-assisted cooperative swarm optimization|√|||√|√||||√||√|||||||
||SADE-AMSS|Surrogate-assisted differential evolution with<br>adaptive multi-subspace search|√|||√|√||||||√|||||||
||SADE-ATDSC|Surrogate-assisted differential evolution with<br>adaptation of trainingdata selection criterion|√|||√|√||||||√|||||||
||SADE-<br>Sammon|Sammon mapping assisted differential evolution|√|||√|√||||||√|||||||
||SAMOEA-<br>TL2M|Surrogate-assisted multiobjective evolutionary<br>algorithm based on two-level model management||√|√|√|√||||||√|||||||
||SAMSO|Multiswarm-assisted expensive optimization|√|||√|√||||√||√|||||||
||SAPO|Surrogate-assisted partial optimization|√|||√|√|||||√|√|||||||
||S-CDAS|Self-controlling dominance area of solutions|||√|√|√|√|√|√||||||||||
||SCEA|Sparsity clustering basec evolutionary algorithm||√||√|||√||√|√|||√|||||
||SD|Steepest descent|√|||√|||||√|||||||||
||S-ECSO|Enhanced competitive swarm optimizer for<br>sparse optimization||√||√|||||√||||√|||||
||SFADE|Scalarization function approximation based<br>differential evolution algorithm||√|√|√|√||||||√|||||||



47 

## PlatEMO 用户手册 

|311 <br>312 <br>313 <br>314 <br>315 <br>316 <br>317 <br>318 <br>319 <br>320 <br>321 <br>322 <br>323 <br>324 <br>325 <br>326 <br>327 <br>328 <br>329 <br>330 <br>331 <br>332 <br>333 <br>334 <br>335 <br>336 <br>337 <br>338 <br>339 <br>340 <br>341|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||SGEA|Steady-state and generational evolutionary algorithm||√||√|√|√|√|√||√||||√||||
||SGECF|Sparsity-guided elitism co-evolutionary framework||√||√|||√||√|√|||√|||||
||SHADE|Success-history based adaptive differential<br>evolution|√|||√|√||||√|√||||||||
||SIBEA|Simple indicator-based evolutionary algorithm||√||√|√|√|√|√||||||||||
||SIBEA-<br>kEMOSS|SIBEA with minimum objective subset of<br>size k with minimum error|||√|√|√|√|√|√||||||||||
||SLMEA|Super-large-scale multi-objective<br>evolutionaryalgorithm||√||√|√||√||√|√|||√|||||
||SMEA|Self-organizing multiobjective evolutionary<br>algorithm||√||√|√|||||||||||||
||SMOA|Supervised multi-objective optimization algorithm||√||√|||||||√|||||||
||SMPSO|Speed-constrained multi-objective particle<br>swarm optimization||√||√|√|||||||||||||
||SMS-EGO|S metric selection based efficient global optimization||√||√|√||||||√|||||||
||SMS-EMOA|S metric selection based evolutionary<br>multiobjective optimization||√||√|√|√|√|√||||||||||
||S-NSGA-II|Sparse NSGA-II||√||√|||||√|√|||√|||||
||SparseEA|Evolutionary algorithm for sparse multi-<br>objective optimizationproblems||√||√|√||√||√|√|||√|||||
||SparseEA2|Improved SparseEA||√||√|√||√||√|√|||√|||||
||SparseEMT|Sparse evolutionary multitasking||√||√|√||√||√|√|||√|||||
||SPEA2|Strength Pareto evolutionary algorithm 2||√||√|√|√|√|√||||||||||
||SPEA2+SDE|SPEA2 with shift-based density estimation|||√|√|√|√|√|√||||||||||
||SPEA/R|Strength Pareto evolutionary algorithm based<br>on reference direction||√|√|√|√|√|√|√||||||||||
||SQP|Sequential quadratic programming|√|||√|||||√|√||||||||
||SRA|Stochastic ranking algorithm|||√|√|√|√|√|√||||||||||
||SSCEA|Subspace segmentation based co-<br>evolutionaryalgorithm||√|√|√|√|||||||||||||
||SSDE|Self-organized surrogate-assisted differential<br>evolution||√|√|√|√|||||√|√|||||||
||SSIO-RL|Search space independent operator based<br>deepreinforcement learning|√|||√|√||||√|√||||||||
||SVR-NSGA-II|Support vector regression based NSGA-II||√||√|√|√|√|√||√||||√||||
||t-DEA|theta-dominance based evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||tDEA-CPBI|Theta-dominance based evolutionary<br>algorithm with CPBI||√|√|√|√|√|√|√||√||||||||
||TEA|Two-phase evolutionary algorithm||√|√|√|√|||||√|√|||||||
||TELSO|Two-layer encoding learning swarm optimizer||√||√|||√||√|√|||√|||||
||TiGE-2|Tri-Goal Evolution Framework for CMaOPs|||√|√|√|√|√|√||√||||||||
||ToP|Two-phase framework with NSGA-II||√||√|√|||||√||||||||
||TPCMaO|Three-population based constrained many-|||√|√|√|√|√|√||√||||||||



48 

五 算法列表 

|342 <br>343 <br>344 <br>345 <br>346 <br>347 <br>348 <br>349 <br>350 <br>351 <br>352|算法缩写|算法全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||objective co-evolutionaryalgorithm||||||||||||||||||
||TriMOEA-<br>TA&R|Multi-modal MOEA using two-archive and<br>recombination strategies||√||√|√|||||||√||||||
||TS-NSGA-II|Two-stage NSGA-II||√|√|√|√|√|√|√||||||||||
||TS-SparseEA|Two-stage SparseEA||√||√|||√||√|√|||√|||||
||TSTI|Two-stage evolutionary algorithm with three<br>indicators||√||√|√|√|√|√||√||||||||
||Two_Arch2|Two-archive algorithm 2||√|√|√|√|√|√|√||||||||||
||URCMO|Utilizing the relationship between<br>constrained and unconstrained Pareto fronts<br>for constrained multi-objective optimization||√||√|√|||||√||||||||
||VaEA|Vector angle based evolutionary algorithm||√|√|√|√|√|√|√||||||||||
||WASF-GA|Weighting achievement scalarizing function<br>genetic algorithm||√||√|√|√|√|√||||||||||
||WOA|Whale optimization algorithm|√|||√|√||||√|√||||||||
||WOF|Weighted optimization framework||√||√|√||||√|||||||||
||WV-MOEA-P|Weight vector based multi-objective<br>optimization algorithm withpreference||√||√|√|||||||||||||



49 

PlatEMO 用户手册 

## 六 问题列表 

|1<br>2<br>3<br>4<br>5<br>6<br>7<br>8<br>9<br>10 <br>11 <br>12 <br>13 <br>14 <br>15 <br>16 <br>17 <br>18 <br>19 <br>20 <br>21 <br>22 <br>23 <br>24 <br>25 <br>26 <br>27 <br>28 <br>29 <br>30 <br>31 <br>32 <br>33|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||BBOB_F1|Sphere function|√|||√|||||||√|||||||
||BBOB_F2|Ellipsoidal function|√|||√|||||||√|||||||
||BBOB_F3|Rastrigin function|√|||√|||||||√|||||||
||BBOB_F4|Buche-Rastrigin function|√|||√|||||||√|||||||
||BBOB_F5|Linear slope|√|||√|||||||√|||||||
||BBOB_F6|Attractive sector function|√|||√|||||||√|||||||
||BBOB_F7|Step ellipsoidal function|√|||√|||||||√|||||||
||BBOB_F8|Rosenbrock function|√|||√|||||||√|||||||
||BBOB_F9|Rotated Rosenbrock function|√|||√|||||||√|||||||
||BBOB_F10|Rotated ellipsoidal function|√|||√|||||||√|||||||
||BBOB_F11|Discus function|√|||√|||||||√|||||||
||BBOB_F12|Bent cigar function|√|||√|||||||√|||||||
||BBOB_F13|Sharp ridge function|√|||√|||||||√|||||||
||BBOB_F14|Different powers function|√|||√|||||||√|||||||
||BBOB_F15|Rastrigin function|√|||√|||||||√|||||||
||BBOB_F16|Weierstrass function|√|||√|||||||√|||||||
||BBOB_F17|Schaffers F7 function|√|||√|||||||√|||||||
||BBOB_F18|Moderately ill-conditioned Schaffers F7 function|√|||√|||||||√|||||||
||BBOB_F19|Composite Griewank-Rosenbrock function F8F2|√|||√|||||||√|||||||
||BBOB_F20|Schwefel function|√|||√|||||||√|||||||
||BBOB_F21|Gallagher's Gaussian 101-me peaks function|√|||√|||||||√|||||||
||BBOB_F22|Gallagher's Gaussian 21-hi peaks function|√|||√|||||||√|||||||
||BBOB_F23|Katsuura function|√|||√|||||||√|||||||
||BBOB_F24|Lunacek bi-Rastrigin function|√|||√|||||||√|||||||
||BT1|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT2|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT3|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT4|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT5|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT6|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT7|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT8|Benchmark MOP with bias feature||√||√|||||√|||||||||
||BT9|Benchmark MOP with bias feature||√||√|||||√|||||||||



50 

六 问题列表 

|34 <br>35 <br>36 <br>37 <br>38 <br>39 <br>40 <br>41 <br>42 <br>43 <br>44 <br>45 <br>46 <br>47 <br>48 <br>49 <br>50 <br>51 <br>52 <br>53 <br>54 <br>55 <br>56 <br>57 <br>58 <br>59 <br>60 <br>61 <br>62 <br>63|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||C10MOP1|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP2|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP3|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP4|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP5|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP6|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP7|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP8|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||C10MOP9|Neural architecture search on CIFAR-10||√||√|||||√|||||||||
||CEC2008_F1|Shifted sphere function|√|||√|||||√||√|||||||
||CEC2008_F2|Shifted Schwefel's function|√|||√|||||√||√|||||||
||CEC2008_F3|Shifted Rosenbrock's function|√|||√|||||√||√|||||||
||CEC2008_F4|Shifted Rastrign's function|√|||√|||||√||√|||||||
||CEC2008_F5|Shifted Griewank's function|√|||√|||||√||√|||||||
||CEC2008_F6|Shifted Ackley's function|√|||√|||||√||√|||||||
||CEC2008_F7|FastFractal 'DoubleDip' function|√|||√|||||√||√|||||||
||CEC2010_F1|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F2|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F3|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F4|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F5|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F6|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F7|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F8|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F9|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F10|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F11|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F12|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F13|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F14|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||



51 

## PlatEMO 用户手册 

|64 <br>65 <br>66 <br>67 <br>68 <br>69 <br>70 <br>71 <br>72 <br>73 <br>74 <br>75 <br>76 <br>77 <br>78 <br>79 <br>80 <br>81 <br>82 <br>83 <br>84 <br>85 <br>86 <br>87 <br>88 <br>89|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||CEC2010_F15|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F16|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F17|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2010_F18|CEC'2010 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2013_F1|Shifted elliptic function|√|||√|||||√|||||||||
||CEC2013_F2|Shifted Rastrigin's function|√|||√|||||√|||||||||
||CEC2013_F3|Shifted Ackley's function|√|||√|||||√|||||||||
||CEC2013_F4|7-nonseparable, 1-separable shifted and<br>rotated elliptic function|√|||√|||||√|||||||||
||CEC2013_F5|7-nonseparable, 1-separable shifted and<br>rotated Rastrigin's function|√|||√|||||√|||||||||
||CEC2013_F6|7-nonseparable, 1-separable shifted and<br>rotated Ackley's function|√|||√|||||√|||||||||
||CEC2013_F7|7-nonseparable, 1-separable shifted and<br>rotated Schwefel's function|√|||√|||||√|||||||||
||CEC2013_F8|20-nonseparable shifted and rotated elliptic<br>function|√|||√|||||√|||||||||
||CEC2013_F9|20-nonseparable shifted and rotated<br>Rastrigin's function|√|||√|||||√|||||||||
||CEC2013_F10|20-nonseparable shifted and rotated<br>Rastrigin's function|√|||√|||||√|||||||||
||CEC2013_F11|20-nonseparable shifted and rotated<br>Schwefel's function|√|||√|||||√|||||||||
||CEC2013_F12|Shifted Rosenbrock's function|√|||√|||||√|||||||||
||CEC2013_F13|Shifted Schwefel's function with conforming<br>overlappingsubcomponents|√|||√|||||√|||||||||
||CEC2013_F14|Shifted Schwefel's function with conflicting<br>overlappingsubcomponents|√|||√|||||√|||||||||
||CEC2013_F15|Shifted Schwefel's function|√|||√|||||√|||||||||
||CEC2017_F1|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F2|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F3|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F4|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F5|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F6|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F7|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||



52 

六 问题列表 

|90 <br>91 <br>92 <br>93 <br>94 <br>95 <br>96 <br>97 <br>98 <br>99 <br>100 <br>101 <br>102 <br>103 <br>104 <br>105 <br>106 <br>107 <br>108 <br>109 <br>110 <br>111 <br>112 <br>113 <br>114|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||CEC2017_F8|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F9|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F10|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F11|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F12|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F13|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F14|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F15|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F16|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F17|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F18|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F19|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F20|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F21|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F22|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F23|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F24|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F25|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F26|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F27|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2017_F28|CEC'2017 constrained optimization<br>benchmarkproblem|√|||√||||||√||||||||
||CEC2020_F1|Bent cigar function|√|||√||||||||||||||
||CEC2020_F2|Shifted and rotated Schwefel's function|√|||√||||||||||||||
||CEC2020_F3|Shifted and rotated Lunacek bi-Rastrigin<br>function|√|||√||||||||||||||
||CEC2020_F4|Expanded Rosenbrock's plus Griewangk's<br>function|√|||√||||||||||||||



53 

PlatEMO 用户手册 

|115 <br>116 <br>117 <br>118 <br>119 <br>120 <br>121 <br>122 <br>123 <br>124 <br>125 <br>126 <br>127 <br>128 <br>129 <br>130 <br>131 <br>132 <br>133 <br>134 <br>135 <br>136 <br>137 <br>138 <br>139 <br>140 <br>141 <br>142 <br>143 <br>144|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||CEC2020_F5|Hybrid function 1|√|||√||||||||||||||
||CEC2020_F6|Hybrid function 2|√|||√||||||||||||||
||CEC2020_F7|Hybrid function 3|√|||√||||||||||||||
||CEC2020_F8|Composition function 1|√|||√||||||||||||||
||CEC2020_F9|Composition function 2|√|||√||||||||||||||
||CEC2020_F10|Composition function 3|√|||√||||||||||||||
||CF1|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF2|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF3|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF4|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF5|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF6|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF7|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF8|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF9|Constrained benchmark MOP||√||√|||||√|√||||||||
||CF10|Constrained benchmark MOP||√||√|||||√|√||||||||
||CI_HS|Multitasking problem (Griewank function +<br>Rastrigin function)|√|||√|||||√||||||√|||
||CI_LS|Multitasking problem (Ackley function +<br>Schwefel function)|√|||√|||||√||||||√|||
||CI_MS|Multitasking problem (Ackley function +<br>Rastrigin function)|√|||√|||||√||||||√|||
||CitySegMOP1|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP2|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP3|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP4|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP5|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP6|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP7|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP8|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP9|Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP10|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP11|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||



54 

六 问题列表 

|145 <br>146 <br>147 <br>148 <br>149 <br>150 <br>151 <br>152 <br>153 <br>154 <br>155 <br>156 <br>157 <br>158 <br>159 <br>160 <br>161 <br>162 <br>163 <br>164 <br>165 <br>166 <br>167 <br>168 <br>169|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||CitySegMOP12|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP13|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP14|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||CitySegMOP15|<br>Neural architecture search on Cityscape<br>segmentation datasets||√||√|||||√||√|||||||
||Community<br>Detection|The community detection problem with label<br>based encoding|√|||||√|||√||√|||||||
||DAS-CMOP1|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP2|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP3|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP4|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP5|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP6|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP7|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP8|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DAS-CMOP9|Difficulty-adjustable and scalable constrained<br>benchmark MOP||√||√|||||√|√||||||||
||DOC1|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC2|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC3|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC4|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC5|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC6|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC7|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC8|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DOC9|Benchmark MOP with constraints in decision<br>and objective spaces||√||√||||||√||||||||
||DSMOP1|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP2|Dynamic sparse multi-objective optimization||√|√|√|||||√||||√|√||||



55 

## PlatEMO 用户手册 

|170 <br>171 <br>172 <br>173 <br>174 <br>175 <br>176 <br>177 <br>178 <br>179 <br>180 <br>181 <br>182 <br>183 <br>184 <br>185 <br>186 <br>187 <br>188 <br>189 <br>190 <br>191 <br>192 <br>193 <br>194 <br>195|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||problem||||||||||||||||||
||DSMOP3|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP4|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP5|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP6|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP7|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP8|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP9|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP10|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP11|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DSMOP12|Dynamic sparse multi-objective optimization<br>problem||√|√|√|||||√||||√|√||||
||DTLZ1|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ2|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ3|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ4|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ5|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ6|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ7|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√||√|||||||
||DTLZ8|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√|√|√|||||||
||DTLZ9|Benchmark MOP proposed by Deb, Thiele,<br>Laumanns,and Zitzler||√|√|√|||||√|√|√|||||||
||CDTLZ2|Convex DTLZ2||√|√|√|||||√||√|||||||
||IDTLZ1|Inverted DTLZ1||√|√|√|||||√||√|||||||
||IDTLZ2|Inverted DTLZ2||√|√|√|||||√||√|||||||
||SDTLZ1|Scaled DTLZ1||√|√|√|||||√||√|||||||
||SDTLZ2|Scaled DTLZ2||√|√|√|||||√||√|||||||
||C1-DTLZ1|Constrained DTLZ1||√|√|√|||||√|√|√|||||||
||C1-DTLZ3|Constrained DTLZ3||√|√|√|||||√|√|√|||||||



56 

六 问题列表 

|196 <br>197 <br>198 <br>199 <br>200 <br>201 <br>202 <br>203 <br>204 <br>205 <br>206 <br>207 <br>208 <br>209 <br>210 <br>211 <br>212 <br>213 <br>214 <br>215 <br>216 <br>217 <br>218 <br>219 <br>220 <br>221 <br>222|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||C2-DTLZ2|Constrained DTLZ2||√|√|√|||||√|√|√|||||||
||C3-DTLZ4|Constrained DTLZ4||√|√|√|||||√|√|√|||||||
||DC1-DTLZ1|DTLZ1 with constrains in decision space||√|√|√|||||√|√|√|||||||
||DC1-DTLZ3|DTLZ3 with constrains in decision space||√|√|√|||||√|√|√|||||||
||DC2-DTLZ1|DTLZ1 with constrains in decision space||√|√|√|||||√|√|√|||||||
||DC2-DTLZ3|DTLZ3 with constrains in decision space||√|√|√|||||√|√|√|||||||
||DC3-DTLZ1|DTLZ1 with constrains in decision space||√|√|√|||||√|√|√|||||||
||DC3-DTLZ3|DTLZ3 with constrains in decision space||√|√|√|||||√|√|√|||||||
||EOPCCV_F1|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F2|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F3|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F4|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F5|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F6|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F7|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F8|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F9|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F10|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F11|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F12|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F13|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F14|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F15|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F16|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F17|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F18|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F19|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||



57 

## PlatEMO 用户手册 

|223 <br>224 <br>225 <br>226 <br>227 <br>228 <br>229 <br>230 <br>231 <br>232 <br>233 <br>234 <br>235 <br>236 <br>237 <br>238 <br>239 <br>240 <br>241 <br>242 <br>243 <br>244 <br>245 <br>246 <br>247 <br>248 <br>249 <br>250 <br>251 <br>252|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||EOPCCV_F20|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F21|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F22|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F23|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F24|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F25|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F26|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F27|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F28|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F29|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||EOPCCV_F30|Expensive optimization problems with<br>continuous and categorical variables|√|||√||√|||||√|||||||
||FCP1|Benchmark constrained MOP proposed by Yuan||√||√||||||√||||||||
||FCP2|Benchmark constrained MOP proposed by Yuan||√||√||||||√||||||||
||FCP3|Benchmark constrained MOP proposed by Yuan||√||√||||||√||||||||
||FCP4|Benchmark constrained MOP proposed by Yuan||√||√||||||√||||||||
||FCP5|Benchmark constrained MOP proposed by Yuan||√||√||||||√||||||||
||FDA1|Benchmark dynamic MOP proposed by Farina,<br>Deb,and Amato||√||√|||||√|||||√||||
||FDA2|Benchmark dynamic MOP proposed by Farina,<br>Deb,and Amato||√||√|||||√|||||√||||
||FDA3|Benchmark dynamic MOP proposed by Farina,<br>Deb,and Amato||√||√|||||√|||||√||||
||FDA4|Benchmark dynamic MOP proposed by Farina,<br>Deb,and Amato||√||√|||||√|||||√||||
||FDA5|Benchmark dynamic MOP proposed by Farina,<br>Deb,and Amato||√||√|||||√|||||√||||
||GLSMOP1|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP2|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP3|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP4|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP5|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP6|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP7|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP8|General large-scale benchmark MOP||√|√|√|||||√||√|||||||
||GLSMOP9|General large-scale benchmark MOP||√|√|√|||||√||√|||||||



58 

六 问题列表 

|253 <br>254 <br>255 <br>256 <br>257 <br>258 <br>259 <br>260 <br>261 <br>262 <br>263 <br>264 <br>265 <br>266 <br>267 <br>268 <br>269 <br>270 <br>271 <br>272 <br>273 <br>274 <br>275 <br>276 <br>277 <br>278 <br>279 <br>280 <br>281 <br>282 <br>283 <br>284 <br>285 <br>286|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||IMMOEA_F1|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F2|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F3|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F4|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F5|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F6|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F7|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F8|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F9|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMMOEA_F10|Benchmark MOP for testing IM-MOEA||√||√|||||√|||||||||
||IMOP1|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP2|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP3|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP4|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP5|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP6|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP7|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IMOP8|Benchmark MOP with irregular Pareto front||√||√|||||||√|||||||
||IN1KMOP1|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP2|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP3|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP4|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP5|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP6|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP7|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP8|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||IN1KMOP9|Neural architecture search on ImageNet 1K||√||√|||||√||√|||||||
||Instance1|Multitasking multi-objective problem<br>(ZDT4-R + ZDT4-G)||√||√|||||√||||||√|||
||Instance2|Multitasking multi-objective problem<br>(ZDT4-RC + ZDT4-A)||√||√|||||√|√|||||√|||
||KP|The knapsack problem|√||||||√||√|√||||||||
||LIR-CMOP1|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP2|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP3|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP4|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||



59 

## PlatEMO 用户手册 

|287 <br>288 <br>289 <br>290 <br>291 <br>292 <br>293 <br>294 <br>295 <br>296 <br>297 <br>298 <br>299 <br>300 <br>301 <br>302 <br>303 <br>304 <br>305 <br>306 <br>307 <br>308 <br>309 <br>310 <br>311|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||LIR-CMOP5|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP6|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP7|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP8|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP9|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP10|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP11|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP12|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP13|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LIR-CMOP14|Constrained benchmark MOP with large<br>infeasible regions||√||√|||||√|√||||||||
||LRMOP1|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LRMOP2|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LRMOP3|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LRMOP4|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LRMOP5|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LRMOP6|Large-scale robust multi-objective<br>benchmarkproblem||√|√|√|||||√||√||√||||√|
||LSCM1|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM2|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM3|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM4|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM5|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM6|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM7|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM8|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM9|Large-scale constrained multiobjective||√||√|||||√|√||||||||



60 

六 问题列表 

|312 <br>313 <br>314 <br>315 <br>316 <br>317 <br>318 <br>319 <br>320 <br>321 <br>322 <br>323 <br>324 <br>325 <br>326 <br>327 <br>328 <br>329 <br>330 <br>331 <br>332 <br>333 <br>334 <br>335 <br>336 <br>337 <br>338 <br>339 <br>340 <br>341 <br>342 <br>343 <br>344 <br>345|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||benchmarkproblem||||||||||||||||||
||LSCM10|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM11|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSCM12|Large-scale constrained multiobjective<br>benchmarkproblem||√||√|||||√|√||||||||
||LSMOP1|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP2|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP3|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP4|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP5|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP6|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP7|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP8|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||LSMOP9|Large-scale benchmark MOP||√|√|√|||||√|||||||||
||MaF1|Inverted DTLZ1||√|√|√|||||√|||||||||
||MaF2|DTLZ2BZ||√|√|√|||||√|||||||||
||MaF3|Convex DTLZ3||√|√|√|||||√|||||||||
||MaF4|Inverted and scaled DTLZ3||√|√|√|||||√|||||||||
||MaF5|Scaled DTLZ4||√|√|√|||||√|||||||||
||MaF6|DTLZ5IM||√|√|√|||||√|||||||||
||MaF7|DTLZ7||√|√|√|||||√|||||||||
||MaF8|MP-DMP||√|√|√||||||||||||||
||MaF9|ML-DMP||√|√|√||||||||||||||
||MaF10|WFG1||√|√|√|||||√|||||||||
||MaF11|WFG2||√|√|√|||||√|||||||||
||MaF12|WFG9||√|√|√|||||√|||||||||
||MaF13|P7||√|√|√|||||√|||||||||
||MaF14|LSMOP3||√|√|√|||||√|||||||||
||MaF15|Inverted LSMOP8||√|√|√|||||√|||||||||
||MaOPP_binary|Many-objective pathfinding problem based<br>on binaryencoding|||√||||√||√||√|||||||
||MaOPP_real|Many-objective pathfinding problem based<br>on real encoding|||√|√|||||√||√|||||||
||Mario|Play with Mario|√||||√|√||||||||||||
||MaxCut|The max-cut problem|√||||||√||√|||||||||
||MLDMP|The multi-line distance minimization problem||√|√|√||||||||||||||
||MMF1|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF2|Multi-modal multi-objective test function||√||√||||||||√||||||



61 

## PlatEMO 用户手册 

|346 <br>347 <br>348 <br>349 <br>350 <br>351 <br>352 <br>353 <br>354 <br>355 <br>356 <br>357 <br>358 <br>359 <br>360 <br>361 <br>362 <br>363 <br>364 <br>365 <br>366 <br>367 <br>368 <br>369 <br>370 <br>371 <br>372 <br>373 <br>374 <br>375 <br>376 <br>377 <br>378|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||MMF3|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF4|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF5|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF6|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF7|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMF8|Multi-modal multi-objective test function||√||√||||||||√||||||
||MMMOP1|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMMOP2|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMMOP3|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMMOP4|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMMOP5|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMMOP6|Multi-modal multi-objective optimization problem||√|√|√||||||||√||||||
||MMOP_HS1|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_HS2|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_LS1|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_LS2|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_MS1|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_MS2|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_NS1|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MMOP_NS2|Large-scale sparse multitasking multi-<br>objective optimizationproblem||√||√|||||√||||√||√|||
||MOEADDE_F1|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F2|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F3|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F4|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F5|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F6|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F7|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F8|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADDE_F9|Benchmark MOP for testing MOEA/D-DE||√||√|||||√|||||||||
||MOEADM2M_F1|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOEADM2M_F2|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOEADM2M_F3|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOEADM2M_F4|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||



62 

六 问题列表 

|379 <br>380 <br>381 <br>382 <br>383 <br>384 <br>385 <br>386 <br>387 <br>388 <br>389 <br>390 <br>391 <br>392 <br>393 <br>394 <br>395 <br>396 <br>397 <br>398 <br>399 <br>400 <br>401 <br>402 <br>403 <br>404 <br>405 <br>406 <br>407|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||MOEADM2M_F5|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOEADM2M_F6|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOEADM2M_F7|Benchmark MOP for testing MOEA/D-M2M||√||√|||||√|||||||||
||MOKP|The multi-objective knapsack problem||√|√||||√||√|√||||||||
||MONRP|The multi-objective next release problem||√|||||√||√|||||||||
||MOTSP|The multi-objective traveling salesman problem||√|√|||||√|√|||||||||
||MPDMP|The multi-point distance minimization problem||√|√|√||||||||||||||
||mQAP|The multi-objective quadratic assignment problem||√|√|||||√|√|||||||||
||MW1|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW2|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW3|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW4|Constrained benchmark MOP proposed by<br>Ma and Wang||√|√|√|||||√|√||||||||
||MW5|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW6|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW7|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW8|Constrained benchmark MOP proposed by<br>Ma and Wang||√|√|√|||||√|√||||||||
||MW9|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW10|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW11|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW12|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW13|Constrained benchmark MOP proposed by<br>Ma and Wang||√||√|||||√|√||||||||
||MW14|Constrained benchmark MOP proposed by<br>Ma and Wang||√|√|√|||||√|√||||||||
||NI_HS|Multitasking problem (Rosenbrock function<br>+ Rastrigin function)|√|||√|||||√||||||√|||
||NI_MS|Multitasking problem (Griewank function +<br>Weierstrass function)|√|||√|||||√||||||√|||
||RMMEDA_F1|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F2|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F3|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F4|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F5|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||



63 

## PlatEMO 用户手册 

|408 <br>409 <br>410 <br>411 <br>412 <br>413 <br>414 <br>415 <br>416 <br>417 <br>418 <br>419 <br>420 <br>421 <br>422 <br>423 <br>424 <br>425 <br>426 <br>427 <br>428 <br>429 <br>430 <br>431 <br>432 <br>433 <br>434 <br>435 <br>436 <br>437 <br>438 <br>439 <br>440 <br>441 <br>442 <br>443|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||RMMEDA_F6|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F7|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F8|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F9|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RMMEDA_F10|Benchmark MOP for testing RM-MEDA||√||√|||||√|||||||||
||RWMOP1|Pressure vessal problem||√||√||||||√||||||||
||RWMOP2|Vibrating platform||√||√||||||√||||||||
||RWMOP3|Two bar truss design problem||√||√||||||√||||||||
||RWMOP4|Weldan beam design problem||√||√||||||√||||||||
||RWMOP5|Disc brake design problem||√||√||||||√||||||||
||RWMOP6|Speed reducer design problem||√||√||||||√||||||||
||RWMOP7|Gear train design problem||√||√||||||√||||||||
||RWMOP8|Car side impact design problem||√||√||||||√||||||||
||RWMOP9|Four bar plane truss||√||√||||||√||||||||
||RWMOP10|Two bar plane truss||√||√||||||√||||||||
||RWMOP11|Water resource management problem||√||√||||||√||||||||
||RWMOP12|Simply supported I-beam design||√||√||||||√||||||||
||RWMOP13|Gear box design||√||√||||||√||||||||
||RWMOP14|Multiple-disk clutch brake design problem||√||√||||||√||||||||
||RWMOP15|Spring design problem||√||√||||||√||||||||
||RWMOP16|Cantilever beam design problem||√||√||||||√||||||||
||RWMOP17|Bulk carriers design problem||√||√||||||√||||||||
||RWMOP18|Front rail design problem||√||√||||||√||||||||
||RWMOP19|Multi-product batch plant||√||√||||||√||||||||
||RWMOP20|Hydro-static thrust bearing design problem||√||√||||||√||||||||
||RWMOP21|Crash energy management for high-speed train||√||√||||||√||||||||
||RWMOP22|Haverly's pooling problem||√||√||||||√||||||||
||RWMOP23|Reactor network design||√||√||||||√||||||||
||RWMOP24|Heat exchanger network design||√||√||||||√||||||||
||RWMOP25|Process synthesis problem||√||√||||||√||||||||
||RWMOP26|Process sythesis and design problem||√||√||||||√||||||||
||RWMOP27|Process flow sheeting problem||√||√||||||√||||||||
||RWMOP28|Two reactor problem||√||√||||||√||||||||
||RWMOP29|Process synthesis problem||√||√||||||√||||||||
||RWMOP30|Synchronous pptimal pulse-width modulation<br>of 3-level inverters||√||√||||||√||||||||
||RWMOP31|Synchronous pptimal pulse-width modulation<br>of 5-level inverters||√||√||||||√||||||||



64 

六 问题列表 

|444 <br>445 <br>446 <br>447 <br>448 <br>449 <br>450 <br>451 <br>452 <br>453 <br>454 <br>455 <br>456 <br>457 <br>458 <br>459 <br>460 <br>461 <br>462 <br>463 <br>464 <br>465 <br>466|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||RWMOP32|Synchronous pptimal pulse-width modulation<br>of 7-level inverters||√||√||||||√||||||||
||RWMOP33|Synchronous pptimal pulse-width modulation<br>of 9-level inverters||√||√||||||√||||||||
||RWMOP34|Synchronous pptimal pulse-width modulation<br>of 11-level inverters||√||√||||||√||||||||
||RWMOP35|Synchronous pptimal pulse-width modulation<br>of 13-level inverters||√||√||||||√||||||||
||RWMOP36|Optimal sizing of single phase distributed generation<br>with reactive power support for phase balancing at<br>main transformer/grid and activepower loss||√||√||||||√||||||||
||RWMOP37|Optimal Sizing of Single Phase Distributed<br>Generation with reactive power support for<br>Phase Balancing at Main Transformer/Grid<br>and reactive Power loss||√||√||||||√||||||||
||RWMOP38|Optimal sizing of single phase distributed<br>generation with reactive power support for<br>active and reactivepower loss||√||√||||||√||||||||
||RWMOP39|Optimal sizing of single phase distributed<br>generation with reactive power support for<br>phase balancing at main transformer/grid and<br>active and reactivepower loss||√||√||||||√||||||||
||RWMOP40|Optimal power flow for minimizing active<br>and reactivepower loss||√||√||||||√||||||||
||RWMOP41|Optimal power flow for minimizing voltage<br>deviation,active and reactivepower loss||√||√||||||√||||||||
||RWMOP42|Optimal power flow for minimizing voltage<br>deviation,and activepower loss||√||√||||||√||||||||
||RWMOP43|Optimal power flow for minimizing fuel cost,<br>and activepower loss||√||√||||||√||||||||
||RWMOP44|Optimal power flow for minimizing fuel cost,<br>active and reactivepower loss||√||√||||||√||||||||
||RWMOP45|Optimal power flow for minimizing fuel cost,<br>voltage deviation,and activepower loss||√||√||||||√||||||||
||RWMOP46|Optimal power flow for minimizing fuel cost,<br>voltage deviation,active and reactivepower loss||√||√||||||√||||||||
||RWMOP47|Optimal droop setting for minimizing active<br>and reactivepower loss||√||√||||||√||||||||
||RWMOP48|Optimal droop setting for minimizing voltage<br>deviation and activepower loss||√||√||||||√||||||||
||RWMOP49|Optimal droop setting for minimizing voltage<br>deviation,active,and reactivepower loss||√||√||||||√||||||||
||RWMOP50|Power distribution system planning||√||√||||||√||||||||
||SDC1|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC2|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC3|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC4|Scalable high-dimensional decicsion||√||√||||||√||||||||



65 

## PlatEMO 用户手册 

|467 <br>468 <br>469 <br>470 <br>471 <br>472 <br>473 <br>474 <br>475 <br>476 <br>477 <br>478 <br>479 <br>480 <br>481 <br>482 <br>483 <br>484 <br>485 <br>486 <br>487 <br>488 <br>489 <br>490|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||constraint benchamrk||||||||||||||||||
||SDC5|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC6|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC7|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC8|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC9|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC10|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC11|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC12|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC13|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC14|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SDC15|Scalable high-dimensional decicsion<br>constraint benchamrk||√||√||||||√||||||||
||SMD1|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD2|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD3|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD4|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD5|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD6|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD7|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD8|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||||||||√||
||SMD9|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||√||||||√||
||SMD10|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||√||||||√||
||SMD11|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||√||||||√||
||SMD12|Bilevel optimization problems proposed by<br>Sinha,Malo,and Deb||√||√||||||√||||||√||
||SO_ISCSO_2016|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||



66 

六 问题列表 

|491 <br>492 <br>493 <br>494 <br>495 <br>496 <br>497 <br>498 <br>499 <br>500 <br>501 <br>502 <br>503 <br>504 <br>505 <br>506 <br>507 <br>508 <br>509 <br>510 <br>511 <br>512 <br>513 <br>514 <br>515 <br>516 <br>517 <br>518|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||SO_ISCSO_2017|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||
||SO_ISCSO_2018|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||
||SO_ISCSO_2019|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||
||SO_ISCSO_2021|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||
||SO_ISCSO_2022|International student competition in structural<br>optimization|<br>√||||√||||√|√||||||||
||Sparse_CD|The community detection problem||√|||||√||√||√||√|||||
||Sparse_CN|The critical node detection problem||√|||||√||√||√||√|||||
||Sparse_FS|The feature selection problem||√|||||√||√||√||√|||||
||Sparse_IS|The instance selection problem||√|||||√||√||√||√|||||
||Sparse_KP|The sparse multi-objective knapsack problem||√|√||||√||√|||||||||
||Sparse_NN|The neural network training problem||√||√|||||√||√||√|||||
||Sparse_PM|The pattern mining problem||√|||||√||√||√||√|||||
||Sparse_PO|The portfolio optimization problem||√||√|||||√||√||√|||||
||Sparse_SR|The sparse signal reconstruction problem||√||√|||||√||√||√|||||
||SMMOP1|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP2|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP3|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP4|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP5|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP6|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP7|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMMOP8|Sparse multi-modal multi-objective<br>optimizationproblem||√|√|√|||||√|||√|√|||||
||SMOP1|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP2|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP3|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP4|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP5|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP6|Benchmark MOP with sparse Pareto optimal||√|√|√|||||√||√||√|||||



67 

## PlatEMO 用户手册 

|519 <br>520 <br>521 <br>522 <br>523 <br>524 <br>525 <br>526 <br>527 <br>528 <br>529 <br>530 <br>531 <br>532 <br>533 <br>534 <br>535 <br>536 <br>537 <br>538 <br>539 <br>540 <br>541 <br>542 <br>543 <br>544 <br>545 <br>546 <br>547 <br>548 <br>549 <br>550 <br>551 <br>552 <br>553 <br>554|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||solutions||||||||||||||||||
||SMOP7|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SMOP8|Benchmark MOP with sparse Pareto optimal<br>solutions||√|√|√|||||√||√||√|||||
||SOP_F1|Sphere function|√|||√|||||||√|||||||
||SOP_F2|Schwefel's function 2.22|√|||√|||||||√|||||||
||SOP_F3|Schwefel's function 1.2|√|||√|||||||√|||||||
||SOP_F4|Schwefel's function 2.21|√|||√|||||||√|||||||
||SOP_F5|Generalized Rosenbrock's function|√|||√|||||||√|||||||
||SOP_F6|Step function|√|||√|||||||√|||||||
||SOP_F7|Quartic function with noise|√|||√|||||||√|||||||
||SOP_F8|Generalized Schwefel's function 2.26|√|||√|||||||√|||||||
||SOP_F9|Generalized Rastrigin's function|√|||√|||||||√|||||||
||SOP_F10|Ackley's function|√|||√|||||||√|||||||
||SOP_F11|Generalized Griewank's function|√|||√|||||||√|||||||
||SOP_F12|Generalized penalized function|√|||√|||||||√|||||||
||SOP_F13|Generalized penalized function|√|||√|||||||√|||||||
||SOP_F14|Shekel's foxholes function|√|||√|||||||√|||||||
||SOP_F15|Kowalik's function|√|||√|||||||√|||||||
||SOP_F16|Six-hump camel-back function|√|||√|||||||√|||||||
||SOP_F17|Branin function|√|||√|||||||√|||||||
||SOP_F18|Goldstein-price function|√|||√|||||||√|||||||
||SOP_F19|Hartman's family|√|||√|||||||√|||||||
||SOP_F20|Hartman's family|√|||√|||||||√|||||||
||SOP_F21|Shekel's family|√|||√|||||||√|||||||
||SOP_F22|Shekel's family|√|||√|||||||√|||||||
||SOP_F23|Shekel's family|√|||√|||||||√|||||||
||TP1|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP2|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP3|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP4|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP5|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP6|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP7|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP8|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP9|Test problem for robust multi-objective optimization||√||√|||||√||||||||√|
||TP10|Test problem for robust multi-objective optimization||√||√|||||√|√|||||||√|
||TREE1|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||



68 

六 问题列表 

|555 <br>556 <br>557 <br>558 <br>559 <br>560 <br>561 <br>562 <br>563 <br>564 <br>565 <br>566 <br>567 <br>568 <br>569 <br>570 <br>571 <br>572 <br>573 <br>574 <br>575 <br>576 <br>577 <br>578 <br>579 <br>580 <br>581 <br>582 <br>583 <br>584 <br>585 <br>586 <br>587 <br>588 <br>589|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||TREE2|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||
||TREE3|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||
||TREE4|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||
||TREE5|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||
||TREE6|The time-varying ratio error estimation problem||√||√|||||√|√|√|||||||
||TSP|The traveling salesman problem|√|||||||√|√|||||||||
||UF1|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF2|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF3|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF4|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF5|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF6|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF7|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF8|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF9|Unconstrained benchmark MOP||√||√|||||√|||||||||
||UF10|Unconstrained benchmark MOP||√||√|||||√|||||||||
||VNT1|Benchmark MOP proposed by Viennet||√||√||||||||||||||
||VNT2|Benchmark MOP proposed by Viennet||√||√||||||||||||||
||VNT3|Benchmark MOP proposed by Viennet||√||√||||||||||||||
||VNT4|Benchmark MOP proposed by Viennet||√||√||||||√||||||||
||WFG1|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG2|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG3|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG4|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG5|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG6|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG7|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG8|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||WFG9|Benchmark MOP proposed by Walking Fish Group||√|√|√|||||√||√|||||||
||ZCAT1|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT2|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCA3|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCA4|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCA5|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT6|Benchmark MOP proposed by Zapotecas,||√|√|√|||||√||√|||||||



69 

## PlatEMO 用户手册 

|590 <br>591 <br>592 <br>593 <br>594 <br>595 <br>596 <br>597 <br>598 <br>599 <br>600 <br>601 <br>602 <br>603 <br>604 <br>605 <br>606 <br>607 <br>608 <br>609 <br>610 <br>611 <br>612 <br>613|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|||Coello,Aguirre,and Tanaka||||||||||||||||||
||ZCAT7|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT8|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT9|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT10|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT11|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT12|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT13|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT14|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT15|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT16|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT17|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT18|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT19|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZCAT20|Benchmark MOP proposed by Zapotecas,<br>Coello,Aguirre,and Tanaka||√|√|√|||||√||√|||||||
||ZDT1|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√||√|||||√||√|||||||
||ZDT2|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√||√|||||√||√|||||||
||ZDT3|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√||√|||||√||√|||||||
||ZDT4|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√||√|||||√||√|||||||
||ZDT5|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√|||||√||√||√|||||||
||ZDT6|Benchmark MOP proposed by Zitzler, Deb,<br>and Thiele||√||√|||||√||√|||||||
||ZXH_CF1|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF2|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF3|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF4|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||



70 

六 问题列表 

|614 <br>615 <br>616 <br>617 <br>618 <br>619 <br>620 <br>621 <br>622 <br>623 <br>624 <br>625|问题缩写|问题全称|single|multi|many|real|integer|label|binary|permutation|large|constrained|expensive|multimodal|sparse|dynamic|multitask|bilevel|robust|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
||ZXH_CF5|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF6|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF7|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF8|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF9|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF10|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF11|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF12|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF13|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF14|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF15|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||
||ZXH_CF16|Constrained benchmark MOP proposed by<br>Zhou,Xiang,and He||√|√|√|||||√|√||||||||



71 

