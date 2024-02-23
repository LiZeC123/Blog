---
title: Python笔记之科学计算
date: 2019-01-02 13:42:43
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---



本文介绍Python科学计算中经常使用的一些第三方库, 包括数据计算模块numpy, 科学计算模块scipy, 数据处理模块pandas, 绘图模块matplotlib等. 上述这些模块都是其他更高级模块的基础模块, 是使用Python进行科学计算的核心内容. 本文在最后还会介绍科学计算领域经常使用的两个Python工具, 即IPython和Jupyter.


numpy库
----------------

Numpy是一个C语言实现的高性能计算库. 由于大部分代码以C语言实现, 因此在使用Python语言的前提下, 提供了很好的计算性能. 很多科学计算库甚至直接将numpy的对象作为接口的参数.

### 创建矩阵

numpy与MATLAB类似, 以矩阵作为核心, 以下函数用于创建numpy的数组(numpy.ndarray)


方法                 | 作用
---------------------|---------------------------
array()              | 将输入的列表(或相似类型)变成一个数组
zeros((m,n))		 | 生成一个全0的MxN的数组
ones((m,n))			 | 生成一个全1的MxN的数组
full((m,n),val)      | 生成以val的值填充的指定维度的数组
arange()			 | 参数与range相同, 产生数组
linspace(beg,end,num)| 创建一个指定范围的等分数组
concatenate()        | 合并多个数组, 组成一个新的数组
random.randn(m,n)    | 产生指定大小的符合正态分布的随机数矩阵

可以发现, Numpy提供的这些函数与MATLAB提供的基本一致, 其中的参数也基本相同. 

上面的创建数组的函数, 可以在创建时使用dtype参数指定数据类型, 否则Numpy会从输入数据自动推断合适的数据类型.

Numpy提供以下的一些方法来获得矩阵的基本信息

属性        | 作用
------------|---------------------------
ndim        | 秩, 即维度的数量
shape       | 维度信息
size        | 元素的个数
dtype       | 元素的数据类型
itemsize    | 每个元素的大小


### 数据访问

Numpy数组中的数据既支持常见的下标索引, 也支持切片表达式(array slice). 假设先执行如下代码

``` py
a = np.arange(10)
# a = 
# array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
```

则对于一维数据有如下的访问方法和访问结果:

表达式              | 结果                  | 说明
--------------------|-----------------------|--------------------------------
a[0],a[3],a[-2]     | (0, 3, 8)             | 直接访问
a[2:8:2]            | array([2, 4, 6])      | 切片
a[3:7]              | array([3, 4, 5, 6])   | 省略步长
a[:4]               | array([0, 1, 2, 3])   | 省略起始
a[6:]               | array([6, 7, 8, 9])   | 省略末尾
a[2::2]             | array([2, 4, 6, 8])   | 省略末尾
a[::3]              | array([0, 3, 6, 9])   | 省略起始和末尾


```py
b = np.arange(0,51,10).reshape(6,1) + np.arange(6)
# b = 
# array([[ 0,  1,  2,  3,  4,  5],
#        [10, 11, 12, 13, 14, 15],
#        [20, 21, 22, 23, 24, 25],
#        [30, 31, 32, 33, 34, 35],
#        [40, 41, 42, 43, 44, 45],
#        [50, 51, 52, 53, 54, 55]])
```

对于二维数据有如下的访问方法和访问结果:

表达式           | 结果                              | 说明
----------------|-----------------------------------|--------------------------------
b[0,0],b[2,-1]  | (0, 25)                           | 直接访问
b[0,2:5]        | array([2, 3, 4])                  | 切片
b[2,:]          | array([20, 21, 22, 23, 24, 25])   | 选取整行
b[:,3]          | array([ 3, 13, 23, 33, 43, 53])   | 选取整列

从这里可以看到, 对于二维数组的表达与MATLAB基本一致, 但是Numpy总是会将列向量转化为行向量. 和MATLAB一样, Numpy也支持给一个布尔矩阵作为索引, 提取符合条件的值, 例如`b[b % 2 == 0]`. 

最后需要注意, 大部分操作Numpy都是共享内存, 如果需要复制, 需要显式的调用copy方法

### 维度变换

方法                | 作用
--------------------|--------------------------------------------------------
reshape(shape)      | 不改变数组元素, 返回shape形状的数组, 原数组不变,且不拷贝数据
resize(shape)       | 与reshape类似, 但直接修改自己
swapaxes(ax1,ax2)   | 交换两个维度
flatten()           | 对数组降维, 返回平坦后的一维数组, 原数组不变, 且拷贝数据
astype              | 始终拷贝数据
tolist              | 转化为Python中的list类型

