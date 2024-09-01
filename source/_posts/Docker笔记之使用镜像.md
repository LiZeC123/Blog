---
title: Docker笔记之使用镜像
date: 2023-08-08 10:50:24
categories: Docker笔记
tags:
    - Docker
cover_picture: images/docker.jpg
---


在之前的文章中, 已经介绍过Docker的基本使用, 以及如何自定义的构造需要的镜像. 本文将主要介绍一些在平常发现的好用镜像, 介绍这些镜像的基本功能和配置细节.


watchtower相关配置
-------------------

watchtower是一个容器更新监控服务镜像, 部署该镜像后, 该镜像会自动检测在HOST机器中运行的其他镜像是否有最新版, 当存在最新版时自动更新相关的镜像. 使用此镜像可使服务器中相关镜像自动保持最新.



```bash
# 启动自动监控服务

docker run -d --name watchtower --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock  containrrr/watchtower --cleanup --interval 300

# 单独执行一次更新服务

docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock  containrrr/watchtower --cleanup --debug --run-once
```




CCAA相关配置
---------------

CCAA是一个磁力链接下载镜像, 该镜像组合了Aria2和File Browser模块, 从而可以方便的实现文件下载和在线预览的功能.


```yml
version: "3.0"
services:
  backend:
    container_name: CCAA
    restart: always
    image: helloz/ccaa
    ports: 
      - "6080:6080"
      - "6081:6081"
      - "6800:6800"
      - "51413:51413"
    environment: 
      PASS: <password>
    volumes:
      - /home/lizec/share/:/data/ccaaDown
    command: sh -c "dccaa pass && dccaa start"
```

```bash
echo "Goto To http://nas:6080/"
echo "Aria2 Password: xiaoz.me"
echo "File Browser: ccaa:admin"
```


注意事项:
1. 不建议设置`restart: always`, 镜像如果出现BUG导致大量IO读写操作, 设置该属性可能导致重启后无法解决问题.
2. File Browser的初始账号密码为`ccaa:admin`, 可进入设置页面修改密码.




Gogs相关配置
--------------

Gogs是一个Git管理镜像, 相当于一个私有部署的Github. 使用该镜像可以将私有代码同步到远程服务器.


```yml
version: "3.0"
services:
  backend:
    container_name: gogs
    restart: always
    image: gogs/gogs
    ports: 
      - "5080:3000"
      - "5022:22"
    volumes:
      - ./data:/data
```

启动镜像后直接访问对应的路径, 第一次访问自动跳转值安装页面, 进行配置时注意如下细节
- SSH端口填写实际映射的端口(即5022), HTTP监听端口保持3000端口不变
- URL改为真实URL(即git.lizec.top), 注意修改所有的localhost
- 防火墙开放5022端口


Navidrome相关配置
-------------------

Navidrome是一个音乐管理和播放服务, 类似于网页版的网易云音乐. 使用该镜像可以从Web端查看和播放音频.


```yml
version: "3"
services:
  navidrome:
    image: deluan/navidrome:latest
    ports:
      - "4533:4533"
    environment:
      # Optional: put your config options customization here. Examples:
      ND_SCANSCHEDULE: 1h
      ND_LOGLEVEL: info  
      ND_BASEURL: ""
    volumes:
      - "./data:/data"
      - "~/Music:/music:ro"
```

启动镜像后, 第一次访问时需要设置管理员账号. 登录后在系统的用户选项下选择快速扫描可刷新歌曲列表



Redis
---------------

使用如下的配置可启动一个基本的Redis服务并将端口暴露, 可将该镜像用于Redis相关业务逻辑的开发和调试

```yml
services:
  todo:
    container_name: base-redis
    image: redis
    restart: always
    environment:
      TZ: Asia/Shanghai
    ports: 
      - "6379:6379"
```

> 注意: 该镜像默认不可被本地的网络访问, 可参考[Error: Protocol error, got "H" as reply type byte](https://cloud.tencent.com/developer/article/1706012)



Clickhouse
------------

使用如下配置可启动一个基本的Clickhouse服务, 可将该镜像用于Clickhouse相关的验证和测试


```yml
services:
  todo:
    container_name: base-clickhouse
    image: clickhouse/clickhouse-server
    environment:
      TZ: Asia/Shanghai
    ports: 
      - "8123:8123"
    volumes:
      - ./data:/var/lib/clickhouse/
      - ./log:/var/log/clickhouse-server/   
    deploy:
      resources:
        limits:
          nofile: 262144    
```

> 注意: Clickhouse作为一个存储组件, 一定要映射数据卷, 否则在其中产生的数据会随着容器的销毁而丢失. 拉取测试数据本身就会消耗很多时间, 数据丢失产生的损失很大.

官方镜像中包含了客户端程序, 可进入容器进行操作

```sh
sudo docker exec -it base-clickhouse clickhouse-client
```


- [docker镜像官方文档](https://hub.docker.com/r/clickhouse/clickhouse-server)
