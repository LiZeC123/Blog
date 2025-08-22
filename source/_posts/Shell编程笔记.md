---
title: Shell编程笔记
date: 2019-06-09 14:32:19
categories:
tags:
    - Shell
cover_picture:
---


在使用Linux系统的过程中, 经常会用到shell, 本文介绍shell脚本编程. 通过shell脚本, 能够将一系列固定的指令快速的执行, 在合适的场景下能够大幅度提高开发效率. 本文按照创建一个Shell脚本的顺序, 依次介绍各个环节涉及的知识.

在使用shell脚本时也需要注意, 由于语法设计堪称非常糟糕, 因此shell脚本不适合做复杂逻辑的处理. shell脚本适合简单调用shell指令的场景, 对于较为复杂的操作, 使用Python脚本进行处理可能更有优势. 例如使用shell操作Git通常都比较简单直观, 而对于处理一个YAML文件的正则替换问题, 使用Python更加的简明易懂.



帮助系统
---------------

如果当前存在一个Shell环境, 那么可以通过安装第三方软件`tldr`(Too long, don't read)快速查询指令的常用方法, 例如

```
root@iZ:~# tldr ps
ps
Information about running processes.

 - List all running processes:
   ps aux

 - List all running processes including the full command string:
   ps auxww

```

> 再也不用记指令参数了, 也比当场Google不知道快到那里去了



指定脚本解释器
-----------------------

在Shell脚本的第一行需要指定执行此脚本的解释器, 通常可以指定为
``` shell
#! /bin/bash
```

bash是`Bourne Again Shell`, 是很多Linux系统的默认脚本解释器. 常见的解析器包括`bash`, `sh`, `fish`, `zsh`等. 不同的解释器语法规则存在差异, 因此虽然bash多数情况下是默认的选择, 但为了避免不必要的麻烦, 还是应该在每个脚本开头的位置都指明需要使用的解释器类型.

> 对于很多极简的docker镜像, 其中仅包含`sh`, 此时应该将解释器类型指定为`#! /bin/sh`以便于最大程度的使得脚本可正常执行.



创建变量
----------------


### 变量规则

在Shell中使用`name=value`的格式来创建变量,而且在等号的两端**不能包含空格**, 如果值的部分包含空格, 则需要用引号包裹整个值. 例如
``` bash
$ EXNAME='Hello World'  #等号两端一定不能有空格,否则是执行指令的含义

$ echo $EXNAME
Hello World

$ echo ${EXNAME}
Hello World
```

> 由于Shell使用空格分隔参数, 因此如果等号两端有空格, 就会将变量名当做指令名, 将等号和值当做第二和第三个参数

- 创建变量时不需要`$`符号, 引用变量时加入`$`符号
- 大括号用于区分变量名的边界, 在不产生歧义的时候可以不加, 但建议始终加入大括号

### 特殊变量

变量名  |  含义
-------|-------------------------------------------
`$0`   | 当前脚本的文件名
`$n`   | 传递给脚本或函数的参数
`$#`   | 传递给脚本或函数的参数个数
`$*`   | 传递给脚本或函数的所有参数
`$@`   | 传递给脚本或函数的所有参数
`$?`   | 上个命令的退出状态, 或函数的返回值
`$$`   | 当前 Shell 进程 ID


### 字符串与变量规则

- Shell中的字符串可以使用单引号, 双引号或者不使用引号
- 单引号内的内容**原样输出**, 而双引号中可以使用变量和转义字符

``` bash
$ foo=bar

$ echo "foo is $foo"
foo is bar

$ echo 'foo is $foo'
foo is $foo
```

> 引号中无法使用`~`表示当前路径, 应该使用`$HOME`变量代替

-----------------------

### 结果作为变量

Shell中可以将一个指令的返回结果作为另一个指令的参数, 只需要将待执行的指令使用`$()`包裹即可, 例如

```bash
appId=$(lsof -i:4567 | awk '$1 == "python3"  {print $2}')
```

> 将一个指令使用反引号包裹, 也具有同样的效果, 不过我觉得这样不够明显, 容易看错



Shell运算符
-----------------

由于Shell的语法限制, Shell的运算符非常的反常规, 因此就不逐一记录了, 以后用到了在来查下面的链接


- [Shell 运算符：Shell 算数运算符、关系运算符、布尔运算符、字符串运算符等](https://wiki.jikexueyuan.com/project/shell-tutorial/shell-operator.html)



流程控制语句
--------------------

### if-else

```bash
if [ expression 1 ]
then
   Statement(s) to be executed if expression 1 is true
elif [ expression 2 ]
then
   Statement(s) to be executed if expression 2 is true
elif [ expression 3 ]
then
   Statement(s) to be executed if expression 3 is true
else
   Statement(s) to be executed if no expression is true
fi
```

注意
1. 由于Shell的设计, `[`是一个指令, 因此`[`两端都需要有空格, 否则会解析错误
2. 表达式部分直接写变量等价于判断此变量是否为空



函数
---------------

函数的格式如下所示

```bash
function <funname> () {
    action;
    ...
}
```

其中关键字`function`以及函数名后的`()`均可以省略. 可以向函数传递参数, 在函数内部使用`$1`等变量访问参数, 调用函数的方式与调用命令的方式相同, 例如

``` bash
funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}

funWithParam 1 2 3 4 5 6 7 8 9 34 73
```

Shell中的函数与其他编程语言中的函数概念不同, Shell中的函数更加类似于一段代码块. 因此并不能在Shell的函数中返回结果. 对于需要返回结果的场景, 通常直接使用全局变量.



重定向与管道
-------------

重定向和管道是我认为最具有Unix哲学的东西, 它们实际上是提供了一种组合的能力, 从而能将各类工具根据需要进行组合. 常见的重定向与管道命令以及一些相关的指令如下表所示:


| 符号/操作                      | 名称             | 功能简介 |
| :---------------------------- | :------------- | :----------------------------- |
| `command > file`              | 输出重定向       | 将 stdout 覆盖写入文件 |
| `command >> file`             | 追加输出重定向   | 将 stdout 追加到文件 |
| `command < file`              | 输入重定向       | 从文件获取 stdin |
| `command1`&#124;`command2`    | 管道            | 将 command1 的 stdout 作为 command2 的 stdin |
| `command 2> file`             | 错误重定向      | 将 stderr 覆盖写入文件 |
| `command &> file`             | 合并重定向      | 将 stdout 和 stderr 都重定向到文件 |
| `command` &#124;&`command2`   | 错误管道        | 将 stdout 和 stderr 都通过管道传递 |
| `command >> file 2>&1`        | 经典合并追加    | 将 stdout 和 stderr 都追加到文件 |
| `<< EOF`                      | Here Document | 多行文本作为输入 |
| `/dev/null`                   | 空设备         | 丢弃所有写入的数据 |
| `$(command)`                  | 命令替换        | 将命令的输出结果作为参数 |
| `<(command)`                  | 进程替换        | 将命令输出作为临时文件使用 |
| `&&`                          | 逻辑与          | 前一个命令成功才执行下一个 |
| `\|\|`                        | 逻辑或          | 前一个命令失败才执行下一个 |



### 重定向

总所周知, 在unix类的系统中, 每个程序会默认开启三个文件:

文件描述符  | 含义                | 默认实现
----------|--------------------|---------
0         | 标准输入(stdin)     | 从键盘读取
1         | 标准输出(stdout)    | 输出到屏幕
2         | 标准错误输出(stderr) | 输出到屏幕

重定向符号实际上就是改变这些文件的指向. 具体来说, 操作系统提供了`dup2`系统调用, 可以修改文件描述符的指向. 在shell启动命令的进程前, 可通过系统调用将这些标准输入输出重新指向特定的文件, 从而实现重定向.



### 管道操作符

管道操作符`|`非常的有意思, 它的实现并不是先执行`command1`然后将输出作为`command2`的输入执行`command2`, 而是启动两个进程同时执行`command1`和`command2`, 并且将两者的输出和输入映射到同一个文件. 能体现这个实现的一个典型场景是使用`grep`指令查找进程, 例如

```bash
> ps aux | grep xx
lizec     23605   0.0  0.0 410210368   1360 s009  S+    7:18PM   0:00.00 grep xx
```

在输出的进程列表中可以看到`grep`命令本身, 这正好说明了`ps`指令在输出进程列表时, `grep`指令的进程已经存在了.

-----

操作系统也提供了`pipe`系统调用, 此调用返回两个文件描述符, 分别表示管道的输入端和输出端. shell将两个子进程的标准输出和标准输入映射到两个文件描述符即可实现管道的效果.

> 这也体现了为什么shell是`外壳`了, 功能都是内核kernel实现的, shell提供了一层封装.



### 多行输入

`<< EOF`可实现多行输入, 例如

```bash
cat << EOF
This is line 1.
This is line 2.
All this text will be fed into the cat command.
EOF
# 常用于脚本中生成配置文件或向交互式命令输入多行内容
```

### 命令替换与进程替换

`$(command)`执行 `command` 并将其**标准输出**的结果替换到当前命令行中

```bash
# 将 date 命令的输出作为参数传递给 echo
echo "The time is $(date)"

# 将当前目录的文件列表作为grep的输入
grep "pattern" $(find . -name "*.txt")
```

`<(command)`使命令的输出(或输入)表现得像一个临时文件

```bash
# 比较两个命令输出的差异
diff <(ls dir1) <(ls dir2)

# 将一个命令的输出作为文件传递给另一个期望文件参数的命令
wc -l <(ls -l)
```


### Tee 分叉

`tee` 命令通常与管道连用, 将数据流传给下一个命令，又同时保存到一个文件中(像水管的一个 T 型三通接头)


```bash
# 将 ls 的输出既显示在屏幕上，又保存到 filelist.txt 中
ls -l | tee filelist.txt

# -a 选项表示追加模式
ls -l | tee -a filelist.txt
```



设置可执行权限
-----------------------

在运行脚本前需要对其赋予可执行权限, 例如对于脚本`shell.sh`, 可以执行如下指令授予其可执行权限.

```bash
$ chmod +x shell.sh
```

> 对于图像界面可以通过右键设置来赋予可执行权限



添加到搜索目录
------------------

TODO: 不同类型的shell添加方式

此步骤不是必须的, 但是如果希望在任意位置都可以执行此脚本, 则可以将脚本放置在一个PATH变量包含的路径之中, 可以使用`echo $PATH`查看系统全部的搜索路径, 例如
	
```bash
lizec@ideapad:~$ echo $PATH
/home/lizec/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

将脚本添加到上面的任意一个目录中即可


### bash新增PATH路径

如果想要把某个目录添加到PATH变量之中, 可以直接修改`$PATH`变量的值, 例如

```bash
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc  
source ~/.bashrc  
```


### zsh新增PATH路径

以新增Go语言的bin目录到PATH路径为例, 打开`~/.zshrc`文件, 新增如下内容

```bash
# Go PATH Configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

执行`source`指令使操作立即生效或者重新打开终端


### fish新增PATH路径

如果使用的是fish, 则可以打开`~/.config/fish/config.fish`添加如下的内容

```sh
set -gx PATH $PATH /usr/local/go/bin
```

然后执行如下指令重新加载配置

```sh
source ~/.config/fish/config.fish
```


更多配置可以查看下面的链接

- [【Ubuntu】Ubuntu设置和查看环境变量](https://blog.csdn.net/White_Idiot/article/details/78253004)




Bash常用快捷功能
--------------------


| 指令     | 解释                            | 说明                                      |
| -------- | ------------------------------- | ----------------------------------------- |
| `cd -`   | 回到上一次停留的目录            |
| `!<num>` | 快速执行history里的某个指定命令 | `!743`                                    |
| `!!`     | 指代上一个命令                  | `sudo !!`  以管理员权限重新执行上一条指令 |




Shell常用判断语句
------------------

### 判断变量是否为空

```bash
para1=  
if [ ! $para1 ]; then  
  echo "IS NULL"  
else  
  echo "NOT NULL"  
fi 
```

### 判断文件和目录是否存在

``` bash
#如果文件夹不存在, 创建文件夹
if [ ! -d "/myfolder" ]; then
  mkdir /myfolder
fi

# -x 参数判断 $folder 是否存在并且是否具有可执行权限
if [ ! -x "$folder"]; then
  mkdir "$folder"
fi

# -d 参数判断 $folder 是否存在
if [ ! -d "$folder"]; then
  mkdir "$folder"
fi

# -f 参数判断 $file 是否存在
if [ ! -f "$file" ]; then
  touch "$file"
fi
```

- [shell bash判断文件或文件夹是否存在](https://www.cnblogs.com/emanlee/p/3583769.html)

> shell写逻辑是真的太烂了, 这种东西让AI写就行了.


Shell其他常见功能
---------------------

以下是一些常见的功能的Shell实例.

### 向文件写入多行数据

``` bash
# 创建 hook 钩子函数
cat>~/repos/"${ProjectName}.git"/hooks/post-receive<<EOF
#!/bin/sh

# 拉取最新代码
git --work-tree=/home/git/projects/"${ProjectName}" --git-dir=/home/git/repos/"${ProjectName}.git" checkout -f

# 执行项目自定义更新重启操作
cd ~/projects/"${ProjectName}"
./service.sh restart
EOF
```

`cat>`表示覆盖写入文件, `~/repos/"${ProjectName}.git"/hooks/post-receive`是文件名, 文件名中可以使用变量, `<<EOF`表示结束符为`EOF`.

中间需要写入的的内容也可以使用变量.

- [shell脚本, 将多行内容写入文件中](https://blog.csdn.net/d1240673769/article/details/103788624)



参考资料
----------


- [Shell编程基础 - Ubuntu Wiki](https://wiki.ubuntu.org.cn/Shell%E7%BC%96%E7%A8%8B%E5%9F%BA%E7%A1%80)