### 矩阵运算

Numpy重载了必要的运算符, 因此常用的四则运算, 比较操作等都可以直接使用.  所有的基础操作都是逐元素计算的, 因此`*`并不是矩阵乘法, 如果需要矩阵乘法, 应该使用dot()函数.

Numpy还提供了一个广播机制, 即如果两个运算对象维度不一致, 但其中一个可以扩展到相同的维度, 则自动完成维度扩展并进行计算. 例如

``` py
b = np.arange(0,51,10).reshape(6,1) + np.arange(6)
```

前一项是一个6x1的矩阵, 后一项是一个1x6的矩阵, 则两者都通过复制列或者行, 变成6x6的矩阵, 然后进行加法操作.


Numpy提供了一系列的数学函数, 与MATLAB相同, 这些函数都是以矩阵作为输入参数, 并返回结果的矩阵. 


### 加载和保存数据

方法                          | 作用
------------------------------|------------------------------------
save(filename, obj)           | 将obj以二进制写入文件
load(filename)                | 读取文件中的数据
savez(filename,obj1,obj2,...) | 将多个对象保存到一个文件之中

save和savez默认的文件后缀为`.npy`, 指定文件名时可以不指定文件后缀名. 使用load读取文件时, 必须指定文件的全名.

使用load读取savez保存的文件时, 会得到一个字典结构的对象, 其中保存了相应的对象名称和数据.

Numpy还提供了loadtxt和savetxt函数来格式化的处理文件文件. 这两个函数本身操作比较复杂, 而且不一定比pandas提供的API好用, 所以具体的使用方法在需要的时候再去学习.

pandas库
----------------

Pandas库的主要目标是对大量数据的处理. Pandas有两个核心的数据类型, 即Series和DataFrame, 两者分别用来保存一维数据和二维数据. Pandas最初用于分析财经数据, 现在已经广泛用于数据分析.

### Series

Series是类似一维数组的字典结构, 由数据和索引组成. 构造时可以只指定数据, 此时索引自动使用从0开始的数字, 从而Series可以当做数组使用. 如果额外的指定了索引, 则可以通过索引访问数据, 就如同一个字典.

属性        | 作用
------------|-----------------------
index	    | 查看索引
values 	    | 查看值

当两个Series合并时, 索引相同的数据才会合并, 只有一项的索引依然存在, 但是值被设置为NaN, 这一特性称为**数据对齐**


### DataFrame
DataFrame表示二维数据, 其中每行对应同一个索引, 而每一列对应同一个属性. DataFrame也具有数据对齐的特性, 创建和使用功能方式与Series也基本相同. 

DataFrame支持以下的属性来获得信息

属性        | 作用
------------|----------
shape       | 显示维度信息
index		| 返回索引
columns 	| 返回列名
values		| 显示值
describe	| 显示全部数据


DateFrame也支持以下的一些基本操作

方法            | 作用
----------------|-------------------------------------------------
head(n)	        | 显示前n行
tail(n)         | 显示最后n行
loc(idx,col)    | idx指定索引, col指定属性列, 两者都可以指定多个项
at()            | 参数与loc类似, 但只能选定一个值
iloc()          | 参数含义与loc相同, 但是全部数字表示(相当访问二维数组)
iat()           | 参数与at类似, 但是全部数字表示
drop()          | 删除数据

### 数据存储
对于DataFrame, 有如下的数据存储和读取方法

方法                | 作用
--------------------|-------------------------------------------
to_csv(filename)    | 将数据写到csv格式的文件中
read_csv(filename)  | 从文件读取数据

其中 CSV(Comma-Separated Values)表示逗号分隔值, 是一种数据的表示方式.



matplotlib库
----------------

matplotlib是一个绘图的库, 提供了与MATLAB几乎完全相同的函数, 据说甚至可以查阅MATLAB文档来学习matplotlib中的函数. 

### 基础设置

Matplotlib库中的pyplot子包是针对Python提供的接口, 因此通常使用`import matplotlib.pyplot as plt`来导入这个包. 

可以访问[Matplotlib使用示例补充](/notebook/UseMatplotlib.html)查看Matplotlib的绘图效果.

<!-- 此外, 如果在Jupyter中使用此库, 通常还需要执行一条魔术指令`%matplotlib inline`, 从而使绘图结果直接内嵌到netebook之中, 并且不需要调用show函数就直接绘制图形. -->

开始绘图前, 可以使用figure函数来指定图形的尺寸属性, 例如

``` py
plt.figure(figsize=(16,10),dpi=144)
```


