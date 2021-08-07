---
title: Java特性之基础特性
date: 2018-11-21 16:05:22
categories: Java特性
tags:
    - Java
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->

本文介绍一些零散的Java特性, 虽然这些知识都比较零散, 但是合理使用可以有效的简化程序的逻辑, 降低开发难度.


Java泛型简介
--------------

### 定义泛型函数
任何一个泛型函数都需要在函数的**返回类型**前声明使用到的类型,例如
``` java
public <T> void print(T num) {
    System.out.println(num);
}
```
上述代码中首先声明了一个泛型名T,然后此函数接受一个类型为T的变量作为参数.


### 有界的参数类型
有时候并不希望任何类型都被传递给函数,而希望只接受某个类的子类,此时可以使用extern关键字,例如
``` java
public <T extends Person> f(T p) { ... }
```
上述函数表示只接受Person及其子类作为参数


### 类型通配符
使用类型通配符`?`来代替任意一种类型,例如`List<?>`表示任意List实例化的类型,例如`List<Integer>`或者`List<String>`. 通配符既可直接作为模板类型也可以用于构成更复杂的模板类型,例如
``` java
public void print(List<?> list) { ... }
public <T extends List<?>> print(T list) { ... }
```

类型通配符也可以进行限制,例如在Compartor接口中定义的comparing函数声明如下
``` java
    public static <T, U extends Comparable<? super U>> Comparator<T> comparing(
            Function<? super T, ? extends U> keyExtractor)
```

首先`<T, U extends Comparable<? super U>>`表面这个函数使用了两个类型名`T`和`U`,其中`T`为任意类型,`U`是某个`Comparable`的子类,而该`Comparable`实例化的类型必须是U的父类.

再看返回类型` Comparator<T>`,该函数返回一个T类型的`Comparator`对象

最后看参数声明`Function<? super T, ? extends U> keyExtractor`,首先这是一个函数对象,根据文档,`Function<T,R>`表示接受参数`T`,返回类型为`R`的函数,所以这里的`keyExtractor`是一个接受`T`和其父类的类型为参数的,返回类型为`U`或其子类的函数. 

注意声明`Function<? super T, ? extends U>`中,  其中`? super T`是逆变性的一种体现, 即如果要求传入的函数是一个处理String的函数, 那么传入的函数可以是接受Object的函数, 因为String满足Object的所有特点, 可以被传入. 其中`? extends U`, 是协变性的体现, 即如果要求函数是一个返回Object的函数, 那么可以接受返回String的函数. 这种接口的声明方式, 在各种函数有关的接口中非常常见.


Java注解简介
------------------

### 注解的定义

注解使用`@interface`定义, 定义的方式和接口类似, 例如
``` java
public @interface LiZeC {

}
```

如上就定义了一个名为LiZeC的注解, 之后就可以和其他注解一样使用,例如
``` java
@LiZeC
class Me {

}
```

注意: **注解本身只提供一个标记, 具体的作用需要通过Java的反射机制, 使用额外的代码来实现**


### 元注解

元注解就是注解的注解, 元注解为我们自定的注解提供了基本的语义信息. Java的元注解包括

Annotation      | Description
----------------|-------------------------------------------------
@Retention      | 指定注解的保留期,是仅保留至源代码还是保留到运行时
@Documented     | 指示注解与文档相关
@Target         | 指定注解运用的对象,例如是类还是方法或者字段
@Inherited      | 指定注解可以被继承
@Repeatable     | 指定注解可以被重复


其中@Retention具有如下三种类型

Type            |  Description
----------------|-----------------------------------------------
SOURCE          | 编译时被编译器丢弃(discard)
CLASS           | 被编译到字节码文件但不加载到VM, 是默认值
RUNTIME         | 被编译到字节码文件并且加载到VM,从而可以被反射获得


其中@Target具有如下的类型

Type                | Description           | Type                | Description           
--------------------|-----------------------|---------------------|----------------------------
TYPE                | 类,接口(包括注解),枚举  | LOCAL_VARIABLE      | 局部变量
FIELD               | 字段					 | ANNOTATION_TYPE     | 注解
METHOD              | 方法					 | PACKAGE             | 包
PARAMETER           | 参数					 | TYPE_PARAMETER      | 类型参数
CONSTRUCTOR         | 构造函数				 | TYPE_USE            | 任意类型


