---
title: MySQL笔记之基本配置
date: 2021-01-20 17:12:54
categories: MySQL笔记
tags:
    - MySQL
    - 数据库
cover_picture: images/mysql.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


最近打算给服务器端的MySQL配置一个只读远程的远程账号, 找了一圈居然没有一篇博客能完整解决这个问题, 所以这篇博客会记录MySQL的一些常见需求的操作方法.


创建账号
------------------------

创建账号的语句非常简单, 执行如下的SQL语句, 即可创建名为`lizec`的用户.

```sql
CREATE USER lizec;
```


授予权限
------------------------

### 授权基本格式

授权语句的格式如下

``` sql
GRANT <methods> ON <databaseName>.<tableName> TO "<username>"@"%" IDENTIFIED BY '<password>' WITH GRANT OPTION;
```

其中`<username>`和`<password>`分别表示需要授权的账号和密码, 使用相应的值替换即可.  

`<databaseName>`和`<tableName>`表示需要授权的数据库和表的名字, 例如`test.*`表示授予test数据库下所有表的权限, 而`*.*`表示授予所有数据库的所有表的权限.

`<methods>`表示授予用于允许的操作, 可选值为`all privileges`, `select`, `delete`, `update`, `create`, `drop`. 这些取值对应了相关的SQL操作.


### 授权举例

下面用几个例子解释授权语句

1. 授予所有权限

```sql
GRANT all privileges ON *.* TO "user"@"%" IDENTIFIED BY '123456' WITH GRANT OPTION;
```

上述语句对用户名为`user`, 密码为`123456`的用户在所有的数据库上授予了所有的权限.

2. 授予只读权限

```sql
GRANT select ON test1.* TO "user"@"%" IDENTIFIED BY '123456' WITH GRANT OPTION;
```

上述语句对用户名为`user`, 密码为`123456`的用户在`test1`数据库上授予了`SELECT`权限, 因此该用户只能在此数据库上执行`SELECT`操作

### 参考文献

- [MySQL中授权(grant)和撤销授权(revoke)](https://blog.csdn.net/Andy_YF/article/details/7487519)


MySQL允许远程登录
-------------------------


### 1. 修改监听地址

首先打开MySQL的配置文件`/etc/mysql/mysql.conf.d/mysqld.cnf`, 找到如下的段落

```conf
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
bind-address      = 127.0.0.1
```

其中的`bind-address`决定了MySQL服务的监听IP地址, 按照上面的配置, 仅允许本地的IP地址连接MYSQL. 可以将这一行注释掉, 或者改为`0.0.0.0`使所有的IP地址都能访问MySQL.

### 2. 设置防火墙

这一步非常关键, 如果设置了防火墙, 需要将MySQL的3306端口放行, 否则无法访问MySQL.

### 参考资料

- [How To Allow Remote Connections To MySQL](https://phoenixnap.com/kb/mysql-remote-connection)


