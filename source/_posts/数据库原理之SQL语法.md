---
title: 数据库原理之SQL语法
date: 2018-07-21 10:59:04
categories: 计算机核心课程
tags:
    - SQL
    - 数据库
cover_picture: images/sql.jpg
---


由于日常开发过程中不经常使用SQL, 对于其中的一些高级语法比较容易遗忘. 因此本文简要介绍了SQL的各种语法, 用于快速回顾有关的知识.


模式
-----------------------

操作    | 指令
--------|---------------------
定义    | `CREATE SCHEMA "S-T" AUTHORIZATION WANG`
删除    | `DROP SCHEMA <模式名> <CASCADE|RESTRICT>`

### 几点说明
- 模式是一系列表的集合, 数据库是一系列模式的集合
- 在MySQL中并不区分模式和数据库（Schema和Database）
- 在SQL Server中每个数据库默认创建dbo模式, 并且将其作为默认模式
- 实际上可以把一个模式视为一个数据库的一部分表的集合


表操作
----------------
### 创建表
``` sql
CREATE TABLE <表名> 
(
	<列名> <数据类型> [列完整性约束条件]
	[, <列名> <数据类型> [列完整性约束条件]]
	...
	[, <表完整性约束>]
) [表附加属性];

列完整性约束条件 => PRIMARY KEY | NOT NULL | UNIQUE
列完整性约束条件 => DEFAULT <默认值> | COMMENT <列说明>

表完整性约束条件 => PRIMARY KEY(<列名1> [,<列名2>]...[,<列名n>])
表完整性约束条件 => FOREIGN KEY(<列名>) REFERENCES <表名>(<列名>)
表完整性约束条件 => [UNIQUE] INDEX <索引名> (<列名1> [,<列名2>]...[,<列名n>]) [USING <索引类型>]

表附加属性 => ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT ''
```

