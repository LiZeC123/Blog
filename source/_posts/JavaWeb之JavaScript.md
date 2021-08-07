---
title: JavaWeb之JavaScript
date: 2018-06-21 20:22:17
categories: JavaWeb
tags:
    - Javascript
cover_picture: images/js.png
---

很早以前就尝试学习js,不过用于当时的时机还不成熟,因此始终没有真正的学会js. 现在终于有机会可以再次系统的学习一次,因此将js学习过程中的笔记记录在此.

由于已经学习过Java和Python等编程语言,因此本文不是一个面向初学者的笔记. 在笔记中往往只会记录js特有的语言特性,而与大部分语言相同的共性内容会直接忽略.


网页中使用js的两种方法
------------------

1. 直接嵌入html代码
``` html
<script type="text/javascript">
alert("Hello");
</script>
```
2. 从文件导入
``` html
<scrpit src = "/static/js/hello.js"></scrpit>
```

js的比较
-------------

比较的类型  | 注意事项
----------------|----------------------------------------------------------
类型比较         | 应始终使用`===`来进行比较,使用`==`时会进行隐含的类型转换
浮点数比较       | 浮点数不能精确表示,因此不能直接比较
NaN             | NaN与任何符号都不相等,使用`isNaN`函数来判断

对于null, undefined,NaN,空字符串`""`与0都视为false,其他所有视为true


基本类型
--------------


类型      |解释
---------|---------------------------------------------------
变量     | 使用let声明可变变量, 使用const声明不可变变量
数组     | 使用`[`和`]`, 与大部分语言一样,且数组中元素可以是任意类型
对象     | 使用大括号包括的键值对
字符串   | `'`和`"`以及反引号都可以定义字符串
``` js
var i = 5;                  // 定义变量
var array = [1,2,"hello"];  // 定义数组
var p = {                   // 定义对象
    name: "Li",
    age: 13,
    tag: ["apple","book"],
    info:null
};

var s = `这是
一个
多行字符串`

// 字符串模板
var name = `Li`;
var hello = `Hello ${name}`;
consloe.log(hello);

```


基本数据结构
---------------
### 数组
1. 数组属性
    - 每个数组都默认有一个length属性表示数组的长度
2. 越界处理
    - 越界写入返回undefined
    - 越界写入,数组会自动扩到到指定的长度,中间的元素使用undefined填充(与matlab类似)
    - 直接修改length也会导致数组长度变化
3. 函数
    - 数组的`pop`,`push`,`sort`,`reverse`与各种语言效果一样,需要的时候查一下就可以了

### 对象
1. 属性访问方法
    - 使用形如p.name访问,也是标准的访问方法
    - 使用p['name']访问,效果与上面一致
2. 未定义访问
    - js这么随意的语言当然不会报错,访问未定义的属性时返回undefined
    - 写入未定义属性时,会直接添加这个属性到对象之中
3. 属性检查
    - 使用`in`关键字可以判断一个属性是否属于对象,无论这个属性是对象原本的属性还是继承的属性
    - 使用`hasOwnProperty`方法检查是否是对象原本的属性

``` js
> var p = {
...     name : 'Li',
...     age: 18
... };
undefined
> p.name = "iL";
'iL'
> p.name
'iL'
> p,age
20
> p.tag
undefined
> p.tag = ["apple"]
[ 'apple' ]
> p
{ name: 'iL', age: 18, tag: [ 'apple' ] }
> 'toString' in p
true
> p.hasOwnProperty('toString')
false
```



语句
----------
1. foreach循环
    - 使用for(var i in arr)的格式进行foreach循环,既可以遍历数组也可以遍历对象
    - 由于设计问题,不建议使用此方法
2. for..of循环
    - 由于后来的类型不能使用for..in循环,因此后来的标准中,添加了统一的循环方式
3. 使用回调函数的for循环
    - 可以遍历的类型都继承了forEach函数,该函数接受一个回调函数,从而在循环的每个元素上可以执行具体的操作
    - 从清晰性的角度,使用回调函数最好


``` js
var o = {
    name: 'Jack',
    age: 20,
    city: 'Beijing'
};
for (var key in o) {
    if (o.hasOwnProperty(key)) {
        console.log(key); // 'name', 'age', 'city'
    }
}

var a = ['A', 'B', 'C'];
for (var i in a) {
    console.log(i); // '0', '1', '2'
    console.log(a[i]); // 'A', 'B', 'C'
}

// for...of循环
var a = ['A', 'B', 'C'];
var s = new Set(['A', 'B', 'C']);
var m = new Map([[1, 'x'], [2, 'y'], [3, 'z']]);
for (var x of a) { // 遍历Array
    console.log(x);
}
for (var x of s) { // 遍历Set
    console.log(x);
}
for (var x of m) { // 遍历Map
    console.log(x[0] + '=' + x[1]);
}

var m = new Map([["Apple",1],["Banana",2]]);
m.forEach(function(value,key,map){
    console.log(`value = ${value}, key = ${key}`);
})
```

