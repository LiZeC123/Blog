---
title: Java源码分析之动态代理
date: 2021-07-31 10:17:56
categories: Java源码分析
tags:
    - Java
cover_picture: images/java.jpg
---




前段时间在学习Google的Java工具库Guava, 发现其中有一个反射包, 提供了动态代理的封装功能. 深入源码一看, 发现实际上还是用了JDK提供的动态代理功能. 查阅一下网络上的相关资料, 就可以看到很多文章声称JDK的动态代理是基于反射实现的. 但仔细一想就会发现其中存在一个问题, 即动态代理是需要返回一个新的类的, 而单纯的使用反射是不能够创造出一个新的类的. 那么JDK的动态代理究竟是如何实现的呢? 



JDK动态代理使用方式
-----------------------

```java
interface A {
    void sayHi(String name);
    int sayHello();
}

public class TestProxy {
    public static void main(String[] args) {
        A proxyA = (A)Proxy.newProxyInstance(A.class.getClassLoader(), new Class[]{A.class}, new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                if (method.getName().equals("sayHi")) {
                    System.out.println("Hi, " + args[0]);
                    return null;
                } else if (method.getName().equals("sayHello")) {
                    System.out.println("Hello.");
                    return 42;
                } else {
                    return null;
                }
            }
        });

        proxyA.sayHi("LiZeC");
        int ans = proxyA.sayHello();
        System.out.println("The Answer is "+ ans);
    }
}
```

使用JDK的动态代理需要如下几个步骤

1. 定义需要被代理的接口
2. 实现InvocationHandler接口, 实现具体需要被代理的逻辑
3. 使用Proxy类创建代理类


newInstance源码分析
----------------------

> 以下源码基于JDK11, JDK11的实现方式与JDK8略有不同

```java
public static Object newProxyInstance(ClassLoader loader,
                                        Class<?>[] interfaces,
                                        InvocationHandler h) {
    Objects.requireNonNull(h);

    final Class<?> caller = System.getSecurityManager() == null
                                ? null
                                : Reflection.getCallerClass();

    /*
        * Look up or generate the designated proxy class and its constructor.
        */
    Constructor<?> cons = getProxyConstructor(caller, loader, interfaces);

    return newProxyInstance(caller, cons, h);
}
```

`newProxyInstance`只是做一些基本的检查,然后调用`getProxyConstructor`得到代理类的构造函数. 最后在`newProxyInstance`的另一个重载版本中通过构造函数创建对象.


```java
private static Constructor<?> getProxyConstructor(Class<?> caller,
                                                    ClassLoader loader,
                                                    Class<?>... interfaces)
{
    // optimization for single interface
    if (interfaces.length == 1) {
        Class<?> intf = interfaces[0];
        if (caller != null) {
            checkProxyAccess(caller, loader, intf);
        }
        return proxyCache.sub(intf).computeIfAbsent(
            loader,
            (ld, clv) -> new ProxyBuilder(ld, clv.key()).build()
        );
    } else {
        // interfaces cloned
        final Class<?>[] intfsArray = interfaces.clone();
        if (caller != null) {
            checkProxyAccess(caller, loader, intfsArray);
        }
        final List<Class<?>> intfs = Arrays.asList(intfsArray);
        return proxyCache.sub(intfs).computeIfAbsent(
            loader,
            (ld, clv) -> new ProxyBuilder(ld, clv.key()).build()
        );
    }
}

```

`getProxyConstructor`也做了一些权限的检查并提供了一个缓存功能, 如果缓存中没有, 则会调用`ProxyBuilder`创建代理对象.

> JDK8的逻辑实际上和JDK11的逻辑是一样的, 不过这里JDK11的代码更清晰好懂

```java
Constructor<?> build() {
    Class<?> proxyClass = defineProxyClass(module, interfaces);
    final Constructor<?> cons;
    try {
        cons = proxyClass.getConstructor(constructorParams);
    } catch (NoSuchMethodException e) {
        throw new InternalError(e.toString(), e);
    }
    AccessController.doPrivileged(new PrivilegedAction<Void>() {
        public Void run() {
            cons.setAccessible(true);
            return null;
        }
    });
    return cons;
}
```

