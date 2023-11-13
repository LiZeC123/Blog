---
title: Clojure学习笔记
date: 2023-06-18 09:53:48
categories: 
tags: 
    - Clojure
cover_picture: 
---


Clojure是一种运行在JVM上的Lisp方言. Clojure语言因此在语法上与Scheme有较多的相似性, 同时又可以充分利用Java生态中的各类工具.


基础语法
---------------

Clojure的基础语法基本上可以认为和Scheme一致, 以下是一些常用的 Clojure 基本关键字及其描述：

| 关键字          | 描述                                               |
|-----------------|----------------------------------------------------|
| def             | 定义一个符号，通常用于定义全局变量。                 |
| defn            | 定义一个函数。                                       |
| let             | 绑定一些局部变量，定义永久性绑定。                   |
| if              | 用于条件判断。                                       |
| do              | 顺序地执行多个表达式。                               |
| loop/recur      | 创建一个可递归的循环。                               |
| fn              | 创建一个匿名函数。                                   |
| quote           | 返回其参数未求值的表示形式。                         |
| eval            | 求值一个表达式。                                     |
| str             | 将一个元素转换为字符串(类似ToString)                |




```Clojure
; 定义符号
(def PI 3.14)

; 定义函数
(defn square [x]
  (* x x))

(defn area [r]
  (* PI (square r)))
```










| case            | 多分支条件判断。                                     |
| cond            | 一系列布尔表达式和结果值的有序并列。                 |
| for             | 列表推导，生成各种数据集合。                         |
| map             | 处理列表中每个元素的操作。                           |
| reduce          | 将一个函数应用于一个序列的元素，以汇总结果。         |
| filter          | 根据一个谓词函数从一个集合中筛选元素。               |
| lazy-seq        | 创建一个惰性序列。                                   |
| deref/@         | 解引用，获取 Ref、Agent 和 Atom 的当前值。           |
| ref             | 创建一个 Ref 类型对象。                              |
| agent           | 创建一个 Agent 对象。                                |
| atom            | 创建一个 Atom 类型对象。                             |
| alter           | 改变 Ref 对象的值。                                  |
| swap!           | 改变 Atom 对象的值。                                 |
| send            | 通过 Agent 发送一个任务。                            |
| ns              | 声明一个命名空间。                                   |
| require         | 在当前命名空间导入另一个模块的符号。                 |
| import          | 导入 Java 类。                                       |
| new             | 创建一个 Java 对象。                                  |
| .               | 调用 Java 的实例方法。                               |
| ..              | 在一个 Java 对象上连续调用方法。                      |
| doto            | 为一个 Java 对象连续调用方法，返回原始对象。         |

请注意，Clojure 关键字列表并不局限于此，还有许多其他的关键字。这个列表仅提供了一些关键字的简短概述，要了解更详细的信息，请参阅 Clojure 官方文档。
