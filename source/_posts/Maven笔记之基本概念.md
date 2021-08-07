---
title: Maven笔记之基本概念
date: 2019-07-09 09:49:51
categories: Maven笔记
tags:
    - Maven
    - Java
cover_picture: images/maven.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


构建一个Java项目, 通常需要下载依赖, 复制jar到类路径, 编译项目, 运行项目测试用例, 打包项目, 将项目部署到服务器等操作.  Maven是一个自动完成上述工作的工具, 从而减少项目构建过程的复杂度. 本文介绍如何通过Maven管理Java项目.


Project Object Model
----------------------

Maven管理一个项目的核心就是Project Object Model(POM), 这是一个名为pom.xml的文件. POM描述了项目的基本信息, 管理项目的依赖, 以及控制项目构建过程. 一个典型的pom.xml文件如下所示

``` xml
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>top.lizec</groupId>
    <artifactId>usemaven</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>UseMaven</name>
    <url>http://maven.apache.org</url>
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
            //...
            </plugin>
        </plugins>
    </build>
</project>
```

上述的xml可以分成如下的几个部分


### 项目标识信息

项目标识信息包含以下的几项内容, 这也被称为坐标信息(coordinates), 这些信息唯一的确定一个项目


名称         | 含义
-------------|---------------------------------------
groupId      | 组织名称,通常是一个反写的域名
artifactId   | 这个项目(模块)的名称
version      | 这个项目的版本号
packaging    | 项目的打包类型,默认为jar

注意: packaging还可以指定为war格式(Web Application Resource)或者pom格式(表示这是一个父项目).

### 依赖信息

依赖信息放置在`<dependencies></dependencies>`标签对中, 当项目需要依赖一个外部的库时, 需要提供这个库的groupId, artifactId和version

``` xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>5.1.2.RELEASE</version>
    <scope>compile</scope>
</dependency>
```

其中groupId, artifactId, version是依赖的项目的坐标信息, 对于scope有如下的选项

scope选项   | 含义
------------|--------------------------------------------------------------
compile     | 默认值, 表示编译和打包阶段都需要此依赖
test        | 仅单元测试阶段需要此依赖
provided    | 编译阶段需要此依赖, 但打包时不包含此依赖(运行环境提供了此依赖)
runtime     | 编译和打包时不需要, 运行时需要此依赖

