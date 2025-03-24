---
title: Sqlite笔记之基础知识
math: false
date: 2025-03-23 22:12:02
categories:
tags:
    - SQL
    - 数据库
    - Sqlite
cover_picture: images/sqlite.jpg
---

SQLite作为轻量级嵌入式数据库，凭借其零配置、无服务端的特性，成为移动端和小型项目的首选


数据表创建与管理
--------------------

### 基础建表语句
```sql
-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    age INTEGER CHECK(age >= 18),
    email TEXT DEFAULT 'unknown@domain.com',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```
**关键要素解析**：
• `PRIMARY KEY AUTOINCREMENT` 自增主键
• `NOT NULL` 非空约束
• `UNIQUE` 唯一性约束
• `CHECK` 数据验证规则
• `DEFAULT` 默认值设置

### 数据类型详解

| 类型    | 存储格式   | 典型用途          |
| ------- | ---------- | ----------------- |
| INTEGER | 整型数字   | ID、年龄、状态码  |
| REAL    | 浮点数     | 价格、地理坐标    |
| TEXT    | UTF字符串  | 名称、描述信息    |
| BLOB    | 二进制数据 | 图片、加密信息    |
| NUMERIC | 特殊数值   | 日期/时间、布尔值 |

> **类型亲和性**：SQLite采用动态类型系统，建议显式声明类型以获得更好的优化效果



内置指令
-----------

| **指令**      | **参数说明**            | **功能描述**         | **使用示例**                  |
| ------------- | ----------------------- | -------------------- | ----------------------------- |
| `.tables`     | [?PATTERN]              | 显示匹配表名         | `.tables 'user%'`             |
| `.schema`     | [?TABLE]                | 显示建表语句         | `.schema users`               |
| `.headers`    | `on`/`off`              | 显示列标题           | `.headers on`                 |
| `.mode`       | `csv`/`json`/`column`等 | 设置输出格式         | `.mode json`                  |
| `.dump`       | [?TABLE]                | 导出SQL格式数据      | `.dump orders`                |
| `.import`     | `FILE` `TABLE`          | 导入CSV数据到表      | `.import data.csv temp_table` |
| `.output`     | `[FILENAME]`            | 重定向输出到文件     | `.output backup.sql`          |
| `.read`       | `FILENAME`              | 执行SQL脚本文件      | `.read init.sql`              |
| `.quit`/.exit | 无                      | 退出命令行           | `.exit`                       |
| `.databases`  | 无                      | 显示所有附加数据库   | `.databases`                  |
| `.indexes`    | [?TABLE]                | 显示表的索引         | `.indexes users`              |
| `.nullvalue`  | `STRING`                | 设置NULL的显示占位符 | `.nullvalue NULL`             |
| `.timer`      | `on`/`off`              | 显示查询执行时间     | `.timer on`                   |
| `.stats`      | `on`/`off`              | 显示性能统计信息     | `.stats on`                   |
| `.width`      | `NUM1 NUM2...`          | 设置列显示宽度       | `.width 10 15 20`             |

---

常用场景

| **场景**       | **指令组合**                                                                 |
| -------------- | ---------------------------------------------------------------------------- |
| 可读方式输出   | `.head on` <br> `.mode column`                                               |
| 导出CSV数据    | `.headers on`<br>`.mode csv`<br>`.output data.csv`<br>`SELECT * FROM table;` |
| 快速备份数据库 | `.output backup.sql`<br>`.dump`                                              |
| 查看表结构详情 | `.schema 表名`<br>`.indexes 表名`                                            |
| 性能调试       | `.timer on`<br>`.stats on`                                                   |
| 模糊查询表结构 | `.tables '%log%'`<br>`.schema '%log%'`                                       |



嗯，用户问到SQLite底层是否是单线程执行的，需要介绍一下它的底层模型。首先，我需要回忆一下SQLite的架构设计。记得SQLite是一个嵌入式数据库，设计初衷是为了轻量级和高效，所以在并发处理上有一些独特的设计。

用户可能之前已经了解了SQLite的基本操作和常用指令，现在想深入理解其内部机制，特别是并发处理方面。他们可能在使用SQLite时遇到了性能问题，或者对数据库的并发控制机制感到好奇。需要解释清楚SQLite的锁机制和线程模型，以及如何在实际应用中优化性能。

首先，SQLite确实在某个层面上是单线程的，但具体来说，它的锁机制允许多个读操作同时进行，而写操作是独占的。这涉及到不同的锁状态，比如共享锁和保留锁。需要详细说明这些锁的状态转换，以及它们如何影响并发访问。

然后，关于线程安全的问题，SQLite提供了不同的编译选项，比如单线程模式、多线程模式和串行化模式。用户可能想知道在不同的配置下，SQLite的表现有何不同，以及如何根据应用需求选择合适的模式。

