---
title: Web开发笔记之HTML基础
math: false
date: 2022-07-14 13:00:50
categories: Web开发笔记
tags:
    - Web
    - HTML
cover_picture: images/web.jpg
---



HTML基本结构
------------------------

一个基本的HTML文件通常具有如下的结构

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
</body>
</html>
```


`<meta charset="UTF-8">`指定了当前的文件编码为UTF-8编码. 显然将编码指定为这个值时, 该文件本身也应该使用UTF-8编码. `<meta http-equiv="X-UA-Compatible" content="IE=edge">`是关于IE浏览器的兼容性设置, 如果不考虑IE的兼容性, 可以不写. `<meta name="viewport" content="width=device-width, initial-scale=1.0">`是网页兼容移动端的重要设置, 启用该设置后浏览器才会按照移动端的规则对页面进行渲染, 否则无论页面是否适配移动端, 都会按照PC端的风格进行渲染.

- [HTML Meta中添加X-UA-Compatible和IE=Edge,chrome=1有什么作用？](https://blog.csdn.net/u012118993/article/details/57083804)
- [meta name="viewport" content="width=device-width,initial-scale=1.0" 究竟什么意思](https://blog.csdn.net/qq_42039281/article/details/83281074)



基础标签
---------------

使用`h1`, `h2`, `h3`, `h4`, `h5`, `h6`定义各级标题. 使用`p`标签定义段落文字. 使用`br`(break)标签强制进行换行. `div`标签和`span`标签不具备语义, 主要用于分割页面中的元素


文本格式化标签
---------------

| 标签            | 含义     | 标签       | 含义     |
| --------------- | -------- | ---------- | -------- |
| `strong` 或 `b` | 加粗文字 | `em`或`i`  | 倾斜文字 |
| `del`或`s`      | 删除线   | `ins`或`u` | 下划线   |


图片
---------

```html
<img src="图片地址" alt="图片加载失败时显示的文字" title="鼠标在图片上显示的文字" width="300" height="" />
```

> 一般仅设置宽度或仅设置高度, 使得图片能够保持比例缩放


超链接
----------------



```html
<a href="跳转目标" target="弹出方式">文字或图片</a>
```

href是跳转地址, 如果是外部链接必须使用完整的URL, 否则默认连接当前服务器的相应位置. target表示链接的打开方式, 通常有如下的取值:

| 参数名 | 效果                          |
| ------ | ----------------------------- |
| _self  | 在当前窗体打开链接,此为默认值 |
| _blank | 在新窗口中打开链接            |



表格
---------

表格基本结构如下所示:

```html
<table>
    <tr>
        <th>表头文字</th>
    </tr>
    <tr>
        <td>单元格文字</td>
    </tr>

</table>
```

`table`表示一个表格, `tr`表示表格中的一行, 即`table row`, `th`表示表头单元格,  `td`表示表格中的普通单元格.

> 表格默认没有分割线且左对齐, 通常使用CSS增强表格的显示



列表
------------

列表的主要作用是页面的布局, 通常规整的结构都采取列表结构. 无序列表使用`ul`标签, 有序列表使用`ol`标签, 自定义列表可以使用`dl`标签

```html
<ul>
    <li>这是第一项</li>
    <li>这是第二项</li>
</ul>

<ol>
    <li>这是第一项</li>
    <li>这是第二项</li>
</ol>

<dl>
    <dt>表头</dt>
    <dd>解释1</dd>
    <dd>解释2</dd>
</dl>
```



表单
--------------


### 表单域

使用`form`定义一个表单域, 例如

```html
<form method="post" action="save.php">
    <label for="username">用户名:</label>
    <input type="text"  name="username" id="username" value="admit" />
    <label for="pass">密码:</label>
    <input type="password"  name="pass" id="pass" value="password" />    
    <input type="submit" value="确定"  name="submit" />
    <input type="reset" value="重置" name="reset" />
</form>
```


### 基本文本框

使用`input`定义一个文本框

```html
<input type="text"  name="username" id="username" value="admit" />
```

> name属性用于后台程序根据名称提取值, value属性用于表示此项被选中时的值(对于文本框则是初始文字)

type常见的取值为:

| type取值 | 含义     | type取值 | 含义     |
| -------- | -------- | -------- | -------- |
| text     | 文本框   | password | 密码框   |
| radio    | 单选按钮 | checkbox | 复选框   |
| submit   | 提交按钮 | reset    | 清除按钮 |
| button   | 普通按钮 | file     | 文件上传 |

单选框和复选框的的同一组应该设置为同样的name, 如果需要预选选中, 则设置checked属性. 例如:

```html
请选择您的性别</br>
<input type="radio" name="sex" value="man">男
<input type="radio" name="sex" value="woman">女
<input type="radio" name="sex" value="None" checked="checked">保密</br>
```

submit类型和reset类型默认会进行操作, 而button类型不绑定任何事件, 需要额外的JS代码进行处理.


### label标签

lable标签和对应的组件绑定, 当点击到label标签时, 相当于点击到对应的组件, 从而避免组件太小难以点击的问题. label的for属性为需要绑定的组件的**id**

### 下拉选择框

```html
<select name = "selectSex">
    <option value="man">男</option>
    <option value="woman">女</option>
    <option value="None" selected="selected">保密</option>
</select>
```


### 文本域

```html
<textarea cols="100" rows="5">默认内容</textarea>
```


HTML5新增语义标签
-------------------

HTML新增了如下的一些常用的标签

- `<header>`: 头部标签
- `<nav>`: 导航标签
- `<article>`: 内容标签
- `<section>`: 定义文档某个区域
- `<aside>`: 侧边栏标签
- `<footer>`: 尾部标签

这些标签本身不通过额外的样式, 其主要用于提供语义. 在使用CSS定义他们的样式的时候, 因为他们有特殊的名字, 因此此时可以直接使用名称选择器, 而不用再额外定义类名.

HTML5新增多媒体标签
--------------------

使用`<video>`标签在HTML中引入视频文件. 大部分浏览器均已支持MP4格式的视频文件
使用`<audio>`标签在HTML中引入音频文件. 大部分浏览器均已支持MP3格式的视频文件

> Chrome禁用了视频和音频的自动播放, 视频设置为静音时可自动播放, 而音频需要通过JS启用自动播放.


HTML5新增input标签
---------------------

HTML5新增了一些input的type属性, 从而对输入框提供更多语义, 常见的新增类型有`email`,`url`,`date`,`time`,`tel`,`search`,`color`等. 这些类型的组件会自动提供一些校验能力, 例如`email`类型会校验输入必须是邮箱格式.

-----------------------------------

HTML5新增了一些表单属性, 包括

属性        | 取值      | 说明
------------|----------|------------
required    | required | 限制表单不允许为空
placeholder | 提示文本  | 设置表单空占位符
autofocus   | autofocus | 使表单自动获取焦点(例如搜索栏)
autocomplete| on/off    | 浏览器根据历史输入情况提供自动补全, 默认为开
multiple    | multiple  | 可以选择多文件提交

