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


### 配置国内加速器

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


### 官方镜像

[Docker Hub](https://hub.docker.com/search?q=&type=image&image_filter=official)是官方的镜像查询网站. 在此网站上可以查询最近的镜像, 以及镜像的使用说明. 



Docker操作容器
-----------------

镜像文件相当于存储在磁盘上的程序, 仅表示其中打包的程序的一个状态, 相当于程序的一个快照。而在运行镜像文件后, Docker还会生成对应的容器文件, 容器文件中保存了程序执行过程中的数据。关闭容器后, 其中的程序停止运行, 但容器文件本身并不会被删除. 容器操作的指令都是以`docker container`开头的指令, 常见的指令如下表所示


操作         | 指令                 | 操作        | 指令
-------------|---------------------|-------------|----------------------
查看运行中容器| `ls`                 | 查看所有容器 | `ls --all`
启动镜像      | `run <imageName>`   | 启动容器     | `start <containerId>`
删除容器      | `rm <containerID>`  | 停止容器     | `stop <containerId>`

> 因为start指令需要指定容器ID, 因此这个指令实际上可以理解为再次启动已经关闭的容器

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

当容器运行情况不符合预期时, 可能需要查看容器内输出的日志, 此时可以执行u如下指令持续的输出容器内的日志

```
docker logs -f {{container_name}}
```

> 使用`tldr docker-logs`可以查看更多常见用法

### 保存容器

可以使用docker commit指令将容器保存为镜像. 

```bash
sudo docker commit -a "runoob.com" -m "my apache" a404c6c174a2  mymysql:v1 
```

使用`-a`指定镜像的作者信息, `-m`指定镜像附加的message信息. 

> 通过保存容器的方式可以交互式的构建复杂的镜像, 实现搭建开发环境, 临时保存工作区等功能

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

参考文献
----------------

第一篇文章对Docker进行了简要的介绍, 第二篇文章是一个系列教程, 对Docker进行了比较深入的介绍.

- [Docker 入门教程](https://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html)
- [Docker —— 从入门到实践](https://yeasy.gitbook.io/docker_practice/)

------------------

以下的几篇文章讨论了限制容器的资源使用情况的指令.

- [Docker: 限制容器可用的 CPU](https://www.cnblogs.com/sparkdev/p/8052522.html)
- [Docker: 限制容器可用的内存](https://cnblogs.com/sparkdev/p/8032330.html)