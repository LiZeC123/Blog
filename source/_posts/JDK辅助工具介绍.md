---
title: JDK辅助工具介绍
date: 2018-11-21 16:05:22
categories: JDK笔记
tags:
    - Java
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍JDK中提供了一系列辅助工具的使用方法, 包括打包程序jar, 监控程序Visual VM等.


Jar指令
-----------------------

使用jar指令对Java的的代码和资源文件进行压缩或解压

1. 压缩包：
jar cvf filename.jar a.class b.class: 压缩指定文件；
jar cvf weibosdkcore.jar *: 全部压缩；

2. 解压包：
jar xvf test.jar

选项:
- c  创建新档案
- t  列出档案目录
- x  从档案中提取指定的 (或所有) 文件
- u  更新现有档案
- v  在标准输出中生成详细输出
- f  指定档案文件名


Javascript引擎
-----------------------

Java提供了一个新的Javascript引擎,名为Nashorn(德语的犀牛,发音类似nas-horn). 在JDK的bin目录中,可以找到一个叫做jss的工具, 通过命令行打开该程序即可获得一个JavaScript的交互命令行.

### 从Java运行Nashorn
从Java6开始,Java提供了脚本引擎机制,通过该机制可以运行一个Nashorn脚本. 当然通过配置以后,也可以运行Groovy,JRuby,Jython等语言. 也有一些其他的引擎可以使JVM支持PHP或者Scheme.

以下代码演示如何从Java中初始化一个nashorn脚本引擎,并运行JavaScript代码

``` java
ScriptEngineManager manager = new ScriptEngineManager();
ScriptEngine engine = manager.getEngineByName("nashorn");
// 直接执行代码
Object result = engine.eval("'Hello World'.length");
System.out.println(result);
```