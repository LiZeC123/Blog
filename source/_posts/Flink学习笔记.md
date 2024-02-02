---
title: Flink学习笔记
math: false
date: 2023-06-06 12:18:46
categories:
tags:
cover_picture:
---


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



代码基本结构
-------------


```java
package spendreport;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.KeyedProcessFunction;
import org.apache.flink.util.Collector;

public class WordCountJob {
    public static void main(String[] args) throws Exception {

        // Flink依赖一个执行环境, 此行代码根据默认配置获取环境参数, 因此可以在本地和集群运行
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // Flink从一个数据源加载数据, 可以是Kafka, 也可以是文件等
        env.readTextFile("input.json").map((MapFunction<String, LogRecord>) s -> {
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(s, LogRecord.class); // 将每一行记录反序列化为结构体
        }).keyBy(LogRecord::getAction) // 将Action字段作为Key
        .process(new KeyedProcessFunction<String, LogRecord, Tuple2<String, Integer>>() {
            @Override
            public void processElement(LogRecord value, KeyedProcessFunction<String, LogRecord, Tuple2<String, Integer>>.Context ctx, Collector<Tuple2<String, Integer>> out) throws Exception {
                out.collect(Tuple2.of(value.getAction(), 1));  // 对每个Action进行拆分
            }
        }).keyBy(t -> t.f0).sum(1) // 求和每个Action的数量
        .print(); // 输出

        // 调用此函数开始执行
        env.execute();
    }
}
```

> 可以注意到, Flink操作过程与Java的Stream API具有高度的相似性, 许多概念都是对应存在的.



时间语义
--------

流计算对于时效性非常敏感, 因此在处理时采取不同的时间计算方式, 对于算子的结算结果也有不同的影响. Flink支持三种不同的计算时间

- 处理时间: 即计算节点所在的机器的本地时间. 由于分布式系统无法保证时间完全一致,且出现故障进行恢复时可能有数据堆积, 因此处理时间通常无法准确反应实际的时间, 通常仅用于不关系发生事件的场景.
- 事件事件: 每个独立事件发生时所在设备上的时间. 事件时间通常在事件进入Flink之前就已经被内嵌在事件中. 事件时间能够保证正确性, 哪怕事件是无序的, 延迟的甚至是从持久层的日志或者备份中恢复的.
- 摄入时间: 事件进入Flink的时间. 作业在执行时, 每个事件以执行source运算符对应的任务的节点的当前时钟作为时间戳.

### 水位线

在Flink计算引擎中度量事件时间进度的机制被称为水位线. 水位线作为特殊的事件被注入到事件流中流向下游.

### 时间窗口

窗口将无界流切片成一系列有界的数据集.

- 固定窗口: 固定窗口按固定的时间段或长度（比如小时或元素个数）来分片数据集
- 滑动窗口: 由窗口大小以及滑动周期构成（比如以小时作为窗口大小，分钟作为滑动周期）


恰好一次处理
--------------

- 最多一次: 事件可能会丢失但不会被重复传递
- 至少一次: 事件不会丢失但可能会被重复传递
- 恰好一次: 事件既不会丢失也不会被重复传递

Flink的分布式异步快照机制支持"恰好一次"语义. 但同样提供了对"至少一次"语义的支持，这给予了用户根据不同场景（比如允许数据重复，但希望延迟尽可能低）进行合理选择的灵活性



参考资料
-----------


- [基于 DataStream API 实现欺诈检测](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/try-flink/datastream/)
- [DataStream API 简介](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/learn-flink/datastream_api/)
- [使用状态](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/dev/datastream/fault-tolerance/state/#using-managed-keyed-state)