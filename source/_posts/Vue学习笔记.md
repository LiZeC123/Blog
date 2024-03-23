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

为了实现上述效果, Vue框架做了大量的底层工作. 但幸运的是, 掌握Vue的基本使用并不需要理解底层的实现原理. 除了必要的时候, 本文将不涉及Vue的实现原理, 仅聚焦于Vue的使用.

大概2020年就学过了Vue的基本知识, 当时就计划写一个学习笔记, 但由于各种原因, 迟迟没有开始写. 过了几年以后, Vue发生了许多变化, 这下正好可以直接切换到Vue3了. 以前学的内容也可以抛弃掉了. 本文将基于Vue3的语法, 介绍Vue的基本内容.


创建项目
-----------

目前的前端框架基本上都依赖NodeJs, 因此在创建Vue项目前需要安装NodeJs环境. 对于大部分系统, 在官网上下载最新版安装包即可. 准备好安装环境后, 执行如下指令创建一个Vue项目

```
npm create vue@latest
```

执行该命令会在命令行中要求我们回答一些选项, 按需选择即可.



基础概念
-----------

一个Vue文件代表一个页面上的组件, Vue将HTML代码, JS代码和CSS代码聚集在一个文件之中. 例如

```html
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

其中`<script>`标签对应于这个组件的JS代码(或者说是TS代码), `<template>`对应HTML代码, `</style>`对应CSS代码.


模板语法
--------------

语法格式       | 示例
--------------|--------------------------------
基础文本插值   | `<span>Message: {{ msg }}</span>`
绑定属性(普通) | `<div :id="dynamicId"></div>`
绑定属性(布尔) | `<button :disabled="isButtonDisabled">Button</button>`
绑定表达式     | `<div :id="\`list-${id}\`"></div>`
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

在Vue框架中, 仅当一个变量声明为响应式变量时, 框架才会自动追踪其变化情况. Vue提供了两种声明方式, 分别是`ref()`和`reactive()`, 以下分别介绍这两种方式

### 使用ref()

ref用于基本类型, 包括JS内置的所有基本类型, 对象, 数组和Map. 例如以下语句将username变量声明为一个响应式变量.

```
let username = ref("")
```

ref函数返回一个带有`value`属性的对象, 该对象就代表了此响应式对象的实际值. 在JS代码中, 使用`username.value`的方式访问这个值. 在HTML模板中, 直接使用`username`访问对象的值.

> 对于Vue3的这种割裂的使用方式表示非常难受. 因为模板是需要Vue框架编译的, 因此可以理解其简化了书写. 但既然模板都简化了, 为什么不把JS也简化一下呢.

### 使用reactive()

reactive作用于对象, 将对象本身变为一个响应式变量.


### reactive()的局限性

1. 只能用于对象类型(对象, 数组和集合类型)
2. **不能直接替换整个对象**
3. 不能解构对象, 解构的变量会失去响应性

其中第二点尤为重要, 例如前端收到后端返回的数据后, 如果直接进行替换, 就会导致响应丢失, 产生不符合预期的表现.


计算属性
-----------

计算属性相当于一个带有缓存的函数. 使用`computed`函数创建一个计算属性, 例如

```js
// 一个计算属性 ref
const publishedBooksMessage = computed(() => {
  return author.books.length > 0 ? 'Yes' : 'No'
})
```

之后可以当做一个普通的变量来使用. 并且当其引用的响应式变量发生变化时, 该变量会自动重新计算值, 并触发相应的页面变换.




条件渲染
-----------------

条件渲染涉及两个指令`v-if`和`v-show`, 其中`v-if`的用法和各类语言的`if-else`语句类似, 例如

```html
<div v-if="type === 'A'">
  A
</div>
<div v-else-if="type === 'B'">
  B
</div>
<div v-else-if="type === 'C'">
  C
</div>
<div v-else>
  Not A/B/C
</div>
```

`v-show`语句相对更简单, 不支持与else的连用, 例如

```html
<h1 v-show="ok">Hello!</h1>
```

`v-if`和`v-show`的区别在于, `v-if`会真实的按照条件渲染, 而`v-show`始终会渲染对应的元素, 仅决定该元素是否显示.


列表渲染
------------

列表渲染的格式与JS的ForEach格式类似, 常用的写法有如下两种

```html
<li v-for="item in items">
  {{ item.message }}
