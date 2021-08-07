---
title: JavaWeb之JavaServerPages
date: 2018-06-21 20:22:03
categories: JavaWeb
tags:
    - Java
    - 数据库
cover_picture:  images/jsp.png
---

本文介绍JSP的基本知识和语法以及由JSP衍生的Web开发技术. JSP（Java Server Pages）是由Sun Microsystems公司倡导和许多公司参与共同创建的一种使软件开发者可以响应客户端请求,而动态生成HTML,XML或其他格式文档的Web网页的技术标准.JSP技术是以Java语言作为脚本语言的,JSP网页为整个服务器端的Java库单元提供了一个接口来服务于HTTP的应用程序.



JSP文件结构
-------------

JSP和PHP等语言一样,可以和HTML文件一同混合编写. 与PHP代码包含在`<?PHP`和`?>`之间一样,所有的JSP代码都包含在`<%`和`%>`之中. JSP文件通常以`.jsp`作为后缀, 在JSP文件中,JSP代码出现的位置并没有具体的限制.

以下是一段JSP代码的例子:
``` jsp
<%@page import="java.util.Random"%>
<%@ page language="java" contentType="text/html; charset=utf8"
    pageEncoding="utf8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Hello From JSP</title>
</head>
<body>
<%!
	String sayHello(String name)
	{
		return "Hi," + name;
	}
%>
<%=sayHello("Lily") %>
<%
	Random rand = new Random();
	int num = rand.nextInt(1000);
	out.println("\n您是今天的第"+num+"位访客");
%>
</body>
</html>
```
从以上代码,我们可以注意到以下几个特征
1. 所有的JSP代码都是包裹在`<%...%>`之中的
2. 页面属性有关的代码使用`<%@page ..."%>`包裹
3. JSP代码本质还是Java代码
4. 如果刷新页面,则每次显示的数字都不同,说明JSP代码每次请求的时候都会被重新执行


JSP元素类型
------------

类型                | 标记                      | 解释
-------------------|---------------------------|------------------------------------------
静态内容            | N/A                       | 即HTML代码,与JSP语法无关
声明(declaration)   | `<%! ... %>`              | 用于定义方法, 变量等
表达式(expression)  | `<%= ... %>`              | 可以计算, 调用函数, 引用变量等
代码片段(scriptlet) | `<% ... %>`               | 任意的Java代码片段, 通常会产生输出到客户端的输出流
指令                | `<%@ ... %>`              | 使用page关键字来设置属性
动作                |`<jsp:动作>...</jsp:动作>`  | 包含文件, 请求转发等


JSP隐式对象
-------------
JSP中共包含4大类,共9个隐含对象,这些对象直接存在于JSP脚本中,不需要任何操作即可使用他们. 具体分类如下所示:

1. 输入输出对象
    - request
        - request对象表示客户端的请求,包含了所有的请求信息,包括协议名,端口号,IP地址,编码方式等信息.
    - response
        - response对象表示服务器端的返回,JSP一般很少使用
    - out
        - 表示输出流,此输出流会作为请求的响应返回给客户端
        - out是JspWrite的实例
2. 作用域通讯对象
    - session
        - 表示用户的会话情况
        - 用于和客户端进行唯一标识,从而保持客户端状态信息
        - 由于HTTP是无状态连接,因此实现此功能通常都是使用了cookie技术
    - application
        - 全局的共享信息
    - pageContext
        - 显式的访问隐式的对象
        - 例如pageContext.getOut()获得out对象
        - 此外也可以保存页面级的信息
3. Servlet对象
    - page
        - 指向当前页面,相当与其他语言中的this指针
        - 现在已经很少使用page变量
    - config
        - 存储Servlet的一些初始信息
        - 现在已经很少使用
4. 错误对象
    - exception
        - 需要在页面中使用page质量将isErrorPage属性置为true
        - 表示异常,是java.lang.Throwable对象