提供这些必要信息以后, Maven会自动去中央仓库下载需要的依赖包到本地的仓库. 可以在[MavenRepository](https://mvnrepository.com/)搜索可用的依赖库. 


### 仓库

Maven有一个默认的中央仓库和一个默认的本地仓库. 本地仓库位于用户目录下的 `.m2/repository` 目录.  通常情况下不需要对仓库进行配置. 但是如果项目需要引用一些中央仓库没有的库, 可以在POM中指定额外的仓库地址.

``` xml
<repositories>
    <repository>
        <id>JBoss repository</id>
        <url>http://repository.jboss.org/nexus/content/groups/public/</url>
    </repository>
</repositories>
```

注意: 一个项目可以指定多个仓库地址.

### 属性

可以在POM中使用自定义属性来提高项目的可维护性. 例如

``` xml
<properties>
    <spring.version>4.3.5.RELEASE</spring.version>
</properties>
 
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>${spring.version}</version>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <version>${spring.version}</version>
    </dependency>
</dependencies>
```

上面定义了一个名为`spring.version`的变量, 之后两个spring的依赖都使用同样的版本值, 这样当后续需要升级spring版本时, 只需要简单的修改`spring.version`即可.


Maven指令
-------------

### 基本指令

指令         | 含义
-------------|----------------------------------------------------------------
mvn compile  | 编译整个项目
mvn test     | 运行项目的测试用例
mvn package  | 编译项目,运行测试用例并打包
mvn install  | 编译项目,运行测试用例,打包代码,最后将代码复制到本地的依赖代码仓库中
mvn clean    | 清理项目生成的各种文件


打包文件的名称由`artifactId`和`version`决定. install以后的代码可以被其他项目引用


### 生命周期

Maven在编译项目时, 按照一定的生命周期进行, 一个主要的生命周期的各个阶段如下所示

阶段名称             | 操作
--------------------|---------------------------------
validate            | 检测项目正确性
compile             | 将源代码编译为二进制文件
test                | 执行单元测试
package             | 将二进制文件打包
integration-test    | 运行集成测试
verify              | 检测打包的项目正确性
install             | 将打包的项目安装到本地仓库
deploy              | 将打包的项目部署到服务器或仓库


Maven版本号
-----------------

### 版本号规则
一个项目的版本应该具有`MAJOR.MINOR.PATCH`的格式. 其中

- MAJOR: 主版本号, 表示与前一个版本有不兼容的更新
- MINOR: 次版本号, 表示与前一个版本有功能增强, 且与之前的版本兼容
- PATCH: 修订号, 可以向前或向后移动, 表示修复了一些BUG


除了数字的版本号以外, 版本号还可以加入一个后缀, 后缀的类型如下

后缀类型                 | 含义
------------------------|--------------------------------------
SNAPSHOT                | 表示当前版本还处于开发过程中
M1                      | 里程碑版, 表示即将发布, 也可以是M2, M3等
RC(Release Candidate)   | 发布候选版本
GA(General availability)| 基本可用版本
RELEASE                 | 正式发布版本

此外, 如果一个库使用`SNAPSHOT`后缀, 则每次构建项目时, Maven都会从中心仓库重新下载依赖库, 从而保证依赖库可以及时的更新.




Maven项目结构
--------------

一个标准的Maven项目具有如下的结构

```
/
src/
    - main/
        - java/
        - resources/
    - test/
        - java/
target/
    - classes/
    - generated-sources/
        - annotation
pom.xml
```

其中`/src/main/java`用来存放项目的代码, `/src/main/resources`用来存放使用的资源文件(例如MyBatis的配置文件). `/test`目录存放测试相关的代码, 而且此目录应该和`/main`目录具有同样的结构, 且每个Java文件都对应一个测试文件.

编译阶段,Maven会自动将`/src/main/java`下的代码编译成class文件,并且存放在`/target/classes`目录下 , 并且将`/src/main/resources`的全部文件直接复制到`/target/classes`目录下. 

这里可以显然地发现, 如果在`/src/main/java`和`/src/main/resources`下创建同样结构的目录, 那么相应的文件最终就会合并到同一个目录下. 例如文件`/src/main/java/top/lizec/main.java`和`/src/main/resources/top/lizec/database.properties`编译之后就会产生`/target/classes/java/top/lizec/main.class`和`/target/classes/java/top/lizec/database.properties`


- [7天学会Maven（第二天——Maven 标准目录结构）](https://www.cnblogs.com/haippy/archive/2012/07/05/2577233.html)




Maven创建聚合项目
------------------

聚合项目是指在一个父项目下包含多个子模块


先创建一个项目, 删除src, 修改为pom格式, 创建module, 注意父项目指向子项目, 子项目指向父项目

- [maven在父级项目文件夹下创建子项目](https://blog.csdn.net/daguanjia11/article/details/76836781)
- [IntelliJ IDEA创建maven多模块项目](https://www.cnblogs.com/wangmingshun/p/6383576.html)



参考资料和扩展阅读
----------------------
- [Apache Maven Tutorial](https://www.baeldung.com/maven)
- [Building Java Projects with Maven](https://spring.io/guides/gs/maven/)
- [Maven Getting Started Guide](http://maven.apache.org/guides/getting-started/index.html)
- [理解Maven中的SNAPSHOT版本和正式版本](http://www.huangbowen.net/blog/2016/01/29/understand-official-version-and-snapshot-version-in-maven/)
- [Maven pom.xml中的元素modules、parent、properties以及import](https://www.cnblogs.com/youzhibing/p/5427130.html)
- [Spring with Maven BOM](https://www.baeldung.com/spring-maven-bom)
