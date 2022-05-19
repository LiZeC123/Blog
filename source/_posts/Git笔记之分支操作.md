---
title: Git笔记之分支操作
date: 2018-09-07 19:20:22
categories: Git笔记
tags:
    - Git
cover_picture:  images/git.jpg
---




分支管理
-----------------------------

### 查看现有分支
```
$ git branch
```

### 创建和切换分支
```
$ git branch        <分支名>                        //创建新分支
$ git checkout      <分支名>                        //切换分支
$ git checkout digs <分支名>                        //从指定的ID创建分支
$ git checkout -b   <分支名>                        //创建并切换分支
$ git checkout -b   <本地分支名> <origin/远程分支名>  //创建并拉取一个分支
```

### 分支合并和撤销
```
$ git merge branchName          //将指定分支的内容合并到当前分支
$ git merge --no-gg branchName  //将指定分支的内容合并到当前分支(非快进合并)
$ git reset --merge             //撤销本次合并
```
例如, 想要将dev分支的内容合并到master分支, 则应该按照如下步骤操作
```
$ git checkout master
$ git merge dev
```

### 快进合并
- 假设当前有两个分支master和dev, 如果仅仅在dev分支上进行更改, 而在master上没有操作, 此时在master分支上进行合并, 则默认进行快速合并, 此时相当于将master的指针移动到和dev指针相关的位置
- 如果使用非快进合并, 则相当于在master分支上进行一次commit, 此commit后的内容将和dev分支相同, 从而可以保留提交的相关信息, 以便于之后的查找

![快进合并示意图](/images/git/fastforword.jpg)

### 修改和删除分支
```
$ git branch -m branchName newBranchName    // 重命名分支
$ git branch -d branchName                  // 删除本地分支
$ git push origin --delete branchname       // 删除远程分支
```

### 冲突合并
如果两个分支的修改存在冲突, 合并时会提示相关的冲突文件, 并且在相关的文件中留有标记, 因此可以手动到相关的文件中修改冲突的内容, 之后再次进行提交

注意：手动解决冲突不是必要的, 可以在冲突的文件中选择保留某个分支的修改, 也可以选择两个分支的更改都抛弃, 或者不进行任何更改

### 保存现场和恢复现场
```
$ git stash list    //列出所有的保存内容
$ git stash         //保存当前工作区和暂存区的内容
$ git stash apply   //应用栈顶的内容
$ git stash drop    //删除栈顶的内容
$ git stash pop     //应用并删除栈顶的内容
```
- 通常情况下, 如果工作区或暂存区有未提交的内容时, 是不允许切换分支的
- 使用上述命令可以先保存相关的操作, 切换分支处理优先级高的问题, 最后切换回来并恢复环境




高级操作
-----------------------------

### 变基操作
- 例如有两个分支master和dev,master分支在A提交后分出dev分支, 之后进行了B提交, 在dev分支上进行了C和D提交, 
- 使用变基操作后, 相当于将dev分支从B上分出
- 相当于对于C提交和D提交都进行合并
```
$ git rebase master
```

![变基操作示意图](/images/git/rebase.jpg)

### 变基操作的冲突处理
- 如果在变基过程中产生了冲突, 变基操作会终止, 并提示冲突原因
- 此时需要手动处理相关冲突, 并add到缓冲区
- 之后指定 git rebase --continue


### 移植分支
```
$ git chechout dev
$ git rebase master --onto release
```
![移植分支示意图](/images/git/changebase.jpg)

### 删除冗余
```
$ git gc
```
- 删除不可访问的提交
- 改善文件保存结构
- 使用gc命令可以节约硬盘空间




参考资料和扩展阅读
-----------------------------
- [简单介绍三路合并](https://blog.csdn.net/u012937029/article/details/77161584)
- [git merge参数详解(还链接了几篇其他文章, 也可以看看)](https://www.jianshu.com/p/58a166f24c81)
