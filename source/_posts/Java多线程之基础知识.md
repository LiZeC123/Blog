---
title: Java多线程之基础知识
date: 2018-11-21 16:39:06
categories: Java多线程
tags:
    - Java
    - 多线程
cover_picture: images/java.jpg
---




用Java开发了一些大大小小的项目了, 虽然在这些项目的开发过程中都使用了一些Java多线程技术, 但对于Java多线程的原理, 细节等诸多方面的认识都是空白. 因此有必要系统的学习一次Java的多线程. 

本文主要介绍Java多线程的基础知识, 包括Thread的使用, wait/notify机制等. 关于Java多线程类库的使用, 可以阅读[Java多线程之核心类库](http://lizec.top/2018/11/21/Java%E5%A4%9A%E7%BA%BF%E7%A8%8B%E4%B9%8B%E6%A0%B8%E5%BF%83%E7%B1%BB%E5%BA%93/).


线程基础知识
------------------------

### 线程状态

![线程状态图](/images/thread/ThreadStates.jpg)


1. RUNNABLE状态根据是否正在运行, 又可以分为READY状态和RUNNING状态
2. 根据是否设置超时时间, WATING状态可分为WAITING和TIMED_WAITING
3. BLOCKED是JVM控制的等待行为, 而WAITING是程序主动要求等待行为
4. 进入WAITING状态后, 会放弃持有的锁
5. [Java线程的6种状态及切换(透彻讲解)](https://blog.csdn.net/pange1991/article/details/53860651)

----------------

**同步队列与等待队列:** 所有调用wait方法的线程都会进入对应的等待队列, 等待唤醒. 当线程被唤醒后并不是立刻进入RUNNABLE状态, 而是进入同步队列, 等待重新获得锁以后才可以恢复执行.

**为什么wait需要锁:** 因为wait通常需要伴随条件检查, 需要保证条件检查和wait调用是原子的, 否则分开执行可能导致条件已经变化了但还是执行了wait方法.

- [阿里巴巴面试题： 为什么wait()和notify()需要搭配synchonized关键字使用](https://blog.csdn.net/lengxiao1993/article/details/52296220)
- [wait为什么要在同步块中使用？ 为什么sleep就不用再同步块中？](https://www.cnblogs.com/myseries/p/13903051.html)


### 创建线程

在Java中有以下几种方法可以使一段代码以多线程的方式运行, 即

1. 继承Thread类并重写run方法
2. 实现Runnable接口, 并构造Thread实例
3. 实现Callable接口, 并构造Thread实例
4. 通过线程池创建并执行线程

> Runnable与Callable的主要区别在于Callable有返回值, 而Runnable没有返回值

注意:
1. 一个Thread实例只能调用一次start()函数, 否则会抛出异常
2. 如果使用一个Runnable对象初始化多个Thread, 则这些线程共享Runnable中的变量


### 线程安全

如果一个类在单线程环境下能正常工作, 并且在多线程环境下, 其使用方能够不必为其做任何改变的使用, 则称此类是线程安全的. 

### 原子性

对于涉及访问共享变量的操作, 若该操作从其执行线程以外的任何线程来看都是不可分割的, 则称该操作是 **原子操作**, 相应的称此操作具有 **原子性**

例如ATM机的取款操作是具有原子性的, 要么取款成功, 要么取款失败, 不存在中间的状态. 

Java中实现原子性的主要方法是使用锁, 此外Java保证除了long/double以外的所有变量的写操作都是原子的(要么完成数据更新, 要么没有更新, 不会因为更新操作产生第三种结果). 


注意:除了long/double类型以外的任意的Java赋值操作都是原子的, 可以充分利用这一特点来保证线程安全, 例如

``` java
public void updateHostInfo(String IP, int port){
    HostInfo info = new HostInfo(IP, port);
    this.hostinfo = info;
}
```

由于赋值操作是原子的, 因此上述更新操作要么没有进行, 要么完成更新, 从而不加锁也能保证线程安全. 


### 公平调度与非公平调度
公平调度指各线程按照先来先得的规则获得资源, 而非公平调度指 **允许** 后来的线程先获得资源.  非公平性调度往往指允许不公平的资源调度而不是刻意造成不公平的调度. 

对于公平调度, 对于某个需要申请的资源, 资源调度器会维护一个等待队列, 需要申请相关资源的线程先被暂停并存放到队列之中, 待资源可用后队列最前端的线程被唤醒, 获得相应的资源后继续执行. 

而非公平模式下, 允许新到来的还出于RUNNABLE状态的线程C跳过整个等待队列直接获得资源, 由于唤醒线程需要一段时间, 因此如果位于等待队列中的线程B在唤醒之前C就完成操作并释放锁, 则系统在B无影响的状态下实现了吞吐量的提升. 

因此非公平调度往往比公平调度有更高的吞吐率, 但由于分配时机不确定, 因此容易导致线程饥饿问题. 


Thread方法介绍
--------------------

### API简介

方法           | 功能                                    | 说明
--------------|-----------------------------------------|------------------------------------------------
currentThread | 获得执行当前代码的进程对应的Thread对象     | 静态方法/native方法
getName       | 获得当前线程的名字                        | 可有构造函数指定或者默认为`Thread-XXX`类型的名字
join          | 等待相应的线程结束                        | A调用B.join(), 则B结束后A才继续执行
yield         | 向进程调度器表明希望放弃对处理器的占用      | 静态方法/此请求并非强制执行
isAlive       | 判断当前进程是否处于活动状态               | 活动状态指线程处于开始执行且尚未结束的状态
sleep         | 让正在执行该语句的线程休眠指定毫秒          | 如果被中断会抛出异常并清除中断状态
setDaemon     | 设置当前线程是否为守护线程                 | 如果当前运行的所有线程都是守护线程, 则JVM自动退出
interrupt     | 将调用此方法的线程设置为中断状态            | 通过中断状态控制线程的状态
isInterrupted | 判断调用此方法的线程是否处于中断状态        | 检测到中断状态后可以自行控制优雅的退出

### 线程名称

Thread的构造函数如下:

``` java
public Thread() {
    init(null, null, "Thread-" + nextThreadNum(), 0);
}

public Thread(Runnable target) {
    init(null, target, "Thread-" + nextThreadNum(), 0);
}

public Thread(Runnable target, String name) {
    init(null, target, name, 0);
}
```
如果直接继承Thread类, 那么默认的产生一个类似`Thread-0`, `Thread-1`的名字. 如果使用Runable构造且指定了线程名, 那么使用设定的名字, 否则和直接继承Thread一样使用

对于main方法对应的线程, 则名称始终都是`main`. 结合currentThread()方法可以发现, 一个Thread实例中, 只有run()方法内处于另外一个线程, 而其他方法都属于调用者线程.

在创建线程时, 最好能指定一个合适的名字, 例如HttpService, 从而可以减少调试的难度. 


### 线程中断

调用interrupt()并不会导致线程中断, 而实际上是标记当前线程处于中断状态. 在线程的run方法中可以检测是否处于中断状态, 进而执行相应的操作, 使自己优雅的退出. 


``` java
public class Run extends Thread {
    public void run() {
        super.run();
        try {
            for(int i=0;i<500000;i++) {
                System.out.println("Print i = "+i);
                if(Thread.currentThread().isInterrupted()) {
                    throw new InterruptedException();
                }
            }
            System.out.println("非中断情况下才输出的内容");
        }
        catch (InterruptedException e) {
            return;
        }
    }
    
    public static void main(String[] args) throws InterruptedException {
        Run mythread = new Run();
        mythread.start();
        Thread.sleep(10);
        mythread.interrupt();
    }
}
```

函数              |  作用                          | 中断标记   | 函数类型
------------------|-------------------------------|------------|--------------
interrupted()     | 测试 **当前线程** 是否中断      | 调用后清除 | 静态方法
isInterrupted()   | 测试调用此方法的线程对象是否中断 | 不清除     | 成员方法


例如在main函数中有一个Thread对象`t`, 则在main函数中使用`Thread.interrupted()`判断main线程是否被中断, 使用`t.isInterrupted()`才判断t对应的线程是否中断. 显然从更加符合逻辑的角度来看, 如果需要判断当前线程是否中断, 应该使用成员方法`isInterrupted()`.

与手动设置中断标记相比, 使用`interrupt()`方法的优势在于线程内部执行`sleep()`等方法时, 可以触发这些方法抛出`InterruptedException`, 从而能够离开`sleep()`方法. 

一旦触发了异常, 则中断标记被清除, 在线程内部可以在此设置中断标记, 使得程序在完成收尾工作后退出.


### 线程优先级

setPriority()方法设置线程的执行优先级, 高优先级的线程由更多机会被执行, 但具体执行顺序仍然是随机的.  高优先级的线程由于有更多机会获得CPU时间, 因此通常在同样的任务量下有更短的执行时间. 



并发访问
--------------------

### 变量访问
局部变量的访问是安全的.  一个变量是否安全的依据是该变量是否可能被共享, 由于每个函数的局部变量都是独占的, 因此局部变量永远是安全的.  

对于实例变量, 由于变量可能被多个线程访问, 因此有可能造成变量的读写错误. 

### volatile关键字

在JVM中不同的线程有拥有一个私有的堆栈, 在以Server模式启动的JVM中, 线程的所有变量都会从私有堆栈读取, 这会导致一个线程更新了变量以后(更新到公共堆栈), 无法影响到其他线程的变量(私有堆栈的值没有变). 

使用volatile关键字声明的变量会强制JVM每次都从公共堆栈读取该变量的值. 

注意: volatile关键字并不保证原子性, 多个线程同时读写时, 还是需要加锁. 而且如果变量读取加锁了, 则也没有必要使用volatile关键字, 因为synchronized关键字具有volatile关键字等价的效果. 

### synchronized关键字
synchronized关键字修饰一个方法, 表示对该方法锁定, 所有访问该方法的线程都需要排队, 依次的访问. 

synchronized关键字有五类用法

用法                          | 含义
------------------------------|---------------------------------------
synchronized(obj) { ... }     | 执行括号内代码前需要获得对象实例obj的锁
直接修饰实例方法               | 执行该方法前需要获得此对象的锁
synchronized(this){ ... }     | 与直接修饰实例方法效果等价
直接修饰静态方法               | 执行该方法前需要获得此类的锁
synchronized(X.class){ ... }  | 与直接修饰静态方法效果等价

synchronized关键字根据需要的锁决定是否需要排队,  如果两个线程需要同一个锁, 则依次排队访问, 但如果需要的锁不同, 则互不影响. 所以synchronized修饰的实例方法和synchronized修饰的静态方法由于锁不同, 两类方法调用不需要竞争锁. 

``` java
public void serciveMenthod() {
    try{
        synchronized(this) {
            // 具体需要同步的操作
        }
    }
    catch(InterruptedException e){
        e.printStackTrace();
    }
}
```
synchronized(this)获得此对象的锁与直接修饰实例方法的锁相同, 因此此部分代码和直接修饰的实例方法不能同时执行.  使用synchronized(this)方法的代码区域可以控制, 因此粒度更低, 对其他线程的影响更小.  类似地, 使用synchronized(XXX.class)可以获得XXX类的锁并将范围控制在更细粒度. 


> 注意： synchronized锁定的是对象实例. 即如果有多个线程访问同一个对象的synchronized修饰的方法, 则这些线程需要排队, 但如果是多个线程访问多个对象的synchronized修饰的方法, 则相互没有影响. 


### synchronized特性

特性        | 解释
-----------|-----------------------------------------------------------
可重入      | 当一个线程获得锁后, 如果再次请求获得锁, 则可以再次立即获得锁
异常释放    | 当一个线程执行的代码出现异常时, 其持有的所有锁都释放
非继承      | 锁定不具有继承性
非公平调度   | JVM默认使用非公平调度, 需要其他调度模式时需要使用Lock的有关类



进程间通信
----------------

#### 等待/通知机制

Java在Object中提供了wait()和notify()方法来实现进程间的通信. 其中wait()方法用于将当前进程进入等待状态, notify()方法随机唤醒一个调用了wait()方法的线程并使其进入就绪队列, 等待被调度器选中后继续执行.

由于这两个方法是Object方法, 因此可以在任意对象上调用这些方法. 但在调用之前, 必须获得调用对象的锁, 即通过synchronized锁定相应的对象, 例如

```java
public static void fun(Object obj) {
    synchronized(obj) {
        obj.wait();
    }
}
```

如果不获得锁就直接调用, 则会抛出`java.lang.IllegalMonitorStateException`, 这个异常的字面意思上时说对象监视器状态异常, 实际上就是指没有获得对象级别的锁.

> 注意: 由于Thread的其他API使用了wait机制, 因此不要将Thread实例作为wait调用的对象.

-----

调用wait()方法的线程会立即释放对象锁, 而执行notify()方法的线程会等到正在执行的方法结束后才会释放锁. 同样被唤醒的线程也不会立即执行, 而是等再次获得对象锁以后才执行.

以下代码演示了基本的等待/通知机制
``` java
public static void main(String[] args) throws InterruptedException {
        final Object lock = new Object();
        final ExecutorService executorService = Executors.newFixedThreadPool(2);

        executorService.submit(() -> {
            synchronized (lock) {
                try {
                    System.out.println("Thread 1 Wait");
                    lock.wait();
                    System.out.println("Thread 1 Finish");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        executorService.submit(() -> {
            synchronized (lock) {
                try {
                    System.out.println("Thread 2 Wait");
                    lock.wait();
                    System.out.println("Thread 2 Finish");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        Thread.sleep(300);

        synchronized (lock) {
            System.out.println("Main Thread notifyAll");
            lock.notifyAll();
        }

        Thread.sleep(300);

        executorService.shutdown();

}
```

如果有多个线程在一个监视器上使用wait()方法, 则当其他线程调用此监视器的notify()方法时, 会随机唤醒一个线程, 使用notifyAll()则会唤醒使用此监视器上的所有线程. 

notify()方法不保证一定会唤醒一个线程, 可以多次调用notify()方法, 如果调用时没有等待状态的线程, 则此方法不产生任何效果.

可以使用wait(long)方法来限定一个时间, 到达时间后如果没有被唤醒, 则自动被唤醒


#### wait()方法与interrupt()方法

一个线程如果执行了wait()方法进入等待状态后调用interrupt方法, 则会产生`java.lang.InterruptedException`异常. 以下代码显示此过程
``` java
public class Run extends Thread {
    public static void main(String[] args) throws InterruptedException {
        Object lock = new Object();
        ThreadA a = new ThreadA(lock);
        a.start();
        Thread.sleep(1000);
        a.interrupt();
    }
}


class Service {
    public void testMethod(Object lock) {
        try {
            synchronized (lock) {
                System.out.println("Begin Wait");
                lock.wait();
                System.out.println("End Wait");
            }
        } catch (InterruptedException e) {
            System.out.println("出现了异常, 锁已经被释放了");
            e.printStackTrace();
        }


    }
}

class ThreadA extends Thread{
    private Object lock;
    public ThreadA(Object lock) {
        super();
        this.lock = lock;
    }    
    public void run() {
        Service service = new Service();
        service.testMethod(lock);
    }
}
```

#### join方法

调用join()方法的线程等待被调用join()方法的线程执行结束. 例如有一个线程对象t, 若在主线程上调用t.join(), 则在t执行完毕后main才能继续执行. join()方法适合在主线程需要等待子线程执行完毕后才执行的场合. 

使用join(long)方法可以指定一个最大时间, 到达最大时间后即使子线程还未执行完毕主线程也会继续执行.

join()方法本质上是将线程对象t作为目标调用wait()方法, 因此调用join()后会释放锁, 从而其他线程可以执行其他的锁定方法, 并且如果当前线程被中断, 也会产生中断异常. join方法的源代码如下所示:


``` java
public final synchronized void join(long millis) throws InterruptedException {
    long base = System.currentTimeMillis();
    long now = 0;

    if (millis < 0) {
        throw new IllegalArgumentException("timeout value is negative");
    }

    if (millis == 0) {
        while (isAlive()) {
            wait(0);
        }
    } else {
        while (isAlive()) {
            long delay = millis - now;
            if (delay <= 0) {
                break;
            }
            wait(delay);
            now = System.currentTimeMillis() - base;
        }
    }
}
```


> 由于join的这种设计, 因此使用wait()/notify()机制时, 不应该把Thread的实例作为调用对象, 否则可能干扰系统API的使用, 或者被系统API干扰.
