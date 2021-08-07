---
title: Python网络爬虫
theme: solarized
revealOptions:
    transition: 'fade'
---


## Python网络爬虫



- 关注思想, 忽视技术细节
- 思想不会局限于Python语言
- 技术细节会随着时间变化


Note: 暂时不考虑使用Python实现网络爬虫, 但是相关的知识还是需要学习

---

## 用到的库

- Python网络请求库(urllib)
- BeautifulSoup(bs4)
- 正则表达式(re)

---

## 构建稳定的程序

- 网络是不稳定而且经常出现错误的
- 在程序中应该充分的处理可能的异常

---

## 不要一直使用锤子

对于难以解析的页面, 可以考虑

1. 查看手机版
2. 选择JS中的信息
3. 从其他同类型网站获取

