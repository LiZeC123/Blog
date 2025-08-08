---
title: HTTP协议解析
date: 2019-08-08 14:09:32
categories:
tags:
    - HTTP
    - 计算机网络
cover_picture: images/http.jpg
---


HTTP协议结构
----------------

网络上已经存在了大量关于HTTP协议的优质文章, 我就不重复. 关于HTTP协议结构的介绍, 可以阅读以下的文章. 

- [HTTP请求行、请求头、请求体详解](https://blog.csdn.net/u010256388/article/details/68491509)

关于HTTP的发展历史, 可以参考以下的文章.

- [HTTP 协议入门](http://www.ruanyifeng.com/blog/2016/08/http.html)


HTTP Header
-----------

HTTP是基于文本的, 所以很多属性看名字就可以知道含义. 但由于HTTP Header中属性太多, 因此本文显然无法记录全部的属性, 对于大部分属性, 在需要的时候再去查询其含义也不会消耗太多时间. 下面介绍一些最常用的参数.

### 请求头参数

参数            | 含义
----------------|-----------------------------
Accept          | 可接受的响应格式
Accept-Encoding | 可接受的编码格式
Accept-Language | 可接受的语言
Cache-Control   | 指示服务器端的Cache保存策略
Connection      | 表示连接类型,例如持续连接
Cookie          | 客户端传输给服务端的Cookie
Host            | 请求服务器的域名
Referer         | 发送此请求时来自的页面
User-Agent      | 使用的客户端名称

----------

**Accept**开头的一组参数都是表示可接受的响应类型, 这些参数可以指定多种类型, 类型之间使用`;`分割. 此外, 其中还会包含一些类似`q=0.9`样式的字段, 此字段用于表示优先级, 例如`zh-CN,zh;q=0.9,en;q=0.8`就表示接受中文的优先级为0.9,而接受英文的优先级为0.8

---------

**Referer**用于指定请求的来源页面, 例如在知乎页面上点击一个外部链接, 向目标网站发送请求时, Referer字段就是知乎的网址. 使用Referer可以用来防止盗链(即如果Referer不是自己的网站, 就拒绝请求).

-----
**Content-Type**用于指定传输的内容的格式. HTTP协议既可以用来传输HTML代码, 也可以传输二进制的图片和视频. 文本和二进制文件的解析方式完全不同, 浏览器和服务器通过此属性来标记传输的内容. 常见的取值有

取值                                 | 含义
------------------------------------|------------------------------
text/html                           | HTML文本
application/x-www-form-urlencoded   | 键值对格式的表单参数
image/jpeg	                        | JPEG格式的图片
multipart/form-data                 | 包含多个部分的数据
application/json                    | JSON格式的文本

- [三种常见的http content-type详解](https://blog.csdn.net/u014209205/article/details/81147783)
- [HTTP Content-Type对照表](http://tool.oschina.net/commons/)


### 响应头参数


参数            | 含义
----------------|-----------------------------
Cache-Control   | 指示客户端的Cache保存策略
ETag            | 指示服务器端资源是否发生变化
Location        | 重定向时的重定向目标地址

----

如果某个Cache-Control取值情况是`Cache-Control: max-age=600, public, must-revalidate`, 则表明Cache的最大保存时间为600秒, 且过期后必须从服务器端重新获取



HTTP Body
-------------

HTTP的数据部分必须存放在Body之中. HTTP Header和HTTP Body之间空一行, 因此读取到连续的`\r\n\r\n`即表示后续内容属于HTTP Body. HTTP协议并没有规定数据必须以某种方式进行编码, 因此通常使用前面介绍的Content-Type属性来决定编码的内容.

### 传输单个数据

HTTP可以传输文本数据或者二进制数据. 对于文本数据, 文本虽然都是可读的, 但也存在多种组织数据的方式. 例如XML文件和JSON文件都可以表达同样的信息, 但文件的组织方式就完全不同. 在浏览器提交表单数据时, 默认采取x-www-form-urlencode格式, 此时参数以`key1=value1&key2=value2`的方式编码数据.

如果只传输一个二进制文件(例如单文件上传), 则传输过程与传输文本并没有区别, 直接将二进制数据放入Body之中即可.


### 传输多个数据

如果既要传输二进制信息, 又要传输一部分文本进行, 那么也可以使用混合传输的方式. 此时需要将Content-Type属性指定为`multipart/form-data`, 即向接收端表明HTTP Body中存在多个部分的数据, 需要分开处理. 

指定编码方式的同时, Content-Type还需要附带一个boundary属性, 此属性为一个任意的随机字符串, 用来分割HTTP Body的不同部分. 只要boundary属性的值不出现在各部分数据之中, boundary可以取任意值.

在这种情况下的HTTP协议具有如下的样式

``` 
POST http://www.example.com HTTP/1.1
Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA

------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="file"; filename="chrome.png"
Content-Type: image/png

<...此处为二进制数据...>
------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="text"

title
------WebKitFormBoundaryrGKCBY7qhFd3TrwA--
```

可以看到, HTTP Body被boundary指定的字符串分割为多个部分, 而每个部分中, 又可以分割为Header和Body. 



HTTP状态码
------------------

HTTP状态码由三个十进制数字组成, 可以分为如下的5种类别

Code    | Message
--------|----------------------------------------------------
1xx     | 信息，服务器收到请求，需要请求者继续执行操作
2xx     | 成功，操作被成功接收并处理
3xx     | 重定向，需要进一步的操作以完成请求
4xx     | 客户端错误，请求包含语法错误或无法完成请求
5xx     | 服务器错误，服务器在处理请求的过程中发生了错误

- [HTTP状态码](https://www.runoob.com/http/http-status-codes.html)


参考文献和扩展阅读
-------------------

以下的几篇文章中, 第一篇文件介绍了`application/x-www-form-urlencoded`, `multipart/form-data`, `application/json` 三种取值的具体含义. 第二篇文章对这三种属性与POST, GET方法的关系进行了讨论, 并且补充了更多关于`multipart/form-data`的特性. 

- [网络协议学习——HTTP协议POST方法的格式](https://blog.csdn.net/Kurozaki_Kun/article/details/78646960)
- [http--body编码的方式](https://blog.csdn.net/evsqiezi/article/details/70919363)
- [HTTP请求GET/POST与参数小结](https://alanli7991.github.io/2016/10/26/HTTP%E8%AF%B7%E6%B1%82GETPOST%E4%B8%8E%E5%8F%82%E6%95%B0%E5%B0%8F%E7%BB%93/)



HTTP方法
------------------

### 方法的区别

方法     | 主要特点                                             | 方法  | 主要特点
-----|--------------------------------------------------------|--------|--------------------------------------------------
GET  | 只获得服务器端的数据, 不对服务器进行修改                   |DELETE |  删除资源  
POST | 创建资源, 对应服务器上的一个动作, 多次操作会可以创建多个结果| PUT    | 替换资源, 对应服务器上的一个资源, 多次操作结果不变(幂等)
PATCH| 局部资源更新, 对PUT方法的补充                            | HEAD   | 获得资源的头部信息


结合前面的HTTP Header和HTTP Body可知, 确定请求方法的是HTTP头部的动词, 与是否传递数据无关, 因此使用GET方法也能够在HTTP Body中传递数据. 因此, 本质来说, 这些方法都是一样的, 更多的是语义上的区别.

-------------

- [浅谈http协议六种请求方法, get、head、put、delete、post、options区别](https://www.cnblogs.com/wei-hj/p/7859707.html)
- [99%的人都理解错了HTTP中GET与POST的区别](https://zhuanlan.zhihu.com/p/22536382)



使用curl指令发送请求
--------------------

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



其他内容
------------

### 查看原始的HTTP数据

虽然使用浏览器的检查功能, 也可以查看网络请求的内容, 但其中的分隔符等细节还是被隐藏了, 所以如果想看到二进制级别的HTTP报文, 最直接的方法还是直接抓包.

抓包的工具很多, 例如`Ethereal`或者`Wireshark`. 如何使用这些工具偏离本文的主题太远了, 就不详细介绍了. 但需要说明, 新版本的`Wireshark`支持抓取本地回环数据, 所以如果想抓取本地运行的多个服务之间的HTTP数据包, 那么还是建议安装`Wireshark`. 最终, 我们可以得到抓包的结果, 以下是一个HTTP响应的抓包结果:

```
0000  9a aa b0 ee 57 25 00 1a  1e 02 0a 00 08 00 45 00   ....W%.. ......E.
0010  00 e7 0a 79 40 00 3b 06  70 6f ac 1e 10 22 0a 8b   ...y@.;. po..."..
0020  fd 5d 00 50 f8 6c ab 15  24 0c 80 c2 54 5d 50 18   .].P.l.. $...T]P.
0030  66 79 e6 07 00 00 48 54  54 50 2f 31 2e 31 20 32   fy....HT TP/1.1 2
0040  30 30 20 4f 4b 0d 0a 53  65 72 76 65 72 3a 20 6e   00 OK..S erver: n
0050  67 69 6e 78 0d 0a 44 61  74 65 3a 20 4d 6f 6e 2c   ginx..Da te: Mon,
0060  20 31 32 20 41 75 67 20  32 30 31 39 20 30 32 3a    12 Aug  2019 02:
0070  35 32 3a 31 30 20 47 4d  54 0d 0a 43 6f 6e 74 65   52:10 GM T..Conte
0080  6e 74 2d 54 79 70 65 3a  20 74 65 78 74 2f 68 74   nt-Type:  text/ht
0090  6d 6c 0d 0a 43 6f 6e 74  65 6e 74 2d 4c 65 6e 67   ml..Cont ent-Leng
00a0  74 68 3a 20 31 34 0d 0a  43 6f 6e 6e 65 63 74 69   th: 14.. Connecti
00b0  6f 6e 3a 20 63 6c 6f 73  65 0d 0a 53 52 75 6e 46   on: clos e..SRunF
00c0  6c 61 67 3a 20 53 52 75  6e 20 70 6f 72 74 61 6c   lag: SRu n portal
00d0  20 73 65 72 76 65 72 20  6e 65 77 20 76 65 72 73    server  new vers
00e0  69 6f 6e 0d 0a 0d 0a 75  6e 6b 6e 6f 77 6e 20 75   ion....u nknown u
00f0  73 65 72 28 29                                     ser()    
```

除去MAC协议,IP协议和TCP协议的头部信息, 可以看到第`0030`行的第7个字节开始, 对应的文字为`HTTP/1.1 200 OK`. 这正是HTTP响应的第一行信息. 依次往后看, 还可以发现很多前面介绍过的头部属性, 并且可以清晰的看到, 每个属性结束后都有两个字节`0d 0a`, 这正是`\r\n`的二进制编码.

最后, 在第`00e0`行的第4到第7个字节是`0d 0a 0d 0a`, 也就是`\r\n\r\n`, 即Header与Body的分隔符. 因此最后的`unknown user()`是位于HTTP Body之中的内容.


HTTP缓存控制
----------------------

浏览器缓存涉及到HTTP协议中的三个属性

1. Last-modified: Web服务器自动添加, 浏览器在此请求时携带此数据, 如果无变化, 服务器返回403
2. Etag: 类似文件的Hash值, 文件多次修改后内容不变时, Etag不变
3. Expires: 服务器或程序直接控制过期时间, 控制能力最强


更多内容可以参考下面的文章
-[最常被遗忘的Web性能优化：浏览器缓存](https://segmentfault.com/a/1190000009970329)
