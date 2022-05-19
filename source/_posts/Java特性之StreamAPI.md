---
title: Java特性之StreamAPI
date: 2018-11-21 16:07:30
categories: Java特性
tags:
    - Java
    - StreamAPI
cover_picture: images/java.jpg
---



Stream是Java8中处理集合的关键抽象概念. 使用Stream API, 编译器可以针对性的使用并行操作来对运算进行加速, 同时使用这些API也能让我们从处理低层次循环中脱离出来, 从更高层次思考问题.



StreamAPI
--------------

以下代码演示了使用Stream API统计一段文本中所有长度大于7的单词数量
``` java
String contents = new String(Files.readAllBytes(Paths.get("alice.txt")),StandardCharsets.UTF_8);
List<String> words = Arrays.asList(contents.split("[\\P{L}]+"));
long count = words.stream().filter(w->w.length() > 7).count();
System.out.println(count);
```

上述代码中,实际只有第三行是真正执行操作, 而使用Stream可以概括成以下三步
1. 创建一个Stream
2. 在一个或多个步骤将一个stream转化为另一个stream
3. 使用一个终止操作来获得结果

注意:
1. Stream的操作很多都是延迟执行的, 只有到需要的时候, 有关的操作才会进行
2. Stream的执行顺序和实际调用的顺序可能并不一致
3. Stream不保存元素, 有关元素保存在底层的集合中


创建Stream
---------------------

创建一个Stream有如下的几种方法

来源类           | 方法名      | 说明
----------------|-------------|---------------------------------------------------------
Collection<E>   | stream()    | 任意的集合类均可使用此实例方法
Stream<T>       | of()        | 用于将若干个零散的元素组成一个流
Arrays          | stream()    | 用于将一个数组转化为流,这个流可能是特殊化的,例如IntStreamm
Files           | lines()     | 创建文件中每一行字符串组成的字符串流

``` java
List<Apple> inventory = Arrays.asList(
                new Apple(80,"green"),
                new Apple(155,"green"),
                new Apple(120,"red"));
Stream<Apple> s1 = inventory.stream();

Stream<String> s2 = Stream.of("123","234");

int[] A = new int[10]
Stream<int[]> s3 = Stream.of(A);   // 返回Stream<int[]>
IntStream s4 =  Arrays.stream(A); // 返回IntStream, 即针对int类型的stream
```

对于of()方法, 由于使用了可变参数, 因此需要注意
1. 可以接受数组, 但是无法转换基础元素组成的数组, 可以转化对象组成的数组并返回相应的类型
2. 由于自动装箱机制, 可以接受任意的基础元素, 并返回包裹类的流
3. 始终可以使用Arrays的stream()方法处理数组

> 在IDEA中对于任何的集合类型都可以使用`.stream`的方式转化为流, IDEA会自动处理上述的各种情况


特殊的流
--------------------

可以使用empty()函数获得一个空的流, 例如
``` java
Stream<String> stream = Stream.empty();
```

可以使用generate()函数获得一个无穷流, 每当需要一个元素的时候, 就会调用给generate()提供的函数创建一个新的元素, 例如
``` java
Stream<String> echo = Stream.generate(()->"Echo");
Stream<String> randoms = Stream.generate(Math::random);
```

如果需要创建一个0,1,2,3,...的无穷序列, 可以使用iterate()函数, 该函数需要一个种子和一个函数, 通过反复将函数运用到上一个结果上得到一个无穷序列
``` java
Stream<BigInteger> integers = Stream.iterate(BigInteger.ZERO,n -> n.add(BigInteger.ONE));
```


流转换
--------------------

以下三种方法都是用于转换流的方法, 即将一个流转换为另外一个流.

方法名    | 效果
---------|------------------------------------------------------------------------------------
filter   | 接受一个Predicate<T>对象,从而对流进行过滤
map      | 接受一个转换函数,此函数将一个元素转换为另一个元素;从而map方法将一个流转化为另一个类型的类
flatMap  | 接受一个转换函数,此函数将一个元素转化为一个流, 然后将所有返回的流合并成一个流


