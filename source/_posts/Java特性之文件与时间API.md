---
title: Java特性之文件与时间API
date: 2018-11-21 16:23:00
categories: Java特性
tags:
    - Java
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


从Java 1.4之后, Java引入了新的Java I/O 库来替代原有的File类, 到了Java 8, Java又引入了新的Base64编码和解码库, 使用新的API可以避免原来Java文件的复杂操作, 简化代码逻辑. 此外, 在Java 8中, 还引入了另外的一组时间API来替代原有的设计, 使用新的时间API能更简单的处理时间的相关问题.


文件操作
----------------------

Java1.4之后,Java引入了一个新的java.nio库,即New I/O. 因此现在的编程应该更多的使用新的类,而File类只应该在和旧系统交互时使用. 此外, Paths和Files两个类中还封装了一些与文件相关的常用操作, 从而可以减少重复代码.

### Path类

Path是一个接口, 用于表示一个目录或者文件. 可以通过Paths.get方法获得一个Path实例. get方法接受若干字符串,并通过系统指定的分割符来连接字符串. 

例如
``` java
Path originPath = Paths.get(".", "a.txt");
```
在Windows上就等于`.\a.txt`而在Linux上等于`./a.txt`

### 遍历目录

Files类提供了两个关于遍历指定目录下所有文件的方法, 两个方法都产生指定目录下所有文件构成的流, 但区别具体如下

方法        | 区别
------------|--------------------------------------
list()      | 此操作不递归包含子目录中的项目
walk()      | 使用深度优先, 递归的包含全部的项目

此外, walk()方法还可以指定最大递归深度. 



### 文件读取和写入

Files类提供了很多以Path为参数的文件读写操作. 包括读取所有字节,所用行等操作.

``` java
Path path = Paths.get("a.txt");
byte[] bytes = Files.readAllBytes(path);
String content = new String(bytes);
List<String> lines = Files.readAllLines(path);
```

在只是读取文件而后续操作与文件无关的场景下,使用Files的有关函数能更加简洁的完成任务.

Fils类还提供newInputStream,newBufferedReader等方法来快速的创建一个流,相比于以往的嵌套模式,使用新的方法显然有助于增加代码可读性.

Files类提供了copy方法来将一个流写入Path对应的文件或者将Path对应的文件写入流. 使用这个函数就基本可以不用再使用数据在流和文件之间交换数据了. 具体的使用示例可以参看下一节的Base64的代码.

> 虽然看起来接口层没有什么变化, 但实际上这些方法都已经采取了nio中的相关方法实现.

### 创建文件
Files类提供了`createDirectory`方法来创建一个目录,除了路径的最后一个目录以外,其他目录都必须存在. 

如果想一次创建多个目录,可以使用`createDirectories`方法.

此外Files还提供了`createTempFile`方法来在系统或用户指定的位置创建临时文件或目录. 例如调用下面的方法

``` java
Path tempPath = Files.createTempFile(null, ".txt");
```

就可能返回一个类似9136812192980078079.txt的文件.


### 复制,移动函数
Files类提供了copy和move方法来复制和移动文件或者目录,同时提供以下参数来指定复制或移动的方式.

参数             |
-----------------|-----------------------------------------------------------
REPLACE_EXISTING | 强制覆盖
COPY_ATTRIBUTES  | 复制文件属性
ATOMIC_MOVE      | 原子操作(要么完成移动,源文件删除,要么移动失败,源文件不变)


可以使用delete方法来删除一个文件,但如果指定的文件不存在,则抛出异常.
使用deleteIfExists方法来检查并删除一个文件.



Base64编码
-----------------------

Java 8中提供了新的Base4编码和解码库. 可以通过Base64类的静态方法 getEnoder,getUriEncoder等方法来获得一个Base64.Encoder对象. 此外还可以包装一个输出流,使得所有发送给流数据都被自动的转换. 

以下代码演示Base64的编码和解码过程
``` java
Base64.Encoder encoder = Base64.getEncoder();
String original = "LiZeC" + ":" + ", 你好";
String encoded = encoder.encodeToString(original.getBytes());
System.out.println(encoded);
```

以下代码演示对流进行包装
``` java
Path originPath = Paths.get(".", "a.txt");
Path encodePath = Paths.get(".","a.encode");
Path thridPaht = Paths.get(".","a.decode.txt");

// encode
Base64.Encoder encoder = Base64.getMimeEncoder();
try(OutputStream outputStream = Files.newOutputStream(encodePath)){
    Files.copy(originPath, encoder.wrap(outputStream));
} 

// decode
Base64.Decoder decode = Base64.getMimeDecoder();
try(InputStream input = Files.newInputStream(encodePath)){
    Files.copy(decode.wrap(input), thridPaht);
}
```

时间API
-----------------

### 时刻

Java 8中引入一个新的类`Instant`来表示时间线上的某一个时刻, 此类提供静态方法`now()`来获得当前时刻, 因此如果计算一段程序的执行时间, 可以使用如下的代码
```java
Instant start = Instant.now();
runAlgorithm();
Instant end = Instant.now();
Duration timeElapsed = Duration.between(start,end);
long millis = timeElapsed.toMillis();
```

`Duration`表示一段时间, 内部使用long型变量保存秒数部分, 使用int型变量表示纳秒部分, 因此在表示大约300年的时间间隔时,`Duration`才会因为超过long范围而溢出.

`Instant`和`Duration`都支持对当前时间进行四则运算, 并且提供判是否为0, 或者是否为负数的方法.


### 本地时间

Java 8中引入`LocalDate`,`LocalTime`和`LocalDateTime`来表示本地的日期和时间. 这些变量都可以使用相应类的静态方法`now`或者`of`来构造, 并且支持计算在当前时间上加入几天,几个月, 几年等时间段时候的日期, 并且提供相互比较的方法.


### 格式化时间

对于本地时间有关的类, 可以使用`DateTimeFormatter`进行格式化, 使用的方式如下

``` java
final DateTimeFormatter fDay = DateTimeFormatter.ofPattern("yyMMdd");
LocalDateTime time = LocalDateTime.now();
System.out.println(time.format(fDay));
```