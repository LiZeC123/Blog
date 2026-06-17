

编译SDS模块最小的依赖文件列表

```
.
├── main.c
└── sds
    ├── atomicvar.h
    ├── config.h
    ├── fast_float_strtod.c
    ├── fast_float_strtod.h
    ├── fmacros.h
    ├── fpconv_dtoa.c
    ├── fpconv_dtoa.h
    ├── fpconv_powers.h
    ├── redisassert.c
    ├── redisassert.h
    ├── sds.c
    ├── sds.h
    ├── sdsalloc.h
    ├── sha256.c
    ├── sha256.h
    ├── solarisfixes.h
    ├── util.c
    ├── util.h
    ├── zmalloc.c
    └── zmalloc.h
```

文件名与含义如下:

| 文件名                       | 主要功能                                                                                                                    |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `atomicvar.h`                | 提供跨平台的原子变量操作（增、减、比较交换等），用于无锁计数和并发控制。                                                    |
| `config.h`                   | 根据编译环境自动检测系统相关特性（字节序、大页支持、`__attribute__` 等），供条件编译使用。                                  |
| `fast_float_strtod.c` / `.h` | 实现快速字符串到双精度浮点数的转换（`strtod` 替代方案），基于 fast_float 算法提升性能。                                     |
| `fmacros.h`                  | 定义必要的 feature test 宏（如 `_GNU_SOURCE`），确保启用现代 POSIX 或 GNU 扩展函数。                                        |
| `fpconv_dtoa.c` / `.h`       | 提供双精度浮点数到字符串的高效转换（dtoa），用于 Redis 中浮点数的序列化与输出。                                             |
| `fpconv_powers.h`            | 被 `fpconv_dtoa` 使用，预计算 10 的幂次表，加速浮点数转换过程。                                                             |
| `redisassert.c` / `.h`       | 实现 Redis 自定义断言宏（`redisAssert`、`redisPanic`），断言失败时打印调用栈并崩溃，便于调试。                              |
| `sds.c` / `.h`               | 实现简单动态字符串（SDS），Redis 内部主要字符串类型，支持自动内存管理、二进制安全等。                                       |
| `sdsalloc.h`                 | 为 SDS 提供内存分配器封装（默认使用 `zmalloc`，可替换为 libc malloc 或 jemalloc）。                                         |
| `sha256.c` / `.h`            | SHA-256 哈希算法的实现，用于 Redis 的认证、ACL 密码存储等安全功能。                                                         |
| `solarisfixes.h`             | 针对 Solaris 系统的兼容性修补，定义缺失的宏或函数替代。                                                                     |
| `util.c` / `.h`              | 提供大量工具函数：字符串与数值转换、路径处理、文件 I/O 辅助、时间处理、随机数等。                                           |
| `zmalloc.c` / `.h`           | 实现 Redis 自身的内存分配器封装（`zmalloc`、`zfree`、`zrealloc`），支持内存使用统计、OOM 处理，并可集成 jemalloc/tcmalloc。 |


