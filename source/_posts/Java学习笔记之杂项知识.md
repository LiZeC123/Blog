---
title: Java学习笔记之杂项知识
math: false
date: 2018-11-21 16:05:22
categories:
tags:
    - Java
cover_picture: images/java.jpg
---


Jar指令
-----------------------

使用jar指令对Java的的代码和资源文件进行压缩或解压

### 压缩包：
jar cvf filename.jar a.class b.class: 压缩指定文件；
jar cvf weibosdkcore.jar *: 全部压缩；

### 解压包：
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



关于Java开发的一些思考
----------------------


在Java Web开发过程中，相比于直接使用MyBatis并手写基础的SQL语句，还是直接使用MyBatis-Plus更好，尤其在涉及字段变化的时候，能够减少很多维护的负担。

一个Java Web项目，即使什么操作也不做，也需要大约200M内存空间，而与此相对的，Go和Python即使实现了一个稍微有些复杂的后端，可能内存还是能够控制在50M以内，因此项目规模决定了是否使用Java。否则开发也费劲，服务器也承受不了。



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



Java删除文件
-----------------

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



Apache fileupload 无法提取参数
----------------------------------

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
