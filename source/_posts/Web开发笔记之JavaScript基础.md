---
title: Web开发笔记之JavaScript基础
math: false
date: 2022-07-14 13:02:25
categories: web
tags:
    - web
    - javascript
cover_picture: images/web.jpg
---


由于已经学习过Java和Python等编程语言, 因此本文不是一个面向初学者的笔记. 在笔记中往往只会记录js特有的语言特性, 而与大部分语言相同的共性内容会直接忽略.


基础知识
------------------------

### 网页中使用js的两种方法

1. 直接嵌入html代码
``` html
<script type="text/javascript">
alert("Hello");
</script>
```

2. 从文件导入
``` html
<script src = "/static/js/hello.js"></script>
```


### 基本类型


类型      |解释
---------|---------------------------------------------------
变量     | 使用let声明可变变量, 使用const声明不可变变量
数组     | 使用`[`和`]`, 与大部分语言一样, 且数组中元素可以是任意类型
对象     | 使用大括号包括的键值对
字符串   | `'`和`"`以及反引号都可以定义字符串

``` js
var i = 5;                  // 定义变量
var array = [1, 2, "hello"];  // 定义数组
var p = {                   // 定义对象
    name: "Li", 
    age: 13, 
    tag: ["apple", "book"], 
    info:null
};

var s = `这是
一个
多行字符串`

// 字符串模板
var name = `Li`;
var hello = `Hello ${name}`;
```

### 基础比较

- 类型比较时应始终使用`===`来进行比较, 使用`==`时会进行隐含的类型转换
- `null`, `undefined`, `NaN`, `""`(空字符串)与`0`都视为false, 其他所有值视为true
- 对于既可能返回null又可能返回undefined的情况, 如果不需要严格区分两种情况可直接if判断该值是否为真

### 数组

- 每个数组都默认有一个length属性表示数组的长度, 可以直接修改length使数组长度改变
- 越界写入会自动将数组扩展到指定长度, 扩展的值默使用undefined填充
- 常用函数包括`pop`, `push`, `sort`, `reverse`, `concat`

### 对象

- 可使用`p.name`或`p['name']`的形式访问对应的值
- 使用`in`关键字可以判断一个属性是否属于对象, 无论这个属性是对象原本的属性还是继承的属性
- 使用`hasOwnProperty`方法检查是否是对象原本的属性

### for循环

使用`for...of`循环遍历内置的数据结构


```js
var a = ['A', 'B', 'C'];
var s = new Set(['A', 'B', 'C']);
var m = new Map([[1, 'x'], [2, 'y'], [3, 'z']]);

// 遍历Array
for (var x of a) { 
    console.log(x); // A B C
}

// 遍历Set
for (var x of s) { 
    console.log(x); // A B C
}

// 遍历Map
for (var x of m) { 
    console.log(x[0] + '=' + x[1]); // 1=x 2=y 3=z
}
```

--------------

使用回调函数遍历数据结构

```js
var m = new Map([["Apple", 1], ["Banana", 2]]);
m.forEach(function(value, key, map){
    console.log(`value = ${value}, key = ${key}`);
})
```


### Map与Set类

js的对象可以视为一个Map, 但是因为键只能是字符串因此有所限制, 因此js提供了Map与Set两个类型. Map可以使用set, delete, get, has等函数来实现增删改查等操作. Set使用add与delete实现插入和删除操作.

``` js
var m = new Map([['Apple', 14], ['Banana', 7]]);
var s = new Set([1, 2, 3]);

> m.get('Apple')
14
> m.set("Orange", 3)
Map { 'Apple' => 14, 'Banana' => 7, 'Orange' => 3 }

> s.has(2)
true
> s.has(5)
false
```

函数
--------

JS的函数是一等公民, 可以保持到变量之中, 也支持函数闭包. JS的函数定义具有如下的形式

``` js
function add(a, b) {
    return a+b;
}

// 使用匿名函数定义并保存到变量中
var puls1 = function(a) {
    return a+1;
};
```

> JS函数不强制调用与声明的一致, 多传入的参数会被忽略, 少传入的参数会被置为undefined.


变量作用域
----------

JS内置了一个window变量, 所有的全局变量实际是作为属性保存到了window变量中. 任何文件中声明的全局变量和函数都都存储在window变量之中, 因此不同文件中的同名函数会冲突. 可以通过手动设置名字空间的方式避免冲突.

``` js
let myNameSpace = {};

myNameSpace.foo = function(x) { ... };
```

> 为了避免变量提升导致BUG, 所有变量都应该使用`let`或`const`关键字进行声明.


解构赋值
-----------------

JS支持解构赋值, 能够将一个结构体的值一次性赋予指定的一组变量. 例如
``` js
let [x, [y, z]] = ['hello', ['JavaScript', 'ES6']];

var person = {
    name: '小明', 
    address: {
        city: 'Beijing', 
        zipcode: '100001'
    }
};
var {name, address: {city, zip}} = person;
// name和city赋予相应的值
// 由于zip变量再person中不存在, 因此zip值为undefined
// address是key因此不存在这个变量
```

> 与Python不同, JS中的解构赋值必须使用中括号, 例如交换变量应该写为`[b, a] = [a, b]`



JS操作DOM
-------------

- [原生js获取DOM对象的几种方法](https://blog.csdn.net/qq_33036599/article/details/80660923)
- [DOM对象的一些常用属性和方法](https://www.jianshu.com/p/7a13f33dab48)


### 文本框获得焦点

```js
document.getElementById("test").focus();
```

### 读写剪切板

```js
navigator.clipboard.writeText(this.message).then(() => {
    this.showAlert = true
    setTimeout(() => this.showAlert = false, 500);
})
```

- [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/write)


JS发送请求
-------------

对于较为复杂的应用, 可以使用第三方库(例如Axios)封装JS的HTTP请求, 对于简单的项目, 可以使用如下的函数

```js
var httpRequest = new XMLHttpRequest();
httpRequest.open('POST', '/api/submit', true); //打开连接
httpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");//设置请求头 注：post方式必须设置请求头（在建立连接后设置请求头）
httpRequest.send('url='+URL);
```

- [MDN: XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest)



NPM基本使用
-----------------

### 基本指令

TODO: 常用命令学习



### package.json文件

TODO: 依赖于开发依赖

对于一个给定的版本号`x.y.z`, `^`表示可以更新`y`和`z`到最新版, `~`表示可以更新`z`到最新版


### 使用模块

在启用webpack打包之前, 只能根据位置位置在HTML中引用对应的文件. 启用webpack后, 可以使用ES6的`require`语法或`import`语法

```js
const $ = require('jquery')


```

webpack原理与使用
---------------