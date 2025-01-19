---
title: Python笔记之内置模块
date: 2019-01-01 19:48:36
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---



本文介绍Python常用的内置模块, 包括全部的内建函数(builtins), 以及文件操作, 系统功能, 进程调度和绘图等模块的基本内容.


内置函数
---------------------------

Python提供了一些重要的内置函数, 可以大致划分为如下的几组, 其中的大部分函数根据名称就可以了解含义, 因此在一个表中归纳, 少部分函数属于单独的模块, 因此在单独的表格中归纳.  所有的内置函数的详细信息可以使用Python的帮助系统, 或者查阅官方文档的[Built-in Functions](https://docs.python.org/3.6/library/functions.html)章节.


类型			| 方法
---------------|------------------------------------------------------------------------
创建数据结构	| bytearray, dict, enumerate, frozenset, list, map, set, str, tuple
数据类型转换    | complex, float, int, bool, bytes, bin, hex, oct
数值计算		| min, max, pow, round, sum, divmod
哈希值			| hash, id
迭代器			| iter, next
I/O操作         | input, open
格式化			| display, format
不常见方法		| memoryview, super, slice


元操作函数               | 说明
------------------------|-------------------------------------
compile(source,file,m)	| 编译一个指定的文件
eval() / exec()			| 将字符串视为语句或代码片段执行
dir()					| 返回对象包含的全部名字
type()					| 返回一个对象的类型
repr()                  | 获得一个对象的可读的字符串
globals()               | 获得当前状态下的所有全局变量
locals()                | 获得当前作用域下的全部局部变量

> 不建议修改globals和locals返回的变量, 这些修改可能是无效的


序列操作函数             | 说明
------------------------|----------------------------------------------------------
range(start,end,step)   | 产生一个包含start,不包含end的序列, 步长为step
reversed(seq)			| 产生一个反序的迭代器对象
sorted()				| 对给定的列表排序
filter(func,iter)		| 接受一个函数与一个可迭代对象, 产生一个过滤后的可迭代对象
map(func,iter)			| 接受一个函数与一个可迭代对象, 执行map操作
zip()                   | 将多个序列的对应元素打包成一个元组, 返回这些元组构成的列表


反射操作函数     | 说明
----------------|----------------------------------------------------------
hasattr         | 判断一个对象是否具有指定的属性
getattr         | `getattr(x,'y')` 等价于 `x.y`
setattr         | 对指定对象的指定属性进行赋值
delattr         | `delattr(x, 'y')` 等价于 `del x.y`
isinstance      | 判断**一个对象**是否指某个类型的实例
issubclass      | 判断**一个类**是否是某个类型的子类


装饰器函数       | 说明
----------------|-----------------------
classmethod     | 将函数装饰为类方法
property        | 将函数装饰为一个只读字段(直接访问函数名获得值)
staticmethod    | 将函数装饰为静态方法

> 注意: Java等语言中的类方法在Python中对应的概念是静态方法, 而不是类方法



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




Python文件处理
-----------------

### 编码与解码

函数		| 作用
------------|-------------------------------
ord() 		| 将字符转化为对于的ASCII码
chr()       | 将数组转化为对于的字符
str.encode	| 将字符串以指定的编码转化为bytes
bytes.decode| 将字节数组以指定的编码转化为文字


Python 3中默认使用UTF8进行编码, 但是也可以将字符串转化为其他编码的字节数组. 例如同样的文字, 使用不同的编码方案, 可以转化为不同的字节数组:

``` py
"中文".encode("gbk")
# Out: b'\xd6\xd0\xce\xc4'
"中文".encode("utf8")
# Out: b'\xe4\xb8\xad\xe6\x96\x87'
```

### 文件操作

```  py
	var = open(<filename>,<mode='r'><buffering=-1>)
```

使用参数与C基本相同,其中buffering为0表示不缓冲, -1为使用系统指定的缓冲区大小, 如果为正值, 则为正值指定的缓冲区大小

方法			| 作用
----------------|-------------------------------------------------------------------
open()			| 打开一个文件, 返回一个文件对象
f.read(size)	| 不使用参数则返回包含整个文件内容的字符串, 否则返回指定字节的数据
f.readline()	| 返回文件下一行的内容
f.readlines()	| 返回整个文件内容的列表, 每项是以换行符结尾的字符串
f.write()		| 把数据写入文件, 接受的对象是字符串, 可以使用str（）转换
f.writelines() 	| 接受一个列表, 将其写入文件中
f.seek()		| 文件指针偏移操作
f.close()		| 关闭文件

从提供的API来看, Python的文件操作与各种编程语言并没有太大的区别. 根据文档, open函数返回的是一个基于缓冲IO的`TextIOWrapper`, 因此开启文件时除了可以指定文件读取类型, 还可以指定缓冲区大小.

有关的函数都提供了文档, 可以使用help函数查阅. 文件使用完毕需要调用close()函数.


### 遍历文件通用代码框架

``` py
with open("somefile","r") as f:
	for line in f:
		# do something for every line.
```

因为`TextIOWrapper`中实现了迭代器相关的函数, 因此可以直接进行遍历, 相当于`f.readlines()`. 通过with语句, 实现文件的自动关闭.


### 高级API

Python的shutil提供了关于文件操作的高级API, 可以参考
- [shutil — High-level file operations — Python 3.8.1 documentation](https://docs.python.org/3/library/shutil.html)




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

总体来说, 这部分的语法与其他位置使用的格式化语法差别不大, 其中`align`部分的四个符号分别表示左对齐, 右对齐, 强制在符号后填充和居中. `type`部分表示数据的显示类型, 根据其缩写, 分别表示二进制,字符, 货币类型, 八进制, 十六进制以及字符串等. 

> 使用 help('FORMATTING') 查看内置文档

format函数可以格式化任何类型的数据(如果此类型支持), 也能够在字符串上格式化, 例如
```py
>>> format(3.1415926, '>+4.2f')
'+3.14'

>>> '{:>10s} {:>10s}'.format('Hello', 'World')
'     Hello      World'
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

```py
from collections import Iterable

def flatten(items, ignore_types=(str, bytes)):
    for x in items:
        if isinstance(x, Iterable) and not isinstance(x, ignore_types):
            yield from flatten(x)
        else:
            yield x
```

yield from 是python协程中的用法, 表示将一个可迭代对象逐元素的yield输出




Python 命令行参数
-----------------


对于基本的参数处理, 可以使用内置的sys模块, 例如

```py
import sys

print '参数个数为:', len(sys.argv), '个参数. '
print '参数列表:', str(sys.argv)
```

其中sys.argv以列表的形式包含了所有给定的命令行参数, 与其他语言中的规则一样, 其中第0个参数是文件本身.

### getopt模块

getopt模块是专门做参数解析的模块, 主要是针对需要带参数的情形, 支持短选项模式(-)和长选项模式(--), 基本用法如下

```py
opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])

