---
title: Go语言笔记之性能分析
math: false
date: 2024-03-24 21:14:11
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---



垃圾回收算法
--------------------

Go的垃圾回收算法是三色算法，即根据对象之间的引用关系，将对象分割为白色对象，灰色对象和黑色对象。 垃圾回收过程使用单独的线程进行处理，并使用写屏障维护指针的关系。


### 三色标记法

将程序中的对象分成白色 黑色 和灰色三类：

- 白色：潜在的垃圾，可能会被回收
- 黑色：活跃的对象，不会被回收
- 灰色：活跃的对象，有指向白色对象的指针

### gc过程

开始垃圾回收时，不存在任何的黑色对象，会把根对象(不需要其他对象就可以访问到的对象：全局对象 栈对象)标记成灰色，垃圾回收只会从灰色的集合中取出对象开始扫描，当没有一个灰对象时标记阶段结束。

具体的扫描逻辑是： 从灰对象集合中选择一个灰色并标记成黑色；将黑对象指的所有对象都标记成灰色，来保证不会被回收，然后重复直到灰对象集合中没有灰对象

### 写屏障

垃圾标记和正常程序是同时进行，所以有可能出现标记错的情况，比如扫描了a 以及a所有的子节点后，这时候用户建立了a指向b的引用，这时b是白色会被回收，所以引入了屏障。它可以在执行内存相关操作时遵循特定的约束，在内存屏障执行前的操作一定会先于内存屏障后执行的操作。屏障有两种，写屏障和读屏障，因为读屏障需要在读操作中加入代码，对性能影响大，所以一般都是写屏障。

业界有两种写屏障 ： 插入写屏障和删除写屏障 1.7用的插入写屏障 1.8用的混合写屏障

- 插入写屏障： 当A对象从A指向B改成从A指向C时，把BC都改成灰色。
- 删除写屏障：在老对象的引用被删除时，将白色的老对象改成灰色
- 混合写屏障 ：将被覆盖的对象标记成灰色 & 没有被扫描的新对象也被标记成灰色 & 将创建的新对象都标记成黑色

> 屏障必须遵守三色不变性 ： 强三色不变性:黑色对象不会指向白对象，只会指向灰色对象或者黑色对象 弱三色不变性：黑色对象指向的白色对象必须包含一条从灰色对象经由的多个白色对象的可达路径

### 垃圾回收阶段

- stw
- 开启写屏障
- stw结束
- 扫描根对象
- 依次处理灰对象
- 关闭写屏障
- 清理所有白对象

### 垃圾回收触发条件

- 用户触发 runtime.gc
- 堆内存比上次垃圾回收增长100%
- 离上次垃圾回收超过2min

### 参考资料

- [Go 语言内存分配器的实现原理 | Go 语言设计与实现](https://draveness.me/golang/docs/part3-runtime/ch07-memory/golang-memory-allocator/)



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




GC优化
--------------


- [只改一个参数让Golang GC耗时暴降到1/30！-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/2356881)