---
title: Python笔记之依赖关系
math: false
date: 2026-11-27 14:48:32
categories: Python笔记
tags:
    - Python
cover_picture: images/python.jpg
---

# 从 conda 到 uv：一次心智模型的切换

如果你已经习惯了 conda 的 `create → activate → install → run` 流程，第一次接触 uv 时最容易产生的困惑是：它是不是只是更快一点的 conda？答案是否定的。uv 快的背后，是一套**完全不同的环境组织方式**——理解这一点，比记住命令映射更重要。

### 两种逻辑的根本差异

conda 的世界观是 **“环境是容器”** ：你先创建一个命名的环境（`conda create -n myenv`），激活它，然后往里装东西。环境独立于项目存在，你可以在任何目录下 `conda activate myenv` 进入同一个环境。

uv 的世界观是 **“项目即环境”** ：环境不再是需要你手动创建和激活的独立实体，而是项目的附属物。在项目根目录执行 `uv init` 后，uv 会在项目文件夹里生成 `.venv/`，项目的一切——依赖、Python 版本、锁文件——都围绕这个目录组织。你在哪个项目目录，就在哪个环境里；不需要“进入”环境，也不需要记住“我现在在哪个 conda 环境”。项目文件夹里的 `.venv/` 默认会被自动排除在版本控制之外，删掉它环境就没了，干净利落，没有全局状态残留。

这个差异带来的直接后果是：**环境管理从“日常操作”变成了“项目结构的副产品”** 。你不再照顾环境，你照顾项目。


### 命令速查：conda 到 uv 的映射

如果你已经有一个 conda 项目想迁移，最省力的方式是直接把 `requirements.txt` 喂给 uv：

```bash
uv add -r requirements.txt
```

这会一次性把旧依赖迁入 uv 的管理体系，同时生成 `pyproject.toml` 和 `uv.lock`，不需要逐条重写。

更日常的命令对照如下：

| 你想做的事           | conda 旧习惯                          | uv 新命令                                      |
| -------------------- | ------------------------------------- | ---------------------------------------------- |
| 创建项目/环境        | `conda create -n myenv`               | `uv init`（在当前目录初始化）                  |
| 添加依赖             | `conda install pkg`                   | `uv add pkg`                                   |
| 移除依赖             | `conda remove pkg`                    | `uv remove pkg`                                |
| 运行脚本/命令        | `conda activate` + `python script.py` | `uv run script.py`（自动使用项目环境）         |
| 一次性运行外部工具   | 不太方便，通常得建环境                | `uvx toolname`（临时隔离，用完即弃）           |
| 安装 Python 版本     | 依赖 conda 的 Python 包               | `uv python install 3.12`                       |
| 固定项目 Python 版本 | 在 environment.yml 中指定             | `uv python pin 3.12`（写入 `.python-version`） |
| 查看依赖树           | `conda list` / `conda tree`           | `uv tree`                                      |
| 打包发布             | `python -m build` / `twine`           | `uv build` / `uv publish`                      |

一个值得留意的兼容层：`uv pip install`、`uv pip freeze` 等命令保留了 pip 的语法习惯，适合在过渡期临时使用，但长期来看，项目工作流应当以 `uv add` / `uv sync` / `uv run` 为主。


### 项目工作流：`add → lock → sync → run`

uv 的项目工作流围绕四个命令展开，理解它们各自的分工比记住语法更重要。

`uv add pkg` 做两件事：把依赖**声明**写入 `pyproject.toml`，同时解析并更新 `uv.lock`。`uv.lock` 是一个**跨平台的锁文件**，记录了所有直接和传递依赖在所有可能的 Python 版本、操作系统和架构下的精确解析版本，应当提交到版本控制。`pyproject.toml` 表达的是“宽泛的需求”（比如 `requests>=2.28`），`uv.lock` 表达的是“精确的结果”——两者分工明确。

`uv lock` 只更新锁文件，不碰环境；`uv sync` 则根据锁文件让环境与锁定结果**精确一致**，默认会移除锁文件中不存在的多余包。`uv run` 是最常用的入口：它默认先检查锁文件是否与 `pyproject.toml` 同步，如果环境不存在或已过期，就自动完成同步，然后执行命令。

日常开发中，`uv run` 通常就够了，因为它在幕后替你做了 `sync` 的工作。显式使用 `uv sync` 的场景主要是：刚 `git clone` 一个仓库后，或者 CI 环境中需要明确控制安装步骤时。

一个值得记住的安全标志是 `--locked`。在 CI 或部署脚本中，使用 `uv sync --locked` 或 `uv run --locked`，可以强制要求锁文件必须与 `pyproject.toml` 一致，否则直接失败，而不是悄悄重新解析。这保证了流水线中安装的依赖与你在本地锁定过的完全同一组。


### 一次性脚本：不需要“环境”的场景

有些脚本可能只运行一次，或者用几天就丢弃，为它们维护一个 conda 环境确实不划算。uv 为这个场景提供了两条路径，按依赖的“持久性”选择。

**最轻量：`uv run --with`。** 把依赖直接写在命令行里：

```bash
uv run --with requests --with rich python quick_script.py
```

uv 会为这次执行临时准备一个隔离环境，跑完即弃，系统 Python 和你的主项目环境完全不受影响。不需要 `create`，不需要 `activate`，也不需要之后记得清理。

