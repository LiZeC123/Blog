---
title: Git笔记之基础操作
date: 2017-08-07 19:10:36
categories: Git笔记
tags:
    - Git
cover_picture:  images/git.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍GIT的基础知识, 包括GIT的初始化, 基本的指令, 基本原理, 以及GIT标签和GIT别名. 本文从GIT的原理出发, 重点分析了各种情况下的代码撤回操作.


Git的基本使用
------------------

### 初始化
```
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
git config --global core.editor vim
```
前两条指令用于指定用户名和邮箱, 这些信息会显示在之后的提交信息之中, --global表明上述配置为全局有效. 完成上述配置以后才能使用Git.

第三条指令将git默认的编辑器设置为vim.

### 基础指令

指令                  | 作用
:--------------------|-------------------
git init             | 将当前文件夹初始化为一个git库
git add .            | 将当前目录和子目录下的所有改变提交
git add --all        | 将所有改变放入暂存区(包括父目录中的更改)
git add filename     | 将指定的文件提交
git commit -m "XXX"  | 使用-m参数指定本次提交的信息, 该信息保留在提交日志中,  从而用于识别提交的内容
git status           | 查看当前的状态, Git同时给出下一步可以执行的操作



Git的基本概念
------------------

### Git的几个区域

Git中存在三个区域, 每个区域的名称和作用如下

名称   | 解释
------|--------------------------------------------------------
工作区 | 与当前文件系统同步变化的区域工作区
暂存区 | 执行add之后后的文件存在的区域
版本库 | 执行commit操作以后的文件进入版本库

其中暂存区(staging area)也被称为缓冲区(buffer)或者索引(index). 


### Git基本原理

Git的三个区域都直接保存文件的快照, 而不是文件的修改. Git通过对比**两个快照之间的差异**来识别做出了什么更改. 当暂存区和工作区存在差异时提示有文件被修改(或者有新创建的文件), 当版本库和暂存区存在差异时提示有`Changes to be committed`

工作区的快照始终和当前的文件系统保持同步. 执行add操作后, 相应的文件就会同步到暂存区, 使得工作区和暂存区保持一致. 执行commit操作时, 暂存区的快照同步到版本库之中, 使得版本库和暂存区保持一致. 

### Git存储原理

每次执行commit操作后, 版本库都会有一个新的快照, Git会对此快照计算哈希值, 并且使用一个节点表示, 各次提交产生的节点通过链表的形式连接(类似比特币), 从而形成提交历史.  

同时Git中还存在一个HEAD指针, 此指针指向当前版本库的状态, 通过修改此指针的指向就可以将版本库恢复到某个历史状态, 例如某个版本库中可能有如下的状态：

```
* f6264d3 <- master <- HEAD
* fae731a 
* 104e8db 
* 61cfc62
```

Git的撤销操作
-------------------

所有版本控制系统的本质都是创建一些安全的文件快照,  从而保证你的代码不会受到不可挽回的修改破坏. 因此Git中所有的撤销操作本质上都是基于**对三个工作区的修改**, 明确这一点有助于对Git撤销的原理的理解. 


### 基本操作

操作类型               |    操作指令                | 含义
:---------------------|----------------------------|------------------------------------------
版本库                 | `git reset --soft <loc>`    | 版本库快照回退到指定的版本, 其他区域快照不变
版本库->暂存区          | `git reset --mixed <loc>`     | 版本库和暂存区都回到指定版本, 其他区域不变
版本库->暂存区->工作区    | `git reset --hard <loc>`     | 版本库, 暂存区, 工作区都回到版本
版本库->工作区          | `git checkout <loc> <file>`| 将指定文件的指定版本回退到工作区

其中`<loc>`表示某一个提交版本, 既可以使用HEAD表达, 也可以使用哈希值表达. `<file>`表示一个文件的文件名 

### 原理分析

假设当前有如下的一组提交历史

```
D-C-B-A
```

即按照时间顺序依次提交了D,C,B,A四个版本, 当前处于A状态. 注意, 这意味着版本库, 暂存区以及工作区都处于A状态. 如果此时使用

```
git reset --mixed HEAD~
```

则版本库和暂存区回退到B状态, 但是工作区还维持A状态. 此时Git对比暂存区和工作区的区别, 就会将B到A之间的差异视为`Changes not staged for commit`, 这就如同将之前的提交撤回到了工作区, 从而可以重新组织需要提交的内容. 

一些常见的撤回操作对应的指令如下所示:


撤销类型      |  指令                        | 说明
--------------|-----------------------------|---------------------------------
撤回提交       | `git reset HEAD~`             | commit的内容撤回到工作区
撤回暂存       | `git reset HEAD`               | 暂存区更改丢失,工作区代码不变
清除未跟踪文件  | `git clean -df`              | 删除新创建的文件和文件夹
撤销工作区更改 | `git checkout -- filename`   | 工作区更改完全丢失


