---
title: Go语言笔记之基础知识
date: 2021-07-01 20:06:01
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


Go基础配置
---------------

Go语言的下载和安装过程比较简单, 不需要进行特殊处理. 在Go安装完毕后, 需要注意两个特殊的环境变量`GOROOT`和`GOPATH`. 其中`GOROOT`表示Go语言安装的位置, 安装后自动设置不需要管. `GOPATH`表示项目的位置, 一般位于用户目录下的`go`目录, 例如在我的电脑上就是`C:\Users\lizec\go`

因为`GOPATH`指定了项目的存放位置, 所以一般情况下就不要在其他地方放置源代码, 否则虽然Go也能编译项目, 但其他工具不一定完全支持. `GOPATH`下一般具有如下的目录结构

```
- bin
    - gocode.exe
    - godef.exe
    - ...
- pkg
    - mod
    - sumdb
- src
    - example.com
        - gohttp
        - hello
    - github.com
        - cmp
```

其中`bin`目录存放编译好的可执行文件, `pkg`目录存放相关的包, `src`目录存放源代码. 由于Go项目的名称需要表示如何下载这个项目, 所以源码的文件夹一般以发布代码的平台开头, 例如在Github上发布代码, 则以`github.com`开头.

> 可以使用`go env`指令查看和管理所有go相关的环境变量

- [一招完美解决vscode安装go插件失败问题](https://blog.csdn.net/qq_41065919/article/details/107710144)


Go项目开发流程
---------------

### 初始化项目

需要初始化一个Go项目时, 首先创建保存项目的文件夹, 然后执行

```
go mod init example.com/hello
```

Go语言中以模块作为基本单位, 所以创建一个项目就是创建一个模块. 最后的`example.com/hello`是模块的名称. 执行完此命令以后, Go会在当前目录下创建`go.mod`文件, 其中存储了此模块的基本信息, 例如模块的名称, 使用的Go语言版本, 依赖的模块等. 

> 如果在`GOPATH`的`src`目录初始化, 那么也可以不指定模块名称, Go可以自动根据路径产生模块名称


### 引入第三方模块

需要使用第三方模块时, 可以使用[https://pkg.go.dev/](https://pkg.go.dev/)网站查询需要的模块.  进入相应模块的详细页面中可以看到模块的主要功能, API文档等信息. 找到需要的模块后, 使用get指令获取这一模块, 例如

```
go get rsc.io/quote
```

以上指令会更新当前模块的`go.mod`文件, 并下载对应的依赖, 之后在代码中可以通过import的方式引入模块, 例如

```go
package main

import "fmt"
import "rsc.io/quote"


func main() {
    fmt.Println(quote.Go())
}
```

> 可以使用`go mod tidy`使编译器检查依赖变化, 添加新的依赖, 删除未使用的依赖

### 添加测试

在当前模块下创建以`_test.go`结尾的文件来表面一个文件是测试文件. 在测试文件中可以进行任意形式的测试, 例如

```go
import (
    "testing"
    "regexp"
)

// TestHelloName calls greetings.Hello with a name, checking
// for a valid return value.
func TestHelloName(t *testing.T) {
    name := "Gladys"
    want := regexp.MustCompile(`\b`+name+`\b`)
    msg, err := Hello("Gladys")
    if !want.MatchString(msg) || err != nil {
        t.Fatalf(`Hello("Gladys") = %q, %v, want match for %#q, nil`, msg, err, want)
    }
}

