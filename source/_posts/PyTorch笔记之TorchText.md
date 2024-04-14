---
title: PyTorch笔记之TorchText
date: 2020-04-11 12:13:30
categories: PyTorch笔记
tags:
    - Python
    - PyTorch
    - 自然语言处理
cover_picture: images/pytorch.png
---



本文介绍PyTorch的文本处理库TorchText. 在自然语言相关的任务中, 训练模型的第一步就是对文本数据进行预处理. 通常文本数据的预处理包括: (1) 从磁盘加载文本数据并分词; (2) 将单词映射为数字, 将句子映射成数字的列表; (3) 将数据转化为分批次的数据. 本文的主要内容是TorchText的基本概念以及上述预处理过程的TorchText实现方法.

TorchText概述
--------------

TorchText的作用是从文本文件, csv文件, json文件或者文件夹中读取数据并转换为一种标准格式的Dataset. 之后, TorchText使用迭代器对数据集中的数据进行数字化, 批次化等操作并决定是否将数据输送到GPU的显存之中. TorchText涉及如下的几个概念


概念    | 含义                             | 概念    | 含义
--------|---------------------------------|---------|---------------------------------------------
Dataset | 存储数据的对象, 由Example构成     | Example | 一个训练数据, 例如一行记录
Fields  | 定义数据集属性的处理方法          | Iterator | 定义数据的批次化, 数字化和遍历顺序等输入细节


