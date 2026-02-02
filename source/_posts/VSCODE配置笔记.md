---
title: VSCODE配置笔记
date: 2022-04-07 10:10:31
categories:
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

> 注意: 截止2024年3月, Pylance插件默认不启用语法检查, 可点击VSCODE右下角的Python按钮启用语法检查

### Live Server

此插件可启动一个Web服务器, 使得项目的文件可以在浏览器中浏览. 例如通过Vscode链接远程服务器开发项目时, 可在生成代码覆盖率报告后, 通过此插件启动Web服务器, 从而在浏览器中查看报告.

### Error Len

此插件可以将错误页面报告的错误直接在对应的行上进行展示, 从而优化VSCODE的错误提示效果.


### Gremlins tracker for Visual Studio Code

显示文本中的不可见字符(例如零宽度空格). 从其他地方复制的文本可能包含这类字符(尤其是来自于AI大语言模型的输出), 通常情况下完全不可见这类字符, 将其作为字符串使用非常容易出现问题.


### Edit CSV

提供类似Excel界面的CSV编辑能力, 适合轻量化场景下的数据浏览和编译.



常用配置修改
-----------------

### VSCODE修改默认终端

按下`Ctrl+P`打开功能搜索栏，输入`Terminal: Select Default Profile`，然后选择自己需要的终端。


### 启用从终端开启Code

对于Mac系统, 可以按下`command+shift+p `打开指令面板后, 输入`Install Code command in PATH`的一部分开启该功能.

- [mac 下命令行启动vscode打开指定文件夹](https://blog.csdn.net/qq_31460257/article/details/81592812)

### 关闭提示音

如果发现操作shell或者在页面编辑时, 出现了奇奇怪怪的提示音, 可以打开配置页面, 搜索`Editor: Accessibility Support`, 选择`off`关闭辅助功能.


常见问题修复
----------------


### Mac端与Linux端远程连接服务器超时

当远程服务器配置使用fish时, 可能出现Mac端或Linux端无法连接远程服务器的问题, 参考Vscode的ISSUS, 可配置`"remote.SSH.useLocalServer": false`来解决此问题

- ["Connecting with SSH timed out" when Fish/tcsh/csh shell is used](https://github.com/microsoft/vscode-remote-release/issues/2509)

### Vscode在Vue文件中无法自动关闭括号

根据这篇回答的说法, 通过`reload window`可以修复此问题. 对于Github Codespace, 也可以执行reload操作

- [Auto closing brackets in visual-studio-code not working for Vue files](https://stackoverflow.com/questions/64086068/auto-closing-brackets-in-visual-studio-code-not-working-for-vue-files)

### VSCode连接服务器太慢问题解决

在使用Vscode连接服务器时, 如果当前客户端使用了更新的版本, 则在服务器上也会对应下载最新的版本. 此时可能出现下载服务器版速度太慢的问题.

当前搜索这个问题, 有些博客会建议手动下载文件并解压到对应的目录. 截止2024年4月, 实测上述操作无效. 但在操作过程中, 发现对待下载文件的写入操作返回busy, 因此当即尝试对服务器进行重启. 重启后下载速度恢复正常.