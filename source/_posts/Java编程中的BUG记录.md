---
title: Java编程中的BUG记录
date: 2017-09-01 19:57:09
categories: Java特性
tags:
    - Java
cover_picture: images/java.jpg
---

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