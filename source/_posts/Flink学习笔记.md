---
title: Flink学习笔记
math: false
date: 2023-06-06 12:18:46
categories:
tags:
    - Flink
cover_picture: images/flink.jpg
---


Flink是一种流式计算框架. 流计算与传统的离线计算相比, 其主要特征是: 需要对随时进入系统的数据进行实时计算. 流计算处理的数据集是无界的, 数据来源可能是非持久化的. 基于以上特征, 流计算需要满足处理结果立即可用, 并随着数据的到来, 持续的进行更新. 由于数据非持久化, 因此对于容错也有较高的要求.


Flink基本概念
----------------

Flink的执行过程可以抽象的分割为 接收数据 -> 处理数据 -> 输出结果. 具体来说, 

1. 接收数据: 从一个或多个数据源(例如kafka)接收数据
2. 处理数据: 使用Flink提供的各类算子, 对收到的数据进行处理
3. 输出结果: 将计算后的结果输出(例如输出到Redis)


从计算逻辑的角度来看, 输入和输出都是外部的固定操作, 只有核心的数据处理过程是需要根据需求不断变化的.



Flink安装和配置
----------------

Flink在生产环境一般以集群的方式运行, 将相关的任务打包后上传到集群执行. 对于本地学习, Flink也支持直接在IDEA中执行. 

