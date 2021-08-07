---
title: Netty笔记之基础知识
date: 2021-04-09 10:14:15
categories:
tags:
cover_picture:
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->

Netty是一个基于Java的高性能的, 异步事件驱动的网络通信框架, 其对Java的NIO进行了封装并提供简单易用的API. Netty本身是一个Jar包, 可以通过Maven进行管理.




基本概念
-----------------



### 缓存IO技术

缓存 I/O 又被称作标准 I/O，大部分操作系统的的默认 I/O 都是缓存 I/O。在 Linux 的缓存 I/O 机制中，操作系统会将 I/O 的数据缓存在文件系统的页缓存中。因此无论是读操作还是写操作， 数据都需要在系统内核的缓冲区中中转一次，由此会带来一部分数据拷贝和系统调用的开销。



以read操作为例，对于一次read操作， 实际上需要经过两个阶段
1. 内核等待数据准备
2. 从数据从内核拷贝到用户空间


### IO模型
由IO操作需要分为等待数据和拷贝数据的特点，可以产生多种IO模型， 具体如下

#### 阻塞IO

默认情况下的Socket都是阻塞IO。当用户调用read操作时，如果当前没有足够的数据，则用户进程被阻塞，内核等待读取到足够的数据并将数据复制到用户空间后恢复用户进程。

#### 非阻塞IO

Socket也可以设置为非阻塞模式。当用户调用read操作时，如果数据没有准备好，则内核立刻返回一个错误信息。用户可以根据错误信息决定要不要再次执行read操作。

#### IO多路复用

IO多路复用使用select和epoll等函数，使得一个用户进程可以同时监听多个文件描述符。如果所有文件都未准备好，则用户进程阻塞在select函数上。只要有一个文件描述符准备好，则用户进程从select返回。

在select返回以后，用户进程还需要对相应的文件描述符发送read请求，由于此时数据已经准备完成，因此read操作只需要等待数据从内核拷贝到用户空间。

------------------

select， poll和epoll都可以实现IO多路复用。select函数需要传入3个数组，分别表示需要监听可读，可写和异常事件的描述符列表。当发生对应事件的时候，select函数返回。如果指定了超时事件，那么达到超时事件后也会返回。返回后用户进程需要遍历文件描述符列表，找到对应的描述符执行操作。由于select函数能够监视的文件描述符的数量存在最大限制，一般为1024.

poll函数采用链表结构，因此与select相比没有最大数量限制。但select和poll返回后需要遍历描述符列表，因此如果监听数量较大，性能会下降。

epoll函数相比于前两种函数， 返回时能够提供发生事件的描述符列表，从而返回后不需要再遍历描述符列表。epoll对文件描述符的操作有两种模式

- LT模式（Level Trigger）：当epoll_wait检测到描述符事件发生并将此事件通知应用程序，应用程序可以不立即处理该事件。下次调用epoll_wait时，会再次响应应用程序并通知此事件。
- ET模式（Edge Trigger）：当epoll_wait检测到描述符事件发生并将此事件通知应用程序，应用程序必须立即处理该事件。如果不处理，下次调用epoll_wait时，不会再次响应应用程序并通知此事件。

