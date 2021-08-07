---
title: Android开发记录
date: 2017-10-12 15:38:17
categories: Android
tags: 
    - Android
cover_picture: images/android.jpg
---


## 内容概述
这里记录了我在开发Android程序的过程中遇到的一些问题和解决方案, 在帮助自己复习有关细节的时候, 希望也能给其他人提供一些帮助

-----------------------------------------------------------------------------------------------------------

## 使用网络
在Android程序中, 如果想要正确的使用网络功能, 需要满足以下条件
1. 在`AndroidManifest.xml` 添加如下语句申请网络使用权限
``` XML
<manifest ... >
    ...
    <uses-permission android:name="android.permission.INTERNET" />
    ...
</manifest>

```
2. 在单独的线程中编写网络相关代码
3. 在主线程上使用start()方法启动线程

**说明**：在Android系统中, 规定不允许在主线程执行网络操作, 因此所有的网络相关操作都需要在单独的线程上进行

---------------------------------------------------------------------------------------------------------------

## 读写文件
1. 在`AndroidManifest.xml` 中添加如下语句申请外部读写权限
``` XML
<manifest ... >
    ...
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    ...
</manifest>

```

2. 调用`getExternalFilesDir`函数获得外部存储上的私有空间
3. 使用`Environment`上的常量指定具体的文件夹类型, 一个例子如下
``` Java
// 获得外部储存上的私有空间下的download目录对应的位置
File path = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS);
```

4. **注意**：给定的路径不一定存在, 使用前需要判断是否存在该目录

--------------------------------------------------------------------------------------------------------

## 更新UI
1. 只有主线程可以更新UI
2. 只有主线程可以弹出对话框
3. 如下代码展示使用Handler类与Message类结合进行消息传递
``` Java
    // 位于主线程的handler接受信息, 更新UI
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
        ProgressBar prbBook = (ProgressBar)findViewById(R.id.prbBook);
        if(msg.what == FINISH_LOAD_BOOK_FROM_NET){
            prbBook.setProgress(100);
            initInfo();
            initCatalog();
        }
        else if(msg.what == UPDATE){
            prbBook.incrementProgressBy(msg.arg1);
        }
        }
    };

    //某个线程执行完毕使用Message类发送消息, 通知handler
    private class LoadBookThread implements Runnable{

        @Override
        public void run() {
            thisBook = new Book(bookURL);
            finishLoading = true;
            Message message = new Message();
            message.what = FINISH_LOAD_BOOK_FROM_NET;
            handler.sendMessage(message);
        }
    }
```

4. **注意**：根据Android Studio的提示, 直接使用handler类可能导致资源泄露,提示内容如下
```
This Handler class should be static or leaks might occur (anonymous android.os.Handler) less... (Ctrl+F1) 


Since this Handler is declared as an inner class, it may prevent the outer class from being garbage collected.
If the Handler is using a Looper or MessageQueue for a thread other than the main thread, then there is no issue. 
If the Handler is using the Looper or MessageQueue of the main thread, you need to fix your Handler declaration, as follows: 
Declare the Handler as a static class; 
In the outer class, instantiate a WeakReference to the outer class and pass this object to your Handler when you instantiate the Handler; 
Make all references to members of the outer class using the WeakReference object.
```
根据提示的内容, 这样设置handler, 可能会导致外部类的某些资源不能被释放, 所以应该建立一些弱引用. 有关于Java的弱引用, 可以参看[这篇文章](http://blog.csdn.net/matrix_xu/article/details/8424038)
处于这种情况, 除了可以按照上述的提示, 建立相关的弱引用以外, 还可以使用AsyncTask类, 具体使用方法, 后续再补充

-------------------------------------------------------------------------------------------------------

## CharSequence接口
TextView类的getText()方法返回的是CharSequence, 查阅API文档可知,CharSequence是一个接口, 已知实现这个接口的类有CharBuffer, Segment, String, StringBuffer, StringBuilder.所以如果直接使用getText()获得对象后, 使用equals与字符串比较可能并不会获得期望的结果,所以正确的做法应该是先调用toString()获得一个String对象, 然后再进行比较,示例代码如下
``` Java
TextView txtURL = (TextView)findViewById(R.id.txtURL);
txtURL.getText().toString().equals("LiZeC");
```

--------------------------------------------------------------------------------------------------------------

## 在代码中获得xml资源

```
java代码获取一个字符数组：
String[] names = getResources().getStringArray(R.array.string_array_name);
java代码获取一个整型数组：
int[] names = getResources().getIntArray(R.array.integer_array_name);
```

[扩展阅读](http://blog.csdn.net/hxltech/article/details/51837384)

----------------------------------------------------------------------------------------------------------------

## 使用lambda表达式
在Android Studio中直接使用lambda表达式, 有可能会报错,内容为`Error:Jack is required to support java 8 language features. Either enable Jack or remove sourceCompatibility JavaVersion.VERSION_1_8.`

此时可以在app模块的build.gradle的android下添加两项, 位置如下所示

``` 
apply plugin: 'com.android.application'

android {

    ......

    defaultConfig {
        jackOptions {
            enabled true
        }

    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    ......
}

```


## 使用Android Studio运行纯Java代码
1. 创建一个Module,类型为Java Lib
2. 在类中正确的输入main方法签名以后,左侧行号边会出现运行的符号,点击即可运行程序
3. 如果使用中文,可能出现乱码,在lib的build.gradle中添加以下内容
```
tasks.withType(JavaCompile) {
    options.encoding = "UTF-8"
}
```
4. 个人推测把源代码文本变成GBK编码也能解决乱码问题

## 其他待补充内容
2. handler其他细节
5. 使用菜单
6. 使用配置文件有关类
7. Splash界面设计
8. 隐藏ActionBar

