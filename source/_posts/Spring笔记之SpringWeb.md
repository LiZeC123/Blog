---
title: Spring笔记之Spring Web
date: 2018-12-23 16:18:01
categories: Spring
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



在Spring中, 最常使用的技术就是MVC框架, 使用Sping中的MVC框架, 可以实现将HTTP URL 映射到Controller某个方法上, 将HTTP 参数映射到Controller方法的参数上, 对参数进行检验, 调用视图等功能.

本文涉及的代码均来自一个Spring Web项目 [fuelGasSystem](https://github.com/LiZeC123/fuelGasSystem), 此项目已经开源在Github上, 欢迎交流.


基础知识
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


Spring MVC配置
----------------------

首先导入需要的依赖

``` xml
<!-- https://mvnrepository.com/artifact/org.springframework/spring-webmvc -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>5.1.1.RELEASE</version>
</dependency>
```

之后进行配置, 首先创建一个conf包, 然后创建一个SpringInitializer类, 这个类需要继承AbstractAnnotationConfigDispatcherServletInitializer类, 并且重载其中的三个方法, 代码如下所示

``` java
package top.lizec.config;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

public class SpringInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
    protected Class<?>[] getRootConfigClasses() {
        return new Class[]{DAOConfig.class, WebSecurityConfig.class};
    }

    protected Class<?>[] getServletConfigClasses() {
        return new Class[]{SpringWebConfig.class};
    }

    protected String[] getServletMappings() {
        return new String[]{"/"};
    }
}

```

可以看到, 代码中引用了另外三个类, 分别是DAOConfig, WebSecurityConfig和SpringWebConfig. 这三个类都是之后需要创建的, 从名称可以容易的指导它们分别用于配置数据访问, 访问安全和Spring web.

首先创建SpringWebConfig, 并且使其实现WebMvcConfigurer接口. 从Java 8开始, 接口可以提供默认实现, 因此WebMvcConfigurer中以及包含了很多默认的实现, 但同时我们也可以对默写感兴趣的部分进行实现,从而替换默认的实现, 代码如下所示

``` java
package top.lizec.config;

// 省略import语句

@Configuration
@EnableWebMvc
@ComponentScan("top.lizec")
public class SpringWebConfig implements WebMvcConfigurer {
    // 如果不添加此转换,则无法访问静态文件
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/**").addResourceLocations("/");
        //registry.addResourceHandler("/static/**").addResourceLocations("/static/");
        //registry.addResourceHandler("*.html").addResourceLocations("/");
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 将指定的URL请求转发到指定的视图
        // 是一种简化控制器的方法
        registry.addViewController("/login").setViewName("login");
    }
}
```

其中@Configuration表示这是一个配置文件, @EnableWebMvc表示开启Web MVC的支持, @ComponentScan("top.lizec")指定了需要扫描的包路径.

在SpringWebConfig中主要实现了两个方法, 其中第一个方法完成对静态资源的处理, 第二个方法完成对视图控制器的一些基本处理. 关于WebMvcConfigurer的更多配置可以参考以下的内容
- [使用WebMvcConfigurer配置SpringMVC](https://www.jianshu.com/p/52f39b799fbb)


Controller层配置
-------------------

在Controller层, 首先需要使用@Controller注解将当前类声明为一个控制器, 然后使用@RequestMapping注解来实现HTTP请求与方法之间的映射. @RequestMapping既可以注解在类上, 也可以注解在方法上, 最终的路径由类上的注解和方法上的注解共同决定.

默认情况下, 被注解的方法应该返回一个字符串, 表示需要返回的视图的名称. 但如果只需要返回字符串, 则可以加上@ResponseBody注解, 从而表示系统应该讲返回值转为为字符串, 然后直接返回给客户端. 示例如下所示:

``` java
@RequestMapping("/index.json")
public @ResponseBody String say() {
    return "Hello World";
}
```

如果整个类都是直接返回字符串, 则可以使用@RestController替换原来的@Controller, 这相当于给每个方法都加上@ResponseBody.

### 方法参数

对于控制器中的方法, 可以定义为无参数的方法, 也可以定义为如下的一些类型, Spring会自动将这些变量注入当方法之中.


参数类型             | 含义                           | 参数类型             | 含义
--------------------|--------------------------------|---------------------|---------------------------------
@RequestParam       | 将HTTP请求的参数转化为指定的类型  | @RequestHeader      | 将HTTP头部的参数转化为指定的类型
Model               | 表示视图中使用的Model部分        | ModelAndView        | 包含模型和视图的对象
@PathVariable       | 将URL中的值映射到指定的变量       | JavaBean            | 将HTTP参数映射为指定的JavaBean
@ModelAttribute     | 将注解的变量作为Model的一个属性   | MultipartFile       | 代表上传的文件
HttpServletRequest  | 代表HTTP Request                | HttpServletResponse | 代表HTTP Response


### 转发和重定向

通常情况下, Controller返回表示视图的字符串. 但如果返回一个以`redirect:`为前缀的URL, 则表示重定向到指定的URL. 例如

``` java
@RequestMapping("/order/saveorder.html")
public String saveOrder(Order order) {
    Long orderId = service.addOrder(order);
    return "redirect:/order/detail.html?orderId="+orderId;
}
```

同理, 返回一个以`foward:`为前缀的URL, 则表示转发到指定的URL.

### 错误处理

在Spring中产生的错误, 需要在Web.xml进行配置(目前似乎还无法进行Java配置), 将以下的内容放置到`<web-app>`标签内

``` xml
<error-page>
    <location>/error</location>
</error-page>
```

在Spring Boot中默认加入了此配置, 因此不需要有以上的操作. 完成以上配置后, Spring产生的操作, 将由`/error`处理. 通过实现一个处理`/error`的Controller, 即可完成错误处理.

Spring提供了一个AbstractErrorController, 继承此类可以增强错误处理能力, 代码如下所示

``` java
@Controller
public class ErrorController extends AbstractErrorController {
    public ErrorController() {
        super(new DefaultErrorAttributes());
    }

    @RequestMapping("/error")
    public ModelAndView getErrorPath(HttpServletRequest request, HttpServletResponse response) {
        // 处理异常
    }
}
```


Service层配置
----------------
在Spring中业务逻辑应该集中在Service层进行处理, 与Controller层类似, Service层有两个主要的注解, @Service和@Transaction. 

@Service用于声明这是一个Bean, 从而可以注入到Controller层中. 

@Transaction表示相关的操作放到一个事务之中, 如果方法正常结束则提交事务, 如果方法抛出RuntimeException, 则进行回滚. @Transaction可以标记在一个类上, 表示所有的方法都需要进行事务管理, 也可以只标记在一个方法上, 这样就只对标记的方法进行事务管理.


其他杂项配置
----------------

### JSON转换器配置

首先导入需要的依赖

``` xml
<!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-databind -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.9.8</version>
</dependency>
```

之后在SpringWebConfig中配置如下的Bean

``` java
@Bean
public HandlerAdapter initRequestMappingHandlerAdapter() {
    RequestMappingHandlerAdapter rmhd = new RequestMappingHandlerAdapter();
    // HTTP JSON转换器
    MappingJackson2HttpMessageConverter jsonConverter = new MappingJackson2HttpMessageConverter();
    //MappingJackson2HttpMessageConverter接收JSON类型消息的转换
    MediaType mediaType = MediaType.APPLICATION_JSON_UTF8;
    List<MediaType> mediaTypes = new ArrayList<>();
    mediaTypes.add(mediaType);
    jsonConverter.setSupportedMediaTypes(mediaTypes);
    rmhd.getMessageConverters().add(jsonConverter);
    return rmhd;
}
```

加入以上的代码以后, 在控制器中如果返回一个非String的对象, 则Spring会使用此处定义的转化器将对象转化为JSON字符串.

如果希望将JSON字符串转化为Java对象, 则可以使用jackson提供的ObjectMapper类, 具体过程如下

``` java
final ObjectMapper mapper = new ObjectMapper();
try {
    GasMeter meter = mapper.readValue(jsonString,GasMeter.class);
    // 解析成功 ...
} catch (Exception e) {
    // 解析失败 ...
    e.printStackTrace();
}
```

注意, 如果希望解析过程中忽略一些Java对象中不存在的属性, 可以在相应的Java对象上加入`@JsonIgnoreProperties(ignoreUnknown = true)`注解



### Log4j日志配置

在Spring中, 默认使用了SLF4J(Simple logging facade for Java)日志接口. 因此只要提供了相应的实现, 就可以获得更过关于Spring的日志输出. 而且在自己的代码中也可以使用同样的日志模块. 想要实现日志模块, 可以加入以下依赖

``` xml
<!-- https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-slf4j-impl -->
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
    <version>2.11.1</version>
</dependency>
```

然后在resources目录下创建`log4j2.xml`, 内容如下

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!--指定log4j内部日志级别-->
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </Console>
    </Appenders>
    <Loggers>
        <Root level="info">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```

由于log4j的配置文件配置法不太符合直觉, 因此此模块还是使用XML进行配置更加简单, 关于可配置的内容, 可以参考以下的内容
- [Configuration](https://logging.apache.org/log4j/2.x/manual/configuration.html#AutomaticConfiguration)
- [Log4j 2.x 配置详解及详细配置例子](https://blog.csdn.net/why_still_confused/article/details/79116565)
- [为什么要使用SLF4J而不是Log4J](http://www.importnew.com/7450.html)


在代码中, 可以使用如下的方式使用日志

``` java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class AOPConfig {
    private final Logger receiveLogger = LogManager.getLogger("ReceiveInfo");

    public Object printReceiveLog(final ProceedingJoinPoint joinPoint) throws Throwable {
        // ...
        receiveLogger.info(()->"Receive request in "+joinPoint.getSignature().toShortString());
    }
}
```


### Thymeleaf模板引擎配置

首先加入必要的依赖

``` xml
<!-- https://mvnrepository.com/artifact/org.thymeleaf/thymeleaf-spring5 -->
    <dependency>
        <groupId>org.thymeleaf</groupId>
        <artifactId>thymeleaf-spring5</artifactId>
        <version>3.0.11.RELEASE</version>
    </dependency>
```

然后在SpringWebConfig中配置如下的Bean

``` java
@Bean
public ITemplateResolver  templateResolver() {
    SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
    templateResolver.setTemplateMode(TemplateMode.HTML);
    templateResolver.setPrefix("/WEB-INF/VIEWS/");
    templateResolver.setSuffix(".html");
    templateResolver.setCharacterEncoding("utf-8");
    templateResolver.setOrder(1);

    templateResolver.setCacheable(false);
    return templateResolver;
}


@Bean
public SpringTemplateEngine templateEngine() {
    SpringTemplateEngine templateEngine = new SpringTemplateEngine();
    templateEngine.setTemplateResolver(templateResolver());
    return templateEngine;
}


@Bean
public ThymeleafViewResolver viewResolver() {
    ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
    viewResolver.setTemplateEngine(templateEngine());
    viewResolver.setCharacterEncoding("utf-8");
    return viewResolver;
}
```

虽然有三个Bean, 但是实际最终被其他模块引用的只有ThymeleafViewResolver. 以上的配置过程中, 通过templateResolver指定模板类型, 前缀, 后缀, 编码等信息, 在控制器中返回的模型名称会自动加上这里指定的前缀, 后缀信息, 组合成实际需要渲染的文件名.

在Controller中, 可以使用类似如下的代码, 使用Model给页面传递参数

``` java
@RequestMapping("/menu")
public String getMenu(Model model) {
    model.addAttribute("isAdmin", isAdmin());
    return "menu";
}
```

页面中使用功能Thymeleaf的语法接受变量, 并且根据相关的值决定页面的渲染. 关于Thymeleaf在页面中的语法, 可以参考如下的内容
- [Thymeleaf 之 内置对象、定义变量、URL参数及标签自定义属性](https://www.jianshu.com/p/661603188da5)
- [thymeleaf 基本语法](https://www.cnblogs.com/nuoyiamy/p/5591559.html)


### Spring Security

首先导入需要的依赖
``` xml
<!-- https://mvnrepository.com/artifact/org.springframework.security/spring-security-web -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-web</artifactId>
    <version>5.1.1.RELEASE</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.springframework.security/spring-security-config -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-config</artifactId>
    <version>5.1.1.RELEASE</version>
</dependency>
```

spring-security-config提供基于Java配置的有关注解, 所以如果不需要Java配置, 可以不包含此模块. 之后创建一个初始化的类, 并使其继承AbstractSecurityWebApplicationInitializer, 代码如下所示

``` java
public class SecurityWebApplicationInitializer extends AbstractSecurityWebApplicationInitializer {

}
```

不需要有任何其他的代码, 这样就完成了springSecurityFilterChain的注册. 之后创建WebSecurityConfig配置类, 代码如下

``` java

@Configuration
@EnableWebSecurity
// WebSecurityConfig也需要加入到SpringInitializer, 配置才能生效
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    private DataSource dataSource;

    @Autowired
    public WebSecurityConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Bean
    public UserDetailsService userDetailsService() {
        // password  => {bcrypt}$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzG3YB1tlRy.fqvM/BG
        // admin     => {bcrypt}$2a$10$lkz8wzmNz2CcnrWCob4RhOi6qPMtrypxjTt12k.bOrzdkiOYvcYCW
        JdbcDaoImpl manager = new JdbcDaoImpl();
        manager.setDataSource(dataSource);
        return manager;
    }

    protected void configure(HttpSecurity http) throws Exception {
        http
            .authorizeRequests()
                .antMatchers("/index.html","/favicon.ico","/css/**","/js/**").permitAll()
                .antMatchers("/user/**").hasRole("ADMIN")
                .anyRequest().authenticated()
                .and()
            .formLogin()
                .loginPage("/login")
                .permitAll()
                .and()
            .logout()
                .permitAll()
                .logoutSuccessUrl("/index.html")
                .and()
            .csrf()
                .disable()
            .rememberMe()
                .tokenValiditySeconds(86400);
    }

}
```

首先看UserDetailsService, 这是一个用户登录信息相关的类, 其中创建了一个默认的JDBC实现, 并且将一个数据源DataSource注入其中, 从而完成数据库的配置. 关于如何创建数据源, 可以阅读本系列中关于数据库的文章.

注意, 数据库的密码字段不应该直接保存密码的明文, 此处使用了bcrypt加密算法. 由于Spring Security不提供直接的注册模块, 因此关于注册以及密码加密等内容, 需要自己组合Spring的模块来实现.

再看configure方法, 此方法通过链式调用的方式实现了授权的声明, 要求一部分页面(index.html等)允许任何权限访问, 一部分页面(/user/)要求ADMIN权限, 其他所有的页面需要登录.  注意, 此处的ADMIN权限对应数据库中的`ROLE_ADMIN`字符串, ADMIN并不是特殊设置, 可以指定为任何值, 只要和数据库里面的权限名称匹配即可.


最后,关于Spring Security的详细内容, 可以参考以下内容
- [SpringSecurity学习笔记之四：拦截请求](https://blog.csdn.net/zhoucheng05_13/article/details/60467234)
- [Security with Spring tutorials](https://www.baeldung.com/security-spring)
- [Spring Security 官方文档](https://spring.io/projects/spring-security)



### curl指令

curl指令是Linux中经常使用的一个文件传输指令, 可以用来简单的模拟GET, POST等请求. 对于大部分Linux系统, 都内置了此指令. 在Windows系统中, 如果安装了git bash, 则git bash也内置了此指令.

curl指令具有如下的一些用法

用法示例                                         | 作用
------------------------------------------------|----------------------------------------
curl www.baidu.com                              | 直接发送请求并输出结果
curl -i www.baidu.com                           | 直接发送请求并且只返回头部的内容
curl URL -H "Content-Type:application/json"     | 设置请求头后发送请求
curl URL -d "param1=value1&param2=value2"       | 发送POST请求
curl URL -F "file=XXX" -F "name=YYY"            | 上传文件


注意: 如果URL或者参数中包含特殊字符, 则需要使用引号将内容包裹起来,否则shell会错误的解析指令的内容.

Chrome的postman插件也可以完成curl的功能, 如果能够安装此插件, 则可以完全图形化地完成上述的操作.
