---
title: Java小知识合集
date: 2019-07-26 15:31:29
categories: Java特性
tags:
    - Java
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文是一些关于Java的各种小知识的合集, 由于这些知识比较零散, 因此暂时不能确定它们所属的类别以及是否需要专门写一篇文件进行介绍.

在内容方面, 当某些知识变成尝试或者达到了写一篇文章的标准, 那么相应的内容就会从这里删除.


检测线程死锁
---------------

其实正常写代码的情况下比较少出现死锁，但如果怀疑程序中出现死锁问题，可以使用JDK自带的工具进行检测

1. 使用jstack查看堆栈信息，可以看到线程持有的锁的情况，从而分析死锁问题
2. 使用visualVM，直接点击检测死锁按钮，也能分析死锁情况

如果代码中出现死锁，可以从如下的角度考虑解决

1. 统一加锁顺序
2. 设置请求锁超时时间
3. 响应中断
4. 使用无锁编程


- [Java中的死锁原理、检测以及解决方法](https://blog.csdn.net/weixin_43767015/article/details/104710979)



一些Java对象的名称
-------------------

名称| 全称                 | 含义
---|----------------------|-------------------------------------
PO | Persistent Object    | 对应数据库记录的Java对象
VO | Value Object         | 业务层之间传递数据的的对象
DAO| Data Access Object   | 控制数据库访问的对象, 通常与PO结合
DTO| Data Transfer Object | 数据传输对象, 与数据库传递数据
BO | Business Object      | 封装业务逻辑的对象, 调用DAO的方法   



序列化ID
--------------

serialVersionUID 用于标记序列化类的版本, 如果对类进行了修改, 那么也应该同步的修改serialVersionUID. IDEA可以直接提供随机值.


手动检查Null
-----------------

手动检查是否为Null, 并手动抛出NullPointException可以视为一种防御性编程, 即如果可能发生错误, 则应该尽可能早的产生.


Lombok
--------

- [lombok](https://www.projectlombok.org/features/all)
    - @Slf4j 自动生成LOG对象



JDK
---------------

前几天更新Intellij IDEA的时候发现, 新版本已经支持JDK 11了, 于是下载了JDK 11 体验了一下. 相较于JDK 8, JDK 11的改动比较大, 目前很多第三方库还没有针对JDK 11做调整, 因此不建议直接把JDK升级, 最好还是先同时保留JDK 8 和JDK 11.


### JDK 新特性介绍

- [Java 9 新特性概述](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-9/index.html)
- [Java 10 新特性介绍](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-10/index.html)
- [Java 11 新特性介绍](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-11/index.html)



JDK集合类归纳
------------------

- [Java语法总结--Java集合类](https://www.cnblogs.com/zhouyuqin/p/5168573.html)
- [排序算法时间复杂度、空间复杂度、稳定性比较](https://blog.csdn.net/yushiyi6453/article/details/76407640)
