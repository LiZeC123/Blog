---
title: Python笔记之高阶技巧
date: 2021-06-02 10:50:07
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---



本文主要介绍一些Python中的高级技巧, 从而使我们的代码更加pythonic. 本文的主要内容来自《Python Cookbook》3rd Edition, 可以访问[python3-cookbook](https://python3-cookbook.readthedocs.io/zh_CN/latest/preface.html)查看中文翻译版本.


基础与数据结构
--------------------------

### 星号表达式

Python可以将一个集合拆开赋值给多个变量, 如果涉及的变量比较多, 也可以使用*表示匹配任意多个字段, 例如

```py
first, *middle, last = grades   # 将成绩的第一个数据和最后一个数据取出, 其他数据存放在middle之中
record = ('Dave', 'dave@example.com', '773-555-1212', '847-555-1212')
name, email, *phone_numbers = record    # 将剩余的字段复制给phone_numbers
```

使用*表达式产生的字段必然是列表类型, 而且这个字段允许匹配0个数据. 因此可以始终按照集合类型处理这些字段, 而不必考虑空值问题.


### 字典的键映射多个值

解决方案: 将list或者set作为字典的值. 为了方便使用, 可以使用`collections`模块中的`defaultdict`

```py
from collections import defaultdict

d = defaultdict(list)
d['a'].append(1)
d['a'].append(2)
d['b'].append(4)

d = defaultdict(set)
d['a'].add(1)
d['a'].add(2)
d['b'].add(4)
```

### 命名切片

切片是可以作为一个变量的, 因此可以将一个切片赋值给一个变量, 从而使切片具有含义. 这避免了硬编码大量magic number.

```py
######    0123456789012345678901234567890123456789012345678901234567890'
record = '....................100 .......513.25 ..........'
cost = int(record[20:23]) * float(record[31:37])
```

上面的代码可以修改为:

```py
SHARES = slice(20, 23)
PRICE = slice(31, 37)
cost = int(record[SHARES]) * float(record[PRICE])
```


### 命名元组

使用`namedtuple`方法可以将一个元组绑定到一个给定的字段列表上. 其本质是创建了一个类并实现了元组的所有操作, 从而既可以按照字段访问变量, 又支持元组的所有操作.

```py
from collections import namedtuple
Subscriber = namedtuple('Subscriber', ['addr', 'joined'])
sub = Subscriber('jonesy@example.com', '2012-10-19')
```

之后可以按照类的方式访问需要的字段

```py
>>> sub.addr
'jonesy@example.com'
>>> sub.joined
'2012-10-19'
```

> 命名元组可以作为字典的替代选项. 且具有不可变且内存消耗更小的优势



字符串和文本
-------------------

### 通配符匹配

如果在某些时候需要使用一些简单的通配符匹配, 同时又不需要引入正则表达式, 那么可以使用`fnmatch`库实现这一功能. 例如

```py
>>> from fnmatch import fnmatch, fnmatchcase
>>> fnmatch('foo.txt', '*.txt')
True
>>> fnmatch('foo.txt', '?oo.txt')
True
>>> fnmatch('Dat45.csv', 'Dat[0-9]*')
True
>>> names = ['Dat1.csv', 'Dat2.csv', 'config.ini', 'foo.py']
>>> [name for name in names if fnmatch(name, 'Dat*.csv')]
['Dat1.csv', 'Dat2.csv']
```

### 字符串对齐

Python提供了`ljust()`, `rjust()`和`center()`方法来提供字符串的对齐操作, 例如
```py
>>> text = "Hello"
>>> text.ljust(20)
'Hello               '
>>> text.rjust(20)
'               Hello'
>>> text.center(20, '*')
'*******Hello********'
```

---------------------------

更加一般地, 可以使用format函数进行格式化, 例如

```py
>>> format(text, '=>20s')
'===============Hello'
>>> format(text, '*^20s')
'*******Hello********'
```

其中format函数的第二个参数用于控制格式化的样式(format_spec). 其基本结构为

```
format_spec     ::= [[fill]align][sign][#][0][width][grouping_option][.precision][type]
fill            ::= <any character>         
align           ::= "<" | ">" | "=" | "^"
sign            ::= "+" | "-" | " "
width           ::= digit+
grouping_option ::= "_" | ","
precision       ::= digit+
type            ::= "b" | "c" | "d" | "e" | "E" | "f" | "F" | "g" | "G" | "n" | "o" | "s" | "x" | "X" | "%"
```

总体来说, 这部分的语法与其他位置使用的格式化语法差别不大, 其中`align`部分的四个符号分别表示左对齐, 右对齐, 强制在付好后填充和居中. `type`部分表示数据的显示类型, 根据其缩写, 分别表示二进制,字符, 货币类型, 八进制, 十六进制以及字符串等. 

> 使用 help('FORMATTING') 查看内置文档

format函数可以格式化任何类型的数据(如果此类型支持), 也能够在字符串上格式化, 例如
```py
>>> format(3.1415926, '>+4.2f')
'+3.14'

>>> '{:>10s} {:>10s}'.format('Hello', 'World')
'     Hello      World'
```



数字运算
----------------------


### 分数运算

Python中提供了Fraction类用于分数运算, 例如

```py
>>> from fractions import Fraction
>>> a = Fraction(5, 4)
>>> b = Fraction(7, 16)
>>> print(a + b)
27/16
>>> print(a * b)
35/64

>>> # Getting numerator/denominator
>>> c = a * b
>>> c.numerator
35
>>> c.denominator
64

>>> # Converting to a float
>>> float(c)
0.546875

>>> # Limiting the denominator of a value
>>> print(c.limit_denominator(8))
4/7

>>> # Converting a float to a fraction
>>> x = 3.75
>>> y = Fraction(*x.as_integer_ratio())
>>> y
Fraction(15, 4)
>>>
```


迭代
-----------------


### 同时迭代多个序列


```
>>> a = [1, 2, 3]
>>> b = ['w', 'x', 'y', 'z']
>>> for i in zip(a,b):
...     print(i)
...
(1, 'w')
(2, 'x')
(3, 'y')
```

```
>>> from itertools import zip_longest
>>> for i in zip_longest(a,b):
...     print(i)
...
(1, 'w')
(2, 'x')
(3, 'y')
(None, 'z')

>>> for i in zip_longest(a, b, fillvalue=0):
...     print(i)
...
(1, 'w')
(2, 'x')
(3, 'y')
(0, 'z')
```


基于zip的这一特性, 也可以用于将两个list对应的转化为dict（dictd的构造函数接受zip的输出）


### 不同集合上迭代

如果需要在多个集合上执行同样的操作, 可以使用chain函数将多个集合链接起来, 一次性的迭代处理

```
>>> from itertools import chain
>>> a = [1, 2, 3, 4]
>>> b = ['x', 'y', 'z']
>>> for x in chain(a, b):
... print(x)
...
1
2
3
4
x
y
z
>>>
```


从而避免在两个集合上分别执行两次迭代操作


### 展开嵌套集合

from collections import Iterable

def flatten(items, ignore_types=(str, bytes)):
    for x in items:
        if isinstance(x, Iterable) and not isinstance(x, ignore_types):
            yield from flatten(x)
        else:
            yield x


yield from 是python协程中的用法, 表示将一个可迭代对象逐元素的yield输出



