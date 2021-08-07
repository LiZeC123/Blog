---
title: Attention机制
theme: solarized
revealOptions:
  transition: fade
date: 2020-03-29 21:04:45
---

## Attention Is All You Need



---

### 目录

1. 循环神经网络
2. 注意力机制
3. Transformer模型
4. BERT模型

Note:
- 首先我想介绍一下为什么我们需要循环神经网络
- 然后介绍如何在循环神经网络中加入注意力机制
- 接下来我会介绍Transformer模型的细节, 以及它是如何做到Attention is all you need.
- 最后, 我会在Transformer的基础上简要的介绍一下BERT模型


---

### 前馈神经网络


![传统的神经网络结构](images/bert-1.jpg)

----


- 网络结构固定
- 两次计算过程相互独立

Note:
- 由输入层, 若干隐含层和一个输出层构成
- 网络结构固定对于长度不定的语言来说是一个缺陷, 自然语言文本的长度是不确定的.
- 计算过程独立, 自然语言文本的每个词与周围的词都存在的一定的关系, 前馈神经网络无法很好的捕捉这一点



---

### 循环神经网络


![按时间展开的循环神经网络](images/bert-2.jpg)

Note:
- 横向箭头表示按照时间展开

----


![完整的循环神经网络](images/bert-3.jpg)

---

### 编码解码框架

![Encode-Decode](images/bert-4.jpg)

- 输入中文, 输出英文 --> 翻译系统
- 输入文章, 输出摘要 --> 文本摘要系统
- 输入问题, 输出回答 --> 问答系统


----


![RNN进行翻译的问题](images/bert-6.jpg)

- 将所有信息压缩成固定长度的中间向量
- 输入与输出之间没有明确的对应关系
- 运算过程相互依赖, 无法并行加速


Note: 

- 如果网络比较小, 训练数据少, 这也不算是一个问题, 但如果向扩大模型的规模, 那么无法并行加速就导致网络的规模受到限制

---

### Attention机制


![Attention机制的简单解释](images/bert-6.jpg)

Note:
- 每次输入都有一个中间表示
- 每次都可以注意某一部分信息

----

![Attention机制的简单解释](images/bert-7.jpg)


----

![权重关系图](images/bert-9.jpg)

Note: 
- 每个词都可以关注输入的任何部分, 解决了信息损失的问题
- 提供了一定的可解释性


----

Attention机制就是给输入分配权重


---

### Attention机制的数学表示

$$Attention(Q,K,V) = Softmax(\frac{QK^T}{\sqrt{d_k}})V$$

----

![Attention机制的简单解释](images/bert-8.jpg)

$$Attention(Q,K,V) = Softmax(\frac{QK^T}{\sqrt{d_k}})V$$


Note: 点乘只是最简单的一种方式, 不一定是点乘

---

### Self-Attention机制

![Attention机制的简单解释](images/bert-8.jpg)

$$Attention(Q,K,V) = Softmax(\frac{QK^T}{\sqrt{d_k}})V$$

---


### Transformer模型

![Transformer宏观结构](images/bert-10.jpg)

----

![Transformer架构图](images/bert-11.jpg)


----

![Transformer宏观架构图](images/bert-12.jpg)

----

![Encoder内部的结构](images/bert-13.jpg)

----

![Encoder的并行计算](images/bert-14.jpg)



---

### Transformer计算过程

![注意力机制计算过程](images/bert-15.jpg)


----

![注意力机制计算过程](images/bert-16.jpg)

----

![image](images/bert-17.jpg)

----

![image](images/bert-18.jpg)


---

### Transformer的多头机制

![Transformer的多头机制](images/bert-19.jpg)


----

![多头机制输出的输出](images/bert-20.jpg)

----

![多头机制输出的合并](images/bert-21.jpg)

----

![多头机制的完整计算过程](images/bert-22.jpg)

---


### 残差连接和归一化

![全局结构](images/bert-24.jpg)

----

![残差连接和归一化](images/bert-23.jpg)

---

### Decoder结构

![全局结构](images/bert-24.jpg)


----

![全局计算过程](images/bert-25-2.gif)

----

![全局计算过程](images/bert-25.gif)

---

### 位置编码

![全局结构](images/bert-24.jpg)

Note: 抛弃了RNN架构的同时, 获得了可以并行计算的好处, 但同时又失去了输入之间相互关联的好处, 从而引入位置编码

---

### 两个问题

1. 如何理解Self-Attention
2. Transformer能不能并行计算


----



![Self-Attention自动识别代词](images/bert-28.jpg)

- 上下文向量

Note: 
Amazing, 上下文向量, 卷积, 底层的网络抽取细节, 高层的网络抽取语义



----

#### Teacher Forcing

![Transformer架构图](images/bert-11.jpg)

---


### BERT模型

BERT: Bidirectional Encoder Representations from Transformers.


![image](images/bert-26.jpg)


----

![image](images/bert-27.jpg)

---

### 个人感受


1. Attention机制解决了信息遗忘问题
2. 位置嵌入机制解决了词语顺序信息的问题
3. Teacher Frocing技术解决了训练并行化问题
4. Self Attention提取了上下文信息
5. 多方面的获取资源: 论文, 博客, 知乎, 视频等

  
---

### 参考资料

- [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)
- [What is a Transformer?](https://medium.com/inside-machine-learning/what-is-a-transformer-d07dd1fbec04)
- [Self-Attention与Transformer](https://zhuanlan.zhihu.com/p/47282410)
- [More About Attention](https://zhuanlan.zhihu.com/p/106662375)