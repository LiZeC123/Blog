---
title: Android使用SQLite
date: 2017-10-19 17:33:26
categories: Android
tags:
    - Android
    - 数据库
cover_picture: images/android.jpg
---

## 操作步骤
首先, 从整体上概括一下Android使用数据库的操作方法, 具体来说, 可以分为以下的四步
1. 继承`SQLiteOpenHelper`
2. 实现其中的`onCreate`和`onUpgrade`方法
3. 使用`getWritableDatabase()`和`getReadableDatabase()`获得一个数据库的类
4. 在数据库的类上使用`insert`,`update`,`delete`,`query`等函数进行数据库操作

接来下对其中的一些细节进行说明

-----------------------------------------------

## 1. `OnCreate方法`
OnCreate函数的注释如下：
``` java
    /**
     * Called when the database is created for the first time. This is where the
     * creation of tables and the initial population of the tables should happen.
     *
     * @param db The database.
     */
    @Override
    public void onCreate(SQLiteDatabase db) {...}
```
这段注释说明, 在数据库被创建的时候, 才会调用此函数, 所以此函数主要用来做一些初始化的工作, 例如创建数据库的表. 
此函数传递了一个SQLiteDatabase对象, 可以使用此对象进行数据库操作

## 2. `OnUpgrade方法`
截取一段OnUpgrade方法的注释如下：
``` java
    /**
     * Called when the database needs to be upgraded. The implementation
     * should use this method to drop tables, add tables, or do anything else it
     * needs to upgrade to the new schema version.
     *
     * @param db         The database.
     * @param oldVersion The old database version.
     * @param newVersion The new database version.
     */
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion)  { ... }
```
从说明可以知道, 这个函数是用来升级数据库的, 包括卸载表, 添加表, 或者其他改变数据库模式的事情. 


## 3. 两种获得数据库的方法

SQLite提供了两种获得数据库的方法, 即 `getWritableDatabased方法` 和 `getReadableDatabase方法`.  还是一样, 首先阅读这两个函数的函数注释
``` java
    /**
     * Create and/or open a database that will be used for reading and writing.
     * The first time this is called, the database will be opened and
     * {@link #onCreate}, {@link #onUpgrade} and/or {@link #onOpen} will be
     * called.
     *
     * <p>Once opened successfully, the database is cached, so you can
     * call this method every time you need to write to the database.
     * (Make sure to call {@link #close} when you no longer need the database.)
     * Errors such as bad permissions or a full disk may cause this method
     * to fail, but future attempts may succeed if the problem is fixed.</p>
     *
     * <p class="caution">Database upgrade may take a long time, you
     * should not call this method from the application main thread, including
     * from {@link android.content.ContentProvider#onCreate ContentProvider.onCreate()}.
     *
     * @throws SQLiteException if the database cannot be opened for writing
     * @return a read/write database object valid until {@link #close} is called
     */
    public SQLiteDatabase getWritableDatabase() {
        synchronized (this) {
            return getDatabaseLocked(true);
        }
    }
```
这段注释有如下几个要点
1. 这个函数第一次被调用的时候, 会调用onCreate, onUpgrade和onOpen, 由此也进一步说明了onCreate, onUpgrade的调用时机
2. 一旦数据库被成功打开, 那么就会被缓冲, 因此可以每次在需要的时候调用此方法
3. 如果确定不再使用数据库, 则调用close()方法关闭数据库
4. 如果存在权限或者磁盘满的问题, 此次调用会失败, 但是之后的尝试可能成功
5. 数据库更新可能花费很多时间, 因此不应该在主线程上调用此方法


``` java
    /**
     * Create and/or open a database.  This will be the same object returned by
     * {@link #getWritableDatabase} unless some problem, such as a full disk,
     * requires the database to be opened read-only.  In that case, a read-only
     * database object will be returned.  If the problem is fixed, a future call
     * to {@link #getWritableDatabase} may succeed, in which case the read-only
     * database object will be closed and the read/write object will be returned
     * in the future.
     *
     * <p class="caution">Like {@link #getWritableDatabase}, this method may
     * take a long time to return, so you should not call it from the
     * application main thread, including from
     * {@link android.content.ContentProvider#onCreate ContentProvider.onCreate()}.
     *
     * @throws SQLiteException if the database cannot be opened
     * @return a database object valid until {@link #getWritableDatabase}
     *     or {@link #close} is called.
     */

    public SQLiteDatabase getReadableDatabase() {
        synchronized (this) {
            return getDatabaseLocked(false);
        }
    }
```
这段注释有如下几个要点
1. 其实`getWritableDatabase()` 和 `getReadableDatabase()`返回的对象完全相同
2. 如果磁盘满, 则返回一个只读的对象. 如果后续磁盘问题解决了, 那么之后调用此函数会返回一个可读可写的对象

## 4. ContentValues类
在很多函数中, 都需要使用这个类作为参数. 实际上这是一个类似哈希表的数据结构, 将列名和实际需要插入的值配对. 

## 5. 使用？
在很多函数中, 都涉及了`?`的使用, 但是应该注意以下几点
1. 注意使用范围, `?`与占位符不同, 并不能在任意位置取代任意词, 具体使用需要看各个函数的说明
2. `?`可以对用户输入的值进行转义, 从而减少自己编写的程序的处理过程
3. 拼接SQL语句时, 固定的值使用`String.format`函数, 包含用户输入的部分再使用?
4. 在某些函数中, 使用?替代的部分会视为字符串, 具体使用需要看各个函数说明

## 6. 调试
主要的函数都是通过返回值来决定是否执行成功. 同时SQLiteDatabase也提供了一组抛出异常的类似函数, 使用这些函数可以帮助定位数据库错误的原因. 例如insertOrThrow函数是insert对应的抛出异常的版本. 如果查看两者的源代码
``` Java
    public long insert(String table, String nullColumnHack, ContentValues values) {
        try {
            return insertWithOnConflict(table, nullColumnHack, values, CONFLICT_NONE);
        } catch (SQLException e) {
            Log.e(TAG, "Error inserting " + values, e);
            return -1;
        }
    }

    public long insertOrThrow(String table, String nullColumnHack, ContentValues values)
            throws SQLException {
        return insertWithOnConflict(table, nullColumnHack, values, CONFLICT_NONE);
    }
```
可以注意到, 不抛出异常的版本只是简单的捕捉异常并在日志中输出, 所以仅仅使用不抛出异常的版本, 也能查看到错误信息, 但如果需要程序出现异常时直接终止, 那么抛出异常的函数则使用更加方便. 


## 7. 其他
1. 比较字符串作为条件时, 字符串需要使用单引号括起来

--------------------------------------------------------

## 总结
本次学习SQLite的使用, 踩了很多坑, 尤其是在?的使用方面, 遇到了很多问题, 花了很多时间去调试. 其间我也在网上查阅了很多资料, 但是基本没有提及?使用的. 实际上, 后来仔细阅读了有关函数的注释, 就发现每个函数的注释中都已经明确的指明了各个函数中如何使用?, 所以网上也没有很多提及的文章. 所以下次百度之前, 还不如先多仔细看看提供的函数注释. 