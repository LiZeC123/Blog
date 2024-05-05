---
title: Java源码分析之集合数据结构
date: 2021-09-09 10:04:08
categories: Java源码分析
tags:
    - Java
cover_picture: images/java.jpg
---






HashMap
----------------

HashMap是是经典的数据结构, 也是Java最常用的数据结构之一. 由于HashMap不涉及多线程问题, 且作者 因此代码理解难度比较低, 非常值得一读.

> HashMap的源码真的有一种作者希望我能看懂的感觉


- 如果多个Key具有同样的Hash值, 但Key本身是Comparable的, 那么将通过比较的方式减少Key冲突造成的



### 计算哈希值

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

将对象的哈希值与高16位做异或操作, 从而保证高位的bit能够影响到低位的bit. 由于HashMap只根据当前table的大小是否部分的低位bit,因此这一操作有助于提高Hash函数的不一致性, 减少冲突.

> 注意在表达式中赋值的用法, 为了简化代码, HashMap中大量使用了此技巧

### 构造函数

```java
public HashMap(int initialCapacity, float loadFactor) {
    if (initialCapacity < 0)
        throw new IllegalArgumentException("Illegal initial capacity: " +
                                            initialCapacity);
    if (initialCapacity > MAXIMUM_CAPACITY)
        initialCapacity = MAXIMUM_CAPACITY;
    if (loadFactor <= 0 || Float.isNaN(loadFactor))
        throw new IllegalArgumentException("Illegal load factor: " +
                                            loadFactor);
    this.loadFactor = loadFactor;
    this.threshold = tableSizeFor(initialCapacity);
}
```

构造函数中是一些检查操作. 注意, 此时并没有分配任何的内存, 因为HashMap采取了惰性加载机制, 只有真的开始使用HashMap的时候才会分配内存.


### 添加数据

```java
final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
    int s = m.size();
    if (s > 0) {
        if (table == null) { // pre-size
            float ft = ((float)s / loadFactor) + 1.0F;
            int t = ((ft < (float)MAXIMUM_CAPACITY) ?
                        (int)ft : MAXIMUM_CAPACITY);
            if (t > threshold)
                threshold = tableSizeFor(t);
        }
        else if (s > threshold)
            resize();
        for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
            K key = e.getKey();
            V value = e.getValue();
            putVal(hash(key), key, value, false, evict);
        }
    }
}
```

当实际向HashMap中添加数据后, 进入此方法. 此方法实际上包含两个逻辑分支, 即如果还没有初始化(`table == null`)或者需要扩容(`s > threshold`)则调用对应的方法进行初始化或者扩容. 否则正常的添加数据.


### 扩容操作

```java
final Node<K,V>[] resize() {
    Node<K,V>[] oldTab = table;
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    int oldThr = threshold;
    int newCap, newThr = 0;

    // 此部分计算容量, 按照出现概率, 最容易出现的情况最先判断
    if (oldCap > 0) {
        if (oldCap >= MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                    oldCap >= DEFAULT_INITIAL_CAPACITY)
            newThr = oldThr << 1; // double threshold
    }
    else if (oldThr > 0) // initial capacity was placed in threshold
        newCap = oldThr;
    else {               // zero initial threshold signifies using defaults
        newCap = DEFAULT_INITIAL_CAPACITY;
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                    (int)ft : Integer.MAX_VALUE);
    }
    threshold = newThr;
    
    //此部分执行具体的扩容操作
    @SuppressWarnings({"rawtypes","unchecked"})
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    if (oldTab != null) {
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                oldTab[j] = null;
                if (e.next == null)
                    // 单一节点按照高位重新分布
                    newTab[e.hash & (newCap - 1)] = e;
                else if (e instanceof TreeNode)
                    // 树节点执行分裂操作
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // preserve order
                    // 链表节点分裂成两个链表
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    do {
                        next = e.next;
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

第一段if-else语句重新计算了容量. 这一段是按照出现概率写的, 即普通的扩容操作最常见,因此在第一个if中处理, 而初始化操作只会执行一次, 因此最后处理.

扩容操作很简单, 根据节点类型进行分裂即可. 由于HashMap的大小始终是2的幂, 因此最需要按照哈希值的最高位重新分布即可.



### 参考资料

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



JDK集合类归纳
------------------

- [Java语法总结--Java集合类](https://www.cnblogs.com/zhouyuqin/p/5168573.html)
- [排序算法时间复杂度、空间复杂度、稳定性比较](https://blog.csdn.net/yushiyi6453/article/details/76407640)