**更优雅：PEP 723 内联元数据。** 如果脚本需要被分享或反复使用，可以把依赖写进脚本自身。PEP 723 允许在 Python 文件顶部用注释块声明依赖和 Python 版本：

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests", "rich"]
# ///
import requests
from rich import print
...
```

之后直接 `uv run script.py` 即可，uv 自动读取元数据、准备隔离环境并执行。脚本变成了自包含的单文件——分享时对方只要有 uv，一条命令就能跑，不需要附带任何环境说明。新建脚本可以用 `uv init --script myscript.py` 生成模板，往已有脚本追加依赖可以用 `uv add --script myscript.py pkg`。


### 工具运行：`uvx` 与 `uv tool` 的分工

如果你只是想临时用一下 `ruff`、`black` 或某个 CLI 工具，不想把它装进任何项目或全局环境，`uvx` 就是为此设计的：

```bash
uvx ruff check .
```

`uvx` 是 `uv tool run` 的便捷别名，它会在缓存目录中创建一个临时隔离环境来运行工具，不污染当前项目。如果某个工具你天天用，可以 `uv tool install ruff` 将它持久安装到一个独立的工具环境并加入 `PATH`，它仍然不会进入任何项目的依赖。

这里有一个容易混淆的边界：**`uvx` 用于与当前项目无关的独立工具，`uv run` 用于需要当前项目依赖的工具**。`pytest` 和 `mypy` 这类工具应当使用 `uv run pytest`，因为它们需要读取你项目的代码和已安装的依赖；如果用 `uvx pytest`，工具将在隔离环境中运行，看不到你的项目包。


### Python 版本管理：从 conda 包里独立出来

在 conda 中，Python 版本是环境的一部分，由 conda 的 Python 包提供。uv 把这件事拆成了独立的命令：`uv python install 3.12` 安装一个由 uv 管理的解释器，存放在独立目录中，不影响系统 Python。在项目层面，`uv python pin 3.12` 会写入 `.python-version` 文件，之后 uv 在创建或同步这个项目的环境时，自动使用锁定的版本。

你通常不需要手动运行 `uv python install`——当 `uv sync` 或 `uv run` 发现项目需要的 Python 版本在本地不存在时，uv 会自动获取它。


### 为什么“热启动”几乎感觉不到等待

uv 在反复执行同一脚本或同步同一项目时的“瞬间完成”，不是魔法，而是两层复用叠加的结果。

**第一层是锁文件。** 一旦 `uv.lock` 存在，后续 `uv sync` 或 `uv run` 不再重新解析版本范围，而是直接按锁定结果执行——依赖解析这个最耗时的步骤被跳过了。

**第二层是全局缓存加文件系统链接。** uv 在全局只存一份解压后的包副本，不同环境中的文件通过硬链接“复用”，而不是复制。硬链接是文件系统层面的指针，不占用额外磁盘空间，也几乎没有复制开销。同一个包装进十个环境，磁盘占用和装进一个几乎一样。在 macOS 等支持的文件系统上，uv 还会使用写时复制，效果类似。

**这两层叠加起来，才是热启动“几乎瞬间完成”的真正原因**——不是 uv 每次都在重新做一遍解析和安装，而是它根本不需要重新做。


### 一个重要的边界：uv 不取代 conda 的全部领地

uv 从 PyPI 安装纯 Python 包和带有预编译 wheel 的原生包（numpy、pandas 等）非常胜任，但它的能力边界是 PyPI。conda 的真正优势在于它能把**非 Python 的原生依赖**作为一等公民管理：CUDA 链接的 PyTorch、完整的 GDAL 地理空间栈、R 互操作、FFmpeg 调用，这些是 PyPI 无法可靠提供的。

如果你的项目涉及这类原生栈，一个实际可行的**混合模式**是：用 conda（或 mamba）建立一个包含原生基础栈的环境，然后在这个环境内部用 uv 来管理上层的纯 Python 包。你既保留了 conda 对原生依赖的处理能力，又能享受 uv 在 Python 依赖解析和安装上的速度。


### 迁移路线建议

不必一次性推倒重来。一个低风险的路径是：

**第一步，安装 uv**。macOS / Linux 用 `curl -LsSf https://astral.sh/uv/install.sh | sh`，Windows PowerShell 用 `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`。uv 不依赖预装 Python。

**第二步，先在一个新脚本上感受“不需要建环境”** 。用 `uv run --with` 或 PEP 723 元数据跑一个一次性脚本，体会一下没有 `activate` 步骤的工作流。

**第三步，迁移一个不涉及原生栈的现有项目**。在项目目录运行 `uv init`，然后用 `uv add -r requirements.txt` 迁入旧依赖，之后全程用 `uv run` 执行。原有的 conda 环境保留不动——在同一个目录下，`python main.py` 仍然走 conda，`uv run main.py` 走 uv 的项目环境，两者互不干扰。

**第四步，确认满足需求后，逐步收缩 conda 的使用范围**，只将它留给真正需要原生栈的场景。

核心只有一条：**在 uv 的世界里，你不再“管理环境”，你管理项目；环境是项目的副产品，而不是你每天要照顾的对象。**