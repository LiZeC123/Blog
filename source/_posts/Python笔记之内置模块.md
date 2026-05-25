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

以下是根据你原有内容及最新 Python 3 特性重写的完整文档，可直接替换博客原文。文档中所有函数均附**典型签名**与**简短说明**，并删除了无效的 `display`，补充了遗漏的常用内置函数。

---

### 类型工厂（创建对象）

这些函数用于创建或转换数据类型。

| 函数        | 典型签名                                         | 说明                                  |
| ----------- | ------------------------------------------------ | ------------------------------------- |
| `bytearray` | `bytearray([source[, encoding[, errors]]])`      | 返回一个可变的字节序列                |
| `bytes`     | `bytes([source[, encoding[, errors]]])`          | 返回一个不可变的字节序列              |
| `dict`      | `dict(**kwargs)` 或 `dict(mapping, **kwargs)`    | 创建字典                              |
| `frozenset` | `frozenset([iterable])`                          | 创建不可变集合                        |
| `list`      | `list([iterable])`                               | 创建列表                              |
| `set`       | `set([iterable])`                                | 创建集合                              |
| `str`       | `str(object='')` 或 `str(b'', encoding='utf-8')` | 创建字符串                            |
| `tuple`     | `tuple([iterable])`                              | 创建元组                              |
| `bool`      | `bool([x])`                                      | 将 `x` 转换为布尔值（`True`/`False`） |
| `int`       | `int([x], base=10)`                              | 将数字或字符串转换为整数              |
| `float`     | `float([x])`                                     | 将数字或字符串转换为浮点数            |
| `complex`   | `complex([real[, imag]])`                        | 创建复数                              |
| `bin`       | `bin(x)`                                         | 整数转二进制字符串（如 `'0b101'`）    |
| `hex`       | `hex(x)`                                         | 整数转十六进制字符串（如 `'0xff'`）   |
| `oct`       | `oct(x)`                                         | 整数转八进制字符串（如 `'0o77'`）     |
| `chr`       | `chr(i)`                                         | 将 Unicode 码位（整数）转换为字符     |
| `ord`       | `ord(c)`                                         | 将字符转换为 Unicode 码位（整数）     |


### 迭代器与可迭代对象处理

这些函数用于操作迭代器、生成惰性序列或处理可迭代对象。

| 函数        | 典型签名                                      | 说明                                                                                   |
| ----------- | --------------------------------------------- | -------------------------------------------------------------------------------------- |
| `enumerate` | `enumerate(iterable, start=0)`                | 返回一个迭代器，产生 `(index, element)` 元组                                           |
| `map`       | `map(func, *iterables)`                       | 将 `func` 应用于每个元素并返回迭代器（Python 3 中不再返回列表）                        |
| `filter`    | `filter(function, iterable)`                  | 返回使 `function` 为真的元素迭代器；若 `function` 为 `None`，则过滤掉假值              |
| `zip`       | `zip(*iterables, strict=False)`               | 聚合各可迭代对象中的对应元素为元组迭代器；`strict=True` 时要求长度相等（Python 3.10+） |
| `range`     | `range(stop)` 或 `range(start, stop[, step])` | 返回一个不可变的等差数列对象（惰性，Python 3 中不再返回列表）                          |
| `reversed`  | `reversed(seq)`                               | 返回反向迭代器，要求 `seq` 支持 `__reversed__()` 或序列协议                            |
| `iter`      | `iter(object[, sentinel])`                    | 从可迭代对象获取迭代器；若提供 `sentinel`，则反复调用 `object` 直至返回 `sentinel`     |
| `next`      | `next(iterator[, default])`                   | 返回迭代器的下一项；若耗尽且提供了 `default`，则返回它，否则抛出 `StopIteration`       |
| `slice`     | `slice(stop)` 或 `slice(start, stop[, step])` | 创建一个切片对象，可用于自定义类的索引操作                                             |


### 数值与序列计算

这些函数用于数学计算、聚合或比较。

