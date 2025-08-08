---
title: Ubuntu使用记录
date: 2017-08-10 21:36:11
tags:
    - Ubuntu
    - 数据库
cover_picture:  images/ubuntu.jpg
---


本文包含我在日常使用Ubuntu系统中遇到的一些问题的记录, 没有什么特定的顺序和联系, 不定期更新.



- [安装node](#安装node)
- [安装OneDrive客户端](#安装onedrive客户端)
- [磁盘操作](#磁盘操作)
  - [Ubuntu挂载U盘](#ubuntu挂载u盘)
  - [ubuntu开机自动挂载新硬盘](#ubuntu开机自动挂载新硬盘)
- [清理系统硬盘空间](#清理系统硬盘空间)
  - [排查思路](#排查思路)
  - [清理系统日志](#清理系统日志)
  - [清理apt缓存](#清理apt缓存)
- [APT更换国内镜像源](#apt更换国内镜像源)
- [查看文件夹空间占用情况](#查看文件夹空间占用情况)
- [开机执行程序](#开机执行程序)
- [设置定时任务](#设置定时任务)
  - [Crontab语法解析](#crontab语法解析)
  - [不执行原因排查](#不执行原因排查)
- [添加搜索路径](#添加搜索路径)
- [MySQL中文乱码](#mysql中文乱码)
- [查看已安装软件位置](#查看已安装软件位置)
- [清除/dev/loop设备](#清除devloop设备)
- [Ubuntu server扩展lvm空间](#ubuntu-server扩展lvm空间)
- [Linux系统目录结构](#linux系统目录结构)
- [Ubuntu管理多版本软件](#ubuntu管理多版本软件)
- [curl指令](#curl指令)
- [配置Samba服务](#配置samba服务)
- [配置代理服务](#配置代理服务)
  - [Ubuntu全局代理](#ubuntu全局代理)
  - [APT](#apt)
  - [Git](#git)
  - [Docker](#docker)
  - [pip](#pip)
- [Openwrt路由器配置Hosts](#openwrt路由器配置hosts)
- [编译线程有关程序](#编译线程有关程序)
- [编译32位程序](#编译32位程序)
- [安装fish](#安装fish)
  - [使fish支持conda](#使fish支持conda)
  - [添加环境变量](#添加环境变量)
- [服务器版开启X11支持](#服务器版开启x11支持)
- [设置时区](#设置时区)
- [视频转码](#视频转码)
  - [安装ffmpeg](#安装ffmpeg)
  - [视频转码](#视频转码-1)
  - [进阶选项](#进阶选项)
  - [任务时间估计](#任务时间估计)
- [服务器部署项目推荐](#服务器部署项目推荐)
- [ubuntu桌面版优化](#ubuntu桌面版优化)
  - [注意事项](#注意事项)
  - [安装搜狗输入法](#安装搜狗输入法)
  - [ubuntu隐藏顶部标题栏](#ubuntu隐藏顶部标题栏)
  - [ubuntu隐藏wine状态栏](#ubuntu隐藏wine状态栏)
  - [ubuntu安装基于wine的软件](#ubuntu安装基于wine的软件)
  - [将CapsLK替换为Esc](#将capslk替换为esc)
  - [使用Mac键位](#使用mac键位)
  - [从文件安装软件](#从文件安装软件)
  - [查询头文件对应的依赖](#查询头文件对应的依赖)
  - [配置X11转发](#配置x11转发)
  - [EPUB阅读器](#epub阅读器)
  - [双系统设置默认启动项](#双系统设置默认启动项)
  - [创建桌面快捷方式](#创建桌面快捷方式)



安装node
----------------

使用snap工具可以直接安装最新的长期支持版node, 指令为

```
sudo snap install node --classic
```

- [Node | Snap Store](https://snapcraft.io/node)

> snap是Ubuntu公司提出的一种包管理系统, 可以安装大部分的开源软件和部分的非开源软件, 无法使用apt安装的软件都可以考虑使用snap安装

---

> 2024年9月更新: 如果在国内无法使用包管理器下载也无法下载预编译文件, 可考虑使用清华大学提供的[镜像加速](https://mirrors.tuna.tsinghua.edu.cn/help/nodejs-release/)


安装OneDrive客户端
---------------------

对于Ubuntu系统，可以安装OneDrive客户端实现Ubuntu与Windows的文件同步。 安装过程执行如下的代码

```bash
# 安装OneDrive客户端需要的依赖
sudo apt install libcurl4-openssl-dev
sudo apt install libsqlite3-dev
sudo snap install --classic dmd

# 编译OneDrive客户端
cd ~/Application
git clone https://github.com/skilion/onedrive.git
cd onedrive
make
sudo make install
```

安装完成后执行`onedrive`开启程序进行第一次配置，此时会输出一个onedrive的登陆URL，通过该URL登陆即可对客户端授权登陆。

之后会自动开始同步操作，第一次同步操作结束后会自动退出。 **一定要等待程序同步完所有文件后再开始后续的配置**。

-----------------------------

使用如下的指令配置开机自启动

```
systemctl --user enable onedrive
systemctl --user start onedrive
```

之后可以使用如下的指令查看运行日志

```
journalctl --user-unit onedrive -f
```


磁盘操作
--------------

### Ubuntu挂载U盘

1. 使用  `sudo fdisk -l` 命令查看U盘的位置
``` 
# 结果可能包含如下字段
$ sudo fdisk -l
Disk /dev/sda: 16.1 GB, 16106127360 bytes
2 heads, 63 sectors/track, 249660 cylinders, total 31457280 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x003996fb

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *          64    31457279    15728608    c  W95 FAT32 (LBA)

# 看到U盘的位置是/dev/sda1是一个FAT32格式
```
2. 挂载U盘到指定节点 
```
# 挂载FAT32格式的U盘
$ sudo mount  -t vfat /dev/sda1 /media/u 
# 挂载NTFS格式的U盘 
$ sudo mount -t ntfs-3g /dev/sda1 /media/u 
# 其中/media/u 为你要挂载到的节点, 这个可以随便指定, 但是这个目录一定要存在
```
3. 卸载u盘 
```
# 卸载之前挂载的U盘
$ sudo umount /media/u
```


### ubuntu开机自动挂载新硬盘


**操作需要Root权限**

1. 查看分区的UUID

```
sudo blkid
```

2. 配置开机加载

打开`/etc/fstab`, 按照如下格式写入配置


```
UUID=66E85884E8585501   /home/lizec/share/C ntfs defaults 0 1
UUID=58682F90682F6BC6   /home/lizec/share/D ntfs defaults 0 1
UUID=5C683BEF683BC714   /home/lizec/share/E ntfs defaults 0 1
```

以上配置前三项分别是`分区ID`, `挂载点`, `分区格式`. 其余的配置可以使用默认值.

3. 验证配置

执行以下指令检查配置是否正确, 不正确的配置将导致系统无法正常启动

```
sudo mount -a
```

确认无误后重启系统即可使配置生效

> 注意: 如果以后挂载信息发生变动, 一定要删除相关的配置, 否则将因为挂载失败导致系统无法启动

- [ubuntu开机自动挂载新硬盘](https://blog.csdn.net/iAm333/article/details/17224115)


清理系统硬盘空间
-------------------------

Linux服务器在长期使用后, 会逐渐产生一些缓存文件和日志文件, 这些文件如果未进行清理, 将逐步消耗磁盘空间, 导致服务器可用空间减少.


### 排查思路

在根目录执行

```sh
du -h --max-depth 1
```

可以查看每个目录下实际消耗的空间, 可以找到占用空间较大的目录, 进入该目录后重复执行上述指令, 定位最终消耗空间较大的目录


### 清理系统日志

在Ubuntu系统的`/var/log/journal`存储了二进制格式的内核日志, 系统服务日志和应用程序日志等内容, 并且这些日志在默认情况下并不会自动删除, 长期使用的服务器可能在这里积累数GB的日志文件.

通常不建议直接删除这些日志, 可执行如下指令, 保留最新的2个日志文件

```sh
sudo journalctl --vacuum-files=2
```


### 清理apt缓存

使用apt安装软件后, 相应的安装包会缓存在`/var/cache/apt/archives/`, 可以使用以下的指令查看这部分缓存占用的空间.

```
sudo du -sh /var/cache/apt/archives/
```

如果已经占用较大的空间, 可以使用以下指令自动清理缓存:

```
sudo apt clean
```

APT更换国内镜像源
-------------------------

```
cp -a /etc/apt/sources.list /etc/apt/sources.list.bak 
wget -O /etc/apt/sources.list http://mirrors.cloud.tencent.com/repo/ubuntu20_sources.list
apt-get clean all && apt-get update
```

- [Linux-Ubuntu20更换apt源](https://blog.csdn.net/timonium/article/details/115540622)
- [中科大 Ubuntu 源使用帮助](https://mirrors.ustc.edu.cn/help/ubuntu.html)


查看文件夹空间占用情况
-------------------------

直接使用以下指令查看文件夹内空间占用情况的概述

```
du -ah --max-depth=1
```

查看当前目录总共占的容量, 而不单独列出各子项占用的容量 

```
du -sh 
```

查看当前目录下一级子文件和子目录占用的磁盘容量

```
du -lh --max-depth=1
```


开机执行程序
-------------------------
- 在18.04中,可以在Tweak中直接设置开启启动程序
- 在20.04中, 搜索startup可以在设置中添加启动指令
- 非桌面版系统可以使用crontab设置开启执行的脚本


设置定时任务
----------------

使用`crontab -e`打开文件, 并输入要执行的指令. 例如

```
0 3 * * * /root/Application/TimeMachine.sh daily
```

> 注意: 全部位置都要使用绝对路径,并且手动执行一次脚本, 确认权限和路径没有问题

### Crontab语法解析

在Crontab的文件中, 每一行表示一个要执行的指令, 每一行都具有如下的格式

```
* * * * * /path/to/script.sh
```

前面的5个`*`的位置分别表示分钟, 小时, 天, 月, 和星期. 如果是数字就是具体的时刻, 如果是`*`则表示所有, 例如

```
0 3 * * *  ==> 每天3点0分执行一次
* 3 * * *  ==> 每天3点0分到3点59分的时间段内, 每分钟执行一次
```

--------------


此外, Crontab还支持一些特殊的语法, 例如下面的指令表示每次系统重启后先休眠300秒, 然后写入当前的时间到指定文件之中.

```
@reboot sleep 300 && date >> ~/date.txt
```

> 注意: 确保脚本能正常结束, 否则应该加入`&`符号使脚本在后台执行

更多配置方式,  可以参考下面的文章

- [Crontab in Linux with 20 Useful Examples to Schedule Jobs](https://tecadmin.net/crontab-in-linux-with-20-examples-of-cron-schedule/)
- [Crontab Reboot: How to Execute a Job Automatically at Boot](https://phoenixnap.com/kb/crontab-reboot)

### 不执行原因排查

首先在根目录手动执行一次脚本, 确定脚本的权限和路径设置都是正确的. 如果脚本可以手动执行, 但配置就是不生效, 可以将脚本的输出重定向到日志文件, 例如

```
* * * * * /root/Application/TimeMachine.sh daily >> /root/TM.log 2>&1
```

之后可以在日志中查看是否有报错. 


添加搜索路径
-------------------------
通常系统会在用户的home目录下添加一个搜索路径, 以便于用户可以调用自己编写的程序, 如果没有, 可以按照如下方式添加
1. 修改`.bashrc`
	- 此文件位于用户的home目录下, 可以使用顺手的编辑器打开

2. 添加指令
	- 例如将home目录下的bin目录添加到搜索路径中, 则添加如下语句
```
export PATH=~/bin:"$PATH"
```

3. 重启终端使配置生效



MySQL中文乱码
-------------------------

注意到在Ubuntu上的MySQL并非默认使用UTF8编码, 因此需要手动将默认编码修改为UTF8, 过程如下

修改/etc/mysql/my.cnf, 添加如下的内容：

```
[client]
default-character-set=utf8
[mysqld]
character-set-server=utf8
```

然后重启数据库. 

**注意**： 以前添加的表还是会乱码, 因此需要重新创建有关的表



查看已安装软件位置
-------------------------

``` 
dpkg -L <软件名>
```

清除/dev/loop设备
--------------------

这些设备来自snap系统, 可以使用如下的指令清理未使用的设备

```
sudo apt-get purge snapd
```


- [这些多出来的/dev/loop是什么东西，全部占用100%](https://forum.ubuntu.org.cn/viewtopic.php?t=487421)


lost+found目录
-----------------

`lost+found` 是 **Linux/Unix 文件系统中的特殊目录**，由系统在创建文件系统时自动生成（如使用 `mkfs` 命令）。它的核心作用是充当文件系统的 **“失物招领处”** ——当文件系统因意外崩溃、断电或不洁卸载导致损坏时，修复工具 `fsck` 会扫描磁盘。若发现**未被任何文件引用的孤立数据块**，便会将这些零散数据恢复为文件并存入 `lost+found`。目录通常位于文件系统根目录下（如 `/lost+found` 或 `/mnt/disk/lost+found`），**权限严格限制**（仅 `root` 可访问）。  

**关键特性：**  
1. **健康状态为空**：目录内容为空是正常的，表明文件系统近期无需修复。  
2. **内容不可直接识别**：内部文件以数字编号命名（如 `#12345`），需通过 `file`、`strings` 等命令分析内容，可能是碎片、完整文件或垃圾数据。  
3. **绝对不可删除**：即使为空，它也是文件系统的**关键基础设施**。删除会导致 `fsck` 无法在修复时恢复数据，削弱系统自我修复能力。  
4. **存在即合理**：若目录中出现文件，说明对应分区经历过修复，需管理员谨慎检查内容；若为空，则无需任何操作，忽略即可。  

**总结**：`lost+found` 是文件系统为应对意外损坏而预留的**安全恢复机制**，其存在本身即是保护措施。用户应避免操作此目录，将其视为系统的重要底层设施而非普通文件夹。



Ubuntu server扩展lvm空间
-------------------------


- [Linux /dev/mapper/ubuntu--vg-ubuntu--lv 磁盘空间不足的问题_阿甘的博客](https://www.cxymm.net/article/qq_39718408/118699328)



Linux系统目录结构
--------------
- [Linux各目录及每个目录的详细介绍](https://www.cnblogs.com/duanji/p/yueding2.html)
- [Linux 系统的/usr目录](https://www.cnblogs.com/ftl1012/p/9278578.html)


Ubuntu管理多版本软件
-----------------------

Ubuntu可以直接使用apt安装多个版本的Java, 多个版本的Java并不会直接产生冲突. 

使用如下的指令, 可以切换`java`指令的版本
``` bash
sudo update-alternatives --config java
```

输入上述指令后, 会显示类似如下的内容

```
There are 3 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
* 0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      auto mode
  1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1101      manual mode
  2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode
  3            /usr/lib/jvm/java-8-oracle/jre/bin/java          1081      manual mode
```

输入相应的编号就可以切换java的默认版本. 同理还可以切换`javac`, `javadoc`等命令的版本.

> 除了Java和Python等软件外，还可以自己添加管理项目， 可参考[update-alternatives使用详解](https://www.jianshu.com/p/4d27fa2dce86)

curl指令
--------------

curl指令是Linux中经常使用的一个文件传输指令, 可以用来简单的模拟GET, POST等请求. 对于大部分Linux系统, 都内置了此指令. 在Windows系统中, 如果安装了git bash, 则git bash也内置了此指令.

curl指令具有如下的一些用法

用法示例                                         | 作用
------------------------------------------------|----------------------------------------
curl www.baidu.com                              | 直接发送请求并输出结果
curl -i www.baidu.com                           | 直接发送请求并且只返回头部的内容
curl URL -H "Content-Type:application/json"     | 设置请求头后发送请求
curl URL -d "param1=value1&param2=value2"       | 发送POST请求
curl URL -F "file=XXX" -F "name=YYY"            | 上传文件


注意: 如果URL或者参数中包含特殊字符, 则需要使用引号将内容包裹起来,否则shell会错误的解析指令的内容.

Chrome的postman插件也可以完成curl的功能, 如果能够安装此插件, 则可以完全图形化地完成上述的操作.


配置Samba服务
----------------

执行如下指令安装服务并设置共享路径和用户名密码

```bash
sudo apt-get install samba samba-common
sudo mkdir /home/lizec/share
sudo chmod 777 /home/lizec/share
sudo smbpasswd -a lizec
```

配置`/etc/samba/smb.conf`文件, 添加如下内容

```
[share]
comment = share folder
browseable = yes
path = /home/lizec/share
create mask = 0700
directory mask = 0700
valid users = lizec
force user = lizec
force group = lizec
public = yes
available = yes
writable = yes
```

> 如果使用VIM, 注意复制的时候开头的字母是否完整的复制. 此服务不检查配置文件语法结构是否正确

最后重启服务, 启用配置

```
sudo service smbd restart
```

- [Ubuntu 18.04安装Samba服务器及配置](https://www.linuxidc.com/Linux/2018-11/155466.htm)

> 如果客户端连接遇到问题, 可以参考如下的解决方案

- [win10不能访问samba共享问题的解决](https://blog.csdn.net/maxzero/article/details/81410620)
- [win10系统访问samba服务器时提示：用户名和密码错误](https://blog.csdn.net/Panda_YinLP/article/details/104687438)


配置代理服务
----------------

对于部分常用软件, 可以通过配置代理的方式加速

### Ubuntu全局代理

在桌面版的Ubuntu系统中, 可以在网络选项下找到代理配置, 可以设置为手动配置. 

此处的配置对于大部分软件而言都是全局生效的, 但对于apt等命令行工具无效. 

> Firefox对于Socks5的支持不太好, 有时候代理软件没问题, 但是Firefox就是用不了


### APT

APT可配置临时使用一次代理,  指令为

```
sudo apt-get -o Acquire::http::proxy="socks5h://127.0.0.1:1080/" update
```

- [临时使用socks代理apt-get的方法](https://www.jianshu.com/p/bc4d7b758503)

### Git

```
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
```

上述设置仅对使用HTTP方式访问的项目有效, 对于以SSH方式访问的项目, 可以对SSH添加代理配置, 编辑`~/.ssh/config`文件, 输入以下内容

对于Linux, 使用如下的配置
```
Host github.com
  User git
  Port 22
  Hostname github.com
  ProxyCommand nc -v -x 127.0.0.1:1080 %h %p
  IdentityFile "~/.ssh/id_rsa"
  TCPKeepAlive yes

Host ssh.github.com
  User git
  Port 443
  Hostname ssh.github.com
  ProxyCommand nc -v -x 127.0.0.1:1080 %h %p
  IdentityFile "~/.ssh/id_rsa"
  TCPKeepAlive yes
```

对于windows, 使用如下的配置

```
Host github.com
  User git
  Port 22
  Hostname github.com
  ProxyCommand connect -S 127.0.0.1:1080 -a none %h %p
  IdentityFile "~/.ssh/id_rsa"
  TCPKeepAlive yes

Host ssh.github.com
  User git
  Port 443
  Hostname ssh.github.com
  ProxyCommand connect -S 127.0.0.1:1080 -a none %h %p
  IdentityFile "~/.ssh/id_rsa"
  TCPKeepAlive yes
```

之后可以使用`ssh -T git@github.com`测试连接是否生效.

- [设置代理解决github被墙](https://zhuanlan.zhihu.com/p/481574024)


### Docker


Docker的代理分为两类, 一类是docker指令在拉取镜像过程中使用的代理, 配置可以参考[Configure the Docker client](https://docs.docker.com/network/proxy/#configure-the-docker-client). 

首先创建配置文件

```
mkdir ~/.docker
vim ~/.docker/config.json
```

输入如下的配置
```
{
 "proxies":
 {
   "default":
   {
     "httpProxy": "socks5://127.0.0.1:1080",
     "httpsProxy": "socks5://127.0.0.1:1080",
     "noProxy": ""
   }
 }
}
```

------------------------

一类是容器运行过程中使用的代理, 可以参考[HTTP/HTTPS proxy](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy). 配置文件可以参考如下的内容:

```
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:1080"
Environment="HTTPS_PROXY=socks5://127.0.0.1:1080"
```

> 关于Docker镜像仓库的配置, 可以参考笔记[Docker笔记之使用镜像](https://lizec.top/2020/06/19/Docker%E7%AC%94%E8%AE%B0%E4%B9%8B%E4%BD%BF%E7%94%A8%E9%95%9C%E5%83%8F/#%E9%85%8D%E7%BD%AE%E5%9B%BD%E5%86%85%E5%8A%A0%E9%80%9F%E5%99%A8)

### pip

pip可以临时指定使用的镜像, 例如

```
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
```

- [ubuntu更换安装源和pip镜像源](https://blog.csdn.net/wssywh/article/details/79216437)


Openwrt路由器配置Hosts
-----------------------

- [Openwrt路由自带hosts功能](https://www.5yun.org/21010.html)



编译线程有关程序
-------------------------
如果用到了pthread.h中的函数,在使用gcc编译的时候,需要加上-pthread 


编译32位程序
-----------------------

安装如下的包

```
sudo apt install build-essential module-assistant gcc-multilib g++-multilib  
```

之后可以使用`-m32`指令进行编译, 例如
```
gcc -m32 hello.c
```



安装fish
--------------

安装并切换默认shel

```
sudo apt install fish
chsh -s /usr/bin/fish
```

> 注意不要以root身份执行chsh, 否则该操作仅对root用户生效

- [Linux Ubuntu 安装 Fish Shell 教程以及配置和使用方法](https://cloud.tencent.com/developer/article/1709295)


fish提供自动补全功能, 使用`→`接受整个补全结果, 使用`Alt+→`接受补全结果中的一个单词. 使用`Alt+s`在上一条指令前补充sudo指令. 


- [Fish Tutorial](https://fishshell.com/docs/current/tutorial.html)


### 使fish支持conda

在bash环境中执行

```
conda init fish
```

然后重新开shell即可实现conda环境的切换

### 添加环境变量

常规的对PATH变量的修改对fish无效, 如果需要添加新的路径到PATH变量中, 可以执行

echo "set PATH /home/lizec/.local/bin $PATH" >>  ~/.config/fish/config.fish

服务器版开启X11支持
----------------------

执行如下指令安装需要的模块

```
sudo apt install xorg xauth openbox xserver-xorg-legacy
```

之后可以输入`xclock`测试配置是否正确

- [Linux安装X11实现GUI](https://blog.csdn.net/lly1122334/article/details/122649364)


> **注意:** 安装X11界面后, 同时会开启自动休眠策略, 为了避免服务器自动关机, 同时需要进行如下的设置

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

- [记UbuntuServer自动关机问题的排查和解决](https://www.jianshu.com/p/6653b4ac1d11)


设置时区
--------------

```
sudo timedatectl set-timezone Asia/Shanghai
```

视频转码
-------------

### 安装ffmpeg

开源项目`ffmpeg`提供了非常好用的视频处理功能, 一般情况下仅使用ffmpeg就可以满足所有的视频处理需求. 对于Ubuntu系统, 可以使用如下指令安装

```bash
sudo apt install ffmpeg
```

直接安装, 之后可使用如下指令查看安装是否成功

```bash
ffmpeg -version
```

> 如果感觉版本较旧, 可考虑使用snap安装


### 视频转码

要使用FFmpeg将视频转码为1080p分辨率的H.264编码MP4文件, 可以按照以下步骤操作


```bash
ffmpeg -i input.mp4 -vf "scale=-1:1080" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k output_1080p.mp4
```


- `-i input.mp4`: 指定输入文件为 `input.mp4`。请将其替换为你要转码的视频文件路径。

- `-vf "scale=-1:1080"`: 使用视频滤镜（Video Filter）调整视频分辨率。`scale=-1:1080` 表示将视频的高度设置为1080像素，宽度自动根据原始视频的宽高比进行调整，以避免变形。

- `-c:v libx264`: 指定视频编码器为 `libx264`，这是H.264编码的标准实现。

- `-preset medium`: 设置编码速度与压缩效率的平衡。常用的预设包括 `ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower`, `veryslow`。预设越快，编码速度越快，但压缩效率可能较低；预设越慢，压缩效率越高，但编码时间更长。`medium` 是默认值，适合大多数情况。

- `-crf 23`: 设置恒定质量因子（Constant Rate Factor），范围为0-51，数值越小，输出质量越高，文件大小也越大。常用范围是18-28，其中23是默认值。你可以根据需要调整此值以平衡质量和文件大小。

- `-c:a aac`: 指定音频编码器为 `aac`，这是MP4容器中常用的音频编码格式。

- `-b:a 192k`: 设置音频比特率为192kbps，以保证良好的音频质量。你可以根据需求调整此值。

- `output_1080p.mp4`: 指定输出文件名为 `output_1080p.mp4`。请根据需要更改输出路径和文件名。

### 进阶选项

1. **调整帧率**: 如果需要设置特定的帧率（例如30fps），可以添加 `-r 30` 参数：

```bash
ffmpeg -i input.mp4 -vf "scale=-1:1080,fps=30" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 192k output_1080p.mp4
```

2. **多线程编码**: 利用多核CPU加快编码速度，可以添加 `-threads` 参数，例如使用4个线程：

```bash
ffmpeg -i input.mp4 -vf "scale=-1:1080" -c:v libx264 -preset medium -crf 23 -threads 4 -c:a aac -b:a 192k output_1080p.mp4
```

### 任务时间估计

执行对应的指令后, 在当前命令行会输出一个统计信息, 其中包含 `speed=1.23x`之类的数据, 其含义为相较于视频原始的播放速度, 当前任务执行速度的倍率. 例如原始视频长度为1小时, 当`speed=2x`时, 转码需要的时间则正好为0.5小时.


服务器部署项目推荐
------------------

[服务器指北 - 有了服务器之后可以做点什么 - idealclover    ](https://idealclover.top/archives/557/)

ubuntu桌面版优化
--------------------

### 注意事项

1. 不建议选择过于新的系统, 选择发布至少一年的版本比较稳妥.
2. 直接使用迅雷下载镜像文件, 从网页下载到2GB时会卡住.
3. 安装时语言选择中文, 从而确保安装了对应的输入法, 否则在英文操作系统上安装输入法将消耗大量时间.
4. 不要安装第三方驱动, 尤其是显卡驱动. 否则容易出现版本不匹配导致无法启动图像界面.
5. 不要选最小安装, 全部使用默认值即可, 附带的软件一般最后都会用上, 提前安装好可以节省后续的时间.
6. 尽量使用命令行安装和卸载软件, 至少能看到错误信息. 不到最后, 不要使用图形界面安装.
7. 不要强制卸载任何软件, 否则可能导致依赖关系破坏, 直接影响整个apt系统.

每个长期支持版都可以使用7年, 不必可以追求最新版. 而且由于最新版的系统中基础软件版本较高, 可能导致无法安装第三方软件. 例如fish对于Python最高版本有要求, 过高的Python版本将导致无法安装fish.

从图形界面安装程序虽然比较简单, 但如果出现错误无法查看错误信息, 如果界面卡住也无法得知具体的进度情况. 强制终止容易出现错误, 进而破坏整个安装系统.

### 安装搜狗输入法

> **注意:** 安装系统时语言必须选择中文, 以免产生不必要的麻烦

搜狗输入法目前已经支持到Ubuntu20.04, 按照如下的教程安装即可. 更高版本的系统可能会安装失败.

- [Ubuntu搜狗输入法安装指南](https://pinyin.sogou.com/linux/guide)


### ubuntu隐藏顶部标题栏

```
sudo apt install gnome-shell-extension-autohidetopbar 
```

注销当前用户后, 重新登录并在搜索页面中打开Extension, 选择`Hide Top Bar`即可

- [Hide Top Bar in Ubuntu 20.04](https://www.youtube.com/watch?v=6rTE8N_aUWQ)


### ubuntu隐藏wine状态栏

访问[此链接](https://extensions.gnome.org/extension/1674/topiconsfix/)安装指定的插件, 即可将独立窗口的`Wine System Tray`移动到右上的状态栏之中. 

> 由于该网站通过在网页上点击的方式安装系统插件, 因此需要先给浏览器安装一个通信插件才能正常使用该功能


### ubuntu安装基于wine的软件

访问[zq1997/deepin-wine](https://github.com/zq1997/deepin-wine), 按照教程添加第三方库后即可按照指令安装Windows平台的软件. 

- [可安装软件列表](https://deepin-wine.i-m.dev/)


### 将CapsLK替换为Esc

搜索`tweaks`打开配置页面, 选择`Keyboard & Mouse`选项卡, 点击`Additional Layout Options`, 再弹出的窗口中选择`Caps Lock Behavior`选项, 并选择`Make Caps Lock an additional Esc`

> 其他键位相关的配置也可以在这里修改, 相比与前几年, ubuntu的配置简单了很多了

### 使用Mac键位

对于我的键盘, 在Mac布局下Cmd建的位置, 对应的是Win键, 因此只需要将Ctrl键覆盖Win键即可解决大部分最难受的快捷键. 配置方法与将CapsLK替换为Esc相同

- [linux如何设置mac快捷键,在Ubuntu上使用macOS的快捷键](https://blog.csdn.net/weixin_39608457/article/details/116909438)


### 从文件安装软件

和Windows平台一样，Ubuntu也可以从文件安装软件。Ubuntu平台默认的安装包格式是`deb`格式，对于该格式的文件，可以直接双击打开安装页面。

对于其他Linux平台的安装包（例如`rpm`格式），可以通过`alien`命令转换为`deb`格式， 例如

```
sudo apt install alien
sudo alien --scripts *.rpm
```

之后会生成同名的`deb`包，双击安装即可


- [ubuntu16 安装RPM软件包](https://blog.csdn.net/wojiushiwoba/article/details/62046750)

> 不建议以这种方式安装软件, 容易导致依赖管理出现错误

### 查询头文件对应的依赖

使用源码编译时，可能因为缺少相关的依赖，导致编译出错。此时可以通过如下指令查询头文件对应的依赖包名称

```bash
# 安装工具
sudo apt install apt-file
sudo apt-file update

# 查询头文件 X11/Xlib.h  对应的依赖包
apt-file search X11/Xlib.h 
```

执行上述命令会出现如下的搜索结果

```
ivtools-dev: /usr/include/IV-X11/Xlib.h   
libghc-x11-dev: /usr/lib/haskell-packages/ghc/lib/x86_64-linux-ghc-8.6.5/X11-1.9-Fmq4QbYpsd5OMgvJkPFaT/Graphics/X11/Xlib.hi
libhugs-x11-bundled: /usr/lib/hugs/packages/X11/Graphics/X11/Xlib.hs
libnx-x11-dev: /usr/include/x86_64-linux-gnu/nx-X11/Xlib.h
libx11-dev: /usr/include/X11/Xlib.h
python-pycparser: /usr/share/python-pycparser/fake_libc_include/X11/Xlib.h
python3-pycparser: /usr/share/python3-pycparser/fake_libc_include/X11/Xlib.h
```

经过分析，安装`libx11-dev`即可解决依赖问题

> 注意configure指令可能会根据依赖的情况设置编译变量，因此安装对应依赖后需要重新执行configure指令

### 配置X11转发

使用X11转发功能, 可以使得其他设备查看Ubuntu系统上的窗口, 进而实现可视化的操作. 虽然基于X11转发的性能不太行, 不如专门的远程桌面, 但相较于专门开启图形化界面进行操作, 这种和SSH紧密结合且仅传输一个窗口的模式对于开发还是非常的方便.

> 运行Chrome很卡, 但运行bochs绰绰有余

实现X11转发需要两个条件:

1. 本地存在相应的软件, 能够渲染从服务器传输过来的数据
2. 本地使用的SSH软件支持X11转发

针对第一点, 可以安装[vcxsrv](https://sourceforge.net/projects/vcxsrv/), 针对第二点, 不同的软件有不同的配置方法, 可以参考

- [Xshell启用X11转发](https://www.xshellcn.com/xsh_column/jiaocheng-x11zf.html)
- [Vscode Remote启用X11转发](https://yunusmuhammad007.medium.com/jetson-nano-vs-code-x11-forwarding-over-ssh-d97fd2290973)

其他参考资料:
- [X11 forwarding，Windows与Linux结合的最佳开发环境](https://zhuanlan.zhihu.com/p/66075449)


### EPUB阅读器

如果在阅读的同时还需要对大量电子书进行管理, 则直接安装`Calibre`并可以配合`Calibre-Web`使用.

如果单纯需要阅读EPUB格式的电子书, 则可以安装`FBReader`, 该软件可以通过snap安装, 即

```
snap install fbreader
```


### 双系统设置默认启动项

1. 打开相关的配置文件
```
$ sudo gedit /etc/default/grub
```

1. 修改相关选项
```
# 节选其中的一段内容如下所示
GRUB_DEFAULT=0     # 此项表示默认选择项位置, 从0开始计数
#GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=2     # 此项表示默认选择时间, 单位为秒
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
```

1. 更新
只有更新上述设置以后, 相关的修改才会生效
```
$ sudo update-grub
```



### 创建桌面快捷方式

使用文件编辑器在桌面创建一个以`.desktop`结尾的文件. 然后依据需要设置一下的内容

``` shell
[Desktop Entry]
Encoding=UTF-8
Version=1.0                                     #version of an app.
Name[en_US]=yEd                                 #name of an app.
GenericName=GUI Port Scanner                    #longer name of an app.
Exec=java -jar /opt/yed-3.11.1/yed.jar          #command used to launch an app.
Terminal=false                                  #whether an app requires to be run in a terminal
Icon[en_US]=/opt/yed-3.11.1/icons/yicon32.png   #location of icon file.
Type=Application                                #type
Categories=Application;Network;Security;        #categories in which this app should be listed.
Comment[en_US]=yEd Graph Editor                 #comment which appears as a tooltip.
```

- [如何在Linux的桌面上创建快捷方式或启动器](https://linux.cn/article-2289-1.html)
