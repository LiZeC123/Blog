---
title: PyTorch笔记之基础知识
date: 2020-02-07 14:04:56
categories: PyTorch笔记
tags:
    - Python
    - PyTorch
cover_picture: images/pytorch.png
math: true
---



Tensor
--------------

Tensor与Numpy的数组类似, 但Tensor可以在GPU上运算. 有两种方式构造Tensor, 第一种方式是直接构造Tensor, 第二种方式将一个Python的数组转化为Tensor. 两种方式的代码如下所示

``` py
x = torch.ones([2, 2, 2])   # torch.Size([2, 2, 2]) 即 2x2x2的Tensor, 且值全部为1
y = torch.tensor([2,2,2])   # torch.Size([3]) 即包含三个元素的Tensor
r0 = torch.rand((2,3), dtype=torch.float32)
```

直接构造方法的API与Numpy类似, 也提供了各种like函数(例如ones_like)创建和输入尺寸相同的数组


### 切片操作

表达式              | 结果                  | 说明
--------------------|-----------------------|--------------------------------
a[0],a[3],a[-2]     | (0, 3, 8)             | 直接访问
a[2:8:2]            | array([2, 4, 6])      | 切片
a[3:7]              | array([3, 4, 5, 6])   | 省略步长
a[:4]               | array([0, 1, 2, 3])   | 省略起始和步长
a[6:]               | array([6, 7, 8, 9])   | 省略末尾和步长



对于二维数据有如下的访问方法和访问结果:

表达式           | 结果                              | 说明
----------------|-----------------------------------|--------------------------------
b[0,0],b[2,-1]  | (0, 25)                           | 直接访问
b[0,2:5]        | array([2, 3, 4])                  | 切片
b[2,:]          | array([20, 21, 22, 23, 24, 25])   | 选取整行
b[:,3]          | array([ 3, 13, 23, 33, 43, 53])   | 选取整列


