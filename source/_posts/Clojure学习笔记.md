---
title: Clojure学习笔记
math: false
date: 2024-09-28 20:39:07
categories:
tags:
    - Clojure
cover_picture: images/clojure.png
---

Clojure是一种在JVM上运行的LISP风格的语言. 由于其函数式编程的风格和强大的宏系统, Clojure在并发编程的理念上非常先进, 不仅支持常规的函数式并发模式, 也支持Go语言的并发风格, Vue框架的许多概念在Clojure中均具有类似的概念. 虽然从实践角度来说, 由于其依赖JVM导致作为脚本语言显得过重, 远不如Python轻便快捷. 但其中涉及的编程范式依然值得学习.

Clojure环境构建
==========================

Clojure常见的开发IDE是vscode和IDEA. 两者都可以免费使用, 考虑到没有代码补全的情况下调用Java方法过于折磨, 因此推荐在编写简单脚本时使用vscode, 开发项目时使用IDEA.

vscode不需要安装插件即可支持基本的Clojure开发, 体验类似于写简单的Python脚本, 提供简单的语法高亮和代码补全.

IDEA需要安装Cursive插件, 安装完毕后重启IDEA即可选择Clojure项目. 在IDEA中, 依然支持Clojure语言的代码补全, 自动导入包等能力.



脚本方式运行Clojure
------------------------

当Clojure作为脚本语言执行时, 只需要使用`clojure -M xx.clj`即可运行该脚本. 

由于并没有代码补全能力, 因此如果使用了非默认导入的包, 则需要手动导入包名.



项目方式运行Clojure
--------------------

### 安装leiningen

leiningen是一个用于生成和管理Clojure项目的工具, 提供了项目初始化, 依赖导入, 项目编译和打包等能力, 基本上等于Java中的Maven.

