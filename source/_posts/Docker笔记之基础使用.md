---
title: Docker笔记之基础使用
date: 2020-06-19 14:17:47
categories: Docker笔记
tags:
    - Docker
cover_picture: images/docker.jpg
---



Docker可以视为一种轻量级的虚拟机, 可以将应用程序和其依赖环境进行打包, 从而在新平台上直接部署. 由于Docker将程序的依赖全部打包到一起, 因此极大的简化了部署操作, 提高了软件部署的效率.

此外, 由于Docker本身具有的隔离性, 将其作为开发环境使用也非常方便, 可以随意尝试各种指令. 如果出现问题只需要重新运行镜像就可以恢复到最初的状态.

在适合Docker的场景下, 使用Docker可以减少工作量, 在其他场景下, 使用脚本可能是一个更适合的方案. 本文介绍Docker的基本概念, 配置方法, 和基本使用.



Docker安装与配置
----------------------

对于Linux系统, 可以直接执行apt进行安装, 指令如下

```
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

> 注意: 如果已经安装了docker, 需要先卸载相关组件在进行安装

其他的安装方式, 可以参考如下内容
- [How To Install Docker On Ubuntu 18.04 Bionic Beaver](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04)


### (已失效)配置国内加速器

> 25.09更新: 由于相关监管需求, 目前已经没有国内加速器可以使用, DockerHub也主动屏蔽了很多IP. 只能使用特定网站的镜像服务来获取
> 可考虑使用[毫秒镜像](https://1ms.run/)直接下载镜像. 更多可查看列表[GitHub - dongyubin/DockerHub](https://github.com/dongyubin/DockerHub)

在 /etc/docker/daemon.json 中写入如下内容（如果文件不存在请新建该文件）
```json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

