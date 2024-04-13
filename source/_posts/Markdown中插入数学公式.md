---
title: Markdown中插入数学公式
date: 2018-03-30 16:46:54
categories:
tags:
  - LaTeX
cover_picture: images/latex.PNG
math: true
---


在日常写文章的过程中,经常会遇到需要使用公式的情况, 在以前我都是尽量使用文字描述, 但这毕竟不能从本质解决问题, 因此我决定学习如何在Markdown中使用公式. 经过一番搜索, 发现要加入公式还是比较简单的. 本文介绍如何在Markdown中使用LaTeX公式, 并且基于此简单介绍LaTeX的数学公式语法. 学会了如何使用公式以后,Markdown基本上就可以完全替代Word了.


什么是LaTeX
--------------
本来我以为LaTex是专门用于数学公式的, 但实际上LaTeX是一个排版工具, 编写公式只是LaTeX的应用之一. 通过导入不同的包, 还可以使用LaTex来展示棋谱,化学式,乐谱,电路图等其他复杂的图示. 由于本文仅仅讨论LaTeX的数学公式, 因此其他的内容就不再展开, 具体可以参考[LaTeX的百科](https://zh.wikipedia.org/wiki/LaTeX).



Markdown中引入LaTex
--------------------

### 直接引用
如果需要在Markdown中加入LaTex公式,可以使用MathJax引擎, 在Markdown中添加MathJax引擎仅仅需要在文章的任意地方加入以下代码
``` html
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script>
```

注意: 上述地址可能在某一天失效, 可以在MathJax的[News页面](https://www.mathjax.org/news/)查看最新版的有关信息.


### 创建博客配置

可以在博客的底层代码中加入如下的配置:

```
<% if (post.math) { %>
    <!-- 启用数学公式的支持 -->
    <script type="text/javascript" src="https://lib.baomitu.com/mathjax/2.7.4/MathJax.js?config=default">
        MathJax.Hub.Config({
            tex2jax: {
                skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
                inlineMath: [['$','$'], ['\\(','\\)']],
                processEscapes: true
            }
        });
    </script>
<% } %>
```

该配置检查文章的属性中是否包含了`math`选项, 如果有则引入对应的JS文件, 并进行了一些转义配置. 配置的具体属性可参考[MathJax 与 Markdown 的究极融合](https://yihui.name/cn/2017/04/mathjax-markdown/).

> 对于事物的理解果然是螺旋上升的, 17年就存在这篇文章了, 但24年才觉得这些配置确实好用.

### 引入公式

> 2024.4.13日更新: 进行了转义配置后, 可直接使用单个美元符号表示行内公式, 从而与标准的Latex语法保持一致.

在文本中`$$公式$$`表示行间公式,`\\(公式\\)`表示行内公式. 例如以下的一段源代码

``` LaTeX
We denote the conditional probability that \\( y = y\_1\\) given \\( x = x\_1\\) as \\( P(y=y\_1|x=x\_1) \\). 

This conditional probability can be computed with the formula:

$$ P(y=y\_1|x=x\_1) = \frac{P(y=y\_1, x=x\_1)}{P(x=x\_1)} $$
```

对应的渲染效果:

We denote the conditional probability that \\( y = y\_1\\) given \\( x = x\_1\\) as \\( P(y=y\_1|x=x\_1) \\). 

This conditional probability can be computed with the formula:

$$ P(y=y\_1|x=x\_1) = \frac{P(y=y\_1, x=x\_1)}{P(x=x\_1)} $$


LaTeX语法
---------------

### 与Markdown的兼容问题
由于`_` , `*`, `{`, `}`, `\`等符号在Markdown中是特殊符号, 因此如果需要使用这些符号, 需要在前面加上转义符号`\`. 对于部分特殊的符号, 在LaTeX中也是特殊符号, 也需要转义, 则在Markdown中需要输入两次转义符号, 即`\\`.

### 角标和括号

名称    | LaTeX语法                         | 示例
-------|------------------------|-----------------------------------
上标    | `i^2`                 | \\( i^2 \\)     
下标    | `i_2`                 | \\( i_2 \\)

上标和下标,默认将这两个符号后的一个符号作为上下标, 如果需要多个符号, 则使用`{`和`}`括起来. 

由于最后的结果依然是HTML代码,而不是图片,因此不支持多层嵌套的上标和下标. 但对于一般公式而言,这也基本够用了.


**注意:** Markdown中, `_`是特殊符号, 通常情况下需要转义才能使用功能


在LaTeX中,`(`, `)`, `[` 和 `]`都不变. `{`和`}`需转义, 即使用`\\{`和`\\}`. 例如
```
$$ a(2) + b[3] = c\\{5\\} $$
```

$$ a(2) + b[3] = c\\{5\\} $$

### 特殊符号

名称    | LaTeX语法                             | 示例
-------|---------------------------------------|-----------------------------------
分数线 | `\frac {a} {b}`                        | \\(\frac {a} {b}\\) 
平方根 | `\sqrt{a*x+b}`                         | \\(\sqrt{a*x+b}\\) 
n次方根| `\sqrt[n]{a*x+b}`                      | \\(\sqrt[n]{a*x+b}\\)
积分   | `\int_a^b f(x) dx`                     | \\(\int_a^b f(x) dx\\)
极限   | `\lim_{n \rightarrow 0} \sin{x} / x`   | \\(\lim_{n \rightarrow 0} \sin{x} / x\\)
求和   | `\sum_{i=0}^n \frac{1}{i^2}`           | \\(\sum_{i=0}^n \frac{1}{i^2}\\)
求积   | `\prod_{i=0}^n \frac{1}{i^2}`          | \\(\prod_{i=0}^n \frac{1}{i^2}\\)
梯度算子|`\nabla`                                | \\(\nabla\\)
偏导数  | `\partial x`                           | \\(\partial x \\)


### 希腊字母


字母名称|大写|小写  |字母名称 |大写|小写
--------|---|-----|---------|---|-------
alpha   | Α | α   | nu      | Ν | ν  
beta    | Β | β   | xi      | Ξ | ξ  
gamma   | Γ | γ   |omicron  | Ο | ο  
delta   | Δ | δ   | pi      | Π | π   
epsilon | Ε | ε   | rho     | Ρ | ρ  
zeta    | Ζ | ζ   | sigma   | Σ | σ/ς
eta     | Η | η   | tau     | Τ | τ
theta   | Θ | θ   | upsilon | Υ | υ
iota    | Ι | ι/℩  | phi     | Φ | φ
kappa   | Κ | κ   | chi     | Χ  | χ
lambda  | Λ | λ   | psi     | Ψ  | ψ
mu      | Μ | μ   | omega   | Ω  | ω


希腊字母基本上就是`\`加上拉丁语写法,例如 \\(\Gamma\\) 的公式是`\\(\Gamma\\)`, \\(\gamma\\) 的公式是 `\\(\gamma\\)` . 通常仅仅在公式中以这样的方式输入希腊字母. 

如果仅仅是在文本中输入希腊字母, 由于使用Unicode编码, 所以这些符号可以直接输入. 所有的希腊字母及其拉丁语写法如上表所示.

### 矢量与划线

名称    | LaTeX语法                             | 示例
-------|---------------------------------------|-----------------------------------
矢量    | `\vec{a}`                            | \\( \vec{a} \\)
上划线  | `\overline{IOW}`                     | \\( \overline{IOW} \\)
下划线  | `\underline{IOW}`                    | \\( \underline{IOW} \\)

所以结合前面提到的各种符号, 现在基本可以无压力的输入一个麦克斯韦方程组了,例如

```
$$ \nabla \cdot \vec{E} = \frac {\rho} {\epsilon_0} $$
```
$$ \nabla \cdot \vec{E} = \frac {\rho} {\epsilon_0} $$

### 集合操作

名称    | LaTeX语法   | 示例             | 名称    | LaTeX语法     | 示例
-------|-------------|------------------|---------|--------------|---------------
任意    | `\forall`  | \\( \forall \\)  | 存在    | `\exists`     | \\( \exists \\)
属于    | `\in`      | \\( \in \\)      | 不属于  | `\notin`      | \\( \notin \\)
子集    | `\subset`  | \\( \subset \\)  | 子集    | `\sqsubseteq` | \\( \sqsubseteq \\)
交      | `\cup`     | \\( \cup \\)     | 并      | `\cap`         | \\( \cap \\) 

可以看到, 集合操作基本就是个符号含义的英文单词, 比较容易记忆.

### 矩阵操作

矩阵的基本形式通过使用`$$\begin{matrix}…\end{matrix}$$`来实现,例如
```
$$
  \begin{matrix}
   1 & 2 & 3 \\\\
   4 & 5 & 6 \\\\
   7 & 8 & 9
  \end{matrix} 
$$
```
$$
  \begin{matrix}
   1 & 2 & 3 \\\\
   4 & 5 & 6 \\\\
   7 & 8 & 9
  \end{matrix} 
$$

注意: 由于LaTex使用`\\`来表示换行, 因此在Markdown代码中,需要使用`\\\\`

由于上述形式中没有括号, 因此可以使用`\left`和`\right`来加入一个可变长的括号. 例如使用小括号的语法如下
```
$$
 \left(
 \begin{matrix}
   1 & 2 & 3 \\\\
   4 & 5 & 6 \\\\
   7 & 8 & 9
  \end{matrix}
  \right)  
$$
```

$$
 \left(
 \begin{matrix}
   1 & 2 & 3 \\\\
   4 & 5 & 6 \\\\
   7 & 8 & 9
  \end{matrix}
  \right) 
$$

与点结合可以产生各种带省略号的矩阵,例如
```
$$
\left[
\begin{matrix}
 1      & 2      & \cdots & 4      \\\\
 7      & 6      & \cdots & 5      \\\\
 \vdots & \vdots & \ddots & \vdots \\\\
 8      & 9      & \cdots & 0      \\\\
\end{matrix}
\right]
$$
```

$$
\left[
\begin{matrix}
 1      & 2      & \cdots & 4      \\\\
 7      & 6      & \cdots & 5      \\\\
 \vdots & \vdots & \ddots & \vdots \\\\
 8      & 9      & \cdots & 0      \\\\
\end{matrix}
\right]
$$

当然,矩阵中的元素可以是其他的公式, 虽然写起来比较麻烦,但最终还是可以得到类似如下的矩阵公式
```
$$
\left( \begin{matrix}
4 \\\\
3 
\end{matrix} \right)
=
\left( \begin{matrix}
1 & 2  \\\\
2 & -1 
\end{matrix} \right)
\left( \begin{matrix}
x  \\\\
y
\end{matrix} \right)
$$
```

<p>
$$
\left(
\begin{matrix}
4 \\\\
3 
\end{matrix}
\right)
=
\left(
\begin{matrix}
1 & 2  \\\\
2 & -1 
\end{matrix}
\right)
\left(
\begin{matrix}
x  \\\\
y
\end{matrix}
\right)
$$
</p>

### 等号对齐

使用`\begin{align}`和`\end{align}`来标记需要等号对齐, 并且在公式中, 使用&=在表示要对其的等号, 使用`\\`来换行, 例如

```
$$
\begin{align}
 Vdiag(\lambda)V^{-1} &= diag(\lambda)VV^{-1} \\\\
 &= [\lambda\_{1}v^{(1)},\lambda\_{2}v^{(2)},\cdots,\lambda\_{n}v^{(n)}]V^{-1} \\\\
 &= [Av^{(1)},Av^{(2)},\cdots,Av^{(n)}]V^{-1} \\\\
 &= AVV^{-1} \\\\
 &= A
\end{align}
$$
```

渲染效果为:

$$
\begin{align}
 Vdiag(\lambda)V^{-1} &= diag(\lambda)VV^{-1} \\\\
 &= [\lambda\_{1}v^{(1)},\lambda\_{2}v^{(2)},\cdots,\lambda\_{n}v^{(n)}]V^{-1} \\\\
 &= [Av^{(1)},Av^{(2)},\cdots,Av^{(n)}]V^{-1} \\\\
 &= AVV^{-1} \\\\
 &= A
\end{align}
$$

### 字体转化

字体      | 示例                | 效果
---------|---------------------|---------------------------------
罗马体    | `\\( \rm{A} \\)`   | \\( \rm{A} \\)
意大利体  | `\\( \it{A} \\)`   | \\( \it{A} \\)
黑体      | `\\( \bf{A} \\)`   | \\( \bf{A} \\)
花体      | `\\( \cal{A} \\)`  | \\( \cal{A} \\)
等线体    | `\\( \sf{A} \\)`   | \\( \sf{A} \\)
数学斜体　| `\\( \mit{A} \\)`  | \\( \mit{A} \\)
打字机字体| `\\( \tt{A} \\)`   | \\( \tt{A} \\)

一般情况下, 公式默认使用意大利体.


### 其他符号
LaTex也支持输入包括逻辑运算符,集合运算符等其他的符号, 由于这些符号的使用场景不多, 因此就不再逐一展示了,具体的名称可以阅读下面的参考文献: [MathJax使用LaTeX语法编写数学公式教程](https://blog.csdn.net/u013007900/article/details/50082205)



辅助输入工具
------------------

首先推荐妈咪叔提供的[LaTeX公式编辑器](https://www.latexlive.com/), 该网站除了提供点击相应符号按钮生成LaTeX代码并提供实时预览能力外, 在注册账号并登录的情况下, 还支持识别图片中的公式. 这个功能实在是非常良心, 在我写毕业论文的时候提供了很多帮助.

其次推荐[在线LaTeX公式编辑器](https://zh.numberempire.com/latexequationeditor.php), 该网站除了可在线编辑LaTeX外, 还提供了许多数学相关的工具.

针对矩阵语法比较复杂的问题, 我编写了一个小程序来完成矩阵代码的生产, 可以查看我的博客文章[如何优雅的输入矩阵公式](https://lizec.top/2019/07/03/%E5%A6%82%E4%BD%95%E4%BC%98%E9%9B%85%E7%9A%84%E8%BE%93%E5%85%A5%E7%9F%A9%E9%98%B5%E5%85%AC%E5%BC%8F/)获得程序源代码和使用说明.


特殊符号转义问题
-----------------

推荐按照[MathJax 与 Markdown 的究极融合](https://yihui.name/cn/2017/04/mathjax-markdown/)这篇文章进行调整, 足够解决大部分情况下的公式转义问题.

对于少部分更复杂的公式(例如矩阵的等式), [关于 Markdown 与 Mathjax 的冲突问题及几个解决方案](https://kingsleyxie.cn/markdown-mathjax-conflicts-and-several-solutions/)指出可以在公式外包裹`<p>`标签, 使得Markdown渲染模块完全不处理该内容. 当然, 加入p标签后, vscode的预览模块也无法解析这些公式了, 但至少保证了最后博客中可以正常渲染.


参考文献和补充
--------------------
- [Markdown中插入数学公式的方法](https://blog.csdn.net/xiahouzuoxin/article/details/26478179)
- [LaTeX 各种命令, 符号](https://blog.csdn.net/garfielder007/article/details/51646604)
- [MathJax使用LaTeX语法编写数学公式教程](https://blog.csdn.net/u013007900/article/details/50082205)
- [使用LaTeX写矩阵](https://blog.csdn.net/bendanban/article/details/44221279)
