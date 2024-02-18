---
title: JavaWeb之环境配置
date: 2018-06-21 10:22:03
categories: JavaWeb
tags:
    - 环境配置
    - Ubuntu
cover_picture: images/javaWeb.png
---

本文介绍在Windows环境下,进行Java Web开发需要的环境配置方法, 以及将开发的项目部署到远程Ubuntu服务器的方法.


Windows开发环境配置过程
--------------------------

在windows平台主要进行的是开发环境配置,包括本地的运行环境和开发的IDE.

### 开发工具
1. JDK
2. Apache-tomcat
3. eclipse-jee

由于使用java进行开发,因此首先需要下载JDK. 之后是Web服务器的有关程序,即Apache-tomcat. 最后下载开发IDE,即eclipse-jee. 这三个软件都是可以免费下载的,使用搜索引擎直接搜索一下就可以获得相应的官网的网址.

注意:
1. JDK按照后,按照惯例需要配置环境变量,如何配置可以百度有很多图文教程
1. tomcat有无需安装的版本,直接解压即可使用,同样也需要配置环境变量,具体步骤可百度
2. 下载eclipse时一定要下载jee版本,该版本对Web开发提供了很多额外的支持


### 创建项目
在eclipse中,依次选择File->New->Others. 在弹出的对话框中选择Web文件夹下的Dynamic Web Project.
由于不同版本可能会有变化,所以具体路径是多少并不重要,最后能找到Dynamic Web Project即可.

注意: 
1. 在创建项目的过程中,一定要选中`Generate web.xml deployment descriptor` 否则由于最后的项目不自动生成web.xml而导致Servlet模块无法访问.
2. 如果已经创建了项目,而且忘记了选中`Generate web.xml deployment descriptor`,还可以在最后项目开发完毕准备部署的时候执行以下操作
    1. 在项目上右键,选择`Java EE Tools`
    2. 在次级菜单中选择`Generate deployment descriptor stub`,即手动生成web.xml文件


### 选择目标运行时
在创建项目的过程中,需要选择程序运行时(Target Runtime),如果没有可以新建一个. 注意以下两点
1. 新建的时候注意选择和之前下载的tomcat保持相同版本
2. 路径选择之前解压tomcat的路径.

