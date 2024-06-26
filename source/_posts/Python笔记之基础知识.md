---
title: Python笔记之基础知识
date: 2018-12-30 12:09:42
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---



本文对Python语言进行一个简单的回顾, 对Python中各种语法进行了简单的介绍, 并且对帮助系统进行了测试, 从而保证在阅读Python代码时不至于遇到无法理解的语法. 在本文的最后, 介绍了Python中模块的有关内容, 以便于后续安装和使用第三方的模块.

Python基本概念
----------------

- Python有三种数值类型,即整型,浮点型以及复数类型,而且三者可以通过int(),double()和complex()函数进行转化. 
- Python的整型可以表示任意大的数字, 浮点型表示范围与其他语言一致
- Python支持幂运算, 使用 `**`表示
- Python可以使用连续的比较符号, 例如`3 < x < 5`等于`3 < x and x < 5`
- 在函数外部的变量是全局变量, 在函数内部的变量是局部变量
- 使用global语句, 可以将一个变量强制认为是全局变量

---------------------------------

- for循环采取`for <var> in <sequence>`格式, python全部都是传递引用, 因此for循环中的变量也是引用变量. 
- while语句支持接一个else语句, 当while第一次就不满足条件时跳到else语句
- if语句与其他语言相同,else if简写为elif

----------------------------------------

- 使用help函数来获得一个Object的帮助文档
- help既可以获取某个类的文档, 也可以获取某个函数的文档. 例如

``` py
>>>help（abs）
Help on built-in function abs in module builtins:

abs(x, /)
    Return the absolute value of the argument.
```

> **内置方法和标准库方法都可以通过帮助系统直接查阅说明, 比查阅在线文档更有效率**


### 异常处理

try语句完整格式如下所示:

``` py
try:
     Normal execution block
except A as e:
     Exception A handle
except B:
     Exception B handle
except:
     Other exception handle
else:
     if no exception,get here
finally:
     print("finally") 
```

--------------------


Python的异常继承结构如下所示, 其中有两点需要注意
1. 所有异常的父类是`BaseException`
2. 常见的业务相关异常的父类是`Exception`

```
BaseException
 +-- SystemExit
 +-- KeyboardInterrupt
 +-- GeneratorExit
 +-- Exception
      +-- StopIteration
      +-- StandardError
      |    +-- BufferError
      |    +-- ArithmeticError
      |    |    +-- FloatingPointError
      |    |    +-- OverflowError
      |    |    +-- ZeroDivisionError
      |    +-- AssertionError
      |    +-- AttributeError
      |    +-- EnvironmentError
      |    |    +-- IOError
      |    |    +-- OSError
      |    |         +-- WindowsError (Windows)
      |    |         +-- VMSError (VMS)
      |    +-- EOFError
      |    +-- ImportError
      |    +-- LookupError
      |    |    +-- IndexError
      |    |    +-- KeyError
      |    +-- MemoryError
      |    +-- NameError
      |    |    +-- UnboundLocalError
      |    +-- ReferenceError
      |    +-- RuntimeError
      |    |    +-- NotImplementedError
      |    +-- SyntaxError
      |    |    +-- IndentationError
      |    |         +-- TabError
      |    +-- SystemError
      |    +-- TypeError
      |    +-- ValueError
      |         +-- UnicodeError
      |              +-- UnicodeDecodeError
      |              +-- UnicodeEncodeError
      |              +-- UnicodeTranslateError
      +-- Warning
           +-- DeprecationWarning
           +-- PendingDeprecationWarning
           +-- RuntimeWarning
           +-- SyntaxWarning
           +-- UserWarning
           +-- FutureWarning
	   +-- ImportWarning
	   +-- UnicodeWarning
	   +-- BytesWarning
```

