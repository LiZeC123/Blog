---
title: 知识碎片
date: 2017-09-01 09:01:00
---



本文是一些小知识的合集, 由于这些知识比较零散, 因此暂时不能确定它们所属的类别以及是否需要专门写一篇文件进行介绍. 当某些知识变成一种无法忘记的常识或者达到了写一篇文章的标准, 那么相应的内容就会从这里删除.

x86-64 Core体系结构历史
-----------------------

x86-64处理器是对x86-32处理器的扩展. 第一个支持x86-32的处理器是1985年推出的Intel 80386微处理器. 80386是对16位体系的80286的扩展, 具有32位寄存器和4GB虚拟地址空间, 使用一个独立的, 称为80387的浮点单元进行浮点运算.

1993年推出的奔腾CPU基于P5架构, 支持MMX技术, 能够对64位大小的寄存处执行单指令多数据(SIMD操作. 1995年推出P6架构, 并在1997年推出的奔腾II中引入三路超标量设计, 使得CPU能够平均在每个周期内解码, 分派和执行三条不同的指令. 此外还引入了无序指令执行, 改进的分支预测等优化.

1999年推出的奔腾III也基于P6架构, 并且支持一种称为 Streaming SIMD Extension, SSE的指令集, 从而能够对8个128位的寄存处进行操作. 2006年, Intel推出Core架构, 支持SSE3和SSE4.1指令集. 2008年推出Nehalem架构, 再次引入超线程技术并支持SSE4.2指令集. 2011年推出Sandy Bridge架构, 引入一种新得SIMD技术, 称为Advanced Vector Extension, AVX. 2013年推出Haswell架构, 支持AVX2指令集和FMA(乘法加法融合)操作. 2017年推出的Skylake-X架构支持了AVX-512指令集, 能够操作512位的寄存器.

与此同期, AMD在2003推出一系列基于K8架构的CPU, 能够支持MMX, SSE和SSE2指令集. 2007年推出K10架构, 支持一种对SSE的扩展指令集SSE4a. 2011年推出Bulldozer架构, 支持SSE3, SSE4.1, SSE4.2, SSE4a和AVX指令集.2017年推出Zen架构, 支持AVX2指令集.

- [The History Of Intel CPUs: Updated!](https://www.tomshardware.com/picturestory/710-history-of-intel-cpus.html)

POSIX接口
--------------

POSIX是 Portable Operating System Interface for uniX的缩写, 即可移植操作系统接口. 在POSIX接口提出以前, 存在很多不同的操作系统, 这些操作系统提供的接口也都不尽相同, 因此对程序开发带来了很大的困难.

POSIX标准通常由C语言的库实现, 例如glibc和musl等. 在C语言层面通过调用POSIX接口实现在不同的操作系统上转换为合适的系统调用.


SPI机制
---------------

SPI机制即Service Provider Interface, 是服务提供方根据现有接口提供服务实现的一种机制. 典型应用是JDBC驱动, 即无论具体使用哪一种数据库, 客户端代码都只使用JDBC的接口进行交互, 而各个数据库厂商根据接口提供相应的驱动实现类.

SPI提供了一种运行时加载具体实现类的方式. 本质上来说就是根据JAR包中提供的类名, 在运行时动态的加载指定的实现类. 这一套逻辑完全可以自己用代码实现.

- [JDBC驱动加载机制详解以及spi机制](https://blog.csdn.net/qq_38712932/article/details/82987865)




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


JVM常用参数
----------------

参数                        | 含义
----------------------------|------------------------------------
-Xms                        | 设置初始堆大小
-Xmx                        | 设置最大堆大小
-XX:+PrintCommandLineFlags  | 打印设置的参数(包括默认参数)



实际上JVM会根据设备可用的内存数量来调整默认使用的垃圾回收算法. 例如在我的服务器上(1GB内存)和开发机器上(16GB内存)分别答应默认的参数. 其结果如下所示:


```
-XX:InitialHeapSize=16071680 -XX:MaxHeapSize=257146880 -XX:+PrintCommandLineFlags -XX:ReservedCodeCacheSize=251658240 -XX:+SegmentedCodeCache -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseSerialGC 
openjdk 11.0.10 2021-01-19
OpenJDK Runtime Environment 18.9 (build 11.0.10+9)
OpenJDK 64-Bit Server VM 18.9 (build 11.0.10+9, mixed mode, sharing)
```

```
-XX:G1ConcRefinementThreads=8 -XX:GCDrainStackTargetSize=64 -XX:InitialHeapSize=267607488 -XX:MaxHeapSize=4281719808 -XX:+PrintCommandLineFlags -XX:ReservedCodeCacheSize=251658240 -XX:+SegmentedCodeCache -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseG1GC -XX:-UseLargePagesIndividualAllocation
java 11.0.4 2019-07-16 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.4+10-LTS)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.4+10-LTS, mixed mode)
```

由于服务器上内存较少, 因此默认采取最简单的Serial系列垃圾回收器, 从而节省内存消耗. 而开发机器上内存比较充足, 因此采取了性能更好的G1垃圾收集器.



## Java删除文件
　　曾经有过使用Java删除文件的经历, 但是偶尔会遇到删除失败. 即使用`file.delete()`函数时, 返回false. 因为这个函数并不抛异常, 所以并不清楚是什么原因导致了这一问题. 如果查看`file.delete()`的源代码, 可以发现这个函数的注释上写了如下的语句:
``` Java
    /**
     * <p> Note that the {@link java.nio.file.Files} class defines the {@link
     * java.nio.file.Files#delete(Path) delete} method to throw an {@link IOException}
     * when a file cannot be deleted. This is useful for error reporting and to
     * diagnose why a file cannot be deleted.
     */

```
　　上面这段注释指明, 可以使用`java.nio.file.Files`类的静态方法`delete(Path)`来删除文件, 这个函数会抛出异常来指明为什么删除失败. 注意到`delete(Path)`方法需要传入一个`Path`类作为参数, 而`File`类正好有一个`toPath()`方法可以将一个`File`类转化为`Path`类. 
　　因此在明白了这些函数以后, 可以将原来的代码中的相关删除操作换成这个会抛异常的方法, 然后根据异常信息来确定具体的异常原因. 替换后, 抛出异常指出我想要删除的文件被正在被另外一个程序使用, 进程无法访问. 检查了一下代码的其他部分, 很快就发现了之前读取这个文件的文件流没有关闭. 因此在原来的代码中加入了关闭流的操作后, 就可以顺利的将文件删除了. 
　　值得一提的是, 同样的代码, 在Linux平台上, 似乎并不会因为文件流没有关闭就导致文件无法被删除. 但是因为Linux平台上使用的编译器和JVM与Windows平台不同, 因此也不能确定这一差异是编译器导致的还是JVM或者操作系统导致的. 如果下次有机会, 可能会进一步探索一下其中的差异. 


## Apache fileupload 无法提取参数
之前使用了Apache的fildupload实现了文件上传功能, 后来发现通过表单传递的参数无法通过`request.getParameter()`获得. 通过查阅[Apache CommonIO文档](https://commons.apache.org/proper/commons-fileupload/using.html)可知, 使用以下方法获得参数

``` java
// Process a regular form field
if (item.isFormField()) {
    String name = item.getFieldName();
    String value = item.getString();
    ...
}
```

其中item通过以下方法获得

``` java
 Map<String, List<FileItem>> formItemMaps =upload.parseParameterMap(request);
               
if (formItemMaps != null && formItemMaps.size() > 0) {
    for (String name : formItemMaps.keySet()) {      
        List<FileItem> itemList = formItemMaps.get(name);
        for(FileItem item:itemList) {
           // 在这里处理item
        }
    }
}
```

注意: 现在如果仅仅是文件上传, 其实并不需要使用CommonIO, Tomcat本身也支持有关功能.




Cheat Sheet
----------------------

- [CheatSheet4LinuxCommand.pdf](CheatSheet4LinuxCommand.pdf)
- [CheatSheet4Matplotlib.pdf](CheatSheet4Matplotlib.pdf)
- [CheatSheet4Redis.pdf](CheatSheet4Redis.pdf)
- [CheatSheet4VSCode.pdf](CheatSheet4VSCode.pdf)


知识碎片
--------------

