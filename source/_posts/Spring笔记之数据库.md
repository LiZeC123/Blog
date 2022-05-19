---
title: Spring笔记之数据库
date: 2021-09-01 16:07:23
categories: Spring笔记
tags:
    - Spring
    - 数据库
cover_picture: images/spring.jpg 
---



数据库组件
----------------

为了使Spring能够访问数据库，我们需要导入三个依赖，即数据库驱动`mysql-connector-java`，数据库连接池`druid`和数据库映射工具`mybatis-spring-boot-starter`。

> 为了保证版本的一致性，使用官网工具添加依赖

`mybatis-spring-boot-starter`封装了Mybatis的核心功能并提供了相关的默认配置. 因此只需要在启动类加上`@MapperScan`注解即可完成MyBatis的配置. 在配置文件中加入如下的配置项对数据库连接池进行配置。

``` yml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/document?serverTimezone=UTC&allowMultiQueries=true
    username: root
    password: 123456
    type: com.alibaba.druid.pool.DruidDataSource
```

> 根据日志给出的提示, 数据库驱动类会自动加载, 因此不需要手动配置`driver-class-name`属性. `mysql-connector-java`依赖的配置和前面介绍的过程一致, 此处不再赘述.


MyBatis
--------------

### 查看详细日志

Spring Boot集成了LogBack日志系统, 因此可以直接在配置文件中通过以下配置来调整日志级别, 启动针对Mapper类的详细日志.

```
logging:
  level:
    top.lizec.smartreview.mapper: TRACE
```

这相当于对所以位于`top.lizec.smartreview.mapper`包下的类都开启TRACE级别的日志输出, 从而可以显示详细的SQL语句.


### 使用YML配置


任意在XML中的配置, 都可以在yml文件中直接进行配置, 例如MyBatis的配置文件中如下的内容

```xml
<configuration>
    <settings >
        <setting name="mapUnderscoreToCamelCase" value="true" />
    </settings>
</configuration>
```

就等价于下面的配置文件.

``` yml
mybatis:
  configuration:
    map-underscore-to-camel-case: true
```

基本上所有的属性都可以按照上面的方式进行配置, 从而可以完全避免写XML格式的MyBatis配置文件



TK MyBatis
--------------

### 基本配置

TK MyBatis是一个第三方库, 可以帮助我们简化MyBatis的开发. Tk提供了大量的组件, 通过直接继承这些组件, 再加上少量的配置, 就可以实现大部分的数据库功能.


首先导入依赖
```xml
<dependency>
  <groupId>tk.mybatis</groupId>
  <artifactId>mapper-spring-boot-starter</artifactId>
  <version>版本号</version>
</dependency>
```

接下来, 在启动类上加入扫描的注解

``` java
@tk.mybatis.spring.annotation.MapperScan(basePackages = "扫描包")
@SpringBootApplication
public class SampleApplication  { ... }
```

完成上述配置以后, 就可以创建需要的实体类和Mapper类, 例如
``` java

// User.java
@Data
public class User implements Serializable {

    private static final long serialVersionUID = -3748212043335093479L;
    private Integer id;
    private String name;
    private Integer sex;
}

// mapper.java
@Mapper
public interface UserMapper extends tk.mybatis.mapper.common.Mapper<User> {
}
```

Mapper类不需要任何代码就自动实现了大量的基础功能, 常见的增删改查操作都可以直接调用.


### 扩展方法

如果默认提供的方法不能满足要求, 还可以通过扩展来实现自己的方法. 扩展可以通过注解进行配置, 也可以使用XML文件进行配置. 具体的配置方法可以参考以下的官方文档:

- [2.1 simple](https://github.com/abel533/Mapper/wiki/2.1-simple)

PageHelper
-------------


PageHelper是一个分页插件


- [SSM框架集成PageHelper插件, 实现分页功能](https://blog.csdn.net/fenghuibian/article/details/77986398)
- [pagehelper/Mybatis-PageHelper](https://github.com/pagehelper/Mybatis-PageHelper)



事务隔离与传播机制
---------------------

Sping事务隔离级别和传播机制实际上只是一套规则, 对于这套规则的定义和使用, 我认为以下的三篇文章已经进行了充分的解释. 因此, 本文不需要再补充相关内容.

- [深入理解 Spring 事务原理](http://www.codeceo.com/article/spring-transactions.html)
- [Spring事务隔离级别和传播特性](https://www.cnblogs.com/zhishan/p/3195219.html)
- [【技术干货】Spring事务原理一探](https://zhuanlan.zhihu.com/p/54067384)