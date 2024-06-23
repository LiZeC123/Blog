LiZeC的博客源码
==========================

![](https://img.shields.io/github/license/LiZeC123/Blog)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/LiZeC123/Blog)
![GitHub last commit](https://img.shields.io/github/last-commit/LiZeC123/Blog)



LiZeC的博客的项目源代码, 访问 https://lizec.top 查看博客.



部署
---------

创建`docker-compose.yml`文件, 输入以下内容

```yml
version: '2'
services:
  blog:
    container_name: blog
    image: ghcr.io/lizec123/blog:latest
    ports: 
        - "7080:80"
```

从而从Github的镜像服务器拉取博客的镜像, 并启动对应的服务镜像, 并运行在7080端口



使用模块
--------

### UML图相关

- [hexo-filter-kroki](https://github.com/miao1007/hexo-filter-kroki)
- [kroki.io](https://kroki.io/)
- [PlantUML 简介](https://plantuml.com/zh/)
