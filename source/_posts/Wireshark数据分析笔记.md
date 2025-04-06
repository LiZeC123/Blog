---
title: Wireshark数据分析笔记
date: 2020-10-21 11:49:30
categories:
tags:
    - 计算机网络
cover_picture: images/wireshark.png
---





路由器抓包
--------------


如果路由器是OpenWrt系统, 那么可以使用管道的方式将数据传输给WireShark进行分析. 首先在OpenWrt路由器上安装工具

```
opkg update
opkg install tcpdump
```


然后执行下面的指令将网络数据通过管道传递给Wireshark执行



```
ssh root@openwrt 'tcpdump  -s 0 -U -n -w - -i br-lan' | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
```

注意:  虽然在Windows平台执行上述代码, 但由于Powershell的解析规则不一样, 因此上面的指令可能需要用Git Bash这样的Linux Bash来执行.


- [使用Wireshark完成OpenWrt抓包](https://www.atfeng.com/post/%E4%BD%BF%E7%94%A8wireshark%E5%AE%8C%E6%88%90openwrt%E6%8A%93%E5%8C%85/)




捕获过滤器
--------------

注意: 捕获过滤器在开始捕获之前进行设置, 与得到数据以后的过滤表达式语法并不一致. 捕获过滤器的语法格式为

```
<Protocol> <Direction> <Host(s)> <Value> <LogicalOperation> <OtherExpression>
```

- Protocol是网络协议的名称, 例如tcp, ether等
- Direction是数据包方向, 取值为src和dst

一些常见的捕获过滤器如下所示

```
host 192.168.1.100  
net  192.168.1      
net 192.168.1.0/24  
port 80             
portrange 8000-8080
```

上述指定可以指定方向, 例如`src host 192.168.1.100` 表示源地址为192.168.1.100的数据包, `dst net  192.168.1`表示目标网段为`192.168.1`的数据包.

> WireShark提供了内置的捕获过滤器, 可以从 `菜单`->`捕获`->`捕获过滤器` 选择使用


显示过滤器
--------------


显示过滤器是在获取到数据包之后对数据进行筛选的方式. WireShark的GUI软件提供了直接生成显示过滤器的方法. 在报文的结构窗口的任意字段上右键, 选择`作为过滤器应用`即可以改字段为条件进行过滤.

由于大部分时候的过滤需求都很简单, 因此上面的方法基本可以满足大部分需求, 但显示过滤器也支持更复杂的范围过滤语法, 需要的时候再查询即可.