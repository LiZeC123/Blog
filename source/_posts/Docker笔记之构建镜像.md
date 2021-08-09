---
title: Docker笔记之构建镜像
date: 2021-08-07 10:50:24
categories: Docker笔记
tags:
    - docker
cover_picture: images/docker.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->




Dockerfile指令详解
-------------------


Dockerfile的指令不多，下面逐一介绍Dockerfile涉及的指令。

可以使用FROM指令来指定一个初始的镜像，并使用RUN指令在镜像的基础上执行一些指令来形成新的镜像。

### 复制文件

Dokcerfile中有两个指令可以复制文件，分别是ADD指令和COPY指令。 两个指令没有太大区别，一般采用COPY指令。

COPY指令可以复制单个文件也可以复制整个文件夹。COPY指令复制文件夹时将Host中的一个文件夹中的**全部文件**复制到Guest中的指定文件夹中。

<!-- TODO： 路径和卷？ -->


### 程序入口

程序入口是镜像启动后需要执行的程序。


Docker启动参数
----------------

TODO： 也许需要在另外一篇文章中记录相关内容
端口映射， 卷映射


深入Docker机制
----------------

### 层和缓存


### 限制资源使用量

默认情况下容器使用的CPU和内存是不受限制的， 为了避免容器消耗了太多资源导致其他服务不可用，可以对CPU和内存使用量进行限制。 使用以下参数对CPU使用进行限制


参数           | 含义
--------------|------------------
--cpus        | 指定CPU的使用量，可以包含小数
--cpuset-cpus | 指定具体使用那个CPU
--cpu-shares  | 指定获得CPU的权重

`--cpus=2`可以理解为使用2个CPU `--cpus=0.9`则可以理解为使用0.9个CPU。具体执行的时候， 并不一定是真的使用2个或者0.9个CPU，而是保证在使用时间上等价于使用2个或者0.9个CPU。

`--cpuset-cpus="1,3"`表示容器只在1号和3号CPU行运行。 `--cpu-shares=512`表示获取CPU时间的权重为512（默认值为1024）

---------------

使用以下参数对内存进行限制

参数           | 含义
--------------|------------------
-m            | 指定最大内存使用量
--memory-swap | 指定包括swap在内的可用内存总量， -1表示无限制使用swap

`-m 300M --memory-swap -1`表示最大可用内存为300M，但是可以无限制使用swap空间，`-m 300M --memory-swap 500M`表示最大可用内存为300M，还可以额外使用200M的swap空间。

------------

参考资料

- [Docker: 限制容器可用的 CPU](https://www.cnblogs.com/sparkdev/p/8052522.html)
- [Docker: 限制容器可用的内存](https://cnblogs.com/sparkdev/p/8032330.html)


Dockerfile多阶段构建
-------------------



Docker-Compose文件详解
---------------------



前后端分离部署
-------------

