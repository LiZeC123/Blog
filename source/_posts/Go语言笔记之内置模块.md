---
title: Go语言笔记之内置模块
date: 2021-07-11 09:31:50
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍Go语言中常见的数据结构的基本使用, 包括定长数组, 变长数组, 哈希表等结构


数组
-----------------

数组是基础的数据结构, 不同于C语言中所有数据都是指针的实现, 在Go语言中数组既包含类型又包含长度, 类型和长度完全相同的数组才是为同一个类型.

### 初始化

数组可以直接初始化, 也可以不指定长度, 由编译器推导数组的长度, 例如

```go
arr1 := [3]int{1, 2, 3}
arr2 := [...]int{1, 2, 3}
```

> 注意: 不可使用`[]int{1,2,3}`的形式初始化, 因为这是切片的语法



切片(变长数组)
-------------------

在Go语言中, 切片既可以视为Python中的同等概念, 即一个数组的片段. 又可以视为一个可变数组, 从而实现动态的容量变化. 

### 初始化

可以使用如下的方式定义切片

```go
var s1 []int  // 不声明长度的数字即为切片

s2 := make([]int, 12) // 使用make函数创建切片并制定初始长度

s :=[]int{1,2,3 } // 使用字面量直接初始化并赋值
```

其中的make函数的原型为`make([]T, length, capacity)`, 长度和容量值得是当前的实际长度和可以存放数据的最大长度. 

向切片中添加数据时, 如果没有达到容量的限制则直接添加, 否则拷贝数据到新分配的空间中. 由于拷贝操作并不会像ArrayList一样预留新的容量, 所以如果持续添加数据,则每一次都会进行拷贝.

> 使用`len()`和`cap()`函数获取切片的长度和容量

### 切片操作

切片的截取操作遵循Python中的切片语法. 也可以从数组等数据结构中产生切片, 从而实现对数组中部分数据的**引用**. 例如

```go
arr  := [10]int {0,1,2,3,4,5,6,7,8,9}

// 创建数组的引用, 容量是数组的剩余空间
var numA []int = arr[6:8]   // Pointer=0xc0000161c0 len=2 cap=4 slice=[6 7]

// 添加数据, 指针不变, 说明原地修改数据
numA = append(numA, 1)      // Pointer=0xc0000161c0 len=3 cap=4 slice=[6 7 1]

// 添加更多数据, 操作数组范围, 进行了复制
numA = append(numA, 2,3,4,5)// Pointer=0xc00000e400 len=7 cap=8 slice=[6 7 1 2 3 4 5]
```

> 使用`append()`和`copy()`对切片进行添加和复制操作



哈希表
------------


### 初始化

Go语言中使用map定义哈希表, 例如

```go
dict := make(map[string]string) 
// 添加数据
dict["go"] = "Golang"
dict["cs"] = "CSharp"
dict["rb"] = "Ruby"
dict["py"] = "Python"
dict["js"] = "JavaScript"
// 遍历
for k, v := range dict {
    fmt.Printf("Key: %s Value: %s\n", k, v)
}
//删除
delete(dict, "go") 
```

map会自动扩容, 但创建是设置一个合适的初始值有助于减少扩容的性能消耗.  map是引用类型, 因此传递map对象与传递一个指针的代价相同. 


### 获取数据

由于map中能够存储任意类型的数据, 因此获取数据时可以采用如下的两种方式

```go
// 如果数据不存在返回nil, 如果本身就是nil, 也会返回nil
val = dict[key]

// 如果数据存在, ok值为true, 否则为false
val, ok = dict[key]

// 仅判断是否存在数据
_, ok = dict[key]


// 与if混合使用
if goString, ok := dict["go"]; !ok{
    /* ... */ 
}
```

### map的切片

如果需要获得一个map的切片, 则需要分为两步构造此数据结构. 第一步对切片分配空间, 第二步对每个元素分配map的空间, 即

```go
items := make([]map[int]int, 5)
for i:= range items {
    items[i] = make(map[int]int, 1)
    items[i][1] = 2
}
```
