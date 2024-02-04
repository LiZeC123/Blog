---
title: Vue学习笔记
date: 2022-04-07 10:10:31
categories: 
tags:
    - vue
    - javascript
cover_picture: images/vue.png
---

Vue是一款用于构建用户界面的 JavaScript 框架, 相较于几十年前以HTML+CSS+JS的开发方式, Vue提供了一系列的新语法, 使得我们可以声明式地描述最终输出的 HTML 和 JavaScript 状态之间的关系, 并且Vue框架会自动跟踪 JavaScript 状态并在其发生变化时响应式地更新 DOM. 

为了实现上述效果, Vue框架做了大量的底层工作. 但幸运的是, 掌握Vue的基本使用并需要理解底层的实现原理. 除了必要的时候, 本文将不涉及Vue的实现原理, 仅聚焦于Vue的使用.

大概2020年就学过了Vue的基本知识, 当时就计划写一个学习笔记, 但由于各种原因, 迟迟没有开始写. 过了几年以后, Vue发生了许多变换, 这下正好可以直接切换到Vue3了. 以前学的内容也可以抛弃掉了. 本文将基于Vue3的语法, 介绍Vue的基本内容.


创建项目
-----------

目前的前端框架基本上都依赖NodeJs, 因此在创建Vue项目前需要按照NodeJs环境. 对于大部分系统, 在官网上下载最新版安装包即可. 准备好安装环境后, 执行如下指令创建一个Vue项目

```
npm create vue@latest
```

执行该命令会在命令行中要求我们回答一些选项, 按需选择即可.



基础概念
-----------

一个Vue文件代表一个页面上的组件, Vue将HTML代码, JS代码和CSS代码聚集在一个文件之中. 例如

```vue
<script setup>
import { ref, onMounted } from 'vue'

// 响应式状态
const count = ref(0)

// 用来修改状态、触发更新的函数
function increment() {
  count.value++
}

// 生命周期钩子
onMounted(() => {
  console.log(`The initial count is ${count.value}.`)
})
</script>

<template>
  <button @click="increment">Count is: {{ count }}</button>
</template>

<style scoped>
button {
  font-weight: bold;
}
</style>
```

其中`<script>`标签对应与这个组件的JS代码(或者说是TS代码), `<template>`对应HTML代码, `</style>`对应CSS代码.


模板语法
--------------

语法格式       | 示例
--------------|--------------------------------
基础文本插值   | `<span>Message: {{ msg }}</span>`
绑定属性(普通) | `<div :id="dynamicId"></div>`
绑定属性(布尔) | `<button :disabled="isButtonDisabled">Button</button>`
绑定表达式     | `<div :id="`list-${id}`"></div>`
调用函数       | `<time :title="toTitleDate(date)"`

### 动态绑定多个属性

可以通过设置一个对象, 来一次性的绑定多个属性

```js
const objectOfAttrs = {
  id: 'container',
  class: 'wrapper'
}
```

```html
<div v-bind="objectOfAttrs"></div>
```

响应式基础
------------

在Vue框架中, 仅当一个变量声明为响应式变量时, 框架才会自动追踪其变化情况. Vue提供了两种声明方式, 分别是ref()和 , 以下分别介绍这两种方式

### 使用ref()

ref用于基本类型, 包括JS内置的所有基本类型, 对象, 数组和Map. 例如以下语句将username变量声明为一个响应式变量.

```
let username = ref("")
```

ref函数返回一个带有`value`属性的对象, 该对象就代表了此响应式对象的实际值. 在JS代码中, 使用`username.value`的方式访问这个值. 在HTML模板中, 直接使用`username`访问对象的值.

> 对于Vue3的这种割裂的使用方式表示非常难受. 因为模板是需要Vue框架编译的, 因此可以理解其简化了书写. 但既然模板都简化了, 为什么不把JS也简化一下呢.

### 使用reactive()

reactive作用于对象, 将对象本身变为一个响应式变量.


#### reactive()的局限性

1. 只能用于对象类型(对象, 数组和集合类型)
2. **不能直接替换整个对象**
3. 不能解构对象, 解构的变量会失去响应性

其中第二点尤为重要, 例如前端收到后端返回的数据后, 如果直接进行替换, 就会导致响应丢失, 产生不符合预期的表现.



