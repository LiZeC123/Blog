---
title: Go语言笔记之Web开发
date: 2021-11-12 15:19:20
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->





基本组件
-----------------

Go官方提供了MySQL驱动代码， 导入驱动代码即可访问数据库。

Redis并没有官方客户端，但是redis官网提供了一些可选的客户端，其中redigo可以考虑使用


Gin
----------

Gin是Go语言的Web框架, 使用此框架需要引入如下的包

```
go get -u github.com/gin-gonic/gin
```

Gin与Java的Spring框架相比, 主要实现了两个功能, 即 URL与Go函数的绑定 和 Web参数与Go接口体的绑定. 

虽然只有这两个功能, 但是对于开发一个简单的Web项目来说确实也基本够用了. Gin的大部分用法在README中都有直接的展示, 非常容易上手.

- [Gin Web Framework](https://github.com/gin-gonic/gin)


Grom
-----------

Gorm是Go语言的ORM框架, 使用此框架需要引入如下的包

```
go get -u gorm.io/gorm
go get -u gorm.io/driver/sqlite
```

其中`gorm.io/driver/sqlite`模块需要使用CGO特性, 要求环境中能使用GCC编译器, 对于window环境, 可以考虑安装[TDM-GCC](https://jmeubank.github.io/tdm-gcc/), 具体可以参考[文档中的这一章节](https://github.com/mattn/go-sqlite3#windows)

> 如果需要访问MySQL数据库, 将驱动替换为MySQL驱动即可

之后, 只需要在代码中进行必要的声明即可

```go
package main

import (
  "gorm.io/gorm"
  "gorm.io/driver/sqlite"
)

type Product struct {
  gorm.Model
  Code  string
  Price uint
}

func main() {
  db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
  if err != nil {
    panic("failed to connect database")
  }

  // Migrate the schema
  db.AutoMigrate(&Product{})

  // Create
  db.Create(&Product{Code: "D42", Price: 100})

  // Read
  var product Product
  db.First(&product, 1) // find product with integer primary key
  db.First(&product, "code = ?", "D42") // find product with code D42

  // Update - update product's price to 200
  db.Model(&product).Update("Price", 200)
  // Update - update multiple fields
  db.Model(&product).Updates(Product{Price: 200, Code: "F42"}) // non-zero fields
  db.Model(&product).Updates(map[string]interface{}{"Price": 200, "Code": "F42"})

  // Delete - delete product
  db.Delete(&product, 1)
}
```

- [GORM Guides](https://gorm.io/docs/index.html)
- [go-sqlite3](https://github.com/mattn/go-sqlite3)