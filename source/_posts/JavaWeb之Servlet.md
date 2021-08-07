---
title: JavaWeb之Servlet
date: 2018-11-21 20:52:04
categories: JavaWeb
tags:
    - Java
    - 数据库
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->





Java Web连接池配置
---------------------------

以连接本地数据库中的`api`库为例, 配置如下所示: 

``` xml
<Context>
    <Resource name="jdbc/mysql"
             type="javax.sql.DataSource"
             auth="Container"
             driverClassName="com.mysql.jdbc.Driver"
             url="jdbc:mysql://localhost:3306/api?serverTimezone=UTC"
             username="root"
             password="123456"
             maxActive="4"
             maxIdle="2"
             maxWait="6000"/>
</Context>
```

连接数据库时, 可能会提示`com.mysql.jdbc.Driver` 已经过时, 按照提示换成新的驱动类即可. 


连接数据库时注意指定`serverTimezone=UTC` 否则可能无法连接数据库. 更多关于时区的问题可以参考[如何规避mysql的url时区的陷阱](https://www.jianshu.com/p/7e9247c0b81a)
