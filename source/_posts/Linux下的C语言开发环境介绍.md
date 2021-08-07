---
title: Linux下的C语言开发环境介绍
date: 2017-08-31 20:14:34
tags: 
	- C
---

在Linux下, 主要的C语言开发工具是GCC和GDB, 其中 GCC 是 GNU Compiler Collection, 是C语言的编译器, GDB是GNU Project Debugger, 是一个基于命令行的调试器. 此外, 与GCC相对应的还有一个G++, 是对应于C++的编译器. 

通常情况下, Linux上的C语言开发都采用VIM作为集成开发环境, 但是VIM配置比较繁琐, 而最近出现的Visual Studio Code, 具有开箱即用的特点, 因此本文最后介绍如何将VSC配置为一个C/C++的集成开发环境.


GCC介绍
-------------------

### GCC编译过程


gcc的编译过程可以分成四步, 即 预处理, 编译, 汇编, 链接, 各个部分的处理器和文件类型关系如下所示

步骤名称    | 生成文件类型  |处理器名称
-----------|---------------|-----------------
预处理		| `.i`文件      | 预处理器 cpp
编译    	| `.s`文件      | 编译器   egcs
汇编    	| `.o`文件      | 汇编器   as
链接    	| 可执行文件    | 链接器   ld


GCC最基本的用法为直接在gcc后加上需要编译的 `.c` 文件, 例如

``` bash
gcc file1.c file2.c
```

此时默认生成名为`a.out`的可执行文件


### GCC编译参数


#### 基本流程控制

参数名			| 效果
----------------|-----------------------------------------------
`-c`			| 只进行预处理, 编译和汇编, 生成`.o`文件
`-S`			| 只进行预处理和编译, 生成`.s`文件
`-masm=intel`	| 以Intel格式输出汇编代码
`-E`			| 只进行预处理, 将结果输出到终端
`-save-temps`	| 保留编译中间过程生成的.i和.o文件, 供用户查询和调试
`-o`			| 指定输出的文件的文件名

注意, 通常预处理后文件很长, 所以建议重定向到文件, 然后再查看文件, 否则可能因为缓冲区大小导致显示不完全


#### 调试与优化

参数名			| 效果
----------------|-----------------------------------------------
`-Wall`			| 使gcc产生尽可能多的警告信息
`-Wextra`		| 输出额外的警告信息(即不包含在`-Wall`参数中的警告)
`-m32`			| 强制生成32位版本的程序
`-g`			| 在编译过程中加入调试信息
`-O`			| 指定程序优化等级
`-p`			| 将编译时产生的Profiling信息加入最后的二进制代码中


`-g`参数一共有三个等级, 即`-g1`, `-g2`, `-g3`. `-g1`只包含基本的信息, `-g2`包含符号表, 行号等信息, `-g3`包含`-g2`的全部信息以外, 还包含源代码中定义的宏. 因为加入的调试信息, 对文件体积上和运行速度都会有一些影响.

`-O`参数一共有三个等级, 即`-O1`, `-O2`, `-O3`. 数字越大, 优化等级越高, 较高的优化等级可能改变代码原有的行为, 导致调试时产生难以理解的问题, 因此通常仅仅在程序发布的时候才高等级优化

编译时产生的Profiling信息可帮助分析程序的性能瓶颈, 如果需要对程序性能进行分析, 可以使用此参数.


#### 链接库

参数名			| 效果
----------------|-----------------------------------------------
`-I`            | 指定头文件搜索目录
`-L`            | 指定库文件搜索目录
`-l<name>`      | 指定链接库的名称

当导入的头文件既不处于标准目录(例如`/usr/include`)也不处于当前目录, 则可以使用`-I`指令来指定一个目录, 将其加入头文件的搜索路径之中.

当需要连接的库文件(例如`.a`文件或`.so`文件)不处于标准目录(例如`/usr/lib`)之中, 则可以使用`-L`指令来指定一个目录, 将其加入库文件的搜索路径之中.

