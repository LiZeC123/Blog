---
title: Python笔记之网络请求
date: 2021-07-25 11:26:32
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---



由于Python的脚本特性, 使得Python特别适合开发网络请求的小脚本. 


requests库简介
-------------------

虽然Python自带的网络库也能够实现网络请求, 但用起来不够简单直接, 所以在条件允许的情况下, 还是直接安装`requests`库, 然后使用其提供的高级API能够更好的满足需求.


对于HTTP支持的6种操作, Requests库提供同名的方法实现对应的HTPP请求操作, 例如发送一个GET请求只需要如下的一行代码

```py
r = requests.get("http://www.baidu.com")
```

> 访问[这里](https://gist.github.com/LiZeC123/80d95703ae81cc111fa063c4fdd5a815)查看一个完整的Requests使用举例

### 快速生成代码

在使用Python发送网络请求的场景中, 有相当大的概率是通过Chrome浏览器的控制台获取某个链接, 然后将请求的信息转写为Python代码. 这一操作非常的机械, 可以考虑按照如下的步骤自动生成

1. 在对应的请求上选择复制为cURL代码
2. 通过[此网站](https://curlconvert.trumanwl.com/python)自动将cURL代码转换为对应的Python代码

> 此方案能自动填充cookie等信息, 减少重复的开发工作. 非常适合只用一次的场景.

### 五个常用属性

属性名						|效果
----------------------------|----------------------------
r.status_code 				| 返回状态码(200 表示成功)
r.text						| 响应内容
r.encoding 					| 猜测的编码方式
r.apparent_encoding			| 根据内容分析的编码方式
r.content					| 二进制内容

> 推测编码功能在大部分时候都能正常工作, 但对于中英文混合的标题, 容易出现推测错误的情况.

### 常见异常

异常名							| 解释
--------------------------------|----------------------------------
requests.ConnectionError		| 拒绝连接或者DNS查找失败
requests.HTTPError 				| HTTP层面错误
requests.URLRequired			| URL缺失异常
requests.TooManyRedirects		| 重定向次数太多
requests.ConnectTimeout			| 连接远程服务器超时
requests.Timeout 				| 请求URL请求超时

> 使用`r.raise_for_status()`可以判断HTTP响应的状态码并根据错误码抛出相应的异常


```py
import requests
 
def getHTMLText(url):
	try:
		r = requests.get(url,timeout=30)
		r.raise_for_status() #判断状态
		r.encoding = r.apparent_encoding
		return r.text
	except:
		return "Exception in getHTMLText"
 
if __name__ == "__main__":
	url = "http://www.baidu.com"
	print(getHTMLText(url))
```


BeautifulSoup解析器简介
-----------------------------------

### 解析器

解析器		         | 使用方法                             | 条件
--------------------|--------------------------------------|-------------------------------
bs4的HTML解析器	     | BeautifulSoup(mk,'html.parser') 	    | 安装bs4库
lxml的HTML解析器	 | BeautifulSoup(mk,'lxml')	            | pip install lxml
html5lib的解析器	 | BeautifulSoup(mk,'html5lib')	        | pip install html5lib

三种解析器的主要区别为
- html.parser为内置解析器, 不需要外部依赖
- lxml解析器依赖C模块, 速度最快
- htmk5lib解析器解析条件最宽松, 能处理有缺损的HTML文件


### 基本元素

BS可以将一个HTML文档转化为一个Python对象树, 并且树的嵌套结构与HTML的结构保持一致. 虽然HTML可以很复杂, 但在BS中实际上只有四种不同的基本元素, 分别是

元素    | 含义
--------|----------------------------------------
标签    | 一个HTML标签, 例如`p`或者`a`
名称    | 标签的名称, 例如`a`标签的名称就是字符`a`
属性    | 标签内的属性, 例如`a`标签的`src`属性
导航串  | 标签对内部的文字

四种属性的应用如下所示:

```py
# 提取标签
soup = BeautifulSoup('<b class="boldest">Extremely bold</b>', 'html.parser')
tag = soup.b
type(tag)
# <class 'bs4.element.Tag'>

# 提取名称
tag.name
# 'b'

# 提取属性
tag = BeautifulSoup('<b id="boldest">bold</b>', 'html.parser').b
tag['id']
# 'boldest'

# 提取导航字符串
soup = BeautifulSoup('<b class="boldest">Extremely bold</b>', 'html.parser')
tag = soup.b
tag.string
# 'Extremely bold'
type(tag.string)
# <class 'bs4.element.NavigableString'>
```

### 遍历方法

BS具有三种遍历方法, 分别是下行遍历, 上行遍历和平行遍历. 三种遍历方法的具体细节如下:


属性                 | 含义
--------------------|---------------------------------------------------------
.contents 	        | 列表类型, 返回`<tag>`的所有儿子节点
.children 	        | 迭代器类型, 返回所有的子节点
.descendants 	    | 迭代器类型, 返回所有的子孙节点的迭代器
.parent 	        | 节点的父亲标签
.parents 	        | 迭代器类型, 节点先辈标签
.next_sibling 	    | 返回按照HTML文本顺序的下一个平行节点标签
.previous_sibling   | 返回按照HTML文本顺序的上一个平行节点标签
.next_siblings 	    | 迭代器类型, 返回按照HTML文本顺序的后续所有平行节点标签
.previous_siblings 	| 迭代器类型, 返回按照HTML文本顺序的前续所有平行节点标签


### 提取方法简介

最基本的提取方法是`find_all(name,attrs,recursive,string,**kwargs)` 其中的参数含义为

- `name`:  标签的名称, 可以为列表, 则表示同时查找多个标签
- `attrs`: 标签具有的属性
- `recursive`: 是否对子孙标签进行搜索, 默认为True
- `string`:  标签之间的字符串

> 注意: `<tag>(...)`等价于`<tag>.find_all(...)`


方法                        | 作用
----------------------------|--------------------------------------
`find()`	                | 只返回一个搜索结果
`find_parents()`            | 在先辈中搜索
`find_parent()`             | 在先辈中搜索, 且只返回一个结果
`find_next_siblings()`      | 在后续平行节点中搜索
`find_next_sibling()`       | 在后续平行节点中搜索, 返回一个结果
`find_previous_siblings()`  | 在前序平行节点中搜索
`find_sibling()`            | 在前序平行节点中搜索, 返回一个结果

> 以上方法的参数均与`find_all()`相同. 返回所有结果的函数, 返回一个列表, 只返回一个结果的函数, 返回字符串



### 参考资料

实际上Beautiful Soup的使用并不复杂, 但由于HTML的内容多变, 因此最稳妥的方式还是逐步的调用Beautiful Soup的API, 观察输出的结果, 而不要期望一次性就能正确的提取需要的数据.

关于API的基本使用, 直接参考官方文档即可:

- [Beautiful Soup Documentation](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)


Scrapy简介
---------------------------------

> WARNING: 本章节笔记产生时间较早, 时效性可能存在问题

Scrapy是一个爬虫框架, 适合创建中型和大型的爬虫项目. 


### 命令行常用命令

命令                | 说明                   | 格式
--------------------|-----------------------|---------------------------
startproject        | 创建一个新工程         | `name[dir]`
genspider           | 创建一个爬虫           | `[options]<name><domain>`
settings            | 获得爬虫配置信息       | `[options]`
crawl               | 运行一个爬虫           | `<spider>`
list                | 列出工程中的所有爬虫    | 
shell               | 启动URL调试命令行       | `[url]`

### 目录结构

```
scrapytest/                 最外层目录
    scrapy.cfg              部署Scrapy爬虫的配置文件
    scrapytest/             Scrapy框架的用户自定义Python代码
        __init__.py         初始化文件, 通常不需要改动
        items.py            对应于框架的Item类, 通常不需要改动
        middlewares.py      对应于中间件, 需要复杂配置时, 才需要改动
        pipelines.py        对应于pipelines
        setting.py          对应于爬虫的配置文件
        scrapy/             代码模板目录
```
