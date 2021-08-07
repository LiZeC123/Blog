---
title: 样式测试
theme: solarized
revealOptions:
    transition: 'fade'
---


# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
正文


---



## Java小知识


----


一些Java对象的名称
-------------------

名称| 全称              | 含义
----|-------------------|-------------------------------------
PO | Persistent Object | 对应数据库记录的Java对象
VO | Value Object      | 业务层之间传递数据的的对象
DAO| Data Access Object| 控制数据库访问的对象, 通常与PO结合
BO | Business Object   | 封装业务逻辑的对象, 调用DAO的方法 



----



序列化ID
--------------

- serialVersionUID 用于标记序列化类的版本,
- 如果对类进行了修改, 那么也应该同步的修改serialVersionUID. 
- IDEA可以直接提供随机值.

---

手动检查Null
-----------------

手动检查是否为Null, 并手动抛出NullPointException可以视为一种防御性编程, 即如果可能发生错误, 则应该尽可能早的产生.

---

Lombok
--------

- [lombok](https://www.projectlombok.org/features/all)
    - @Slf4j 自动生成LOG对象

---

JDK
---------------

Note:
前几天更新Intellij IDEA的时候发现, 新版本已经支持JDK 11了, 于是下载了JDK 11 体验了一下. 相较于JDK 8, JDK 11的改动比较大, 目前很多第三方库还没有针对JDK 11做调整, 因此不建议直接把JDK升级, 最好还是先同时保留JDK 8 和JDK 11.

---

### JDK 新特性介绍

- [Java 9 新特性概述](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-9/index.html)
- [Java 10 新特性介绍](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-10/index.html)
- [Java 11 新特性介绍](https://www.ibm.com/developerworks/cn/java/the-new-features-of-Java-11/index.html)

---

### Math

$$
\textrm{padSize} = \lceil \log_{10}(\mathbf{arraySize} + 1) \rceil
$$

---

### Char

```chart
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```