---
title: Android文件读写方法
date: 2017-10-18 10:44:15
categories: Android
tags:
    - Android
cover_picture: images/android.jpg
---

由于中文翻译和表达的关系, Android中关于文件存储位置的有关词汇存在一些歧义, 同时也存在一些在PC上并不存在的概念. 为了便于查找, 下面先给出其中的各种位置的路径获取方法和一些对比. 之后对其中的一些概念和细节进行进一步的解释

## 各种存储位置的对比
名称                    | 位置                                 |获得方法                                           
:-----------------------|:------------------------------------ |:----------------------------------------------------
内部存储                |`/data/data/包名/files`               |`getFilesDir()`
外部存储的公共空间      |`/storage/sdcard0`                    |`Environment.getExternalStorageDirectory()`
系统的外部公共空间      |`/storage/sdcard0/类型名`             |`Environment.getExternalStoragePublicDirectory(TYPE)`
外部存储的私有空间      |`/storage/sdcard0/Android/data/包名/` |`getExternalFilesDir(TYPE)`


名称                    |卸载后是否清除|用户是否可见|其他程序是否可见| 主要用途
:-----------------------|:------------:|:----------:|:--------------:|:----------
内部存储                |是            |否          | 否             | APP私有文件存放的位置
外部存储的公共空间      |否            |是          | 是             | 希望与用户和其他程序共享的位置
系统的外部公共空间      |否            |是          | 是             | 希望与用户和其他程序共享的位置
外部存储的私有空间      |是            |是          | 否             | 对其他程序没有作用的其他次要文件

**注意**
1. **TYPE指Environment中定义的常量, 例如Environment.DIRECTORY_DOCUMENTS**
2. **如果TYPE置为null, 则返回相应的根目录**

----------------------------------------------------------------------------------------------------------
## 几种方式的简要说明
### 内部存储
1. 内部存储类似系统空间, 该位置对于非root用户不可见, 在此处创建的文件, 只有该APP可以进行读写
2. 当APP被卸载的时, 此空间内的所有文件都会被删除
3. APP有关的不需要共享的文件都可以存放在此文件夹中

### 外部存储的公共空间
1. 外部存储的公共空间通常对应于手机存储, 此处可以存放任意文件, 用户和任何程序都可以对其中的文件进行读写
2. 通常需要程序先创建一个文件夹, 之后在此文件夹中操作
3. 当APP被卸载时, 此区域的文件不会被删除
4. APP需要共享的文件存放在此处

### 系统的外部公共空间
1. 系统的外部公共空间是指系统预先定义的一系列文件夹, 例如Document, Music等. 
2. 与外部存储的公共空间相比, 由于系统预先定义, 因此使用更加方便
3. APP需要共享的文件存放在此处

### 外部存储的私有空间
1. 外部存储的私有空间存在于外部存储, 但其又具有私有空间的性质, 限制了其他APP访问此区域的文件
3. APP需要的大体积文件或其他次要文件存放在此处

-------------------------------------------------------------------------------------------------

## 外部存储与外置SD卡
对于系统而言, 只有内部存储和外部存储, 即无论内置SD卡还是外置SD卡, 都被视为外部存储, 但是由于使用外置SD卡的设备越来越少, 因此本文中不再讨论如何读写外置SD卡. 


----------------------------------------------------------------------------------------------------


## 测试函数
以下提供一个函数, 用于测试有关存储空间的位置
``` Java
void test(){
    //内部存储位置
    String L1 = getFilesDir().getAbsolutePath();
    Log.i("内部存储",L1);

    
    // 外部存储的公共空间
    String L2 = Environment.getExternalStorageDirectory().getAbsolutePath();
    Log.i("外部存储的公共空间",L2);
    // 输出外部存储的公共空间下, 所有的文件和文件夹
    for(String file:Environment.getExternalStorageDirectory().list()){
        Log.i("文件->",file);
    }

    // 系统的外部公共空间, 使用Environment指定类型
    String L3 = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).toString();
    Log.i("系统公共区域",L3);

    // 外部存储的私有空间
    String L4 = getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath();
    Log.i("外部私有区域",L4);
}
```

----------------------------------------------------------------------------------------------------

## 参考文献和扩展阅读
[彻底理解android中的内部存储与外部存储](http://blog.csdn.net/u012702547/article/details/50269639)
[Android中的内部存储与外部存储](http://www.jianshu.com/p/ad844547a43b)
[android中的文件操作详解以及内部存储和外部存储](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2013/0923/1557.html)
[Android 漫游之路------将文件保存到内存、SD以及获取手机内部存储与外部存储空间的大小](http://blog.csdn.net/helloxiaobi/article/details/12293197)