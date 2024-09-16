---
title: Redis源码分析笔记之指令执行
math: false
date: 2024-06-12 09:25:57
categories: Redis笔记
tags:
    - Redis
cover_picture: images/redis.jpg
---

内容施工中, 请稍后查看...


Redis对象
-------------

Redis中最核心的数据结构是Redis对象, Redis中几乎所有东西最终都以Redis对象的形式表示,  其定义如下

```c
struct redisObject {
    unsigned type:4;
    unsigned encoding:4;
    unsigned lru:LRU_BITS; /* LRU time (relative to global lru_clock) or
                            * LFU data (least significant 8 bits frequency
                            * and most significant 16 bits access time). */
    int refcount;
    void *ptr;
};
```

其中使用位域的方式定义了三个变量, 表示数据类型的`type`字段和表示编码类型的`encoding`字段公用1字节, 而实现缓存淘汰策略的`lru`字段使用剩余的3字节.

> 缓存淘汰算法最常用的是LRU(记录最近一次访问时间)和LFU(记录访问的次数, 和访问的时间).

`refcount`是引用计数, 使得一个`redisObject`可以在不同的位置进行共享, 从而避免重复的内存分配行为. `ptr`是指向具体数据结构的指针.

### 数据类型与编码

数据类型的具体定义如下, 其中大部分类型在[Redis源码分析笔记之数据结构 | LiZeC的博客](https://lizec.top/2024/03/22/Redis%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90%E7%AC%94%E8%AE%B0%E4%B9%8B%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84/)中已有介绍, 可查阅此文章进一步了解相关实现的细节.

```c
/* The actual Redis Object */
#define OBJ_STRING 0    /* String object. */
#define OBJ_LIST 1      /* List object. */
#define OBJ_SET 2       /* Set object. */
#define OBJ_ZSET 3      /* Sorted set object. */
#define OBJ_HASH 4      /* Hash object. */

/* The "module" object type is a special one that signals that the object
 * is one directly managed by a Redis module. In this case the value points
 * to a moduleValue struct, which contains the object value (which is only
 * handled by the module itself) and the RedisModuleType struct which lists
 * function pointers in order to serialize, deserialize, AOF-rewrite and
 * free the object.
 *
 * Inside the RDB file, module types are encoded as OBJ_MODULE followed
 * by a 64 bit module type ID, which has a 54 bits module-specific signature
 * in order to dispatch the loading to the right module, plus a 10 bits
 * encoding version. */
#define OBJ_MODULE 5    /* Module object. */
#define OBJ_STREAM 6    /* Stream object. */
#define OBJ_TYPE_MAX 7  /* Maximum number of object types */
```

-------------------------------------------------------------

编码类型的具体定义如下

```c
#define OBJ_ENCODING_RAW 0     /* Raw representation */
#define OBJ_ENCODING_INT 1     /* Encoded as integer */
#define OBJ_ENCODING_HT 2      /* Encoded as hash table */
#define OBJ_ENCODING_ZIPMAP 3  /* No longer used: old hash encoding. */
#define OBJ_ENCODING_LINKEDLIST 4 /* No longer used: old list encoding. */
#define OBJ_ENCODING_ZIPLIST 5 /* No longer used: old list/hash/zset encoding. */
#define OBJ_ENCODING_INTSET 6  /* Encoded as intset */
#define OBJ_ENCODING_SKIPLIST 7  /* Encoded as skiplist */
#define OBJ_ENCODING_EMBSTR 8  /* Embedded sds string encoding */
#define OBJ_ENCODING_QUICKLIST 9 /* Encoded as linked list of listpacks */
#define OBJ_ENCODING_STREAM 10 /* Encoded as a radix tree of listpacks */
#define OBJ_ENCODING_LISTPACK 11 /* Encoded as a listpack */
#define OBJ_ENCODING_LISTPACK_EX 12 /* Encoded as listpack, extended with metadata */
```

其中大部分编码类型在之前的文章中也有介绍. 对于某一特定的类型, Redis可能根据其实际存储的数据, 选择不同的编码类型.

这里需要展开说明一下`OBJ_ENCODING_EMBSTR`编码类型. 在`redisObject`中实际存储的数据通过`ptr`访问, 分散存储将导致CPU的缓存命中情况较低, 不利于性能. 因此在`OBJ_ENCODING_EMBSTR`模式下, 将会在`ptr`指针之后直接分配一个`sds`存储对应的数据, 从而使相应的数据在内存中连续分布.


### 缓存淘汰算法

对于LRU算法, 其实现较为简单, 仅需要比较最近访问时间即可得到分数的高低. 访问时间离当前时刻越近的key得分越高.

对于LFU算法, 其中记录的访问的次数和最近一次访问的时间. 在更新此字段时不可直接对访问次数进行累加, 而需要根据上一次访问时间进行衰减, 使得较长时间未访问的Kye的LFU分数下降. 其算法如下

```c
unsigned long LFUDecrAndReturn(robj *o) {
    unsigned long ldt = o->lru >> 8;
    unsigned long counter = o->lru & 255;
    unsigned long num_periods = server.lfu_decay_time ? LFUTimeElapsed(ldt) / server.lfu_decay_time : 0;
    if (num_periods)
        counter = (num_periods > counter) ? 0 : counter - num_periods;
    return counter;
}
```

> 基本上可以理解为上次访问到现在经过了多少个`lfu_decay_time`, 那么counter就减少相应的次数