---
title: Maven笔记之使用插件
date: 2019-07-09 10:36:09
categories: Maven笔记
tags:
    - Maven
    - Java
cover_picture: images/maven.jpg
---




回顾Maven生命周期
------------------

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





maven有一个约定, 如果插件的名字叫maven-xxxx-plugin或xxxx-maven-plugin的话. 可以直接用mvn xxxx:goal的方式调用其提供的功能




Maven 插件
---------------

Maven的核心是一个基于插件的框架(Maven is - at its heart - a plugin execution framework). Maven在声明周期的各个阶段都提供了一些插件, 用于对具体的行为进行精细化的操作. 

Maven的插件可以分成两类, 即`Build plugins`和`Reporting plugins`. 其中`Build plugins`将会在软件构建的声明周期中执行并且需要在`<build />`标签内声明. 



插件示例
--------------

### 复制依赖

这是一个将所有依赖复制到lib文件夹下的插件示例, 这一操作通常用于Web项目, 以便于将项目打包后放入容器

``` xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <id>copy</id>
            <phase>install</phase>
            <goals>
                <goal>copy-dependencies</goal>
            </goals>
            <configuration>
                <outputDirectory>src/main/webapp/WEB-INF/lib</outputDirectory>
            </configuration>
        </execution>
    </executions>
</plugin>
```



- 关于Maven支持的插件, 可以阅读官网上的列表 [Available Plugins](https://maven.apache.org/plugins/)
- 关于Maven的插件基本知识, 可以阅读官网上的指导[Guide to Configuring Plug-ins](https://maven.apache.org/guides/mini/guide-configuring-plugins.html)
- 关于Dependency阶段的插件示例, 可以阅读官网提供的[Examples](https://maven.apache.org/plugins/maven-dependency-plugin/)
- [Spring Boot的Maven插件Spring Boot Maven plugin详解](https://blog.csdn.net/taiyangdao/article/details/75303181)