可参考官网指引安装[leiningen](https://leiningen.org/), 也就是将对应的脚本下载到本地, 放入一个PATH变量中存在的路径.

保存后执行`lein self-install`安装此工具需要的依赖. 此操作需要环境中能执行java命令.


### 创建项目

执行`lein new xx`命令, 创建一个Clojure项目, 执行完毕后, 在IDEA中打开该项目. 

`lein`创建的项目结构与标准的maven项目结构没有明显区别, 在src路径下正常编写代码即可. 对于main函数所在文件需要进行如下的处理

```clojure
(ns demo3.core
  (:gen-class))


(defn -main [& args]
  (println "Hello World!"))
```

1. 在`ns`中需要使用`:gen-class`表明该文件需要生成一个Java的类, 否则无法在IDEA中运行程序
2. 声明一个`-main`函数, 该函数就相当于Java中的main函数


> 默认情况下IDEA会下载一些依赖, 但由于网络原因可能会下载失败, 使得源码中产生许多告警. 此时可执行`lein run`命令运行当前项目, 从而强制执行一次依赖下载操作.



### 项目级配置

在`project.clj`中还需要增加如下的配置


```clojure
:main demo3.core
:profiles {:uberjar {:aot :all}}
```

`:main`用于指定入口的main函数位置, 在生成jar时需要该属性. 

`:aot`指定预先编译(Ahead-Of-Time, AOT)所有的命名空间, 该操作有助于提升jar的运行速度, 并提前发现一些类型问题. 但是在开发过程中, 启用预先编译会消耗更多时间, 因此通常仅在生成uberjar时启用该特性.


### 打包

当Clojure作为项目执行时, 最后可使用lein进行打包, 执行

```sh
lein uberjar
```

生成一个包含了所有依赖的JAR文件, 之后可使用`java -jar`指令运行对应的jar.


数据类型
==============

布尔类型有三种, 除了false和nil其他任何值均可视为true(当然也包括数字0)

```clojure
(= true false nil)
; false
```

字符串就是Java的String类

```clojure
(.contains "hello" "he")
; true
```

整数默认为long类型, 使用N后缀创建BigInt, 支持分数

```clojure
(+ 41 21N 2/3)
188/3
```

使用单引号创建一个符号, 使用冒号创建一个关键字, 关键字就是一个指向自身的符号

```clojure
'Hello
:apple
:apple
```


列表
--------

列表类型与Schema的列表类型对应, 类似于链表实现. 可以使用list关键字显式创建一个列表, 也可以通过引用的方式使用字面量的形式创建列表


```clojure
user=> (list 1 2 3)
(1 2 3)

user=> (def listA '(1 2 3 4)) 
#'user/listA

user=> (first listA)
1

user=> (last listA)
4

user=> (rest listA)
(2 3 4)
```

```clojure
; 根据输入的数据类型不同, 会在不同的配置插入数据
user=> (conj listA 6)
(6 1 2 3 4)

; 将列表视为栈使用, 返回第一个元素
(peek listA)

; 将列表视为栈使用, 返回剩余元素
(pop listA)
```


向量
--------

向量是Coljure新加入的数据结构, 类似于数组的实现. 可以直接使用方括号定义向量, 也可以调用vector函数显式的创建向量

```clojure
user=> [1 2 3]
[1 2 3]

user=> (vector 1 2 3)
[1 2 3]

; 方括号本身说明了后续内容是数据, 因此不需要使用单引号
(def vectorA [1 2 3])

; 获得第二个元素, 如果越界返回nil
(get vectorA 2) 

; 获取第二个元素, 如果越界抛出异常
(nth vectorA 2)

; 将指定位置进行替换, 返回修改后的新向量
(assoc vectorA 2 23) 

; 向量本身可以作为一个函数, 返回给定位置的数据
(vectorA 2)
```

> 实际上由于向量不可变, 其底层实现并非一个数组, 而是类似于二叉树的结构, 具体可阅读[Understanding Clojure's Persistent Vectors](https://hypirion.com/musings/understanding-persistent-vector-pt-1)

哈希表与集合
-------------

使用大括号创建哈希表, 其中的逗号在任何位置都会视为空格, 仅用于增加可读性. 

```clojure
user=> {:a 1, :b 2}
{:a 1, :b 2}

user=> (def the-map {:a 1, :b 2})
#'user/the-map

; 哈希表本身也是函数, 可用于查找值
(the-map :a)  

; 也可以反过来调用, 效果一样
(:a the-map)  

; 集合就是一个特殊的哈希表, 使用#宏创建
#{:a :b :c}
```

对于嵌套多层的哈希结构, Clojure提供了一组方法来简化操作


```clojure
(def users {:ggboy {
    :date "2013-04-05",
    :summary {
        :average {
            :monthly 1000,
            :yearly 12000,
        }
    }
}})
```

```clojure
; 设置嵌套层次的数据, 并返回新的结构
(assoc-in users [:ggboy :summary :average :monthly] 2000) 
; {:ggboy {:date "2013-04-05", :summary {:average {:monthly 2000, :yearly 12000}}}}

; 获取嵌套层次的数据
(get-in users [:ggboy :summary :average :monthly])  
; 1000

; 在指定的位置执行给定的函数, 返回更新后的数据
(update-in users [:ggboy :summary :average :monthly] + 500) 
; {:ggboy {:date "2013-04-05", :summary {:average {:monthly 1500, :yearly 12000}}}}

users
; {:ggboy {:date "2013-04-05", :summary {:average {:monthly 1500, :yearly 12000}}}}
```

列表操作
-----------

Clojure支持函数式语言中经典的列表类操作

```clojure
(every? number? [1 2 3 :four])

(filter (fn [x] (> x 4)) [1, 2, 3, 4, 5])

(map (fn [x] (* x x)) [1 2 3])


```

Clojure中使用for关键词实现类似Python的列表推导功能, 即根据表达式生成列表. for仅可实现列表生成, 而不具备其他语言中循环的能力.


```clojure
(def color ["red" "blue"])
(for [x color] (str "I like " x))
```

语言结构
===========

函数与绑定
----------------

```clojure
; 创建匿名函数并调用
((fn [a b] (+ a b)) 1 2)

; 可变参数
(defn more-arg [x y & more] (+ x y))

; 绑定
(def line [[0 0] [10 20]] )
(first line)

; 定义函数
(defn mmax [a b]
  (if (> a b) a b))


; defn实际上是一个宏, 等于def+fn
(def a-function 
  (fn [a b] (+ a b))
)


; let形式, 绑定局部变量
(let [ x 1, y  2, z (+ x y)] z)

; 变量解构
(def board [ [:x :o :x] [:o :cc :x] [:o :o :x]  ])
(defn center  [[_ [_ c _] _]] c)

; 其实只是使用了函数的形式参数的能力而已
(center board) 
```


流程控制
-------------


```clojure
(def x 42)

(if (> x 2) 
    (println "X > 2")
    (println "X < 2"))

(if-not (< x 2) 
    (println "X > 2")
    (println "X < 2"))

(cond 
  (> x 0) "greater"
  (= x 0) "equal"
  :default "lesser"
)

; do依次执行多个函数
(do (println "A") (println "B"))


; when 等于if + do, 条件满足时执行多个语句
; when也有相反的 when-not 形式
(when (> x 5)
  (println "A")
  (println "B")
  "done"
)
```

逻辑运算
----------

逻辑函数, 支持 and, or, not. Clojure中仅false与nil视为逻辑假, 其余值均视为逻辑真.

逻辑函数具有短路特性并返回最后一个处理的值, 例如对于and, 要么返回最后一个值, 要么中途遇到nil或者false, 从而返回nil或false.

```clojure
(and :a :b :c) ; => :c

(and :a nil :c); => nil
```


递归循环
----------

使用loop与recur实现经典的函数式递归循环. loop的第一个参数是绑定列表, 提供偶数个参数, 将符号与值绑定.

因此在`fact-loop`方法中, 首先将current绑定到n, fact绑定到1. 后续在recur中再次进行绑定后递归的进行计算.

由于Clojure不能自动优化尾递归, 因此只能采取这种方式实现尾递归.



```clojure
(defn fact-loop [n]
  (loop [current n, fact 1]
    (if (= current 1)
      fact
      (recur (dec current) (* fact current) ) )))
```

由于递归方式实现循环时, 代码比较复杂, 因此Clojure中还有两个简化循环的操作


```clojure
; 简化循环操作, 遍历指定的列表
(doseq [user ["alice" "bob" "ggboy"]]
  (println "Hello, " user))


; 简化循环操作, 执行指定次数
(dotimes [x 5]
  (println "x is" x))  
```

串行宏
-----------

对于复杂表达式, 需要多层嵌套, 因此书写不方便, 可使用串行宏. 

`->` 将上一个表达式放到下一个表达式的第一个参数的位置.

`->>` 将上一个表达式放到下一个表达式最后一个参数的位置.

此外还支持更复杂的任意位置串行`as->` 和条件串行`cond->`

```clojure
(defn final-amount-> [principle rate time]
  (-> rate
    (/ 100)
    (+ 1)
    (Math/pow time)
    (* principle)))
; 等价于

(defn final-amount [principle rate time]
    (* 
        (Math/pow 
            (+ 
                (/ rate 100) 
                1) 
            time) 
        principle))
```

```clojure
(= 
  (final-amount-> 100 0.24 2) 
  (final-amount 100 0.24 2))

(= 
  (take 5 (drop 2 (cycle [:i :love :clj]))) 
  (->> [:i :love :clj] (cycle) (drop 2) (take 5)) )
```


异常处理
---------

CLojure不要求强制处理任何异常, 但依然可以使用`try`和`throw`等语句处理异常. 

```clojure
(defn safe-average [numbers]
    (let [total (apply + numbers)]
        (try
            (/ total (count numbers))
            (catch ArithmeticException e
                (println "Divided by Zero!")
                0)
            (finally (println "done"))
        )
    )
)
```

> 在没有代码补全的情况下, 应该并没有人愿意写这些代码, 所以脚本环境就随便写吧

注意`(apply + numbers)`与`(+ numbers)`的区别. 对于前者, 相当于将`numbers`的内容展开后调用`+`函数, 而对于后者, 相当于直接对`numbers`本身进行操作.

例如当`number`为`[1 2 3]`时, 两者相当于`(+ 1 2 3)`与`(+ [1 2 3])`


元数据
-------

可以对任意对象附加元数据. 元数据不会改变该对象的任何特性(包括相等比较), 可以使用特定的函数提取对象的元数据

```clojure
(def untrusted (with-meta {:a 123} {:safe false :io true}))

; 可使用^{}宏代替with-meta函数
(def untrusted2 ^{:safe true, :io false} {:b 234})

(meta untrusted)
; (meta untrusted)
```


函数
==========

重载
-----

Clojure支持在一个函数中提供多个实现, 根据参数的数量实现重载

```clojure
(defn func-m
    ([A] (println "One") A)
    ([A B] (println "Tow") (+ A B))
)

(func-m 2) 

(func-m 2 3)
```

可变参数
---------

使用`&`符号声明可变参数, 剩余的所有参数打包到`&`符号后面的变量之中

```clojure
(defn func-print-more [name & more]
    (println more))

(func-print-more "func" 1 2 3 4)
; (1 2 3 4)

```

常用高阶函数
--------------

函数名      | 效果
------------|-------------
every?      | 对列表中每个元素执行判断, 判断是否均满足条件
constantly  | 返回一个函数, 该函数无论输入什么, 均返回给定的值
complement  | 对一个函数取反
comp        | 将一组函数组合为一个函数
partial     | 将一个函数的前k个参数赋予默认值后返回一个新函数
memoize     | 对函数执行内存化

```clojure
(every? number? [1 2 3 :four])

(def two (constantly 2))
(println (two 1))
(println (two 2 3 4 5))

(defn greater [x y]
    (> x y))
(println (greater 2 3))

(def less (complement greater))
(less 2 3)

(def opp-zero-str (comp str not zero?))
(opp-zero-str 1)

(defn full-add [x y c]
    (+ x y c))
(def simple-add (partial full-add 1 2))
(simple-add 3)

(defn fib [n]
  (if (<= n 1)
    n
    (+ (fib (- n 1))
       (fib (- n 2)))))
(def m-fib (memoize fib))
; 首次计算用时1.2s
(m-fib 39)
; 再次计算用时0.1s
(m-fib 39)
```

匿名函数
------------

在前面已经看到了使用`fn`定义匿名函数. Clojure也提供了一个宏实现匿名函数, 即`#()`

```clojure
(def users [{:name "alice", :age 12} {:name "bob", :age 24}])

; %表示入参, 如果有多个入参, 可依次使用%1 %2等
; #后面直接写对应的你们函数体即可
(map #(% :name) users)

; 由于关键词本身可以作为一个函数, 因此上面的代码也可以简化为如下的形式
(map :name users)
```


操作Java对象
==========================

使用`.`操作符调用Java提供的库. Clojure默认导入了一些Java的包, 可以直接使用


```clojure
(. Math PI)

(. Math abs -3)

(. "foo" toUpperCase)

(new Integer "42")
```

以上的调用方式由于比较常用, 因此可以使用简写方式


```clojure
Math/PI

(Math/abs -3)

(.toUpperCase "foo")

; 注意new的简化方式中, "."的位置
(Integer. "43")
```

导入Java包
------------

在REPL中, 可以使用import语句进行导入, 在程序项目中, 可以在ns语句中导入


```clojure
(import 'java.util.Date)

(new Date)
```

```clojure
(ns test5 (:import java.util.Date))

(Date.)
```

对于多层次的链式调用, 可以使用`..`符号进行简化

```clojure
(ns test6 (:import java.util.Calendar))

; 由于getTimeZone和getDisplayName不需要额外参数, 因此甚至可以省略圆括号
(.. (Calendar/getInstance) (getTimeZone) (getDisplayName))
```

辅助Java调用的宏
------------------

对于如下的Clojure代码, 必须定义一个匿名函数编译器才可以确定getBytes函数具体是哪一个(Java对应的类上存在多个函数重载, 无参数调用返回默认编码格式, 有参数调用可额外指令编码的字符集名称)


```clojure
(map (fn [x] (.getBytes x)) ["alice", "bob"])
```

可以使用`memfn`将一个成员函数调用转换为一个Clojure函数, `memfn`在运行时通过反射确定具体应该调用的函数

```clojure
(map (memfn getBytes) ["alice", "bob"])
```

可以使用`bean`宏, 将一个JavaBean对象映射为Clojure的map结构, 例如

```clojure
(ns test6 (:import java.util.Calendar))
(bean (Calendar/getInstance))
; {:weeksInWeekYear 52, :timeZone #object[sun.util.calendar.ZoneInfo 0x34e5ff85 "sun.util.calendar.ZoneInfo[id=\"Etc/UTC\",offset=0,dstSavings=0,useDaylight=false,transitions=0,lastRule=null]"], :weekDateSupported true, :weekYear 2024, :lenient true, :time #inst "2024-06-01T08:16:14.579-00:00", :calendarType "gregory", :timeInMillis 1717229774579, :class java.util.GregorianCalendar, :firstDayOfWeek 1, :gregorianChange #inst "1582-10-15T00:00:00.000-00:00", :minimalDaysInFirstWeek 1}
```

跳出Java思维
---------------

需要注意, 虽然Clojure提供了直接无缝操作Java类的方法, 但不要尝试在Clojure中硬写Java代码. 例如, 对于从一个文件中读取所有行并放入一个向量中的操作, 使用Java类强行实现的代码和使用Clojure实现的代码分别如下所示:  

```clojure
(ns demo3.input
  (:import (java.io FileInputStream)
           (java.util Scanner)))


(defn scan [scanner]
  (loop [rst []]
    (if (.hasNext scanner)
      (recur (conj rst (.nextLine scanner)))
      rst)))


(defn read-file [filename]
  (let [fis (new FileInputStream filename) s (new Scanner fis)]
    (scan s)))
```

```clojure
(ns demo3.core
  (:gen-class)
  (:require [clojure.java.io :as io]
            [demo3.input :as input]))


(defn read-file [filename]
  (with-open [file (io/reader filename)]
    (vec (line-seq file))))
```

使用Java的类实现该操作, 就如同在用牙签吃饭, 不仅繁琐, 还很难保证正确的实现(例如上述代码未关闭文件流). 而使用Clojure提供的库来实现此功能就非常的简单且符合逻辑.

在使用Clojure的过程中需要始终记住不要用Java思维写代码, 也不要把Clojure当做一个在JVM上的LISP封装. Clojure作为一门生态成熟的语言, 常见的操作都有自己的解决方案, 不必强行使用Java实现.

> 写代码之前多问一下GPT如何实现



状态与并发
============

基本概念
----------

**不可变量**: Clojure与其他函数式语言类似, 除了极少数情况下, 大部分时候的创建的变量实际上是不可变的.

**持久化**: 在Clojure中, 持久化并非指保存到硬盘, 而是指变量再线程内具有一致性, 其他线程对数据的修改本质上是创建了一个新的对象并共享其中不变的部分.

**软件事务内存**: Clojure支持软件事务内存, 即提供一种机制可以类似于事务的模式下更新多个变量(具有原子性和一致性).

**事务的副作用**: 软件事务内存会自动重试失败的事务, 因此事务中的函数可能重复执行多次, 这些函数不应该具有副作用

**事务安全标记**: Clojure中以`!`结尾的函数表明不均被事务安全性, 即不建议在事务中调用. 可参考`swap!`和`send`

ref
-----------

在Clojure中使用标识与值分离的思想解决并发问题. 引用相当于一个指针, 指针可以指向不同的值, 而每个值本身不会变化.

使用ref创建引用, 使用deref解除引用(或者使用@宏)

```clojure
(def user (ref {:name "alice", :age 12}))
; #'user/user

(println user)
(println @user)

; #ref[{:status :ready, :val {:name alice, :age 12}} 0x2c424287]
; {:name alice, :age 12}
```

-------------------

Clojure提供了多种方式修改引用的值, 这些方法都需要在`dosync`函数内执行. `ref-set`直接修改引用的指向


```clojure
(def user (ref {:name "alice", :age 12}))
(println "Before: " @user)
(dosync (ref-set user {}))
(println "After : " @user)


Before:  {:name alice, :age 12}
After :  {}
```

----------------

`alter`将读取引用的值, 修改值, 写入修改值三个操作合并到一起. `alter`接受一个引用和一个函数, 将函数应用到应用的值上, 并将操作后的结果重新写入引用.


```clojure
(def all-users (ref {}))
(defn new-user [id login budget]
    {:id id, :login login, :budget budget, :expenses 0})

(defn add-new-user [login budget]
    (dosync
        (let [current (count @all-users)
              user (new-user (inc current) login budget)]
            (alter all-users assoc login user))))
```

```clojure
(add-new-user "alice", 120)

; {"alice" {:id 1, :login "alice", :budget 120, :expenses 0}}
```


```clojure
(add-new-user "bob", 240)
; {"alice" {:id 1, :login "alice", :budget 120, :expenses 0}, "bob" {:id 2, :login "bob", :budget 240, :expenses 0}}
```

------------------

`commute`与`alter`的输入是一样的, 但与`alter`不同的地方在于: 

当多个线程同时修改引用时, `alter`会检查是否发生冲突, 并最终导致只有1个线程修改成功, 其余线程修改失败.

但如果两次修改可交换(即两者的先后顺序不重要, 例如两次计数器累加操作), 则可以改为使用`commute`


agent
------------

Clojure提供一种称为代理（agent）的特殊结构，可以对共享可变数据进行异步和独立更改。

使用`agent`创建代理, 使用deref解除引用(或者使用@宏)


```clojure
(def cpu-time (agent 0))
@cpu-time

; 0
```

------------------------

代理在对特定状态的更改必须以异步方式进行时很有用。这些更改通过发送一个动作（常规的Clojure函数）给代理进行，这个动作将在以后于单独的线程上运行。


```clojure
(send cpu-time + 700)

; #agent[{:status :ready, :val 700} 0x7ad38df0]
```

send操作将请求提交到一个固定大小的线程池中. 如果线程池未满, 则函数立即返回. 在之后的一段时间, Clojure会调度执行对应的函数, 在执行完毕之前, 解引用依然返回旧的值.

如果提交时线程池已满, 则会阻塞send函数. 如果希望不被阻塞, 可使用send-off操作. send-off将函数提交到一个无界的线程池中, 因此永远不会阻塞.

向代理提交操作后, 可使用await或者await-for等待代理执行完毕. 

如果代理执行错误, 可以使用`agent-error`获取错误的原因. 一旦代理出现执行错误, 则后续所有的操作都是错误状态, 且代理的值也不会变换. 使用`clear-agent-errors`可以清除代理的错误状态.

> 注意send函数并未以`!`结尾, 因此如果事务回滚, 则send对应的操作也不会生效. 因此send具有事务安全性.

atom
-----------------

原子是Clojure中另一种可变状态管理机制。与引用不同，原子不支持事务性更新，也不支持乐观并发控制。原子提供了一种简单的方式来管理可变状态，它使用CAS（Compare-and-Swap）操作来确保更新的原子性。原子适用于那些不需要事务性保证，但需要保证状态更新原子性的场景。

```clojure
(def total-rows (atom 42))
@total-rows
; 42

(reset! total-rows 43)
; 43

(swap! total-rows + 100)
; 143

```

validator
--------------

在创建引用, 代理或原子变量时支持添加一个校验器, 当条件不满足时抛出异常

```clojure
user=> (def non-negative (atom 0 :validator #(>= % 0)))
#'user/non-negative

user=> (reset! non-negative 42)
42

user=> (reset! non-negative -1)
Execution error (IllegalStateException) at user/eval2010 (REPL:1).
Invalid reference state
```

```clojure
```

```clojure
```

watch
-----------------

在创建引用, 代理或原子变量时支持添加监视器, 使得一个变量发生变更时, 调用指定的函数

```clojure
(def adi (atom 0))
(defn on-change [the-key the-ref old new]
    (println "On-Change" the-key the-ref old new))
(add-watch adi :adi-watcher on-change)


(swap! adi inc)
; On-Change :adi-watcher #atom[1 0x67ee9052] 0 1
; 1

(remove-watch adi :adi-watcher)
; #atom[1 0x67ee9052]
```


future
-------------

future是代表在不同线程上执行的函数结果的一个对象. 

```clojure
(defn slow-c [M N]
    (Thread/sleep 2000)
    (* M N))

(defn long-run []
    (let [x (slow-c 11 13)
          y (slow-c 13 17)
          z (slow-c 17 19)]
        (* x y z)))


(time (long-run))

; "Elapsed time: 6000.576719 msecs"
; 10207769
```

```clojure
(defn fast-run []
    (let [x (future (slow-c 11 13))
          y (future (slow-c 13 17))
          z (future (slow-c 17 19))]
        (* @x @y @z)))

(time (fast-run))

; "Elapsed time: 2006.047192 msecs"
; 10207769
```

使用future可以创建一个独立的线程运行给定的函数并返回一个future对象. 该操作会立刻返回. 

当后续对future进行解引用时, 会阻塞线程, 直到对应的操作执行完毕.

可以使用如下的一些方法对future进行控制

函数            | 效果
----------------|-----------
future?         | 判断一个对象是否是future对象
future-done?    | 判断是否计算结束
future-cancel?  | 如果future尚未开始则撤销操作, 否则不进行任何操作


promise
------------

promise是代表将在未来某个时点交付的一个值的对象. 可以创建一个promise对象后, 在一个线程中提交值, 在另一个线程中读取, 从而实现线程间通信.

使用`deliver`函数投递值. 使用解引用读取值. 如果promise还未被投递值, 则当前线程阻塞.

> 不要在REPL上解引用promise, 会导致阻塞



并行计算
==============

Clojure的函数式模式天然的适合并行计算, 许多代码仅需要简单替换即可实现并行, 例如



```clojure
(ns sum.core
    (:require [clojure.core.reducers :as r]))

(defn sum [numbers]
    (reduce + numbers))

(defn psum [numbers]
    (r/fold + numbers))

(def numbers (into [] (range 0 10000000)))
```


```clojure
(time (sum numbers))
; "Elapsed time: 806.0037 msecs"

(time (psum numbers))
; "Elapsed time: 397.8081 msecs"
```

注意: 由于并发模式具有一定的固定成本, 因此在不同设备上的执行情况有显著差异. 以上结果来自于一台12核心的PC机. 如果在2核心设备上执行, 则通常非并发模式更快


宏系统
===========

Clojure中宏的概念与C语言中宏的概念是类似的, 即一种代码的模板, 根据输入的参数替换为对应的代码.

```clojure
; 定义宏, 使用`开始一个模板, 使用~解引用, 即在模板的对应位置使用变量实际的值
(defmacro unless [test then]
    `(if (not ~test) 
        ~then))

; 可查看一个宏的展开情况
(macroexpand '(unless (even? x) (println x)))
; (if (clojure.core/not (even? x)) (println x))  

; 使用~@可以将一个列表作为参数展开到表达式中
; 如下代码中, then是一个包含剩余参数的数组, 如果直接接引用, 会将第一个参数作为函数调用, 导致执行错误
(defmacro unless [test & then]
    `(if (not ~test) 
        (do ~@then)))

(macroexpand  '(unless (even? x) (println x) (println "done")))        
; (if (clojure.core/not (even? x)) (do (println x) (println "done")))
```

```clojure
; 宏展开时, 如果不对now进行特殊处理, 会导致解析失败, 加入#使Clojure为now生成一个随机名称, 从而避免冲突
(defmacro def-login-fn [name arg & body]
    `(defn ~name ~arg 
        (let [now# (System/currentTimeMillis)]
            (println "[" now# "]" "Call To" (str (var ~name))) 
            ~@body)))

; 注意这里参数使用数组传递, 在模板里面直接解引用, 从而巧妙的实现了与defn的表现一致
; 正是这种同态性, 保证了Clojure的宏特别灵活
(def-login-fn printname [name] 
    (println "Hello, " name))  

(printname "Li")
; [ 1717487486057 ] Call To #'user/printname
; Hello,  Li         
```
