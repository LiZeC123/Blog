---
title: Maven笔记之依赖管理
date: 2019-07-09 09:50:02
categories: Maven笔记
tags:
    - Maven
    - Java
cover_picture: images/maven.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍Maven的依赖相关的内容, 包括如何获取依赖, 版本一致性控制等内容.



查询可用的依赖
-------------------

可以在[MavenRepository](https://mvnrepository.com/)搜索可用的依赖库. 此网站提供了每一个可用依赖的基本介绍, 使用量统计, 以及引用依赖的XML代码. 


依赖管理
--------------

### 继承依赖

每一个Maven项目都可以在pom文件中使用`<parent>`标签指定一个父项目, 从而直接继承父项目中定义的依赖和属性. 

``` xml
<parent>
        <groupId>baeldung</groupId>
        <artifactId>Baeldung-BOM</artifactId>
        <version>0.0.1-SNAPSHOT</version>
</parent>
```


### 依赖管理

在父项目中可以创建`<dependencyManagement>`标签, 并在其中声明依赖. 子项目继承父项目后, 获得`<dependencies>`标签声明的依赖, 但不会获得`<dependencyManagement>`标签中声明的依赖. 

子项目必须显式的声明才能够获得这些依赖, 但此时不再需要指定`<version>`和`<scope>`, 而是直接继承父项目中的属性.

通过这样的方法, 可以将必要的依赖配置集中到一个文件之中, 从而能够统一的管理.


### Maven BOM


本节内容来自[Baeldung](https://www.baeldung.com/)的文档[Spring with Maven BOM](https://www.baeldung.com/spring-maven-bom).

BOM是`Bill Of Materials`的缩写, 所谓Maven BOM实际上也是一个普通的pom文件, 此文件用于解决依赖的版本一致性问题. 一个包含`dependencyManagement`标签的pom文件称为BOM文件, 以下是一个示例

``` xml
<project ...>
    <modelVersion>4.0.0</modelVersion>
    <groupId>baeldung</groupId>
    <artifactId>Baeldung-BOM</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>BaelDung-BOM</name>
    <description>parent pom</description>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>test</groupId>
                <artifactId>a</artifactId>
                <version>1.2</version>
            </dependency>
            <dependency>
                <groupId>test</groupId>
                <artifactId>b</artifactId>
                <version>1.0</version>
                <scope>compile</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

有两种使用BOM文件的方法, 第一种是继承父项目

``` xml
<project ...>
    <modelVersion>4.0.0</modelVersion>
    <groupId>baeldung</groupId>
    <artifactId>Test</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>Test</name>
    <parent>
        <groupId>baeldung</groupId>
        <artifactId>Baeldung-BOM</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
</project>
```

由于pom文件是单继承的, 因此无法再其中导入多个BOM, 对于这种情况, 可以考虑使用import方式.

``` xml
<project ...>
    <modelVersion>4.0.0</modelVersion>
    <groupId>baeldung</groupId>
    <artifactId>Test</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>Test</name>
     
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>baeldung</groupId>
                <artifactId>Baeldung-BOM</artifactId>
                <version>0.0.1-SNAPSHOT</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

这里的pom类型和import范围表示将指定的BOM导入此项目. 由于import可以出现任意次, 因此可以导入多个BOM.


版本优先级
----------------

关于一个依赖的版本的选择的优先级由高到低如下确定

1. 直接在当前项目中声明的版本
2. 父项目中声明的版本
3. 导入的BOM文件中声明的版本
4. 版本协调机制


### 版本协调机制

当有两个依赖B和C同时依赖D, 但依赖的D的版本不同的时候, Maven会优先选择离依赖树顶部最近的版本. 例如有如下的两个依赖

``` 
A - B - C - D (1.2)
A - E - D (1.0)
```

上面的依赖关系中, A依赖B和E, B和E最终都依赖D, 由于D(1.0)在依赖树中离A更近, 因此Maven最终会选择D(1.0)



Spring依赖管理
--------------

### Spring Framework BOM
在使用Spring的过程中, 我们多少都有过版本冲突的问题, 如果我们没有明确指定冲突的版本, 很容易产生一些意料之外的错误. 为了克服这种问题, 我们可以导入`spring-framework-bom`

``` xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-framework-bom</artifactId>
            <version>4.3.8.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

导入此文件后, 我们使用Spring依赖时不再需要指定版本, 由BOM文件保证所有的Spring依赖使用同样的版本.

### Spring Boot Starter Parent

如果创建Spring Boot应用, 可以将`spring-boot-starter-parent`作为父项目, 从而基础一些配置和依赖, 实现编译控制, 打包支持, 插件配置等功能. 

``` xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.6.RELEASE</version>
</parent>
```

使用这种方案继承`spring-boot-starter-parent`后, 也不再需要指定spring boot相关项目的依赖版本.


### 导入dependency
如果需要使用Spring Boot 和Spring Cloud等组件, 由于POM的单继承, 不能同时继承, 此时可以使用导入的方式导入相应的依赖.

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <!-- Import dependency management from Spring Boot -->
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>2.2.0.BUILD-SNAPSHOT</version>
            <type>pom</type>
            <scope>import</scope> 
        </dependency>
    </dependencies>
</dependencyManagement>
```


导入依赖以后, 同样不需要指定版本, 但关于
- [理解spring-boot-starter-parent](https://www.jianshu.com/p/628acadbe3d8)  