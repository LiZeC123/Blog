---
title: Kotlin快速入门笔记
math: false
date: 2025-12-21 18:15:57
categories:
tags:
    - Kotlin
cover_picture: images/kotlin.png
---


针对有 Java 背景的开发者，学习 Kotlin 的核心在于“语法差异”和“思维转换”。



第一部分: 消除冗余
------------------

### 变量与分支

```java
// 编译时常量, 只能定义在函数外
const val MAX_COUNT = 100

fun main() {
    // 声明变量
    var count = 0

    // 声明只读变量, 在代码中赋值后无法修改
    var name:String

    count += 1

    // 编译期字符串插值, 只会在编译的时候做一次替换
    name = "str($count)"

    // 输出
    println("count is $count  name is $name")


    // if是表达式, 可以省略大括号但不可以省略圆括号
    count = if (name.length > 10) 10 else name.length
    // 支持范围
    count = if (name.length in 0..10) name.length else 10

    // when约等于一个switch, 但是条件部分可以写任意表达式
    val item = "Apple"
    val price = when(item) {
        "Apple" -> 2.99
        "Banana" -> 4.99

        else -> 0.99
    }
}


```


### 空安全


```java
fun nullF() {
    // 默认变量不可为null, 需要手动加上?才能赋值为null, 与TypeScript类似
    var v1: String? = null
    // 使用 ?. 可以安全调用, 如果v1为空则不调用count函数, 支持链式调用
    val count: Int? = v1?.count()

    // 如果?:左侧变量为null, 则返回右侧的值
    val v2: String = v1 ?: "base"

    // 无视null检测, 强行调用. 确实为null时抛出异常
    v1!!.count()
}
```


### 函数

```java
// 声明模式比较类似于TypeScript
private fun add(item: Int, delta: Double = 3.0) : Double {
    return item + delta
}

// Unit表示无返回值, 无需显式指定
public fun doChange(base: Int): Unit {
    val v1 = add(base, 1.2)
    val v2 = add(base)
    todo()
}

// Nothing表示函数无法返回, 必须抛出异常或者终止程序
private fun todo(): Nothing {
    throw NotImplementedError()
}

// 支持默认参数
private fun g1(name: String = "GGBoy", age: Int = 22): Boolean {
    return false
}

// 支持命名参数调用
private fun g2() {
    g1(age=12, name="Bob")
}


private fun f1() {
    // 使用一个lambda函数统计特定字符的数量
    val count = "GG Boy".count { s -> s == 'G' }

    // 先写函数声明, 再写实现, lambda必须写在{}内
    // 入参的圆括号不可省略, 只有一个入参时可以使用it代替
    val welcomeF: (String) -> String = { "Welcome $it" }

    // 类型如果可以被推断, 那么可以不声明. 对于lambda函数也就是需要声明入参的类型
    val addF = {name: String, age: Double -> "welcome $name with age $age"}

    // 支持高阶函数, 直接写函数的类型即可, 例如 (String, Double) -> String
    val g = {b: String, f: (String, Double) -> String -> b +f("GG Boy", 22.3) }

    // 如果lambda函数是最后一个参数, 则需要放到圆括号外
    // 如果lambda函数是唯一的参数, 则可以不写圆括号, 例如上面的count函数
    g("Tag: ") { n, i -> "n $n + $i" }
}
```

Kotlin的文件级函数对应为Java的类静态方法. 类名对应文件名.


### 内联函数

```java
// 使用inline关键词将当前函数内联, 从而避免传递f对象, 导致对象分配的开销
private inline fun g(b: String, f: (String, Double) -> String) {
    b +f("GG Boy", 22.3)
}

private fun f2() {
    println("Start")
    g("Tag: ") { n, i -> "n $n + $i" }
    println("end")
}

//f2等价于如下的Java代码, f原本就是代码, 现在也是直接嵌入, 因此不需要真的构造一个匿名对象了
private static final void f2() {
    String b$iv = "Start";
    System.out.println(b$iv);
    b$iv = "Tag: ";
    int $i$f$g = false;
    StringBuilder var10000 = (new StringBuilder()).append(b$iv);
    double i = 22.3;
    String n = "GG Boy";
    StringBuilder var6 = var10000;
    int var5 = false;
    String var7 = "n " + n + " + " + i;
    var6.append(var7).toString();
    b$iv = "end";
    System.out.println(b$iv);
}
```



### 定义类



```java
// 定义类的时候给定参数列表, 支持默认值和命名参数
// 这个构造函数称为主构造函数
// 如果一个属性只需要默认的get和set, 则可以完全不定义, 只在主构造函数中声明. 纯数据类可以采用这种方式
class Player(name: String, hp: Double) {
    
    // 不可变属性只能Get
    val name = name
        get() = "User: $field"

    // 可变属性可以Get和Set
    // 外部直接访问变量, 会自动调用set或者get方法
    var hp: Int = (hp*100).toInt()
        get() = field * 100
        set(value)  {
            field = value / 100
        }

    // 属性无法被外部访问
    private var pName = "private"

    // 设置私有set, 则外部可访问不可读取
    var pName2 = "private"
        private set(v) {
            field = v + "\n"
        }

    // 计算属性, 可以完全基于get的逻辑生成结果
    val rolledValue
        get() = (1..6).shuffled().first()

    // 延迟初始化, 可以在稍后初始化该变量
    // 使用变量前必须确保已经初始化, 否则抛出UninitializedPropertyAccessException
    lateinit var aligment: String

    // 惰性初始化, 只有实际访问这个变量的时候才会真的执行初始化逻辑
    val hometown = lazy { File("town.txt").readText().split("\n").shuffled().first() }

    // 次构造函数, 必须最终转发到主构造函数
    constructor(name: String) : this(name, 100.0)


    // init块, 构造时可进行校验
    init {
        // require函数进行检查, 不满足条件时抛出IllegalArgumentException
        require(hp > 0) { "hp must greater than zero" }
    }


    fun greetStr(name: String) = "greet, $name"
}
```


