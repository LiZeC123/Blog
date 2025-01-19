---
title: 《SICP》读书笔记
date: 2017-09-01 11:24:10
tags:
	- 函数式编程
---

About This Book
----------------------
`Structure and Interpretation of Computer Programs`(also named as  `SICP`) is a textbook about the principles of computer programming,such as abstraction in programming, metalinguistic abstracion, recursion, interpreters, and modular programming. It is widely considered a classic text in computer science. SCIP focuses on finding general patterns from specific problem and building software tools that embody each pattern. 

### How to Start Learning This Book
1. Get this book.
2. Get Scheme dialect of Lisp.
3. Get all code of this book.

You can get all of those above from https://mitpress.mit.edu/sicp/

### How to Use Edwin
When I first tried to learn Sheme, I had a lot of problem about how to use the interpreter. One of the main reason is that Edwin is an Emacs-like editor, which is not easy for beginner to use. Therefore, I want to give an outline of Edwin. 

Edwin is an Emace-like editor, that is, all the usages of Edwin are almost same as Emacs. Emacs is a famous editor in Linux platforms, and almost all the commands used by Emacs are begin with Ctrl key or Alt key.Now I give some the most used commands to help beginner to use Edwin. In the following, the prefix `C-` refers to the Ctrl key. For example, `C-x` means to simultaneously press the Ctrl key and the x key.

command  | means
:--------|:-------------------------------------
C-x c    | close Edwin and back to interpreter
M-z      | evalute the expression
C-i      | auto indent
M-/      | auto complete
C-x C-s  | save this file
C-x C-f  | open a new file
C-x o    | switching windows
C-x 0    | close this windows

For more commands, You can read the article written by me `<<Edwin笔记>>`

Building Abstractions with Procedures
---------------------------------------

### The Elements of Programming
Every powerful language has three mechanisms for accomplishing this:
- **primitive expressions**, which represent the simplest entities the language is concerned with.
- **means of combinatoin**, by which compound elements are built form simpler ones.
- **means of abstraction**, by which compound elements can be named and manipulated as units.

In programming, we deal with two kinds of elements: procedures and data. Thus any powerful programming language should be able to describle primitive data and primitive procedures and should have methonds for combining and abstracting procedures and data.

For example, in Java language, basic statements and basic number are primitive procedures and primitive data, and functions and classes are methonds for combining and abstracting procedures and data. When we defined a class in Java, we can manipulate it as an unit.


### Expressions
- There are some examples about based expressions in Scheme.

``` scheme
486

(+ 137 248)

(* 2.7 12)
```
- Expressions such as these,formed by delimiting a list of expresions within parentheses in order to denote procedure applicartion, are called **combinations**.
- The leftmost element in the list is called the **operator**,and the other elements are called **operands**.
- The value of a combination is obtained by applying the procedure specified by the operator to the **arguments** that are the values of the operands.
- The convention of placing the operator to the left of the operands is konwn as **prefix** notation.
- Prefix notation has several advantages
	- it can accommodate procedures that may take an arbitray number of arguments.
	- it extends in a straightforward way to allow combinations to be **nested**,that is, to have combinatons whose elements are themselver combinations

``` scheme
(+ 137 248 342 23)

(* (+ 4 3) (- 10 3))
```

- There is no limit to the depth of such nesting and to the overall complexity of the expressions that the Lisp interpreter can evaluate.
- We can use a formatting convention known as **pretty-printing**, in which each long combination is written so that the operands are aligned vertically.

``` scheme
(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))

(+ (* 3
      (+ (* 2 4)
   		(+ 3 5)))
   (+ (- 10 7)
      6))
```

### Read-Eval-Print Loop

- The interpreter always operates in the same basic cycle
	1. read an expression from the terminal
	2. evaluate the expression
	3. print the result
- This mode of operation is often expressed by saying that the interpreter runs in a **read-eval-print loop**(REPL).

### Naming
- A critical aspect of a programming language is the means it provides for using names to refer to computational objects.
- In the Scheme dialect of Lisp, we name things with **define**.

``` Scheme
(define size 2)

(* size 5)

(define PI 3.1415)

(* 2 PI size)
```
 
### Evaluating Combinations
- To evaluate a combination, do the following:
	1. Evaluate the subexpressions of the combination
	2. Apply the procedure that is the value of the leftmost subexpression(the operator) to the arguments that are the value of the other subexpressions(the operands).

### Evaluating Combinations
#### Applicative order
- To evaluate a combination, do the following:
    - Evaluate the subexpressions of the combination.
    - Apply the proceduce that is the value of the leftmost subexpression (the operator) to the arguments that are the values of the other subexpressions.

#### Normal order
- To evaluate a combination, do the following:
    - Not evaluate a combination until its value was needed.
    - substitute operand expressions for parameters until it obtained an expression involving only primitive operators,and would then preform the evaluation.