参数    |   默认值        | 推荐最大值  | 含义
--------|----------------|------------|---------------------------
figsize | (6.4, 4.8)     | (16,10)    | 图片大小(单位为inch)
dpi     | 100            | 144        | 每英寸点数

注意: 全部使用默认参数时, 一张图片大约10KB. 使用推荐最大值时, 一张图片大约50KB

### 绘制线条

Matplotlib库主要通过plot函数完成绘图. plot前两个参数分别是x坐标和y坐标的列表, 第三个参数指定绘图样式, 可选值如下

颜色参数     | 说明              | 颜色参数   | 说明   
------------|-------------------|-----------|--------------------
b	        | blue              | m	        | magenta(品红)
g	        | green             | Y	        | yellow
r	        | red               | k	        | black
w	        | white             | c	        | cyan(青色)


散点样式     | 英文          |中文       | 线条参数       | 英文         | 中文
------------|---------------|----------|----------------|--------------|-----------------
`o`	        | circle        | 圆圈      | `-`		    | solid		    | 实线
`v`	        | triangle_down | 下箭头    | `--`		    | dashed		| 虚线
`s`	        | square        | 方形      | `-.`		    | dashed_dot	| 点线
`p`	        | pentagon	    | 五角星    | `:`		    | dotted		| 点
`*`	        | star          | 星型      | None    	    | draw nothing	| 不绘制
`h`	        | hexagon   	| 六边形    | (空格)	    | draw nothing  | 不绘制
`+`	        | plus          | 加号      | (不指定)      | draw nothing  | 不绘制
`D`	        | diamond		| 钻石      |               |               | 


绘制时, 可以从颜色参数和样式参数之中各选择一个参数. 例如`b-`表示蓝色的实线线条.

注意: 程序会根据数据的范围自动调整坐标系位置和缩放比例, 因此要注意数据的范围, 使用合适的范围.

### 标签刻度和图例

plt中有以下方法来设置图片的属性

方法            | 作用                  | 方法            | 作用
----------------|----------------------|------------------|-------------------
title	        | 设置图标题            | xlable	        | 设置x轴标题
xlim            | 设置/获得x轴刻度范围   | set_xticks      | 设置x轴刻度范围

通过`fig, ax = plt.subplots()`获得ax对象后, 可以使用ax对象设置坐标轴的刻度和标签, 具体方法如下

方法            | 作用                
----------------|---------------------
set_xticks      | 设置刻度的值
set_xticklabels | 设置刻度标签的值

上述方法的使用, 可以参考[Matplotlib使用示例补充](/notebook/UseMatplotlib.html)展示的效果.


**注意:** 上表中的x替换为y即为相应的y轴方法,例如ylim设置y轴刻度范围.


### 分块绘图

与MATLAB一样, matplotlib也提供了分块绘图函数`subplot`. 并且与MATLAB一样, 也是使用一个3位的数字或者3个数字来指定行数,列数和索引.

例如
``` py
x = np.linspace(-5,5,100)
y1 = np.sin(x)
y2 = np.cosh(x)
# 设置图像大小等参数
plt.figure(figsize=(10,5),dpi=144)
# 指定第一个区域
plt.subplot(121)
plt.plot(x,y1)
# 指定第二个区域
plt.subplot(122)
plt.plot(x,y2)
```

`subplot`可以设置如下的参数

参数        | 说明                         | 参数        | 说明
------------|-----------------------------|-------------|--------------
nrows       | subplot行数                  | ncols       | subplot列数
sharex      | 共享x轴刻度                  | sharey      | 共享y轴刻度
subplot_kw  | 创建各个subplot的关键字字典   | **fig_kw    | 创建figure的其他参数

`**fig_kw` 参数使得`subplot`支持所有`figure`的参数, 例如可以在绘图时指定图形大小

```py
plt.subplot(2,2,figsize=(10,5))
```

使用`subplots_adjust`函数可以控制subplot之间的间距, 如果需要使用此函数, 可以查阅官方文档的说明.


### 保存图表

使用`plt.savefig`保存当前图表. 参数列表如下

参数                     | 说明
------------------------|-------------------------------------------------
fname                   | 文件名, 如果指定后缀则可以自动推断保存文件的类型
dpi                     | 图像分辨率
facecolor, edgecolor    | 图像背景色, 默认为`w`(白色)
format                  | 显式指定文件类型
bbox_inches             | 图片需要保留的部分, `tight`表示裁剪周围的全部空白

Matplotlib支持各种常见的格式, 包括`png`, `pdf`, `svg`, `ps`, `eps`等, 因此使用Matplotlib就可以直接创建矢量图形, 而不需要经过额外的转换.


