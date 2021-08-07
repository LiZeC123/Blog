---
title: Hexo命令简介
theme: solarized
revealOptions:
    transition: 'fade'
---

## Hexo命令简介

---

## 基础流程

过程        |    指令
-----------|-----------------------
创建新文章  | `hexo new filename`
渲染        | `hexo g`
本地测试    | `hexo s`
部署        | `hexo d`


---

## 草稿

过程        |    指令
-----------|-----------------------
创建草稿    | `hexo new draft <filename>`
发布        | `hexo publish <filename>`

----

## 草稿

- 新创建的草稿位于`source/_draft`
- 发布草稿时会修改文件属性

---

## 注意事项

1. 所有指令都应该在hexo文件夹下执行,否则无效
2. 及时备份源文件, 远程仓库中仅包含渲染后的文件

