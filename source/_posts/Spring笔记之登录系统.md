---
title: Spring笔记之登录系统
date: 2021-09-01 16:07:26
categories: Spring笔记
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



依赖
-----------

可以在创建项目的时候, 直接使用Spring Initializr加入Spring Security依赖, 也可以手动加入如下的两个依赖.


``` xml
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-config</artifactId>
    </dependency>
```


只要导入上述依赖, 即使不做任何操作, 整个Spring Web项目立即引入一个登陆页面, 其用户名为`user`, 密码为控制台打印的随机字符串.

如果希望使用指定的用户名和密码, 那么也可以在配置文件中分别设置用户名和密码, 例如

```yml
spring:
  security:
    user:
      name: blurooo
      password: 123456
```


内存数据库
--------------

Spring Security可以在内存中建立一个用户数据库, 从而实现多用户的验证和授权


```Java
    @Bean
    public UserDetailsService userDetailsService() {
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        manager.createUser(User.withUsername("user").password("123").roles("USER").build());
        manager.createUser(User.withUsername("admin").password("123").roles("ADMIN").build());

        return manager;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
```

目前的Spring Security库需要两个Bean才能实现自定义用户的功能. 其中UserDetailsService提供用户的基本信息的定义, PasswordEncoder提供数据加密算法.

上面的代码创建了两个用户, 并分别授予了`USER`权限和`ADMIN`权限, 在Spring Security的配置类中, 可以进行如下的配置来实现权限管理.

``` java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/css/*").permitAll()
                .antMatchers("/img/*").permitAll()
                .antMatchers("/js/*").permitAll()
                .antMatchers("/admin/api/**").hasRole("ADMIN")
                .antMatchers("/user/api/**").hasRole("USER")
                .anyRequest().authenticated()
                .and().formLogin().loginPage("/login.html").permitAll()
                .and().csrf().disable();
    }
}
```

- [Default Password Encoder in Spring Security 5](https://www.baeldung.com/spring-security-5-default-password-encoder)


自定义用户数据库
----------------

Spring Security支持用户自定义的用户数据库, 用户只需要自定义实现UserDetailsService类, 并将实例注册为Bean, 即可自动使用用户自定义的数据库.(内存数据库就相当于使用了内置的UserDetailsService实现类).

具体要求为, 根据数据库的实际情况, 自定义User类, 并实现UserDetails接口, 然后定义UserService实现UserDetailsService类. 最后将UserService加入`@Service`注解, 声明为Bean即可.

> 存在在数据库中的权限需要以`ROLE_`开头, 例如`ROLE_USER`




密码加密
-----------------

### 添加初始密码

如果希望在系统中存在初始用户, 那么就需要使用SQL向数据库中加入用户, 此时用户的密码应该是加密后的密码. 由于只需要少量数据, 因此可以使用Java代码直接计算, 例如

``` java
    List<String> passwords = Arrays.asList("xcf12fg3", "odj99Wdx", "9d9xs2x");
    BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
    passwords.stream().map(encoder::encode).forEach(System.out::println);
```

就可以直接得到一批密码在BCrypt算法下的加密结果, 将结果直接写入数据库即可.

> BCrypt算法通过引入一定的计算量, 使得暴力破解的难度增加


### 旧系统迁移

对于一个已有的系统, 如果原本并没有采取某种加密措施, 那么贸然的引入加密会导致原有的用户无法登陆. 针对这种问题可以采取自定义PasswordEncoder的方法.

在判断用户密码之前先判断数据库中存储的密码是否为指定的格式(例如BCrypt), 如果是, 则采用BCryptPasswordEncoder进行处理, 否则使用旧系统中的方法进行处理.
按照这种方式即可实现与原有密码的兼容.

-----

如果希望能够将原有系统中的密码都更新为Bcrypt形式的密码, 则可以考虑如下的三种情况

1. 如果原有密码为明文, 则可以直接更新数据库, 将所有密码都更新
2. 如果密码已经加密, 则可以在用户登录时进行判断, 并根据用户提交的密码更新数据库
3. 如果密码是MD5值, 则可以将MD5值直接作为明文进行更新, 之后通过将用户的密码分别计算MD5值和Bcrypt来判断是否相等




自动登录
------------

使用Spring的系统, 在浏览器不关闭的情况下, 经过认证后可以任意访问已经授权的页面, 但只要浏览器关闭以后, 之前的授权就会全部关闭, 用户需要再次登录才能访问相关页面

> 开启新的标签页或者新窗口均不会影响授权, 只有关闭浏览器才会导致授权消失


开启自动登录功能后, 可以使得浏览器关闭后, 


其他需要讨论的话题

1. Session与Cookie


默认情况下, Cookie中只包含JSESSIONID, 其中存储的用户的SessionID

===================================



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