### 关于session实现的讨论
- [JSP Session介绍](http://www.runoob.com/jsp/jsp-session.html)
- [深入理解cookie与session](http://blog.csdn.net/j903829182/article/details/39855221)
- [Session原理和Tomcat实现分析](http://www.blogjava.net/persister/archive/2010/08/24/329838.html)


### 演示代码
- 以下代码演示了如何使用request对象和HTML代码实现网页的数据交互
``` jsp
<%@page import="java.util.Enumeration"%>
<%@ page language="java" contentType="text/html; charset=utf8"
    pageEncoding="utf8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Hello From JSP</title>
</head>
<body>

<%
String str = "";
if(request.getParameter("username") != null && request.getParameter("password") != null)
{
	Enumeration<String> enumt = request.getParameterNames();
	while(enumt.hasMoreElements()){
		str = enumt.nextElement().toString();
		out.println(str + ":"+ request.getParameter(str) + "<br>");
	}
	
}
%>

<form method="post" action="">
	用户名:<input type="text"  name="username" id="username" value="" />
	 密码: <input type="password"  name="password" id="pass" value="" />
    <input type="submit" value="提交"/> 
</form> 
</body>
</html>
```


Servlet技术
----------------

Servlet是一种独立于平台和协议的服务器端的Java应用程序,处理请求的信息并将结果返回给客户端. Servlet的客户端可以是浏览器,java应用程序等. Servlet实际上是充当客户端与服务器端数据库之间的中间层.


### Servlet运行原理
1. 客户端发送请求
2. 服务器将请求转发给Servlet容器处理
3. Servlet容器处理完毕后将结果返回给服务器
4. 服务器将结果返回给客户端
注意: 当一个Servlet第一次收到http请求时,服务器启动一个Servlet实例,并启动一个线程. 后续同一个Servlet再次收到请求时,只开一个新的线程,不再创建实例.

### Servlet方法和使用
学习Servlet方法的最简单方式就是阅读源代码,但是tomcat并没有提供源代码,如果想看诸如HttpServlet类的实现需要自己下载源代码,例如[这篇博客](http://blog.csdn.net/u013823429/article/details/66982245)提供了源代码的下载和使用方法.

以下的内容都是基于HttpServlet的源代码.

#### doGet方法
``` java
    /**
     *
     * Called by the server (via the <code>service</code> method) to
     * allow a servlet to handle a GET request. 
     *
     * <p>Overriding this method to support a GET request also
     * automatically supports an HTTP HEAD request. A HEAD
     * request is a GET request that returns no body in the
     * response, only the request header fields.
     *
     * <p>When overriding this method, read the request data,
     * write the response headers, get the response's writer or 
     * output stream object, and finally, write the response data.
     * It's best to include content type and encoding. When using
     * a <code>PrintWriter</code> object to return the response,
     * set the content type before accessing the
     * <code>PrintWriter</code> object.
     *
     * <p>The servlet container must write the headers before
     * committing the response, because in HTTP the headers must be sent
     * before the response body.
     *
     * <p>Where possible, set the Content-Length header (with the
     * {@link javax.servlet.ServletResponse#setContentLength} method),
     * to allow the servlet container to use a persistent connection 
     * to return its response to the client, improving performance.
     * The content length is automatically set if the entire response fits
     * inside the response buffer.
     *
     * <p>When using HTTP 1.1 chunked encoding (which means that the response
     * has a Transfer-Encoding header), do not set the Content-Length header.
     *
     * <p>The GET method should be safe, that is, without
     * any side effects for which users are held responsible.
     * For example, most form queries have no side effects.
     * If a client request is intended to change stored data,
     * the request should use some other HTTP method.
     *
     * <p>The GET method should also be idempotent, meaning
     * that it can be safely repeated. Sometimes making a
     * method safe also makes it idempotent. For example, 
     * repeating queries is both safe and idempotent, but
     * buying a product online or modifying data is neither
     * safe nor idempotent. 
     *
     * <p>If the request is incorrectly formatted, <code>doGet</code>
     * returns an HTTP "Bad Request" message.
     * 
     * @param req   an {@link HttpServletRequest} object that
     *                  contains the request the client has made
     *                  of the servlet
     *
     * @param resp  an {@link HttpServletResponse} object that
     *                  contains the response the servlet sends
     *                  to the client
     * 
     * @exception IOException   if an input or output error is 
     *                              detected when the servlet handles
     *                              the GET request
     *
     * @exception ServletException  if the request for the GET
     *                                  could not be handled
     *
     * @see javax.servlet.ServletResponse#setContentType
     */

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException
    { ... }
```
以上是源代码中提供的注释. 从注释可以看到以下几点
1. 这是一个回调方法,会被该类的service方法在合适的时候调用
2. 通过重写这个方法来实现对get请求的处理,如果不重写,也提供了一个默认的操作
3. 重写这个方法时,从request中读取数据,处理后写入respond中
4. 此方法要求安全且幂等,即没有副作用且可以重复调用,并且说明查询通常时安全且幂等的而修改数据既不是安全也不是幂等的
4. 如果请求格式不正确,返回一个"Bad Request"的HTTP消息

此外, 源代码注释中使用了大量的篇幅说明了使用过程的可能出现错误的细节问题,这些问题将在后续统一的进行讨论.

#### doPost方法
``` java
    /**
     *
     * Called by the server (via the <code>service</code> method)
     * to allow a servlet to handle a POST request.
     *
     * The HTTP POST method allows the client to send
     * data of unlimited length to the Web server a single time
     * and is useful when posting information such as
     * credit card numbers.
     *
     * <p>When overriding this method, read the request data,
     * write the response headers, get the response's writer or output
     * stream object, and finally, write the response data. It's best 
     * to include content type and encoding. When using a
     * <code>PrintWriter</code> object to return the response, set the 
     * content type before accessing the <code>PrintWriter</code> object. 
     *
     * <p>The servlet container must write the headers before committing the
     * response, because in HTTP the headers must be sent before the 
     * response body.
     *
     * <p>Where possible, set the Content-Length header (with the
     * {@link javax.servlet.ServletResponse#setContentLength} method),
     * to allow the servlet container to use a persistent connection 
     * to return its response to the client, improving performance.
     * The content length is automatically set if the entire response fits
     * inside the response buffer.  
     *
     * <p>When using HTTP 1.1 chunked encoding (which means that the response
     * has a Transfer-Encoding header), do not set the Content-Length header. 
     *
     * <p>This method does not need to be either safe or idempotent.
     * Operations requested through POST can have side effects for
     * which the user can be held accountable, for example, 
     * updating stored data or buying items online.
     *
     * <p>If the HTTP POST request is incorrectly formatted,
     * <code>doPost</code> returns an HTTP "Bad Request" message.
     *
     *
     * @param req   an {@link HttpServletRequest} object that
     *                  contains the request the client has made
     *                  of the servlet
     *
     * @param resp  an {@link HttpServletResponse} object that
     *                  contains the response the servlet sends
     *                  to the client
     * 
     * @exception IOException   if an input or output error is 
     *                              detected when the servlet handles
     *                              the request
     *
     * @exception ServletException  if the request for the POST
     *                                  could not be handled
     *
     * @see javax.servlet.ServletOutputStream
     * @see javax.servlet.ServletResponse#setContentType
     */
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException
    { ... }
```
doPost方法的注释和doGet方法的注释介绍的内容基本是相同的,但有如下的几点差别
1. 使用post方法可以提供无限制长度的数据传输
2. 此方法不要求安全或幂等,即可以在此方法中处理诸如数据更新的任务

#### init方法
``` java
    /**
     * Called by the servlet container to indicate to a servlet that the
     * servlet is being placed into service.  See {@link Servlet#init}.
     *
     * <p>This implementation stores the {@link ServletConfig}
     * object it receives from the servlet container for later use.
     * When overriding this form of the method, call 
     * <code>super.init(config)</code>.
     *
     * @param config 			the <code>ServletConfig</code> object
     *					that contains configutation
     *					information for this servlet
     *
     * @exception ServletException 	if an exception occurs that
     *					interrupts the servlet's normal
     *					operation
     * 
     * @see 				UnavailableException
     */
    public void init(ServletConfig config) throws ServletException { ... }
```

由于HttpServlet方式继承自GenericServlet,所以这个方法实际上是定义在GenericServlet中的. 从注释可以看到
1. 此方法被Servlet容器调用,来使Servlet进入服务状态
2. 此方法提供了默认的实现,保存最近的ServletConfig,重写此方法时一定要调用super.init()

#### service方法
``` java
    /**
     * Receives standard HTTP requests from the public
     * <code>service</code> method and dispatches
     * them to the <code>do</code><i>XXX</i> methods defined in 
     * this class. This method is an HTTP-specific version of the 
     * {@link javax.servlet.Servlet#service} method. There's no
     * need to override this method.
     *
     * @param req   the {@link HttpServletRequest} object that
     *                  contains the request the client made of
     *                  the servlet
     *
     * @param resp  the {@link HttpServletResponse} object that
     *                  contains the response the servlet returns
     *                  to the client                                
     *
     * @exception IOException   if an input or output error occurs
     *                              while the servlet is handling the
     *                              HTTP request
     *
     * @exception ServletException  if the HTTP request
     *                                  cannot be handled
     * 
     * @see javax.servlet.Servlet#service
     */
    protected void service(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException
    { ... }
```

service方法注释提到了以下几个要点
1. 此方法接受HTTP请求并根据方法类型调用doXXX类型的方法(例如doGet和doPost)
2. 通常没有必要重写此方法


#### destory方法
``` java
    /**
     * Called by the servlet container to indicate to a servlet that the
     * servlet is being taken out of service.  See {@link Servlet#destroy}.
     */
    public void destroy() { ... }
```
此方法也定义在GenericServlet之中,注释提到如下要点
1. 此方法被Servlet容器调用,当一个Servlet不再提供服务


### Servlet生命周期
1. 实例化
    - Servlet容器创建Servlet类的实例
2. 初始化
    - 容器调用init方法
    - 通常在init方法中申请资源,以便于后续使用
3. 服务
    - 根据请求,调用doGet,doPost等方法
4. 销毁
    - 调用destroy方法
    - 通常在destroy方法中释放之前申请的资源
5. 不可用
    - 释放容器对应的内存

<!-- ### Servlet API

#### ServletInputStream 类 -->




JDBC技术
---------------

本节介绍如何使用JDBC技术连接MySQL数据库. 本质上, JDBC和JSP技术并没有相关性, 使用到的JDBC技术也是可以直接用于其他的Java应用程序之中.

### MySQL和Connector下载
MySQL提供了多种版本, 一般情况下选择免费的社区版下载即可. 下载完MySQL后可以在官网上下载最新版的Connector. 官网上提供了多种语言的Connector, 选择Java语言的版本即可. 下载过程中可能要求注册一个账户, 点击最下方的直接下载即可.

补充:
1. 如果使用完整的安装, 则在安装过程中MySQL就提供了各种语言的驱动, 因此不需要再额外的下载
2. 如果使用Maven, 也可以直接导入需要的驱动


### 导入Connector包
下载MySQL的按照程序后, 按照向导进行安装即可. 下载的Connector解压后有两个jar包, 选择`mysql-connector-java-XXX.jar`(XXX为版本号)并将其复制到项目的`WEB-INF\lib`文件夹下即完成包的导入工作.


### 连接数据库

连接数据库是一个固定操作, 一般有以下的过程
``` java
Connection conn=null;             //声明数据库连接对象
PreparedStatement pstmt=null;     //声明数据库操作对象
ResultSet rs=null;                //声明查询结果集对象,对于更新操作, 可不声明

String driverName = "com.mysql.jdbc.Driver";
String userName = "root";
String userPwd = "123456";
String dbName = "webinfo";
String url1 = "jdbc:mysql://localhost:3306/"+dbName;
String url2 = "?user="+userName+"&password="+userPwd;
String url3 = "&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
String url = url1+url2+url3;
try {
    Class.forName(driverName);
    conn=DriverManager.getConnection(url);
    String sql= "SELECT * FROM stu_info;";   //构造完成所需功能的SQL语句(可带参数)
    pstmt= conn.prepareStatement(sql);   
    rs=pstmt.executeQuery();
    
    while (rs.next()) {
        response.getWriter().append(rs.getString(1)).append(" ").append(rs.getString(3));
        response.getWriter().append("\n");
    }
    
} catch (ClassNotFoundException e) {
    e.printStackTrace();
} catch (SQLException e) {
    e.printStackTrace();
}
finally {
    try {
        if(rs!=null){ rs.close(); }
        if(pstmt!=null){ pstmt.close(); }
        if(conn!=null){ conn.close(); }
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```

连接数据库时注意指定`serverTimezone=UTC` 否则可能无法连接数据库. 更多关于时区的问题可以参考[如何规避mysql的url时区的陷阱](https://www.jianshu.com/p/7e9247c0b81a)


### 连接池技术

以连接本地数据库中的`api`库为例, 配置如下所示: 

``` xml
<Context>
    <Resource name="jdbc/mysql"
             type="javax.sql.DataSource"
             auth="Container"
             driverClassName="com.mysql.jdbc.Driver"
             url="jdbc:mysql://localhost:3306/api?serverTimezone=UTC"
             username="root"
             password="123456"
             maxActive="4"
             maxIdle="2"
             maxWait="6000"/>
</Context>
```

连接数据库时, 可能会提示`com.mysql.jdbc.Driver` 已经过时, 按照提示换成新的驱动类即可. 

更多关于MySQL和JDBC的内容, 可以参考一下的一些博客
- [21分钟 MySQL 入门教程](http://www.cnblogs.com/mr-wid/archive/2013/05/09/3068229.html)

JavaBean
---------------

JavaBean是一个Java编写的,符合某种规则的类. JavaBean封装了数据和业务逻辑, 可以被JSP或者Servlet直接调用.

### JavaBean设计规则
1. 必须是公共类
2. 具有公共的无参数构造方法
3. 所有属性定义为私有
4. 每个属性提供get和set方法(boolean类型方法特殊处理)
5. 通常位于某个包下(而不是默认包)


### JSP种使用JavaBean
#### JSP标签
一般可以使用以下三种标签来使用JavaBean
1. `<jsp:useBean>`
2. `<jsp:setProperty>`
3. `<jsp:getProperty>`



`<jsp:useBean id = "对象名" class = "类名" scope = "有效范围">`
- id相当于类对象标识符,后续使用此标识符引用JavaBean对象
- class是JavaBean的类名,且需要使用完整的类型
- scope表示范围,可选page, request, session, application, 默认为page

`<jsp:setPropert name = "对象名" property = "属性名" value = "属性值">`
- name对应useBean种id的值
- 属性值按照声明的属性类型进行自动转换


`<jsp:setPropert name = "对象名" property = "参数名">`
- 将一个同名的参数赋值给属性

`<jsp:setProperty name="beanname" property="属性名e" param="请求参数名"/>`
- 将请求参数的值赋值给JavaBean属性值
- 从而协调参数名与JavaBean属性名不一致的问题

`<jsp:setProperty name="对象名" property="*"/>`
- 将所有的输入参数赋予相应的属性值


#### 脚本代码
使用脚本代码时,和使用一个Java类没有区别.