> 切片操作与Numpy的API相同, 可以参考[相关的笔记](https://lizec.top/2019/01/02/Python%E7%AC%94%E8%AE%B0%E4%B9%8B%E7%A7%91%E5%AD%A6%E8%AE%A1%E7%AE%97/#%E6%95%B0%E6%8D%AE%E8%AE%BF%E9%97%AE)


### 调整维度

pyTorch使用view函数调整维数, 示例如下

``` py
x = torch.randn(4, 4)   # torch.Size([4, 4]) 
y = x.view(16)          # torch.Size([16]) 
z = x.view(-1, 8)       # torch.Size([2, 8]) 
w = x.view(1,-1)        # torch.Size([1, 16]) 
```

**注意:** `-1`表示从其他维度推断此维度的大小

> `torch.Size([16])` 和 `torch.Size([1, 16]) `是不同的, 后者是二维的数组


------------

pyTorch使用squeeze()函数和unsqueeze()函数调整Tensor的维度. squeeze()函数取消数量为1的维度, unsqueeze()函数增加一个数量为1的维度. 例如

``` py
# 创建一个2x3的Tensor, 输出如下所示
>>> x = torch.tensor([[1,2,3],[4,5,6]])
x
tensor([[1, 2, 3],
        [4, 5, 6]])

# 在第0个维度添加一个额外的维度
>>> x.unsqueeze(dim=0)
tensor([[[1, 2, 3],
         [4, 5, 6]]])

# 在第1个维度添加一个额外的维度
x.unsqueeze(dim=1)
tensor([[[1, 2, 3]],
        [[4, 5, 6]]])

# 查看两者情况的维度
>>> x.unsqueeze(dim=0).size()
torch.Size([1, 2, 3])

>>> x.unsqueeze(dim=1).size()
torch.Size([2, 1, 3])
```
 

### 数据转换

- 如果Tensor中仅包含一个元素, 则无论此Tensor的维度是多少, 都可以使用`item()`方法取值.
- 使用`from_numpy()`将numpy数组转化为Tensor, 使用`numpy()`函数将Tensor转化为numpy数组


### PyCharm与Debug

Pycharm的Debug模式只会显示Tensor的第一个维度的信息, 例如

``` py
x2 = torch.tensor([[1, 2, 3], [4, 3, 5]])
x3 = torch.tensor([[[1, 2, 3], [4, 3, 5]], [[1, 2, 3], [4, 3, 5]]])
```

Debug时看到的信息如下所示:
```
x2 = {Tensor:2} tensor([[1, 2, 3], \n [4, 3, 5]])
x2 = {Tensor:2} tensor([[[1, 2, 3], \n [4, 3, 5]], \n\n [[1, 2, 3], \n [4, 3, 5]]])
```

因此获取维度信息最准确的办法是在Debug时使用变量计算机直接调用Tensor的size()方法

> 显示的信息包含了一些换行符号(\n), 因此直接输出的效果与IPython中的Numpy矩阵类似


### 自动微分概述

PyTorch提供自动微分功能

- 定义Tensor时指定参数`requires_grad=True`可以开启自动微分的记录功能
- 在Tensor上调用`backward()`函数将梯度信息写入Tensor的`grad`字段
- 如果Tensor是标量, 则`backward()`函数不需要参数, 否则需要提供一个Tensor作为参数



Module
--------------

通常使用python的类机制构建Module, 每个Module就是一个可以独立计算的模块. 一个标准的Module一般具有如下的结构

```py
class NGramLanguageModeler(nn.Module):
    def __init__(self, vocab_size, embedding_dim, context_size):
        super(NGramLanguageModeler, self).__init__()
        self.embeddings = nn.Embedding(vocab_size, embedding_dim)
        self.linear1 = nn.Linear(context_size * embedding_dim, 128)
        self.linear2 = nn.Linear(128, vocab_size)

    def forward(self, inputs):
        embeds = self.embeddings(inputs).view((1, -1))
        out = F.relu(self.linear1(embeds))
        out = self.linear2(out)
        log_probs = F.log_softmax(out, dim=1)
        return log_probs
```


可以明显的看到代码具有如下的特点:
- 自定义模块继承标准的nn.Module类
- 在init函数中构造网络的子模块
- 在forward函数中定义网络的正向计算过程
- 通常init函数定义包含可训练参数的模块, forward模块定义不包含可训练参数的模块

> 内置的模块都定义在nn包中

此外还要注意以下几点:
- nn.Module类自动计算反向传播过程
- nn.Module类重载了`call`运算符, 因此直接圆括号调用模型, 不需要手动调用forward方法

> 圆括号调用使得我们的自定义模块和内置的模块的调用方法一致, 便于将我们的模块嵌入到其他模块之中


### 小知识

- 任何会就地(in place)改变Tensor的操作都会后置一个`_`符号, 例如 y.add_(x)
- [PyTorch 的 backward 为什么有一个 grad_variables 参数？](https://zhuanlan.zhihu.com/p/29923090)
因为张量对张量的求导不易表示, 因此框架强制限定只能做标量对张量的求导(结果始终是确定维数的张量). 如果需要微分的变量是张量, 则传递另外一个张量, 将带求变量求和成标量后再求导数

训练过程
------------

完成网络的forward计算以后, 训练过程就相对比较固定了, 可以分为如下的步骤
1. 构造网络的输入数据
2. 清空网络的梯度
3. 使用网络计算输出
4. 计算损失函数值loss
5. loss计算整个图的梯度并使用优化器优化网络

整个过程可以参考以下的代码

``` py
for epoch in range(10):
    total_loss = 0
    for context, target in trigrams:
        # Step 1. Prepare the inputs to be passed to the model (i.e, turn the words
        # into integer indices and wrap them in tensors)
        context_idxs = torch.tensor([word_to_ix[w] for w in context], dtype=torch.long)

        # Step 2. Recall that torch *accumulates* gradients. Before passing in a
        # new instance, you need to zero out the gradients from the old
        # instance
        model.zero_grad()

        # Step 3. Run the forward pass, getting log probabilities over next
        # words
        log_probs = model(context_idxs)

        # Step 4. Compute your loss function. (Again, Torch wants the target
        # word wrapped in a tensor)
        loss = loss_function(log_probs, torch.tensor([word_to_ix[target]], dtype=torch.long))

        # Step 5. Do the backward pass and update the gradient
        loss.backward()
        optimizer.step()

        # Get the Python number from a 1-element Tensor by calling tensor.item()
        total_loss += loss.item()
    losses.append(total_loss)
```

损失函数和优化器都有多种选择, 可以参考[官方文档](https://pytorch.org/docs/stable/index.html).



保存和加载
-----------------


```py
# 保存和加载整个模型
torch.save(model_object, 'model.pt')
model = torch.load('model.pt')

# 仅保存和加载模型参数(推荐使用)
torch.save(model.state_dict(), 'params.pt')
model.load_state_dict(torch.load('params.pt'))
```

> 每一轮训练后都应该及时存档, 以免意外中断导致计算结果丢失


GPU操作
------------

如果服务器上存在多块GPU, PyTorch默认使用第0块GPU, 如果此时第0块GPU正在运行程序, 则可以手动指定其他GPU. 例如希望在第1块GPU上运行, 则可以输入

```
CUDA_VISIBLE_DEVICES=1 python my_script.py
```