- [Python异常类的继承关系](https://blog.csdn.net/Dragonfli_Lee/article/details/52350793)

--------------------

with语句就如同Java中管理资源的try语句, with语句有如下的等价关系

``` py
with open("a.txt") as f:
	r = f.read()

<==>

f=open('file_name','r')
try:
    r=f.read()
except:
    pass
finally:
    f.close() 
```

本节可以阅读以下补充内容
- [python with关键字学习](https://www.cnblogs.com/Xjng/p/3927794.html)
- [浅谈 Python 的 with 语句](https://www.ibm.com/developerworks/cn/opensource/os-cn-pythonwith/)


Python字符串操作
-----------------
- 使用`string[i]`来访问字符串中的第i个字符
- 可以通过`string[<start>,<end>]`来返回一个字符串子串
- 可以使用负数来从右侧索引(最右侧的字符是-1,倒数第二个字符是-2)
- 使用`+`将两个字符串链接,**不支持**连接其他对象


---------------------------

从Python3.6开始, python提供一种新的字符串格式化方法, 称为f-String. 通过f-String可以直接引用变量, 例如

``` py
name = "LiZeC"
print(f"my name is {name}")
#output: my name is LiZeC
```

关于f-String有如下的一些要点
- 内部的引号可以根据需要灵活使用, 只要不发生冲突即可
- 如果需要输出大括号, 使用`{{`和`}}`表示

----------------------------

f-String格式化的采取`{content:format}`格式, 例如`{x:2.6f}`表示将x以浮点数格式输出, 且整数部分至少保留2位, 小数部分至少保留6位. 各种操作符的含义与C语言的表示方法基本相同.


关于f-string的格式化内容, 可以参考以下的文章
- [Python格式化字符串f-string概览](https://blog.csdn.net/sunxb10/article/details/81036693)


Python数据结构
-----------------

Python提供了一系列的内置数据结构, 每个数据结构都通过重载运算符等方式获得了一些简便操作, 使用`help(<name>)`可以容易的获得这些数据结构的文档.


数据结构     | 补充说明
------------|--------------------------------------------
元组(tuple) | 可以使用元组同时给多个变量赋值
列表(list)  | 可以使用in表达式判断一个元素是否位于列表之中
字典(dict)  | 通过可变参数实现了几种特殊的构造方式
集合(set)   | 重载了各种符号, 从而可以简单的进行集合操作

集合支持可变集合与不可变集合, 分别使用set()和frozenset()创建. 上述所有的数据结构都可以使用for语句进行迭代访问, 字典结构默认访问key, 可以调用items()函数来同时迭代key和value.

---------------

Python数据结构的操作可以划分为两个类别. 第一类是函数类型的API, 第二类是重载运算符构成的API. 对于大部分集合类型, 都实现了对`+`,`*`, `+=`等操作的重载, 对于集合类型, 还重载了逻辑运算符`&`, `|`等.

可以通过`dir(list)`的方法查看集合类型的所有属性, 对于其中感兴趣的属性, 可以进一步使用`help`函数查看. 例如查询list的属性, 可以看到一个平常基本没有使用过的`count`属性, 使用help函数, 可以得到相应的说明

```py
In [19]: help(list.count)
Help on method_descriptor:

count(...)
    L.count(value) -> integer -- return number of occurrences of value
```

> **对于基础类型和标准库中的方法, 使用python内置的帮助系统往往比查询在线文档能更快的获得需要的信息.**



Python函数
-----------------

Python函数的结构如下
``` py
def functionName(arg,*args,**kwargs):
    '''Doc String'''
    <body>
```

其中涉及的一些概念如下表:

名称        | 含义
------------|--------------------------------------------------------------------------------------
Doc String  | 函数开始的第一行可以使用一个字符串对函数功能进行解释, 可以使用`func.__doc__`查看
默认参数     | Python支持默认参数, 默认参数必须在所有的非默认参数列表后面
关键字参数   | 使用`参数名 = 参数值`来以任意的顺序对函数参数赋值
返回值       | 不需要定义函数返回值类型, 可以返回任何类型的数据, 可以返回多个变量(等于返回一个元组)


除了普通的参数传递以外, Python还支持两种特殊的参数传递方式
- `*args`声明了可变长位置参数, 多余的参数会构成一个元组, 放入args之中
- `**kwargs`声明了可变长关键字参数, 多余的关键字参数构成一个字典, 放入kwargs之中

``` py
def test_args(name, age, *args, **kwargs):
    print(f"name = {name},age={age},args={args},kwargs={kwargs}")


test_args(name="LiZeC", age=5, id=123321, message="mess")
test_args("LiZeC", 5, 233, "Apple")

# output:
# name = LiZeC,age=5,args=(),kwargs={'id': 123321, 'message': 'mess'}
# name = LiZeC,age=5,args=(233, 'Apple'),kwargs={}
```

### 强制位置参数与强制命名参数

对于一个如下定义的函数

```py
def f(a, b, /, c, *, d, e):
    pass
```

其中的`/`表示再此之前的参数强制使用位置参数的方式进行调用, `*`表示再此之后的参数强制使用命名参数调用. 这种表达方式在文档中非常常见, 例如
```py
Help on built-in function sorted in module builtins:

sorted(iterable, /, *, key=None, reverse=False)
    Return a new list containing all items from the iterable in ascending order.

    A custom key function can be supplied to customize the sort order, and the
    reverse flag can be set to request the result in descending order.
```

这表明了sorted需要的可迭代对象只能以位置参数的方式传入, 而后面两个参数只能以命名参数的形式传入.


Python面向对象
---------------------

Python中的一个类通常具有如下的结构

``` py
class Me(SuperName):
    'Doc String'
    def __init__(self):
        self.name = "LiZeC"
        self.age = 5

    def hello(self, to_name):
        print(f"Hello {to_name}, I am {self.name}")
```

其中涉及的一些概念如下表

名称        | 含义
------------|---------------------------------------------------------------------
self参数     | self代表类的实例,每个实例方法都需要将self作为第一个参数
`__init__`   | 构造函数, 由于Python不能直接声明变量, 因此可以在构造函数中添加属性
SuperName    | 继承的父类, Python可以多继承


在调用**实例方法**时, 例如me.hello("Alice"), 解释器会自动替换为Me.hello(me,"Alice"). 如果一个方法不包含self, 则只能作为静态方法调用. 

> 此外self并不是关键字, 仅仅是一种约定习惯


### 成员函数命名规则

命名格式    | 说明
------------|--------------------------------------------------
`_xx`       | protected变量, 使用from XX import时不会导入
`__xx`      | private变量, 仅类内部可访问,调用时名字被改变
`__xx__`    | 特列方法, 用于重载运算符或者控制特殊函数的行为


例如在Foo类中的`__boo`方法的方法名变成`Foo_boo`, 因此虽然无法直接访问`__boo`方法,但是还是可以通过`Foo_boo`方法访问.

> 通常这种重命名的方式也可以避免子类覆盖父类的私有方法

### 重载运算符

以下方法可以重载类的基本操作:

函数            | 作用                         | 函数            | 作用
----------------|-----------------------------|-----------------|--------------------------
`__init__`      | 构造函数, 在生成对象时调用    | `__del__`       | 析构函数, 释放对象时使用
`__setitem__`   | 重载使用中括号赋值的方法      | `__getitem__`   | 重载使用中括号取值的方法
`__delitem__`   | 控制使用del删除时的操作       | `__contains__`  | 重载in操作符


以下方法可以重载基本函数的返回结果:

方法            | 重载的函数   | 作用
----------------|-------------|-------------------------------------------
`__repr__`      | repr()      | 输出此类的介绍, 通常使得`eval(repr(x)) == x`为真
`__len__`       | len()       | 返回此类的长度(通常指集合类元素个数)
`__iter__`      | iter()      | 返回此类的迭代器
`__next__`      | next()      | 根据迭代器, 返回下一个元素的值
`__str__`       | str()       | 返回此类转换的字符串


此外, 还有以下的一系列函数:
`__add__`,`__sub__`,`__mul__`,`__truediv__`,`__mod__`,`__pow__`等函数,分别重载`+`,`-`,`*`,`/`等符号.
`__eq__`, `__gt__`, `__ge__`, `__lt__`, `__le__`, 分别重载`==`,`>`,`>=`等符号.

另外, 如果想要实现迭代效果, 还可以使用yield关键字, 使用此方法相当于自动实现`__iter__`和`__next__`, 并且在两次调用之间还会自动保存局部变量, 例如:

``` py
def reverse(data):
    for index in range(len(data)-1, -1, -1):
        yield data[index]
```

### 继承规则

```py
class Base:
    def __init__(self):
        self.base = 0

class A(Base):
    def __init__(self):
        Base.__init__(self)
        self.a = 1

class B(Base):
    def __init(self):
        super().__init(self)
        self.b = 2
```

需要调用父类方法时, 以父类名称加相应的函数调用父类方法并将子类的self变量传入即可, 这一调用相当于借助父类的函数在自己的self上完成相关的操作. 

> 由于成员变量默认都是公共变量, 子类可以**访问**和**覆盖**任何父类的变量, 因此子类定义的变量不要与父类变量相同


由于Python支持多继承, 因此可能出现菱形继承的情况, 为了防止祖父类被多次调用, 可以使用super关键字进行调用, 此时Python通过搜索机制使祖父类只被调用一次.

> super语法在Python 2和Python 3中不同, Python 3中使用`super().xxx`替代了Python 2中的`super(Class, self).xxx`




列表解析
------------------

列表解析是一种简单的生成一个列表的方法, 格式如下

``` py
[
<exp>   for <expr1> in <sequence1>
        for <expr2> in <sequence2>
        ...
        if <condition>
]
```

每次迭代时将产生的`<expr>`值应用到`<exp>`, 如果满足`<condition>`, 则将值放入列表, 例如

``` py
[x ** 2 for x in range(10) if x**2 < 50]
# output
# [0, 1, 4, 9, 16, 25, 36, 49]
```

列表解析本质是产生了一个可迭代的对象, 然后被list的构造函数转化为一个list. 



生成器
-------------

### 直接生成器

使用类似列表推导的语法, 但如果直接使用小括号包裹, 则按照语法是一个迭代对象, 例如

``` py
In [1]: L = [x ** 2 for x in range(10) if x**2 < 50]

In [2]: type(L)
Out[2]: list

In [3]: T = (x ** 2 for x in range(10) if x**2 < 50)

In [4]: type(T)
Out[4]: generator

In [5]: next(T)
Out[5]: 0

In [6]: next(T)
Out[6]: 1
```

### yield关键字

对于一些比较复杂的迭代过程, 可能无法简单的使用列表推导的语法来产生迭代器, 此时可以先创建一个函数来表述迭代过程, 然后将输出的语句替换为yield来创建迭代器, 例如

``` py
def fib(max):
    n, a, b = 0, 0, 1
    while n < max:
        print(b)
        a, b = b, a + b
        n = n + 1
    return 'done'
```

上述函数定义了一个斐波拉契数列, 可以依次输出输出指定返回内的斐波拉契数, 此时只需要将print语句改为yield语句, 即

``` py
def fib(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        a, b = b, a + b
        n = n + 1
    return 'done'
```

每当执行到yield语句时, Python自动将函数当前的执行状态保存, 并且返回yield后面的值, 当程序下一次访问此函数时, Python在将函数的状态恢复, 使得函数从yield语句之后继续执行.

``` py
In [16]: f = fib(100)

In [17]: f
Out[17]: <generator object fib at 0x000001B4EEB70EB8>
```


装饰器
--------------

### 基本原理与使用

Python中的装饰器类似于Spring的AOP, 即在不改变函数代码的基础上, 对函数的功能进行增强. 装饰器的一个常见的使用场景是对函数添加调用日志.

首先定义装饰器, 其代码如下

``` py
def log(func):
    @wraps(func)
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper
```

之后对于需要被装饰的函数, 按照如下的方式使用

```py
@log
def now():
    print('Hello World')
```



其中@使得下面的函数now作为参数传入log函数之中, 并使用log函数返回的函数替换now函数, 从而使now函数在外围增强了需要的功能.

----

由于now函数被替换, 因此now函数的一些元信息在替换过程中被丢失了, 这些元信息包括now函数的函数名, doc字符串等. 为了防止这些信息被丢失, 需要在wapper函数上加入`@wraps`装饰器, 此装饰器帮助我们重新恢复now函数的相关信息.

> 反正一直加上这个注解就是了

### 装饰器参数

可以注意到, 装饰器函数以被装饰的函数作为参数, 因此按照上面的方法, 装饰器函数本身并不能要求输入额外的参数了. 如果需要使装饰器可以接受参数, 可以使用类定义装饰器, 具体代码如下

```py
class authority_check:
    def __init__(self, role='ROLE_USER') -> None:
        self.role = role

    def __call__(self, func) -> Any:
        @functools.wraps(func)
        def wrapped_function(*args, **kwargs):
            # 装饰器逻辑
            func(*args, **kwargs) 

        return wrapped_function
```

这里的核心技巧是: 重载call方法并在其中返回装饰器逻辑, 从而避免多层次嵌套导致的逻辑难以理解的问题. 可以使用如下的两种形式使用装饰器:

``` py
# 无参数装饰器, 此时也必须有括号
@authority_check()
def add(x, y):
    return x + y

# 有参数装饰器
@authority_check(role="ADMIN')
def spam():
    print('Spam!')
```

- [理解 Python 装饰器看这一篇就够了](https://foofish.net/python-decorator.html)
- [第九章：元编程](https://python3-cookbook.readthedocs.io/zh_CN/latest/chapters/p09_meta_programming.html)


类型注解
----------------

从Python3.6开始, Python提供了类型注解功能, 可以为变量提供一个类型, 从而便于IDE进行语法检查. 例如

``` py
def add(a: int, b: int) -> int:
    return a + b
```

如果是集合类型, 可以导入相关的集合类型, 并且可以根据这些类型定义新的类型名称, 例如

```py
from typing import List
def read(names : List[str]) -> str :
    return names[0]

Vector = List[str]

def write(names: Vector) -> int:
    pass
```

### 函数类型

如果需要一个函数作为参数, 可以按照如下的方式定义

```py
def update(where: Callable[[dict], bool], update=Callable[[int, int], NoReturn])
```

### 可空类型和特殊类型

Python标记的类型默认是不可为None的, 如果一个变量需要为None, 则需要标注为Optional类型

```py
def f() -> Optional[str]:
    return None
```

则f函数的返回值类型为`str`并且允许返回None.

--------------

Python还提供了两种新的类型`Any`和`NoReturn`, 其中`Any`表示可以返回任意类型, 而`NoReturn`表示函数没有返回值. 这两个标记都有助于IDE对函数的调用情况进行检查.


- [Python官方文档: 26.1. typing — 类型标注支持](https://docs.python.org/zh-cn/3.6/library/typing.html)



异步编程与协程
----------------

从 Python 3.7 开始,  Python支持使用`async`和`await`关键字定义协程以使用异步编程. 一个简单的例子如下所示

```py

import asyncio
from datetime import datetime

# 使用async表示此函数是异步操作
async def say_hi_after(second, name):
    # 使用await等待其他异步操作
    print(f"{datetime.now()}: {name} -> Hi!")
    await asyncio.sleep(second)
    print(f"{datetime.now()}: {name} -> Done.")


async def main():
    print(f"{datetime.now()}:Begin Main")
    # 将多个异步任务合并成一个新的异步任务并等待结果
    await asyncio.gather(say_hi_after(1, 'Task1'), say_hi_after(2, "Task2"))
    print(f"{datetime.now()}:Finished Main")


if __name__ == '__main__':
    # 启动异步任务
    asyncio.run(main())
```

最后的执行结果如下所示

```log
13:58:21.353098:Begin Main
13:58:21.353098: Task1 -> Hi!
13:58:21.353098: Task2 -> Hi!
13:58:22.361652: Task1 -> Done.
13:58:23.357971: Task2 -> Done.
13:58:23.357971:Finished Main
```

可以注意到, 多个任务之间并没有顺序执行, 而是在发生异步操作时进行了切换. 通过这一方式Python实现了在单线程模式下的多任务效果.

### 基础概念

以`async`修饰的函数称为协程(Coroutines), 直接调用协程函数并不会执行此函数, 而是产生了一个协程对象. 大量关于协程的接口都需要使用awaitable对象, Python中协程和任务(Task)都是awaitable对象. 


### 高级API

Python异步编程的核心是`asyncio`, 其中提供了一组高级API, 名称和效果如下表所示:


API             | 作用
----------------|-------------------------------------------------------
run             | 创建一个事件循环,  启动一个协程,  然后关闭事件循环
create_task     | 开始一个异步任务(使用默认的事件循环)
await sleep     | 休眠指定的时间(秒), 放弃执行权
await gather    | 同时执行给定的多个协程
await wait_for  | 已给定的超时时间执行协程
await shield    | 防止给定的awaitable对象被取消
await wait      | 运行一组aws, 并根据设置的条件进行等待
current_task    | 返回当前的任务
all_tasks       | 返回事件循环中的所有任务
to_thread       | 以线程模式运行异步任务

### 扩展阅读

- [Coroutines and Tasks](https://docs.python.org/3/library/asyncio-task.html)
- [Python 异步编程, 看这个教程就够了~](https://zhuanlan.zhihu.com/p/75347080)



Python模块
---------------

- 使用`import <lib>`后, 可以使用库中方法的全限定名来调用
- 使用`import <lib> as <name>`后, 可以使用创建的别名来使用导入的库
- 使用`from <lib> import <func>`后, 可以直接使用导入的函数

使用import时,仅仅导入了模块的名称, 这个模块(也就是这个文件)中的任何类或者函数都需要加上模块的名称才能使用, 而使用from时, 对应的函数或者类将被直接导入.

如果一个包的内部还有子包, 则有如下的两种导入方式 :

- 使用`import sound.effects.echo`, 则需要使用完整的名称才能调用echo中的函数
- 使用`from sound.effects import echo`, 则可以直接使用echo作为前缀调用echo的函数

因此, from语句既可以导入函数, 也可以导入模块, 甚至也可以导入一个子包, 最终效果就是导入的项目可以忽略其前缀而直接使用. 而import语句永远都只导入一个名称, 而不做任何其他的工作.

### 相对导入

上一节介绍的导入方法称为绝对导入, 即所有需要导入的函数和类都从包的顶级目录指定路径. 通常情况下, 这是导入方法和类的首选方案. 但如果在构建一个复杂的包, 就可能在包内输入一个非常长的引用路径, 例如`from package1.subpackage2.subpackage3.subpackage4.module5 import function6`. 在这种情况下可以考虑使用相对导入来简化导入名称.

```py
from .some_module import some_function
from ..some_package import some_class
from . import some_class
```

相对导入的语法与相对路径的语法类似, `.`表示当前路径, `..`表示当前路径的父目录, `...`表示当前路径的祖父目录. 由于相对导入和相对位置有关, 因此一旦当前文件改变了位置, 相对路径都需要改变.

- [Python中的绝对导入和相对导入](https://python.freelycode.com/contribution/detail/1360)


### 创建模块

模块实际上就是一个.py文件, 此文件的文件名就是模块的名称. 由模块和有层次的子包组成的模块称为包. 一个具有包的项目结构如下所示:

```
graphics/
    __init__.py
    primitive/
        __init__.py
        line.py
        fill.py
        text.py
    formats/
        __init__.py
        png.py
        jpg.py
```

> 当定义一个包时, 此文件夹下必须有`__init__.py`文件, 此文件用于标识当前文件夹是一个包, 可以为空, 也可以放入一下包层次的初始化代码

`__init__.py`能够用来自动加载子模块:

```py
# graphics/formats/__init__.py
from . import jpg
from . import png
```

经过上述的导入语句后, 用户仅需要执行`import grahpics.formats`就相当于执行了`import graphics.formats.jpg`和`import graphics.formats.png`


关于模块的更多内容, 可以阅读以下内容

- [Python \__init__.py 作用详解](https://www.cnblogs.com/Lands-ljk/p/5880483.html)
- [Python包中\__init__.py作用](https://www.cnblogs.com/AlwinXu/p/5598543.html)

### 模块搜索路径

当导入一个包时, Python首先搜索内置的包中是否含有指定的名称. 如果没有则搜索sys.path中指定的路径中是否包含指定的名称. sys.path的值由以下的位置组成

- 执行文件时文件所在的目录, 或者直接执行时的当前目录
- `PYTHONPATH`的值

一个模块的子模块之间可以使用绝对路径进行引用, 例如sound的两个子包之间都可以使用`import sound.XXX`来导入sound的子包.


安装第三方库
-------------

Python提供了大量的第三方库, 一般情况下可以选择自定义安装, pip安装和文件安装, 各种安装方式的对比如下


安装方式        | 说明
---------------|-----------------------------------
pip安装         | 使用python提供的pip程序
自定义安装      | 在库所在的网站, 根据指示下载安装
文件安装        | 通过.whl文件直接安装

通常情况下, 应该优先考虑使用pip安装, 如果无法安装, 再考虑使用自定义安装, 最后考虑使用文件安装.


### pip 常用命令

指令                     | 作用
-------------------------|------------------
`install <package>`      | 安装库
`uninstall <package>`    | 卸载库
`list`		             | 列出已安装的库信息
`show <package>`         | 列出已安装的库的详细信息
`search <keyword>`	     | 通过PyPI搜索库
`help <cmdName>`         | 帮助命令


- install时可以使用`-U`参数来更新一个库
- list时可以使用`--outdated`显示可更新的库


### 库文件安装

如果需要使用库文件安装, 首选需要一个可以下载库文件的网站, 这里提供一个非官方的网站[Unofficial Windows Binaries for Python Extension Packages](http://www.lfd.uci.edu/~gohlke/pythonlibs)


下载对应的库文件后, 使用`pip install <filename>`安装


### 配置镜像

升级 pip 到最新的版本, 然后配置清华镜像为默认镜像源：

```
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```


