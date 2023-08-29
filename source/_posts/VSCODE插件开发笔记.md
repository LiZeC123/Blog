---
title: VSCODE插件开发笔记
math: false
date: 2023-08-25 22:30:20
categories: vscode
tags:
    - vscode
cover_picture: images/vscode.jpg
---



VsCode由于其跨平台的特性, 已经成为JetBrains全家桶以外, 我使用最多的IDE. 由于VsCode相对轻量的特性, 在写博客, 写Python脚本的场景中, 甚至比JetBrains全家桶更好用. 近期在一些开发过程中, 一直苦于没有合适的IDE支持自定义的语言, 因此我决定尝试开发一个Vscode插件, 实现需要的功能.



创建插件项目
----------------

Vscode已经提供了一些必要的工具来辅助我们创建Vscode插件的工程项目. 开发过程需要nodejs环境. 由于nodejs更新较快, 因此建议先升级一下现有的nodejs, 以免因为版本太低导致无法安装后续的依赖.

nodejs安装完毕后, 执行如下的指令安装vscode插件开发需要的依赖项目

```
npm install -g yo generator-code
```

> yo是一个通用的项目骨架生成工具, generator-code是vscode插件生成工具, 和yo配合生成项目的骨架

安装依赖需要一些时间, 安装完毕后执行如下指令创建项目

```
yo code
```

上述指令会在用户的目录下创建一个工程目录, 可根据需要将这个项目移动到其他位置.

> 在window平台, 建议使用CMD执行此指令. git-bash和powershell效果都不太好



### 参考资料

- [Vscode官方的插件文档](https://code.visualstudio.com/api/get-started/your-first-extension)
- [如何开发一款vscode插件 - 知乎](https://zhuanlan.zhihu.com/p/386196218)



发布插件
--------------

执行如下指令安装打包模块

```
npm i -g vsce
```

然后执行如下指令打包插件

```
vsce package
```

执行完毕后, 会在当前项目下生成`xx.vsix`文件, 最后执行

```
code --install-extension xx.vsix
```

即可将插件安装到vscode之中

### 参考资料

- [VSCode 插件开发（三）：插件打包与本地安装](https://www.jianshu.com/p/bb379a628004)