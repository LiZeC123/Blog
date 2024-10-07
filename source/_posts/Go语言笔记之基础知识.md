---
title: Go语言笔记之基础知识
date: 2021-07-01 20:06:01
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---



Go基础配置
---------------

Go语言的下载和安装过程比较简单, 不需要进行特殊处理. 在Go安装完毕后, 需要注意两个特殊的环境变量`GOROOT`和`GOPATH`. 其中`GOROOT`表示Go语言安装的位置, `GOPATH`表示项目和依赖存储的位置. 一般情况下不需要关注`GOROOT`的值, 对于低版本的Go(低于1.11版本), 需要关注`GOPATH`的取值.  `GOPATH`一般指向用户目录下的`go`目录, 例如在我的电脑上就是`C:\Users\lizec\go`. `GOPATH`下一般具有如下的目录结构:

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

> ~~将自己的代码放置在src目录下是低版本Go的推荐操作, 可以最大程度的保证第三方工具的兼容性.~~
> 2024年1月更新: 当前已经距离Go1.11非常远了, 大部分工具也不存在兼容性问题了, 因此可以在任意位置放置Go项目, 而不必再局限于`GOPATH`.

配置代理
-----------

由于网络问题，无法顺畅的访问go的插件系统，因此在使用前需要对go进行配置，执行如下的指令

```
go env -w GOPROXY=https://proxy.golang.com.cn,direct
```

其中代理网站的具体地址可以访问`https://goproxy.io`查看。此外，也可以使用`go env`指令查看和管理所有go相关的环境变量

