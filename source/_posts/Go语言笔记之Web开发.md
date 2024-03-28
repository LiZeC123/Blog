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


### 配置MySQL

与SQLite几乎不需要任何参数的链接方式不同, 在连接到MySQL时, 需要配置好MySQL的字符串, 并且添加如下的一些参数

- `parseTime=True`: 启用时间解析, 否则无法正确实例时间类型, 导致数据获取失败

### 字段标记

GORM使用GO语言提供的结构体字段tag功能实现数据库字段的结构定义, 例如

```
type Task struct {
	gorm.Model
	Type     string `gorm:"size:32"`
	Status      string `gorm:"size:8"`
	Env         string `gorm:"size:32;index"`
}
```

所欲的属性都以`gorm`开头, 在属性的内部, 不同的属性之间使用`;`分割, 同一个属性的参数之间使用`,`分割. 详细的标记使用方法可参考官方文档

- [所有可用属性表](https://gorm.io/docs/models.html#Fields-Tags)
- [Index相关属性](https://gorm.io/docs/indexes.html)

### 动态查询

在开发Web接口时, 可能遇到不定条件的查询请求, 又或者一个基本相同的SQL需要做分页查询, 需要返回分页数据和总数据条数. 此时可利用GORM的链式调用能力实现此功能.

GORM的WHERE函数可多次调用, 这些条件之间使用AND连接. 在组装完毕后, 可分别调用Count函数和Find函数获取数据, 例如


```go
db := VarGorm.Table("tasks").Order("id desc")
if  xx {
  db = db.Where("creator = ?", Req.Get("creator").String() )
}

db.Count(&count)

db.Limit(10).Offset(20).Find(&tasks)
```

- [一种使用GORM实现动态查询的可行方案](https://www.cnblogs.com/Di-iD/p/16320874.html)


### 无结构体查询

通常情况下, GORM需要一个GO的结构体作为模型, 从而确定需要查询的表以及数据的映射关系. 但有些情况下可能无法给定对应的模型, 或者需要一个通用能力的查询接口. 此时可以使用字符串指定表名, 使用map获取数据, 例如

```go
// 查询单条数据
m := map[string]interface{}{}
VarGorm.Table("tasks").First(&m)

// 查询多条数据
s := []map[string]interface{}
VarGorm.Table("tasks").Find(&s)
```


### 参考资料

- [GORM Guides](https://gorm.io/docs/index.html)
- [go-sqlite3](https://github.com/mattn/go-sqlite3)