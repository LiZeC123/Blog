---
title: Java开发手册笔记
date: 2020-06-29 17:17:17
categories:
tags:
    - Java
cover_picture: images/java.jpg
---




本文是对阿里巴巴的`Java开发手册`的笔记, 对其中的一些平时没有注意的细节进行记录, 并对一些内容补充细节和自己的理解.


命名风格
----------------

**【强制】** 类名使用UpperCamelCase风格, 但以下情形例外：DO / BO / DTO / VO / AO / PO / UID等

> 这些例外情况都是缩写词, 缩写词始终保持全大写.


**【强制】** 抽象类以Abstract或Base开头

**【强制】** POJO类中的任何布尔类型的变量, 都不要加is前缀

> 由于各种框架对于布尔型变量可能生成is开头的get方法, 因此不建议加入is, 以免解析过程中产生冲突.


**【强制】** 包名统一使用小写, 点分隔符之间有且仅有一个自然语义的英语单词. 包名统一使用单数形式, 类名根据需要可以使用复数形式

**【参考】** 各层命名规约 

方法含义        | 前缀              | 方法含义        | 前缀
---------------|-------------------|----------------|---------------
获取单个对象    | get               | 获取多个对象    | list
获取统计值      | count             | 插入数据        | save / insert
删除数据        | remove / delete   | 修改数据        | update


领域模型        | 命名      | 备注
----------------|----------|-------------------
数据对象        | xxxDO     | xxx为对应的表名
数据传输对象    | xxxDTO    | xxx为业务领域相关名称
展示对象        | xxxVO     | xxx为网页名称

**【推荐】** 单个方法的总行数不超过80行

> 一个方法写太长则可读性不好, 方法太过零散也不适合阅读. 因此需要把方法的长度控制在适当的范围内. 要分清楚主干代码和辅助代码. 辅助代码写成函数, 使主干逻辑保持清晰简洁. 

OOP规范
---------------

**【强制】** 禁止使用构造方法BigDecimal(double)的方式把double值转化为BigDecimal对象.

> double不能精确表示数字, 使用String类型构造函数可以保证数字与字面值完全一致


**【强制】**  定义数据对象DO类时, 属性类型要与数据库字段类型相匹配

> 不当的数据类型可能导致溢出, 从而导致错误

**【强制】** 所有的POJO类属性必须使用包装数据类型
**【强制】** RPC方法的返回值和参数必须使用包装数据类型
**【推荐】** 所有的局部变量使用基本数据类型

> 包装类型可以设置为null, 从而提供额外的信息. 


**【强制】** 定义DO/DTO/VO等POJO类时, 不要设定任何属性默认值

> 构造函数不包含参数, 但实际却设置了属性, 容易产生误解



<!-- 
异常日志
单元测试
安全规约
MySQL数据库(重点)
工程结构
设计规约
 -->
