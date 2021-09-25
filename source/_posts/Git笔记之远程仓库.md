---
title: Git笔记之远程仓库
date: 2018-08-07 19:19:54
categories: Git笔记
tags:
    - Git
cover_picture:  images/git.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



远程仓库
-----------------------------
### 初始化SSH密钥

检查当前用户目录下是否有.ssh文件夹, 其中是否包含id_rsa和id_rsa.pub这两个文件, 如果有则说明已经创建过SSH密钥. 如果没有则执行如下的指令来创建密钥

```
$ ssh-keygen -t rsa -C "youremail@example.com"
```

指令执行过程中会询问几个问题, 全部使用默认值即可. 执行完毕后就可以在当前用户目录的.ssh文件夹下看到id_rsa和id_rsa.pub这两个文件.


### 添加SSH公钥

1. 登陆GitHub, 进入个人主页, 选择设置选项后, 依次选择`Account settings`->`SSH Keys`
2. 点击`Add SSH Key`, 添加任意`Title`, 在Key文本框里粘贴将上一节生成的id_rsa.pub文件的内容

注意: Title用来标识不同的Key的, 例如在不同的设备上有不同的Key, 则Title可以设置为设备的名称

完成上述操作后, 即可免密码的从GitHub上传和下载代码.


### 关联远程仓库

- 在GitHub上创建相关的仓库, 如果为远程仓库为空, 本地仓库非空, 则可使用
```
$ git remote add origin git@github.com:XXX/YYY.git      //关联本地仓库和远程仓库
```
- 若本地尚未建立仓库, 远程仓库非空, 则可使用
```
$ git clone git@github.com:XXX/YYY.git                  //将远程仓库内容拷贝到本地并关联
```

---------------------

因为只在第一次使用时需要关联远程仓库, 所以不建议GitHub和本地同时存在内容时进行关联. 在这种条件下的关联操作非常繁琐, 强烈不建议尝试.


Remote操作
-------------------

一个本地的git仓库可以关联多个远程仓库, 并且每个仓库可以分别具有不同的用户权限.


操作            | 指令
----------------|---------------------------------------
查看已有仓库     | `git remote -V`
添加            | `git remote add <name> <address>`
删除            | `git remote remove <name>`
重命名          | `git remote rename <old> <new> `

- [2.5 Git 基础 - 远程仓库的使用](https://git-scm.com/book/zh/v2/Git-%E5%9F%BA%E7%A1%80-%E8%BF%9C%E7%A8%8B%E4%BB%93%E5%BA%93%E7%9A%84%E4%BD%BF%E7%94%A8)

GitHub技巧
-----------------------


### 文件模板

在Github中创建名为`LICENSE`或`gitignore`时, 网站会提示可以使用模板, 从而可以快速添加协议或忽略文件.

更多关于Github的小细节, 可以查看[GitHub秘籍（中文版）](https://www.kancloud.cn/thinkphp/github-tips/37890)




本地关联技术
-----------------------------

本节介绍如何将Git仓库与本地其他位置的仓库关联. 当其他仓库位于可移动设备上时, 可以使用Git进行同步.

### 创建公共仓库

使用以下指令在需要的位置创建一个没有工作区的仓库

```
$ git --bare init
```


### 管理公共仓库

Git支持将远程仓库指定为本地的仓库, 因此使用和远程仓库相同的指令进行关联即可. 例如以下代码联了位于G:/files文件夹下的公共仓库

```
$ git clone /g/files
```

一旦和本地的仓库管理以后, 之后的操作与一般的远程仓库没有区别


### Windows下可能的问题

Windows上不能直接在分区跟目录创建公共仓库. 如果执行这一操作, Windows会提示Permission denied. 

产生这一错误的原因是Git创建仓库时, Git需要先创建文件夹, 而Windows会认为Git想要创建一个驱动器, 从而拒绝Git的操作. Git的操作被拒绝后, 又会认为是权限不够, 因此返回Permission denied的提示.

解决这一问题的方法就是先在根目录创建一个文件夹, 在此文件夹内再创建Git仓库. 详细的讨论可以参考[这个回答](https://superuser.com/questions/409177/git-init-bare-permission-denied-on-16gb-usb-stick)


私有Git服务器
--------------

虽然可以仅仅使用Git就可以搭建私有服务器, 但出于使用更方便的角度考虑, 还是使用现有的解决方案更好. 例如Gogs.

