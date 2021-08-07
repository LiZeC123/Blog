---
title: 数学工具之LINGO使用笔记
date: 2020-05-10 10:15:08
categories:
tags:
cover_picture: images/LINGO.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



基本模型
---------------

如果需要求解的问题比较简单, 可以直接使用数学表示, 例如

```
min=2*x1+3*x2;

x1+x2>=350;
x1>=100;
2*x1+x2<=600;
```

注意:
- 第一行是目标函数, 其余为约束条件
- 约束条件默认取等号
- 变量默认大于零


程序结构
------------------

### 小型模型

一个标准的程序示例如下所示:

```
model:
title: 标准程序示例;
! 这是注释;
[opt] min=2*x1+3*x2;
[st1] x1+x2>=350;
[st2] x1>=100;
[st3] 2*x1+x2<=600;
@gin(x1);@gin(x2);
end
```

注意:
- 所有语句都用分号结尾, 包括注释
- 使用title来指定标题
- 使用中括号对行命名, 在分析报告中使用此名称替代行号对应的数字


### 大型模型

大型模型采用分段的结构, 将变量, 数据和模型分离, 整体结构类似于如下的结构

```
model:
title: 6发点8收点运输问题;
sets:
 warehouses/wh1..wh6/: capacity;
 vendors/v1..v8/: demand;
 links(warehouses,vendors): cost, volume;
endsets
!目标函数;
 min=@sum(links: cost*volume);
!需求约束;
 @for(vendors(J):
 @sum(warehouses(I): volume(I,J))=demand(J));
!产量约束;
 @for(warehouses(I):
 @sum(vendors(J): volume(I,J))<=capacity(I));
!这里是数据;
data:
 capacity=60 55 51 43 41 52;
 demand=35 37 22 32 41 32 43 38;
 cost=6 2 6 7 4 2 9 5
 4 9 5 3 8 5 8 2
 5 2 1 9 7 4 3 3
 7 6 7 3 9 2 7 1
 2 3 9 5 7 2 6 5
 5 5 2 2 8 1 4 3;
enddata
end
```



定义变量
-------------

### 集

对于有大量变量的优化问题, 逐一定义变量是一件非常麻烦的事情. 此时可以使用集的概念来批量的定义变量. 集是一组成员的集合, 而每个成员又可以具有若干的属性, 因此集的定义表示为

```
set:
<setname>[/<member_list>/][:<attribute_list>];
endsets
```

成员名称可以使用逗号分割的方式逐一制定, 也可以按照上面的例子, 使用缩写表示来自动定义多个变量. 隐式成员格式有

格式                    | 示例               | 成员
:-----------------------|:------------------|:-----------------------------------------
1..n                    | 1..5              | 1,2,3,4,5
StringM..StringN        | Car2..Car5        | Car2, Car3, Car4, Car5
DayM..DayN              | Mon..Fri          | Mon, Tue, Wed, Thu, Fri
MonthM..MonthN          | Oct..Jan          | Oct, Nov, Dec, Jan
MonthYearM..MonthYearN  | Oct2001..Jan2002  | Oct2001, Nov2001, Dec2001, Jan2002


### 派生集

派生集是在其他集合的基础上构建的新集合, 默认情况下, 其成员为所有继承的集合的组合, 派生集语法为

```
<setname>(<parent_set_list>)[/<member_list>/][:<attribute_list>];
```

例如分别定义三个集合, 则基于这三个集合的派生集合可以定义为如下的形式

```
sets:
 product/A B/;
 machine/M N/;
 week/1..2/;
 allowed(product,machine,week):x;
endsets
```

allowed拥有2x2x2=8个成员, 且每个成员都具有x属性. 这种默认包含所有成员的组合的集合称为**稠密集**, 如果希望去掉部分不需要的元素, 可以使用LINGO的逻辑表达式, 例如


### 属性列

在data部分指定数据, 可以依据某一个属性来指定, 也可以依据对象来指定.

```
sets:
 set1/A,B,C/: X,Y;
endsets
data:
 X=1,2,3;
 Y=4,5,6;
enddata
```

```
sets:
 set1/A,B,C/: X,Y;
endsets
data:
 X,Y=1 4
 2 5
 3 6;
enddata
```

将所有成员的属性指定为一个值
```
sets:
 days /MO,TU,WE,TH,FR,SA,SU/:needs;
endsets
data:
 needs = 20;
enddata
```


部分指定

```
sets:
 years/1..5/: capacity;
endsets
data:
 capacity = ,34,20,,;
enddata
```



函数
----------------

### 数学函数

LINGO提供了大量的函数, 一般以@开头, 例如`@sin`,`@abs`,`@log`(自然对数)等等. 除去这些常见的数学函数以外, LINGO还定义了如下的一些重要的数学函数

|  函数  | 作用                  |  函数     | 作用
|--------|----------------------|-----------|------------------------
|`@sign` | 符号函数              | `@floor`  | 取整
|`@smax` | 返回一组数据的最大值   | `@smin`   | 返回一组数的最小值

使用示例:

```
model:
sets:
 object/1..3/: f;
endsets
data:
 a, b = 3, 4; !两个直角边长, 修改很方便;
enddata
 f(1) = a * @sin(x);
 f(2) = b * @cos(x);
 f(3) = a * @cos(x) + b * @sin(x);
 min = @smax(f(1),f(2),f(3));
 @bnd(0,x,1.57);
end
```


### 变量定界函数

|  函数        | 作用                    |  函数      | 作用
|--------------|------------------------|------------|------------------------
|`@bin(x)`     | 限制为0-1变量           | `@gin(x)`  | 限制为整数
|`@bnd(L,x,U)` | 限制取值范围在L和U之间   | `@free(x)` | 取消变量默认大于零的限制

变量定界函数在约束条件部分单独对变量执行即可. 例如

```
sets:
a/1..100/:x;
b/1..100/:y;
endsets

@for(b(j):@gin(y(j)));  
@for(a(i):@bin(x(i))); 
```


### 集循环函数

```
@<function>(<setname>[(<set_index_list>)[|<conditional_qualifier>]]:<expression_list>);
```

从上面的格式可以注意到:
- 集合名称必须指定
- 索引可以省略
- 过滤条件可以省略
- 表达式部分必须指定

因此如果是针对整个集合的操作, 显然可以省略索引和过滤条件, 例如某个集合之和小于90可以表示为

```
model:
sets:
 s/1..100/:x;
endsets
@sum(s:x)<90;
```





逻辑表达式可以表达分段函数