</li>

<li v-for="(item, index) in items">
  {{ parentMessage }} - {{ index }} - {{ item.message }}
</li>
```

`v-for`既可以遍历数组, 也可以遍历一个对象, 例如

```html
<ul>
  <li v-for="value in myObject">
    {{ value }}
  </li>
</ul>
```

Vue框架默认使用就地更新的方式刷新数组, 当数组中的元素的顺序发生变化时, 这种特性可能导致不正确的效果表现. 此时应该给每个元素指定一个key, 以便于Vue框架根据key追踪元素的顺序变换

```html
<div v-for="item in items" :key="item.id">
  <!-- 内容 -->
</div>
```


事件处理
-----------

使用`@`来监听事件. `@`既可以监听原生的事件, 也可以监听组件自定义的事件. 例如

```html
<button @click="count++">Add 1</button>
```

> 上述代码既可以直接绑定一个JS表达式, 也可以绑定一个函数, 或者一个箭头函数表达式.

Vue提供了一些按键修饰符, 从而可以快速的绑定某些按键事件, 例如

```
<!-- 仅在 `key` 为 `Enter` 时调用 `submit` -->
<input @keyup.enter="submit" />
```

- [按键修饰符](https://cn.vuejs.org/guide/essentials/event-handling.html#key-modifiers)



### 高级特性

以下是一些高级特性, 可查阅如下文档进行了解

- [在内联事件处理器中访问事件参数](https://cn.vuejs.org/guide/essentials/event-handling.html#accessing-event-argument-in-inline-handlers)
- [事件修饰符](https://cn.vuejs.org/guide/essentials/event-handling.html#event-modifiers)


表单输入绑定
------------

Vue使用`v-model`指令提供表单元素与变量的双向绑定, 例如

```html
<input v-model="text">
```

则在页面上修改input的内容时, text变量的值会同步变化. 使用JS修改text变量的值时, input的内容也会同步变化.

> 表单组件的各类表现可直接查看官方的[交互式示例](https://cn.vuejs.org/guide/essentials/forms.html#form-input-bindings)


生命周期
-----------

Vue框架给组件的生命周期定义了多个阶段, 其中最常用的是`onMounted`钩子, 其相当于各类语言中的init阶段, 可以做一些初始化工作.

```
onMounted(() => {
  console.log(`the component is now mounted.`)
})
```

> 通常并不需要关注Vue的生命周期, 仅使用onMounted做初始化工作即可


侦听器
----------

可以使用`watch`函数在每次响应式状态发生变化时触发回调函数, 可以监听的对象包括响应式对象或者一个函数.

```js
// 单个 ref
watch(x, (newX) => {
  console.log(`x is ${newX}`)
})

// getter 函数
watch(
  () => x.value + y.value,
  (sum) => {
    console.log(`sum of x + y is: ${sum}`)
  }
)
```

> 注意: props不属于响应式变量, 应该使用getter函数的方式进行监听



组件props
------------

使用`defineProps`宏来声明组件需要的props, 例如

```js
const props = defineProps<{
  title?: string
  likes?: number
}>()
```

使用上述方式声明props可以附带变量的类型, 从而为后续使用相关变量提供语法检查和代码补全.

### 绑定多个值

如果想将一个对象的所有属性都当作 props 传入, 可以使用不指定参数名的绑定方式, 即

```js
const post = {
  id: 1,
  title: 'My Journey with Vue'
}
```

```html
<BlogPost v-bind="post" />
```

### 单向数据流

当父元素修改props的值时, 子元素会自动的感知到props的变化, 并进行相应的更新. 这种变更机制是单向的, 即仅父元素可变更子元素, 而子元素不应该反向影响父元素. 通常, 如果子元素希望父元素发生改变, 应该抛出一个事件.

> 因此props可以直接声明为const变量. 这可以防止在子元素中修改props.


### 扩展特性

以下是一些高级特性, 可查阅如下文档进行了解

- [Props校验](https://cn.vuejs.org/guide/components/props.html#prop-validation)



组件事件
---------

在组件的模板表达式中, 直接使用`$emit`触发事件, 在父组件中, 使用`@`绑定事件处理逻辑, 例如

```html
<!-- MyComponent -->
<button @click="$emit('someEvent')">click me</button>