**注意:** 如果没有选择运行时, 创建项目以后, 新建了JSP文件, 可能会提示`he superclass "javax.servlet.http.HttpServlet" was not found on the Java Build Path`. 这是由于项目之中没有添加tomcat的依赖, 导致有关的类无法找到. 重新创建项目并选择运行时即可. 此外以下两个文章给出了从现有项目添加运行时的方法.
- [解决办法：错误异常The superclass "javax.servlet.http.HttpServlet" was not found on the Java Build Path](https://blog.csdn.net/dietime1943/article/details/75127417)
- [the superclass javax servlet http httpservlet was not found on the java build](https://stackoverflow.com/questions/22756153/the-superclass-javax-servlet-http-httpservlet-was-not-found-on-the-java-build)


### 创建服务器
程序运行之前还需要配置运行服务器. 不过由于eclipse有引导, 点击运行按钮以后,按照引导选择正确的tomcat版本即可.

### 查看效果
tomcat运行后会在本地的8080端口展示效果,因此使用浏览器访问`http://localhost:8080/项目名` 即可查看运行效果


ubuntu远程服务器配置
-------------------------
Ubuntu平台只需要执行有关的代码而不需要进行开发,因此只需要下载运行环境而不需要下载IDE,也不需要使用图形界面. 因此以下过程都是在命令行中执行.

### 安装JDK
和Windows环境一样,在Ubuntu下安装jdk只需要输入以下指令
``` bash
sudo apt install default-jdk
```

注意:
1. 按照惯例,安装软件之前应该先更新软件源和软件列表,具体方法可以百度
2. 据说某些情况下可能无法访问到国外的源,这个时候可以考虑换一个国内的
3. 使用apt安装时,自动配置了有关的环境变量,因此不需要再次配置

### 安装tomcat
依次执行以下指令下载tomcat
``` bash
# 下载并解压tomcat
cd /usr/local/lib
sudo wget -c http://apache.mirrors.tds.net/tomcat/tomcat-9/v9.0.10/bin/apache-tomcat-9.0.10.tar.gz
sudo tar -zxvf apache-tomcat-9.0.5.tar.gz

# 修改文件名
sudo mv apache-tomcat-9.0.10 apache-tomcat

#修改用户
sudo chown -R ubuntu:ubuntu /usr/local/lib/apache-tomcat/

# 添加环境变量
export TOMCAT_HOME=/usr/local/lib/apache-tomcat
export CATALINA_HOME=$TOMCAT_HOME
export PATH=$PATH:$TOMCAT_HOME/bin

# 启动服务
cd apache-tomcat/bin/
./startup.sh

# 关闭服务
```

注意:
1. 由于tomcat不断的更新,因此可能某一天这个链接就不能用了,由于wget本质就是一个下载程序,因此可以访问 http://apache.mirrors.tds.net/tomcat/ 查看最近的版本,依据情况自行调整下载连接


部署Web项目到远程服务器
------------------------

### 将项目部署到tomcat文件夹
默认情况下,Eclipse会将项目放在工程目录并将最后的Web文件存放在`.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\` 下,通过修改部署位置可以为后续部署到远程服务器提提供便利. 按照以下步骤修改Eclipse项目部署位置

1. 在Eclipse中创建服务并运行项目(如果已经由服务器和项目跳过此步)
2. 移除当前服务上的项目
    1. 在Eclipse的`Servers`视图,选中服务器右键
    2. 选择`Remove`,移除所有项目
3. 配置属性
    1. 再次在`Servers`视图,选中服务器右键
    2. 选中`Open`,打开配置
    3. 将`Server Locations`修改为`Use Tomcat installation`
    4. 在下面的`Deplay path`输入`wabapps`
4. 配置依赖库
    1. 在项目上右键,选中`Properties`
    2. 在弹出菜单的侧边栏选择`Deplayment Assembly`
    3. 在右侧选择`Add`,在弹出菜单中选择`Java Build Path Entries`,点击`Next`
    4. 在弹出菜单中选择需要添加的库

### Tomcat配置热部署
默认情况下,将Windows上生成好的Wen项目直接复制到Ubuntu的相应目录下就可以直接访问了,但是如果对内容进行了修改,则必须要重启tomcat服务才能更新内容. 通过配置tomcat热部署可以动态的改变内容而不需要重启服务. 配置tomcat热更新仅仅修改`$TOMCAT_HOME\conf\server.xml`文件, 在其中的`<host></host>`内部添加`<context/>`标签
``` xml
<host>
    ...
    <Context debug="0" docBase="WebHello" path="/WebHello" privileged="true" reloadable="true"/>
    ...
</host>
```

注意:
1. 其中的docBase指的是项目在服务器上的路径,使用相对路径时,当前目录是webapps
2. path是最后在浏览器上的访问路径,例如本例中是`http://example.com:8080/WebHello`
3. reloadable表示文件发生变动时是否自动重新加载
4. 如果修改servlet文件没有生效, 可以先删除有关的class文件, 再添加新的文件



补充: Tomcat文件结构介绍
----------------------------
- bin
    - 该目录下存放的是二进制可执行文件
    - 包括启动,关闭tomcat服务的各种程序
- conf
    - 这是一个非常非常重要的目录,这个目录下有四个最为重要的文件
    - server.xml
        - 配置整个服务器信息
        - 例如修改端口号, 添加虚拟主机等
    - tomcatusers.xml
        - 存储tomcat用户的文件,这里保存的是tomcat的用户名及密码, 以及用户的角色信息
        - 配置后可通过配置的用户名密码进入Tomcat Manager页面
    - web.xml
        - 部署描述符文件
    - context.xml
        - 对所有应用的统一配置
- lib
    - 项目依赖的二进制文件
- logs
    - 日志文件
- temp
    - 运行过程中产生的临时文件

- webapps
    - 存放web项目的目录,其中每个文件夹都是一个项目
    - 其中ROOT是一个特殊的项目,在地址栏中没有给出项目目录时,对应的就是ROOT项目
- work
    - 运行时生成的文件,最终运行的文件都在这里
    - 可以删除,下次运行时tomcat会再次自动生成

参考文献
--------
- [Eclipse开发Web项目入门篇](http://blog.csdn.net/ldw4033/article/details/18313281)
- [Eclipse手动生成JavaWeb项目web.xml文件](http://blog.csdn.net/o0darknessyy0o/article/details/52579408)
- [Ubuntu 服务器安装 Java Web 开发环境](https://www.jianshu.com/p/96c03c33d421)
- [Eclipse中web项目部署至Tomcat步骤](http://blog.csdn.net/master_yao/article/details/74176722)
- [Tomcat热部署方法](http://chen25362936.blog.163.com/blog/static/25655474201216113142284/)
- [Tomcat的目录结构](http://www.cnblogs.com/greatfish/p/6083887.html)