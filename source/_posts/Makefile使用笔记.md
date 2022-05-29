---
title: Makefile使用笔记
date: 2017-08-31 20:14:56
tags:
	- Makefile
---



基本规则
-------------------------

一个简单的Makefile文件如下所示:

``` makefile
all:
	gcc f.o codeTest.o -o codeTest.exe
f.o: f.c
	gcc -c f.c
codeTest.o: codeTest.c
	gcc -c codeTest.c
clear:
	rm *.o
```

可以注意到其中的基本结构是

```
target ... : prerequisites ...
	command
	...
	...
```

target是目标标签, 标签可以设置为一个任意的单词, 也可以设置为需要生成的可执行文件或中间文件.  prerequisites是需要生成的文件依赖的文件(或者标签). command是任意的shell指令.

> 注意: command部分必须以`Tab`符号开头, 不可以使用空格. 如果需要注释, 必须顶格书写, 不可以使用`Tab`符号开头




自动推导
-------------------------

由于编译过程一般还是具有一定的规律可循, 因此Makefile有一定的自动推导功能, 从而能够在编写Makefile时减少重复指令. 


### 系统变量

makefile中定义了一些系统变量, 这些变量的值可能在某些规则中被使用, 常见系统变量如下

| 参数 | 含义                     | 参数     | 含义          |
| ---- | ------------------------ | -------- | ------------- |
| CC   | C语言编译器, 默认为cc    | CFLAGS   | C语言编译参数 |
| CXX  | C++语言编译器, 默认为g++ | CXXFLAGS | C++编译器参数 |


### 隐含规则

makefile定义了一系列的隐含规则,这些规则可以帮助我们简化makefile的书写, 例如对于C和C++语言, `.o`文件通常来自于同名的`.c`文件, 因此具有如下的规则

- 对于C语言, 执行`$(CC) –c $(CFLAGS) [.c]`类生成对应的.o文件
- 对于C++语言, 执行`$(CXX) –c $(CXXFLAGS) [.c]`类生成对应的.o文件

> 如果依赖了某个`.o`文件, 但同时又没有指定其生成规则, 则使用上述的隐含规则进行处理

### 自动化变量

makefile提供了几个自动变量用于简化命令的书写, 这些变量是


| 变量 | 含义                                                      |
| ---- | --------------------------------------------------------- |
| `$@` | 表示要生成的目标, 可以记为`aim at`, 即瞄准目标            |
| `$<` | 表示第一个依赖文件, `<`可以记为最左侧的一个文件           |
| `$^` | 表示全部的依赖文件, `^`可以记为笼罩在全部依赖上的一个盖子 |
| `$?` | 表示比目标文件新的依赖文件                                |


例如某makefile中有如下的一段

``` makefile
obj/cn_work.o : sources/cn_work.c 
	gcc  -I  headers   -c 	$<	-o  $@
```

则在此时`$@`等价于`obj/cn_work.o`而`$<`等价于`sources/cn_work.c `


### 模式规则

Makefile可以定义一些模板, 从而实现类似隐含规则的效果, 例如

```makefile
%.o: %.c
	$(CC) –c $(CFLAGS) -o $@ $^
```

就可以实现与makefile内置的隐含规则同等的效果.

> %表示匹配任意非空字符串


### 变量替换

在C语言中往往.o文件和.c文件仅后缀不同,重复书写两次较为繁琐, 可以使用变量替换, 替换规则如下所示

``` makefile
SRCS = fun1.c fun2.c main.c
# 使用变量替换
OBJS=$(SRCS: .c=.o)
```

OBJS将SRC中所有的.c替换为.o, 文件名部分不变





Makefile举例
----------------------

### 编译当前目录下所有文件

```makefile
SRC=$(wildcard *.cpp)
OBJ=$(SRC:.cpp=.o)

WARNFLG = -Wall -Wextra
DEBUG = -g
STD = -std=c++11
CXXFLAGS += $(DEBUG) $(WARNFLG) $(STD)
CC = g++

lscc: $(OBJ) 
	$(CC) $(CXXFLAGS) $(OBJ) -o $@
```



### 使用自动推导

``` makefile
CC=clang
EXEC=printAdd.exe
# 替换规则,foo = $(var:a=b), 将var变量中的a替换成b, 并返回给foo
SRCS = fun1.c fun2.c main.c
# 使用变量替换
OBJS=$(SRCS: .c=.o)

CFLAGS = -Wall -O2 
CFLAGS += -I./  -L./
LFLAGS = -lpthread -lm 


all: fun1.o fun2.o main.o
	$(CC) $(OBJS) -o $(EXEC)
# .o文件自动推导,仅仅指定依赖
# 其他文件完全不出现则自动依赖.c文件
fun2.o: fun2.c fun2.h
clean:
	rm -rf *.o
	rm -rf $(EXEC)
```

### 使用宏

``` makefile
CC=gcc
CFLAGS = -Wall -O2 
CFLAGS += -I./  -L./
LFLAGS = -lpthread -lm 

SRCS = fun1.c \
	fun2.c  \
	main.c

OBJS=$(SRCS:.c=.o)

EXEC=test

all:$(OBJS)
        $(CC) $(CFLAGS) $(OBJS) -o $(EXEC) $(LFLAGS)

clean:
        rm -rf $(EXEC) $(OBJS)
```


### 多目录项目

``` makefile
CC=gcc
HD=-I headers
SC=-c $<
OBJ=-o $@
bin/cn_work : obj/main.o  obj/cn_work.o  obj/fun.o   
	gcc  $^  -o $@  
obj/cn_work.o : sources/cn_work.c 
	$(CC)	$(HD)	$(SC)	$(OBJ)
obj/main.o : 	sources/main.c
	$(CC)	$(HD)	$(SC)	$(OBJ)
obj/fun.o  :	 sources/fun.c
	$(CC)	$(HD)	$(SC)	$(OBJ)
clean：
	rm -f bin/cn_work obj/*.o

```

假设在工作目录下有4个文件夹  分别是 
- sources（源文件） 
- obj （中间文件）
- headers（头文件） 
- bin（目标文件）

对于gcc的编译过程而言, 主要是需要在输入文件和输出文件是指出具体的路径,并且使用-I指定头文件位置


参考文献和扩展阅读
------------------------------

[跟我一起写Makefile](http://wiki.ubuntu.org.cn/%E8%B7%9F%E6%88%91%E4%B8%80%E8%B5%B7%E5%86%99Makefile)