关于上述几个类有几种**实现**, 每种实现提供什么**功能**可以参考[官方文档](https://torchtext.readthedocs.io/en/latest/data.html). 以下分别介绍这些概念的基础信息.


Fields
------------

Fields的含义是字段, 但在TorchText中指的是数据的处理方式,  Fields指定数据集的字段的处理方法. 例如一个数据集可能按照如下的方式定义

``` py
from torchtext.data import Field
tokenize = lambda x: x.split()
TEXT = Field(sequential=True, tokenize=tokenize, lower=True)

LABEL = Field(sequential=False, use_vocab=False)
```

上面是一个分类任务, 其中文本是连续的句子, 而标签是一个词, 因此两者的处理方式显然不同. Fieid提供了很多字段来表达如何对某个字段的数据进行处理, 一些常见的字段含义如下表所示. 

参数        | 含义
------------|-------------------------------------------
sequential  | 是否需要对输入分词
use_vocab   | 是否使用单词表, 否则表明输入已经数字化了
lower       | 是否将字母转化为小写字母
fix_length  | 是否有固定长度

> Fieid的Doc String提供了详细的说明, 编程时可以直接参考

TorchText提供了多种不同功能的Field, 具体效果可以参考文档的[Field章节](https://torchtext.readthedocs.io/en/latest/data.html#field).


Dataset
----------------

如果给定的数据是CSV这类格式化数据, 可以使用TorchText提供的TabularDataset类, 此类可以自动完成数据的读取和分割操作. 具体代码如下所示

``` py

from torchtext.data import TabularDataset

tv_datafields = [("id", None),  
                 ("comment_text", TEXT), ("toxic", LABEL),
                 ("severe_toxic", LABEL), ("threat", LABEL),
                 ("obscene", LABEL), ("insult", LABEL),
                 ("identity_hate", LABEL)]

# splits函数可以分别制定训练集, 验证集和测试集的文件位置. 给定几个位置, 就返回几个数据集
trn, vld = TabularDataset.splits(
    path="data",  
    train='train.csv', validation="valid.csv",
    format='csv',
    skip_header=True,
    fields=tv_datafields)

tst_datafields = [("id", None),  ("comment_text", TEXT)]

tst = TabularDataset(
    path="data/test.csv",  # the file path
    format='csv',
    skip_header=True,
    fields=tst_datafields)

```

在构建数据组的过程中, 我们首先创建(name, field)的元组列表, 其中name指定的数据列的名称, field指定了数据的处理方式. 使用同一field的字段共用单词表. 这个列表需要和数据集的属性一一对应. 对于我们不使用的属性列, 可以将field列置为None.


由于python是动态语言, 因此可以通过访问相应的字段获得相应的数据, 具体如下所示:

``` py
>>> trn[0]
torchtext.data.example.Example at 0x10d3ed3c8
>>> trn[0].__dict__.keys()
dict_keys(['comment_text', 'toxic', 'severe_toxic', 'threat', 'obscene', 'insult', 'identity_hate'])
>>> trn[0].comment_text[:3]
['explanation', 'why', 'the']
```

从上面的输出可以注意到如下的几点:

1. Dataset确实是Example组成的列表.
2. 数据集中的句子已经被分词, 但还没有转化为数字


### 划分数据集

注意到上面的代码分别读取了测试集的文件和验证集的文件. 如果给定的数据集并没有专门的划分测试集和验证集, 则可以通过`split`方法进行划分. 示例如下:

``` py
dataset = TabularDataset(
    path="data/all.csv",  
    format='csv',
    skip_header=True,
    fields=tst_datafields)

# 指定测试集与验证集的比例
trn, vld = dataset.split(split_ratio=0.9)

# 完整的指定所有的比例为8:1:1
trn, test, vld = dataset.split(split_ratio=[8,1,1])
```

`split`方法的参数传递方式比较复杂, 但我认为主要是以上的两种使用方法, 更多细节可以参考此方法的[文档](https://torchtext.readthedocs.io/en/latest/data.html#torchtext.data.Dataset.split)



Vocab
---------------

### 构建单词表

从Dataset的`comment_text`字段的输出可以看到, 句子已经被分词, 但还没有转化为数字, 因此接下来需要执行数字化操作, 将每个单词对应一个数字, 这一操作只需要一行代码, 即

``` py
TEXT.build_vocab(trn)
```

测试集(trn)中所有与TEXT绑定的属性都会被遍历一次, 将所有的单词构成一个词表. 经过此操作后, TEXT会包含两个字典`TEXT.vocab.stoi`和`TEXT.vocab.itos`. 这两个字典实现了单词到数字和数字到单词的转换, 一个例子如下所示

``` py

In[9] :TEXT.vocab.stoi
Out[9]: 
defaultdict(<bound method Vocab._default_unk_index of <torchtext.vocab.Vocab object at 0x7efe7974f310>>,
            {'<unk>': 0,
             '<pad>': 1,
             'the': 2,
             ...})
```

> 如果查询的单词不在单词本中, 则使用`<unk>`符号代替(表示Unknow)


### 预训练词向量

TorchText提供了加载预训练词向量的功能, 内置的词向量列表如下所示:


``` py
pretrained_aliases = {
    "charngram.100d": partial(CharNGram),
    "fasttext.en.300d": partial(FastText, language="en"),
    "fasttext.simple.300d": partial(FastText, language="simple"),
    "glove.42B.300d": partial(GloVe, name="42B", dim="300"),
    "glove.840B.300d": partial(GloVe, name="840B", dim="300"),
    "glove.twitter.27B.25d": partial(GloVe, name="twitter.27B", dim="25"),
    "glove.twitter.27B.50d": partial(GloVe, name="twitter.27B", dim="50"),
    "glove.twitter.27B.100d": partial(GloVe, name="twitter.27B", dim="100"),
    "glove.twitter.27B.200d": partial(GloVe, name="twitter.27B", dim="200"),
    "glove.6B.50d": partial(GloVe, name="6B", dim="50"),
    "glove.6B.100d": partial(GloVe, name="6B", dim="100"),
    "glove.6B.200d": partial(GloVe, name="6B", dim="200"),
    "glove.6B.300d": partial(GloVe, name="6B", dim="300")
}
```

如果需要使用这些词向量, 可以通过的两种方式使用

``` py
# 直接通过名称获取预训练词向量
TEXT.build_vocab(train, vectors="glove.6B.200d")

# 或者通过一个具体的类型来获取相应的词向量
TEXT.build_vocab(train, vectors=GloVe(name='6B', dim=300))
```

> TorchText将会通过网络下载对应的预训练词向量

通过上述的方法加载词向量后, 可以将词向量的值传递给Embedding层, 代码如下

``` py
# 通过pytorch创建的Embedding层
embedding = nn.Embedding(2000, 256)
# 指定嵌入矩阵的初始权重
weight_matrix = TEXT.vocab.vectors
embedding.weight.data.copy_(weight_matrix )
```

加载预训练词向量后, Field对象的`vocab`字段会加载词向量(即vectors). 将词向量复制给Embedding层的权重矩阵, 即可实现词向量的加载.




Example
---------------

针对表格类型的数据集, TabularDataset能够很好的处理,  但如果涉及更一般的数据集, 则必须使用更一般的方式构建. 因为Dataset实际是就是Example的列表, 因此构建自定义数据集的关键就是构建Example. 

``` py
from torchtext.data import Example
from torchtext.data import Field, Dataset
# 假设数据集由两句话构成
text = ["How are you?", "I am fine. Thank you."]

# 同样的构建Field
TEXT = Field(sequential=True, tokenize=lambda x: x.split(), lower=True)
LABEL = Field(sequential=False, use_vocab=False)
fields = [("text", TEXT), ("label", LABEL)]

examples = []
for t in text:
    # 每一个Example中, text部分来自t, label部分始终等于"LABEL"
    examples.append(Example.fromlist([t, "LABEL"], fields))

# 通过Example和Field构建Dataset
dataset = Dataset(examples, fields)
```

> Example还提供了从CVS和JSON读取数据的方法


Iterator
----------------

迭代器的作用是完成最后的数据处理, 包括基本的数据转换, 将数据组成批次, 数据移动到GPU等. 

``` py
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

train_iter, val_iter = BucketIterator.splits(
    (trn, vld),  # we pass in the datasets we want the iterator to draw data from
    batch_sizes=(64, 64),
    device=device,
    sort_key=lambda x: len(x.comment_text),
    sort_within_batch=False,
    repeat=False  
)
test_iter = Iterator(tst, batch_size=64, device=device, sort=False, sort_within_batch=False, repeat=False)
```

BucketIterator支持批量操作, 因此可以同时输入多个数据集, BucketIterator就相应的返回多个迭代器. BucketIterator的特点是支持对数据进行排序, 从而将相似的数据移动到同一批次. 当数据需要进行填充对齐时, 可以利用这一特点将长度相近的数据移动到一起, 从而提高效率.


测试集通常不需要改变顺序, 因此可以使用普通的迭代器.

------------

迭代器创建之后, 可以调用`__iter__()`方法获得迭代器对象, 并使用Python的`next()`函数获取数据. 不过由于接口和数据集的字段有一些耦合, 因此可以使用下面的类对迭代器进行包装

``` py

class BatchWrapper:
    def __init__(self, dl, x_var, y_vars):
        self.dl, self.x_var, self.y_vars = dl, x_var, y_vars  # we pass in the list of attributes for x

    def __iter__(self):
        for batch in self.dl:
            x = getattr(batch, self.x_var)  # we assume only one input in this wrapper

            if self.y_vars is not None:  # we will concatenate y into a single tensor
                y = torch.cat([getattr(batch, feat).unsqueeze(1) for feat in self.y_vars], dim=1).float()
            else:
                y = torch.zeros((1))

            yield (x, y)

    def __len__(self):
        return len(self.dl)
```

这个类的作用是将迭代器的属性分成x和y两个集合, 从而方便后续的处理. 使用方法如下所示

``` py
train_dl = BatchWrapper(train_iter, "comment_text",
                        ["toxic", "severe_toxic", "obscene", "threat", "insult", "identity_hate"])
valid_dl = BatchWrapper(val_iter, "comment_text",
                        ["toxic", "severe_toxic", "obscene", "threat", "insult", "identity_hate"])
test_dl = BatchWrapper(test_iter, "comment_text", None)
```


一点细节
--------------


### 如何加载词向量

以下是`torchtext.vocab.Vocab.load_vectors`方法的代码片段. vectors是加载的预训练词向量, self.vectors是根据任务构建的词汇向量表.

``` py
tot_dim = sum(v.dim for v in vectors)
self.vectors = torch.Tensor(len(self), tot_dim)
for i, token in enumerate(self.itos):
    start_dim = 0
    for v in vectors:
        end_dim = start_dim + v.dim
        self.vectors[i][start_dim:end_dim] = v[token.strip()]
        start_dim = end_dim
    assert(start_dim == tot_dim)
```

从上面的代码可以发现, 加载词向量的过程就是根据任务构建的词汇表向预训练词汇表查询的过程. 如果预训练的vectors是一个列表, 那么还可以自动实现将多个预训练向量首位拼接为一个向量的功能.

为了保证通用性, 预训练的词向量文件加载后提供 "根据单词查询向量" 的功能, 是非常符合逻辑的. 预训练词表中没有的单词的取值情况显然取决于各个词表的默认行为了.