| 函数     | 典型签名                                                              | 说明                                                              |
| -------- | --------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `min`    | `min(iterable, *[, key, default])`<br>`min(arg1, arg2, *args[, key])` | 返回最小值；可指定 `key` 函数和 `default`（避免空可迭代对象异常） |
| `max`    | 同上                                                                  | 返回最大值                                                        |
| `sum`    | `sum(iterable, /, start=0)`                                           | 对可迭代对象求和，可以加 `start` 初始值                           |
| `pow`    | `pow(base, exp[, mod])`                                               | 计算 `base` 的 `exp` 次幂；若提供 `mod`，则计算模幂（效率更高）   |
| `round`  | `round(number[, ndigits])`                                            | 四舍五入到指定小数位（**银行家舍入**：.5 时向偶数取整）           |
| `divmod` | `divmod(a, b)`                                                        | 返回 `(a // b, a % b)` 元组                                       |
| `abs`    | `abs(x)`                                                              | 返回绝对值                                                        |
| `len`    | `len(s)`                                                              | 返回对象长度（元素个数）                                          |
| `sorted` | `sorted(iterable, *, key=None, reverse=False)`                        | 返回一个已排序的**新列表**（不修改原可迭代对象）                  |
| `all`    | `all(iterable)`                                                       | 若所有元素均为真（或可迭代对象为空），返回 `True`                 |
| `any`    | `any(iterable)`                                                       | 若任一元素为真，返回 `True`；空可迭代对象返回 `False`             |


### 内省与反射

这些函数用于在运行时检查对象类型、属性、变量等。

| 函数         | 典型签名                                    | 说明                                                          |
| ------------ | ------------------------------------------- | ------------------------------------------------------------- |
| `type`       | `type(object)`<br>`type(name, bases, dict)` | 返回对象的类型；也可动态创建新类                              |
| `isinstance` | `isinstance(obj, classinfo)`                | 判断 `obj` 是否为 `classinfo`（可以是元组）的实例             |
| `issubclass` | `issubclass(cls, classinfo)`                | 判断 `cls` 是否为 `classinfo` 的子类                          |
| `hasattr`    | `hasattr(obj, name)`                        | 判断对象是否有指定属性                                        |
| `getattr`    | `getattr(obj, name[, default])`             | 获取属性值；若不存在且未提供 `default`，抛出 `AttributeError` |
| `setattr`    | `setattr(obj, name, value)`                 | 设置对象属性值                                                |
| `delattr`    | `delattr(obj, name)`                        | 删除对象属性，等价于 `del obj.name`                           |
| `dir`        | `dir([object])`                             | 返回对象的所有属性名称列表；无参数时返回当前作用域中的名称    |
| `vars`       | `vars([object])`                            | 返回对象的 `__dict__` 属性；无参数时返回当前局部变量字典      |
| `globals`    | `globals()`                                 | 返回当前全局符号表的字典（**不建议修改**内部变量）            |
| `locals`     | `locals()`                                  | 返回当前局部符号表的字典（在函数内部修改该字典通常无效）      |
| `id`         | `id(object)`                                | 返回对象的唯一标识（通常是内存地址）                          |
| `hash`       | `hash(object)`                              | 返回对象的哈希值（要求对象不可变）                            |
| `callable`   | `callable(object)`                          | 判断对象是否可调用（如函数、类、实现了 `__call__` 的对象）    |

### 动态代码执行与编译

这些函数用于动态编译、执行或求值 Python 代码。

| 函数      | 典型签名                                                           | 说明                                                                        |
| --------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| `compile` | `compile(source, filename, mode, flags=0, ...)`                    | 将源码编译为代码对象或 AST 对象；`mode` 可为 `'exec'`、`'eval'`、`'single'` |
| `eval`    | `eval(expression[, globals[, locals]])`                            | 求值一个表达式（如 `'3+5'`）并返回结果；不能执行语句                        |
| `exec`    | `exec(object[, globals[, locals]])`                                | 动态执行 Python 代码（语句或代码块），**无返回值**（或返回 `None`）         |
| `repr`    | `repr(object)`                                                     | 返回对象的“官方”字符串表示，通常可用于 `eval()` 重新创建该对象              |
| `ascii`   | `ascii(object)`                                                    | 类似 `repr()`，但将非 ASCII 字符转义为 `\uxxxx` 形式                        |
| `print`   | `print(*objects, sep=' ', end='\n', file=sys.stdout, flush=False)` | 打印对象，可指定分隔符、结束符、输出文件和是否刷新缓冲区                    |
| `input`   | `input([prompt])`                                                  | 从标准输入读取一行字符串（Python 3 中不会自动 `eval`）                      |

