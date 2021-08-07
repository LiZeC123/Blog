---
title: Java单元测试之有效测试
date: 2018-11-21 16:54:04
categories: Java单元测试
tags:
    - Java
    - 单元测试
cover_picture: images/unit.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->



什么是优秀的测试
---------------------

### 测试的价值
- 测试帮助捕获错误,因此一个永远正确的测试是一个无效的测试,而一个永远错误的测试也不能提供有效的信息.
- 在另一个层面,测试提供一个实际使用的环境,从而明确实际的需求并给出辅助设计
- 编写测试的最大价值不在于结果,而在于编写过程的学习


### 评价测试的标准
- 可读性, 较少阅读代码的难度, 从而提供生产力
- 测试结果的准确性, 不要让错误抵消了测试带来的好处
- 可信赖性和可靠性

### 测试的潜力
- 将测试作为一种设计工具,指导代码对实际用途的设计,从而开发过程变为 `测试->代码->重构` 的循环
- 首先给出测试,之后以测试为依据写出能通过测试的代码, 最后重构代码. 




测试替身
-----------

测试替身的作用是将被测代码与周围隔开,使测试不依赖随机数等外部因素, 从而将执行变得确定. 此外使用测试替身还可以模拟特殊的场景, 或者暴露特定的信息.


### 替身的类型

类型           |    使用情景
---------------|------------------------------------------------------------
测试桩(Stub)    | 不关心替身的实现时, 使用测试桩
伪造对象(Fake)  | 在需要某些情况下能特异性的返回不同结果时, 使用伪造对象.
测试间谍(Spy)   | 当需要获得一些内部信息时, 使用测试间谍
模拟对象(Mock)  | 需要对替身进行精细的控制时, 使用模拟对象

具体使用哪一种替身取决于具体的需求:
- 如果关心交互情况, 考虑使用Mock
- 如果使用Mock的结果不如预期, 可以考虑使用一个Spy
- 如果只关心替身向被测对象发送的相应, 可以使用Stub, 或者使用简单的Mock
- 如果运行于一个复杂的场景, 而且不能简单的使用Stub, 可以考虑使用Fake


### 测试桩(Stub)

桩都是简单的, 通常只是硬编码的返回一个结果或者完全就是空的方法. 在这种情况下, 我们通常不关心替身如何实现, 也不希望因为替身的实现逻辑消耗太多时间和资源

``` java
public class LoggerStub implements Logger {
    public void log(LogLevel level, String message) {
        // 空方法
    }

    public LogLevel getLogLevel() {
        return LogLevel.WARN;   // 硬编码返回值
    }
}
```

### 伪造对象(Fake)

伪造对象像一个真实事物的简单版本, 优化的伪造真实事物的行文, 比测试桩更加真实. 持久化对象是使用Fake的典型场景, 由于数据访问会消耗很多时间, 而且操作有副作用, 因此不应该使用真实的数据库.

在访问文件或者数据库时, 使用一个Fake就相当于自己实现了一个自定义内存数据库. 例如, 对于下面这个接口定义的数据库发方法

``` java
public interface BookRepository {
    void save(Book book);
    Book findById(long id);
}
```

可以通过以下这个Fake简单的实现数据库的有关操作. 

``` java
public class FakeBookRepository implements BookRepository {
    private Collection<Book> books = new ArrayList<Book>();

    public void save(Book book) {
        if(findById(book.getId()) == null) {
            books.add(book);
        }
    }

    public Book findById(long id) {
        for(Book book: books){
            if(book.getId() == id){
                return book;
            }
        }
        return null;
    }
}
```

### 测试间谍(Spy)

测试间谍继承需要替换的类,从而可以将一些内部数据通过额外的方法暴露给外部

``` java
public class DLogTest {
    @Test
    public void writesEachMessageToAllTarget() throws Exception {
        SpyTarget spy1 = new SpyTarget();
        SpyTarget spy2 = new SpyTarget();
        DLog log = new DLog(spy1,spy2);
        log.write(Level.INFO,"message");
        assertTrue(spy1.received(Level.INFO,"message"));
        assertTrue(spy2.received(Level.INFO,"message"));
    }
}

private class SpyTarget implements DLogTarget {
    // 记录收到的记录
    private List<String> log = new ArrayList<String>();

    @Override
    public void write(Level level, String message) {
        log.add(concatenated(level, message));
    }

    boolean received(Level level, String name) {
        return log.contains(concatenated(level,name));
    }

    // 省略concatenated 方法的实现
}
```

### 模拟对象(Mock)

模拟对象除了保证方法可以被特异性的调用以外, 还可以对调用次数做出规定, 从而任何条件不满足时都能抛出异常. 对于模拟对象, 可以使用JMock, Mockito等模拟对象库. 关于模拟对象的使用可以阅读[Java单元测试库简介](http://lizec.top/2018/11/17/Java%E5%8D%95%E5%85%83%E6%B5%8B%E8%AF%95%E5%BA%93%E7%AE%80%E4%BB%8B/#JMock%E4%BD%BF%E7%94%A8) 的JMock章节.


Given, When, Then
-------------------------

`给定-当-那么` 是一种组织测试方法的约定, 一个测试方法可以分成三个部分, 使用这种表达是希望我们在编写测试的过程中能够关注于行为, 而不是程序实现的细节. 下面是一个示例

``` java
@Test
public void usesInternetForTranslation() throws Exception {
    // Given
    final Internet internet = context.mock(Internet.class);
    context.checking(new Expectations(){{
        one(internet).get(with(containsString("langpair=en%7Cfi")));
        will(returnValue("{\"translatedText\":\"kukka\"}"));
    }});
    Translator t = new Translator(internet);

    // When
    String translation = t.translate("folwer",ENGLISH,FINNISH);

    // Then
    assertEquals("kukka",translation);
}
```

注意, 一定要避免对Mock对象设置过于详细的期望, 如果太详细, 会导致程序的灵活性降低, 细小的变更也会导致测试的错误. 测试用例应该检测程序的行为, 而不是程序的实现.




参考文献
-------------------
- [安卓单元测试(八)：Junit Rule的使用](http://chriszou.com/2016/07/09/junit-rule.html)
- [深入JUnit源码之Rule](http://www.blogjava.net/DLevin/archive/2012/05/12/377955.html)