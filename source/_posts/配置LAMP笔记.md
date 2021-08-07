---
title: 配置LAMP笔记
date: 2017-08-10 22:15:57
categories:
tags:
   - 环境配置
---

## LAMP环境
LAMP环境指Linux, Apache, MySQL, PHP


## 基本环境配置
- 执行以下两条命令中的任意一条即可完成基本安装
```
sudo apt-get install apache2 php5 mysql-server php-mysql
sudo tasksel install lamp-server
```

## 模块选择
- **注意**：测试发现以下模块需要分开安装
```
sudo apt-get install php5-gd cur1 libcurl3 libcurl3-dev php5-curl
```
------------------------------------------------------------------
## openssh设置远程root登录
1. 修改root密码
```
sudo passwd root
```
2. 设置ssh配置文件
- 执行以下命令, 找到PermitRootLogin 一行, 设置为yes
```
sudo vi /etc/ssh/sshd_config
```

--------------------------------------------------------------------
## 模块基本信息
名称   | 配置文件位置 | 配置文件名
:-----:|:-------------|:----------
Apache |/etc/apache2  |
MySQL  |/etc/mysql    | my.cnf
PHP    |/etc/php5     | php.ini

## Apache简单介绍
- Apache会首先加载apache.conf, 因此这个文件是配置文件的入口
- 其下有若干子目录, 含义如下
	- mods-*	Apache模块
	- sites-*   虚拟主机
	- *-available 表示可用的配置
	- *-enable    表示已经启用的配置
- 使用ln命令创建软连接, 将available中的文件链接到enable中


## Windows10下hosts文件位置
C:\Windows\System32\drivers\etc

## 虚拟主机配置
1. 首先进入虚拟主机的可用配置目录
```
cd /etc/apache2/sites-available/
```
2. 对于每一个需要的域名, 都需要创建一个配置文件. 否则将转向默认的配置文件
3. 在文件中, 通过ServerName来指定该配置文件所对应的域名
4. 在Directory标签下设置访问权限
```
<Directory /wwwroot/vedio>

            Options FollowSymLinks

            AllowOverride None

            Require all granted
</Directory>
```
5. 创建软链接
```
sudo ln -s ../sites-available/video.conf video.conf
```
6. 重启apache

## MySQL数据迁移
1. 停止MySQL服务
2. 在挂在的硬盘上, 创建需要的目录
3. 设置该目录所有者权限
```
sudo chown -vR mysql:mysql 创建的目录
```
4. 设置该目录权限
```
sudo chown -vR 700 创建的目录
```
5. 复制（首先切换到root）
```
cp -av 原来的目录/* 新目录（参数）
```
6. 设置my.cnf
	- 修改datadir的值（建议直接注释原来的哪一行, 便于发生意外后恢复）
7. 修改apparmor配置文件
	- 找到 ` /var/lib/mysql` 的两行, 注释掉, 然后在新的行中设置新的目录为原来的值
8. 重启apparmor
9. 启动mysql



## Apache 访问配置
1. 访问权限
	- 每一个不同的文件夹, 都可以使用Directory标签设置权限, 具体的权限设置方法可以参考网上的资料
2. 访问其他路径
	- 如果网站需要访问文件夹中的内容, 需要设置虚拟路径, 使用Alias设置路径的别名, 格式为
```
Alisa 新的名称 原来的名称
```
	- 注意：原来的名称需要在在双引号之中, 例如
```
Alias /media/u_lizec/Data "/media/u_lizec/Data"
```
	- 设置文件夹后, 需要重新设置访问权限