使用`-l<name>`使编译器链接名为`lib<name>`的库, 例如使用`-lm`可以使编译器链接`libm.a`这个数学库.


GDB介绍
------------

GDB是GNU Project debugger, 是Linux上一个非常常见的调试器. GDB的所有操作都是基于命令行的, 因此通常情况下并不直接使用GDB, 很多IDE(例如vscode)都可以将GDB的指令映射为可视化界面的按钮, 从而通过点击完成调试. 但是如果遇到没有源代码的情况, 或者进行汇编级别的程序开发, 则只能使用基于命令行的GDB进行调试. 因此有必要简单的了解GDB的有关语法, 大致的掌握GDB的使用.


### GDB基本指令

命令            | 解释                                   | 示例
---------------|------------------------------------------|----------------
`file <文件名>` | 使GDB加载指定的文件                       | (gdb) file a.out
r              | Run,运行程序                              | (gdb) r
c              | Continue,继续运行程序                     | (gdb) c
b              | Break,添加断点                            | (gdb) b mian
d              | 指定一个数字,则删除指定断点,否则删除所有断点 | (gdb) d 1
s,n            | Step,Next,以c语句为单位                   | (gdb) s
si,ni          | 同上,但以汇编指令为单位                    | (gdb) si
p              | Print 显示指定的变量的值                   | (gdb) p $eax
dispaly        | 在每次中断后显示指定变量的值                | (gdb) display $eax
i              | 显示有关的信息                             | (gdb) i r
q              | 退出                                      | (gdb) q


### 详细说明

#### 添加断点
实际上,添加断点有四种格式

1. `b <行号>`
2. `b <函数名>`
3. `b *<函数名>`
4. `b *<代码地址>`

其中行号指的是C语言源代码的行号, 由于可执行程序中没有源代码的信息, 则只能使用函数名或者代码地址.

#### 逐语句与逐过程
- s表示Step,执行一个C语句,如果是函数,则会进入函数
- n表示Next,执行一个C语句,如果是函数,则执行完函数
- si表示逐语句的执行一条汇编指令
- ni表示逐过程的执行一条汇编指令

#### 显示变量值
p指令可以显示一个C语言中定义的全局或局部变量的值

#### display指令
- 使用display指令,相当于添加了一个监视变量每次遇到断点或者使用了s或n以后,会打印指定的变量的值
- 使用`display /i $pc`可以打印下一条汇编指令
- 使用`undisplay <编号>` 可以取消指定序号的打印操作

#### 显示所有寄存器的值
- 使用`i r`指令


### GDB初始化脚本

如果一个程序存在某些问题需要反复的调试, 则有些初始化的命令可能需要反复的被执行, 此时可以使用gdb脚本来减少工作量.

#### 编写脚本

gdb启动时会尝试加载当前目录下的`.gdbinit`文件, 如果存在此文件, 则将其中的内容作为GDB指令直接执行, 因此脚本中可以编写任意的GDB指令, 以下是一个示例

```
set disassembly-flavor intel
file a.out
display /x $eax
display /x $ebx
display /x $ecx
display /x $edx
display /i $pc
```

上述脚本启动了当前目录下的a.out文件, 将反汇编格式设为intel格式, 要求每次断点时显示eax, ebx, ecx, edx的值以及下一条指令的值. 

#### 脚本安全问题

由于安全原因, gdb默认不加载`.gdbinit`文件, 如果直接启动gdb会给出相关的警告, 同时提示可以设置允许启动的路径. 因此按照要求,可以执行以下步骤来启用脚本

1. 在用户文件夹下创建`.gdbinit`文件
2. 在其中加入`set auto-load safe-path /`

如果担心安全问题, 也可以把上述指令中的`/` 换成具体的目录名, 从而获得更细致的权限控制.



Vscode配置
------------

和VIM一样, 在C/C++语言上, vscode实际上只是一个文本编辑器, 仅仅提供了基本的语法高亮和代码补全功能, 所以如果需要实现一个IDE的功能, 还需要配置编译器和调试器, 也就是上文介绍的GCC和GDB了.


