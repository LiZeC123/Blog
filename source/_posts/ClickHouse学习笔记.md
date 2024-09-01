---
title: ClickHouse学习笔记
math: false
date: 2024-08-18 13:01:36
categories:
tags:
    - ClickHouse
cover_picture:
---


ClickHouse
----------------

ClickHouse是一种开源的分布式列式数据库管理系统（DBMS），专为处理大规模数据分析和数据仓库工作负载而设计。它是由俄罗斯的Yandex开发，并于2016年开源发布。

ClickHouse的设计目标是提供高性能的数据查询和分析能力，特别适用于处理大规模数据集和复杂查询。它采用了列式存储结构，这意味着数据按列而不是按行存储，这在分析场景下可以提供更高的查询性能。此外，ClickHouse还采用了多级压缩和向量化查询等技术，进一步提升了查询速度。

ClickHouse具有以下几个主要特点：

1. 高性能：ClickHouse在大规模数据集上具有出色的查询性能。它可以并行处理大量数据，支持高吞吐量和低延迟的查询操作。

2. 可扩展性：ClickHouse是一个分布式系统，可以水平扩展到多个节点，以处理大量数据和并发查询。它支持数据的分区和复制，可以在集群中实现高可用性和容错性。

3. 实时数据插入：尽管ClickHouse主要用于数据分析，但它也支持实时数据插入。它提供了高效的批量数据导入接口和实时数据流式传输接口，可以满足实时数据分析的需求。

4. SQL兼容性：ClickHouse支持标准的SQL查询语言，并提供了丰富的查询功能，包括聚合函数、窗口函数、子查询等。这使得开发人员可以使用熟悉的SQL语法进行数据分析和查询。

5. 灵活的数据模型：ClickHouse支持动态和静态数据模型，可以处理各种数据类型和复杂的数据结构。它还提供了高级的数据压缩和索引技术，可以有效地存储和查询大规模数据。

ClickHouse在许多大型互联网公司和数据驱动型企业中被广泛应用，用于数据分析、日志分析、实时报表和数据仓库等场景。它的高性能和可扩展性使得它成为处理大数据分析任务的理想选择。同时，由于其开源的特性，ClickHouse也得到了一个活跃的社区支持，并不断发展和改进。

> 云产品也太贵了, 根本买不起(包月需要1000+元, 按量付费每小时8+元). 



### 导入数据

```
Query id: 041b433b-c386-459c-99a1-f335da5c7f75

Ok.

0 rows in set. Elapsed: 646.208 sec. Processed 29.30 million rows, 5.13 GB (45.34 thousand rows/s., 7.93 MB/s.)
Peak memory usage: 428.90 MiB.
```

### 查询数据

```
30 rows in set. Elapsed: 0.062 sec. Processed 29.30 million rows, 175.80 MB (473.14 million rows/s., 2.84 GB/s.)
Peak memory usage: 6.72 MiB.
```

查询数据本质上取决于磁盘性能, 但总体上来说, 确实可以实现声称的亿级别的行处理速度




参考资料
----------

- [clickhouse/clickhouse-server | DockerHub](https://hub.docker.com/r/clickhouse/clickhouse-server)
- [案例: 英国房地产支付价格 | ClickHouse Docs](https://clickhouse.com/docs/zh/getting-started/example-datasets/uk-price-paid)