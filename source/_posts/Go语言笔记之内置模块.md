---
title: Go语言笔记之内置模块
date: 2021-07-11 09:31:50
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---

本文介绍Go语言最常用的模块, 包括基础的数据结构(数组, 切片, 哈希表), 基本的IO操作, 字符串操作, 并发控制和反射相关的内容. 由于Go并不是我的第一门语言, 所以本文将对照C, Java, Python等语言已有的语法进行对比. 对于其他语言中已有的内容, 会比较简略地带过.

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

切片的截取操作与Python中的切片语法基本一致, 但在Go语言中**切片索引越界会直接导致程序错误**. 由于切片是对数据的引用, 因此修改切片显然也会导致底层数据被修改. 

--------------

除了常规的切片语法外, GO还支持三索引切片的语法, 例如

```go
// 创建一个数组
arr := [10]int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

// 创建一个切片，包含数组的第2个到第4个元素
s1 := arr[1:4] // s1: [1, 2, 3]

// 创建一个新切片，包含s1的所有元素，但容量限制为2
s2 := s1[:len(s1):2] // s2: [1, 2]

fmt.Println("s1:", s1) // 输出: s1: [1 2 3]
fmt.Println("s2:", s2) // 输出: s2: [1 2]
```

通过指定切片的容量, 可以在后续操作该切片导致容量超出预期时产生错误, 从而提前发现相关的问题



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

> 注意: 如果指定了长度, 则其中的元素会初始化为相应的零值. 但如果仅指定了容量, 则没有进行任何操作.

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

Go语言中使用内置的map实现哈希表结构. 其内部结构如图所示:

![](/images/go/map.jpg)

在map结构中, `buckets`字段指向了一个桶的数组. 其中每个桶可存储8个元素. 在桶内为了充分保证字节对齐, key和value是分开存储的. 因为Go在编译阶段已经可以得知key和value的具体类型, 因此可通过类型计算出key和value的具体偏移值.

与许多语言对冲突的处理不同, Go语言为了充分利用局部性, 在哈希冲突时采取开放寻址法中的线性探测解决冲突问题. 即当前位置冲突时, 按照顺序寻找i+1位置是否为空. 

Go语言的负载因子定义为`哈希表元素数量/桶数量`, 并且在负载因子达到6.5时触发扩容. 扩容后并不会立即移动所有元素, 而是采用写时复制策略, 只有对应的项被修改时才会进行移动.

> map显然也是一个引用语义的数据结构.

### 初始化

可以直接使用列表初始化一个map, 也可以使用make函数创建map. 使用make函数时能够提前分配空间, 从而减少扩容操作产生的性能消耗.

```go
// 直接列表初始化
ages := map[string]int{
    "alice":   31,
    "charlie": 34,
}


// 先分配空间, 再赋值
ages := make(map[string]int)
ages["alice"] = 31
ages["charlie"] = 34
```

map会自动扩容, 但创建时设置一个合适的初始值有助于减少扩容的性能消耗.  map是引用类型, 因此传递map对象与传递一个指针的代价相同. 

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

### 零值可用性

不同于切片在任何时候都是零值可用, map数据的零值具有不同的表现, 建议始终使用make函数创建map而不要依赖零值可用性.


```go
var m map[string]string
fmt.Printf("value is %v", m["123"]) // 零值可查询, 返回对应类型的零值(此处为空字符串)
m["345"] = "345"                    // panic: assignment to entry in nil map
fmt.Printf("%v", m == nil)          // true
```



IO操作
---------

### 基础接口

与Java的抽象一样, Go也提供了一套统一的IO操作, 无论是读写文件, 读写网络数据, 读写标准输入输出还是读写字符串, 都可以抽象为对应的IO读写操作, 基于IO接口的上层函数也可以应用到任意的一种实现了IO接口的数据类型上. Go语言中定义了两个基本的IO接口, 即

```go
type Reader interface {
    // 从底层数据流读取len(p)个字节的数据到切片p中, 返回实际读取到的字节数以及可能的错误
    Read(p []byte) (n int, err error)
}

type Writer interface {
    // 从切片p写入len(p)个字节的数据到底层数据流, 返回实际写入的字节数以及可能的错误
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
--------------

Go本身并不暴露string的底层结构, 但可以认为Go语言中的字符串与C的实现类似, 是一个指向实际数据的指针. 和大部分语言一样, string也是不可变的, 传递string变量也不会产生拷贝开销.

- [GO 中 string 的实现原理](https://segmentfault.com/a/1190000040203636)


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

对于字符串和字节数组的转化, Go提供了标准操作, 代码如下

```go
var str string = "test"
var data []byte = []byte(str)

