---
title: 知识碎片
date: 2017-09-01 09:01:00
---



本文是一些小知识的合集, 由于这些知识比较零散, 因此暂时不能确定它们所属的类别以及是否需要专门写一篇文件进行介绍. 当某些知识变成一种无法忘记的常识或者达到了写一篇文章的标准, 那么相应的内容就会从这里删除.



CPU如何实现时间片切换
----------------------------

显然CPU在执行过程中并没有时间的概念，也不可能在执行进程的代码的时候，在每一条指令后检查是否已经执行了指定的时间。所以时间片的切换显然是通过中断触发的。

通过单独的计时模块可以按照一定的时间间隔触发时钟中断（例如每隔1ms触发一次），从而CPU在执行完当前指令后通过响应中断的方式通知操作系统判断当前进程是否指向了足够长的时间。


ELF文件是如何记载的？
--------------------------

从ELF文件的结构来看，似乎有很多不同的段，似乎如果要执行ELF文件，还需要进行解析过程。但需要注意到ELF的两个常见的格式，即可重定位目标文件和可执行目标文件。对于可重定位目标文件，由于需要重定位，因此有很多辅助的信息表。但是对于可执行目标文件，少了很多辅助段。

而且代码中的.text段和.data段时间上也是相邻的，分别将这两个段加载到内存之中即可构建进程在内存中的状态。整个过程中只需要简单的解析每个段所在的位置即可，不需要进行复杂的分析过程。

当然，这个解析过程肯定还是需要加载器进行处理的，并不是硬件直接完成。

静态链接过程
---------------

静态链接过程的核心是将多个代码片段合并为一个代码片段，并且适当的重写其中的符号引用地址。由于最终的文件包含所有的代码，因此所以的符号最终的位置都是可以确定的，只需要通过适当的计算即可得到对应的地址。


动态链接库的加载
--------------------

使用动态链接库的程序相比于静态链接的程序，由于有动态链接的内容，因此显然并不能像静态链接的程序一样直接复制text段和data段带内存中即可执行。假设当前的用户程序A动态链接了一个库lib，则在启动A的过程中需要执行如下的一些操作：

1. 加载A的代码和数据到内存之中
2. 根据A中描述的动态链接库列表，使用动态链接器加载lib的代码和数据到内存之中
3. 重写A中关于lib的符号，使其指向lib的实际地址

之后使用了动态链接库的的用户程序A就可以像静态链接的程序一样运行了。而且通过虚拟内存技术可以使得动态链接器的代码段在不同的进程中共享，从而减少应用程序的体积，减少运行时的内存消耗。


与位置无关代码
---------------------

动态链接库和静态链接库的一个重要区别就是动态链接库的代码要求是位置无关代码（Position Independent Code， PIC）。这主要有两个原因

1. 动态链接库中的代码不和用户代码合并到一个文件之中，因此不能知道最终会被加载到内存的那个位置，不能假定绝对地址
2. 动态链接库中的代码可能被多个进程共享，因此不能保证总是加载到同一个内存位置

即使使用了虚拟地址技术，也不能假定一定加载到某个位置，否则在位置分配上容易产生空间浪费或者冲突等问题，带来管理上的负担。

动态链接库中需要处理位置的地方主要是对全局变量和外部函数的访问。对于模块内部的变量和函数，显然在编译过程中就可以确定相对位置了，只有外部的变量和函数由于也可能是动态加载的而不确定位置。

为了实现对其他模块的符号的访问，动态链接库的代码中再data段的开头设置了一个表格（Global Offset Table， GOT），表格中记录了外部符号的绝对地址。其中的绝对地址在程序加载的时候由动态链接器更新。而在代码中所有需要访问外部符号的地方，都改为先访问GOT中的条目，再通过其中的记录得到对应的符号。

由于库中的代码和GOT表的位置是可以编译时确定的，因此只需要在代码中设置对应的偏移地址即可。从而保证了动态链接库无论加载到那个位置都只需要修改GOT，而不需要修改代码中的引用。

对于动态链接库和静态链接库，可以看到两者本质上都是解决重定位问题，只不过静态链接库因为具有所有的代码，可以在链接过程中直接完成计算，而动态链接库在程序加载以后才具有对应的代码，才完成对应的计算。


动态链接库方法的延迟绑定
------------------------------

对于动态链接库中的变量，在加载的时候就完成GOT表的计算，实现绑定效果。对于函数，动态链接库并没有采用同样的方式，而是采取了延迟绑定的方法。

延迟绑定的核心还是利用GOT表，代码中直接call GOT表对应条目中存储的地址。当此函数是第一次调用的时候，GOT表格中的地址指向启动动态链接器的代码，使得动态链接器加载对应的代码，并修改GOT中的对应条目，使其直接指向加载的函数。最后动态链接器将控制权转移到对应的函数。

第二次访问时，再次call GOT表对应条目中存储的地址时，就可以直接跳转到对应的函数。

相比于变量的两次访问，通过延迟加载可以使的方法调用除了第一次需要额外逻辑后只需要一次额外的GOT表访问。



前端校验和后端校验
--------------------------

前端校验的目的是防止用户错误输入。 后端校验的目的是方式恶意攻击。

所以一些关键的校验既需要前端校验也需要后端校验



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