HEAD是头指针,表示当前版本. HEAD~表示上一个版本, 如果是之前的第100个版本, 则可写为HEAD~100.  使用`git status`显示当前状态时, Git会提示上面的大部分指令, 因此这些指令并不需要记忆, 了解实现原理即可. 


### 清理工作区

工作区与其他区域相比有一些不同, 在工作区存在新建文件和修改文件的区别. 虽然两种都会使工作区与暂存区产生差异, 但是新建的文件默认都是不跟踪的, 如果不执行add操作, 则Git默认不管理这些文件. 

因此撤销工作区的更改, 有两个指令, 分别用于清除新添加的文件和恢复文件的修改.  对于`git clean`指令, 具有如下的参数

参数     | 含义
--------|--------------------------------------------------
-d        | 清理文件夹
-f        | 强制清理, 通常情况下不指定此参数会拒绝执行
-n        | 模拟执行一次, 显示会删除的文件
-x        | 删除被.gitignore忽略的文件

对于`git checkout`, 既可以使用 `git checkout -- filename`也可以使用`git checkout <loc> <file>`, 两种格式是等价的. 


### 远程撤销更改
```
$ git revert HEAD
```

使用后分支并不会被回退, 而是创建了一个新的提交, 该提交通过反向修改恢复了代码. 由于这本身也是一个提交操作, 因此即使以及有其他人在此分支上切出, 只要没有同时修改回退的内容, 就不会产生任何的影响. reset适用于私有分支,而revert可以适用于公共分支.
 

### 分支文件替换

`git checkout`指令可以将一个文件切换到指定的版本, 因此可以通过此指令将一个文件用另外一个分支的文件替换, 例如

```
$ git checkout test -- pom.xml
```

可以将当前分支的pom.xml文件替换为test分支上的相应文件.


### 参考资料

- [Git reset checkout commit 命令详解](https://halfmoonvic.github.io/2017/07/20/Git-reset-checkout-commit-%E5%91%BD%E4%BB%A4%E8%AF%A6%E8%A7%A3/)


Git的监视指令
------------------

### 查看记录
```
$ git log
$ git log --pretty=oneline
$ git reflog
```

直接使用log指令会展示详细的提交记录, 如果使用`online`参数, 则只显示提交ID和提交信息. 

reflog相对于对git所有的操作进行了版本控制, 其中展示了所有git指令的哈希值, 从而可以方便的回滚git操作


### 查看更新
```
$ git diff
$ git diff filename
$ git diff --staged
```
- 使用前两种指令将显示*工作区*中的内容和*暂存区*中内容的区别(尚未add的版本和最近一次add或commit的版本的区别)
- 使用第三中指令将显示*暂存区*中内容和*版本库*中内容的区别


标签管理
-----------------------------

### 添加标签
```
$ git tag                                //显示所有标签
$ git tag tagName                        //给最近一次提交添加标签
$ git tag tagName digs                   //给指定ID的提交添加标签
$ git tag -a tagName -m tagMessage digs  //给指定ID的提交添加标签和详细信息
```

### 操作标签
```
$ git tag -d tagName            //删除指定的标签
$ git push origin tagName        //推送指定的标签
$ git push origin --tags        //推送所有的标签
```

设置别名
-------------

如果经常使用命令行进行Git操作, 那么执行如下的指令来设置一些简称可能有助于提高指令的输入速度


```
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

<!-- 
[alias]
    co = checkout
    ci = commit
    st = status
    pl = pull
    ps = push
    dt = difftool
    l = log --stat
    cp = cherry-pick
    ca = commit -a
	cm = commit -m
    b = branch
	a = add .
	s = stash -->


Win10创建可执行文件
---------------------

使用如下的指令, 将`foo.sh`添加可执行权限.

```bash
git update-index --chmod=+x foo.sh
```

- [如何在Windows上的Git中创建文件执行模式的权限？](https://cloud.tencent.com/developer/ask/28981)


参考资料和扩展阅读
-----------------------------
- [Git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
- [GitHub基本使用](http://www.cnblogs.com/findingsea/archive/2012/08/27/2654549.html)
- [Git撤销](https://segmentfault.com/a/1190000013838580)
- [git reset soft,hard,mixed之区别深解](http://www.cnblogs.com/kidsitcn/p/4513297.html)
- [有关 Git 中 commit 的原理 理解 及 reset、checkout 命令详解](https://segmentfault.com/a/1190000005638174)
- [Learn Git with Bitbucket Cloud](https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud)
- [Git的原理简介和常用命令](https://www.cnblogs.com/yelbosh/p/7471979.html)
- [Git工作流](https://github.com/oldratlee/translations/blob/master/git-workflows-and-tutorials/README.md)