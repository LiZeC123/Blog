---
title: Spring笔记之通用配置
date: 2021-09-01 16:07:21
categories: Spring笔记
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->




项目依赖一致性
-----------------

由于Spring/Spring Cloud涉及的组件太多, 各个组件之间的依赖关系比较复杂, 因此为了保证项目的一致性, 需要通过引入合适的parent文件来规定各个组件的版本.

手写pom文件比较复杂, 任何时候都不建议手写这些配置文件. 应该使用SpringBoot官网上的[Spring Initializr](https://start.spring.io/)来获得初始项目的结构和pom文件. 如果使用IDEA, 也可以在创建的时候使用Spring Initializr工具创建项目.

> 官方帮助我们解决版本问题, 不用白不用啊!

如果是父子项目结构, 由于子项目继承父项目, 因此上述配置都应该写在父项目中(由于只是声明, 因此不会造成额外的空间占用)

- [SpringCloud--第一篇 搭建maven子母项目](https://www.jianshu.com/p/19b6553eb603)



热重启
-----------------

为了提高Spring项目的开发速度，可以引入热重启功能。启用此功能需要导入`spring-boot-devtools`依赖。

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-devtools</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

> 将`optional`指定为`true`可以避免此依赖被传递依赖到其他地方

spring-boot-devtools内部使用了两个不同的类加载器，对于第三方的依赖，采用BaseClassLoader，对于自己的代码采用RestartClassLoader。当自己的代码发生变更的时候，则创建一个新的RestartClassLoader并加载新的类文件。由于第三方库不需要再进行加载，因此重启速度有了很大的提高。

spring-boot-devtools会自动监控类路径上的class文件变化，因此只要对项目重新编译，就会触发spring-boot-devtools的重新启动操作。为了使代码修改后能够重新编译，需要对IDEA进行配置，具体可以参考[这篇博客](https://segmentfault.com/a/1190000020594808)和[IDEA官方文档](https://www.jetbrains.com/help/idea/compiling-applications.html#auto-build)




日志配置
---------------


在Spring中, 默认使用了SLF4J(Simple logging facade for Java)日志接口. 因此只要提供了相应的实现, 就可以获得更过关于Spring的日志输出. 而在Spring Boot中，则通过间接依赖`spring-boot-starter-logging`导入了`Logback`模块，因此不需要进行任何配置就可以实现默认的日志功能。

默认配置已经可以满足大部分需求，如果需要进行配置，可以参考下面的几篇文章

- [Logback、Log4J及slf4J日志框架分析对比及在Spring Boot中的使用](https://blog.csdn.net/wudiyong22/article/details/78584128)
- [【SpringBoot-2】SLF4J+logback进行日志记录](https://blog.csdn.net/mu_wind/article/details/99830829)
- [Spring Boot-日志配置(超详细)](https://blog.csdn.net/Inke88/article/details/75007649)