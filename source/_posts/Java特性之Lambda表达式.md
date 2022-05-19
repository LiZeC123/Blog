---
title: Java特性之Lambda表达式
date: 2018-11-21 16:05:34
categories: Java特性
tags:
    - Java
    - 函数式编程
cover_picture: images/java.jpg
---




在很多函数式编程的语言中,都具有lambda表达式. lambda表达式可以视为一段可以被引用的代码, Java中经常使用的匿名类就可以视为一种lambda表达式的替代品. 在Java 8中, 正式的引入了lambda表达式的概念, 本文介绍如何在Java中使用lambda表达式.


基础知识
-----------

在Java中一直有需要lambda表达式的场景,一个典型的例子就是需要注入一个匿名类的接口. 例如

``` java
Thread thread = new Thread(new Runnable{
    public void run(){
        System.out.println("Hello");
    }
});
```

在上述例子中,实际上只是需要一个run方法而已,但是由于java是面向对象的语言,方法不能脱离对象存在,因此必须将方法依附与某个具体的类或者接口. 而使用lambda表达式后,上述代码可以简化为
``` java
Thread thread = new Thread(()->System.out.println("Hello"));
```

这样代码的简洁性就有了巨大的提升. 实际上,在Java 8中,任何需要一个接口函数的地方,都可以使用lambda函数进行替换.

一个完整的lambda表达式一般具有以下的形式
``` java
(String a,String b) -> {
    if(a.length() < b.length()){
        return a;
    }
    else{
        return b;
    }
}
```
一个lambda表达式可以分成以下几个部分
1. 参数列表,在上例中是`(String a,String b)`
2. 箭头`->`
3. 函数体

注意
1. 在任何情况下,都不需要写返回类型,返回类型由编译器根据上下文进行推导
2. 如果参数类型也可以被推导,则参数列表中也不用写变量类型
4. 如果只有一个参数,可以省略括号,例如`v -> Sysmtem.out.println(v)`
5. 如果不需要参数,则提供一对空括号,即`()`


引用方法
---------------

在某些接口中,可能需要的方法已经在其他类中提供了,因此java也提供了直接引用已经存在方法的语言,即 使用`::`来引用一个方法.
对于`::`操作符,有三种使用场景
1. 对象::实例方法
2. 类::静态方法
3. 类::实例方法


对于前两种方法,方法引用等于提供方法的的lambda表达式.例如

``` java
System.out::println <==> x -> Sysmtem.out.println(x)
Math::pow           <==> (x,y) -> Math.pow(x,y)
```

对于第三种情况,第一个参数将成为执行方法的对象,例如
``` java
String::length <==> x -> x.length()
String::compareToIgnoreCase <==> (x,y) -> x.compareToIgnoreCase(y)
```

在引用方法时,也可以使用this和super,两者指向的对象取决于定义lambda函数时的位置,例如
``` java
public class Main {
	public void greet() {
		System.out.println("Hello!");
	}

	public void hello() {
		Thread thread = new Thread(this::greet);
		thread.start();
	}
}
```
在上述hello()函数中,this指的就是所在的Main类,而this::greet就是该类中的greet函数. 实际上这与匿名类中使用`外部类.this`来访问外部的变量是类似的效果.

> 注意: 内部类中使用的this指的是内部类本身,而不是外部的类,这是lambda与内部类的一个区别

除了引用普通的方法以外,还可以**引用构造函数**,例如
``` java
List<String> labels = new ArrayList<>();
Stream<Button> stream = labels.stream().map(Button::new);
List<Button> buttons = stream.collect(Collectors.toList());
```
先不用在意这些函数到底都是些什么,这些函数具体的效果在后续章节中会进行介绍,现在只用注意到第二行的代码中,map函数接受了Button类的new构造函数. map函数会在labels的每个元素上调用Button的构造函数,从而构造了一组Button.

闭包作用域
-------------------

在很多实现了闭包的语言中,在函数内部定义的函数,可以自由的引用该函数外部的变量, 在java中也实现了类似的机制,例如
``` java
public static Runnable repeat(String text,int count) {
    Runnable runnable = () -> {
        for(int i=0;i < count;i++) {
            System.out.println(text);
            Thread.yield();
        }
    };
    return runnable;
}

public static void main(String[] args) {
    Runnable runnable = repeat("Hello", 10);
    new Thread(runnable).start();
}
```

在上述代码中,runnable中引用了其外部的text和count对象. 含有自由变量的代码段成为闭包. 

实现闭包有一个问题,那就是在runnable被调用的时候,repeat函数已经结束了,text变量和count变量已经离开作用域了. 所以在runnable中必须保存这两个变量. 而实际上java也对自由变量做了限制, 即在lambda中不可对自由变量进行修改. 这一点有两方面原因
1. lambda调用时,引用的自由变量可能已经不存在了,此时修改是没有意义的
2. 多个线程运行时,这样的修改不是线程安全的



JDK中新增Lambda相关代码
---------------------

### 生成比较器

Java的Comparator提供了一种生成比较器的方法, 仅需要像此方法提供一个类的属性提取方法, 即可生成比较该类的比较器

``` java
Comparator<Person> comp = Comparator.comparing(Person::getName);
comp.compare(p1,p2);
```

### Map操作

Map的一个常见操作是检查是否存在某个key, 如果不存在则放入新的值, Java新增`computer`, `computerIfAbsent`等方法处理这种情况, 例如

``` java
public Artist getArtist(String name) {
    return artistCache.computeIfAbsent(name, this::readArtistFromDB);
}
```

此外, 针对Map遍历语法比较困难的问题, Java也新增了ForEach方法, 例如

``` java
Map<Artist, Integer> countOfAlbums = new HashMap<>();
albumsByArtist.forEach((artist, albums) -> {
    countOfAlbums.put(artist, albums.size());
});
```