然后重启服务
``` bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

- [镜像加速器](https://yeasy.gitbook.io/docker_practice/install/mirror)

------------------------------------------

如果需要拉取的进行镜像在国内的加速器中没有, 则还可以考虑对docker配置代理, 使用代理服务器加速. 具体的配置可以参考[Docker代理配置](https://lizec.top/2017/08/10/Ubuntu%E4%BD%BF%E7%94%A8%E8%AE%B0%E5%BD%95/#Docker)


### Docker替代品

除了Linux平台下使用包管理器可以较为简单地安装Docker服务, 对于Windows和Mac平台, 都需要借助于虚拟机才能启动. 而Docker官方早就是一脸死相, 无法正常访问官网. 因此可以考虑使用替代产品.

可使用[Podman Installation | Podman](https://podman.io/docs/installation)替换Docker. 对于本文提到的绝大部分docker指令, 直接替换为podman即可.

> 在安装了Desktop的情况下, 许多指令也可以通过GUI页面点击完成, 操作更简单.

Docker操作镜像
-----------------

Docker的镜像操作都是以`docker image`开始的指令, 常见指令如下表所示

操作         | 指令                 | 操作        | 指令
-------------|---------------------|-------------|----------------------
显示本地镜像  | `ls`                | 删除本地镜像   | `rm <imageName>`
拉取远程镜像  | `pull <imageName>`  | 清理无效的镜像 | `prune`

例如, 想要拉取官方的测试镜像, 可以执行

``` bash
docker image pull library/hello-world
```

由于官方的镜像都位于`library/`下, 因此`library/`是默认路径, 也可以省略不写. 此外, 每个镜像还可以具有不同的标签, 例如`UBUNTU:18.04`表示具有`18.04`标签的的`UBUNTU`镜像. 如果不指定标签, 则默认下载`LATEST`标签


### 查询镜像列表

可使用第三方网站[毫秒镜像](https://1ms.run/)或者[轩辕镜像](https://xuanyuan.cloud/)查询镜像和版本. 官方提供的[Docker Hub](https://hub.docker.com/search?q=&type=image&image_filter=official)主动屏蔽IP, 导致即使使用代理也难以访问.



Docker操作容器
-----------------

镜像文件相当于存储在磁盘上的程序, 仅表示其中打包的程序的一个状态, 相当于程序的一个快照。而在运行镜像文件后, Docker还会生成对应的容器文件, 容器文件中保存了程序执行过程中的数据。关闭容器后, 其中的程序停止运行, 但容器文件本身并不会被删除. 容器操作的指令都是以`docker container`开头的指令, 常见的指令如下表所示


操作         | 指令                 | 操作        | 指令
-------------|---------------------|-------------|----------------------
查看运行中容器| `ls`                 | 查看所有容器 | `ls --all`
启动镜像      | `run <imageName>`   | 启动容器     | `start <containerId>`
删除容器      | `rm <containerID>`  | 停止容器     | `stop <containerId>`


因为start指令需要指定容器ID, 因此这个指令实际上可以理解为再次启动已经关闭的容器. 默认情况下容器将会在后台启动并执行, 只有手动设置为交互使用时, 才会将当前终端链接到镜像.

-----------

执行`ls`指令后, 会输入类似如下格式的内容
```
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS
f1cdbb6d6fce        onlyoffice/documentserver   "/bin/sh -c /app/ds/…"   5 weeks ago         Up 5 weeks
673ef1834e3d        nextcloud                   "/entrypoint.sh apac…"   2 months ago        Up 2 months
```

### 运行镜像

启动镜像时, 可以指定如下的一些参数来控制容器的行为, 具体如下表所示:


参数  | 效果                   | 参数       | 效果
------|------------------------|----------|------------------
`-i`  | 交互使用                | `-t`     | 连接镜像的终端
`--rm`| 容器关闭后删除容器文件   | `--name` | 指定容器的名称

例如, 以下指令表示启动ubuntu 18.04的镜像文件, 以交互模式连接该系统的终端, 并且在容器关闭后删除容器文件.

```
docker container run -it --rm ubuntu:18.04 bash
```

通常情况下, 是不会删除容器文件的, 但出于测试的目的, 可以在使用完毕后删除容器文件, 从而节省硬盘空间.

> 但实际上只有修改的文件才会产生空间消耗, 所以容器本身并没有那么消耗空间

### 进入容器

在镜像运行以后, 还可以通过命令行进入容器内, 从而查看或者执行需要的指令. 可以使用如下的指令进入容器并启动一个shell

```
sudo docker exec -it <containerID> /bin/bash  
```

例如可以进入一个mysql容器中, 并查看IP地址信息, 从而从外部连接到数据库.

- [进入docker容器的四种方法](https://blog.csdn.net/skh2015java/article/details/80229930)

### 查看日志

当容器运行情况不符合预期时, 可能需要查看容器内输出的日志, 此时可以执行如下指令持续的输出容器内的日志

```
docker logs -f {{container_name}}
```

> 使用`tldr docker-logs`可以查看更多常见用法


### 重命名容器

可以使用docker rename指令对容器重命名, 使其具有一个可读性更好的名称

```
docker rename <ContainerId> <newName>
```

> 不能使用容器名替代容器ID, 容器名仅作为提高可读性的手段


Docker维护
--------------------

### 映射

通常情况下, 可以直接运行相关的镜像, 如果容器需要存储空间, 会自动映射数据卷. 但也可以通过手动指定的方式, 明确数据卷的存储位置.


```
$ docker run -d -v nextcloud:/var/www/html -p 8080:80 nextcloud
```

以上述指令为例, 通过`-v`参数将宿主机的相对路径目录`nextcloud`映射到了容器中的`/var/www/html`. 当宿主机使用相对路径时, 其相对的根目录是数据卷的根目录`/var/lib/docker/volumes/`.

通过`-p`参数, 将宿主机的8080端口与容器的80端口关联, 从而访问宿主机8080端口就等价于访问容器的80端口.

- [关于Docker目录挂载的总结](https://www.cnblogs.com/ivictor/p/4834864.html)


### 查看空间占用情况

Docker的容器在运行过程中可能需要存储数据, 进而在磁盘上创建数据卷, 可以使用`docker system df -v`查看docker所有相关组件的空间占用情况

```
root@iZ:~# docker system df -v
Images space usage:

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE                SHARED SIZE         UNIQUE SIZE         CONTAINERS
nextcloud           latest              137bb882dbc1        12 months ago       676.3MB             0B                  676.3MB             0

Containers space usage:

CONTAINER ID        IMAGE               COMMAND             LOCAL VOLUMES       SIZE                CREATED             STATUS              NAMES

Local Volumes space usage:

VOLUME NAME                                                        LINKS               SIZE
1faa7f03e67410a04aa6fb5038d89f8349210e0c3a27cf30d65043843426ea5e   0                   202.6MB
3124a81cd8cfae41156f80fb6d4ff49df17d4af1d10705b9aae609e0851cd5c5   0                   1.201GB

Build cache usage: 0B