进入到`build`方法之中, 可以看到通过`defineProxyClass`创建了代理类, 之后获取代理类的构造函数并做权限检查. 因此经过上面一系列的跳转, 我们终于进入到看到了核心方法, 也就是`defineProxyClass`方法

------------------

```java
private static Class<?> defineProxyClass(Module m, List<Class<?>> interfaces) {
    // 省略部分代码 

    /*
        * Generate the specified proxy class.
        */
    byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
            proxyName, interfaces.toArray(EMPTY_CLASS_ARRAY), accessFlags);
    try {
        Class<?> pc = UNSAFE.defineClass(proxyName, proxyClassFile,
                                            0, proxyClassFile.length,
                                            loader, null);
        reverseProxyCache.sub(pc).putIfAbsent(loader, Boolean.TRUE);
        return pc;
    } catch (ClassFormatError e) {
        throw new IllegalArgumentException(e.toString());
    }
}
```
`defineProxyClass`代码很长, 做了很多设置,省略掉这些设置以后, 最核心的代码实际上就是两句

1. 使用`ProxyGenerator`直接在内存中生成了一个class文件
2. 调用`defineClass`方法将生成的文件加载到虚拟机中

因此实际上JDK的动态代理也是通过生成字节码并加载的方式实现的.



ProxyGenerator分析
----------------------

进入ProxyGenerator可以看到, 这个类确实就是手动写Class的各种字段在内存中拼接出来了一个Class文件. 虽然代码很复杂, 设计了很多Class文件的细节, 但是我们可以直接将生成的class文件保存下来并直接反编译查看其中的逻辑.

由于ProxyGenerator类并不是public类, 所以不能直接访问, 但只要使用一些反射技巧, 就可以轻松的获得这个对象并调用generateProxyClass方法, 例如

```java
Class<?> pGC = Class.forName("java.lang.reflect.ProxyGenerator");
Method generateProxyC = pGC.getDeclaredMethod("generateProxyClass", String.class, Class[].class);
generateProxyC.setAccessible(true);

byte[] classCode = (byte[])generateProxyC.invoke(null, "TestA", new Class[]{A.class});

OutputStream out = Files.newOutputStream(Path.of("TestA.class"));
out.write(classCode);
out.close();
```

直接使用IDEA打开保存的TestA.class文件, 可以看到如下的代码

```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.lang.reflect.UndeclaredThrowableException;

public final class TestA extends Proxy implements A {
    private static Method m1;
    private static Method m4;
    private static Method m2;
    private static Method m3;
    private static Method m0;

    public TestA(InvocationHandler var1) throws  {
        super(var1);
    }

    public final boolean equals(Object var1) throws  {
        try {
            return (Boolean)super.h.invoke(this, m1, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }

    public final int sayHello() throws  {
        try {
            return (Integer)super.h.invoke(this, m4, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final String toString() throws  {
        try {
            return (String)super.h.invoke(this, m2, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final void sayHi(String var1) throws  {
        try {
            super.h.invoke(this, m3, new Object[]{var1});
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }

    public final int hashCode() throws  {
        try {
            return (Integer)super.h.invoke(this, m0, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", Class.forName("java.lang.Object"));
            m4 = Class.forName("A").getMethod("sayHello");
            m2 = Class.forName("java.lang.Object").getMethod("toString");
            m3 = Class.forName("A").getMethod("sayHi", Class.forName("java.lang.String"));
            m0 = Class.forName("java.lang.Object").getMethod("hashCode");
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
}
```

看到以上代码以后, 我相信很多问题已经不需要多解释了, 例如为什么JDK的动态代理只能基于接口(因为默认继承了Proxy类), 为什么会抛出`UndeclaredThrowableException`等等.

不难看出, 在生成的类中确实使用了反射获得方法, 但在具体调用的时候, 还是通过字节码生成的方式直接调用的类方法而不是反射调用. 所以至少从性能的角度来说, 自己的逻辑如果不反射调用, 实际上是没有额外的反射调用开销的.



参考资料
--------------

- [ProxyGenerator生成代理类的字节码文件解析](https://www.cnblogs.com/liuyun1995/p/8144706.html)
- [Spring AOP --JDK动态代理方式](https://www.jianshu.com/p/a5e7f61db26d)