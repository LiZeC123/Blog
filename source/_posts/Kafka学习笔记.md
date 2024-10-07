---
title: Kafka学习笔记
math: false
date: 2024-10-07 08:51:28
categories:
tags:
    - Kafka
cover_picture: images/kafka.jpg
---

Kafka是一个分布式, 高吞吐量, 高可扩展性的消息系统. Kafka基于发布/订阅模式, 通过消息解耦, 使生产者和消费者异步交互, 无需彼此等待. Kafka具有高可用, 数据压缩, 同时支持离线和实时数据处理等优点, 适用于日志压缩收集, 监控数据聚合, 流式数据集成等场景.


基本概念
------------------

生产者(Producer)负责向Kafka集群发送数据消息, 消费者(Consumer)订阅并处理来自Kafka集群的数据消息. 消息依据主题(Topic)进行分类, 生产者向特定主题发送消息, 消费者订阅特定主题以接收消息. 投递到Kafka的消息可以被多个消费组(Consumer Group)消费, 每个消费组独立记录消息消费进度(Offset), 因此多个消费组可以并行地消费同一个主题, 该主题下的消息可被每个消费者组消费一次.

为了实现高吞吐量和负载均衡, 一个主题被拆分为多个分区(Partition), 每个分区都是一个有序的消息队列, 拥有该主题的一部分消息. 数据按照特定的规则写入分区并被不同的消费者读取. 在一个消费组内, 一个分组仅可被一个消费者消费, 因此分区数量通常应该设置为消费者数量的整数倍, 使得每个消费者消费的分区数量尽可能均衡.

Kafka是一个分布式组件, 集群中的每个节点被称为代理(Broker). 为了确保数据的可靠性和容错, 每条消息应该具有多个副本(Replication), 并且这些副本应该保存在不同的节点上, 使得Kafka的某个节点出现故障时, 其他具有相同副本的代理节点可以继续处理消息. 

启用副本后, 主节点与副本节点需要同步消息, 副本节点与主节点的消息差距小于一定值时称之为处于同步状态(in-sync-replica, ISR). 为了保证主节点故障后切换到副本节点时, 不会产生数据丢失, Kafka需要保证消费者当前的消费进度小于父节点的消息同步进度.