// TestHelloEmpty calls greetings.Hello with an empty string,
// checking for an error.
func TestHelloEmpty(t *testing.T) {
    msg, err := Hello("")
    if msg != "" || err == nil {
        t.Fatalf(`Hello("") = %q, %v, want "", error`, msg, err)
    }
}
```

最后使用

```
go test -v
```

运行测试并查看测试结果



### 编译应用程序

每个应用程序需要包含一个main包并包含一个位于此包下的main函数.  然后使用

```
go build
```

编译应用程序并生成可执行文件.  如果进一步执行

```
go install
```

还可以将此可执行文件复制到指定的目录之中. 

### 发布模块

模块在发布以后才能够被其他模块引用. 因为模块的名称会作为获得模块的依据, 因此在创建模块的时候就需要设置一个合适的模块名称. 例如创建模块时打算在GitHub上进行发布, 那么可以在GitHub上创建一个仓库, 然后以仓库的URL路径作为名称（例如`github.com/LiZeC123/go-test`）

此后在开发代码的过程中, 对GitHub上的代码标记适当的版本tag就完成来模块的发布. 

----------

对于自己使用的模块, 如果不想走发布流程, 也可以通过编辑`go.mod`文件来修改Go语言查找模块的方式, 从而即使不发布模块也能够被其他模块引用. 指令为

```
go mod edit -replace=example.com/greetings=../greetings
```

这条指令的含义非常简单, 即如果需要查找`example.com/greetings`模块, 就访问`../greetings`路径.  执行上面的指令后, 会在`go.mod`文件中加入如下的一行内容

```
replace example.com/greetings => ../greetings
```


错误处理
----------

错误处理分为两个部分, 即如何抛出错误和如何处理错误.  因为Go语言的函数支持返回多个值, 因此如果一个函数需要抛出错误, 一般具有如下的格式

```go
// 导入errors模块
import (
    "errors"
    "fmt"
)


// 返回值包含正常的输出和错误信息
func Hello(name string) (string, error) {

    if name == "" {
        // 如果出现错误, 返回错误信息
        return "", errors.New("Empty Name")
    }

    message := fmt.Sprintf("Hi, %v. Welcome!", name)

    // 如果没有错误, 错误信息位置返回nil
    return message, nil
}
```


当调用这种函数时, 一般具有如下的格式

```go
func main() {
    // 调用时接受返回值和错误信息
    message, err := greating.Hello("")
    // 检查是否有错误
    if err != nil {
        // 有错误执行错误分支
        log.Fatal(err)
    }
    // 没有错误执行正常分支
    fmt.Println(message)
}
```

> 以上为Go语言中标准的错误抛出和处理方案


模块和包
-------------

Go程序的基本单位是模块, 一个Go应用程序对应一个模块, 一个Go的库也对应一个模块. Go语言中的模块基本等价于Java中的项目，但Go不要求模块的名称与项目名称一致，而且为了方便Go的工具获取模块, 模块名称一般是一个URL的一个部分。例如模块`golang.org/x/tools`表明Go的工具可以直接访问`https://golang.org/x/tools`来获取这一模块. 

Go语言中也有包的概念，一个包由一组位于同一目录下的若干源文件组成. Go的包名称不必和目录名称一致, 只需要保证位于同一目录下的所有文件声明的包名称是一致的即可。例如在`ROOT/hello`目录下的文件包名可以是`hello`也可以是`abc`或者任何其他的名称, 但位于该目录下的文件必须具有同样的包名称. 

> Go语言中的包可以视为一种将大文件拆分为小文件的方式

在项目中使用import语句导入包，如果包名以`./`开头，则使用相对路径查找指定的包。如果包名以`/`开头，则使用绝对路径查找指定的包。如果直接以包名开头，则在指定的位置查找。

> 由于使用go get安装的包位于GOPATH中，因此第三方包和系统标准库都可以直接导入

同一个包内的一个文件中的函数变量等各种元素对包内的其他文件都是可见的. 只有以首字母大写的函数和变量是导出的，可以被外部的代码访问。


语法结构
------------

### 变量与常量

Go语言中以如下的方式声明变量和常量
```go
var varName1 type1      // 声明type1类型的变量
const varName2 type2    // 声明type2类型的常量
var var3 = 3.14         // 自动推导变量类型
var4 := 3               // 根据初始值自动推导类型并声明变量
```

注意：
- `:=`表达式只能在函数体内使用, 全局变量声明不能使用此特性
- 多个变量可以同时赋值, 例如`a,b = b,a`
- 每个文件都可以定义一个init函数, 使得包加载时执行指定操作


### 控制流

Go的if结构与C语言类似, 但是不需要圆括号且始终需要大括号, 例如

```go
if x < 0 {
    return sqrt(-x) + "i"
}
```

可以在if的条件前加入一个语句, 这个语句在执行后再进行if条件判断, 例如