#### Which is used in Scheme?
- Lisp uses **applicative-order** evaluation,partly because of the additional efficiency obtained from avoiding multiple evaluation of ecpressions.
- normal-order evaluation becomes much more complicated to deal with when we leave the realm of procedures that can be modeled by substitution.
- On the other hand, normal-order evaluation can be an extremely valuable tool.

### Compound Procedures
We can use a much more powerful abstraction technique by which a compound operation can be given a name and then referred to as a unit.
``` Scheme

; General Form
(define (<name> <formal parameters>) <body>)

; Examples
(define (square x) (* x x))
(define (return42 x)  42 )
(define (sum-of-square x y) (+ (square x) (square y)))
(define (f a) (sum-of-square (+ a 1) (* a 2)))
(square 5)
(square (+ 3 1))

```

<span id="Substitution_Model"></span>
### The Substitution Model for Procedure Application
The iterpreter follows much the samme process as for combinations whose operator name primitive procedures. To apply a compound procedure to arguments, evaluate the body of the procedure with each formal parameter replaced by the corresponding argument.
``` Scheme
; we can try to evaluate the combination
(f 5)
=> (sum-of-square (+ 5 1) (* 5 2))
=> (sum-of-square 6 10)
=> (+ (square 6) (square 10))
=> (+ 36 100)
=> 136

```
The purpose of the substitution is to help us think about procedure application, not to provide a description of how the interpreter really works. But it is still an important model whicn can explain many question.

### Condtional Expressions and Predicates

``` Scheme
;General Form
(cond (<p1> <e1>)
	  (<p2> <e2>)
	  ...
	  (<pn> <en>))

(cond (<p1> <e1>)
	  (<p2> <e2>)
	  ...
	  (else <e>))

(if <predicate> <consequent> <alternative>)

; Example
(define (abs x)
  (cond ((> x 0) x)
  ((= x 0) 0)
  ((< x 0) (- x))))

(define (abs x)
  (cond ((> x 0) x)
  (else (- x))))

(define (abs x)
   (if (< x 0)
       (- x)
       x))
```
- Conditional expressions are evaluated as follows.
    - The predicate `<p1>` is evaluated first. If its value is false, then `<p2>` is evaluated.
    - If `<p2>`'s value is also false, then `<p3>` is evaluated.
    - This process continues until a predicate is found whose value is true, in which case the interpreter returns the value of the corresponding consequent expression.
    - If none of the `<p>`'s value is true, the value of the cond is **undefined**.
- If expressions are evaluated as follows.
    - The interpreter starts by evaluating the `<predicate>` part of expression.
    - If the `<predicate>` evaluates to a true value,the interpreter then evaluates the `<consequent>` and return its values
    - Otherwise it evaluates the `<alternative>` and return its values.
- **Attention:** Conditional expression and If expression are **special form**, that is, this expression can't be replaced by an ordinary procedure.

