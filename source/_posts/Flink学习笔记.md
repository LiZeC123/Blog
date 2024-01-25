---
title: Flink学习笔记
math: false
date: 2023-06-06 12:18:46
categories:
tags:
cover_picture:
---



内容施工中, 请稍后查看...

Flink是一种流式计算框架. 流计算与传统的离线计算相比, 其主要特征是: 需要对随时进入系统的数据进行实时计算. 流计算处理的数据集是无界的, 数据来源可能是非持久化的. 基于以上特征, 流计算需要满足处理结果立即可用, 并随着数据的到来, 持续的进行更新. 由于数据非持久化, 因此对于容错也有较高的要求.


Flink基本概念
----------------

Flink的执行过程可以抽象的分割为 接收数据 -> 处理数据 -> 输出结果. 具体来说, 

1. 接收数据: 从一个或多个数据源(例如kafka)接收数据
2. 处理数据: 使用Flink提供的各类算子, 对收到的数据进行处理
3. 输出结果: 将计算后的结果输出


Flink安装和配置
----------------

Flink在生产环境一般以集群的方式运行, 将相关的任务打包后上传到集群执行. 对于本地学习, Flink也支持直接在IDEA中执行. 

对于本地执行, 需要按照Java 11和以上的版本, 并下载Flink的代码包, 具体可参考[官方安装指引](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/try-flink/local_installation/). 

在本地执行时, 可直接创建一个Maven项目 , 并在运行前在IDEA的配置中, 进行如下配置, 使得代码能够直接运行.

> IntelliJ IDEA: Go to Run > Edit Configurations > Modify options > Select include dependencies with "Provided" scope.





