---
title: NodeJs学习笔记之基础知识
math: false
date: 2023-09-23 22:17:40
categories:
tags:
    - nodejs
    - javascript
cover_picture:
---



ES6 与 ECMAScript 2015 
------------------------

ES6是JavaScript语言的一种规范定义, 可以类似的理解为`Java 8`. 该标准于2015年推出, 因此有时候也使用`ECMAScript 2015` 指代. 在ES6标准推出的时候, 许多浏览器对于该语法的支持还不完善, 因此还需要使用Babe转码器进行处理.

对于NodeJs而言, 通常情况下是领先于浏览器的, 对于ES6的支持比较全面.

> 都2023年了, 感觉应该并不存在这些问题了.





NPM基本使用
-----------------

### 基本指令

TODO: 常用命令学习



### package.json文件

TODO: 依赖于开发依赖

对于一个给定的版本号`x.y.z`, `^`表示可以更新`y`和`z`到最新版, `~`表示可以更新`z`到最新版


### 使用模块

在启用webpack打包之前, 只能根据位置位置在HTML中引用对应的文件. 启用webpack后, 可以使用ES6的`require`语法或`import`语法

```js
const $ = require('jquery')
```

webpack原理与使用
---------------


TODO:
1. 回顾JS语法特性, 补充必要的语法知识
2. 补充对于NodeJS情况下, JS的语法知识
3. 增加Typescript相关内容
