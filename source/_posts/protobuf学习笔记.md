---
title: protobuf学习笔记
math: false
date: 2022-07-23 22:42:41
categories:
tags:
cover_picture:
---





protobuf是一种将结构化数据序列化的机制, 可用于内部设备通信或存储. 与JSON格式相比, 基于protobuf协议的二进制文件体积更小, 解析速度更快.




protobuf修饰词
----------------

### 修饰词

- required: a well-formed message must have exactly one of this field.
- optional: a well-formed message can have zero or one of this field (but not more than one).
- repeated: this field can be repeated any number of times (including zero) in a well-formed message. The order of the repeated values will be preserved.


### 类型

| 类型                                 | 解释                               |
| ------------------------------------ | ---------------------------------- |
| float, double                        | 浮点数                             |
| int32, int64, uint32, uint64         | 整数，但不适合编码较大的数字和负数 |
| sint32, sint64                       | 针对负数进行优化的整数类型         |
| fixed32, fixed64, sfixed32, sfixed64 | 更适合大数字的有符号数或无符号数   |
| bool                                 | 布尔值                             |
| string                               | 任意的UTF-8字符串                  |
| byte                                 | 任意的字节                         |

protobuf对数字存储进行了优化，一个数字越小则存储长度越短。由于计算机使用补码表示负数，因此通常情况下负数将使用多个字节表示。为了优化这种情况，sint类型使用交叉的方式表示，绝对值较小的负数依然可以获得较短的存储长度。

- [官方文档](https://developers.google.com/protocol-buffers/docs/overview)
- [Protobuf通信协议详解：代码演示、详细原理介绍等CPP加油站](https://zhuanlan.zhihu.com/p/141415216)
- [proto2格式说明](https://developers.google.com/protocol-buffers/docs/proto)
- [proto3格式说明](https://developers.google.com/protocol-buffers/docs/proto3)


