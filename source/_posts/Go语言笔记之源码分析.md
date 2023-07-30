---
title: Go语言笔记之源码分析
math: false
date: 2023-07-30 21:30:10
categories:
tags:
cover_picture:
---



sync/atomic包
--------------

### Value

在GO语言中, 对于小于64位的基本类型和指针类型, 其赋值操作是原子的, 可以不加锁的进行并发赋值. 但对于复杂的数据结构, 无法保证原子的赋值. Go提供了Value对象来原子的对任意类型赋值. 其Store函数源码如下:

```go
func (v *Value) Store(val any) {
	if val == nil {
		panic("sync/atomic: store of nil value into Value")
	}
    // Value对象实际就是一个interface{}, 而interface{}可以视为一个包含两个指针字段的结构体
    // 其中字段typ表示类型, data表示实际的值
    // 无论val是什么类型, 进入Store函数后, val都是指向实际数据的interface{}对象
	vp := (*ifaceWords)(unsafe.Pointer(v))
	vlp := (*ifaceWords)(unsafe.Pointer(&val))
	for {
        // 由于interface{}对象包含两个字段, 实际上这个函数要做的就是一致性的写入两个字段
		typ := LoadPointer(&vp.typ)
		if typ == nil {
            // 首先获取当前对象的type字段, 如果为空, 说明之前从未写入过任何数据, 这是第一次尝试写入数据
			runtime_procPin()   // 此函数关闭Go语言的协程调度
            // 首先尝试CAS更新type字段, 将其设置为更新的标记
			if !CompareAndSwapPointer(&vp.typ, nil, unsafe.Pointer(&firstStoreInProgress)) {
                // CAS失败, 等价于其他协程获得锁, 当前协程进入自旋
				runtime_procUnpin()
				continue
			}
			// CAS成功等价于当前协程获得锁, 因此执行更新操作
			StorePointer(&vp.data, vlp.data)
			StorePointer(&vp.typ, vlp.typ)
			runtime_procUnpin()
			return
		}
        // 如果当前的type标记为更新状态
        // 说明其他协程正在更新, 因此当前协程进行自旋等待
        // 等待其他协程更新完毕后, 当前协程可直接更新data部分
		if typ == unsafe.Pointer(&firstStoreInProgress) {
			continue
		}
		// 如果type不是nil, 说明之前已经设置过类型, 此时进行判断
        // Value对象不能存储不同类型的数据
		if typ != vlp.typ {
			panic("sync/atomic: store of inconsistently typed value into Value")
		}
        // 类型相同时, 更新操作值需要更新一个data字段, 此时直接更新即可
		StorePointer(&vp.data, vlp.data)
		return
	}
}


// ifaceWords is interface{} internal representation.
type ifaceWords struct {
	typ  unsafe.Pointer
	data unsafe.Pointer
}
```

> 上述接口非常巧妙地利用了Go语言中interface{}对象的结构, 用一种简单的方式实现了对象的原子复制