``` java
String[] words = {"a","bcfs","ew","eqe"};
Stream<String> stream = Stream.of(words);
// 通过过滤获得长度大于3的单词
Stream<String> longWords = stream.filter(w->w.length() > 3);
// 通过map转换为首字母组成的流
Stream<Character> firstChars = stream.map(s->s.charAt(0));

// 通过flatMap将多个流合并成一个流(将单词流拆分为字符流)
Stream<Character> letters = stream.flatMap(w -> {
    List<Character> result = new ArrayList<>();
    for(char c:w.toCharArray()) {
        result.add(c);
    }
    return result.stream();
});
```

> 注意: Objects类新增isNull和nonNull两个静态方法来进行NULL检查,在流中可能用到这些方法来进行匹配或过滤


提取或组合流
-----------------------

方法          |  效果
--------------|--------------------------------------------------------------------------
limit(n)      | 获得一个流的前n个元素(不足n则返回所有元素) 
skip(n)       | 跳过一个流的前n个元素
concat(s1,s2) | 将两个流连接成一个流(第一个流不能为无限流,否则第二个流就没有被使用的机会了)
peek()        | 可以添加一个函数,在每次取出一个元素时,调用添加的函数,从而便于调试

``` java
Object[] powers = Stream
        .iterate(1.0,p->p*2)
        .peek(e-> System.out.println("Fetching "+ e))
        .skip(3).limit(5).toArray();

Stream.of(powers).forEach(System.out::println);
```

> 注意: 默认情况下, 给定的流都是**有序**的. 当不需要有序时, 可以调用unorder()方法. 在无序条件下, dintinct()和limit()等方法可以获得更快的执行效率.


状态转换
-----------------------

方法       | 效果
-----------|---------------------
distinct   | 获得一个无相同元素的流
sorted     | 对元素进行排序

如果仅仅是最终的结果需要无相同元素, 也可以考虑不使用distinct方法, 而是将结果输出为一个Set.

sorted的排序依赖Comparable<T>接口, String,Integer等类已经实现了此接口, 以此为元素的流可以无参数的调用sorted方法. 对于没有实现此接口的类, 可以为sorted提供一个Comparator来实现比较. 

Comparator类提供静态方法comparing,传入抽出key的函数即可完成构造指定类型的Comparator

> 注意: 这些方法由于涉及状态, 基本上需要遍历整个流才能得到结果, 因此性能开销更大



简单聚合方法
-----------------------

### 查找和匹配

方法        |   效果                            | 方法        | 效果
------------|----------------------------------|-------------|------------------------------------------
min         | 获得流中最小值                    | max         | 获得流中最大值
findFirst   | 返回第一个符合条件的元素           |findAny     | 返回任意一个符合条件的元素(对多线程操作更友好) 
allMatch    | 返回是否所有元素均匹配给定的条件    |noneMatch   | 返回是否所有元素均不匹配给定的条件 


findFirst和findAny需要在调用之前调用filter函数进行筛选,而allMatch和noneMatch本身接受一个函数,因此可以直接使用

findFirst和findAny方法返回元素,而allMatch和noneMatch方法返回Boolean值


### Optional类型
findAny和findFirst方法并不直接返回元素,而是返回一个包装元素的Optional类型. 该对象中要么包含实际的元素,要么为空.
正确的使用方法是调用其ifPresent函数. 该函数接受一个函数,如果元素存在,则执行传入的函数,否则直接跳过.
``` java
String[] words = {"Question","Stream","What","How","That","This"};

Optional<String> T = Stream.of(words).filter(s->s.startsWith("T")).findAny();

T.ifPresent(System.out::println);
```

除此以外,还可以使用orElse函数时Optional对象为空时赋予另外的值,例如
``` java
String result = T.orElse("none");
```
除了orElse以外,还可以用orElseGet填入一段代码来计算默认值或者orElseThrow来抛出一个异常

