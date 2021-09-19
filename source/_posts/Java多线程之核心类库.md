---
title: Java多线程之核心类库
date: 2018-11-21 16:39:29
categories: Java多线程
tags:
    - Java
    - 多线程
cover_picture: images/java.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍Java中关于多线程的类库, 包括各种类的实现原理和使用方法, 关于多线程的基础知识, 可以阅读[Java多线程之基础知识](http://lizec.top/2018/11/21/Java%E5%A4%9A%E7%BA%BF%E7%A8%8B%E4%B9%8B%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86/).



无锁可变量
-----------------

从Java 5开始, `java.util.concurrent.atomic`中就提供了支持无锁可变变量的类, 例如`AtomicLong`等. 可以使用这些类提供的方法对其进行加减法, 并且不需要任何的同步操作.

在上述的类中,使用了一种CAS技术, 即Compare And Set.  一个线程在更新变量值之前, 会检测变量的当前值是否和预期的值相同, 如果是,则说明变量尚未被其他线程修改, 于是可以直接修改这个变量. 如果发现变量已经改变, 那么这次操作失败. 由于CAS技术是硬件提供支持,因此性能比加锁操作有很大的提升.

在Java 8中, 不需要写循环来反复进行CAS操作, 可以直接传入lambda或者方法引用来完成操作

```java
long observed = 2333;
AtomicLong largest = new AtomicLong();
largest.updateAndGet(x -> Math.max(x,observed));
largest.accumulateAndGet(observed,Math::max);
```

如果线程间的竞争压力很大, 可以使用`LongAdder`来代替`AtomicLong`. `LongAdder`内部有多个变量, 这些变量累计起来表示总和, 从而多个线程进行操作时, 可以将它们分布到不同的变量上进行操作.


AQS
----------------


- [一文带你搞懂什么是AQS及其组件的核心原理](https://zhuanlan.zhihu.com/p/267679376)


并行哈希表
-----------------

`ConcurrentHashMap`是一个保证线程安全的哈希表, 多个线程可以同时对其进行添加和删除元素, 且各个线程之间不会被阻塞. 

### 更新值

由于`ConcurrentHashMap`不保证内部存储的元素的原子性, 因此当需要更新元素的值时, 需要使用一些操作, 例如CAS技术, 使用CAS有两种方式, 分别如下
``` java
// 手动进行循环检测
do{
    oldValue = map.get(word);
    newValue = oldValue == null ? 1 : oldVaue + 1;
} while(!map.replace(word,oldValue,newValue));

// 直接使用lambda函数
map.compute(word, (k,v)-> v==null?1:v+1);
```

与`compute`方法参数类似的方法还有两个, `computeIfPresent`和`computerIfAbsent`分别来处理值已经存在和值不存在的情况, 此外对于上述这种第一次加入与后续操作存在差异的操作, 可以使用`merge`方法, 此方法提供一个额外的参数用于表示初始值.

``` java
map.computeIfAbsent(word, k -> new LongAddr()).increment();

// 如果word不存在, 初始为1L, 否则将原有值和1L进行相加
map.merge(word, 1L, (existingValue, newValue) -> existingValue + newValue);
// 可以使用 Long::sum 进一步简化代码
map.merge(word, 1L, Long::sum);
```


### 批量操作

`ConcurrentHashMap` 提供三种批量操作的方式, 即 `search`, `reduce` 和 `forEach`, 这三种方式都可以分别对键, 值, 建和值, `Map.Entry`进行操作. 这些操作都是并行的, 需要提供一个阈值来指定一个线程中大约包含多少数据. 

如果需要单线程操作, 可以将阈值指定为`Long.MAX_VALUE`, 如果需要尽可能多的线程, 可以将阈值指定为`1`, 但是无论如何设置, 最后的线程数量都不会超过`ForkJoinPool`指定的一个最大线程数量的4倍.


### Set视图

可以在`ConcurrentHashMap` 的基础上获得一个Set视图, 根据需要, 可以使用以下两种方式
``` java
// 在ConcurrentHashMap上封装一个Set
ConcurrentHashMap.newKeySet()

// 在一个已有的ConcurrentHashMap产生一个Set
Set<String> set = map.keySet(1L);
set.add("123")
```

其中`keySet`方法的参数表示使用Set视图添加元素时, 向ConcurrentHashMap添加的默认值. 如果map中不存在`"123"`, 那么执行后map中就存在此元素,且值为1.


重入锁
-----------------

重入锁可以代替synchronized关键字, 且JDK早期版本中性能优于synchronized关键字. 在后续版本中JDK对synchronized关键字进行了优化, 从而使两种差距不大.  重入锁通过ReentrantLock类实现, 使用lock()方法获得锁, 使用unlock()方法释放锁. 对于有异常的场景, 可以在finally语句块中释放锁. 

一种典型的使用方式如下所示：

``` java
try {
    lock.lock();
    // ...
} catch(Exception e) {
    // ...
} finally {
    lock.unlock();
}
```

 而使用ReentrantLock时可以使用tryLock()来尝试获得锁, 根据能否获得锁来执行不同的操作

ReentrantLock可以多次调用lock方法进行锁定（重入）, 因而被称为重入锁.  关于ReentrantLock还有如下的一些重要方法

方法                    | 作用                               | 备注
------------------------|---------------------------------|-------------------------------------------------
lockInterruptibly()     | 除非被中断不断尝试获得锁            | 如果线程被设置为中断, 立刻抛出InterruptedException
tryLock()                | 尝试获得锁并且立刻返回是否获得锁   |  可以根据是否获得锁执行不同的操作
isFair()                 | 是否是公平锁                       | 
isHeldByCurrentThread() | 此锁是否被当前线程持有            |

注意:
- tryLock()方法可以指定一个最大等待时间, 如果到达时间后还是无法获得锁, 则放弃等待并返回false.
- 使用tryLock()或lockInterruptibly()获取锁时, 操作更加灵活, 从而有助于解决一部分死锁问题.
- synchronized和默认的ReentrantLock都是非公平锁, 但是如果需要, 也可以在构造函数中将ReentrantLock指定为公平锁. 




多路通知
----------------------

通过synchronized, wait()/notify()可以实现等待和唤醒. 其中synchronized关键字的作用可以通过ReentrantLock替代, 同样wait()/notify()机制可以被Condition对象替代. 

Condition对象与Lock接口配合使用(ReentrantLock实现了此接口), Lock接口的newCondition()方法可以产生一个Condition对象, 此对象具有以下的一些方法


方法                    | 作用                               | 备注
------------------------|---------------------------------|-------------------------------------------------
await()                    | 使当前线程等待,并且释放锁         | 等待过程中可以响应中断
awaitUninterruptibly()    | 使当前线程等待,并且释放锁         | 等待过程中不会响应中断
signal()                | 唤醒一个等待中的线程              |


注意:
- 等待和唤醒都和一个Condition绑定在一起, 从而实现了更加精细的线程控制
- newCondition()方法每次调用都会返回一个完全不同的实例


信号量
-----------------

Java也提供信号量机制, 关于信号量可以参考操作系统笔记中[信号量和PV原语](http://lizec.top/2017/09/23/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E7%AC%94%E8%AE%B0/#%E4%BF%A1%E5%8F%B7%E9%87%8F%E5%92%8CPV%E5%8E%9F%E8%AF%AD)章节.

表示信号量的类是Semphore, 提供acquire方法实现P操作, 提供release方法实现V操作



读写锁
------------------

Java提供读写锁机制, 关于读写锁的有关内容可以参考数据库系统原理中[封锁技术](http://lizec.top/2017/12/20/%E6%95%B0%E6%8D%AE%E5%BA%93%E7%B3%BB%E7%BB%9F%E5%8E%9F%E7%90%86/#%E5%B0%81%E9%94%81%E6%8A%80%E6%9C%AF)章节.

表示读写锁的类是ReentrantReadWriteLock, 此类提供radLock()方法获得一个读锁, 提供writeLock()获得一个写锁. 在读取操作远多于写入操作时, 读写锁可以获得极高的性能.


倒计时器
-----------------

CountDownLatch是一个用于控制线程等待的多线程控制类. 通常由构造函数指定需要管理的子线程数量, 每个子线程执行完毕后调用countDown()通知CountDownLatch该子线程完成任务.

主线程调用await()方法等待子线程执行相关的任务, 当所有子线程都完成任务后, 主线程被唤醒, 从而继续执行后续的操作.

方法            | 说明
----------------|---------------------------------------
countDown()        | 子线程中调用, 通知此子线程完成任务
await()            | 主线程调用, 等待所有子线程完成任务