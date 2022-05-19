---
title: Spring笔记之Web开发
date: 2021-09-01 16:07:24
categories: Spring
tags:
    - Spring
cover_picture: images/spring.jpg 
---




在Spring中, 最常使用的技术就是MVC框架, 使用Sping中的MVC框架, 可以实现将HTTP URL 映射到Controller某个方法上, 将HTTP 参数映射到Controller方法的参数上, 对参数进行检验, 调用视图等功能. 



请求绑定
-------------------

在Controller层, 首先需要使用@Controller注解将当前类声明为一个控制器, 然后使用@RequestMapping注解来实现HTTP请求与方法之间的映射. @RequestMapping既可以注解在类上, 也可以注解在方法上, 最终的路径由类上的注解和方法上的注解共同决定.  例如

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


> 除了简单的字符串匹配以外, @RequestMapping还支持多种匹配方式

- [超详细 Spring @RequestMapping 注解使用技巧 ](https://www.oschina.net/translate/using-the-spring-requestmapping-annotation?lang=chs&p=1)


--------------------------------


默认情况下, 被注解的方法应该返回一个字符串, 表示需要返回的视图的名称. 但如果只需要返回字符串, 则可以加上@ResponseBody注解, 从而表示系统应该讲返回值转为为字符串, 然后直接返回给客户端. 示例如下所示:

``` java
@RequestMapping("/index.json")
public @ResponseBody String say() {
    return "Hello World";
}
```

如果整个类都是直接返回字符串, 则可以使用@RestController替换原来的@Controller, 这相当于给每个方法都加上@ResponseBody.


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



### 其他特殊参数

对于控制器中的方法, 可以定义为无参数的方法, 也可以定义为如下的一些类型, Spring会自动将这些变量注入当方法之中.


参数类型             | 含义                           | 参数类型             | 含义
--------------------|--------------------------------|---------------------|---------------------------------
MultipartFile       | 代表上传的文件                  | @RequestHeader      | 将HTTP头部的参数转化为指定的类型
Model               | 表示视图中使用的Model部分        | ModelAndView        | 包含模型和视图的对象
@ModelAttribute     | 将注解的变量作为Model的一个属性   | JavaBean            | 将HTTP参数映射为指定的JavaBean
HttpServletRequest  | 代表HTTP Request                | HttpServletResponse | 代表HTTP Response


### 参考文献和扩展阅读
- [Spring mvc中Controller参数绑定注解详解](https://blog.csdn.net/iwillbeaceo/article/details/72878114)
- [【SpringMVC学习05】SpringMVC中的参数绑定总结](https://blog.csdn.net/eson_15/article/details/51718633)


响应参数绑定
-------------------

### @ResponseBody

此注解表示将返回值放入HTTP的请求体中. 默认情况下, Controller返回的是视图的名称, 使用此注解后, 控制器返回的结果将直接转化为字符串, 并放入到HTTP Response Body之中. 在字符串转化过程中, 可能涉及到Java对象与JSON对象的转化.



组合注解
--------------

Spring提供了一些组合组件，从而减少在逐渐上的重复代码

### @RestController

@RestController相当于@Controller和@ResponseBody, 因此当Controller中返回一个对象时, 会自动将其转化为JSON, 并放入HTTP Body之中.

### @GetMapping系列

对于HTTP的GET, POST等方法, 都提供了一个特殊化的注解, 例如@GetMapping就等于@RequestMapping(method = {RequestMethod.GET})



转发和重定向
-------------------

通常情况下, Controller返回表示视图的字符串. 但如果返回一个以`redirect:`为前缀的URL, 则表示重定向到指定的URL. 例如

``` java
@RequestMapping("/order/saveorder.html")
public String saveOrder(Order order) {
    Long orderId = service.addOrder(order);
    return "redirect:/order/detail.html?orderId="+orderId;
}
```

同理, 返回一个以`foward:`为前缀的URL, 则表示转发到指定的URL.
