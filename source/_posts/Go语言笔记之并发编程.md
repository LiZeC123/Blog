---
title: Go语言笔记之并发编程
date: 2022-01-11 11:51:14
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---



设计哲学
------------------


当两个或多个操作必须按正确的顺序执行，而程序并未保证这个顺序，就会发生竞争条件. 通过假设设置协程到执行协程需要很长时间, 有助于分析程序中可能存在的竞争条件.

临界区: 程序中需要独占访问共享资源的部分
内存同步: 
有一个专有名词，叫｜临界区

使用通信未共享内存，而不是通过共享内存未通信. 大部分问题都可以通过传统的锁或者GO的通道解决, 选择最好描述和最简单的那个方.


协程
------------

协程是Go的运行时管理的一种轻量级的线程.  使用go关键字即可使一个函数在协程上运行, 例如

```go
func say(s string) {
    for i := 0; i < 5; i++ {
        time.Sleep(100 * time.Millisecond)
        fmt.Println(s)
    }
}

func main() {
    go say("world")
    say("hello")
}
```

不同于Python语言中协程之间完全通过自主切换实现调度的单线程模式, Go的协程与Go运行时深度集成, 在自己的代码中不需要进行任何额外的操作, 运行时会观察协程的执行状态, 自动地进行切换. 因此Go的协程更像一种轻量级的线程.

> 协程非常的轻量, 1GB内存即可启用将近4万个空协程





通道
--------

channels是Go中不同协程之间的通信机制, 正如channels这个名字所表达的意思, channels可以视为一个可以保证线程安全的队列.


### 初始化

channels是引用语义的数据结构, 可以使用make函数创建, 例如

```go
ch1 := make(chan int)
ch2 := make(chan int, 10)
```

创建通道时可以指定队列的大小, 从而使通道具有一定的缓冲区容量. 队列满时添加操作被阻塞, 队列空时获取操作被阻塞.

> 依然使用`len()`和`cap()`函数获取通道的队列中当且元素的数量, 以及队列的容量


### 发送和接收数据

发送和接收数据都使用`<-`运算符, 根据`<-`与通道的位置判断是发送数据还是接收数据. 例如

```go
ch <- 42
x := <- ch
```

### 管道

有一种基于通道的编程模式称为管道, 即一个通道的输出作为下一个通道的输入. 这种模式类似于Java中的Stream模式. 例如下面的三组协程, 实现了生成自然数, 平方给定的数字, 以及输出数字的功能.

```go
func main() {
    nums := make(chan int)
    square := make(chan int)

    go func() {
        for i := 0; i < 10; i++ {
            nums <- i
        }
    }()

    go func() {
        for {
            x := <-nums
            square <- x * x
        }
    }()

    for {
        x := <-square
        fmt.Println(x)
    }
}
```

直接运行上面的代码最后会产生异常, 报告所有的协程都进入休眠状态, 程序死锁. 产生这一错误的原因是生成自然数的协程完成任务后没有正确的通知其他协程任务结束, 导致其他协程在相关的通道上无限等待. 可以对上述代码进行修改

```go
func main() {
    nums := make(chan int)
    square := make(chan int)

    go func() {
        for i := 0; i < 10; i++ {
            nums <- i
        }
        close(nums)     // 使用close关闭通道
    }()

    go func() {
        for x := range nums {   // 使用range关键字遍历, 通道关闭后自动结束循环
            square <- x * x
        }
        close(square)
    }()

    for x := range square {
        fmt.Println(x)
    }

    return
}
```

> 通道并不一定要手动关闭, 当其失去所有引用时会自动被垃圾回收


### 只读与只写

基于管道的编程模式经常需要将一个通道作为输入, 另一个通道作为输出, 为了避免参数传递错误, 导致逻辑错误, 可以在函数的声明时指定通道是只读还是只写

