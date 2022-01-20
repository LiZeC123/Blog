---
title: Go相关知识
date: 2021-12-16 08:00:00
---


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


排序
------------

对于简单的结构体数组，可以使用`sort.slice`方法，例如

```go
sort.Slice(planets, func(i, j int) bool {
  return planets[i].Axis < planets[j].Axis
})
```

- [What is the shortest way to simply sort an array of structs by (arbitrary) field names?](https://stackoverflow.com/questions/28999735/what-is-the-shortest-way-to-simply-sort-an-array-of-structs-by-arbitrary-field)

对于复杂的数据结构，可以通过实现sort包中定义的三个接口实现排序，可参考下面的文章

- [Go 中的三种排序方法](https://learnku.com/articles/38269)



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
