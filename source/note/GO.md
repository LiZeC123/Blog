---
title: Go相关知识
date: 2021-12-16 08:00:00
---


GO的指针与对象
--------------

Go存在类似C语言的指针，其含义也和C语言中的指针一样。

Go语言的特性使得结构体指针可以和结构体变量一样的语法来访问成员变量。因此有时候有一种和Java类似的错觉，似乎可以把指针视为对象。

但是另一方面Go的指针又具有函数可能修改这一变量的含义，但是Go没有泛型，类似场景只能定义一个万能的interface{}类型，这导致函数内如果想要修改变量，没有办法明确的要求这里是一个指针。 

如果调用的时候忘记了取地址，虽然函数的代码中可以做运行时检查，但这基本导致Go语言的强类型系统报废了。这绝对是一个设计缺陷。


排序
------------

对于简单的结构体数组，可以使用`sort.slice`方法，例如

```go
sort.Slice(planets, func(i, j int) bool {
  return planets[i].Axis < planets[j].Axis
})
```

- [What is the shortest way to simply sort an array of structs by (arbitrary) field names?](https://stackoverflow.com/questions/28999735/what-is-the-shortest-way-to-simply-sort-an-array-of-structs-by-arbitrary-field)

对于复杂的数据结构，可以通过实现sort包中定义的三个接口实现排序，可参考下面的文章

- [Go 中的三种排序方法](https://learnku.com/articles/38269)



字符串与数组转换
--------------------

使用`strconv`包将字符串转换为数字，使用`fmt.Sprintf`函数格式化的将一个数字转换为字符串。

- [Convert string to integer type in Go?](https://stackoverflow.com/questions/4278430/convert-string-to-integer-type-in-go)


字节数组与字符串转换
-----------------------------

```go
var str string = "test"
var data []byte = []byte(str)

str = string(data[:])
```