- [Linux IO模式及 select、poll、epoll详解](https://segmentfault.com/a/1190000003063859)


#### 异步IO

用户发送read请求后，由操作系统完成全部的等待数据和拷贝数据操作，全部操作完成后通知用户进程。


#### 同步与阻塞

上述四种模型中，除了最后一种是异步IO以外，其余三种都是同步IO。 同步和异步的差别主要在于如何响应。同步IO发送请求并等待结果，而异步IO发送请求后一般通过回调函数等机制处理结果。

阻塞IO和非阻塞IO比较容易区分，主要看发送IO请求时用户线程会不会被阻塞。


#### Java的IO模型

Java的IO模型实际上最终也会对应操作系统的IO模型， 目前可以分为如下的四种

- BIO(Blocking IO): 即同步阻塞IO, 在这种场景下, 通常使用一个线程对应一个IO连接的方式. 当请求较多时, 虚拟机的压力较大
- 伪异步IO: 依然是BIO, 但引入线程池进行优化, 从而限制最大线程数量
- NIO(Java Non-blocking IO): 同步非阻塞IO, 通过Channel, Selector和Buffer实现
- AIO(Java Asynchronous IO): 异步非阻塞IO, 通过回调通知线程, 回调时已经完成IO操作




Java NIO基础
-------------

Java的NIO库有三个核心组件， 分别是缓冲区（Buffer），通道（Channel）和选择器（Selector）。与Java的BIO可以处理各类IO一样，NIO也可以处理网络，文件等各种IO。

### Buffer

Buffer就是一个缓冲区，根据Java的数据类型， 每种类型有一个子类，例如ByteBuffer和LongBuffer。根据使用的需要，可以在JVM的堆内存中或者在直接内存中分配缓冲区。

> BIO中所有的操作都是面向流的，而NIO中所有操作都是面向Buffer的

缓冲区是双向的， 既可以向其中写入数据，也可以从中读取数据，在实现上就是一个在数组上的循环队列。


### Channel

NIO中有四种Channel，分别是FileChannel，SocketChannel，ServerSockectChannel和DatagramChannel。前面三种看名称就可以知道含义，第四种通道处理针对UDP通信的数据。

Channel本身并不包含数据，而是封装了针对缓冲区的操作，例如将一个通道的数据写入到另一个通道的操作代码为

```java
//把输入流通道的数据读取到缓冲区
inputStreamChannel.read(byteBuffer);
//切换成读模式
byteBuffer.flip();
//把数据从缓冲区写入到输出流通道
outputStreamChannel.write(byteBuffer);
```

### Selector

Selector对应IO多路复用中的select函数。 每个Selector可以被注册到多个通道之中， 当Selector监听的通道发生相应的事件时能够通知用户线程

```java
//打开一个选择器
Selector selector = Selector.open();
//serverSocketChannel注册到选择器中,监听连接事件
serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

 //循环等待客户端的连接
while (true) {
    if (selector.select(3000) == 0) {
        continue;
    }
    //如果有事件
    Set<SelectionKey> selectionKeys = selector.selectedKeys();
    Iterator<SelectionKey> it = selectionKeys.iterator();
    while (it.hasNext()) {
        SelectionKey selectionKey = it.next();
        if (selectionKey.isAcceptable()) {
            // 处理连接相关的操作
        }
        //如果是读事件
        if (selectionKey.isReadable()) {
            //处理读取相关的操作
        }
        //从事件集合中删除已处理的事件
        it.remove();
    }
}
```

- [NIO从入门到踹门](https://mp.weixin.qq.com/s/GfV9w2B0mbT7PmeBS45xLw?spm=a2c6h.12873639.0.0.53064a61WLaTGt)



Java NIO原理
-------------

### 非直接缓冲区

操作系统提供的IO操作默认包含缓存，因此从内核读取数据，到用户进程得到数据需要进行一次复制操作，将数据从内核缓冲区复制到用户空间。 Java NIO提供直接缓冲区，使用直接缓冲区时， 通过将内核的内存和用户空间的内存映射为同一块内存，实现了避免复制的功能。

### transferTo原理





Reactor模型
-----------------


将需要处理的IO事件注册到一个中心IO多路复用器上, 同时主线程阻塞在复用器上, 当相应的IO事件发生时, 主线程被唤醒, 将相应的事件派发给相应的的处理器进行处理.

Handler

- Synchronous Event Demultiplexer(同步事件分离器): 一般就是指IO多路复用机制
- Event Handler(事件处理器): 由开发人员编写的回调代码
- Concrete Event Handler(具体事件处理器): 事件处理器的具体的实现
- Initiation Dispatcher(初始分发器): 控制事件的调度, 事件处理器的注册和删除.



- 单线程模式: 所有的IO操作在一个线程上完成
- 多线程模式: 




