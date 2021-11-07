---
title: Ubuntu使用记录
date: 2017-08-10 21:36:11
tags:
    - Ubuntu
    - 数据库
cover_picture:  images/ubuntu.jpg
---

## 内容概述
本文包含我在日常使用Ubuntu系统中遇到的一些问题的记录, 没有什么特定的顺序和联系, 不定期更新


Ubuntu下如何挂载U盘
-------------------------
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


ubuntu开机自动挂载新硬盘
---------------------------

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
UUID=FA1CAC411CABF733   /home/lizec/share/E ntfs defaults 0 1
```

以上配置前三项分别是`分区ID`, `挂载点`, `分区格式`. 其余的配置可以使用默认值.

3. 验证配置

执行以下指令检查配置是否正确, 不正确的配置可能导致无法正常启动

```
sudo mount -a
```

确认无误后重启系统即可使配置生效

- [ubuntu开机自动挂载新硬盘](https://blog.csdn.net/iAm333/article/details/17224115)


清理软件安装缓存
-------------------------


使用apt安装软件后, 相应的安装包会缓存在`/var/cache/apt/archives/`, 可以使用以下的指令查看这部分缓存占用的空间.

```
sudo du -sh /var/cache/apt/archives/
```

如果已经占用较大的空间, 可以使用以下指令自动清理缓存:

```
sudo apt clean
```


扩展可用空间
-------------------------
```
$ sudo fs_resize
WARNING: Do you want to resize "/dev/mmcblk0p2" (y/N)?  y
```

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
- 找到 `/etc/re.local`
- 在此文件中写入需要的命令

**注意**: 在18.04中,可以在Tweak中直接设置开启启动程序


设置定时任务
----------------

使用`crontab -e`打开文件, 并输入要执行的指令. 例如

```
0 3 * * * /root/Application/TimeMachine.sh daily
```

> 注意: 全部位置都要使用绝对路径,并且手动执行一次脚本，确认权限和路径没有问题

### Crontab语法解析

在Crontab的文件中，每一行表示一个要执行的指令，每一行都具有如下的格式

```
* * * * * /path/to/script.sh
```

前面的5个`*`的位置分别表示分钟，小时，天，月，和星期。如果是数字就是具体的时刻，如果是`*`则表示所有，例如

```
0 3 * * *  ==> 每天3点0分执行一次
* 3 * * *  ==> 每天3点0分到3点59分的时间段内，每分钟执行一次
```

更多配置方式， 可以参考下面的文章

- [Crontab in Linux with 20 Useful Examples to Schedule Jobs](https://tecadmin.net/crontab-in-linux-with-20-examples-of-cron-schedule/)


### 不执行原因排查

首先在根目录手动执行一次脚本，确定脚本的权限和路径设置都是正确的。 如果脚本可以手动执行，但配置就是不生效，可以将脚本的输出重定向到日志文件， 例如

```
* * * * * /root/Application/TimeMachine.sh daily >> /root/TM.log 2>&1
```

之后可以在日志中查看是否有报错。


双系统设置默认启动项
-------------------------
1. 打开相关的配置文件
```
$ sudo gedit /etc/default/grub
```

2. 修改相关选项
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

3. 更新
只有更新上述设置以后, 相关的修改才会生效
```
$ sudo update-grub
```


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

创建桌面快捷方式
-------------------

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





Linux系统目录结构
--------------
- [Linux各目录及每个目录的详细介绍](https://www.cnblogs.com/duanji/p/yueding2.html)
- [Linux 系统的/usr目录](https://www.cnblogs.com/ftl1012/p/9278578.html)


Ubuntu管理多版本Java
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


Zsh与oh-my-zsh
------------------
- [Ubuntu 16.04下安装zsh和oh-my-zsh](https://www.cnblogs.com/EasonJim/p/7863099.html)



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

- [Ubuntu 18.04安装Samba服务器及配置](linuxidc.com/Linux/2018-11/155466.htm)


配置代理服务
----------------

对于部分常用软件, 可以通过配置代理的方式加速

### Git

```
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
```

### Docker

Docker的代理分为两类, 一类是docker指令在拉取镜像过程中使用的代理, 配置可以参考[HTTP/HTTPS proxy](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy). 一类是容器运行过程中使用的代理, 可以参考[Configure the Docker client](https://docs.docker.com/network/proxy/#configure-the-docker-client). 配置文件可以参考如下的内容:

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

[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:1080"
Environment="HTTPS_PROXY=socks5://127.0.0.1:1080"
```

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