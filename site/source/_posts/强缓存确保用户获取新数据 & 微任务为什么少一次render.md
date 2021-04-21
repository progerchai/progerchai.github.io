---
title: 强缓存确保用户获取新数据 & 微任务为什么少一次render
date: 2021-04-22 00:43:39
tags: [前端, 性能, micro-task, macro-task, cache]
keywords: [前端, 性能, micro-task, macro-task, cache]
---

# 性能优化的两点补充

## 1.强缓存如何确保用户拿到更改后的数据?

强缓存分两种,一种是`Memery cache`,一种是`Disk cache`,如果用户的数据可以从强缓存中拿到,那么即使服务端数据被修改,在该资源还未过期的情况下,客户端还是会从缓存中拿取旧数据.

### 那么如何确保用户拿到更改后的数据呢?

**答案是:** 用户强刷页面跳过`http`缓存获取新数据,或者是关闭 tab 页面,那么浏览器的`Memery cache`就会被清空,下一次访问会重新从服务端获取更改后的数据

而如果数据存在`Disk cache`中,则需要依托浏览器自己的资源算法,他会把“最老的”和“最可能过时的”资源删除来保证自己的内存存储大小不会过大.即使同一个页面,长时间不访问他,等你再一次访问他等时候,你会发现很多原本再 Disk cache 中的资源消失了,重新从服务端进行了获取,这就是归功于浏览器的缓存回收算法

如下,我刷新访问一个页面,发现很多图片资源都走了强缓存,不是`disk cache` 就是`memery cache`

![](/static/notion/Performance-Optimization-Supplement/Untitled.png)

而当我有一段时间不访问这个页面之后,再次进入,发现有一些原本已经缓存了的资源,被重新获取了

![](/static/notion/Performance-Optimization-Supplement/Untitled%201.png)

## 宏任务 和 微任务,为什么使用微任务可以减少一次 render 操作呢?

js 中,事件循环的异步队列有两种: `macro`队列和`micro`队列

- 常见的 macro-task 比如: setTimeout、setInterval、setImmediate、script、I/O 操作、UI 渲染等
- 常见的 micro-task 比如: process.nextTick、Promise、MutationObserver 等

两者的执行顺序是先 macro-task 出队,然后处理 micro-task,但是当那个 macro-task 出队时,任务是一个一个执行的,如下图所示,而 micro-task 出队时,micro-task 是多个打包成一队,一队一队执行的.并且任务执行有一定的顺序,(每当一个 macro-task 完成,接下来会去执行一队的 micro-task,然后执行渲染操作),如此反复进行操作,这点就是问题的关键.

![](/static/notion/Performance-Optimization-Supplement/Untitled%202.png)

当在异步任务中进行 DOM 更新的时候,首先这个更新任务 task 是一个 macro-task,但是脚本本身就是一个 macro-task,所以会有两个 macro-task 被一起推入 macro 队列中

```jsx
优先执行脚本本身这个macro-task(在这里,会往macro队列中新推一个执行DOM更新的macro-task)
->执行空的micro-task
->执行render渲染操作
->执行DOM更新的macro-task
->执行空的micro-task
->执行render渲染操作
这时候的DOM更新才被处理完成
```

如果是 micro 中执行 DOM 更新操作,在执行完脚本本身这个 macro-task 之后,就会执行 DOM 更新这个 micro-task,再执行 render 也就达到了目的

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
