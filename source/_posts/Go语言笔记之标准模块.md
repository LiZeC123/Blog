---
title: Go语言笔记之标准模块
date: 2022-01-11 11:42:25
categories: Go语言笔记
tags: 
    - Go
cover_picture: images/go.png
---



本文主要介绍GO的标准库中一些最常用的重要模块. 由于Go并不是我的第一门语言, 所以本文将对照C, Java, Python等语言, ...



IO操作
---------

### 基础接口

与Java的抽象一样, Go也提供了一套统一的IO操作, 无论是读写文件, 读写网络数据, 读写标准输入输出还是读写字符串, 都可以抽象为对应的IO读写操作, 基于IO接口的上层函数也可以应用到任意的一种实现了IO接口的数据类型上. Go语言中定义了两个基本的IO接口, 即

```go
type Reader interface {
	Read(p []byte) (n int, err error)
}

type Writer interface {
	Write(p []byte) (n int, err error)
}
```

对于Read方法, 向切片p中读取len(p)个字节的数据. 对于Write方法, 将切片p中的数据写入.

> 注意: Read方法的err可能会返回io.EOF, 因此做错误处理时需要额外处理这种情况.

常用的实现了IO接口的库包括os.File, strings.Reader, bufio.Reader/Writer, bytes.Buffer, bytes.Reader, net/conn

### 扩展接口

```go
type ReaderFrom interface {
	ReadFrom(r Reader) (n int64, err error)
}

type WriterTo interface {
	WriteTo(w Writer) (n int64, err error)
}
```

这两个接口提供了从IO接口读取或者写入全部数据的功能. 由于这两个方法不返回数据, 因此一般是Writer对象实现ReadFrom方法, Reader对象实现WriteTo方法, 从而将一个IO流中的数据全部移动到另一个IO流中.



### ioutil包

ioutil包定义了几个比较常用的函数, 包括读取全部数据, 读写文件, 读写目录等, 具体函数前面如下:

```go
func ReadAll(r io.Reader) ([]byte, error)
func ReadFile(filename string) ([]byte, error)
func WriteFile(filename string, data []byte, perm fs.FileMode)
func ReadDir(dirname string) ([]fs.FileInfo, error)
```

### bufio包

bufio包提供缓冲操作, 从而提高读写的效率. 不过由于Go默认的Reader接口是读取数据到指定的切片之中, 因此天然就可以一次性读取一整块数据. 如果在某些场合, 需要一个字节一个字节的读取数据, 则此时引入一个缓冲层能够提高读写的效率.

bufio包提供了NewReader等方法创建一个带缓冲的Reader对象, 后续可以直接将该对象当做Reader对象使用. 此外, bufio的Reader对象还提供了一些有帮助的简化方法, 例如

```go
func (b *Reader) ReadSlice(delim byte) (line []byte, err error)
func (b *Reader) ReadBytes(delim byte) ([]byte, error)
func (b *Reader) ReadString(delim byte) (string, error)
```

> 对于简单的文本读写, 还可以使用bufio包中的Scanner对象.

> bufio包也提供了Write缓冲, 并且有一组类似的方法