```go
func counter(out chan<- int) {
    for x := 0; x < 100; x++ {
        out <- x
    }
    close(out)
}

func squarer(out chan<- int, in <-chan int) {
    for v := range in {
        out <- v * v
    }
    close(out)
}

func printer(in <-chan int) {
    for v := range in {
        fmt.Println(v)
    }
}

func main() {
    naturals := make(chan int)
    squares := make(chan int)
    go counter(naturals)
    go squarer(squares, naturals)
    printer(squares)
}
```


多路复用
-------------

使用select语句可以使协程在多个条件上等待, 直到其中一个条件能够执行时, 执行相应的语句. 


```go
func fibonacci(c, quit chan int) {
    x, y := 0, 1
    for {
        select {
        case c <- x:        // 等待c通道可以写入
            x, y = y, x+y
        case <-quit:        // 等待quit通道可以读取
            fmt.Println("quit")
            return
        }
    }
}

func main() {
    c := make(chan int)
    quit := make(chan int)
    go func() {
        for i := 0; i < 10; i++ {
            fmt.Println(<-c)    // 循环读取c通道, 使得fibonacci函数能够持续计算
        }
        quit <- 0                // 向quit写入数据, 使得fibonacci函数中quit通道变为可读状态
    }()
    fibonacci(c, quit)
}

```

在执行select语句时
- 如果多个通道均可以执行, 则随机选择一个条件分支执行
- 如果没有任何分支可以执行, 则select语句进入阻塞状态, 直到其中的某一个分支可执行
- 如果存在default分支, 则其他分支不满足条件时自动执行default分支

> 给select语句添加一个`time.After`分支, 可以简单地实现超时控制.



如果同时有多个条件可以执行, 则Go



并发控制包
----------------


### 基础锁组件

go的`sync`包提供了`Mutex`类, 实现了基本的**不可重入的**排它锁. 具体方法包括

```go
func (m *Mutex) Lock()
func (m *Mutex) TryLock() bool
func (m *Mutex) Unlock()
```

提供的接口比较简单, 与其他语言中的使用方法基本一致. 为了保证正确的释放锁, 通常在获取锁后立刻使用defer语句释放锁.

> 由于Go的作者认为如果代码需要重入锁, 则表明代码存在耦合问题, 因此Go中并不提供任何可重入锁

-----------

相应的, go也提供了`RWMutex`类, 实现了**不可重入的**, **类似于公平锁**的读写锁. 具体方法包括

```go
func (rw *RWMutex) Lock()
func (rw *RWMutex) RLock()
func (rw *RWMutex) RUnlock()
func (rw *RWMutex) TryLock() bool
func (rw *RWMutex) TryRLock() bool
func (rw *RWMutex) Unlock()
```

> `RWMutex`类实现了类似公平锁的特性, 如果一个协程尝试获取写锁, 则其他协程无法再获得读锁, 即使按照读写锁性质可以获得读锁.


### WaitGroup

WaitGroup用于在多个线程之间同步, 与Java中的`CounterDown`类效果类似, 具体方法包括

```go
func (wg *WaitGroup) Add(delta int)
func (wg *WaitGroup) Done()
func (wg *WaitGroup) Wait()
```


一个典型的场景是开启多个协程执行任务, 并等待所有协程执行完毕, 此时可以使用如下的代码

```go
package main

import (
    "fmt"
    "sync"
)

func main() {
    var wg sync.WaitGroup
    numGoroutines := 30

    wg.Add(numGoroutines)
    for i := 0; i < numGoroutines; i++ {
        go func(id int) {
            defer wg.Done()
            fmt.Println("Goroutine id:", id)
        }(i)
    }

    wg.Wait()
}
```


> WaitGroup适合不需要关注并发结果, 仅需要等待其他协程执行完毕的场景. 如果需要关注协程执行的结果, 此时更适合使用通道和select语句.


### Once

Once类可以保证其中提交的方法无论在多少个线程中执行, 都只会执行一次,