- [一招完美解决vscode安装go插件失败问题](https://blog.csdn.net/qq_41065919/article/details/107710144)


Go项目开发流程
---------------

### 初始化项目

需要初始化一个Go项目时, 首先创建保存项目的文件夹, 然后执行`go mod init`指令, 例如


```
mkdir hello
cd hello
go mod init example.com/hello
```

Go语言中以模块作为基本单位, 所以创建一个项目就是创建一个模块. 最后的`example.com/hello`是模块的名称. 执行完此命令以后, Go会在当前目录下创建`go.mod`文件, 其中存储了此模块的基本信息, 例如模块的名称, 使用的Go语言版本, 依赖的模块等. 

高版本的Go语言支持模块化, 因此模块名称和项目的实际位置不需要保持一致. 但如果将项目放置到`GOPATH`的`src`目录下, 则可以不指定名称, 由Go根据路径直接产生模块名称.

> 为了便于后续的模块发布, 一般go项目的模块名都是一个实际可以访问的域名, 对应代码的Git仓库



### 引入第三方模块

需要使用第三方模块时, 可以使用[https://pkg.go.dev/](https://pkg.go.dev/)网站查询需要的模块.  进入相应模块的详细页面中可以看到模块的主要功能, API文档等信息. 找到需要的模块后, 使用get指令获取这一模块, 例如

```bash
# 获取特定版本号的库
go get rsc.io/quote@v1.0.0  

# 获取特定commit id的库
go get rsc.io/quote@2c4df32  
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

`go.mod`文件本质上是由Go工具进行维护的, 因此虽然其中的内容是可读的, 但并不需要关注其中具体的内容. Go的编译过程会根据`go.mod`文件自动下载需要的依赖. 此外, 可以使用`go mod tidy`使编译器检查依赖变化, 添加新的依赖, 删除未使用的依赖.



### 补充说明: 模块和包

Go程序的基本单位是模块, 一个模块相当于Java语言中的一个项目. 根据模块的功能, 一个Go语言模块可以是一个可执行程序, 也可以是一个纯粹的代码库. Go的模块名称通常设置为一个URL, 从而使Go的工具能够根据名称获得对应的模块. 例如模块`golang.org/x/tools`表明Go的工具可以直接访问`https://golang.org/x/tools`来获取这一模块.

执行`go get`指令实际上就是先从指定的URL下载对应的代码, 然后在本地执行编译操作, 将代码编译为库文件或可执行文件, 最后将库文件复制到`$GOPATH/pkg`的指定位置. 之后其他项目在编译阶段就可以直接链接编译好的库文件.

- [go get命令——一键获取代码、编译并安装](http://c.biancheng.net/view/123.html)

---------------


Go语言中也有包的概念, 一个包由一组位于同一目录下的若干源文件组成. 从编译的角度来说, 一个包中的多个文件会合并成一个文件进行编译, 因此Go语言中的包可以视为一种将大文件拆分为小文件的方式. 

> 因此Go语言包内的多个文件共享名字空间, 这一点与Java和Python语言存在显著的不同

Go语言的包具有可见性控制功能, 同一个包内的一个文件中的函数变量等各种元素对包内的其他文件都是可见的. 只有以首字母大写的函数和变量是导出的, 可以被外部的代码访问. 

Go的包名称不必和目录名称一致(但建议保持一致), 只需要保证位于同一目录下的所有文件声明的包名称是一致的即可. 例如在`ROOT/hello`目录下的文件包名可以是`hello`也可以是`abc`或者任何其他的名称, 但位于该目录下的文件必须具有同样的包名称. 

在项目中使用import语句导入包, 除标准库中的包以外, 所有的包均采用`模块名/包名`的方式导入, 例如

``` go
import (
    "log"                                       // 导入标准库的包

    "github.com/LiZeC123/SmartReview/app/kb"    // 导入本项目的包
    "github.com/LiZeC123/SmartReview/app/user"
    "gorm.io/driver/sqlite"                     // 导入第三方项目的包
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

```

- [同时开发多模块教程](https://go.dev/doc/tutorial/workspaces)

### 补充说明: 模块初始化顺序

与Python和C语言类似, Go中每一个文件都是一个代码组织的基本单元, 对于每个文件都可以定义一个init函数. 该函数会在此文件对应的包第一次导入时自动执行, 从而对模块进行一些初始化操作. 一个包可以有多个文件, 因此可以定义多个init函数. 同一个包内的多个init函数的调用顺序并不确定. 因此建议每个包内仅保留一个init函数.

不同的包之间存在依赖关系, Go语言保证最底层的依赖中的init函数最先被调用, 且无论一个包被依赖多少次, 其init函数仅被调用一次.


### 编译应用程序


| 指令       | 含义                                                          |
| ---------- | ------------------------------------------------------------- |
| go build   | 编译当前项目并生成可执行文件                                  |
| go run .   | 编译并运行当前项目, 但不在当前位置生成可执行文件              |
| go install | 编译当前项目并将可执行文件复制到指定位置(默认为`$GOPATH/bin`) |


在开发阶段可以直接`go run `指令编译并运行程序, 从而避免手动的编译+运行. 无论是build的指令还是run指令都会在临时目录中保存中间结果, 因此不必担心run指令的编译效率.

`go install`指令类似于`make install`, 主要目的是将可执行文件复制到`$PATH`变量规定的位置之中, 从而使对应的可执行文件能够被命令行直接访问.



### 发布模块

模块在发布以后才能够被其他模块引用. 因为模块的名称会作为获得模块的依据, 因此在创建模块的时候就需要设置一个合适的模块名称. 例如创建模块时打算在GitHub上进行发布, 那么可以在GitHub上创建一个仓库, 然后以仓库的URL路径作为名称（例如`github.com/LiZeC123/go-test`）

此后在开发代码的过程中, 对GitHub上的代码标记适当的版本tag就完成来模块的发布. Go的版本Tag采用语义化规则, 即一般命名为`vx.y.z`, 并根据代码的兼容情况增加版本号.

----------

对于某一个模块, 如果被其他模块依赖, 当当前的修改仍然处于开发阶段, 无法发布正式的版本号, 此时可以使用引用commit-id的方式进行依赖. 例如

对于一个正式发布的依赖, 使用如下的方式安装

```
go get github.com/LiZeC123/SmartReview@v1.0.0
```

而对于某个特定的版本, 可以使用指定commit-id的方式, 

```
go get github.com/LiZeC123/SmartReview@4d5c2133f
```



Go语言语法基础
---------------

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

这一语法可以将代码和错误处理合并到一行语句中, 例如

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

对于可遍历对象(包含array, slice, channel和map), Go语言支持for-range语法, 例如

```go
func main() {
	s := []string{"A", "B"}
	m := map[string]string{
		"Key1": "Value1",
		"Key2": "Value2",
	}


	for idx, v := range s {
		fmt.Println(idx, v)
	}

	for key, value := range m {
		fmt.Println(key, value)
	}
}
```

> 注意: 遍历时value是对应元素的拷贝, 不可直接引用value, 否则会导致与循环闭包类似的问题. 例如保存value的地址后, 按照地址访问元素, 几乎肯定是BUG行为.


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




函数
-------------

Go语言中的函数一般具有如下的格式
```go
func functionName(param1 type1, param2 type2) (ret1 type1, ret2 type2) {
    // function code
}
```

返回值部分可以指定变量名, 则相当于在函数开头就定义了相关的变量, 之后可以空return. 如果不指定返回值变量名, 则和常规函数一样需要在return语句中明确需要返回的变量. 例如

```go
func rectProps(length, width float64) (area, perimeter float64) {
    area = length * width
    perimeter = (length + width) * 2
    return 
}
```

> 使用返回值变量命名以后, 需要注意是否重复定义了名称类似的变量, 以免最后返回的值不符合预期

### 可变参数

Go语言中可变参数的定义方式与各类语言相似, 通过`...`表示一个参数为可变参数

```go
func f(a int, args... interface{})
func g(args... interface{})
```

在函数的内容部, 变量`args`自动转换为一个切片.

---------

注意: 如果需要将一个函数内的可变参数转发给另个拥有可变参数的函数, 需要手动解开切片, 即

```go
func f(a int, args... interface{}) {
  g(args...)
}

```

否则会将切片作为`一个`参数传入函数之中.



defer语句
----------------

### 基本操作

被defer修饰的语句会在当前模块执行return语句之前执行. 但需要注意, defer语句本身需要先能够被执行, 才能保证在函数的最后执行指定的函数.

```go
err := DoSomething()
defer Report("Cmd.Some.Sum", err) // 必须紧跟执行函数, 否则容易漏掉异常分支
if err := nil {
  // 异常情况下的逻辑
  return err
}

// 不可以在这里defer, 否则异常情况下直接return导致defer的函数根本不执行

// 正常情况下的业务逻辑
DoOther()
```

> defer语句通常用来实现关闭资源等操作, 在开启资源后紧跟一个defer引导的关闭语句, 从而避免忘记关闭资源

### 参数计算

被defer修饰的函数调用中, 函数的参数会立即计算, 但函数调用会延后执行. 

```go
    startedAt := time.Now()
    defer fmt.Println(time.Since(startedAt))
    
    time.Sleep(time.Second)
```

因此对于上述代码, 并不会实现计算时间的功能. 如果需要解决上述问题, 则应该使用闭包(或者定义一个函数实现对应的逻辑)

```go
func main() {
    startedAt := time.Now()
    defer func() { fmt.Println(time.Since(startedAt)) }()
    
    time.Sleep(time.Second)
}
```

如果在defer修饰的函数的参数上引用了局部变量, 则由于参数已经拷贝了, 外部的修改不会影响内部

```go
func deferTest() {
  var a = 1
  defer fmt.Println(a)
  
  a = 2
  return
}
```

上述代码中虽然在return之前a已经修改为2, 但是defer的时候已经拷贝了a的值, 因此输出的还是1.

### 调用时机

Go语言的return语句并不是原子的, 具体可以划分为设置返回值和执行`ret`操作两步. defer修饰的语句正好在这两步之间执行. 如果在defer语句中修改了返回值, 则根据返回值的声明方式以及return返回的方式会产生多种不同的情况. 为了避免增加不必要的理解难度, 不建议在defer的语句中进行类似的操作. 具体情况可参考如下的链接

- [Go，一文搞懂 defer 实现原理](https://xie.infoq.cn/article/6f5cc8b14cc60c8985dc7257f)


闭包
------------

GO语言的闭包和其他语言中的闭包没有本质上的区别, 都是对外部参数的引用. 与Java要求事实上final不同, Go确实可以在闭包内修改引用的变量, 使得变量作用域逃逸. 例如对于如下的代码

```go
func incr() func() int {
    var x int
    return func() int {
        x++
        return x
    }
}
```

如果执行如下代码, 则每次调用都会使x的值增加

```go
i := incr()
println(i()) // 1
println(i()) // 2
println(i()) // 3
```


> GO闭包的一个常见的坑是在循环中创建了闭包并引用循环变量. 由于所有的闭包都**引用**循环变量, 因此通常并不能达到预期的效果

- [Go 语言闭包详解](https://segmentfault.com/a/1190000022798222)



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
p := &Interval{0, 3} // 使用字面量创建指针, 通常使用此方式而不是new的方式
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

### 零值可用

由于Go不像Java一样提供构造函数, 因此无法强制要求调用构造函数, 而直接声明的变量仅具有默认的零值. 对于引用类型, 零值相当与空指针. 为了避免产生空指针的问题, Go哲学强调零值可用, 例如

```go
var zeroSlice []int
zeroSlice = append(zeroSlice, 1) // 未初始化的切片依然可以正常添加
```

> 对于自己定义的对象, 也应该尽量处理零值的情况, 使得零值就是一个有效的状态


### 匿名成员

在定义结构体时可以不指定成员变量的名称, 而是直接给定类型, 此时相当于定义了一个与类型同名的成员变量

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

除了基本类型以外, 结构体类型也可以声明匿名成员, 此时就相当于将该结构体直接嵌入到定义的结构体中. 例如

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

定义Chef类型时, 直接声明了一个Honor类型而没有设置变量的名称（也被称为匿名成员）, 此时Chef等价于自动具有了Honor类型的所有字段, 可以直接用对应的变量名访问. 

> 实际上, 这种方式就等价于Java语言中的继承操作. 外面的结构体自动的继承了匿名结构体的成员变量和方法, 


结构体方法
--------------

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

当Vertex直接以值类型的形式声明时, 采取复制的方式传递值, 因此方法内部不能对变量进行修改(准确来说, 修改是无效的), 同时拷贝数据也会产生一些性能消耗. 如果希望方法能够修改变量, 或者避免拷贝大量数据的性能消耗, 则可以声明为指针类型. 

绑定在值类型上的方法和绑定在指针类型上的方法属于不同的集合. 但用方法时Go会自动转换, 因此无论调用方是值类型还是指针类型都可以直接调用. 

### 绑定已有类型

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

### 零值方法

Go的方法可以安全的在nil对象上执行, 因此可以使用下面的方式使得任意情况下都可以安全的访问成员变量

```go
type MyStructWithNil struct {
	in *MyStructWithNil
}

func (m *MyStructWithNil) GetA() *MyStructWithNil {
	// 
	if m != nil {
		return m.in
	}
	return nil
}

func TestNilFunction(t *testing.T) {
	var m *MyStructWithNil
    
    // 不会panic
	fmt.Println(m.GetA().GetA())   
}
```


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

> **注意：**  绑定在值类型的方法和绑定在指针类型上的方法属于不同的集合, 因此在对**接口**赋值时, 需要保证对象具有的方法完全一致. 由于Abs方法绑定在*Vertex类型, 因此只能将Vertex类型取地址后复制给Abser接口. 

> **注意：**  值对象仅拥有绑定在值类型上的方法, 指针对象同时拥有值类型和指针类型上绑定的方法



### 鸭子类型

Go语言的接口是鸭子类型的, 只要实现了对应的方法就可以视为对应的接口. 如果以前学过Java这种强定义的语言, 那么对于Go的这种鸭子类型可能觉得无法接受. 但实际上可以考虑一下, 在类似Spring的开发过程中, Java的接口基本上就是一层毫无意义的抽象. 此时不声明接口能减少许多无意义的工作量.

此外, 虽然语法层面上想要确定一个类实现了什么接口有点困难, 但反正写代码都是用IDE, 所以有了IDE的辅助以后, 也没有太大的问题.


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

除了接口内嵌接口以外, 也可以使用结构体内嵌接口, 此时表示结构体声明了一个指定接口类型的变量. 例如

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

`UpperWriter`的声明表示内嵌了一个`Writer`变量, 该变量的类型可以是任何实现了`io.Writer`接口的类型. 在创建`UpperWriter`时, 将`os.Stdout`绑定到成员变量`Writer`上.

之后UpperWriter对自己的指针类型绑定了一个Write方法, 将文本大写后转发给成员变量Writer进行处理. 

> 注意：由于UpperWriter直接内嵌io.Writer, 因此原本就可以直接调用Write方法, 此时等价于调用Writer.Write. 通过重新绑定Write方法, 相当于对这一行为进行了重写. 

最后, 由于接口io.Writer只定义了一个Write方法, 而UpperWriter的Write方法绑定在指针上, 所以传入fmt.Fprintln时需要取地址才能转化为io.Writer接口. 


### 空接口

空接口是指不定义任何方法的接口, 任何其他类型都实现了空接口. 因此空接口也类似于Java中的Object对象. 通常可以将空接口命名为`Any`, 例如

```go
type Any interface {}
```

### nil接口非nil

由于Go语言中接口实际是一个复合对象, 保存了指向实际数据的指针与类型. 因此将一个有类型的nil指针赋值给interface{}以后, 被赋值的变量并不为nil

```go
var rsp *Sa = nil
var i interface{} = rsp

fmt.Printf("i==nil: %v\n", i == nil)              // i==nil: false
j, ok := i.(*Sa)
fmt.Printf("ok: %v, j==nil: %v\n", ok, j == nil)  // ok: true, j==nil: true
```

一般情况下并不会使用`interface{}`类型变量持有一个结构体的指针. 但在下列场景中容易出现该情况, 需要谨慎处理

1. 通用的数据结构, 例如`sync.Map`
2. 通用框架, 例如数据库框架

在这些场景中, 由于需要通用性, 因此必须使用`interface{}`类型. 而在取回数据时需要进行强制类型转换, 此时尤其需要注意对nil的判断, 不仅需要判断是否转换成功, 还需要进一步判断值是否为nil.



### 组合优于继承

Go语言在中并没有提供类似Java的各种继承语法, 因此并不能写出非常具有Java风格的代码. 相反地, Go更偏向于通过组合的方式实现代码复用.

Go的设计趋向于正交, 即各个模块之间保持相互独立, 在用户代码中通过组合机制实现功能.


Go语言测试框架
------------



在当前模块下创建以`_test.go`结尾的文件来表明一个文件是测试文件. 在测试文件中可以进行任意形式的测试, 通常可以将测试分为三种类型


类型       | 格式要求         | 含义
----------|----------------|--------------
基本测试    | 函数名前缀为Test | 常规的单元测试
基准测试    | 函数名前缀为Benchmark | 测试函数的性能
示例测试    |函数名前缀为Example    | 为文档提供示例


常见的测试代码如下所示

```go
import (
    "testing"
    "regexp"
)


// 测试函数的参数为*testing.T, 该参数提供了一些方法用于决策测试是否通过
func TestHelloName(t *testing.T) {    
    name := "Gladys"
    want := regexp.MustCompile(`\b`+name+`\b`)
    msg, err := Hello("Gladys")
    if !want.MatchString(msg) || err != nil {
        t.Fatalf(`Hello("Gladys") = %q, %v, want match for %#q, nil`, msg, err, want)
    }
}

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

最后使用`go test -v`即可运行测试并查看测试结果.


- [Go语言基础之单元测试](https://www.liwenzhou.com/posts/Go/unit-test/#autoid-2-5-0)
- [Go语言圣经 测试](https://gopl-zh.codeyu.com/ch11/ch11.html)


### 常用测试指令

```bash
# 运行当前包下的所有测试, 并显示详细信息
go test -v

# 以启用缓存的模式运行指定路径下的所有测试, 并显示详细信息
go test . -v

# 运行当前包下指定名称的测试函数
go test -run TestFunction


# 运行基准测试(默认不会运行基准测试)
go test -bench .
```

### Mock框架简介

一般情况下, 如果代码通过接口的方式与其他模块交互, 则可以比较容易的根据结构创建Mock对象并替换. 但实际开发过程中, 存在许多直接与其他模块交互的场景, 此时需要使用Mock框架在运行时修改函数实现, 以达到Mock的效果.

此类框架的基本原理是在程序启动后, 通过反射获取要Mock函数的地址, 通过直接修改内存的方式, 将函数体修改为跳转至指定的Mock函数. 基于该技术, 可对任意函数进行替换.

常用的Mock框架有:

- [Mockery](https://github.com/bytedance/mockey)


依赖管理
---------------

GO语言中通过`go.mod`文件管理项目涉及的依赖.

### 依赖模块分析

通常情况下, 可以在`go.mod`文件中查看项目的依赖情况. 但某些依赖可能属于间接依赖, 无法在`go.mod`文件中找到对应的依赖性. 此时可以使用如下的指令进行查询

```bash
go mod why <依赖>
```

如果以上指令返回`main module does not need package`, 则还可以通过如下的指令进行查找

```bash
go mod graph | grep A
```

### 版本决策机制

Go语言的版本决策机制涉及两个基本特性: 版本语义和最小依赖原则.

版本语义是指在Go语言中, 同一个依赖的两个大版本号不一致, 则视为两个不同的模块, 从而可以同时存在. 例如`v1.0.1`和`v2.1.0`是两个不同的模块.

最小依赖原则是指当一个模块C被另外两个模块A和B依赖, 且依赖的C版本不一致时, 采取能兼容条件下的最低版本依赖. 例如A依赖C版本为`V1.1.0`, B依赖C的版本为`V1.2.0`, 当前C的版本为`V1.4.0`, 则Go决策使用`V1.2.0`, 因为该版本是满足所有依赖关系的最低版本.

- [为什么有了Go module后“依赖地狱”问题依然存在 | Tony Bai](https://tonybai.com/2022/03/12/dependency-hell-in-go/)


### 依赖强制替换

可以使用`replace`指令强制替换一个Go依赖, 例如

```
replace (
	gorm.io/gorm => gorm.io/gorm v1.25.3
)
```

这一操作将会影响Go模块的依赖选择机制, 使得其子模块中所有的相关依赖强制替换为指定的版本.

> 注意: replace操作是非继承的, 即子模块的replace操作不会对父模块的版本决策产生任何影响. 父模块依赖子模块后还是会使用子模块原本的依赖版本

可以通过查看`go.sum`中的依赖信息判断相应的替换是否已经生效. 例如执行上述的`gorm`替换以后, 查看`go.sum`文件, 其中应该仅包含1种`gorm`的依赖



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