Map与Set类
------------
- js的对象可以视为一个Map,但是因为键只能是字符串因此有所限制,因此js提供了Map与Set两个类型.
- Map可以使用set,delete,get,has等函数来实现增删改查等操作.
- Set使用add与delete实现插入和删除操作.
``` js
var m = new Map([['Apple',14],['Banana',7]]);
var s = new Set([1,2,3]);

> m.get('Apple')
14
> m.set("Orange",3)
Map { 'Apple' => 14, 'Banana' => 7, 'Orange' => 3 }

> s.has(2)
true
> s.has(5)
false
```

函数
--------
- 使用function关键字引导一个函数
- 没有return的函数返回undefined
``` js
function add(a,b){
    return a+b;
}

add(2,3)
```
- 函数也是对象,可以保存到变量之中
```js
// 使用匿名函数定义并保存到变量中
var puls1 = function(a){
    return a+1;
};

```
- js函数不强制调用与声明的一致,传入的变量个数也可以完全不同(简直不能更随意)
    - 多传入的参数会被忽略
    - 少传入的参数会被置为undefined
- 使用arguments可以获得所有传入参数组成的数组,从而对于实际传入参数进行判断
- 可以使用rest关键字实现可变参数函数
``` js
// 手动检查
function narg(a,b,c){
    if(arguments.length == 1){
        return a;
    }
    else if(arguments.length == 2){
        return a+b;
    }
    else if(arguments.length == 3){
        return a+b+c;
    }
}

console.log(narg(1));
console.log(narg(1,2));
console.log(narg(1,2,3));

// 可变参数声明
function foo(a, b, ...rest) {
    console.log('a = ' + a);
    console.log('b = ' + b);
    console.log(rest);
}

foo(1, 2, 3, 4, 5);
// 结果:
// a = 1
// b = 2
// Array [ 3, 4, 5 ]

foo(1);
// 结果:
// a = 1
// b = undefined
// Array []
```
- js支持闭包
    - 因此内部定义的函数可以直接访问外部的函数中的变量
    - 可以将子函数作为参数返回,之后子函数依然可以访问定义此子函数的父函数中的变量
``` js
function foo(x){
    function bar(y){
        return x+y;
    }

    return bar;
}


var g = foo(10);
console.log(g(2));

// 通过闭包机制,还可以实现更加复杂的机制
function cons(x,y){
    return function(c){
        return c(x,y);
    }
}

function car(m){
    return m(function(x,y){return x});
}

function cdr(m){
    return m(function(x,y){return y});
}

console.log(car(cons(1,2)));
```
- 使用return的时候,单一语句一定要写在同一行,否则解释器会默认在return后直接加上分号,因此要确保return后不为空


变量作用域
----------
1. 全局变量
    - js有一个window变量,所有的全局变量实际是作为属性保存到了window变量中
    - 直接声明的函数是全局变量,因此不同文件中的同名函数会冲突
    - 为了避免冲突,可以手动设置名字空间
``` js
var myNameSpace = {};

myNameSpace.foo = function(x) { ... };
```
2. 变量提升
    - 在函数中声明的变量具有函数作用域
    - 即无论在函数中的何处声明的变量都是函数类任意位置可见的
    - 因此在循环中的变量在循环外也是可以访问的
``` js
function f(x){
    var x;
    console.log("y="+y);
    var y = 4;
}
```
<==>
``` js
function f(x){
    var x;
    var y;
    console.log("y="+y);
    y = 4;
}
```
3. 真局部变量
    -使用let关键字创建绝对的局部变量(其实这个作用域规则和lisp之类的语差不多了)
``` js
function f(x){
    var sum = 0;
    for(let i = 0;i < x;i++){
        sum += i;
    }
    i += 3; // 报错
}
```

4. 常量
    - 使用const关键字声明
    - 声明的变量是真局部变量

5. 解构赋值
    - 可以同时对多个变量赋值
    - 使用中括号包括
``` js
let [x, [y, z]] = ['hello', ['JavaScript', 'ES6']];
x; // 'hello'
y; // 'JavaScript'
z; // 'ES6'

var person = {
    name: '小明',
    age: 20,
    gender: 'male',
    passport: 'G-12345678',
    school: 'No.4 middle school',
    address: {
        city: 'Beijing',
        street: 'No.1 Road',
        zipcode: '100001'
    }
};
var {name, address: {city, zip}} = person;
name; // '小明'
city; // 'Beijing'
zip; // undefined, 因为属性名是zipcode而不是zip
// 注意: address不是变量, 而是为了让city和zip获得嵌套的address对象的属性:
address; // Uncaught ReferenceError: address is not defined
```

高阶函数
-----------

1. map函数
    - 将一个函数依次作用到每个元素上,并将结果组成一个新的列表
```js
var arr = [1,2,3];
var result = arr.map(Math.sqrt);
console.log(result); //Array(3) [1, 1.4142135623730951, 1.7320508075688772]
```

2. reduce函数
    - 接受一个函数,该函数接受两个参数
    - 将函数计算结果与下一个元素一同被函数再次计算
``` js
var arr = [1,2,3];
var result = arr.reduce((x,y)=> x+y); // 6
```

