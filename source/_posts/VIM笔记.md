---
title: VIM笔记
date: 2020-11-01 21:26:02
categories:
tags:
    - VIM
cover_picture:
---



由于最近经常需要在服务器端简单修改一些配置文件, 因此有必要了解一下VIM的基本操作. 此外, 目前的主流IDE基本都提供了VIM的键位映射, 虽然这些键位映射的模式并不能等同于VIM, 但大部分基本操作都是支持的. 因此掌握了VIM的基本操作还是能够在其他IDE上提高代码的编辑速度.

~~目前的个人体验是, VIM适合编辑不太依赖代码补全的项目, 例如Python. 对于需要切换输入法的场景, 例如写博客, 由于多了切换的步骤, 因此不适合VIM. 对于写LeetCode这种可能要手写代码的场景, 可以考虑使用VIM作为IDE.~~

VIM的一大特色就是需要进行大量的配置才能用的舒服. 以前觉得不适合使用VIM的场景实际上都能够配置解决. 例如中英文切换就可以通过插件自动切换.

由于VIM的操作实在是太多, 根本不可能完全的记住, 所以本文采取需求驱动的方法, 每次遇到一个需求时, 使用查询VIM的相关用法, 并记录再这里. 按照这样的规律进行学习可能更容易记住相关的操作. 所以下面的内容不会按照逻辑顺序组织, 而是按照时间顺序组织.


![VIM键位图](/images/vimCheatSheet.jpg)

如上图所示, 给出了VIM大部分常见的操作, 同时每个按键也给了相应的含义, 这有助于记忆每个按键的功能.

> 对VIM了解的越多, 则从这张图中获得的信息越多



