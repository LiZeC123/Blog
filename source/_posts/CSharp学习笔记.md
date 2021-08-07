---
title: CSharp学习笔记
date: 2017-12-23 10:29:33
tags:
	- CSharp
cover_picture: images/cs.jpg
---

这是关于C#的学习笔记,假定读者已经具有C与Java的基础,本文只涉及与这两种语言有差异的C#特性


目录
------------------
- [基本语句](#base)
- [基本类型属性与方法](#func)
- [类与函数](#class)
- [垃圾回收与资源管理](#gc)
- [属性与索引器](#extern)
- [泛型](#generics)
- [委托与事件](#delegate)
- [LINQ](#LINQ)
- [窗体和控件](#windows)



<span id="base" />
基本语句
-----------------------

#### 格式码
- 一般格式为`{N [,M]: D}`
- N为一个数字,表示对应第n个参数
- M为一个数字,表示总长度,为负数时表示左对齐
- D表示格式码,具有如下选项

格式码  |  含义         |
-------|---------------|
C      |  金额
D      |  十进制整数
F	   |  浮点数
0	   |  指定具体的长度,不足用0填充
`#`    |  同0,但省略无效的0

``` cs
示例                                        | 结果
--------------------------------------------|--------------------
Console.WriteLine("{0:F4}",10.5);           | 10.5000
Console.WriteLine("{0:D5}",12);	            | 00012
Console.WriteLine("{0:00000}", 123);        | 00123
Console.WriteLine("{0:000}", 12345);        | 12345
Console.WriteLine("{0:0000}", 123.64);      | 0124
Console.WriteLine("{0:00.00}", 123.6484);   | 123.65
Console.WriteLine("{0:####}", 123);         | 123
Console.WriteLine("{0:####}", 123.64);      | 124
Console.WriteLine("{0:####.###}", 123.64);  | 123.64
Console.WriteLine("{0:####.##}", 0);        | 0
Console.WriteLine("{0:####.##}", 123.648);  | 123.65
``` 


注意:
- 上述格式码还可以在`String.Format`和`ToString`函数中使用
- 在DateTime的ToString函数中还可以通过y,M,d,h,m,s来格式化时间


#### checked与unchecked关键字
- 使用checked关键字可以对其后的语句中的算术运算进行溢出检查
	- 只适用于整数,如int和long
	- 如果计算结果溢出,会抛出OverflowException
- 使用unchecked关键字可以强制不进行溢出检查
	- 无论是否溢出,都必定不会抛出OverflowException
``` cs
int m = int.MaxValue
int n = checked(m + 1);		// 抛出异常
int o = unchecked(m + 1);	// 不抛出异常

```

#### 使用params object[]
- 实现可变参数, 使用此方式声明的函数可以对应任意数量的任意类型的参数
``` CSharp
void Hole(params object[] args);

Hole();                 // => Hole(new Object[0])
Hole(null);             
Hole(array);            
Hole("string",3);       // => Hole(new Object[]{"string",3})

// Console.WriteLine方法的声明
public static void WriteLine(string format, params object[] args)
```



#### 可空类型
- 对于值类型的变量,不能设置为null,但可以通过可空类型实现这一点
- 在基础类型后加上一个`?`构成相应的可空类型
- 正常的值类型变量可以赋值给相应的可空类型,但反之不行
- 任意可空类型具有两个属性,HasValue用来判断是否为空,Value用来读取变量值
- 其中Value是只读属性,如果需要修改变量,还是需要使用普通的赋值语句

``` CSharp
int ? i = null;
int j = 19;
i = 19; 	// 正常类型向可空类型赋值,允许
j = i;		// 可空类型向正常类型赋值,不允许

if(!i.HasValue)
{
	i = 99;
}
else
{
	Console.WriteLine(i.value);
}

```

#### ref与out关键字
- ref和out都用于函数形参声明
- ref表示引用这个参数,无论这个参数是一个类还是一个基本类型
- out与ref效果相同,但是ref要求传入的参数必须已经初始化,而out没有这一要求
- out主要用于在函数内向外部的参数赋值
- ref与out都带有一定的语义信息,有时虽然没有效果,但是可以起到提示其他程序员的效果
- 函数调用时,对应的实际参数也需要加上ref或out关键字
``` CSharp
int addOne(ref int n){
	n = n + 1;
}

int initToThree(out int n){
	n = 3;
}


int m()
{
	int n;
	initToThree(out n); 	// n = 3
	addOne(ref n)			// n = 4
}

```

#### is与as关键字
- is用于判断一个实例是不是属于一个类,可以用于辅助类型转换
- as尝试将一个实例转化为一个指定的类
	- 如果成功,则返回指定的类
	- 如果失败,则返回null
``` CSharp
WarppedInt wi = new WarppedInt();
...
object o = wi;
if(o is WarppedInt){
	// do
}


WarppedInt temp = o as WarppedInt
if(temp != null){
	// do
}

```

#### foreach循环
- 使用foreach in 的格式进行foreach循环, 语义和个语言一致
- 迭代变量是只读的,不可修改


<span id="func" />
基本类型属性与方法
-----------------------

### String常用属性和方法

函数									| 作用
:---------------------------------------|:----------------------------------------------------
String.Empty							| 空字符串
string.Compare(string s1,string s2)		| 逐一比较字符, s1大时返回1,否则返回0或者-1
Contains( string value )				| 返回是否包含指定的字符串
IndexOf(string s, int startIndex)		| 返回给定字串第一次出现位置的索引, 第二个参数可以省略
LastIndexOf()							| 参数与IndexOf类似,但返回最后一次出现的位置
IndexOfAny(char[] anyOf)				| 返回给定数组中任意字符第一次出现的索引
Substring(int startIndex, int count)	| 从指定位置截取指定长度的字符串
Remove(int startIndex,int count) 		| 删除指定内容,返回新字符串
Replace (string oldStr,string newStr) 	| 替换指定内容,返回新字符串
Insert(int startIndex,string value) 	| 插入指定的内容,返回新字符串
Join(string separator, string[] value)  | 将给定的字符串数组使用指定的分隔符连接组成一个新的字符串
Split(params char[] separator)			| 使用指定的分隔符切分当前的字符串
ToUpper()								| 转化为大写
toLower()								| 转化为小写

### 多维数组和交错数组

```cs
// 多维数组时真的多维数组
int[,] arr = new int[3,5];
int[,] n2 = new int[,] { {1, 2}, {3, 4}, {5, 6} };

// 交错数组就是数组的数组,每行长度可以不一致
int[][] n1 = new int[2][ ] 
{
    new int[ ] {2,4,6}, 
    new int[ ] {1,3,5,7,9}
};

arr[2, 3] = 4;
n1[1][2] = 2;

// 使用Resize函数可以调整数组大小
// 如果新数组小于原数组,则忽略之后的元素
// 如果新数组大于原数组, 补充0
// 如果一样大,则不进行任何操作, 注意使用ref关键字
int[] arr = new int[] { 1, 2, 3, 4, 5 };
Array.Resize(ref arr, 3);

```

此外数组还提供Average,Sum,Max,Min,Sort,Reverse进行简单的数据操作






<span id="class" />
类与函数
--------------------

#### 枚举
- 与C一样,枚举对应的是一个整数
- 每个枚举类型变量都可以使用ToString函数输出对应的名称
- 使用强制类型转换可以得到枚举变量对应的数字
- 可以手动指定某一个枚举值的具体数值,也可以将两个枚举值设为同样的数值
``` CSharp
enum Season 
{
	Spring = 1,			// 手动指定值
	Summer,
	Fall,				
	Autumn = Fall,		// 设为同样的值,进行某种意义上的兼容
	Winter
};

Season ? colorful = null;
colorful = Season.Fall;
Console.WriteLine(colorful.ToString());
```
- 使用Enum.GetNames和Enum.GetValues获得枚举的名称和值
	- 两个函数都接受一个Type类型变量,可以使用typeof(枚举集合名)获得相应的Type类型对象

``` cs
var list = Enum.GetNames(typeof(Season));	// 获得Season的枚举名,即 Spring,Summer,...
```


#### 结构
- 与C一样,C#的结构也是一个值类型,并且存放于栈上
- 与类相比,结构有一些差异
	- 结构不能定义无参数构造函数
	- 结构不能在声明中初始化
	- 结构可以使用new创建,也可以直接声明,两种方式都是创建在栈上



#### 函数覆盖与重载
- C#中,所有函数默认是非虚的,因此如果希望此函数可以多态,则必须使用virtual关键字声明
- 如果没有任何设置,在子类中覆盖了一个父类的函数,编译器会提出警告
- 可以使用new关键字引导一个函数,表示自己就是要覆盖一个非虚的函数,让编译器安心
- 在子类中,使用base调用父类的函数
- 注意,使用override关键字时,才是重写,此时会检查是否重写的是虚函数等操作
- 如果不使用override关键字,直接定义函数,是覆盖操作
``` Csharp
class Mammal
{
	public void Talk()
	{
		// do something
	}
}

class Horse:Mammal
{
	new public void Talk()
	{
		// do something others
	}
}

// Object中ToString的示例
class Object
{
	public virtual string ToString()
	{
		...
	}
}

class MyClass
{
	public override string ToString()
	{
		base.ToString()
		...
	}
}

```

#### 扩展方法
- 对于一个类,有时可能只是想扩展一个方法,但直接继承会编写大量重复的代码
- 可以使用扩展方法对当前的类或结构进行扩展
- 需要定义一个静态类,在这个类中,为需要扩展的类或结构提供静态方法
- 使用this关键字引导,后面是需要扩展的类型
``` Csharp
static class Util
{
	// 为int类型扩展一个取反的方法
	public static int Negate(this int i)
	{
		return -1;
	}
}


// 在其他地方可以直接调用扩展的方法
int x = 42;
Console.WriteLine("x.Negate {0}", x.Negate());
```

#### 密封类
- 使用sealed修饰一个类表示此类不可作为基类
- 使用sealed修饰方法可以使一个虚方法不可再次被重写

#### 接口,抽象类,抽象方法
- 与Java一致,使用interface定义接口,使用abstract定义抽象类和抽象方法


<span id = "gc" />
垃圾回收和资源管理

#### 托管资源与非托管资源
- 与Java一样,C#会自动管理所有的托管资源,例如分配的内存
- 对于非托管资源,C#有析构机制,从而可以类似C++的释放资源
- 非托管资源常见有文件流,网络连接,数据库连接等

#### 析构器
- 析构函数声明方法与C++一致
- C#对析构函数的实现机制保证了即使在析构函数中发生异常也可以保证调用父类的析构函数
- 实现了析构器的类在内存回收的时候会先进入一个队列
	- 回收机制在保证这些类的析构方法被调用以后才会进行内存释放
	- 不定义析构器则可以避免这一过程,从而提高运行效率
	- 析构函数的调用时机是不确定且无法控制的
- 因此虽然析构函数有着和C++析构函数一样的名称,但实际上更加接近Java的finalize()方法`

#### 资源清理
- 除了定义析构函数以外,还可以定义资源清理函数来手动释放资源,从而明确资源的释放时间
- 以下演示了如何同时使用析构函数和资源清理函数


``` CSharp
class Example : IDisposable
{
	private Reasource scarce;
	private bool disposed = false;

	~Example()
	{
		this.Dispose(false);
	}

	public virtual void Dispose()
	{
		// 被用户手动调用了
		this.Dispose(true);
		GC.SupressFinalize(this);		// 告诉GC不要调用此方法的析构函数
	}

	public virtual void Dispose(bool disposing)
	{
		if(!this.disposed)
		{
			if(disposing)
			{
				// 此处释放托管资源,例如将大型数组置为null
			}
			// 此处释放非托管资源,例如文件流

			this.disposed = true;
		}
	}

	public void someBahavior()
	{
		checkIfDisposed();	// 每个常规方法都需要检查资源是否被释放
		...
	}

	private void checkIfDisposed()
	{
		if(this.disposed)
		{
			throw new ObjectDisposedException("对象已经被清理");
		}
	}
}
```

注意:
- 由于析构函数与资源清理函数都实现了同样的功能,而又没有强制资源清理函数一定被调用,因此存在多种可能的情况
- 接受bool值的Dispose函数通过对this.dispoesd的检查,保证此方法可以被多次调用,从而无论析构函数与Dispose函数如何调用,都能保证最后资源被正确的释放
- 用户手动调用时,释放非托管资源并将托管资源置null(便于垃圾回收器标记和清除),并且通知GC不要调用析构函数
- 用户没有手动调用时,则在析构函数中释放非托管资源,由于此时已经进入垃圾回收过程,因此不需要将托管资源置为null
- 由于用户可以手动释放资源,因此在每个方法中都需要检查非托管资源是否被释放
- 对this.dispoesd的检查不是线程安全的, 因此多线程下可以考虑加锁(使用`lock(this)`语句块)


#### using语句与IDisposeable接口
- 通过此组合实现对某些资源的自动管理,使资源可以得到立即的释放
- using后的类型必须实现了IDisposable接口
- 注意: 内存始终是由垃圾回收机制管理的,这里的资源释放指的是对象内部持有的非托管资源的释放(例如文件流)
``` CSharp
using(TextReader reader = new StreamReader(filename))
{
	string line;
	while((line = reader.ReadLine()) != null)
	{
		Console.WriteLine(line);
	}
}

<==>

{
	TextReader reader = new StreamReader(filename);
	try
	{
		string line;
		while((line = reader.ReadLine()) != null)
		{
			Console.WriteLine(line);
		}
	}
	finally
	{
		if(reader != null)
		{
			((IDisposable)reader).Dispose();
		}
	}
}


```


<span id="extern" />
扩展
-----------------------

#### 属性
- 是字段和方法的集合,看起来像字段,用起来像方法
``` CSharp
struct ScreenPoint
{
	private int _x, _y;

	public int X
	{
		get {return this._x;}
		set {this._x = rangeChecked(value);}
	}
}
```
- 通过控制是否创建get与set,可以决定属性是否只读,只写或者执行某些检查等
- 注意:C#不推荐使用下划线开头的命名方法,但此处是例外

#### 自动生成属性
- C#编译器可以自动生成属性的get与set方法
- 后续如果添加逻辑,也可以直接更改此方法,不用修改其他地方

``` CSharp
class Circle
{
	public int Radius{get; set;}
}
```

#### 索引器
- 通过定义索引器,使一个实例可以像数组一样使用
``` CSharp
struct IntBits
{
	public bool this[int index]
	{
		get
		{
			return (bits & (1 << index)) != 0;
		}

		set
		{
			if(value)
				bits |= (1 << index);
			else
				bits &= ~(1 << index);
		}
	}
}

```


<span id="generics" />
泛型
--------------------------

#### 泛型
- 泛型的方法与Java基本一致

#### 范型约束
- 如果定义的某种范型要求其实例必须实现某种方法可以按照如下格式定义
- 例如以下声明要求实际的T类型必须实现IPrintable接口,否则会报告编译错误
``` CSharp
public calss PrintableCollection<T> where T : IPrintable { ... }
```

#### 泛型库
集合  						| 说明
:---------------------------|:---------------------------
`List<T>`     				| 列表
`Queue<T>`					| 队列
`Stack<T>`					| 堆栈
`LinkedList<T>`		 		| 双向链表,对两端的插入与删除做了优化
`HashSet<T>`				| 集合
`Dictionary<TKey,TValue>`	| 哈希表
`SortedList<TKey,TValue>`	| 有序列表,必须实现IComparable接口

#### 协变接口和逆变接口
- 协变性:如果泛型接口中的方法能返回字符串,那么也能返回对象(所有字符串都是对象)
- 逆变性: 如果泛型接口中的方法能获得对象参数,那么也能获得字符串参数(所有对象能做的事情,字符串都能做)
- 协变性在泛型名前加上`out`关键字,逆变性在泛型名前加上`in`关键字


#### 枚举集合
- 实现了`System.Collections.IEnumerable`接口的集合
- 枚举集合可以被foreach遍历




<span id="delegate" />
委托与事件
---------------------------

#### 委托
- 之所以称为委托,是因为一旦被调用,就"委托"所引用的方法进行处理
- 看起来像一个函数指针,但委托是类型安全的,且一个委托可以同时引用多个方法
- 定义方法
``` CSharp
class Controller
{
	delegate void stopMachineryDelegate();         // 定义委托
	private stopMachineryDelegate stopMachinery    // 创建委托实例

	...
	public Controller()
	{
		this.stopMachinery += folder.StopFolding;  // 添加引用
		this.stopMachinery += welder.FinishWelding;
	}

	public Shutdown()
	{
		this.stopMachinery();                      //调用
	}
}
```
- 调用委托与调用一个函数方法没有区别
- 通过委托可以实现执行过程与方法名,方法数量无关,从而将代码逻辑分离

#### Lambda表达式
- 声明形式与各语言差不多,使用`=>`表示箭头
``` CSharp
x => x*x;
() => folder.StopFolding(0);
(x,y) => {x++;return x/y;};
(ref int x, int y) {}

```
- 可以作为函数直接添加到委托中
- 也可以作为配适器来配饰接口和实际函数


#### 事件
- 格式
``` CSharp
event delegateTypeName eventName
```
- 一个事件的定义依赖于一个委托,委托实际上是提供了函数的结构
- 事件也可以添加方法且和委托的添加方法一致
- 引发事件时,会自动的调用所有在事件上登记的方法
- 事件的引发方法和函数调用一致,且C#限制一个时间只能在被定义的类中被调用

``` cs
class TemperatureMonitor
{
	public delegate void StopMachineryDelegate();
	public event StopMachineryDelegate MachineOverheating;


	private void Notify()
	{
		// 事件默认为空,因此有必要检查是否为null
		if(this.MachineOverheating == null)
		{
			// 引发事件
			this.MachineOverheating();
		}
	}
}
```


<span id = "LINQ">
LINQ


#### 什么是LINQ
LINQ意为语言集成查询(Language Integrated Query,LINQ). LINQ语言设计时借鉴了很多数据库管理系统的经验. 因此LINQ使用起来与SQL有很多相似之处.

以下语句分别演示了使用LINQ语句进行Select,Where,OrderBy以及Join操作,这些操作的含义与SQL语句中的含义完全一致.

注意: 由于Select语句执行以后,就变成选定元素组成的集合了,因此大多数的限制性操作(例如Where或From)都必须在Select语句之前执行
``` cs
var furitList = new[]
{
	new {ID = 1,Name = "Apple",Price = 4.5},
	new {ID = 2,Name = "Banana",Price = 4.0},
	new {ID = 3,Name = "Orange",Price = 3.0},
	new {ID = 4,Name = "Others",Price = 99.9}
};

var addresses = new[]
{
	new {Name = "Apple",City = "Ax"},
	new {Name = "Banana",City = "Bh"},
	new {Name = "Orange",City = "Cy"},
	new {Name = "None",City = "None"}
};

var Names = furitList.Where(fruit => fruit.Name.Length > 5)
						.Select(furit => furit.Name);

foreach (var name in Names){
	Console.WriteLine(name);
}

var OrderNames = addresses.OrderBy(addr => addr.Name).Select(addr => addr.Name);

var list = furitList
	.Select(furit => new { furit.Name, furit.Price })
	.Join(addresses,
		fruit => fruit.Name,
		addr => addr.Name,
		(fruit, addr) => new { fruit.Name, fruit.Price, addr.City });
```


#### 使用查询操作符
除了上述提到的使用各种函数调用来实现查询以外,LINQ也提供了一组操作符来使LINQ查询更加像SQL语句,例如上例中的查询语句可以进行如下的替换
``` cs
var Names = furitList.Where(fruit => fruit.Name.Length > 5)
						.Select(furit => furit.Name);
```
等价与
``` cs
var Names = from furit in furitList
				where furit.Name.Length > 5
				select furit.Name;
```

此外LINQ还提供了集合操作等其他SQL语句中的方法,具体内容可以查阅文档.

