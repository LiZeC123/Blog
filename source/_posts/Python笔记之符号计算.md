---
title: Python笔记之符号计算
date: 2019-01-12 20:45:22
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
math: true
---


在学习机器学习等内容时, 我们经常遇到需要公式推导的情景. 但实际上我们往往只需要理解其中的概念, 具体的计算过程并不重要. 因此如果符号推导过程可以由计算机完成, 则可以节省很多时间, 从而把精力集中到最核心的部分. 

文本介绍Python中两个与符号计算相关的第三方库, 即Sympy库和Linalg库. 其中Sympy库用于符号计算, Linalg库是Scipy的一个子包, 用于线性代数的计算.

本文只展示部分函数的计算结果, 更多API调用和计算结果可以参考[Sympy使用示例补充](/notebook/Python笔记之符号计算.html)

基本概念
---------------

由于Sympy库中主要以单独的方法为主, 较少提供类, 因此在单独使用的场景下, 可以直接导入其中所有的方法.

``` py
from sympy import *
```

如果在Jupyter notebook环境中使用, 还可以执行

```
init_printing(use_latex=True)
```

从而使输出变为LaTex格式, 由于notebook本身支持LaTeX格式的输出, 因此这样可以获得最佳的公式表现形式. 在IPython环境中, 使用此参数也可以获得更好的分数表达式效果.

如果需要输入LaTeX代码, 可以使用latex()函数, 直接从Python命令行输出的LaTeX代码已经正确的处理了部分转义字符的问题, 可以直接输出矩阵.

Sympy中所有的符号对象都是不可变的, 因此所有的运算都会产生新的符号对象. 


创建变量
----------------

有如下的一些方式来创建符号变量

``` py
# 简单变量可以直接导入
from sympy.abc import x,y

# 使用symbols函数导入任意的表达式
x, t, z, nu = symbols('x t z nu')

# 创建函数
f = Function('f')
g = Function('g')(x)

# 从字符串创建任意表达式
str_expr = "x**2 + 3*x - 1/2"
expr = sympify(str_expr)
```

基础运算
------------

由于Python支持运算符重载, 因此包括幂运算在内的所有算数运算都可以直接使用. 可以使用如下的两个方法将符号结果转化为数值结果.


方法示例         | 功能
----------------|------------------------------
expr.subs(x, 2) | 将x等于2带入表达式并求表达式的值 
pi.evalf(100)   | 计算表达式的结果并指定精度

`subs`方法本质是做了一个替换, 因此既可以将一个变量替换为一个常数, 也可以将一个变量替换为另外一个表达式, 甚至将一个表达式替换为另外一个表达式. 如果有多个替换, 则应该传入一个列表. 

`evalf`方法可以对表达式求任意精度的浮点结果, 例如

``` py
>>> pi.evalf(100)
3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117068
```

同时, 此函数也支持subs的替换功能, 从而能够更简单的求数值结果, 例如

``` py
>>> expr = cos(2*x)
>>> expr.evalf(subs={x: 2.4})
0.0874989834394464
```

默认情况下, `evalf`提供15位小数的精度.


微积分
---------------

方法示例                                         | 功能
------------------------------------------------|---------------------
diff(sin(x)*exp(x), x)                          | 导数
Derivative(expr, x, y)                          | 创建一个不计算的导数对象
integrate(exp(x)*sin(x) + exp(x)*cos(x), x)     | 不定积分
integrate(sin(x**2), (x, -oo, oo))              | 定积分                       
Integral(expr, x, y)                            | 创建一个不计算的积分对象
doit()                                          | 求不计算对象的实际结果
limit(sin(x)/x, x, 0)                           | 极限

