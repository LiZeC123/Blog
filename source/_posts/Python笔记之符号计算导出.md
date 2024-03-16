---
title: Python笔记之符号计算导出版
date: 2019-01-12 20:45:22
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
math: true
---


在学习机器学习等内容时, 我们经常遇到需要公式推导的情景. 但实际上我们往往只需要理解其中的概念, 具体的计算过程并不重要. 因此如果符号推导过程可以由计算机完成, 则可以节省很多时间, 从而把精力集中到最核心的部分.

在数学建模场景中, 也可能存在一些方程需要根据符号关系计算出表达式, 此时也希望计算机能实现一定程度的符号计算(例如求解方程或微分方程等), 从而将精力集中到问题分析和建模环节之中.

文本介绍Python中最常用的符号计算库, 即Sympy库. 通过该库, 我们能简单的完成各类符号计算, 从而直接求解出我们需要的结果.

导入库和设置
---------------------

由于Sympy库中主要以单独的方法为主, 较少提供类, 因此在单独使用的场景下, 可以直接导入其中所有的方法.


```python
from sympy import *
```

在NoteBook场景中, 可启用Latex输出, 使得公式具有一个较好的展示效果


```python
init_printing(use_latex=True)
```

符号与变量
----------------

### 引入变量

`sympy.abc`包内置了所有的单字符变量, 可以直接从中导入需要的变量, 例如


```python
from sympy.abc import x,y,z,a,b,c
```


```python
x,y,a,b
```




$\displaystyle \left( x, \  y, \  a, \  b\right)$



除了内置的单字符变量以外, 也可以使用`symbols`函数定义任意名称的变量, 例如


```python
Vmin, Vmax = symbols("Vmin, Vmax")
Vmin, Vmax
```




$\displaystyle \left( Vmin, \  Vmax\right)$



注意: 符号的名称和变量的名称可以不一致, 但不建议这么使用, 容易产生误解. 建议始终使符号名称与变量名称一致

### 引入函数


Sympy库已经内置了大部分常见的函数, 例如指数函数, 对数函数, 三角函数. 这些函数按照数学中常用的方式使用即可, 例如


```python
(x+sin(x)-tanh(x)) / (1 + exp(x)-log(x))
```




$\displaystyle \frac{x + \sin{\left(x \right)} - \tanh{\left(x \right)}}{e^{x} - \log{\left(x \right)} + 1}$



### 字符串转表达式

Sympy库支持使用`sympify`函数(注意是表示符号化的意思, 不是simplify)直接将一个字符串转换为对应的表达式, 例如


```python
sympify(a*x**2+b*x+c)
```




$\displaystyle a x^{2} + b x + c$



表达式变换与求值
-----------------


### 表达式替换
Sympy库使用`subs`函数将表达式中的任意部分替换为指定的部分. 此函数可以达到两个效果
1. 将表达是中的一个部分替换为另一个部分, 从而变换表达式的形式
2. 将表达式中的变量替换为常数, 从而求解表达式的值

例如给定如下的表达式


```python
expr = sin(2*x) + cos(2*x)
expr
```




$\displaystyle \sin{\left(2 x \right)} + \cos{\left(2 x \right)}$



如果考虑到恒等变换, 希望将sin函数展开, 则可以进行如下替换


```python
expr.subs(sin(2*x), 2*sin(x)*cos(x))
```




$\displaystyle 2 \sin{\left(x \right)} \cos{\left(x \right)} + \cos{\left(2 x \right)}$



如果想求解上述表达式在$x=\frac{\pi }{2} $的值, 则可以进行如下的替换


```python
expr.subs({x: pi/2})
```




$\displaystyle -1$



### 表达式求值

如果当前表达式已经是一个常量表达式, 则可以使用`evalf`防范求解任意进度的浮点值, 例如


```python
pi.evalf(20)
```




$\displaystyle 3.1415926535897932385$



表达式化简
---------------

Sympy库的核心功能之一就是表达式简化, 此功能可以对表达式进行符号运算, 从而获得最简单的表达形式. Sympy库提供了一个`simplify`函数来求解任意表达式的最简单形式. 该函数会尝试对给定的表达式引用所有内置的简化规则, 并给出一个可能的最简单结果. 例如