```go
func main() {
    var once sync.Once
    onceBody := func() {
        fmt.Println("Only once")
    }
    done := make(chan bool)
    for i := 0; i < 10; i++ {
        go func() {
            once.Do(onceBody)
            done <- true
        }()
    }
    for i := 0; i < 10; i++ {
        <-done
    }
}
```

### Map

go提供了可以并发使用的`Map`类, 但由于不支持泛型, 官方建议在大部分场景优先考虑使用加锁的普通map对象. 只有如下的几个场景中可以考虑优先使用`Map`类.

- 存在一个key写入后基本只有读取操作的场景
- 存在大量协程读写互不相交的一组key的场景

上述两个场景下使用`Map`类能够一定程度的减少手动加`Mutex`锁或`RWMutex`锁产生的冲突.


### 扩展阅读

- [Go Documentation of sync](https://pkg.go.dev/sync)
- [Go语言如何实现可重入锁？](https://segmentfault.com/a/1190000040092635)


Context包
-------------

go语言中的Context对象主要用户协程之间的上下文信息传递以及并发控制. Context是一个接口类型, 定义了四个方法


```go
type Context interface {
    // 返回这个任务的截止时间, 如果没有设置截止时间, 则ok返回false
    Deadline() (deadline time.Time, ok bool)

    // Done方法返回一个通道, 如果当前任务需要被取消, 则该通道被关闭, 通常按照如下的方式使用
    //  // Stream generates values with DoSomething and sends them to out
    //  // until DoSomething returns an error or ctx.Done is closed.
    //  func Stream(ctx context.Context, out chan<- Value) error {
    //      for {
    //          v, err := DoSomething(ctx)
    //          if err != nil {
    //              return err
    //          }
    //          select {
    //          case <-ctx.Done():
    //              return ctx.Err()
    //          case out <- v:
    //          }
    //      }
    //  }
    //
    // See https://blog.golang.org/pipelines for more examples of how to use
    // a Done channel for cancellation.
    Done() <-chan struct{}

    // 如果任务被取消,返回取消的具体原因. 否则始终返回nil
    Err() error

    Value(key interface{}) interface{}
}
```

context通过内嵌父context的方式记录依赖关系, 有点类似Lisp的cons结构. 例如WithDeadline方法在给定的context对象基础上返回新的context, 使得达到截止时间时关闭done通道.

> Context的设计哲学要求Context不可修改, 不可复制. 因此如果需要修改, 可以通过覆盖的方式实现


- [小白也能看懂的context包详解：从入门到精通](https://segmentfault.com/a/1190000040917752)



数据竞争检测
--------------

`-race`参数（也称为"竞态检测器"）是Go工具链中强大的一个功能，它用于在编译和测试Go程序时检测代码中的数据竞态。数据竞态是指两个或更多的协程（goroutines）在没有适当同步的情况下并发访问共享数据时，程序的输出取决于具体执行情况。这通常导致不确定的行为和难以调试的错误。

通过添加`-race`标志，Go工具链会插入特殊的处理函数和编译选项，以便在运行时监控对共享数据的访问，以注册和报告任何数据竞态。它会记录并发访问的内存地址、协程（goroutine）ID和访问顺序（是读操作还是写操作）等信息。当它检测到互相冲突的访问活动（例如，同时发生的一个读操作和一个写操作）时，它将报告详细的错误信息，包括涉及的协程（goroutine）ID、源代码文件和行号等。

`-race`标志可以用在编译、测试和运行命令上：

- `go build -race`: 用于生成一个带有竞态检测器的二进制文件。
- `go test -race`: 在运行测试时激活竞态检测器以检测测试用例中的数据竞态。
- `go run -race`: 在运行程序时激活竞态检测器。

需要注意的是，使用竞态检测器会增加程序的运行时间和内存使用，因为它需要在运行时记录和处理更多的数据。通常，仅在开发和测试环境中使用竞态检测器，而不建议在生产环境中使用。

有关竞态检测器的详细信息，您可以查阅官方文档：https://golang.org/doc/articles/race_detector.html