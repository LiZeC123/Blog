---
title: Termux使用教程
math: false
date: 2026-06-17 15:43:19
categories:
tags:
    - Termux
cover_picture:
---

Termux是一个非常神奇的项目, 其利用Android系统本身是基于Linux内核这一点, 在手机上创造了一个命令行环境. 得益于各种语言的跨平台性, 许多项目得以简单的在手机上启动. 尤其是基于Web的CS架构, 由于在本地运行, 既可以获得较好的体验效果, 又无需担心敏感数据的存储和访问鉴权问题.

基础准备
-------------

首先执行如下指令更换数据源, 从而方便后续快速更新依赖

```sh
termux-change-repo
```

然后更新现有依赖的状态

```sh
pkg update && pkg upgrade -y
```

执行如下指令获取手机的存储权限

```sh
termux-setup-storage
```

此后可通过`~/storage/`访问手机的内部存储

> 注意: Android的应用本质上都是独立的沙盒, 因此Termux也无法访问别的App的私有空间. 



### 配置远程联机

在手机上输入命令显得非常的呆, 因此可以在手机上启动ssh服务, 使用电脑远程连接后再操作

```sh
pkg install openssh
passwd      # 设置登录密码
sshd        # 启动SSH服务
ifconfig    # 查看手机在局域网的IP地址
```

由于Termux只有主动打开的时候才能生效, 因此可以使用一个简单密码, 并且需要再每次使用前都手动启动sshd.

Termux 是单用户环境，整个系统只有唯一一个内置用户, 因此登录时无需指定用户名, 只需要指定端口为`8022`即可, 例如

```sh
ssh 192.168.1.6 -p 8022
```

之后可以使用scp命令复制文件到手机中, 例如

```sh
scp -P 8022 ./legado-tts-tencent ./config.json @192.168.1.6:~/legado
```


### 编译GO项目

可以使用交叉编译的方式在其他平台编译后复制到手机中执行, 只需要执行

```sh
GOOS=android GOARCH=arm64 go build 
```

即可生成在Android平台执行的文件. 

> 注意: 不使用GCO的情况下, DNS服务非常容易异常, 最好手动指定DNS服务器

Termux的包管理器也提供了go语言的依赖, 也可以尝试在手机上直接编译Go语言的项目.
