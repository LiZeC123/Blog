---
title: Git笔记之基础操作
date: 2017-08-07 19:10:36
categories: 
tags:
    - Git
cover_picture:  images/git.jpg
---

Git是一个免费, 开源的分布式版本控制系统, 用于敏捷高效地处理任何或小或大的项目. Git是 Linus Torvalds 为了帮助管理 Linux 内核开发而开发的一个开放源码的版本控制软件.本文介绍Git的基础知识, 具体包括Git的初始化配置, 常用的基础指令, Git的基本原理等内容.


基本使用
------------------

### 初始化
```
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
git config --global core.editor vim
```
前两条指令用于指定用户名和邮箱, 这些信息会显示在之后的提交信息之中, --global表明上述配置为全局有效. 完成上述配置以后才能使用Git.

第三条指令将git默认的编辑器设置为vim.

### 设置简称指令

如果经常使用命令行进行Git操作, 那么执行如下的指令来设置一些简称可能有助于提高指令的输入速度.


```
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

可以使用如下的配置文件进行更多配置, 输入`git config --global -e`后在打开的文件中进行编辑即可生效. 详细内容可参考[Git 命令的简写配置(别名)](https://blog.csdn.net/Lakers2015/article/details/111872161)

```
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
	s = stash
```

> 在实践过程中, 通常不会在命令行中执行过于复杂的指令, 而是更加倾向于通过IDE的图像界面完成相关操作. 因此配置一些基础的指令别名就可以满足绝大部分需求.


### 基础指令

| 指令                | 作用                                                                          |
| :------------------ | ----------------------------------------------------------------------------- |
| git init            | 将当前文件夹初始化为一个git库                                                 |
| git add .           | 将当前目录和子目录下的所有改变提交                                            |
| git add --all       | 将所有改变放入暂存区(包括父目录中的更改)                                      |
| git add filename    | 将指定的文件提交                                                              |
| git commit -m "XXX" | 使用-m参数指定本次提交的信息, 该信息保留在提交日志中,  从而用于识别提交的内容 |
| git status          | 查看当前的状态, Git同时给出下一步可以执行的操作                               |

### 常用前缀

在Git提交时, 约定使用如下的一些单词作为提交记录的前缀, 以表明本次提交的操作类型

| 前缀   | 含义                       | 前缀     | 含义                       |
| ------ | -------------------------- | -------- | -------------------------- |
| feat   | 新功能, 新特性             | fix      | 修复BUG                    |
| perf   | 不改变功能的前提下提高性能 | refactor | 不改变功能的前提下重构代码 |
| docs   | 文档修改                   | style    | 代码格式修改               |
| revert | 恢复上一次提交             | release  | 发布新版本                 |
| test   | 测试用例新增或修改         | ci       | 持续集成相关文件修改       |
| build  | 影响项目构建或依赖项修改   | workflow | 工作流相关文件修改         |
| chore  | 其他修改                   |



基本概念与原理
------------------

### Git的几个区域

Git中存在三个区域, 每个区域的名称和作用如下

| 名称   | 解释                               |
| ------ | ---------------------------------- |
| 工作区 | 与当前文件系统同步变化的区域工作区 |
| 暂存区 | 执行add之后后的文件存在的区域      |
| 版本库 | 执行commit操作以后的文件进入版本库 |

> 其中暂存区(staging area)也被称为缓冲区(buffer)或者索引(index). 


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

常用撤销操作
-------------------

所有版本控制系统的本质都是创建一些安全的文件快照,  从而保证你的代码不会受到不可挽回的修改破坏. 因此Git中所有的撤销操作本质上都是基于**对三个工作区的修改**, 明确这一点有助于对Git撤销的原理的理解. 


### 基本操作

| 操作类型               | 操作指令                    | 含义                                         |
| :--------------------- | --------------------------- | -------------------------------------------- |
| 版本库                 | `git reset --soft <loc>`    | 版本库快照回退到指定的版本, 其他区域快照不变 |
| 版本库->暂存区         | `git reset --mixed <loc>`   | 版本库和暂存区都回到指定版本, 其他区域不变   |
| 版本库->暂存区->工作区 | `git reset --hard <loc>`    | 版本库, 暂存区, 工作区都回到版本             |
| 版本库->工作区         | `git checkout <loc> <file>` | 将指定文件的指定版本回退到工作区             |

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


| 撤销类型       | 指令                       | 说明                          |
| -------------- | -------------------------- | ----------------------------- |
| 撤回提交       | `git reset HEAD~`          | commit的内容撤回到工作区      |
| 撤回暂存       | `git reset HEAD`           | 暂存区更改丢失,工作区代码不变 |
| 清除未跟踪文件 | `git clean -df`            | 删除新创建的文件和文件夹      |
| 撤销工作区更改 | `git checkout -- filename` | 工作区更改完全丢失            |


HEAD是头指针,表示当前版本. HEAD~表示上一个版本, 如果是之前的第100个版本, 则可写为HEAD~100.  使用`git status`显示当前状态时, Git会提示上面的大部分指令, 因此这些指令并不需要记忆, 了解实现原理即可. 


### 清理工作区

工作区与其他区域相比有一些不同, 在工作区存在新建文件和修改文件的区别. 虽然两种都会使工作区与暂存区产生差异, 但是新建的文件默认都是不跟踪的, 如果不执行add操作, 则Git默认不管理这些文件. 

因此撤销工作区的更改, 有两个指令, 分别用于清除新添加的文件和恢复文件的修改.  对于`git clean`指令, 具有如下的参数

| 参数 | 含义                                       |
| ---- | ------------------------------------------ |
| -d   | 清理文件夹                                 |
| -f   | 强制清理, 通常情况下不指定此参数会拒绝执行 |
| -n   | 模拟执行一次, 显示会删除的文件             |
| -x   | 删除被.gitignore忽略的文件                 |

对于`git checkout`, 既可以使用 `git checkout -- filename`也可以使用`git checkout <loc> <file>`, 两种格式是等价的. 


### 远程撤销更改

```
git revert HEAD
```

使用后分支并不会被回退, 而是创建了一个新的提交, 该提交通过反向修改恢复了代码. 由于这本身也是一个提交操作, 因此即使以及有其他人在此分支上切出, 只要没有同时修改回退的内容, 就不会产生任何的影响. 

通常情况下, reset适用于私有分支, 而revert可以适用于公共分支.
 

### 分支文件替换

`git checkout`指令可以将一个文件切换到指定的版本, 因此可以通过此指令将一个文件用另外一个分支的文件替换, 例如

```
git checkout test -- pom.xml
```

可以将当前分支的pom.xml文件替换为test分支上的相应文件. 可查看 [Git reset checkout commit 命令详解](https://halfmoonvic.github.io/2017/07/20/Git-reset-checkout-commit-%E5%91%BD%E4%BB%A4%E8%AF%A6%E8%A7%A3/)获取更多高级用法



分支管理
------------------

### 查看现有分支

```
git branch
```

### 创建和切换分支

```
git branch        <分支名>                        //创建新分支
git checkout      <分支名>                        //切换分支
git checkout digs <分支名>                        //从指定的ID创建分支
git checkout -b   <分支名>                        //创建并切换分支
git checkout -b   <本地分支名> <origin/远程分支名>  //创建并拉取一个分支
```

### 分支合并和撤销

```
git merge branchName          //将指定分支的内容合并到当前分支
git merge --no-gg branchName  //将指定分支的内容合并到当前分支(非快进合并)
git reset --merge             //撤销本次合并
```

例如, 想要将dev分支的内容合并到master分支, 则应该按照如下步骤操作

```
git checkout master
git merge dev
```

### 快进合并

假设当前有两个分支master和dev, 如果仅仅在dev分支上进行更改, 而在master上没有操作, 此时在master分支上进行合并, 则默认进行快速合并, 此时相当于将master的指针移动到和dev指针相关的位置.

如果使用非快进合并, 则相当于在master分支上进行一次commit, 此commit后的内容将和dev分支相同, 从而可以保留提交的相关信息, 以便于之后的查找

![快进合并示意图](/images/git/fastforword.jpg)

### 修改和删除分支

```
git branch -m branchName newBranchName    // 重命名分支
git branch -d branchName                  // 删除本地分支
git push origin --delete branchname       // 删除远程分支
```

### 冲突合并

如果两个分支的修改存在冲突, 合并时会提示相关的冲突文件, 并且在相关的文件中留有标记, 因此可以手动到相关的文件中修改冲突的内容, 之后再次进行提交.

实践过程中, 对于冲突通常并不会使用文本编辑器手动解决, 而是采取IDE提供的对比工具进行处理. 而且IDE通常还会提供一些自动解决冲突的功能, 对于部分简单冲突的情况可以自动解决.

> 注意：虽然手动解决冲突不是必要的, 即可以选择两个分支的更改都抛弃, 或者不进行任何更改. 但实际通常需要谨慎的处理冲突, 否则几乎必定会产生代码BUG.

### 保存现场和恢复现场

```
git stash list    //列出所有的保存内容
git stash         //保存当前工作区和暂存区的内容
git stash apply   //应用栈顶的内容
git stash drop    //删除栈顶的内容
git stash pop     //应用并删除栈顶的内容
```

如果工作区或暂存区有未提交的内容时, Git是不允许切换分支的. 使用上述命令可以先保存相关的操作, 切换分支处理优先级高的问题, 最后切换回来并恢复环境

### 参考资料

- [简单介绍三路合并](https://blog.csdn.net/u012937029/article/details/77161584)
- [git merge参数详解(还链接了几篇其他文章, 也可以看看)](https://www.jianshu.com/p/58a166f24c81)


分支高级操作
-----------------------------

### 变基操作

假定有两个分支master和dev, master分支在A提交后分出dev分支, 之后进行了B提交, 在dev分支上进行了C和D提交, 使用变基操作后, 相当于将dev分支修改为从B上分出, 然后进行C和D提交.

使用rebase操作可以保持提交记录简单, 避免产生大量的merge提交记录.

```
git rebase master
```

![变基操作示意图](/images/git/rebase.jpg)

### 变基操作的冲突处理

如果在变基过程中产生了冲突, 变基操作会终止, 并提示冲突原因. 此时需要手动处理相关冲突, 并add到缓冲区. 之后指定`git rebase --continue`继续变基操作

实践中通常采用IDE完成变基操作, 此时如果产生冲突仅需要按照提示处理即可.

> 执行变基操作前最好对当前分支的提交记录进行合并, 变为只有少数提交. 否则变基过程中可能会多次重复解决相同的冲突, 容易在解决冲突过程中由于决策错误产生BUG.


### 移植分支
```
git chechout dev
git rebase master --onto release
```

![移植分支示意图](/images/git/changebase.jpg)


### 从另一个分支提取指定的提交

使用如下的指令, 可以将一个指定的提交应用到当前分支.

```
git cherry-pick <commit-id>
```

### 删除冗余

使用如下指令, 可以删除不可访问的提交, 从而改善文件保存结构并节省硬盘空间

```
git gc
```

实践中通常并不会手动执行此指令. 正常使用下也不会产生显著数量的不可访问的提交.



远程仓库
-------------

### 初始化SSH密钥

检查当前用户目录下是否有.ssh文件夹, 其中是否包含id_rsa和id_rsa.pub这两个文件, 如果有则说明已经创建过SSH密钥. 如果没有则执行如下的指令来创建密钥

```
ssh-keygen -t rsa -C "youremail@example.com"
```

指令执行过程中会询问几个问题, 全部使用默认值即可. 执行完毕后就可以在当前用户目录的.ssh文件夹下看到id_rsa和id_rsa.pub这两个文件.


### 添加SSH公钥

1. 登陆GitHub, 进入个人主页, 选择设置选项后, 依次选择`Account settings`->`SSH Keys`
2. 点击`Add SSH Key`, 添加任意`Title`, 在Key文本框里粘贴将上一节生成的id_rsa.pub文件的内容

注意: Title用来标识不同的Key的, 例如在不同的设备上有不同的Key, 则Title可以设置为设备的名称

完成上述操作后, 即可免密码的从GitHub上传和下载代码.


### 关联远程仓库

在GitHub上创建相关的仓库, 如果为远程仓库为空, 本地仓库非空, 则可使用

```
git remote add origin git@github.com:XXX/YYY.git      //关联本地仓库和远程仓库
```

若本地尚未建立仓库, 远程仓库非空, 则可使用

```
git clone git@github.com:XXX/YYY.git                  //将远程仓库内容拷贝到本地并关联
```


> 因为只在第一次使用时需要关联远程仓库, 所以不建议GitHub和本地同时存在内容时进行关联. 在这种条件下的关联操作非常繁琐, 强烈不建议尝试.


远程分支操作
-------------------

一个本地的git仓库可以关联多个远程仓库, 并且每个仓库可以分别具有不同的用户权限.


| 操作         | 指令                              |
| ------------ | --------------------------------- |
| 查看已有仓库 | `git remote -V`                   |
| 添加         | `git remote add <name> <address>` |
| 删除         | `git remote remove <name>`        |
| 重命名       | `git remote rename <old> <new> `  |

- [2.5 Git 基础 - 远程仓库的使用](https://git-scm.com/book/zh/v2/Git-%E5%9F%BA%E7%A1%80-%E8%BF%9C%E7%A8%8B%E4%BB%93%E5%BA%93%E7%9A%84%E4%BD%BF%E7%94%A8)




Git的监视指令
------------------

### 查看记录

```
git log
git log --pretty=oneline
git reflog
```

直接使用log指令会展示详细的提交记录, 如果使用`online`参数, 则只显示提交ID和提交信息. 

reflog相对于对git所有的操作进行了版本控制, 其中展示了所有git指令的哈希值, 从而可以方便的回滚git操作


### 查看更新

```
git diff
git diff filename
git diff --staged
```

- 使用前两种指令将显示*工作区*中的内容和*暂存区*中内容的区别(尚未add的版本和最近一次add或commit的版本的区别)
- 使用第三中指令将显示*暂存区*中内容和*版本库*中内容的区别


标签管理
-----------------------------

### 添加标签
```
git tag                                //显示所有标签
git tag tagName                        //给最近一次提交添加标签
git tag tagName digs                   //给指定ID的提交添加标签
git tag -a tagName -m tagMessage digs  //给指定ID的提交添加标签和详细信息
```

### 操作标签
```
git tag -d tagName            //删除指定的标签
git push origin tagName        //推送指定的标签
git push --tags               //推送所有的标签
```


私有Git服务器
--------------

本节介绍如何将Git仓库与本地其他位置的仓库关联. 当其他仓库位于可移动设备上时, 可以使用Git进行同步.

### 创建公共仓库

使用以下指令在需要的位置创建一个没有工作区的仓库


```
git --bare init
```


### 管理公共仓库

Git支持将远程仓库指定为本地的仓库, 因此使用和远程仓库相同的指令进行关联即可. 例如以下代码联了位于G:/files文件夹下的公共仓库

```
git clone /g/files
```

一旦和本地的仓库管理以后, 之后的操作与一般的远程仓库没有区别


### Windows下可能的问题

Windows上不能直接在分区跟目录创建公共仓库. 如果执行这一操作, Windows会提示Permission denied. 

产生这一错误的原因是Git创建仓库时, Git需要先创建文件夹, 而Windows会认为Git想要创建一个驱动器, 从而拒绝Git的操作. Git的操作被拒绝后, 又会认为是权限不够, 因此返回Permission denied的提示.

解决这一问题的方法就是先在根目录创建一个文件夹, 在此文件夹内再创建Git仓库. 详细的讨论可以参考[这个回答](https://superuser.com/questions/409177/git-init-bare-permission-denied-on-16gb-usb-stick)


### 第三方私有仓库

虽然可以仅仅使用Git就可以搭建私有服务器, 但该方案过于简陋, 缺乏很多需要的功能. 此时可以考虑在服务器上部署第三方工具(例如[Gogs](https://github.com/gogs/gogs)), 从而实现类似Github的体验. 此外, Github目前也已经免费开发私有项目, 也可以考虑将代码以私有项目的形式放在Github上.


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