更多关于极限, 扩展等内容, 可以参考官方文档的[Calculus](https://docs.Sympy.org/latest/tutorial/calculus.html)章节. 以下仅介绍导数和计算的有关内容

### 导数运算

将自变量多次传入, 可以对一个表达式求多阶导入, 例如
``` py
>>> diff(x**4, x, x, x)
24⋅x
>>> diff(x**4, x, 3)
24⋅x
```

同样, 如果要求偏导数, 也只需要按照顺序依次传入自变量即可
```
expr = exp(x*y*z)
diff(expr, x, y, y, z, z, z, z)
```

不计算结果的导数对象可以用于延迟计算或者展示中间结果. 如果Sympy对于某个表达式无法计算导数, 也会采用这种格式.

### 积分运算

默认情况下, Sympy按照不定积分进行计算, 但是也可以指定上下限来完成定积分计算. 

在Sympy中使用两个连续的小写字母o来表示无穷大, 即`oo`.

和导数计算类似, 可以传入多组积分上下限构成的元组来完成多次积分的运算, 例如一个经典的二重积分

$$ \int\_{-\infty}^\infty \int\_{-\infty}^\infty{e^{-x^2-y^2}} dxdy $$

可以执行如下的代码
```
integrate(exp(-x**2 - y**2), (x, -oo, oo), (y, -oo, oo))
```

和导数一样, 不可积分的对象会使用一个不计算的积分结果. 当然, 这个积分结果也是可以参与后续的导数运算的, 如果最后微分和积分抵消了, 则后续结果就还是一个计算后的符号对象.


求解等式
-------------------

Sympy既可以求解基本的线性方程组, 也可以求解微分方程, 一些方法如下所示


方法示例                     | 功能
--------------------------------------------------------|------------------------------
Eq(x+1,4)                                               | 创建一个等式
solveset(Eq(x**2, 1), x)                                | 求解等式的结果
linsolve([x + y + z - 1, x + y + 2*z - 3 ], (x, y, z))  | 求解线性方程组
nonlinsolve([a**2 + a, a - b], [a, b])                  | 求解非线性方程组
dsolve(diffeq, f(x))                                    | 求解微分方程

Python中的赋值`=`和`==`不便于重载, 因此当需要创建一个等式的时候, 需要使用Eq函数. 

由于理论证明, 没有通用的方法可以判断两个符号表达式是否相等. 因此如果想判断相等, 只能使用减法, 即如果A-B等于0, 则A等于B. 或者使用equals函数, 此函数通过随机选取若干点来判断两个表达式是否相等.

``` py
>>> a = cos(x)**2 - sin(x)**2
>>> b = cos(2*x)
>>> a.equals(b)
True
```

在所有的求解方法中, 如果直接传入一个表达式, 而不是一个等式, 则默认是求解表达式等于0的时候的值.

以下内容可以参考官方文档的[Solvers](https://docs.Sympy.org/latest/tutorial/solvers.html)章节
- 限定解的范围, 例如在实数范围求解
- 求解包含三角函数的非线性方程
- LambertW


### 求解集

`solveset`方法本质是返回解的集合, 因此返回结果可能是包含若干个解的集合, 也可以是由实数构成的一段连续的集合. 如果无解, 则返回一个空集, 如果无法求解, 则返回一个等式构成的条件集合.

### 线性方程组

使用`linsolve`可以求解任意形式的线性方程组, 参数既可以以数组的方式传入, 也可以使用矩阵的方式传入, 例如

``` py
linsolve(Matrix(([1, 1, 1, 1], [1, 1, 2, 3])), (x, y, z))
```

### 非线性方程组

使用`nonlinsolve`可以求解非线性方程组, 求解范围默认是复数, 如果需要, 也可以指定为实数. 如果表达式带有参数, 也可以求解基于参数的结果, 例如下面的方程中`c`是一个参数, 依然可以获得解集.

``` py
system = [a**2 + a*c, a - b]
>>> nonlinsolve(system, [a, b])
{(0, 0), (-c, -c)}
```

### 微分方程

首先创建不定的函数对象
``` py
f, g = symbols('f g', cls=Function)
```

然后创建微分方程的等式, 例如
``` py
diffeq = Eq(f(x).diff(x, x) - 2*f(x).diff(x) + f(x), sin(x))
```

最后指定函数对象来求解最终的结果
``` py
dsolve(diffeq, f(x))
```

线性代数
------------------

### 矩阵基础
方法示例                                         | 功能
------------------------------------------------|---------------------
Matrix([[1, -1], [3, 4], [0, 2]])               | 创建一个矩阵
diag(1,2,3)                                     | 创建对角线为1,2,3的对角矩阵
M.shape                                         | 获得矩阵的维度信息
M.row(0)                                        | 获得第0行的内容
M.col(-1)                                       | 获得从右数第一列的内容
M.col_del(0)                                    | 删除列
M.row_del(1)                                    | 删除行
M = M.row_insert(1, Matrix([[0, 4]]))           | 插入列
M = M.col_insert(0, Matrix([1, -2]))            | 插入行

输入多个数据时, 使用嵌套的列表, 列表中的每组数据视为矩阵的一行. 而为了方便, 单层的列表会视为一个列向量.

矩阵的加法和乘法运算可以直接使用运算符, 幂运算和逆运算也可以直接使用幂运算符号.

### 矩阵操作


方法示例                                         | 功能
------------------------------------------------|---------------------
M.T                                             | 转置
det()                                           | 求行列式
rref()                                          | 执行行化简
nullspace()                                     | 求nullsapce
columnspace()                                   | 求columnspace
eigenvals()                                     | 求特征值
eigenvects()                                    | 求特征向量
diagonalize()                                   | 求对角矩阵
pinv()                                          | 广义逆
jordan_form()                                   | 约当标准型

对于特征值, 具有如下的结构

``` py
>>> M = Matrix([[3, -2,  4, -2], [5,  3, -3, -2], [5, -2,  2, -2], [5, -2, -3,  3]])
>>> M
⎡3  -2  4   -2⎤
⎢             ⎥
⎢5  3   -3  -2⎥
⎢             ⎥
⎢5  -2  2   -2⎥
⎢             ⎥
⎣5  -2  -3  3 ⎦
>>> M.eigenvals()
{-2: 1, 3: 1, 5: 2}
```
这是一个列表, 第一个参数是特征值, 第二个参数是特征值对应的跟数量, 例如上面的结果表明M有三个特征值, 分别是-2, 3, 5, 其中-2和3只有一重根, 5有两重根.

对于对角矩阵, 方法会返回两个矩阵P和D, 使得D是一个对角矩阵, 而且有

$$ M = PDP^{-1} $$


简化表达式
----------------

方法示例                                         | 功能
------------------------------------------------|---------------------
expand(expr)                                    | 按照指数展开表达式   
factor(expr)                                    | 因式分解   


此外, Sympy还提供包括三角函数化简在内的若干方法, 由于不常用, 就不一一列举了, 详细内容可以阅读官方文档的[Simplification](https://docs.sympy.org/latest/tutorial/simplification.html)章节


扩展阅读
--------------

- [Scipy:高端科学计算](http://reverland.org/python/2012/10/22/scipy/)
- [用Python来学高数？解方程组？简直不敢相信！简直不可思议！](https://www.phpyuan.com/285188.html)
- [Welcome to SymPy’s documentation!](https://docs.sympy.org/latest/index.html)

第一篇文献写于2012年, 因此其中介绍的API可能有些变化.