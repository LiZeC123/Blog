---
title: Go语言笔记之并发编程
date: 2022-01-11 11:51:14
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



并发编程
-------------

### 协程

协程是Go的运行时管理的一种轻量级的线程. 协程之间通过自己主动切换来实现调度. 使用go关键字即可使一个函数在协程上运行, 例如

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


### 通道

```go
func sum(s []int, c chan int) {
    sum := 0
    for _, v := range s {
        sum += v
    }
    c <- sum // send sum to c
}

func main() {
    s := []int{7, 2, 8, -9, 4, 0}

    c := make(chan int)
    go sum(s[:len(s)/2], c)
    go sum(s[len(s)/2:], c)
    x, y := <-c, <-c // receive from c

    fmt.Println(x, y, x+y)
}
```

> make创建通道时, 可以额外用一个参数指定通道缓冲区的大小, 此时只有缓冲区空或者满时才会阻塞


> 可以调用close函数关闭通道, 但一般情况下不需要手动关闭

### select

select语句可以时协程在多个条件上等待, 直到其中一个条件能够执行时, 执行相应的语句.  如果同时有多个条件可以执行, 则Go随机选择一个条件分支执行. 


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