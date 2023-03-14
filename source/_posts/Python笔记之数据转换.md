---
title: Python笔记之数据转换
date: 2020-03-12 15:35:11
categories: Python笔记
tags:
    - Python
    - Excel
cover_picture: images/python.jpg
---



本文介绍Python数据转换相关的库, 主要包括如何使用Python读写Excel文件(使用`openpyxl`库)和数据库. 写入Excel文件的好处是便于后续的处理和传播, 同时相较于操作CSV文件, 直接操作Excel文件可以避免特殊字符产生的问题.



读取文件
-----------------


```py
from openpyxl import Workbook, load_workbook
wb = load_workbook('test.xlsx')    # 读取一个已经存在的Excel文件

# 获得默认的Sheet, 每个Excel都默认包含Sheet1
ws = wb.active
# 或者手动指定sheet名称
ws = wb['Sheet1']

# 遍历表格中指定区域的内容, 行列均从1开始计数
for row in ws.iter_rows(min_row=1, max_row=2,  min_col=1, max_col=3):
    for cell in row:
        print(cell)
```

`openpyxl`提供了两个迭代器`ws.iter_rows`, `ws.iter_cols`和两个属性`ws.rows`, `ws,columns`, 可以分别按行和按列遍历整个表格

如果只需要值(默认返回Cell, 需要手动取值), 可以对迭代器指定一个参数`values_only=True`, 或者直接遍历属性`ws.values`


写入数据
-----------------

```py
from openpyxl import Workbook
wb = Workbook()                    # 直接在内存中创建一个Excel文件
# 获得默认的Sheet, 每个Excel都默认包含Sheet1
ws = wb.active
# 创建新的Sheet并插入到sheet列表的开头
ws = wb.create_sheet("Mysheet", 0) 

# 按行在末尾添加数据
ws.append([1,2,3])

# 直接对指定的位置写入数据
ws['A10'] = 233

# 保存文件
wb.save("act.xlsx")
```


其他操作
------------------

```py
#删除Sheet
del wb[name]
```



访问Excel的数据
---------------------

`openpyxl`充分利用了Python的切片功能, 因此可以非常简单的获得Excel中某个区域的数据, 例如

要求        | 示例          | 要求       | 示例
-----------|---------------|------------|-----------------------
获得某一行  | `ws['10']`      | 获得某一列  | `ws['C']`
获得某些行  | `ws['5:10']`    | 获得某些列  | `ws['A:C']`
获得任意数据| `ws['A1:C5']`


无论是获得一个矩形区域的数据, 还是单行数据, 或者一个单元的数据, 使用这种风格获得的数据的返回值都是一个二维的Tuple. 例如

```py
((<Cell 'Sheet1'.A1>,),
 (<Cell 'Sheet1'.A2>,),
 (<Cell 'Sheet1'.A3>,))
```

因此可以考虑使用如下的方式将二维数组变为一维数组.

```py
import operator
from functools import reduce
a = [[1,2,3], [4,6], [7,8,9,8]]
print(reduce(operator.add, a))
[1, 2, 3, 4, 6, 7, 8, 9, 8]
```

如果是取出一行或者一列, 那么直接取出返回值的第0个元素即可.



参考资料
---------------

- [官方教程](https://openpyxl.readthedocs.io/en/stable/tutorial.html)