CACHE ID            CACHE TYPE          SIZE                CREATED             LAST USED           USAGE               SHARED
```


其中`VOLUME`为容器的数据卷, 其生命周期独立于容器, 如果需要清理无用的数据卷, 可以执行`docker volume prune`

### 查看资源使用情况

Docker的容器运行过程中需要消耗CPU和内存, 可以使用`docker stats`查看所有正在运行的容器当前消耗的资源数量。



### 限制资源使用量

默认情况下容器使用的CPU和内存是不受限制的, 为了避免容器消耗了太多资源导致其他服务不可用, 可以对CPU和内存使用量进行限制。 使用以下参数对CPU使用进行限制


参数           | 含义
--------------|----------------------------------
--cpus        | 指定CPU的使用量, 可以包含小数
--cpuset-cpus | 指定具体使用那个CPU
--cpu-shares  | 指定获得CPU的权重

`--cpus=2`可以理解为使用2个CPU `--cpus=0.9`则可以理解为使用0.9个CPU。具体执行的时候,  并不一定是真的使用2个或者0.9个CPU, 而是保证在使用时间上等价于使用2个或者0.9个CPU。

`--cpuset-cpus="1,3"`表示容器只在1号和3号CPU行运行。 `--cpu-shares=512`表示获取CPU时间的权重为512（默认值为1024）

---------------

使用以下参数对内存进行限制

参数           | 含义
--------------|--------------------------------------------------
-m            | 指定最大内存使用量
--memory-swap | 指定包括swap在内的可用内存总量,  -1表示无限制使用swap

`-m 300M --memory-swap -1`表示最大可用内存为300M, 但是可以无限制使用swap空间, `-m 300M --memory-swap 500M`表示最大可用内存为300M, 还可以额外使用200M的swap空间。

### 参考文献

以下的几篇文章讨论了限制容器的资源使用情况的指令.

- [Docker: 限制容器可用的 CPU](https://www.cnblogs.com/sparkdev/p/8052522.html)
- [Docker: 限制容器可用的内存](https://cnblogs.com/sparkdev/p/8032330.html)



Docker原理简介
---------------

Docker虽然有时候被叫做轻量级虚拟机, 但Docker的技术通常视为一种容器化技术. Docker主要利用Linux内核提供的如下几种能力实现


### Namespaces

操作系统对硬件进行了抽象, 提供了内存, 文件系统, CPU等资源. Linux内核的Namespaces技术可以对这些资源进行隔离, 让其中的程序觉得自己独占所有资源. 具体来说, Docker涉及了如下的几种隔离

- PID 命名空间：进程隔离，每个容器有独立的进程树
- Network 命名空间：网络隔离，每个容器有自己的网络接口、IP、路由表
- Mount 命名空间：文件系统挂载点隔离
- UTS 命名空间：主机名和域名隔离
- IPC 命名空间：进程间通信隔离
- User 命名空间：用户和用户组隔离（可选，用于增强安全性）

在进行如上的隔离后, 在Docker容器内就会感觉只有自己的进程, 而无法感知到其他容器或者宿主机的进程. 但由于这仅仅是操作系统内核制造的假象, 因此相较于虚拟机的方式性能更高.

### Control Groups

使用控制组能力可以限制容器使用的CPU, 内存, 磁盘IO等资源, 从而限制容器的资源使用量, 防止单个容器耗尽系统资源.





docker-compose安装
----------------------

当前docker-compose项目已经在Github上开源, 可在对应的[release页面](https://github.com/docker/compose/releases)中找到需要的二进制文件, 以Linux系统下X86指令集为例, 可下载

```bash
wget https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64
```

由于docker-compose项目使用GO语言实现, 因此选择正确的版本后, 直接赋予可执行权限即可运行, 无需其他任何依赖项目. 如果需要在任意位置执行, 可将文件复制到$PATH变量包含的路径中.

> 这大概就是GO语言静态编译的余裕吧



docker-compose.yml文件详解
-----------------------------

在启动Docker镜像时, 如果镜像的配置比较复杂, 则命令行中需要附带大量的参数才可以启动. docker-compose.yml文件可将相关的配置固化到文件之中, 从而可以一键启动镜像. 此外, 基于yml文件还可以配置多个镜像的依赖关系, 使得我们能够便捷的将一组镜像按照一定规则启动, 组合成我们需要的应用.

一个基本的docker-compose.yml文件通常具有如下的一些属性

```yml
version: '3.0'
services:
  todo:
    container_name: smart-todo
    image: ghcr.io/lizec123/smart-todo:latest
    restart: always
    environment:
      TZ: Asia/Shanghai
    ports: 
      - "8080:80"
    volumes:
      - ./config:/app/config
```

> 文件中的各个配置与命令行中的数据基本一一对应, 此处不再赘述


- [Compose 模板文件](https://yeasy.gitbook.io/docker_practice/compose/compose_file)





参考文献
----------------

第一篇文章对Docker进行了简要的介绍, 第二篇文章是一个系列教程, 对Docker进行了比较深入的介绍.

- [Docker 入门教程](https://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html)
- [Docker —— 从入门到实践](https://yeasy.gitbook.io/docker_practice/)
