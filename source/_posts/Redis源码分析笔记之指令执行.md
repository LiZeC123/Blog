---
title: Redis源码分析笔记之指令执行
math: false
date: 2024-06-12 09:25:57
categories: Redis笔记
tags:
    - Redis
cover_picture: images/redis.jpg
---


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


客户端结构体对象
------------------

客户端结构体为`client`, 其中包含了几十个字段, 以下仅列举一些核心的参数

```c
typedef struct client {
    uint64_t id;            /* Client incremental unique ID. */
    connection *conn;
    redisDb *db;            /* Pointer to currently SELECTed DB. */
    robj *name;             /* As set by CLIENT SETNAME. */
    sds querybuf;           /* Buffer we use to accumulate client queries. */
    int argc;               /* Num of arguments of current command. */
    robj **argv;            /* Arguments of current command. */
    struct redisCommand *cmd, *lastcmd;  /* Last command executed. */
    time_t lastinteraction; /* Time of the last interaction, used for timeout */
    list *reply;            /* List of reply objects to send to the client. */
}
```

`conn`是表示连接的结构体, 其中存储了该client对应socket的文件描述符, 注册的回调函数等信息. `db`是该client使用的数据库指针, Redis默认定义了16个数据库, 因此至少存在16个`redisDb`对象. 

`querybuf`缓存客户端发送的查询信息, 由于TCP可能存在拆分发送, 因此需要一个缓冲区来组装信息. `cmd`字段使用`redisCommand`记录了当前执行的指令.

其余字段含义比较明确, 可基于注释了解其用途.



### redisDb对象

`redisDb`对象的结构体如下所示:

```c
typedef struct redisDb {
    kvstore *keys;              /* The keyspace for this DB */
    kvstore *expires;           /* Timeout of keys with a timeout set */
    ebuckets hexpires;          /* Hash expiration DS. Single TTL per hash (of next min field to expire) */
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP)*/
    dict *blocking_keys_unblock_on_nokey;   /* Keys with clients waiting for
                                             * data, and should be unblocked if key is deleted (XREADEDGROUP).
                                             * This is a subset of blocking_keys*/
    dict *ready_keys;           /* Blocked keys that received a PUSH */
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */
    int id;                     /* Database ID */
    long long avg_ttl;          /* Average TTL, just for stats */
    unsigned long expires_cursor; /* Cursor of the active expire cycle. */
    list *defrag_later;         /* List of key names to attempt to defrag one by one, gradually. */
} redisDb;
```

其中的大部分字段基于注释都很好理解, 这里需要解释一下`watched_keys`字段, 该字段存储了Redis事务中使用WATCH指令关注的KEY, 当对应的KEY发生变更时进行对应的标记, 使得事务执行时能够感知到该变化并拒绝事务执行.

### redisCommand对象

`redisCommand`可以视为Redis中具体指令的实现函数的封装, 增加了ACL控制属性, 指令的文档信息等内容. 其结构体中部分字段如下

```c
struct redisCommand {
    /* Declarative data */
    const char *declared_name; /* A string representing the command declared_name.
                                * It is a const char * for native commands and SDS for module commands. */
    const char *summary; /* Summary of the command (optional). */
    const char *complexity; /* Complexity description (optional). */
    const char *since; /* Debut version of the command (optional). */
    int doc_flags; /* Flags for documentation (see CMD_DOC_*). */
    const char *replaced_by; /* In case the command is deprecated, this is the successor command. */
    const char *deprecated_since; /* In case the command is deprecated, when did it happen? */

    redisCommandProc *proc; /* Command implementation */
    int arity; /* Number of arguments, it is possible to use -N to say >= N */
    uint64_t flags; /* Command flags, see CMD_*. */
    uint64_t acl_categories; /* ACl categories, see ACL_CATEGORY_*. */
};
```

由于Redis中指令众多, 因此在源码的`commands.def`文件中, 通过宏的方式注册了许多指令的信息, 之后通过如下的函数填充到服务端结构体对象之中.

```c
/* Populates the Redis Command Table dict from the static table in commands.c
 * which is auto generated from the json files in the commands folder. */
void populateCommandTable(void) {
    int j;
    struct redisCommand *c;

    for (j = 0;; j++) {
        c = redisCommandTable + j;
        if (c->declared_name == NULL)
            break;

        int retval1, retval2;

        c->fullname = sdsnew(c->declared_name);
        if (populateCommandStructure(c) == C_ERR)
            continue;

        retval1 = dictAdd(server.commands, sdsdup(c->fullname), c);
        /* Populate an additional dictionary that will be unaffected
         * by rename-command statements in redis.conf. */
        retval2 = dictAdd(server.orig_commands, sdsdup(c->fullname), c);
        serverAssert(retval1 == DICT_OK && retval2 == DICT_OK);
    }
}
```

服务端结构体对象
------------------


服务端结构体为`redisServer`, 其中包含了几百个字段, 以下仅列举一些核心的参数

```c
struct redisServer {
    char *configfile;           /* Absolute config file path, or NULL */
    redisDb *db;
    dict *commands;             /* Command table */
    dict *orig_commands;        /* Command table before command renaming. */
    
    aeEventLoop *el;

    int dbnum;                      /* Total number of configured DBs */

    list *clients;              /* List of active clients */
}
```

