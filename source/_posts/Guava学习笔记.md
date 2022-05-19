---
title: Guava学习笔记
date: 2021-07-30 22:53:58
categories:
tags:
    - Java
cover_picture:
---


Guava是Google开发的Java工具包, 其中提供了很多好用的Java工具类. 学习这些类的使用方法和实现原理有助于提高Java的开发效率和Java的编写水平.



Guava包功能简介
-------------------

首先简单介绍一下Guava包中每个模块的具体功能.



base包
--------

### Optional

> 表示一个可能为null的值，使用标准库中的同名类替换这个类

有很多程序的错误都是因为null值，null值缺乏明确的含义。虽然由于性能原因，在库中无法避免使用null，但在用户程序中避免使用null能够极大的减少错误的产生。

对于Map类，尤其要避免值为null，否则使用一个key获取value的时候，如果返回了null，程序无法区分是key不存在还是key存在但值为null。为了避免这种情况，最好的方式是将值不能为null的key与值为null的key隔开。这样在程序中能够唯一的确定null的含义。

对于包含null值的List，如果列表中的元素非常稀疏（null值非常多），可以考虑使用`Map<Integer, E>`代替，这样可以明确的表明哪些数据是不存在的。

对于可能返回null的方法，可以考虑使用一个更又意义的对象来表示，例如`java.math.RoundingMode`有一个`UNNECESSARY`值表示不进行舍入，这比直接返回null更具有含义。


### Preconditions

包含一组方法用于前置检查参数是否满足条件， 例如是否为空，是否位于指定的范围等等。 当条件不满足的时候抛出IllegalArgumentException等异常。

**注意：** Preconditions中方法无论是否需要打印错误信息，都会计算错误信息的表达式，因此可能导致性能问题。必要时可以退回到手动判断条件，并抛出异常的模式。

### StopWatch

一个简单的计时工具，可以用于统计代码执行之间等数据。 使用格式如下

```java
Stopwatch stopwatch = Stopwatch.createStarted();
Thread.sleep(1);
stopwatch.stop();
System.out.println(stopwatch);
```

> 直接调用toString方法转换为字符串时， StopWatch会计算流失时间并使用合适的时间单位展示


### Throwables

处理异常相关的工具类， 提供包含获取异常链条， 将异常堆栈变成字符串， 判断异常类型并重新抛出新的异常等操作。


### Joiner && Splitter

用于合并和拆分字符串的工具类。这两个工具类被设计为不可变类型，需要通过构造函数一次性指定全部需要的特性。这使得这两个类具有线程安全和可以缓存的特性。

```java
Joiner joiner = Joiner.on("; ").skipNulls();

joiner.join("Harry", null, "Ron", "Hermione");
```

-----------------

实现这一特性的方法也非常巧妙， 以Joiner为例，其`useForNull`方法通过自己构造新的Joiner类并重写其中的方法实现了特性的拓展，代码如下：

```java
  public Joiner useForNull(final String nullText) {
    checkNotNull(nullText);
    return new Joiner(this) {
      @Override
      CharSequence toString(@Nullable Object part) {
        return (part == null) ? nullText : Joiner.this.toString(part);
      }

      @Override
      public Joiner useForNull(String nullText) {
        throw new UnsupportedOperationException("already specified useForNull");
      }

      @Override
      public Joiner skipNulls() {
        throw new UnsupportedOperationException("already specified useForNull");
      }
    };
  }
```

### Strings && CharMatcher

Strings提供字符串相关的基本操作，包括判断是否为空，null与空字符串的转换，重复字符串等。 CharMatcher提供字符串匹配相关接口，例如是否为ASCII字符，是否为数字，是否为大写字母等等。


collect包
--------------

collect提供了一些扩展的集合类，已经一些对现有的集合拓展的方法。 新增的集合类中有如下的几个核心类

新增集合类            |  主要功能
--------------------|----------------------------------------------------------
BiMap               | 一个保证存储的值具有唯一性的Map，也被称为可逆表，可以提供可逆的View
MulitSet            | 可以存储重复值的集合（但仅实现Collection接口）
Multimap            | 可以存储多个值的Map，具有多种存储多个值的实现方式
Table               | 一个以行key和列key存储数据的集合，具有多种实现方式

对于已有的集合类型，collect包中也提供了相应的不可变集合与直接转发集合。



cache包
----------




io包
-------


math包
--------

math包针对基本的数据类型和BigInteger提供类扩展的数学方法， 根据不同的数据类型，提供了计算组合数，阶乘，最大公约数等功能。 



### Stats

提供了统计相关的方法， 包括计算一组数据的最大值，最小值，均值，标准差和样本差等方法，并提供了一组好用的构造函数， 使用方式如下

```java
double mean = Stats.of(1, 2, 3, 4, 3, 2, 3, 2, 1, 2, 3, 4).mean();
```

> 注意： Stats目前处于beta状态




concurrent包
-----------------







eventbus包
-----------


其他包
-----------

包名     | 主要功能
--------|----------------------------------------------------------
reflect ｜ 提供了一些反射相关的工具类，但目前都是Bata状态
escape  ｜ 提供了逃逸字符处理的工具
graph   ｜ 提供图论中相关数据结构
hash    ｜ 提供哈希值计算的工具类
html    ｜ 目前仅包含HTML逃逸字符相关的处理类
