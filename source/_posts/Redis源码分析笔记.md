---
title: Redis源码分析笔记
math: false
date: 2024-03-22 22:54:02
categories: Redis笔记
tags:
    - Redis
cover_picture: images/redis.jpg
---

Redis是一个C语言实现的高性能内存数据库, 在日常的业务开发过程中, Redis占据重要的地位. 因此阅读和学习Redis源代码有助于理解Redis的具体实现原理, 从而更好的将其运用到业务开发过程之中.

同时Redis源码本身由C语言实现, 因此并不包含复杂的语言特性, 相对较为容易阅读. 阅读这些代码也可以学习如何写出简洁的代码.



Redis代码阅读环境准备
----------------------

Redis项目在Github上开源, 因此可借助Github的Codespace功能快速的构建一个阅读环境. 首先打开Redis的[官方仓库](https://github.com/redis/redis), 将代码fork一份到自己的账号下. 然后在自己的仓库页面按下`,`键, 对当前仓库启用Codespace.

根据以上两步, 即可快速的获得一个可在浏览器中使用的代码阅读环境. 由于Codespace已经安装好了依赖, 因此甚至可以在此环境中尝试编译和调试Redis本身.

> 感谢Github和Vscode提供的能力, 现在想学习一个项目可容易太多了.




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

创建`zskiplist`的逻辑比较简单, 给数组分配空间后填充对应的初始值即可. 其中`ZSKIPLIST_MAXLEVEL`在当前版本的定义为32, 因此头节点时一个具有32层的节点.

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

跳跃表作为一种可以保持元素顺序且查询效率达到O(logN)的数据结构, 其插入和删除过程与红黑树相比, 确实可以算得上简单易懂了. 如果不考虑span相关的逻辑, 甚至可以说是非常的简单直观. 但需要注意到, 跳跃表的层高并不是一种精心计算的结构, 而是直接引入概率的. 因此与红黑树在任何时候都较好的位置平衡性不同, 跳跃表的查询效率受到概率影响, 只能在平均层面上达到O(logN)的查询复杂度.

在Redis中, 跳跃表用于zset的底层实现, 但zset并不一定采取跳跃表. 仅当zset中的元素较多, 且每个项目的长度较大时才会采取此数据结构, 否则Redis将采取另一种称为压缩列表的数据结构进行存储.


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