> **安全警告**：`eval()` 和 `exec()` 可以执行任意代码，切勿用于处理未信任的用户输入！


### 输入输出与对象序列化

这些函数用于文件操作、内存视图和特殊对象支持。

| 函数           | 典型签名                                                                                                  | 说明                                                                                |
| -------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `open`         | `open(file, mode='r', buffering=-1, encoding=None, errors=None, newline=None, closefd=True, opener=None)` | 打开文件并返回文件对象；建议明确指定 `encoding` 参数（如 `'utf-8'`）                |
| `memoryview`   | `memoryview(obj)`                                                                                         | 创建一个内存视图对象，用于零拷贝访问支持缓冲区协议的对象（如 `bytes`、`bytearray`） |
| `super`        | `super([type[, object-or-type]])`                                                                         | 返回一个代理对象，用于调用父类的方法（Python 3 中可无参数调用，自动推断类和实例）   |
| `property`     | `property(fget=None, fset=None, fdel=None, doc=None)`                                                     | 创建属性，支持装饰器用法（`@property`、`@方法名.setter`）                           |
| `classmethod`  | `classmethod(function)`                                                                                   | 将方法转换为类方法，第一个参数为 `cls`（类本身）                                    |
| `staticmethod` | `staticmethod(function)`                                                                                  | 将方法转换为静态方法，无特殊隐式参数                                                |
| `breakpoint`   | `breakpoint(*args, **kws)`                                                                                | 进入调试器（Python 3.7+），默认调用 `pdb.set_trace()`                               |
| `help`         | `help([object])`                                                                                          | 启动内置帮助系统，或输出对象的帮助信息                                              |

---

### 装饰器与描述符

- **`classmethod`** 和 **`staticmethod`** 常用于定义不需要实例（或只需要类）的方法。
- **`property`** 可将方法转换为属性访问，实现 getter/setter。
- 三者均可作为装饰器使用，例如：

```python
class MyClass:
    @classmethod
    def factory(cls):
        return cls()
    
    @staticmethod
    def helper():
        return 42
    
    @property
    def value(self):
        return self._value
```





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

| 函数         | 作用                             |
| ------------ | -------------------------------- |
| ord()        | 将字符转化为对于的ASCII码        |
| chr()        | 将数组转化为对于的字符           |
| str.encode   | 将字符串以指定的编码转化为bytes  |
| bytes.decode | 将字节数组以指定的编码转化为文字 |


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

| 方法           | 作用                                                             |
| -------------- | ---------------------------------------------------------------- |
| open()         | 打开一个文件, 返回一个文件对象                                   |
| f.read(size)   | 不使用参数则返回包含整个文件内容的字符串, 否则返回指定字节的数据 |
| f.readline()   | 返回文件下一行的内容                                             |
| f.readlines()  | 返回整个文件内容的列表, 每项是以换行符结尾的字符串               |
| f.write()      | 把数据写入文件, 接受的对象是字符串, 可以使用str（）转换          |
| f.writelines() | 接受一个列表, 将其写入文件中                                     |
| f.seek()       | 文件指针偏移操作                                                 |
| f.close()      | 关闭文件                                                         |

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

| 方法             | 操作                             |
| ---------------- | -------------------------------- |
| getcwd()         | 获得当前工作目录                 |
| listdir(path)    | 返回指定目录下所有的文件和目录名 |
| remove()         | 删除一个文件                     |
| removedirs(path) | 删除多个文件                     |
| chdir(path)      | 更改当前目录到指定目录           |
| mkdir(path)      | 新建一个目录                     |
| rmdir(name)      | 删除目录                         |
| rename(old,new)  | 更改文件名                       |