str = string(data[:])
```

由于字符串不可变, 因此在转换过程中需要对内容进行一次拷贝.

----------------------------------------

对于极端需要性能的场景, 存在如下的转换方法.

```go
func String2Bytes(s string) []byte {
    sh := (*reflect.StringHeader)(unsafe.Pointer(&s))
    bh := reflect.SliceHeader{
        Data: sh.Data,
        Len: sh.Len,
        Cap: sh.Len,
    }
    return *(*[]byte)(unsafe.Pointer(&bh))
}

func Byte2String(b []byte) string {
    return *(*string)(unsafe.Pointer(&b))
}
```

由于调用了unsafe方法, 因此代码存在安全问题, 通常情况下都不应该使用该方法进行转换.

------------------------------------------

此外, 对于Gin项目中, 使用了如下的方式进行转换

```go
func StringToBytes(s string) []byte {
 return *(*[]byte)(unsafe.Pointer(
  &struct {
   string
   Cap int
  }{s, len(s)},
 ))
}

func BytesToString(b []byte) string {
 return *(*string)(unsafe.Pointer(&b))
}
```

上述代码抛弃了reflect库的API, 因此兼容性可能会更好一点. 但是代码依然假定了Go底层的实现结构, 如果Go内部实现发生变化将导致上述代码无法执行.

- [你真的懂string与[]byte的转换了吗](https://mp.weixin.qq.com/s?__biz=MzAxMTA4Njc0OQ==&mid=2651442152&idx=2&sn=e0c6b49d6792366de56337ef2b5d25c7&chksm=80bb151ab7cc9c0c5855061554f86df7264912b069e4e8dc39133dd6841ca2cbac99624cc91d&scene=21#wechat_redirect)
- [你所知道的 string 和 []byte 转换方法可能是错的](https://mp.weixin.qq.com/s/T--shUtArU-asFthtR7waA)



interface结构原理
---------------------

在泛型或反射场景中经常使用interface{}表示任意类型的变量, 但是由于Go语言对interface{}的实现, interface{}实际上并不与C中的void*或者Java中的Object等价. 

针对一个接口是否定义了方法, 接口变量可能有两种实现. 包含方法的iface和不包含方法的eface. 以eface为例, 对应的实例变量的结构可以视为
```go
type eface struct {
    _type *_type
    data  unsafe.Pointer
}
```

其中_type存储了实际变量的类型, data存储了实际变量的值, 例如对于如下的代码

```go

