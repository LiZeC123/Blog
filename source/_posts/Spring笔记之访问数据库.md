---
title: Spring笔记之访问数据库
date: 2019-01-13 14:16:38
categories: Spring笔记
tags:
    - Spring
    - 数据库
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->

本文介绍Spring框架中与数据库操作相关的内容, 主要包括数据库连接池以及MyBatis的基本知识. 在本文的前半部分, 假定已经按照之前的文章[Spring笔记之Spring Web](http://lizec.top/2018/12/23/Spring%E7%AC%94%E8%AE%B0%E4%B9%8BSpringWeb/)完成了基础的配置, 本文将此基础上介绍Spring框架下的数据库配置方法.

在本文的后半部分, 将会介绍Spring Boot环境中如何进行同样的配置. 最后, 本文还将介绍一些可以帮助我们简化MyBatis配置和数据库访问的第三方库.

配置连接池
--------------------

首先导入必要的依赖

``` xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.13</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.apache.commons/commons-dbcp2 -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-dbcp2</artifactId>
    <version>2.5.0</version>
</dependency>
```

然后在DAOConfig中配置如下的Bean

``` java
@Bean(destroyMethod="close")
public BasicDataSource dataSource() {
    BasicDataSource dataSource = new BasicDataSource();
    dataSource.setUsername(username);
    dataSource.setPassword(password);
    dataSource.setUrl(url);
    dataSource.setDriverClassName(driverClassName);
    dataSource.setMaxIdle(maxIdle);
    return dataSource;
}
```

BasicDataSource是DataSource的一个实现, 实现了完整的连接池功能. 上述配置信息(用户名,密码等)可以通过Spring的常量注入方式进行注入, 也可以直接作为Java代码中的常量直接引用.

这里将BasicDataSource声明为一个Bean, 因此后续任何需要使用功能数据库的地方, 都可以通过向Spring声明, 从而将这个Bean注入其中, 从而保证所有的数据库访问都统一的通过连接池管理.

配置MyBatis
-------------------------

### 导入依赖

``` xml
<!-- https://mvnrepository.com/artifact/org.mybatis/mybatis-spring -->
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis-spring</artifactId>
    <version>1.3.1</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.mybatis/mybatis -->
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.4.1</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.springframework/spring-orm -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-orm</artifactId>
    <version>5.1.1.RELEASE</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.springframework.data/spring-data-commons -->
<dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-commons</artifactId>
    <version>2.1.1.RELEASE</version>
</dependency>
```

同时导入以上四个模块才能保证@MapperScan等注解的正常使用. 之后在DAOConfig中配置SqlSessionFactoryBean和@MapperScan注解. 需要注意相关的模块直接版本号的问题, 如果没有特别的需求, 就尽量都使用最新版.

### 配置Config

``` java
@Configuration
@MapperScan("top.lizec.mapper")
@PropertySource("classpath:database.properties")
public class DAOConfig {
    // 省略数据库参数的注入代码
    @Bean(destroyMethod="close")
    public BasicDataSource dataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        dataSource.setUrl(url);
        dataSource.setDriverClassName(driverClassName);
        dataSource.setMaxIdle(maxIdle);
        return dataSource;
    }

    @Bean // SqlSessionFactoryBean 是mybatis的类,从而连接dbcp的连接池
    public SqlSessionFactoryBean sqlSessionFactory(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean sessionFactoryBean = new org.mybatis.spring.SqlSessionFactoryBean();
        sessionFactoryBean.setDataSource(dataSource);
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        //指定mybatis的xml文件路径, 匹配mapper目录下任意位置的文件
        sessionFactoryBean.setMapperLocations(
                resolver.getResources("classpath:/mapper/**/*.xml"));
        sessionFactoryBean.setTypeAliasesPackage("top.lizec.entity");
        return  sessionFactoryBean;
    }

}
```

以上代码有如下的几个要点
1. 使用@MapperScan指定需要扫描的mapper类位置
2. 通过注入包含连接池的DataSource, 使得MyBatis的连接也被连接池管理
3. 通过setMapperLocations方法指定MyBatis配置文件的位置
4. 使用setTypeAliasesPackage方法指定xml文件的类别名

### 配置XML文件

MyBatis通过XML文件完成相关操作的配置. 首先可以创建一个mapper包, 其中专门放置进行数据映射的接口类. 由于具体的方法由MyBatis实现, 因此只需要对相关的方法进行声明即可, 例如

``` java
package top.lizec.mapper;

import org.springframework.stereotype.Repository;
import top.lizec.entity.GasMeter;
import java.util.List;

@Repository
public interface GasMeterMapper extends AbstractMapper<GasMeter>{
    GasMeter getGasMeterById(String meterId);
    List<GasMeter> getGasMeterList();
}
```

其中AbstractMapper<GasMeter>也是一个自定义的类, 其中包含了对GasMeter的基本增删改操作, 代码如下

``` java
public interface AbstractMapper<T> {
    void insert(T t);
    int update(T t);
    int delete(T t);
}
```

接下来创建对应的XML文件, 内容如下

``` xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="top.lizec.mapper.GasMeterMapper">
    <!--通过代码指定类别名, 从而不用写全路径,且类名变为小写-->
    <!--gasMeter就是top.lizec.entity.GasMeter-->
    <resultMap id="gasMeterResultMap" type="gasMeter">
        <id property="meterId" column="meter_id" />
        <result property="type" column="type" />
        <result property="orientation" column="orientation"/>
        <result property="batch" column="batch" />
        <result property="producedDate" column="produced_date"/>
    </resultMap>

    <insert id="insert" parameterType="gasMeter">
        INSERT INTO gas_meter(meter_id, type, orientation, batch, produced_date)
        VALUES (#{meterId},#{type},#{orientation},#{batch},#{producedDate});
    </insert>

    <update id="update" parameterType="gasMeter">
        UPDATE gas_meter
        <set>
            <if test="meterId!=null">meter_id=#{meterId},</if>
            <if test="type!=null">type=#{type},</if>
            <if test="orientation!=null">orientation=#{orientation},</if>
            <if test="batch!=null">batch=#{batch},</if>
            <if test="producedDate!=null">produced_date=#{producedDate}</if>
        </set>
        WHERE meter_id = #{meterId};
    </update>

    <delete id="delete" parameterType="gasMeter">
        DELETE FROM gas_meter
        WHERE meter_id = #{meterId}
    </delete>

    <select id="getGasMeterById" resultMap="gasMeterResultMap" parameterType="java.lang.String" >
        SELECT * FROM gas_meter WHERE meter_id = #{meterId}
    </select>
    
    <select id="getGasMeterList" resultMap="gasMeterResultMap" >
        SELECT * FROM gas_meter ORDER BY produced_date ASC;
    </select>
</mapper>
```

开头4行的内容总是一样的, 从第5行开始, namespace指定了这个XML文件与之对应的Java类, resultMap定义了数据库中的属性名和Java类的属性名直接的对应关系. 接下来的各种语句实现了各种增删改查操作, 具体语法不再详细介绍, 可以参考官方文档
- [XML 映射配置文件](http://www.mybatis.org/mybatis-3/zh/configuration.html)


Spring Boot模式
----------------

Spring Boot的Spring的很多配置进行了封装, 节省了很多的工作量, 引入数据库连接池和MyBatis只需要导入如下的依赖

``` xml
<!-- mybatis -->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>1.3.2</version>
</dependency>
<!-- 数据源 -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.1.10</version>
</dependency>
```

和各种starter一样, `mybatis-spring-boot-starter`提供了需要的全部依赖和相关的默认配置. 由于不需要编写任何的XML文件, 因此只需要在启动类加上`@MapperScan`注解即可完成MyBatis的配置. `druid`是alibaba创建了一种数据库连接池, 在配置文件中进行如下的配置

``` yml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/document?serverTimezone=UTC&allowMultiQueries=true
    username: root
    password: 123456
    type: com.alibaba.druid.pool.DruidDataSource
```

上述配置中的大部分字段的含义都是显然的, 其中`spring.datasource.type`属性用于指定数据库连接池的类型, 这里指定的就是之前导入的`druid`. 

根据日志给出的提示, 数据库驱动类会自动加载, 因此不需要手动配置`driver-class-name`属性. `mysql-connector-java`依赖的配置和前面介绍的过程一致, 此处不再赘述.


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

