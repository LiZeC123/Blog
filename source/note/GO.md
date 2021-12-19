---
title: Go相关知识
date: 2021-12-16 08:00:00
---


字节数组与字符串转换
-----------------------------

```go
var str string = "test"
var data []byte = []byte(str)

str = string(data[:])
```