> [7张图了解kafka基本概念](https://segmentfault.com/a/1190000040633029)

Kafka的消息可以分为消息标识(Key)和消息内容(Value). Key可以用于唯一标识一条消息, 也可以用于分区路由. Value是业务的自定义参数, 本质上就是一个字节数组, 由业务自行决定存储格式.

在一条消息被消费后, Kafka并不会立即删除该消息, 而是将该消息保留, 直到 消息存储了指定的天数 或者 消息保留的消息达到一定大小的字节数.

Kafka的消费语义是至少投递一次(at least once), 即保证消息不被丢失, 至少被消费者消费一次. 但不保证消息重复消费. 如果业务对重复消费较为敏感, 则还需要进行幂等处理.


核心参数
------------

在不同的框架下, 表示同一含义的参数可能具有不同的名称, 因此以下仅给出参数的含义与解释

**消费者组名称**: 用于标记一组消费者, 一条消息仅可在一个消费者组内消费一次. 不同的消费者组可以消费同一条消息.

**生产者ID**: 仅用于标识生产者, 对投递消息无影响. 但使用恰当的名称有助于分析消息的生产情况

**重试次数与间隔**: 消息投递失败时可进行重试, 如果需要确保消息绝不丢失, 可设置非常大的重试次数(例如Integer.MAX_VALUE)

**消息确认机制**: 可选择无需确认, 主节点写入成功即确认, 或者主节点写成功且 ISR 中的节点同步成功才确认. 一般选择主节点写入成功即确认, 该模式具有较好的性能, 但如果主节点宕机, 将导致少量数据丢失.

**批量发送**: 生产者将一批数据打包发送到服务端, 可以控制打包发送的参数, 例如消息的最大缓存时间, 最大缓存容量等. 较小的缓存将导致频繁的发送请求, 拉高服务端的CPU消耗.

**压缩算法**: 可指定是否对消息进行压缩. 消息压缩后体积更小, 因此消耗的磁盘和带宽将会减少. 但消息压缩也会产生更高的CPU消耗.

**自动提交**: 消费者可自动自动提交, 从而在收到消息后就视为消费成功. 否则消费者需要手动提交, 否则视为该消息消费时候, 会自动重试消费此消息.

> [生产消费最佳实践 - 腾讯云课程](https://cloud.tencent.com/developer/tutorial/practice/1007?from=22466&from_column=22466)



分区策略
----------

Kafka具有多种分区策略, 通常情况下, 如果指定的Key, 则按照Key的Hash值进行分区, 从而确保Key一致的消息总是路由到同一个分区. 如果未指定Key, 则Kafka默认使用轮询策略.

> 注意: 对于Java来说, 将Key指定为null即为不指定, 但对于其他语言, 需要确认具体是什么零值表示不指定.

### 黏性分区

只有发送到相同分区的消息，才会被放到同一个 Batch 中, 在消息没有指定Key的情况下, 默认策略是循环使用主题的所有分区, 此模式下批量发送消息的效果较差. 因此Kafka在2.4版本引入了黏性分区策略(Sticky Partitioning Strategy).

其主要思路是随机选择一个分组, 在一段时间内使得后续消息尽可能使用该分区, 直到这批消息批量发送后再随机切换到下一个分区. 在短时间内看, 此模式会将消息发送到同一个分区, 但从长时间看, 消息还是均匀的发送到各分区之上的. 在此模式下批量发送效率更高, 从而可以降低延迟, 提升服务性能.

- [Kafka分区分配策略（Partition Assignment Strategy）-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1708388)


安装Kafka
---------------

Kafka具有多种安装方式, 其中基于官网指引的安装模式最为稳定, 但该模式需要在本机安装程序和依赖, 如果出现错误可能导致本机环境不稳定. 因此以下仅介绍两种特殊安装方式, 本地安装可直接参考官网教程


### 使用Docker镜像安装kafka

使用如下的`docker-compose.yml`文件拉取kafka镜像

```yml
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

version: "2"

services:
  kafka:
    image: docker.io/bitnami/kafka:3.5
    ports:
      - "9092:9092"
      - '9094:9094'
    volumes:
      - "kafka_data:/bitnami"
    environment:
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093,EXTERNAL://:9094
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092,EXTERNAL://localhost:9094
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT

volumes:
  kafka_data:
    driver: local
```

> 注意: 官方标准的yml文件中未配置KAFKA_CFG_LISTENERS, 导致无法在HOST机器中链接到镜像内的kafka


可执行如下指令安装python的kafka库

```
pip install confluent-kafka
```

并使用如下脚本验证能否正常发送消息

```py
#! /usr/bin/python3

from confluent_kafka import Producer
import socket

conf = {'bootstrap.servers': "localhost:9092", 'client.id': socket.gethostname()}

producer = Producer(conf)

producer.produce("foo", key="key", value="value")
producer.flush()
```

### 免费试用云产品

可在腾讯云免费试用Kafka在内的多种云产品

- [免费试用专区 - 腾讯云](https://cloud.tencent.com/act/pro/free)



RabbitMQ和Kafka的对比
------------------------------


RabbitMQ 和 Kafka 都是高度可扩展、高性能的消息队列服务。以下是它们一些基本概念的对比：

数据模型
RabbitMQ：基于 AMQP 协议，使用 Exchange 和 Queue 的概念。生产者发送消息到 Exchange，然后 Exchange 根据规则将消息路由到一个或多个 Queue 中，消费者从 Queue 中消费消息。
Kafka：基于分布式的流处理平台，使用 Topic 和 Partition 的概念。生产者发送消息到特定的 Topic，Topic 可划分为多个 Partition。消费者订阅并消费特定的 Topic。


消息分发
RabbitMQ：通过 Exchange 和 Binding 规则实现较为灵活的消息路由能力。可以实现广播、直接发送或主题匹配等方式来将消息传递给消费者。
Kafka：通过 Partition 实现消息并行处理，从而提升消费速度。但不具备灵活的消息路由功能。


消息持久化
RabbitMQ：消息默认保存在内存中，但可以配置为持久化到硬盘。持久化的消息在 RabbitMQ 服务器重启后仍然可用。
Kafka：消息默认持久化存储在硬盘上。默认保留数据的时间窗口是7天，也可以调整。

消费模型
RabbitMQ：支持点对点模式（一个消息只能被一个消费者消费）以及发布/订阅模式（一个消息可以被多个消费者消费）。
Kafka：天然支持发布/订阅模式，允许多个消费组并行消费同一主题。


一致性
RabbitMQ：在消息传递过程中可能会发生消息丢失或重复消费的情况。
Kafka：通过使用 Partition、Offset 和 Consumer Group 确保消息只会被消费一次，保证了一致性。


扩展性
RabbitMQ：可以通过集群或镜像队列来实现高可用性和负载均衡。
Kafka：采用分布式架构、多副本机制和分区模型，具备较高的扩展性和容错能力。


总结，RabbitMQ 与 Kafka 在概念上存在一定相似度，都提供高性能、高可扩展性的消息队列服务。然而，它们在数据模型、消息分发、持久化和消费模型等方面有着不同的特点。RabbitMQ 更适用于需要灵活路由能力的场景，而 Kafka 更适用于面向高并发、高吞吐量的大规模事件流处理场景。选择适合的消息队列服务需要根据实际业务场景进行评估。

- [消息队列RocketMQ是什么？和Kafka有什么区别？架构是怎么样的？7分钟快速入门_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1m7421Z7fN/)
- [kafka为什么这么快？RocketMQ哪里不如Kafka?_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Zy411e7qY/)