### 使用举例
对于一个链式调用的过程,若其中的函数返回的不是基本类型而是Optional类型,可以使用flatMap函数来避免对空值的处理. 以下代码演示如何创建Optional对象以及如何组合链式调用
``` java
public class RunStream {
    public static void main(String[] args) {
        Optional<Double> result = Optional
                .of(-4.0)
                .flatMap(RunStream::inverse)
                .flatMap(RunStream::sqrt);
    }

    public static Optional<Double> inverse(Double x) {
        return x == 0 ? Optional.empty() : Optional.of(1 / x);
    }

    public static Optional<Double> sqrt(Double x) {
        return x < 0 ? Optional.empty() : Optional.of(Math.sqrt(x));
    }

}
```
Optional类有一个flatMap函数, 此函数接受一个条件, 对Optional进行过滤,并且返回一个新的Optional. 

当过程中所有的返回值都不为空时, 程序正常的调用. 否则任何空值都会导致最后结果为空值


聚合操作
----------------

方法       | 效果
-----------|----------------------------------------------------------
reduce     | 接受一个二元函数,并依次将二元函数运用到累计值和下一个元素上

``` java
Integer[] values = {1,2,3,4,5,6};
Optional<Integer> sum = Stream.of(values).reduce((x,y)-> x + y); // <==> 1+2+3+4+5+6
sum.ifPresent(System.out::println);
```

注意: 上面求和过程中的lambda函数可以使用`Integer::sum`代替. 如果使用`Integer::max`则可以用来求最大值.


如果一个元素e满足`e op x = x`, 即e为单位元时,可以作为reduce的起点,从而保证即使流为空也不用返回Optional对象
``` java
Integer[] values = {1,2,3,4,5,6};
Integer sum = Stream.of(values).reduce(0,(x,y)-> x + y);
System.out.println(sum);
```

转化为集合
---------------------

方法       | 效果
-----------|---------------------
iterator   | 获得一个传统的迭代器
toArray    | 获得数组

注意:由于不能创建运行时的泛型数组,因此toArray()返回Object[]类型的数组. 或者向toArray函数传递一个构造器来获得类型.

``` java
Integer[] values = {1,2,3,4,5,6};

System.out.println("From Iterator");
Iterator<Integer> it = Stream.of(values).iterator();
while (it.hasNext()){
    System.out.println(it.next());
}

System.out.println("From Array");
Integer[] re = Stream.of(values).toArray(Integer[]::new);
for (Integer i: re) {
    System.out.println(i);
}
```

Collect操作
-----------------------

Stream的collect操作是一个通用的操作,接受一个收集器,返回各种类型的收集结果. 以下介绍收集成各种不同类型时应该使用的收集器


### 收集为表

使用Collectors的以下方法来产生指定的收集器

方法名         | 说明
--------------|---------------------------------------
toList        | 产生收集为List的收集器
toSet         | 产生收集为Set的收集器
toColection   | 指定一个构造器,产生指定类型的Set


``` java
List<String> rlist = stream.of(words).collect(Collectors.toList());
Set<String> rset = stream.of(words).collect(Collectors.toSet());
HashSet<String> set = Stream.of(words).collect(Collectors.toCollection(HashSet::new));
```

注意: 实际的代码中, 直接静态导入Collectors类的方法能进一步简化代码

### 收集为Map

使用Collectors的以下方法来产生指定的收集器

方法名      | 说明
-----------|----------------------------------------------------
toMap      | 接受两个参数,分别提取键和值,产生收集为Map的收集器

注意: 虽然可以使用Function.identity()函数来获得实际的元素本身, 但使用`e -> e`可能更简短

``` java
Map<Integer,String> idToName = people.collect(Collectors.toMap(Person::getID,Person::getName));
Map<Integer,Person> idToPerson = people.collect(Collectors.toMap(Person::getID, e -> e);
```

**如果有多个元素具有同样的key, 此方法会抛出IllegalStateException.** 针对这种冲突, Collectors提供了groupingby方法来处理这种情况.


### 转化为字符串

使用Collectors提供的以下方法产生的收集器可以将一个流转化为一个字符串

方法名            | 说明
-----------------|---------------------------------------
joining()        | 返回一个可以将字符串连接起来的收集器
joining(String)  | 接受一个字符串作为各个元素之间的分隔符

```java
String result = Stream.of(words).collect(Collectors.joining("?"));   //用?隔开各个元素的字符串
```

注意: 使用此方法连接的字符串, 内部使用了StringBuilder, 因此比使用reduce方法连接效率更高

### 转化为数字统计

