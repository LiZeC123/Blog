---
title: Java单元测试之基础类库
date: 2018-11-21 16:53:41
categories: Java单元测试
tags:
    - Java
    - 单元测试
cover_picture: images/unit.png
---
<!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.4/MathJax.js?config=default"></script> -->

本文介绍Java的单元测试中经常使用的Junit和JMock库的主要API和使用方法. 阅读本文前需要对Maven有基本的了解, 如果对其不了解, 可以阅读 [Maven笔记之基本概念](https://lizec.top/2019/07/09/Maven%E7%AC%94%E8%AE%B0%E4%B9%8B%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5/) .


Junit使用
-----------------

### 依赖导入

根据官网上的指示, 编译和运行JUnit的代码, 需要依赖`junit-4.XX.jar`以及`hamcrest-core-1.3.jar`. 由于hamcrest库从2012年以来就没有更新, 因此1.3版是当前的最新版.

在Maven中,仅仅需要导入JUnit即可, 此依赖会自动依赖`hamcrest-core`, 具体的版本号可以在[MvnRepository](https://mvnrepository.com/)搜索.


### 待测试方法限制
Junit中的测试方法需要满足以下的条件
1. 使用@Test注解声明
2. 必须声明为 public void 且不接受参数
3. 可以抛出任意异常

### 生命周期

Junit中提供如下的一些注解,被各注解标记的方法的含义如下

Annotation      | Description                 | Annotation      | Description
----------------|-----------------------------|-----------------|-----------------------------
@BeforeClass    | 在测试类所有方法开始前调用    | @AfterClass     | 在测试类所有方法结束后调用
@Before         | 在测试类每个测试方法前调用    | @After          | 在测试类每个测试方法后调用


一个类中可以有任意数量的@BeforeClass, @Before, @After, @AfterClass标记, Junit不保证同类型标记的方法的调用顺序(调用顺序取决于反射的API实现).

### JUnit断言
在Junit的`org.junit.Assert`类中提供了大量的静态方法, 这些方法都是assertXXX的形式, 通常以静态导入的方式导入这些方法. 比较常见的方法如下表所示

方法                | 含义                          | 方法               | 含义
--------------------|------------------------------|--------------------|---------------------------
assertEquals        | 两个参数是否相等              | assertArraysEquals  | 两个数组是否包含同样的元素
assertTrue          | 语句是否为真                  | assertFalse         | 语句是否为假
assertNull          | 对象引用是否为空              | assertNotNull       | 对象引用是否非空
assertSame          | 两个对象是否引用同样对象       | assertNotSame       | 两个对象是否应用不同的对象


### Hamcrest匹配器

除了常见的assertXXX API以外, JUnit还提供了一个assertThat方法. 此方法接受两个参数, 一个是Object, 另一个是`org.hamcrest.Matcher`. 而且Matcher是一个接口, 文档中指出, 如果需要自定义实现Matcher, 不应该直接实现这个接口, 而应该继承抽象类`org.hamcrest.BaseMatcher`, 从而可以保证在后续的更新过程中, 可以改变Matcher接口而不影响其他Matcher的实现.


使用过程中, `org.hamcrest.CoreMatchers`类提供了大量的静态方法, 这些方法都是一些谓词, 通常以静态导入的方式导入这些方法, 这些方法可以分为两类

#### 产生Matcher

以下的方法接受参数, 产生一个Matcher

方法            | 含义                             | 方法            | 含义
----------------|---------------------------------|-----------------|------------------------------------
equalTo         | 判断是否相等                     | not             | 判断是否不相等
nullValue       | 产生一个检查是否为Null的Matcher   | notNullValue    | 产生一个检查是否为非Null的Matcher
sameInstance    | 判断是否为同一个引用              | theInstance     | 判断是否为同一个引用
startsWith      | 判断字符串是否以指定的子串开头     | endsWith        | 判断字符串是否以指定的子串结尾
containsString  | 判断字符串是否包含指定的子字符串   |                 | 

一些方法的使用示例如下所示:

``` java
assertThat("foo", equalTo("foo"))
assertThat(new String[] {"foo", "bar"}, equalTo(new String[] {"foo", "bar"}))
assertThat(cheese, is(not(smelly)))
assertThat(cheese, is(nullValue())
assertThat("myStringOfNote", containsString("ring"))
```

#### 复合Matcher

以下的方法接受一个Matcher, 产生一个复合的Matcher

方法            | 含义                             | 方法            | 含义
----------------|---------------------------------|-----------------|-----------------------------------
allOf           | 判断是否所有Matcher都满足条件     | anyOf           | 判断是否有任何Matcher满足条件
both            | 是否添加的Matcher都满足条件       | either          | 是否存在Matcher满足条件
is              | 本身无操作,用于增强语义           | isA             | 代替instanceof
anything        | 创建一个永远匹配的Matcher         | not             | 对Matcher取反
everyItem       | 判断数组是否所有元素都满足条件     | hasItem         | 判断数组是否有元素满足指定的一个条件
describeAs      | 包裹已有的Matcher, 重写其描述     |                 |


注意: not方法比较特殊化, 也可以接受普通的参数, 与is一起表示不等于的语义.


一些方法的使用示例如下所示:
``` java
assertThat("myValue", allOf(startsWith("my"), containsString("Val")))
assertThat("myValue", anyOf(startsWith("foo"), containsString("Val")))
assertThat("fab", both(containsString("a")).and(containsString("b")))
assertThat("fan", either(containsString("a")).and(containsString("b")))
describedAs("a big decimal equal to %0", equalTo(myBigDecimal), myBigDecimal.toPlainString())
assertThat(Arrays.asList("bar", "baz"), everyItem(startsWith("ba")))
```

#### 自定义Matcher

以下演示如何使用自定义Matcher

``` java
@Test
public void testPhone() {
    String phone = "3232332";
    assertThat(phone,is(internationalNumber()));
}

public Matcher<String> internationalNumber() {
    return new BaseMatcher<String>() {
        @Override
        // 重写此方法, 判断是否满足条件
        public boolean matches(Object item) {
            if(!(item instanceof String)) {
                return false;
            }
            return ((String) item).matches("^\\+(?:[0-9] ?){6,14}[0-9]$");
        }

        @Override
        // 重写此方法, 在不匹配时输出适当的提示信息
        public void describeTo(Description description) {
            description.appendText("a correct type phone number");
        }
    };
}
```

### 检测异常
当被测试方法期待抛出异常时, 可以使用@Test的参数来实现此功能, 例如

``` java
@Test(expected = IllegalArgumentException.class)
public void ensureThatInvalidPhoneNumberYieldsProperException() {
    FaxMachine fax = new FaxMachine();
    fax.connect("+dsd-ds-0090");
}
```

如果此方法没有抛出IllegalArgumentException,则此方法运行失败. 但是使用这种方案只能检测异常, 而不能获得具体的异常以及进一步的分析异常的原因. 在这种复杂逻辑的情况下, 还是应该使用try-catch模式


### @Rule注解

通过该注解可以在每个测试方法的开始和结束后执行指定的操作, 通过此注解来替代原有的@Before和@After注解,从而避免同样的初始化代码在多个测试用例类种反复编写


#### 原理

使用@Rule标记的类必须实现TestRule接口,此接口定义如下
``` java
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

public interface TestRule {
    Statement apply(Statement base, Description description);
}
```

其中base表示即将执行的测试方法, description表示此方法的描述信息. 一个Rule的实现如下所示:

``` java
public class MethodNameExample implements TestRule {
    @Override
    public Statement apply(final Statement base, final Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                //想要在测试方法运行之前做一些事情, 就在base.evaluate()之前做
                String className = description.getClassName();
                String methodName = description.getMethodName();

                base.evaluate();  //这其实就是运行测试方法

                //想要在测试方法运行之后做一些事情, 就在base.evaluate()之后做
                System.out.println("Class name: "+className +", method name: "+methodName);
            }
        };
    }
}
```

根据文档要求, 使用@Rule标记的字段必须public and not static.

#### 内置规则

JUnit提供了一些内置的实现TestRule的类, 使用这些类可以完成全局超时控制,临时文件等功能. 这些规则全部位于`org.junit.rules`包下, 下面介绍两个最常见的规则

``` java
public class PublisherTest {
    @Rule
    public TemporaryFolder folder = new TemporaryFolder();


    @Rule
    public MethodRule globalTimeout = new Timeout(20);

    @Test
    public void thisTempFileIsSquashedAfterTheTest() throws Exception {
        File tempFile = folder.newFile();  // 创建一个临时文件
        assertTrue(tempFile.exists());
    }
}
```

上述代码中, TemporaryFolder在每个Test方法被调用以前都会创建一个新的根目录, Test方法中可以使用folder方法创建文件和目录, Test方法执行完毕后, floder会自动删除有关的文件和文件夹. globalTimeout则会对每个Test方法进行计时, 如果运行时间超过指定的最大时间, 则会将测试方法终止.

其他的规则可以查看`org.junit.rules`的文档, 其中的每个规则都在文档中提供了使用示例.


JMock使用
----------------------

### 依赖导入

根据[官网](http://jmock.org/)的指示, 编译和运行JMock需要`jmock-2.6.1.jar`, `hamcrest-core-1.3.jar`, `hamcrest-library-1.3.jar`和`jmock-junit4-2.6.1.jar`


在Maven中仅需要导入`jmock-junit4`即可, 此依赖会自动导入其他的三个依赖jar. 因为hamcrest库很久没有更新, 所以JUnit和JMock都是依赖同样版本的hamcrest库, 并不会产生冲突.

注意: 如果希望使用Rule注解, `jmock-junit4` 至少为`2.6.0`版本.

### JMock使用

根据官网上的示例, 结合JUnit4的一个测试应该具有如下的结构

``` java
import org.jmock.Expectations;
import org.jmock.integration.junit4.JUnitRuleMockery;
import org.junit.Rule;
import org.junit.Test;

public class PublisherTest {
    @Rule
    public JUnitRuleMockery context = new JUnitRuleMockery();

    public void oneSubscriberReceivesAMessage() {
        // 使用JMock产生了一个Subscriber类的实例
        // 使用final修饰, 从而可以在Expectations块中引用
        final Subscriber subscriber = context.mock(Subscriber.class);

        Publisher publisher = new Publisher();
        // 将mock对象注入待测试类
        publisher.add(subscriber);

        final String message = "message";

        // 需要检测的内容,有subscriber收到了指定的消息
        context.checking(new Expectations() {{
            oneOf (subscriber).receive(message);
        }});

        // 实际调用需要测试的方法
        publisher.publish(message);
    }
}
```

注意: 先调用context的checking方法, 然后再调用实际待测试的方法, 否则会抛出异常


### Expectations

与hamcrest库类似, JMock也提供了大量的谓词, 用来检测方法是否调用了指定次数, 接受的参数是否为指定的类型, 设置返回值等操作. 具体可以分成如下的几类

#### 调用次数

方法                  | 含义                       | 方法             | 含义
---------------------|----------------------------|------------------|--------------------------
oneOf                | 希望方法被调用有且只有一次   | exactly(n).of    | 希望方法正好被调用n次
atLeast(n).of        | 希望方法被调用至少n次        |  atMost(n).of    | 希望方法被调用至多n次
between(min, max).of | 运行调用min到max之间的次数   | never            | 希望方法不被调用  
allowing             | 允许方法调用任意次数         | ignoring         | 允许方法调用任意次数 

注意: allowing和ignoring效果相同, 具体使用哪一个谓词应该由实际的语义确定.

#### 参数匹配

以下的谓词用于限定被mock方法接受的参数的类型

方法                 | 含义                   | 方法                    | 含义      
---------------------|-----------------------|-------------------------|------------------------------
equal(n)             | 参数等于n              | same(o)                 | 参数与o是同一个对象
a(type)              | 参数是type类型的实例    | an(type)                | 参数是type类型的实例
aNull(type)          | 参数是type类型且为Null  | aNonNull(type)          | 参数是type类型且非Null
any(type)            | 参数是type的任意值      | not(m)                  | 将给定的Matcher取反      
anyOf(...)           | 参数匹配任意的Matcher   | allOf(...)              | 参数匹配全部的Matcher

上述所有的方法,最后都需要通过with方法转化为实际的类型,从而可以作为被测试方法的参数

例如对于被测试方法`add`, 通过如下的代码
``` java
allowing (calculator).add(with(any(int.class)), with(any(int.class)));
```

说明此方法可以调用任意次数,add的两个参数都是任意的int类型的值


#### 动作

以下谓词用于指定被mock对象的动作(Action)

方法                                    | 含义
----------------------------------------|--------------------------------------
will(returnValue(v))	                | 返回v给调用者 
will(returnIterator(c))	                | 每次调用返回集合c中的一个值
will(returnIterator(v1, v2, ..., vn))	| 每次调用返回v1到vn的一个值
will(throwException(e))	                | 抛出异常e给调用者
will(doAll(a1, a2, ..., an))	        | 在每次调用时执行a1到an的Action

