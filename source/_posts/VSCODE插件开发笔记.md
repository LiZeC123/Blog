---
title: VSCODE插件开发笔记
math: false
date: 2023-08-25 22:30:20
categories:
tags:
    - vscode
cover_picture: images/vscode.jpg
---



VsCode由于其跨平台的特性, 已经成为JetBrains全家桶以外, 我使用最多的IDE. 由于VsCode相对轻量的特性, 在写博客, 写Python脚本的场景中, 实际上比JetBrains全家桶更好用. 

近期在一些开发过程中, 一直苦于没有合适的IDE支持自定义的语言, 因此我决定尝试开发一个Vscode插件, 实现需要的功能. 通过查阅Vscode的官方文档, 发现VSCODE对于插件的支持非常全面, 想要开发一个基本能用的代码补全插件也非常的简单. 本文主要记录了VSCODE插件开发的一些基本内容.


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


注册指令
--------------

使用如下的指令可向VSCODE注册一个命令. 

```js
	context.subscriptions.push(vscode.commands.registerCommand('expr-kokomi.helpMe', async () => {
        // 命令实际上就一个函数, 在这个函数中, 使用VSCODE提供的其他API来实现具体的功能.
	}));
```

其中第一个参数为指令名称, 需要在配置文件中进行声明, 例如

```
  "contributes": {
    "commands": [
      {
        "command": "expr-kokomi.helpMe",
        "title": "Help me, Miss Kokomi",
        "category": "EK"
      },
    ]
  }
```

其中`command`就相当于这个指令的ID, 调用这个指令的时候需要使用此名称. `title`是这个指令在VSCODE面板上显示的文字.

> VSCODE通过将插件的功能抽象为指令, 提供了非常强大的扩展能力, 使得插件内调用和插件之间调用变得非常简单.


常用API
-----------


API名称                         | 效果
-------------------------------|------------------------------------------------
vscode.window.showErrorMessage | 在VSCODE右下弹出一个提示框, 有多种等级
vscode.window.createTerminal   | 创建一个terminal, 后续可通过发送text执行任意的指令



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

参考资料
-----------

### 文档

- [VSCode 插件开发（三）：插件打包与本地安装](https://www.jianshu.com/p/bb379a628004)
- [when条件的文档](https://code.visualstudio.com/api/references/when-clause-contexts)


### 项目

- [Vscode Go语言插件](https://github.com/golang/vscode-go)
- [Gopls: The language server for Go](https://go.dev/gopls/)