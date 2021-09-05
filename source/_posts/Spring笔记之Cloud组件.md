---
title: Spring笔记之Cloud组件
date: 2021-09-01 16:07:25
categories: Spring
tags:
    - Spring
cover_picture: images/spring.jpg 
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



由于Spring Cloud涉及的组件太多, 各个组件之间的依赖关系比较复杂, 因此为了保证项目的一致性, 任何时候都不建议手写这些配置文件. 可以使用SpringBoot官网上的[Spring Initializr](https://start.spring.io/)来获得初始项目的结构和pom文件. 如果使用IDEA, 也可以在创建的时候使用Spring Initializr工具创建项目.




Actuator
-------------------------


配置项    |  值
----------|----------------------------------------------------
依赖      | `spring-boot-starter-actuator`
配置属性  | `management.endpoint.health.show-details=always`


在新版本的Actuator中, 默认显示的信息很少, 需要在配置上表的属性, 才可以显示完整的信息. 配置完成后, 就可以直接访问项目的`/actuator/health`路径, 获取项目的健康状态.


此外还可以在配置文件中, 以`info.*`的方式引入任意属性, 例如

``` yml
info:
  app:
    name: @project.artifactId@
    encoding: @project.build.sourceEncoding@
    java:
      source: @java.version@
      target: @java.version@
```

之后就可以访问项目的`/actuator/info`路径获得这些信息.

-------------

- [SpringBoot2.x中Actuator的health响应信息不完整的解决方法](https://blog.csdn.net/jy1690229913/article/details/85227453)




Eureka
-------------

Eureka是服务发现组件, 各个微服务启动的时候, 将自己的信息注册到Eureka Server上, 从而由Eureka提供的管理.


配置项            |  值
-----------------|----------------------------------------------
服务端依赖        | `spring-cloud-starter-netflix-eureka-server`
客户端依赖        | `spring-cloud-starter-netflix-eureka-client`



### Eureka Server
对于服务器端, 在启动Class上加上注解`@EnableEurekaServer`并且在配置文件中添加如下的配置
``` yml
server:
  port: 8761
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: http://localhost:8761/eureka
```

`register-with-eureka`表示是否把自己注册到Eureka Server, `fetch-registry`表示是否从其他Eureka Server获得信息, 当Eureka以单节点方式启动时, 这两个配置都需要置为flase
`defaultZone`表示与Eureka Server交互的地址, 可以加入以逗号分隔的多个地址

### Eureka Client
对于客户端, 在启动Class上加上注解`@EnableDiscoveryClient`并且在配置文件中添加如下的配置
```yml
spring:
  application:
    name: microservice-consumer-movie
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
  instance:
    prefer-ip-address: true
```

`spring.application.name`用于给这个微服务指定一个名称, 此名称将会显示在Eureka的管理页面上, 并且作为其他微服务调用此微服务的依据.
`service-url`指定Eureka Server的位置. `prefer-ip-address`表示优先将IP地址注册到Eureka Server, 否则注册微服务所在操作系统的hostname.

### 高可用Eureka Server

通过加入多个Eureka Server节点可以实现Eureka Server的高可用.


``` yml
spring:
  application:
    name: microservice-discovery-eureka-ha
---
spring:
  profiles: peer1
server:
  port: 8761
eureka:
  instance:
    hostname: peer1
  client:
    serviceUrl:
      defaultZone: http://peer2:8762/eureka
---
spring:
  profiles: peer2
server:
  port: 8762
eureka:
  instance:
    hostname: peer2
  client:
    serviceUrl:
      defaultZone: http://peer1:8761/eureka
```

以上配置文件由`---`分割成三段, 其中第一段没有指定profiles名称, 因此对所有的profile生效. 第二段和第三段的Profile分别命名为peer1和peer2. 将项目打包以后, 可以按照如下的方式启动两个不同配置的节点
```
java -jar microservice-discovery-eureka-ha-0.0.1-SNAPSHOt.jar --spring.profiles.active=peer1
java -jar microservice-discovery-eureka-ha-0.0.1-SNAPSHOt.jar --spring.profiles.active=peer2
```

多节点与单节点相比, 主要是设置hostname,并且在defaultZone指定每一个其他的Eureka节点.

对于客户端, 也只需要在`defaultZone`指定所有的Eureka Server节点即可. 由于Eureka Server节点之间会同步信息, 因此仅指定一个Eureka节点也可以满足需求, 但指定多个节点时, 稳定性更好.


### 用户认证

配置项            |  值
-----------------|----------------------------------------------
依赖             | `spring-boot-starter-security`

在配置文件中加入以下内容

``` yml
spring:
  security:
    user:
      name: user
      password: 123
```

创建一个`WebSecurityConfig`, 内容如下:

``` java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable().authorizeRequests()
                .anyRequest()
                .authenticated()
                .and()
                .httpBasic();
    }
}
```

原来的配置`security.user.name`等属性已经废弃, 现在应该使用`spring.security.user.name`. 此外, 还需要通过Java配置禁用csrf.

- [eureka配置了spring security后, 客户端启动报错, 请求不到服务器 ](https://github.com/yinjihuan/spring-cloud/issues/1)

-----
以上述配置为例, 在客户端, 将`eureka.client.serviceUrl.defaultZone`设置为`http://user:123@localhost:8761/eureka`即可访问加密的Eureka服务器.



Ribbon
----------

Ribbon是一个负载均衡器,  此项目借助于Eureka Server的信息, 可以自动将请求均衡的发送到不同的目标服务器.

配置项            |  值
-----------------|----------------------------------------------
依赖             | `spring-cloud-starter-ribbon`
负载均衡方法注解  | `@LoadBalanced`

注意: Eureka的依赖包含此依赖. 在需要使用负载均衡的RestTemplate上直接加入注解即可实现负载均衡.

``` java
@Bean
@LoadBalanced
public RestTemplate restTemplate(){
    return new RestTemplate();
}
```

通过此RestTemplate发送的请求, 将会自动具备负载均衡能力. 此时在调用端,使用微服务的名称指定需要调用的微服务.
``` java
@GetMapping("/user/{id}")
public User findById(@PathVariable Long id){
    return this.restTemplate.getForObject("http://microservice-provider-user/"+id,User.class);
}
```

Ribbon会在Eureka Service上查询指定名称的微服务, 并由此实现负载均衡.

Ribbon可以使用@Configuration进行Java配置, 使用`<clientName>.ribbon`在配置文件中进行配置. 在没有Eureka Service时, 可以使用`<clientName>.ribbon.listOfServers`来指定各个服务的URL, ribbon在这些URL的基础上实现负载均衡.

Feign
---------

Feign是一个用来提供HTTP API调用的组件. 

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-starter-openfeign`
启动类注解        | `@EnableFeignClients`

注意: feign已经被标记为废弃, 需要使用openfeign代替. 

``` java
@FeignClient(name="microservice-provider-user")
public interface UserFeignClient {
    
    @RequestMapping(value = "/{id}",method = RequestMethod.GET)
    User findById(@PathVariable Long id);
}
```
`@FeignClient`注解指定Feign需要调用的微服务的名称. 这里需要注意, 方法上的`@RequestMapping`指示的是Feign需要调用的API的URL格式. 接口类提供的方法只由其他Java类调用, 而不从网络上调用. Feign根据结构自动实现相应的网络请求功能.

在相应的Controller类上, 按照如下的方式使用
``` java
@RestController
public class MovieController {
    @Autowired
    private UserFeignClient userFeignClient;
    
    @GetMapping("/user/{id}")
    public User findById(@PathVariable Long id){
        return this.userFeignClient.findById(id);
    }
}
```

关于Feign配置和日志等内容, 参考以下文章
- [跟我学Spring Cloud（Finchley版）-10-Feign深入](http://www.itmuch.com/spring-cloud/finchley-10/)

> 注意: 在@EnableFeignClients的扫描范围内的, 被@FeignClient注解的类才会进入容器, 可以通过@EnableFeignClients指定要扫描的包名

### 回退方法
`@FeignClient`注解可以指定一个`fallback`属性, 指定一个实现了当前接口的实现类, 当相应的方法调用失败时, 改为调用实现类中的对应方法. 实现这一功能需要引入Hystrix的依赖.

此外, `@FeignClient`注解也可以指定`fallbackFactory`属性, 指定一个实现了`FallbackFactory<T>`接口的实现类. `FallbackFactory<T>`接口提供了返回T类型的方法, 从而可以直接使用匿名类的构造方式创建回退的实现类. 例如

``` java
public class BookAuthUserServiceFallbackFactory implements FallbackFactory<BookAuthUserService> {

    private static final Logger LOGGER = LoggerFactory.getLogger(BookAuthUserServiceFallbackFactory.class);

    @Override
    public BookAuthUserService create(Throwable cause) {
        LOGGER.info("fallback reason was: " + cause.getMessage());
        return new BookAuthUserService() {
            @Override
            public ResponseEntity<ResponseDto<Boolean>> checkIsHaveAuthWithServer(Long bookId, Long channelId, Long adviserId, Long wecharUserId, Long serverId) {
                return ResponseHandleUtil.toResponse(false);
            }
        };
    }
}
```

这样就可以避免同一接口有多个实现而导致的需要手动调整注入规则的问题.

### 多参数请求

方案一: 使用`@RequestMapping`和`@RequestParam`的映射功能, 有几个参数就填几个参数

``` java
@FeignClient(name="microservice-provider-user")
public interface UserFeignClient {
    @RequestMapping(value = "/getone",method = RequestMethod.GET)
    User findById(@RequestParam("id") Long id,@RequestParam("username") Long username);
}
```


方案二: 使用Map传入多个参数

``` java
@FeignClient(name="microservice-provider-user")
public interface UserFeignClient {
    @RequestMapping(value = "/getone",method = RequestMethod.GET)
    User findById(@RequestParam Map<String,Object> map);
}
```

> 注意: Feign无视@RequestMapping注解的method参数, @RequestParam不可省略, 否则始终按照POST方法发送请求

### post请求


``` java
// 服务提供者的Controller
public class UserController {
    @PostMapping("/p")
    public User post(@RequestBody User user){
    }
}

// Feign的调用方法
@FeignClient(name="microservice-provider-user")
public interface UserFeignClient {
    @RequestMapping(value = "/p",method = RequestMethod.GET)
    User findById(@RequestBody User user);
}
```

在Feign客户端, 使用`@RequestBody`将User对象添加到待发送的Request之中, 而在服务提供端, 同样使用`@RequestBody`从收到的Request中提取参数绑定到User对象.


Hystrix
----------------

Hystrix是一个断路器组件, 用于隔离远程访问体现, 防止级联失效, 从而提高系统的可用性和容错性.

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-starter-netflix-hystrix`, `hystrix-javanica`
启动类注解        | `@EnableCircuitBreaker`


``` java
@HystrixCommand(fallbackMethod = "findByIdFallback")
@GetMapping("/user/{id}")
public User findById(@PathVariable Long id){
    return this.restTemplate.getForObject("http://microservice-provider-user/"+id,User.class);
}

public User findByIdFallback(Long id){
    User user = new User();
    user.setId(-1L);
    user.setName("默认用户");
    return user;
}
```
其中`@HystrixCommand`注解来自依赖`hystrix-javanica`, 此项目是Hystrix的子项目, 主要用于简化Hystrix的使用.

在`/actuator/health`可以查看Hystrix的状态. 注意, 一次调用失败并不会导致Hystrix的状态变为`CIRCUIT_OPEN`, 只有达到了阈值(默认5秒内失败了20次)后才会变为`CIRCUIT_OPEN`状态.

进入开启状态一段时间以后, Hystrix进入半开状态, 此时只要发生了一次调用成功, 则会进入关闭状态, 否则再次进入开启状态.

<!-- (暂时没有观察到这一现象, 项目恢复以后, 直接变为UP状态, 不确定是否是时间不够) -->

`@HystrixCommand`提供了丰富了配置, 可以使用@HystrixPreoperty 进行配置, 具体的选项可以参考[项目官网的README](https://github.com/Netflix/Hystrix/tree/master/hystrix-contrib/hystrix-javanica)


### 监控

配置项            |  值
-----------------|----------------------------------------------
端点依赖          | `spring-boot-starter-actuator`
监控依赖          | `hystrix-metrics-event-stream`
开启端点          | `management.endpoints.web.exposure.include=hystrix.stream`

注意: `spring-cloud-starter-netflix-hystrix`不包含监控依赖, 需要额外添加才能生效. 访问`/actuator/hystrix.stream`即可查看监控信息.

Hystrix会自动监控使用`@HystrixCommand`等注解标记的方法. 


### Feign监控

配置项            |  值
-----------------|----------------------------------------------
启动类注解        | `@EnableCircuitBreaker`
启动Hystrix      | `feign.hystrix.enabled=true`


在Feign环境下使用Hystrix, 除了添加依赖和开启端点以外, 还需要配置上表的属性来启用Hystrix. 启用后Feign会自动包裹所有的方法, 因此不需要再添加`@HystrixCommand`注解


### Dashboard

对于每一个启用了Hystrix的项目, 都可以访问项目的`/actuator/hystrix.stream`端点查看访问信息, 但这一信息是文本的, 不便于阅读. Hystrix Dashboard 是一个可视化Hystrix结果的组件.

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-starter-netflix-hystrix-dashboard`
启动类注解        | `@EnableHystrixDashboard`

此项目通过访问Hystrix项目的端点获得信息, 因此不需要注册到Eureka, 因此在配置文件中指定启动端口即可. 

项目启动后, 访问`/hystrix`, 会出现如下的图形界面

![HystrixDashboard](/images/spring/HystrixDashboard.JPG)

在启动输入Hystrix项目的端点地址(例如`http://localhost:8010/actuator/hystrix.stream`)和任意的Title即可进入监控界面.


### Trubine

Turbine是一个可视化Hystrix结果的组件.

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-starter-netflix-turbine`
启动类注解        | `@EnableTurbine`

除了常规的端口,应用名称, Eureka配置以外, 配置文件添加如下内容
``` yml
turbine:
  app-config: microservice-consumer-movie-feign,microservice-consumer-movie
  cluster-name-expression: "'default'" # 注意双层引号
```
其中`app-config`指定了需要监控的微服务的名称. 配置完成以后, 启动项目并访问`/turbine.stream`就可以看到聚合了多个项目的监控信息. 

启动Hystrix Dashboard并且输入Turbine的端点地址, 即可访问包含全部项目的监控页面

![TurbineDashboard](/images/spring/TurbineDashboard.JPG)


Zuul
-----------

Zuul是微服务网关, 核心是过滤器, 完成身份认证, 审查, 动态路由, 负载分配等功能.

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-starter-netflix-zuul`
启动类注解        | `@EnableZuulProxy`


完成上面的两步以后, 在配置文件中加入Eureka的配置, 将Zuul注册到Eureka即可完成创建工作. 

``` yml
server:
  port: 8040
spring:
  application:
    name: microservice-gateway-zuul
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka
```

Zuul会自动代理所有注册在Eureka的微服务, 并且将发送到 `http://ZUUL_HOST:ZUUL_PORT/微服务名/*` 的请求转发到相应的微服务, 并且自动使用Ribbon实现负载均衡.

如果希望使用Hystrix Dashboard监控Zuul, 则按照Hystrix的[监控](#监控)章节, 添加两个依赖并在配置文件中**启用端点**即可.

### 配置路由

使用`zuul.routes.<serverID>=<path>`的方式可以将指定的路径映射到指定的微服务, 例如

``` yml
zuul:
  routes:
    microservice-provider-user: /user/**
```

此时访问`/user/1`就相当于访问`microservice-provider-user/1`.

使用`zuul.ignored-services`可以忽略指定名称的微服务. 按照如下的方案可以实现只代理指定的服务
``` yml
zuul:
  ignored-services: '*'  # 忽略所有的服务, 但是明确指定的服务除外
  routes:
    microservice-provider-user: /user/**
```

`zuul.prefix`可以添加前缀, `zuul.ignoredPatterns`可以忽略指定的路径. 最后, 也可以通过Java配置实现更复杂的正则匹配等功能.

### 文件上传

对于1M以内的小文件, 可以直接上传. 对于10M以上的大文件, 需要在上传路径之前加上`/zuul`前缀, 例如`/zuul/microservice-file-upload/upload`

对于超大文件(500M), 需要提升超时设置

``` yml
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds: 60000
ribbon:
  ConnectTimeout: 3000
  ReadTimeout: 60000
```

<!-- curl -F "file=@a.exe" localhost:8050/upload -->


### 过滤器

Zuul可以在一个请求的请求之前, 请求中, 请求之后, 以及发生错误时执行用户指定的代码. 创建一个过滤器只需要继承`ZuulFilter`,并在启动类中创建一个相应的Bean即可, 代码如下:

``` java
public class PreRequestLogFilter extends ZuulFilter {
    private static final Logger LOGGER = LoggerFactory.getLogger(PreRequestLogFilter.class);
    @Override
    public String filterType() {
      // 过滤器类型
        return "pre";
    }
    @Override
    public int filterOrder() {
        //过滤器优先级
        return 1;
    }
    @Override
    public boolean shouldFilter() {
        // 是否启动过滤器
        return true;
    }
    @Override
    public Object run() {
        // 过滤器执行逻辑
        RequestContext ctx = RequestContext.getCurrentContext();
        HttpServletRequest request = ctx.getRequest();
        LOGGER.info(String.format("send %s request to %s",request.getMethod(),request.getRequestURL().toString()));
        return null;
    }
}

@SpringBootApplication
@EnableZuulProxy
public class MicroserviceGatewayZuulApplication {
    @Bean
    public PreRequestLogFilter preRequestLogFilter() {
        return new PreRequestLogFilter();
    }

    public static void main(String[] args) {
        SpringApplication.run(MicroserviceGatewayZuulApplication.class, args);
    }
}
```

### 容错与回退
使用FallbackProvider替代ZuulFallbackProvider, 

``` java
@Component
public class UserFallbackProvider implements FallbackProvider {
    @Override
    public String getRoute() {
        return "microservice-provider-user";
    }

    @Override
    public ClientHttpResponse fallbackResponse(String route, Throwable cause) {
        return new ClientHttpResponse() {
            @Override
            public @NonNull HttpStatus getStatusCode() {
                return HttpStatus.OK;
            }

            @Override
            public @NonNull int getRawStatusCode() {
                return getStatusCode().value();
            }

            @Override
            public @NonNull String getStatusText() {
                return getStatusCode().getReasonPhrase();
            }

            @Override
            public void close() { }

            @Override
            public @NonNull InputStream getBody() {
                return new ByteArrayInputStream("用户微服务不可用, 请稍微再试".getBytes());
            }

            @Override
            public @NonNull HttpHeaders getHeaders() {
                HttpHeaders headers = new HttpHeaders();
                MediaType mt = new MediaType("application", "json", Charset.forName("UTF-8"));
                headers.setContentType(mt);
                return headers;
            }
        };
    }
}
```

实现此功能需要依赖Hystrix, 但此依赖已经内置到Zuul之中, 因此不需要重复添加.

Config
----------------

Spring Cloud Config 是配置管理模块, 用于统一的管理各个微服务的配置, 并提供动态修改配置的功能. Config组件分为Server和Client, 其中Server使用Git保存配置信息, Client通过访问Server获得配置信息.


### Config Server

配置项            |  值
-----------------|----------------------------------------------
依赖              | `spring-cloud-config-server`
启动类注解        | `@EnableConfigServer`

``` yml
server:
  port: 8080
spring:
  application:
    name: microservice-config-server
  cloud:
    config:
      server:
        git:
          uri:      # Git仓库
          username: # Git用户名
          password: # Git密码
```
配置文件如上所示, 只读的访问Git仓库时, 可以省略用户名和密码.

Config Server提供了如下的端点
- `/{application}/{profile}[/{label}]`
- `{application}-{profile}.yml`
- `/{label}/{application}-{profile}.yml`
- `{application}-{profile}.properties`
- `/{label}/{application}-{profile}.properties`

label对应的是git的分支名. 无论使用那种后缀, 都可以访问同名的文件, 但文件格式并不会跟随后缀名进行转换. 

指定文件后缀时返回文件的文本信息, 不指定后缀时返回信息中还会包含分支名等额外信息的JSON数据.


### Config Client

配置项            |  值
-----------------|----------------------------------------------
依赖              | ` spring-cloud-starter-config`

创建以下两个配置文件, 并填写如下的内容

``` yml
# 文件名: application.yml
spring:
  application:
    name: microservice-foo
```

``` yml
# 文件名: bootstrap.yml
spring:
  cloud:
    config:
      uri: http://localhost:8080/
      profile: dev
      label: master
```

其中`spring.application.name`就对应配置文件的`{application}`部分, `spring.cloud.config.profile`和`spring.cloud.config.label`分别对应配置文件的`{profile}`和`{label}`部分.

``` java
@RestController
public class ConfigClientController {
    @Value("${profile}")
    private String profile;

    @GetMapping("/profile")
    public String hello(){
        return profile;
    }

}
```
在项目中使用`@Value`注解提取需要的属性.

### 仓库配置

Git仓库支持使用占位符, 例如仓库的uri可以设置为`http://github.com/xxx/{application}`, 从而使一个项目对应一个Git仓库. 此外也可以通过配置实现模式匹配或者搜索子目录.

`clone-on-start`属性可以使Server在启动时就clone仓库, 从而尽早的发现配置中存在的问题.


### DEBUG

将以下包的日志设置为DEBUG可以便于快速定位问题

``` yml
logging:
  level:
    org.springframework.cloud: DEBUG
    org.springframework.boot: DEBUG
```
