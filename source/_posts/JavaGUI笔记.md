---
title: JavaGUI笔记
date: 2017-08-10 22:39:43
categories: Java特性
tags:
	- Java
cover_picture: images/java.jpg
---

##  Label类
- 基本的设置参考代码补全即可

##  Button类
- 构造函数可以直接设置上面的标签内容, 也可以使用函数

##  TextField类
- 单行输入框, 构造函数可以设置宽度或者初始文本, 或者同时
- 设置宽度是指这个控件在界面上的长度大小
- getEchoChar函数设置回显字符样式
- setEditable函数设置是否可以编辑,此外估计setEnable功能类似

## TextArea类
- 多行输入框, 构造函数可以设置行和列数, 初始文本, 或者一起设置, 或者增加是否需要滑动条
- 包含一些和上面类似的函数, 可以使用append函数最后追加文本

## Choice类
- 单选下拉框, 
- 使用add添加可选字符串
- 可以使用索引获得某一指定字符串
- 使用getSelectedItem函数获得当前选中的字符串
- 使用select函数是控件显示为指定的字符串,如果不存在, 实际上是不会执行这一操作

## List类
- 可多选下拉框, 构造函数可以设置有多少行可见选项被显示
- 或者加上一个额外的布尔值, 表示能否多选,默认不能多选, 实际上这个空间至少在Windows平台上看起来像一个列表而不是一个下拉框
- 设置和获得函数基本相同, 但是因为可以多选, 因此返回值是字符串的数组

## Checkbox类
- 一个Checkbox是一个单独的选择, 可以把一组Checkbox放入CheckboxGroup中, 从而实现单选功能
- 构造函数可以为空, 设置字符串, 默认是否被选中, 或者两张一起, 此外还有一个三参数的构造函数, 第三个参数指定一个CheckboxGroup, 将若干个Checkbox放入该CheckboxGroup中
- 可以使用getState函数获得是否被选中
- CheckboxGroup可以使用getSelectedCheckbox获得被选中的Checkbox


## 事件处理
- 如果一个类想要对发生的时间进行处理, 需要实现指定的接口, 如ActionEvent, ItemEvent, KeyEvent. 不同的控件可以触发不同的事件, 通常的做法是在一个类的内部创建一个内部类来专门处理这些事件, 需要的时候, 就new一个新的类去处理. 这样可以实现分组（因为内部类也可以访问这个类的私有变量, 从而不受访问权限的影响）

## 布局管理
- Java大致分为三层容器
	- 顶层：Applet, Frame, Dialog
	- 中间：Panel, ScrollPane
	- 基本：之前的如Button等元素
- 每个容器对象, 都有他相应的布局管理器, 使用setLayout（）设置. 如果没有使用, 默认的是顺序布局
	
## Java应用程序
### Frame
- 表示一个窗口, 在这个窗口上面可以和小应用程序一样的添加各种控件, 设置窗口布局等
- setBounds设置窗口的位置以及大小
- WindowsEvent接口中定义了窗口中对应的事件
### 除了创建一个frame对象以外, 还可以选择将自己的类继承Frame类, 然后设置各种方法和对象

## 关于事件处理
- 实际上实现的接口也不过就是一个函数, 所以可以直接调用这些方法, 使用适当的内部类可以对这些方法进行分类

## JScrollPane
- 实际上, 不应该把这个认为是一个附加的属性, 而是把它认为是一个容器, 所以也需要为这个容器制定布局以后, 才能看到这个容器. 
- 尤其主要要设置中央文件, 才能看到包含在其中的内容


## Java提示框
- 在Java中也有, 利用JOptionPane类中的各个static方法来生成各种标准的对话框, 实现显示出信息、提出问题、警告、用户输入参数等功能. 这些对话框都是模式对话框. 
- ConfirmDialog　---　确认对话框, 提出问题, 然后由用户自己来确认（按"Yes"或"No"按钮）
- InputDialog　---　提示输入文本
- MessageDialog　---　显示信息
- OptionDialog　-－　组合其它三个对话框类型. 
- 这四个对话框可以采用showXXXDialog()来显示, 如showConfirmDialog()显示确认对话框、showInputDialog()显示输入文本对话框、showMessageDialog()显示信息对话框、showOptionDialog()

## 选择性的对话框
1. ParentComponent：指示对话框的父窗口对象, 一般为当前窗口. 也可以为null即采用缺省的Frame作为父窗口, 此时对话框将设置在屏幕的正中. 
2. message：指示要在对话框内显示的描述性的文字
3. String title：标题条文字串. 
4. Component：在对话框内要显示的组件（如按钮）
5. Icon：在对话框内要显示的图标
6. messageType：一般可以为如下的值ERROR_MESSAGE、INFORMATION_MESSAGE、WARNING_MESSAGE、QUESTION_MESSAGE、PLAIN_MESSAGE、
7. optionType：它决定在对话框的底部所要显示的按钮选项. 一般可以为DEFAULT_OPTION、YES_NO_OPTION、YES_NO_CANCEL_OPTION、OK_CANCEL_OPTION. 

## Java选择文件提示框
- 使用JFileChooser类, 使用setFileSelectionMode函数设置提示框模式, 使用showOpenDialog显示提示框, 使用getSelectFile获得选中的文件

## 设置文本框居中
- setLocationRelativeTo(null), 设置此窗口与其他窗口的相对位置, 为null表示在屏幕上居中


## 菜单
- 一个界面可以有一个菜单栏(MenuBar)
- 每个菜单栏可以包含多个菜单(Menu)
- 每个菜单可以包含多个菜单选项(MenuItem)
- 每个菜单选择通过addActionListener函数实现事件响应