<MyComponent @some-event="callback" />
```

```html
<button @click="$emit('increaseBy', 1)">
  Increase by 1
</button>

<MyButton @increase-by="(n) => count += n" />
```

-----------

在JS代码中, 需要通过`defineEmits`宏, 声明涉及的事件, 例如

```html
<script setup>
const emit = defineEmits<{
  (e: 'update-todo', type: string, data:FuncData | CreateItem ) : void
}>()

function buttonClick() {
  emit('update-todo', 'create', data)
}
</script>
```

### 扩展特性

以下是一些高级特性, 可查阅如下文档进行了解

- [事件校验](https://cn.vuejs.org/guide/components/events.html#events-validation)



Vue路由
-------------

`Vue Router`是Vue官方的路由插件. 通过该插件可以便捷的实现单页面应用. 单页面应用与传统的前端页面相比, 其主要区别在于页面交互时不发生跳转, 直接在当前页面上进行元素的重新渲染.

创建Vue项目时, 可选择是否包含`Vue Router`, 选择包含时, 会自动添加相关的依赖. 仅需两步即可引入, 首先定义路由规则, 例如

```js
// 1. 定义路由组件.
import Home from "@/xx"
import About from "@/xx"

const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes: [
    { path: '/', component: Home },
    { path: '/about', component: About },
  ]
})


// 2. 创建并挂载根实例
const app = Vue.createApp({})
app.use(router)
```

### 动态路由

如果路径中包含一些参数, 则可以使用动态路由特性, 该特性可将路径中的一部分内容匹配到变量之中, 例如对于如下的配置

```js
const routes = [
  // 动态字段以冒号开始
  { path: '/users/:id', component: User },
]
```

则无论是访问`/users/233`还是`/users/114514`都会匹配此规则, 并且在组件中, 还可以通过如下的方式获得具体的ID值

```js
const $router = useRouter();
const id = $router.params.userId as string
```


Axios网络请求库
------------------

### 基础使用

在Vue框架中, 通常使用axios库发送请求. 通常使用如下的方式发送HTTP请求

```js
import axios from 'axios'

// 发送GET请求
axios.get<TomatoItem>('/tomato/getTask')

// 发送POST请求
axios.post<Item[]>('/item/back', { id, parent }).then((res) => {doSomething()})
```

通常情况下, 对于POST请求, 仅需要指定路径和参数接口. 

> 注意, 对于TS代码, 在函数后通过泛型参数指定返回值类型, 可使得返回对象(即res)具有正确的数据结构, 从而获得代码补全和语法检查

### 全局拦截器

axios可配置全局拦截器, 使得在发送每个请求前和收到每个响应后, 统一执行一段代码, 例如

```js
// 设置统一的URL前瞻, 实际URL等于前缀+函数指定的路径, 例如 /api/item/back
axios.defaults.baseURL = '/api'

// 设置统一的请求拦截器, 在发送请求前可统一设置参数
axios.interceptors.request.use(config => {
    config.headers.set('Token', 'XXX')
    return config;
});

// 设置统一的响应拦截器, 在收到请求后可设置统一的错误处理
axios.interceptors.response.use(res => {
    return res;
}, async error=> {
    if (error.response.status === 401) {
        console.log("返回401, 跳转到登录页面")
    } 
});
```

Vue其他相关知识
--------------------


### Vue引用静态资源

在Vue中, 静态资源也视为一个模块, 因此可以也可以导入, 例如

```js
import imgUrl from '../assets/test.png';
```

之后将该变量赋值给Vue的变量, 即可将其视为一种资源进行引用

- [Vue 引入本地资源](https://blog.csdn.net/XueDaJing030409/article/details/117549660)


Vue问题解决方案
--------------------

- [Vue--Router--解决多路由复用同一组件页面不刷新问题](https://blog.51cto.com/knifeedge/5627125)