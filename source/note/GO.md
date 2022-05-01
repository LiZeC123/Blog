---
title: Go相关知识
date: 2021-12-16 08:00:00
---


垃圾回收算法
--------------------

Go的垃圾回收算法是三色算法，即根据对象之间的引用关系，将对象分割为白色对象，灰色对象和黑色对象。

垃圾回收过程使用单独的线程进行处理，并使用写屏障维护指针的关系。



Mid-stack inlining
--------------------

与C系列的语言一样, Go语言的编译器对于比较短小的函数会默认进行内联操作. 是否内联的主要依据是代码的代价(复杂度), 越是简单的代码越容易被内联. 

内联是递归的, 例如对于下面的函数, 由于g是简单函数, 因此f中的调用被内联, 之后f也是简单函数, 因此f被内联到main方法中.

```go
func main() {
  f()
}

func f() int {
  g() + g()
}

func g() int {
  // 简单函数
}
```

由于是否内联取决于函数的代价, 因此部分无法衡量代价的操作将导致整个函数无法被内联. 此外, 如果一个函数内调用了不可内联的函数, 则此函数由于无法计算代价也必然不可内联.

--------

针对函数内调用了不可内联的函数导致不可内联的问题, Go语言引入了`Mid-stack inlining`技术. 只要一个函数f本身足够简单, 即使调用了不可内联的函数g, f自己还是可以被内联.

无法对f进行内联的主要原因是Go的编译器对于此类内联操作无法准确的追踪堆栈和调用信息, 导致报错时无法准确输出信息. 对编译器进行改造以后即可修复此问题. 引入此优化后, Go语言有大约9%的性能提升和大约15%的体积增加


- [Mid-stack inlining的提案](https://go.googlesource.com/proposal/+/master/design/19348-midstack-inlining.md)
- [Mid-stack inlining的PPT](https://docs.google.com/presentation/d/1Wcblp3jpfeKwA0Y4FOmj63PW52M_qmNqlQkNaLj0P5o/edit#slide=id.p)
- [Mid-stack inlining in Go](https://dave.cheney.net/2020/05/02/mid-stack-inlining-in-go)


--------------

标准库的`sync`包中的`Lock`方法采用了`Mid-stack inlining`特性, 代码如下:

```go
func (m *Mutex) Lock() {
	// Fast path: grab unlocked mutex.
	if atomic.CompareAndSwapInt32(&m.state, 0, mutexLocked) {
		if race.Enabled {
			race.Acquire(unsafe.Pointer(m))
		}
		return
	}
	// Slow path (outlined so that the fast path can be inlined)
	m.lockSlow()
}
```

上述代码对于加锁操作分为两个部分, 首先尝试CAS加锁, 如果失败则执行后续逻辑. 此处CAS操作的代价是确定的, 而`lockSlow()`逻辑非常复杂, 不可被内联. 

按照上述写法, 可以确保Lock方法本身可以被内联, 从而使得锁压力较小时性能较高.


GO的指针与对象
--------------

Go存在类似C语言的指针，其含义也和C语言中的指针一样。

Go语言的特性使得结构体指针可以和结构体变量一样的语法来访问成员变量。因此有时候有一种和Java类似的错觉，似乎可以把指针视为对象。

但是另一方面Go的指针又具有函数可能修改这一变量的含义，但是Go没有泛型，类似场景只能定义一个万能的interface{}类型，这导致函数内如果想要修改变量，没有办法明确的要求这里是一个指针。 

如果调用的时候忘记了取地址，虽然函数的代码中可以做运行时检查，但这基本导致Go语言的强类型系统报废了。这绝对是一个设计缺陷。


字符串与数组转换
--------------------

使用`strconv`包将字符串转换为数字，使用`fmt.Sprintf`函数格式化的将一个数字转换为字符串。

- [Convert string to integer type in Go?](https://stackoverflow.com/questions/4278430/convert-string-to-integer-type-in-go)


字节数组与字符串转换
-----------------------------

```go
var str string = "test"
var data []byte = []byte(str)

str = string(data[:])
```


Go语言哲学
-------------

组合优于继承。Go语言在中并没有提供类似Java的集成组建，因此并不能写出非常具有Java风格的代码。相反地，Go更偏向于通过组合的方式实现代码复用。

Go的设计趋向于正交，即各个模块之间保持相互独立，在用户代码中通过组合机制实现功能。


### 零值可用

由于Go不像Java一样提供构造函数，因此直接声明的变量仅具有默认的零值。对于引用类型，相当与空指针。为了避免产生空指针的问题，Go哲学强调零值可用，例如

```go
var zeroSlice []int
zeroSlice = append(zeroSlice, 1) // 未初始化的切片依然可以正常添加
```

对于自己的代码，也应该尽量处理零值的情况




golang-open-source-projects
----------------------------------

- https://github.com/hackstoic/golang-open-source-projects

这个项目可以理解为针对互联网IT人打造的中文版awesome-go。已有的awesome-go项目， 汇总了很多go开源项目， 但存在的问题是收集太全了， 而且每个项目没有详细描述。

本项目作为awesome-go的一个扩展，根据go语言中文社区提供的资料，还有互联网企业架构设计中的常见组件分类， 共精心挑选了154个开源项目（项目不限于在github开源的项目）， 分成以下17个大类。

项目初衷是帮助到那些想学习和借鉴优秀golang开源项目， 和在互联网架构设计时期望快速寻找合适轮子的人。

ps: 以下项目star数均大于100，且会定期检查项目的url，剔除无效链接。 每个分类下的项目会按照star数从高到低进行排列。



