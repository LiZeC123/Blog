---
title: Go语言笔记之内置工具
math: false
date: 2023-08-19 13:49:31
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---


本文介绍Go内置工具的基本使用.



运行测试
----------------

对于大多数情况, 直接在IDE中点击运行对应的测试函数是最为简单的方式. 但少数情况下, 由于需要添加一些特殊的参数, 因此也会手动运行测试.

常用的指令如下
```bash
# 运行当前包下的所有测试, 并显示详细信息
go test -v

# 以启用缓存的模式运行指定路径下的所有测试, 并显示详细信息
go test . -v

# 运行当前包下指定名称的测试函数
go test -run TestFunction


# 运行基准测试(默认不会运行基准测试)
go test -bench .
```

