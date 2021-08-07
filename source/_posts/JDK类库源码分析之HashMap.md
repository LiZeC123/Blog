---
title: JDK类库源码分析之HashMap
date: 2019-07-11 09:11:57
categories: JDK笔记
tags:
    - Java
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


以下的几篇参考资料中, 第一篇重点分析了HashMap的插入过程, 解释了其中使用的一些二进制技巧, 并且提供了插入过程的流程图. 第二篇重点介绍了插入过程中, 红黑树的操作, 从红黑树的基本操作开始, 详细介绍了HashMap的红黑树创建和插入过程. 

第三篇完整的介绍了HashMap的插入, 删除过程, 对源代码的注解比较详细.第四篇文章在对源代码进行注释的同时, 还提供了操作逻辑的总结, 看文字总结更容易理解.

第五篇介绍了JDK1.7中为什么HashMap会产生死循环.

- [Java8系列之重新认识HashMap](https://mp.weixin.qq.com/s?__biz=MjM5NjQ5MTI5OA==&mid=2651745258&idx=1&sn=df5ffe0fd505a290d49095b3d794ae7a&mpshare=1&scene=1&srcid=0602KPwDM6cb3PTVMdtZ0oX1&key=807bd2816f4e789364526e7bba50ceab7c749cfaca8f63fc1c6b02b65966062194edbc2e5311116c053ad5807fa33c366a23664f76b0b440a62a3d40ec12e7e72973b0481d559380178671cc3771a0db&ascene=0&uin=NjkzMTg2NDA%3D&version=12020810&nettype=WIFI&fontScale=100&pass_ticket=ebineaMbB8BVIeUpnUZjBm8%2BZice%2Bhba5IDsVDpufNY%3D)
- [HashMap分析之红黑树树化过程](https://www.cnblogs.com/finite/p/8251587.html)
- [面试必备：HashMap源码解析（JDK8）](https://blog.csdn.net/zxt0601/article/details/77413921)
- [HashMap源码分析（基于JDK8）](https://blog.csdn.net/fighterandknight/article/details/61624150)
- [老生常谈, HashMap的死循环](https://juejin.im/post/5a66a08d5188253dc3321da0)



以下几篇参考资料中, 第一篇介绍了红黑树的插入和删除过程, 不过全程使用伪代码描述, 直接看可能看不懂.

- [教你初步了解红黑树](https://github.com/julycoding/The-Art-Of-Programming-By-July/blob/master/ebook/zh/03.01.md)

JDK类库源码分析
-------------------

- [HashMap? ConcurrentHashMap? 相信看完这篇没人能难住你！](https://crossoverjie.top/2018/07/23/java-senior/ConcurrentHashMap/)




多线程环境DEBUG
------------------------------

- [IntelliJ IDEA - Debug 调试多线程程序](https://blog.csdn.net/nextyu/article/details/79039566)
- [IDEA 多线程Debug](https://blog.csdn.net/u011781521/article/details/79251819)


可以对所有线程在指定的位置进行断点, 所以即使是多线程环境, 也能够一步步的执行代码
