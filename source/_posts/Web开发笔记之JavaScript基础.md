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


### 基本类型


类型      |解释
---------|---------------------------------------------------
变量     | 使用`let`声明可变变量, 使用`const`声明常量, 不要使用`var`
数组     | 使用`[`和`]`, 与大部分语言一样, 且数组中元素可以是任意类型
对象     | 使用大括号包括的键值对
字符串   | `'`和`"`以及反引号都可以定义字符串
扩展运算符| 使用`...`展开一个对象的全部属性

``` js
let i = 5;                  // 定义变量
const array = [1, 2, "hello"];  // 定义数组
const p = {                   // 定义对象
    name: "Li", 
    age: 13, 
    tag: ["apple", "book"], 
    info:null
};

let s = `这是
一个
多行字符串`

// 字符串模板
let name = `Li`;
let hello = `Hello ${name}`;

// 扩展运算符
let z = { a: 3, b: 4 };
let n = { ...z };
```

> 为了避免变量提升导致BUG, 所有变量都应该使用`let`或`const`关键字进行声明.

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
for (var [key, value] of m) { 
    console.log(key + '=' + value); // 1=x 2=y 3=z
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

### 对象

ES6语法支持简化对象的定义, 如果直接给一个变量, 则属性名为变量的名字, 属性值为变量的值

```js
const foo = 'bar';
const baz = {foo};
baz // {foo: "bar"}

// 等同于
const baz = {foo: foo};
```

对于方法, 也可以同样的简写

```js
const o = {
  method() {
    return "Hello!";
  }
};

// 等同于

const o = {
  method: function() {
    return "Hello!";
  }
};
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
// 支持默认参数
function add(a, b=2) {
    return a+b;
}

// 使用匿名函数定义并保存到变量中
var puls1 = function(a) {
    return a+1;
};

// 支持箭头函数
var puls2 = x => x+1;
```

> JS函数不强制调用与声明的一致, 多传入的参数会被忽略, 少传入的参数会被置为undefined.


变量作用域
----------

JS内置了一个window变量, 所有的全局变量实际是作为属性保存到了window变量中. 任何文件中声明的全局变量和函数都都存储在window变量之中, 因此不同文件中的同名函数会冲突.

> 从ES6开始, 只有使用`var`和`function`定义的变量会视为window的属性, 其他方式创建的对象不再是顶层对象




解构赋值
-----------------

JS支持解构赋值, 能够将一个结构体的值一次性赋予指定的一组变量. 例如

``` js
// 对于数组, 按照位置进行复制
let [x, [y, z]] = ['hello', ['JavaScript', 'ES6']];

var person = {
    name: '小明', 
    address: {
        city: 'Beijing', 
        zipcode: '100001'
    }
};
// 对于对象, 不要求顺序, 但被赋值的变量必须与源对象的命名完全一致例如name变量
// 如果变量名不一致, 则需要手动指定key, 例如将address的值复制给内部的两个变量
var {name, address: {city, zip}} = person;
```

-------------

通过解构复制可以实现一些简易操作, 例如

```js
// 将某个方法绑定到变量之上
const { log } = console;
log('hello') // hello

// 交换两个变量的值
[b, a] = [a, b]


// 函数返回多个值, 或者接受多个值
function example() {
  return [1, 2, 3];
}
let [a, b, c] = example();
```

> 参考 [变量的解构赋值](https://es6.ruanyifeng.com/#docs/destructuring)



模块化
--------------

JS提供模块化能力, 整体设计与Python类似. 通过`export`导出一个文件内的变量或函数. 通过`import`语句导入其他模块内的变量或函数.

```js
// 导出变量
export var firstName = 'Michael';

// 导出函数
export function multiply(x, y) {
  return x * y;
};

// 从其他模块带入
import { firstName } from './profile.js';

// 导入并重命名
import { lastName as surname } from './profile.js';

// 导入全部方法, 类似于其他语言中导入包
import * as circle from './circle';
```

导入的变量默认是不可变的, 如果需要修改变量的值, 只能让被导入的模块提供一个修改函数. 被导入的变量发生修改时, 其他模块能感知到变量值的变化.

---------------------

除了上述常规的导出和导入以外, JS也支持导出一个默认符号, 其他模块在导入此模块时, 可以给这个默认符号一个任意名, 例如

```js
export default function () {
  console.log('foo');
}


// import-default.js
import customName from './export-default';
customName(); // 'foo'
```

> nodejs提供require语句来实现模块加载, 通常情况下不建议使用此语法, 而应该使用JS的标准语法


异步编程
---------------

由于JS的单线程机制, 在实际的代码开发中, 存在大量的异步和回调操作. JS提供了Promise机制来简化异步编程. 许多异步操作都会返回一个Promise对象, 该对象具有两个常用的方法, `then`和`catch`

```js
this.axios.post("/item/getTitle", data).then(res => document.title = res.data).catch(e => console.log(e));
```

当异步操作正常执行完毕时, 回调then指定的方法. 如果出现异常, 则回调catch指定的方法.

> 当存在多个异步操作时, 就会嵌套多层回调函数, 导致代码可读性较差

JS提供async关键字和await关键字来解决一次执行多个异步调用的问题. 对于一个返回Promise的函数, 可以使用await关键词同步等待执行结果. 上面的代码可以等价的转换为如下的代码:

```js
// 只有进行async声明的函数可以使用await函数
async function m() {
    try{
        const res = await this.axios.post("/item/getTitle", data)
        document.title = res.data
    } catch (e) {
        console.log(e)
    }
}
```

上述代码相当于以同步的方式执行了一个异步操作, 从而在进行多次异步操作时不用再层层嵌套回调函数.





Web页面中的JS开发
----------------------

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

对于现代的前端项目, 通常采用框架编译的方式生成JS文件, 而不会直接手写JS文件了.


### JS发送请求


对于较为复杂的应用, 可以使用第三方库(例如Axios)封装JS的HTTP请求, 对于简单的项目, 可以使用如下的函数

```js
var httpRequest = new XMLHttpRequest();
httpRequest.open('POST', '/api/submit', true); //打开连接
httpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");//设置请求头 注：post方式必须设置请求头（在建立连接后设置请求头）
httpRequest.send('url='+URL);
```

- [MDN: XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest)



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

