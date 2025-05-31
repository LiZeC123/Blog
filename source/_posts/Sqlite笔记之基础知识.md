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

| **指令**        | **参数说明**            | **功能描述**         | **使用示例**                  |
| --------------- | ----------------------- | -------------------- | ----------------------------- |
| `.tables`       | [?PATTERN]              | 显示匹配表名         | `.tables 'user%'`             |
| `.schema`       | [?TABLE]                | 显示建表语句         | `.schema users`               |
| `.headers`      | `on`/`off`              | 显示列标题           | `.headers on`                 |
| `.mode`         | `csv`/`json`/`column`等 | 设置输出格式         | `.mode json`                  |
| `.dump`         | [?TABLE]                | 导出SQL格式数据      | `.dump orders`                |
| `.import`       | `FILE` `TABLE`          | 导入CSV数据到表      | `.import data.csv temp_table` |
| `.output`       | `[FILENAME]`            | 重定向输出到文件     | `.output backup.sql`          |
| `.read`         | `FILENAME`              | 执行SQL脚本文件      | `.read init.sql`              |
| `.quit`/`.exit` | 无                      | 退出命令行           | `.exit`                       |
| `.databases`    | 无                      | 显示所有附加数据库   | `.databases`                  |
| `.indexes`      | [?TABLE]                | 显示表的索引         | `.indexes users`              |
| `.nullvalue`    | `STRING`                | 设置NULL的显示占位符 | `.nullvalue NULL`             |
| `.timer`        | `on`/`off`              | 显示查询执行时间     | `.timer on`                   |
| `.stats`        | `on`/`off`              | 显示性能统计信息     | `.stats on`                   |
| `.width`        | `NUM1 NUM2...`          | 设置列显示宽度       | `.width 10 15 20`             |

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
