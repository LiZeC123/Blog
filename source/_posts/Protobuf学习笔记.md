---
title: Protobuf学习笔记
math: false
date: 2025-10-18 21:32:21
categories:
tags:
   - pb
cover_picture: images/protobuf.png
---

protobuf是一种将结构化数据序列化的机制, 可用于内部设备通信或存储. 与JSON格式相比, 基于protobuf协议的二进制文件体积更小, 解析速度更快.


protobuf简介
----------------

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
- [Protobuf通信协议详解：代码演示、详细原理介绍等](https://zhuanlan.zhihu.com/p/141415216)
- [proto2格式说明](https://developers.google.com/protocol-buffers/docs/proto)
- [proto3格式说明](https://developers.google.com/protocol-buffers/docs/proto3)



protobuf命名冲突解决方案
------------------------

对于PB的namespace, 规范要求每个PB都是全局唯一的. 如果设计不合理就会导致PB名称冲突, 对于高版本的依赖库, Go语言在启动时会直接painc, 导致系统无法启动. 

对于上述问题, 可以通过降级依赖版本临时解决:

```go
replace (
	github.com/golang/protobuf => github.com/golang/protobuf v1.4.3
	google.golang.org/protobuf => google.golang.org/protobuf v1.25.0
)
```


Protocol Buffers (PB) 的设计哲学与反序列化安全
----------------------------------------------

PB 通过其“契约优先、编译时绑定、数据纯填充”的设计理念，天然地规避了 Java 原生序列化及某些 JSON 库中常见的反序列化漏洞，为现代分布式系统提供了安全、高效的数据交换基石。

一、 漏洞根源：超越“数据填充”的复杂重建

Java 原生序列化漏洞（如 Common-Collections 利用链）的根源在于其设计目标：完美重建任意复杂的对象图。为实现此目标，它必须：
1.  动态加载类： 根据流中嵌入的类名，通过 ClassLoader 动态加载未知的 .class 文件。
2.  执行回调方法： 在反序列化过程中，自动调用特定方法（如 readObject、readResolve），以恢复对象状态。
3.  处理复杂关系： 自动管理循环引用、继承关系等。

这种复杂性创造了攻击面。攻击者可以精心构造一条 “利用链 (Gadget Chain)”：从一个可序列化类的 readObject 方法开始，通过一系列库中的类的方法调用，最终触发危险操作（如 Runtime.exec()）。其本质是数据流中包含的“指令”被反序列化过程“执行”了。

二、 PB 的设计反击：坚守“数据编码器”的本分

PB 的设计哲学截然不同。它放弃了“完美对象图重建”的宏大目标，将自身严格限定为一个高效的“结构化数据编码器”。其核心理念体现在：

1.  契约优先 (Schema First)： 所有数据结构必须预先在 .proto 文件中明确定义。该文件是独立于语言的、不变的契约。
2.  编译时类型绑定： 通过 protoc 编译器，将 .proto 契约编译成各语言的强类型代码（如 Java 的 User 类）。类型信息在编译时即被硬编码至生成的代码中。
3.  无动态行为： PB 的序列化 (toByteArray) 和反序列化 (parseFrom) API 仅操作生成的、具体的数据容器类。过程如下：
    *   序列化： 将已知类型的对象数据按契约编码为二进制流。
    *   反序列化： 根据调用方指定的目标类型（如 User.parseFrom），严格按照契约将二进制流解码并填充至该类型的对象中。
4.  无回调机制： 整个过程仅是数据拷贝，绝不会调用任何用户定义的构造函数、初始化方法或类似 readObject 的回调。

三、 关键差异与安全优势

特性 Java 原生序列化 / 危险JSON特性 Protocol Buffers 安全优势

类型信息 动态，来自数据流 (className, @type) 静态，来自契约和编译生成 杜绝动态类加载，攻击者无法指定任意类。

反序列化过程 复杂对象图重建，可能执行回调 纯数据填充 无代码执行，无法触发利用链。

多态处理 危险：依赖数据流指定具体类 安全：显式字段标识 + oneof 或 Any + 白名单 接收方主动选择处理已知类型，而非被动加载。

数据流内容 类名、字段名、对象引用句柄等元数据 仅字段编号 (Tag) 和值 (Value) 流中无指令，仅为数据，无法操控解析逻辑。

四、 总结：安全源于克制与显式

PB 的安全优势并非偶然，而是其克制、显式、契约驱动的设计哲学的必然结果。

*   克制 (Restraint)： 它主动放弃了“智能”地重建行为与复杂类型的功能，选择了功能上的“简单”，换取了安全性和性能上的“强大”。
*   显式 (Explicitness)： 所有类型都在编译时确定，所有操作都通过生成的强类型 API 进行。没有隐藏的魔法行为，一切皆可预测。
*   契约驱动 (Contract-Driven)： 通信双方严格依赖共享的 .proto 契约，而非嵌入在数据流中的隐含信息。这确保了数据解析的一致性和安全性。

因此，在技术选型中，PB 因其内在的安全属性，成为微服务通信、数据持久化等场景下的稳妥首选。它提醒我们，在软件设计中，通过限定边界、简化模型、显式约定，往往能从根本上规避一整类的复杂问题，反序列化漏洞正是其中之一。与之相比，在 JSON 中使用 @type 等功能，是一种为了便利性而牺牲安全性的危险妥协，应极力避免。


---

FastJSON（特别是其 `autoType` 特性）的设计理念与 Protocol Buffers 的“契约优先、编译时绑定”原则形成鲜明对比，这种差异直接导致了其高频发的安全漏洞。FastJSON允许 JSON 数据通过 **`@type` 字段动态指定任意类名**（如 `"@type": "com.attacker.Exploit"`）。将**类型解释权交给不可信的数据流**，而非预先定义的契约。攻击者可注入恶意类名，触发类加载。即使开启 `autoType` 白名单，攻击者仍可利用未覆盖的 JDK 或第三方库危险类（如 `BasicDataSource`）。或者利用未覆盖的 JDK 或第三方库危险类（如 `BasicDataSource`）。



踩坑实录：当 Protobuf 的 `[]string` 被当作 `[]int` 读取时发生了什么？
-----------------------------------------------------------------

> **看似正常的代码背后，隐藏着静默数据污染的致命风险——一次由 Protobuf 二进制格式特性引发的诡异 BUG**

### 一、故障现场：类型错乱却“正常”返回数据
最近在开发中遇到一个诡异现象：业务方通过 gRPC 传递了一个 `repeated string` 字段，而我方服务因未更新 `.proto` 文件，仍按 `repeated int32` 解析。奇怪的是：
1. **没有抛出任何错误**
2. **返回了一个非空整数数组**（如 `[104, 101, 108, 108, 111]`）

更匪夷所思的是：**反向操作（`[]int` → `[]string`）却会报错**！这背后究竟隐藏着 Protobuf 的什么秘密？

---

### 二、罪魁祸首：Protobuf 的二进制编码机制
要理解这个 BUG，必须深入 Protobuf 的二进制编码设计。其核心是 **TLV 结构**（Tag-Length-Value）和 **Wire Type 机制**：

#### 1. **TLV 三元组：数据的物理存储单元**
```plaintext
[Tag] [Length] [Value]  // Length 仅变长类型存在
```
- **Tag** = 字段编号 (Field Number) + **Wire Type**（关键！）
- **Wire Type** 决定 Value 的解析方式（而非编程语言类型！）

| Wire Type | 值 | 对应类型          | 数据布局               |
|-----------|----|-------------------|------------------------|
| 0         | Varint | int32/bool/enum   | 变长整数               |
| 1         | 64-bit | double/fixed64    | 固定8字节              |
| 2         | Length-delimited | string/bytes/嵌套消息 | 长度前缀 + 数据块      |
| 5         | 32-bit | float/fixed32     | 固定4字节              |

#### 2. **类型兼容性的真相**
Protobuf 解码器**只认 Wire Type，不认语言类型**：
- 当 Wire Type **匹配**时：尝试解析 Value（即使类型语义错误）
- 当 Wire Type **不匹配**时：跳过 Value 部分（无报错）

---

### 三、BUG 解密：为什么 `[]string` 能解析为 `[]int`？
#### 关键条件：双方都使用 **Wire Type 2**
- 发送方：`repeated string` → **Wire Type 2**（每个元素独立编码）
- 接收方：`repeated int32`（打包模式）→ **Wire Type 2**（整个数组为单个数据块）

#### 灾难性解析过程
假设发送数据 `["hello"]`：
```protobuf
0A 05 68 65 6C 6C 6F  // Wire Type=2, Length=5, Value="hello"
```
接收方按打包的 `[]int` 解析：
1. 读取 Length=5（0x05）
2. 将后续 5 字节 `68 65 6C 6C 6F` 视为 **连续的 Varint 序列**
3. 解析出 5 个整数：  
   `0x68` → 104, `0x65` → 101, `0x6C` → 108...  
   **得到 [104,101,108,108,111]**

> 💣 **这就是为什么会出现“看似正常”的整数数组！**  
> 本质是将字符串的 ASCII 码误解析为 Varint 整数。

---

### 四、反向操作为何会失败？
若发送 `[]int` 而接收方按 `[]string` 解析：
```protobuf
// 打包的 []int [500,600]：
0A 04 F4 03 D8 04  // Wire Type=2, Length=4, 数据=F4 03 D8 04
```
接收方尝试解析字符串：
1. 读取 Length=4（0x04）
2. 将数据块 `F4 03 D8 04` 视为 **多个独立字符串**
3. 解析第一个字符串：
   - 读取长度前缀（Varint）：`0xF4 03` → 500
   - 尝试读取 500 字节 → **超出数据块边界！**
4. 结果：抛出 `DecodingError`（如 "unexpected EOF"）

---

### 五、防御方案：避免静默数据污染


```protobuf
// 永远禁止修改字段类型！
message User {
  repeated string tags = 1;  // ✅ 稳定后不再修改
  // 新增字段用新编号
  repeated int32 tag_ids = 2; 
}
```

