---
title: Python笔记之高级特性
date: 2019-02-02 12:37:14
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---


本文介绍Python语言中相对比较高级的一些特性, 包括列表解析, 生成器, 函数式编程,装饰器,类型注解等.



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

可以注意到, 装饰器函数以被装饰的函数作为参数, 因此按照上面的方法, 装饰器函数本身并不能要求输入额外的参数了. 如果需要使装饰器可以接受参数, 那么需要引入一些技巧, 具体代码如下

```py
from functools import wraps, partial
import logging

def logged(func=None, level=logging.DEBUG, name=None, message=None):
    if func is None:
        return partial(logged, level=level, name=name, message=message)

    @wraps(func)
    def wrapper(*args, **kwargs):
        log.log(level, logmsg)
        return func(*args, **kwargs)

    return wrapper
```

这里的核心技巧是: 如果直接使用装饰器, 那么func参数有取值, 而其他参数为默认值, 而如果使用有参数的装饰器, 那么func为默认值None, 而其他参数有具体的取值. 那么根据func是否为None就可以判断是直接使用了装饰器还是使用了有参数的装饰器.

在装饰器使用了参数的情况下, 可以使用`partial`生成一个其他参数都被初始化了, 仅func没有初始化的偏函数, 将这个偏函数应用到被装饰的函数上, 就等价于上一节定义了基本的装饰器. 而如果装饰器没有使用参数, 也能够使用默认参数完成装饰器的功能.

最后可以使用如下的两种形式使用装饰器:

``` py
# 无参数装饰器
@logged
def add(x, y):
    return x + y

# 有参数装饰器
@logged(level=logging.CRITICAL, name='example')
def spam():
    print('Spam!')
```

- [第九章：元编程](https://python3-cookbook.readthedocs.io/zh_CN/latest/chapters/p09_meta_programming.html)
- [9.6 带可选参数的装饰器](https://python3-cookbook.readthedocs.io/zh_CN/latest/c09/p06_define_decorator_that_takes_optional_argument.html)


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

扩展阅读
------------------

- [Python教程 -廖雪峰](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)