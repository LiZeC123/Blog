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


Dockerfile的指令不多，只需要理解几个简单的指令就可以构建一个自定义的镜像。一个Dockerfile一般具有如下的一些指令，以下分别介绍这些指令的含义。

```Dockerfile
FROM python:3.8-alpine
WORKDIR /app
COPY app/requirements.txt /app/requirements.txt
RUN pip3 install -r requirements.txt
COPY app .
VOLUME [ "/app/config", "/app/data"]
EXPOSE 4231
ENTRYPOINT [ "python3", "app.py"]
```

### 指定基础镜像

自定义的镜像可以再一个基础镜像上进行处理，从而避免一些重复性的工作。 使用`FROM`指令指定基础镜像，可用的基础镜像可以[Docker Hub](https://hub.docker.com/)上查询。

> alpine是一种体积非常小的操作系统，一般的镜像都有针对alpine系统的版本

### 设定工作目录

使用`WORKDIR`指令指定镜像内的工作目录（相当于shell的当前目录），后续的操作默认都是在当前工作目录下执行。例如在上面的Dockerfile中，将工作目录指定为`/app`，那么后续的RUN指令和COPY指令也就将`/app`路径作为当前目录。

### 复制文件

`COPY`指令将Host中的文件复制到Guest中， 既可以复制单个文件也可以复制整个文件夹。`COPY`指令复制文件夹时将Host中的一个文件夹中的**全部文件**复制到Guest中的指定文件夹中。因此上面的例子中将Host中的`app`路径下的所有文件复制到Guest的工作目录中（也就是前面指定的`/app`）

> Dokcerfile中有两个指令可以复制文件，分别是ADD指令和COPY指令。 两个指令没有太大区别，一般采用COPY指令。

### 程序入口

`ENTRYPOINT`指定镜像启动后需要执行的程序。 例如上面的例子指定程序启动时执行python指令。

> 注意：镜像中将直接启动指定的程序而不是用shell启动，因此并不能执行shell的语法




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