```go
if v := math.Pow(x, n); v < lim {
    return v
}
```

这一语法可以将代码和错误处理合并到一行语句中，例如

```go
if err := binary.Write(f, binary.BigEndian, chunk.Size); err != nil {
    log.Fatal(err)
}
```

---------------------


Go语言只有一种循环语句, 即for循环. 通过设置不同的条件来实现不同的循环语句, 例如

```go
func main() {
    sum := 0
    for i := 0; i < 10; i++ {
        sum += i
    }
    fmt.Println(sum)
}

func main() {
    sum := 1
    for sum < 1000 {
        sum += sum
    }
    fmt.Println(sum)
}
```

### defer

被defer修饰的语句会在当前模块的其他语句执行结束后执行. 如果是函数调用, 那么函数的参数会立即计算, 但函数调用会延后执行. 

```go
func main() {
    defer fmt.Println("world")

    fmt.Println("hello")
}
```

> 对于需要关闭的资源, 在开启后紧跟一个defer引导的关闭语句就可以确保不会忘记关闭资源


函数
-------------

Go语言中的函数一般具有如下的格式
```go
func functionName(param1 type1, param2 type2) (ret1 type1, ret2 type2) {
    // function code
}
```




结构体
--------------


Go语言中的结构体与C语言中的结构体定义基本一致. 一个简单的结构体定义如下

```go
type Vertex struct {
    X int
    Y int
}

func main() {
    fmt.Println(Vertex{1, 2})
    v.X = 4
    // 指针操作与C类似, 但不需要 ->
    p := &v
    p.X = 1e9
}
```


在代码中可以直接创建结构体, 也能够通过new关键字以指针的形式访问

```go
type Interval struct {
    start int
    end   int
}

intr := Interval{0, 3}  
intr := Interval{end:5, start:1}
intr := Interval{end:5}

p := new(Interval)
p := &Interval{0, 3} // 特殊写法, 本质还是new初始化
```

> 和C一样, Go的结构体布局默认是紧凑的连续存储布局, 只有显式地存放指针的时候才会和Java的对象布局一样.


### 构造函数

由于Go中实际上并不存在类, 因此如果一个结构体需要初始化函数, 通常创建一个以new开头的函数, 例如
```go
type File struct {
    fd      int     // 文件描述符
    name    string  // 文件名
}

func NewFile(fd int, name string) *File {
    if fd < 0 {
        return nil
    }

    return &File{fd, name}
}
```

> 通过控制结构体本身的可见性和构造函数的可见性就可以实现强制使用构造函数

### 匿名成员

在定义结构体时可以不指定成员变量的名称，而是直接给定类型，此时相当于定义了一个与类型同名的成员变量

```go
type MyNumber struct {
	int
	float32
}

number := MyNumber{
    int:     12,
    float32: 3.14,
}
```


### 结构体嵌套

除了基本类型以外，结构体类型也可以声明匿名成员，此时就相当于将该结构体直接嵌入到定义的结构体中。例如

```go

type Honor struct {
	Title string
	GetTime time.Time
}

type Chef struct {
	Name string
	Age int
	Honor
	Trainee *Chef
}

func main() {
	chef := Chef{Name: "LiZeC", Age: 3, Honor:Honor{}, Trainee: nil}
    chef.Honor.GetTime = time.Now()     // 通过Horror间接访问 
	chef.Title = "Honor Test"           // 直接访问
}
```

定义Chef类型时，直接声明了一个Honor类型而没有设置变量的名称（也被称为匿名成员），此时Chef等价于自动具有了Honor类型的所有字段，可以直接用对应的变量名访问。


### 方法

Go语言中并没有类, 但可以把方法绑定到一个类型上. 例如

```go
type Vertex struct {
    X, Y float64
}

func (v Vertex) Abs() float64 {
    return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v *Vertex) Scale(f float64) {
    v.X = v.X * f
    v.Y = v.Y * f
}


func main() {
    v := Vertex{3, 4}
    fmt.Println(v.Abs())
}
```