其中`el`表示事件循环, Redis服务器是典型的事件驱动程序, 而事件又分为文件事件(socket的可读可写事件)与时间事件(定时任务)两大类. 无论是文件事件还是时间事件都封装在结构体aeEventLoop中:

```c
/* State of an event based program */
typedef struct aeEventLoop {
    int maxfd;   /* highest file descriptor currently registered */
    int setsize; /* max number of file descriptors tracked */
    long long timeEventNextId;
    aeFileEvent *events; /* Registered events */
    aeFiredEvent *fired; /* Fired events */
    aeTimeEvent *timeEventHead;
    int stop;
    void *apidata; /* This is used for polling API specific data */
    aeBeforeSleepProc *beforesleep;
    aeBeforeSleepProc *aftersleep;
    int flags;
} aeEventLoop;
```


事件处理机制
--------------

Redis的事件处理机制是基于Reactor模式实现的，主要用于处理客户端连接、读写事件以及定时任务等。Redis的事件处理机制主要包括以下几个核心组件：

**1. 多路复用器（Multiplexer）** 多路复用器负责监听多个文件描述符（例如套接字），并在这些文件描述符上有事件发生时通知Redis。Redis支持多种多路复用器，如`epoll`（Linux）、`kqueue`（BSD/macOS）和`select`（跨平台）。多路复用器的主要优点是可以在单个线程中高效地处理大量并发连接。

**2. 事件处理器（Event Handler）** 事件处理器负责处理不同类型的事件，如连接建立、数据读取、数据写入等。Redis为每种事件类型定义了一个处理器，例如`acceptTcpHandler`用于处理新的TCP连接，`readQueryFromClient`用于从客户端读取查询命令等。

**3. 事件循环（Event Loop）** 事件循环是Redis事件处理机制的核心，它不断地运行并调用多路复用器来检查文件描述符上的事件。当有事件发生时，事件循环会根据事件类型调用相应的事件处理器来处理事件。事件循环会一直运行，直到Redis服务器关闭。

**4. 定时任务（Timers）** Redis还支持定时任务，例如延迟关闭客户端连接、定期持久化数据等。定时任务由一个独立的定时器管理器负责处理。当定时器触发时，相应的事件处理器会被调用。

----------------------------

以下是Redis事件处理的基本流程：

1. 启动Redis服务器时，初始化多路复用器、事件处理器和事件循环。
2. 事件循环开始运行，调用多路复用器检查文件描述符上的事件。
3. 当有事件发生时，多路复用器会返回一个事件列表，其中包含发生事件的文件描述符和事件类型。
4. 事件循环遍历事件列表，根据事件类型调用相应的事件处理器来处理事件。
5. 事件处理器处理完事件后，事件循环继续运行，等待下一个事件发生。
6. 如果有定时任务触发，事件循环会暂停当前的事件处理，调用相应的事件处理器处理定时任务，然后继续处理其他事件。

通过这种事件处理机制，Redis可以在单线程中高效地处理大量并发连接和各种事件，从而实现高性能和高吞吐量。





Redis指令格式
-------------

Redis通信协议（RESP, Redis Serialization Protocol）是Redis客户端与服务器端之间交换数据的一种格式。它是一个简单的基于文本的协议，易于理解和实现。

### 发送指令

Redis客户端发送给服务器端的指令遵循以下格式：

```
*<参数数量>\r\n
$<参数1长度>\r\n
<参数1内容>\r\n
...
$<参数n长度>\r\n
<参数n内容>\r\n
```

- `*<参数数量>`：表示接下来的参数数量，以星号开头，后面跟参数的数量。
- `$<参数长度>`：表示参数的长度，以美元符号开头，后面跟参数的字节长度。
- `<参数内容>`：参数的实际内容。
- `\r\n`：回车换行符，用于分隔不同的部分。

例如，发送一个`SET key value`指令：

```
*3\r\n
$3\r\n
SET\r\n
$3\r\n
key\r\n
$5\r\n
value\r\n
```

### 返回响应

Redis服务器端返回给客户端的响应遵循以下格式：

```
<响应类型><具体内容>
```

响应类型有以下几种：

1. **简单字符串（Simple Strings）**：以`+`开头，表示操作成功或返回一些简单的信息。
2. **错误信息（Errors）**：以`-`开头，表示操作失败或错误信息。
3. **整数（Integers）**：以`:`开头，表示返回一个整数值。
4. **批量字符串（Bulk Strings）**：以`$`开头，表示返回一个字符串。如果长度为`-1`，表示返回空值（nil）。
5. **数组（Arrays）**：以`*`开头，表示返回一个数组。数组中的每个元素可以是上述任意一种类型。

例如，对于`SET key value`指令的响应：

```
+OK\r\n
```

对于`GET key`指令的响应：

```
$5\r\n
value\r\n
```

对于`INCR counter`指令的响应：

```
:1\r\n
```

对于`LRANGE mylist 0 -1`指令的响应：

```
*3\r\n
$5\r\n
first\r\n
$5\r\n
second\r\n
$5\r\n
third\r\n
```

总之，Redis的RESP协议简单易用，使得客户端和服务器端之间的通信变得高效且易于实现。