完整的数据类型表请查看本文末尾的[附录A 数据类型](#附录A-数据类型), 数据类型选择应该遵守: 选择不超过范围的最小数据类型, 尽量使用简单类型, 避免使用NULL, 尤其索引列.关于更高级的约束条件设置方法, 可以查看本文的[完整性约束](#完整性约束)章节. 

对于时间类型的字段, 可以使用`DEFAULT CURRENT_TIMESTAMP`将该字段的默认值设置为当前时间.

对于索引, 默认情况下相当于使用了`USING BTREE`. 每个索引的列还可以执行索引的顺序, 例如递增或者递减.

对于表附加属性, 可以指定引擎类型和编码集. 通常使用默认值即可, 但出于兼容性考虑, 也可以明确的指定为`InnoDB`和`utf8mb4`


### 修改表

```sql
ALTER TABLE <TableName>
[ADD [COLUMN] <newColName> <datType> [ColIntegrity]]
[ADD <TabIntegrity>]
[DROP [COLUMN] <ColName> [CASCADE|RESTRICT]]
[DROP CONSTRAINT <Integrity> [RESTRICT|CASCADE]]
```


### 删除表

```
DROP TABLE <TableName> [RESTRICT|CASCADE]
```


完整性约束
-------------------

### 用户自定义约束
可以使用Check关键字来检测一个属性是否位于某个集合之中, 例如

``` sql
CREATE TABLE St
(
    Sname CHAR(8) NOT NULL,
    Ssex CHAR(2) CHECK(Ssex IN ('男','女')), 
    Grade SMALLINT CHECK(Grade >=0 AND Grade <= 100),
    CHECK(Ssex='女' OR Sname NOT LIKE 'Ms.%')
)
```



#### 创建命名约束

```sql
CREATE TABLE Student
(
    Sno NUMBERIC(6)
        CONSTRAINT C1 CHECK(Sno BETWEEN 90000 AND 99999), 
    Sname CHAR(20)
        CONSTRAINT C2 NOT NULL, 
    Sage NUMERIC(3)
        CONSTRAINT C3 CHECK(Sage < 30), 
    Ssex CHAR(2)
        CONSTRAINT C4 CHECK(Ssex IN ('男', '女')), 
        CONSTRAINT StudentKey PRIMARY KEY(Sno)
)
```

### 修改约束条件

```sql
ALTER TABLE Student
    DROP CONSTRAINT C1;
ALTER TABLE Student
    ADD CONSTRAINT C1 CHECK(Sno BETWEEN 900000 AND 999999)
```



查询
---------

### 单表查询

```sql
SELECT [ALL|DISTINCT] <目标列表达式> [, <目标列表达式>] ...
FROM <表名 | 视图名> [, <表名 | 视图名>]
[WHERE <条件表达式>]
[GROUP BY <列名> [HAVING <条件表达式>]]
[ORDER BY <列名> [ASC|DESC]]
```


目标表达式除了使用属性列以外, 还可以使用表达式, 例如

```sql
SELECT Sname,2018-Sage BIRTHDAY FROM Student;
```

上面的语句通过2018-Sage计算了实际的年龄, 并且将该列命名为BIRTHDAY. 


HAVING语句用于给GROUP BY的分组设置条件, 例如

```sql
SELECT Sno,AVG(Grade) FROM SC GROUP BY Sno HAVING AVG(Grade)>=90;
```

### 连接查询

```sql
SELECT *
FORM <TabName1> <JoinKeyWord> <TabName2>
ON <ConditionExpr>

JoinKeyWord ==> JOIN | LEFT OUTER JOIN | RIGHT OUTER JOIN | FULL OUTER JOIN
```

例如:

```sql
SELECT Student.Sno, Sname, Ssex, Sage, Sdept, Cno, Grade
FROM  Student LEFT OUT JOIN SC 
ON (Student.Sno=SC.Sno); 
```

说明:
1. JOIN等价于 ENTER JOIN 表示普通连接, 会去除所有的空行
2. LEFT OUTER JOIN 表示左外连接, 左边的表中的项一定会出现
3. RIGHT OUTER JOIN 表示右外连接, 右边的表中的项一定为出现
4. FULL OUTER JOIN 表示全连接, 左右的表中项都会出现


### 嵌套查询

```sql
SELECT Sname FROM Student
WHERE Sno IN
(
    SELECT Sno FROM SC
    WHERE Cno='2';
)
```


更新
--------------

### 插入元组

```sql
INSERT INTO <TableName> [(<ColName_1> [, <ColName_2>]...)]
VALUE (<Data1>, [<Data2>] ...);
```

注意:
1. 字符串需要使用单引号括起来
2. 非字符类型的数据也可以使用单引号包括

### 修改元组

```sql
UPDATE <TableName>
SET <ColName> = <Expr> [, <ColName> = <Expr>]
[WHERE <ConditionExpr>]
```

可以同时更新多个表, 例如

``` sql
UPDATE message m, lib ml
SET m.M_ID = ml.M_ID, m.TYPE = ml.TYPE
WHERE m.LIB_ID = ml.LIB_ID;
```

### 删除元组

```sql
DELETE FROM <TableName>
[WHERE <conditionExpr>]
```

索引
----------------

### 建立索引

```sql
CREATE [UNIQUE] [CLUSTER] INDEX <IndexName>
ON <TableName>(<ColName> [Order] [, <ColName> [Order]])

Order => ASC | DESC
```

注意:
1. 上述索引中, 可以选择每个索引是对应唯一值还是聚簇索引
2. 每个列名后可跟随一个排序表示

### 修改索引

```sql
ALTER INDEX <OldIndexName> RENAME TO <NewIndexName>
```

### 删除索引

```sql
DROP INDEX <IndexName>
```


视图
---------------

### 建立视图

```sql
CREATE VIEW <ViewName> [(<ColName> [, <ColName>] ... )]
AS <SubSelect>
[WITH CHECK OPTION]
```

注意:
1. 可以全部省略列名, 表示由子查询语句指定
2. WITH CHECK OPTION表示对视图的更新操作需要保证满足子查询的条件表达式

### 删除视图

```sql
DROP VIEW <ViewName> [CASCADE]
```

### 更新视图
- 更新视图与更新表没有语法差异
- 但是有些视图操作是不可逆的, 此时不能进行更新操作(例如使用了聚集函数)


事务
---------------

对于MySQL数据库, 不同的设置下有不同的效果
- 如果autocommit=0, 只有用户手动COMMIT以后, 数据才会写入磁盘
- 如果autocommit=1, 则有两种情况
    - 如果用户执行`START TRANSACTION;`, 则用户手动提交才会写入磁盘, 否则自动回滚
    - 如果用户直接执行语句, 则每个语句都视为一个独立的事务

-------------

使用以下指令进行事务相关的操作.

操作        | 指令
-----------|-----------------------
开始事务    | START TRANSACTION;
提交        | COMMIT;
回滚        | ROLLBACK;

上面的每条执行都是单独执行的, 开始事务以后,  可以执行任意SQL语句, 更新数据库可以接着执行查询语句来检查效果. 在用户手动提交以前, 其他事务都不可见当前的更新.

注意: **只能回滚数据的修改, 不能回滚结构的修改**.

- [mysql事务的开启](https://www.cnblogs.com/Renyi-Fan/p/8547306.html)


权限控制
-----------------

### 授予权限

```sql
GRANT <权限> [, <权限>] ...
ON <对象类型> <对象名> [, <对象类型> <对象名>]
TO <用户> [, <用户>]
[WITH GRANT OPTION]
```

例如：

```sql
GRANT UPDATE(Sno), SELECT
ON TABLE Student
TO PUBLIC
```

说明：
1. WITH GRANT OPTION 表示被授权用户可以再次将权限授予其他用户
2. 不允许循环授权

### 收回权限

```sql
REVOKE <权限> [, <权限>] ...
ON <对象类型> <对象名> [, <对象类型> <对象名>]
FROM <用户> [, <用户>]
[CASCADE|RESTRICT]
```

角色控制
-----------

### 创建角色

```sql
CREATE ROLE <RoleName>
```

### 角色授权

```sql
GRANT <权限> [, <权限>] ...
ON <对象类型> <对象名> [, <对象类型> <对象名>]
TO <角色> [, <角色名>]
```

### 用户角色授权

```
GRANT <角色1> [, <角色2>] ...
TO <角色3> [, <用户1>] ...
[WITH ADMIN OPTION]
```

说明：
1. 角色可以授予给某个用户或者其他角色
2. WITH ADMIN OPTION表示被授权者可以再次授予自己的权限

### 角色权限的收回

```sql
REVOKE <权限> [, <权限>] ...
ON <对象类型> <对象名> [, <对象类型> <对象名>]
FROM <角色> [, <角色名>]
```

断言
-----------------

### 创建断言

``` sql
CREATE ASSERTION <断言名> <CHECK子句>
```

例如

``` sql
CREATE ASSERTION ASSE_SC_DB_NUM
CHECK (60 >= 
        (
            SELECT COUNT(*) FROM Course,SC
            WHERE SC.CNO = Course.CNO AND Course.CNAME='数据库'
        )
    )
```

执行上述语句后, 每次插入选课记录后, 都会执行一次CHECK子句中的条件, 如果选课人数超过60人, 就会拒绝执行


### 删除断言

``` sql
DROP ASSERTION <断言名>
```

附录A 数据类型
---------------------

数据类型             | 含义              | 数据类型             | 含义
--------------------|-------------------|---------------------|----------------------
TINYINT             | 小整数(1字节)      | SMALLINT            | 短整数（2字节）
INT                 | 整数（4字节）      | BIGINT              | 长整数（8字节）
FLOAT(p,d)          | 单精度浮点数       | DOUBLE(p,d)         | 双精度浮点数
DECIMAL(p,d)        | 货币类型           | NUMERIC(p,d)        | 定点数, 

- 两个浮点数类型支持指定数字范围, 但仅影响存储时的舍入操作, 不影响存储精度
- DECIMAL可以用参数指定数据范围是p位整数数字, d位小数数字, 并且提供此范围的精确存储
- 其他数据类型也可以指定一个数字, 但此参数值影响命令行中的显示效果, 不影响实际的存储大小
- 整数数据类型支持有符号数与无符号数(使用UNSIGNED关键字), 相应的存储范围也会变化

> 注意: 对于有精度要求的浮点数, DECIMAL通常是首选


数据类型    | 含义       | 取值范围
-----------|-----------|---------------------------------------------------
DATETIME   | 时间日期   |  '1000-01-01 00:00:00' to '9999-12-31 23:59:59'
DATE       | 仅含日期   |  '1000-01-01' to '9999-12-31'.
TIMESTAMP  | 时间戳     |  截止于北京时间 2038-1-19 11:14:07

> 注意: 输入时间时尽量使用标准格式表示, 以免数据库解析规则不一致导致错误


数据类型            | 含义                 | 数据类型             | 含义
--------------------|---------------------|---------------------|-----------------------
CHAR(n)             | 长度为n的定长字符串   | VARCHAR(n)          | 最大长度为n的变长字符串
TEXT                | 字符串大对象          | BLOB                | 二进制大对象         

CHAR和VARCHAR的参数表示存储的**字符**数量, 每个字符具体需要几个**字节**取决于实际的编码. 而CHAR最多存储 256 Byte 数据, VARCHAT最多存储 65536 Byte 数据.

> 由于UTF-8是不定长编码, 因此CHAR类型为了保证能够存储指定数量的字符, 会将字符集中需要的最大字节长度作为一个字符的长度.

> UTF-8中一个汉字一般需要三个字节, 而GBK编码中, 一个汉字仅需要两个字节.

--------------

TEXT和BLOB都有四种类型, 以TEXT为例, 分别是TINYTEXT, TEXT, MEDIUMTEXT和LONGTEXT. TEXT和BLOB的四种类型的存储范围是一致的, 其存储范围分别用1字节, 2字节, 3字节和4字节无符号整数表示.

两种类型的区别是TEXT用于存储文本, 存在编码的问题, 而BLOB用于存储二进制数据, 直接将数据作为二进制串进行存储.

---------------------

关于MySQL中的数据类型, 可以参考下面的几篇文章. 第一篇文章对相关数据类型进行了详细的测试. 第二篇和第三篇都是偏向官方文档的表格式描述. 第四篇是官方文档, 对数据的存储细节进行了详细的介绍.

- [详解MySQL数据类型](https://www.cnblogs.com/xrq730/p/8446246.html)
- [MySQL 数据类型](https://www.runoob.com/mysql/mysql-data-types.html)
- [MySQL Data Types](https://www.w3resource.com/mysql/mysql-data-types.php)
- [MySQL官方文档 - String Type Storage Requirements](https://dev.mysql.com/doc/refman/8.0/en/storage-requirements.html#data-types-storage-reqs-innodb)



附录B 聚合函数
----------------------

函数            | 含义                | 函数            | 含义
-----------------|--------------------|-----------------|--------------------
`COUNT(*)`       | 统计元组数量        | `COUNT(<列名>)`  | 统计指定列包含元素的数量
`SUM(<列名>)`    | 统计列的总和        | `AVG(<列名>)`    | 统计平均值
`MAX(<列名>)`    | 统计最大值          | `MIN(<列名>)`    | 统计最小值


说明：
1. 各种聚合函数都可以在列名前指定DISTINCT或ALL（默认值）, 来指定是否计算重复值


附录C 查询条件
------------------------------

查询条件    | 谓词                          | 查询条件    | 谓词
-----------|-------------------------------|------------|--------------------------
比较        | =, >, <, != 等常见数学运行符号 | 字符匹配    | LIKE, NOT LIKE
范围        | BETWEEN AND, NOT BETWEEN AND | 空值        | IS NULL, IS NOT NULL
集合        | IN, NOT IN                   | 逻辑        | AND, OR, NOT



附录D 集合操作
-------------------

操作名       |  含义
------------|----------------------
UNION       | 并
INTERSECT   | 交
EXCEPT      | 差


附录E 包含操作
----------------------
1. 原理
```
A Contain B = (B - A) 为空集
            = NOT EXIST (B EXCEPT A)
```
2. 举例应用
	- 查询至少选修了学生2002122选修的全部课程的学生号码
	- 即 求所有学生S: (S选修课程) Contains (学生2002122选修的所有课程)
	- 即 NOT EXISTS (学生2002122选修的所有课程 EXCEPT S选修课程)

```sql
SELECT DISTINCT sno
FROM sc A
WHERE NOT EXISTS
(
    (
        SELECT cno FROM sc
        WHERE sno = '2002122'
    )
    EXCEPT
    (
        SELECT cno
        FROM SC B
        WHERE A.sno = B.sno
    )
)
```
