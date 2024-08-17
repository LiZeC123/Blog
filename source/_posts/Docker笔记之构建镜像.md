---
title: Docker笔记之构建镜像
date: 2021-08-07 10:50:24
categories: Docker笔记
tags:
    - Docker
cover_picture: images/docker.jpg
---





Dockerfile指令详解
-------------------


Dockerfile的指令不多, 只需要理解几个简单的指令就可以构建一个自定义的镜像. 一个Dockerfile一般具有如下的一些指令, 以下分别介绍这些指令的含义. 

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

自定义的镜像可以在一个基础镜像上进行构建, 从而避免一些重复性的基础工作. 使用`FROM`指令指定基础镜像, 可以在[Docker Hub](https://hub.docker.com/)上查询可用的镜像. 

--------

很多镜像的标签都包含一些代号,  常见代号的含义如下

名称     | 含义
--------|------------------------------------
alpine  | 一种体积非常小的操作系统, 本体只有5M
slim    | 包含指定工具的最小软件包
buster  | buster是Debian系统当前稳定版的代号

如果希望体积尽可能小, 同时不需要其他依赖, 那么可以选择alpine版本. 如果alpine缺少依赖, 则可以考虑slim版本. 虽然buster版本体积比较大, 但如果其他镜像都不行, 那么buster版本最稳妥. 


> Debian系统最近的版本代号分别是 Jessie(8.x) / Stretch(9.x) / Buster(10.x) / Bullseye(11.x) / Bookworm(12.x) / Trixie(13.x)

### 设定工作目录

使用`WORKDIR`指令指定镜像内的工作目录（相当于shell的当前目录）, 后续的操作默认都是在当前工作目录下执行. 例如在上面的Dockerfile中, 将工作目录指定为`/app`, 那么后续的RUN指令和COPY指令也就将`/app`路径作为当前目录. 

> 因为Dockerfile每执行一条指令就会创建一个新的层, 所以直接在SHELL上切换路径对后续指令是无效的

### 复制文件

`COPY`指令将Host中的文件复制到Guest中,  既可以复制单个文件也可以复制整个文件夹. `COPY`指令复制文件夹时将Host中的一个文件夹中的**全部文件**复制到Guest中的指定文件夹中. 因此上面的例子中将Host中的`app`路径下的所有文件复制到Guest的工作目录中（也就是前面指定的`/app`）

> Dokcerfile中有两个指令可以复制文件, 分别是ADD指令和COPY指令. 两个指令没有太大区别, 一般采用COPY指令. 

### 执行指令

使用`RUN`指令可以在Guest中执行任意的Shell指令, 例如进行一些参数设置或者安装需要的依赖程序. 由于每行指令都会产生一个新的层, 因此不要用写Shell的思路写`RUN`指令, 而应该尽可能一次性执行全部指令, 例如

```
RUN apk update && \
    apk add --no-cache tzdata
```


### 程序入口

`ENTRYPOINT`指定镜像启动后需要执行的程序. 例如上面的例子指定程序启动时执行python指令. 

> 注意：镜像中将直接启动指定的程序而不是用shell启动, 因此并不能执行shell的语法

除了使用`ENTRYPOINT`指定启动程序以外, 也可以使用`CMD`指定启动程序. 两者的区别在于`ENTRYPOINT`指令比较明确的表明这个镜像就应该执行`ENTRYPOINT`指定的唯一的程序, 而`CMD`指定的程序则可以在启动镜像的时候直接被命令行上的参数覆盖. 

### 定义数据卷

如果直接在容器内写入数据, 则数据保存在容器内部. 如果容器被删除, 那么对应的数据也就一起被删除了. 使用数据卷可以将数据写入到Host的文件系统中, 从而使容器变为无状态的应用, 可以随意的创建和删除. 使用`VOLUME`定义镜像的数据卷, 在容器启动后, 如果用户没有手动挂载这些数据卷则自动挂在一个匿名数据卷. 

> 用户在启动时当然还是可以用命令直接覆盖这些配置, 挂载一个命名的数据卷

### 声明端口

使用`EXPOSE`可以声明容器想要暴露的端口. 这个指令是一个纯粹的声明, 没有任何效果, 仅仅用于提示用户这个镜像希望暴露的服务端口. 

### 深入原理：层和缓存

使用Docker构建镜像的一个常见的错误操作就是像写Shell脚本一样分多次执行`RUN`指令. Dockerfile中每执行一行指令, 都会构建一个新的层, 每个层之间是没有关系的, 上一层中创建的文件在下一层中无法删除. 因此分多次执行`RUN`指令只会产生大量无意义的中间层而浪费空间, 指令之间产生的临时文件也会残留在镜像中, 使得镜像体积增加. 

Docker分层的一个作用是缓存, 如果一个层没有发生变化, 则可以直接复用. 例如在上面的例子中, 先复制Python项目的依赖配置文件并使用pip安装依赖, 再复制项目的代码. 如果后续只修改了代码文件, 而没有修改依赖, 则再次构建时, 安装依赖的一层就可以直接复用, 从而节省了构建时间. 

- [关于RUN和层的一些讨论](https://yeasy.gitbook.io/docker_practice/image/build#run-zhi-hang-ming-ling)

### 扩展阅读

更多关系Dockerfile的详细信息, 可以参考如下的一些资源

- [Docker从入门到实践--Dockerfile指令详解](https://yeasy.gitbook.io/docker_practice/image/dockerfile)
- [Docker 镜像制作教程：针对不同语言的精简策略](https://xie.infoq.cn/article/9d564171a39e38661bea6092c)



Dockerfile多阶段构建
-------------------

在上一节中以部署Python应用给出了一个Dockerfile的例子, 因为Python是解释执行的, 所以部署相对简单一些. 对于需要编译执行的语言, 其部署就更想对而言更复杂一些. 例如以Java语言为例, 编译Java需要JDK环境, 而运行Java只需要JRE环境. 或者对于更极端的C语言或者Go语言, 编译需要编译环境, 但运行可能不需要任何额外的依赖. 如果直接在编译环境运行程序, 虽然也可以运行, 但镜像体积就太大了. 

对此Dockerfile提供了多阶段构建的能力, 可以分别使用两个镜像来编译和运行程序. 例如如下的Dockerfile分别使用两个镜像来构建Java镜像. 在编译阶段, 使用maven镜像将源码打包为jar, 在运行阶段直接在jre环境运行上一步打包的jar. 

```dockerfile
# First stage: complete build environment
FROM maven:3.5.0-jdk-8-alpine AS builder

# add pom.xml and source code
ADD ./pom.xml pom.xml
ADD ./src src/

# package jar
RUN mvn clean package

# Second stage: minimal runtime environment
From openjdk:8-jre-alpine

# copy jar from the first stage
COPY --from=builder target/my-app-1.0-SNAPSHOT.jar my-app-1.0-SNAPSHOT.jar

EXPOSE 8080

CMD ["java", "-jar", "my-app-1.0-SNAPSHOT.jar"]
```

-[在Dockerfile中使用多阶段构建打包Java应用](https://help.aliyun.com/document_detail/173175.html)




前后端分离部署
-------------


### 配置前后端项目的编译和运行环境

对于前后端分离的项目, 一般有如下的几个要素

1. 前端的编译环境和运行环境. 如果使用Vue.js开发, 那么编译过程需要npm环境, 运行过程则只需要nginx代理编译后的静态文件. 
2. 后端的编译环境和运行环境. 如果使用Java开发, 则后端编译过程需要Maven环境, 运行过程则需要JRE环境. 如果使用Python开发, 则因为解释执行只需要对应的Python环境

无论是那种情况, 都可以使用Dockerfile轻松的引入相应的依赖并执行操作


### 配置文件

由于前端使用nginx代理了静态文件, 所以访问后端的请求需要在配置文件中转发给后端容器. 使用docker-compose时, 可以直接把后端容器名作为域名, 在配置文件中进行转发, 例如

```
    # Smart-Todo
    upstream backend {
        server backend:4231;
    }

    server {
        listen 80;

        # 所有的请求默认转发到前端的index文件, 由Vue进行代理 
        location / {
            root /app;
            try_files $uri $uri/ /index.html;
        }  
        
        # API相关的路径是后端的接口, 转发给后端
        location /api {
            proxy_pass http://backend;
            proxy_set_header User-Agent $http_user_agent;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
```

### 参考资料

- [docker-compose 部署 Vue+SpringBoot 前后端分离项目](https://segmentfault.com/a/1190000021008496)
- [前后端分离应用（单应用/多应用）docker部署](https://segmentfault.com/a/1190000023939043)



Docker镜像构建常见问题
---------------------------


### 设置时区

经过实践, 相比于使程序支持时区的切换, 还是直接使用本地时间并修改容器的时区最简单. 毕竟程序也不是真的需要支持多时区.

无论是哪种镜像, 都可以通过将Host中的时间配置文件映射到容器中实现修改时区. 即加入映射

```
-v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro
```

但对于apline镜像, 必须安装了`tzdata`包后才会生效, 因此还需要在构建镜像的时候执行

```
RUN apk update && \
    apk add --no-cache tzdata
```

对于Ubuntu之类的系统, 更简单的方式是直接指定环境变量`TZ=Asia/Shanghai`实现时区的修改.

- [Docker 时区调整方案](https://cloud.tencent.com/developer/article/1626811)
- [docker: Apline configure timezone](https://quaded.com/docker-apline-configure-timezone/)

### MySQL镜像配置

为了使镜像可以被远程连接, 可以设置如下的环境变量

```
ENV MYSQL_ROOT_PASSWORD="123456" MYSQL_ROOT_HOST=%
```

----------------------

如果希望MySQL镜像在第一次启动时执行指定的初始化脚本, 可以将文件复制到`/docker-entrypoint-initdb.d`, 例如

```
COPY sql/ /docker-entrypoint-initdb.d/
```

可以参考Docker Hub上的[文档](https://hub.docker.com/_/mysql)的 Initializing a fresh instance 章节

