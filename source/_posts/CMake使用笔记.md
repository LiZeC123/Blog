---
title: CMake使用笔记
date: 2019-01-31 22:37:56
categories:
tags:
    - CMake
cover_picture: images/cmake.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->

CMake是一个跨平台的构建工具, 通过编写CMakeList.txt文件, 可以轻松的产生需要的Makefile文件, 从而简化构建脚本的编写难度. 和make类似, CMake需要一个名为CMakeLists.txt的文件, 通过编写此文件来制定编译过程中的各种细节, CMake在依据这个文件来产生相应的Makefile.



使用CMake
------------
对于一个CMake的系统而言, 通常执行如下的几步来完成软件的编译

``` bash
cmake .
make
make install
```
其中cmake后面的参数是CMakeLists.txt的路径. 在本例中, 此文件正好位于当前目录. 使用cmake生成Makefile时, 会产生很多中间文件. 因此也可以先创建一个build目录, 然后在build之中进行编译.

之前尝试对原来使用功能Makefile维护的一个C++项目使用CMake替换, 但实际操作后发现CMake并没有对原来的问题给出更好的解决, 而对于部分问题甚至还需要一些不太优雅的方式来完成. 因此以下仅给出两篇质量较高的CMake相关的博客, 不再具体介绍CMake的有关内容.

博客如下:

- [CMake 入门实战 -HaHack](https://www.hahack.com/codes/cmake/)
- [VS Code与CMake真乃天作之合 -知乎专栏](https://zhuanlan.zhihu.com/p/52874931)