#### Why If Expression Must Be a Special Form
We can just try to define a funtion to replace if expression, for example
``` Scheme
(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
		(else else-clause)))
```
If we use this new-if like this:
``` Scheme
(new-if (= 2 3) 0 5) 
;value 5
(new-if (= 1 2) 0 5)
;value 0
```
It is seems that new-if can work euqally. But if we use new-if in a more complicated procedure, we will find a tiny difference of if expression and new-if. The difference is also the reason why if expression must be a special form.
``` Scheme
(define (iter guess x)
  (new-if (= guess x)
          guess
          (iter (- guess 1) x)))

(iter 10 3)
;Aborting!: maximum recursion depth exceeded
```
If we use `if expression`, interpreter print the value 3 as we expected. But if we use new-if,interpreter tell us maximum recursion depth exceeded. In fact, we can use the [Substitution Model](#Substitution_Model) to analyze this question
```
(iter 10 3)
=> (new-if (= 10 3) 3 (iter (- 10 1) x))
=> (new-if #f 3 (new-if (= 9 3) 3 (iter (- 9 1) x)))
=> (new-if #f 3 (new-if #f 3 (new-if (= 8 3) 3 (iter (- 8 1) x))))
...
```
In order to evaluate the value of new-if, we must first evaluate the value of `(= 10 3)` and `(iter (- 10 1) x)` . In order to evaluate the value of `(iter (- 10 1) x)` , we must fisrt evaluate the value of the new-if. This leads to an infinite recursion. 
However, if expression is different from new-if, if expression only evaluate a subexpression when predicate is decided. Therefore if we overwrite the iter by if expression and use the Substitution Model again, we can get the value we want finally.
```
(iter 10 3)
=> (if (= 10 3) 3 (iter (- 10 1) x))
=> (iter 9 3)
=> (if (= 9 3) 3 (iter (- 9 1) x))
...
=> (iter 3 3)
=> (if (= 3 3) 3 (iter (- 3 1) x))
=> 3
```


#### Logic
```
;General Form
(and <e1> ... <en>)
(or <e1> ... <en>)
(not <e>)

```

#### An Example of Block Structure
``` Scheme
(define (sqrt x)
  (define (square x) (* x x) )
  (define (average x y) (/ (+ x y) 2))
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))

(sqrt 2)
```

We hava already learned the basic usages of those function. And there are two new usages
- **Internal definitions and block structure**. It allows a procedure to have internal definitions that are local to that procedure. 
- **lexical scoping**. It allows x to be a free variable in the internal definitions. Thus, it is not necessary to pass x explicitly to each of these procedures. 
The idea of block structure originated with the programming language Algol 60. It appears in most advanced programming languages and is an important tool for helping to organize the construction of large programs.

#### An Example of Exponentiation
``` Scheme
(define (fast-expt b n)
  (cond ((= n 0) 1)
        ((even? n) (square (fast-expt b (/ n 2))))
        (else (* b (fast-expt b (- n 1))))))

(define (even? n)
  (= (remainder n 2) 0))
```

#### Higher-Order Procedures
Procedures that manipulate procedures are called higher-order proceduces. It can accept procedures as arguments or return proceduces as value.For example, we can define a procedure which computer the sum of the `f(i)` from `i=a` tp `i=b`.
``` Scheme
(define (sum f a next b)
  (if (> a b)
      0
      (+ (f a) (sum f (next a) next b))))

(sum (lambda (x) x) 1 (lambda (x) (+ x 1)) 100)
```

#### Constructing Procedures Using Lambda
In general, lambda is uesd to create procedures in the same way as `define`, except that no name is specified for the procedure
```  Scheme
;General Form
(lambda (<formal-parameters>) <body>)

;An Example
(define (plus4 x) (+ x 4))
; is equivalent to
(define plus4 (lambda (x) (+ x 4)))
```
Like any expression that has a procedure as its value, a lambda expression can be used as the operator in a combination such as
``` Scheme
((lambda (x y z) (+ x (- y z))) 1 3 2)
;Value 2
```

#### Use `let` to create local variables
``` Scheme
;General Form
(let ((<var1> <exp1>)
      (<var2> <exp2>)
      ...
      (<varn> <expn>))
  <body>)

; An Example
(define (f x y)
  (let ((a (+ 1 (* x y)))
	(b (- 1 y)))
    (+ (* x (* a a))
       (* y b)
       (* a b))))
(f 1 2)
;Value 4
```
The fisrt part of the `let` expression is a list of name-expression pairs. When the `let` is evaluated, each name is associated with the value of the corresponding expression. The body of the `let` is evaluated with these names bound as local variables. The way this happens is that the `let`  expression is interpreted as an alternate synatax for
``` Scheme
((lambda (<var1> ... <varn>)
   <body>)
<exp1>
...
<expn>)
```
No new mechanism is required in the interpreter in order to provide local variables. A `let` expression is simply syntactic sugar for the underlying `lambda` application. We can see from this equivalence that the scope of a variable specified by a `let` expression is the body of the `let`


#### Procedures as Returned Values
``` Scheme
(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))


(define (average-damp f)
  (lambda (x) (average x (f x))))

(define (sqrt x)
  (fixed-point (average-damp (lambda (y) (/ x y)))
               1.0))
```
Notice how this formulation makes explicit the three idesa in the method: fixed-point search, average damping, and the fuction `y -> x/y`. It is instructive to compare this formulation of the suqare-root method with the original version. Bear in mind that these procedures express the same process, and notice how much clearer the idea becomes when we express the process in terms of these abstractions.


#### Pair
Scheme provides a compoind structure called a `pair`, which can be constructed with the primitive procedure `cons`. This procedure take two arguments and returns a compound data object that contains the two arguments as pairs. Given a pair, we can extract the parts using the primitive procedures `car` and `cdr`. Thus, we can use `cons`,`car`, and `cdr` as follows:
``` Scheme
(define x (cons 1 2))

(car x)
;Value: 1
(cdr x)
;Value: 2
    
```

Pair is an abstract conception. Therefor the implemention of pair is not importan. For example we can give a solution like this

``` Scheme
(define (cons x y)
  (lambda (m) (m x y)))

(define (car z)
  (z (lambda (p q) p)))

(define (cdr z)
  (z (lambda (p q) q)))
```

we can verify this implemention by  [Substitution Model](#Substitution_Model)


#### Abstraction Barriers
In gerneral, the underlying idea of data abstracion is to identify for each type of data object a basic set of operations in terms of which all manipulations of data objects of that type will be expressed, and then to use only those operations in manipulating the data.

We can also find this idea in the other programming paradigms,such as OOP. This idea can reduce the complexity of programming. We know that the complexity is the major obstacle to build large program. Therefore this idea is widely use in programming paradigms.

