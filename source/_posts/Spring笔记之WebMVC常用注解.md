---
title: Spring笔记之WebMVC常用注解
date: 2019-08-12 10:39:53
categories: Spring
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



依赖配置
----------------

本文涉及的Web相关注解都需要导入如下的依赖

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
</dependency>
```

由于此项目来自于SpringBoot, 因此可以用SpringBoot相关的依赖进行统一版本控制, 否则容易造成冲突.



请求绑定
---------------

### @RequestMapping

此注解将一个HTTP请求与Controller中的一个方法进行绑定, 既可以注释在类上, 也可以注释在一个方法上, 最终的效果等于类注解和方法注解的组合. 例如

```java
@RequestMapping("/gasMeter")
public class GasMeterWeb {
    @RequestMapping("/get")
    public GasMeter getGasMeterById(String meterId) {
        return service.getGasMeterById(meterId);
    }
}
```

则访问`/gasMeter/get`时, Spring会接受HTTP请求, 并调用getGasMeterById方法. 

-----------

除了简单的字符串匹配以外, @RequestMapping还支持多种匹配方式, 具体方法可以参考以下的文章

- [超详细 Spring @RequestMapping 注解使用技巧 ](https://www.oschina.net/translate/using-the-spring-requestmapping-annotation?lang=chs&p=1)


请求参数绑定
---------------

### @RequestParam

此注解用于绑定HTTP请求中提供的参数. 无论是以GET请求发送的参数, 还是以POST请求发送的参数, 此注解都可以提取相应的参数.

注意: 无论以GET方式发送数据, 还是以POST方式发送数据, 都应该将`Content-Type`设置为`application/x-www-form-urlencoded`. 对于浏览器而言, 这是默认值, 但其他的第三方库不一定满足此要求. 

如果HTTP中的参数名称和方法中的参数名称相同, 则可以省略此注解.


### @RequestBody

此注解用于HTTP请求发送的JSON对象和Java对象之间的绑定. 当HTTP请求发送JSON对象是, 应该将`Content-Type`设置为` application/json`. 当Controller接收到JSON对象后, 会自动完成JSON和Java对象的转换.

对于非JSON格式的数据, 只要位于HTTP Body之中, 也可以使用此注解提取参数.


### @PathVariable

此注解用于路径变量与函数参数的绑定, 即绑定@RequestMap中使用大括号定义的变量和方法中的变量. 例如

``` java
@GetMapping("/{id}")
public User findById(@PathVariable("id") Long id)
```

如果两个变量的名称是一致的, 那么@PathVariable就不必在指定大括号定义的变量的名称.


### 默认行为与语义

首先, @RequestParam注解通常情况下有没有都不影响使用. 除非需要绑定不同的名称, 否则按照名称绑定GET参数是默认行为, 其次, 通常POST方法与@RequestBody绑定使用, 此时需要将对象的字段转化为JSON格式并放置到HTTP Body之中. 这种方法在HTTP Body之中只能放置一个对象, 因此函数接口上也只能有一个参数有@RequestBody注解. 

在实践上, 一般传递少量简单对象时, 使用GET方法+直接定义参数, 需要传递大量复杂对象时, 使用POST方法+@RequestBody注释的对象.


### 参考文献和扩展阅读
- [Spring mvc中Controller参数绑定注解详解](https://blog.csdn.net/iwillbeaceo/article/details/72878114)
- [【SpringMVC学习05】SpringMVC中的参数绑定总结](https://blog.csdn.net/eson_15/article/details/51718633)


响应参数绑定
-------------------

### @ResponseBody

此注解表示将返回值放入HTTP的请求体中. 默认情况下, Controller返回的是视图的名称, 使用此注解后, 控制器返回的结果将直接转化为字符串, 并放入到HTTP Response Body之中. 在字符串转化过程中, 可能涉及到Java对象与JSON对象的转化.



其他组合注解
--------------

### @RestController

@RestController相当于@Controller和@ResponseBody, 因此当Controller中返回一个对象时, 会自动将其转化为JSON, 并放入HTTP Body之中.

### @GetMapping系列

对于HTTP的GET, POST等方法, 都提供了一个特殊化的注解, 例如@GetMapping就等于@RequestMapping(method = {RequestMethod.GET})


Spring参数绑定过程
----------------------

虽然经过上述的归纳, 各种注解在语义上没有理解的障碍, 但如果想要搞清楚各个注解具体有什么效果, 默认情况下相当于什么注解, 那么还是需要从Spring的参数绑定过程入手.

这一部分的内容正在学习之中, 可以参考以下的一些文章
    
- https://blog.csdn.net/eson_15/article/details/51718633
- https://blog.csdn.net/iwillbeaceo/article/details/72878114
- https://blog.csdn.net/u013310119/article/details/79776708
