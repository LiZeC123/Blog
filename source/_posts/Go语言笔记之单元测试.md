---
title: Go语言笔记之基础知识
date: 2024-11-02 15:00:28
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---


Go语言作为一个较为现代的语言, 其工具链中已经内置了单元测试相关的组件, 仅需要在当前模块下创建以`_test.go`结尾的文件来表明一个文件是测试文件, 并使用特定的前缀表明一个函数是测试函数.


基本测试
----------

基本测试的函数名前缀为Test, 例如

```go
// 测试函数的参数为*testing.T, 该参数提供了一些方法用于决策测试是否通过
func TestHelloName(t *testing.T) {    
    name := "Gladys"
    want := regexp.MustCompile(`\b`+name+`\b`)
    msg, err := Hello("Gladys")
    if !want.MatchString(msg) || err != nil {
        t.Fatalf(`Hello("Gladys") = %q, %v, want match for %#q, nil`, msg, err, want)
    }
}
```


由于基本测试是最常见的测试, 因此运行当前位置下的所有基本测试的指令最为简单, 仅需要执行

```bash
go test -v
```

其中`-v`参数用于打印详细信息, 如果不需要查看详细信息则可以进一步省略该参数, 直接以无参数的方式执行指令. 如果需要执行某一个特定的单元测试, 则可以使用`-run`参数指定具体的函数名, 例如

```bash
go test -run TestFunction
```


基准测试
----------

基准测试的函数名前缀为Benchmark, 例如

```go
// 基准测试的参数为*testing.B, 方提供的法与*testing.T基本相同
func BenchmarkSplit(b *testing.B) {
    time.Sleep(5 * time.Second) // 假设需要做一些耗时的无关操作

    b.ResetTimer()              // 重置计时器
    for i := 0; i < b.N; i++ {
        // b.N是一个特殊的变量, Go会自动设置该变量的取值, 使得被测试的函数执行足够长的时间
        strings.Split("沙河有沙又有河", "沙")
    }
}
```

默认情况下, Go不会执行任何基准测试, 如需运行则需要携带`-bench`参数, 例如为

```bash
go test -bench .
```


示例测试
----------

示例测试的函数名前缀为Example, 示例测试的函数既无输入也无输出, 主要用于为文档提供示例. Go的文档工具会将示例测试的代码复制到输出的文档之中. 例如

```go
func ExampleSplit() {
	fmt.Println(split.Split("a:b:c", ":"))
}
```


数据竞态测试
--------------


Go语言内置了强大的并发能力, 因此在开发并发的代码时, 有很强的数据竞态测试需求, 即通过运行本地的单元测试分析一段代码是否具有多个协程在没有适当同步的情况下并发访问共享数据的问题.

Go在执行测试时, 可加入`-race`参数执行数据竞态测试. 其原理是在编译过程中, 加入特殊的处理函数, 以便在运行时监控对共享数据的访问, 从而可以判断是否存在读写冲突问题.

数据竞态测试通常需要依赖CGO特性, 因此通常使用如下的模式启动测试

```sh
CGO_ENABLED=1 go test -race -run TestGoReadMap
```

- [官方文档](https://golang.org/doc/articles/race_detector.html)



Mock函数
-------------

理想情况下, 如果代码仅通过接口的方式与其他模块交互, 则可以比较容易的根据接口创建Mock对象并替换. 但实际开发过程中, 存在许多直接与其他模块交互的场景, 此时需要使用Mock框架在运行时修改函数实现, 以达到Mock的效果.

此类框架的基本原理是在程序启动后, 修改需要Mock的函数的内存, 将函数体修改为调用指定的Mock函数. 实现此功能需要依赖如下的一些条件

1. 可通过反射技术在运行时获得被Mock的函数地址
2. 操作系统支持将被Mock的函数位置的内存从只读修改为可写
3. 被Mock的函数的函数体占用的内存足够长, 在写入调用Mock函数的二进制指令后不至于超过函数范围.

因此如果函数被内联, 操作系统不可修改内存属性, 或者函数太短都可能导致替换失败.

> 基于本地Mock的方式, 可以对一些比较难以在本地运行的代码进行测试, 从而能提前发现问题.


### Mockery框架

[Mockery](https://github.com/bytedance/mockey)是字节跳动开源的一款Go Mock框架, 基于上述的运行时字节替换原理实现对任何代码的Mock能力. 通常可以按照如下的模式使用Mockery框架

```go
import (
    "github.com/bytedance/mockey"
	"github.com/stretchr/testify/assert"
)

func TestGetUser(t *testing.T) {
    // 替换操作仅在PatchConvey传入的函数内生效, 离开此函数自动恢复, 从而避免各类Mock操作相互干扰
	mockey.PatchConvey("TestGetUser", t, func() {
		// 将rpc.GetUser 替换为 MockTestGetUser, 调用Build函数后生效
        mockey.Mock(rpc.GetUser).To(MockTestGetUser).Build()
		
        // 被测试函数, 其中包含了对 rpc.GetUser 的调用
		m := GetUsers("username")

        // 断言结果
		assert.Equal(t, len(m), 3)
	})
}
```

执行Mock操作必须关闭函数内联, 因此通常以如下的模式启用测试

```sh
go test -gcflags="all=-l -N" -run TestGetUser
```


其他常用参数
----------

### 抑制PB冲突


由于一些代码的历史原因, PB直接可能存在名称冲突问题. 此时可通过如下指令在运行测试时将冲突的panic改为warning

```sh
go test -ldflags " -X google.golang.org/protobuf/reflect/protoregistry.conflictPolicy=warn" -run TestGoReadMap
```




参考资料
---------


- [Go语言基础之单元测试](https://www.liwenzhou.com/posts/Go/unit-test/#autoid-2-5-0)
- [Go语言圣经 测试](https://gopl-zh.codeyu.com/ch11/ch11.html)