另外，用户可能对WAL（Write-Ahead Logging）模式感兴趣，因为这是提高SQLite并发性能的一个重要特性。需要解释WAL的工作原理，以及它如何减少写操作的锁竞争，从而提升多线程读写的效率。

还要提到事务处理，特别是BEGIN IMMEDIATE和BEGIN EXCLUSIVE的区别，这些事务类型如何影响并发性能。用户可能需要在实际开发中选择合适的事务类型来平衡数据一致性和性能。

最后，需要给出一些实际的建议，比如在高并发场景下如何配置SQLite，或者推荐使用WAL模式来优化性能。这些建议可以帮助用户更好地应用SQLite，避免常见的并发问题。

在回答时，要确保技术细节准确，同时用通俗易懂的语言解释复杂概念，避免过于晦涩。可能需要用一些比喻或示例来说明锁机制和线程模型，帮助用户更好地理解。同时，注意结构清晰，分点阐述，让用户能够快速抓住重点。



线程模型
----------

SQLite 的并发模型常被误解为「单线程执行」，实际上其采用**多线程访问+单写者锁**的机制。我们通过底层架构拆解其真实工作方式：


### 核心锁机制

SQLite 采用**文件锁**实现并发控制，包含5种锁状态升级路径：

| 锁状态        | 共享读 | 保留锁 | 未决锁 | 排他锁 | 描述                     |
| ------------- | ------ | ------ | ------ | ------ | ------------------------ |
| **UNLOCKED**  | ✔️      | ❌      | ❌      | ❌      | 初始状态，无锁           |
| **SHARED**    | ✔️      | ❌      | ❌      | ❌      | 允许其他读，禁止写       |
| **RESERVED**  | ✔️      | ✔️      | ❌      | ❌      | 准备写入，阻止其他保留锁 |
| **PENDING**   | ❌      | ✔️      | ✔️      | ❌      | 等待现有读完成           |
| **EXCLUSIVE** | ❌      | ❌      | ❌      | ✔️      | 独占写入状态             |

**关键特性**：
• **读并行**：多个连接可同时处于 SHARED 状态
• **写串行**：同一时刻仅允许一个写操作（EXCLUSIVE 锁）
• **写优先**：RESERVED 锁阻止新读连接进入


### 线程安全模式

通过编译时选项控制线程模型：

| 模式           | 线程安全等级                     | 适用场景                            |
| -------------- | -------------------------------- | ----------------------------------- |
| **单线程模式** | 完全无锁, 各个线程不能共享模块   | 嵌入式设备（关闭线程安全）          |
| **多线程模式** | 线程可以共享模块，但不能共享连接 | 默认配置（`SQLITE_THREADSAFE=1`）   |
| **串行化模式** | 线程可以共享模块、连接和游标     | 高并发需求（`SQLITE_THREADSAFE=2`） |

```py
import sqlite3
# 打印线程模式
print("SQLite连接的线程模式：", sqlite3.threadsafety)
```

> 当前Python中默认的线程模型是串行化模式, 即完全线程安全模式. 可参考[官方文档](https://docs.python.org/zh-cn/3.13/library/sqlite3.html#sqlite3.threadsafety)


### WAL模式优化

**Write-Ahead Logging (预写日志)** 大幅提升并发性能：

1. **原理差异**：
   • 传统模式：直接修改数据库文件
   • WAL模式：先写日志文件（-wal），后批量合并

2. **并发提升**：
   ```text
   传统模式：读↔写互斥，写↔写互斥
   WAL模式：读↔写可并行，写↔写仍互斥
   ```

3. **启用方式**：
   ```sql
   PRAGMA journal_mode = WAL;  -- 启用WAL
   PRAGMA synchronous = NORMAL;-- 平衡性能与安全
   ```


### 事务类型与并发控制

不同事务类型影响锁行为：

| 事务类型            | 锁获取时机           | 并发性能 | 使用场景       |
| ------------------- | -------------------- | -------- | -------------- |
| **DEFERRED (默认)** | 首次访问数据时       | 高       | 只读事务       |
| **IMMEDIATE**       | 开始事务即获取保留锁 | 中       | 明确需要写操作 |
| **EXCLUSIVE**       | 开始事务即获取排他锁 | 低       | 需要独占数据库 |

**事务示例**：
```sql
BEGIN IMMEDIATE;  -- 提前声明写意图
UPDATE accounts SET balance = balance - 100;
COMMIT;
```


### 性能优化实践

1. **缩短事务时间**：
   • 避免在事务中执行耗时操作（如文件IO）
   • 批量写入使用单一事务

2. **连接池配置**：
   ```python
   # Python示例：限制最大连接数
   from sqlite3 import connect
   import threading

   connection_pool = threading.BoundedSemaphore(5)  # 最大5连接
   ```

3. **监控锁竞争**：
   ```sql
   SELECT * FROM sqlite_stat1 WHERE tbl = '锁状态表';
   ```
