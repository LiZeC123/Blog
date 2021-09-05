---
title: Spring笔记之基础知识
date: 2021-09-01 16:07:22
categories: Spring笔记
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



本文介绍Spring体系中Spring framework的主要内容, 包括Spring的两个核心概念, 即控制反转(Inversion of Control, IoC)和面向切面编程(Aspect Oriented Programming, AOP). 这些内容是Spring的基础知识, 被广泛的应用在其他的模块之中.


IoC
---------------

### 创建Bean

Spring中有两种基于注解的方式创建Bean, 具体使用功能的注解效果如下所示

注解            | 注解对象       | 效果
----------------|---------------|---------------------------------------------------------
@Component      | 类            | 表示此类需要装配到IoC容器之中
@ComponentScan  | 类            | 自动扫描包含@Component的类并且将其装配到IoC容器之中
@Configuration  | 类            | 表示此类是一个配置类, 配合@Bean来创建Bean
@Bean           | 方法          | 配置类中使用, 表示此方法的返回值需要装配到IoC容器之中

@ComponentScan不带参数时扫描当前包和其子包, 可以额外指定其扫描的表的位置. 通过includeFilters和excludeFilters可以指定需要扫描的类的条件或者需要排除的类的条件.

被@Configuration注解的类本身也会声明为一个Bean.

以下代码演示使用上述两种方式创建Bean.

``` java
@Configuration
@ComponentScan
public class DAOConfig {
    @Bean(destroyMethod="close")
    public BasicDataSource dataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        dataSource.setUrl(url);
        dataSource.setDriverClassName(driverClassName);
        dataSource.setMaxIdle(maxIdle);
        return dataSource;
    }
}

@Component
public class User {
    private Long id;
    private String userName;
    private String note;
}

```

使用@Component生成的Bean的名称是首字母小写的类名, 使用@Bean生成的类的名称是对应的方法的名称. 因此上述代码中分别创建了名为basicDataSource和user的Bean. 此外也可以给上述两个注解提供一个字符串来指定为需要的名称.


### 注入Bean

Spring中可以使用@Autowired进行注入, 此注解按照类型寻找合适的Bean, 因此当前的系统中有且只能有一个类与需要注入的类符合. 例如以下的代码通过此标签注入了之前声明的DataSource.


``` java
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    private DataSource dataSource;

    @Autowired
    public WebSecurityConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    // ...
}
```

@Autowired可以注解在属性, 构造方法和setter方法上, 但是推荐注解在构造方法或setter方法上.

### 消除歧义

由于@Autowired按照类型注入, 因此如果需要注入的类型在系统中存在多个实现, 则注入时有多个选择, 从而无法自动注入. 因此Spring提供了@Primary和@Quelifier两个注解, 用于消除歧义

注解            |  效果
----------------|---------------------------------------------------------
@Primary        | 如果多个可选类中只有一个类有此注解, 则使用此注解对应的类
@Quelifier      | 与@Autowired一同使用, 通过类型和名称共同确定一个Bean

如果有多个可选的了类都标记了@Primary, 则依然无法自动注入.

### 注入常量

Spring中可以使用@Value注入一个常量, 常量值通常来自配置文件, 但也可以通过Spring EL表达式获得计算结果或者系统属性. 

``` java
// 如果出现编码问题, PropertySource可以指定编码方式
@PropertySource("classpath:database.properties")
public class DAOConfig {
    @Value("${dbcp.username}")
    private String username;
    @Value("${dbcp.password}")
    private String password;

    // ...
}
```

其中`${...}` 对应一个配置文件中的属性. @PropertySource将指定的配置文件加入到Spring的环境之中. 

Spring EL表达式大致有如下的集中用法

示例                                | 效果
------------------------------------|---------------------------
`#{'Some String'}`                  | 获得一个字符串
`#{3.1415}`                         | 注入一个数字
`#{T(System).currentTimeMillis()}`  | 调用函数获得返回值
`#{user.name}`                      | 引用bean的属性
`#{23+321}`                         | 数值计算
`#{user.name eq 'admin'}`           | 字符串比较

如果调用java.lang.*中的方法, 可以直接写类名, 调用其他方法需要写全限定名. 

