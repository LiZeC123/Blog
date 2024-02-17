---
title: VSCODE配置笔记
date: 2022-04-07 10:10:31
categories: vscode
tags:
    - vscode
cover_picture: images/vscode.jpg
---

VSCODE作为一个较为轻量级的编辑器, 总体上来说是开箱可用的. 不过对于各类具体的场景, 安装一些插件或者修改一些配置能够带来更好的使用体验. 本文将简单介绍一些好用的VSCODE插件, 以及一些常用的VSCODE配置

插件推荐
---------

### Markdown All in One

此插件提供了大量Markdown相关的功能, 相比与前几年写Markdown需要安装一堆插件的情况, 这个插件确实做到了"All in One"

### Remote-SSH

此插件是VSCODE远程开发插件中的一部分, 可以使VSCODE在远程服务器上运行. 此功能可以说是VSCODE最具特色的功能, 至今还是比JetBrains全家桶不知道高到哪里去了.

### Compare Folders

提供文件夹对比功能, 可方便的对比不同文件之间的差异.

### Pylance

Python语言的插件, 对于机器学习场景, 感觉比PyCharm更好用.


常用配置修改
-----------------

### VSCODE修改默认终端

按下`Ctrl+P`打开功能搜索栏，输入`Terminal: Select Default Profile`，然后选择自己需要的终端。


### 启用从终端开启Code

对于Mac系统, 可以按下`command+shift+p `打开指令面板后, 输入`Install Code command in PATH`的一部分开启该功能.

- [mac 下命令行启动vscode打开指定文件夹](https://blog.csdn.net/qq_31460257/article/details/81592812)

常见问题修复
----------------


### Mac端与Linux端远程连接服务器超时

当远程服务器配置使用fish时, 可能出现Mac端或Linux端无法连接远程服务器的问题, 参考Vscode的ISSUS, 可配置`"remote.SSH.useLocalServer": false`来解决此问题

- ["Connecting with SSH timed out" when Fish/tcsh/csh shell is used](https://github.com/microsoft/vscode-remote-release/issues/2509)
