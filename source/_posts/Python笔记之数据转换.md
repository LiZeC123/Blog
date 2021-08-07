---
title: Python笔记之数据转换
date: 2020-03-12 15:35:11
categories: Python笔记
tags:
    - Python
    - Excel
cover_picture: images/python.jpg
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->


本文介绍Python数据转换相关的库, 主要包括如何使用Python读写Excel文件和数据库. 本文中, 读取Excel的库为`openpyxl`


打开和保存Excel文件
------------------

``` py
from openpyxl import Workbook
wb1 = Workbook()                    # 直接在内存中创建一个Excel文件
wb2 = load_workbook('test.xlsx')    # 读取一个已经存在的Excel文件
```

无论是哪种方法创建的Excel, 其中至少包含一个Sheet. 可以使用如下的方法获得默认Sheet

```py
ws = wb.active
ws = wb['Sheet1']
```

最终, 可以调用`wb.save(<name>)`保存文件.


访问Excel的数据
---------------------

`openpyxl`充分利用了Python的切片功能, 因此可以非常简单的获得Excel中某个区域的数据, 例如

要求        | 示例          | 要求       | 示例
-----------|---------------|------------|-----------------------
获得某一行  | `ws[10]`      | 获得某一列  | `ws['C']`
获得某些行  | `ws[5:10]`    | 获得某些列  | `ws['A:C']`
获得任意数据| `ws[A1:C5]`


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


按行按列遍历
---------------

`openpyxl`提供了两个迭代器`ws.iter_rows`, `ws.iter_cols`和两个属性`ws.rows`, `ws,columns`, 可以分别按行和按列遍历整个表格, 例如

```py
>>> for row in ws.iter_rows(min_row=1, max_col=3, max_row=2):
...    for cell in row:
...        print(cell)
<Cell Sheet1.A1>
<Cell Sheet1.B1>
<Cell Sheet1.C1>
<Cell Sheet1.A2>
<Cell Sheet1.B2>
<Cell Sheet1.C2>
```

如果只需要值(默认返回Cell, 需要手动取值), 可以对迭代器指定一个参数`values_only=True`, 或者直接遍历属性`ws.values`


添加数据
---------------------


如果是规则的按行添加数据, 可以直接使用`ws.append`在表格的末尾加入一行数据. 例如

```py
ws.append([1,2,3])
```

也可以直接对Cell进行赋值来添加数据.


其他事项
---------------------

1. 如果只是写入Excel, 那么可以考虑用pandas进行处理, 然后直接用其API保存为Excel文件

