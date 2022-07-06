---
title: Go语言笔记之内置模块
date: 2021-07-11 09:31:50
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---

本文介绍Go语言最常用的模块, 包括基础的数据结构(数组, 切片, 哈希表), 基本的IO操作和字符串操作相关的内容. 由于Go并不是我的第一门语言, 所以本文将对照C, Java, Python等语言已有的语法进行对比. 对于其他语言中已有的内容, 可能会比较简略地带过.

数组
-----------------

数组是基础的数据结构, 不同于C语言中所有数组类型的变量本质上都是指针的实现, Go语言中的数组变量具有**值类型的语义**, 在Go语言中数组既包含类型又包含长度, 类型和长度完全相同的数组才是为同一个类型.

### 初始化

数组可以直接初始化, 也可以不指定长度, 由编译器推导数组的长度, 例如

```go
arr1 := [3]int{1, 2, 3}
arr2 := [...]int{1, 2, 3}
```

> 注意: 不可使用`[]int{1,2,3}`的形式初始化, 因为这是切片的语法

数组初始化时可以直接指定某个位置的值, 使用此方式时, 没有被指定的位置默认使用零值, 例如

```go
a := [...]string{0:"A", 25:"Z"}
//a = [A                         Z]
```

### 实现细节

- 如果数组中的元素可以比较, 那么可以直接使用`==`比较两个数组是否相同. 此时当且仅当数组中每个元素都对应相等时, 两个数组才相等
- GO语言中数组是值类型, 采用拷贝传递, 因此向函数传递数组会导致数组被复制

> 由于数组拷贝的特性, 一般不会将数组作为参数, 而是将可变的切片作为参数.



切片(变长数组)
-------------------

Go语言的Slice是一个没有正交的数据结构, 在实际使用过程中具有**对数组的引用**和**可变长数组**两种功能. 在使用过程中应该尽量避免同时使用Slice的两种功能. 以下分别介绍作为切片的Slice和作为变长数组的Slice.


### 将Slice作为切片

Go的数组是值语义, 而C系列的语言对于数组都是视为引用语义, 因此直接将数组作为函数参数传递时会遇到很多问题, 例如值传递导致较高的拷贝开销, 无法在函数内修改数组等. 为了解决这一问题, Go引入了切片数据结构. 切片可以视为对数组的一个片段的引用. 切片是一个轻量级的数据结构, 其中只包含了引用数据的指针和切片的长度, 以及切片剩余的容量, 切片结构示意图如下所示

![](/images/go/slice.png)

> 由于每个变量在编译时就可以确定类型, 因此切片中不需要存储类型信息.



切片是一个数据片段的引用, 因此主要通过如下的方式产生切片:

```go
var s1 []int                            // 直接声明一个切片, 不指向任何数组

arr  := [10]int {0,1,2,3,4,5,6,7,8,9}
var numA []int = arr[6:8]               // 使用切片语法获得一个数组切片
```

切片的截取操作与Python中的切片语法基本一致, 但Go的**切片索引越界会直接导致程序错误**, 这与Python的切片语法不同. 由于切片是对数据的引用, 因此修改切片显然也会导致底层数据被修改. 



### 将Slice作为变长数组

Slice也可以当做一个可变长的数组使用, 可以使用如下的方式定义变长数组

```go
var s1 []int            // 直接声明一个切片, 不指向任何数组

s2 := make([]int, 12)   // 使用make函数创建切片并指定初始长度, 相当于同时分配了数组空间

s :=[]int{1,2,3 }       // 使用字面量直接初始化并赋值
```

其中的make函数的原型为`make([]T, length, capacity)`, 长度和容量指的是当前的实际长度和可以存放数据的最大长度. 

> 使用`len()`和`cap()`函数获取切片的长度和容量


### 变长数组操作

```go
// 创建变长数组, Len是实际空间, 容量是数组的剩余空间
// 超过Len就视为越界, 即使后续的空间依然可用
arr := make([]int, 3, 5)   // Point=0xc00000a390, Len=3 Cap=5 Value=[0 0 0]

// 添加数据, 指针不变, 说明原地修改数据
arr = append(arr, 12)      // Point=0xc00000a390, Len=4 Cap=5 Value=[0 0 0 12] 

// 添加更多数据, 超过底层数组范围, 因此发生了复制
arr = append(arr, 1, 2)    // Point=0xc000018190, Len=6 Cap=10 Value=[0 0 0 12 1 2]
```

向切片中添加数据时, 根据底层的数据结构是否还有空间, 新添加的数据可能原地添加, 也可能复制到一个新的内存之中. 因此append方法要有返回值而不能原地调用.



### 切片转换语法

使用`a[:]`将数组a转换为一个切片, 使用`s...`将切片s展开为多个参数



### 排序

由于切片排序是一个常用操作, 因此从Go 1.8开始,  `sort`包提供如下的排序函数

```go
func Slice(x any, less func(i, j int) bool)
```

其中`less`函数给定了数组中的两个元素, 需要返回两种的大小关系, 例如

