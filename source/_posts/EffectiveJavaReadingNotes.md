---
title: Effective Java Reading Notes
date: 2019-07-18 09:13:03
categories:
tags:
    - Java
cover_picture: images/java.jpg
toc: false
---

The book, "*Effective Java*",  is designed to help us make the most effective use of the Java programming language and its fundamental libraries. And this is the reading notes of that book. 

I am not sure what will be written in the note, but there are two reason for me to write:

1. learning the most effective use of Java
2. learning the expression of English

~~Therefor, this article's grammar may not be fully correct. I will try my best to ensure the expression of this note is correct and clear.~~

然而事实证明, 想要一步完成阅读和笔记是不可能的, 勉强完成也没有效率的. 由于目前的英语水平还没有达到流畅表达的地步, 因此强行使用英文只会变成抄写摘要. 所以, 在之后的内容中, 我考虑按照两个步骤完成这篇文章. 第一阶段, 使用中文总结每个部分的主要内容. ~~第二阶段, 将中文表述转换为英文.~~ 咱就是说中国人不难为中国人了, 用英文写并没有什么意义呢. 能看懂英文就行了, 真要用英文交流不还有翻译软件呢.



Content
--------------
- 创建和销毁对象
    - [Item 1 使用静态工厂方法代替构造器](#Item-1)
    - [Item 2 面对很多构造器参数时使用builder模式](#Item-2)
    - [Item 3 单例模式使用私有构造器或枚举](#Item-3)
    - [Item 4 不可实例化的类强制使用私有构造函数](#Item-4)
    - [Item 5 使用依赖注入来管理资源](#Item-5)
    - [Item 6 避免创建不必要的对象](#Item-6)
    - [Item 7 消除无效的引用](#Item-7)
    - [Item 8 避免使用finalizers和cleaners](#Item-8)
    - [Item 9 使用try-with-resources替代try-finally](#Item-9)
- 对象的共有方法
    - [Item 10 重写equals方法的规则](#Item-10)
    - [Item 11 重写equals的同时重写hashCode方法](#Item-11)
    - [Item 12 始终重写toString方法](#Item-12)
    - [Item 13 谨慎的重写clone方法](#Item-13)
    - [Item 14 考虑实现Comparable接口](#Item-14)
- 类和接口
    - [Item 15 最小化类和成员的可见性](#Item-15)
    - [Item 16 在public类使用访问器而不是public字段](#Item-16)
    - [Item 17 最小化可变性](#Item-17)
    - [Item 18 组合优于继承](#Item-18)
    - [Item 19 设计并说明继承否则禁止继承](#Item-19)
    - [Item 20 接口优于抽象类](#Item-20)
    - [Item 21 为后续设计接口](#Item-21)
    - [Item 22 只使用接口定义类型](#Item-22)
    - [Item 23 继承优于Tagged类](#Item-23)
    - [Item 24 使用静态成员类替代非静态成员类](#Item-24)
    - [Item 25 一个文件只定义一个顶级类](#Item-25)  
- 泛型
    - [Item 26 不要使用原始类型](#Item-26)
    - [Item 27 消除unchecked警告](#Item-27)
    - [Item 28 偏向使用list而不是array](#Item-28)
    - [Item 29 偏向使用泛型参数](#Item-29)
    - [Item 30 偏向使用泛型方法](#Item-30)
    - [Item 31 使用bounded wildcards来增加API的灵活性](#Item-31)
    - [Item 32 谨慎的组合泛型和可变参数](#Item-32)
    - [Item 33 使用类型安全的异质容器](#Item-33)  
- 枚举和注解
    - [Item 34 使用枚举类型替代整数常量](#Item-34)
    - [Item 35 使用枚举实例而不要使用枚举的顺序](#Item-35)
    - [Item 36 使用EnumSet代替bit模式](#Item-36)
    - [Item 37 使用EnumMap代替序号索引](#Item-37)
    - [Item 38  ](#Item-38)
    - [Item 39 注解优于命名模式](#Item-39)
    - [Item 40 一致地使用Override注解](#Item-40)
    - [Item 41 使用标记接口定义类型](#Item-41)
- Lambdas和Streams
    - [Item 42 Lambda方法优于匿名类](#Item-42)
    - [Item 43 方法引用优于Lambda方法](#Item-43)
    - [Item 44 使用标准函数接口](#Item-44)
    - [Item 45 谨慎的使用Streams](#Item-45)
    - [Item 46 在Stream中使用无副作用的函数](#Item-46)
    - [Item 47 返回Collection而不是Stream](#Item-47)
    - [Item 48 谨慎使用Stream的并行化](#Item-48)
- 方法
    - [Item 49 检查参数的有效性](#Item-49)
    - [Item 50 在必要时进行防御性拷贝](#Item-50)
    - [Item 51 仔细的设计方法签名](#Item-51)
    - [Item 52 谨慎的重载方法](#Item-52)
    - [Item 53 谨慎使用可变参数](#Item-53)
    - [Item 54 返回空集合而不是null](#Item-54)
    - [Item 55 谨慎的使用Optional](#Item-55)
    - [Item 56 为所有暴露的API提供文档](#Item-56)
- 一般性编程
    - [Item 57 最小化局部变量作用域](#Item-57)
    - [Item 58 使用for-each代替传统的for循环](#Item-58)
    - [Item 59 了解和使用库](#Item-59)
    - [Item 60 需要精确值时避免使用float和double类型](#Item-60)
    - [Item 61 偏向使用基本类型而不是装箱类型](#Item-61)
    - [Item 62 其他类型更合适时不要使用字符串](#Item-62)
    - [Item 63 注意字符串连接的性能](#Item-63)
    - [Item 64 通过接口引用对象](#Item-64)
    - [Item 65 偏向使用接口而不是反射](#Item-65)
    - [Item 66 谨慎的使用native方法](#Item-66)
    - [Item 67 谨慎的优化](#Item-67)
    - [Item 68  ](#Item-68)
- 异常
    - [Item 69 在需要使用异常的场合使用异常](#Item-69)
    - [Item 70 对可恢复的条件使用受检异常, 对编程错误使用运行时异常](#Item-70)
    - [Item 71 避免不必要的受检异常](#Item-71)
    - [Item 72 使用标准异常](#Item-72)
    - [Item 73 抛出匹配抽象程度的异常](#Item-73)
    - [Item 74 对所有方法抛出的异常编写文档](#Item-74)
    - [Item 75 在异常中加入错误的详细信息](#Item-75)
    - [Item 76 保证失败原子性](#Item-76)
    - [Item 77 不要忽略异常](#Item-77)
- 并发
    - [Item 78 同步访问共享的可变数据](#Item-78)
    - [Item 79 避免过度使用synchronization](#Item-79)
    - [Item 80 使用Executors, Tasks和Streams代替线程](#Item-80)
    - [Item 81 使用concurrency工具类代替wait和notify](#Item-81)
    - [Item 82 在文档中标记是否线程安全](#Item-82)
    - [Item 83 谨慎使用惰性初始化](#Item-83)
    - [Item 84 不要依赖线程调度器](#Item-84)
    
- 序列化
    - [Item 85 考虑使用序列化的替代品](#Item-85)
    - [Item 86 ](#Item-86)
    - [Item 87 ](#Item-87)
    - [Item 88 ](#Item-88)
    - [Item 89 ](#Item-89)
    - [Item 90 ](#Item-90) 





Item 1
-------------

使用静态工厂方法代替构造器.

A class can provide a `static factory methods`, which is simply a static methods that return an instance of the class. Note that a static factory method is not the same as the Factory Method pattern from Design Patterns.

A class can provide its clients with static factory methods instead of, or in addition to, constructors. There are 3 reasons to ues static factory methods:

1. 静态方法可以具有一个自定义的名字. 构造函数的名称必须与类名一直, 当构造函数的重载版本较多时, 会导致比较难以区分. 
2. 静态方法不必每次都创建新的对象, 静态方法可以可以缓存结果, 返回不可变对象
3. 静态方法可以返回声明类型的子类
4. 

--------------------------------

一些常见的静态工厂方法如下表所示

名称                    | 方法举例
------------------------|-----------------------------------|
from                    | `Date.from(instance)`             |
of                      | `EnumSet.of(JACK, QUEEN)`         |
valueOf                 | `BigInteger.valueOf(...)`         |
instance / getInstance  | `A.getInstance(options)`          |
create / newInstance    | `Array.newInstance(...)`          |
getType                 | `Files.getFileStore(path)`        |
newType                 | `Files.newBufferedReader(...)`    |
type                    | `Collections.list(...)`           |





Item 2
-------------

当构造器有很多参数时使用builder

Item 3
-------------

单例模式使用私有构造器或使用枚举. 

``` java
public enum Elvis {
    INSTANCE;
    
    private String name;
    Elvis(){
        name = "LiZeC";
    }
    public String getName() {
        return name;
    }
}
```

使用枚举可以利用JVM的类加载机制实现线程安全和单例加载, 是通常情况下的最优解. 由于枚举类型无法继承, 因此这种方案的单例无法继承其他的类.


Item 4
-------------

不可实例化的类强制使用私有构造函数

Item 5
-------------

使用依赖注入来管理资源

Item 6
-------------

避免创建不必要的对象. 由于String是不可变的, 因此在String相关的操作时, 应该避免毫无意义的调用String的构造函数, 或者重复的执行String的连接操作. 与此类似, 数字的自动装箱和自动拆箱机制使得数字的基本类型和原始类型可以混合使用. 但数字装箱操作既耗费时间又耗费空间, 因此要尽量避免自动装箱操作.

对于Adapter, 由于Adapter本身不包含任何多余的状态信息, 因此完全可以所有的Adapter使用一个实例. 对于轻量级的对象, 自己实现一个对象池并不是一个好主意, 通常垃圾回收系统可以做的更好


Item 7
-------------

消除无效的引用. 垃圾回收系统根据引用关系决定一个对象是否需要回收, 因此不需要的对象需要及时的置为null. 尤其是容器类型的类, 内部的数据在删除后, 引用一定要置为null, 否则相关的对象无法正确的释放.

另一个常见的内存泄露常见就是Cache, Cache保存了对象的强引用, 而对象并不一定总是被使用, 而Cache中的引用阻止了垃圾回收系统. 通常可以使用WeakHashMap实现Cache的功能, 从而在相关对象不被其他对象引用时能够被回收.



Item 8
-------------

避免使用finalizers和cleaners. 从Java 9开始,  finalizers函数已经被标记为废弃, 任何时候都不要使用此函数. 对于需要回收资源的场景, 使用`try-with-resources`语句. 



Item 9
-------------

使用try-with-resources替代try-finally


Item 10
-------------

重写equals方法的规则.

以下条件下, 可以不重写equals方法
1. 所有的实例都不相同
2. 不需要提供逻辑上的相等
3. 父类已经合适的重写了equals方法
4. 可以肯定不会调用equals方法

不满足以上条件时, 可以考虑重写一个equals方法. 例如, 通常表示值类型的对象, 在进行相等判断时, 往往期望判断两个值是否相等, 而不是判断是否是同一对象.

由于equals是一个等价关系, 因此需要满足如下的一些要求

1. 自反性: 对任意非空引用的`x`, `x.equals(x)`必须返回`true`
2. 对称性: 对任意非空引用的`x`和`y`, `x.equals(y)`返回true当且仅当`y.equals(x)`返回true
3. 传递性: 对任意非空引用的`x`,`y`和`z`, 如果`x.equals(y)`返回`true`且`y.equals(z)`返回`true`, 则`x.equals(z)`返回`true`
4. 一致性: 对任意非空引用的`x`和`y`, 多次调用`x.equals(y)`时, 返回结果应该始终为`true`或始终为`false`
5. 空条件: 对任意非空引用的`x`, `x.equals(null)`始终返回`false`

Item 11
-------------

重写equals的同时重写hashCode方法. 相等的对象必须具有相同的哈希值.

Item 12
-------------

始终重写toString方法. 合适的toString方法有利于代码的理解和调试.

Item 13
-------------

谨慎的重写clone方法. clone机制的设计存在瑕疵, Cloneable接口是一个标记接口,  其中不包含任何方法, 而对象的clone方法来自Object对象, 但在Object对象中, clone方法又是protected方法. 因此存在实现了Cloneable接口, 但是由于没有正确的重写clone方法导致不可调用或者调用出现错误的情况. 


Item 14
-------------

考虑实现Comparable接口.

Item 15
-------------

最小化类和成员变量的可见性. 对于非final, 可变对象的引用, 一定要严格控制可见性, 否则容易造成内部数据泄露到类外部的情况.


在Java 9中引入了模块(module)的概念,模块是一组包(package)的集合. 模块可以通过导出列表明确的执行需要导出那些API. 位于导出列表的API可以被模块外部的其他类访问, 而不在导出列表的类, 即使是public或者protected也不能被模块外的其他类访问.

模块对应的jar只有放置在模块搜索路径上才能以模块的方式生效, 如果直接放置在classpath上, 则依然按照普通的jar进行加载. 这一模式仅有一个例外, 即JDK中的模块, 无论放置在那个路径上, 都只能以模块的方式加载.

Item 16
-------------

在public类使用访问器而不是public字段. 不使用访问器会导致后期的修改余地较小.


Item 17
-------------

最小化可变性. 如果需要一个类不可变, 则需要满足如下的5个条件:

1. 不要提供修改类状态的方法
2. 确保类不可被继承
3. 确保所有字段都是final
4. 使所有字段为private
5. 确保不访问任何可变对象

不可变对象更加简单, 且天然具有线程安全的特性. 因为一个线程不会观察到不可变对象被修改, 因此不可变对象可以安全的在不同线程中共享. 此外, 由于不可变对象内部的各个部分也是不可变的, 因此不可变对象的内部属性也能够直接在多个线程中共享. 

不可变对象也可以作为构建其他对象的基本模块, 无论一个对象是否可变, 对于其他的一部分属性, 如果能够组成一个不可变对象, 也能够降低做这个对象的维护难度.

---------------------

不可变对象的主要缺点是需要大量的对象表示不同的值.

---------------------

**实现细节:**根据不可变性的五条规则, 需要将类声明为final使得其不能被继承. 但将类的构造函数声明为private并使用工厂方法创建对象是一种更有效的方法. 因为构造函数为private, 这使得包外的类都无法继承此类, 间接的实现了final效果. 而工厂方法相比于构造器又能够实现对象缓存等其他优化措施.

此外, 不可变对象并不要求对象绝对不可变, 在对象内部可以有一些可变的字段, 他们可以用来缓存一些计算代价较高的函数的结果. 这是一种称为惰性加载的优化措施. 因为对象不可变, 因此可以保证这些缓存结果有意义.

--------------------

**JDK的缺陷:** 在编写BigInteger和BigDecimal时, 不可变对象应该不可继承这一点并没有被广泛的认识, 因此这两个类都可以被继承,其中的方法也可以被子类重写. 如果以这两个类作为接口, 并且运行在一个可能存在恶意代码的环境, 则最稳妥的方法是判断输入参数的类型, 并进行适当的转换, 例如

``` java
public static BigInteger safeInstance(BigInteger val) {
    return val.getClass() == BigInteger.class ? val : new BigInteger(val.toByteArray())
}
```




Item 18
-------------

组合优于继承. 继承是一个强大的复用代码的工具, 但如果不正确的使用, 会造成代码非常脆弱. 一般而言, 将继承限制在一个包内, 从而使一个程序员维护继承类是安全的. 或者继承一个明确标记为可以继承的类也认为是安全的. 而跨越包的随意继承具体的一个类是危险的.

继承的主要问题是违背了封装性, 子类的实现依赖了父类的具体实现, 如果父类发生了变化, 子类也会相应的受到影响.  

继承的另外一个问题是父类可以随意的添加新的方法, 如果子类对父类的方法进行限制来实现功能, 那么新加入的方法可能因为子类没有适当的重写而导致子类的功能被破坏.

使用继承的时候应该问自己一个问题, 如果B希望继承A, 那么是否有 B is a A? 如果不能肯定的回答, 或者回答是否定, 那么就不应该使用继承. 例如在JDK中, Stack不是一个Vector, Properties也不是一个Hashtable, 那么这两个类也不应该使用继承.

Item 19
-------------

设计并说明继承否则禁止继承. 对于每一个创建的类, 要么通过设计使其满足继承条件并在文档中进行说明, 否则就应该禁止其被继承.


Item 20
-------------

接口优于抽象类. 


Item 21
-------------

为后续设计接口.  Java 8引入了默认方法, 可以对接口添加默认的方法, 而实现这些接口的类不需要进行任何修改即可自动继承这些方法. 

默认方法使得实现接口具有了一点继承的特性. 正如继承中父类随机添加方法可能导致子类的功能出现问题, 默认方法也会导致这种结果, 相关的子类在接口加入默认方法后, 必须对默认方法进行适当的重写才能保证功能的正确性.

虽然默认方法一定程度上可以对已经发布的接口进行修改, 但精心设计接口依然是最重要的. 接口在发布后虽然可能被修改, 但不能指望这一点.


Item 22
-------------

Use interfaces only to define types.

When a class implements an interface, the interface servers as a type that can be used to refer to instances of the class. That a class implements an interface should therefore say something about what a client can do with instances of the class.

One kind of interface that fails this test is the so-called **constant interface**. Such an interface contains no methods; it contains solely of static final fields, each exporting a constant. Classes using these constants implements the interface to avoid the need to qualify constant names with a class name.

**The constant interface patter is a poor use of interfaces**. That a class uses some constants internally is an implementation detail.

If you want to export constants, there are several reasonable choices. If the constants are strongly tied to an existing class or interface, you should add them to the class or interface. For example, all of the boxed numerical primitive classes export MIN_VALUE and MAX_VALUE constants. If the constants are best viewed as members of an enumerated type, you should export them with an enum type. Otherwise, you should export the constants with a noninstantiable utily class.

``` java
public class PhysicalConstants{
    private PhysicalConstants() { } 
    public static final double AVOGADROS_NUMBER = 6.022_140_857e34;
    public static final double BOLTZMANN_CONST  = 1.380_648_52e-23;
    public static final double ELECTRON_MASS    = 9.109_383_56e-32;
}
```

``` java
// Use of static import to avoid qualifying constants b
import PhysicalConstants.*;

public class Test {
    double atoms(double mols){
        return AVOGADROS_NUMBER * mols;
    }
}

```


Item 23
-------------

继承优于Tagged类. Tagged类是指通过在类上进行Tag标记来区分不同的类型的类. 由于这一需求正好可以被继承代替, 因此没有任何必要手动标记来区分类, 完全可以通过继承系统自动的实现类型的区分.

Item 24
-------------

Favor static member class over non-static.

A nested class is a class defined within another class. **A nested class should exist only to server its enclosing class.** If a nested class would be useful in some other context, then it should be a top-level class. 

There are four kinds of nested classes: *static member classes*, *nonstatic member classes*, * anonymous classes*, and *local classes*. All but the first kind are known as inner classes.

A static member class is the simplest kind of nested class. It is best thought of as an ordinary class that happens to be declared inside another class and has access to all of the enclosing class's members, even those declared private.

One common use of  a static member class is as a public helper class, useful only in conjunction with its other class. For example, consider an enum describing the operations supported by a calculator([Item 34](#Item-34)). The `Operation` enum should be a public static member class of the `Calculator` class. Clients of `Calculator` could then refer to operation using names like `Calculator.Operation.PLUS`.

One common use of a non-static member class is to define an Adapter that allows an instance of the outer class to be viewed as an instance of some unrelated class. For example, implementations of the Map interface typically use non-static member classes to implement their collection.views.

**If you declare a member class that done not require access to an enclosing instance, always pus the static modifier in its declaration** If you omit this modifier, each **instance** will have a hidden extraneous reference to its enclosing class. Storing this reference takes time and space. More seriously, it can result in the enclosing instance being retained when it would otherwise be eligible for garbage collection.



Item 25
-------------

Limit source files to a single top-level class.

Definitions multiple top-level classes in a source file makes it possible to provide multiple definitions for a class. Which definition gets used is affected by the order in which the source file are passed to the compiler.


Item 26
-------------

不要使用原始类型. 原始类型存在的意义是与以前的代码兼容, 在新的代码中一定要指定泛型的类型, 从而由编译器检查类型和自动转换.

`List`类型与`List<Object>`类型都可以加入任意对象, 但`List<Object>`与`List<String>`没有任何继承关系, 可以确保不会因为继承操作导致类型错误.

如果一个方法只需要一个集合, 而不关心具体是什么元素, 那么可以声明为`Set<?>`的形式. 这种形式的集合会拒绝插入除`null`以外的任何类型的元素, 且无法从此集合获得任何的类型信息.

Item 27
-------------

消除unchecked警告. 在编写代码的时候, 尽可能的消除unchecked警告, 没有unchecked警告意味着代码是类型安全的, 不会在运行时出现ClassCastException. 

如果确实有无法消除的unchecked警告, 但是又确认确实是可以安全转换的, 可以使用`@SuppressWarnings("unchecked")` 注解, 以免这些warning掩盖了其他真的代表某些问题的warning.  

这个注解可以控制使用范围, 因此需要确保使用范围尽可能的小, 最好是针对一个语句或者一个很短的函数使用此注解. 并且在使用时通过注释表明为什么可以保证这个转换是安全的. 如果不能简单的说明这一点, 最好仔细考虑一下是不是真的能够保证转换是类型安全的.

Item 28
-------------

偏向使用list而不是array. array与list的最大区别是array是可变的, 而list是不可变的. 这意味着如果Sub是Super的子类, 那么`Sub[]`是`Super[]`的子类, 而任意两个不同的类型T1和T2, `List<T1>`和`List<T2>`不会有任何继承关系. array的这一特性导致运行时会出现类型错误, 而List则不会有这样的问题, 例如

```java
Object[] objectArray = new Long[1];
objectArray[0] = "str";     //抛出ArrayStoreException

List<Object> ol = new ArrayList<Long>();    // 不兼容类型, 无法编译
ol.add("str") 
```

由于list与array的差异, 两种不太能混合使用, 例如无法`new List<String>[]`或者`new E[]`. 如果允许这些操作, 就可以通过array的特性绕过list的类型检查, 导致运行时错误.

因此如果在混合使用array和list时, 出现了无法创建的错误, 或者有类型转换不安全的警告, 那么可以考虑全部使用list. 虽然这可能导致代码变得冗长或者有一些性能损失, 但这样可以保证类型安全.


Item 29
-------------

偏向使用泛型参数. 虽然Object是所有对象的父类, 设计Object类型的容器可以容纳任意类型的对象, 但将对象从Object转换回去的时候就无法进行编译时检查. 因此在这种场合应该使用泛型参数, 从而获得编译时检查类型的能力.



Item 30
-------------

偏向使用泛型方法. 如果一个方法需要对任意的类型进行操作, 或者需要对泛型集合进行操作但又不关心集合中的具体元素类型, 那么相比于直接使用Raw类型, 定义泛型方法来处理更加安全. 

Item 31
-------------

使用bounded wildcards来增加API的灵活性. 规则是`PECS`原则, 即`producer-extend, consumer-super`. 即如果一个参数是想向对象的内部传递数据, 那么应该声明为`<? extend T>`, 如果参数是想从对象内取出数据, 那么应该声明为`<? super T>`. 

针对第一种情况, 通过extend声明, 使得T的子类也能传递进来(符合子类替换原则). 而针对第二种情况, 通过super声明, 可以将对象类的数据放置到其父类的容器之中(这也符合子类替换原则).

推论: 以`Comparable`接口为例, 由于这个接口只能消费对象内的数据, 因此`Comparable`接口几乎总是声明为`Comparable<? super T>`的形式


-----------------

如果一个泛型参数只出现一次, 那么可以考虑将其替换为`<?>`, 例如以下两个表示交换列表中数据的API
``` java
public static <E> void swap(List<E> list, int i, int j);
public static void swap(List<?> list, int i, int j);
```

相比于第一种较为复杂的API, 第二种API更为简单, 因此交换操作本来就不关心元素的具体类型, 因此直接使用`<?>`表达这一不关心元素类型的含义更加准确.



Item 32
-------------

谨慎的组合泛型和可变参数. 由于可变参数的实现是数组, 而这种实现是可见的, 因此当泛型和可变参数一同使用时, 就会出现前面提到的泛型和数组组合的问题.


Item 33
-------------

使用类型安全的异质容器. 有时候可能需要在集合中存储类型不同的多个对象, 可以考虑使用如下的实现方式.

```java
public class Favorites {
    private Map<Class<?>, Object> favorites = new HashMap<>();
    
    
    public <T> void putFavorites(Class<T> type, T instance) {
        // 对参数进行检查, cast方法可以保证类型不正确时直接抛出异常
        favorites.put(Objects.requireNonNull(type), type.cast(instance));
    }
    
    public <T> T getFavorites(Class<T> type) {
        return type.cast(favorites.get(type));
    }
}
```



Item 34
-------------

使用枚举类型替代整数常量. 枚举类型具有类型, 而整数常量都是int类型, 因此使用枚举能获得更多语义信息, 从而为代码提供更多语法检查.

枚举类型实际上就是一个Java中的类, 其中声明的每个枚举值都是这个类对应的final static实例. 枚举天然的实现了单例模式, 每个枚举值都是一个单例.

实际上Java的枚举很好的实现了Object中定义的方法, 并且实现了`Comparable`和`Serializable`接口. Java枚举的序列化经过了设计, 能够适应大部分对枚举进行修改的情况.

Java的枚举可以加入任何的方法, 实现任意的接口. 这种需求通常源于对实例值附加更多属性. 例如表示水果类型的枚举值可能希望能获得一个获得水果颜色的方法. 一个包含了各种特性的枚举值具有如下的样式.

``` java
public enum Plant {
    MERCURY(3.302e+23, 2.439e6),
    VENUS(4.869e+24, 6.052e6),
    EARTH(5.975e+24,6.378e+6),
    MARCH(6.419e+23,3.393e+6);  // 注意这里的分号表示结束枚举值

    private final double mass;
    private final double radius;
    private final double surfaceGravity;
    private static final double G = 6.67300E-11;

    Plant(double mass, double radius) {
        this.mass = mass;
        this.radius = radius;
        surfaceGravity = G * mass / (radius * radius);
    }

    public double mass() { return mass; }
    public double radius() { return radius; }
    public double surfaceGravity() { return surfaceGravity; }

    public double sufaceWeight(double mass) {
        return mass* surfaceGravity;
    }
}
```

可以按照如下的方式使用上面的枚举类

``` java
public static void main(String[] args) {
    double earthWeight = 70;
    double mass = earthWeight / Plant.EARTH.surfaceGravity();
    for (Plant plant : Plant.values()) {
        System.out.printf("Weight on %s is %f%n", plant, plant.sufaceWeight(mass));
    }
}
```




Item 35
-------------

使用枚举实例而不要使用枚举的顺序. 直接获取枚举的int值对后续添加和修改枚举值造成了不利的影响. 如果一定需要使用枚举的int值, 可以在构造枚举实例的时候明确指定取值.


Item 36
-------------

使用EnumSet代替bit模式. 在Linux操作系统中, 文件权限就采取了bit模式, 分别用1 bit表示文件是否可读, 是否可写, 是否可执行. 在Java开发过程中, 完全可以使用EnumSet代替这种模式.

例如, 对于一个需要接受多个枚举值组合的接口, 可以按照如下的形式定义.

``` java
public class Text {
    public enum Style {BOLD, ITALIC, UNDERLINE, STRIKETHOUGH}

    public void applyStyle(Set<Style> styles) { ... }
}
```

在需要使用的地方, 使用EnumSet的of函数构建一个Set.

``` java
text.applyStyle(EnumSet.of(Style.BOLD, Style.ItALIC));
```

当枚举的数量小于64时, EnumSet在内部仅使用一个long值, 因此在性能上与手动实现bit模式没有区别, 但在其他情况, EnumSet也能更加妥当的处理.



Item 37
-------------

使用EnumMap代替序号索引. EnumMap是Map接口的一种实现, 其中Key必须为枚举类型, 值可以为任意类型. 由于EnumMap对这种场景进行了优化, 因此能够使用EnumMap的场景都应该直接使用.


Item 38
-------------
Item 39
-------------

注解优于命名模式. 命名模式通过某种命名方式使得某些类或者方法具有一些额外的属性. 例如在Junit测试框架的早期版本中, 要求需要被测试的方法以`test`字符开头或者结尾. 这种模式虽然一定程度上可以附加额外的属性, 但是由于存在拼写错误的可能性, 因此不够好用. 使用注解可以更好的替代这种模式.

Item 40
-------------

一致地使用Override注解. 


Item 41
-------------

标记接口是指一类只用于标记, 而不包含任何方法的接口. 典型的标记接口是Serializable接口, 此接口不包含任何方法, 只用来标记一个类可以被序列化.相比于Item 39中介绍的使用注解引入额外信息, 使用标记接口最主要的优势在于, 标记接口定义了一种类型, 而注解没有定义任何类型. 这使得使用标记接口时, 与类型相关的错误可以在编译器就被发现. 而如果使用注释, 这类错误则需要在运行期才能够被发现. 标记接口的第二个优势是标记接口只能应用到类或者接口上, 因此可以将应用范围限制在更小的范围内, 而注解如果没有进行限制, 可以注解到任何位置.

注解的优势是存在大量以注解为基础的框架, 使用这些框架的时候, 就需要一致地使用注解. 关于何时使用标记接口, 何时使用注解, 可以概括为如下的情况. 如果这个额外信息针对的不是类或者接口, 那么只能使用注解. 如果额外信息针对的是类或者接口, 那么考虑一个问题, 即是否存在以这种信息为要求的方法, 如果是, 那么使用标记接口可以将标记接口作为方法的参数, 从而获得编译时检查. 否则可以考虑使用注解.

本条与Item 22正好是一个相对应的关系. Item 22概括来说就是如果不想定义类型, 不要使用接口. 而本条相当于说如果想定义一个类型, 那么就使用接口.



Item 42
-------------

偏向使用Lambda而不是匿名类. Lambda函数是针对需要一个函数的场景设计的, 在这种场景下Lambda表达式比同等的匿名类更短, 更能清晰的表达代码的意图.

但在另一方法, Lambda表达式缺少名字和文档. 如果一个计算过程不是可以自我解释的, 或者长度较长, 那么就不适合使用Lambda表达式. 

Lambda表达式最适合的长度是一行, 三行是可以接受的最大长度, 否则应该思考一下是否合适.


Item 43
-------------

偏向使用方法引用而不是Lambda方法. 方法引用比Lambda方法更简洁(succinct). 

``` java
map.merge(key, 1, (count, incr) -> count + incr);

map.merge(key, 1, Integer::sum);
```

以上面的两行代码为例, 第二行使用方法引用, 更简明的表达了计算含义, 而且代码长度更短. 一个函数接口需要的参数越多, 使用方法引用可以消除的代码就越多. 除非使用Lambda更简洁, 否则就应该使用方法引用(例如identity操作就是Lambda更简洁). 

基本上所有使用Lambda的地方都可以使用方法引用替换, 而且IDE也提供了将Lambda转化为方法引用的功能.



Item 44
-------------

使用标准函数接口.

Java的`java.util.Function`包提供了43个函数接口. 这43个接口可以分成6个基础接口, 和相应的基础类型派生接口. 6个基础接口分别是

Interface               | Function Signature    | Example
------------------------|-----------------------|-----------------------------
`UnaryOperation<T>`     | `T apply(T t)`        | `String::toLowerCase`
`BinaryOperation<T>`    | `T apply(T t1, T t2)` | `BigIntgeter::add`
`Predicate<T>`          | `boolean test(T t)`   | `Collection::isEmpty`
`Function<T,R>`         | `R apply(T t)`        | `Arrays::asList`
`Supplier<T>`           | `T get()`             | `Instant::now`
`Consumer<T>`           | `void accept(T t)`    | `System.out.println`

对于上面的6中基本类型, 都有三种基础类型的派生类型(int, long和double). 三种派生类型通过加入前缀的方式产生, 例如针对long版本的`UnaryOperation`名称为`LongUnaryOperation`. `Function`的派生版本稍微有些特殊, `LongFunction<int[]>`表示参数为`long`, 返回值为`int[]`的函数. `ToLongFunction<int[]>`表示参数为`int[]`, 返回值为`Long`的函数. 通过这一派生方法, 产生了5x3+3+3=21种新接口.


针对`Function`接口, 根据不同的参数和返回值, 产生了6种从一个基础类型转换到另外一个基础类型的接口, 例如从`long`到`int`的`Function`定义为`LongToIntFunction`. 同种类型的转换不需要派生, 因为这种情况可以使用`UnaryOperation`的派生接口. 

对于6种基本接口类型中的3种, 提供了二元函数版本. 分别是`BiPrediction<T,U>`, `BiFunction<T,U, R>`, `BiConsumer<T,U>`. `BiFunction`根据返回值类型, 可以派生三种类型, 例如`ToIntBiFunction`. `BiConsumer`派生三种接受`Object`和基本类型的接口, 例如`ObjLongConsumer`. 3种二元函数和6种派生类型构成了9种新接口.

最后, `BooleanSupplier`提供了boolean版本的`Supplier`, 加上这一个接口即可得到6+21+6+9+1=43个接口.

由于装箱类型与基础类型存在一些差异(例如`==`的效果), 以及装箱带来的性能问题, 因此要尽可能的使用基础类型. 由于基础类型和封装类型并不是完全等价的, 因此IDEA并不会分析某个接口能否替换为基础类型的版本. 但当Stream本身就是基础类型时, 相应的接口就自动使用基础类型, 从而不用考虑选择问题.


----------------------------------------------

大部分时候应该直接使用标准函数接口, 但如果存在如下的一些情况, 也可以考虑使用自定义接口

- 此函数接口被广泛的使用, 值得使用一个更有意义的名称.
- 可以从接口的默认方法获得收益.

自定义的函数接口应该始终使用`@FunctionalInterface`进行标记, 此标记可以保证

- 向读者表明此接口是函数接口, 应该传递函数
- 使编译器检查此接口有且只有一个方法


Item 45
-------------

谨慎的使用Streams. Stream存在一定的局限性, 不要在不适合的场景下强行使用Stream. 使用了Stream后, 代码应该更加简洁易懂, 而不是相反的情况.

在缺少类型的情况下, 应该谨慎的定义Lambda表达式的变量名, 使其具有一定的类型信息.

Stream缺少对char类型的支持, 此时应该控制Stream的使用.



Item 46
-------------

在Stream中偏向使用无副作用的函数, 以确保Stream能够正确的并行执行.



Item 47
-------------


偏向返回Collection而不是Stream.

Stream需要通过链式操作使代码易于理解, 如果一个接口只返回Stream类型, 那么当用户希望显式迭代时, 就不太容易操作. 虽然Stream实现的iterator实现了迭代器的功能, 但这一接口不能使用for循环. 如果需要使用for循环, 只能以如下的方式进行处理.

``` java
for (String s : (Iterable<? extends String>) Arrays.stream(words)::iterator) {

}
```

Iterable要求实现iterator方法, Stream实质上已经实现了Iterable接口, 但由于没有声明此接口, 因此只能如上面的代码一样迂回一下, 或者按照如下的方式实现一个转换的适配器

``` java
public static <E> Iterable<E> iterableOf(Stream<E> stream) {
    return stream::iterator;
}
```

------------------

但是在另一方面, Stream具有一定的延迟计算的特性, 当需要返回一个巨大的集合时, 使用Stream构建一个类似生成器的结构则有助于减少内存消耗.


Item 48
-------------

谨慎使用Stream的并行化. Stream并行化使用fork/join框架, 需要数据能够容易一分为二的处理.

如果一个Stream使用iterate方法创建, 或者使用了limit方法, 那么并行化基本不可能使性能提升. 

使用合适的数据结构才可能提升并行化的性能. 合适的数据结构包括 ArrayList, HashMap, HashSet和ConcurrentHashMap等对象, 数组, int/long range.

在终止操作方面, 最适合并行的终止操作是reduce操作, 或者内置的类似reduce的操作, 包括 min, max, count等. 其次是短路操作, 包括anyMatch, allMatch等. 

如果计算的大部分时间都在终止操作, 那么并行化中间的计算过程显然不是一个有价值的操作. 一个粗略的估计是, 如果需要处理的元素数量乘以处理这些元素的操作行数大于10万, 那么考虑进行并行化才是有价值的.


Item 49
-------------

检查参数的有效性. 尽可能早的检查错误是一条通用的编程原则, 否则错误的扩散将导致错误难以发现.

对于一个参数是否为null, 可以使用`Object.requireNonNull`进行处理, 这比手动检查更方便一点. 如果是类中的私有方法, 可以使用assert来进行处理, 因为此类私有方法可以控制调用环境, 因此不应该出现值为空的情况.



Item 50
-------------

在必要时进行防御性拷贝. 在编程时, 需要你编写的类会被使用他们的用户尽可能修改. 例如Java中的Date类由于不是可变的, 因此一个类将Date作为参数存储后, 外部对Data的修改都会导致内部的变量也被修改. 解决这一问题的方法是使用Instant类代替(不可变的类), 或者进行防御性拷贝, 在类的内部拷贝一份Date类. 例如

```java
public Period(Date start, Date end) {
    this.start = new Date(start.getTime());
    this.end = new Date(end.getTime());

    if(this.start.compareTo(this.end) > 0) {
        throw new IllegalArgumentException(this.start + "after " + this.end);
    }
}
```

注意: 这里首先进行拷贝, 然后在拷贝的变量上检查参数有效性, 而不是直接检查参数有效性. 这一操作的目的是确保在检查参数有效性和拷贝的间隙内, 参数的值不会被其他线程修改. 这一问题在计算机安全领域被称为time-of-check/time-of-use攻击(TOCTOU攻击).

在另一方法, 可以注意到上面的代码没有使用clone方法获取拷贝. 因为Date类是非final的, 因此clone可能被子类实现, 而导致调用clone后返回了一个不可信的子类.

---------------

Preiod类现在虽然可以抵抗输入参数的修改, 但如果Preiod类直接返回Date类, 那么外部的代码还是可以通过修改Date类影响Preiod类的内部状态. 因此Preiod类返回时也需要进行防御性拷贝, 例如

``` java
public Date start() {
    return new Date(start.getTime());
}

public Date end() {
    return new Date(end.getTime());
}
```

**无论何时, 只要编写的方法保存了客户端提供的参数, 那么都需要考虑提供的参数是否需要防御性拷贝.** 在返回内部可变组件时, 也需要考虑外部代码是否可能影响内部的状态.


Item 51
-------------

仔细的设计方法签名. **方法签名的首要目的是保证签名容易理解且与包内的其他方法签名一致**. 一个方法的名称并不是越长越好. **不要在一个类中实现过多的便捷方法**. 这一点对于接口尤其重要, 如果一个接口内方法太多, 会导致实现此接口和使用此接口更加困难. 对于每一个操作, 提供一个完整功能的方法. 只有当某些便捷方法非常常用时, 才考虑实现这种便捷方法.

**避免设计过长的参数列表**. 一个方法最好只有四个以内的参数. 如果参数过多, 可以考虑三种方法进行处理
1. 将一个方法拆分为多个方法, 从而每个方法仅使用原方法参数列表中的一部分参数
2. 设计一个帮助类存储需要的参数
3. 使用Builder模式构建对象

**方法的参数偏向使用接口类型而不是具体类型**. 具体内容可以参考[Item 64](#Item-64).

**考虑使用两个元素的枚举类型替换boolean参数**. 使用枚举能够更加清晰的表达含义. 例如, 对于包含两个元素的温度类型枚举

``` java
public enum TemperatureScale { FAHRENHEIT, CELSIUS }
```

使用枚举就比使用布尔值更能清晰的表达温度类型的含义. 而且后续如果加入新的温度类型, 也能够更方便的进行修改.



Item 52
-------------

谨慎的重载方法. Java的方法重载是静态的, 在编译器就根据声明的类型完成了函数调用选择.

**泛型和自动装箱模糊了标准库中可重载的API**. Set接口存在一个移除对象的方法`remove(E)`, 在`Set<Integer>`上调用`remove(2)`时, 会自动对`2`进行自动装箱. 但List接口存在两个移除对象的方法, 分别是`remove(E)`和`remove(int)`, 在`List<Integer>`上调用`remove(2)`时, 不会自动装箱, 而是直接移除第二个元素.

在Java8中, lambda方法的引入也会进一步导致一些函数重载出现问题, 例如下面的代码

```java
    // 方案一
    new Thread(System.out::println).start();

    // 方案二
    ExecutorService exec = Executors.newCachedThreadPool();
    exec.submit((Runnable) System.out::println);
```

方案一可以正常的编译运行, 而方案二会因为无法确定重载版本而报错. 因为`Thread`的构造函数只能接受`Runnable`接口的参数, 但sumbit方法可以接受`Runnable`和`Callable<T>`, 虽然`System.out::println`的所有重载都是`void`, 不可能重载`Callable<T>`, 但编译器并不能除以这种两个方法都可以重载的情况.

**重载相关联的类时要确保重载行为一致**. 以String方法为例, 此方法提供了`valueOf(char[])`和`value(Object)`重载, 但一个`char[]`对象分别以这两种方法进行调用时, 就会出现不一致的行为. 在程序中应该避免出现这样的重载.


Item 53
-------------

谨慎使用可变参数. 在使用可变参数时, 方案二比方案一更好. 尤其在一个方法至少需要有一个参数时.

``` java
// 方案一
static int min(int... args) {
    if (args.length == 0) {
        throw new IllegalArgumentException("Too few Arguments");
    }

    int min = args[0];
    for (int i = 1; i < args.length; i++) {
        if (args[i] < min) {
            min = args[i];
        }
    }
    return min;
}

// 方案二
static int min(int firstArg, int... remainingArgs) {
    int min = firstArg;
    for (int arg : remainingArgs) {
        if (arg < min) {
            min = arg;
        }
    }
    return min;
}
```

Item 54
-------------

返回空集合而不是null.  可以使用`Collections.emptyList()`代替每次创建一个新的空集合. 

Item 55
-------------

谨慎的使用Optional. Optional与Checked Exception非常类似, 只有在确定客户端代码必须要处理空值问题的时候才应该使用Optional. 有几种情况下不应该使用Optional

1. 集合类型不应该使用Optional, 而应该直接返回集合
2. 基本类型应该使用特殊化的Optional, 例如OptionalInt, 否则包装成本太高
3. 不应该将Optional对象作为map类型的key, value或者集合类型的元素




Item 56
-------------

为所有暴露的API提供文档. 对于提供给其他用户使用的API, 其中的所有类, 接口, 构造函数, 方法,和字段都应该提供文档. 对于方法的文档, 应该简洁的描述方法和调用者之间的联系, 即应该说明方法**实现了**什么功能, 而不是**怎么实现**功能.

对于包含泛型的方法, 应该同时说明每个泛型表示的含义. 对于枚举类型, 应该说明每个枚举值具体的含义. 对于注解类型, 应该说明注解本身和其中的每个字段的含义.


Item 57
-------------

最小化局部变量作用域. 在需要的地方声明变量, 而不要在一个方法的开头声明变量. 每个变量都应该尽可能在声明的时候就完成初始化, 否则应该考虑能够延后这个变量的声明.

为了减小局部变量的作用域, 也应该同时保持每个函数的功能简单且专一. 避免将多个功能耦合在一起从本质上减少了变量的作用域.




Item 58
-------------

使用for-each代替传统for循环. 大部分情况下, 使用for-each循环更加简单, 能够尽可能减少意外的书写错误. 但是如果需要在遍历过程中删除数据, 则必须使用迭代器.


Item 59
-------------

了解和使用库. Java的标准库都是专家编写的, 经过广泛验证的代码, 因此能够使用标准库结解决问题就不要自己实现. 虽然标准库中的类很多, 无法一一了解, 但对于`Java.lang`, `java.util`, `java.io`包中的类应该有充分的认识. 

对于集合类, Stream类和`java.util.concurrent`包也应该有充分的认识.

Item 60
-------------

需要精确值时避免使用float和double类型. 对于涉及货币的领域, 使用BigDecimal是默认的选择. 但对于非货币领域, 使用BigDecimal可能有一些繁琐, 此时使用int或者long来表示可能更简单.

Item 61
-------------

偏向使用基本类型而不是装箱类型. 虽然自动装箱和自动拆箱模糊了基本类型和装箱类型的界限, 但并没有消除两者的区别. 因此基础类型和装箱类型有三个重要的区别

1. 基本类型只有值, 但装箱类型有值和地址, 装箱类型可以具有同样的值和不同的地址
2. 基本类型只有值, 但装箱类型有null值
3. 装箱类型有更高的性能开销


下面是一个简单的整数比较代码, 似乎也能够正确的工作

``` java
Comparator<Integer> naturalOrder = 
    (i, j) -> (i < j) ? -1 : (i == j ? 0 : 1)
```

但当执行下面的语句

```java
naturalOrder.compare(new Integer(42), new Integer(42))
```

时, 程序并不会返回0, 而是返回1. 其原因就是`<`会自动拆箱, `==`并不会自动拆箱, 而是进行对象比较. **对装箱类型使用==进行比较几乎总是错误操作**

> 针对上面的代码, IDEA会报告Warning以及提示使用内置函数进行替换


Item 62
-------------

其他类型更合适时不要使用字符串. 字符串是用来表示一段文本的, 在其他的场景应该使用更合适的工具. 最典型的场景就是不要使用字符串代替枚举类型. 关于枚举参考[Item 43](#Item-34).

另一个场景是使用字符串表示一个聚合类型, 例如

```java
String compoundKey = className + "#" + i.next();
```

对于上面这种通过拼接字符串表示类型的情况, 定义一个专用的类可能更合适.



Item 63
-------------

注意字符串连接的性能. 字符串是不可变的, 循环拼接字符串的性能非常差, 此时应该使用StringBuilder代替.

Item 64
-------------

通过接口引用对象. 通过接口引用对象使得程序具有更换实现的灵活性. 当需要更换实现时, 只需要修改构造函数这一个地方.

有三种主要情况下, 应该使用类直接引用对象. 第一种情况是值类型(例如String和BigInteger), 这种类一般没有多种实现, 因此可以直接引用. 第二种情况是来自框架的基础类, 这一类框架一般使用抽象基类, 此时可以使用基类引用对象. 第三中情况是具体的实现类中有额外的方法, 如果需要使用这些额外方法, 则只能使用具体类.

一般情况下,如果一个类有对应的接口, 那么就应该直接使用对应的接口. 如果一个类没有对应的接口, 那么就应该使用最符合实际需要的子类.


Item 65
-------------

偏向使用接口而不是反射. 相比于使用接口, 使用反射将导致三个问题. 第一, 使用反射将无法在编译时检查类型. 第二, 反射的代码非常复杂, 且需要处理大量运行时异常, 这导致代码非常臃肿. 第三, 反射调用的性能低于直接调用的性能.

一般情况下, 只有一定要在运行时动态决定创建那个类的时候, 才应该使用反射技术, 而且应该在创建之后使用接口访问这个对象, 而不是使用反射API直接调用方法.


Item 66
-------------

谨慎的使用native方法. 有三种使用native方法的场景, 分别是访问平台相关的方法, 使用只有native实现的库, 提高某些方法的执行性能. 对于前两种场景, 使用native方法是允许的. 但是**使用native方法提升性能几乎永远是不利的**.

JVM本身就在不断的提高执行性能, 大部分时候已经不需要通过调用native方法提供性能. 而且native方法中的代码bug还会导致整个应用程序出现错误.


Item 67
-------------

谨慎的优化. 应当追求写好的代码而不是快的代码. 当代码写的好的时候, 将其改的更快是容易的, 而对于一个快但不正确的代码, 将其修复是困难的.

构建系统的时候不要太在意性能, 但在构建API, 通信协议, 序列化格式的时候应该重点考虑性能问题, 因为这些部分一旦确定, 往往无法轻易修改, 且决定了系统的性能上限.

如果系统的性能存在问题, 一定要通过测量的方式定位性能问题, 而不要根据代码凭空猜想. 由于JVM的不断优化, 写的代码和CPU执行的代码已经有很大的差距了, 一切都要根据实际测试结果确定.

优化性能时, 首先尝试优化算法. 一个算法的优化效果远远好于若干个细节优化的效果.


Item 68
-------------


Item 69
-------------

在需要使用异常的场合使用异常. 不要将异常用于正常的流程控制. 




Item 70
-------------

对可恢复的条件使用受检异常, 对编程错误使用运行时异常.

每一个受检异常都表明这种异常也是调用方法可能的一种出口. 运行时异常用于表明程序存在错误. 

使用受检异常还是运行时异常取决于能否从异常状态恢复. 能够从异常状态恢复的情形使用受检异常, 否则使用运行时异常. 如果不能明确能否从异常状态恢复, 那么先使用运行时异常比较稳妥.



Item 71
-------------

避免不必要的受检异常. 如果一个方法只抛出一个异常, 并且只会抛出这种异常, 那么就应该考虑是否有必要在这里使用异常. 这种情况下, 使用Optional可以替代异常. 但相对地, 使用Optional无法携带错误的原因, 是否替换需要根据实际情况进行取舍.


Item 72
-------------

使用标准异常. 使用标准异常可以使代码更容易阅读, 更符合一般认识, 并且是JVM加载更少的类. 以下是一些常见的可复用异常.


Exception                           | Occasion For Use
------------------------------------|--------------------------------------
IllegalArgumentException            | 不合适的非空参数
IllegalStateException               | 在方法调用时, 对象状态不正确
NullPointerException                | 参数为null
IndexOutOfBoundsException           | 索引参数越界
ConcurrentModificationException     | 禁止并发操作的对象探测到并发修改
UnsupportedOperationException       | 对象不支持的方法


原则上, 所有的错误都可以归纳为 IllegalArgumentException 或者 IllegalStateException, 但使用一个更详细, 更合适的异常有助于提高代码的可读性. 一般地, 如果两种异常都可以抛出的场景下, 如果所有参数都不能使方法正确的执行, 则抛出 IllegalStateException, 否则抛出 IllegalArgumentException.


Item 73
-------------

抛出匹配抽象程度的异常. 高层次的方法不应该抛出低层次的异常, 这种情况下, 应该catch低层次的异常, 并重新包装为高层次的异常. 

如果高层次异常需要携带低层次异常的信息, 可以使用`Exception(Throwable cause)`方法将低层次异常作为高层次异常的参数.


Item 74
-------------

对所有方法抛出的异常编写文档.


Item 75
-------------

在异常中加入错误的详细信息.

Item 76
-------------

保证失败原子性. 如果一个方法抛出了异常之后, 整个对象还是处于一个可用的状态, 则称这个对象具有失败原子性.

保证失败原子性的最简单方式是使对象是不可变的. 不可变对象天然保证原子性. 其次可以考虑在方法的开头做统一个检查, 从而如果存在问题, 在执行具体逻辑前就抛出异常.


Item 77
-------------

不要忽略异常.

Item 78
-------------

同步访问共享的可变数据. Java规范保证了除了long和double变量以外的任何变量的读写操作都是原子的, 但由于Java虚拟机的内存模型, 这不代表任何对变量的读写都是线


``` java
private static boolean stopRequest;

public static void main(String[] args) throws InterruptedException {
    Thread backgroundThread = new Thread(()-> {
        int i=0;
        while (!stopRequest) {
            i++;
        }
    });
    backgroundThread.start();

    TimeUnit.SECONDS.sleep(1);
    stopRequest = true;
}
```

以上的代码并不会终止, 因为一般情况下, 在backgroundThread线程看来, stopRequest在循环过程中是不变的, 因此循环会被优化为

``` java
if(!stopRequest) {
    while(true) {
        i++
    }
}
```

解决这一问题的方法是将stopRequest声明为volatile变量, 从而使其他线程的修改对当前线程可见.

解决线程问题的最好方法是**不共享可变数据**, 如果所有的可变数据都限制在一个线程之中, 线程之间仅共享不可变数据, 那么线程之间就不会出现任何读写问题.


Item 79
-------------

避免过度使用synchronization. 

**永远不要在同步块中将控制权交给客户端代码**, 由于无法得知客户端代码会做什么, 因此在同步块中调用客户端代码可能导致异常和死锁. 由于同步块具有可重入性, 因此如果在一个同步块中调用客户端代码, 而客户端代码又调用其他同步方法, 则会因为可重入性而直接获得锁, 这种同时修改可能导致数据不一致或者抛出异常.

**考虑内部加锁和外部加锁**, 如果一个类不考虑多线程使用, 那么可以由客户端代码在外部加锁来保证线程安全. 如果一个类在内部加锁, 虽然可能可以更高效的实现加锁, 但由于外部环境可能根本不需要加锁而导致性能反而降低.


Item 80
-------------

使用Executors, Tasks和Streams代替线程. Executor类提供了很多不同的实现, 从而能够满足各种不同的场景. 相比于直接使用线程, 使用这些工具类能够使代码更加灵活. 这些工具类同时将线程控制和执行代码分析, 因此也能降低代码的复杂度, 提高代码的可维护性.

Item 81
-------------

使用concurrency工具类代替wait和notify.  


Item 82
-------------

在文档中标记是否线程安全. 线程安全可以分为不同的等级, 包括**不可变**, **无条件线程安全**, **条件线程安全**, **无线程安全**.

如果一个对象是不可变的, 那么他必然是线程安全的, 例如String和Long. Java并行集合类中的对象通常是无条件线程安全的, 即任意多线程条件下使用都可以保证线程安全, 例如ConcurrentHashMap和AtomicLong. 使用Collections.synchronized包裹的类都是条件线程安全的, 其中的大部分方法是线程安全的, 但部分方法需要额外加锁才能保证安全. 其他的大部分Java类都没有考虑线程问题, 因此是无线程安全的.


Item 83
-------------

谨慎使用惰性初始化. 惰性初始化通常视为一种优化方式, 与其他任何优化方式一样, 只有在你需要的时候才采取这种优化方式. 惰性加载是否能够提高性能要实际测量才能确定.

多线程的引入导致惰性初始化更容易出现问题. 如果需要惰性初始化静态变量, 那么可以采用下面的holder方案.

``` java
private static class FieldHolder {
    static final FieldType field = computerFieldValue();
}

private static FieldType getField() { return FieldHolder.field};
```

这种方案利用JVM的类加载机制, 保证了第一次调用getField方法时, JVM才加载这个类. JVM加载此类时会自动保证初始化的线程安全, 并且一旦完成初始化, 后续访问就与直接访问一个字段等价.

--------------

如果需要初始化一个实例变量, 那么可以考虑使用double-check方案, 

``` java
private volatile FieldType field;

private FieldType getField() {
    FieldType result = field;
    if(result == null) {
        synchronized(this) {
            if(field == null) {
                field = result = computeFieldValue();
            }
        }
    }
    return result;
}
```

这段代码有两个要点:
1. 使用volatile修饰变量, 保证线程之间的可见性
2. 使用result保存field的值, 保证正常流程时field只读取一次



Item 84
-------------

不要依赖线程调度器. 依赖线程调度器来保证正确性或者性能的程序是不可移植的. 为了减少线程的调度代价, 每个检查的工作应该足够短但又不至于太短.

不要使用Thread.yield来保证程序的性能或正确性. 这个方法不具备可测试性, 在一个JVM上能提高性能不代表在另一个JVM上也能取得同样的效果.

不要调整线程优先级, 通过调整线程优先级来保证程序的性能也是不可靠的, 应该从程序的结构上避免这种问题.


Item 85
-------------
Item 86
-------------
Item 87
-------------
Item 88
-------------
Item 89
-------------
Item 90
-------------