### 创建项目文件夹
如果需要使用vscode编译和调试项目, 需要使用vscode打开一个文件夹, 否则vscode不会创建相关的配置信息. 


1. 点击调试, 在调试界面中, 选择开始调试
2. 此时vscode会提示选择环境,在linux平台上可以选择C++(GDB/LLDB),即使用GDB作为调试器
3. vscode会创建一个名为launch.json的文件, 此文件即为调试的配置文件
4. 使用如下的配置替换原有配置

``` json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) Launch",
            "type": "cppdbg",
            "request": "launch",
            "preLaunchTask": "make",
            "program": "${workspaceRoot}/compile/lscc",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceRoot}/compile/",
            "environment": [],
            "externalConsole": true,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

和默认的文件相比, 主要有如下的几项修改
1. program属性修改为要调试的程序的程序名, 例如`${workspaceRoot}/a.out`表示要调试的程序是当前项目的目录下的`a.out`程序
2. 添加一个preLaunchTask属性, 使得再执行调试操作前先执行指定的Task(通常是编译任务), 其中preLaunchTask的值需要与后面介绍的Task.json中的Task的label属性名一致


### 编辑tasks.json
- 完成launch.json后, 再次点击开始调试, vscode会提示 `未配置任何任务运行程序` , 此时选择 `配置任务允许程序` , 之后选择`Others`, vscode即可自动生成一个tasks.json
- 以下是**两个**可用的tasks.json, 第一个是简单文件的配置,第二个是较为复杂的文件配置
``` json
{
    "version": "0.1.0",
    "command": "g++",
    "args": ["-g","scan.c","-o","a.out"],   
    "problemMatcher": {
        "owner": "cpp",
        "fileLocation": ["relative", "${workspaceRoot}"],
        "pattern": {
            "regexp": "^(.*):(\\d+):(\\d+):\\s+(warning|error):\\s+(.*)$",
            "file": 1,
            "line": 2,
            "column": 3,
            "severity": 4,
            "message": 5
        }
    }
}
```

``` json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "make",
            "type": "shell",
            "command": "./makeProject",
            "problemMatcher": {
                "owner": "cpp",
                "fileLocation": ["relative", "${workspaceRoot}/compile"],
                "pattern": {
                    "regexp": "^(.*):(\\d+):(\\d+):\\s+(warning|error):\\s+(.*)$",
                    "file": 1,
                    "line": 2,
                    "column": 3,
                    "severity": 4,
                    "message": 5
                }
            }
        }
    ]
}
```
说明:
1. 上述配置文件正确执行以后 ,在编译的过程中,编译器报告的错误会被提取并在vscode的问题页面中显示
2. 其中fileLocation表示编译器报告的文件名的位置关系, 上述示例中,使用的是相对关系,并且认为是直接相对于当前目录. 如果需要编译的文件在工作目录的子文件夹下,需要配置该属性为具体的子文件夹


### 注意事项
1. 如果需要使用断点功能, 则被调试的程序中一定需要包含相关信息,即编译的时候, 需要-g参数
2. vscode默认的调试快捷键是F5, 对于笔记本而言, 那些F键实在是难以精确定位, 所以可以读默认快捷键进行修改. 依次选择文件->首选项->键盘快捷方式, 然后在界面上修改为其他方案即可(例如Ctrl+B)


## 参考文献和扩增阅读
1. [关于C++的说明(英文版)](https://code.visualstudio.com/docs/languages/cpp)
2. [关于C++插件的说明(中文版)](https://blogs.msdn.microsoft.com/c/2016/04/18/visual-studio-code%E7%9A%84cc%E6%89%A9%E5%B1%95%E5%8A%9F%E8%83%BD/)
2. [关于配置信息的说明](http://www.jianshu.com/p/d0350f51e87a)
3. [关于task的官方说明(英文版)](https://code.visualstudio.com/docs/editor/tasks#vscode)
4. [一般配置参考](https://i5ting.github.io/vsc/#110)