for opt, arg in opts:
    if opt == '-h':
        print 'test.py -i <inputfile> -o <outputfile>'
        sys.exit()
    elif opt in ("-i", "--ifile"):
        inputfile = arg
    elif opt in ("-o", "--ofile"):
        outputfile = arg
```



Python 日志处理
-----------------

按照如下的方式导入logging库并创建logger对象

``` py
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
```

由于全局创建的对象可全局访问, 因此如果需要在其他文件中使用, 可以直接导入这个对象.

---------------------

如果需要将日志写入文件, 可以添加如下代码进行配置

```py
th = handlers.TimedRotatingFileHandler(filename=Log_File, when='midnight', backupCount=14, encoding='utf-8')
th.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
logger.addHandler(th)
```

- [Python日志库logging总结](https://juejin.im/post/5bc2bd3a5188255c94465d31)



Python OS编程
------------------------------

### 使用os库

方法			| 操作
----------------|--------------------------
getcwd()		| 获得当前工作目录
listdir(path)	| 返回指定目录下所有的文件和目录名
remove()		| 删除一个文件
removedirs(path)| 删除多个文件
chdir(path)		| 更改当前目录到指定目录
mkdir(path)		| 新建一个目录
rmdir(name)		| 删除目录
rename(old,new)	| 更改文件名

### 使用os.path库

os.path是os的一个字库, 主要负责与路径相关的操作

方法			| 作用
----------------|----------------------------------------------------------
isfile()		| 检验路径是否是一个文件
isdir()			| 检验路径是否是一个目录
exists()		| 判断路径是否存在
splitext()		| 分离扩展名（返回一个二元组, 分别包含文件名和扩展名）
split()			| 返回一个路径的目录名和文件名
dirname()		| 获得路径名
basename()		| 获得文件名
getsize()		| 获得文件大小, 单位是字节
join(path,name)	| 将路径与文件名组合获得绝对路径


### 遍历目录

```py
for root, dirs, files in os.walk('.'):
    # ...
