---
title: Maven笔记之依赖管理
date: 2019-07-09 09:50:02
categories: Maven笔记
tags:
    - Maven
    - Java
cover_picture: images/maven.jpg
---



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

> 其中使用`dependencyManagement`标签指定版本的方式又被称为版本锁定, 因为其直接指定了版本, 因此就不用进入后续的版本协调机制.


版本协调机制
--------------

### 最短路径原则

当有两个依赖B和C同时依赖D, 但依赖的D的版本不同的时候, Maven会优先选择离依赖树顶部最近的版本. 例如有如下的两个依赖

``` 
A - B - C - D (1.2)
A - E - D (1.0)
```

上面的依赖关系中, A依赖B和E, B和E最终都依赖D, 由于D(1.0)在依赖树中离A更近, 因此Maven最终会选择D(1.0)


### 版本排除

可以使用`exclusion`标签来显式的排除依赖, 例如对于上面的依赖E, 可以在其中直接排除对D的依赖, 使得整个项目最终采取C中的1.2版本依赖.

### 可选依赖

在导入依赖时, 可以将其指定为`optional`, 从而如果此项目被其他项目依赖, 则可选依赖不会被间接依赖.