```python
simplify(sin(x)**2 + cos(x)**2)
```




$\displaystyle 1$



由于表达式的最简形式并无良好的定义, 因此`simplify`函数可能会消耗很长的时间才能给出结果或者给出的结果不满足需求, 因此如果能够明确具体应该执行什么类型的简化时, 应该直接调用对应的函数.

Sympy库支持多项式, 三角函数, 指数函数与对数函数, 特殊函数的简化, 具体内容可查阅官方文档[Simplification](https://docs.sympy.org/latest/tutorials/intro-tutorial/simplification.html)章节

微积分运算
--------------

Sympy库提供了完善的微积分运算支持, 可以求解导数, 积分, 极限等微积分运算

### 导数

使用`diff`函数求解一个表达式的导函数, 多次传入变量可求解多次导数, 例如


```python
f = sin(x)+x
f
```




$\displaystyle x + \sin{\left(x \right)}$




```python
f.diff(x)
```




$\displaystyle \cos{\left(x \right)} + 1$




```python
f.diff(x, x)
```




$\displaystyle - \sin{\left(x \right)}$



对于多元函数, 将按照自变量传入顺序求解偏导数, 例如


```python
f = sin(x*y) + x
f
```




$\displaystyle x + \sin{\left(x y \right)}$




```python
f.diff(x)
```




$\displaystyle y \cos{\left(x y \right)} + 1$




```python
f.diff(x, y)
```




$\displaystyle - x y \sin{\left(x y \right)} + \cos{\left(x y \right)}$



### 积分

默认情况下, Sympy按照不定积分进行计算,  例如对于如下的经典二重积分, 默认计算其不定积分的表达式


```python
f = exp(-x**2 - y**2)
f
```




$\displaystyle e^{- x^{2} - y^{2}}$




```python
integrate(f, x, y)
```




$\displaystyle \frac{\pi \operatorname{erf}{\left(x \right)} \operatorname{erf}{\left(y \right)}}{4}$



但如果在积分时指定上下限, 则也可以计算定积分, 例如


```python
integrate(f, (x, -oo, oo), (y, -oo, oo))
```




$\displaystyle \pi$



注意: 在Sympy中使用两个连续的小写字母o来表示无穷大, 即`oo`.

### 极限

使用`limit`函数求解指定表达式的极限, 例如


```python
limit(sin(x)/x, x, 0)
```




$\displaystyle 1$



### 泰勒展开

使用`series`函数可求解指定表达式在指定位置的泰勒展开表达式, 例如


```python
f = exp(x)
f
```




$\displaystyle e^{x}$




```python
f.series(x,0, 4)
```




$\displaystyle 1 + x + \frac{x^{2}}{2} + \frac{x^{3}}{6} + O\left(x^{4}\right)$



如果不需要后面的高阶无穷小, 则调用`removeO`函数移除此部分


```python
f.series(x,0, 4).removeO()
```




$\displaystyle \frac{x^{3}}{6} + \frac{x^{2}}{2} + x + 1$



求解等式
------------

Python中的赋值`=`和`==`不便于重载, 因此当需要创建一个等式的时候, 需要使用`Eq`函数. 例如



```python
Eq(x+2, 3)
```




$\displaystyle x + 2 = 3$



在求解等式的过程中, 如果一个表达式不是`Eq`函数定义的等式, 则默认求解该表达式等于0的时候的值

### 求解集

`solveset`方法返回解的集合, 因此返回结果可能是包含若干个解的集合, 也可以是由实数构成的一段连续的集合. 如果无解, 则返回一个空集, 如果无法求解, 则返回一个等式构成的条件集合. 例如


```python
solveset(x**2 - x, x)
```




$\displaystyle \left\{0, 1\right\}$




```python
solveset(sin(x) - 1, x, domain=S.Reals)
```




$\displaystyle \left\{2 n \pi + \frac{\pi}{2}\; \middle|\; n \in \mathbb{Z}\right\}$



### 解线性方程组

使用linsolve可以求解任意形式的线性方程组, 参数既可以以数组的方式传入, 也可以使用矩阵的方式传入, 例如


```python
linsolve([x + y + z - 1, x + y + 2*z - 3 ], (x, y, z))
```




$\displaystyle \left\{\left( - y - 1, \  y, \  2\right)\right\}$




```python
linsolve(Matrix(([1, 1, 1, 1], [1, 1, 2, 3])), (x, y, z))
```




$\displaystyle \left\{\left( - y - 1, \  y, \  2\right)\right\}$



### 求解非线性方程组

`solveset`方法底层使用`nonlinsolve`函数求解非线性方程组, 例如


```python
nonlinsolve([a*x**2 + b*x + c, y**2 + 1], [x, y])
```




$\displaystyle \left\{\left( - \frac{b}{2 a} - \frac{\sqrt{- 4 a c + b^{2}}}{2 a}, \  - i\right), \left( - \frac{b}{2 a} - \frac{\sqrt{- 4 a c + b^{2}}}{2 a}, \  i\right), \left( - \frac{b}{2 a} + \frac{\sqrt{- 4 a c + b^{2}}}{2 a}, \  - i\right), \left( - \frac{b}{2 a} + \frac{\sqrt{- 4 a c + b^{2}}}{2 a}, \  i\right)\right\}$



### 解微分方程

使用`dsolve`方法求解微分方程, 首先创建不定的函数对象


```python
f, g = symbols('f g', cls=Function)
f, g
```




    (f, g)



然后创建微分方程的等式, 例如


```python
diffeq = Eq(f(x).diff(x, x) - 2*f(x).diff(x) + f(x), sin(x))
diffeq
```




$\displaystyle f{\left(x \right)} - 2 \frac{d}{d x} f{\left(x \right)} + \frac{d^{2}}{d x^{2}} f{\left(x \right)} = \sin{\left(x \right)}$



最后指定函数对象来求解最终的结果


```python
dsolve(diffeq, f(x))
```




$\displaystyle f{\left(x \right)} = \left(C_{1} + C_{2} x\right) e^{x} + \frac{\cos{\left(x \right)}}{2}$



Sympy应用举例
--------------

### 拉格朗日乘数法
利用拉格朗日乘数法, 就可以求任意表达式的极值. 对于函数
$$z = f(x,y)$$
在条件
$$\varphi(x,y) = 0$$
下取得极值的必要条件, 可以按照如下的方式获得:

首先引入辅助函数
$$L(x,y)=f(x,y)+\lambda\varphi(x,y)$$
其中L(x,y)称为**拉格朗日函数**, \\( \lambda \\)称为**拉格朗日乘子**.

然后求解等式组
$$
\left\{\begin{matrix}
L_x(x_0,y_0)=0 \\ 
L_y(x_0,y_0)=0\\ 
\varphi(x_0,y_0) = 0
\end{matrix}\right.
$$

最后的解即为可能的极值点

-------

下面演示使用Sympy进行上述操作. 其中V为需要求解的目标函数, p表示约束条件, r表示拉格朗日乘子.


```python
V, a,b,c,r = symbols("V a b c r")
V = a*b*c
p = a + b +c - 20
L = V + r * p
L
```




$\displaystyle a b c + r \left(a + b + c - 20\right)$




```python
exprs = [Eq(L.diff(a),0),Eq(L.diff(b),0),Eq(L.diff(c),0),Eq(p,0)]
exprs
```




$\displaystyle \left[ b c + r = 0, \  a c + r = 0, \  a b + r = 0, \  a + b + c - 20 = 0\right]$




```python
solve(exprs,[a,b,c,r])
```




$\displaystyle \left[ \left( 0, \  0, \  20, \  0\right), \  \left( 0, \  20, \  0, \  0\right), \  \left( \frac{20}{3}, \  \frac{20}{3}, \  \frac{20}{3}, \  - \frac{400}{9}\right), \  \left( 20, \  0, \  0, \  0\right)\right]$



从求解结果可以看到, 方程一共有四个解, 结合问题的实际含义可知, 第三个解是表示最大值的解


```python
ans = 20/3
V.subs({a:ans,b:ans,c:ans})
```




$\displaystyle 296.296296296296$



### 求解不等式


```python
A,B,C,D = symbols("A B C D")
A1,B1,C1,D1 = symbols("A1 B1 C1 D1")
e1,e2 = symbols("e1 e2")
s = solve([Eq(A/C,A1/C1+e1),Eq(B/D,B1/D1+e2)],A,B)
A = s[A]
B = s[B]
A,B
```




$\displaystyle \left( \frac{A_{1} C + C C_{1} e_{1}}{C_{1}}, \  \frac{B_{1} D + D D_{1} e_{2}}{D_{1}}\right)$




```python
solve(((A+B)-(A1+B1))>0,e1,domain=S.Reals)
```




$\displaystyle C e_{1} > - \frac{A_{1} C D_{1} - A_{1} C_{1} D_{1} + B_{1} C_{1} D - B_{1} C_{1} D_{1} + C_{1} D D_{1} e_{2}}{C_{1} D_{1}}$



扩展: 偏微分方程
-----------------------


```python
a,t = symbols("a t")
T = symbols("T",cls=Function)
diffeq = Eq(a*T(x,t).diff(x,x),T(x,t).diff(t))
diffeq
```




$\displaystyle a \frac{\partial^{2}}{\partial x^{2}} T{\left(x,t \right)} = \frac{\partial}{\partial t} T{\left(x,t \right)}$




```python
# Sympy 无法求解这个方程
# pdsolve(diffeq, f(x,t))
```


```python
f = Function('f') # 表示z为x, y的函数 
z = f(x,y) 
zx = z.diff(x) 
zy = z.diff(y) 
eq = Eq(1 + (2*(zx/z)) + (3*(zy/z)), 0) 
result = pdsolve(eq) 
eq,result
```




$\displaystyle \left( 1 + \frac{2 \frac{\partial}{\partial x} f{\left(x,y \right)}}{f{\left(x,y \right)}} + \frac{3 \frac{\partial}{\partial y} f{\left(x,y \right)}}{f{\left(x,y \right)}} = 0, \  f{\left(x,y \right)} = F{\left(3 x - 2 y \right)} e^{- \frac{2 x}{13} - \frac{3 y}{13}}\right)$



扩展: 线性代数
--------------------



```python
M = Matrix([[2,-4],[4,-5],[5,-9]])
M
```




$\displaystyle \left[\begin{matrix}2 & -4\\4 & -5\\5 & -9\end{matrix}\right]$




```python
M.rref()
```




$\displaystyle \left( \left[\begin{matrix}1 & 0\\0 & 1\\0 & 0\end{matrix}\right], \  \left( 0, \  1\right)\right)$



rref()是行化简操作, 返回值是一个元组, 其中第一个元素为简化后的矩阵, 第二个元素表示每一行的枢纽元素的位置


```python
M = Matrix([[1,0,5,4],[0,1,2,3],[0,0,0,3]])
M
```




$\displaystyle \left[\begin{matrix}1 & 0 & 5 & 4\\0 & 1 & 2 & 3\\0 & 0 & 0 & 3\end{matrix}\right]$




```python
M.rref()
```




$\displaystyle \left( \left[\begin{matrix}1 & 0 & 5 & 0\\0 & 1 & 2 & 0\\0 & 0 & 0 & 1\end{matrix}\right], \  \left( 0, \  1, \  3\right)\right)$




```python
M = Matrix([[1, 2, 3, 0, 0], [4, 10, 0, 0, 1]])
M
```




$\displaystyle \left[\begin{matrix}1 & 2 & 3 & 0 & 0\\4 & 10 & 0 & 0 & 1\end{matrix}\right]$




```python
M.nullspace()
```




$\displaystyle \left[ \left[\begin{matrix}-15\\6\\1\\0\\0\end{matrix}\right], \  \left[\begin{matrix}0\\0\\0\\1\\0\end{matrix}\right], \  \left[\begin{matrix}1\\- \frac{1}{2}\\0\\0\\1\end{matrix}\right]\right]$



nullspace()返回构成nullspace的向量, 即返回向量的任意线性组合都处于nullspace
