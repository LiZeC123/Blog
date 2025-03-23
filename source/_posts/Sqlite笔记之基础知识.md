---
title: Sqlite笔记之基础知识
math: false
date: 2025-03-23 22:12:02
categories:
tags:
cover_picture:
---

Sqlite显示表头
-----------------

默认情况下执行select语句只能得到`|`分割的数据, 如果数据比较多, 这种格式就不够直观. 可以通过如下的指令启用表头和以行模式展示数据.

```
.head on
.mode column
```