---
title: Go语言笔记之Web开发
date: 2021-11-12 15:19:20
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---




Go语言的Web开发与Java的Web开发一样，虽然内置包提供了基础功能，但还是会使用一系列的开源框架和中间件来简化开发。在目前的Go语言Web开发中，通常会使用Gin作为Web框架，使用Gorm作为数据库映射框架，使用redigo作为redis客户端。

Gin提供了URL绑定和Web参数绑定功能，虽然远不如Spring框架自动化程度高，但好在够用，性能消耗小。Gorm提供了Go对象和数据库的映射功能，用法上与MyBatis差别比较大，但足够简单易用，因此小项目中开发更顺滑。


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