对于本地执行, 需要安装Java 11及以上的版本(推荐安装长期支持版, 例如Java 17), 并下载Flink的代码包, 具体可参考[官方安装指引](https://nightlies.apache.org/flink/flink-docs-release-1.17/zh/docs/try-flink/local_installation/). 

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



聚合查询
---------

### Java模式

例如想要按照事件查询某个滑动窗口内的次数, 使用Java的代码如下:

```java
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

    DataStream<Transaction> transactions = env
            .addSource(new TransactionSource(10, 3, 1))
            .name("transactions");
    
    DataStream<Alert> alerts = transactions
            .assignTimestampsAndWatermarks(
                    WatermarkStrategy.<Transaction>forBoundedOutOfOrderness(Duration.ofSeconds(3))
                            .withTimestampAssigner((event, timestamp) -> event.getTimestamp()))
            .keyBy(Transaction::getAccountId)
            .window(SlidingEventTimeWindows.of(Duration.ofSeconds(10), Duration.ofSeconds(2)))
            .aggregate(
                    new AggregateFunction<Transaction, Alert, Alert>() {
                        @Override
                        public Alert createAccumulator() {
                            return new Alert("", 0);
                        }

                        @Override
                        public Alert add(Transaction transaction, Alert o) {
                            return new Alert(transaction.getAccountId(), o.getCount() + 1);
                        }

                        @Override
                        public Alert getResult(Alert o) {
                            return o;
                        }

                        @Override
                        public Alert merge(Alert o, Alert acc1) {
                            return new Alert(o.getUid(), o.getCount() + acc1.getCount());
                        }
                    }
            );


    alerts
            .addSink(new SinkFunction<>() {
                public void invoke(Alert alert, Context ctx) {
                    LoggerFactory.getLogger(Alert.class).info(alert.toString());
                }
            })
            .name("send-alerts");

    env.execute("Fraud Detection");
```

逻辑并不复杂, 但由于Java的强类型要求, 这里面涉及大量的类型问题, 泛型代码写起来非常的难受.



### SQL模式

相较于Java写的头疼的类型转换, 使用SQL可以极大的简化代码, 因此官方也更推荐使用SQL来进行处理.

```java
    // 1. 创建环境（不再需要 setStreamTimeCharacteristic）
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env);

    // 2. 创建数据源并添加水印策略
    DataStream<Transaction> transactions = env
            .addSource(new TransactionSource(10, 3, 1))
            .name("transactions");

    // 🌟 关键：创建并应用水印策略
    WatermarkStrategy<Transaction> watermarkStrategy =
            WatermarkStrategy.<Transaction>forBoundedOutOfOrderness(Duration.ofSeconds(3))
                    .withTimestampAssigner((event, timestamp) -> event.getTimestamp());

    DataStream<Transaction> watermarkedTransactions = transactions
            .assignTimestampsAndWatermarks(watermarkStrategy);

    // 3. 创建视图（使用带水印的流）
    tableEnv.createTemporaryView("transactions", watermarkedTransactions,
            $("accountId"),
            $("timestamp").rowtime().as("rowtime")  // 标记为事件时间
    );

    // 4. SQL查询
    Table resultTable = tableEnv.sqlQuery(
            "SELECT accountId, COUNT(*) AS cnt " +
                    "FROM transactions " +
                    "GROUP BY accountId, " +
                    "HOP(rowtime, INTERVAL '2' SECOND, INTERVAL '10' SECOND)"
    );

    // 5. 转换并输出结果
    DataStream<Row> resultStream = tableEnv.toDataStream(resultTable);
    resultStream.print();

    env.execute("SQL Window Aggregation");
```

> SQL可以解决类型问题, 但水位线还是要手动设置一下



### 窗口函数速查表


| **窗口类型** | **SQL 语法**                                                        | **参数说明**                                                                      | **示例**                                                  | **等价 DataStream API**                                                     |
| ------------ | ------------------------------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------------------- |
| **滚动窗口** | `TUMBLE(rowtime, INTERVAL '时长' 单位)`                             | • `rowtime`: 事件时间字段<br>• `时长`: 窗口大小<br>• `单位`: SECOND/MINUTE/HOUR等 | `TUMBLE(rowtime, INTERVAL '10' SECOND)`                   | `TumblingEventTimeWindows.of(Duration.ofSeconds(10))`                       |
| **滑动窗口** | `HOP(rowtime, INTERVAL '滑动步长' 单位, INTERVAL '窗口大小' 单位)`  | • `rowtime`: 事件时间字段<br>• `滑动步长`: 窗口滑动间隔<br>• `窗口大小`: 窗口长度 | `HOP(rowtime, INTERVAL '2' SECOND, INTERVAL '10' SECOND)` | `SlidingEventTimeWindows.of(Duration.ofSeconds(10), Duration.ofSeconds(2))` |
| **会话窗口** | `SESSION(rowtime, INTERVAL '超时时间' 单位)`                        | • `rowtime`: 事件时间字段<br>• `超时时间`: 会话不活动间隔                         | `SESSION(rowtime, INTERVAL '5' MINUTE)`                   | `EventTimeSessionWindows.withGap(Duration.ofMinutes(5))`                    |
| **累积窗口** | `CUMULATE(rowtime, INTERVAL '步长' 单位, INTERVAL '最大时长' 单位)` | • `rowtime`: 事件时间字段<br>• `步长`: 每次累积间隔<br>• `最大时长`: 累积上限     | `CUMULATE(rowtime, INTERVAL '1' HOUR, INTERVAL '1' DAY)`  | 需自定义 `Trigger` + `AggregateFunction`                                    |


### 时间单位速查

| **单位** | **SQL 语法**          | **Java Duration 等价**  |
| -------- | --------------------- | ----------------------- |
| 秒       | `INTERVAL 'X' SECOND` | `Duration.ofSeconds(X)` |
| 分钟     | `INTERVAL 'X' MINUTE` | `Duration.ofMinutes(X)` |
| 小时     | `INTERVAL 'X' HOUR`   | `Duration.ofHours(X)`   |
| 天       | `INTERVAL 'X' DAY`    | `Duration.ofDays(X)`    |


### 完整 SQL 查询模板

#### 1. 滚动窗口模板
```sql
SELECT 
    user_id,
    COUNT(*) as event_count,
    TUMBLE_START(rowtime, INTERVAL '10' MINUTE) as window_start,
    TUMBLE_END(rowtime, INTERVAL '10' MINUTE) as window_end
FROM events
GROUP BY 
    user_id,
    TUMBLE(rowtime, INTERVAL '10' MINUTE)
```

#### 2. 滑动窗口模板
```sql
SELECT 
    user_id,
    COUNT(*) as event_count,
    HOP_START(rowtime, INTERVAL '1' MINUTE, INTERVAL '5' MINUTE) as window_start,
    HOP_END(rowtime, INTERVAL '1' MINUTE, INTERVAL '5' MINUTE) as window_end
FROM events
GROUP BY 
    user_id,
    HOP(rowtime, INTERVAL '1' MINUTE, INTERVAL '5' MINUTE)
```

#### 3. 会话窗口模板
```sql
SELECT 
    user_id,
    COUNT(*) as event_count,
    SESSION_START(rowtime, INTERVAL '10' MINUTE) as window_start,
    SESSION_END(rowtime, INTERVAL '10' MINUTE) as window_end
FROM events
GROUP BY 
    user_id,
    SESSION(rowtime, INTERVAL '10' MINUTE)
```

#### 4. 累积窗口模板
```sql
SELECT 
    user_id,
    SUM(amount) as total_amount,
    CUMULATE_START(rowtime, INTERVAL '1' HOUR, INTERVAL '24' HOUR) as window_start,
    CUMULATE_END(rowtime, INTERVAL '1' HOUR, INTERVAL '24' HOUR) as window_end
FROM transactions
GROUP BY 
    user_id,
    CUMULATE(rowtime, INTERVAL '1' HOUR, INTERVAL '24' HOUR)
```

---

### ⚠️ 重要前置步骤：定义事件时间

在使用任何窗口前，必须先定义事件时间属性：

**方法1：DDL 方式**
```sql
CREATE TABLE events (
    user_id STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (...);
```

**方法2：DataStream 转换方式**
```java
Table eventsTable = tableEnv.fromDataStream(
    eventsStream, 
    $("user_id"), 
    $("event_time").rowtime()  // 关键：标记为事件时间
);
```

---

### 💡 使用技巧

1. **窗口函数必须在 GROUP BY 子句中使用**
2. **TUMBLE_START/HOP_START 等函数用于获取窗口边界时间**
3. **累积窗口特别适合实时更新累计指标的场景**
4. **会话窗口无需指定固定大小，根据数据活跃度自动划分**



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