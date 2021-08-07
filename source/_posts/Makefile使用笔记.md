---
title: Makefile使用笔记
date: 2017-08-31 20:14:56
tags:
	- Makefile
---



基本规则
-------------------------
### 基本规则
```
target ... : prerequisites ...
	command
	...
	...
```

- target可以是一个目标文件, 例如需要生成的可执行文件或中间文件
- target也可以是一个标签
- prerequisites是需要生成的文件依赖的文件
- command是任意的shell指令

### Makefile举例
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

隐含规则和默认宏
-------------------------

### 隐含规则
makefile定义了一系列的隐含规则,这些规则可以帮助我们简化makefile的书写, 常见的隐含规则如下
1. .o文件指定依赖以后,默认执行`$(CC) –c $(CFLAGS) [.c]`类生成对应的.o文件
2. 如果完全不提及.o文件依赖和生成规则, 则自动使用相应的.c文件编译


### 宏
makefile使用了一些默认的宏,这些宏可能会用与隐含规则,常见的宏如下
1. CC 编译器类型
2. CFLAGS 编译参数

### 变量替换
在C语言中往往.o文件和.c文件仅后缀不同,重复书写两次较为繁琐, 可以使用变量替换, 替换规则如下所示
``` makefile
SRCS = fun1.c fun2.c main.c
# 使用变量替换
OBJS=$(SRCS: .c=.o)
```
OBJS将SRC中所有的.c替换为.o, 文件名部分不变


### Makefile举例

#### 使用自动推导演示
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

#### 使用宏演示
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


多目录下makefile构成方法
-----------------------------

### 多目录项目一般结构
假设在工作目录下有4个文件夹  分别是 
- sources（源文件） 
- obj （中间文件）
- headers（头文件） 
- bin（目标文件）

对于gcc的编译过程而言, 主要是需要在输入文件和输出文件是指出具体的路径,并且使用-I指定头文件位置

### 自动变量
makefile提供了几个自动变量用于简化命令的书写, 这些变量是
1. `$@`     表示要生成的目标
2. `$^`     表示全部的依赖文件
3. `$<`     表示第一个依赖文件

例如某makefile中有如下的一段
``` makefile
obj/cn_work.o : sources/cn_work.c 
	gcc  -I  headers   -c 	$<	-o  $@
```
则在此时`$@`等价于`obj/cn_work.o`而`$<`等价于`sources/cn_work.c `

### Makefile举例
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

## 参考文献和扩展阅读
[跟我一起写Makefile](http://wiki.ubuntu.org.cn/%E8%B7%9F%E6%88%91%E4%B8%80%E8%B5%B7%E5%86%99Makefile)