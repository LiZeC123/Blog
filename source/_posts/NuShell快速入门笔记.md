---
title: NuShell快速入门笔记
math: false
date: 2026-11-20 14:27:50
categories:
tags:
    - NuShell
cover_picture:
---

在日常工作中有时候会有一些些shell脚本的需求, 但是bash的语法过于反人类, 根本记不住这些奇奇古怪的缩写以及各种由于shell限制导致的问题(例如对于空格及其敏感). 虽然用Python可以避免这些语法层面上的问题, 但Python调用其他程序又显得过于笨重. 因此非常需要一种调用其他命令像bash但是语法结构像其他编程语言的东西, 而这个解决方案就是NuShell.

> Bash的问题是写起来费劲, 但如果让AI来写, 那么Bash只是可读性差一点, 但也没那么难受了. 

安装NuShell
------------

NuShell是Rust写的, 只依赖一个单一的二进制文件. 从[Release](https://github.com/nushell/nushell/releases)页面选择合适的系统, CPU架构和C库的版本. 前两个参数比较容易理解, 关于C库主要有两个版本gnu和musl. musl相当于一个主打静态链接的替代版C库, 因此对于嵌入式或者比较老的系统更加友好, 不容易出现glib不匹配的问题. 

将压缩包解压后, 直接将nu文件复制到`/usr/bin`即可完成安装. 执行`nu`可启动交互式shell. 


管道与结构
-------------

Nu 的管道里流动的是结构化数据，不是文本。同一条“找出最大的 5 个文件”：

**Bash**：
```bash
ls -la | awk '$5 > 1048576' | sort -k5 -nr | head -5
```

**Nu**：
```nu
ls | where size > 1mb | sort-by size -r | first 5 | select name size
```

不需要 `awk` 解析列位置，不需要 `sort -k` 记字段编号。列名 `size` 可以直接比较、排序、选取。

`select`、`reject`、`rename`、`insert`、`update`、`upsert` 是列级操作的主力。注意 `upsert`：列存在则更新，不存在则插入，省掉“先判断再操作”的分支。

```nu
ls | upsert size {|r| $r.size / 1kb } | rename size_kb
```

`group-by` + `transpose` 做聚合，替代 `find + awk + sort + uniq -c`：

```nu
ls **/* | group-by {|f| $f.name | path parse | get extension } | transpose ext count | sort-by count -r
```

`transpose` 把记录转成表格，`group-by` 的键变成列。这是 Nu 里“计数”最自然的写法。




结构化 `ls` 与路径操作
----------------------

`ls` 返回的是带 `name`、`type`、`size`、`modified` 等列的表格，不是字符串列表。因此文件筛选不需要 `find` 加 `-name` 再拼正则：

```nu
ls **/*.rs                                    # 递归找 .rs（替代 find . -name "*.rs"）
ls | where type == dir                        # 只列目录（替代 ls -d */）
ls | where modified >= (date now) - 2wk       # 最近两周修改过
ls | where name =~ '(?i)readme'               # 大小写不敏感匹配
```

`glob` 在需要“只要路径列表、不要文件元数据”时使用，支持深度限制和排除：

```nu
glob **/*.{rs,toml} --depth 2
glob '**/*' --exclude ['**/target/**', '**/.git/**']
```

`cp`、`mv`、`rm` 的语义与 Bash 接近，但参数是结构化的：`cp -r src dest` 递归复制目录，`rm -r` 递归删除。真正需要切换习惯的是**重定向**：Nu 没有 `>` 和 `>>`，用 `save` 替代。

```nu
ls | save listing.json                         # 结构化数据写文件，格式由扩展名推断
"raw text" | save --raw notes.txt              # 字符串原样写入，替代 >
some-command e> errors.log                     # 只重定向 stderr
some-command o+e> combined.log                 # stdout + stderr 合并
```

路径操作集中在 `path` 子命令下，返回的仍然是字符串，可以继续进管道：

```nu
"~/projects" | path expand                     # 展开 ~ 和相对路径
["/tmp", "work", "logs"] | path join           # 拼接路径片段
"/home/user/report.tar.gz" | path parse        # → {parent, stem, extension}
```

`path join` 比手工字符串拼接安全：它处理分隔符和尾部斜杠，不依赖当前操作系统。

**一个完整的“遍历—筛选—处理”链条**，替代 `find -exec`：

```nu
ls **/*.log | where size > 10mb | each {|f| 
    open --raw $f.name | lines | last 100 | save --raw ($f.name + ".tail")
}
```


变量与字符串
------------

Nu 用 `let` 声明不可变变量，用 `mut` 声明可变变量，用 `const` 声明编译期常量。引用变量时加 `$` 前缀：

```nu
let name = "nushell"        # 不可变
$name                       # => nushell
$name = "bash"              # 报错：不可变变量不能重新赋值

mut count = 0               # 可变
$count += 1                 # => 1

const MAX_SIZE = 10mb       # 常量
```

不可变变量可以被**遮蔽**，用一个同名的 `let` 重新声明，旧值在当前作用域内不再可用：

```nu
let x = 10
let x = $x + 5              # 遮蔽，现在是 15
$x                          # => 15
```

`let` 也可以作为管道的一步。在管道**末尾**，它存储结果并原样输出；在管道**中间**，它存储输入并透传给下一步：

```nu
[3 1 2] | sort | let nums   # $nums 是 [1, 2, 3]
"hello" | let greeting | str length   # $greeting 是 "hello"，输出 5
```

如果需要用 `=` 形式从管道取值，应写成 `let nums = ([3 1 2] | sort)`，而不是在管道后加 `=`。

---

Nu 的字符串不止单引号和双引号。按是否转义、是否插值来选：

| 形式       | 示例                 | 转义                     | 插值 |
| ---------- | -------------------- | ------------------------ | ---- |
| 单引号     | `'hello world'`      | 无                       | 否   |
| 双引号     | `"line1\nline2"`     | C 风格 `\n` `\t` `\e` 等 | 否   |
| 原始字符串 | `r#'raw \d string'#` | 无                       | 否   |
| 单引号插值 | `$'Hello ($name)'`   | 无                       | 是   |
| 双引号插值 | `$"Hello ($name)"`   | C 风格                   | 是   |

**单引号**不解释任何转义，适合正则、路径、字面量文本。字符串内部的 `'` 不能转义，`''` 不会被合并成一个引号，而是原样保留。

**双引号**解释反斜杠转义：`\n`、`\t`、`\e`（ANSI 转义）、`\"`、`\\`、`\(`、`\)` 等。需要把字面反斜杠放进字符串时，必须写 `\\`。

**原始字符串**用 `r#'...'#` 包裹，不解释任何转义，内容可以跨行，适合正则和包含大量反斜杠的文本。如果内容本身含有 `'#`，可以在两端加更多的 `#`：`r##'contains '# inside'##`。


### 字符串插值

插值用 `$` 前缀加引号。括号 `()` 里面是**表达式**，不限于变量名——可以放运算、子表达式、甚至另一个管道：

```nu
let name = "nushell"
$"Hello, ($name)!"                   # => Hello, nushell!
$'Hello, ($name)!'                   # 单引号版本，不做转义解释

$"2 + 2 = (2 + 2)"                   # => 2 + 2 = 4
$"size: (10kb / 1kb) kb"             # => size: 10 kb
$"top file: (ls | sort-by size -r | first 1 | get name.0)"
```

双引号插值 `$"..."` 会解释转义，单引号插值 `$'...'` 不解释。需要插入路径或正则时，优先用 `$'...'`，避免反斜杠被吃掉。

**用插值构建外部命令**是常见模式。`^` 前缀表示调用外部程序，`$"..."` 构建完整路径：

```nu
let dir = "/usr/local/bin"
let tool = "rg"
^$"($dir)/($tool)" --version
```

`^` 放在 `$` 之前，表示“把插值结果当作外部命令来执行”。


### 字符串拼接与格式化

简单的拼接用 `+` 或 `++`。`++` 在管道中更自然，尤其配合 `each` 对列表中的每个字符串统一添加前缀或后缀：

```nu
let base = "/var/log/"
$base + "app.log"                    # => /var/log/app.log

['foo', 'bar'] | each {|s| '~/' ++ $s }
# => ~/foo, ~/bar
```

把表格列格式化成字符串，用 `format pattern`。模式里的 `{column_name}` 会被替换成对应列的值，比在 `each` 里手工插值更简洁：

```nu
ls | format pattern '{name}: {size}'
[[col1, col2]; [v1, v2] [v3, v4]] | format pattern '{col2}'
# => v2, v4
```

需要输出字面花括号时，重复一次：`{{` 和 `}}`。


## 与Bash的差异速查

[Coming from Bash](https://www.nushell.sh/book/coming_from_bash.html)