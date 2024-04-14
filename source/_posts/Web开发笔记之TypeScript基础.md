---
title: Web开发笔记之TypeScript基础
math: false
date: 2023-09-23 22:18:12
categories: Web开发笔记
tags:
    - typescript
cover_picture: images/typescript.jpg
---

TypeScript是JavaScript的超集, 可以视为一个具有类型的JS语言. 因此TS既可以在浏览器中运行(传统的前端开发), 也可以在Node.js环境中运行(写Vscode插件). 由于JS的语法特性TS均支持, 因此学习TS语言, 主要就是学习类型系统.


基本类型
---------------

```js
// 赋予初始值时自动推断类型
let a = 'abc';
// 可手动指定类型
let b: string = 'ss'


// 数组类型支持两种声明方式
let arr: number[] = [1, 2, 3]
let brr: Array<number> = [4, 5, 6]


// 声明复合类型, ?表示字段可空
let t1 : [string, number, string?] = ['abc', 2, 'def']
let o1: {foo: string, bar: number} = {foo: 'foo', bar: 42}


// 联合类型
let v1: string | null = null


// 可直接限定变量取值范围, 达到类似枚举的效果
let v2: 1 | 2 | 3 = 2


// 强制类型转换
const rst = arr.find(n => n > 2) // number | undefined
//注意: TS的所有类型检查都是编译期行为, 因此强制类型转换如果不符合预期, TS也无法进行提示.
const pst = arr.find(n => n > 2) as number // number


// 枚举类型
enum MyEnum {
    A, B, C
}
// console.log(MyEnum.A)

```

类型别名
-----------

对于较为复杂的联合类型, 可使用类型别名进行简化

```js
type TokenType = "IDENT" | "STR" | "NUM"

const v:TokenType = "IDENT"
```



函数
-------------

函数的类型标记方式与变量相同, 整体与Python的风格类似

```js
// 常规函数
function add(x: number, y: number): number {
    return x + y;
}

// 可选参数和void返回值
function add2(x: number, y?: number): void {
    console.log(x+y);
}

// 泛型函数
function f<T>(a: T, b: T): T[] {
    return [a, b]
}
```

接口
------------

TS支持通过定义一个interface来指定某一种数据结构的行为, 例如

```js
// 直接定义具体的字段名和类型
interface FunItem {
    name: string
    doc: string
}

// 对于对象, 可通过如下方式定义key和value类型
interface FunMap {
    [key: string]: FunItem
}

let m: FunMap = {
    "SayHello": {name: 'Hello', doc: "document"},
    "Exit": {name: 'Hello', doc: "document"}
}

// console.log(m['SayHello'].name)
```


参考资料
------------------

- [Typescript在线运行](https://www.typescriptlang.org/play)
- [20分钟学会TypeScript](https://www.bilibili.com/video/BV1gX4y177Kf/)

