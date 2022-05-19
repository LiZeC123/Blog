---
title: Go语言笔记之并发编程
date: 2022-01-11 11:51:14
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---





协程
------------

协程是Go的运行时管理的一种轻量级的线程. 不同于Python语言中协程之间完全通过自主切换实现调度的单线程模式, Go的协程更像一种轻量级的线程. 在代码中不需要调用特殊的API就可以直接启用协程.

使用go关键字即可使一个函数在协程上运行, 例如

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


### 并发控制

由于Go启用协程的代价非常低, 因此很容易在代码中引入多个协程并发的执行任务, 此时也会面临类似Java中的并发控制问题, Go提供了`sync.WaitGroup`等工具帮助完成协程之间的同步问题.


### 多路复用

使用select语句可以使协程在多个条件上等待, 直到其中一个条件能够执行时, 执行相应的语句. 如果同时有多个条件可以执行, 则Go随机选择一个条件分支执行. 


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