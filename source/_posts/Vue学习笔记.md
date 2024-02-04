---
title: Vue学习笔记
date: 2022-04-07 10:10:31
categories: 
tags:
    - vue
    - javascript
cover_picture: images/vue.png
---


大概2020年就学过了Vue的基本知识, 当时就计划写一个学习笔记, 但由于各种原因, 迟迟没有开始写. 过了几年以后, Vue发生了许多变换, 这下正好可以直接切换到Vue3了. 以前学的内容也可以抛弃掉了.



基础概念
-----------

Vue是一个前端框架, 



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


模板语法
--------------

基础的文本插入值:

```html
<span>Message: {{ msg }}</span>
```


绑定属性:

```html
<div :id="dynamicId"></div>
<button :disabled="isButtonDisabled">Button</button>
```