### 继承与多态


```java
// 默认类不可继承, 需要open修饰才可被继承
open class Room(name: String) {
    // 同样open修饰的方法才能被重写
    open fun load() = "Nothing..."
}

// 类似Python的继承语法
open class TownSquare: Room("Town Square") {
    // 重写数必须添加override
    // final标记可以让open函数不可被子类覆盖
    final override fun load() = "load Town"
}

// 所有类都继承自Any类
fun f2(t: Any): String {
    val className = when(t) {
        is TownSquare -> "Town"
        is Room -> "Room"
        else -> "Unknown"
    }
    return className
}
```


### 对象

```java
// 对象, 全局唯一的实例
object Game {
    // 支持init块
    init {
        println("Game Init")
    }

    // 支持定义方法
    // 在第一次访问对象时初始化实例
    fun play() {
        println("play")
    }
}


// 对象表达式, 直接构造一个临时对象, 同样在第一次使用时初始化并且全局唯一
val temp = object : Room("Temp") {
    override fun load()= "load Temp"
}


class GameMap {

    // 伴生对象, 可以直接通过GameMap.load 调用其中的方法
    companion object {
        private const val MAP_PATH = "map.txt"
        fun load() = File(MAP_PATH).readBytes()
    }
}

// 数据类, 相比于普通类重写了equals, toString, copy方法, 逻辑类似Java中自动生成的逻辑
// 因此相较于普通类, 更适合表示纯数据的对象
data class Coordinate(val x: Int, val y: Int)

// 枚举类
enum class Direction {
    NORTH,
    EAST,
    SOUTH,
    WEST,
}
```

### 接口与抽象类

```java
interface Bird {
    // 可以附带默认实现, 实现类可以直接复用或者重写
    val rolledValue
        get() = (1..6).shuffled().first()
    
    
    fun Fly()
}

// 定义抽象类并实现接口
abstract class AbsBird() : Bird {
    // 重写接口函数
    override fun Fly() {
        println("fly")
    }
    
    // 声明抽象方法
    abstract fun DoSome()
}
```



### 标准函数


| 函数 | 接收者 (this) | 参数 (it) | 返回值 | 主要用途 |
|------|--------------|-----------|--------|----------|
| **apply** | 对象本身 | 无 | 对象本身 | 对象初始化配置 |
| **let** | 无 | 对象本身 | lambda最后一行 | 非空转换、作用域变换 |
| **run** | 对象本身 | 无 | lambda最后一行 | 对象计算、作用域变换 |
| **also** | 无 | 对象本身 | 对象本身 | 附加操作、副作用 |



```java
fun stdF(i: String?) {
    // apply函数把调用对象传入(即当前的file)作用域内, 在其中可以对file执行一些操作后返回file本身
    // 这种方式可以保证file创建出来后就是不可变的
    val file = File("a.txt").apply {
        setReadable(true)
        setWritable(true)
    }

    // let函数把调用对象传入, 返回执行的结果
    // let和apply的区别在于, apply相当于内置了一个this, 而let需要用lambda引用变量
    val firstItemSquare = listOf(1, 2, 3).first().let { it*it }

    // let也用于非空判断, 执行let则说明i非空, 可以安全的使用it
    val welcome = i?.let { "welcome $it" } ?: "welcome user"

    // run与apply类似, 但返回执行结果而不是对象本身
    val containsGGBoy = File("a.txt").run {
        readText().contains("GG Boy")
    }

    // also与let类似, 但是返回接受者, 可以用于在指令逻辑中外挂一些副作用
    val file2 = File("a.txt").also { 
        println(it.name)
    }

    // takeIf在条件满足时返回对象本身, 不满足时返回null
    val file3 = File("b.txt").takeIf {
        it.canRead() && it.canWrite()
    }?.readText()
}
```


### 扩展

```java
// 扩展方法: 对String对象新增一个addTag方法
fun String.addTag(tag: String) = "$this(Tag: $tag)"

// 扩展属性
val String.numVowels
    get() = count{ "aeiouy".contains(it)}
```

扩展函数和属性可以用private修饰, 使得该扩展仅在当前文件内有效. 




### 泛型扩展

```java
// <T>表示这个函数是一个泛型函数, T.apply表示这是一个扩展函数
// T.() -> Unit是一个带有接收者的函数类型参数, 在此函数体内可以直接调用接收者的方法, 而不需要显式地写出接收者
public inline fun <T> T.apply(block: T.() -> Unit): T {
    // contract是Kotlin的契约功能 用于给编译器提供关于函数行为的额外信息
    contract {
        // 表示block参数会被调用 并且只调用一次
        callsInPlace(block, InvocationKind.EXACTLY_ONCE)
    }
    // 执行函数
    block()
    // 返回接收者
    return this
}
```



