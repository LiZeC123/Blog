---
title: Go语言笔记之常见陷阱
math: false
date: 2024-06-22 11:52:27
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---


Item 1 nil接口非nil
---------------------

由于Go语言中接口实际是一个复合对象, 保存了指向实际数据的指针与类型. 因此将一个有类型的nil指针赋值给interface{}以后, 该变量并不为nil

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

在这些场景中, 由于需要通用性, 因此必须使用`interface{}`类型. 而在取回数据时需要进行强制类型转换, 此时尤其需要注意对nil的判断.


Item 2 defer的立即求值
-----------------------

defer语句可以在函数执行完主要逻辑后再执行, 但其中的参数是立即求值的, 不当使用可能导致执行不符合预期



Item 3 可变参数的再展开
------------------------