更多关于Spring EL表达式的内容, 可以阅读官方文档的[Language Reference](https://docs.spring.io/spring/docs/5.1.3.RELEASE/spring-framework-reference/core.html#expressions-language-ref)

### Bean作用域

Spring中的Bean有如下几种作用域

类型        | 使用范围          | 说明
------------|------------------|-------------------------------------
singleton   | 所有Spring应用    | 默认值, 单例模式
prototype   | 所有Spring应用    | 每次都会创建新的Bean
session     | Spring Web应用    | 一次HTTP会话保存唯一
application | Spring Web应用    | 整个Web工程的生命周期保持唯一

通常, application与singleton效果相同, 因此使用singleton来代替.

如果希望改变Bean的作用域, 可以使用@Scope注解. 以下代码演示将一个Bean设置为prototype作用域.

``` java
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
//    @Scope(WebApplicationContext.SCOPE_SESSION) 
public class ScopeBean {
    // ....
}

```
如果使用Spring MVC, 则可以使用 WebApplicationContext 的有关属性. 


AOP
--------------

AOP的作用是在指定的一个切面前后加入一部分代码, 从而在不干扰原有业务逻辑的基础上, 提供额外的功能. 例如在于数据库的操作过程中, 业务逻辑可以只负责数据的查询, 如何开启数据库连接以及如何关闭连接由框架通过AOP技术完成.

使用AOP功能需要引入aspectjrt(提供基本功能)和aspectjweaver(提供Advice相关功能)

### AOP基本概念

AOP涉及如下的一些基础概念, 具体如下

名称    | 英文名称      | 含义
--------|---------------|--------------------------------------------------
连接点  | join point    | 被拦截的对象, Spring只支持方法
切点    | point cut     | 通过规则定义的一组连接点
通知    | advice        | 在拦截对象之前,之后等条件下执行的方法

### 创建切面

使用@Aspect来表明一个类是切面的配置类. 由于切面的配置类需要成为一个Bean才能使用, 因此通常还会加上@Configuration来将其声明为一个配置类. 此外还可以使用@EnableAspectJAutoProxy使得多个切面时, 能使用自动代理使得这些切面都能执行.

在切面配置类中可以使用@Before, @After, @AfterReturning, @AfterThrowing等注解来添加功能, 各注解功能如下

注解                | 功能
--------------------|---------------------------------------------------------
@Before             | 此注解修饰的方法在注解指定的方法**调用之前**执行
@After              | 此注解修饰的方法在注解指定的方法**调用之后**执行
@AfterReturning     | 此注解修饰的方法在注解指定的方法**正常返回后**执行
@AfterThrowing      | 此注解修饰的方法在注解指定的方法**抛出异常后**执行

以下代码演示如何使用上述注解创建切面

``` java
@Configuration
@EnableAspectJAutoProxy
@Aspect
public class AOPConfig {
    @Before("execution(* top.lizec.web.UserWeb.listUser(..))")
    public void before(){

        System.out.println("Do Something Before ...");
    }
}

```

其中的`execution`表示在方法执行的时候拦截, `*`表示任意返回值, `top.lizec.web.UserWeb`是拦截对象的全限定名, `listUser`是拦截方法的名称, `(..)`表示任意参数.

### 创建切点

直接使用@Before等注解创建切面时, 可能有很多注解都需要拦截同一个连接点, 从而导致同一的条件写多次. 此时可以使用切点绑定一个条件, 之后的注解都引用这个切点.

切点通过@Pointcut注解创建, 注解在方法上. 注解的方法不需要有实际内容, 仅仅起到提供名称的作用, 其他的注解直接引用这个方法的名称来表示引用此切点. 以下代码演示如何通过切点进行拦截

``` java
@Configuration
@EnableAspectJAutoProxy
@Aspect
public class AOPConfig {    
    @Pointcut("execution(* top.lizec.web.UserWeb.listUser(..))")
    public void cutListUser() { }
    
    @After("cutListUser()")
    public void doAfter() {
        System.out.println("Do Something After ...");
    }
}
```

### 环绕执行

除了上述提到的在拦截方法前后执行的注解以外, Spring还提供了一种环绕执行模式. 在该模式下使用新的方法替代原有的方法, 并且提供了一个调用原来方法的机制. 以下代码演示环绕执行

``` java
@Around("@within(org.springframework.web.bind.annotation.RestController)")
public Object printReceiveLog(final ProceedingJoinPoint joinPoint) throws Throwable {
    joinPoint.getSignature().toShortString();
    receiveLogger.info(()->"Receive request in "+joinPoint.getSignature().toShortString());
    return joinPoint.proceed();
}
```

### 切面执行顺序

当有多个切面时, 其执行顺序是随机的, 可以使用@Order来指定切面的执行顺序. @Order需要一个数字参数, 数字越小, 优先级越高. 

各个切面嵌套执行, 即执行before时, 数字越小越先执行, 执行after时, 数字越大越先执行

### AOP 表达式

以下是一些常见的AOP 表达式

表达式              | 含义
--------------------|-------------------------------------------------------------------
`excution(...)`     | 表示一个方法执行是拦截, 可以使用*匹配任意字符, 使用(..)表示任意参数
`target(...)`       | 指定一个接口, 拦截所有实现此接口的类的全部方法
`@target(...)`      | 指定一个注解, 拦截所有被指定注解修饰的方法
`@within(...)`      | 指定一个注解, 拦截被指定注解修饰的类的全部方法


关于AOP 表达式的详细规则可以查阅Spring文档中的[Aspect Oriented Programming with Spring](https://docs.spring.io/spring/docs/5.1.3.RELEASE/spring-framework-reference/core.html#aop-pointcuts)章节


MVC架构
---------------

通常情况下, MVC项目按照如下的结构放置代码

包名        |  注解          | 内容
------------|---------------|-------------------------------
controller  | @Controller   | MVC的控制器
service     | @Service      | 业务逻辑有关的代码
mapper      | @Repository   | 数据映射相关的代码
entity      | N/A           | 业务实体类
conf        | @Configuration| 配置类


控制器接受到请求后, 首先完成请求参数的处理, 然后调用service层的方法实现业务逻辑. service层通过mapper层提供的数据库方法完成需要的业务逻辑. mapper层通常由框架实现具体的操作, 因此仅仅需要提供方法声明, 然后使用配置文件配置具体的行为. 

关于Spring Web的基础知识 , 还可以参考以下的内容
- [Spring Mybatis Maven 项目搭建（Java配置）](https://blog.csdn.net/w1196726224/article/details/52784588)
- [关于web.xml配置的那些事儿](https://segmentfault.com/a/1190000011404088)
