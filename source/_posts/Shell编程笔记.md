---
title: Shell编程笔记
date: 2019-06-09 14:32:19
categories:
tags:
    - Shell
cover_picture:
---



在使用Linux系统的过程中, 经常会用到shell, 本文介绍shell编程. 本文按照创建一个Shell脚本的顺序,依次介绍各个环节涉及的知识.



帮助系统
---------------

如果当前存在一个Shell环境, 那么获得一个指令的用法的第一方案是使用man指令进行查询, 绝对能比任何其他搜索方法更快的获得搜索结果.

如果可以安装第三方软件, 那么首先安装`tldr`(Too long, don't read). 此指令可以给出各种常见的指令组合的文档, 例如

```
root@iZ:~# tldr ps
ps
Information about running processes.

 - List all running processes:
   ps aux

 - List all running processes including the full command string:
   ps auxww

 - Search for a process that matches a string:
   ps aux | grep {{string}}

 - List all processes of the current user in extra full format:
   ps --user $(id -u) -F

 - List all processes of the current user as a tree:
   ps --user $(id -u) f

 - Get the parent pid of a process:
   ps -o ppid= -p {{pid}}
```


指定脚本解释器
-----------------------

在Shell脚本的第一行需要指定执行此脚本的解释器, 通常可以指定为
``` shell
#! /bin/bash
```

bash是`Bourne Again Shell`, 是很多Linux系统的默认脚本解释器. 常见的解析器包括`bash`, `sh`, `fish`, `zsh`等. 不同的解释器语法规则存在差异, 因此虽然bash多数情况下是默认的选择, 但为了避免不必要的麻烦, 还是应该在每个脚本开头的位置都指明需要使用的解释器类型.

> 对于很多极简的docker镜像, 其中甚至仅包含`sh`, 此时最好将解释器类型指定为`#! /bin/sh`


创建变量
----------------


### 变量规则

在Shell中使用`name=value`的格式来创建变量,而且在等号的两端**不能包含空格**,例如
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


函数
---------------

函数的格式如下所示

```bash
function <funname> () {
    action;
    ...
    return <int>
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



设置可执行权限
-----------------------

在运行脚本前需要对其赋予可执行权限, 例如对于脚本`shell.sh`, 可以执行如下指令授予其可执行权限.

```
$ chmod +x shell.sh
```

> 对于图像界面可以通过右键设置来赋予可执行权限


添加到搜索目录
------------------

此步骤不是必须的, 但是如果希望在任意位置都可以执行此脚本, 则可以将脚本放置在一个PATH变量包含的路径之中, 可以使用`echo $PATH`查看系统全部的搜索路径, 例如
	
```
lizec@ideapad:~$ echo $PATH
/home/lizec/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

将脚本添加到上面的任意一个目录中即可

------------------

如果想要把某个目录添加到PATH变量之中, 可以直接修改`$PATH`变量的值, 例如

```
export PATH=$PATH:/home/lizec/.local/bin
```

但这一指令只会对当前终端生效, 如果需要持久生效, 可以将这一指令写入`~/.bashrc`文件. 更多配置可以查看下面的链接

- [【Ubuntu】Ubuntu设置和查看环境变量](https://blog.csdn.net/White_Idiot/article/details/78253004)


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