scikit-learn库
----------------

scikit-learn是一个机器学习工具包, 涵盖了主流的机器学习算法, 并且提供了一致的调用接口. 不过由于不支持分布式计算, scikit-learn并不用来处理大量数据.


### 加载数据集

scikit-learning提供了一些标准数据集, 包括用于分类训练的iris(Anderson's Iris data set)和digits(Pen-Based Recognition of Handwritten Digits Data Set), 用于回归训练的boston house prices dataset. 

这些数据集都位于sklearn的datasets包下, 例如可以使用如下的方式导入digits数据集

``` py
from sklearn import datasets
digits = datasets.load_digits()
```

由于此部分的Python代码并没有使用类型注解技术, 因此对于各个变量拥有哪些成员变量, IDE也无能为力, 无法进行补全. 但是在命令行中使用dir函数查看就可以容易的了解具体的成员变量,  通常都会包含`data`,`feature_names`, `target`, `target_names`等具有明显含义的成员. 此外每个数据集都提供了`DESC`变量来描述数据集的组成等信息.

### 训练与评估模型

以下代码演示使用支持向量机对digits数据集进行分类

``` py
from sklearn.model_selection import train_test_split
from sklearn import datasets
digits = datasets.load_digits()

# 分割数据集
Xtrain, Xtest, Ytrain, Ytest = train_test_split(digits.data, digits.target, test_size=0.2, random_state=2)

# 创建支持向量机并且训练
clf = svm.SVC(gamma=0.001, C=100.)
clf.fit(Xtrain, Ytrain)

# 对训练的模型进行评分
rate = clf.score(Xtest, Ytest)
print(f"rate = {rate}")
```

实际上对于scikit-learning中的所有模型评估对象都有如下的一些接口

方法        | 作用
------------|----------------------------
fit         | 训练模型
predict     | 根据数据数据进行预测
score       | 对训练的模型进行评分


更多内容可以参考以下的连接
- [scikit-learn Tutorials](https://scikit-learn.org/stable/tutorial/index.html)
- [Choosing the right estimator](https://scikit-learn.org/stable/tutorial/machine_learning_map/index.html)

### 模型保存与加载

可以使用sklearn.externals包中的joblib对象完成模型的保存和加载, 具体代码如下所示:

``` py
from sklearn.externals import joblib
# 保存到文件
joblib.dump(clf,'digits_svm.pkl')
# 从文件加载
clf2 = joblib.load('digits_svm.pkl')
```



IPython
------------


IPython实际上是一个加强的Python命令行工具, 与直接使用Python命令行相比, IPython具有代码提示, 魔术指令, 语法高亮等增强功能, 因此更适合在命令行中使用.

### 基本操作

IPython提供了一个类EMACS的快捷键方案, 比较常用的指令如下

指令     | 作用
--------|--------------------------------------
C+A     | 移动到本行的开头
C+E     | 移动到本行的末尾
C+U     | 删除光标所在位置之前的所有字符
C+K     | 删除光标所在位置以及之后的所有字符
C+L     | 清除屏幕
C+P     | 向前(Previous)移动
C+N     | 向后(Next)移动

### 魔术指令

魔术指令(The magic function)是IPython提供的一系列的指令, 这些指令可以对IPython本身或者Python进行控制. 魔术指令分为面向行的指令(line-oriented)和面向块的指令(cell-oriented). 

面向行的指令以`%`开头, 面向块的指令以`%%`开头. IPython默认启动`%automagic`, 因此输入面向行的指令时, 可以省略`%`, 但是面向块的指令始终需要以`%%`开头.

以下是一些常用的魔术指令


指令                | 效果
--------------------|---------------------------------------------
%quickref           | 显示IPython简要的文档
%magic              | 显示所有的魔术指令详细文档 
%reset              | 删除当前环境下所有的指令  
%rehashx            | 使大部分shell指令不需要`!`就直接执行
%run                | 运行一个脚本,并将其中的变量导入
%who/whos           | 显示当前的变量
%timeit             | 统计一条指令消耗的时间
%matplotlib inline  | 启用IPython对绘图的额外支持

### 帮助系统

在任意指令的开头或者结尾加上一个`?`即可查询此模块/函数的文档. 使用`??`可以查询文档和源代码(如果有源代码). 

此外, 帮助系统还支持使用`*`进行搜索, 例如`np.*load*?`将会显示numpy包中所有包含load的函数.


### 输入和输出变量

IPython中使用`_`和`__`保存了最近的两个输出结果. 每一行的输入和输出也都保存在相应的变量之中. 例如`_2`保存了第二行的输入, `_i2`保存了第二行的输出结果.

IPython的这一保存机制将导致所有的对象都始终存在引用, 而无法被垃圾回收. 如果在使用过程中会频繁的创建大对象, 注意使用%xdel来删除不必要的引用, 或者使用%reset来重置.

### 与OS交互

在IPython中可以执行任意shell指令, 只需要在相应的指令之前加上一个`!`. 一些常见的指令如下表所示

指令                 | 说明
--------------------|-------------------------------------------
`! <cmd>`           | 执行shell执行
`out = !<cmd>`      | 将shell执行结果赋值给out变量
`%bookmark`         | 启用IPython目录书签系统
`%pushd`/`%popd`    | 使用堆栈效果的目录切换
`%env`              | 显示环境变量

使用`%bookmark <name> <path>`的格式, 给`<path>`创建一个名称, 之后就可以使用`<name>`代表这个路径进行切换. bookmark的操作是自动持久化的. 使用`-l`参数可以列出所有创建的书签.


Jupyter
---------------

Jupyter notebook是一个基于Web的图形编程界面, 可以在其中编写Markdown文本和Python代码, 并且直接运行其中的代码. 除了在网页上直接展示以外, Jupyter还支持将页面保存为Markdowm, HTML, pdf 等多种格式.

在命令行中输入`jupyer notebook`来启动程序.

### 常用命令

Jupyter采用了类似VIM的键位, 因此对于VIM的常见操作(移动, 添加, 删除等)都是同样的快捷键. 下面是一些常用的指令

指令     | 作用
--------|--------------------------------------
Esc     | 进入命令模式
Enter   | 进入编辑模式
A       | 在当前Cell之上插入一个新的Cell
B       | 在当前Cell之下插入一个新的Cell
C+Enter | 执行当前Cell代码
M+Enter | 执行当前Cell代码,并且移动到下一个Cell


除了以上的指令以外, 还可以在点击`Help->Keyboard Shortcut`查看全部的快捷键, 点击`Help->User Interface Tour`查看用户界面引导.

### docker部署

Jupyter支持使用Docker部署, Jupyter团队在dockerhub提供了专用于科学计算的Docker镜像, 其中已经预制了各类常用的科学计算库, 可使用如下的配置

```yml
version: '3.0'
services:
  gitlab:
    image: jupyter/scipy-notebook:ubuntu-20.04
    container_name: jupyter-lab
    user: root
    environment: 
      TZ: Asia/Shanghai
      GRANT_SUDO: 'yes'
    ports: 
      - "8888:8888"
    volumes:
      - ./work:/home/jovyan/work
    command: start.sh jupyter lab
```

如果希望内置的用户`jovyan`具有不需要密码的root权限, 则必须配置`user: root`和`GRANT_SUDO: 'yes'`. 通常情况下, 在此镜像内安装新的Python包并不需要root权限, 获取root权限主要是为了使用`apt`工具按照其他的依赖.


- [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks)
- [Using sudo within a container](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html#using-sudo-within-a-container)
- [How to configure docker-compose.yml to up a container as root](https://stackoverflow.com/questions/48727548/how-to-configure-docker-compose-yml-to-up-a-container-as-root)


### 安装其他内核

由于Jupyter Notebook的模式非常好用, 因此有许多第三方开发了其他语言的内核, 使得Notebook可以运行其他的语言. 支持的语言可在如下的页面上查询.

- [Jupyter-kernels](https://github.com/jupyter/jupyter/wiki/Jupyter-kernels)

> 大部分常用语言(例如C, Java, Go等)以及许多非常小众的语言(例如Scheme, Prolog等)都提供了支持.

使用Notebook的模式, 可以快速的运行某个语言的代码片段, 因此非常适合作为学习新语言的工具.


我的看法
-------------

虽然只要随便搜索一下, 就可以看到很多文章推荐使用这两个工具. 但我个人的体验是这两个工具对于初学者来说, 都不太顺手. 

IPython的解释执行机制不太适合需要反复执行某一段代码的场景. 如果执行的代码都是单一的语句, 那么IPython用起来还是非常舒服的, 但如果涉及到更复杂的结构, 例如循环语句或者定义函数, 那么这种一行一行输入的模式显然就不太合适了. 对于这个问题, Jupyter有一定程度的弥补, 但Jupyter的代码补全不太好用, 如果不熟悉库的参数, Jupyter的体验就如同记事本写代码.

因此, 如果对使用的库非常熟悉了, 那么可以考虑使用Jupyter, 但如果是新学习一个库, 那么还是建议先使用一个有更友好的代码补全和文档的IDE.
