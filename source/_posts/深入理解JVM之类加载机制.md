---
title: 深入理解JVM之类加载机制
date: 2021-01-12 14:22:55
categories: 深入理解JVM
tags:
    - Java
    - JVM
cover_picture: images/JVM.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->




类加载过程
----------------

![image](/images/jvm/ClassLoading.jpg)

一个类从加载到卸载的生命周期如上图所示. 其中验证, 准备, 解析三个阶段也统称为链接阶段.


### 加载

在加载阶段, Java虚拟机需要完成三件事情

1. 根据类的全限定名获取其二进制流
2. 将二进制流转化为方法区的运行时数据结构
3. 在内存中生成一个代表这个类的class对象, 作为方法区这个类各种数据的访问入口

因为并没有规定如何获取二进制流, 因此在实现的时候有多种选择, 例如从压缩包(jar)或者网络(web applet)读取, 这些读取方法各自产生了一些Java的技术. 

加载阶段和链接阶段可以有一部分重叠, 在加载还没有完全结束之前, 就可以先开始一部分链接阶段的工作(例如开始部分验证工作).


### 验证

验证阶段主要的工作是验证字节码是否满足Java虚拟机中的约束要求, 是否存在危害虚拟机安全的代码. 

Java语言规定了很多不安全的行为, 包括数组越界, 跳转到不存在的代码位置等. 如果在Java语言中出现了这些行为, 代码将无法编译. 但字节码文件可以通过其他方式产生, 因此JVM并不能直接信任字节码文件中的代码.

验证阶段的内容比较多且比较细节, 具体可以查看[Java Virtual Machine Specification 5.4.1. Verification](https://docs.oracle.com/javase/specs/jvms/se15/html/jvms-5.html#jvms-5.4.1)


### 准备

准备阶段的工作是为类变量(类中的静态变量)分配内存空间并赋予初始值. 这一阶段的内存分配工作与实例变量没有关系, 从逻辑上将, 这是在方法区分配内存空间. 不过在最终的实现上, HotSpot虚拟机的方法区也位于Java堆上.

如果静态变量并没有被`final`修饰, 那么赋予的初始值是相应类型的零值, 而实际的赋值在类构造器`<clinit>()`方法之中. 反之, 如果被`final`修饰, 那么此时就会赋予给定的初始值.


### 解析

解析阶段的主要工作是将常量池中的符号引用替换为直接引用. 



### 初始化

初始化阶段执行用户在Java代码中写的初始化语句, 包括对`static`变量赋值和位于`static{}`代码块中的其他代码. 编译器会自动收集这些操作, 并在`<clinit>()`方法中进行调用. 

对于类, 虚拟机保证父类的`<clinit>()`方法会比子类的`<clinit>()`方法先执行. 而对于接口, 只有使用到父类的字段时才会对父类进行初始化, 否则仅初始化子类的接口.

虚拟机保证在多线程环境下, 初始化过程能够被正确的同步. 



类加载器
------------------


类加载器用于实现类的加载动作, 但对于每一个类, 加载它的类加载器和这个类本身一起共同确立其在Java虚拟机中的唯一性. 也就是说同一个类加载器加载的同一个类才是相同的, 不同的类加载器即使加载了同一个类, 在JVM中也认为是不同的.



### 双亲委派模型


JVM的类加载器使用双亲委派模型, 即系统中存在多种不同的类加载器, 各种类加载器之间存在一定的层次结构. 其示意图如下图所示

![image](/images/jvm/ParentClassLoader.jpg)

其中Bootstrap Class Loader由JVM提供实现, 用于加载核心的类. Extension Class Loader和之后的类加载器都使用功Java实现, 其中Extension Class Loader加载扩展类, 而Application Class Loader加载用户自定义的类.

每当一个类加载器需要加载一个类时, 其首先将这一加载请求委托给父加载器处理, 如果父加载器无法处理, 再由自己进行处理. 其代码如下所示

```java
protected synchronized Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException
{
    // 首先, 检查请求的类是否已经被加载过了
    Class c = findLoadedClass(name);
    if (c == null) {
        try {
            if (parent != null) {
                c = parent.loadClass(name, false);
            } else {
                c = findBootstrapClassOrNull(name);
            }
        } catch (ClassNotFoundException e) {
            // 如果父类加载器抛出ClassNotFoundException
            // 说明父类加载器无法完成加载请求
        }

        if (c == null) {
            // 在父类加载器无法加载时
            // 再调用本身的findClass方法来进行类加载    
            c = findClass(name);
        }
    }

    if (resolve) {
        resolveClass(c);
    }
    return c;
}
```

使用双亲委托模型可以保证核心的库始终被Bootstrap Class Loader加载. 基础的类库不会因为不同的加载器加载导致出现混乱.

> 自定义的类加载器应该重写findClass方法, 从而复用loadClass的双亲委派逻辑


### 破坏双亲委派模型

1. 直接重写loadClass方法, 从而覆盖原本的双亲委派逻辑
2. SPI机制: 由于SPI机制需要核心类加载用户提供的类, 因此引入线程上下文加载器.
3. OSGI热部署: 每个模块使用一个单独的类加载器

- [类加载器如何打破双亲委派加载机制（SPI原理）](https://segmentfault.com/a/1190000020858126)
- [Java使用自定义类加载器实现热部署](https://www.cnblogs.com/yuanyb/p/12066388.html)

### 模块化的类加载器

JDK9中引入模块化系统, 模块化下的类加载器发生了一些变化.

首先, Extension Class Loader被Platform Class Loader取代, 因为模块化以后, 模块天然具有扩展性, 因此不再需要Extension Class Loader. 

并且由于模块化之后, 新版本的JDK中也不再单独提供jre目录, 用户可以根据自己的需要在jmod中选择需要的模块构成自定义的jre.

其次, 平台类加载器和应用程序类加载器都不再派生自java.net.URLClassLoader, 如果之前的程序依赖了相关的方法, 那么在新的JDK上可能会启动失败.