高价值参考资料
---------------------
- [Vim 从入门到精通](https://github.com/wsdjeg/vim-galore-zh_cn)
- [精通 VIM , 此文就够了](https://zhuanlan.zhihu.com/p/68111471)


基础移动
--------------


| 常见需求           | 指令            | 说明                                                              |
| ------------------ | --------------- | ----------------------------------------------------------------- |
| 跳转到文件的指定行 | `<N>G`/`:<N>`   | /                                                                 |
| 跳转到指定字符     | `f<a>` / `F<a>` | 小写字母`f`正向跳转, 大写字母`F`反向跳转                          |
| 删除一个单词       | `cw`            | `w`表示移动到单词的末尾位置                                       |
| 撤销上一个操作     | `u`             | /                                                                 |
| 全选               | `yG`            | 即复制当前位置到末尾的全部内容                                    |
| 复制字符串         | `f"yf"`         | 首先`f"`移动到字符串开始位置, 然后`yf"`复制到字符串结束的全部内容 |
| 删除字符串         | `f"dt"`         | 首先`f"`移动到字符串开始位置, 然后`dt"`删除                       |
| 标签跳转           | `ma` / `'a`     | `m`定义标签, `'`跳转到标签的所在行                                |
| 重新加载文件        | `:e`            |                                                               |
| 指定文件编码        | `:set encoding=utf8` |                                                            |

标签
-------

VIM可以定义标签, 标签是文本中的一个位置, 可以快速跳转到标签所在的位置

使用指令ma 定义标签a, 使用mA定义标签A. 小写字母只能在单个文件内跳转, 跨文件跳转需要使用大写字母. 
使用指令`a 跳转光标到标签a的位置, 使用指令 'a 跳转到标签a所在行的行首. 

| 指令        | 作用         |
| ----------- | ------------ |
| :marks      | 查看所有标签 |
| :delmarks a | 删除标签a    |
| :delmarks!  | 删除所有标签 |



寄存器
-------

寄存器暂存复制和剪切的结果. 所有的寄存器都是以双引号`"`+字母的形式构成. 通常情况下使用的是无名寄存器`""`(即寄存器的名称为双引号). 如果想把结果放入某个具体的寄存器, 可以如下操作


| 指令   | 作用                 |
| ------ | -------------------- |
| `"ayy` | 将当前行放入寄存器a  |
| `"ap`  | 粘贴寄存器a的内容    |
| `:reg` | 显示全部寄存器的内容 |


宏
-------

VIM可以将一组动作保存起来, 并在之后将其作为基本指令进行重放. 

按下`qa`开始录制宏并将宏保存到寄存器a中.  之后可以输入任意的指令序列, 最后回到normal模式再次按下q结束录制. 

使用`@a`重放`a`中记录的操作. 

> 宏的名字空间和寄存器是独立的, 不会相互影响

例如在rebase代码时, 可能看到如下的代码

```
pick commit4
pick commit3
pick commit2
pick commit1
```

如果想从第二行开始将所有的pick替换为s, 则可以在第二行开头的位置执行`qaces<ESC>jq`录制一个替换的宏, 然后输入`2@a`将这个宏直接重放两次



搜索和替换
------------

在正常模式输入`/`进入搜索模式, 此时直接搜索需要的字符串, 即可在文本中进行搜索. 输入要查找的字符串并按下回车进入搜索模式, 此时按`n`查找下一个, 按`N`查找上一个. 查找过程支持正则表达式.


VIM使用`:substitute`指令进行搜索和替换, 这一指令通常简写为`:s`, `:s`将当前行的指定字符串替换为另外一个字符串, 格式如下

```
:s/<find-this>/<replace-with-this>/<flags>
```

以将字符串tthe替换为the为例, 不同模式具有如下的格式

| 指令                 | 作用                             |
| -------------------- | -------------------------------- |
| `:s/tthe/the`        | 在当前行第一个匹配的位置进行替换 |
| `:s/tthe/the/g`      | 在当前行进行全部替换             |
| `:15,42s/tthe/the/g` | 在15行到42行之间的内容中进行替换 |
| `:%s/tthe/the/g`     | 全局替换                         |
| `:%s/tthe/the/gc`    | 全局替换并并在每一处询问是否替换 |



- [在 Vim 中优雅地查找和替换](https://harttle.land/2016/08/08/vim-search-in-file.html)



键位映射
---------------

键位映射的基本指令是`map`指令. 在这个指令的基础上可以添加一些前缀来限定范围, 前缀列表如下:

| 前缀词 | 效果                   |
| ------ | ---------------------- |
| nore   | 非递归映射             |
| n      | 表示在普通模式下生效   |
| v      | 表示在可视模式下生效   |
| i      | 表示在插入模式下生效   |
| c      | 表示在命令行模式下生效 |

因此`norenmap`表示在normal模式下的非递归映射.


> 把最常用的操作映射为最舒服的按键方式

- [【Vim】使用map自定义快捷键](https://blog.csdn.net/JasonDing1354/article/details/45372007)



IDEA使用VIM
---------------

IDEA系列的IDE均提供了VIM插件, 可以通过配置该插件实现使用VIM的效果. 首先需要安装如下的插件

- ideaVIM: 提供VIM的核心功能
- IdeaVimExtension: 提供中英文输入法自动切换功能


上述插件均可直接在插件市场下载. 安装完成后在IDE的右下角有一个VIM的图标,点击这个图片可以快速启用和关闭插件. 同样地, 需要写个配置文件来做相关的设置. 点击VIM图标可以打开配置文件, 输入如下内容:

```
" 显示当前模式
set showmode
" 共享系统粘贴板
set clipborad=unamed
" 打开行号
set number
" 打开相对行号
set relativenumber
" 设置命令历史记录条数
set history=2000
" 关闭兼容vi
set nocompatible
" 开启语法高亮功能
syntax enable
" 允许用指定语法高亮配色方案替换默认方案
syntax on
" 模式搜索实时预览,增量搜索
set incsearch
" 设置搜索高亮
set hlsearch
" 忽略大小写 (该命令配合smartcase使用较好, 否则不要开启)
set ignorecase
" 模式查找时智能忽略大小写
set smartcase
" vim自身命令行模式智能补全
set wildmenu
" 总是显示状态栏
set laststatus=2
" 显示光标当前位置
set ruler
" 高亮显示当前行/列
set cursorline
"set cursorcolumn
" 禁止折行
set nowrap
" 将制表符扩展为空格
set expandtab
" 设置编辑时制表符占用空格数
set tabstop=8
" 设置格式化时制表符占用空格数
set shiftwidth=4
" 让 vim 把连续数量的空格视为一个制表符
set softtabstop=4
" 基于缩进或语法进行代码折叠
set foldmethod=indent
set foldmethod=syntax
" 启动 vim 时关闭折叠代码
set nofoldenable

" 设置前导键
let mapleader=";"
" 暂时取消搜索高亮快捷键
nnoremap <silent> <Leader>l :<C-u>nohlsearch<CR><C-l>

" 移动相关
" 前一个缓冲区
nnoremap <silent> [b :w<CR>:bprevious<CR>
" 后一个缓冲区
nnoremap <silent> ]b :w<CR>:bnext<CR>
" 定义快捷键到行首和行尾
map H ^
map L $
map J <C-d>
map K <C-u>
" 定义快速跳转
nmap <Leader>t <C-]>
" 定义快速跳转回退
nmap <Leader>T <C-t>
" 标签页后退 ---标签页前进是gt
nmap gn gt
nmap gp gT

" 文件操作相关
" 定义快捷键关闭当前分割窗口
nmap <Leader>q :q<CR>
" 定义快捷键保存当前窗口内容
nmap <Leader>w :w<CR>

" 窗口操作相关
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" 使用idea内部功能
" 找到usage
nnoremap <Leader>u :action FindUsages<CR>
" 调用idea的replace操作
nnoremap <Leader>; :action Replace<CR>
" go to class
nnoremap <Leader>gc :action GotoClass<CR>
" go to action
nnoremap <Leader>ga :action GotoAction<CR>
" run
nnoremap <Leader>r :action RunClass<CR>
" 显示当前文件的文件路径
nnoremap <Leader>fp :action ShowFilePath<CR>
" 隐藏激活窗口
nnoremap <Leader>h :action HideActiveWindow<CR>

" 中英文自动切换
" 需要IdeaVimExtension插件的支持
set keep-english-in-normal-and-restore-in-insert

" other vim plugins
" comment plugin
set commentary
" surround plugin
set surround
" easymotion
set easymotion

" 一些有用的快捷键, 但是没做映射
" open project file tree ---------- alt + 1
" open terminal window   ---------- alt + F12
```

配置文件来自博客: [ideavim 配置说明](https://ravenblog.vercel.app/archives/9cf25d6b.html). 



VsCode配置VIM
--------------------

1. 下载插件`Vim`
2. 下载输入法切换工具[im-select](https://github.com/daipeihust/im-select#windows), 将
3. 将im-select放置到合适的位置(不需要是PATH路径)
4. 打开设置, 搜索`vim`进行配置
5. 打开设置, 搜索`vimrc`进行配置

- [如何解决VSCode Vim中文输入法切换问题？ - somenzz的回答 - 知乎](https://www.zhihu.com/question/303850876/answer/822818615)
- [How to modify/change the vimrc file in VsCode?](https://stackoverflow.com/questions/63017771/how-to-modify-change-the-vimrc-file-in-vscode)

> 一套配置下来也能用, 但是和Markdown All for One插件存在一些冲突, 因此用来写Markdown有些不合适


VIM基础配置
---------------

对于服务器上的VIM，因为大部分时候都是简单改配置，所以不需要太过复杂的配置文件，可以使用如下的简化版配置文件。VIM的配置位于用户目录的.vimrc文件, 建议在其中加入如下的内容

```
syntax on                   " 开启语法高亮
filetype plugin indent on   " 根据文件类型自动缩进

set autoindent              " 开始新的一行时自动缩进
set expandtab               " 将Tab展开为空格
set tabstop=4               " tab的空格数
set shiftwidth=4            " 自动缩进的空格数
set hlsearch                " 高亮搜索结果
set incsearch               " 在没有完成搜索输入时, 就根据搜索输入开始匹配

set backspace=2             " 修正backspace的行为
set number                  " 显示行号

colorscheme slate           " 颜色主题

" 定义快捷键到行首和行尾
map H ^
map L $
map J <C-d>
map K <C-u>

```

> 如果只是使用VIM的键位映射, 那么就没必要进行配置了



参考资料
-----------------
- [简明 VIM 练级攻略](https://coolshell.cn/articles/5426.html)
- [Linux vi/vim | 菜鸟教程](https://www.runoob.com/linux/linux-vim.html)
- [Vim简明教程【CoolShell】](http://blog.csdn.net/niushuai666/article/details/7275406)
- [Vim配置及说明——IDE编程环境](http://www.cnblogs.com/zhongcq/p/3642794.html)
