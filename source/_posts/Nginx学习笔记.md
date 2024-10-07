---
title: Nginx学习笔记
math: false
date: 2024-06-19 21:31:44
categories:
tags:
    - Nginx
cover_picture: images/nginx.png
---

Nginx是一款高性能的Web服务器和反向代理服务器, 由俄罗斯的程序设计师Igor Sysoev开发. 它以其轻量级, 高并发处理能力和低内存消耗的特点, 广泛应用于互联网领域, 特别是用于构建高性能的网站和应用程序. 本文主要讨论Nginx在个人项目中的一些使用, 例如构建Web服务, 进行反向代理等. 关于负载均衡, 模块化等能力在后续的文章中讨论.



安装与配置
--------------

Nginx作为一个常用的软件, 通常可直接使用包管理器安装, 例如

```sh
sudo apt-get update
sudo apt-get install nginx
```

安装完毕后, 可打开`/etc/nginx`目录, 此处存放了Nginx的配置文件, 其结构如下

```
.
├── conf.d
│   └── passwd
├── fastcgi.conf
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types
├── modules-available
├── modules-enabled
├── nginx.conf
├── proxy_params
├── scgi_params
├── sites-available
│   └── default
├── sites-enabled
│   ├── default -> /etc/nginx/sites-available/default
│   └── lizec.top
├── snippets
│   ├── fastcgi-php.conf
│   └── snakeoil.conf
├── uwsgi_params
└── win-utf
```

其中`nginx.conf`是Nginx的核心配置文件, 可以在其中配置Nginx的核心参数. 其中包含了如下的命令

```sh
	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
```

因此位于`conf.d`路径和`sites-enabled`路径下的文件也会作为配置的一部分被加载.

> 通常在`sites-available`中创建配置文件, 然后在`sites-enabled`中通过软链接引用对应的文件, 从而实现快速增删配置的效果.



构建Web服务
---------------

Nginx构建Web服务的配置非常简单, 以下是一个静态网站的Nginx配置

```sh
server {
    listen 443 ssl;
    server_name lizec.top;

    # 指定证书位置
    ssl_certificate     /etc/letsencrypt/live/lizec.top/fullchain.pem;        
    ssl_certificate_key /etc/letsencrypt/live/lizec.top/privkey.pem; 
}

server {
    listen 80;
    server_name lizec.top;
    return 301 https://$server_name$request_uri;                                      
}
```

`server_name`指定了此站点的域名, 当HTTP请求以域名的模式访问时, Nginx会根据域名定位具体的配置文件. 证书部分使用了`letsencrypt`服务, 该项目可生成一个90天有效的证书, 从而使得Web服务支持HTTPS访问.

这里并未指定静态网站的文件位置, 因此会使用默认值, 即`/usr/share/nginx/html`, 将静态网站的全部文件放入此路径下, 并确保包含index.html文件即可.

考虑到用于可能以http模式进行访问, 因此这里同时也监听了http的80端口, 并向用户返回重定向错误码, 使用户的浏览器重定向到对应的https地址.

> 在十年前可能还存在http和https混用的情况, 现在浏览器基本上都强制https了



请求转发
-----------

Nginx可配置请求转发, 根据不同的条件, 将请求转发到不同的后端服务, 例如如下的配置给出了一个典型的前后端分离的Nginx配置


```sh
    # 省略基本定义部分 ...

    upstream backend {
        server localhost:4231;
    }

    server {
        listen 80;

        # 所有的请求默认转发到前端的index文件, 由Vue进行代理 
        location / {
            root /web;
            try_files $uri $uri/ /index.html;
        }  
        
        # API相关的路径是后端的接口, 转发给后端
        location /api {
            proxy_pass http://backend;
            proxy_set_header User-Agent $http_user_agent;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # 上传和下载的文件, 直接由Nginx进行代理
        location /file {
            alias  /app/data/filebase/;
        }

    }       
```

`location`命令定义了多种条件, Nginx根据请求的URL和这些`location`命令选择一个最佳匹配进行执行. 最佳匹配通常可视为最长匹配的路径, 例如`/api/v2/getXxx`就更加匹配`/api`条件, 而不是`/`条件. 关于匹配的详细规则可参考[nginx的location匹配规则, 泣血总结](https://blog.csdn.net/luoyang_java/article/details/83507193)和[nginx配置location匹配顺序总结](https://blog.csdn.net/agonie201218/article/details/92795522)

`root`定义了URL对应的根路径, 因此在当前配置下, 访问`/a/b.html`就等于访问`web/a/b.html`. `alias`定义了一段路径的别名, 因此`/file/c.zip`就等于访问`/app/data/filebase/c.zip`.

`proxy_pass`定义了请求转发, 因此访问`/api/v2/getXxx`的请求将直接转发到`http:localhost:4231/api/v2/getXxx`(这对应了本地的一个web服务), 并将执行结果返回.


反向代理特定服务
----------------

Nginx可反向代理某个特定网站(例如Google), 其原理和请求转换一样, 即收到请求后直接转发给特定的网站, 然后将特定网站的执行结果返回给客户端. 具体配置可参考如下的一些文章.


- [Nginx反向代理Gοοgle | 若水斋](https://blog.werner.wiki/nginx-reverse-proxy-google/)

> 对于仅想使用Google或者Wikipedia的场景, 使用此方法更加简单可控