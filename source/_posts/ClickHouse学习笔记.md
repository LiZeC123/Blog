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


### 列式存储

**列式存储**是ClickHouse的核心特性之一，它与传统的关系型数据库常用的行式存储形成鲜明对比。以下是关于ClickHouse中列式存储的详细介绍：

#### 基本概念

- **数据组织方式**：在列式存储中，数据按照列而不是按照行来组织和存储。这意味着同一列的所有数据项都连续存放在一起。
  
- **优势**：
  - **高效的聚合操作**：因为相同类型的数据聚集在一起，所以执行SUM、AVG等聚合函数时更加高效。
  - **减少I/O开销**：查询只需要读取必要的列，减少了不必要的数据传输。
  - **更好的压缩比**：同一列内的数据相似度高，更容易被压缩。

#### 实现细节

- **存储引擎**：ClickHouse提供了多种存储引擎，如MergeTree系列，它们都支持列式存储。
  
- **数据文件**：每个列通常会被存储在一个或多个单独的文件中，便于并行读取和处理。

### 数据压缩

数据压缩是提高存储效率和I/O性能的关键技术。ClickHouse内置了多种压缩算法，并允许用户根据具体需求进行选择和配置。

#### 主要特点

- **多种压缩算法**：支持LZ4、ZSTD、Deflate等压缩算法，每种算法在压缩比和压缩/解压速度之间有不同的权衡。
  
- **自动压缩**：ClickHouse可以在数据写入磁盘时自动进行压缩，并在读取时解压。
  
- **分区和分片级别的压缩**：可以在不同的数据分区或分片上应用不同的压缩策略。

#### 压缩的好处

- **节省存储空间**：通过去除冗余数据和利用数据的局部性，显著减少所需的物理存储空间。
  
- **加速数据传输**：压缩后的数据占用更少的带宽，特别是在网络传输过程中。

### 向量化技术

向量化是ClickHouse用来进一步提高查询性能的一种重要技术。

#### 核心思想

- **批量处理**：向量化技术允许数据库引擎一次处理多个数据值（即一个向量），而不是逐个处理单个值。
  
- **SIMD指令集利用**：现代CPU支持SIMD（单指令多数据）指令集，向量化能够充分利用这些指令集进行并行计算。

#### 实施细节

- **查询优化器**：ClickHouse的查询优化器会尝试将可以向量化的操作转换为对应的向量操作。
  
- **内置函数支持**：许多内置函数都已经过优化，以支持向量化执行。

#### 性能优势

- **显著提高计算速度**：通过并行处理，向量化可以大大加快数据处理速度，尤其是在大规模数据集上执行复杂计算时。
  
- **减少CPU周期消耗**：相比于逐条处理记录，向量化减少了循环开销和条件判断次数。


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

CK的环境配置与案例数据

- [clickhouse/clickhouse-server | DockerHub](https://hub.docker.com/r/clickhouse/clickhouse-server)
- [案例: 英国房地产支付价格 | ClickHouse Docs](https://clickhouse.com/docs/zh/getting-started/example-datasets/uk-price-paid)


一些关于CK原理的介绍

- [Clickhouse数据存储结构 - eedbaa - 博客园](https://www.cnblogs.com/eedbaa/p/14512803.html)
- [MergeTree | ClickHouse Docs](https://clickhouse.com/docs/zh/engines/table-engines/mergetree-family/mergetree#mergetree)
- [ClickHouse存储原理初窥_性能优化_循环智能_InfoQ写作社区](https://xie.infoq.cn/article/9f325fb7ddc5d12362f4c88a8)
- [Clickhouse的数据存储原理、二进制文件内容分析与索引详解_clickhouse 数据存储-CSDN博客](https://blog.csdn.net/Urbanears/article/details/129509398)