### 注解的值

通常情况下, 注解的内部会定义一些值, 从而为处理注解时提供更多额外的信息. 例如

``` java
public @interface LiZeC {
	String name() default "";
}
```

在上述注解中, 定义了名为name的元素, 其类型为String, 默认值为空字符串. 之后就可以如下的使用注解

``` java
@LiZeC(name="Me")
class Me {

}
```

注解的元素类型可以是 基本类型, String, Class, enum, Annotation 以及这些类型的数组.  此外, 如果定义的元素名称为value, 且此元素是唯一需要赋值的元素, 则可以省略元素名, 直接赋值.




### 参考文献和扩展阅读
- [秒懂, Java 注解 （Annotation）你可以这样学](https://blog.csdn.net/briblue/article/details/73824058)
- [深入理解Java注解类型(@Annotation)](https://blog.csdn.net/javazejian/article/details/71860633)


Java枚举类型
-------------------

Java从JDK1.5开始, 加入了枚举类型. 和各种语言中定义的枚举类型一样, Java枚举中的字段可以表示一个选项, 从而用于判断或者switch语句. 枚举的定义语法与类定义语法相似, 只是关键词不同, 例如:

```java
public enum Color {  
  RED, GREEN, BLANK, YELLOW  
} 
```


### 枚举方法

实际上, Java中的枚举相当于一个继承了`java.lang.Enum`的类, 可以向枚举中添加任意的方法和构造函数, 例如
``` java
public enum Color {  
    RED("红色", 1), GREEN("绿色", 2), BLANK("白色", 3), YELLO("黄色", 4); // 注意最后的分号
    // 成员变量  
    private String name;  
    private int index;  
    // 构造方法  
    private Color(String name, int index) {  
        this.name = name;  
        this.index = index;  
    }  
    // 普通方法  
    public static String getName(int index) {  
        for (Color c : Color.values()) {  
            if (c.getIndex() == index) {  
                return c.name;  
            }  
        }  
        return null;  
    }  
    // get set 方法  
    public String getName() {  
        return name;  
    }  
    public void setName(String name) {  
        this.name = name;  
    }  
    public int getIndex() {  
        return index;  
    }  
    public void setIndex(int index) {  
        this.index = index;  
    }  
} 

```

- [Java枚举的七种常见用法](https://blog.csdn.net/jzhf2012/article/details/8528979)




Java反射
------------

所谓的反射就是在运行时获得对象的信息， 具体包括如下的一些操作

1. 在运行时判断任意一个对象所属的类
2. 在运行时构造任意对象
3. 在运行时调用任意对象的任意方法
4. 在运行时获得对象的成员变量或方法

### 核心类

Java的反射操作涉及如下的一组核心类， 包括Class， Field，Method，Constructor和Array。这些名字一看就可以知道其代表的含义。

进行反射操作的第一步是获得想要反射的对象的Class，有三种方式获得Class对象

1. Class.forName("java.lang.String")
2. String.class
3. obj.getClass()

> `.class`获得的是变量声明的类型，而`getClass()`方法获得的是变量实际的类型（例如子类）

### 创建对象

有两种方法创建对象，第一种是直接调用对象的无参构造函数，例如

```java
Class<?> classType = String.class;
Object obj = classType.newInstance();
```

第二种方法是先获得Class对象，然后通过该对象获得对应的Constructor对象，再通过该Constructor对象的newInstance()方法生成，例如

```java
Class<?> classType = Customer.class;
Constructor cons2 = classType.getConstructor(String.class, int.class);
Object obj2 = cons2.newInstance("ZhangSan",20);
```



### 枚举不可反射

Java中的枚举被设计为无法通过反射创建实例，其目的是保证枚举的实例在JVM中唯一，从而可以安全的使用`==`进行比较。 在JDK的代码中，newInstance方法中对是否为枚举类型进行了检测， 如果是枚举类型会抛出异常。





Java可变参数简介
--------------------


Java的可变参数本质就是**数组**, 函数被编译成字节码后,可变参数就是一个数组. 

### 可变参数与数组的转换
- 声明一个可变参数以后,既可以传入多个单独的参数,也可以传入一个数组
- 在函数内部,总是视为一个数组

### 匹配规则
1. 可变参数至少传入一个参数
2. 可变参数函数与固定参数函数同时匹配时,调用固定参数函数
3. 多种可变参数同时匹配时,编译失败




Java函数式接口
--------------------

### 函数式接口标记

对于自定义的函数式接口,可以使用`@FunctionalInterface`注解, 这样有两个效果
1. 编译器会检测此接口是否只包含一个抽象接口
2. 在javadoc中提供一项声明,指出这是一个函数式接口

### Java常见函数式接口

函数式接口           |参数类型| 返回类型  | 抽象方法名 |    说明
--------------------|-------|-----------|-----------|---------------------------------------------
Runnable            | Node  | void      | run       | 执行一个没有参数和返回值的操作
Supplier<T>         | None  | T         | get       | 提供一个T类型的值
Consumer<T>         | T     | void      | accept    | 处理一个T类型的值
BiConsumer<T,U>     | T, U  | void      | accept    | 处理T类型和U类型的值
Predicate<T>        | T     | bollean   | test      | 计算出一个逻辑结果
toIntFunction<T>    | T     | int       | applyasInt| 转化为int,也存在转化为long和double的同类函数
IntFunction<R>      | int   | R         | apply     | 从int转化为其他类型,也存在从long和double转化的同类函数
Function<T,R>       | T     | R         | apply     |  一个参数类型为T返回类型为R的函数
BiFunction<T,U,R>   | T, U  | R         | apply     | 一个参数类型为T和U,返回类型为R的函数
UnaryOperator<T>    | T     | T         | apply     | 对类型T的一元操作
BinaryOperator<T>   | T, T  | T         | apply     | 对类型T的二元操作


try-with-resources语句
-----------------------

从Java 7开始,可以在try后跟上一个括号, 从而打开一个资源并由编译器保证无论发生何种情况, 都正确的调用close语句关闭资源. 该特性与C#的using语句类似. 

编译器只保证在离开作用域后能调用close,但不主动catch任何异常,因此在try中的异常还是需要进行处理.

所有实现了AutoCloseable接口的资源类都可以使用此机制.


对null的处理
------------------

Java提供了如下的一组方法来处理各种常见的null值问题, 使用下面的方法可以减少代码中的判断逻辑.

方法                    | 解释
------------------------|------------------------------------------------
Objects.equals(a,b)     | 可以正确的处理a,b为null的情况,而不抛出异常
Objects.hash(a,b, ...)  | 可以组合多个对象,产生一个hash值
String.valueof(obj)     | 可以保证null也被转化为字符串"null",而不抛出异常
Objects.toString(o,"")  | 可以在o为null时,返回第二个参数指定的值
Integer.compare(a,b)    | 比较两个数的值,并且保证没有溢出风险


全局日志
-----------

从Java 7开始, 提供了一种简便获得日志对象的方法, 即`Logger.getClobel()`, 使用此函数可以简便的替换`System.out.println()`进行日志输出.

``` java
Logger.getGlobal().setLevel(Level.WARNING);
Logger.getGlobal().info(()->"Hello");
Logger.getGlobal().warning(()->"Warning");
```



默认方法
---------------------

在Java 8中,可以对接口添加默认的方法,使用default关键字声明,例如
``` java
public interface Person {
	long getAge();
	default void plusOne(int old, int you) { old += 1; you -= 1;} 
}
```

通过默认方法, Java在行为上实现了多继承, 对于继承过程中可能的冲突问题, 按照如下的规则判断
1. 类中的方法优先级最高, 类或父类中声明的方法的优先级高于任何声明为默认方法的优先级
2. 子接口优先级更高, 函数签名相同时, 优先选择最具体的实现的默认方法
3. 若以上两条规则均无法判定, 则类中需要显式的指定调用哪一个方法