var num *int = nil
var face interface{} = num
```

对num和face进行nil判断会得到不同的结果. 其本质原因就是face变量并非一个指向num的指针, 而是具有自己的内存结构, 虽然data部分为nil, 但_type部分存储了num的类型.

> interface{}常用于反射, 因此显然其中也需要存储原始指向的变量的类型.

显然, face变量与num变量的内存结构是不同的, 因此赋值操作也不是简单的内存拷贝, 而是需要根据变量的类型合适的设置face的值. 与C/Java中等号永远是简单赋值操作不同, Go有点类似C++, 在不同的场景下等号会进行适当的重载.


- [深入研究 Go interface 底层实现](https://halfrost.com/go_interface/)



时间包
---------------

程序中应使用 Time 类型值来保存和传递时间. 使用Before, After和Equal等方法进行比较和运算. 使用Sub方法可以获取两个时间的差值, 生成一个Duration对象.




反射操作包
---------------

反射操作包的核心是两个函数`reflect.TypeOf`和`reflect.ValueOf`, 两个函数都可以接受任意的变量, 分别返回变量的类型和变量实际的值. 例如

```go
mm := make(map[string]string, 23)
t := reflect.TypeOf(mm)
v := reflect.ValueOf(mm)
fmt.Println(t)              // map[string]string
fmt.Println(v)              // map[]
```

似乎看起来`reflect.ValueOf`这种获得变量的值的操作并没有意义, 因为直接访问变量也能获得变量的值. 但需要注意到, 使用反射场景的时候, 给定的参数通常是表示任意类型的`interface{}`, 虽然其中存储了变量实际的值, 但空接口并不提供获得底层值的方法. 以下代码演示了如何根据`reflect.Value`获得变量实际的值

```go
// formatAtom formats a value without inspecting its internal structure.
func formatAtom(v reflect.Value) string {
    switch v.Kind() {
    case reflect.Invalid:
        return "invalid"
    case reflect.Int, reflect.Int8, reflect.Int16,
        reflect.Int32, reflect.Int64:
        return strconv.FormatInt(v.Int(), 10)
    case reflect.Uint, reflect.Uint8, reflect.Uint16,
        reflect.Uint32, reflect.Uint64, reflect.Uintptr:
        return strconv.FormatUint(v.Uint(), 10)
    // ...floating-point and complex cases omitted for brevity...
    case reflect.Bool:
        return strconv.FormatBool(v.Bool())
    case reflect.String:
        return strconv.Quote(v.String())
    case reflect.Chan, reflect.Func, reflect.Ptr, reflect.Slice, reflect.Map:
        return v.Type().String() + " 0x" +
            strconv.FormatUint(uint64(v.Pointer()), 16)
    default: // reflect.Array, reflect.Struct, reflect.Interface
        return v.Type().String() + " value"
    }
}
```

> 反射存在运行时产生painc, 性能低下等问题, 因此通常情况下不要使用反射

- [Go语言圣经 反射](https://gopl-zh.codeyu.com/ch12/ch12.html)




IP操作
--------

### 解析IP地址

```go
parsedIP := net.ParseIP(rawIP)
```

使用`net.ParseIP`可以将一个字符串格式的IP地址解析为Go语言中的IP对象. IP对象实际是一个字节数组, 通常占据16字节(对应IPV6地址的长度), 采用大端序存储IP的字节.


> 注意: 根据IP协议的规范, 任何一个合法的IPV4地址也是一个合法的IPV6地址. 不要根据IP对象的长度判断IP类型



数据库操作
-----------

Go语言在标准库`database/sql`包中提供了数据库相关的操作. 在`database/sql`包中并未实现具体的数据库操作, 而是给出了一组关于`driver`的接口, 所有关于数据库的操作最终均通过操作`driver`的接口实现. 通过在代码中注册不同的数据库driver, 从而实现连接到不同的数据库.


### 创建连接

`database/sql`包中的核心对象是`DB`结构体. `DB`表示了拥有一个或多个连接的连接池. 实际上, 相较于Java/C++等语言, Go语言似乎因为出现的比较晚, 因此`DB`默认就是一个连接池. 不同版本的Go对于`database/sql`包的实现基本一致.


### 设置连接池大小

除非数据库操作频率非常低, 否则始终应该设置连接池大小. 在未设置连接池大小的情况下, 创建过多的连接可能导致数据库服务消耗更多的CPU, 导致新增连接失败或者干扰其他业务.

在设置了连接池大小的情况下, 如果当前无法从连接池获取一个可用链接, 则当前协程会阻塞, 直到获得可用链接后再继续执行. 当一个连接归还到连接处时, 会判断当前空闲连接数, 如果大于最大空闲连接数, 则释放当前连接.


### 评估数据库性能

对于云数据库, 可通过最大连接数与IOPS评估数据库性能. 例如在腾讯云中, 最低配置的1核1G数据库, 其IOPS标注为1200, 最大连接数为750. 则对于该数据库, 则最多可支持750个连接, 每秒钟可执行1200次IO操作.(对于写入数据而言, 基本约等于写入速度)

根据业务逻辑的机器数量可计算每台机器允许的最大连接数. 例如当前有10台机器需要连接该数据库, 则每台机器至多使用75个连接. 考虑到其他服务可能也需要连接该数据库以及服务器本身的性能, 则实际允许的最大连接数量则还要明显小于75.

通过最大连接数, 可以一定程度的限制单台机器的写入速度. 例如当前最大连接数设置为35, 则即使使用5000个协程进行写入操作, 对于数据库而言, 依然相当于35个连接在发送请求. 5000个协程在写入数据时, 需要排队进行写入.

数据库的写入性能最终还是取决于IOPS, 如果50个连接就可以使IOPS达到最大值, 那么新增更多连接也不会使插入速度更快, 过多的连接数还会导致额外的CPU消耗, 从而进一步降低数据库性能.


### 扩展阅读

- [Golang sql 标准库源码解析 - Powered by MinDoc](https://www.iminho.me/wiki/blog-41.html)



参考资料与扩展阅读
-------------------------


- [《Go语言标准库》The Golang Standard Library by Example](https://books.studygolang.com/The-Golang-Standard-Library-by-Example/)