### 使用os.path库

os.path是os的一个字库, 主要负责与路径相关的操作

| 方法            | 作用                                                 |
| --------------- | ---------------------------------------------------- |
| isfile()        | 检验路径是否是一个文件                               |
| isdir()         | 检验路径是否是一个目录                               |
| exists()        | 判断路径是否存在                                     |
| splitext()      | 分离扩展名（返回一个二元组, 分别包含文件名和扩展名） |
| split()         | 返回一个路径的目录名和文件名                         |
| dirname()       | 获得路径名                                           |
| basename()      | 获得文件名                                           |
| getsize()       | 获得文件大小, 单位是字节                             |
| join(path,name) | 将路径与文件名组合获得绝对路径                       |


### 遍历目录

```py
for root, dirs, files in os.walk('.'):
    # ...
```


os库中提供了一个walk方法, 该方法可以遍历指定目录, 使用方式如上所示. 每一轮遍历, root都指向一个目录A, dirs中保存A中所有的子目录, files保存A中的全部文件. walk函数按照深度优先的方式依次遍历所有的目录.



Python虚拟环境
----------------

从Python3.6开始, 可以使用内置的模块创建虚拟环境, 例如

``` bash
python3 -m venv .venv
```

由于已经明确指定了Python的版本, 因此不会产生虚拟环境是那个Python版本的问题. 此操作会在当前目录下创建一个`.venv`目录, 其中包含虚拟环境相关的全部内容. 

> 由于该目录以`.`开头, 因此通常情况下对于shell来说是不可见的.

创建完成后, 进入创建的目录, 执行`bin`目录(Linix/Mac)或者`Script`目录(WIndows)下的activate文件即可激活环境. 对于Vscode, 如果其识别到当前项目存在虚拟环境, 那么在打开shell时会自动执行对应的`activate`指令

注意: 如果使用Power Shell, 应该执行`Script/activate.ps1`文件, 如果提示不能执行脚本, 可以先执行`set-executionpolicy remotesigned`

- [Virtual Environments and Packages](https://docs.python.org/3/tutorial/venv.html)

---

现在已经Python 3.14了, 相比于最初的Python 3.6, 在虚拟环境方面多了许多工具, 例如`conda`和`uv`, 虽然`uv`更加先进, 但对于一个只有少量依赖的web项目来说, 直接使用`venv`反而是更好的选择, 尤其是考虑到如果需要进行CI/CD集成和打包部署时, 能直接使用而无需安装额外的模块是重要的需求.





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

| 方法        | 作用                         |
| ----------- | ---------------------------- |
| scheduler() | 创建一个调度任务对象         |
| enter()     | 加入一个事件                 |
| run()       | 运行调度任务中的全部调度事件 |
| cancel()    | 取消某个调度事件             |

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

| 方法                 | 含义                                                                             |
| -------------------- | -------------------------------------------------------------------------------- |
| Tultle()             | 定义一个turtle对象, 该对象可以使用turtle的相关函数                               |
| setup(high,wide,x,y) | 指定窗口的高和长, 并指定窗口左上角的坐标在屏幕上的坐标                           |
| seth(angle)          | 指定运动的方向, 其中angle为角度制, 数值与方向与数学定义相同                      |
| pensize(x)           | 指定运动轨迹的粗细, x为像素单位                                                  |
| circle(rad,angle)    | 圆形运动, rad正值表示圆心在左侧, 负值表示圆心在右侧, angle表示爬行的角度的角度值 |
| turtle.fd(x)         | 向前爬行, x表示爬行距离                                                          |



扩展阅读
----------------------

- [python3-cookbook中文版](https://python3-cookbook.readthedocs.io/zh_CN/latest/preface.html)
- [Brief Tour of the Standard Library -- Part I](https://docs.python.org/3/tutorial/stdlib.html)
- [Brief Tour of the Standard Library -- Part II](https://docs.python.org/3/tutorial/stdlib2.html)
