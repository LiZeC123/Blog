---
title: MySQL笔记之高级优化
math: false
date: 2024-06-22 11:59:14
categories: MySQL笔记
tags:
    - MySQL
    - 数据库
cover_picture: images/mysql.png
---

本文主要讨论如何实现高并发, 高性能, 高可用的MySQL集群. 实现此目标的核心是复制, 扩展和切换. 复制通过binlog传送实现数据冗余, 获得并发量与可用性提升, 但会占用更多硬件资源. 扩展通过数据分片, 分库分表方式实现实现数据库容量提升, 获得并发量与可用性提升, 但可能会降低可用性. 切换通过主从切换, 获得可用性提升.