如果对之后的结果需要进行最大值,最小值,平均值等数据的统计操作,可以将流转化为一个TYPESummaryStatistic类型. 其中TYPE为Int,Double或者Long. 可以分别使用Collector的如下方法

方法名            | 说明
-----------------|---------------------------------------------------------------------
summarizingTYPE  | 产生一个生成TYPESummaryStatistic的收集器,其中TYPE是Int,Double或者Long


```java
IntSummaryStatistics summary = Stream.of(words).collect(Collectors.summarizingInt(String::length));
double averWordLength = summary.getAverage();
double maxWordLength = summary.getMax();
```

原始类型流
----------------------

由于Stream中使用原始类型需要进行装箱, 效率很低, 因此对于基础类型, Stream提供了特殊的一类Stream, 包括IntStream, LongStream和DoubleStream.

可以使用如下的方法获得原始类型流, 以下均以Int为例,其他类型方法名类似.

来源类           | 方法名           | 说明
----------------|------------------|------------------------------------------------
IntStream       | of               | 可变参数函数,接受零散的值或者同类型数组
Arrays          | stream           | 将对应类型的数组转化为Stream
IntStream       | range            | 产生一个指定返回的Stream,类似Python中的range
Stream          | maptoInt         | 将一个流转化为IntStream
Random          | ints             | 一个包含随机数字的IntStream

如果想把原始类型流转化为对象流, 可以使用`boxed`方法


原始类型流除了不用进行装箱操作以外, 还提供了一组额外的操作, 以便于进行数值上的计算, 例如`sum`方法可以直接进行求和. 

分组
-------------------

Collectors提供函数以下的方法,根据指定的条件将流进行分组

方法名            | 说明
-----------------|---------------------------------------
groupingBy       | 根据指定的条件分组,类似SQL的`GROUP BY`
partitioningBy   | 接受一个Prediction,将流分成两类

``` java
Stream<Locale> locales = Stream.of(Locale.getAvailableLocales());
// 按照国家名称分类,以国家名称为键,语言代码的集合为值
Map<String, List<Locale>> countryToLocales = locales.collect(Collectors.groupingBy(Locale::getCountry));
List<Locale> cn = countryToLocales.get("CN");
cn.forEach(System.out::println);
```


并行流
--------------

来源类           | 方法名           | 说明
----------------|------------------|------------------------------
Collection      | parallelStream() | 任意集合类都可以直接创建并行流
Stream          | parallel()       | 任意流都可以转化为并行流
Stream          | sequential()     | 任意流都可以转化为串行流

调用`parallel() `方法后, 流的内部进行了一个标记, 表示之后的操作都希望并行执行, 同样, 调用`sequential()`表示后续所有操作都希望按照串行执行. 

并行流的内部使用了ForkJoinPool, 默认使用的线程数量与和处理数量一致. 并行流对于线程安全问题不做任何保证, 因此其中执行的方法要求保证是线程安全的.


### 高效实用并行流

1. 并非任何时候采用并行流都会获得更高的性能, 当任务不容易切分时, 可能因为线程的开销导致性能反而低于串行流. 
2. 注意自动装箱机制, 尽量使用原始类型流
3. 依赖顺序的方法,例如limit或findFirst的性能在并行流上更差, 此时可以考虑使用不依赖顺序的方法或者使用unorder方法
4. 数据量较小或者处理每个元素的时间占比低的情况下不适合使用并行流
5. 如果数据结构不易分解, 不适合使用并行流

各种数据源可分解程度如下表所示:

源              | 可分解性       | 源              | 可分解性
----------------|---------------|----------------|------------
ArrayList       | 极佳          | IntStream.range | 极佳
HashSet         | 好            | TreeSet         | 好
LinkedList      | 差            | Stream.iteratr  | 差



Stream原理
--------------

对于看过函数式编程, 或者学习过LISP语言的人来说, Stream的原理并不复杂. 对于所有的操作, 在执行终止操作前, 都通过函数式的方式组合到一起. 组合到一起的原理和`compose`或者`andThen`函数并没有什么太大的区别.

- [深入理解Java Stream流水线](https://www.cnblogs.com/CarpenterLee/p/6637118.html)