```go
arr := [10]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
sort.Slice(arr[:], func(i, j int) bool {
    // 从大到小排序数据
    return arr[i] > arr[j]
})
```

对于复杂的数据结构, 可以通过实现sort包中定义的三个接口实现排序, 可参考下面的文章

- [Go 中的三种排序方法](https://learnku.com/articles/38269)



### 第三方增强库

由于Go的切片提供的方法非常少, 因此使用起来远没有Java和Python中顺手, 为此可以使用一些第三方库增强切片的功能. 例如

```
go get github.com/feyeleanor/slices
```

```go
import (
	"fmt"
	"github.com/feyeleanor/slices"
)

func ps(arr []int) {
	fmt.Printf("Point=%p, Len=%v Cap=%v Value=%v\n", arr, len(arr), cap(arr), arr)
}

func main() {
	iss := make(slices.ISlice, 5, 8)

	for i := 0; i < 5; i++ {
		iss[i] = i
	}

	iss.Insert(2, 55)
}

```

这个库对于所有的基本类型和一般类型提供了大量简便方法, 例如插入, 删除, 查找, 替换和常见的谓词操作. 

- [feyeleanor/slices](https://github.com/feyeleanor/slices)



### 切片与内存泄露

由于切片是底层数组的一个引用, 因此即使只有非常小的一个切片引用, 也会导致整个底层数组无法被释放. 如果不想出现这种问题, 可以考虑在返回切片的时候创建一个切片的拷贝, 从而切断与原始底层数组的联系. 

此外, 与Java实现堆栈的情形类似, 如果切片中持有了对象的指针, 而删除指针的时候没有手动置为null, 也会导致对象被延迟垃圾回收. 

> 如果切片本身的生命周期就比较短, 那么就不必特别担心这个问题了



哈希表
------------

Go语言中使用内置的map实现哈希表结果. map显然也是一个引用语义的数据结构.

### 初始化

可以直接使用列表初始化一个map, 也可以使用make函数创建map. 使用make函数时能够提前分配空间, 从而减少扩容操作产生的性能消耗.

```go
// 直接列表初始化
ages := map[string]int{
    "alice":   31,
    "charlie": 34,
}


// 先分配空间, 再复制
ages := make(map[string]int)
ages["alice"] = 31
ages["charlie"] = 34
```

map会自动扩容, 但创建是设置一个合适的初始值有助于减少扩容的性能消耗.  map是引用类型, 因此传递map对象与传递一个指针的代价相同. 

> **注意:** map类型必须初始化, 否则直接添加数据会导致空指针错误


### 操作数据

由于map中能够存储任意类型的数据, 因此获取数据时可以采用如下的两种方式

```go
// 如果数据不存在返回对应类型的零值, 如果本身就是零值, 也会返回零值
val = dict[key]

// 如果数据存在, ok值为true, 否则为false
val, ok = dict[key]

// 仅判断是否存在数据
_, ok = dict[key]


// 与if混合使用
if goString, ok := dict["go"]; !ok{
    /* ... */ 
}

// 遍历
for k, v := range dict {
    fmt.Printf("Key: %s Value: %s\n", k, v)
}


//删除
delete(dict, "go") 
```




IO操作
---------

### 基础接口

与Java的抽象一样, Go也提供了一套统一的IO操作, 无论是读写文件, 读写网络数据, 读写标准输入输出还是读写字符串, 都可以抽象为对应的IO读写操作, 基于IO接口的上层函数也可以应用到任意的一种实现了IO接口的数据类型上. Go语言中定义了两个基本的IO接口, 即

```go
type Reader interface {
    // 从切片p中读取len(p)个字节的数据, 返回实际读取到的字节数以及可能的错误
	Read(p []byte) (n int, err error)
}

type Writer interface {
    // 向切片p写入len(p)个字节的数据, 返回实际写入的字节数以及可能的错误
	Write(p []byte) (n int, err error)
}
```

> 注意: Read方法的err可能会返回io.EOF, 进行错误处理时需要对该情况进行额外处理

后续的很多方法都将Reader或者Writer对象作为操作的参数, 常见的实现了上述接口的对象如下表所示



| 类型                | 创建方法          | 备注                                         |
| ------------------- | ----------------- | -------------------------------------------- |
| os.File             | os.Open/OpenFile  | 文件类型实现了Reader和Writer等方法           |
| strings.Reader      | strings.NewReader | 将一个字符串转换为一个Reader                 |
| bufio.Reader/Writer | bufio.NewReader   | 将一个Reader转化为一个带缓冲的Reader         |
| bytes.Buffer        | bytes.NewBuffer   | 创建一个字节缓冲区或者从字符串构造一个缓冲区 |
| bytes.Reader/Writer | bytes.NewReader   | 将一个字节数组转换为一个Reader               |
| net/conn            | 网络相关方法      | 网络流也实现了了Reader和Writer等方法         |





### 扩展接口

除了最基础的读取和写入接口外, 在io包中还定义了如下的一些接口, 其含义都非常明确

```go
type ReaderFrom interface {
    // 从指定的Reader中读取全部数据
	ReadFrom(r Reader) (n int64, err error)
}

type WriterTo interface {
    // 向指定的Writer写入全部数据
	WriteTo(w Writer) (n int64, err error)
}

type ReaderAt interface {
    // 从底层数据偏移off位置读取len(p)字节到p之中
	ReadAt(p []byte, off int64) (n int, err error)
}

type WriterAt interface {
    // 从底层数据偏移off位置, 将p中len(p)字节输入写入
	WriteAt(p []byte, off int64) (n int, err error)
}
```

通常情况下, 由Writer对象实现ReadFrom方法, Reader对象实现WriteTo方法, 从而将一个IO流中的数据全部移动到另一个IO流中. 某些自定义的数据结构也可以使用该方法表示读取或写入全部数据.


IO常见操作
---------------

ioutil包定义了很多常用的IO操作方法, 具体可以分为文件操作, 接口封装, ... 等.


几个比较常用的函数, 包括读取全部数据, 读写文件, 读写目录等, 具体函数前面如下:



### 读取整个文件

对于读取或者写入全部的数据, ioutil包提供了如下的方法

```go
func ReadFile(filename string) ([]byte, error)
func WriteFile(filename string, data []byte, perm fs.FileMode)
```

### 按行读取文件

如果需要按行读取数据, 可以执行

```go
f, _ := os.Open("Hello.go")
rr := bufio.NewReader(f)
for {
    line, err := rr.ReadString('\n')
    if err != nil {
        fmt.Println(err)
        return
    }
    if err == io.EOF {
        fmt.Println("EOF")
        return
    }

    fmt.Print(line)
}
```

或者

```go
f, _ := os.Open("Hello.go")
sc := bufio.NewScanner(f)
for sc.Scan() {
    fmt.Println(sc.Text())
}
```

bufio的Reader对象还提供了一些有帮助的简化方法, 例如

```go
func (b *Reader) ReadSlice(delim byte) (line []byte, err error)
func (b *Reader) ReadBytes(delim byte) ([]byte, error)
func (b *Reader) ReadString(delim byte) (string, error)
```

### 读取全部数据

ioutil包提供了如下的方法从任意Reader读取全部数据

```go
func ReadAll(r io.Reader) ([]byte, error)
```


格式化输入输出
----------------

Go的格式化系统与C基本一致, 对于文件, 标准输入输出和字符串提供了格式化函数, 并且使用一套类似的占位符, 具体如下

| 类型         | 可选占位符           | 备注                                                 |
| ------------ | -------------------- | ---------------------------------------------------- |
| 一般占位符   | %v %T                | 使用Go格式输出, 通常用于复合结构                     |
| 布尔值       | %t                   | 输出布尔值                                           |
| 整数         | %b %c %d %o %x %X %U | 除了各种进制以外, %U表示按照Unicode编码输出          |
| 浮点数和复数 | %b %e %E %f %g %G    | %e表示使用科学计数法, %g表示视情况选择最短的表示方法 |
| 字符串       | %s %q %x %X          | %q表示输出时添加一对引号                             |
| 指针         | %p                   | 输出地址值                                           |

除了占位符以外, 其他标记包括

| 其他标记 | 含义                           |
| -------- | ------------------------------ |
| +        | 始终打印数值的正负号           |
| -        | 左对齐                         |
| #        | 添加前导符号(例如16进制添加0x) |
| (空格)   | 使用空格填充空位               |
| 0        | 使用0填充空位                  |


字符串操作包
---------------


### 字符串基本操作

strings包提供了字符串的常见操作, 包括比较字符串大小, 查找字符, 替换字符, 合并字符串等操作


- [strings — 字符串操作](https://books.studygolang.com/The-Golang-Standard-Library-by-Example/chapter02/02.1.html)



### 字符串转数字

strconv包提供了字符串到数值的转换, 例如字符串转整数, 字符串转浮点数等. strconv包定义了两种常见的错误, 即`strconv.ErrRange`表示转换超出表示范围, `strconv.ErrSyntax`表示要转换的数据不符合对应的格式.

```go
func ParseInt(s string, base int, bitSize int) (i int64, err error)
func ParseUint(s string, base int, bitSize int) (n uint64, err error)
func Atoi(s string) (i int, err error)
```

base是数据的进制, 例如2进制, 10进制, 16进制. bitSize表示数据的长度, 例如8表示转换为int8. 如果bitSize取零, 表示转换为平台使用的int对应的长度.

> Atoi 相当于 ParseInt(s, 10, 0) 

### 整型转为字符串

```go
func FormatUint(i uint64, base int) string    // 无符号整型转字符串
func FormatInt(i int64, base int) string    // 有符号整型转字符串
func Itoa(i int) string
```

> Itoa 相当于 FormatInt(i, 10) 

### 字符串与字节数组的转换

```go
var str string = "test"
var data []byte = []byte(str)

str = string(data[:])
```


参考资料与扩展阅读
-------------------------


- [《Go语言标准库》The Golang Standard Library by Example](https://books.studygolang.com/The-Golang-Standard-Library-by-Example/)