当Vertex直接以值类型的形式声明时, 采取复制的方式传递值, 因此方法内部不能对变量进行修改(准确来说, 修改是无效的)，同时拷贝数据也会产生一些性能消耗. 如果希望方法能够修改变量, 或者避免拷贝大量数据的性能消耗，则可以声明为指针类型。

绑定在值类型上的方法和绑定在指针类型上的方法属于不同的集合。但用方法时Go会自动转换，因此无论调用方是值类型还是指针类型都可以直接调用。

------------------------------------------------------------------------------

除了绑定在一个自定义的类似上, 也可以绑定到已有的类型上, 例如

```go
type MyFloat float64

func (f MyFloat) Abs() float64 {
    if f < 0 {
        return float64(-f)
    }
    return float64(f)
}

func main() {
    f := MyFloat(-math.Sqrt2)
    fmt.Println(f.Abs())
}
```

> 方法只能绑定在同一个包中的类型上



接口
-------

与其他语言中的概念一致, 接口是一组方法签名的集合.  例如

```go
type Abser interface {
    Abs() float64
}
```

可以将实现了接口中方法的变量赋值给接口, 例如

```go
type Vertex struct {
	X float64
	Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	var abser Abser
	abser = &Vertex{}
}
```

**注意：**  绑定在值类型的方法和绑定在指针类型上的方法属于不同的集合，因此在对**接口**赋值时, 需要保证对象具有的方法完全一致。由于Abs方法绑定在*Vertex类型，因此只能将Vertex类型取地址后复制给Abser接口。

> Go语言的接口是鸭子类型的，只要实现了对应的方法就可以视为对应的接口. 


### 接口类型转换

可以使用如下的语法得到接口下对应的具体实现

```go
func main() {
    var i interface{} = "hello"

    s := i.(string)
    fmt.Println(s)

    s, ok := i.(string)
    fmt.Println(s, ok)

    f, ok := i.(float64)
    fmt.Println(f, ok)

    f = i.(float64) // panic
    fmt.Println(f)
}

func do(i interface{}) {
    switch v := i.(type) {
    case int:
        fmt.Printf("Twice %v is %v\n", v, v*2)
    case string:
        fmt.Printf("%q is %v bytes long\n", v, len(v))
    default:
        fmt.Printf("I don't know about type %T!\n", v)
    }
}
```

### 嵌套接口

一个接口可以包含一个或多个其他的接口, 这相当于直接将这些内嵌接口的方法列举在外层接口中一样.

```go
type ReadWrite interface {
    Read(b Buffer) bool
    Write(b Buffer) bool
}

type Lock interface {
    Lock()
    Unlock()
}

type File interface {
    ReadWrite
    Lock
    Close()
}
```

---------------------

除了接口继承接口以外，也可以使用结构体继承接口，例如

```go
type UpperWriter struct {
	io.Writer
}

func (p *UpperWriter) Write(data []byte) (n int, err error) {
	return p.Writer.Write(bytes.ToUpper(data))
}

func main() {
 	fmt.Fprintln(&UpperWriter{Writer:os.Stdout}, "Hello World");
}
```

首先UpperWriter声明了一个匿名接口io.Writer，因此获得了一个成员变量Writer，该成员具有一个Write方法的声明，但是没有具体的实现。在创建UpperWriter时，将os.Stdout绑定到成员变量Writer上（也就是将一个实现了对应方法的结构体赋值给接口），因此，调用Writer.Write就等价于调用os.Stdout.Write

之后UpperWriter对自己的指针类型绑定了一个Write方法，将文本大写后转发给成员变量Writer进行处理。

> 注意：由于UpperWriter直接内嵌io.Writer，因此原本就可以直接调用Write方法，此时等价于调用Writer.Write。通过重新绑定Write方法，相当于对这一行为进行了重写。

最后，由于接口io.Writer只定义了一个Write方法，而UpperWriter的Write方法绑定在指针上，所以传入fmt.Fprintln时需要取地址才能转化为io.Writer接口。


### 空接口

空接口是指不定义任何方法的接口, 任何其他类型都实现了空接口. 因此空接口也类似于Java中的Object对象. 通常可以将空接口命名为`Any`, 例如

```go
type Any interface {}
```

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