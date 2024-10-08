---
title: Redis源码分析笔记之数据结构
math: false
date: 2024-03-22 22:54:02
categories: Redis笔记
tags:
    - Redis
cover_picture: images/redis.jpg
---

Redis是一个C语言实现的高性能内存数据库, 在日常的业务开发过程中, Redis占据重要的地位. 因此阅读和学习Redis源代码有助于理解Redis的具体实现原理, 从而更好的将其运用到业务开发过程之中.

同时Redis源码本身由C语言实现, 因此并不包含复杂的语言特性, 相对较为容易阅读. 阅读这些代码也可以学习如何写出简洁的代码. 本文主要介绍Redis中使用的数据结构, 理解这些数据结构的功能与实现是阅读后续的高层次代码的基础.



Redis代码阅读环境准备
----------------------

Redis项目在Github上开源, 因此可借助Github的Codespace功能快速的构建一个阅读环境. 首先打开Redis的[官方仓库](https://github.com/redis/redis), 将代码fork一份到自己的账号下. 然后在自己的仓库页面按下`,`键, 对当前仓库启用Codespace.

根据以上两步, 即可快速的获得一个可在浏览器中使用的代码阅读环境. 由于Codespace已经安装好了依赖, 因此甚至可以在此环境中尝试编译和调试Redis本身.

> 感谢Github和Vscode提供的能力, 现在想学习一个项目可容易太多了.

在阅读实际代码之前, 建议先仔细阅读一遍Redis项目的ReadMe, 此文件不仅详细介绍了如何编译和测试Redis, 还简要介绍了Redis的项目结构, 核心的数据结构和对应的实现所在的文件. 可谓是没有一句废话的介绍了Redis最主要的内容.


简单动态字符串
----------------

简单动态字符串(Simple Dynamic Strings, SDS)是Redis的基本数据结构之一, 用于存储字符串和整型数据. 对应的源码文件为`sds.h`和`sds.c`. SDS库的目标是实现一个可动态扩容的, 二进制安全的, 兼容C语言标准的字符串类型.

由于C语言的字符串使用`\0`表示字符串结尾, 因此如果一个字符串本身就包含`\0`, 则会被此字符截断, 导致字符串处理异常. 而二进制安全要求即使字符串本身包含`\0`, 也可以正确的处理字符串.

为了实现上述目标, 则需要对字符串长度进行记录, 从而能够准确的得知字符串的长度. 而为了实现可动态扩容, 每次分配的空间可能比字符串实际需要的空间更多, 此时需要记录剩余空间的大小. 

### 内存结构

基于以上考虑, 可以看到SDS的结构体定义如下

```c
struct __attribute__ ((__packed__)) sdshdr8 {
    uint8_t len; /* used */
    uint8_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
```
其中`sdshdr8`表示记录长度的字段使用8bit的变量, 因此SDS同理定义了`sdshdr16`, `sdshdr32`, `sdshdr64`, 这些结构体的主体结构完全相同, 仅len字段和alloc字段的长度不一致. 

> buf字段使用了C语言柔性数组特性. 在创建SDS结构体时, buf数组的长度取决于malloc函数分配的空间大小. 

结构体中的flags字段定义了SDS的类型, 例如结构体为`sdshdr8`时, 取值为`SDS_TYPE_8=1`. 在实际使用时, SDS实际会返回buf数组的地址, 使用buf[-1]即可访问到flags变量, 再根据flags变量的值可以得知len变量和alloc变量的具体长度. 获取SDS长度的函数很好的展示了上述的取值逻辑

```c
#define SDS_HDR(T,s) ((struct sdshdr##T *)((s)-(sizeof(struct sdshdr##T))))

static inline size_t sdslen(const sds s) {
    unsigned char flags = s[-1];
    switch(flags&SDS_TYPE_MASK) {
        case SDS_TYPE_5:
            return SDS_TYPE_5_LEN(flags);
        case SDS_TYPE_8:
            return SDS_HDR(8,s)->len;
        case SDS_TYPE_16:
            return SDS_HDR(16,s)->len;
        case SDS_TYPE_32:
            return SDS_HDR(32,s)->len;
        case SDS_TYPE_64:
            return SDS_HDR(64,s)->len;
    }
    return 0;
}
```

`__attribute__ ((__packed__))`标记表明取消结构体字段对齐. 通常情况下, 由于结构体对齐的特性, flags字段虽然仅声明1字节空间, 但实际会占据4字节空间. 禁用对齐后, flags字段仅占据1字节空间, 后面直接就是buf变量的空间. 

> 此标记既可以节省数据结构占据的空间, 又能保证buf[-1]必定可访问到flags变量, 可谓是一举两得, 太妙了


### 创建

```c
/* Create a new sds string with the content specified by the 'init' pointer
 * and 'initlen'.
 * If NULL is used for 'init' the string is initialized with zero bytes.
 * If SDS_NOINIT is used, the buffer is left uninitialized;
 *
 * The string is always null-terminated (all the sds strings are, always) so
 * even if you create an sds string with:
 *
 * mystring = sdsnewlen("abc",3);
 *
 * You can print the string with printf() as there is an implicit \0 at the
 * end of the string. However the string is binary safe and can contain
 * \0 characters in the middle, as the length is stored in the sds header. */
sds _sdsnewlen(const void *init, size_t initlen, int trymalloc) {
    void *sh;
    sds s;
    char type = sdsReqType(initlen);
    /* Empty strings are usually created in order to append. Use type 8
     * since type 5 is not good at this. */
    if (type == SDS_TYPE_5 && initlen == 0) type = SDS_TYPE_8;
    int hdrlen = sdsHdrSize(type);
    unsigned char *fp; /* flags pointer. */
    size_t usable;

    assert(initlen + hdrlen + 1 > initlen); /* Catch size_t overflow */
    sh = trymalloc?
        s_trymalloc_usable(hdrlen+initlen+1, &usable) :
        s_malloc_usable(hdrlen+initlen+1, &usable);
    if (sh == NULL) return NULL;
    if (init==SDS_NOINIT)
        init = NULL;
    else if (!init)
        memset(sh, 0, hdrlen+initlen+1);
    s = (char*)sh+hdrlen;
    fp = ((unsigned char*)s)-1;
    usable = usable-hdrlen-1;
    if (usable > sdsTypeMaxSize(type))
        usable = sdsTypeMaxSize(type);
    switch(type) {
        case SDS_TYPE_5: {
            *fp = type | (initlen << SDS_TYPE_BITS);
            break;
        }
        case SDS_TYPE_8: {
            SDS_HDR_VAR(8,s);
            sh->len = initlen;
            sh->alloc = usable;
            *fp = type;
            break;
        }
        case SDS_TYPE_16: {
            SDS_HDR_VAR(16,s);
            sh->len = initlen;
            sh->alloc = usable;
            *fp = type;
            break;
        }
        case SDS_TYPE_32: {
            SDS_HDR_VAR(32,s);
            sh->len = initlen;
            sh->alloc = usable;
            *fp = type;
            break;
        }
        case SDS_TYPE_64: {
            SDS_HDR_VAR(64,s);
            sh->len = initlen;
            sh->alloc = usable;
            *fp = type;
            break;
        }
    }
    if (initlen && init)
        memcpy(s, init, initlen);
    s[initlen] = '\0';
    return s;
}
```

在理解了SDS的内存结构后, 创建过程的逻辑可以说是非常的简单. 其中`s_trymalloc_usable`和`s_malloc_usable`是Redis封装的两个内存申请函数, 从名字可以看出, 前者不要求内存分配必须成功. 两个函数中的`usable`是指Redis会通过`malloc_size`获取本次内存分配的实际块大小, 并直接将内存扩展到这个块大小.


### 扩容

```c
/* Enlarge the free space at the end of the sds string so that the caller
 * is sure that after calling this function can overwrite up to addlen
 * bytes after the end of the string, plus one more byte for nul term.
 * If there's already sufficient free space, this function returns without any
 * action, if there isn't sufficient free space, it'll allocate what's missing,
 * and possibly more:
 * When greedy is 1, enlarge more than needed, to avoid need for future reallocs
 * on incremental growth.
 * When greedy is 0, enlarge just enough so that there's free space for 'addlen'.
 *
 * Note: this does not change the *length* of the sds string as returned
 * by sdslen(), but only the free buffer space we have. */
sds _sdsMakeRoomFor(sds s, size_t addlen, int greedy) {
    void *sh, *newsh;
    size_t avail = sdsavail(s);
    size_t len, newlen, reqlen;
    char type, oldtype = s[-1] & SDS_TYPE_MASK;
    int hdrlen;
    size_t usable;

    /* Return ASAP if there is enough space left. */
    if (avail >= addlen) return s;

    len = sdslen(s);
    sh = (char*)s-sdsHdrSize(oldtype);
    reqlen = newlen = (len+addlen);
    assert(newlen > len);   /* Catch size_t overflow */
    if (greedy == 1) {
        if (newlen < SDS_MAX_PREALLOC)
            newlen *= 2;
        else
            newlen += SDS_MAX_PREALLOC;
    }

    type = sdsReqType(newlen);

    /* Don't use type 5: the user is appending to the string and type 5 is
     * not able to remember empty space, so sdsMakeRoomFor() must be called
     * at every appending operation. */
    if (type == SDS_TYPE_5) type = SDS_TYPE_8;

    hdrlen = sdsHdrSize(type);
    assert(hdrlen + newlen + 1 > reqlen);  /* Catch size_t overflow */
    if (oldtype==type) {
        newsh = s_realloc_usable(sh, hdrlen+newlen+1, &usable);
        if (newsh == NULL) return NULL;
        s = (char*)newsh+hdrlen;
    } else {
        /* Since the header size changes, need to move the string forward,
         * and can't use realloc */
        newsh = s_malloc_usable(hdrlen+newlen+1, &usable);
        if (newsh == NULL) return NULL;
        memcpy((char*)newsh+hdrlen, s, len+1);
        s_free(sh);
        s = (char*)newsh+hdrlen;
        s[-1] = type;
        sdssetlen(s, len);
    }
    usable = usable-hdrlen-1;
    if (usable > sdsTypeMaxSize(type))
        usable = sdsTypeMaxSize(type);
    sdssetalloc(s, usable);
    return s;
}
```

`_sdsMakeRoomFor`是SDS扩容的核心函数. 作为一个单线程下的扩容函数, 其逻辑非常直白. 

1. 如果当前空间已经满足需求, 则直接返回
2. 如果当前需要扩容, 且扩容后SDS类型不发生改变, 则使用`s_realloc_usable`函数扩容. 基于`realloc`函数的特性, 这一操作可能会原地扩展空间, 也可能导致数据复制.
3. 如果类型发生变化, 则创建一个新的SDS对象, 将原有数据复制到新的对象后释放旧对象

### 其他函数

SDS库中其他的函数基本上与常规的字符串处理函数类似, 逻辑也相对比较简单, 此处不再具体解读, 可直接查看Redis源码进行学习.


跳跃表
-------------

跳跃表是一种链表结构, 其中的元素按照顺序排列, 并且不同的链表节点具有不同的层高, 从而在查询数据的时候, 能够跳过一些节点实现O(logN)的时间复杂度. 跳跃表实现的效果与红黑树类似, 但相较于红黑树复杂的旋转和染色操作, 跳跃表的实现相对更为简单直接.

![跳跃表结构示意](/images/redis/跳跃表结构示意图.jpg)

> 跳跃表的结构实际上基本等价于二叉树, 因此可以容易的推测出其查询复杂度大约为O(logN)

跳跃表是Redis中ZSET的底层数据结构. ZSET是一个类似于哈希表的数据结构, 但其中的每个对象可以附加一个分数, Redis保证可以高效的按照分数的大小顺序来遍历ZSET中的项目.

### 数据结构

跳跃表的结构信息定义在`server.h`文件中, 具体如下

```c
typedef struct zskiplistNode {
    sds ele;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned long span;
    } level[];
} zskiplistNode;

typedef struct zskiplist {
    struct zskiplistNode *header, *tail;
    unsigned long length;
    int level;
} zskiplist;

typedef struct zset {
    dict *dict;
    zskiplist *zsl;
} zset;
```

`zskiplistNode`是跳跃表的节点接口, 其中`ele`是存储的对象, 其类型是上一节介绍的简单动态字符串. `score`是该数据的分数, 用于排序. `backward`是反向指针, 指向该节点的上一个元素(因此跳跃表是一个双向链表, 从而支持两个方向的遍历). `zskiplistLevel`是一个柔性数组, 实际就是每一层的节点结构. 其中每一层包含两个元素, `forward`指向下一个节点, `span`表示跨越的节点数量.

Redis中使用`zskiplist`管理跳跃表, 其中包含指向头尾节点的指针, 跳跃表的元素数量以及跳跃表的高度. 最后可以看到, ZSET实际上就是哈希表+跳跃表, 其中哈希表用于存储数据, 跳跃表用于使数据保持顺序.


### 创建跳跃表

```c
zskiplist *zslCreate(void) {
    int j;
    zskiplist *zsl;

    zsl = zmalloc(sizeof(*zsl));
    zsl->level = 1;
    zsl->length = 0;
    zsl->header = zslCreateNode(ZSKIPLIST_MAXLEVEL,0,NULL);
    for (j = 0; j < ZSKIPLIST_MAXLEVEL; j++) {
        zsl->header->level[j].forward = NULL;
        zsl->header->level[j].span = 0;
    }
    zsl->header->backward = NULL;
    zsl->tail = NULL;
    return zsl;
}

zskiplistNode *zslCreateNode(int level, double score, sds ele) {
    zskiplistNode *zn =
        zmalloc(sizeof(*zn)+level*sizeof(struct zskiplistLevel));
    zn->score = score;
    zn->ele = ele;
    return zn;
}
```

创建`zskiplist`的逻辑比较简单, 给数组分配空间后填充对应的初始值即可. 其中`ZSKIPLIST_MAXLEVEL`在当前版本的定义为32, 因此头节点是一个具有32层的节点.

### 插入数据

对于一个经典的双向链表, 如果需要执行插入操作, 一般需要如下的步骤

1. 找到需要插入的项目在链表中的位置
2. 修改待插入位置前后Node的指针

对于跳跃表而言, 插入的主要过程也基本如同上述步骤, 仅因为存在多层链表, 可能需要进行多次操作而已.

```c
/* Insert a new node in the skiplist. Assumes the element does not already
 * exist (up to the caller to enforce that). The skiplist takes ownership
 * of the passed SDS string 'ele'. */
zskiplistNode *zslInsert(zskiplist *zsl, double score, sds ele) {
    zskiplistNode *update[ZSKIPLIST_MAXLEVEL], *x;
    unsigned long rank[ZSKIPLIST_MAXLEVEL];
    int i, level;

    serverAssert(!isnan(score));
    x = zsl->header;
    // 第一段for循环找到待插入节点在链表的位置
    // 由于跳跃表有多层, 因此需要使用update数组记录每一层待插入的位置的指针
    // rank数组记录了从头结点到update所在节点经历的节点数量, 用于在后续更新span的值, 即计算两个节点直接跨越了多少元素(等于两层rank的差值)
    for (i = zsl->level-1; i >= 0; i--) { // 逐层查找链表
        // 每一层都横向遍历元素, 直到找到目标元素待插入的位置
        // 注意: 当上一层不满足条件后, 进入下一层查找, 基于跳跃表的性质, 在下一层可能会继续前进若干元素, 而不可能出现越过位置的情况
        // 因此每一层的rank至少是等于上一层的rank, 如果本层又向前移动了节点, 则本层的rank还需要继续增加越过节点的span值
        /* store rank that is crossed to reach the insert position */
        rank[i] = i == (zsl->level-1) ? 0 : rank[i+1];

        while (x->level[i].forward &&
                (x->level[i].forward->score < score ||
                    (x->level[i].forward->score == score &&
                    sdscmp(x->level[i].forward->ele,ele) < 0)))
        {
            // 如果当前查询节点小于插入节点, 则继续前进
            rank[i] += x->level[i].span;
            x = x->level[i].forward;
        }
        update[i] = x; // update数组记录此时的元素指针, 用于后续更新
    }
    /* we assume the element is not already inside, since we allow duplicated
     * scores, reinserting the same element should never happen since the
     * caller of zslInsert() should test in the hash table if the element is
     * already inside or not. */
    level = zslRandomLevel();  // 按照概率得到一个当前待插入节点的高度
    if (level > zsl->level) {  // 如果随机高度大于当前的最大高度, 则更新头结点的对应层数上的指针, 使其
        for (i = zsl->level; i < level; i++) {
            rank[i] = 0;
            update[i] = zsl->header;
            update[i]->level[i].span = zsl->length; // 新引入的层由于还未链接到待插入节点, 因此span默认初始化为链表的长度
        }
        zsl->level = level;
    }
    x = zslCreateNode(level,score,ele); // 创建待插入节点, 核心逻辑与双向链表的插入并无区别, 仅存在多层需要多次处理而已
    for (i = 0; i < level; i++) {
        x->level[i].forward = update[i]->level[i].forward;
        update[i]->level[i].forward = x;

        /* update span covered by update[i] as x is inserted here */
        // rank[0] x在第0层的前一节节点距离头节点的位置, 由于第0层是连续的, 因此实际就是在链表中的位置, 例如此时取值为20
        // rank[i] x在第i层的前一个节点距离头节点的位置, 由于跳跃表的性质, 第i层可能会跳过一些节点直接链接x, 例如此时取值为15
        // 两者相减, 即为第i层的前一个节点与x之间跨越的元素数量, 从而需要相应的更新前一个节点的span值, 并可计算出x在当前层数的span值
        x->level[i].span = update[i]->level[i].span - (rank[0] - rank[i]);
        update[i]->level[i].span = (rank[0] - rank[i]) + 1;
    }

    // 对于更高层, 由于x节点没有这么多层, 因此对于这些层来说, 跨越的节点数量+1
    /* increment span for untouched levels */
    for (i = level; i < zsl->level; i++) {
        update[i]->level[i].span++;
    }

    // 调整反向指针, 调整头尾节点和链表长度
    x->backward = (update[0] == zsl->header) ? NULL : update[0];
    if (x->level[0].forward)
        x->level[0].forward->backward = x;
    else
        zsl->tail = x;
    zsl->length++;
    return x;
}
```

rank或者span数据对于构建跳跃表结构并无用处, 但对于查询第N个元素非常有帮助. 由于Redis支持查询第N个元素, 因此需要维护这些数据.

### 随机层高

Redis使用如下的函数得到一个随机的层数高度, 其中`ZSKIPLIST_P`当前取值为0.25

```c
int zslRandomLevel(void) {
    static const int threshold = ZSKIPLIST_P*RAND_MAX;
    int level = 1;
    while (random() < threshold)
        level += 1;
    return (level<ZSKIPLIST_MAXLEVEL) ? level : ZSKIPLIST_MAXLEVEL;
}
```

即有0.75的概率, 当前层高度为1, 0.25*0.75的概率当前层高度位2, 以此类推, 直到最多为32层

### 删除操作

在理解了插入操作后, 删除操作看起来比较简单, 同样是先计算update数组(过程与插入一致, 这里略过), 此后在每一层删除掉节点, 并更新span值即可

```c
void zslDeleteNode(zskiplist *zsl, zskiplistNode *x, zskiplistNode **update) {
    int i;
    for (i = 0; i < zsl->level; i++) {
        if (update[i]->level[i].forward == x) {
            update[i]->level[i].span += x->level[i].span - 1; // 如果这一层涉及待删除的节点, 这span需要加上被删除节点的值
            update[i]->level[i].forward = x->level[i].forward;
        } else {
            update[i]->level[i].span -= 1;                    // 如果这一层不涉及待删除的节点, span直接减一
        }
    }
    if (x->level[0].forward) {
        x->level[0].forward->backward = x->backward;
    } else {
        zsl->tail = x->backward;
    }
    while(zsl->level > 1 && zsl->header->level[zsl->level-1].forward == NULL) // 如果被删除的节点是最高节点, 则对应的处理头结点的值
        zsl->level--;
    zsl->length--;
}
```

### 总结

跳跃表作为一种可以保持元素顺序且查询效率达到O(logN)的数据结构, 其插入和删除过程与红黑树相比, 确实可以算得上简单易懂了. 如果不考虑span相关的逻辑, 甚至可以说是非常的简单直观. 但需要注意到, 跳跃表的层高并不是一种精心计算的结构, 而是直接引入概率的. 因此与红黑树在任何时候都较好的维持平衡性不同, 跳跃表的查询效率受到概率影响, 只能在平均层面上达到O(logN)的查询复杂度.

在Redis中, 跳跃表用于zset的底层实现, 但zset并不一定采取跳跃表. 仅当zset中的元素较多, 或者项目的长度较长时才会采取此数据结构, 否则Redis将采取另一种称为压缩列表的数据结构进行存储.


压缩表
--------

压缩表`ziplist`是一个基于字节数组的双向表结构, Redis的有序集合, 散列和列表都直接或者间接使用了压缩列表. 其中的元素按照顺序连续存储, 其基本结构如下所示

```
<zlbytes> <zltail> <zllen> <entry> <entry> ... <entry> <zlend>
```

启用`<entry>`表示具体存储的数据, 当插入或删除数据时, `ziplist`通过复制的方式移动数据的位置. `<entry>`结构如下所示

```
<prevlen> <encoding> <entry-data>
```

其中`<prevlen>`表示当且节点的前一个节点的长度, `<encoding>`表示本阶段编码类型, 包含了存储的内容结构以及本节数据的长度, `<entry-data>`为具体的数据. 在反向遍历压缩表时, 可通过`<prevlen>`计算出前一个节点的起始位置.

### 编码格式

`<encoding>`有多种表示方式, 具体如下所示

```
 * |00pppppp| - 1 byte
 *      String value with length less than or equal to 63 bytes (6 bits).
 *      "pppppp" represents the unsigned 6 bit length.
 * |01pppppp|qqqqqqqq| - 2 bytes
 *      String value with length less than or equal to 16383 bytes (14 bits).
 *      IMPORTANT: The 14 bit number is stored in big endian.
 * |10000000|qqqqqqqq|rrrrrrrr|ssssssss|tttttttt| - 5 bytes
 *      String value with length greater than or equal to 16384 bytes.
 *      Only the 4 bytes following the first byte represents the length
 *      up to 2^32-1. The 6 lower bits of the first byte are not used and
 *      are set to zero.
 *      IMPORTANT: The 32 bit number is stored in big endian.
 * |11000000| - 3 bytes
 *      Integer encoded as int16_t (2 bytes).
 * |11010000| - 5 bytes
 *      Integer encoded as int32_t (4 bytes).
 * |11100000| - 9 bytes
 *      Integer encoded as int64_t (8 bytes).
 * |11110000| - 4 bytes
 *      Integer encoded as 24 bit signed (3 bytes).
 * |11111110| - 2 bytes
 *      Integer encoded as 8 bit signed (1 byte).
 * |1111xxxx| - (with xxxx between 0001 and 1101) immediate 4 bit integer.
 *      Unsigned integer from 0 to 12. The encoded value is actually from
 *      1 to 13 because 0000 and 1111 can not be used, so 1 should be
 *      subtracted from the encoded 4 bit value to obtain the right value.
 * |11111111| - End of ziplist special entry.
```

基于以上定义, 一个ziplist可能具有如下的形式

```
 *  [0f 00 00 00] [0c 00 00 00] [02 00] [00 f3] [02 f6] [ff]
 *        |             |          |       |       |     |
 *     zlbytes        zltail     zllen    "2"     "5"   end
```

### 基础操作

`ziplist`由于仅顺序存储数据, 因此插入和删除操作实际并无特殊逻辑. 仅在插入或删除数据后, 需要根据节点情况适当的更新`<prevlen>`(并且该操作可能产生级联效果, 导致更多节点需要更新`<prevlen>`).


哈希表
---------

哈希表结构定义如下, Redis中的哈希表采取经典的哈希表实现, 即使用一个数组存储实际的元素, 通过哈希函数将key转换为数组的下标. 当下标冲突时, 使用链表法解决冲突.

因此, 

```c
struct dict {
    dictType *type;

    dictEntry **ht_table[2];
    unsigned long ht_used[2];

    long rehashidx; /* rehashing not in progress if rehashidx == -1 */

    /* Keep small vars at end for optimal (minimal) struct padding */
    int16_t pauserehash; /* If >0 rehashing is paused (<0 indicates coding error) */
    signed char ht_size_exp[2]; /* exponent of size. (size = 1<<exp) */
    int16_t pauseAutoResize;  /* If >0 automatic resizing is disallowed (<0 indicates coding error) */
    void *metadata[];  // 依然是柔性数组, 自定义大小的meta空间
};
```

在上面的定义中, `dictEntry`表示一个具体的哈希表元素节点. `dictEntry **ht_table[2];`的声明较为复杂, 可以拆分为两个部分, 其中`dictEntry **`是二重指针, 可以视为一个`dictEntry`指针构成的数组, 后面的`[2]`表示有两个这样的元素的数组. 

因为哈希表结构可能存在rehash的情况, 因此需要有两个指针分别指向扩容前的哈希表和扩容后的哈希表. 哈希表中`ht_used`和`ht_size_exp`字段也因此声明为具有两个元素的数组.

`rehashidx`字段除了使用`-1`表示当前无rehash操作外, 当其大于0时, 还表示了当前数据迁移的进度. 当`rehashidx`等于旧哈希表容量时, 表明迁移操作已经完成.

> 哈希表底层就是数组, 所谓的迁移进度就是在这个数组中的下标, 当期指向最后一个元素之后, 就表明所有元素都处理过了.


```c
struct dictEntry {
    void *key;
    union {
        void *val;
        uint64_t u64;
        int64_t s64;
        double d;
    } v;
    struct dictEntry *next;     /* Next entry in the same hash bucket. */
};
```

`dictEntry`表示一个具体的存储节点, 其中的定义比较简单, 存储值的部分使用了C语言的联合特性, v字段的类型在运行时可为定义的几种类型中的一种.

```c
typedef struct dictType {
    /* Callbacks */
    uint64_t (*hashFunction)(const void *key);
    void *(*keyDup)(dict *d, const void *key);
    void *(*valDup)(dict *d, const void *obj);
    int (*keyCompare)(dict *d, const void *key1, const void *key2);
    void (*keyDestructor)(dict *d, void *key);
    void (*valDestructor)(dict *d, void *obj);
    int (*resizeAllowed)(size_t moreMem, double usedRatio);
    /* Invoked at the start of dict initialization/rehashing (old and new ht are already created) */
    void (*rehashingStarted)(dict *d);
    /* Invoked at the end of dict initialization/rehashing of all the entries from old to new ht. Both ht still exists
     * and are cleaned up after this callback.  */
    void (*rehashingCompleted)(dict *d);
    /* Allow a dict to carry extra caller-defined metadata. The
     * extra memory is initialized to 0 when a dict is allocated. */
    size_t (*dictMetadataBytes)(dict *d);

    /* Data */
    void *userdata;

    /* Flags */
    /* The 'no_value' flag, if set, indicates that values are not used, i.e. the
     * dict is a set. When this flag is set, it's not possible to access the
     * value of a dictEntry and it's also impossible to use dictSetKey(). Entry
     * metadata can also not be used. */
    unsigned int no_value:1;
    /* If no_value = 1 and all keys are odd (LSB=1), setting keys_are_odd = 1
     * enables one more optimization: to store a key without an allocated
     * dictEntry. */
    unsigned int keys_are_odd:1;
    /* TODO: Add a 'keys_are_even' flag and use a similar optimization if that
     * flag is set. */
} dictType;
```

`dictType`是一个包含许多函数的结构体, 在创建哈希表时必须传入此结构体.哈希表在执行各类操作时, 会调用`dictType`中定义的一些函数.


### 创建哈希表

```c
dict *dictCreate(dictType *type)
{
    size_t metasize = type->dictMetadataBytes ? type->dictMetadataBytes(NULL) : 0;
    dict *d = zmalloc(sizeof(*d)+metasize);
    if (metasize > 0) {
        memset(dictMetadata(d), 0, metasize);
    }
    _dictInit(d,type);
    return d;
}

/* Initialize the hash table */
int _dictInit(dict *d, dictType *type)
{
    _dictReset(d, 0);
    _dictReset(d, 1);
    d->type = type;
    d->rehashidx = -1;
    d->pauserehash = 0;
    d->pauseAutoResize = 0;
    return DICT_OK;
}

/* Reset hash table parameters already initialized with _dictInit()*/
static void _dictReset(dict *d, int htidx)
{
    d->ht_table[htidx] = NULL;
    d->ht_size_exp[htidx] = -1;
    d->ht_used[htidx] = 0;
}
```

创建过程主要是内存分配和参数初始化, 其中为了分别初始化内部的两个元素, 调用了两次`_dictReset`函数.


### 扩缩容操作

```c
/* Resize or create the hash table,
 * when malloc_failed is non-NULL, it'll avoid panic if malloc fails (in which case it'll be set to 1).
 * Returns DICT_OK if resize was performed, and DICT_ERR if skipped. */
int _dictResize(dict *d, unsigned long size, int* malloc_failed)
{
    if (malloc_failed) *malloc_failed = 0;

    /* We can't rehash twice if rehashing is ongoing. */
    assert(!dictIsRehashing(d));

    /* the new hash table */
    // 为新的哈希表计算需要的空间, 既有可能执行扩容操作, 也有可能执行缩容操作
    dictEntry **new_ht_table;
    unsigned long new_ht_used;
    signed char new_ht_size_exp = _dictNextExp(size); // 根据当前给定的容量大小, 对齐到2^n, 例如给定15, 则对其到16=2^4, 并返回4

    /* Detect overflows */
    size_t newsize = DICTHT_SIZE(new_ht_size_exp);
    if (newsize < size || newsize * sizeof(dictEntry*) < newsize)
        return DICT_ERR;

    /* Rehashing to the same table size is not useful. */
    if (new_ht_size_exp == d->ht_size_exp[0]) return DICT_ERR;

    /* Allocate the new hash table and initialize all pointers to NULL */
    // 根据给定的是否允许失败参数, 尝试分配内存
    if (malloc_failed) {
        new_ht_table = ztrycalloc(newsize*sizeof(dictEntry*));
        *malloc_failed = new_ht_table == NULL;
        if (*malloc_failed)
            return DICT_ERR;
    } else
        new_ht_table = zcalloc(newsize*sizeof(dictEntry*));

    new_ht_used = 0;

    /* Prepare a second hash table for incremental rehashing.
     * We do this even for the first initialization, so that we can trigger the
     * rehashingStarted more conveniently, we will clean it up right after. */
    // 给新的哈希表初始化参数
    d->ht_size_exp[1] = new_ht_size_exp;
    d->ht_used[1] = new_ht_used;
    d->ht_table[1] = new_ht_table;
    d->rehashidx = 0;
    if (d->type->rehashingStarted) d->type->rehashingStarted(d);

    /* Is this the first initialization or is the first hash table empty? If so
     * it's not really a rehashing, we can just set the first hash table so that
     * it can accept keys. */
    // 检查旧哈希表状态, 如果已经全部迁移完成, 则重置旧哈希表的指针指向新的哈希表
    if (d->ht_table[0] == NULL || d->ht_used[0] == 0) {
        if (d->type->rehashingCompleted) d->type->rehashingCompleted(d);
        if (d->ht_table[0]) zfree(d->ht_table[0]);
        d->ht_size_exp[0] = new_ht_size_exp;
        d->ht_used[0] = new_ht_used;
        d->ht_table[0] = new_ht_table;
        _dictReset(d, 1);
        d->rehashidx = -1;
        return DICT_OK;
    }

    return DICT_OK;
}
```


### Rehash操作


Redis的Rehash操作具有一个不同于一般哈希表的实现, 可以把这种特性称之为渐进式Rehash. 即需要进行Rehash操作时, 并不是一次性完成所有数据的迁移, 而是将该操作分散到各个操作之中, 使得迁移数据的耗时分散开.

```c
/* Helper function for `dictRehash` and `dictBucketRehash` which rehashes all the keys
 * in a bucket at index `idx` from the old to the new hash HT. */
// 尝试移动一个元素
static void rehashEntriesInBucketAtIndex(dict *d, uint64_t idx) {
    dictEntry *de = d->ht_table[0][idx];
    uint64_t h;
    dictEntry *nextde;
    while (de) {
        nextde = dictGetNext(de);
        void *key = dictGetKey(de);
        /* Get the index in the new hash table */
        if (d->ht_size_exp[1] > d->ht_size_exp[0]) {
            // 如果是扩容, 则重新计算一次哈希值
            h = dictHashKey(d, key) & DICTHT_SIZE_MASK(d->ht_size_exp[1]);
        } else {
            /* We're shrinking the table. The tables sizes are powers of
             * two, so we simply mask the bucket index in the larger table
             * to get the bucket index in the smaller table. */
            // 如果是缩容, 则使用掩码遮盖高位bit即可
            h = idx & DICTHT_SIZE_MASK(d->ht_size_exp[1]);
        }
        if (d->type->no_value) {
            if (d->type->keys_are_odd && !d->ht_table[1][h]) {
                /* Destination bucket is empty and we can store the key
                 * directly without an allocated entry. Free the old entry
                 * if it's an allocated entry.
                 *
                 * TODO: Add a flag 'keys_are_even' and if set, we can use
                 * this optimization for these dicts too. We can set the LSB
                 * bit when stored as a dict entry and clear it again when
                 * we need the key back. */
                assert(entryIsKey(key));
                if (!entryIsKey(de)) zfree(decodeMaskedPtr(de));
                de = key;
            } else if (entryIsKey(de)) {
                /* We don't have an allocated entry but we need one. */
                de = createEntryNoValue(key, d->ht_table[1][h]);
            } else {
                /* Just move the existing entry to the destination table and
                 * update the 'next' field. */
                assert(entryIsNoValue(de));
                dictSetNext(de, d->ht_table[1][h]);
            }
        } else {
            // 此函数设置de的next指针, 使得de变量链接到现有链表的头部.
            // 如果当前位置本来就没有元素, 则此操作也等于什么都不做
            dictSetNext(de, d->ht_table[1][h]);
        }
        d->ht_table[1][h] = de; // 在对应的位置写入de, 使得de变为头结点
        d->ht_used[0]--;
        d->ht_used[1]++;
        de = nextde;
    }
    d->ht_table[0][idx] = NULL;
}
```

`dictRehash`执行N次迁移操作, 同时为了避免遇到太多空位置, 导致此函数执行时间过长, 内部限制了最多处理10*N个空元素就退出执行.

```c
/* Performs N steps of incremental rehashing. Returns 1 if there are still
 * keys to move from the old to the new hash table, otherwise 0 is returned.
 *
 * Note that a rehashing step consists in moving a bucket (that may have more
 * than one key as we use chaining) from the old to the new hash table, however
 * since part of the hash table may be composed of empty spaces, it is not
 * guaranteed that this function will rehash even a single bucket, since it
 * will visit at max N*10 empty buckets in total, otherwise the amount of
 * work it does would be unbound and the function may block for a long time. */
int dictRehash(dict *d, int n) {
    int empty_visits = n*10; /* Max number of empty buckets to visit. */
    // 获取新旧两个哈希表的容量
    unsigned long s0 = DICTHT_SIZE(d->ht_size_exp[0]);
    unsigned long s1 = DICTHT_SIZE(d->ht_size_exp[1]);
    // dict_can_resize是一个全局变量, Redis在进行备份时, 由于使用copy-on-write机制,  为了避免产生太多的内存移动, 此时会全局禁用哈希表的迁移操作
    if (dict_can_resize == DICT_RESIZE_FORBID || !dictIsRehashing(d)) return 0;
    /* If dict_can_resize is DICT_RESIZE_AVOID, we want to avoid rehashing. 
     * - If expanding, the threshold is dict_force_resize_ratio which is 4.
     * - If shrinking, the threshold is 1 / (HASHTABLE_MIN_FILL * dict_force_resize_ratio) which is 1/32. */
    // 如果当前是 DICT_RESIZE_AVOID, 则扩容和缩容的要求更加严格, 从而减少Rehash的概率
    if (dict_can_resize == DICT_RESIZE_AVOID && 
        ((s1 > s0 && s1 < dict_force_resize_ratio * s0) ||
         (s1 < s0 && s0 < HASHTABLE_MIN_FILL * dict_force_resize_ratio * s1)))
    {
        return 0;
    }

    while(n-- && d->ht_used[0] != 0) {
        /* Note that rehashidx can't overflow as we are sure there are more
         * elements because ht[0].used != 0 */
        assert(DICTHT_SIZE(d->ht_size_exp[0]) > (unsigned long)d->rehashidx);
        while(d->ht_table[0][d->rehashidx] == NULL) {
            // rehashidx 除了用于记录当前是否正在rehash以外, 还用于记录当前rehash的进度, 当其等于旧哈希表容量时表明已经完成迁移
            d->rehashidx++;
            if (--empty_visits == 0) return 1;
        }
        /* Move all the keys in this bucket from the old to the new hash HT */
        rehashEntriesInBucketAtIndex(d, d->rehashidx);
        d->rehashidx++;
    }

    // 检查是否已经完成迁移, 如果完成迁移则调整对应字段的值
    return !dictCheckRehashingCompleted(d);
}
```


作为渐进式Rehash的一部分, `_dictBucketRehash`在插入数据时调用, 在满足一些条件时执行一次迁移数据操作

```c
/* Performs rehashing on a single bucket. */
int _dictBucketRehash(dict *d, uint64_t idx) {
    if (d->pauserehash != 0) return 0;
    unsigned long s0 = DICTHT_SIZE(d->ht_size_exp[0]);
    unsigned long s1 = DICTHT_SIZE(d->ht_size_exp[1]);
    if (dict_can_resize == DICT_RESIZE_FORBID || !dictIsRehashing(d)) return 0;
    /* If dict_can_resize is DICT_RESIZE_AVOID, we want to avoid rehashing. 
     * - If expanding, the threshold is dict_force_resize_ratio which is 4.
     * - If shrinking, the threshold is 1 / (HASHTABLE_MIN_FILL * dict_force_resize_ratio) which is 1/32. */
    if (dict_can_resize == DICT_RESIZE_AVOID && 
        ((s1 > s0 && s1 < dict_force_resize_ratio * s0) ||
         (s1 < s0 && s0 < HASHTABLE_MIN_FILL * dict_force_resize_ratio * s1)))
    {
        return 0;
    }
    rehashEntriesInBucketAtIndex(d, idx);
    dictCheckRehashingCompleted(d);
    return 1;
}
```

### 添加数据

添加数据的扩充可以概括为先找到要插入数据的位置, 然后在该位置插入数据


```c
dictEntry *dictAddRaw(dict *d, void *key, dictEntry **existing)
{
    /* Get the position for the new key or NULL if the key already exists. */
    void *position = dictFindPositionForInsert(d, key, existing);
    if (!position) return NULL;

    /* Dup the key if necessary. */
    if (d->type->keyDup) key = d->type->keyDup(d, key);

    return dictInsertAtPosition(d, key, position);
}
```

查找插入点的代码逻辑并不复杂, 找到对应的bucket的位置即可, 并不需要处理链表的内容. 但由于需要支持渐进式Rehash, 因此在查找过程中还需要顺便完成节点迁移的工作.

```c
/* Finds and returns the position within the dict where the provided key should
 * be inserted using dictInsertAtPosition if the key does not already exist in
 * the dict. If the key exists in the dict, NULL is returned and the optional
 * 'existing' entry pointer is populated, if provided. */
void *dictFindPositionForInsert(dict *d, const void *key, dictEntry **existing) {
    unsigned long idx, table;
    dictEntry *he;
    if (existing) *existing = NULL;
    uint64_t hash = dictHashKey(d, key);
    idx = hash & DICTHT_SIZE_MASK(d->ht_size_exp[0]);

    // 如果当前正在Rehash, 则执行一次操作
    if (dictIsRehashing(d)) {
        if ((long)idx >= d->rehashidx && d->ht_table[0][idx]) {
            /* If we have a valid hash entry at `idx` in ht0, we perform
             * rehash on the bucket at `idx` (being more CPU cache friendly) */
            _dictBucketRehash(d, idx);
        } else {
            /* If the hash entry is not in ht0, we rehash the buckets based
             * on the rehashidx (not CPU cache friendly). */
            _dictRehashStep(d);
        }
    }

    /* Expand the hash table if needed */
    // 即计算是否需要扩容
    _dictExpandIfNeeded(d);
    for (table = 0; table <= 1; table++) {
        if (table == 0 && (long)idx < d->rehashidx) continue; 
        idx = hash & DICTHT_SIZE_MASK(d->ht_size_exp[table]);
        /* Search if this slot does not already contain the given key */
        he = d->ht_table[table][idx];
        while(he) {
            void *he_key = dictGetKey(he);
            if (key == he_key || dictCompareKeys(d, key, he_key)) {
                if (existing) *existing = he;
                return NULL;
            }
            he = dictGetNext(he);
        }
        if (!dictIsRehashing(d)) break;
    }

    /* If we are in the process of rehashing the hash table, the bucket is
     * always returned in the context of the second (new) hash table. */
    dictEntry **bucket = &d->ht_table[dictIsRehashing(d) ? 1 : 0][idx];
    return bucket;
}
```

找到对应的bucket后, 插入操作比较直接, 分配内存后插入即可.

```c
/* Adds a key in the dict's hashtable at the position returned by a preceding
 * call to dictFindPositionForInsert. This is a low level function which allows
 * splitting dictAddRaw in two parts. Normally, dictAddRaw or dictAdd should be
 * used instead. */
dictEntry *dictInsertAtPosition(dict *d, void *key, void *position) {
    dictEntry **bucket = position; /* It's a bucket, but the API hides that. */
    dictEntry *entry;
    /* If rehashing is ongoing, we insert in table 1, otherwise in table 0.
     * Assert that the provided bucket is the right table. */
    int htidx = dictIsRehashing(d) ? 1 : 0;
    assert(bucket >= &d->ht_table[htidx][0] &&
           bucket <= &d->ht_table[htidx][DICTHT_SIZE_MASK(d->ht_size_exp[htidx])]);
    if (d->type->no_value) {
        if (d->type->keys_are_odd && !*bucket) {
            /* We can store the key directly in the destination bucket without the
             * allocated entry.
             *
             * TODO: Add a flag 'keys_are_even' and if set, we can use this
             * optimization for these dicts too. We can set the LSB bit when
             * stored as a dict entry and clear it again when we need the key
             * back. */
            entry = key;
            assert(entryIsKey(entry));
        } else {
            /* Allocate an entry without value. */
            entry = createEntryNoValue(key, *bucket);
        }
    } else {
        /* Allocate the memory and store the new entry.
         * Insert the element in top, with the assumption that in a database
         * system it is more likely that recently added entries are accessed
         * more frequently. */
        entry = zmalloc(sizeof(*entry));
        assert(entryIsNormal(entry)); /* Check alignment of allocation */
        entry->key = key;
        entry->next = *bucket;
    }
    *bucket = entry;
    d->ht_used[htidx]++;

    return entry;
}
```


整数集合
---------

整数集合`intset`底层实际就是一个按照大小排序的数组, 当Redis集合中的数据全部是小于64位的整数并且数量较少时使用此数据结构. `intset`结构非常简单, 其定义如下

```c
typedef struct intset {
    uint32_t encoding;
    uint32_t length;
    int8_t contents[];
} intset;
```

其中`encoding`用于表示每个元素的类型, 例如int16, int32或者int64. `length`存储元素的数量, `contents`存储具体的数据. 

由于不同类型的整数本质上只有长度不同, 因此`intset`的实现非常的普通. 在插入数据时, `intset`使用二分法判断是否存在对应的数据, 从而避免元素重复. 如果插入的数据大于当前的表示范围(例如当前按照int16存储, 插入了int32的数据), 则对`intset`进行扩容, 每个元素的长度翻倍.


字符串列表
--------------

字符串列表`listpack`与`ziplist`类似, 是一种顺序存储数据的结构, 但其中的元素不要求按照顺序排列. 其结构与编码方式也类似.


快速列表
----------


快速列表`quicklist`可以视为将`listpack`作为元素的双向链表. 

![quicklist结构示意图](/images/redis/quicklist.jpeg)


从上图可以看到, `quicklist`的数据结构非常适合存储大量数据并实现列表结构. 在Redis中列表通常按照队列模式使用, 仅可再头尾添加或删除元素, 因此为了进一步节省内存, `quicklist`还支持对中间的元素进行压缩.


### 数据结构

```c
/* quicklist is a 40 byte struct (on 64-bit systems) describing a quicklist.
 * 'count' is the number of total entries.
 * 'len' is the number of quicklist nodes.
 * 'compress' is: 0 if compression disabled, otherwise it's the number
 *                of quicklistNodes to leave uncompressed at ends of quicklist.
 * 'fill' is the user-requested (or default) fill factor.
 * 'bookmarks are an optional feature that is used by realloc this struct,
 *      so that they don't consume memory when not used. */
typedef struct quicklist {
    quicklistNode *head;
    quicklistNode *tail;
    unsigned long count;        /* total count of all entries in all listpacks */
    unsigned long len;          /* number of quicklistNodes */
    signed int fill : QL_FILL_BITS;       /* fill factor for individual nodes */
    unsigned int compress : QL_COMP_BITS; /* depth of end nodes not to compress;0=off */
    unsigned int bookmark_count: QL_BM_BITS;
    quicklistBookmark bookmarks[];
} quicklist;
```

`quicklist`结构定义如上所示, 其中`fill`为正数时表示表示每个`ziplist`的最大元素个数, 为负数时, 按照取值表示最大的长度(单位为字节). `compress`表示两端不压缩的节点数量, 例如取值为1则左右各1个`ziplist`不压缩.


```c
/* quicklistNode is a 32 byte struct describing a listpack for a quicklist.
 * We use bit fields keep the quicklistNode at 32 bytes.
 * count: 16 bits, max 65536 (max lp bytes is 65k, so max count actually < 32k).
 * encoding: 2 bits, RAW=1, LZF=2.
 * container: 2 bits, PLAIN=1 (a single item as char array), PACKED=2 (listpack with multiple items).
 * recompress: 1 bit, bool, true if node is temporary decompressed for usage.
 * attempted_compress: 1 bit, boolean, used for verifying during testing.
 * dont_compress: 1 bit, boolean, used for preventing compression of entry.
 * extra: 9 bits, free for future use; pads out the remainder of 32 bits */
typedef struct quicklistNode {
    struct quicklistNode *prev;
    struct quicklistNode *next;
    unsigned char *entry;
    size_t sz;             /* entry size in bytes */
    unsigned int count : 16;     /* count of items in listpack */
    unsigned int encoding : 2;   /* RAW==1 or LZF==2 */
    unsigned int container : 2;  /* PLAIN==1 or PACKED==2 */
    unsigned int recompress : 1; /* was this node previous compressed? */
    unsigned int attempted_compress : 1; /* node can't compress; too small */
    unsigned int dont_compress : 1; /* prevent compression of entry that will be used later */
    unsigned int extra : 9; /* more bits to steal for future usage */
} quicklistNode;
```

其中`encoding`表示编码类型, 可选默认编码或者LZF压缩编码. `container`表示存储类型, 默认情况下使用`ziplist`存储数据(即PACKED), 但如果需要存储的元素体积较大, 则会直接存储该元素(即PLAIN). `recompress`表示该节点是否被压缩, 如果已经被压缩则修改前需要解压, 修改后需要压缩.


### 数据压缩


```c
/* Compress the listpack in 'node' and update encoding details.
 * Returns 1 if listpack compressed successfully.
 * Returns 0 if compression failed or if listpack too small to compress. */
REDIS_STATIC int __quicklistCompressNode(quicklistNode *node) {
#ifdef REDIS_TEST
    node->attempted_compress = 1;
#endif
    if (node->dont_compress) return 0;

    /* validate that the node is neither
     * tail nor head (it has prev and next)*/
    assert(node->prev && node->next);

    node->recompress = 0;
    /* Don't bother compressing small values */
    if (node->sz < MIN_COMPRESS_BYTES)
        return 0;

    quicklistLZF *lzf = zmalloc(sizeof(*lzf) + node->sz);

    /* Cancel if compression fails or doesn't compress small enough */
    if (((lzf->sz = lzf_compress(node->entry, node->sz, lzf->compressed,
                                 node->sz)) == 0) ||
        lzf->sz + MIN_COMPRESS_IMPROVE >= node->sz) {
        /* lzf_compress aborts/rejects compression if value not compressible. */
        zfree(lzf);
        return 0;
    }
    lzf = zrealloc(lzf, sizeof(*lzf) + lzf->sz);
    zfree(node->entry);
    node->entry = (unsigned char *)lzf;
    node->encoding = QUICKLIST_NODE_ENCODING_LZF;
    return 1;
}
```

以上函数将一个Node节点进行压缩. 首先分配了`quicklistLZF`的空间, 此时的大小等于该结构体的头部加上原始数据的大小. 之后调用`lzf_compress`进行压缩. 如果压缩过程出现错误或者压缩后体积大于原本的体积, 则该函数返回0, 否则返回压缩后的大小.

最后通过`zrealloc`回收多余的空间, 由于压缩后体积缩小, 所以这里必然是一个减少分配空间的操作.

### 添加与删除数据

```c
/* Add new entry to head node of quicklist.
 *
 * Returns 0 if used existing head.
 * Returns 1 if new head created. */
int quicklistPushHead(quicklist *quicklist, void *value, size_t sz) {
    quicklistNode *orig_head = quicklist->head;
    
    // 是否为大体积的元素, 是则直接添加该元素
    if (unlikely(isLargeElement(sz, quicklist->fill))) {
        __quicklistInsertPlainNode(quicklist, quicklist->head, value, sz, 0);
        return 1;
    }

    // 否则判断当前头部的listpack是否可以继续添加元素, 是则加入
    if (likely(
            _quicklistNodeAllowInsert(quicklist->head, quicklist->fill, sz))) {
        quicklist->head->entry = lpPrepend(quicklist->head->entry, value, sz);
        quicklistNodeUpdateSz(quicklist->head);
    } else {
        // 否则创建一个新节点
        quicklistNode *node = quicklistCreateNode();
        // lpPrepend 在底层的listpack的头部插入数据
        node->entry = lpPrepend(lpNew(0), value, sz);

        quicklistNodeUpdateSz(node);
        _quicklistInsertNodeBefore(quicklist, quicklist->head, node);
    }
    quicklist->count++;
    quicklist->head->count++;
    return (orig_head != quicklist->head);
}

```

删除操作与插入操作类似, 先删除底层listpack的数据, 如果一个节点中不包含任何数据了, 则删除对应的节点.

### 替换数据

```c
/* Replace quicklist entry by 'data' with length 'sz'. */
void quicklistReplaceEntry(quicklistIter *iter, quicklistEntry *entry,
                           void *data, size_t sz)
{
    quicklist* quicklist = iter->quicklist;
    quicklistNode *node = entry->node;
    unsigned char *newentry;

    if (likely(!QL_NODE_IS_PLAIN(entry->node) && !isLargeElement(sz, quicklist->fill) &&
        (newentry = lpReplace(entry->node->entry, &entry->zi, data, sz)) != NULL))
    {
        // 如果是一个普通节点并且插入的数据也是普通数据, 则可以直接替换
        entry->node->entry = newentry;
        quicklistNodeUpdateSz(entry->node);
        /* quicklistNext() and quicklistGetIteratorEntryAtIdx() provide an uncompressed node */
        quicklistCompress(quicklist, entry->node);
    } else if (QL_NODE_IS_PLAIN(entry->node)) {
        if (isLargeElement(sz, quicklist->fill)) {
            // 如果原节点是平坦节点, 新数据也是平坦数据, 则直接替换
            zfree(entry->node->entry);
            entry->node->entry = zmalloc(sz);
            entry->node->sz = sz;
            memcpy(entry->node->entry, data, sz);
            quicklistCompress(quicklist, entry->node);
        } else {
            // 否则删除就节点, 插入新数据
            quicklistInsertAfter(iter, entry, data, sz);
            __quicklistDelNode(quicklist, entry->node);
        }
    } else { /* The node is full or data is a large element */
        // 如果节点已经满了, 或者要插入一个大体积的数据, 则分裂当前节点
        quicklistNode *split_node = NULL, *new_node;
        node->dont_compress = 1; /* Prevent compression in __quicklistInsertNode() */

        /* If the entry is not at the tail, split the node at the entry's offset. */
        if (entry->offset != node->count - 1 && entry->offset != -1)
            split_node = _quicklistSplitNode(node, entry->offset, 1);

        /* Create a new node and insert it after the original node.
         * If the original node was split, insert the split node after the new node. */
        new_node = __quicklistCreateNode(isLargeElement(sz, quicklist->fill) ?
            QUICKLIST_NODE_CONTAINER_PLAIN : QUICKLIST_NODE_CONTAINER_PACKED, data, sz);
        __quicklistInsertNode(quicklist, node, new_node, 1);
        if (split_node) __quicklistInsertNode(quicklist, new_node, split_node, 1);
        quicklist->count++;

        /* Delete the replaced element. */
        if (entry->node->count == 1) {
            __quicklistDelNode(quicklist, entry->node);
        } else {
            unsigned char *p = lpSeek(entry->node->entry, -1);
            quicklistDelIndex(quicklist, entry->node, &p);
            entry->node->dont_compress = 0; /* Re-enable compression */
            new_node = _quicklistMergeNodes(quicklist, new_node);
            /* We can't know if the current node and its sibling nodes are correctly compressed,
             * and we don't know if they are within the range of compress depth, so we need to
             * use quicklistCompress() for compression, which checks if node is within compress
             * depth before compressing. */
            quicklistCompress(quicklist, new_node);
            quicklistCompress(quicklist, new_node->prev);
            if (new_node->next) quicklistCompress(quicklist, new_node->next);
        }
    }

    /* In any case, we reset iterator to forbid use of iterator after insert.
     * Notice: iter->current has been compressed above. */
    resetIterator(iter);
}
```


前缀树
------------


前缀树`Rax`是一种树形结构, 按照字符串的字符顺序进行构造, 从而可以快速的判断一个指定的字符串是否位于集合之中. 

```c
/* Representation of a radix tree as implemented in this file, that contains
 * the strings "foo", "foobar" and "footer" after the insertion of each
 * word. When the node represents a key inside the radix tree, we write it
 * between [], otherwise it is written between ().
 *
 * This is the vanilla representation:
 *
 *              (f) ""
 *                \
 *                (o) "f"
 *                  \
 *                  (o) "fo"
 *                    \
 *                  [t   b] "foo"
 *                  /     \
 *         "foot" (e)     (a) "foob"
 *                /         \
 *      "foote" (r)         (r) "fooba"
 *              /             \
 *    "footer" []             [] "foobar"
 *
 * However, this implementation implements a very common optimization where
 * successive nodes having a single child are "compressed" into the node
 * itself as a string of characters, each representing a next-level child,
 * and only the link to the node representing the last character node is
 * provided inside the representation. So the above representation is turned
 * into:
 *
 *                  ["foo"] ""
 *                     |
 *                  [t   b] "foo"
 *                  /     \
 *        "foot" ("er")    ("ar") "foob"
 *                 /          \
 *       "footer" []          [] "foobar"
 *
 * However this optimization makes the implementation a bit more complex.
 * For instance if a key "first" is added in the above radix tree, a
 * "node splitting" operation is needed, since the "foo" prefix is no longer
 * composed of nodes having a single child one after the other. This is the
 * above tree and the resulting node splitting after this event happens:
 *
 *
 *                    (f) ""
 *                    /
 *                 (i o) "f"
 *                 /   \
 *    "firs"  ("rst")  (o) "fo"
 *              /        \
 *    "first" []       [t   b] "foo"
 *                     /     \
 *           "foot" ("er")    ("ar") "foob"
 *                    /          \
 *          "footer" []          [] "foobar"
 *
 * Similarly after deletion, if a new chain of nodes having a single child
 * is created (the chain must also not include nodes that represent keys),
 * it must be compressed back into a single node.
 *
 */
```


数据结构的应用
-----------------------------


底层数据结构        |  可存储的Redis数据结构
------------------|-----------------------
简单动态字符串      | 字符串
跳跃表              | 有序集合
字典                | 集合 散列表 有序集合
压缩表              | 散列表 有序集合
整数集合            | 集合
快速列表            | 列表
流                  | 流

除了以上涉及的5种数据结构(字符串, 列表, 集合, 散列表, 有序集合)以外, Redis还对外提供了位图(BitMap)和地址位置(Geo), 有关这两种数据结构的相关内容在后续补充.



补充说明:C语言特性说明
-------------------------

### 柔性数组

在C语言中, 定义结构体时, 结构体中的最后一个元素可以定义为一个不声明长度的数组. 创建该结构体时, 可使用malloc分配大于该结构体常规尺寸的空间, 剩余的空间将自动作为最后一个数组成员的空间. 例如

```c
typedef struct Sa {
    int data
    int buf[]
}

Sa* pa = (Sa*)malloc(sizeof(int) + 10*sizeof(int))
// buf具有10个元素的空间
```

### Union

联合(Union)是一种能在同一储存空间里储存不同类型数据的数据结构. 其定义方式为

```
union 标志符{
	成员1
	成员2
	.
	.
};     //注意此处的分号
```

### 位域

位域（Bit Fields）是一种允许程序在结构体或联合体中定义比特级别的字段的数据结构. 其定义方式为

```
struct 位域结构名 {
    数据类型 位域名 : 比特数;
    ...
};
```

例如对于如下的定义


```c
struct BitFieldExample {
    unsigned int a : 3;  // a占3位
    unsigned int b : 5;  // b占5位
    unsigned int c : 10; // c占10位
};
```

3个字段实际只使用18个bit, 编译器将其连续的存储并在读写时完成对应的转换.


补充说明:常见宏效果说明
-------------------------


### UNUSED

```c
#define UNUSED(x) ((void)(x))
```

这个C语言宏的目的是消除编译器产生的"unused variable"（未使用变量）警告. 有些函数可能因为某些原因声明了一些不使用的变量, 使用此宏可以强制的产生一个对该变量的使用操作, 从而消除警告.


补充说明:内存分配相关
--------------------------

### malloc_size

使用`malloc_size`函数可获取内存块的实际大小. 在一次内存分配过程中, 实际分配的内存空间大小与申请的空间大小可能并不一致, 而且可能比申请的空间大. 使用此函数可以得知具体的空间大小. 在Redis中, SDS库借助于此机制调整alloc变量的取值, 从而减少不必要的内存分配.

代码中可通过`HAVE_MALLOC_SIZE`得知是否支持此函数


### extend_to_usable

```c
__attribute__((alloc_size(2),noinline)) void *extend_to_usable(void *ptr, size_t size);
```

`extend_to_usable`是一个纯声明性质的函数, 通过`alloc_size(2)`属性标记, 向编译器表明这个函数的第二个参数是ptr执行的内存空间的实际大小, 从而避免编译器进行了一些错误的内部优化.

此函数通常与`malloc_size`函数配合使用, 通过`malloc_size`函数获取实际分配的内存空间大小后, 使用`extend_to_usable`函数向编译器声明后续代码会按照实际分配的空间大小使用.


### realloc

`realloc`函数的语义是重新分配内存空间大小. 当需要扩大内存空间时, 有可能当前内存位置的后部有足够的空闲空间, 此时可以直接扩容. 但如果当前位置无法满足要求, 则`realloc`函数会重新申请一块足够的空间并复制原有数据到新的空间之中.

- [C语言内存管理机制--malloc/calloc/free原理与实现](https://zhuanlan.zhihu.com/p/404081543)