```


os库中提供了一个walk方法, 该方法可以遍历指定目录, 使用方式如上所示. 每一轮遍历, root都指向一个目录A, dirs中保存A中所有的子目录, files保存A中的全部文件. walk函数按照深度优先的方式依次遍历所有的目录.



Python虚拟环境
----------------

根据实际体验, 在Linux系统使用conda, 在win系统使用PyCharm. 没有必要使用命令行处理

-------------

从Python3.6开始, 可以使用内置的模块创建虚拟环境, 例如

``` bash
python3 -m venv /path/to/new/virtual/environment
```

由于已经明确指定了Python的版本, 因此不会产生虚拟环境是那个Python版本的问题. 创建完成后, 进入创建的目录, 执行Script目录下的activate文件即可激活环境.

注意: 如果使用Power Shell, 应该执行`Script/activate.ps1`文件, 如果提示不能执行脚本, 可以先执行`set-executionpolicy remotesigned`




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



Python事件调度
--------------------

Python提供了sched库来实现事件调度有关的操作, sched内部维护一个事件队列, 可以安全的在多线程场景下使用. 以下是一些主要的方法

方法			| 作用
----------------|--------------------------
scheduler()		| 创建一个调度任务对象
enter()			| 加入一个事件
run()			| 运行调度任务中的全部调度事件
cancel()		| 取消某个调度事件

以下代码演示sched的基本使用, 如果需要更详细的内容, 可以查阅标准库的文档

``` py
import sched, time
s = sched.scheduler(time.time, time.sleep)
def print_time(a='default'):
    print("From print_time", time.time(), a)

def print_some_times():
    print(time.time())
    s.enter(10, 1, print_time)
    s.enter(5, 2, print_time, argument=('positional',))
    s.enter(5, 1, print_time, kwargs={'a': 'keyword'})
    s.run()
    print(time.time())

print_some_times()

# Output:
# 930343690.257
# From print_time 930343695.274 positional
# From print_time 930343695.275 keyword
# From print_time 930343700.273 default
# 930343700.276
```


Turtle
-------------------------

Turtle是一个Python内置的绘图库, 通过Turtle可以绘制简单的线条. 一些主要的方法如下所示

方法					| 含义
------------------------|-----------------------------------------------------------------------------
Tultle()				| 定义一个turtle对象, 该对象可以使用turtle的相关函数
setup(high,wide,x,y)	| 指定窗口的高和长, 并指定窗口左上角的坐标在屏幕上的坐标
seth(angle)				| 指定运动的方向, 其中angle为角度制, 数值与方向与数学定义相同
pensize(x)				| 指定运动轨迹的粗细, x为像素单位
circle(rad,angle)		| 圆形运动, rad正值表示圆心在左侧, 负值表示圆心在右侧, angle表示爬行的角度的角度值
turtle.fd(x)			| 向前爬行, x表示爬行距离



扩展阅读
----------------------

- [python3-cookbook中文版](https://python3-cookbook.readthedocs.io/zh_CN/latest/preface.html)
- [Brief Tour of the Standard Library -- Part I](https://docs.python.org/3/tutorial/stdlib.html)
- [Brief Tour of the Standard Library -- Part II](https://docs.python.org/3/tutorial/stdlib2.html)
