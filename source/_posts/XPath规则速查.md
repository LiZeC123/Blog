---
title: XPath规则速查
math: false
date: 2026-11-27 14:46:37
categories:
tags:
    - XPath
cover_picture:
---

下面以 **XPath 1.0** 为主做基础介绍。XPath 是用于在 XML/HTML 文档中“选节点”的路径语言；表达式结果可以是节点集、字符串、数字或布尔值。

示例 XML（后文示例都基于它；实际结果中的文本是节点的字符串值）：

```xml
<bookstore>
  <book id="b1" lang="en">
    <title>XML Basics</title>
    <author>Alice</author>
    <price>29.99</price>
  </book>
  <book id="b2">
    <title>XPath Guide</title>
    <author>Bob</author>
    <price>39.95</price>
  </book>
</bookstore>
```

## 1. 路径与节点选择

| 语法         | 含义                                   | 示例                       | 示例结果                                   |
| ------------ | -------------------------------------- | -------------------------- | ------------------------------------------ |
| `/` 开头     | 绝对路径，从文档根开始                 | `/bookstore/book`          | 两本 `book` 元素                           |
| 相对路径     | 从当前上下文节点开始                   | 在某个 `book` 上写 `title` | 该书的 `title`                             |
| `/` 分隔步骤 | 父子关系                               | `/bookstore/book/title`    | 两个 `title`                               |
| `//`         | 后代选择缩写，表示任意深度的后代中匹配 | `//author`                 | `Alice`、`Bob` 两个 `author`               |
| `.`          | 当前节点，等价 `self::node()`          | `./title`                  | 当前节点的 `title` 子元素                  |
| `..`         | 父节点，等价 `parent::node()`          | `//title/..`               | 两个 `book`                                |
| `@属性名`    | 选属性，等价 `attribute::属性名`       | `//book/@id`               | `b1`、`b2`                                 |
| `*`          | 任意元素节点通配符                     | `//book/*`                 | 两本书的 `title/author/price`，共 6 个元素 |
| `@*`         | 任意属性通配符                         | `//book/@*`                | `id="b1"`、`lang="en"`、`id="b2"`          |
| `text()`     | 选文本节点                             | `//title/text()`           | `XML Basics`、`XPath Guide`                |
| `node()`     | 选任意类型子节点                       | `//book/node()`            | 子元素及空白文本节点（若文档有缩进换行）   |

## 2. 谓词 `[]`：过滤与位置

谓词写在步骤后面，用于过滤节点。**XPath 位置从 1 开始，不是 0。**

| 语法/写法        | 含义               | 示例                                  | 示例结果      |
| ---------------- | ------------------ | ------------------------------------- | ------------- |
| `[条件]`         | 保留满足条件的节点 | `//book[@id='b2']`                    | 第二本 `book` |
| `[@属性='值']`   | 按属性过滤         | `//book[@lang='en']/title`            | `XML Basics`  |
| `[子元素条件]`   | 按子元素值过滤     | `//book[price>30]/title`              | `XPath Guide` |
| `[1]`、`[2]`     | 位置谓词           | `//book[2]/title`                     | `XPath Guide` |
| `[last()]`       | 最后一个           | `(//book)[last()]/title`              | `XPath Guide` |
| `[position()=2]` | 显式位置           | `//book[position()=2]/title`          | `XPath Guide` |
| `[and/or/not()]` | 组合条件           | `//book[@id='b2' and price>30]/title` | `XPath Guide` |
| `not(@lang)`     | 没有某属性         | `//book[not(@lang)]/title`            | `XPath Guide` |

注意：`//book[1]` 与 `(//book)[1]` 语义不同。前者表示“每个父上下文中的第一个 `book`”，后者表示“全文档 `book` 节点集中的第一个”。基础使用时若想取全局第一个，建议写 `(//book)[1]`。

## 3. 轴（Axis）：控制查找方向

完整语法是 `轴名::节点测试[谓词]`，例如 `child::title`。很多常用轴有缩写。

| 轴语法                | 含义                   | 示例                                      | 示例结果                  |
| --------------------- | ---------------------- | ----------------------------------------- | ------------------------- |
| `child::`             | 子节点，默认轴，可省略 | `//book/child::title` 等价 `//book/title` | 两个 `title`              |
| `parent::`            | 父节点，缩写 `..`      | `//title/parent::book`                    | 两个 `book`               |
| `ancestor::`          | 所有祖先               | `//title/ancestor::bookstore`             | `bookstore`（去重后一个） |
| `descendant::`        | 所有后代               | `//bookstore/descendant::price`           | 两个 `price`              |
| `self::`              | 自身                   | `//title/self::title`                     | 两个 `title`              |
| `attribute::`         | 属性，缩写 `@`         | `//book/attribute::id` 等价 `//book/@id`  | `b1`、`b2`                |
| `following-sibling::` | 后续同级兄弟           | `//title/following-sibling::author`       | 两个 `author`             |
| `preceding-sibling::` | 前面的同级兄弟         | `//author/preceding-sibling::title`       | 两个 `title`              |

## 4. 运算符与常用函数

| 类别       | 语法                | 含义                     | 示例                                         | 示例结果                              |
| ---------- | ------------------- | ------------------------ | -------------------------------------------- | ------------------------------------- |
| 并集       | `\|`                | 合并两个节点集           | `//title \| //author`                        | 四个节点：两个 `title`、两个 `author` |
| 比较       | `= != < > <= >=`    | 比较值                   | `//book[price>=30]/title`                    | `XPath Guide`                         |
| 逻辑       | `and or not()`      | 逻辑组合                 | `//book[not(@lang)]/title`                   | `XPath Guide`                         |
| 算术       | `+ - * div mod`     | 加减乘除、取余           | `//book[price div 2 > 15]/title`             | `XPath Guide`                         |
| 计数       | `count()`           | 节点个数                 | `count(//book)`                              | `2`                                   |
| 字符串包含 | `contains()`        | 是否包含子串             | `contains(string((//title)[1]), 'XML')`      | `true`                                |
| 字符串前缀 | `starts-with()`     | 是否以某串开头           | `starts-with(string((//title)[2]), 'XPath')` | `true`                                |
| 去空白     | `normalize-space()` | 去首尾空白并压缩内部空白 | `normalize-space((//title)[2])`              | `"XPath Guide"`                       |
| 转字符串   | `string()`          | 转字符串                 | `string((//price)[1])`                       | `"29.99"`                             |
| 转数字     | `number()`          | 转数字                   | `number((//price)[2])`                       | `39.95`                               |

## 小结

XPath 表达式基本可理解为：

```text
路径 = 步骤/步骤/步骤...
步骤 = 轴::节点测试[谓词]
```

最常用的基础写法是：`/` 绝对路径、`//` 后代选择、`@` 属性、`*` 通配、`[]` 过滤、`.`/`..` 当前/父节点，以及 `child/parent/ancestor/descendant/attribute/following-sibling/preceding-sibling` 等轴。使用时特别注意：XPath 1.0 的索引从 1 开始；`//book[1]` 与 `(//book)[1]` 不同；XML 命名空间和 HTML 大小写在实际环境中也会影响匹配。