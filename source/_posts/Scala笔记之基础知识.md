---
title: Scala笔记之基础知识
date: 2019-12-17 15:12:25
categories: Scala笔记
tags:
    - Scala
cover_picture: images/scala.png
---


Scala语言运行在JVM上, 因此Scala可以认为在一定程度上与Java是兼容的, Scala可以自由的使用Java所有的类.





变量
--------

Scala的变量分为可变变量与不可变变量. 变量在创建时可以指定变量类型, 也可以省略, 让编译器根据赋予的初始值自动推断类型. 所有变量都必须在定义时初始化, 但如果初始值不确定, 可以使用占位符进行初始化.

``` scala
var numberA = 123
val numberB: Int = 456
var strA:String = "Hello"
val strB = "World"
var t:Int = _
```

> 在Scala中统一了基本类型和封装类型, 因此无论是Java中的int类型还是Integer类型, 在Scala中都是为Int类型.

### 惰性初始化

初始化变量时, 可以采用lazy关键字, 使得变量在使用时才会赋值. lazy关键字只能修饰val变量

``` scala
> lazy val v1 = "test"
v1: String = [lazy]

> v1
res9: String = "test
```

### 基础特性

Scala有一些基础特性, 在其他语言中可能有类似的语言, 具体如下

- 3个双引号"""包裹的字符串保持原样输出
- 以s开头的字符串使用`$x`的形式在字符串中引用变量
- 支持圆括号定义元组, 并使用`tuple._n`的形式访问元组的第n个元素(第一个元素是`_1`)
- 支持元组拆包
- 使用`'`定义一个符号(同Scheme语言)
- 单参数函数调用可以省略`.`和括号, 例如`a.to(b)`等价于`a to b`或者`a + b`等价于`a.+(b)`
- 支持默认参数和命名参数传递(同Python)
- 


控制语句
--------------

Scala的控制语句基本与Java一致, 但for循环有额外的格式
```
for( i <- 1 to 5) {
    println(s"i=$i")
}
```

其中的变量i不需要定义, 编译器能够自动推断i的类型. 表达式部分要求是任意的Range类型. `to`函数是包含右边界的, 如果不需要包含右边界, 可以使用`until`函数.

---------------

对于For循环的控制, Scala不提供break和continue关键字, 但提供类似Python列表推导格式的循环控制
```
for(i <- 1 to 5 if i > 2; if i < 4) {
   println(s"i=$i")
}
```

与Python相同, 可以使用yield关键字实现序列


数据结构
-------------


Scala区分可变集合与不可变集合, 且默认情况下, 所有的集合都是不可变集合. 不可变集合是函数变成的一个基本设置. 默认情况下, Scala会自动导入不可变集合的相关包, 如果需要可变集合, 则需要手动导入`scala.collection.mutable`包中的相关类. 常用的集合类如下所示


不可变集合   | 可变集合
------------|-----------------------------------
Array       | ArrayBuffer
List        | ListBuffer
/           | LinkedList, DoubleLinkedList
List        | MutableList
/           | Queue
Array       | ArraySeq
Stack       | Stack
HashMap     | HashMap
HashSet     | HashSet
/           | ArrayStack

与Java一样, 集合类型都是泛型, 但Scala使用`[]`指定泛型的具体类型, 例如
``` scala
// 显式创建数组
> val numberArray = new Array[Int](10)

numberArray: Array[Int] = Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

// 自动推断数组类型
> val strArray = Array("Hello", "Scala")

strArray: Array[String] = Array("Hello", "Scala")
```

---------------------------------------------------------------------

对于List类型, Scala还提供了一个类似Scheme的创建方法, 形式如下

``` scala
> val nums = 1::2::3::4::Nil

nums: List[Int] = List(1, 2, 3, 4)
```

集合操作相关的API与JAVA大同小异, 具体使用时, 可以查阅API文档



函数
-----------


一个标准的函数具有如下的结构

``` scala
def gcd(x:Int, y:Int): Int = {
    if (x % y == 0) 
        y
    else
        gcd(y, x%y)
}
```

函数体的最后一个表达式的值将作为函数的返回值, 并且通常情况下返回值类型可以自动推导, 但如果显式使用return或者递归则无法推导返回值类型, 此时需要明确指定返回值类型.


### Lambda函数
Scala支持Lambda函数, 格式与Java类似

``` scala
> val sum = (x:Int, y:Int) => {x+y}
sum: (Int, Int) => Int = <function2>
```

Lambda函数可以作为其他函数的参数, 使用方式与大部分语言类似

``` scala
> val arrInt =  Array(1,2,3,4)
arrInt: Array[Int] = Array(1, 2, 3, 4)

> arrInt.map(x => x+1)
res7: Array[Int] = Array(2, 3, 4, 5)
```

由于部分操作十分经典, 因此Scala提供了更简单的输入方式, 以上面的对所有元素执行+1操作为例, 可以进一步简化为

``` scala
// 集合是不可变的, 因此重复执行map操作结果是一致的
> arrInt.map(_+1)

res8: Array[Int] = Array(2, 3, 4, 5)  
```

### 高阶函数

Scala支持高阶函数, 定义形式如下

``` scala
def higher(f: (Double) => Double) = f(100)

import java.lang.Math   // NoteBook需要手动导入Math,否则没有sqrt函数
def sqrt(x: Double) = Math.sqrt(x)

higher(sqrt)    // res16: Double = 10.0
```

-----------

高阶函数的另一个常见的用法是将函数作为返回值, 例如

``` scala
def higher2(factor:Int) = (x:Double) => factor * x
higher2(10)(2)
```

注意: `=`是分割函数声明和函数体的标志, 明确这一点有助于阅读复杂的高阶函数



### 函数柯里化

对于将函数作为返回值的高阶函数, 通常具有`f(A)(B)`的调用形式, Scala可以直接定义柯里化函数实现上述形式的函数调用, 例如上一节的函数可以直接定义为

``` scala
def multiply(factor:Int)(x: Double) = factor * x
multiply(10)(2.2)
```
此时虽然看起来与高阶函数有相同的调用形式, 但如果单独调用`multiply(10)`会报错, 因为柯里化函数并不是高阶函数, 不能分步调用. 如果需要此特性, 可以使用部分应用函数, 格式如下

``` scala
val paf = multiply(10) _
paf(2.4)

val paf2 = multiply _   //这就相当于原来的高阶函数
paf2(10)(2.4)   
```

对于普通函数, 也能够使用部分应用函数, 例如

``` scala
def product(x1:Int, x2:Int, x3:Int) = 100*x1 + 10*x2 + x3
product_1 = product(_:Int, 2, 3) // _后面的类型不能省略且需要与原函数匹配, 否则不能编译
product_1(1)
```
通过函数柯里化和部分应用函数, 可以使得部分参数直接固定到函数之中, 从而提高函数的复用性, 减少重复输入. 柯里化的其他应用可以参考如下的一些资料

- [简述几个非常有用的柯里化函数使用场景](https://segmentfault.com/a/1190000015281061)


### 偏函数

偏函数是处理定义域子集的函数, 如果参数不在子集内, 则抛出异常, 这一特点通常与Scala的模式匹配结合. 偏函数的定义模式为

``` scala
val isEven: PartialFunction[Int, String] = {
    case x if x % 2 == 0 => x + "is even"
}

val receive:PartialFunction[Any,Unit] = {
    case x:Int => println("Int Type")
    case x:String => println("String Type")
    case _ => println("Other Type")
}
```



面向对象编程
---------------

``` scala
class Person {
    val name:String = null; // 不可变变量不生成set方法
    var age:Int = null;     // 可变变量自动生成set方法
}

class Person(val name:String, var age:Int);
```

上述代码均可实现对成员变量的定义, 并且Scala会同时自动生成Scala风格的get和set方法. Scala风格的get与set使用方法类似于C#的属性, 在实现上, Scala定义了与成员变量同名的函数实现get功能, 重载了`=`运算符实现了set功能, 例如

``` scala
var p = new Person("Scala",23)
var name = p.name
p.age = p.age + 1
```


### 单例对象

Scala不支持Java中的静态类成员, 类似的功能需要使用单例对象实现, 单例对象使用object关键字定义. 具体形式如下

``` scala
object Student {
    private var studentNo = 0;
    def uniqueStudentNo() = {
        studentNo += 1
        studentNo
    }
}

Student.uniqueStudentNo()   // res38_0: Int = 1
Student.uniqueStudentNo()   // res38_1: Int = 2
Student.uniqueStudentNo()   // res38_2: Int = 3
```

------------------

包含main方法的单例对象也称为应用实例对象. 与Java一样, 此main函数可以作为程序的入口函数. 此外, 如果继承了App类, 也可以直接执行代码, 而不用定义main函数

``` scala
object AppTest extends App {
    // 这里写的代码直接执行
    var num = 12;
    println("Hello World"+num);
}


object TestOut {
    def main(args:Array[String]){
        // 按照Java的方式定义main函数
        println(args)
    }
}
```


### 伴生对象

Scala可以分别使用class关键字和object关键字定义同名的类和对象. 这组对象分别称为伴生类和伴生对象. 伴生类和伴生对象内部可以无视访问权限控制而直接访问私有字段.

伴生对象定义`apply`方法可以是伴生类不使用new创建对象. 伴生对象定义`unapply`方法可以在模式匹配中使伴生类实现构造函数匹配.




### 构造函数

在前面定义Person对象时, 如果只需要一个简单的数据结构, 那么只有函数声明部分即可实现全部功能, 如果需要重写其他内容, 则可以按照如下的方式重写


``` scala
class Person(val name:String, var age:Int) {
    override def toString() = name + ":" +  age
}
```

这种定义类的方法称为 主构造函数. Scala支持默认参数和辅助构造函数. 无论这个类的名称如何, 辅助构造函数都定义为`this(argA,argB)`的形式


### Trait

Trait的含义是特质, 其基本作用是代替Java中的Interface, 例如

``` scala
trait Closeable {
    def close(): Unit
}

class File(val name:String) extends Closeable {
    def close() = println(s"File $name has been closed")
}

new File("a.txt").close()
```

类实现Trait被称为混入, 如果只需要混入一个Trait, 则可以使用extends关键字, 如果需要混入多个Trait, 则可以使用with关键字, 例如

``` scala
class File(val name:String) extends java.io.File with Closeable with Cloneable {
    def close() = println(s"File $name has been closed")
}
```
Trait可以像Java中的接口类一样使用, 不过Trait在使用上可以更加灵活, 可以有具体的成员变量和成员函数, 因此与Java中的抽象类更接近.

在Java中, 一个类只能继承一个类, 而Trait具有抽象类的特性, 同时Scala允许混入多个Trait, 因此在Scala中存在多继承问题.


模式匹配
------------

模式匹配是Scala的一个重要的语言特性, 在开发过程中被广泛应用. 常见的元组解包就是模式匹配的一个应用. 模式匹配通常具有如下的结构

```
for(i <- 1 to 5) {
    i match {
        case 1 => println("这是数字1")
        case x if (x %2 == 0) => println(s"${x}能被2整除")
        case _ => 
    }
}
```

相比于Jave的switch语法, Scala的模式匹配能够支持更多不同的类型, 从而提高的这一语法的表达能力. 在前面的偏函数章节也可以看到, 模式匹配语法除了作为语句使用外, 也可以作为函数体.


### 模式匹配类型

上面演示了模式匹配对常量和变量的匹配格式, 下面介绍模式匹配的几种其他用法.

------------------------------

**使用构造函数解构对象**

``` scala
case class Dog(val name:String, var age:Int);

val dog = Dog("Pet",2)

def patternMatching(x:AnyRef) = x match {
    case Dog(name, age) => println(s"Dog name = $name, age = $age")
    case _ =>
}

patternMatching(dog)    // Dog name = Pet, age = 2
```

------------------------------

**序列匹配与元组匹配**

``` scala
val arrInt = Array(1,2,3,4)
def patternMatching(x:AnyRef) = x match {
    case Array(first, second) => println(s"first is $first, second is $second")
    case Array(fisrt, _, thrid, _) => println(s"first is $fisrt, thrid is $thrid")
    case Array(fisrt, _*) => println(s"first is $fisrt")
}

patternMatching(arrInt)     // first is 1, thrid is 3
patternMatching(arrMore)    // first is 1
```

```
val tupleInt = (1,2,3,4)
def patternMatching(x:AnyRef) = x match {
    case (first, second) => println(s"first is $first, second is $second")
    case (fisrt, _, thrid, _) => println(s"first is $fisrt, thrid is $thrid")
}

patternMatching(tupleInt)   // first is 1, thrid is 3
```

------------------------------

**类型匹配**

``` scala
def patternMatching(x:Any) = x match {
    case s:String => println("This is String")
    case i:Int => println("This is Int")
}

patternMatching("Hello")    // This is String
patternMatching(123)        // This is Int
```

------------------------------

**变量绑定模式**

变量绑定模式相当于将指定的变量绑定到任意的表达式

``` scala
val list = List(List(1,2,3,4), List(4,5,6,7,8,9))

def patternMatching(x: AnyRef)= x match {
    case e1@List(_, e2@List(4, _*)) => println(s"e1=$e1 e2=$e2")
}

patternMatching(list)   // e1=List(List(1, 2, 3, 4), List(4, 5, 6, 7, 8, 9)) e2=List(4, 5, 6, 7, 8, 9)
```

上述模式匹配规则表明, e2需要匹配一个任意长度的List, 且第一个元素是数字4. e1需要匹配一个有两个元素的List, 且第二个元素需要时e2对应格式的List. 这种操作非常类似正则表达式中的变量捕获.

-----------------------

**For循环**

For循环支持所有格式的模式匹配, 例如

```
for((language, e@"Spark) <- Map("Java" -> "Hadoop".length, "Closure" -> "Storm", "Scala" -> "Spark")) {
    println(s"$e is development by $language language)
}
```




类型参数
---------------


Scala的泛型与Java泛型基本上存在一一对应的关系, Java的泛型特性Scala都支持, 并且在Java泛型的基础上, Scala提供了更多特性. 


特性    |Java泛型                   | Scala泛型
--------|--------------------------|----------------------------
泛型    | `List<String>`            | `Array[String]`
通配符  | `List<?>`                 | `Array[_]`
下界    | `List<? extends String>`  | `Array[T <: String]`
上界    | `List<? super String>`    | `Array[T >: String]`
协变    | `<T extends U>`           | `[+T]`
逆变    | `<T super U>`             | `[-T]`
